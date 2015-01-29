cs = require('coffee-script')
fs = require('fs')
uglify = require('uglify-js')

task 'build', 'compiles to source', ->
  console.log 'Compiling source'
  source = fs.readFileSync(__dirname + '/backbone.typeahead.coffee', 'utf8')
  compiled = cs.compile(source)
  fs.writeFileSync(__dirname + '/backbone.typeahead.js', compiled)
  fs.writeFileSync(__dirname + '/backbone.typeahead.min.js', uglify.minify(compiled, {fromString: 1}).code)
