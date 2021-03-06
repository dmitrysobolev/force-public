_ = require 'underscore'
sd = require('sharify').data
Backbone = require 'backbone'
CurrentUser = require '../../../models/current_user.coffee'
Partner = require '../../../models/partner.coffee'
PartnerArtists = require '../../../collections/partner_artists.coffee'
PartnerShowsGrid = require './shows_grid.coffee'
PartnerLocations = require '../../../collections/partner_locations.coffee'
ArtistsListView = require './artists_list.coffee'
template = -> require('../templates/overview.jade') arguments...
artistsGridTemplate = -> require('../templates/_artists_grid.jade') arguments...

module.exports = class PartnerOverviewView extends Backbone.View

  partnerDefaults:
    numberOfFeatured: 1 # number of featured shows needed
    numberOfShows: 6 # number of other shows needed

  nonPartnerDefaults:
    numberOfFeatured: 0
    numberOfShows: 6

  initialize: (options={}) ->
    { @profile, @partner } = _.defaults options, @defaults
    @isPartner = @partner.get('claimed') isnt false
    { @numberOfFeatured, @numberOfShows } =
      _.defaults options, if @isPartner then @partnerDefaults else @nonPartnerDefaults
    @$el.html template partner: @partner, isPartner: @isPartner
    @initializeShows()
    @initializeArtists()
    @initializeLocations()

  initializeShows: ->
    new PartnerShowsGrid
      el: @$('.partner-overview-shows')
      partner: @partner
      numberOfFeatured: @numberOfFeatured
      isCombined: true
      numberOfShows: @numberOfShows
      heading: if @isPartner then '' else 'Shows & Fair Booths'
      seeAll: if @isPartner then true else false

  initializeArtists: ->
    partnerArtists = new PartnerArtists()
    partnerArtists.url = "#{@partner.url()}/partner_artists"
    partnerArtists.fetchUntilEnd
      cache: true
      success: =>
        # Display represented artists or non- ones who have published artworks
        displayables = partnerArtists.filter (pa) ->
          pa.get('represented_by') or
          pa.get('published_artworks_count') > 0

        if @isPartner
          @renderArtistsGrid displayables
        else
          @renderArtistsList displayables

  renderArtistsGrid: (artists) ->
    groups = _.groupBy artists, (pa) -> pa.get 'represented_by'
    represented = label: "represented artists", list: groups.true or []
    nonrepresented = label: "works available by", list: groups.false or []

    groups = _.filter [represented, nonrepresented], (g) -> g.list.length > 0
    groups[0].label = "artists" if groups.length is 1

    @$('.partner-overview-artists').html artistsGridTemplate
      partner: @partner
      groups: groups

  renderArtistsList: (artists) ->
    new ArtistsListView
      collection: artists
      el: @$('.partner-overview-artists')
      linkToPartnerArtist: @isPartner

  initializeLocations: ->
    return @$('.partner-overview-locations').hide() if @isPartner

    locations = new PartnerLocations()
    locations.url = "#{@partner.url()}/locations"
    locations.fetchUntilEnd success: =>
      return @$('.partner-overview-locations').hide() if locations.length is 0

      locationsArray = []
      _.each locations.groupBy('city'), (ls, c) ->
        _.each ls, (l) ->
          locationsArray.push "<li>#{l.toHtml()}</li>"
      @$('.locations').html locationsArray.join('')
