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
    employ:
      'Truck': e

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
    [light_factory, 9, 234]
    [research_facility, 6, 234]
    [command_center, 6, 237]
    [power_generator, 3, 234]
  ]
  data.push(p333()) for data in phase1
    
  # Phase 2, p111,  just have one truck max out the base with research and power.
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
  data.push(p111()) for data in phase2

  # Join the phases
  orders = phase1.concat(phase2)
  # Convert array data to an object
  orders = orders.map (data) -> order(data...)
  # Convert the list to wzarray
  WZArray.bless(orders)
