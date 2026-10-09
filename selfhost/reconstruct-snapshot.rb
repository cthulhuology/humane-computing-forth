# Independent test oracle for the native parent-linked patch reader.
# Usage: ruby reconstruct-snapshot.rb NODE IMAGE [SOURCE]
node = File.expand_path(ARGV.fetch(0))
base = File.dirname(node)
magic = 0x3250414e53485446
chain = []
id = Integer(File.basename(node), 16)
loop do
  dir = File.join(base, '%08x' % id)
  raise 'incomplete snapshot' unless File.binread(File.join(dir, 'complete')) == [magic].pack('Q<')
  patch = File.binread(File.join(dir, 'image.patch'))
  raise 'short header' if patch.bytesize < 40
  tag, parent, before, after, count = patch.unpack('Q<5')
  raise 'bad header' unless tag == magic && (393216..1048576).cover?(after)
  chain << [patch, before, after, count]
  break if parent == 0xffffffffffffffff
  raise 'forward or cyclic parent' unless parent < id
  id = parent
end
image = ''.b
chain.reverse_each do |patch, before, after, count|
  raise 'parent size' unless before == image.bytesize
  image = image.byteslice(0, after).ljust(after, "\0")
  cursor = 40
  limit = 0
  count.times do
    raise 'short record' if cursor + 16 > patch.bytesize
    offset, length = patch.byteslice(cursor, 16).unpack('Q<2')
    cursor += 16
    raise 'invalid record' unless offset >= limit && length > 0 && offset + length <= after && cursor + length <= patch.bytesize
    image[offset, length] = patch.byteslice(cursor, length)
    cursor += length
    limit = offset + length
  end
  raise 'trailing bytes' unless cursor == patch.bytesize
  raise 'image size' unless image.byteslice(16, 8).unpack1('Q<') == after
end
File.binwrite(ARGV.fetch(1), image)
if ARGV[2]
  offset, length = image.byteslice(48, 16).unpack('Q<2')
  File.binwrite(ARGV[2], image.byteslice(offset, length))
end
