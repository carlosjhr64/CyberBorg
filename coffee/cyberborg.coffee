# Let's keep our Array hacks in their own files for now.
include "multiplay/skirmish/cyberborg.array.js"

# Let's keep our Object hacks in their own files for now.
include "multiplay/skirmish/cyberborg.object.js"

# Warzone 2100 Objects
class WZObject
  # There are two ways to convert a game data object into a WZObject object.
  # The first way is by copying the object's data into a WZObject.
  # That's the constructor's way (for the second way, see bless below).
  constructor: (object) -> @copy(object)
  copy: (object) ->
    @game_time = gameTime
    @[key] = object[key] for key of object
  # There are two ways to convert a game data object into a WZObject object.
  # The second way is by linking WZObject's methods to the object's data.
  # That's the bless's way (for the first way, see constructor above).
  # Unfortunately, we're given a read only object, so have to use the constructor.
  @bless = (object) ->
    return object if object.game_time # very likely already blessed
    object['game_time'] = gameTime
    object[name] = method for name, method of WZObject.prototype
    object

  # TODO only needs to update volatile data :-??
  update: () -> @copy(objFromId(@))

  build: (structure_id, pos, direction) ->
    orderDroidBuild(@, DORDER_BUILD, structure_id, pos.x, pos.y, direction)

  namexy: () -> "#{@name}(#{@x},#{@y})"

  position: () -> x: @x, y: @y

  is_truck: () -> CyberBorg.is_truck @


class WZArray
  @INIT = -1
  @NONE = -1

  @bless = (array) ->
    # TODO when "is" is WZArray, uncoment below
    #return array if array.is # if array.is, very likely already blessed.
    array[name] = method for name, method of WZArray.prototype
    array

  # center WZ2100
  center: ->
    at =
      x: 0
      y: 0
    n = @length
    i = 0
    while i < n
      at.x += this[i].x
      at.y += this[i].y
      i++
    at.x = at.x / n
    at.y = at.y / n
    at

  # first
  first: ->
    this[0]

  # count WZ2100 (clobbers ruby?) TODO
  count: (type) ->
    count = 0
    i = 0
    while i < @length
      count += 1  if type(this[i])
      i++
    count

  #  current WZ2100
  _current: WZArray.INIT
  current: this[@_current]

  # next WZ2100
  next: (gameobj) ->
    @_current += 1  if @_current < this.length
    order = this[@_current]
    @is[gameobj.id] = order  if gameobj
    order

  # previous WZ2100
  previous: (gameobj) ->
    @_current -= 1  if @_current > WZArray.init
    order = this[@_current]
    @is[gameobj.id] = order  if gameobj
    order

  # not_built WZ2100
  not_built: -> @filters(not_built)

  # not_in_group  WZ2100
  not_in_group: (group) ->
    @filters((droid) -> group.group.indexOfObject(droid) is Array.NONE)

  # indexOf  JS-ARRAY
  # is WZ2100
  is: {}

  # of  WZ2100
  of: (gameobj) ->
    @is[gameobj.id]

  # replace  RUBY
  # reverse  JS-ARRAY
  # shift  JS-ARRAY
  # slice  JS-ARRAY
  # some  JS-ARRAY
  # sort  JS-ARRAY
  # splice  JS-ARRAY
  # toSource  JS-ARRAY
  # toString  JS-ARRAY
  # trucks  WZ2100
  trucks: -> @filters(CyberBorg.is_truck)

  # factories WZ2100
  factories: -> @filters(CyberBorg.is_factory)

  # unshift  JS-ARRAY

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

# Filters
is_idle = (droid) ->
  # It's not really a droid  :P
  return (structureIdle(droid))  if droid.type is STRUCTURE
  # It's a droid
  not_idle = [DORDER_BUILD, DORDER_HELPBUILD, DORDER_LINEBUILD, DORDER_DEMOLISH]
  not_idle.indexOf(droid.order) is Array.NONE

# The Group Class
class Group
  constructor: (@group, @orders, @reserve) ->
    # If we're not given a list of droids,
    # get them from enumDroid (all of the player's pieces).
    if @group then WZArray.bless(@group) else @group = CyberBorg.enum_droid()
    # orders is a list of things for the group to do
    if @orders then WZArray.bless(@orders) else @orders = WZArray.bless([])
    # reserve are the units we can draw from.
    if @reserves then WZArray.bless(@reserves) else @reserves = WZArray.bless([])

  recruit: (n, type, at) ->
    recruits = @reserve
    # NOTE: recruits won't be this.reserve if filtered!
    recruits = recruits.filters(type)  if type
    recruits.nearest at  if at
    i = 0
    while i < n
      break  unless recruits[0]
      droid = recruits.shift()
      @reserve.removeObject(droid)
      @group.push(droid)
      i++

  cut: (n, type, at) ->
    cuts = @group
    # NOTE: cuts won't be this.group if filtered!
    cuts = cuts.filters(type)  if type
    cuts.nearest at  if at
    i = 0
    while i < n
      droid = cuts.pop()
      break  unless droid
      @group.removeObject(droid)
      @reserve.push(droid)
      i++

  buildDroid: (order) ->
    factories = @group.factories().idle()
    i = 0
    while i < factories.length
      return (factories[i])  if buildDroid(factories[i], order.name, order.body, order.propulsion, "", order.droid_type, order.turret)
      i++
    null

  build: (order) ->
    builders = [] # going to return the number of builders
    structure = order.structure
    if isStructureAvailable(structure)
      at = order.at # where to build the structure
      # Get available trucks
      trucks = @group.trucks().idle()
      count = trucks.length
      if count < order.min
        @recruit(order.min - count, CyberBorg.is_truck, at)
        # Note that reserve trucks should always be idle for this to work.
        trucks = @group.trucks().idle()
      else
        if count > order.max
          @cut(count - order.min, CyberBorg.is_truck, at)
          trucks = @group.trucks().idle()
      if trucks.length > 0
        trucks.nearest(at) # sort by distance
        # assume nearest one can do
        pos = pickStructLocation(trucks[0], structure, at.x, at.y)
        if pos
          i = 0
          while i < trucks.length
            builders.push trucks[i]  if trucks[i].build(structure, pos)
            i++
    builders
# The Group Class End

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
#var BASE_ORDER = Array.INIT;
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
#  return (a_resource.indexOf(object.stattype) > Array.NONE);
#}
#
#//  The API is moving from 3 switches to just two.
#//  BEING_BUILT, BUILT, and BEING_DEMOLISHED to just
#//  BEING_BUILT and BUILT.
#//  It may be confusing to have a function called being_built
#//  when it could in fact be being demolished.
#//  So the function is named by what it tests and means.
#function not_built(structure){
#  return(structure.status != BUILT);
#}
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
