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
      { band: 'A Flock of Seagulls', name: 'A Flock of Seagulls' }
      { band: 'Rick Astley', name: 'Whenever You Need Somebody' }
      { band: 'Queen', name: 'A Day at the Races' }
      { band: 'Queen', name: 'Tie Your Mother Down' }
    ])

    it 'should handle simple search', ->
      expected = ['Whenever You Need Somebody', 'Tie Your Mother Down']
      actual = _.map albums.typeahead('you'), (a) -> a.get('name')

      expected.should.eql actual

    it 'should handle simple facet', ->
      expected = ['A Day at the Races']
      actual = _.map albums.typeahead('ra', band: 'Queen'), (a) -> a.get('name')

      expected.should.eql actual

  describe 'Support External Indexes for Facets', ->
    class IndexedCollection extends Backbone.TypeaheadCollection
      typeaheadAttributes: ['name']
      typeaheadIndexer: (facet, value) -> @index
      initialize: (models, options) -> @index = options.index

    it 'should allow for an external index', ->
      collection = new IndexedCollection([
        { id: 1, name: 'Aa' }
        { id: 2, name: 'Ab' }
        { id: 3, name: 'Ac' }
        { id: 4, name: 'Ad' }
        { id: 5, name: 'Ae' }
        { id: 6, name: 'Af' }
      ], index: [3, 5])

      expected = ['Ac', 'Ae']
      `debugger`
      actual = _.map collection.typeahead('a', indexedFacet: 'this value does not matter'), (m) -> m.get('name')

      expected.should.eql actual

  describe 'Common Error States', ->
    it 'should handle a falsy id'
    it 'should handle an empty collection'

    it 'should require the typeaheadAttributes member', ->
      class BrokenCollection extends Backbone.TypeaheadCollection
      causeError = ->
        collection = new BrokenCollection({name: 'Test'})

      causeError.should.throw('Missing typeaheadAttributes value')
