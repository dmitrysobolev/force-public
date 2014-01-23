benv          = require 'benv'
sinon         = require 'sinon'
Backbone      = require 'backbone'
SaveControls  = require '../save_controls'
mediator      = require '../../../lib/mediator'
{ resolve }   = require 'path'

model           = new Backbone.Model(id: 'artwork')
model.isSaved   = sinon.stub()

artworkCollection                 = new Backbone.Collection
artworkCollection.unsaveArtwork   = sinon.stub()
artworkCollection.saveArtwork     = sinon.stub()

describe 'SaveControls', ->
  describe '#save', ->
    beforeEach (done) ->
      benv.setup =>
        benv.expose { $: benv.require 'components-jquery' }
        Backbone.$ = $
        benv.render resolve(__dirname, '../overlay_controls.jade'), {}, =>
          @view = new SaveControls { artworkCollection: null, model: model, el: $('.overlay-container') }
          done()

    afterEach ->
      benv.teardown()

    it 'triggers the register modal if theres no artworkCollection', ->
      sinon.spy mediator, 'trigger'
      @view.$('.overlay-button-save').click()
      mediator.trigger.args[0][0].should.equal 'open:auth'
      mediator.trigger.args[0][1].mode.should.equal 'register'
      mediator.trigger.restore()

    describe 'logged in behavior', ->
      beforeEach (done) ->
        benv.setup =>
          benv.expose { $: benv.require 'components-jquery' }
          Backbone.$ = $
          benv.render resolve(__dirname, '../overlay_controls.jade'), {}, =>
            @view = new SaveControls { artworkCollection: artworkCollection, model: model, el: $('.overlay-container') }
            done()

      afterEach ->
        benv.teardown()

      it 'saves the artwork if it is not in the collection', ->
        @view.model.isSaved = -> false
        @view.$button.click()
        @view.model.isSaved = -> true
        @view.artworkCollection.trigger 'add:artwork'
        @view.artworkCollection.saveArtwork.called.should.be.ok
        @view.artworkCollection.saveArtwork.args[0][0].should.equal model.id
        @view.$button.attr('data-state').should.equal 'saved'

      it 'unsaves the artwork if it is in the collection', ->
        @view.model.isSaved = -> true
        @view.$button.click()
        @view.model.isSaved = -> false
        @view.artworkCollection.trigger 'remove:artwork'
        @view.artworkCollection.unsaveArtwork.called.should.be.ok
        @view.artworkCollection.unsaveArtwork.args[0][0].should.equal model.id
        @view.$button.attr('data-state').should.equal 'unsaved'