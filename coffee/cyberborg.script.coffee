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
  cyberBorg.add_group(FACTORIES, 20, cyberBorg.factory_commands())
  cyberBorg.add_group(LABS, 30, cyberBorg.lab_commands())
  # More groups...
  resources = cyberBorg.resources
  cyberBorg.add_group(DERRICKS, 40, cyberBorg.derricks_commands(resources))
  cyberBorg.add_group(SCOUTS, 50, cyberBorg.scouts_commands(resources))
  # Our first concern is our base.
  # We'll build it up and here forth react to events in the game.
  # With only two trucks (usually) to start and base group with first dibs,
  # the AI guarantees that the first thing that happens
  # is that the base gets built.
