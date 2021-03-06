_ = require 'underscore'
{ fabricate } = require 'antigravity'
FilterState = require '../models/filter_state'

describe 'FilterState', ->
  beforeEach ->
    @filterState = new FilterState fabricate('artist_filtered_search_suggest'), modelId: _.uniqueId()

  describe '#criteria', ->
    it 'selects the filter sections from the response', ->
      _.keys(@filterState.criteria()).should.eql ['medium', 'gallery', 'institution', 'period']

    it 'sets up some labels by humanizing the keys', ->
      @filterState.criteria().medium.label.should.equal 'Medium'
      @filterState.criteria().medium.filters[0].label.should.equal 'Work On Paper'

    it 'sorts the filters by count', ->
      _.pluck(@filterState.criteria().medium.filters, 'count').should.eql [41, 23, 10, 8, 7, 1, 1]

    it 'it leaves the period filters in chronological order', ->
      _.pluck(@filterState.criteria().period.filters, 'key').should.eql ['1940', '1960', '1970', '1980', '1990', '2000', '2010']

  describe '#criteria with nested fields', ->
    beforeEach ->
      @filterStateNested = new FilterState fabricate('artist_filtered_search_nested_suggest'), modelId: _.uniqueId()

    it 'selects the filter sections from the response', ->
      _.keys(@filterStateNested.criteria()).should.eql ['medium', 'gallery', 'institution']

    it 'grabs the correct name without simply desluggifying keys', ->
      _.pluck(@filterStateNested.criteria().gallery.filters, 'label').should.eql ['Armand Bartos Fine Art', 'Artware Editions', 'Barbara Krakow Gallery', 'Carolina Nitsch Contemporary Art', 'CASTERLINE GOODMAN GALLERY']

    it 'sets up some labels by humanizing the keys', ->
      @filterStateNested.criteria().medium.label.should.equal 'Medium'
      @filterStateNested.criteria().medium.filters[0].label.should.equal 'Work On Paper'
