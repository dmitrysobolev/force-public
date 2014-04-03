_               = require 'underscore'
Backbone        = require 'backbone'
benv            = require 'benv'
sinon           = require 'sinon'
sd              = require('sharify').data
{ resolve }     = require 'path'
rewire          = require 'rewire'
UnsubscribeView = rewire '../client/view'

describe 'Unsubscribe View', ->

  before (done) ->
    benv.setup =>
      benv.expose { $: benv.require 'jquery' }
      Backbone.$ = $
      done()

  after ->
    benv.teardown()

  beforeEach (done) ->
    benv.setup =>
      sinon.stub Backbone, 'sync'
      benv.render resolve(__dirname, '../templates/index.jade'), {
        sd: {}
        emailTypes: 
          'weekly_email': "Weekly Newsletters"
          'personalized_email': "Personalized Emails"
          'follow_users_email': "User Follow Emails"
      }, =>
        UnsubscribeView.__set__ 'sd', { UNSUB_AUTH_TOKEN: 'cat' }
        @view = new UnsubscribeView
          el: $('body')
        done()

  afterEach ->
    Backbone.sync.restore()

  it 'renders checkboxes for each email type, including a select all', ->
    _([ 'weekly_email', 'personalized_email', 'follow_users_email', ]).each (type) =>
      @view.$el.find("input[name='#{type}']").length.should.equal 1
    @view.$el.find("input[name='selectAll']").length.should.equal 1

  describe 'posting to the API', ->

    it 'correctly passes in the token and selected email types', ->
      @view.$el.find("input[name='personalized_email']").click()
      @view.$el.find('button').click()
      _.last(Backbone.sync.args)[1].attributes.type[0].should.equal 'personalized_email'
      _.last(Backbone.sync.args)[1].attributes.authentication_token.should.equal 'cat'

    it 'renders success message on success', ->
      @view.$el.find('button').click()
      _.last(Backbone.sync.args)[2].success {}
      @view.$el.html().should.include "You've been unsubscribed"

    it 'renders error message on error', ->
      @view.$el.find('button').click()
      _.last(Backbone.sync.args)[2].error {}
      @view.$el.html().should.include "Whoops, there was an error"