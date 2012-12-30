var CyberBorg, Group, WZObject, is_idle,
  __slice = Array.prototype.slice;

include("multiplay/skirmish/cyberborg.array.js");

include("multiplay/skirmish/cyberborg.object.js");

CyberBorg = (function() {

  CyberBorg.NORTH = 0;

  CyberBorg.EAST = 90;

  CyberBorg.SOUTH = 180;

  CyberBorg.WEST = 270;

  CyberBorg.ALL_PLAYERS = -1;

  CyberBorg.enum_feature = function() {
    var params;
    params = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    return enumFeature.apply(null, params).map(function(object) {
      return new WZObject(object);
    });
  };

  CyberBorg.enum_droid = function() {
    var params;
    params = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    return enumDroid.apply(null, params).map(function(object) {
      return new WZObject(object);
    });
  };

  function CyberBorg() {}

  CyberBorg.prototype.get_resources = function(at) {
    return CyberBorg.enum_feature(this.ALL_PLAYERS, "OilResource").nearest(at);
  };

  CyberBorg.is_truck = function(droid) {
    return droid.droidType === DROID_CONSTRUCT;
  };

  CyberBorg.is_factory = function(structure) {
    return structure.stattype === FACTORY;
  };

  CyberBorg.distance_metric = function(a, b) {
    var x, y;
    x = a.x - b.x;
    y = a.y - b.y;
    return x * x + y * y;
  };

  CyberBorg.nearest_metric = function(a, b, at) {
    return CyberBorg.distance_metric(a, at) - CyberBorg.distance_metric(b, at);
  };

  return CyberBorg;

})();

is_idle = function(droid) {
  var not_idle;
  if (droid.type === STRUCTURE) return structureIdle(droid);
  not_idle = [DORDER_BUILD, DORDER_HELPBUILD, DORDER_LINEBUILD, DORDER_DEMOLISH];
  return not_idle.indexOf(droid.order) === Array.NONE;
};

WZObject = (function() {

  function WZObject(object) {
    var key;
    for (key in object) {
      this[key] = object[key];
    }
  }

  WZObject.prototype.build = function(structure_id, pos, direction) {
    return orderDroidBuild(this, DORDER_BUILD, structure_id, pos.x, pos.y, direction);
  };

  WZObject.prototype.namexy = function() {
    return "" + this.name + "(" + this.x + "," + this.y + ")";
  };

  WZObject.prototype.position = function() {
    return {
      x: this.x,
      y: this.y
    };
  };

  WZObject.prototype.is_truck = function() {
    return CyberBorg.is_truck(this);
  };

  return WZObject;

})();

Group = (function() {

  function Group(group, orders, reserve) {
    this.group = group;
    this.orders = orders;
    this.reserve = reserve;
    if (!this.group) this.group = CyberBorg.enum_droid();
    if (!this.orders) this.orders = [];
    if (!this.reserve) this.reserve = [];
  }

  Group.prototype.recruit = function(n, type, at) {
    var droid, i, recruits, _results;
    recruits = this.reserve;
    if (type) recruits = recruits.filter(type);
    if (at) recruits.nearest(at);
    i = 0;
    _results = [];
    while (i < n) {
      if (!recruits[0]) break;
      droid = recruits.shift();
      this.reserve.removeObject(droid);
      this.group.push(droid);
      _results.push(i++);
    }
    return _results;
  };

  Group.prototype.cut = function(n, type, at) {
    var cuts, droid, i, _results;
    cuts = this.group;
    if (type) cuts = cuts.filter(type);
    if (at) cuts.nearest(at);
    i = 0;
    _results = [];
    while (i < n) {
      droid = cuts.pop();
      if (!droid) break;
      this.group.removeObject(droid);
      this.reserve.push(droid);
      _results.push(i++);
    }
    return _results;
  };

  Group.prototype.buildDroid = function(order) {
    var factories, i;
    factories = this.group.factories().idle();
    i = 0;
    while (i < factories.length) {
      if (buildDroid(factories[i], order.name, order.body, order.propulsion, "", order.droid_type, order.turret)) {
        return factories[i];
      }
      i++;
    }
    return null;
  };

  Group.prototype.build = function(order) {
    var at, builders, count, i, pos, structure, trucks;
    builders = [];
    structure = order.structure;
    if (isStructureAvailable(structure)) {
      at = order.at;
      trucks = this.group.trucks().idle();
      count = trucks.length;
      if (count < order.min) {
        this.recruit(order.min - count, CyberBorg.is_truck, at);
        trucks = this.group.trucks().idle();
      } else {
        if (count > order.max) {
          this.cut(count - order.min, CyberBorg.is_truck, at);
          trucks = this.group.trucks().idle();
        }
      }
      if (trucks.length > 0) {
        trucks.nearest(at);
        pos = pickStructLocation(trucks[0], structure, at.x, at.y);
        if (pos) {
          i = 0;
          while (i < trucks.length) {
            if (trucks[i].build(structure, pos)) builders.push(trucks[i]);
            i++;
          }
        }
      }
    }
    return builders;
  };

  return Group;

})();
