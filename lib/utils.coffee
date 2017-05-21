module.exports = Utils = 

  last_id: -1

  context: new AudioContext()

  nodes: {}

  create_nodes: (id) ->
    node_builder = new NodeBuilder(@context)

    # add individual nodes    
    oscillator = node_builder.add_oscillator()
    gain = node_builder.add_gain()
    oscillator.connect(gain)
    gain.connect(@context.destination)

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

  # connect_node: (node) ->
  #   @connect_buffer_source node
  #   @connect_destination node

  # connect_buffer_source: (node, target) -> (->
  #   source = target.createBufferSource()
  #   source.connect node

  # connect_destination: (node, target) -> (->
  #   node.connect target.destination
