module.exports = Utils = 

  last_id: -1

  context: new AudioContext()

  nodes: {}

  create_nodes: (id) ->
    node_builder = new NodeBuilder(@context)
    oscillator = node_builder.add_oscillator()
    @nodes[id] = {
      oscillator
    }
    Object.values(@nodes[id]).forEach (node) ->
      node.start() unless node.playing
      node.playing = true

  stop_nodes: (id) ->
    Object.values(@nodes[id] || {}).forEach (node) ->
      if node.playing
        node.disconnect(0)
        node.stop()
      node.playing = false
    @nodes[id] = {}
