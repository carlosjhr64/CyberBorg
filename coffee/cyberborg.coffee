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

  ###################
  ### CONSTRUCTOR ###
  ###################

  # Need a way to register groups
  constructor: () ->
    @groups = WZArray.bless([])
    @power = 0

  ###############
  ### UPDATES ###
  ###############

  update: () ->
    @power = playerPower()
    for group in @groups
      for object in group.list
        object.update() if object.game_time < gameTime

  find: (target) ->
    for group in @groups
      for object in group.list
        return(object) if object.id is target.id
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
    # It's a droid # TODO specifically a truck, will need more cases.
    not_idle = [
      DORDER_BUILD, DORDER_HELPBUILD, DORDER_LINEBUILD, DORDER_DEMOLISH
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
  #  So the function is named by what it tests and means.
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
