all: compile minify

compile: backbone.typeahead.coffee
	./node_modules/coffee-script/bin/coffee --compile --map $<

minify: backbone.typeahead.js
	./node_modules/uglify-js/bin/uglifyjs $< -o ./backbone.typeahead.min.js

.PHONY: all
