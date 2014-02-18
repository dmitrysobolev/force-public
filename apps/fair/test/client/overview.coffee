_             = require 'underscore'
sd            = require('sharify').data
benv          = require 'benv'
Backbone      = require 'backbone'
sinon         = require 'sinon'
moment        = require 'moment'
{ resolve }   = require 'path'
{ fabricate } = require 'antigravity'
OverviewView = require '../../client/overview.coffee'
Fair          = require '../../../../models/fair.coffee'

describe 'ForYouView', ->

  before (done) ->
    benv.setup =>
      sd.ARTSY_URL = 'localhost:3003'
      sd.ASSET_PATH = 'assets/'
      sd.CURRENT_PATH = ""
      sd.CURRENT_USER = "hello"
      sd.NODE_ENV = "test"
      benv.expose { $: benv.require 'jquery' }
      sinon.stub Backbone, 'sync'
      Backbone.$  = $

      @fair = new Fair fabricate 'fair'
      done()

  after ->
    benv.teardown()
    Backbone.sync.restore()
    sd.CURRENT_USER = undefined

  describe '#initialize', ->

    it "renders personalized artist list", ->
      view = new OverviewView
        el: $("""<div>
            <div class='auction-clock'></div>
            <div class='container-left'><div class='large-section-subheading'></div></div>
            </div>""")
        fair: @fair
        model: @model

      Backbone.sync.args[0][2].success { time: moment().subtract('minutes', 2).format("YYYY-MM-DD HH:mm:ss ZZ") }
      Backbone.sync.args[1][2].success [{artist: fabricate('artist')}]
      Backbone.sync.args[2][2].success []

      view.$el.html().should.not.include 'undefined'
      view.$el.html().should.not.include "\#{"
      view.$el.html().should.not.include "NaN"

      view.$('.container-left .large-section-subheading').length.should.equal 1
      view.$('.container-left .large-section-subheading').text().should.include 'Pablo Picasso'