CyberBorg::base_orders = ->
  light_factory = "A0LightFactory"
  command_center = "A0CommandCentre"
  research_facility = "A0ResearchFacility"
  power_generator = "A0PowerGenerator"

  p = (n,x) -> min: n, max:x
  p33 = -> p(3,3)
  p11 = -> p(1,1)

  order = (params) ->
    # str, x, y, p = *params
    p = params[3]
    p.structure = params[0]
    p.at = x: params[1], y: params[2]
    p

  # Phase 1, p33(),  Build up the initial base as fast a posible
  phase1 = [
    [light_factory, 9, 234]
    [research_facility, 6, 234]
    [command_center, 6, 237]
    [power_generator, 3, 234]
  ]
  data.push(p33()) for data in phase1
    
  # Phase 2, p11(),  just have one truck max out the base with research and power.
  phase2 = [
    [research_facility, 3, 237]
    [power_generator, 3, 240]
    [research_facility, 6, 240]
    [power_generator, 9, 240]
    [research_facility, 12, 240]
    [power_generator, 12, 243]
    [research_facility, 9, 243]
    [power_generator, 6, 243]
  ]
  data.push(p11()) for data in phase2

  orders = phase1.concat(phase2)
  orders.map (data) -> order(data)

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
  orders
