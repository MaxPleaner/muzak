
# ============================================================================
# This file is the entry point for the client
# ============================================================================

# ============================================================================
# npm deps
# ============================================================================

$ = require 'jquery'
sig2hz = require 'signaltohertz'
firebase = require 'firebase/app'
require 'firebase/auth'
require 'firebase/storage'
require 'firebase/database'


# ============================================================================
# custom file deps
# ============================================================================

FirebaseWrapper = require './lib/firebase_wrapper.coffee'
NodeBuilder = require './lib/node_builder.coffee'
Utils = require './lib/utils.coffee'
is_hash = require "./lib/is_hash.coffee"

# ============================================================================
# attach stylesheet to dom
# ============================================================================

require './style.sass'

# ============================================================================
# load templates from slim files into strings,
# then pass them to jQuery to build nodes
# ============================================================================

$layout_content = $ require "html-loader!./templates/layout.slim"
$root_content = $ require "html-loader!./templates/root.slim"
$auth_content = $ require "html-loader!./templates/auth.slim"
$grid_content = $ require "html-loader!./templates/grid.slim"

# ============================================================================
# Initialize custom ORM and grid state
# ============================================================================

db = new FirebaseWrapper({firebase})

state =
  grid_matrix: []
  last_row_idx: -1

# ============================================================================
# Make some things globals
# ============================================================================

Object.assign window, {
  $, firebase, sig2hz, NodeBuilder, Utils, is_hash,
  db, state
}

$ ->

# ============================================================================
# Start by attaching the layout template to the DOM
# ============================================================================

  $layout_wrapper = $ "#layout-wrapper"
  $layout_wrapper.append($layout_content)

# ============================================================================
# Render the root or auth template, depending on the login state
# Note that Firebase handles this, there is no session tracking code here.
# ============================================================================

  firebase_logged_in = (user) ->
    window.UID = user.uid
    db.ready()
    $auth_content.remove()
    $root_wrapper = $ "#root-wrapper"
    $root_wrapper.append($root_content)
    $grid_wrapper = $root_content.find "#grid-wrapper"
    $grid_wrapper.append $grid_content
    $credentials = $root_content.find "#credentials"
    $credentials.text "logged in as #{user.email}"

  firebase_logged_out = ->
    window.UID = null
    $root_content.remove()
    $auth_wrapper = $ "#auth-wrapper"
    $auth_wrapper.append $auth_content


  firebase.auth().onAuthStateChanged (user) ->
    if user then firebase_logged_in(user) else firebase_logged_out()      

# ============================================================================
# Global keyboard shortcuts (right now it's only 'r' to toggle recording
# ============================================================================

  $(document).on "keyup", (e) ->
    if e.which == 82 # the 'r' key
      $("#record").trigger "click"