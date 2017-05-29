
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

$        = require 'jquery'
sig2hz   = require 'signaltohertz'
firebase = require 'firebase/app'

require 'firebase/auth'
require 'firebase/storage'
require 'firebase/database'

FirebaseWrapper   = require './lib/firebase_wrapper.coffee'
NodeBuilder       = require './lib/node_builder.coffee'
Utils             = require './lib/utils.coffee'
is_hash           = require "./lib/is_hash.coffee"
AttachStylesheets = require './lib/attach_stylesheets.coffee'
Templates         = require './lib/templates.coffee'
InitDom           = require './lib/init_dom.coffee'
StaticDom         = require './lib/static_dom.coffee'
TemplateCallbacks = require './lib/template_callbacks.coffee'
State             = require './lib/state.coffee'
Validations       = require('./lib/validations.coffee').load({StaticDom})

db = new FirebaseWrapper({firebase})

Object.assign window, { $, Muzak: {
  firebase, sig2hz, NodeBuilder, Utils, is_hash, db, state,
  Templates, FirebaseWrapper, TemplateCallbacks, Validations
}}
  
new InitDom(Muzak)

