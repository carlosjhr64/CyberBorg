#   ***Order Attributes***
#   function:  the function name to call
#   number:    order number for order functins, like orderDroid(... order.number ...).
#   min:       minimum number of units required to execute order.
#   max:       maximum allowed number of units to execute order.
#   employ:    (unit_name)-> amount of the unit the group will to employ.
#   at:        preferred location.
#   power:     minimum power b/4 starting
#   cost:      the power cost of the order
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
      cost: 100
      structure: arr[0]
      at: x: arr[1], y: arr[2]
    order

  with_three_trucks = (obj) ->
    # All these are required
    obj.like = /Truck/
    obj.power = 100
    obj.limit = 3 # maximum group size
    obj.min = 1 # it will execute the order only with at least this amount
    obj.max = 3 # it will execute the order with no more than this amount
    obj.recruit = 3 # recruit from reserve if we have less than this amount
    obj.help = 3 # project will accept help once started
    ### TODO might not get used
    obj.conscript = 1 # steal from another group if necessary to execute this order
    # Employ is just a way to add to a group an idle truck b/4 it gets recruited by another group
    obj.employ = (name) ->
      # Group size sought through employment
      (Truck: 0)[name] # this is undefined unless name is 'Truck'
    ###
    obj

  with_one_truck = (obj) ->
    obj.like = /Truck/
    obj.power = 250
    obj.limit = 1 # maximum group size
    obj.min = 1
    obj.max = 1
    obj.recruit = 1
    obj.help = 1 # project will accept help once started :-??
    ### TODO might not get used
    obj.employ = (name) ->
      (Truck: 0)[name]
    ###
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
    with_one_truck dorder_build [power_generator,   4, 238]
    with_one_truck dorder_build [research_facility, 4, 241]
    with_one_truck dorder_build [power_generator,   7, 241]
    with_one_truck dorder_build [research_facility, 10, 241]
    with_one_truck dorder_build [power_generator,   13, 241]
    with_one_truck dorder_build [research_facility, 13, 244]
    with_one_truck dorder_build [power_generator,   10, 244]
    with_one_truck dorder_build [research_facility,  7, 244]
  ]

  # Join the phases
  orders = phase1.concat(phase2)
  # Convert the list to wzarray
  WZArray.bless(orders)
