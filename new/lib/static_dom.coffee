module.exports = (->

  layout_wrapper: =>
    @_layout_wrapper ||= $("#layout-wrapper")

  root_content: =>
    @_root_content ||= $("#root-content")

  audios: =>
    @_audios ||= @root_content().find("#audios")

  recordings: =>
    @_recordings ||= @root_content().find("#recordings")

  audio_template: =>
    @_audio_template ||= @root_content().find("#audio-template")

  analyser: =>
    @_analyser ||= @root_content().find("#analyser")

  analyser_note: =>
    @_analyser_note ||= @analyser().find("#note")

  analyser_hz: =>
    @_analyser_hz ||= @analyser().find("#hz")

  analyser_semitones: =>
    @_analyser_semitones ||= @analyser().find("#semitones")

  record_btn: =>
    @_record_btn ||= @root_content().find("#record")

  recordings: =>
    @_recordings ||= @root_content().find("#recordings")

  recordings_index: =>
    @_recordings_index ||= @root_content().find("#recordings-index")

  show_analyser_btn: =>
    @_show_analyser_btn ||= @root_content().find("#show-analyser")

  show_grid: =>
    @_show_grid ||= @root_content().find("#show-grid")

  grid_wrapper: =>
    @_grid_wrapper ||= @root_content().find("#grid-wrapper")

  grid_content: =>
    @_grid_content ||= @grid_wrapper().find("#grid-content")

  show_recordings: =>
    @_show_recordings ||= @root_content().find("#show-recordings")

  around_recordings: =>
    @_around_recordings ||= @root_content().find("#around-recordings")

  this

).apply {}