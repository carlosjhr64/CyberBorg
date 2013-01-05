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
# { name: min: max: number: employ: at: ... }
CyberBorg::base_orders = ->
  # What we're building
  light_factory     = "A0LightFactory"
  command_center    = "A0CommandCentre"
  research_facility = "A0ResearchFacility"
  power_generator   = "A0PowerGenerator"

  dorder_build = (arr) ->
    order =
      function: 'orderDroidBuild'
      number: DORDER_BUILD
      structure: arr[0]
      at: x: arr[1], y: arr[2]
    order

  with_three_trucks = (obj) ->
    obj.like = /Truck/
    obj.min = 1 # it will execute the order only with at least this amount
    obj.max = 3 # it will execute the order with no more than this amount
    obj.recruit = 3 # it will try to execute with at least this amount but less than max
    obj.conscript = 1 # steal from another group if necessary to execute this order
    obj.cut = 3 # layoff units above this amout
    obj.employ = (name) ->
      # Group size sought through employment
      (Truck: 3)[name] # this is undefined unless name is 'Truck'
    obj

  with_one_truck = (obj) ->
    obj.min = 1
    obj.max = 1
    obj.recruit = 1
    obj.cut = 1
    obj.employ = (name) ->
      (Truck: 1)[name]
    obj

  # Build up the initial base as fast a posible
  phase1 = [
    with_three_trucks dorder_build [light_factory,    10, 235]
    with_three_trucks dorder_build [research_facility, 7, 235]
    with_three_trucks dorder_build [command_center,    7, 238]
    with_three_trucks dorder_build [power_generator,   4, 235]
  ]
    
  # Just have one truck max out the base with research and power.
  phase2 = [
    with_one_truck dorder_build [research_facility,  4, 238]
    with_one_truck dorder_build [power_generator,    4, 241]
    with_one_truck dorder_build [research_facility,  7, 241]
    with_one_truck dorder_build [power_generator,   10, 241]
    with_one_truck dorder_build [research_facility, 13, 241]
    with_one_truck dorder_build [power_generator,   13, 244]
    with_one_truck dorder_build [research_facility, 10, 244]
    with_one_truck dorder_build [power_generator,    7, 244]
  ]

  # Join the phases
  orders = phase1.concat(phase2)
  # Convert the list to wzarray
  WZArray.bless(orders)
