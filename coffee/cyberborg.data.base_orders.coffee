CyberBorg::base_orders = ->
  # What we're building
  light_factory = "A0LightFactory"
  command_center = "A0CommandCentre"
  research_facility = "A0ResearchFacility"
  power_generator = "A0PowerGenerator"

  # With how many trucks
  p = (n,x,e) ->
    min: n
    max: x
    employ: (name) ->
      # making this a function gives us more flexibility
      ('Truck': e)[name]

  p333 = -> p(3,3,3)
  p111 = -> p(1,1,1)

  # Returning an object
  order = (str, x, y, p) ->
    # str, x, y, p = data...
    p.structure = str
    p.at = x: x, y: y
    p

  # Phase 1, p333,  Build up the initial base as fast a posible
  phase1 = [
    [light_factory, 10, 235]
    [research_facility, 7, 235]
    [command_center, 7, 238]
    [power_generator, 4, 235]
  ]
  data.push(p333()) for data in phase1
    
  # Phase 2, p111,  just have one truck max out the base with research and power.
  phase2 = [
    [research_facility,  4, 238]
    [power_generator,    4, 241]
    [research_facility,  7, 241]
    [power_generator,   10, 241]
    [research_facility, 13, 241]
    [power_generator,   13, 244]
    [research_facility, 10, 244]
    [power_generator,    7, 244]
  ]
  data.push(p111()) for data in phase2

  # Join the phases
  orders = phase1.concat(phase2)
  # Convert array data to an object
  orders = orders.map (data) -> order(data...)
  # Convert the list to wzarray
  WZArray.bless(orders)
