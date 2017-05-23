module.exports = Utils = 

  last_id: -1

  context: new AudioContext()

  init_analyser: (callback) ->
    callback ||= ->
    @analyser = @context.createAnalyser()
    @analyser.connect @context.destination
    @analyser.fftSize = 2048
    requestAnimationFrame @analyser_tick(callback)

  analyser_tick: (callback) ->
    -> (->
      requestAnimationFrame(@analyser_tick(callback))
      buffer_len = @analyser.frequencyBinCount
      frequencies = new Float32Array(buffer_len)
      @analyser.getFloatFrequencyData frequencies
      hz = sig2hz(frequencies)
      note = @identify_note(hz)
      @add_data_point(note, callback)
    ).apply Utils

  data_points:
    notes: []

  get_average: (nums) ->
    real_nums = (num for num in nums when not isNaN num)
    sum = real_nums.reduce (memo, num) ->
      memo + num
    , 0
    sum / real_nums.length

  data_point_collection_len: 1

  add_data_point: (note, callback) -> (->
    notes = @data_points.notes    
    notes.push note
    if notes.length > @data_point_collection_len
      avg = @get_average(notes)
      @data_points.notes = []
      callback({note: avg})
  ).apply Utils

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
