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

  order = (p, str, x, y) ->
    p.structure =  str
    p.at = x: x, y: y
    p

  [
    # Phase 1  Build up the initial base as fast a posible
    order(p33(), lf, 9, 234)
  ,
    order(p33(), rf, 6, 234)
  ,
    order(p33(), cc, 6, 237)
  ,
    order(p33(), pg, 3, 234)
  ,
    
    # Phase 2  Just have one truck max out the base with research and power
    order(p11(), rf, 3, 237)
  ,
    order(p11(), pg, 3, 240)
  ,
    order(p11(), rf, 6, 240)
  ,
    order(p11(), pg, 9, 240)
  ,
    order(p11(), rf, 12, 240)
  ,
    order(p11(), pg, 12, 243)
  ,
    order(p11(), rf, 9, 243)
  ,
    order(p11(), pg, 6, 243)
  ]

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
