_ = require 'underscore'
_s = require 'underscore.string'
sd = require('sharify').data
Backbone = require 'backbone'
CarouselView = require '../../../components/carousel/view.coffee'
HeaderView = require './views/header.coffee'
OverviewView = require './views/overview.coffee'
WorksView = require './views/works.coffee'
ShowsView = require './views/shows.coffee'
ArticlesView = require './views/articles.coffee'
RelatedArtistsView = require './views/related_artists.coffee'
PublicationsView = require './views/publications.coffee'
CollectionsView = require './views/collections.coffee'
{ ArtistData, sections } = require './data.coffee'

module.exports = class ArtistRouter extends Backbone.Router
  routes:
    'artist/:id': 'overview'
    'artist/:id/works': 'works'
    'artist/:id/shows': 'shows'
    'artist/:id/articles': 'articles'
    'artist/:id/collections': 'collections'
    'artist/:id/publications': 'publications'
    'artist/:id/related-artists': 'relatedArtists'

  initialize: ({ @model, @user }) ->
    @data = new ArtistData model: @model
    @options = model: @model, user: @user, data: @data

    @setupUser()
    @setupCarousel()
    @setupHeaderView()

    @listenTo @data, 'sync:all', @deferredDispatch
    @data.sync()

  setupUser: ->
    @user?.initializeDefaultArtworkCollection()

  setupCarousel: ->
    @carouselView = new CarouselView el: $('#artist-carousel'), height: 300
    @carouselView.postRender()

  setupHeaderView: ->
    @headerView = new HeaderView _.extend el: $('#artist-page-header'), @options

  deferredDispatch: ->
    Backbone.history.loadUrl Backbone.history.fragment

  execute: ->
    @view?.remove()
    # Only execute a route handler if
    # the artist data is synced
    if @data.synced
      @headerView.renderNav()
      @options.section = @getSection()
      # Abort route and redirect to overview if the section isn't in the returns
      return @navigateToOverview() unless @validSection(@options.section)
      super # Route handler
      @renderCurrentView()

  validSection: (section) ->
    _.contains @data.returns, section

  navigateToOverview: ->
    @navigate "artist/#{@model.id}", trigger: true

  getSection: ->
    slug = _.last(Backbone.history.fragment.split '/').split('?')[0]
    slug = '' if slug is @model.id
    _.findWhere @data.sections, slug: slug

  renderCurrentView: ->
    (@$content ?= $('#artist-page-content'))
      .html @view.render().$el

  overview: ->
    @view = new OverviewView @options

  works: ->
    @view = new WorksView @options

  shows: ->
    @view = new ShowsView @options

  articles: ->
    @view = new ArticlesView @options

  relatedArtists: ->
    @view = new RelatedArtistsView @options

  publications: ->
    @view = new PublicationsView @options

  collections: ->
    @view = new CollectionsView @options
