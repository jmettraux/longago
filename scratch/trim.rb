
#
# trim.rb

fail 'no worky! trims too much...'

dir = nil
pat = '*.jpg'
fuz = '7%'
dry = false
  #
ARGV.each do |a|
  if File.directory?(a)
    dir = a
  elsif a == '--dry' || a == '-d'
    dry = true
  elsif a.index('.')
    pat = a
  elsif a.match?(/^\d+%$/)
    fuz = a
  else
    # nada
  end
end

fail "not a dir >#{dir}<" if dir.nil? || ! File.directory?(dir)

Dir[File.join(dir, pat)].each do |path|

  tmp =
    #File.join(dir, 'tmp' + File.extname(path))
    'tmp' + File.extname(path)
  cmd0 =
    "convert -fuzz #{fuz} -define trim:percent-background=0% -trim +repage " +
    path + " " + tmp
  cmd1 =
    "mv #{tmp} #{path}"
  puts
  puts cmd0
  system(cmd0) unless dry
  puts cmd1
  system(cmd1) unless dry
end

