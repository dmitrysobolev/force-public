_ = require 'underscore'
Backbone = require 'backbone'
Items = require '../collections/items.coffee'
LayoutSyle = require './mixins/layout_style.coffee'
{ Image, Markdown } = require 'artsy-backbone-mixins'
{ SECURE_IMAGES_URL } = require('sharify').data

module.exports = class FeaturedLink extends Backbone.Model
  _.extend @prototype, Image(SECURE_IMAGES_URL)
  _.extend @prototype, Markdown
  _.extend @prototype, LayoutSyle

  imageUrlForLayout: (collectionLength) ->
    @imageUrl @imageSizeForLayout collectionLength

  hasImageForLayout: (collectionLength) ->
    @hasImage @imageSizeForLayout collectionLength
