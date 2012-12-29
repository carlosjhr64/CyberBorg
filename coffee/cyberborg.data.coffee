Number::times = (action) ->
  i = 0
  while i < this.valueOf()
    action()
    i++

CyberBorg::base_orders = ->
  lf = "A0LightFactory"; cc = "A0CommandCentre"
  rf = "A0ResearchFacility"; pg = "A0PowerGenerator"

  p = (n,x) -> min: n, max:x
  p33 = -> p(3,3)
  p11 = -> p(1,1)

  order = (params) ->
    # p, str, x, y = *params
    p = params[0]
    p.structure = params[1]
    p.at = x: params[2], y: params[3]
    p

  # Phase 1, p33(),  Build up the initial base as fast a posible
  phase1 = [ [lf, 9, 234], [rf, 6, 234], [cc, 6, 237], [pg, 3, 234] ]
  data.unshift(p33()) for data in phase1
    
  # Phase 2, p11(),  just have one truck max out the base with research and power.
  phase2 = [
    [rf, 3, 237], [pg, 3, 240], [rf, 6, 240], [pg, 9, 240]
    [rf, 12, 240], [pg, 12, 243], [rf, 9, 243], [pg, 6, 243]
  ]
  data.unshift(p11()) for data in phase2

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
