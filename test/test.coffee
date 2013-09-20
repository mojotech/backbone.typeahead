should = require 'should'
global.$ = require 'jquery'
global._ = require 'underscore'
global.Backbone = require 'backbone'
require '../backbone.typeahead.coffee'

describe 'Backbone Typeahead', ->
  testRoutes =
    'todos/new': 'show'
    'todos/:todo_id/comments/:id': 'showComment'
    'todos/:id': 'show'
    'todos': 'index'

  describe 'Readme Tests', ->
    class Albums extends Backbone.TypeaheadCollection
      typeaheadAttributes: ['band', 'name']

    albums = new Albums([
      { id: 1, band: 'A Flock of Seagulls', name: 'A Flock of Seagulls' }
      { id: 2, band: 'Rick Astley', name: 'Whenever You Need Somebody' }
      { id: 3, band: 'Queen', name: 'A Day at the Races' }
      { id: 4, band: 'Queen', name: 'Tie Your Mother Down' }
    ])

    it 'should handle simple search', ->
      expected = ['Whenever You Need Somebody', 'Tie Your Mother Down']
      actual = _.map albums.typeahead('you'), (a) -> a.get('name')

      expected.should.eql actual

    it 'should handle simple facet', ->
      expected = ['A Day at the Races']
      actual = _.map albums.typeahead('ra', band: 'Queen'), (a) -> a.get('name')

      expected.should.eql actual
