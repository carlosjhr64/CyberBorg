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
base_group = (name) ->
  for base in [BASE, FACTORIES, LABS]
    return true if name is base
  false

# What type of droids is the factory allowed to build without HQ?
allowed_hqless_build = (command) ->
  if command.droid_type is DROID_CONSTRUCT
    return true
  false

script = () ->
  resources = cyberBorg.resources
  reserve = cyberBorg.reserve
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
  cyberBorg.add_group(BASE, 10, commands.base_commands())

  # Structures are also considered units the AI can command.
  # Let's have a factory group... etc.
  # So do use reserve for structure units, just as we do for droids...
  cyberBorg.add_group(FACTORIES, 20, commands.factory_commands())
  cyberBorg.add_group(LABS, 30, commands.lab_commands())

  # More groups...
  cyberBorg.add_group(DERRICKS, 40, commands.derricks_commands(resources))
  cyberBorg.add_group(SCOUTS, 50, commands.scouts_commands(resources))

# Our first concern is our base.
# We'll build it up and here forth react to events in the game.
# With only two trucks (usually) to start and base group with first dibs,
# the AI guarantees that the first thing that happens
# is that the base gets built.
Command::base_commands = () ->
  @limit = 3 # Group size limit
  @savings = 400 # TODO explain
  @cost = 100 # default cost of command
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

Command::factory_commands = () ->
  @limit = 1 # Group size limit
  @savings = 0 # TODO explain
  @cost = 100 # default cost of command
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

Command::derricks_commands = (derricks) ->
  @limit = 3 # Group size limit
  @savings = 0 # TODO explain
  @cost = 100 # default cost of command
  commands = WZArray.bless([])
  for derrick in derricks
    commands.push(
      @immediately @one @truck @maintains @resource_extractor @at derrick.x, derrick.y)
  # Eight derricks starting from derrick #0
  Scouter.bless(commands)
  commands.mod = 8
  commands.offset = 0
  commands

Command::scouts_commands = (derricks) ->
  @limit = 12 # Group size limit
  @savings = 0 # TODO explain
  @cost = 0 # default cost of command
  commands = WZArray.bless([])
  for derrick in derricks
    commands.push(
      @immediately @one @gun @scouts @at derrick.x, derrick.y)
  # Five derricks starting at derrick #3
  Scouter.bless(commands)
  commands.mod = 5
  commands.offset = 3
  commands

Command::lab_commands = () ->
  @limit = 5 # Group size limit
  @savings = 0 # TODO explain
  @cost = 100 # default cost of command
  commands = [
    @pursue('R-Wpn-MG1Mk1', 1)			# Machine Gun
    @pursue('R-Wpn-MG2Mk1', 37)			# Dual Machine Gun
    @pursue('R-Struc-PowerModuleMk1', 37)	# Power Module
    @pursue('R-Wpn-MG3Mk1', 75)			# Heavy Machine Gun
    @pursue('R-Struc-RepairFacility', 75)	# Repair Facility
    @pursue('R-Defense-Tower01', 18)		# MG Tower
    @pursue('R-Defense-WallTower02', 75)	# Ligh Cannon Hardpoint
    @pursue('R-Defense-AASite-QuadMg1', 112)	# AA
    @pursue('R-Vehicle-Body04', 75)		# Bug Body
    @pursue('R-Vehicle-Prop-VTOL', 100)		# Vtol
    @pursue('R-Struc-VTOLFactory', 100)		# Vtol Factory
    @pursue('R-Wpn-Bomb01', 100)		# Vtol Bomb
  ]
  WZArray.bless(commands)
