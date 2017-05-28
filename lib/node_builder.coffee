
# ============================================================================
# Some utility methods for building Web Audio components
#
# Stuff to add:
#   - panning
#   - distortion
#   - reverb
#   - delay
#
#   etc
# ============================================================================

module.exports = class NodeBuilder

  constructor: (context) ->
    @context = context

  add_oscillator: ->
    oscillator = @context.createOscillator()
    oscillator.type = 'sine'
    oscillator.frequency.value = '200'
    oscillator

  add_gain: ->
    gain = @context.createGain()
