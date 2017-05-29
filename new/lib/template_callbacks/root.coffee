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
    $template = $ @StaticDom.audio_template()[0].innerHTML
    @StaticDom.audios().append $template
    $play_btn = $template.find(".play")
    $stop_btn = $template.find(".stop")
    $remove_btn = $template.find(".remove")

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

