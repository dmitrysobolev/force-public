benv            = require 'benv'
Backbone        = require 'backbone'
sinon           = require 'sinon'
{ resolve }     = require 'path'
{ fabricate }   = require 'antigravity'

Artworks  = require '../../../../collections/artworks'
Artwork   = require '../../../../models/artwork'

describe 'SaleView', ->
  before (done) ->
    benv.setup =>
      benv.expose $: benv.require 'jquery'
      Backbone.$ = $
      done()

  after ->
    benv.teardown()

  beforeEach (done) ->
    sinon.stub(Backbone, 'sync').yieldsTo('success')
    SaleView    = benv.requireWithJadeify resolve(__dirname, '../../client/sale'), ['template', 'artworkColumnsTemplate']
    @$fixture   = $('<div></div>')
    @artwork    = new Artwork fabricate 'artwork'
    @artwork.sales.add fabricate 'sale'
    @view = new SaleView el: @$fixture, sale: @artwork.sales.first(), saved: {}
    done()

  afterEach ->
    Backbone.sync.restore()

  describe '#initialize', ->
    it 'sets up the saleArtworks collection with the correct URL and fetches it', ->
      Backbone.sync.args[0][0].should.equal 'read'
      Backbone.sync.args[0][1].url.should.include '/api/v1/sale/whtney-art-party/sale_artworks'
    it 'sets up artworks on success', ->
      @view.artworks.constructor.name.should.equal 'Artworks'

  describe '#rendered', ->
    it 'has the correct title', ->
      text = @view.$('h2').text()
      text.should.include 'Works from'
      text.should.include 'Whitney Art Party'
    it 'has a container for the artwork columns', ->
      @view.$('#sale-artwork-columns').length.should.be.ok
    it 'links to the feature', ->
      @view.$('a').attr('href').should.equal '/feature/whtney-art-party'
    it 'renders sale artwork columns', ->
      saleArtwork = new Backbone.Model(fabricate 'sale_artwork')
      # A bug with the comparator means you can't add to this collection (FWIW)
      # So we reset it completely here
      @view.artworks  = Artworks.fromSale [saleArtwork]
      artwork         = @view.artworks.first()
      @view.render()

      # Various content assertions
      link = @view.$('.artwork-item-image-link')
      link.length.should.be.ok
      link.attr('href').should.equal artwork.href()

      @view.$('.artwork-item-blurb').text().should.equal artwork.get('saleArtwork').get('user_notes')