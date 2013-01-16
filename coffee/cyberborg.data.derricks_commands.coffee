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
# name:      name of droid built (model name, need not be unique)
# body:
# propulsion:
# turret:
# { name: min: max: order: employ: at: ... }
CyberBorg::derricks_commands = (derricks) ->
  extractor = "A0ResourceExtractor"
  truck = /Truck/
  truck_build = (derrick) ->
    power: 0
    cost: 0
    like: truck
    limit: 3
    min: 1
    max: 1
    help: 1
    order: DORDER_MAINTAIN
    structure: extractor
    at: x:derrick.x, y:derrick.y

  commands = WZArray.bless( derricks.map((derrick)->truck_build(derrick)) )
  Scouter.bless(commands)
  # Eight derricks starting from derrick #0
  commands.mod = 8
  commands.offset = 0
  return commands
