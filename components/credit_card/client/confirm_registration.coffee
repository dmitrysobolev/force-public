_             = require 'underscore'
ModalView     = require '../../modal/view.coffee'
mediator      = require '../../../lib/mediator.coffee'

template      = -> require('../templates/registration-confirmation.jade') arguments...

module.exports = class ConfirmRegistration extends ModalView

  className: 'confirm'

  template: template

  defaults: ->
    width: '800px'

  initialize: (options = {}) ->
    @options = _.defaults options, @defaults()
    _.extend @templateData,
      artwork: @options.artwork
    super @options