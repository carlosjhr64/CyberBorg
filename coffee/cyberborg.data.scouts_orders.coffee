#   ***Order Attributes***
#   function:  the function name to call
#   number:    order number
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

  scout = (derrick) ->
    function: 'orderDroidLoc'
    power: 0
    cost: 0
    like: /MgWh/
    limit: 12
    recruit: 1
    min: 1
    max: 1
    help: 1
    number: DORDER_SCOUT
    at: x:derrick.x, y:derrick.y

  orders = WZArray.bless( derricks.map((derrick)->scout(derrick)) )
  Scouter.bless(orders)
  # Five derricks starting at derrick #3
  orders.mod = 5
  orders.offset = 3
  return orders
