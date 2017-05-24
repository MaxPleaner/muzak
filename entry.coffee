require './style.sass'

$ = require 'jquery'

firebase = require 'firebase/app'
require 'firebase/auth'
require 'firebase/storage'

FirebaseWrapper = require './lib/firebase_wrapper.coffee'

sig2hz = require 'signaltohertz'

NodeBuilder = require './lib/node_builder.coffee'
Utils = require './lib/utils.coffee'

$layout_content = $ require "html-loader!./templates/layout.slim"
$root_content = $ require "html-loader!./templates/root.slim"
$auth_content = $ require "html-loader!./templates/auth.slim"

db = new FirebaseWrapper({firebase})

Object.assign window, {
  $, firebase, sig2hz, NodeBuilder, Utils, db
}

auth_filter = ({on_success}) ->
  $auth_wrapper = $ "#auth-wrapper"
  $auth_wrapper.append $auth_content
    
  $("body").on "auth_done", (e) ->
    on_success(e)

$ ->

  $layout_wrapper = $ "#layout-wrapper"
  $layout_wrapper.append($layout_content)

  auth_filter on_success: ({credentials}) ->
    debugger
    $root_wrapper = $ "#root-wrapper"
    $root_wrapper.append($root_content)
