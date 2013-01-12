# ***Order Attributes***
# function:  the function name to call (order number often determines this)
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
CyberBorg::factory_orders = ->
  # General orders are...
  build = (obj) ->
    obj.function = "buildDroid"
    obj.like = /Factory/
    obj.power = 440
    obj.cost = 50
    obj.limit = 5
    obj.min = 1
    obj.max = 1
    obj.help = 1
    return obj

  # ...a wheeled viper...
  whb1 = (droid) ->
    droid.body = "Body1REC"; droid.propulsion = "wheeled01"
    return droid

  # ...truck
  truck = name: "Truck", turret: "Spade1Mk1", droid_type: DROID_CONSTRUCT

  # ...machine gunner
  mg1 = name: "MgWhB1", turret: "MG1Mk1", droid_type: DROID_WEAPON

  # The orders are...
  orders = []
  # ... 1 truck
  (1).times -> orders.push(build whb1(truck))
  # ... 12 machine gunners
  (12).times -> orders.push(build whb1(mg1))
  WZArray.bless(orders)
