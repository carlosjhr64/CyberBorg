#   ***Order Attributes***
#   function:  the function name to call
#   number:    order number for order functins, like orderDroid(... order.number ...).
#   min:       minimum number of units required to execute order.
#   max:       maximum allowed number of units to execute order.
#   employ:    (unit_name)-> amount of the unit the group will to employ.
#   at:        preferred location.
#   structure:
#   body:
#   propulsion:
#   turret:
#   research:
# { name: min: max: number: employ: at: ... }
CyberBorg::scouts_orders = (derricks) ->
  # What we're building
  extractor = "A0ResourceExtractor"

  p = (n,x,em) ->
    min: n
    max: x
    number: DORDER_SCOUT
    employ: (name) ->
      ('MgWhB1': em)[name]

  # With how many trucks, etc...
  p11 = -> p(1,1,9)

  # Returning an object
  order = (str, x, y, p) ->
    # str, x, y, p = data...
    p.structure = str
    p.at = x: x, y: y
    p

  orders = []
  orders.push(order(extractor, derrick.x, derrick.y, p11())) for derrick in derricks
  WZArray.bless(orders)
  # TODO
  #orders._current = 4
  #orders._current_min = 4
  #orders._current_max = 8
  #orders.next = () ->
  #  orders._current -=1
  #  orders._current = orders._current_max
  #  if orders._current < orders._current_min
  #    orders._current_max += 1
  #    orders._current_min += 1
  #    orders._current += orders._current_max
  #  return orders[orders._current]
  return orders
