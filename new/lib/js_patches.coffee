module.exports = (->

  @replace_array = (source, target) ->
    source.length = 0
    source.push target...
    # https://stackoverflow.com/a/1234337


  @random_string = (length) ->
    Math.random().toString(36).substring(length || 7)

  @get_average = (nums) ->
    real_nums = (num for num in nums when not isNaN num)
    sum = real_nums.reduce (memo, num) ->
      memo + num
    , 0
    sum / real_nums.length

  @get_cycled_index = (orig_index, array) ->
    Math.round(orig_index % scale_notes.length)

  @is_hash = (obj) ->
    return false if (!obj) 
    return false if Array.isArray(obj)
    return false if (obj.constructor != Object)
    return true

  this
  
).apply {}