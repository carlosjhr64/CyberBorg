# ***Order Attributes***
# order:     order number
# like:      the unit name pattern
# power:     minimum power b/4 starting
# cost:      the power cost of the command
# limit:     the maximum group size
# min:       minimum number of units required to execute command.
# max:       maximum allowed number of units to execute command.
# help:      the number of helping unit the job is willing to take.
# at:        preferred location.
# structure: structure to be built
# research:  technology to be researched
# body:
# propulsion:
# turret:
# { name: min: max: order: employ: at: ... }
###
Command::factory_commands = () ->
  # The commands are...
  commands = []
  # ... 1 truck
  (1).times -> commands.push(@on_budget @manufacture @wheeled @viper @trucker())
  # ... 12 machine gunners
  (12).times -> commands.push(@on_budget @manufacture @wheeled @viper @gunner())
  # ... and one more truck.
  (1).times -> commands.push(@on_budget @manufacture @wheeled @viper @trucker())
  WZArray.bless(commands)
###
