module.exports = class ToneGenerator

  constructor: ->
    @ctx = new AudioContext()
    @oscillator = @ctx.createOscillator()
    @oscillator.connect @ctx.destination

  start: ->
    @oscillator.start(0)

  update: ({type, freq}) ->
    @oscillator.type = type
    @oscillator.frequency.value = freq

  stop: ->
    @oscillator.stop()
    # Note that this is NOT like pause; it cannot be restarted afterward.
    # Which begs the question of what the point of this method is

  close: ->
    @ctx.close()
    # needs to be called, or else the browser's hardware limits will quickly be reached.
    # For me, the limit is only 6 Audio Contexts.