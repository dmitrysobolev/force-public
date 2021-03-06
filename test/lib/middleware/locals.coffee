Backbone = require 'backbone'
sinon = require 'sinon'
middleware = require '../../../lib/middleware/locals'

describe 'locals middleware', ->

  it 'adds a session id', ->
    middleware req = { url: 'localhost:3000', session: {}, get: (->)},
      res = { locals: { sd: { ASSET_PATH: '' } } }, ->
    req.session.id.length.should.be.above 0
    res.locals.sd.SESSION_ID.should.equal req.session.id

  it 'sets the hide header flag', ->
    middleware req = { url: 'localhost:3000', cookies: { 'hide-force-header': true }, session: {}, get: (->)},
      res = { locals: { sd: { ASSET_PATH: '' } } }, ->
    res.locals.sd.HIDE_HEADER.should.be.ok

  it 'adds the user agent', ->
    middleware req = { url: 'localhost:3000', get: -> 'foobar' },
      res = { locals: { sd: { ASSET_PATH: '' } } }, ->
    res.locals.userAgent.should.equal 'foobar'

  it 'current_path does not include query params', ->
    middleware req = { url: 'localhost:3000/foo?bar=baz', get: -> 'foobar' },
      res = { locals: { sd: { ASSET_PATH: '' } } }, ->
    res.locals.sd.CURRENT_PATH.should.equal '/foo'

  it 'flags eigen', ->
    middleware req = { url: 'localhost:3000/foo?bar=baz', headers: { 'user-agent': 'Eigen' }, get: -> },
      res = { locals: { sd: {} } }, ->
    res.locals.sd.EIGEN.should.be.ok
