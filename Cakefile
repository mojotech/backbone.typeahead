cs = require('coffee-script')
fs = require('fs')
uglify = require('uglify-js')
tmpl_precompile = require('tmpl-precompile')

task 'build', 'compiles to source', ->
  console.log 'Compiling source'
  source = fs.readFileSync(__dirname + '/js/app.coffee', 'utf8')
  compiled = cs.compile(source)
  fs.writeFileSync(__dirname + '/js/app.min.js', compiled)

  tmpl_precompile.precompile({
    relative: true
    groups: [
      source: '/templates/'
      output: '/templates.js'
      namespace: 'Tmpl'
      templates: ['repo_item', 'facet_item']
      uglify: false
    ]
  }, __dirname)
