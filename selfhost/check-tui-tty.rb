# Host-side terminal harness only; all rendering and navigation run in native Forth.
require 'pty'
require 'io/console'
require 'timeout'
require 'tmpdir'
RUNTIME = File.expand_path(ARGV.fetch(0, './forth'))
def read_until(io, marker)
  output = +''
  Timeout.timeout(15) do
    until output.include?(marker)
      IO.select([io])
      output << io.read_nonblock(65536)
    end
  end
  output
rescue Exception
  warn output.inspect
  raise
end
def plain(text)
  graphics = false
  decoded = +''
  text.gsub(/\e\[[0-9;]*[A-Za-z]/, '').scan(/\e\([0B]|./m).each do |part|
    if part == "\e(0"
      graphics = true
    elsif part == "\e(B"
      graphics = false
    else
      decoded << (graphics ? {'l'=>'┌', 'k'=>'┐', 'm'=>'└', 'j'=>'┘', 'q'=>'─', 'x'=>'│', 't'=>'├', 'u'=>'┤'}.fetch(part, part) : part)
    end
  end
  decoded.delete("\r").gsub(/.\x08/, '')
end
def framed(text, width)
  rows = plain(text).lines.map(&:chomp).select { |line| line.match?(/\A[┌└├│]/) }
  raise 'No complete frame' if rows.length < 5
  raise "Incorrect frame width #{rows.map(&:length).uniq}" unless rows.all? { |line| line.length == width }
end
Dir.mktmpdir do |home|
  [80, 120].each do |columns|
    master, slave = PTY.open
    slave.winsize = [50, columns]
    original = IO.popen(['stty', '-g'], in: slave, &:read)
    pid = Process.spawn({'HOME' => home}, RUNTIME, 'see dup', 'quit', in: slave, out: slave, err: slave, chdir: home)
    begin
      # A marker after inspection avoids depending on pauses to identify complete output.
      master.write("777 . cr\n")
      inspected = read_until(master, "777 \r\n")
      raise 'No styling' unless inspected.include?("\e[36m")
      framed(inspected, columns)
      text = plain(inspected)
      raise 'Metadata panel lacks word title' unless text.include?('┌─ dup ─')
      raise 'Metadata is outside the first frame' unless text.index('┌─ dup ─') < text.index('dup  image 0x') && text.index('dup  image 0x') < text.index('┌─ Memory: ─')
      raise 'Title is not embedded in top border' unless text.include?('┌─ Memory: ─')
      raise 'Wrong corners' unless text.include?('┐') && text.include?('└') && text.include?('┘')
      raise 'ASCII corners remain' if text.include?('+---')
      raise 'Wrong display order' unless text.index('Memory:') < text.index('Disassembly (Intel):') && text.index('Disassembly (Intel):') < text.index('Source:')
      raise 'Missing documentation' unless text.include?('Duplicate the top data-stack cell.')

      # A resized terminal is remeasured when the next panel opens.
      slave.winsize = [50, 60]
      master.write("see dup 778 . cr\n")
      resized = read_until(master, "778 \r\n")
      framed(resized, 60)
      slave.winsize = [50, columns]
      master.write("debug.on 10 20 trap\n")
      initial = read_until(master, 'Enter/q: quit debugger')
      framed(initial, columns)
      raise 'RIP not highlighted' unless initial.include?("\e[7m")
      master.write("\e[B")
      down = read_until(master, 'Enter/q: quit debugger')
      raise 'Selected frame not highlighted' unless down.include?("\e[7m")
      raise 'Missing selected caller' unless plain(down).include?('Source: image.call')
      master.write("\e[D")
      left = read_until(master, 'Enter/q: quit debugger')
      raise 'Fault source not restored' unless plain(left).include?('Source: trap')
      master.write('q')
      master.write("output.vector @ . tui.active @ . 779 . cr\n")
      read_until(master, "0 0 779 \r\n")

      master.write("tui.off see dup 780 . cr\n")
      unstyled = read_until(master, "780 \r\n")
      # TUI.OFF can emit a final reset; subsequent inspection contains no frames.
      raise 'Styling stayed enabled' if plain(unstyled).include?('┌')
      master.write("trap\n")
      unstyled_debug = read_until(master, 'Enter/q: quit debugger')
      raise 'Debugger ignored TUI.OFF' if plain(unstyled_debug).include?('┌')
      master.write('q')
      master.write("bye\n")
      _, status = Timeout.timeout(15) { Process.wait2(pid) }
      raise 'Bad exit status' unless status.success?
      restored = IO.popen(['stty', '-g'], in: slave, &:read)
      raise 'Terminal settings changed' unless original == restored
      puts "TUI at #{columns} columns: panels, resize, source ordering, selection, recovery and disable passed."
    ensure
      Process.kill('KILL', pid) rescue nil
      Process.wait(pid) rescue nil
      master.close
      slave.close
    end
  end
end
