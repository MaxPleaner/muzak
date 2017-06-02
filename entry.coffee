
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

window.$ = require 'jquery'

deps = (->

  @sig2hz   = require 'signaltohertz'
  @firebase = require 'firebase/app'

  require 'firebase/auth'
  require 'firebase/storage'
  require 'firebase/database'

  @NodeBuilder           = require './lib/node_builder.coffee'
  @AttachStylesheets     = require './lib/attach_stylesheets.coffee'
  @Templates             = require './lib/templates.coffee'
  @StaticDom             = require './lib/static_dom.coffee'
  @DomGraph              = require './lib/dom_graph.coffee'
  @TemplateCallbacks     = require './lib/template_callbacks.coffee'
  @state                 = require './lib/state.coffee'
  @config                = require './lib/config.coffee'
  @JsPatches             = require './lib/js_patches.coffee'
  { @build_dom_methods } = require './lib/build_dom_methods.coffee'

  @FirebaseWrapper       = require('./lib/firebase_wrapper.coffee').load(this)
  @db = new @FirebaseWrapper()

  @Utils                 = require('./lib/utils.coffee').load(this)
  @InitDom               = require('./lib/init_dom.coffee').load(this)
  @Validations           = require('./lib/validations.coffee').load(this)
  

  this

).apply {}

Object.assign window, {$, Muzak: deps}
  
new deps.InitDom()

