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
#   power:      minimum amount of power needed b/4 start construction
# { name: min: max: number: employ: at: ... }
CyberBorg::factory_orders = ->
  # General orders are...
  build = (obj) ->
    obj.function = "buildDroid"
    obj.like = /Factory/
    obj.power = 300
    obj.cost = 50
    obj.limit = 1
    obj.min = 1
    obj.max = 1
    obj.recruit = 1
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
