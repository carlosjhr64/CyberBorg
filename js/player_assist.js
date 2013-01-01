var CyberBorg, Group, WZArray, WZObject, base_group, cyberBorg, derricks_group, eventChat, eventDroidBuilt, eventDroidIdle, eventResearched, eventStartLevel, eventStructureBuilt, factory_group, min_map_and_design_on, report, research_group,
  __slice = Array.prototype.slice;

Number.prototype.times = function(action) {
  var i, _results;
  i = 0;
  _results = [];
  while (i < this.valueOf()) {
    action();
    _results.push(i++);
  }
  return _results;
};

WZObject = (function() {

  function WZObject(object) {
    this.copy(object);
    this.is_wzobject = true;
  }

  WZObject.prototype.copy = function(object) {
    var key, _results;
    this.game_time = gameTime;
    _results = [];
    for (key in object) {
      _results.push(this[key] = object[key]);
    }
    return _results;
  };

  WZObject.prototype.update = function() {
    return this.copy(objFromId(this));
  };

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

  WZObject.prototype.is_weapon = function() {
    return CyberBorg.is_weapon(this);
  };

  return WZObject;

})();

WZArray = (function() {

  function WZArray() {}

  WZArray.INIT = -1;

  WZArray.NONE = -1;

  WZArray.bless = function(array) {
    var method, name, _ref;
    if (array.is_wzarray) return array;
    _ref = WZArray.prototype;
    for (name in _ref) {
      method = _ref[name];
      array[name] = method;
    }
    array.is_wzarray = true;
    return array;
  };

  /* QUERIES
  */

  WZArray.prototype.indexOfObject = function(object) {
    var i, id;
    id = object.id;
    i = 0;
    while (i < this.length) {
      if (this[i].id === id) return i;
      i++;
    }
    return WZArray.NONE;
  };

  WZArray.prototype.contains = function(object) {
    return this.indexOfObject(object) > WZArray.NONE;
  };

  WZArray.prototype.removeObject = function(object) {
    var i;
    i = this.indexOfObject(object);
    if (i > WZArray.NONE) this.splice(i, 1);
    return i;
  };

  /* FILTERS
  */

  WZArray.prototype.filters = function(type) {
    return WZArray.bless(this.filter(type));
  };

  WZArray.prototype.trucks = function() {
    return this.filters(CyberBorg.is_truck);
  };

  WZArray.prototype.weapons = function() {
    return this.filters(CyberBorg.is_weapon);
  };

  WZArray.prototype.factories = function() {
    return this.filters(CyberBorg.is_factory);
  };

  WZArray.prototype.not_built = function() {
    return this.filters(CyberBorg.is_not_built);
  };

  WZArray.prototype.not_in = function(group) {
    return this.filters(function(object) {
      return group.group.indexOfObject(object) === WZArray.NONE;
    });
  };

  WZArray.prototype["in"] = function(group) {
    return this.filters(function(object) {
      return group.group.indexOfObject(object) > WZArray.NONE;
    });
  };

  WZArray.prototype.idle = function() {
    return this.filters(CyberBorg.is_idle);
  };

  /* SORTS
  */

  WZArray.prototype.nearest = function(at) {
    this.sort(function(a, b) {
      return CyberBorg.nearest_metric(a, b, at);
    });
    return this;
  };

  /* SUMARIES
  */

  WZArray.prototype.counts = function(type) {
    var count, i;
    count = 0;
    i = 0;
    while (i < this.length) {
      if (type(this[i])) count += 1;
      i++;
    }
    return count;
  };

  WZArray.prototype.counts_named = function(name) {
    var count, i;
    count = 0;
    i = 0;
    while (i < this.length) {
      if (this[i].name === name) count += 1;
      i++;
    }
    return count;
  };

  WZArray.prototype.center = function() {
    var at, i, n;
    at = {
      x: 0,
      y: 0
    };
    n = this.length;
    i = 0;
    while (i < n) {
      at.x += this[i].x;
      at.y += this[i].y;
      i++;
    }
    at.x = at.x / n;
    at.y = at.y / n;
    return at;
  };

  /* ACCESSING
  */

  WZArray.prototype.first = function() {
    return this[0];
  };

  WZArray.prototype._current = WZArray.INIT;

  WZArray.prototype.current = function() {
    return this[this._current];
  };

  WZArray.prototype.next = function(gameobj) {
    var order;
    if (this._current < this.length) this._current += 1;
    order = this[this._current];
    if (gameobj) this.is[gameobj.id] = order;
    return order;
  };

  WZArray.prototype.previous = function(gameobj) {
    var order;
    if (this._current > WZArray.init) this._current -= 1;
    order = this[this._current];
    if (gameobj) this.is[gameobj.id] = order;
    return order;
  };

  /* STORES
  */

  WZArray.prototype.is = {};

  WZArray.prototype.of = function(object) {
    return this.is[object.id];
  };

  return WZArray;

})();

Group = (function() {

  function Group(group, orders, reserve) {
    this.group = group;
    this.orders = orders;
    this.reserve = reserve;
    if (this.group) {
      WZArray.bless(this.group);
    } else {
      this.group = CyberBorg.enum_droid();
    }
    if (this.orders) {
      WZArray.bless(this.orders);
    } else {
      this.orders = WZArray.bless([]);
    }
    if (this.reserves) {
      WZArray.bless(this.reserves);
    } else {
      this.reserves = WZArray.bless([]);
    }
  }

  Group.prototype.add = function(droid) {
    if (this.reserve.contains(droid)) {
      this.reserve.removeObject(droid);
      return this.group.push(droid);
    } else {
      throw "Can't add " + droid.namexy + " b/c it's not in reserve.";
    }
  };

  Group.prototype.remove = function(droid) {
    if (this.group.contains(droid)) {
      this.group.removeObject(droid);
      return this.reserve.push(droid);
    } else {
      throw "Can't remove " + droid.namexy + " b/c it's not in group.";
    }
  };

  Group.prototype.applying = function(droid) {
    var employ, name, order;
    name = droid.name;
    order = this.orders.current() || this.orders.first();
    employ = order.employ(name);
    if (!employ || this.group.counts_named(name) >= employ) return false;
    this.add(droid);
    return true;
  };

  Group.prototype.recruit = function(n, type, at) {
    var droid, i, recruits, _results;
    recruits = this.reserve;
    if (type) recruits = recruits.filters(type);
    if (at) recruits.nearest(at);
    i = 0;
    _results = [];
    while (i < n) {
      if (!recruits[0]) break;
      droid = recruits.shift();
      this.add(droid);
      _results.push(i++);
    }
    return _results;
  };

  Group.prototype.cut = function(n, type, at) {
    var cuts, droid, i, _results;
    cuts = this.group;
    if (type) cuts = cuts.filters(type);
    if (at) cuts.nearest(at);
    i = 0;
    _results = [];
    while (i < n) {
      droid = cuts.pop();
      if (!droid) break;
      this.remove(droid);
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

CyberBorg = (function() {
  /* CONSTANTS
  */
  CyberBorg.NORTH = 0;

  CyberBorg.EAST = 90;

  CyberBorg.SOUTH = 180;

  CyberBorg.WEST = 270;

  CyberBorg.ALL_PLAYERS = -1;

  /* CONSTRUCTOR
  */

  function CyberBorg(groups) {
    this.groups = groups != null ? groups : {};
  }

  CyberBorg.prototype.update = function() {
    var group, name, object, _results;
    _results = [];
    for (name in this.groups) {
      group = this.groups[name].group;
      _results.push((function() {
        var _i, _len, _results2;
        _results2 = [];
        for (_i = 0, _len = group.length; _i < _len; _i++) {
          object = group[_i];
          if (object.game_time < gameTime) {
            _results2.push(object.update());
          } else {
            _results2.push(void 0);
          }
        }
        return _results2;
      })());
    }
    return _results;
  };

  /* ENUMS
  */

  CyberBorg.enum_feature = function() {
    var array, params;
    params = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    array = enumFeature.apply(null, params).map(function(object) {
      return new WZObject(object);
    });
    return WZArray.bless(array);
  };

  CyberBorg.enum_droid = function() {
    var array, params;
    params = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    array = enumDroid.apply(null, params).map(function(object) {
      return new WZObject(object);
    });
    return WZArray.bless(array);
  };

  /* IS WUT???
  */

  CyberBorg.is_truck = function(droid) {
    return droid.droidType === DROID_CONSTRUCT;
  };

  CyberBorg.is_weapon = function(droid) {
    return droid.droidType === DROID_WEAPON;
  };

  CyberBorg.is_factory = function(structure) {
    return structure.stattype === FACTORY;
  };

  CyberBorg.is_idle = function(object) {
    var not_idle;
    if (object.type === STRUCTURE) return structureIdle(object);
    not_idle = [DORDER_BUILD, DORDER_HELPBUILD, DORDER_LINEBUILD, DORDER_DEMOLISH];
    return not_idle.indexOf(object.order) === WZArray.NONE;
  };

  CyberBorg.is_resource = function(object) {
    return [OIL_RESOURCE, RESOURCE_EXTRACTOR].indexOf(object.stattype) > WZArray.NONE;
  };

  CyberBorg.is_not_built = function(structure) {
    return structure.status !== BUILT;
  };

  /* METRICS
  */

  CyberBorg.distance_metric = function(a, b) {
    var x, y;
    x = a.x - b.x;
    y = a.y - b.y;
    return x * x + y * y;
  };

  CyberBorg.nearest_metric = function(a, b, at) {
    return CyberBorg.distance_metric(a, at) - CyberBorg.distance_metric(b, at);
  };

  /* GETS
  */

  CyberBorg.get_resources = function(at) {
    return CyberBorg.enum_feature(this.ALL_PLAYERS, "OilResource").nearest(at);
  };

  CyberBorg.get_my_trucks = function(at) {
    return CyberBorg.enum_droid(me, DROID_CONSTRUCT);
  };

  return CyberBorg;

})();

CyberBorg.prototype.base_orders = function() {
  var command_center, data, light_factory, order, orders, p, p111, p333, phase1, phase2, power_generator, research_facility, _i, _j, _len, _len2;
  light_factory = "A0LightFactory";
  command_center = "A0CommandCentre";
  research_facility = "A0ResearchFacility";
  power_generator = "A0PowerGenerator";
  p = function(n, x, e) {
    return {
      min: n,
      max: x,
      employ: function(name) {
        return {
          'Truck': e
        }[name];
      }
    };
  };
  p333 = function() {
    return p(3, 3, 3);
  };
  p111 = function() {
    return p(1, 1, 1);
  };
  order = function(str, x, y, p) {
    p.structure = str;
    p.at = {
      x: x,
      y: y
    };
    return p;
  };
  phase1 = [[light_factory, 9, 234], [research_facility, 6, 234], [command_center, 6, 237], [power_generator, 3, 234]];
  for (_i = 0, _len = phase1.length; _i < _len; _i++) {
    data = phase1[_i];
    data.push(p333());
  }
  phase2 = [[research_facility, 3, 237], [power_generator, 3, 240], [research_facility, 6, 240], [power_generator, 9, 240], [research_facility, 12, 240], [power_generator, 12, 243], [research_facility, 9, 243], [power_generator, 6, 243]];
  for (_j = 0, _len2 = phase2.length; _j < _len2; _j++) {
    data = phase2[_j];
    data.push(p111());
  }
  orders = phase1.concat(phase2);
  orders = orders.map(function(data) {
    return order.apply(null, data);
  });
  return WZArray.bless(orders);
};

CyberBorg.prototype.factory_orders = function() {
  var mg1, orders, truck, whb1;
  whb1 = function(droid) {
    droid.body = "Body1REC";
    droid.propulsion = "wheeled01";
    return droid;
  };
  truck = {
    name: "Truck",
    turret: "Spade1Mk1",
    droid_type: DROID_CONSTRUCT
  };
  mg1 = {
    name: "MgWhB1",
    turret: "MG1Mk1",
    droid_type: DROID_WEAPON
  };
  orders = [];
  2..times(function() {
    return orders.push(whb1(truck));
  });
  12..times(function() {
    return orders.push(whb1(mg1));
  });
  return WZArray.bless(orders);
};

CyberBorg.prototype.research_orders = function() {
  return ['R-Wpn-MG1Mk1', 'R-Struc-PowerModuleMk1', 'R-Defense-Tower01', 'R-Wpn-MG3Mk1', 'R-Struc-RepairFacility', 'R-Defense-WallTower02', 'R-Defense-AASite-QuadMg1', 'R-Vehicle-Body04', 'R-Struc-VTOLFactory', 'R-Vehicle-Prop-VTOL', 'R-Wpn-Bomb01'];
};

CyberBorg.prototype.derricks_trucks_orders = function(derricks) {
  var derrick, extractor, order, orders, p, p11, _i, _len;
  extractor = "A0ResourceExtractor";
  p = function(n, x, et) {
    return {
      min: n,
      max: x,
      order: DORDER_BUILD,
      employ: function(name) {
        return {
          'Truck': et
        }[name];
      }
    };
  };
  p11 = function() {
    return p(1, 1, 3);
  };
  order = function(str, x, y, p) {
    p.structure = str;
    p.at = {
      x: x,
      y: y
    };
    return p;
  };
  orders = [];
  for (_i = 0, _len = derricks.length; _i < _len; _i++) {
    derrick = derricks[_i];
    orders.push(order(extractor, derrick.x, derrick.y, p11()));
  }
  return WZArray.bless(orders);
};

CyberBorg.prototype.derricks_weapons_orders = function(derricks) {
  var derrick, extractor, order, orders, p, p11, _i, _len;
  extractor = "A0ResourceExtractor";
  p = function(n, x, em) {
    return {
      min: n,
      max: x,
      order: DORDER_SCOUT,
      employ: function(name) {
        return {
          'MgWhB1': em
        }[name];
      }
    };
  };
  p11 = function() {
    return p(1, 1, 9);
  };
  order = function(str, x, y, p) {
    p.structure = str;
    p.at = {
      x: x,
      y: y
    };
    return p;
  };
  orders = [];
  for (_i = 0, _len = derricks.length; _i < _len; _i++) {
    derrick = derricks[_i];
    orders.push(order(extractor, derrick.x, derrick.y, p11()));
  }
  WZArray.bless(orders);
  orders._current = 4;
  orders._current_min = 4;
  orders._current_max = 8;
  orders.next = function() {
    orders._current -= 1;
    orders._current = orders._current_max;
    if (orders._current < orders._current_min) {
      orders._current_max += 1;
      orders._current_min += 1;
      orders._current += orders._current_max;
    }
    return orders[orders._current];
  };
  return orders;
};

cyberBorg = new CyberBorg();

eventStartLevel = function() {
  var derricks, groups, reserve;
  console("This is player_assist.js");
  reserve = new Group();
  console("We have " + reserve.group.length + " droids available, and  " + (reserve.group.counts(CyberBorg.is_truck)) + " of them are trucks.");
  derricks = CyberBorg.get_resources(reserve.group.center());
  console("There are " + derricks.length + " resource points.");
  groups = cyberBorg.groups;
  groups.reserve = reserve;
  cyberBorg.derricks = derricks;
  groups.base = new Group([], cyberBorg.base_orders(), reserve.group);
  groups.derricks = new Group([], cyberBorg.derricks_trucks_orders(derricks), reserve.group);
  groups.factory = new Group([], cyberBorg.factory_orders());
  groups.research = new Group([], cyberBorg.research_orders());
  return base_group();
};

base_group = function() {
  var base, builders, count, groups, order;
  groups = cyberBorg.groups;
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
  cyberBorg.update();
  structure = new WZObject(structure);
  droid = new WZObject(droid);
  groups = cyberBorg.groups;
  console("" + (structure.namexy()) + " Built!");
  if (groups.base.group.contains(droid)) base_group();
  if (structure.type === STRUCTURE) {
    switch (structure.stattype) {
      case FACTORY:
        groups.factory.group.push(structure);
        return factory_group();
      case RESEARCH_LAB:
        return research_group(structure);
      case HQ:
        return min_map_and_design_on(structure);
    }
  }
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
  groups = cyberBorg.groups;
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
  cyberBorg.update();
  droid = new WZObject(droid);
  structure = new WZObject(structure);
  groups = cyberBorg.groups;
  console("Built " + droid.name + ".");
  groups.reserve.group.push(droid);
  if (groups.factory.group.contains(structure)) return factory_group();
};

eventChat = function(sender, to, message) {
  cyberBorg.update();
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
  var droid, droids, groups, _i, _j, _len, _len2, _ref, _ref2;
  groups = cyberBorg.groups;
  droids = [];
  switch (who) {
    case 'base':
      _ref = groups.base.group;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        droid = _ref[_i];
        droids.push(droid.namexy());
      }
      break;
    case 'reserve':
      _ref2 = groups.reserve.group;
      for (_j = 0, _len2 = _ref2.length; _j < _len2; _j++) {
        droid = _ref2[_j];
        droids.push(droid.namexy());
      }
      break;
    default:
      console("What???");
  }
  if (droids.length) return console("" + (droids.join(', ')) + ".");
};

research_group = function(structure, completed) {
  var order, orders;
  structure = new WZObject(structure);
  orders = cyberBorg.groups.research.orders;
  order = orders.of(structure) || orders.next(structure);
  if (completed) {
    console("" + (structure.namexy()) + " pursuing " + order + " got done with " + completed.name + ".");
    if (order === completed.name) order = orders.next(structure);
  }
  if (order) {
    console("" + (structure.namexy()) + " is doing " + order + ".");
    return pursueResearch(structure, order);
  } else {
    return console('Research orders complete?');
  }
};

eventResearched = function(completed, structure) {
  if (structure) return research_group(structure, completed);
};

eventDroidIdle = function(droid) {
  var groups;
  droid = new WZObject(droid);
  groups = cyberBorg.groups;
  if (groups.reserve.group.contains(droid)) {
    console("Idle droid applies...");
    groups.base.applying(droid) || groups.derricks.applying(droid);
  }
  if (groups.derricks.group.contains(droid)) {
    console("Derricks droid reporting for duty!");
    return derricks_group(droid);
  }
};

derricks_group = function(droid) {
  if (droid.is_truck()) {
    console("Droid to build derick.");
    return true;
  }
  if (droid.is_weapon()) {
    console("Droid to defend derick.");
    return true;
  }
  return false;
};
