# ***Order Attributes***
# number:    order number
# like:      the unit name pattern
# power:     minimum power b/4 starting
# cost:      the power cost of the order
# limit:     the maximum group size
# min:       minimum number of units required to execute order.
# max:       maximum allowed number of units to execute order.
# help:      the number of helping unit the job is willing to take.
# at:        preferred location.
# structure: structure to be built
# research:  technology to be researched
# body:
# propulsion:
# turret:
# { name: min: max: number: employ: at: ... }
CyberBorg::scouts_orders = (derricks) ->

  scout = (derrick) ->
    power: 0
    cost: 0
    like: /MgWh/
    limit: 12
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
