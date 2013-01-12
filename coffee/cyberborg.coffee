# CyberBorg will help package data and prodide utilities
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
    'DORDER_NONE'
    'DORDER_STOP'
    'DORDER_MOVE'
    'DORDER_ATTACK'
    'DORDER_BUILD'
    'DORDER_HELPBUILD'
    'DORDER_LINEBUILD'
    'DORDER_DEMOLISH'
    'DORDER_REPAIR'
    'DORDER_OBSERVE'
    'DORDER_FIRESUPPORT'
    'DORDER_RETREAT'
    'DORDER_DESTRUCT'
    'DORDER_RTB'
    'DORDER_RTR'
    'DORDER_RUN'
    'DORDER_EMBARK'
    'DORDER_DISEMBARK'
    'DORDER_ATTACKTARGET'
    'DORDER_COMMANDERSUPPORT'
    'DORDER_BUILDMODULE'
    'DORDER_RECYCLE'
    'DORDER_TRANSPORTOUT'
    'DORDER_TRANSPORTIN'
    'DORDER_TRANSPORTRETURN'
    'DORDER_GUARD'
    'DORDER_DROIDREPAIR'
    'DORDER_RESTORE'
    'DORDER_SCOUT'
    'DORDER_RUNBURN'
    'DORDER_UNUSED'
    'DORDER_PATROL'
    'DORDER_REARM'
    'DORDER_RECOVER'
    'DORDER_LEAVEMAP'
    'DORDER_RTR_SPECIFIED'
    'DORDER_CIRCLE'
    'DORDER_HOLD'
  ]

  #######################
  ### CLASS VARIABLES ###
  #######################

  @TRACE = false
  @OID = 0

  ###################
  ### CONSTRUCTOR ###
  ###################

  constructor: () ->
    # Need a way to register groups
    @groups = WZArray.bless([])
    # Used to keep track of power consumption.
    # Gets updated in update, below.
    @power = 0

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

  # Returns the first order found with the given oid
  get_order: (oid) ->
    for group in @groups
      for order in group.orders
        return order if order.oid is oid
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

  @is_idle = (object) ->
    # It's not really a droid  :P
    if object.type is STRUCTURE
      if object.order_time is gameTime
        # It got it's orders just now
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

  @oid = () -> CyberBorg.OID += 1
