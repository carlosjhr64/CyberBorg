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
CyberBorg::scouts_commands = (derricks) ->

  scout = (derrick) ->
    power: 0
    cost: 0
    like: /MgWh/
    limit: 12
    min: 1
    max: 1
    help: 1
    order: DORDER_SCOUT
    at: x:derrick.x, y:derrick.y

  commands = WZArray.bless( derricks.map((derrick)->scout(derrick)) )
  Scouter.bless(commands)
  # Five derricks starting at derrick #3
  commands.mod = 5
  commands.offset = 3
  return commands
