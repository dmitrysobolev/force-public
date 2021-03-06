_ = require 'underscore'
Q = require 'q'
{ parse } = require 'url'
Backbone = require 'backbone'
sd = require('sharify').data
HeroUnits = require '../../collections/hero_units'
Items = require '../../collections/items'
{ client } = require '../../lib/cache'
welcomeHero = require './welcome'

getRedirectTo = (req) ->
  req.body['redirect-to'] or
  req.query['redirect-to'] or
  req.query['redirect_uri'] or
  parse(req.get('Referrer') or '').path or
  '/'

@index = (req, res) ->
  heroUnits = new HeroUnits
  featuredLinks = new Items [], id: '529939e2275b245e290004a0', item_type: 'FeaturedLink'
  exploreSections = new Items [], id: '54528dc072616942f91f0200', item_type: 'FeaturedLink'
  Q.allSettled(_.compact([
    heroUnits.fetch(cache: true)
    featuredLinks.fetch(cache: true)
    exploreSections.fetch(cache: true) unless req.user?
  ])).then(->
    heroUnits.unshift(welcomeHero) unless req.user?
    res.render 'index',
      heroUnits: heroUnits.models
      featuredLinks: featuredLinks.models
      exploreSections: exploreSections.models
  ).done()

@redirectToSignup = (req, res) ->
  res.redirect "/sign_up"

@redirectLoggedInHome = (req, res, next) ->
  pathname = parse(req.url or '').pathname
  req.query['redirect-to'] = '/' if pathname is '/log_in' or pathname is '/sign_up'
  if req.user? then res.redirect getRedirectTo(req) else next()

@bustHeroCache = (req, res, next) ->
  return next() unless req.user?.get('type') is 'Admin'
  heros = new HeroUnits
  if client
    client.del(heros.url)
    res.redirect '/'
  else
    res.redirect '/'
