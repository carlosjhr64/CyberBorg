# JS extensions

# This is like ruby's number.times{ }
Number::times = (action) ->
  i = 0
  while i < this.valueOf()
    action()
    i++

class Scouter
  @bless = (array) ->
    return array if array.is_scouter
    array[name] = method for name, method of Scouter.prototype
    array.offset = 0
    array.mod = @length
    array.index = -1
    array.is_scouter = true
    array

  set_current: () ->
    @_current = @offset + (@index % @mod)

  _next: () ->
    @index += 1
    @set_current()

  revert: () ->
    if @index > -1
      @index -= 1
      @set_current()
    else
      @_current = -1

# Alias debug as trace
# It's a way to differentiat intent
trace = debug
