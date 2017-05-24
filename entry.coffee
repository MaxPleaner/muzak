require './style.sass'

$ = require 'jquery'

firebase = require 'firebase/app'
require 'firebase/auth'
require 'firebase/storage'
require 'firebase/database'

FirebaseWrapper = require './lib/firebase_wrapper.coffee'

sig2hz = require 'signaltohertz'

NodeBuilder = require './lib/node_builder.coffee'
Utils = require './lib/utils.coffee'

$layout_content = $ require "html-loader!./templates/layout.slim"
$root_content = $ require "html-loader!./templates/root.slim"
$auth_content = $ require "html-loader!./templates/auth.slim"

Object.assign window, {
  $, firebase, sig2hz, NodeBuilder, Utils
}

window.db = new FirebaseWrapper({firebase})

$ ->

  $layout_wrapper = $ "#layout-wrapper"
  $layout_wrapper.append($layout_content)

  firebase.auth().onAuthStateChanged (user) ->
    if user
      window.UID = user.uid
      db.ready()
      $auth_content.remove()
      $root_wrapper = $ "#root-wrapper"
      $root_wrapper.append($root_content)
      $credentials = $root_content.find "#credentials"
      $credentials.text "logged in as #{user.email}"
    else
      $root_content.remove()
      $auth_wrapper = $ "#auth-wrapper"
      $auth_wrapper.append $auth_content