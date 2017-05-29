module.exports =
  root: require "./template_callbacks/root.coffee"
  auth: require "./template_callbacks/auth.coffee"
  grid: require "./template_callbacks/grid.coffee"

#       show_grid: -> (->
#         $grid = Dom.grid_wrapper.find("#grid-content")
#         if Dom.show_grid.data("state") == "visible"
#           $grid.addClass("hidden")
#           Dom.show_grid.data("state", "hidden")
#           Dom.show_grid.text "grid (show)"
#         else
#           $grid.removeClass("hidden")
#           Dom.show_grid.data("state", "visible")
#           Dom.show_grid.text "grid (hide)"

#       ).apply Utils

# # ============================================================================
# # logs the user out.
# # no success callback is declared here;
# # rather the auth state is listened to elsewhere
# # ============================================================================

#       logout: -> (->
#         firebase.auth().signOut()
#       ).apply Utils

# # ============================================================================
# # Toggles the visibility of the analyser
# # ============================================================================

#       show_analyser: -> (->
#         if Dom.show_analyser_btn.data("state") == "open"
#           Dom.show_analyser_btn
#           .text("analyser (show)")
#           .data("state", "closed")
#           Dom.analyser.addClass "hidden"
#           DomState.analyser_visible = false
#         else
#           Dom.show_analyser_btn
#           .text("analyser (hide)")
#           .data("state", "open")
#           Dom.analyser.removeClass "hidden"
#           DomState.analyser_visible = true

#       ).apply Utils

# # ============================================================================
# # Toggles recording state
# # ============================================================================

#       record: (e) -> (->
#         if Dom.record_btn.data("playing") == "true"
#           @media_stream.disconnect()
#           @analyser.disconnect()
#           @analyser.connect @context.destination
#           @media_recorder.stop()
#           Dom.record_btn.text("record").data("playing", "false")
#         else
#           @analyser.disconnect()
#           @analyser.connect @media_stream
#           @media_stream.connect @context.destination
#           @media_recorder.start(1000)
#           Dom.record_btn.text("record (stop)").data("playing", "true")
#       ).apply Utils

# # ============================================================================
# # Adds a new audio generator to the page.
# # Declares event listeners for it.
# # ============================================================================

#       add_audio: (e) -> (->

#         $template = $ Dom.audio_template[0].innerHTML
#         Dom.audios.append $template
#         $play_btn = $template.find(".play")
#         $stop_btn = $template.find(".stop")
#         $remove_btn = $template.find(".remove")
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





