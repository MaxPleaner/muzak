
# ============================================================================
# This file is the entry point for the client
# ============================================================================

NpmDeps           = require './lib/npm_deps.coffee'
CustomDeps        = require './lib/custom_deps.coffee'
AttachStylesheets = require './lib/attach_stylesheets.coffee'
Templates         = require './lib/templates.coffee'
InitDom           = require './lib/init_dom.coffee'
StaticDom         = require './lib/static_dom.coffee'
TemplateCallbacks = require './lib/template_callbacks.coffee'
State             = require './lib/state.coffee'

{ firebase, $ } = NpmDeps

db = new FirebaseWrapper({firebase})

new AttachStylesheets()

Muzak = {
  $, firebase, sig2hz, NodeBuilder, Utils, is_hash,
  db, state, Templates, FirebaseWrapper, TemplateCallbacks
}

Object.assign window, { Muzak, $ }

new InitDom(Muzak)

