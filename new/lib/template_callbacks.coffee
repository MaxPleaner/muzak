module.exports =
  root: require "./template_callbacks/root.coffee"
  auth: require "./template_callbacks/auth.coffee"
  grid: require "./template_callbacks/grid.coffee"

# # ============================================================================
# # Adds a new audio generator to the page.
# # Declares event listeners for it.
# # ============================================================================

#         dropdowns.$oscillator_type.on "change", =>
#           type = dropdowns.$oscillator_type.val()
#           @nodes[id].oscillator.type = type

#         $tone_value.on "input", (e) =>
#           oscillator = sliders.$oscillator
#           oscillator.val $tone_value.val()
#           oscillator.trigger "input"

#         $gain_value.on "input", (e) =>
#           gain = sliders.$gain
#           gain.val $gain_value.val()
#           gain.trigger "input" 

#       ).apply Utils





