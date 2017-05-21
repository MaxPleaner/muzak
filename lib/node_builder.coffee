module.exports = class NodeBuilder
  constructor: (context) ->
    @context = context

  #public
  add_oscillator: ->
    oscillator = @context.createOscillator()
    oscillator.type = 'sine'
    oscillator.frequency.value = '200'
    @connect_destination oscillator
    oscillator

  #private
  connect_node: (node) ->
    @connect_buffer_source node
    @connect_destination node
  connect_buffer_source: (node) -> (->
    source = @createBufferSource()
    source.connect node
  ).apply @context
  connect_destination: (node) -> (->
    node.connect @destination
  ).apply @context
