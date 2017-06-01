module.exports = class

  constructor: ({state}) ->
    @state = state
    { @grid_state } = @state

  build_col_html: (row_idx, col_idx) ->
    $ """
      <li data-row-idx='#{row_idx}' data-idx='#{col_idx}' class='col'>
        <span class='col-text'></span>
        <section class='hidden grid-cell-audio'>
        </section>
      </li>
    """

  build_modal_html: ->
    """
      <div class='col-opts-modal'>
      </div>
    """

  unselect_opts: (idx, node) =>
    node.removeAttribute "selected"

  build_null_option: ->
    """
      <option disabled selected value> -- select an option -- </option>
    """

  build_modal_opts: ($select) ->
    $modal = $ @build_modal_html()
    $selected_opts = $select.find("option:selected")
    $.each $selected_opts, @unselect_opts
    $select.prepend $ @build_null_option()
    $modal.append $select
    $opts.on "change", @opts_on_change($opts, $col, $grid_cell_audio, $modal)

  show_modal: ($col) ->
    $select = $("#audio-selector").clone()
    $grid_cell_audio = $col.find(".grid-cell-audio")
    $modal = @build_model_opts $select
    $modal

  opts_on_change: ($opts, $col, $grid_cell_audio, $modal) => =>
    $selected = $opts.find("option:selected")
    filename = $selected.val()
    common_name = $selected.text()
    row_idx = ~~$col.data("row-idx")
    col_idx = ~~$col.data("idx")
    row = @state.grid.matrix[row_idx]
    row[col_idx] = { cmd: "note", filename }
    $col.addClass("has-content")
    $col.attr("title", common_name)
    $audio = $(".audio[data-filename='#{filename}'] audio").clone()
    $audio.addClass("hidden")
    $grid_cell_audio.empty().append $audio
    $modal.remove()


  remove_col_content: ($col) ->
    @state.grid.matrix[row_idx][col_idx] = {cmd: "rest"}
    $col
    .attr("title", "")
    .text("")
    .removeClass("has-content")
    .find(".grid-cell-audio").empty()

  add_col_content_selector: ($col) ->
    return if $col.find(".col-opts-modal").length > 0
    $open_modal = @show_modal($col)
    $col.prepend $open_modal

  col_on_click: ($col) => =>
    if $col.hasClass "has-content"
      @remove_col_content($col)
    else
      @add_col_content_selector($col)

  col_on_mouseenter: ($col, $text) => =>
    if $col.hasClass("has-content")
      $text.text "x"
    true

  col_on_mouseleave: ($text) => =>
    $text.text ""
    true

  add_col: (row_idx, col_idx, $ul) ->
    $col = $ @build_col_html(row_idx, col_idx)
    $ul.append $col
    @add_col_events($col, row_idx, col_idx)
    @grid_state.$containers[row_idx].push $col

  add_col_events = ($col, row_idx, col_idx) ->
    $text = $col.find(".col-text")
    $col.on "click", @col_on_click($col)
    $col.on "mouseenter", @col_on_mousenter($col, $text)
    $col.on "mouseleave", @col_on_mouseleave($text)

  set_num_cols = (row_idx, num_cols, $rows, $row_wrapper, $ul) ->
    @state.grid.matrix[row_idx] = [0...num_cols].map -> {cmd: "rest"}
    @grid_state.$containers[row_idx] = []
    [0...num_cols].forEach (col_idx) -> @add_col(row_idx, col_idx, $ul)
    $rows.append $row_wrapper

  build_row = (idx) ->
    $ """
      <div class='row-wrapper'>
        <ul class='row' data-idx='#{idx}' ></ul>
          <button class='remove-row'>X</button>
          <label for='num-cols'> beats: </label>
          <input
            type='number'
            name='num-cols'
            class='num-cols'
          ></input>
        </div>
      </div>
    """

  play_row: (missing_rows) ->
    (row, row_idx) =>
      col_idx = @grid_state.col_idxs[row_idx]
      col = row[col_idx]
      if !col
        col_idx = 0
        @grid_state.col_idxs[row_idx] = col_idx
        col = row[col_idx]
      containers_row = @grid_state.$containers[row_idx]
      $last_col = if col_idx == 0
        containers_row[(containers_row.length) - 1]
      else
        containers_row[col_idx - 1]
      $last_col.removeClass("playing")
      unless @grid_state.$containers[row_idx]
        missing_rows.push row_idx
        return
      $container = @grid_state.$containers[row_idx][col_idx]
      $container.addClass("playing")
      switch col.cmd
        when "rest"
          null
        when "note"
          aud = @grid_state.audios[col.filename]
          aud ||= add_grid_audio_ref(
            $(".audios audio[filename='#{col.filename}']")[0]
          )
          aud.pause()
          aud.currentTime = 0
          aud.play()
      @grid_state.col_idxs[row_idx] += 1


  account_for_row_removal: (missing_rows) ->
    missing_rows.sort().reverse().forEach (idx) ->
      @state.grid.matrix.splice(idx, 1)

  play_next_note: ->
    missing_rows = []
    @state.grid.matrix.forEach @play_row(missing_rows)
    @account_for_row_removal(missing_rows)

  # =============================================================================
  # Most of the grid data is stored in matrices,
  # so indices are automatically adjusted upon row removal,
  # but the data on the DOM has to be manually changed.
  # =============================================================================

  fix_containers_after_removal = (row_idx) ->
    all_idxs = [0...(@grid_state.$containers.length + 1)]
    to_fix = all_idxs.filter (num) -> num > row_idx
    to_fix.forEach (idx) ->
      $containers = @grid_state.$containers[idx - 1]
      $containers[0].parent(".row").data("idx", idx - 1)
      $containers.forEach ($container) ->
        $container.attr("data-row-idx", idx - 1)
    @grid_state.last_row_idx -= 1

  # ============================================================================
  # Sets the column indexes to 0, both visually and in the @grid_state
  # ============================================================================

  reset_grid_state = ->
    $(".col.playing").removeClass "playing"
    @grid_state.col_idxs.forEach (_, row_idx) ->
      @grid_state.col_idxs[row_idx] = 0
      @grid_state.$containers[row_idx][0].addClass "playing"

  # =============================================================================
  # Called every animation frame, determines based on the provided "ticks_gap"
  # (the number of ms to wait between playing columns) whether to move forward in
  # the grid.
  # =============================================================================

  grid_tick = (ticks_gap, idx) ->
    ->
      if [ticks_gap, 0].includes(idx)
        play_next_note(idx) 
      idx += 1
      (idx = 0) if idx >= (ticks_gap * 2)
      if @grid_state.stopping
        @grid_state.stopping = false
        reset_grid_state()
      else
        requestAnimationFrame grid_tick(ticks_gap, idx)

  # ============================================================================
  # When a recording is attached to a column, a hidden audio node is created 
  # which gets attached to the grid recorder.
  # ============================================================================

  add_grid_audio_ref = (audio) ->
    { context, stream } = @grid_state
    audio_clone = $(audio).clone()[0]
    @grid_state.audios[$(audio).data("filename")] = audio_clone
    audio_clone.loop = false
    source = context.createMediaElementSource audio_clone
    source.connect context.destination
    source.connect stream
    audio_clone

  # ============================================================================
  # When the 'play grid' button is clicked, the DOM is parsed for bpm/division
  # which is used to call grid_tick (invoked in an animation frame request)
  #
  # NOTE looks to be a small bug in here, add_grid_audio_ref should be cached
  # ============================================================================

  play_grid = ->
    return true if @state.grid.matrix.length < 1
    bpm = parseFloat($bpm.val())
    console.log bpm, "bpm"
    division = parseFloat($division.find("option:selected").val() || 120)
    console.log division, "division"
    seconds_gap = 240 / (bpm * division)
    console.log seconds_gap, "seconds gap"
    ticks_gap = seconds_gap * 60.0
    console.log ticks_gap, "ticks gap"
    $audios = $(".audio audio")
    $.each $(".row"), (row_idx, row_node) ->
      row = @grid_state.$containers[row_idx]
      $.each $(row_node).find(".col"), (col_idx, col) ->
        row.push $(col)

    $.each $audios, (idx, audio) ->
      add_grid_audio_ref(audio)
    requestAnimationFrame(grid_tick ticks_gap, 0)

  # ============================================================================
  # Stops the grid by setting a config option that short-circuits the recursive
  # requestAnimationFrame sequence in grid_tick
  # ============================================================================

  stop_grid = ->
    @grid_state.stopping = true

  # ============================================================================
  # Turns grid recording on
  # ============================================================================

  start_recording = ->
    @grid_state.recorder.start(1000)

  # ============================================================================
  # Turns grid recording off
  # ============================================================================

  stop_recording = ->
    @grid_state.stream.disconnect()
    @grid_state.recorder.stop()

  # ============================================================================
  # Event listeners for button which toggles grid recording
  # ============================================================================

  $record_grid.on "click", ->
    if $record_grid.data("state") == "recording"
      $record_grid.data("state", "stopped")
      $record_grid.text "record"
      stop_recording()
    else
      $record_grid.data("state", "recording")
      $record_grid.text "record (stop)"
      start_recording()

  # ============================================================================
  # Event listener to add a row to the grid
  # Declares event listeners for the row (num cols, remove button)
  # ============================================================================

  $add_row.on "click", ->
    $row_wrapper = @build_row(@grid_state.last_row_idx += 1)
    $rows.append $row_wrapper
    $ul = $row_wrapper.find "ul"
    $num_cols = $row_wrapper.find ".num-cols"
    $remove_row = $row_wrapper.find ".remove-row"

    num_cols = ~~$default_row_length.val()
    row_idx = @grid_state.last_row_idx
    set_num_cols(row_idx, num_cols, $rows, $row_wrapper, $ul)
    $num_cols.val(num_cols)

    @grid_state.col_idxs[row_idx] = 0

    reset_grid_state()

    $remove_row.on "click", ->
      @grid_state.$containers.splice(row_idx, 1)
      @grid_state.col_idxs.splice row_idx, 1
      @state.grid.matrix.splice(row_idx, 1)
      $row_wrapper.remove()
      fix_containers_after_removal(row_idx)

    $num_cols.on "input", (e) ->
      $col = $(e.currentTarget)
      row_idx = $ul.data("idx")
      num_cols = ~~$num_cols.val()
      $ul.empty()
      set_num_cols row_idx, num_cols, $rows, $row_wrapper, $ul

  # ============================================================================
  # Button to toggle playback of the grid
  # ============================================================================

  $play_grid.on "click", ->
    if $play_grid.data("state") == "playing"
      $play_grid.text "play"
      $play_grid.data("state", "stopped")
      stop_grid()
    else
      $play_grid.text "stop"
      $play_grid.data("state", "playing")
      play_grid()


