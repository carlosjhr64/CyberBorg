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

# CyberBorg::base_commands = (reserve, resources) ->

class Command
  # @cost is the default cost of structures
  # @savings is... TODO
  constructor: (@savings=500, @cost=100) ->
    reserve = cyberBorg.reserve
    resources = cyberBorg.resources
    # Center point of our trucks.
    # ie. (10.5,236)
    @tc = reserve.trucks().center().to_at()
    trace "Trucks around #{@tc.x}, #{@tc.y}" if cyberBorg.trace
    # Center point of our first 4 resources.
    # ie. (12, 236.5)
    @rc = WZArray.bless(resources[0..3]).center().to_at()
    trace "Resources around #{@rc.x}, #{@rc.y}." if cyberBorg.trace
    # Which x direction towards resources
    @dx = 1
    @dx = -1 if @tc.x > @rc.x
    # Which y direction towards resources
    @dy = 1
    @dy = -1 if @tc.y > @rc.y
    # Spacing between maintain points
    @s = 4
    # Which way is the greater offset?
    @horizontal = false
    if (@rc.x-@tc.x)*@dx > (@rc.y-@tc.y)*@dy
      @horizontal = true
    # So let's see how many locations this will work,
    # and find ways to improve the heuristics.
    # We'll assume maintain is relative to trucks.
    @x = @tc.x
    @y = @tc.y

  #################
  ### Buildings ###
  #################

  light_factory: (obj={}) ->
    obj.structure = "A0LightFactory"
    obj

  command_center: (obj={}) ->
    obj.structure = "A0CommandCentre"
    obj

  research_facility: (obj={}) ->
    obj.structure = "A0ResearchFacility"
    obj

  power_generator: (obj={}) ->
    obj.structure = "A0PowerGenerator"
    obj

  structure: (name, obj={}) ->
    obj.structure = name
    obj

  ##################
  ### propulsion ###
  ##################

  wheeled: (obj={}) ->
    obj.propulsion = "wheeled01"
    obj

  ############
  ### body ###
  ############

  viper: (obj={}) ->
    obj.body = "Body1REC"
    obj

  ##############
  ### turret ###
  ##############

  trucker: (obj={}) ->
    obj.name = "Truck"
    obj.turret = "Spade1Mk1"
    obj.droid_type = DROID_CONSTRUCT
    obj

  gunner: (obj={}) ->
    obj.name = "Gunner"
    obj.turret = ["MG3Mk1", "MG2Mk1", "MG1Mk1"]
    obj.droid_type = DROID_WEAPON
    obj

  ############
  ### Who? ###
  ############

  none: (obj={}) ->
    obj.like = /none/
    obj.limit = 0
    obj.min = 0
    obj.max = 0
    obj.help = 0
    obj

  truck: (obj={}) ->
    obj.like = /Truck/
    obj

  factory: (obj={}) ->
    obj.like = /Factory/
    obj

  ##############
  ### Where? ###
  ##############

  at: (x, y, obj={}) ->
    obj.at = {x:x, y:y}
    obj

  ##############
  ### Orders ###
  ##############

  manufacture: (obj={}) ->
    obj.order = FORDER_MANUFACTURE
    obj.like = /Factory/
    obj.cost = 62
    obj

  maintain: (obj={}) ->
    cost = @cost
    if @savings > @cost
      cost = @savings
      @savings -= @cost
    obj.order = DORDER_MAINTAIN
    obj.cost = cost
    obj

  pass: (obj={}) ->
    obj.cost = 0
    obj.order = CORDER_PASS
    # 1 just means success in this case. Normally,
    # it would be the number of units that succesfully executed the command.
    obj.execute = (units) -> 1
    obj.cid = null
    obj

  #################
  ### How many? ###
  #################

  three: (obj={}) ->
    obj.limit = 3 # maximum group size
    obj.min = 1 # it will execute the command only with at least this amount
    obj.max = 3 # it will execute the command with no more than this amount
    obj.help = 0
    obj

  two: (obj={}) ->
    obj.limit = 2 # maximum group size
    obj.min = 1
    obj.max = 2
    obj.help = 0
    obj

  one: (obj={}) ->
    obj.limit = 1 # maximum group size
    obj.min = 1
    obj.max = 1
    obj.help = 0
    obj

  with_help: (obj={}) ->
    obj.help = 3
    obj

  ##########################
  ### Power requirements ###
  ##########################

  immediately: (obj={}) ->
    obj.power = 0
    obj

  on_income: (obj={}) ->
    cost = obj.cost or @cost
    obj.power = cost/2
    obj

  on_budget: (obj={}) ->
    cost = obj.cost or @cost
    obj.power = cost
    obj

  on_surplus: (obj={}) ->
    cost = obj.cost or @cost
    obj.power = 2*cost
    obj

  on_glut: (obj={}) ->
    cost = obj.cost or @cost
    obj.power = 4*cost
    obj

  base_commands: () ->
    block = [
      # Build up the initial base as fast a posible
      @with_help @immediately @three @trucks @maintain @light_factory @at @x-@s*@dx, @y-@s*@dy
      @with_help @immediately @three @trucks @maintain @research_facility @at @x, @y-@s*@dy
      @with_help @immediately @three @trucks @maintain @command_center @at @x+@s*@dx, @y-@s*@dy

      # Transitioning.
      @immediately @three @trucks @maintain @power_generator @at @x+@s*@dx, @y
      @on_surplus @one @truck @maintains @power_generator @at @x, @y

      # Wait for power levels to come back up.
      @pass @on_glut @none()
      @on_budget @one @truck @maintains @research_facility @at @x-@s*@dx, @y
      @on_budget @one @truck @maintains @power_generator @at @x-@s*@dx, @y+@s*@dy

      # Wait for power levels to come back up.
      @pass @on_glut @none()
      @on_budget @one @truck @maintains @research_facility @at @x, @y+@s*@dy
      @on_budget @one @truck @maintains @power_generator @at @x+@s*@dx, @y+@s*@dy
    ]

    more = null
    if @horizontal
      more = [
        @pass @on_glut @none()
        @on_budget @one @truck @maintains @research_facility @at @x+2*@s*@dx, @y+@s*@dy
        @on_budget @one @truck @maintains @power_generator @at @x+2*@s*@dx, @y
        @pass @on_glut @none()
        @on_budget @one @truck @maintains @research_facility @at @x+2*s*@dx, @y-@s*@dy
      ]
    else
      more = [
        @pass @on_glut @none()
        @on_budget @one @truck @maintains @research_facility @at @x+@s*@dx, @y+2*@s*@dy
        @on_budget @one @truck @maintains @power_generator @at @x, @y+2*@s*@dy
        @pass @on_glut @none()
        @on_budget @one @truck @maintains @research_facility @at @x-@s*@dx, @y+2*@s*@dy
      ]

    commands = block.concat(more)
    # Convert the list to wzarray
    WZArray.bless(commands)

  factory_commands: () ->
    # The commands are...
    truck = @on_budget @manufacture @wheeled @viper @trucker()
    gunner = @on_budget @manufacture @wheeled @viper @gunner()
    commands = []
    # ... 1 truck
    commands.push(truck)
    # ... 12 machine gunners
    12.times -> commands.push(gunner)
    commands.push(truck)
    WZArray.bless(commands)

###############
### Aliases ###
###############
Command::maintains = Command::maintain
Command::manufactures = Command::manufacture
Command::trucks = Command::truck
