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
      node.start()

  stop_nodes: (id) ->
    Object.values(@nodes[id]).forEach (node) ->
      node.disconnect(0)
      node.stop()
    @nodes[id] = {}
