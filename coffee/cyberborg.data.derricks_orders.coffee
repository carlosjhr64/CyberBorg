# ***Order Attributes***
# function:  the function name to call (order number often determines this)
# number:    order number
# like:      the unit name pattern
# power:     minimum power b/4 starting
# cost:      the power cost of the order
# limit:     the maximum group size
# recruit:   the amount of units order tries to get
# min:       minimum number of units required to execute order.
# max:       maximum allowed number of units to execute order.
# help:      the number of helping unit the job is willing to take.
# at:        preferred location.
# structure: structure to be built
# research:  technology to be researched
# name:      name of droid built (model name, need not be unique)
# body:
# propulsion:
# turret:
# { name: min: max: number: employ: at: ... }
CyberBorg::derricks_orders = (derricks) ->
  extractor = "A0ResourceExtractor"
  truck = /Truck/
  truck_build = (derrick) ->
    function: 'orderDroidBuild'
    power: 0
    cost: 0
    like: truck
    limit: 3
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
  orders.mod = 8
  orders.offset = 0
  return orders
