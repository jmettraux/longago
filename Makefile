
render:
	bundle exec ruby -Ilib lib/render.rb
r: render

serve:
	bundle exec ruby -run -ehttpd out/ -p7000
s: serve

.PHONY: render serve

