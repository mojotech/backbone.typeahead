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

  $ ->
    view = null
    repos = new Repos()

    repos.fetch().done ->
      view = new RepoListView(collection: repos, el: $('#list')[0])
      view.render()

    $('input').keyup (e) ->
      query = $(this).val()
      results = repos.typeahead(query)

      view.filter results
