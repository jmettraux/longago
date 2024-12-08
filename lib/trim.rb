
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

  # image = image.crop(left, top, width, height)
  #
def crop_top(img)
  xy = [ img.width / 2, 0 ]
  c = img.getpoint(*xy)
  echo { ". crop_top ?        #{pt_to_s(xy)}  #{color_to_s(c)}" }
  return img if ! black?(c)
  echo { "crop_top because    #{pt_to_s(xy)}  #{color_to_s(c)}" }
  img.crop(0, 1, img.width, img.height - 1)
end
def crop_left(img)
  xy = [ 0, img.height / 2 ]
  c = img.getpoint(*xy)
  echo { ". crop_left ?       #{pt_to_s(xy)}  #{color_to_s(c)}" }
  return img if ! black?(c)
  echo { "crop_left because   #{pt_to_s(xy)}  #{color_to_s(c)}" }
  img.crop(1, 0, img.width - 1, img.height)
end
def crop_right(img)
  xy = [ img.width - 1, img.height / 2 ]
  c = img.getpoint(*xy)
  echo { ". crop_right ?      #{pt_to_s(xy)}  #{color_to_s(c)}" }
  return img if ! black?(c)
  echo { "crop_right because  #{pt_to_s(xy)}  #{color_to_s(c)}" }
  img.crop(0, 0, img.width - 1, img.height)
end
def crop_bottom(img)
  xy = [ img.width / 2, img.height - 1 ]
  c = img.getpoint(*xy)
  echo { ". crop_bottom ?     #{pt_to_s(xy)}  #{color_to_s(c)}" }
  return img if ! black?(c)
  echo { "crop_bottom because #{pt_to_s(xy)}  #{color_to_s(c)}" }
  img.crop(0, 0, img.width, img.height - 1)
end
def crop(img)
  img = crop_top(img)
  img = crop_left(img)
  img = crop_right(img)
  img = crop_bottom(img)
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
    img1.write_to_file(path, opts) unless $dry
    puts "trimmed #{path}."
  end
end

echo "Ite, missa est."

