module.exports = npm_deps = (->

  @$        = require 'jquery'
  @sig2hz   = require 'signaltohertz'
  @firebase = require 'firebase/app'

  require 'firebase/auth'
  require 'firebase/storage'
  require 'firebase/database'

  this

).apply {}