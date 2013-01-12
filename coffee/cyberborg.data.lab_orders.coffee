# ***Order Attributes***
# function:  the function name to call (order number often determines this)
# number:    order number
# like:      the unit name pattern
# power:     minimum power b/4 starting
# cost:      the power cost of the order
# limit:     the maximum group size
# min:       minimum number of units required to execute order.
# max:       maximum allowed number of units to execute order.
# help:      the number of helping unit the job is willing to take.
# at:        preferred location.
# structure: structure to be built
# research:  technology to be researched
# body:
# propulsion:
# turret:
# { name: min: max: number: employ: at: ... }
CyberBorg::lab_orders = ->
  # General orders are...
  pursue = (research) ->
    obj = research: research
    obj.function = "pursueResearch"
    obj.like = /Research Facility/
    obj.power = 390
    obj.cost = 100
    obj.limit = 5
    obj.min = 1
    obj.max = 1
    obj.help = 1
    return obj

  [
    pursue 'R-Wpn-MG1Mk1'		# Machine Gun Turret
    pursue 'R-Struc-PowerModuleMk1'	# Power Module
    pursue 'R-Defense-Tower01'
    pursue 'R-Wpn-MG3Mk1'		# Heavy Machine Gun
    pursue 'R-Struc-RepairFacility'	# Repair Facility
    pursue 'R-Defense-WallTower02'	# Ligh Cannon Hardpoint
    pursue 'R-Defense-AASite-QuadMg1'	# AA
    pursue 'R-Vehicle-Body04'		# Bug Body
    pursue 'R-Vehicle-Prop-VTOL'	# Vtol
    pursue 'R-Struc-VTOLFactory'	# Vtol Factory
    pursue 'R-Wpn-Bomb01'		# Vtol Bomb
  ]
