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
CyberBorg::lab_commands = ->
  # General commands are...
  pursue = (research) ->
    obj = research: research
    obj.order = LORDER_RESEARCH
    obj.like = /Research Facility/
    obj.power = 388
    obj.cost = 100
    obj.limit = 5
    obj.min = 1
    obj.max = 1
    obj.help = 1
    return obj

  [
    pursue 'R-Wpn-MG2Mk1'		# Heavy Machine Gun
    pursue 'R-Struc-PowerModuleMk1'	# Power Module
    pursue 'R-Wpn-MG3Mk1'		# Heavy Machine Gun
    pursue 'R-Struc-RepairFacility'	# Repair Facility
    pursue 'R-Defense-Tower01'
    pursue 'R-Defense-WallTower02'	# Ligh Cannon Hardpoint
    pursue 'R-Defense-AASite-QuadMg1'	# AA
    pursue 'R-Vehicle-Body04'		# Bug Body
    pursue 'R-Vehicle-Prop-VTOL'	# Vtol
    pursue 'R-Struc-VTOLFactory'	# Vtol Factory
    pursue 'R-Wpn-Bomb01'		# Vtol Bomb
  ]
