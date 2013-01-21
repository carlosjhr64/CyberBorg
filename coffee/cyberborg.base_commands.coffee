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

  none = (obj={}) ->
    obj.like = /none/
    obj.limit = 0
    obj.min = 0
    obj.max = 0
    obj.help = 0
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

  trucks = (obj={}) ->
    obj.like = /Truck/
    obj
  truck = trucks # alias

  three = (obj={}) ->
    obj.limit = 3 # maximum group size
    obj.min = 1 # it will execute the command only with at least this amount
    obj.max = 3 # it will execute the command with no more than this amount
    obj.help = 0
    obj

  two = (obj={}) ->
    obj.limit = 2 # maximum group size
    obj.min = 1
    obj.max = 2
    obj.help = 0
    obj

  one = (obj={}) ->
    obj.limit = 1 # maximum group size
    obj.min = 1
    obj.max = 1
    obj.help = 0
    obj

  with_help = (obj={}) ->
    obj.help = 3
    obj

  immediately = (obj={}) ->
    obj.power = 0
    obj

  pass = (obj={}) ->
    obj.cost = 0
    obj.order = CORDER_PASS
    # 1 just means success in this case. Normally,
    # it would be the number of units that succesfully executed the command.
    obj.execute = (units) -> 1
    obj.cid = null
    obj

  on_budget  = (obj={}) ->
    obj.power = 100
    obj

  on_surplus = (obj={}) ->
    obj.power = 125 # TODO recheck this
    obj

  on_glut = (obj={}) ->
    obj.power = 400
    obj

  # Center point of our trucks.
  # ie. (10.5,236)
  tc = reserve.trucks().center()
  trace "Trucks around #{tc.x}, #{tc.y}"
  x = tc.x.to_i()
  y = tc.y.to_i()

  # Center point of our first 4 resources.
  # ie. (12, 236.5)
  rc = WZArray.bless(resources[0..3]).center()
  trace "Resources around #{rc.x}, #{rc.y}."
  rx = rc.x.to_i()
  ry = rc.y.to_i()

  # Which x direction towards resources
  dx = 1
  dx = -1 if x > rx
  # Which y direction towards resources
  dy = 1
  dy = -1 if y > ry

  # So let's see how many locations this will work,
  # and find ways to improve the heuristics.

  s = 4 # Spacing
  block = [
    # Build up the initial base as fast a posible
    with_help immediately three trucks build [light_factory,     x-s*dx, y-s*dy]
    with_help immediately three trucks build [research_facility, x,      y-s*dy]
    with_help immediately three trucks build [command_center,    x+s*dx, y-s*dy]

    # Transitioning, two trucks.
    immediately two truck builds             [power_generator,   x+s*dx, y]
    # Transitioning, one truck.
    on_surplus one truck builds              [power_generator,   x,      y]
    # Wait for power levels to come back up.
    pass on_glut none()
    on_budget one truck builds               [research_facility, x-s*dx, y]

    on_budget one truck builds               [power_generator,   x-s*dx, y+s*dy]
    pass on_glut none()
    on_budget one truck builds               [research_facility, x,      y+s*dy]
    on_budget one truck builds               [power_generator,   x+s*dx, y+s*dy]
  ]

  more = null
  if (rx-x)*dx > (ry-y)*dy
    more = [
      pass on_glut none()
      on_budget one truck builds               [research_facility, x+2*s*dx, y+s*dy]
      on_budget one truck builds               [power_generator,   x+2*s*dx, y]
      pass on_glut none()
      on_budget one truck builds               [research_facility, x+2*s*dx, y-s*dy]
    ]
  else
    more = [
      pass on_glut none()
      on_budget one truck builds               [research_facility, x+s*dx, y+2*s*dy]
      on_budget one truck builds               [power_generator,   x,      y+2*s*dy]
      pass on_glut none()
      on_budget one truck builds               [research_facility, x-s*dx, y+2*s*dy]
    ]

  commands = block.concat(more)
  # Convert the list to wzarray
  WZArray.bless(commands)
