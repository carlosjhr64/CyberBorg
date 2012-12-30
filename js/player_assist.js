var base_group, cyberBorg, eventChat, eventDroidBuilt, eventStartLevel, eventStructureBuilt, factory_group, min_map_and_design_on, report;

include("multiplay/skirmish/cyberborg.js");

include("multiplay/skirmish/cyberborg.data.js");

cyberBorg = new CyberBorg();

eventStartLevel = function() {
  var derricks, groups, reserve;
  console("This is player_assist.js");
  reserve = new Group();
  console("We have " + reserve.group.length + " droids available, and    " + (reserve.group.count(CyberBorg.is_truck)) + " of them are trucks.");
  derricks = cyberBorg.get_resources(reserve.group.center());
  console("There are " + derricks.length + " resource points.");
  groups = CyberBorg.groups;
  groups.reserve = reserve;
  cyberBorg.derricks = derricks;
  groups.base = new Group([], cyberBorg.base_orders(), reserve.group);
  groups.factory = new Group([], cyberBorg.factory_orders());
  return base_group();
};

base_group = function() {
  var base, builders, count, groups, order;
  groups = CyberBorg.groups;
  base = groups.base;
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
  var groups;
  structure = new WZObject(structure);
  droid = new WZObject(droid);
  groups = CyberBorg.groups;
  console("" + (structure.namexy()) + " Built!");
  if (groups.base.group.contains(droid)) base_group();
  if ((structure.type === STRUCTURE) && (structure.stattype === FACTORY)) {
    groups.factory.group.push(structure);
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
  var factory, groups, order;
  groups = CyberBorg.groups;
  factory = groups.factory;
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
  var groups;
  droid = new WZObject(droid);
  structure = new WZObject(structure);
  groups = CyberBorg.groups;
  console("Built " + droid.name + ".");
  groups.reserve.group.push(droid);
  if (groups.factory.group.contains(structure)) return factory_group();
};

eventChat = function(sender, to, message) {
  if (sender === 0) {
    switch (message) {
      case 'report base':
        return report('base');
      case 'report reserve':
        return report('reserve');
      default:
        return console("What?");
    }
  }
};

report = function(who) {
  var droid, groups, _i, _j, _len, _len2, _ref, _ref2, _results, _results2;
  groups = CyberBorg.groups;
  switch (who) {
    case 'base':
      _ref = groups.base.group;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        droid = _ref[_i];
        _results.push(console(droid.namexy()));
      }
      return _results;
      break;
    case 'reserve':
      _ref2 = groups.reserve.group;
      _results2 = [];
      for (_j = 0, _len2 = _ref2.length; _j < _len2; _j++) {
        droid = _ref2[_j];
        _results2.push(console(droid.namexy()));
      }
      return _results2;
      break;
    default:
      return console("What???");
  }
};
