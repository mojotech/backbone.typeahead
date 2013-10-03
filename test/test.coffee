should = require 'should'
global.$ = require 'jquery'
global._ = require 'underscore'
global.Backbone = require 'backbone'
require '../backbone.typeahead.coffee'

describe 'Backbone Typeahead', ->
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

      actual.should.eql expected

    it 'should handle simple facet', ->
      expected = ['A Day at the Races']
      actual = _.map albums.typeahead('ra', band: 'Queen'), (a) -> a.get('name')

      actual.should.eql expected

  describe 'Support External Indexes for Facets', ->
    class IndexedCollection extends Backbone.TypeaheadCollection
      typeaheadAttributes: ['name']
      typeaheadIndexer: (facet, value) -> @index
      initialize: (models, options) -> @index = options.index

    it 'should respect the order of the list', ->
      collection = new IndexedCollection([
        { id: 1, name: 'Aa' }
        { id: 3, name: 'Ba' }
        { id: 2, name: 'Ab' }
      ], index: [2, 1])

      collection.typeaheadPreserveOrder = true

      expected = ['Aa', 'Ab']
      actual = _.map collection.typeahead('a', indexedFacet: 'this value does not matter'), (m) -> m.get('name')

      actual.should.eql expected

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
      actual = _.map collection.typeahead('a', indexedFacet: 'this value does not matter'), (m) -> m.get('name')

      actual.should.eql expected

  describe 'Common Error States', ->
    it 'should handle a falsy id', ->
      class TestCollection extends Backbone.TypeaheadCollection
        typeaheadAttributes: ['name']

      collection = new TestCollection([
        { id: 3, name: 'Aa' }
        { id: 0, name: 'Ba' }
        { id: '', name: 'Bb' }
        { id: false, name: 'Ca' }
        { id: 7, name: 'Bc' }
      ])

      expected = ['Ba', 'Bb', 'Bc']
      actual = _.map collection.typeahead('b'), (m) -> m.get('name')

      actual.should.eql expected

    it 'should handle an empty collection', ->
      class TestCollection extends Backbone.TypeaheadCollection
        typeaheadAttributes: ['id']

        collection = new TestCollection()

        expected = []
        actual = _.map collection.typeahead('a'), (m) -> m.id

        actual.should.eql expected

    it 'should require the typeaheadAttributes member', ->
      class BrokenCollection extends Backbone.TypeaheadCollection
      causeError = ->
        collection = new BrokenCollection({name: 'Test'})

      causeError.should.throw('Missing typeaheadAttributes value')

  describe 'Common Backbone Scenarios', ->
    it 'should handle attributes with array values', ->
      class MyModel extends Backbone.Model

      class MyCollection extends Backbone.TypeaheadCollection
        model: MyModel
        typeaheadAttributes: ['array']

      collection = new MyCollection([
        { id: 1, array: ['Aa', 'Ab'] }
        { id: 2, array: ['Aa'] }
        { id: 3, array: ['Bb'] }
      ])

      expected = [1, 2]
      actual = _.map collection.typeahead('a'), (m) -> m.id

    it 'should support alternative ID attributes', ->
      json = '[{"url":"people/Nick-Kishfy","indexText":"Nick Kishfy Founder & CEO boss hiker ceo","title":"Nick Kishfy"}]'

      class PageModel extends Backbone.Model
        idAttribute: 'url'

      class PageCollection extends Backbone.TypeaheadCollection
        model: PageModel
        typeaheadAttributes: ['indexText']

      collection = new PageCollection(JSON.parse(json))

      collection.typeahead().length.should.eql collection.length
