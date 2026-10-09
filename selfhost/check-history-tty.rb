require 'pty'
require 'io/console'
require 'timeout'
require 'tmpdir'
RUNTIME = File.expand_path(ARGV.fetch(0, './forth'))
def receive(io, text)
  output = +''
  Timeout.timeout(10) do
    until output.include?(text)
      IO.select([io])
      output << io.read_nonblock(16384)
    end
  end
  output
rescue Exception
  warn output.inspect
  raise
end
def session(home)
  master, slave = PTY.open
  slave.winsize = [40, 120]
  original_terminal = IO.popen(['stty', '-g'], in: slave, &:read)
  pid = Process.spawn({'HOME'=>home}, RUNTIME, in: slave, out: slave, err: slave)
  yield master, pid, slave
  restored_terminal = IO.popen(['stty', '-g'], in: slave, &:read)
  raise 'terminal settings changed' unless original_terminal == restored_terminal
ensure
  Process.kill('KILL', pid) rescue nil
  Process.wait(pid) rescue nil
  master.close rescue nil
  slave.close rescue nil
end
Dir.mktmpdir do |home|
  File.write("#{home}/.forth", "111 . cr\n222 . cr\n")
  session(home) do |io,pid,slave|
    # Give native startup time to switch the terminal before sending key bytes.
    sleep 0.1
    io.write("\e[A\n")
    receive(io, "222 \r\n")
    raise 'not appended' unless File.read("#{home}/.forth").end_with?("222 . cr\n222 . cr\n")
    io.write("333 . cr\e[A\e[A\e[A\e[B\e[B\e[B\n")
    receive(io, "333 \r\n")
    io.write("444 . cx\x7fr\n")
    receive(io, "444 \r\n")
    io.write("debug.on\ntrap\n")
    receive(io, 'Enter/q: quit debugger')
    raise 'fault not recorded' unless File.read("#{home}/.forth").end_with?("debug.on\ntrap\n")
    io.write("q")
    sleep 0.1
    io.write("555 . cr\n")
    receive(io, "555 \r\n")
    io.write("bye\n")
    _, status = Timeout.timeout(10) { Process.wait2(pid) }
    raise 'exit status' unless status.success?
  end
  session(home) do |io,pid,slave|
    sleep 0.1
    io.write("\e[A\e[A\n")
    receive(io, "555 \r\n")
    # Ctrl-D sent while command output is still in canonical mode is consumed
    # by the terminal driver; wait until the next native input read owns it.
    Timeout.timeout(5) do
      loop do
        settings = "\0" * 36
        slave.ioctl(0x5401, settings)
        break if settings.byteslice(12, 4).unpack1('L<') & 2 == 0
        sleep 0.01
      end
    end
    io.write("\x04")
    _, status = Timeout.timeout(10) { Process.wait2(pid) }
    raise 'EOF exit' unless status.success?
  end
  puts 'PTY persistent recall, draft restoration, deletion, fault recording, debugger and EOF passed.'
end
