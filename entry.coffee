# --------------------------------------------------
# Helper deps
# --------------------------------------------------

window.ToneGenerator = require './lib/tone_generator.coffee'

# --------------------------------------------------
# Load templates as big strings
# --------------------------------------------------

window.$ = require 'jquery'

window.$layout_content = $ require "html-loader!./templates/layout.slim"
window.$root_content = $ require "html-loader!./templates/root.slim"

# --------------------------------------------------
# Attach templates to DOM, running their inline scripts
# --------------------------------------------------

$ ->

  $layout_wrapper = $ "#layout-wrapper"
  $layout_wrapper.append($layout_content)

  $root_wrapper = $ "#root-wrapper"
  $root_wrapper.append($root_content)
