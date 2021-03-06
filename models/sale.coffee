_ = require 'underscore'
sd = require('sharify').data
moment = require 'moment'
Backbone = require 'backbone'
{ Fetch } = require 'artsy-backbone-mixins'
Clock = require './mixins/clock.coffee'
SaleArtworks = require '../collections/sale_artworks.coffee'

module.exports = class Sale extends Backbone.Model
  _.extend @prototype, Clock

  urlRoot: "#{sd.API_URL}/api/v1/sale"

  href: -> "/feature/#{@get('id')}"
  registrationSuccessUrl: -> "#{@href()}/confirm-registration"

  fetchArtworks: (options = {}) ->
    @artworks = new SaleArtworks [], id: @id
    @artworks.fetchUntilEnd options

  calculateOffsetTimes: (options = {}) ->
    new Backbone.Model().
      fetch
        url: "#{sd.API_URL}/api/v1/system/time"
        success: (model) =>
          offset = moment().diff(model.get('time'))
          @set('offsetStartAtMoment', moment(@get 'start_at').add(offset))
          @set('offsetEndAtMoment', moment(@get 'end_at').add(offset))
          @updateState()
          options.success() if options?.success?
        error: options?.error

  updateState: ->
    @set('auctionState', (
      if moment().isAfter(@get 'offsetEndAtMoment')
        'closed'
      else if moment().isAfter(@get 'offsetStartAtMoment') and moment().isBefore(@get 'offsetEndAtMoment')
        'open'
      else if moment().isBefore(@get 'offsetStartAtMoment')
        'preview'
    ))

  registerUrl: (redirectUrl) ->
    url = "/auction-registration/#{@id}"
    if redirectUrl
      url += "?redirect_uri=#{redirectUrl}"
    url

  bidUrl: (artwork) ->
    "/feature/#{@id}/bid/#{artwork.id}"

  redirectUrl: (artwork) ->
    if @isBidable() and artwork?
      @bidUrl artwork
    else
      @href()

  # NOTE
  # auction_state helpers are used serverside of if updateState hasn't been run
  # auctionState used after updateState is run
  isRegisterable: ->
    @isAuction() and _.include(['preview', 'open'], @get('auction_state'))

  isAuction: ->
    @get('is_auction')

  isBidable: ->
    @isAuction() and _.include(['open'], @get('auction_state'))

  isPreviewState: ->
    @isAuction() and _.include(['preview'], @get('auction_state'))

  isOpen: ->
    @get('auctionState') is 'open'

  isPreview: ->
    @get('auctionState') is 'preview'

  isClosed: ->
    @get('auctionState') is 'closed'

  # @param {CurrentUser, Artwork (optional)}
  # @return {Object}
  bidButtonState: (user, artwork) ->
    if @isPreview() and !user?.get('registered_to_bid')
      label: 'Register to bid', enabled: true, classes: undefined, href: @registerUrl()
    else if @isPreview() and user?.get('registered_to_bid')
      label: 'Registered to bid', enabled: false, classes: 'is-success is-disabled', href: undefined
    else if @isOpen()
      label: 'Bid', enabled: true, classes: undefined, href: (@bidUrl(artwork) if artwork)
    else if @isClosed()
      label: 'Online Bidding Closed', enabled: false, classes: 'is-disabled', href: undefined
