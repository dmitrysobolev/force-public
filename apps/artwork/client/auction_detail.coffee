_           = require 'underscore'
Backbone    = require 'backbone'
accounting  = require 'accounting'
template    = -> require('../templates/auction_detail.jade') arguments...

module.exports = class AuctionDetailView extends Backbone.View
  template: template

  events:
    'submit form' : 'submit'

  initialize: (options) ->
    { @user, @auction, @saleArtwork, @bidderPositions } = options

  submit: (e) ->
    return unless @user
    e.preventDefault()
    @$('button').attr 'data-state', 'loading'
    if (val = @validate @$('input').val())
      window.location = "#{@$('form').attr('action')}?bid=#{val}"
    else
      @displayValidationError()

  displayValidationError: ->
    (@$error ?= @$('.abf-validation-error')).show()
    @$('button').attr 'data-state', 'error'

  # Check to see if the form value is greater or equal to the minimum next bid
  # and in the process strip the formatting and return the value if it (only if it is valid)
  #
  # @return {Integer or undefined}
  validate: (val) ->
    if (val = accounting.unformat val) >= @saleArtwork.get('minimum_next_bid_cents') / 100
      val

  render: ->
    @$el.html(template
      user            : @user
      auction         : @auction
      saleArtwork     : @saleArtwork
      bidderPositions : @bidderPositions
    ).addClass 'is-fade-in'
    this