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