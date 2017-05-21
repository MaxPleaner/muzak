require './style.sass'

window.$ = require 'jquery'

window.NodeBuilder = require './lib/node_builder.coffee'
window.Utils = require './lib/utils.coffee'

$layout_content = $ require "html-loader!./templates/layout.slim"
$root_content = $ require "html-loader!./templates/root.slim"

$ ->

  $layout_wrapper = $ "#layout-wrapper"
  $layout_wrapper.append($layout_content)

  $root_wrapper = $ "#root-wrapper"
  console.log $root_wrapper
  $root_wrapper.append($root_content)
