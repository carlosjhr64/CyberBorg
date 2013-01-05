var CyberBorg, Group, WZArray, WZObject, cyberBorg, eventChat, eventDroidBuilt, eventDroidIdle, eventResearched, eventStartLevel, eventStructureBuilt, group_executions, min_map_and_design_on, report,
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

  WZObject.prototype.executes = function(order) {
    var at, number;
    number = order.number;
    at = order.at;
    switch (number) {
      case DORDER_ATTACK:
        return debug("TODO: need to implement number " + number + ".");
      case DORDER_BUILD:
        return orderDroidBuild(this, DORDER_BUILD, order.structure, at.x, at.y, order.direction);
      case DORDER_DEMOLISH:
        return debug("TODO: need to implement number " + number + ".");
      case DORDER_DISEMBARK:
        return debug("TODO: need to implement number " + number + ".");
      case DORDER_EMBARK:
        return debug("TODO: need to implement number " + number + ".");
      case DORDER_FIRESUPPORT:
        return debug("TODO: need to implement number " + number + ".");
      case DORDER_HELPBUILD:
        return debug("TODO: need to implement number " + number + ".");
      case DORDER_HOLD:
        return debug("TODO: need to implement number " + number + ".");
      case DORDER_LINEBUILD:
        return debug("TODO: need to implement number " + number + ".");
      case DORDER_MOVE:
      case DORDER_SCOUT:
        return orderDroidLoc(this, number, at.x, at.y);
      case DORDER_OBSERVE:
        return debug("TODO: need to implement number " + number + ".");
      case DORDER_PATROL:
        return debug("TODO: need to implement number " + number + ".");
      case DORDER_REARM:
        return debug("TODO: need to implement number " + number + ".");
      case DORDER_RECOVER:
        return debug("TODO: need to implement number " + number + ".");
      case DORDER_REPAIR:
        return debug("TODO: need to implement number " + number + ".");
      case DORDER_RETREAT:
        return debug("TODO: need to implement number " + number + ".");
      case DORDER_RTB:
        return debug("TODO: need to implement number " + number + ".");
      case DORDER_RTR:
        return debug("TODO: need to implement number " + number + ".");
      case DORDER_STOP:
        return debug("TODO: need to implement number " + number + ".");
      default:
        return debug("DEBUG: Order number " + number + " not listed.");
    }
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

  WZArray.prototype.like = function(rgx) {
    return this.filters(function(object) {
      return rgx.test(object.name);
    });
  };

  /* EDITS
  */

  WZArray.prototype.cap = function(n) {
    return WZArray.bless(this.slice(0, (n - 1) + 1 || 9e9));
  };

  WZArray.prototype.add = function(arr) {
    return WZArray.bless(this.concat(arr));
  };

  /* SORTS
  */

  WZArray.prototype.nearest = function(at) {
    return this.sort(function(a, b) {
      return CyberBorg.nearest_metric(a, b, at);
    });
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

  WZArray.prototype.revert = function(gameobj) {
    if (this._current > WZArray.INIT) return this._current -= 1;
  };

  WZArray.prototype.named = function(name) {
    var i;
    i = 0;
    while (i < this.length) {
      if (this[i].name === name) return this[i];
      i++;
    }
    return null;
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

  function Group(name, rank, group, orders, reserve) {
    this.name = name;
    this.rank = rank;
    this.group = group;
    this.orders = orders;
    this.reserve = reserve;
    if (this.group) {
      WZArray.bless(this.group);
    } else {
      this.group = CyberBorg.enum_droid();
    }
    this.list = this.group;
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
      throw new Error("Can't add " + droid.namexy + " b/c it's not in reserve.");
    }
  };

  Group.prototype.remove = function(droid) {
    if (this.group.contains(droid)) {
      this.group.removeObject(droid);
      return this.reserve.push(droid);
    } else {
      throw new Error("Can't remove " + droid.namexy + " b/c it's not in group.");
    }
  };

  /*
  
    # We have a droid applying for base group.
    # Returns true if droid gets employed.
    # This allows a chain of employment applications.
    applying: (droid) ->
      # See if we're employing
      name = droid.name
      # Group may be just about to start
      order = @orders.current() or @orders.first()
      employ = order.employ(name)
      return false if not employ or @group.counts_named(name) >= employ
      # OK, you're in!
      # TODO should help right away
      @add(droid)
      true
  
    recruit: (n, type, at) ->
      recruits = @reserve
      # NOTE: recruits won't be this.reserve if filtered!
      recruits = recruits.filters(type)  if type
      recruits.nearest at  if at
      i = 0
      while i < n
        break  unless recruits[0]
        droid = recruits.shift()
        @add(droid)
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
        @remove(droid)
        i++
  
    buildDroid: (order) ->
      factories = @group.factories().idle()
      i = 0
      while i < factories.length
        # Want factory.build(...)
        return (factories[i])  if buildDroid(factories[i], order.name, order.body, order.propulsion, "", order.droid_type, order.turret)
        i++
      null
  
    build: (order) -> #PREDICATE!  TODO this method goes away!
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
          pos = at
          #if structure != "A0ResourceExtractor"
          #  # TODO DEBUG why is pickStructLocation not giving me "at" back?
          #  # when I can actually build at "at"???
          #  pos = pickStructLocation(trucks[0], structure, at.x, at.y)
          if pos
            debug("#{structure}: at is #{at.x},#{at.y} but pos is #{pos.x},#{pos.y}")
            i = 0
            while i < trucks.length
              truck = trucks[i]
              if truck.execute(order)
                # TODO this should be better abstracted, use order.order
                truck.order = DORDER_BUILD
                builders.push(truck)
              i++
      builders
  */

  Group.prototype.units = function(order) {
    var count, max, reserve, unit, units, _i, _len;
    units = this.group.idle();
    if (order.like) units = units.like(order.like);
    if (this.group.length < order.limit) {
      if (order.recruit && units.length < order.recruit) {
        reserve = this.reserve;
        if (order.like) reserve = reserve.like(order.like);
        units = units.add(reserve);
      }
      if (order.constript && units.length < order.conscript) {
        debug("Order conscript not implemented");
      }
    }
    if (units.length < order.min) return null;
    if (order.at) units.nearest(order.at);
    max = order.max;
    count = 0;
    for (_i = 0, _len = units.length; _i < _len; _i++) {
      unit = units[_i];
      count += 1;
      if (count <= max) {
        if (!this.group.contains(unit)) this.add(unit);
      } else {
        if (count > order.cut) if (this.group.contains(unit)) this.remove(unit);
      }
    }
    if (units.length > max) units = units.cap(max);
    return units;
  };

  Group.prototype.execute = function(order, units) {
    var executers, unit, _i, _len;
    if (units == null) units = this.units(order);
    executers = [];
    if (units) {
      for (_i = 0, _len = units.length; _i < _len; _i++) {
        unit = units[_i];
        if (unit.executes(order)) {
          unit.order = order.number;
          executers.push(unit);
        }
      }
    }
    return executers;
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
    this.groups = groups != null ? groups : WZArray.bless([]);
  }

  CyberBorg.prototype.update = function() {
    var group, list, object, _i, _len, _ref, _results;
    _ref = this.groups;
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      group = _ref[_i];
      list = group.list;
      _results.push((function() {
        var _j, _len2, _results2;
        _results2 = [];
        for (_j = 0, _len2 = list.length; _j < _len2; _j++) {
          object = list[_j];
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
  var command_center, dorder_build, light_factory, orders, phase1, phase2, power_generator, research_facility, with_one_truck, with_three_trucks;
  light_factory = "A0LightFactory";
  command_center = "A0CommandCentre";
  research_facility = "A0ResearchFacility";
  power_generator = "A0PowerGenerator";
  dorder_build = function(arr) {
    var order;
    order = {
      "function": 'orderDroidBuild',
      number: DORDER_BUILD,
      structure: arr[0],
      at: {
        x: arr[1],
        y: arr[2]
      }
    };
    return order;
  };
  with_three_trucks = function(obj) {
    obj.like = /Truck/;
    obj.limit = 3;
    obj.min = 1;
    obj.max = 3;
    obj.recruit = 3;
    obj.conscript = 1;
    obj.cut = 3;
    obj.employ = function(name) {
      return {
        Truck: 0
      }[name];
    };
    return obj;
  };
  with_one_truck = function(obj) {
    obj.min = 1;
    obj.max = 1;
    obj.recruit = 1;
    obj.cut = 1;
    obj.employ = function(name) {
      return {
        Truck: 0
      }[name];
    };
    return obj;
  };
  phase1 = [with_three_trucks(dorder_build([light_factory, 10, 235])), with_three_trucks(dorder_build([research_facility, 7, 235])), with_three_trucks(dorder_build([command_center, 7, 238])), with_three_trucks(dorder_build([power_generator, 4, 235]))];
  phase2 = [with_one_truck(dorder_build([research_facility, 4, 238])), with_one_truck(dorder_build([power_generator, 4, 241])), with_one_truck(dorder_build([research_facility, 7, 241])), with_one_truck(dorder_build([power_generator, 10, 241])), with_one_truck(dorder_build([research_facility, 13, 241])), with_one_truck(dorder_build([power_generator, 13, 244])), with_one_truck(dorder_build([research_facility, 10, 244])), with_one_truck(dorder_build([power_generator, 7, 244]))];
  orders = phase1.concat(phase2);
  return WZArray.bless(orders);
};

CyberBorg.prototype.factory_orders = function() {
  var build, mg1, orders, truck, whb1;
  build = function(object) {
    object["function"] = "buildDroid";
    return object;
  };
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
    return orders.push(build(whb1(truck)));
  });
  12..times(function() {
    return orders.push(build(whb1(mg1)));
  });
  return WZArray.bless(orders);
};

CyberBorg.prototype.lab_orders = function() {
  return ['R-Wpn-MG1Mk1', 'R-Struc-PowerModuleMk1', 'R-Defense-Tower01', 'R-Wpn-MG3Mk1', 'R-Struc-RepairFacility', 'R-Defense-WallTower02', 'R-Defense-AASite-QuadMg1', 'R-Vehicle-Body04', 'R-Struc-VTOLFactory', 'R-Vehicle-Prop-VTOL', 'R-Wpn-Bomb01'].map(function(name) {
    return {
      name: name,
      research: name
    };
  });
};

CyberBorg.prototype.derricks_orders = function(derricks) {
  var derrick, extractor, order, orders, p, p11, _i, _len;
  extractor = "A0ResourceExtractor";
  p = function(n, x, et) {
    return {
      "function": 'orderDroidBuild',
      min: n,
      max: x,
      number: DORDER_BUILD,
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

CyberBorg.prototype.scouts_orders = function(derricks) {
  var derrick, extractor, order, orders, p, p11, _i, _len;
  extractor = "A0ResourceExtractor";
  p = function(n, x, em) {
    return {
      min: n,
      max: x,
      number: DORDER_SCOUT,
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
  return orders;
};

cyberBorg = new CyberBorg();

eventStartLevel = function() {
  var base, derricks, factories, groups, labs, reserve, resources, scouts;
  console("This is player_assist.js");
  reserve = new Group('Reserve', 0);
  console("We have " + reserve.group.length + " droids available, and  " + (reserve.group.counts(CyberBorg.is_truck)) + " of them are trucks.");
  resources = CyberBorg.get_resources(reserve.group.center());
  console("There are " + resources.length + " resource points.");
  groups = cyberBorg.groups;
  groups.push(reserve);
  base = new Group('Base', 100, [], cyberBorg.base_orders(), reserve.group);
  groups.push(base);
  derricks = new Group('Derricks', 90, [], cyberBorg.derricks_orders(resources), reserve.group);
  groups.push(derricks);
  scouts = new Group('Scouts', 80, [], cyberBorg.scouts_orders(resources), reserve.group);
  groups.push(scouts);
  factories = new Group('Factories', 20, [], cyberBorg.factory_orders());
  groups.push(factories);
  labs = new Group('Labs', 19, [], cyberBorg.lab_orders());
  groups.push(labs);
  groups.sort(function(a, b) {
    return b.rank - a.rank;
  });
  return group_executions();
};

eventStructureBuilt = function(structure, droid) {
  var groups;
  cyberBorg.update();
  structure = new WZObject(structure);
  droid = new WZObject(droid);
  groups = cyberBorg.groups;
  console("" + (structure.namexy()) + " Built!");
  if (structure.type === STRUCTURE) {
    switch (structure.stattype) {
      case FACTORY:
        groups.named('Factories').group.push(structure);
        break;
      case RESEARCH_LAB:
        groups.named('Labs').group.push(structure);
        break;
      case HQ:
        min_map_and_design_on(structure);
    }
  }
  return group_executions({
    event: 'StructureBuilt',
    structure: structure,
    droid: droid
  });
};

min_map_and_design_on = function(structure) {
  debug("min_map_and_design_on");
  return null;
  structure = new WZObject(structure);
  if (structure.player === selectedPlayer && structure.type === STRUCTURE && structure.stattype === HQ) {
    setMiniMap(true);
    return setDesign(true);
  }
};

eventDroidBuilt = function(droid, structure) {
  var groups;
  debug("in eventDroidBuilt");
  return null;
  cyberBorg.update();
  droid = new WZObject(droid);
  structure = new WZObject(structure);
  groups = cyberBorg.groups;
  console("Built " + droid.name + ".");
  groups.named('Reseve').group.push(droid);
  return group_executions({
    event: 'DroidBuilt',
    structure: structure,
    droid: droid
  });
};

eventChat = function(sender, to, message) {
  debug("in eventChat");
  return null;
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
  debug("in report");
  return null;
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

eventResearched = function(completed, structure) {
  debug("in eventResearched");
  return null;
  structure = new WZObject(structure);
  return group_executions({
    event: 'Researched',
    structure: structure,
    research: completed
  });
};

eventDroidIdle = function(droid) {
  var groups;
  debug("in eventDroidIdle");
  return null;
  droid = new WZObject(droid);
  groups = cyberBorg.groups;
  return group_executions({
    event: 'DroidIdle',
    droid: droid
  });
};

group_executions = function(event) {
  var count, executers, group, groups, name, order, orders, _i, _len, _results;
  groups = cyberBorg.groups;
  _results = [];
  for (_i = 0, _len = groups.length; _i < _len; _i++) {
    group = groups[_i];
    name = group.name;
    orders = group.orders;
    order = orders.next();
    debug("" + name + " has " + orders.length + " orders");
    debug(order);
    if (name !== 'Base') continue;
    if (order) {
      while (order) {
        debug("" + name + " " + order["function"]);
        executers = group.execute(order);
        count = executers.length;
        if (count === 0) {
          orders.revert();
          console("Group " + name + " has pending orders.");
          break;
        }
        console("There are " + count + " " + name + " units working on " + order["function"] + ".");
        order = orders.next();
      }
      if (!order) {
        _results.push(console("Group " + name + " orders complete!"));
      } else {
        _results.push(void 0);
      }
    } else {
      _results.push(void 0);
    }
  }
  return _results;
};
