Number::times = (action) ->
  i = 0
  while i < this.valueOf()
    action()
    i++

CyberBorg::base_orders = ->
  [
    
    # Phase 1  Build up the initial base as fast a posible
    min: 3
    max: 3
    structure: "A0LightFactory"
    at:
      x: 9
      y: 234
  ,
    min: 3
    max: 3
    structure: "A0ResearchFacility"
    at:
      x: 6
      y: 234
  ,
    min: 3
    max: 3
    structure: "A0CommandCentre"
    at:
      x: 6
      y: 237
  ,
    min: 3
    max: 3
    structure: "A0PowerGenerator"
    at:
      x: 3
      y: 234
  ,
    
    # Phase 2  Just have one truck max out the base with research and power
    min: 1
    max: 1
    structure: "A0ResearchFacility"
    at:
      x: 3
      y: 237
  ,
    min: 1
    max: 1
    structure: "A0PowerGenerator"
    at:
      x: 3
      y: 240
  ,
    min: 1
    max: 1
    structure: "A0ResearchFacility"
    at:
      x: 6
      y: 240
  ,
    min: 1
    max: 1
    structure: "A0PowerGenerator"
    at:
      x: 9
      y: 240
  ,
    min: 1
    max: 1
    structure: "A0ResearchFacility"
    at:
      x: 12
      y: 240
  ,
    min: 1
    max: 1
    structure: "A0PowerGenerator"
    at:
      x: 12
      y: 243
  ,
    min: 1
    max: 1
    structure: "A0ResearchFacility"
    at:
      x: 9
      y: 243
  ,
    min: 1
    max: 1
    structure: "A0PowerGenerator"
    at:
      x: 6
      y: 243
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
