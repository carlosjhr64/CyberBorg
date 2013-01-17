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
CyberBorg::maintainance_commands = ->
  # What we're building
  light_factory     = "A0LightFactory"
  command_center    = "A0CommandCentre"
  research_facility = "A0ResearchFacility"
  power_generator   = "A0PowerGenerator"

  build = (arr) ->
    command =
      order: DORDER_MAINTAIN
      cost: 100
      structure: arr[0]
      at: x: arr[1], y: arr[2]
      cid: null # set at the time command is given
    command
  builds = build # alias

  trucks = (obj) ->
    obj.like = /Truck/
    obj
  truck = trucks # alias

  one = (obj) ->
    obj.limit = 1 # maximum group size
    obj.min = 1
    obj.max = 1
    obj.help = 0
    obj

  on_budget  = (obj) ->
    obj.power = 100
    obj

  commands = [
    on_budget one truck builds [light_factory,    10, 235]
    on_budget one truck builds [research_facility, 7, 235]
    on_budget one truck builds [command_center,    7, 238]
    on_budget one truck builds [power_generator,   4, 235]
    on_budget one truck builds [power_generator,   4, 238]
    on_budget one truck builds [research_facility, 4, 241]
    on_budget one truck builds [power_generator,   7, 241]
    on_budget one truck builds [research_facility, 10, 241]
    on_budget one truck builds [power_generator,   13, 241]
    on_budget one truck builds [research_facility, 13, 244]
    on_budget one truck builds [power_generator,   10, 244]
    on_budget one truck builds [research_facility,  7, 244]
  ]

  # Convert the list to wzarray
  WZArray.bless(commands)
