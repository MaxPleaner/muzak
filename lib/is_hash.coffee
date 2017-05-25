module.exports = (obj) ->
    return false if (!obj) 
    return false if Array.isArray(obj)
    return false if (obj.constructor != Object)
    return true
