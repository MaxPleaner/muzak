module.exports = load: (deps) -> (->

  {
    db, StaticDom, state, JsPatches, NodeBuilder
  } = deps
  { 
    replace_array, random_string, get_average, get_cycled_index
  } = JsPatches
  {
    recording_filenames
  } = state

  @context = new AudioContext()
  @media_stream = @context.createMediaStreamDestination()
  @media_recorder = new MediaRecorder(@media_stream.stream)
  @node_builder = new NodeBuilder(@context)

  @logged_in = (user) =>
    {
      auth_content, grid_content, root_content, root_wrapper,
      grid_wrapper, credentials
    } = StaticDom
    state.current_user.uid = user.uid
    db.user_signed_in()
    auth_content().remove()
    root_wrapper().append grid_content()
    credentials().text "logged in as #{user.email}"

  @logged_out = =>
    { root_content, auth_wrapper, auth_content } = StaticDom
    state.current_user.uid = null
    root_content().remove()
    auth_wrapper().append auth_content()


  @start_node = (node) ->
    node.start() if node.start

  @stop_node = (node) ->
    node.stop() if node.stop

  @create_nodes = (id) =>
    throw("analyser hasn't been built yet") unless @analyser
    oscillator = node_builder.add_oscillator()
    gain = node_builder.add_gain()
    oscillator.connect(gain)
    gain.connect @analyser
    @nodes[id] = { oscillator, gain }
    Object.values(@nodes[id]).forEach (node) =>
      @start_node(node) unless node.playing
      node.playing = true

  @stop_nodes: (id) =>
    Object.values(@nodes[id] || {}).forEach (node) =>
      if node.playing
        node.disconnect(0)
        @stop_node(node)
      node.playing - false
    @nodes[id] = {}

  @init_analyser = (callback) =>
    callback ||= =>
    @add_media_recorder_events()
    @analyser = @context.createAnalyser()
    @analyser.connect @context.destination
    @analyser.fftSize = 2048
    requestAnimationFrame @analyser_tick(callback)

  @analyser_tick = (callback) =>
    requestAnimationFrame(@analyser_tick(callback))
    buffer_len = @analyser.frequencyBinCount
    frequencies = new Float32Array(buffer_len)
    @analyser.getFloatFrequencyData frequencies
    hz = sig2hz(frequencies)
    num_semitones = @identify_note(hz)
    @add_analyser_data_point({num_semitones, hz}, callback)
  
  @add_analyser_data_point = ({num_semitones, hz}, callback) =>
    data = state.analyser_data
    data.hertz.push hz
    data.num_semitones.push num_semitones
    data.idx += 1
    if data.idx > data.ticks_per_analyser_data_point
      callback @process_aggregated_analyser_data(data)
      @clear_aggregate_recorder_data(data)

  @clear_aggregate_recorder_data = (data) =>
    Object.assign data, {
      num_semitones: 0,
      hertz: 0,
      idx: 0
    }

  @process_aggregated_analyser_data: (data) =>
    avg_semitones = get_average data.num_semitones
    avg_hz = get_average data.hertz
    note = @get_note avg_semitones
    @clear_aggregate_recorder_data(data)
    { note, avg_semitones, avg_hz }

  @get_note: (num_semitones) =>
    scale_notes = state.scales["standard"]
    idx = get_cycled_index(num_semitones - 4, scale_notes)
    scale_notes[idx]

  @identify_note: (hz) =>
    (12 * (Math.log2(hz / 440))) + 49

  @add_media_recorder_events = =>
    @media_recorder.onerror = @media_recorder_on_error
    @media_recorder.ondataavailable = @media_recorder_on_data_available
    @media_recorder.onstop = @media_recorder_on_stop

  @media_recorder_on_stop = (evt) =>
    blob = new Blob @media_recorder_chunks,
      type: 'audio/ogg; codecs=opus'
    url = db.get_blob_url blob
    filename = "#{random_string()}.webm"
    db.store_audio blob, filename

  @media_recorder_on_data_available = (evt) =>
    state.media_recorder_chunks.push evt.data

  @media_recorder_on_error = (e) =>
    console.log("ERROR")
    throw e

  @sync_recording_state = (filenames, common_names) =>
    replace_array
    storage_ref_paths = @get_storage_ref_paths()
    @get_blobs_from_storage_refs(storage_ref_paths)
    .then @import_audio_blobs()

  @get_storage_ref_paths = =>
    "users/#{UID}/audios/#{filename}" for filename in @filenames
      
  @get_blobs_from_storage_refs = (storage_ref_paths) =>
    blob_promises = storage_ref_paths.map db.blob_from_ref_path
    Promise.all(blob_promises)

  @import_audio_blobs = (blobs) =>
    blob_urls = blobs.map db.get_blob_url
    StaticDom.recordings().empty()
    $audios = @add_recorded_audios(blob_urls)
    $select = @rebuild_recording_selector($audios, common_names)
    @add_recording_selector_events($index_container, $select)

  @rebuild_recording_selector = ($audios, common_names) =>
    $index_container = $ @build_recording_index_html()
    $select = $index_container.find "select"
    @add_recording_index_options($audios, $select, common_names)
    StaticDom.recordings_index()
    .empty()
    .append($index_container)
    $select

  @add_recording_selector_events = ($index_container, $select, filename) =>
    $change_recording = $index_container.find ".change-recording"
    $change_recording.on "click",
      @change_recording_on_click($select, filename)
    $change_recording.trigger "click"

  @change_recording_on_click = ($select, filename) => =>
    $selected = $select.find("option:selected")
    ($selected = $select.find("option")) if $selected.length == 0
    filename = $selected.val()
    @unhide_recording(filename)

  @unhide_recording = (filename) =>
    $(".audio[data-filename='#{filename}']")
    .removeClass("hidden")

  @add_recording_index_options = ($audios, $select, common_names) =>
    [0...$audios.length].forEach (idx) =>
      filename = $audios.eq(idx).data "filename"
      common_name = common_names[idx]
      $option = @build_recording_index_option filename, common_name
      $select.append $option

  @build_recording_index_option = (filename, common_name) =>
    """
      <option value='#{filename}'>
        #{common_name}
      </option
    """

  @build_recording_index_html = =>
    """
      <div class='recording-index-container'>
        <select id="audio-selector"></select>
        <button class='change-recording'>add</button>
      </div>
    """

  @add_recorded_audios = (blob_urls) =>
    $(blob_urls).map @add_recorded_audio

  @add_recorded_audio = (blob_url, idx) =>
    filename = filenames[idx]
    common_name = common_names[idx]
    $audio = $ @build_recorded_audio_html(blob_url)
    @configure_recorded_audio($audio, filename, common_name)
    StaticDom.recordings().prepend $audio
    $audio[0]

  @build_recorded_audio_html = (blob_url) =>
    """
      <section class='audio hidden'>
        <audio loop controls></audio>
        <section class='audio-options'>
          <a href='#{blob_url}' download=''>download</a>
          <button class='hide'>hide</button>
          <button class='remove'>delete</button>
          <input type='text' class='editable-filename'></input>
          <button class='editable-filename-submit'>edit filename</button>
        </section>
      <section>
    """

  @configure_recorded_audio = ($audio, filename, common_name) =>
    controls = @get_recorded_audio_controls $audio
    $audio.attr("data-filename", filename)
    controls.$audio_node.attr('src', url)
    controls.$audio_node.data("filename", filename)
    controls.$download_link.attr("download", filename)
    controls.$editable_filename.val common_name
    source = @connect_audio_source(controls.$audio_node)
    @add_event_listeners($audio, controls, filename, source)

  @add_event_listeners = ($audio, controls, filename, source) =>
    controls.$editable_filename.on "click",
      @edit_filename_on_click(controls, filename)
    controls.$hide_btn.on "click",
      @hide_btn_on_click($audio, controls)
    controls.$remove_btn.on "click",
      @remove_btn_on_click(source, $audio, filename)

  @remove_btn_on_click = (source, $audio, filename) =>
    source.disconnect()
    $audio.remove()
    db.remove_audio(filename)
    @remove_recording_from_index(filename)
  
  @remove_recording_from_index = (filename) =>
    selector = "[value='#{filename}']"
    StaticDom.recordings_index().find(selector).remove()

  @hide_btn_on_click = ($audio, controls) => =>
    $audio.addClass "hidden"
    controls.$audui_node[0].pause()

  @edit_filename_on_click = (controls, filename) =>
    db.store_audio_metadata filename,
      common_name: controls.$editable_filename.val()

  @connect_audio_source = ($audio_node) =>
    source = @context.createMediaElementSource $audio_node[0]
    source.connect @analyser
    source

  @get_recorded_audio_controls = ($audio) =>
    $hide_btn: $audio.find(".hide")
    $remove_btn: $audio.find(".remove")
    $audio_node: $audio.find "audio"
    $download_link: $audio.find("a")
    $editable_filename: $audio.find ".editable-filename"
    $editable_filename_submit: $audio.find ".editable-filename-submit"

  this

).apply {}