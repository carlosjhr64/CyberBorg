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
CyberBorg::base_commands = ->
  # What we're building
  light_factory     = "A0LightFactory"
  command_center    = "A0CommandCentre"
  research_facility = "A0ResearchFacility"
  power_generator   = "A0PowerGenerator"

  # We need to reserve power to ensure the initial base build...
  savings = 500
  # Structures costs about 100
  costs = 100
  build = (arr) ->
    cost = costs
    if savings > costs
      cost = savings
      savings -= costs
    command =
      order: DORDER_MAINTAIN
      cost: cost
      structure: arr[0]
      at: x: arr[1], y: arr[2]
      cid: null # set at the time command is given
    command
  builds = build # alias

  trucks = (obj) ->
    obj.like = /Truck/
    obj
  truck = trucks # alias

  three = (obj) ->
    obj.limit = 3 # maximum group size
    obj.min = 1 # it will execute the command only with at least this amount
    obj.max = 3 # it will execute the command with no more than this amount
    obj.help = 0
    obj

  two = (obj) ->
    obj.limit = 2 # maximum group size
    obj.min = 1
    obj.max = 2
    obj.help = 0
    obj

  one = (obj) ->
    obj.limit = 1 # maximum group size
    obj.min = 1
    obj.max = 1
    obj.help = 0
    obj

  with_help = (obj) ->
    obj.help = 3
    obj

  immediately = (obj) ->
    obj.power = 0
    obj

  on_budget  = (obj) ->
    obj.power = costs
    # basically we enlist more help after the project starts
    obj

  # This is a trick...
  # Wait until there more than enough power, but
  # don't relay down the power cost.
  # If we have more than enough, it wont matter anyways
  # that cost is set to zero.
  on_glut = (obj) ->
    obj.power = 400
    obj.cost = 0
    obj

  commands = [
    # Build up the initial base as fast a posible
    with_help immediately three trucks build [light_factory,    10, 235]
    with_help immediately three trucks build [research_facility, 7, 235]
    with_help immediately three trucks build [command_center,    7, 238]
    # Transitioning...
    immediately two truck builds [power_generator,   4, 235]
    on_budget one truck builds [power_generator,   4, 238]
    on_glut one truck builds [research_facility, 4, 241]
    on_budget one truck builds [power_generator,   7, 241]
    on_glut one truck builds [research_facility, 10, 241]
    on_budget one truck builds [power_generator,   13, 241]
    on_glut one truck builds [research_facility, 13, 244]
    on_budget one truck builds [power_generator,   10, 244]
    on_glut one truck builds [research_facility,  7, 244]
  ]

  # Convert the list to wzarray
  WZArray.bless(commands)
