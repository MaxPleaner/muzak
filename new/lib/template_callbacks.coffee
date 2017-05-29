module.exports =
  root: require "./template_callbacks/root.coffee"
  auth: require "./template_callbacks/auth.coffee"
  grid: require "./template_callbacks/grid.coffee"

# # ============================================================================
# # Adds a new audio generator to the page.
# # Declares event listeners for it.
# # ============================================================================

#       add_audio: (e) -> (->

# ......... ..... .....
#         sliders = 
#           $oscillator: $template.find(".sliders [name='oscillator']")
#           $gain: $template.find(".sliders [name='gain']")
#         dropdowns =
#           $oscillator_type: $template.find(".dropdowns [name='oscillator-type']")
#         $tone_value = $template.find(".tone-value")
#         $gain_value = $template.find(".gain-value")

#         id = (@last_id += 1)

#         $play_btn.on "click", =>
#           @create_nodes(id)
#           $play_btn.addClass("hidden")
#           $stop_btn.removeClass("hidden")
#           sliders.$oscillator.trigger "input"
#           sliders.$gain.trigger "input"

#         $stop_btn.on "click", =>
#           @stop_nodes(id)
#           $play_btn.removeClass("hidden")
#           $stop_btn.addClass("hidden")

#         $remove_btn.on "click", =>
#           @stop_nodes(id)
#           $template.remove()

#         sliders.$oscillator.on "input", =>
#           freq = parseFloat sliders.$oscillator.val()
#           $tone_value.val(freq)
#           if @nodes[id]
#             oscillator = @nodes[id].oscillator
#             if oscillator
#               oscillator.frequency.value = freq

#         sliders.$oscillator.trigger("input")

#         sliders.$gain.on "input", =>
#           val = parseFloat sliders.$gain.val()
#           $gain_value.val(val.toPrecision(4))
#           if @nodes[id]
#             gain = @nodes[id].gain
#             if gain
#               gain.gain.value = val

#         sliders.$gain.trigger("input")

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





