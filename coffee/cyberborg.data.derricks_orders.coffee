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
CyberBorg::derricks_orders = (derricks) ->
  extractor = "A0ResourceExtractor"
  truck = /Truck/
  truck_build = (derrick) ->
    function: 'orderDroidBuild'
    power: 0
    cost: 0
    like: truck
    limit: 5
    recruit: 1
    min: 1
    max: 1
    help: 1
    number: DORDER_BUILD
    structure: extractor
    at: x:derrick.x, y:derrick.y

  orders = WZArray.bless( derricks.map((derrick)->truck_build(derrick)) )
  Scouter.bless(orders)
  # Eight derricks starting from derrick #0
  orders.mod = 12
  orders.offset = 0
  return orders
