module.exports = Utils = 

  last_id: -1

  context: new AudioContext()

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
    $change_recording.trigger "click"


  init_analyser: (callback) ->
    callback ||= ->
    @media_stream = @context.createMediaStreamDestination()
    @media_recorder = new MediaRecorder(@media_stream.stream)
    @init_media_recorder()
    @analyser = @context.createAnalyser()
    @analyser.connect @context.destination
    @analyser.fftSize = 2048
    requestAnimationFrame @analyser_tick(callback)

  media_recorder_chunks: []

  random_string: (length) ->
    Math.random().toString(36).substring(length || 7);

  add_recorded_audio: (url, filename, common_name) ->
    $audio = $ """
      <section class='audio hidden'>
        <audio loop controls></audio>
        <section class='audio-options'>
          <a href='#{url}' download=''>download</a>
          <button class='hide'>hide</button>
          <button class='delete'>delete</button>
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

    $remove_btn.find(".remove").on "click", ->
      source.disconnect()
      $audio.remove()
      db.remove_audio(filename)
    $audio

  init_media_recorder: ->

    @media_recorder.onerror = (e) =>
      console.log "ERR"
      debugger

    @media_recorder.ondataavailable = (evt) =>
      @media_recorder_chunks.push evt.data

    @media_recorder.onstop = (evt) =>
      blob = new Blob @media_recorder_chunks,
        'type': 'audio/ogg; codecs=opus'
      url = db.get_blob_url(blob)
      filename = "#{@random_string()}.webm"
      db.store_audio(blob, filename)

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

  data_points:
    idx: 0
    num_semitones: []
    hertz: []

  scale: "standard"

  get_average: (nums) ->
    real_nums = (num for num in nums when not isNaN num)
    sum = real_nums.reduce (memo, num) ->
      memo + num
    , 0
    sum / real_nums.length

  data_point_collection_len: 10

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

  get_note: (num_semitones) ->
    scale_notes = switch @scale
      when "standard"
        [
          "c", 'c#', 'd', 'd#', 'e', 'f', 'f#', 
          'g', 'g#', 'a', 'a#', 'b'
        ]
    idx = Math.round((num_semitones - 4) % scale_notes.length)
    # console.log(idx)
    scale_notes[idx]

  identify_note: (hz) ->
    (12 * (Math.log2(hz / 440))) + 49

  nodes: {}

  create_nodes: (id) ->
    node_builder = new NodeBuilder(@context)

    # add individual nodes    
    oscillator = node_builder.add_oscillator()
    gain = node_builder.add_gain()
    oscillator.connect(gain)
    gain.connect @analyser

    @nodes[id] = { oscillator, gain }
    Object.values(@nodes[id]).forEach (node) =>
      @start_node(node) unless node.playing
      node.playing = true

  stop_nodes: (id) ->
    Object.values(@nodes[id] || {}).forEach (node) =>
      if node.playing
        node.disconnect(0)
        @stop_node(node)
      node.playing = false
    @nodes[id] = {}


  start_node: (node) ->
    node.start() if node.start

  stop_node: (node) ->
    node.stop() if node.stop

  # connect_node: (node, target) ->
  #   @connect_buffer_source node, target
  #   @connect_destination node, target

  # connect_buffer_source: (node, target) ->
  #   source = target.createBufferSource()
  #   source.connect node

  # connect_destination: (node, target) ->
  #   node.connect target.destination
