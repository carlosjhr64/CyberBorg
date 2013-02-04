# CyberBorg will help package data and provide utilities
class CyberBorg
  #################
  ### CONSTANTS ###
  #################

  @NORTH = 0
  @EAST = 90
  @SOUTH = 180
  @WEST = 270

  @ORDER_MAP = [
    'DORDER_NONE'		# 0
    'DORDER_STOP'		# 1
    'DORDER_MOVE'		# 2
    'DORDER_ATTACK'		# 3
    'DORDER_BUILD'		# 4
    'DORDER_HELPBUILD'		# 5
    'DORDER_LINEBUILD'		# 6
    'DORDER_DEMOLISH'		# 7
    'DORDER_REPAIR'		# 8
    'DORDER_OBSERVE'		# 9
    'DORDER_FIRESUPPORT'	# 10
    'DORDER_RETREAT'		# 11
    'DORDER_DESTRUCT'		# 12
    'DORDER_RTB'		# 13
    'DORDER_RTR'		# 14
    'DORDER_RUN'		# 15
    'DORDER_EMBARK'		# 16
    'DORDER_DISEMBARK'		# 17
    'DORDER_ATTACKTARGET'	# 18
    'DORDER_COMMANDERSUPPORT'	# 19
    'DORDER_BUILDMODULE'	# 20
    'DORDER_RECYCLE'		# 21
    'DORDER_TRANSPORTOUT'	# 22
    'DORDER_TRANSPORTIN'	# 23
    'DORDER_TRANSPORTRETURN'	# 24
    'DORDER_GUARD'		# 25
    'DORDER_DROIDREPAIR'	# 26
    'DORDER_RESTORE'		# 27
    'DORDER_SCOUT'		# 28
    'DORDER_RUNBURN'		# 29
    'DORDER_UNUSED'		# 30
    'DORDER_PATROL'		# 31
    'DORDER_REARM'		# 32
    'DORDER_RECOVER'		# 33
    'DORDER_LEAVEMAP'		# 34
    'DORDER_RTR_SPECIFIED'	# 35
    'DORDER_CIRCLE'		# 36 :-??
    'DORDER_HOLD'		# 37 :-??
    null			# 38
    null			# 39
    'DORDER_CIRCLE'		# 40 :-??
    # ME STUFF
    null			# 41
    null			# 42
    null			# 43
    null			# 44
    null			# 45
    null			# 46
    null			# 47
    null			# 48
    null			# 49
    'DORDER_MAINTAIN'		# 50
    'FORDER_MANUFACTURE'	# 51
    'LORDER_RESEARCH'		# 52
    'CORDER_PASS'		# 53
    'IS_LAIDOFF'		# 54
  ]

  #############
  ### ENUMS ###
  #############

  @enum_struct = (params...) ->
    array = enumStruct(params...).map (object) -> new WZObject(object)
    WZArray.bless(array)

  @enum_feature = (params...) ->
    array = enumFeature(params...).map (object) -> new WZObject(object)
    WZArray.bless(array)

  @enum_droid = (params...) ->
    array = enumDroid(params...).map (object) -> new WZObject(object)
    WZArray.bless(array)

  #################
  ### IS WUT??? ###
  #################

  @is_truck = (droid) ->
    droid.droidType is DROID_CONSTRUCT

  @is_weapon = (droid) ->
    droid.droidType is DROID_WEAPON

  @is_factory = (structure) ->
    structure.stattype is FACTORY

  @is_resource = (object) ->
    [
      OIL_RESOURCE,
      RESOURCE_EXTRACTOR
    ].indexOf(object.stattype) > WZArray.NONE

  # The API is moving from 3 switches to just two.
  # BEING_BUILT, BUILT, and BEING_DEMOLISHED to just
  # BEING_BUILT and BUILT.
  # It may be confusing to have a function called being_built
  # when it could in fact be being demolished.
  # So the function is named by what it tests and means.
  @is_not_built = (structure) -> structure.status != BUILT

  ############
  ### GETS ###
  ############

  @get_resources = (at) ->
    CyberBorg.enum_feature(ALL_PLAYERS, "OilResource").nearest(at)

  @get_free_spots = (at,n=1) ->
    x = at.x
    y = at.y
    list = WZArray.bless(enumArea(x-n, y-n, x+n, y+n, ALL_PLAYERS, false))
    positions = []
    for i in [-n..n]
      for j in [-n..n]
        pos = {x:(x+i),y:(y+j)}
        positions.push(pos) unless list.collision(pos)
    positions

  @get_power = () -> playerPower(me)

# This is to keep with the WZ JS API's way...
# Globals for ME STUFF order numbers.
DORDER_MAINTAIN    = CyberBorg.ORDER_MAP.indexOf('DORDER_MAINTAIN')
FORDER_MANUFACTURE = CyberBorg.ORDER_MAP.indexOf('FORDER_MANUFACTURE')
LORDER_RESEARCH    = CyberBorg.ORDER_MAP.indexOf('LORDER_RESEARCH')
CORDER_PASS        = CyberBorg.ORDER_MAP.indexOf('CORDER_PASS')
IS_LAIDOFF         = CyberBorg.ORDER_MAP.indexOf('IS_LAIDOFF')
