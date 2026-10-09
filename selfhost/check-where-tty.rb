# Exercise native WHERE navigation and screen-height limits through a pseudo-terminal.
require 'pty'
require 'io/console'
require 'timeout'
require 'tmpdir'
RUNTIME = File.expand_path(ARGV.fetch(0, './forth'))
FOOTER = 'Up/Down: locations   Enter/q: return'
def receive(io, marker, timeout: 15)
  output = +''
  Timeout.timeout(timeout) do
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
def check_screen(output, selected, height)
  screen = output.split("\e[2J").last
  raise 'Wrong selection' unless screen.include?("location #{selected}/31")
  # Include the footer even if its final newline arrives in the next read.
  visible = screen.split(FOOTER).first + FOOTER
  raise "Screen exceeds #{height} rows" if visible.count("\n") + 1 >= height
  raise 'No selection highlight' unless screen.include?("\e[7m")
end
Dir.mktmpdir do |home|
  master, slave = PTY.open
  slave.winsize = [24, 80]
  original = IO.popen(['stty', '-g'], in: slave, &:read)
  definitions = ': needle.tui 7 ; ' + (1..30).map { |i| ": caller.#{i} needle.tui ;" }.join(' ') + ' : outer.tui caller.15 ;'
  pid = Process.spawn({'HOME'=>home}, RUNTIME, definitions + ' 42 where needle.tui . cr quit', in: slave, out: slave, err: slave, chdir: home)
  begin
    first = receive(master, FOOTER, timeout: 60)
    check_screen(first, 1, 24)
    master.write("\e[A")
    check_screen(receive(master, FOOTER), 1, 24)
    selected_screen = nil
    (2..16).each do |selected|
      master.write("\e[B")
      selected_screen = receive(master, FOOTER)
      check_screen(selected_screen, selected, 24)
    end
    # Follow the selected caller, then its caller, and restore both saved views.
    master.write("\e[C")
    followed = receive(master, FOOTER)
    raise 'Right did not follow caller.15' unless followed.include?('Where: caller.15') && followed.include?('location 1/2')
    master.write("\e[B")
    receive(master, FOOTER)
    master.write("\e[C")
    nested = receive(master, FOOTER)
    raise 'Nested follow failed' unless nested.include?('Where: outer.tui')
    master.write("\e[D")
    restored = receive(master, FOOTER)
    raise 'Nested back lost selection' unless restored.include?('Where: caller.15') && restored.include?('location 2/2')
    master.write("\e[D")
    restored = receive(master, FOOTER)
    check_screen(restored, 16, 24)
    before = selected_screen.split("\e[2J").last.split(FOOTER).first
    after = restored.split("\e[2J").last.split(FOOTER).first
    raise 'Back did not restore exact viewport' unless before == after
    master.write("\e[D")
    check_screen(receive(master, FOOTER), 16, 24)
    slave.winsize = [12, 80]
    master.write("\e[B")
    short = receive(master, FOOTER)
    check_screen(short, 17, 12)
    raise 'Context should be hidden in a short terminal' if short.include?('Selected source:')
    (18..31).each do |selected|
      master.write("\e[B")
      check_screen(receive(master, FOOTER), selected, 12)
    end
    master.write("\e[B")
    check_screen(receive(master, FOOTER), 31, 12)
    master.write("\e[A")
    check_screen(receive(master, FOOTER), 30, 12)
    master.write('q')
    receive(master, "42 \r\n")
    master.write("depth . output.vector @ . where.history @ . 888 . cr\n")
    receive(master, "0 0 0 888 \r\n")
    master.write("where nowhere.in.source\n")
    receive(master, 'No source occurrences.')
    master.write("where needle.tui\n")
    receive(master, FOOTER)
    master.write("\e[B")
    receive(master, FOOTER)
    master.write("\e[C")
    receive(master, FOOTER)
    Process.kill('INT', pid)
    receive(master, 'signal 2')
    master.write("depth . output.vector @ . where.history @ . 889 . cr\n")
    receive(master, "0 0 0 889 \r\n")
    master.write("bye\n")
    _, status = Timeout.timeout(15) { Process.wait2(pid) }
    raise 'Bad exit' unless status.success?
    restored = IO.popen(['stty', '-g'], in: slave, &:read)
    raise 'Terminal settings changed' unless original == restored
    puts 'WHERE navigation, nested follow/back, exact viewport restoration, resize and history cleanup passed.'
  ensure
    Process.kill('KILL', pid) rescue nil
    Process.wait(pid) rescue nil
    master.close
    slave.close
  end
end
