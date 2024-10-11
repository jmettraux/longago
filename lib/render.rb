
require 'redcarpet'
require 'colorato'
require 'longago/html_renderer'

C = Colorato.colours

rc = Redcarpet::Markdown.new(
  Longago::HtmlRenderer.new({}),
  tables: false, footnotes: false, strikethrough: false)

puts

Dir['posts/*.md'].each do |path|

  bn = File.basename(path, '.md')
  out = File.join('out', bn + '.html')

  md = rc.render(File.read(path))

  head =
    File.read('lib/head.html')
      .gsub('$TITLE', bn)

  File.open(out, 'wb') do |f|
    f.write(head)
    f.write(md)
    f.write("</body></html>\n")
  end

  puts "  rendered #{C.green(out)}"
end

puts

