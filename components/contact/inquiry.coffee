_         = require 'underscore'
Backbone  = require 'backbone'
{ SESSION_ID, ARTSY_URL } = require('sharify').data

ContactView       = require './view.coffee'
Representatives   = require './collections/representatives.coffee'
analytics         = require('../../lib/analytics.coffee')

headerTemplate  = -> require('./templates/inquiry_header.jade') arguments...
formTemplate    = -> require('./templates/form.jade') arguments...

module.exports = class InquiryView extends ContactView
  headerTemplate: -> headerTemplate.apply this, arguments
  formTemplate: -> formTemplate.apply this, arguments

  defaults: -> _.extend super,
    url: "#{ARTSY_URL}/api/v1/me/artwork_inquiry_request"

  initialize: (options) ->
    { @artwork } = options

    @representatives = new Representatives
    @representatives.fetch().then =>
      @templateData.representative = @representatives.first()
      @renderTemplates()
      @updatePosition()
      @isLoaded()
      # Ensure autofocus
      @$(':input[autofocus]').focus()

    super

  postRender: ->
    @isLoading()

  submit: ->
    analytics.track.funnel 'Sent artwork inquiry', label: analytics.modelToLabel(@artwork)

    @model.set
      artwork: @artwork.id
      contact_gallery: false
      session_id: SESSION_ID
    super