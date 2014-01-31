_             = require 'underscore'
jade          = require 'jade'
path          = require 'path'
fs            = require 'fs'
cheerio       = require 'cheerio'
Backbone      = require 'backbone'
{ fabricate } = require 'antigravity'
FeaturedSet   = require '../../../../models/featured_set.coffee'
FeaturedLink  = require '../../../../models/featured_link.coffee'

render = (templateName) ->
  filename = path.resolve __dirname, "../../templates/#{templateName}.jade"
  jade.compile(
    fs.readFileSync(filename),
    { filename: filename }
  )

describe 'Featured Links', ->

  beforeEach ->
    @sd =
      ARTSY_URL : 'http://localhost:5000'
      ASSET_PATH: 'http://localhost:5000'
    @set = new FeaturedSet
      owner     : fabricate('feature', { image_versions: ['wide'] })
      id        : "52b347c59c18db5aef000208"
      published : true
      key       : "1"
      name      : "Top 10 Posts"
      item_type : "FeaturedLink"
      type      : "featured links"
      owner_type: "Feature"
      data      : new Backbone.Collection [ fabricate 'featured_link' ], { model: FeaturedLink }

  describe 'template', ->

    it 'adds different layout classes depending on the size of the collection', ->
      _(5).times (n) =>
        html = render('sets')({ sets : [ @set ] })
        $ = cheerio.load html
        len = @set.get('data').length
        featuredLink = @set.get('data').first()
        $('.feature-set-item').is(".feature-set-item-#{featuredLink.layoutStyle(len)}").should.be.true
        @set.get('data').add new FeaturedLink fabricate 'featured_link'

    it 'links elements if the model has an href attribute', ->
      html = render('sets')({ sets : [ @set ] })
      $ = cheerio.load html
      $('.feature-set-item').should.have.lengthOf 1
      $('.feature-set-item a').should.have.lengthOf 2

    it 'adds an image when the model has one', ->
      @set.get('data').first().set 'image_versions', ['original', 'large_rectangle', 'medium_rectangle']
      link = @set.get('data').first()
      html = render('sets')({ sets : [ @set ] })
      $ = cheerio.load html
      $('.feature-set-item img').should.have.lengthOf 1
      $('.feature-set-item img').attr('src').should.equal link.imageUrlForLayout @set.get('data').length

    it 'does not link elements if the model has no href attribute', ->
      @set.get('data').first().set 'href', null
      html = render('sets')({ sets : [ @set ] })
      $ = cheerio.load html
      $('.feature-set-item').should.have.lengthOf 1
      $('.feature-set-item a').should.have.lengthOf 0

    xit 'renders a caption with heading and subheading if available', ->
      link = @set.get('data').first()
      html = render('sets')({ sets : [ @set ] })
      $ = cheerio.load html
      $('.feature-set-item-caption').should.have.lengthOf 1
      $('.feature-set-item-caption-heading').should.equal link.get('title')
      $('.feature-set-item-caption-subheading').should.have.lengthOf link.get('subtitle')