# Host-only terminal harness; capture, layout and pager navigation are native Forth.
require 'pty'
require 'io/console'
require 'timeout'
require 'tmpdir'
RUNTIME = File.expand_path(ARGV.fetch(0, './forth'))
PROMPT = 'Up/Down: line  Left: back  q: quit'
def receive(io, marker)
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
def screen(output, height, width = 80)
  page = output.split("\e[2J").last
  raise 'Missing pager controls' unless page.include?(PROMPT)
  raise 'Page exceeds terminal height' unless page.split(PROMPT).first.count("\n") + 1 < height
  visible = (page.split(PROMPT).first + PROMPT).gsub(/\e\[[0-9;]*[A-Za-z]|\e\([0B]/, '')
  rows = 1
  column = 0
  visible.each_char do |char|
    case char
    when "\n" then rows += 1; column = 0
    when "\r" then column = 0
    when "\b" then column = [column - 1, 0].max
    else
      if column >= width then rows += 1; column = 0 end
      column += 1
    end
  end
  raise 'Wrapped page exceeds terminal height' unless rows < height
  page
end
Dir.mktmpdir do |home|
  master, slave = PTY.open
  slave.winsize = [24, 80]
  original = IO.popen(['stty', '-g'], in: slave, &:read)
  pid = Process.spawn({'HOME'=>home}, RUNTIME, '42 see quit . cr quit', in: slave, out: slave, err: slave)
  begin
    first = screen(receive(master, PROMPT), 24)
    raise 'Missing metadata' unless first.include?('quit') && first.include?('image 0x')
    master.write(' ')
    second = screen(receive(master, PROMPT), 24)
    raise 'Page did not advance' if first == second
    master.write('b')
    back = screen(receive(master, PROMPT), 24)
    raise 'Page back did not restore metadata' unless back.include?('image 0x')
    master.write("\e[B")
    down = screen(receive(master, PROMPT), 24)
    raise 'Down did not move a line' if down == back
    master.write("\e[A")
    screen(receive(master, PROMPT), 24)
    slave.winsize = [12, 60]
    master.write("\e[6~")
    resized = screen(receive(master, PROMPT), 12, 60)
    raise 'Layout was not regenerated at new width' unless resized.include?("\e(0")
    master.write("\r")
    receive(master, "42 \r\n")
    master.write("pager.address @ . output.capture @ . output.vector @ . depth . 888 . cr\n")
    receive(master, "0 0 0 0 888 \r\n")

    # Styling must not disable paging, including long source lines that wrap.
    master.write("tui.off see quit 890 . cr\n")
    plain = screen(receive(master, PROMPT), 12, 60)
    raise 'Plain pager unexpectedly styled' if plain.include?("\e[36m")
    master.write(' ')
    screen(receive(master, PROMPT), 12, 60)
    master.write('q')
    receive(master, "890 \r\n")

    # An existing raw-mode owner must not make SEE skip its pager or lose settings.
    master.write("tui.on debug.terminal.open drop see quit debug.terminal.close 891 . cr\n")
    screen(receive(master, PROMPT), 12, 60)
    master.write('q')
    receive(master, "891 \r\n")

    # Capture enough output to grow the buffer, then interrupt navigation.
    master.write("see kernel.start\n")
    screen(receive(master, PROMPT), 12, 60)
    Process.kill('INT', pid)
    receive(master, 'signal 2')
    master.write("pager.address @ . output.capture @ . output.vector @ . depth . 889 . cr\n")
    receive(master, "0 0 0 0 889 \r\n")
    master.write("bye\n")
    _, status = Timeout.timeout(15) { Process.wait2(pid) }
    raise 'Bad exit status' unless status.success?
    restored = IO.popen(['stty', '-g'], in: slave, &:read)
    raise 'Terminal settings changed' unless original == restored
    puts 'SEE pager: bounded pages, backward/line navigation, resize, stack preservation and interrupt cleanup passed.'
  ensure
    Process.kill('KILL', pid) rescue nil
    Process.wait(pid) rescue nil
    master.close
    slave.close
  end
end
