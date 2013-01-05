#   ***Order Attributes***
#   function:  the function name to call
#   number:    order number for order functins, like orderDroid(... order.number ...).
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
  [
    'R-Wpn-MG1Mk1'		# Machine Gun Turret
    'R-Struc-PowerModuleMk1'	# Power Module
    'R-Defense-Tower01'
    'R-Wpn-MG3Mk1'		# Heavy Machine Gun
    'R-Struc-RepairFacility'	# Repair Facility
    'R-Defense-WallTower02'	# Ligh Cannon Hardpoint
    'R-Defense-AASite-QuadMg1'	# AA
    'R-Vehicle-Body04'		# Bug Body
    'R-Struc-VTOLFactory'	# Vtol Factory
    'R-Vehicle-Prop-VTOL'	# Vtol
    'R-Wpn-Bomb01'		# Vtol Bomb
  ].map( (name)-> name:name, research:name )
