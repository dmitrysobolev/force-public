#
# Feature
#
# A feature is a generic model that is used for grouping featued content.
# A feature could be a group of links to posts, shows, or any other Artsy entity.
# Auctions are also features and add the most plumbing to this general purpose set up.
#
# Heavily leveraging @craigspaeth's work from microgravity.
# https://github.com/artsy/microgravity/blob/master/apps/feature
#
_ = require 'underscore'
sd = require('sharify').data
{ Image } = require 'artsy-backbone-mixins'
Artworks = require '../collections/artworks.coffee'
Backbone = require 'backbone'
FeaturedLinks = require '../collections/featured_links.coffee'
FeaturedSet = require './featured_set.coffee'
Sale = require './sale.coffee'

{ smartTruncate } = require "../components/util/string.coffee"
ABM = require 'artsy-backbone-mixins'

module.exports = class Feature extends Backbone.Model

  _.extend @prototype, ABM.Image(sd.SECURE_IMAGES_URL)
  _.extend @prototype, ABM.Markdown
  _.extend @prototype, ABM.Feature(sd.API_URL, Sale, Artworks, FeaturedSet, FeaturedLinks)

  urlRoot: -> "#{sd.API_URL}/api/v1/feature"

  hasImage: (version = 'wide') ->
    version in (@get('image_versions') || [])

  metaTitle: ->
    "#{@get('name')} | Artsy"

  metaDescription: ->
    smartTruncate(@mdToHtmlToText('description'))

  shareTitle: (truncate = false) ->
    smartTruncate "#{@get('name')} on Artsy #{sd.APP_URL}#{@href()}", 140

  href: ->
    "/feature/#{@get('id')}"
