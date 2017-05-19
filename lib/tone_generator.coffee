module.exports = class ToneGenerator

  constructor: ->
    @ctx = new AudioContext()
    @oscillator = @ctx.createOscillator()
    @gain = @ctx.createGain()
    @oscillator.connect(@gain)
    @gain.connect @ctx.destination

  start: ->
    @oscillator.start(0)

  update: ({oscillator, gain}) =>
    if oscillator then @update_oscillator oscillator
    if gain then @update_gain gain

  update_oscillator: ({ type, freq }) =>
    if type then @oscillator.type = type
    if freq then @oscillator.frequency.value = freq

  update_gain: ({ val }) =>
    if val then @gain.gain.value = val
    console.log @gain.gain.value
    window.foo = @gain.gain

  stop: ->
    @oscillator.stop()
    # Note that this is NOT like pause; it cannot be restarted afterward.
    # Which begs the question of what the point of this method is

  close: ->
    @ctx.close()
    # needs to be called, or else the browser's hardware limits will quickly be reached.
    # For me, the limit is only 6 Audio Contexts.