module.exports = class NodeBuilder
  constructor: (context) ->
    @context = context

  #public
  add_oscillator: ->
    oscillator = @context.createOscillator()
    oscillator.type = 'sine'
    oscillator.frequency.value = '200'
    oscillator

  add_gain: ->
    gain = @context.createGain()
