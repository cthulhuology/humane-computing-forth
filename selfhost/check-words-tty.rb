# Exercise dictionary selection and nested SEE paging in a real terminal stream.
require 'pty'
require 'io/console'
require 'timeout'
require 'tmpdir'
RUNTIME = File.expand_path(ARGV.fetch(0, './forth'))
FOOTER = 'Up/Down: select  Enter/Right: see  q: return'
BROWSER_END = '/: search  n: next match'
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
def screen(output, selected, height)
  view = output.split("\e[2J").last.split(FOOTER).first
  raise 'Wrong selection' unless view.include?("Words: #{selected}/")
  raise 'Viewport exceeds terminal height' unless view.count("\n") + 2 <= height
  view
end
Dir.mktmpdir do |home|
  master, slave = PTY.open
  slave.winsize = [12, 60]
  original = IO.popen(['stty', '-g'], in: slave, &:read)
  definitions = (1..30).map { |i| ": browser.#{i} " + ('1 drop ' * 20) + ';' }.join(' ')
  pid = Process.spawn({'HOME'=>home}, RUNTIME, definitions + ' 42 words . cr quit', in: slave, out: slave, err: slave, chdir: home)
  begin
    screen(receive(master, BROWSER_END, timeout: 60), 1, 12)
    before = nil
    (2..15).each do |n|
      master.write("\e[B")
      before = screen(receive(master, BROWSER_END), n, 12)
    end
    raise 'Selected word not visible' unless before.include?('browser.16')
    master.write("\r")
    inspected = receive(master, 'q: quit')
    raise 'Wrong word inspected' unless inspected.include?('browser.16')
    master.write("\e[D")
    after = screen(receive(master, BROWSER_END), 15, 12)
    raise 'Nested SEE lost viewport' unless before == after
    slave.winsize = [24, 80]
    master.write("\e[A")
    screen(receive(master, BROWSER_END), 14, 24)
    master.write("\e[C")
    receive(master, 'q: quit')
    master.write("\r")
    returned = receive(master, "42 \r\n")
    raise 'Nested SEE exit did not clear the display' unless returned.include?("\e[2J\e[H")
    master.write("tui.off words\n")
    plain = receive(master, BROWSER_END)
    screen(plain, 1, 24)
    raise 'Plain browser contains highlighting' if plain.include?("\e[7m")
    master.write("\e[C")
    receive(master, 'q: quit')
    Process.kill('INT', pid)
    receive(master, 'signal 2')
    master.write("depth . output.vector @ . pager.address @ . 889 . cr\n")
    receive(master, "0 0 0 889 \r\n")
    master.write("bye\n")
    _, status = Timeout.timeout(15) { Process.wait2(pid) }
    raise 'Bad exit' unless status.success?
    restored = IO.popen(['stty', '-g'], in: slave, &:read)
    raise 'Terminal settings changed' unless original == restored
    puts 'WORDS scrolling, selected SEE, viewport restoration, resize, plain mode and fault cleanup passed.'
  ensure
    Process.kill('KILL', pid) rescue nil
    Process.wait(pid) rescue nil
    master.close
    slave.close
  end
end

# Small definitions must remain visible even when their complete SEE fits one page.
Dir.mktmpdir do |home|
  master, slave = PTY.open
  slave.winsize = [60, 100]
  pid = Process.spawn({'HOME'=>home}, RUNTIME,
    ': tiny.word ; 7 constant tiny.constant variable tiny.variable words bye',
    in: slave, out: slave, err: slave, chdir: home)
  begin
    receive(master, BROWSER_END)
    %w[tiny.variable tiny.constant tiny.word].each_with_index do |name, index|
      if index > 0
        master.write("\e[B")
        receive(master, BROWSER_END)
      end
      master.write(index.even? ? "\r" : "\n")
      view = receive(master, 'Enter: editor')
      raise "Short inspection was overwritten: #{name}" if view.include?('Words:')
      raise "Wrong short definition: #{name}" unless view.include?(name)
      raise 'No inspection controls' unless view.include?('Left: back')
      master.write("\e[D")
      receive(master, BROWSER_END)
    end
    master.write('/tui.onx' + "\x7f\r")
    receive(master, BROWSER_END)
    master.write("\e[C")
    view = receive(master, 'Enter: editor')
    raise 'Search did not select tui.on' unless view.include?('tui.on') && view.include?('Left: back')
    master.write("\e[D")
    receive(master, BROWSER_END)
    master.write("/not.a.dictionary.word\r")
    receive(master, 'No matching words.  /: search  n: next')
    master.write("/tiny.\r")
    receive(master, BROWSER_END)
    %w[tiny.variable tiny.constant tiny.word tiny.variable].each_with_index do |name, index|
      if index > 0
        master.write('n')
        receive(master, BROWSER_END)
      end
      master.write("\e[C")
      view = receive(master, 'Enter: editor')
      raise "Search next/wrap failed: #{name}" unless view.include?(name) && view.include?('Left: back')
      master.write("\e[D")
      receive(master, BROWSER_END)
    end
    master.write("q")
    receive(master, "\e[2J\e[H")
    _, status = Timeout.timeout(15) { Process.wait2(pid) }
    raise 'Bad short-view exit' unless status.success?
    puts 'WORDS short inspections, substring search, query editing, missing matches and next-match wrap passed.'
  ensure
    Process.kill('KILL', pid) rescue nil
    Process.wait(pid) rescue nil
    master.close
    slave.close
  end
end
