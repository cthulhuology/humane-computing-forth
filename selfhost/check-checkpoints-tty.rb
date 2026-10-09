# Checkpoint paths are plain, nonblocking output even on an interactive terminal.
require 'pty'
require 'io/console'
require 'timeout'
require 'tmpdir'
RUNTIME = File.expand_path(ARGV.fetch(0, './forth'))
Dir.mktmpdir do |home|
  ['42 checkpoints . cr bye', ': saved 77 ; 42 checkpoints . cr bye'].each_with_index do |command, index|
    master, slave = PTY.open
    slave.winsize = [12, 60]
    original = IO.popen(['stty', '-g'], in: slave, &:read)
    pid = Process.spawn({'HOME'=>home}, RUNTIME, command, in: slave, out: slave, err: slave, chdir: home)
    begin
      output = +''
      Timeout.timeout(15) do
        until output.include?("42 \r\n")
          IO.select([master])
          output << master.read_nonblock(65536)
        end
      end
      _, status = Timeout.timeout(15) { Process.wait2(pid) }
      raise "Checkpoint listing failed: #{output.inspect}" unless status.success?
      raise 'Checkpoint listing entered a TUI' if output.include?("\e")
      expected = 'No snapshot saved'
      raise "Missing checkpoint information: #{output.inspect}" unless output.include?(expected)
      raise 'Terminal settings changed' unless original == IO.popen(['stty', '-g'], in: slave, &:read)
    ensure
      Process.kill('KILL', pid) rescue nil
      Process.wait(pid) rescue nil
      master.close; slave.close
    end
  end
end
puts 'Checkpoint terminal output is plain, nonblocking and preserves stack and terminal state.'
