
#
# trim.rb
#
# CC0 1.0 - https://creativecommons.org/publicdomain/zero/1.0/
#

require 'ruby-vips'


def echo_help_and_exit

  puts
  #puts "#{RbConfig.ruby} #{$0}: trims the black border of images"
  puts "ruby #{$0}: trims the black border of images"
  puts
  puts "Usage: ruby ${0} [options] [file or file pattern]"
  puts
  puts "Options:"
  puts "  --dry or -d      Runs dry, no write to disk"
  puts "  --help or -h     This help printed here"
  puts "  --verbose or -v  Explains what is going on"
  #puts "  --quality or -q  JPEG quality for the output"
  puts
  exit 0
end

$files = []
$dry = false
$vrb = false
  #
ARGV.each do |a|

  if File.file?(a)
    $files << a
  elsif a == '--dry' || a == '-d'
    $dry = true
  elsif a == '--verbose' || a == '-v'
    $vrb = true
  elsif a == '--help' || a == '-h'
    echo_help_and_exit
  else
    # discard argument
  end
end
  #
echo_help_and_exit if $files.empty?


MAX_BLACK = 39
  #
def black?(rgb)

  #rgb[0] < MAX_BLACK && rgb[1] < MAX_BLACK && rgb[2] < MAX_BLACK
  (rgb[0] + rgb[1] + rgb[2]) / 3 < MAX_BLACK
end

def color_to_s(pt)
  r, g, b = pt
  m = ((r + g + b) / 3).to_i
  #r, g, b = pt.map { |f| f.to_i.to_s(16).upcase }
  r, g, b = pt.map(&:to_i)
  "r%3d g%3d b%3d  m%3d" % [ r, g, b, m ]
end

def pt_to_s(xy)
  "[ x %4d y %4d ]" % xy
end

CROPS = [
  [ 'top   ',
    lambda { |img| [ img.width / 2, 0 ] },
    lambda { |img| [ 0, 1, img.width, img.height - 1 ] } ],
  [ 'left  ',
    lambda { |img| [ 0, img.height / 2 ] },
    lambda { |img| [ 1, 0, img.width - 1, img.height ] } ],
  [ 'right ',
    lambda { |img| [ img.width - 1, img.height / 2 ] },
    lambda { |img| [ 0, 0, img.width - 1, img.height ] } ],
  [ 'bottom',
    lambda { |img| [ img.width / 2, img.height - 1 ] },
    lambda { |img| [ 0, 0, img.width, img.height - 1 ] } ] ]

def crop(img)

  CROPS.each do |n, xy, xywh|
    xy = xy.call(img)
    c = img.getpoint(*xy)
    echo { ". crop_#{n} ?     #{pt_to_s(xy)}  #{color_to_s(c)}" }
    next if ! black?(c)
    echo { "crop_#{n} because #{pt_to_s(xy)}  #{color_to_s(c)}" }
    img = img.crop(*xywh.call(img))
  end

  img
end

def echo(*ss, &block)

  return unless $vrb
  puts ss if ss.any?
  puts block.call if block
end

opts = {}
#opts[:Q] = 85 # quality for JPEGs

$files.each do |path|

  img = Vips::Image.new_from_file(path)
  echo { "#{path} --> #{img.inspect}" }

  img0 = img
  img1 = img

  while img.width > 0 && img.height > 0

    img1 = crop(img); break if img1.object_id == img.object_id
    img = img1
  end

  if img0.object_id == img1.object_id
    puts "not writing #{path}, already trimmed."
  else
    echo { "w#{img0.width} h#{img0.height} -> w#{img.width} h#{img.height}" }
    #img1.write_to_file(path, opts) unless $dry
    img1.write_to_file(path) unless $dry
    puts "trimmed #{path}."
  end
end

echo "Ite, missa est."

