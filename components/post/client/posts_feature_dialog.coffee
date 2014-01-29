_                  = require 'underscore'
Backbone           = require 'backbone'
sd                 = require('sharify').data
Artists            = require('../../../collections/artists.coffee')
Artworks           = require('../../../collections/artworks.coffee')
featurePostArtworkTemplate = -> require('../templates/actions_feature_post_artwork.jade') arguments...
featurePostArtistTemplate  = -> require('../templates/actions_feature_post_artist.jade') arguments...

module.exports = class PostsFeatureDialog extends Backbone.View

  events:
    'click .feature-by-slug'   : 'featureBySlug'
    'click a.post-feature'     : 'featurePostOnPage'
    'click a.post-unfeature'   : 'unfeaturePostOnPage'

  getFeatureUrl: (modelName, modelId) ->
    "#{sd.ARTSY_URL}/api/v1/post/#{@model.get('id')}/#{modelName}/#{modelId}/feature"

  initialize: ->
    @$postsDialog = @$('.posts-dialog')
    @$error = @$('.slug-container .error')

  show: ->
    if ! @$postsDialog.is(':visible')
      @loadPosts()
    @$postsDialog.toggleClass 'on'

  hide :-> @$postsDialog.removeClass 'on'

  loadPosts: ->
    @model.ensureFeatureArtistsFetched @displayFeatureArtists
    @model.ensureFeatureArtworksFetched @displayFeatureArtworks

  displayFeatureArtworks: (artworksCollection) =>
    featureArtworks = @$('.posts-dialog .feature-artworks')

    if @model.artworks()?.length
      for artwork in @model.artworks()
        artworksCollection.add artwork

    html = artworksCollection.map((artwork) =>
      featurePostArtworkTemplate( post: @model, artwork: artwork )
    ).join('')
    featureArtworks.html html

    artworksCollection.map (artwork) => @updateFeatured(artwork.get('id'), 'artwork')

  displayFeatureArtists: (artistsCollection) =>
    featureArtists = @$('.posts-dialog .feature-artists')

    for artwork in @model.artworks()
      artistsCollection.add artwork.get('artist')

    html = artistsCollection.map((artist) =>
      featurePostArtistTemplate( post: @model, artist: artist )
    ).join('')
    featureArtists.html html

    artistsCollection.map (artist) => @updateFeatured(artist.get('id'), 'artist')

  displayFeatureBySlugError: (response) ->
    @$error.text _.compact([
      (JSON.parse(response.responseText).error ? response.statusText),
      @$error.text()
    ]).join(", ")

  featureBySlug: ->
    $featureBySlugButton = @$('.slug-container a')
    return false if $featureBySlugButton.hasClass('working')
    $featureBySlugButton.addClass('working')

    @$error.text('')

    modelId = @$('input[name=post-feature-model-id]').val()
    return unless modelId && modelId.length > 0

    modelName = @$('input[name=post-feature-model-name]').val()
    return unless slug && slug.length > 0

    model = new Backbone.Model()
    model.save
      url    : @getFeatureUrl(modelName, modelId)
      success: =>
        @$error.text('')
        $featureBySlugButton.removeClass('working')
      error: (response) =>
        $featureBySlugButton.removeClass('working')
        @displayFeatureBySlugError(response)

  updateFeatured: (modelId, modelName) =>
    selector = ".posts-dialog a[data-#{modelName}_id=#{modelId}]".toLowerCase()
    model = new Backbone.Model()
    model.fetch
      url: @getFeatureUrl(modelName, modelId)
      success: =>
        @$(selector).addClass('post-unfeature')
      error: (xhr) =>
        @$(selector).addClass('post-feature')

  featurePostOnPage: (event) ->
    modelName = $(event.target).attr('data-model_name')
    modelId = $(event.target).attr("data-#{modelName}_id")

    model = new Backbone.Model
    model.url = @getFeatureUrl(modelName, modelId)
    model.save
      success: =>
        @loadPosts()

  unfeaturePostOnPage: (event) ->
    modelName = $(event.target).attr('data-model_name')
    modelId = $(event.target).attr("data-#{modelName}_id")

    model = new Backbone.Model(id: _.uniqueId)
    model.destroy
      url: @getFeatureUrl(modelName, modelId)
      success: =>
        @loadPosts()