# Backbone.Typeahead 1.0.0
# (c) 2013 Mojotech
# Backbone.Typeahead may be freely distributed under the MIT license.

class Backbone.TypeaheadCollection extends Backbone.Collection
  _tokenize: (s) ->
    s = $.trim(s)
    return null if s.length is 0

    s.toLowerCase().split(/[\s\-_]+/)

  _tokenizeModel: (model) ->
    throw new Error('Missing typeaheadAttributes value') unless @typeaheadAttributes?

    _.uniq(@_tokenize(_.flatten(_.map(@typeaheadAttributes, (att) -> model.get(att))).join(' ')))

  _addToIndex: (models) ->
    models = [models] unless _.isArray(models)

    for model in models
      tokens = @_tokenizeModel(model)
      id = if model.id? then model.id else model.cid

      @_tokens[id] = tokens

      for t in tokens
        character = t.charAt(0)
        adjacency = @_adjacency[character] ||= [id]
        adjacency.push(id) unless ~_.indexOf(adjacency, id)

  _removeFromIndex: (models) ->
    models = [models] unless _.isArray(models)

    ids = _.map(models, (m) -> if m.id? then m.id else m.cid)

    delete @_tokens[id] for id in ids

    for k,v of @_adjacency
      @_adjacency[k] = _.without(v, ids...)

  _rebuildIndex: ->
    @_adjacency = {}
    @_tokens = {}
    @_addToIndex @models

  _facetMatch: (facets, attributes) ->
    for k,v of facets
      return false if v? and v isnt attributes[k]

    return true

  typeaheadIndexer: (facets) ->
    return null unless facets? and _.keys(facets).length > 0
    _.map(@where(facets), (m) -> if m.id? then m.id else m.cid)

  typeahead: (query, facets) ->
    throw new Error('Index is not built') unless @_adjacency?

    queryTokens = @_tokenize(query)
    suggestions = []
    lists = []
    shortestList = null
    firstChars = _(queryTokens).chain().map((t) -> t.charAt(0)).uniq().value()

    _.all firstChars, (firstChar) =>
      list = @_adjacency[firstChar]

      return false unless list?

      lists.push list
      shortestList = list if list.length < (shortestList?.length or @length)

      true

    return [] if lists.length < firstChars.length

    facetList = @typeaheadIndexer(facets)
    lists.push facetList if facetList?
    shortestList = facetList if facetList? and facetList.length < (shortestList?.length or @length)

    return @models unless shortestList?

    for id in shortestList
      isCandidate = _.every lists, (list) ->
        ~_.indexOf(list, id)

      isMatch = isCandidate and _.every queryTokens, (qt) =>
        _.some @_tokens[id], (t) ->
          t.indexOf(qt) is 0

      if isMatch
        item = @get(id)

        if @typeaheadPreserveOrder
          suggestions[@indexOf(item)] = item
        else
          suggestions.push item

    if @typeaheadPreserveOrder then _.compact(suggestions) else suggestions

  _reset: ->
    @_tokens = {}
    @_adjacency = {}
    super

  set: ->
    models = super
    models = [models] unless _.isArray(models)
    @_rebuildIndex models
    models

  remove: ->
    models = super
    models = [models] unless _.isArray(models)
    @_removeFromIndex models
    models

  _onModelEvent: (event, model, collection, options) ->
    add = false

    if event is "change:#{model.idAttribute}"
      add = true
      debugger
      @_removeFromIndex id: model.previous(model.idAttribute)
    else if _.indexOf(_.map(@typeaheadAttributes, (att) -> 'change:' + att), event) >= 0
      add = true
      @_removeFromIndex model

    @_addToIndex model if add

    super
