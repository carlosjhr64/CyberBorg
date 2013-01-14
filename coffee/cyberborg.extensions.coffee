# JS extensions

# This is like ruby's number.times{ }
Number::times = (action) ->
  i = 0
  while i < this.valueOf()
    action()
    i++

Number::order_map = () -> CyberBorg.ORDER_MAP[@]

# Alias debug as trace
# It's a way to differentiat intent
trace = (message) ->
  debug(message) if CyberBorg.TRACE
