_ = require 'underscore'
Backbone = require 'backbone'
RelatedPostsView = require '../../../../components/related_posts/view.coffee'
template = -> require('../../templates/sections/articles.jade') arguments...

module.exports = class ArticlesView extends Backbone.View
  subViews: []

  postRender: ->
    @model.related().posts.fetch data: size: 20
    relatedPostsView = new RelatedPostsView collection: @model.related().posts, numToShow: 4
    @$('#artist-page-related-posts-section').html relatedPostsView.render().$el
    @subViews.push relatedPostsView

  render: ->
    @$el.html template(artist: @model, articles: @model.related().articles.models)
    _.defer => @postRender()
    this

  remove: ->
    _.invoke @subViews, 'remove'
