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
CyberBorg::base_commands = (reserve, resources) ->
  # What we're building
  light_factory     = "A0LightFactory"
  command_center    = "A0CommandCentre"
  research_facility = "A0ResearchFacility"
  power_generator   = "A0PowerGenerator"

  none = () ->
    obj =
      like: /none/
      limit: 0
      min: 0
      max: 0
      help: 0
    obj

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

  pass = (obj) ->
    obj.cost = 0
    obj.order = CORDER_PASS
    # 1 just means success in this case. Normally,
    # it would be the number of units that succesfully executed the command.
    obj.execute = (units) -> 1
    obj.cid = null
    obj

  on_budget  = (obj) ->
    obj.power = 100
    obj

  on_surplus = (obj) ->
    obj.power = 125
    obj

  on_glut = (obj) ->
    obj.power = 400
    obj

  # Center point of our trucks.
  # ie. (10.5,236)
  tcenter = reserve.trucks().center()
  trace "Trucks around #{tcenter.x}, #{tcenter.y}"

  # Center point of our first 4 resources.
  # ie. (12, 236.5)
  rcenter = WZArray.bless(resources[0..3]).center()
  trace "Resources around #{rcenter.x}, #{rcenter.y}."

  rtx = (rcenter.x + tcenter.x) / 2.0
  rty = (rcenter.y + tcenter.y) / 2.0
  trace "Cluster center is #{rtx}, #{rty}."

  # Positions relative to x,y
  x = (rtx - 7.25).to_i()
  y = (rty - 1.25).to_i()
  blue_alert "Relative build x,y are #{x}, #{y}."
  # So let's see how many locations this will work,
  # and find ways to improve the heuristics.

  commands = [
    # Build up the initial base as fast a posible
    with_help immediately three trucks build [light_factory,    x+6, y]
    with_help immediately three trucks build [research_facility, x+3, y]
    with_help immediately three trucks build [command_center,    x+3, y+3]
    # Transitioning, two trucks.
    immediately two truck builds [power_generator,   x, y]
    # Transitioning, one truck.
    on_surplus one truck builds [power_generator,   x, y+3]
    # Wait for power levels to come back up.
    pass on_glut none()
    on_budget one truck builds [research_facility, x, y+6]
    on_budget one truck builds [power_generator,   x+3, y+6]
    pass on_glut none()
    on_budget one truck builds [research_facility, x+6, y+6]
    on_budget one truck builds [power_generator,   x+9, y+6]
    pass on_glut none()
    on_budget one truck builds [research_facility, x+9, y+9]
    on_budget one truck builds [power_generator,   x+6, y+9]
    pass on_glut none()
    on_budget one truck builds [research_facility,  x+3, y+9]
  ]

  # Convert the list to wzarray
  WZArray.bless(commands)
