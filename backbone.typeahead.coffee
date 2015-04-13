# Backbone.Typeahead 1.0.0
# (c) 2013 Mojotech
# Backbone.Typeahead may be freely distributed under the MIT license.

class Backbone.TypeaheadCollection extends Backbone.Collection
  _tokenize: (s) ->
    s = $.trim(s)
    return null if s.length is 0

    s.toLowerCase().split(/[\s\-_]+/)

  ###
    Recursive method for walking an object as defined by an
    array. Returns the value of the last key in the array
    sequence.
    @private
    @method _deepObjectMap
    @param {Object} Object to walk
    @param {Array} Keys to walk the object with
    @return {Value} Last value from the object by array walk

    @example
      _deepObjectMap
        key:
          key2:
            key3: "val"
        , ['key', 'key2', 'key3']
      # Returns "val"
  ###
  _deepObjectMap: (obj, attrs) ->
    return obj unless attrs.length > 0 and _.isObject(obj)
    return obj[attrs[0]] if attrs.length is 1
    @_deepObjectMap(obj[attrs[0]], attrs.slice(1, attrs.length))


  ###
    Split each typeaheadAttribute into an array of nested methods
    and return an array map the returned values from deepObjectMap.
    @private
    @method _getAttributeValues
    @param {Backbone.Model} Model to fetch and map values from
    @return {Array} Values from model retrieved by _deepObjectMap

  ###
  _getAttributeValues: (model) ->
    _.map(@typeaheadAttributes, (att) =>
      attArray = att.split('.')
      @_deepObjectMap(model.get(attArray[0]), attArray[1..-1]))

  # Check if typeaheadAttributes were set. If they were then retrieve
  # the values via _getAttributeValues. Otherwise, get all of the values
  # from the movdel.
  _extractValues: (model) ->
    if @typeaheadAttributes?
      @_getAttributeValues(model)
    else _.values(model.attributes)

  _tokenizeModel: (model) ->
    _.uniq(@_tokenize(
      _.flatten(
        @_extractValues(model)
        ).join(' ')
      )
    )

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

  typeaheadIndexer: (facets) ->
    return null unless facets? and _.keys(facets).length > 0
    _.map(@where(facets), (m) -> if m.id? then m.id else m.cid)

  typeahead: (query, facets) ->
    throw new Error('Index is not built') unless @_adjacency?

    queryTokens = @_tokenize(query)
    lists = []
    shortestList = null
    firstChars = _(queryTokens).chain().map((t) -> t.charAt(0)).uniq().value()
    checkIfShortestList = (list) => shortestList = list if list.length <= (shortestList?.length or @length)

    _.all firstChars, (firstChar) =>
      list = @_adjacency[firstChar]

      return false unless list?

      lists.push list
      checkIfShortestList list

      true

    return [] if lists.length < firstChars.length

    facetList = @typeaheadIndexer(facets)

    if facetList?
      lists.push facetList
      checkIfShortestList facetList

    return @models unless shortestList?
    return [] if shortestList.length is 0

    suggestions = []

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
      @_removeFromIndex id: model.previous(model.idAttribute)
    else if event.indexOf('change:') is 0
      if not @typeaheadAttributes? or _.indexOf(_.map(@typeaheadAttributes, (att) -> 'change:' + att), event) >= 0
        add = true
        @_removeFromIndex model

    @_addToIndex model if add

    super
