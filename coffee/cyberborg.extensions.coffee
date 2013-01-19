# JS extensions

# This is like ruby's number.times{ }
Number::times = (action) ->
  i = 0
  while i < this.valueOf()
    action()
    i++

Number::to_i = () -> parseInt @.toFixed(0)

Number::order_map = () -> CyberBorg.ORDER_MAP[@]
