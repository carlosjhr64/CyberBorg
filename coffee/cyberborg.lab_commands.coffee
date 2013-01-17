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
  pursue = (research, cost) ->
    obj = research: research
    obj.order = LORDER_RESEARCH
    obj.like = /Research Facility/
    obj.power = cost
    obj.cost = cost
    obj.limit = 5
    obj.min = 1
    obj.max = 1
    obj.help = 1
    return obj

  [
    pursue('R-Wpn-MG1Mk1', 1)			# Machine Gun
    pursue('R-Wpn-MG2Mk1', 37)			# Dual Machine Gun
    pursue('R-Struc-PowerModuleMk1', 37)	# Power Module
    pursue('R-Wpn-MG3Mk1', 75)			# Heavy Machine Gun
    pursue('R-Struc-RepairFacility', 75)	# Repair Facility
    pursue('R-Defense-Tower01', 18)		# MG Tower
    pursue('R-Defense-WallTower02', 75)		# Ligh Cannon Hardpoint
    pursue('R-Defense-AASite-QuadMg1', 112)	# AA
    pursue('R-Vehicle-Body04', 75)		# Bug Body
    pursue('R-Vehicle-Prop-VTOL', 100)		# Vtol
    pursue('R-Struc-VTOLFactory', 100)		# Vtol Factory
    pursue('R-Wpn-Bomb01', 100)			# Vtol Bomb
  ]
