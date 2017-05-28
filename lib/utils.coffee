
# ============================================================================
# This is a huge file which probably should get split up.
# ============================================================================

module.exports = Utils = 

# ============================================================================
# Grid rows are tracked by in-memory objects (state.grid_matrix and grid_state)
# but they also have the row/column indexes added to the DOM.
# 
# In order to do this correctly, the most recent row index is stored.
# It's incremented whenever a row is added, and decremented when one is removed.
# ============================================================================

  last_id: -1

# ============================================================================
# AudioContext is a limited resource;
# There can only be 6 alive on a page in my browser.
#
# This site uses two contexts; one for the grid and one for everything else
# The context here is the 'everything else'
# ============================================================================

  context: new AudioContext()

# ============================================================================
# Function that runs when the client gets a refreshed list of recordings
# Fetches all the blobs and recreates the 'recordings' component
# ============================================================================

  sync_recording_state: (filenames, common_names) ->
    storage_ref_paths = filenames.map (filename) =>
      "users/#{UID}/audios/#{filename}"
    blob_promises = storage_ref_paths.map db.blob_from_ref_path
    Promise.all(blob_promises)
    .then (blobs) =>
      blob_urls = blobs.map db.get_blob_url
      Dom.recordings.empty()
      $audios = $ blob_urls.map (url, idx) =>
        @add_recorded_audio(url, filenames[idx], common_names[idx])[0]
      @setup_recording_selector($audios, common_names)

# ============================================================================
# There's a dropdown to select a recording to play.
# It gets recreated whenever the recordings list updates.
# The event listeners for the dropdown get added here as well.
# ============================================================================

  setup_recording_selector: ($audios, common_names) ->

    $index_container = $ """
      <div class='recording-index-container'>
        <select id="audio-selector"></select>
        <button class='change-recording'>add</button>
      </div>
    """

    $select = $index_container.find("select")

    [0...$audios.length].forEach (idx) =>
      filename = $audios.eq(idx).data("filename")
      $option = $ """
        <option value='#{filename}'>#{common_names[idx]}</option>
      """
      $select.append $option
    Dom.recordings_index.empty()

    Dom.recordings_index.append($index_container)

    $change_recording = $index_container.find(".change-recording")

    $change_recording.on "click", =>
      selected = $select.find("option:selected")[0]
      selected ||= $select.find("option")[0]
      filename = $(selected).val()
      $(".audio[data-filename='#{filename}']").removeClass("hidden")

    # automatically display the first recording in the list
    $change_recording.trigger "click"

# ============================================================================
# The analyser is the final node before the main output.
# All other nodes (oscillators / recordings) get connected to it.
# It only gets initialized once.
# ============================================================================

  init_analyser: (callback) ->
    callback ||= ->
    @media_stream = @context.createMediaStreamDestination()
    @media_recorder = new MediaRecorder(@media_stream.stream)
    @init_media_recorder()
    @analyser = @context.createAnalyser()
    @analyser.connect @context.destination
    @analyser.fftSize = 2048
    requestAnimationFrame @analyser_tick(callback)

# ============================================================================
# When recording is in progress, chunks get pushed to an array
# ============================================================================

  media_recorder_chunks: []

# ============================================================================
# Filenames for recordings are randomly generated.
# This is used as the key/identifier for recordings.
# There is also a "common name", i.e. display name, that is separate.
# ============================================================================

  random_string: (length) ->
    Math.random().toString(36).substring(length || 7);

# ============================================================================
# Once the user selects a recording from the dropdown, it is added to DOM.
# This builds the HTML, attaches it, and adds event listeners.
# ============================================================================

  add_recorded_audio: (url, filename, common_name) ->
    $audio = $ """
      <section class='audio hidden'>
        <audio loop controls></audio>
        <section class='audio-options'>
          <a href='#{url}' download=''>download</a>
          <button class='hide'>hide</button>
          <button class='remove'>delete</button>
          <input type='text' class='editable-filename'></input>
          <button class='editable-filename-submit'>edit filename</button>
        </section>
      <section>
    """
    
    $hide_btn = $audio.find(".hide")
    $remove_btn = $audio.find(".remove")
    $audio_node = $audio.find "audio"
    $download_link = $audio.find("a")
    $editable_filename = $audio.find ".editable-filename"
    $editable_filename_submit = $audio.find ".editable-filename-submit"

    $audio.attr("data-filename", filename)
    $audio_node.attr('src', url)
    $audio_node.data("filename", filename)
    $download_link.attr("download", filename)
    $editable_filename.val common_name

    Dom.recordings.append $audio
    source = @context.createMediaElementSource($audio.find("audio")[0])
    source.connect(@analyser)

    $editable_filename_submit.on "click", ->
      val = $editable_filename.val()
      db.store_audio_metadata(filename, {common_name: val})

    $hide_btn.on "click", ->
      $audio.addClass("hidden")
      $audio_node[0].pause()

    $remove_btn.on "click", ->
      source.disconnect()
      $audio.remove()
      db.remove_audio(filename)
      Dom.recordings_index.find("[value='#{filename}']").remove()
    $audio

# ============================================================================
# The media recorder gets initialized with callbacks.
# Chunks are saved periodically, and upon stop the blob is uploaded.
# No 'success' event is defined here;
# rather, the realtime database listener is declared elsewhere
# ============================================================================

  init_media_recorder: ->

    @media_recorder.onerror = (e) =>
      console.log "ERR"
      throw e

    @media_recorder.ondataavailable = (evt) =>
      @media_recorder_chunks.push evt.data

    @media_recorder.onstop = (evt) =>
      blob = new Blob @media_recorder_chunks,
        'type': 'audio/ogg; codecs=opus'
      url = db.get_blob_url(blob)
      filename = "#{@random_string()}.webm"
      db.store_audio(blob, filename)

# ============================================================================
# analyser_tick runs every animation frame.
# it calculates the frequency, and uses that to find the Hz / musical note.
# The callback is only called every N frames,
# where N is data_point_collection_length.
# It's invoked with the averaged data (note, semitones, and hz)
# ============================================================================

  analyser_tick: (callback) ->
    -> (->
      requestAnimationFrame(@analyser_tick(callback))
      buffer_len = @analyser.frequencyBinCount
      frequencies = new Float32Array(buffer_len)
      @analyser.getFloatFrequencyData frequencies
      hz = sig2hz(frequencies)
      num_semitones_datum = @identify_note(hz)
      @add_data_point({num_semitones_datum, hz}, callback)
    ).apply Utils

# ============================================================================
# Analyser data is not updated on the DOM each animation frame;
# rather, the average of the past N frames is shown,
# where N equals Utils.data_point_collection_len
#
# If the frequencies were not averaged, and the results were updated each
# frame, then due to the inherit variation of the oscillator's frequencies
# the detected note would fluctuate too rapidly.
#
# This is a storage for that data; it's emptied whenever it's averaged.
# ============================================================================

  data_points:
    idx: 0
    num_semitones: []
    hertz: []

# ============================================================================
# There's two potential ways to do 'note detection':
#
#   1. the 'conventional' way (used by this app)
#        - standard A440 tuning (the A note is tuned to 440hz)
#        - 12-step (semitones) equal temperament scale
#        - using a math equation (identify_note), the herz can be used to
#          find the number of semitones from the root note
#        - The num semitones can be used as an index into a cyclical array
#          containing the sequence of musical notes.
#        - for example, if the scale is [A,B,C] and a frequency is known to be
#          A semitones from the root, then the note would be A since it cycles
#          through exactly once.
#
#   2. the more scientific approach, which would take advantage of the
#      computer's power to calculate every single possible "note name" for a
#      given frequency.
#        - tone.js has a 1MB file of microtonal scales data
#        - thus it's probably the best tool; however the lookup structure
#          from frequency => notes needs to be constructed manually.
#
# Anyway, here only the aformentioned equal-temperament scale is used,
# but so that more can be added it is named and checked for in a case statement.
# ============================================================================

  scale: "standard"

# ============================================================================
# Gets the average of an array of nums. Ignores any elements that are NaN.
# Used to calculate the average musical note over some period of time.
# ============================================================================

  get_average: (nums) ->
    real_nums = (num for num in nums when not isNaN num)
    sum = real_nums.reduce (memo, num) ->
      memo + num
    , 0
    sum / real_nums.length

# ============================================================================
# The num frames wherein detected frequency data is aggregated.
# Too small, and the detected note will fluctuate wildly.
# Too big, and it won't appear realtime.
# A value of 10 means it's run every 10 frames; 6 times per second
# ============================================================================

  data_point_collection_len: 10

# ============================================================================
# Run every frame to add the frequency data to the accumulator.
# If the interval for accumulating values is done,
# then the average is calculated and the callback is invoked.
#
# This method gets called by interval_tick
# ============================================================================

  add_data_point: ({num_semitones_datum, hz}, callback) -> (->
    num_semitones = @data_points.num_semitones
    hertz = @data_points.hertz
    hertz.push hz
    num_semitones.push num_semitones_datum
    @data_points.idx += 1
    if @data_points.idx > @data_point_collection_len
      @data_points.idx = 0
      avg_semitones = @get_average(num_semitones)
      avg_hz = @get_average hertz
      @data_points.num_semitones = []
      @data_points.hertz = []
      note = @get_note(avg_semitones)
      callback({
        note,
        semitones: avg_semitones,
        hz: avg_hz
      })
  ).apply Utils

# ============================================================================
# Uses cyclical indexing to get the note in the scale given the num semitones
#
# Don't ask why the -4 is in there, all I know is it makes the data correct
# ============================================================================

  get_note: (num_semitones) ->
    scale_notes = switch @scale
      when "standard"
        [
          "c", 'c#', 'd', 'd#', 'e', 'f', 'f#', 
          'g', 'g#', 'a', 'a#', 'b'
        ]
    idx = Math.round((num_semitones - 4) % scale_notes.length)
    scale_notes[idx]

# ============================================================================
# Assuming the standard A440 tuning, finds the number of semitones from the root
# given some frequency.
# ============================================================================

  identify_note: (hz) ->
    (12 * (Math.log2(hz / 440))) + 49

# ============================================================================
# A store of references to components making up the sound generators.
# This is a map of id (index of the sound generator) to a hash with keys
# oscillator and gain.
#
# Unline <audio>, web audio components don't have built in DOM controls so at
# the end of the day, the objects need to be stored in memory so that there's
# a way to update them. 
# ============================================================================

  nodes: {}

# ============================================================================
# Create the nodes that go into a single sound generator.
# This is just oscillator and gain for now.
#
# Something probably surprising here: these are recreated every time the
# sound generator's play button is clicked. Maybe this should be refactored ...
# ============================================================================

  create_nodes: (id) ->

    node_builder = new NodeBuilder(@context)

    oscillator = node_builder.add_oscillator()
    gain = node_builder.add_gain()
    oscillator.connect(gain)
    gain.connect @analyser

    @nodes[id] = { oscillator, gain }
    Object.values(@nodes[id]).forEach (node) =>
      @start_node(node) unless node.playing
      node.playing = true

# ============================================================================
# Disconnect sound generator nodes, called when "stop" button is clicked.
# ============================================================================

  stop_nodes: (id) ->
    Object.values(@nodes[id] || {}).forEach (node) =>
      if node.playing
        node.disconnect(0)
        @stop_node(node)
      node.playing = false
    @nodes[id] = {}

# ============================================================================
# Starts a sound generator ... refactor?
# ============================================================================

  start_node: (node) ->
    node.start() if node.start

# ============================================================================
# Stops a sound generator ... refactor?
# ============================================================================

  stop_node: (node) ->
    node.stop() if node.stop
