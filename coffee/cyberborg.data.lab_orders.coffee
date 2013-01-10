#   ***Order Attributes***
#   function:  the function name to call
#   number:    order number
#   min:       minimum number of units required to execute order.
#   max:       maximum allowed number of units to execute order.
#   employ:    (unit_name)-> amount of the unit the group will to employ.
#   at:        preferred location.
#   structure:
#   body:
#   propulsion:
#   turret:
#   research:
# { name: min: max: number: employ: at: ... }
CyberBorg::lab_orders = ->
  # General orders are...
  pursue = (research) ->
    obj = research: research
    obj.function = "pursueResearch"
    obj.like = /Research Facility/
    obj.power = 250
    obj.cost = 100
    obj.limit = 1
    obj.min = 1
    obj.max = 1
    obj.recruit = 1
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
    pursue 'R-Struc-VTOLFactory'	# Vtol Factory
    pursue 'pursue R-Vehicle-Prop-VTOL'	# Vtol
    pursue 'R-Wpn-Bomb01'		# Vtol Bomb
  ]
