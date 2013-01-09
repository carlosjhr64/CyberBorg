# JS extensions

# This is like ruby's number.times{ }
Number::times = (action) ->
  i = 0
  while i < this.valueOf()
    action()
    i++

# Alias debug as trace
# It's a way to differentiat intent
trace = debug
