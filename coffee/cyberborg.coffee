# CyberBorg will help package data and prodide utilities
class CyberBorg
  # Constants
  @NORTH = 0
  @EAST = 90
  @SOUTH = 180
  @WEST = 270
  @ALL_PLAYERS = -1

  @enum_feature = (params...) ->
    array = enumFeature(params...).map (object) -> new WZObject(object)
    WZArray.bless(array)

  @enum_droid = (params...) ->
    array = enumDroid(params...).map (object) -> new WZObject(object)
    WZArray.bless(array)

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
  @not_built = (structure) -> structure.status != BUILT

  @distance_metric = (a, b) ->
    x = a.x - b.x
    y = a.y - b.y
    x * x + y * y

  @nearest_metric = (a, b, at) ->
    CyberBorg.distance_metric(a, at) - CyberBorg.distance_metric(b, at)

  @get_resources = (at) ->
    CyberBorg.enum_feature(@ALL_PLAYERS, "OilResource").nearest(at)

  # Need a way to register groups
  constructor: (@groups={}) ->

  update: () ->
    for name of @groups
      group = @groups[name].group
      for object in group
        object.update() if object.game_time < gameTime

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

#//  6.
#//  The second structure that this AI builds is a research facility.
#//  When that happens, do_research gets called from eventStructureBuilt (see 3.).
#//  This AI builds five research facilities (the standard limit).
#//  The AI also makes use of WZ2100 JS API's pursueResearch, which
#//  allows one to specify the desired technology rather than
#//  having to specify each technologyy in it's research path.
#//  This requires a bit a management.
#function do_research(structure, research){
#  // The structure may already have been given a research path.
#  var  order = RESEARCH_ORDERS.of(structure);
#  // If not, then we'll give it one.
#  if(!order){ order = RESEARCH_ORDERS.next(structure); }
#  // we need to know what the structure just got done researching, if anything.
#  if (research) {
#    console(structure.namexy()+" pursuing "+order+" got done with "+research.name+".");
#    debug('***'); // TODO remove
#    debug(structure.namexy()+" pursuing "+order+" got done with "+research.name+"."); // TODO remove
#    // If we've reached the the technology sought, then get the next order.
#    if (order == research.name) { order = RESEARCH_ORDERS.next(structure); }
#  }
#  // Eventually, we run out of orders, so we need to check.
#  if (order) {
#    // So let the player know what we're researching, and order the facilty to pursue it.
#    console(structure.namexy()+' is doing '+order+'.');
#    pursueResearch(structure, order);
#  } else {
#    console('Research orders complete?');
#  }
#}
#
#/* TODO Commented out for now
#//  Every time a research facility is done researching a technology,
#//  a research event is triggered, and eventResearched is called.
#//  eventResearched is WZ2100 JS API.
#function eventResearched(research, structure){
#  // A new research tecnology can be acquired by picking up it's plan,
#  // which can be found from the ruins of a demolished facility.
#  // So we need to check that in fact the technology came from an active structure.
#  if (structure) { do_research(structure, research); }
#}
#
#
#// OK, so I need to define RESERVE quick!  :))
#// See 6. above.
#
#
