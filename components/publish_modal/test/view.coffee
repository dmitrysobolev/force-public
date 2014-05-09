benv      = require 'benv'
sinon     = require 'sinon'
Backbone  = require 'backbone'
sd        = require('sharify').data
mediator  = require '../../../lib/mediator'
rewire    = require 'rewire'

describe 'PublishModal', ->
  before (done) ->
    benv.setup =>
      benv.expose $: benv.require 'jquery'
      Backbone.$ = $
      @PublishModal = rewire '../view'
      @PublishModal.__set__ 'readCookie', (@cookie = sinon.stub())
      sinon.stub @PublishModal::, 'initialize'
      done()

  after ->
    benv.teardown()

  describe '#makePublic', ->
    beforeEach ->
      @e        = $.Event('click')
      @close    = sinon.stub @PublishModal::, 'close'
      @trigger  = sinon.stub mediator, 'trigger'
      @view     = new @PublishModal

    afterEach ->
      @close.restore()
      @trigger.restore()

    it 'triggers the publishEvent event and close the modal after making public', ->
      @view.publishEvent = 'foo:bar'
      @view.makePublic @e
      @trigger.args[0][0].should.equal 'foo:bar'
      @close.calledOnce.should.be.ok

    it 'closes the modal after canceling', ->
      @view.cancel @e
      @close.calledOnce.should.be.ok

    describe 'cookie behavior', ->
      beforeEach ->
        @cookie.returns true
        sinon.stub @PublishModal::, 'remove'
        @PublishModal::initialize.restore()

      it 'if cancelled then the modal should not present itself again', ->
        @view = new @PublishModal
          persist      : true
          name         : 'foobar'
          publishEvent : 'foo:bar'
          message      : 'Foo Bar'
        @PublishModal::remove.called.should.be.true