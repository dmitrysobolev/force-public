#
# Detects a mobile browser by user agent and redirects it to Microgravity
#

{ MOBILE_URL } = require '../../config'

module.exports = (req, res, next) ->
  return next() unless ua = req.get 'user-agent'
  isPhone = (ua.match(/iPhone/i) && !ua.match(/iPad/i)) ||
            (ua.match(/Android/i) && ua.match(/Mobile/i)) ||
            (ua.match(/Windows Phone/i)) ||
            (ua.match(/BB10/i)) ||
            (ua.match(/BlackBerry/i))
  if isPhone and not req.query?.stop_microgravity_redirect
    res.redirect MOBILE_URL + req.url
  else
    next()
