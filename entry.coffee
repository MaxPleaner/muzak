ToneGenerator = require './lib/tone_generator.coffee'

$ = require 'jquery'

$layout_content = $ require "html-loader!./templates/layout.slim"
$root_content = $ require "html-loader!./templates/root.slim"

# --------------------------------------------------
# TEMPLATES ARE BIG STRINGS AT THIS POINT
# --------------------------------------------------

$ ->

  $layout_wrapper = $ "#layout-wrapper"
  $layout_wrapper.append($layout_content)

  $root_wrapper = $ "#root-wrapper"
  $root_wrapper.append($root_content)

# --------------------------------------------------
# NOW THEY'RE ON THE DOM AND THEIR INLINE SCRIPTS ARE RUN
# --------------------------------------------------

new ToneGenerator()