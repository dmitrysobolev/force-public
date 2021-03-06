#
# /shows
#

express = require 'express'
routes = require './routes'
cities = require '../../components/locations/cities'

app = module.exports = express()
app.set 'views', "#{__dirname}/templates"
app.set 'view engine', 'jade'

app.get '/shows', routes.index
app.get '/shows/:city', routes.city

# Redirect all old location routes
for city in cities
  app.get "/#{city.slug}", ((city) -> (req, res) ->
    res.redirect 301, "/shows/#{city.slug}"
  )(city)
