
# ============================================================================
# This file is the entry point for the client
#
# It attaches the layout template to the page, and listens
# for firebase auth status to switch between root and auth templates.
# 
# The templates contain inline script calls, but each only invokes
# a single constructor for the class exported by
# lib/template_callbacks/<template>.slim
# ============================================================================

deps = (->

  @$        = require 'jquery'
  @sig2hz   = require 'signaltohertz'
  @firebase = require 'firebase/app'

  require 'firebase/auth'
  require 'firebase/storage'
  require 'firebase/database'

  @NodeBuilder       = require './lib/node_builder.coffee'
  @Utils             = require './lib/utils.coffee'
  @is_hash           = require "./lib/is_hash.coffee"
  @AttachStylesheets = require './lib/attach_stylesheets.coffee'
  @Templates         = require './lib/templates.coffee'
  @StaticDom         = require './lib/static_dom.coffee'
  @TemplateCallbacks = require './lib/template_callbacks.coffee'
  @State             = require './lib/state.coffee'
  @JsPatches         = require './lib/js_patches.coffee'

  @InitDom           = require('./lib/init_dom.coffee').load(this)
  @FirebaseWrapper   = require('./lib/firebase_wrapper.coffee').load(this)
  @Validations       = require('./lib/validations.coffee').load(this)
  @db = new FirebaseWrapper(this)

  this

).apply {}

Object.assign window, {$, Muzak: deps}
  
new InitDom(deps)

