_ = require 'underscore'
Backbone = require 'backbone'
isCreditCard = require('validator').isCreditCard
isEmail = require('validator').isEmail
analytics = require('../../../lib/analytics.coffee')

module.exports = class ErrorHandlingForm extends Backbone.View

  fields: {}
  errors:
    missingOrMalformed: "Your card appears to be missing or malformed. Please try another card or contact <a href='mailto:support@artsy.net'>support</a>."
    couldNotAuthorize: "Your card could not be authorized. Please try another card or contact <a href='mailto:support@artsy.net'>support</a>."
    paymentError: "Your payment could not be processed. Please try again or contact <a href='mailto:support@artsy.net'>support</a>."
    other: "There was a problem processing your order. Please try another card or contact <a href='mailto:support@artsy.net'>support</a>."

  isChecked: ($el) => $el.is(':checked')
  isCardNumber: ($el) => isCreditCard $el.val()
  isEmail: ($el) -> isEmail $el.val()
  isPresent: ($el) -> $el.val()? && $.trim($el.val()).length > 0
  isState: ($el) => @isPresent($el) || $el.parent().parent().find('select.country').val() != 'USA'
  isZip: ($el) => @isPresent($el) && ($el.parent().parent().find('select.country').val() != 'USA' || $el.val().trim().match(/^\d{5}/))

  clearErrors: ->
    @$el.find('.has-error').removeClass('has-error')
    @$el.find('.error').remove()

  validateForm: ->
    errors = {}
    @clearErrors()
    for own key, val of @fields
      continue unless val.el.is(':visible') && !val.validator(val.el)
      errors[key] = val.message || "Invalid #{val.label || key}"
      val.el.addClass 'has-error'
      val.el.last().after "<div class='error'>#{errors[key]}</div>"
    _.isEmpty(errors)

  showError: (description, response={}) =>
    if response.responseText?
      errorJson = JSON.parse response.responseText
      message = if errorJson.type == 'payment_error' then @errors.paymentError else @errors.other
    else if response.status == 400 or response.status == 403
      message = @errors.missingOrMalformed
      description = "Registration card missing or malformed."
    else if response.status == 402
      message = @errors.couldNotAuthorize
      description = "Registration card could not be authorized."
    else if response.status == 404
      message = "Registration marketplace invalid."
      description = message
    else if typeof(description) == 'string'
      message = description
    else
      message = @errors.other

    # Display balanced errors
    message += " #{response.error.additional}" if response?.error?.additional

    @$submit.removeClass('is-loading').before "<div class='error'>#{message}</div>"
    analytics.track.error(description) if description?

  internationalizeFields: ->
    @$('select.country').change =>
      if @$('select.country').val() == 'USA'
        @$el.removeClass('not-usa')
        @$('.postal-code label').text 'Zip Code'
        @$('.region label').text 'City'
      else
        @$el.addClass('not-usa')
        @$('.postal-code label').text 'Postal Code'
        @$('.region label').text 'Region'
