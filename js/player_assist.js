var base_group, cyberBorg, eventDroidBuilt, eventStartLevel, eventStructureBuilt, factory_group, min_map_and_design_on;

include("multiplay/skirmish/cyberborg.js");

include("multiplay/skirmish/cyberborg.data.js");

cyberBorg = new CyberBorg();

eventStartLevel = function() {
  var derricks, reserve;
  console("This is player_assist.js");
  reserve = new Group();
  console("We have " + reserve.group.length + " droids available, and    " + (reserve.group.count(CyberBorg.is_truck)) + " of them are trucks.");
  derricks = cyberBorg.get_resources(reserve.group.center());
  console("There are " + derricks.length + " resource points.");
  cyberBorg.reserve = reserve;
  cyberBorg.derricks = derricks;
  cyberBorg.base = new Group([], cyberBorg.base_orders(), cyberBorg.reserve.group);
  cyberBorg.factory = new Group([], cyberBorg.factory_orders());
  return base_group();
};

base_group = function() {
  var base, builders, count, order;
  base = cyberBorg.base;
  order = base.orders.next();
  if (order) {
    builders = base.build(order);
    count = builders.length;
    console("There are " + count + " droids working on " + order.structure + ".");
    if (builders.length === 0) {
      return console("Base group was unable to complete base orders.");
    }
  } else {
    return console("Base orders complete?");
  }
};

eventStructureBuilt = function(structure, droid) {
  structure = new WZObject(structure);
  droid = new WZObject(droid);
  console("" + (structure.namexy()) + " Built!");
  if (cyberBorg.base.group.contains(droid)) base_group();
  if ((structure.type === STRUCTURE) && (structure.stattype === FACTORY)) {
    cyberBorg.factory.group.push(structure);
    factory_group();
  }
  if (structure.stattype === HQ) return min_map_and_design_on(structure);
};

min_map_and_design_on = function(structure) {
  structure = new WZObject(structure);
  if (structure.player === selectedPlayer && structure.type === STRUCTURE && structure.stattype === HQ) {
    setMiniMap(true);
    return setDesign(true);
  }
};

factory_group = function() {
  var factory, order;
  factory = cyberBorg.factory;
  order = factory.orders.next();
  if (order) {
    if (factory.buildDroid(order)) {
      return console("Building " + order.name + ".");
    } else {
      return console("" + order.name + " rejected?");
    }
  } else {
    return console("Droid builds done?");
  }
};

eventDroidBuilt = function(droid, structure) {
  droid = new WZObject(droid);
  structure = new WZObject(structure);
  console("Built " + droid.name + ".");
  cyberBorg.reserve.group.push(droid);
  if (cyberBorg.factory.group.contains(structure)) return factory_group();
};
