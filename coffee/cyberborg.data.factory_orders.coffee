CyberBorg::factory_orders = ->
  # A wheeled viper
  whb1 = (droid) ->
    droid.body = "Body1REC"; droid.propulsion = "wheeled01"
    droid
  # A wheeled truck
  truck = name: "Truck", turret: "Spade1Mk1", droid_type: DROID_CONSTRUCT
  # A wheeled machine gunner
  mg1 = name: "MgWhB1", turret: "MG1Mk1", droid_type: DROID_WEAPON
  # The orders are...
  orders = []
  # ... 2 trucks
  (2).times -> orders.push(whb1(truck))
  # ... 12 machine gunners
  (12).times -> orders.push(whb1(mg1))
  WZArray.bless(orders)
