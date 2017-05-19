# --------------------------------------------------
# Load CSS
# --------------------------------------------------

require './style.sass'

# --------------------------------------------------
# Helper deps
# --------------------------------------------------

# ... globals
window.$ = require 'jquery'
window.ToneGenerator = require './lib/tone_generator.coffee'

# custom almost-global properties
window.state = {}

# custom almost-global functions
window.helpers = {}

# --------------------------------------------------
# Load templates as big strings
# --------------------------------------------------

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
