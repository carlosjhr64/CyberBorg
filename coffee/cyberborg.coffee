# CyberBorg will help package data and provide utilities
class CyberBorg
  #################
  ### CONSTANTS ###
  #################

  @NORTH = 0
  @EAST = 90
  @SOUTH = 180
  @WEST = 270
  @ALL_PLAYERS = -1
  @IS_IDLE = -1

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
  ]

  #######################
  ### CLASS VARIABLES ###
  #######################

  @TRACE = true # TODO set to false when done debuging, Class Varible? :-??
  @CID = 0 # TODO Class Variable? :-??

  ###################
  ### CONSTRUCTOR ###
  ###################

  constructor: () ->
    # Need a way to register groups
    @groups = WZArray.bless([])
    # Used to keep track of power consumption.
    # Gets updated in update, below.
    @power = 0
    @stalled = []

  ###############
  ### UPDATES ###
  ###############

  # Updates all game objects, group by group.
  update: () ->
    @power = playerPower()
    for group in @groups
      for object in group.list
        object.update() if object.game_time < gameTime

  ############
  ### GETS ###
  ############

  for_all: (test_of) ->
    list = []
    for group in @groups
      for object in group.list
        list.push(object) if test_of(object)
    return WZArray.bless(list)

  for_one: (test_of) ->
    for group in @groups
      for object in group.list
        return({object:object,group:group}) if test_of(object)
    return null

  # When we get pre-existing game objects from WZ's JS API,
  # we need to find them in our groups.
  # Otherwise we end up with duplicates.
  find: (target) -> @for_one((object) -> object.id is target.id)?.object

  # For cases where we want to get both our copy of the object and
  # the group it's in.
  finds: (target) -> @for_one((object)->  object.id is target.id)

  structure_at: (at) ->
    found = (object) ->
      object.x is at.x and
      object.y is at.y and
      object.type is STRUCTURE
    @for_one(found)?.object

  # Returns the first command found with the given cid
  get_command: (cid) ->
    for group in @groups
      for command in group.commands
        return command if command.cid is cid
    return null

  #############
  ### ENUMS ###
  #############

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

  # TODO will this ever be relevant again?
  @is_idle = (object) ->
    # It's not really a droid  :P
    if object.type is STRUCTURE
      if object.command_time is gameTime
        # It got it's command just now
        return(false)
      else
        return(structureIdle(object))
    # It's a droid # TODO may need more cases.
    not_idle = [
      DORDER_BUILD, DORDER_HELPBUILD, DORDER_LINEBUILD
      DORDER_DEMOLISH
      DORDER_REPAIR
      DORDER_SCOUT, DORDER_MOVE
    ]
    not_idle.indexOf(object.order) is WZArray.NONE

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

  ###############
  ### METRICS ###
  ###############

  @distance_metric = (a, b) ->
    x = a.x - b.x
    y = a.y - b.y
    x * x + y * y

  @nearest_metric = (a, b, at) ->
    CyberBorg.distance_metric(a, at) - CyberBorg.distance_metric(b, at)

  ############
  ### GETS ###
  ############

  @get_resources = (at) ->
    CyberBorg.enum_feature(@ALL_PLAYERS, "OilResource").nearest(at)

  @get_my_trucks = (at) -> # TODO out of group style?
    CyberBorg.enum_droid(me, DROID_CONSTRUCT)

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

  @cid = () -> CyberBorg.CID += 1

# This is to keep with the WZ JS API's way...
# Globals for ME STUFF order numbers.
DORDER_MAINTAIN    = CyberBorg.ORDER_MAP.indexOf('DORDER_MAINTAIN')
FORDER_MANUFACTURE = CyberBorg.ORDER_MAP.indexOf('FORDER_MANUFACTURE')
LORDER_RESEARCH    = CyberBorg.ORDER_MAP.indexOf('LORDER_RESEARCH')
