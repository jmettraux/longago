
#
# trim.rb

require 'ruby-vips'

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
  else
    # nada
  end
end


MAX_BLACK = 39
  #
def black?(rgb)

  #rgb[0] < MAX_BLACK && rgb[1] < MAX_BLACK && rgb[2] < MAX_BLACK
  (rgb[0] + rgb[1] + rgb[2]) / 3 < MAX_BLACK
end

  # image = image.crop(left, top, width, height)
  #
def crop_top(img)
  echo "crop_top ? #{img.getpoint(img.width / 2, 0).inspect}"
  return img if ! black?(img.getpoint(img.width / 2, 0))
  echo "crop_top because #{img.getpoint(img.width / 2, 0).inspect}"
  img.crop(0, 1, img.width, img.height - 1)
end
def crop_left(img)
  return img if ! black?(img.getpoint(0, img.height / 2))
  echo 'crop_left'
  img.crop(1, 0, img.width - 1, img.height)
end
def crop_right(img)
  return img if ! black?(img.getpoint(img.width - 1, img.height / 2))
  echo 'crop_right'
  img.crop(0, 0, img.width - 1, img.height)
end
def crop_bottom(img)
  return img if ! black?(img.getpoint(img.width / 2, img.height - 1))
  echo 'crop_bottom'
  img.crop(0, 0, img.width, img.height - 1)
end
def crop(img)
  img = crop_top(img)
  img = crop_left(img)
  img = crop_right(img)
  img = crop_bottom(img)
  img
end

def echo(*ss)

  puts ss if $vrb
end

$files.each do |path|

  img = Vips::Image.new_from_file(path)
  echo "#{path} #{img.inspect}"

  img0 = img
  img1 = img

  while img.width > 0 && img.height > 0

    img1 = crop(img); break if img1.object_id == img.object_id
    img = img1
  end

  echo "w#{img0.width} h#{img0.height} -> w#{img.width} h#{img.height}"

  if img0.object_id == img1.object_id
    puts "not writing #{path}, already trimmed"
  else
    puts "trimmed #{path}."
    #img1.write_to_file('tmp.jpg', Q: 85)
    img1.write_to_file(path) unless $dry
  end
end

