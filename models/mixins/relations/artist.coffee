{ API_URL } = require('sharify').data
Backbone = require 'backbone'

module.exports =
  related: ->
    return @__related__ if @__related__?

    # Deferred requires:
    Artist = require '../../artist.coffee'
    Posts = require '../../../collections/posts.coffee'
    PartnerShows = require '../../../collections/related_partner_shows.coffee'
    Artworks = require '../../../collections/artworks.coffee'
    Articles = Books = require '../../../components/artsypedia/collection.coffee'

    # Setup:
    artists = new Backbone.Collection [], model: Artist
    artists.url = "#{API_URL}/api/v1/related/layer/main/artists?artist[]=#{@id}&exclude_artists_without_artworks=true"

    contemporary = new Backbone.Collection [], model: Artist
    contemporary.url = "#{API_URL}/api/v1/related/layer/contemporary/artists?artist[]=#{@id}&exclude_artists_without_artworks=true"

    posts = new Posts
    posts.url = "#{API_URL}/api/v1/related/posts?artist[]=#{@id}"

    shows = new PartnerShows
    shows.url = "#{API_URL}/api/v1/related/shows?artist[]=#{@id}&sort=-end_at"

    artworks = new Artworks
    artworks.url = "#{@url()}/artworks?published=true"

    articles = new Articles
    articles.url = "/artist/data/#{@id}/publications?merchandisable[]=false"

    merchandisable = new Books
    merchandisable.url = "/artist/data/#{@id}/publications?merchandisable[]=true"

    bibliography = new Books
    bibliography.url = "/artist/data/#{@id}/publications"

    collections = new Backbone.Collection
    collections.url = "/artist/data/#{@id}/collections"

    exhibitions = new Backbone.Collection
    exhibitions.url = "/artist/data/#{@id}/exhibitions"

    # Return:
    @__related__ =
      artists: artists
      contemporary: contemporary
      posts: posts
      shows: shows
      artworks: artworks
      articles: articles
      merchandisable: merchandisable
      bibliography: bibliography
      collections: collections
      exhibitions: exhibitions
