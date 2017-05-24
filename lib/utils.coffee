module.exports = Utils = 

  last_id: -1

  context: new AudioContext()

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

  init_media_recorder: ->

    @media_recorder.onerror = (e) =>
      console.log "ERR"
      debugger

    @media_recorder.ondataavailable = (evt) =>
      @media_recorder_chunks.push evt.data

    @media_recorder.onstop = (evt) =>
      blob = new Blob @media_recorder_chunks,
        'type': 'audio/ogg; codecs=opus'
      url = URL.createObjectURL blob
      filename = "#{@random_string()}.webm"
      db.store_audio(blob, filename)
      $audio = $ """
        <section class='audio'>
          <audio loop controls></audio>
          <br>
          <section class='audio-options'>
            <a href='#{url} download=''>download</a>
            <button class='remove'>remove</button>
          </section>
        <section>
      """
      $audio.find("audio").attr('src', url)
      Dom.recordings.append $audio
      $audio.find(".remove").on "click", ->
        $audio.remove()

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
