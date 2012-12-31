# JS extensions

# This is like ruby's number.times{ }
Number::times = (action) ->
  i = 0
  while i < this.valueOf()
    action()
    i++

getObjectClass = (obj) ->
  if (obj and obj.constructor and obj.constructor.toString)
    arr = obj.constructor.toString().match(/function\s*(\w+)/)
    return arr[1] if arr and (arr.length is 2)
  undefined
