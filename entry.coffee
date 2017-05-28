
# ============================================================================
# This file is the entry point for the client
# ============================================================================

NpmDeps           = require './lib/npm_deps.coffee'
CustomDeps        = require './lib/custom_deps.coffee'
AttachStylesheets = require './lib/attach_stylesheets.coffee'
Templates         = require './lib/templates.coffee'
InitDom           = require './lib/init_dom.coffee'
StaticDom         = require './lib/static_dom.coffee'

{ $, sig2hz, firebase }                                          = NpmDeps
{ FirebaseWrapper, NodeBuilder, Utils, is_hash }                 = CustomDeps

new AttachStylesheets()

state =
  grid_matrix: []
  last_row_idx: -1

db = new FirebaseWrapper({firebase})

Object.assign window, {
  $, firebase, sig2hz, NodeBuilder, Utils, is_hash,
  db, state
}

new InitDom(StaticDom, Templates)

