module.exports = class ToneGenerator

  constructor: ->
    @ctx = new AudioContext()
    @oscillator = @ctx.createOscillator()
    @oscillator.type = "sin"
    @oscillator.frequency.value = 261.63
    @oscillator.start(0)
    @oscillator.connect @ctx.destination
