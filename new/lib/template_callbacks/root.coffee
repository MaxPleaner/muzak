module.exports = class

  constructor: (Muzak) ->
    {@Utils, @StaticDom} = Muzak
    @init_analyser()
    @add_event_listeners()

  add_event_listeners: ->
    @listener_to_add_sound_generator()
    @listener_to_toggle_recording_state()
    @listener_to_toggle_analyser_visibility()
    @listener_to_toggle_grid_visibility()
    @listener_to_toggle_recordings_visibility()
    @listener_to_logout()

  listener_to_logout: ->
    @StaticDom.logout.on "click" @logout_on_click()

  listener_to_toggle_recordings_visibility: ->
    @StaticDom.show_recordings().on 'click', @show_recordings_on_click()

  listener_to_toggle_analyser_visibility: ->
    @StaticDom.show_analyser().on 'click', @show_analyser_on_click()

  listener_to_toggle_grid_visibility: ->
    @StaticDom.show_grid().on 'click', @show_grid_on_click()

  listener_to_toggle_recording_state: ->
    @StaticDom.record().on 'click', @record_on_click()

  listener_to_add_sound_generator: ->
    @StaticDom.add_audio().on 'click', @add_audio_on_click()

  logout_on_click: -> =>

  show_grid_on_click: -> =>
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

  show_analyser_on_click: -> =>

  add_audio_on_click: -> =>

  record_on_click: -> =>

  show_recordings_on_click: -> =>
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

