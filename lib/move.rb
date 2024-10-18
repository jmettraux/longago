
#
# lib/move.rb

target = ARGV[0]
doit = ARGV[1] == 'DOIT'

unless target
  puts
  puts "ruby lib/move.rb out/images/l20241018/"
  puts "ruby lib/move.rb out/images/l20241018/ DOIT"
  puts
  exit 1
end

unless File.directory?(target)
  puts
  puts "target '#{target}' not a directory"
  puts
  exit 1
end

Dir[File.join(Dir.home, 'Downloads', 'igo*.{jpg,jpeg}')].each do |pa|

  ta = File.join(target, File.basename(pa))

  cmd = "mv #{pa} #{ta}"

  puts cmd
  system(cmd) if doit
end

