# ***Order Attributes***
# number:    order number
# like:      the unit name pattern
# power:     minimum power b/4 starting
# cost:      the power cost of the command
# limit:     the maximum group size
# min:       minimum number of units required to execute command.
# max:       maximum allowed number of units to execute command.
# help:      the number of helping units the job is willing to take.
# at:        preferred location (and direction).
# structure: structure to be built
# research:  technology to be researched
# body:
# propulsion:
# turret:
# cid:       the command id is set at the time the command is given.
# { name: min: max: number: employ: at: ... }
CyberBorg::base_commands = ->
  # What we're building
  light_factory     = "A0LightFactory"
  command_center    = "A0CommandCentre"
  research_facility = "A0ResearchFacility"
  power_generator   = "A0PowerGenerator"

  dorder_build = (arr) ->
    command =
      number: DORDER_BUILD
      cost: 100
      structure: arr[0]
      at: x: arr[1], y: arr[2]
      cid: null # set at the time command is given
    command

  with_three_trucks = (obj) ->
    # All these are required
    obj.like = /Truck/
    obj.power = 100
    obj.limit = 3 # maximum group size
    obj.min = 1 # it will execute the command only with at least this amount
    obj.max = 3 # it will execute the command with no more than this amount
    obj.help = 3 # project will accept help once started
    obj

  with_one_truck = (obj) ->
    obj.like = /Truck/
    obj.power = 390
    obj.limit = 1 # maximum group size
    obj.min = 1
    obj.max = 1
    obj.help = 1 # project will accept help once started :-??
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
  commands = phase1.concat(phase2)
  # Convert the list to wzarray
  WZArray.bless(commands)
