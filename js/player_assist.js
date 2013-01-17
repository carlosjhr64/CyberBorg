var CyberBorg, DORDER_MAINTAIN, FORDER_MANUFACTURE, Group, LORDER_RESEARCH, Scouter, WZArray, WZObject, eventChat, eventDestroyed, eventDroidBuilt, eventDroidIdle, eventResearched, eventStartLevel, eventStructureBuilt, trace,
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

Number.prototype.order_map = function() {
  return CyberBorg.ORDER_MAP[this];
};

trace = function(message) {
  if (CyberBorg.TRACE) return debug(message);
};

WZObject = (function() {

  function WZObject(object) {
    this.copy(object);
    this.is_wzobject = true;
  }

  WZObject.prototype.copy = function(object) {
    var key, _results;
    this.game_time = gameTime;
    this.corder = CyberBorg.IS_IDLE;
    this.dorder = CyberBorg.IS_IDLE;
    _results = [];
    for (key in object) {
      _results.push(this[key] = object[key]);
    }
    return _results;
  };

  WZObject.prototype.update = function() {
    var obj, order;
    obj = objFromId(this);
    this.x = obj.x;
    this.y = obj.y;
    this.selected = obj.selected;
    this.health = obj.health;
    order = obj.order;
    if (order != null) return this.order = order;
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

  WZObject.prototype.move_to = function(at, order) {
    if (order == null) order = DORDER_MOVE;
    if (droidCanReach(this, at.x, at.y)) {
      orderDroidLoc(this, order, at.x, at.y);
      this.order = order;
      return true;
    }
    return false;
  };

  WZObject.prototype.repair_structure = function(built) {
    if (built.health < 99) {
      if (orderDroidObj(this, DORDER_REPAIR, built)) {
        this.order = DORDER_REPAIR;
        return true;
      } else {
        return false;
      }
    }
    return this.move_to(built);
  };

  WZObject.prototype.build_structure = function(structure, at) {
    if (orderDroidBuild(this, DORDER_BUILD, structure, at.x, at.y, at.direction)) {
      this.order = DORDER_BUILD;
      return true;
    }
    return false;
  };

  WZObject.prototype.maintain_structure = function(structure, at) {
    var built;
    if (built = cyberBorg.structure_at(at)) return this.repair_structure(built);
    return this.build_structure(structure, at);
  };

  WZObject.prototype.pursue_research = function(research) {
    if (pursueResearch(this, research)) {
      this.researching = research;
      this.order = LORDER_RESEARCH;
      return true;
    }
    return false;
  };

  WZObject.prototype.build_droid = function(command) {
    if (buildDroid(this, command.name, command.body, command.propulsion, "", command.droid_type, command.turret)) {
      this.order = FORDER_MANUFACTURE;
      return true;
    }
    return false;
  };

  WZObject.prototype.executes = function(command) {
    var at, ok, order;
    order = command.order;
    at = command.at;
    ok = (function() {
      switch (order) {
        case DORDER_MAINTAIN:
          return this.maintain_structure(command.structure, at);
        case FORDER_MANUFACTURE:
          return this.build_droid(command);
        case LORDER_RESEARCH:
          return this.pursue_research(command.research);
        case DORDER_BUILD:
          return this.build_structure(command.structure, at);
        case DORDER_MOVE:
        case DORDER_SCOUT:
          return this.move_to(at, order);
        default:
          trace("" + (order.order_map()) + ", #" + order + ", un-implemented.");
          return false;
      }
    }).call(this);
    if (ok) {
      this.corder = command.order;
      this.dorder = this.order;
      this.command_time = gameTime;
    }
    return ok;
  };

  return WZObject;

})();

/* ***Array***
*/

Array.prototype.first = function() {
  return this[0];
};

Array.prototype.last = function() {
  return this[this.length - 1];
};

Array.prototype.shuffle = function() {
  return this.sort(function() {
    return 0.5 - Math.random();
  });
};

/* ***WZArray***
*/

WZArray = (function() {

  function WZArray() {}

  WZArray.INIT = -1;

  WZArray.NONE = -1;

  WZArray.bless = function(array) {
    var method, name, _ref;
    if (array.is_wzarray) {
      trace("Warning: WZArray re'bless'ing");
      return array;
    }
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

  WZArray.prototype.in_cid = function(cid) {
    return this.filters(function(object) {
      var _ref;
      return ((_ref = object.command) != null ? _ref.cid : void 0) === cid;
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
    return this.counts(function(obj) {
      return obj.name === name;
    });
  };

  WZArray.prototype.counts_in_cid = function(cid) {
    return this.counts(function(obj) {
      var _ref;
      return ((_ref = obj.command) != null ? _ref.cid : void 0) === cid;
    });
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

  WZArray.prototype.collision = function(at) {
    var object, _i, _len;
    for (_i = 0, _len = this.length; _i < _len; _i++) {
      object = this[_i];
      if (object.x === at.x && object.y === at.y) return true;
    }
    return false;
  };

  /* ACCESSING
  */

  WZArray.prototype.named = function(name) {
    var object, _i, _len;
    for (_i = 0, _len = this.length; _i < _len; _i++) {
      object = this[_i];
      if (object.name === name) return object;
    }
    return null;
  };

  WZArray.prototype.get_command = function(cid) {
    var command, _i, _len;
    for (_i = 0, _len = this.length; _i < _len; _i++) {
      command = this[_i];
      if (command.cid === cid) return command;
    }
    return null;
  };

  /* CURSOR
  */

  WZArray.prototype._current = WZArray.INIT;

  WZArray.prototype.current = function() {
    return this[this._current];
  };

  WZArray.prototype._next = function() {
    if (this._current < this.length) this._current += 1;
    return this._current;
  };

  WZArray.prototype.next = function() {
    return this[this._next()];
  };

  WZArray.prototype._previous = function() {
    if (this._current > WZArray.INIT) this._current -= 1;
    return this._current;
  };

  WZArray.prototype.revert = function() {
    return this._previous();
  };

  WZArray.prototype.previous = function() {
    return this[this._previous()];
  };

  return WZArray;

})();

/* ***Scouter***
*/

Scouter = (function() {

  function Scouter() {}

  Scouter.bless = function(array) {
    var method, name, _ref;
    if (array.is_scouter) {
      trace("Warning: Scouter re'bless'ing");
      return array;
    }
    _ref = Scouter.prototype;
    for (name in _ref) {
      method = _ref[name];
      array[name] = method;
    }
    array.offset = 0;
    array.mod = this.length;
    array.index = WZArray.INIT;
    array.is_scouter = true;
    return array;
  };

  Scouter.prototype._set_current = function() {
    return this._current = this.offset + (this.index % this.mod);
  };

  Scouter.prototype._next = function() {
    this.index += 1;
    return this._set_current();
  };

  Scouter.prototype._previous = function() {
    if (this.index > -1) {
      this.index -= 1;
      return this._set_current();
    } else {
      return this._current = -1;
    }
  };

  return Scouter;

})();

Group = (function() {

  function Group(name, rank, group, commands, reserve) {
    var list, _i, _len, _ref;
    this.name = name;
    this.rank = rank;
    this.group = group != null ? group : [];
    this.commands = commands != null ? commands : [];
    this.reserve = reserve != null ? reserve : [];
    _ref = [this.group, this.commands, this.reserve];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      list = _ref[_i];
      if (!list.is_wzarray) WZArray.bless(list);
    }
    this.list = this.group;
  }

  Group.prototype.add = function(droid) {
    if (this.reserve.contains(droid)) {
      this.reserve.removeObject(droid);
      return this.group.push(droid);
    } else {
      throw new Error("Can't add " + (droid.namexy()) + " b/c it's not in reserve.");
    }
  };

  Group.prototype.remove = function(droid) {
    if (this.group.contains(droid)) {
      this.group.removeObject(droid);
      this.reserve.push(droid);
      return droid.order = CyberBorg.IS_IDLE;
    } else {
      throw new Error("Can't remove " + (droid.namexy()) + " b/c it's not in group.");
    }
  };

  Group.prototype.layoffs = function(command, reset) {
    var unit, _i, _len, _ref;
    if (reset == null) reset = null;
    if (!command.cid) throw new Error("Command without cid");
    _ref = this.group.in_cid(command.cid);
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      unit = _ref[_i];
      this.remove(unit);
      unit.command = reset;
    }
    return command.cid = reset;
  };

  Group.prototype.units = function(command) {
    var limit, max, min, size, units;
    min = command.min;
    limit = command.limit;
    size = this.group.length;
    if (size + min > limit) return null;
    units = this.reserve.like(command.like);
    if (units.length < min) return null;
    if (command.at) units.nearest(command.at);
    max = command.max;
    if (size + max > limit) max = limit - size;
    if (units.length > max) units = units.cap(max);
    return units;
  };

  Group.prototype.execute = function(command) {
    var cid, count, unit, units, _i, _len;
    count = 0;
    if (((command.power === 0) || (cyberBorg.power > command.power)) && (units = this.units(command))) {
      cid = CyberBorg.cid();
      for (_i = 0, _len = units.length; _i < _len; _i++) {
        unit = units[_i];
        if (unit.executes(command)) {
          unit.command = command;
          this.add(unit);
          count += 1;
        }
      }
      if (count) command.cid = cid;
    }
    cyberBorg.power -= command.cost;
    return count;
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

  CyberBorg.IS_IDLE = -1;

  CyberBorg.ORDER_MAP = ['DORDER_NONE', 'DORDER_STOP', 'DORDER_MOVE', 'DORDER_ATTACK', 'DORDER_BUILD', 'DORDER_HELPBUILD', 'DORDER_LINEBUILD', 'DORDER_DEMOLISH', 'DORDER_REPAIR', 'DORDER_OBSERVE', 'DORDER_FIRESUPPORT', 'DORDER_RETREAT', 'DORDER_DESTRUCT', 'DORDER_RTB', 'DORDER_RTR', 'DORDER_RUN', 'DORDER_EMBARK', 'DORDER_DISEMBARK', 'DORDER_ATTACKTARGET', 'DORDER_COMMANDERSUPPORT', 'DORDER_BUILDMODULE', 'DORDER_RECYCLE', 'DORDER_TRANSPORTOUT', 'DORDER_TRANSPORTIN', 'DORDER_TRANSPORTRETURN', 'DORDER_GUARD', 'DORDER_DROIDREPAIR', 'DORDER_RESTORE', 'DORDER_SCOUT', 'DORDER_RUNBURN', 'DORDER_UNUSED', 'DORDER_PATROL', 'DORDER_REARM', 'DORDER_RECOVER', 'DORDER_LEAVEMAP', 'DORDER_RTR_SPECIFIED', 'DORDER_CIRCLE', 'DORDER_HOLD', null, null, 'DORDER_CIRCLE', null, null, null, null, null, null, null, null, null, 'DORDER_MAINTAIN', 'FORDER_MANUFACTURE', 'LORDER_RESEARCH'];

  /* CLASS VARIABLES
  */

  CyberBorg.TRACE = true;

  CyberBorg.CID = 0;

  /* CONSTRUCTOR
  */

  function CyberBorg() {
    this.groups = WZArray.bless([]);
    this.power = 0;
    this.stalled = [];
    this.reserve = null;
  }

  /* UPDATES
  */

  CyberBorg.prototype.update = function() {
    var group, object, _i, _len, _ref, _results;
    this.power = playerPower();
    _ref = this.groups;
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      group = _ref[_i];
      _results.push((function() {
        var _j, _len2, _ref2, _results2;
        _ref2 = group.list;
        _results2 = [];
        for (_j = 0, _len2 = _ref2.length; _j < _len2; _j++) {
          object = _ref2[_j];
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

  /* GETS
  */

  CyberBorg.prototype.for_all = function(test_of) {
    var group, list, object, _i, _j, _k, _len, _len2, _len3, _ref, _ref2, _ref3;
    list = [];
    _ref = this.reserve;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      object = _ref[_i];
      if (test_of(object)) list.push(object);
    }
    _ref2 = this.groups;
    for (_j = 0, _len2 = _ref2.length; _j < _len2; _j++) {
      group = _ref2[_j];
      _ref3 = group.list;
      for (_k = 0, _len3 = _ref3.length; _k < _len3; _k++) {
        object = _ref3[_k];
        if (test_of(object)) list.push(object);
      }
    }
    return WZArray.bless(list);
  };

  CyberBorg.prototype.for_one = function(test_of) {
    var group, object, _i, _j, _k, _len, _len2, _len3, _ref, _ref2, _ref3;
    _ref = this.reserve;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      object = _ref[_i];
      if (test_of(object)) {
        return {
          object: object,
          group: group
        };
      }
    }
    _ref2 = this.groups;
    for (_j = 0, _len2 = _ref2.length; _j < _len2; _j++) {
      group = _ref2[_j];
      _ref3 = group.list;
      for (_k = 0, _len3 = _ref3.length; _k < _len3; _k++) {
        object = _ref3[_k];
        if (test_of(object)) {
          return {
            object: object,
            group: group
          };
        }
      }
    }
    return null;
  };

  CyberBorg.prototype.find = function(target) {
    var _ref;
    return (_ref = this.for_one(function(object) {
      return object.id === target.id;
    })) != null ? _ref.object : void 0;
  };

  CyberBorg.prototype.finds = function(target) {
    return this.for_one(function(object) {
      return object.id === target.id;
    });
  };

  CyberBorg.prototype.structure_at = function(at) {
    var found, _ref;
    found = function(object) {
      return object.x === at.x && object.y === at.y && object.type === STRUCTURE;
    };
    return (_ref = this.for_one(found)) != null ? _ref.object : void 0;
  };

  CyberBorg.prototype.get_command = function(cid) {
    var command, group, _i, _j, _len, _len2, _ref, _ref2;
    _ref = this.groups;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      group = _ref[_i];
      _ref2 = group.commands;
      for (_j = 0, _len2 = _ref2.length; _j < _len2; _j++) {
        command = _ref2[_j];
        if (command.cid === cid) return command;
      }
    }
    return null;
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
    if (object.type === STRUCTURE) {
      if (object.command_time === gameTime) {
        return false;
      } else {
        return structureIdle(object);
      }
    }
    not_idle = [DORDER_BUILD, DORDER_HELPBUILD, DORDER_LINEBUILD, DORDER_DEMOLISH, DORDER_REPAIR, DORDER_SCOUT, DORDER_MOVE];
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

  CyberBorg.get_free_spots = function(at, n) {
    var i, j, list, pos, positions, x, y;
    if (n == null) n = 1;
    x = at.x;
    y = at.y;
    list = WZArray.bless(enumArea(x - n, y - n, x + n, y + n, ALL_PLAYERS, false));
    positions = [];
    for (i = -n; -n <= n ? i <= n : i >= n; -n <= n ? i++ : i--) {
      for (j = -n; -n <= n ? j <= n : j >= n; -n <= n ? j++ : j--) {
        pos = {
          x: x + i,
          y: y + j
        };
        if (!list.collision(pos)) positions.push(pos);
      }
    }
    return positions;
  };

  CyberBorg.cid = function() {
    return CyberBorg.CID += 1;
  };

  return CyberBorg;

})();

DORDER_MAINTAIN = CyberBorg.ORDER_MAP.indexOf('DORDER_MAINTAIN');

FORDER_MANUFACTURE = CyberBorg.ORDER_MAP.indexOf('FORDER_MANUFACTURE');

LORDER_RESEARCH = CyberBorg.ORDER_MAP.indexOf('LORDER_RESEARCH');

CyberBorg.prototype.base_commands = function() {
  var build, builds, command_center, commands, costs, immediately, light_factory, on_budget, on_glut, one, power_generator, research_facility, savings, three, truck, trucks, two, with_help;
  light_factory = "A0LightFactory";
  command_center = "A0CommandCentre";
  research_facility = "A0ResearchFacility";
  power_generator = "A0PowerGenerator";
  savings = 500;
  costs = 100;
  build = function(arr) {
    var command, cost;
    cost = costs;
    if (savings > costs) {
      cost = savings;
      savings -= costs;
    }
    command = {
      order: DORDER_MAINTAIN,
      cost: cost,
      structure: arr[0],
      at: {
        x: arr[1],
        y: arr[2]
      },
      cid: null
    };
    return command;
  };
  builds = build;
  trucks = function(obj) {
    obj.like = /Truck/;
    return obj;
  };
  truck = trucks;
  three = function(obj) {
    obj.limit = 3;
    obj.min = 1;
    obj.max = 3;
    obj.help = 0;
    return obj;
  };
  two = function(obj) {
    obj.limit = 2;
    obj.min = 1;
    obj.max = 2;
    obj.help = 0;
    return obj;
  };
  one = function(obj) {
    obj.limit = 1;
    obj.min = 1;
    obj.max = 1;
    obj.help = 0;
    return obj;
  };
  with_help = function(obj) {
    obj.help = 3;
    return obj;
  };
  immediately = function(obj) {
    obj.power = 0;
    return obj;
  };
  on_budget = function(obj) {
    obj.power = costs;
    return obj;
  };
  on_glut = function(obj) {
    obj.power = 400;
    obj.cost = 0;
    return obj;
  };
  commands = [with_help(immediately(three(trucks(build([light_factory, 10, 235]))))), with_help(immediately(three(trucks(build([research_facility, 7, 235]))))), with_help(immediately(three(trucks(build([command_center, 7, 238]))))), immediately(two(truck(builds([power_generator, 4, 235])))), on_budget(one(truck(builds([power_generator, 4, 238])))), on_glut(one(truck(builds([research_facility, 4, 241])))), on_budget(one(truck(builds([power_generator, 7, 241])))), on_glut(one(truck(builds([research_facility, 10, 241])))), on_budget(one(truck(builds([power_generator, 13, 241])))), on_glut(one(truck(builds([research_facility, 13, 244])))), on_budget(one(truck(builds([power_generator, 10, 244])))), on_glut(one(truck(builds([research_facility, 7, 244]))))];
  return WZArray.bless(commands);
};

CyberBorg.prototype.factory_commands = function() {
  var build, commands, mg1, truck, turret, whb1;
  build = function(obj) {
    obj.order = FORDER_MANUFACTURE;
    obj.like = /Factory/;
    obj.power = 62;
    obj.cost = 62;
    obj.limit = 5;
    obj.min = 1;
    obj.max = 1;
    obj.help = 1;
    return obj;
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
  turret = ["MG3Mk1", "MG2Mk1", "MG1Mk1"];
  mg1 = {
    name: "MgWhB1",
    turret: turret,
    droid_type: DROID_WEAPON
  };
  commands = [];
  1..times(function() {
    return commands.push(build(whb1(truck)));
  });
  12..times(function() {
    return commands.push(build(whb1(mg1)));
  });
  1..times(function() {
    return commands.push(build(whb1(truck)));
  });
  return WZArray.bless(commands);
};

CyberBorg.prototype.lab_commands = function() {
  var pursue;
  pursue = function(research, cost) {
    var obj;
    obj = {
      research: research
    };
    obj.order = LORDER_RESEARCH;
    obj.like = /Research Facility/;
    obj.power = cost;
    obj.cost = cost;
    obj.limit = 5;
    obj.min = 1;
    obj.max = 1;
    obj.help = 1;
    return obj;
  };
  return [pursue('R-Wpn-MG1Mk1', 1), pursue('R-Wpn-MG2Mk1', 37), pursue('R-Struc-PowerModuleMk1', 37), pursue('R-Wpn-MG3Mk1', 75), pursue('R-Struc-RepairFacility', 75), pursue('R-Defense-Tower01', 18), pursue('R-Defense-WallTower02', 75), pursue('R-Defense-AASite-QuadMg1', 112), pursue('R-Vehicle-Body04', 75), pursue('R-Vehicle-Prop-VTOL', 100), pursue('R-Struc-VTOLFactory', 100), pursue('R-Wpn-Bomb01', 100)];
};

CyberBorg.prototype.derricks_commands = function(derricks) {
  var commands, extractor, truck, truck_build;
  extractor = "A0ResourceExtractor";
  truck = /Truck/;
  truck_build = function(derrick) {
    return {
      power: 0,
      cost: 100,
      like: truck,
      limit: 3,
      min: 1,
      max: 1,
      help: 1,
      order: DORDER_MAINTAIN,
      structure: extractor,
      at: {
        x: derrick.x,
        y: derrick.y
      }
    };
  };
  commands = WZArray.bless(derricks.map(function(derrick) {
    return truck_build(derrick);
  }));
  Scouter.bless(commands);
  commands.mod = 8;
  commands.offset = 0;
  return commands;
};

CyberBorg.prototype.scouts_commands = function(derricks) {
  var commands, scout;
  scout = function(derrick) {
    return {
      power: 0,
      cost: 0,
      like: /MgWh/,
      limit: 12,
      min: 1,
      max: 1,
      help: 1,
      order: DORDER_SCOUT,
      at: {
        x: derrick.x,
        y: derrick.y
      }
    };
  };
  commands = WZArray.bless(derricks.map(function(derrick) {
    return scout(derrick);
  }));
  Scouter.bless(commands);
  commands.mod = 5;
  commands.offset = 3;
  return commands;
};

/*
 Here I have here listed all of the events documented by
 the JS API as of 2013-01-09.  The ones not used are commented out.
 See:
   https://warzone.atlassian.net/wiki/display/jsapi/API
 Preliminary data wrapping into either WZArray or WZObject occurs here.
*/

/*
eventAttacked = (victim, attacker) ->
  obj =
    name: 'Attacked'
    victim: new WZObject(victim)
    attacker: new WZObject(attacker)
  events(obj)

eventAttackedUnthrottled = (victim, attacker) ->
  obj =
    name: 'Attacked'
    victim: new WZObject(victim)
    attacker: new WZObject(attacker)
  events(obj)

eventBeacon = (x, y, sender, to, message) ->
  obj =
    name: 'Beacon'
    at: x:x, y:y
    sender: sender
    to: to
    message: message
  events(obj)

eventBeaconRemoved = (sender, to) ->
  obj =
    name: 'BeaconReamoved'
    sender: sender
    to: to
  events(obj)
*/

eventChat = function(sender, to, message) {
  var obj;
  obj = {
    name: 'Chat',
    sender: sender,
    to: to,
    message: message
  };
  return events(obj);
};

/*

eventCheatMode = (entered) ->
  obj =
    name: 'CheatMode'
    entered: entered
  events(obj)
*/

eventDestroyed = function(object) {
  var found, group, obj;
  if (object.name !== 'Oil Resource') {
    group = null;
    if (object.player === me && (found = cyberBorg.finds(object))) {
      group = found.group;
      object = found.object;
      group.list.removeObject(object);
    } else {
      object = new WZObject(object);
    }
    obj = {
      name: 'Destroyed',
      object: object,
      group: group
    };
    return events(obj);
  }
};

eventDroidBuilt = function(droid, structure) {
  var found, obj;
  found = cyberBorg.finds(structure);
  obj = {
    name: 'DroidBuilt',
    droid: new WZObject(droid),
    structure: found.object,
    group: found.group
  };
  return events(obj);
};

eventDroidIdle = function(droid) {
  var found, obj;
  found = cyberBorg.finds(droid);
  obj = {
    name: 'DroidIdle',
    droid: found.object,
    group: found.group
  };
  return events(obj);
};

/*

eventGameInit = () ->
  obj = name: 'GameInit'
  events(obj)

eventGameLoaded = () ->
  obj = name: 'GameLoaded'
  events(obj)

eventGameSaved = () ->
  obj = name: 'GameSaved'
  events(obj)

eventGameSaving = () ->
  obj = name: 'GameSaving'
  events(obj)

eventGroupLoss = (object, group, size) ->
  obj =
    name: 'GroupLoss'
    object: new WZObject(object)
    group: group
    size: size
  events(obj)

eventLaunchTransporter = () ->
  obj = name: 'LaunchTransporter'
  events(obj)

eventMissionTimeout = () ->
  obj = name: 'MissionTimeout'
  events(obj)

eventObjectSeen = (sensor, object) ->
  obj =
    name: 'ObjectSeen'
    sensor: new WZObject(sensor)
    object: new WZObject(object)
  events(obj)

eventObjectTransfer = () ->
  obj = name: 'ObjectTransfer'
  events(obj)

eventPickup = () ->
  obj = name: 'Pickup'
  events(obj)

eventReinforcementsArrived = () ->
  obj = name: 'ReinforcementArrived'
  events(obj)
*/

eventResearched = function(research, structure) {
  var found, obj;
  found = cyberBorg.finds(structure);
  obj = {
    name: 'Researched',
    research: research,
    structure: found != null ? found.object : void 0,
    group: found != null ? found.group : void 0
  };
  return events(obj);
};

/*

eventSelectionChange = (selected) ->
  selected = selected.map( (object) -> new WZObject(object) )
  selected = WZArray.bless(selected)
  obj =
    name: 'SelectionChange'
    selected: selected
  events(obj)
*/

eventStartLevel = function() {
  var obj;
  obj = {
    name: 'StartLevel'
  };
  return events(obj);
};

eventStructureBuilt = function(structure, droid) {
  var found, obj;
  found = cyberBorg.finds(droid);
  obj = {
    name: 'StructureBuilt',
    structure: new WZObject(structure),
    droid: found.object,
    group: found.group
  };
  return events(obj);
};

/*

eventStructureReady = (structure) ->
  obj =
    name: 'StructureReady'
    structure: new WZObject(structure)
  events(obj)

eventVideoDone = () ->
  obj = name: 'VideoDone'
  events(obj)
*/
