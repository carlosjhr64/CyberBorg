# ***Order Attributes***
# order:     order number
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
# { name: min: max: order: employ: at: ... }
CyberBorg::opportunity_commands = ->
  # What we're building
  light_factory     = "A0LightFactory"
  command_center    = "A0CommandCentre"
  research_facility = "A0ResearchFacility"
  power_generator   = "A0PowerGenerator"

  abort = () ->

  dorder_build = (arr) ->
    command =
      order: DORDER_MAINTAIN
      cost: 100
      structure: arr[0]
      at: x: arr[1], y: arr[2]
      cid: null # set at the time command is given
      abort: abort
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
    obj.power = 100
    obj.limit = 1 # maximum group size
    obj.min = 1
    obj.max = 1
    obj.help = 1 # project will accept help once started :-??
    obj

  commands = [
    with_three_truck dorder_build [power_generator,   4, 238]
  ]

  # Convert the list to wzarray
  WZArray.bless(commands)
