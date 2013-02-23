# Want to try to expose to the strategist
# as little of the AI's code as possible.
# Here begins "volatile" coding.
#
# Really want to keep the number of globals down, but
# these are a convenience...
# Define the group names
BASE      = 'Base'	# will build the base
FACTORIES = 'Factories'	# builds droids
LABS      = 'Labs'	# research facilities
DERRICKS  = 'Derricks'	# will build derricks
SCOUTS    = 'Scouts'	# will scout and guard the area

# Which groups are allowed to execute commands without HQ?
Ai::base_group = (name) ->
  for base in [BASE, FACTORIES, LABS]
    return true if name is base
  false

# What types of commands are allowed without HQ?
Ai::allowed_hqless = (command) ->
  switch command.order
    when FORDER_MANUFACTURE
      # Only trucks allowed to be built without HQ.
      # Note that this is stricter than for human players.
      # Human players just can't design new units.
      return true if command.droid_type is DROID_CONSTRUCT
    when LORDER_RESEARCH
      # As per the guide...
      # No research of defensive structures allowed without HQ.
      return true unless /Defense/.test(command.research)
    else
      # Any command allowed except manufacture or research.
      return true
  return false

# Unacceptable losses threshold for an area.
Ai::too_dangerous_level = () ->
  threshold = @power_type_factor * powerType
  m1 = 1.0 * GROUPS.count((object) -> object.stattype is RESOURCE_EXTRACTOR)
  m2 = 4.0 * GROUPS.count((object) -> object.stattype is POWER_GEN)
  m = m1
  m = m2 if m1 > m2
  m = 0.5 if m < 1.0
  threshold = Math.sqrt(m)*threshold
  return threshold

Ai::script = () ->
  # We'll create many groups besides the reserve, and
  # we'll keep them in cyberBorg.groups.
  # For this AI, we won't command individual droids directly.
  # All commands will be given to groups, which
  # will then be relayed down to an individual droid.
  # Group is a class provided by CyberBorg.
  # Rank is used to determine which group gets to pick units first.
  # Rank number will allow us to sort the groups by priority.
  # Groups with higher priority get first dibs on any action.
  # Groups can release droids they no longer need
  # into the reserve, and draw droids they need from the reserve.
  # The Base group will be responsible for building the base.
  # The group starts out empty, with [].
  # Also, from a datafile, we give the Base group its commands list.
  # The datafile defines the function that returns the group's commands.
  # For example, cyberBorg.base_commands in the case of BASE group.
  # Finally, the base needs the reserve list.
  commands = new Command()
  # just add groups in order rather than rely on rank.
  GROUPS.add_group(BASE, commands.base_commands())

  # Structures are also considered units the AI can command.
  # Let's have a factory group... etc.
  # So do use reserve for structure units, just as we do for droids...
  GROUPS.add_group(FACTORIES, commands.factory_commands())
  GROUPS.add_group(LABS, commands.lab_commands())

  # More groups...
  GROUPS.add_group(DERRICKS, commands.derricks_commands())
  GROUPS.add_group(SCOUTS, commands.scouts_commands())

Command::trucker = (obj={}) ->
  obj.like = /Truck$/
  obj

Command::scouter = (obj={}) ->
  obj.like = /^Fastgun$/
  obj

Command::fastgun = (obj={}) ->
  obj.name = "Fastgun"
  obj.turret = ["MG2Mk1", "MG1Mk1"]
  obj.body = ["Body4ABT", "Body1REC"]
  obj.propulsion = ["hover01", "wheeled01"]
  obj.cost = Command.min_cost_of(obj)
  obj.droid_type = DROID_WEAPON
  obj

Command::fasttruck = (obj={}) ->
  obj.name = "Truck"
  obj.turret = 'Spade1Mk1'
  obj.body = ["Body4ABT", "Body1REC"]
  obj.propulsion = ["hover01", "wheeled01"]
  obj.cost = Command.min_cost_of(obj)
  obj.droid_type = DROID_CONSTRUCT
  obj

# Our first concern is our base.
# We'll build it up and here forth react to events in the game.
# With only two trucks (usually) to start and base group with first dibs,
# the AI guarantees that the first thing that happens
# is that the base gets built.
Command::with_three_trucks = (obj) ->
  @with_help @on_budget @three @trucker @maintain obj
Command::with_two_trucks = (obj) ->
  @with_help @on_budget @two @trucker @maintain obj
Command::with_one_truck = (obj) ->
  @on_budget @one @trucker @maintains obj
Command::base_commands = () ->
  @limit = 3 # Group size limit
  # savings is a way to signal that we want to ensure
  # completion of a set of projects without other projects
  # taking up the required resources.
  generator_cost = @power_generator().cost
  energy_cost = generator_cost + 4*@oil_derrick().cost
  factory_cost = @light_factory().cost
  research_cost = @research_facility().cost
  hq_cost = @command_center().cost
  savings = energy_cost + factory_cost + research_cost + hq_cost +
  generator_cost
  # First to ensure is income...
  energy_build = [
    @with_two_trucks @power_generator @at @x+@s*@dx, @y
    @with_two_trucks @oil_derrick @at @resources[0].x, @resources[0].y
    @with_two_trucks @oil_derrick @at @resources[1].x, @resources[1].y
    @with_two_trucks @oil_derrick @at @resources[2].x, @resources[2].y
    @with_two_trucks @oil_derrick @at @resources[3].x, @resources[3].y
  ]
  # Next is factory to build trucks
  factory_build = [
    @with_three_trucks @light_factory @at @x-@s*@dx, @y-@s*@dy
  ]
  # Then research
  research_build = [
    @with_three_trucks @research_facility @at @x, @y-@s*@dy
  ]
  # Then HQ
  hq_build = [
    @with_three_trucks @command_center @at @x+@s*@dx, @y-@s*@dy
  ]
  # And finally one more generator
  generator_build = [
    @with_one_truck @power_generator @at @x, @y
  ]
  # The optimal build sequence depends on how much power we have to start
  commands = null
  if @power <= energy_cost + factory_cost
    commands =
    energy_build.concat(factory_build).concat(research_build).concat(hq_build)
  else if @power <= energy_cost + factory_cost + research_cost
    commands =
    factory_build.concat(energy_build).concat(research_build).concat(hq_build)
  else if @power <= energy_cost + factory_cost + research_cost + hq_cost
    commands =
    factory_build.concat(research_build).concat(energy_build).concat(hq_build)
  else
    commands =
    factory_build.concat(research_build).concat(hq_build).concat(energy_build)
  # Next, the extra generator
  commands = commands.concat(generator_build)
  # OK, we need to reset savings now that we have the build order
  for command in commands
    savings -= command.cost
    command.savings = savings
  # There's an unusual race condition bug that may occur
  # while building derricks.  Need to find the maximum value of
  # savings under that condition.
  max_savings = 0
  for command in commands
    if command.structure is "A0ResourceExtractor"
      savings = command.savings
      max_savings = savings if savings > max_savings
  for command in commands
    if command.structure is "A0ResourceExtractor"
      command.savings = max_savings
  penultima = commands.penultima()
  last = commands.last()
  last.savings = penultima.savings - last.cost
  last.promote = 2
  # Convert the list to wzarray
  WZArray.bless(commands)

## This to be moved to extend_base_commands
# @savings = 0
# @limit = 1
# more = [
#   # Wait for power levels to come back up.
#   @pass @on_plenty @one @trucker()
#   @with_one_truck @research_facility @at @x-@s*@dx, @y
#   @with_one_truck @power_generator @at @x-@s*@dx, @y+@s*@dy
#   # Wait for power levels to come back up.
#   @pass @on_plenty @none()
#   @with_one_truck @research_facility @at @x, @y+@s*@dy
#   @with_one_truck @power_generator @at @x+@s*@dx, @y+@s*@dy
# ]
# commands = commands.concat(more)

# if @horizontal
#   more = [
#     @pass @on_plenty @none()
#     @with_one_truck @research_facility @at @x+2*@s*@dx, @y+@s*@dy
#     @with_one_truck @power_generator @at @x+2*@s*@dx, @y
#     @pass @on_plenty @none()
#     @with_one_truck @research_facility @at @x+2*@s*@dx, @y-@s*@dy
#   ]
# else
#   more = [
#     @pass @on_plenty @none()
#     @with_one_truck @research_facility @at @x+@s*@dx, @y+2*@s*@dy
#     @with_one_truck @power_generator @at @x, @y+2*@s*@dy
#     @pass @on_plenty @none()
#     @with_one_truck @research_facility @at @x-@s*@dx, @y+2*@s*@dy
#   ]
# commands = commands.concat(more)

Command::factory_commands = () ->
  @limit = 1 # Group size limit
  @savings = 0
  # The commands are...
  truck = @on_budget @manufacture @fasttruck()
  fastgun = @on_budget @manufacture @fastgun()
  commands = []
  # ... 1 truck
  commands.push(truck)
  # ... 12 machine gunners
  4.times -> commands.push(fastgun)
  # We'll then build one more truck...
  commands.push(truck.dup()) # ... as a sigl'y modifiable object...
  # and tell the ai to promote this group by 1.
  commands.last().promote = 1
  # Build 8 more fastguns for a total of 12.
  8.times -> commands.push(fastgun)
  WZArray.bless(commands)

Command::now_with_truck = (obj) ->
  @immediately @one @trucker @maintains obj
Command::derricks_commands = () ->
  @limit = 3 # Group size limit
  @savings = 0
  commands = WZArray.bless([])
  for derrick in @resources
    commands.push(@now_with_truck @oil_derrick @at derrick.x, derrick.y)
  # Twelve derricks from derrick #0, starting four times next.
  # The initial four derricks built by Base group.
  Scouter.bless(commands)
  commands.mod = 12
  commands.offset = 0
  4.times -> commands.next()
  commands

Command::scouts_commands = () ->
  @limit = 12 # Group size limit
  @savings = 0
  commands = WZArray.bless([])
  for derrick in @resources
    commands.push(
      @immediately @one @scouter @scouts @at derrick.x, derrick.y)
  # Twelve derricks from derrick #0, starting off 3 times next.
  # We start by defending the fourth derrick forward while
  # the initial 4 are being built.
  Scouter.bless(commands)
  commands.mod = 12
  commands.offset = 0
  3.times -> commands.next()
  commands

Command::lab_commands = () ->
  @limit = 5 # Group size limit
  @savings = 0
  commands = [
    @pursue('R-Wpn-MG1Mk1')		# Machine Gun
    @pursue('R-Wpn-MG2Mk1')		# Dual Machine Gun
    @pursue('R-Vehicle-Prop-Hover')	# Hovercraft
    @pursue('R-Vehicle-Body04')		# Bug Body
    @pursue('R-Struc-PowerModuleMk1')	# Power Module
    @pursue('R-Wpn-MG3Mk1')		# Heavy Machine Gun
    @pursue('R-Struc-RepairFacility')	# Repair Facility
    @pursue('R-Defense-Tower01')	# MG Tower
    @pursue('R-Defense-WallTower02')	# Ligh Cannon Hardpoint
    @pursue('R-Defense-AASite-QuadMg1')	# AA
    @pursue('R-Vehicle-Prop-VTOL')	# Vtol
    @pursue('R-Struc-VTOLFactory')	# Vtol Factory
    @pursue('R-Wpn-Bomb01')		# Vtol Bomb
  ]
  WZArray.bless(commands)
