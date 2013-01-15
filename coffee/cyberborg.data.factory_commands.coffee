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
CyberBorg::factory_commands = ->
  # General commands are...
  build = (obj) ->
    obj.order = FORDER_MANUFACTURE
    obj.like = /Factory/
    obj.power = 417 
    obj.cost = 50
    obj.limit = 5
    obj.min = 1
    obj.max = 1
    obj.help = 1
    return obj

  # ...a wheeled viper...
  whb1 = (droid) ->
    droid.body = "Body1REC"; droid.propulsion = "wheeled01"
    return droid

  # ...truck
  truck = name: "Truck", turret: "Spade1Mk1", droid_type: DROID_CONSTRUCT

  # ...machine gunner
  turret = ["MG3Mk1", "MG2Mk1", "MG1Mk1"]
  mg1 = name: "MgWhB1", turret: turret, droid_type: DROID_WEAPON

  # The commands are...
  commands = []
  # ... 1 truck
  (1).times -> commands.push(build whb1(truck))
  # ... 12 machine gunners
  (12).times -> commands.push(build whb1(mg1))
  WZArray.bless(commands)
