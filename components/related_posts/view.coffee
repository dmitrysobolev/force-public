_         = require 'underscore'
Backbone  = require 'backbone'
Post      = require '../../models/post.coffee'

template      = -> require('./templates/index.jade') arguments...
noneTemplate  = -> require('./templates/none.jade') arguments...

module.exports = class RelatedPostsView extends Backbone.View
  events:
    'click .related-posts-show-all'   : 'showAll'
    'click .related-posts-add-button' : 'addPost'

  initialize: (options) ->
    { @model, @numToShow } = options

    throw 'Model must implement #fetchRelatedPosts' unless _.isFunction(@model.fetchRelatedPosts)

    @model.fetchRelatedPosts()
    @listenTo @model.relatedPosts, 'sync', @render

  render: ->
    if @model.relatedPosts.length > 0
      @$el.html template
        model: @model
        posts: @model.relatedPosts.first @numToShow
        remaining: Math.max((@model.relatedPosts.length - @numToShow), 0)
    else
      @$el.html noneTemplate(model: @model)

    _.defer =>
      @$('.related-posts').addClass 'is-complete'

  showAll: (e) ->
    e.preventDefault()
    @numToShow = @model.relatedPosts.length
    @render()

  # TODO: Update this after we add the post dialog
  addPost: ->
    window.location = '/post'