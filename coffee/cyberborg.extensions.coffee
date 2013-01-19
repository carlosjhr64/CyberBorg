# JS extensions

# This is like ruby's number.times{ }
Number::times = (action) ->
  i = 0
  while i < this.valueOf()
    action()
    i++

Number::order_map = () -> CyberBorg.ORDER_MAP[@]
