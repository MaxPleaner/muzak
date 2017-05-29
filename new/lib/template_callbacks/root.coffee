module.exports = class

  constructor: (Muzak) ->
    {@Utils, @StaticDom, @firebase} = Muzak
    @init_analyser()
    @add_event_listeners()

  add_event_listeners: ->
    @StaticDom.logout.on "click" @logout_on_click()
    @StaticDom.show_recordings().on 'click', @show_recordings_on_click
    @StaticDom.show_analyser().on 'click', @show_analyser_on_click
    @StaticDom.show_grid().on 'click', @show_grid_on_click
    @StaticDom.record().on 'click', @record_on_click
    @StaticDom.add_audio().on 'click', @add_audio_on_click

  logout_on_click: ->
    @firebase.auth().signOut()

  show_analyser_on_click: ->
    if @analyser_visible() then @hide_analyser() else @show_analyser()

  add_audio_on_click: ->
    $template = @build_audio_template()
    controls = @get_audio_controls $template
    id = (@Utils.last_id += 1)
    @add_audio_event_listeners(id, controls)

  set_audio_initial_state: (controls) ->
    controls.sliders.$oscillator.trigger "input"
    controls.sliders.$gain.trigger "input"

  add_audio_event_listeners: (id, controls) ->

    controls.play_btn
    .on 'click', @play_audio_on_click(id, controls)
    
    controls.stop_btn
    .on 'click', @stop_audio_on_click(id, controls)
    
    controls.remove_btn
    .on 'click', @remove_audio_on_click(id, controls, $template)
    
    controls.sliders.$oscillator
    .on 'input', @oscillator_on_input(id, controls)
    
    controls.sliders.$gain
    .on 'input', @gain_on_input(id, controls)
    
    controls.dropdowns.$oscillator_type
    .on 'change', @oscillator_type_on_change(id, controls)

    controls.$tone_value
    .on "input", @tone_value_on_input(id, controls)

    controls.$gain_value
    .on "input", @gain_value_on_input(id, controls)

  tone_value_on_input: (id, controls) -> =>
    oscillator = controls.sliders.$oscillator
    oscillator.val controls.$tone_value.val()
    oscillator.trigger "input"

  gain_value_on_input: (id, controls) -> =>
    gain = controls.sliders.$gain
    gain.val $gain_value.val()
    gain.trigger "input"

  oscillator_type_on_change: (id, controls) -> =>
    type = controls.dropdowns.$oscillator_type.val()
    @Utils.nodes[id].oscillator.type = type

  oscillator_on_input: (id, controls) -> =>
    freq = parseFloat controls.sliders.$oscillator.val()
    controls.$tone_value.val freq
    if oscillator = (Utils.nodes[id] || {}).oscillator
      oscillator.frequency.value = freq

  gain_on_input: (id, controls) -> =>
    val = parseFloat controls.sliders.$gain.val()
    controls.$gain_value.val val.toPrecision(4)
    if gain = (Utils.nodes[id] || {}).gain
      gain.gain.value = val

  stop_audio_on_click: (id, controls) -> =>
    @Utils.stop_nodes(id)
    controls.$play_btn.removeClass "hidden"
    controls.$stop_btn.addClass "hidden"

  remove_audio_on_click: (id, controls, $template) -> =>
    @Utils.stop_nodes(id)
    $template.remove()

  play_audio_on_click: (id, controls) -> =>
    @Utils.create_nodes(id)
    controls.$play_btn.addClass "hidden"
    controls.$stop_btn.removeClass "hidden"
    @setup_audio_sliders controls
    @set_audio_initial_state(controls)

  setup_audio_sliders: (controls) ->
    controls.sliders.$oscillator.trigger "input"
    controls.sliders.$gain.trigger "input"

  build_audio_template: ->
    $template = $ @StaticDom.audio_template()[0].innerHTML
    @StaticDom.audios().append $template
    $template

  get_audio_controls: ($template) ->
    $play_btn: $template.find(".play")
    $stop_btn: $template.find(".stop")
    $remove_btn: $template.find(".remove")
    $tone_value: $template.find(".tone-value")
    $gain_value: $template.find(".gain-value")
    sliders:
      $oscillator: $template.find(".sliders [name='oscillator']")
      $gain: $template.find(".sliders [name='gain']")
    dropdowns:
      $oscillator_type: $template.find(".dropdowns [name='oscillator-type']")

  record_on_click: ->
    if @recordings_visible() then @hide_recordings() else @show_recordings()

  recordings_visible: ->
    @StaticDom.record_btn().data("playing") == "true"

  hide_recordings: ->
    @Utils.media_stream.disconnect()
    @Utils.analyser.disconnect()
    @Utils.analyser.connect @Utils.context.destination
    @Utils.media_recorder.stop()
    @StaticDom.record_btn()
    .text("record")
    .data("playing", "false")

  show_recordings: ->
    @Utils.analyser.disconnect()
    @Utils.analyser.connect @Utils.media_stream
    @Utils.media_stream.connect @Utils.context.destination
    @Utils.media_recorder.start 1000
    @StaticDom.record_btn()
    .text("record(stop)")
    .data("playing", "true")

  show_analyser: ->
    @StaticDom.analyser().removeClass "hidden"
    @StaticDom.show_analyser_btn()
    .text("analyser (hide)")
    .data("state", "open")

  hide_analyser: ->
    @StaticDom.analyser().addClass "hidden"
    @StaticDom.show_analyser_btn()
    .text("analyser (show)")
    .data("state", "closed")

  analyser_visible: ->
    @StaticDom.show_analyser_btn().data("state") == "open"

  show_grid_on_click: ->
    if @grid_visible() then @hide_grid() else @show_grid()

  grid_visible: ->
    @StaticDom.show_grid().data("state") == "visible"

  show_grid: ->
    @StaticDom.grid_content().removeClass "hidden"
    @StaticDom.show_grid()
    .data("state", "visible")
    .text("grid (hide)")

  hide_grid: ->
    @StaticDom.grid_content().addClass "hidden"
    @StaticDom.show_grid()
    .data("state", "hidden")
    .text("grid (show)")

  show_recordings_on_click: ->
    if @recordings_visible() then @hide_recordings() else @show_recordings()      

  recordings_visible: ->
    @StaticDom.show_recordings().data("state") == "visible"

  show_recordings: ->
    @StaticDom.around_recordings().removeClass("hidden")
    @StaticDom.show_recordings()
    .data("state", "visible")
    .text("recordings (hide)")

  hide_recordings: ->
    @StaticDom.around_recordings().addClass("hidden")
    @StaticDom.show_recordings()
    .data("state", "hidden")
    .text("recordings (show)")

  init_analyser: ->
    @Utils.init_analyser @process_analyser_data()

  process_analyser_data: ->
    ({note, hz, semitones}) =>
      @StaticDom.analyser_note().text(note)
      @StaticDom.analyser_hz().text(hz) unless isNaN hz
      @StaticDom.analyser_semitones().text(semitones) unless isNaN semitones    

