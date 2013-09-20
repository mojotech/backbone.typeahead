do (Backbone, Marionette, _, $) ->
  class Repo extends Backbone.Model

  class Repos extends Backbone.TypeaheadCollection
    url: 'data/repos.json'
    model: Repo
    typeaheadAttributes: ['name', 'description', 'language']

  class RepoItemView extends Marionette.ItemView
    tagName: 'li'
    className: 'list-group-item'
    template: Tmpl.repo_item

    hide: -> @$el.hide()
    show: -> @$el.show()

  class RepoListView extends Marionette.CollectionView
    tagName: 'ul'
    className: 'list-group'
    itemView: RepoItemView

    filter: (models) ->
      @children.call 'hide'
      @children.findByModel(model).show() for model in models

  class FacetItemView extends Marionette.ItemView
    tagName: 'li'
    template: Tmpl.facet_item

    events:
      'click': -> @trigger 'facet', @model.id

    applyFacet: (facet) -> @$el.toggleClass('active', @model.id is facet)

  class FacetListView extends Marionette.CollectionView
    tagName: 'ul'
    className: 'nav nav-stacked nav-pills'
    itemView: FacetItemView

    applyFacet: (facet) -> @children.call 'applyFacet', facet

  $ ->
    listView = null
    facets = null
    repos = new Repos()
    lastQuery = ''
    lastFacets = null

    applyTypeahead = ->
      results = repos.typeahead(lastQuery, lastFacets)
      listView.filter results

    repos.fetch().done ->
      facets = _(repos.pluck('language')).chain().compact().uniq().value().sort()
      facets = _.map(facets, (l) -> id: l)
      facets = new Backbone.Collection(facets)

      facetView = new FacetListView(collection: facets)
      facetView.on 'itemview:facet', (iv, facet) ->
        lastFacets = if lastFacets?.language is facet then null else language: facet
        facetView.applyFacet lastFacets?.language
        applyTypeahead()

      listView = new RepoListView(collection: repos)

      $('#facet').append(facetView.render().el)
      $('#list').append(listView.render().el)

    $('input').keyup (e) ->
      lastQuery = $(this).val()
      applyTypeahead()

