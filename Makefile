
HOST = jutsu

render:
	bundle exec ruby -Ilib lib/render.rb
r: render

serve:
	bundle exec ruby -run -ehttpd out/ -p7000
s: serve

publish:
	chmod a+r out/*.html
	chmod a+r out/images/*.jpg
	rsync -azv --delete --delete-excluded \
      --exclude *.swp \
      out/ $(HOST):/var/www/htdocs/igo.boardroom.cafe/longago/
p: publish

.PHONY: render serve publish

