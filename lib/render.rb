
require 'redcarpet'
require 'colorato'
require 'longago/html_renderer'

C = Colorato.colours

rc = Redcarpet::Markdown.new(
  Longago::HtmlRenderer.new({}),
  tables: false, footnotes: false, strikethrough: false)

foot = File.read('lib/partials/foot.html')

posts = Dir['posts/*.md']
  .sort_by { |path|
    m = path.match(/(\d{4}-?\d{2}-?\d{2})/)
    m ? m[1] : '9999-12-31' }
  .reverse

puts

#
# the index

titles = {}

File.open('out/index.html', 'wb') do |f|

  head =
    File.read('lib/partials/head.html')
      .gsub('$TITLE', 'Igo Journey')

  f.write(head)

  f.write(File.read('lib/partials/index_top.html'))

  f.write("<ul>\n")

  posts.each do |path|

    bn = File.basename(path, '.md')
    ti = File.read(path).match(/^## ([^\n]+)/)
    ti = ti ? ti[1] : '(no ## title)'

    titles[bn] = ti

    f.write("<li><a href=\"#{bn}.html\">#{ti}</a></li>\n")
  end

  f.write("</ul>\n")

  f.write(foot)
end

puts "  wrote #{C.green('out/index.html')}"

puts

#
# the posts

s = StringIO.new
#s << "<div class=\"separator\"></div>\n"
s << "<div class=\"links\">\n"
s << "<span class=\"link\">"
s << "<a href=\"index.html\">Index</a>"
s << "</span>\n"
posts.each do |path|
  bn = File.basename(path, '.md')
  s << "<span class=\"sep\">"
  s << "<span class=\"link\">"
  s << "<a href=\"#{bn}.html\">#{titles[bn]}</a>"
  s << "</span>\n"
end
s << "<div>\n"
  #
links = s.string

posts.each do |path|

  bn = File.basename(path, '.md')
  out = File.join('out', bn + '.html')

  md = rc.render(File.read(path))

  head =
    File.read('lib/partials/head.html')
      .gsub('$TITLE', bn)

  File.open(out, 'wb') do |f|

    f.write(head)
    f.write(md)
    f.write(links)
    f.write(foot)
  end

  puts "  rendered #{C.green(out)}"
end

puts

