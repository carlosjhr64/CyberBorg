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
  constructor: (@groups={}) ->

  update: () ->
    for name of @groups
      group = @groups[name].group
      for object in group
        object.update() if object.game_time < gameTime

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

  @is_factory = (structure) ->
    structure.stattype is FACTORY

  @is_idle = (object) ->
    # It's not really a droid  :P
    return (structureIdle(object))  if object.type is STRUCTURE
    # It's a droid
    not_idle = [DORDER_BUILD, DORDER_HELPBUILD, DORDER_LINEBUILD, DORDER_DEMOLISH]
    not_idle.indexOf(object.order) is WZArray.NONE

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


# ###########################################################################################
#  
#
#// Globals
#
#var GUARD_DERRICK = 0;
#var BUILD_DERRICK = 0;
#var PHASE_MODULO = 12;
#var DERRICKS = null; // Set at start of game
#
#
#var BASE_ORDER = WZArray.INIT;
#
#var RESEARCH_ORDERS = [
#  'R-Wpn-MG1Mk1',		// Machine Gun Turret
#  'R-Struc-PowerModuleMk1',	// Power Module
#  'R-Defense-Tower01',
#  'R-Wpn-MG3Mk1',		// Heavy Machine Gun
#  'R-Struc-RepairFacility',		// Repair Facility
#  'R-Defense-WallTower02',	// Ligh Cannon Hardpoint
#  'R-Defense-AASite-QuadMg1',	// AA
#  'R-Vehicle-Body04',		// Bug Body
#  'R-Struc-VTOLFactory',	// Vtol Factory
#  'R-Vehicle-Prop-VTOL',	// Vtol
#  'R-Wpn-Bomb01',		// Vtol Bomb
#];
#var RESEARCH_FACILITIES = [];
#
#// JS Utilities
#
#
#// General Utilities
#
#// WZ2100 Utilities
#
#function my_trucks(){
#  return(enumDroid(me, DROID_CONSTRUCT));
#}
#
#function is_resource(object){
#  var a_resource = [ OIL_RESOURCE, RESOURCE_EXTRACTOR ];
#  return (a_resource.indexOf(object.stattype) > WZArray.NONE);
#}
#

#
#// Console utilities
#
#
#var DERRICK_GROUP = new Group();
#
#function derrick_moves(droid){
#  var moving = false;
#
#  if (droid.is_truck()){
#    var at = DERRICKS[BUILD_DERRICK];
#    if (at){
#      droid.build("A0ResourceExtractor", at);
#      BUILD_DERRICK = (BUILD_DERRICK + 1) % PHASE_MODULO;
#      moving = true;
#    }
#  }else{
#    if (droid.group != DERRICK_GROUP) {
#      var at = DERRICKS[(PHASE_MODULO - 1) - GUARD_DERRICK];
#      if (at){
#        DERRICK_GROUP.add(droid);
#        // Problem here is that we've ordered an individual droid  :(
#        orderDroidLoc(droid, DORDER_SCOUT, at.x, at.y);
#        GUARD_DERRICK = (GUARD_DERRICK + 1) % PHASE_MODULO;
#        moving = true;
#      }
#    }else{
#      // presumably guarding the position
#      moving = true;
#    }
#  }
#
#  return(moving);
#}
#
#function make_busy(droids){
#  var clss = getObjectClass(droids);
#  if (clss != 'Array'){ droids = [droids]; }
#  for (var i=0;i<droids.length;i++) {
#    var droid = droids[i];
#    if(derrick_moves(droid) == false) { console(droid.namexy()+" is idle."); }
#  }
#}
#
#/* TODO Commented out for now
#function eventDroidIdle(droid)
#{
#//  make_busy(droid);
#}
#

