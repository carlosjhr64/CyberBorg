var BASE, CyberBorg, DERRICKS, DORDER_MAINTAIN, FACTORIES, FORDER_MANUFACTURE, Group, LABS, LORDER_RESEARCH, RESERVE, SCOUTS, Scouter, WZArray, WZObject, bug_report, chat, cyberBorg, destroyed, droidBuilt, droidIdle, eventChat, eventDestroyed, eventDroidBuilt, eventDroidIdle, eventResearched, eventStartLevel, eventStructureBuilt, events, gotcha_idle, gotcha_rogue, gotcha_selected, gotcha_working, gotchas, group_executions, helping, min_map_and_design_on, report, researched, startLevel, structureBuilt, trace,
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
    _results = [];
    for (key in object) {
      _results.push(this[key] = object[key]);
    }
    return _results;
  };

  WZObject.prototype.update = function() {
    var obj, order_number;
    obj = objFromId(this);
    this.x = obj.x;
    this.y = obj.y;
    this.selected = obj.selected;
    this.health = obj.health;
    order_number = obj.order;
    if (order_number != null) return this.order = order_number;
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

  WZObject.prototype.move_to = function(at, number) {
    if (number == null) number = DORDER_MOVE;
    if (droidCanReach(this, at.x, at.y)) {
      orderDroidLoc(this, number, at.x, at.y);
      return true;
    }
    return false;
  };

  WZObject.prototype.repair_structure = function(built) {
    if (built.health < 99) return orderDroidObj(this, DORDER_REPAIR, built);
    return this.move_to(built);
  };

  WZObject.prototype.build_structure = function(structure, at) {
    return orderDroidBuild(this, DORDER_BUILD, structure, at.x, at.y, at.direction);
  };

  WZObject.prototype.maintain_structure = function(structure, at) {
    var built;
    if (built = cyberBorg.structure_at(at)) return this.repair_structure(built);
    return this.build_structure(structure, at);
  };

  WZObject.prototype.pursue_research = function(research) {
    if (pursueResearch(this, research)) {
      this.researching = research;
      return true;
    }
    return false;
  };

  WZObject.prototype.build_droid = function(command) {
    return buildDroid(this, command.name, command.body, command.propulsion, "", command.droid_type, command.turret);
  };

  WZObject.prototype.executes = function(command) {
    var at, number, ok;
    number = command.number;
    at = command.at;
    ok = (function() {
      switch (number) {
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
          return this.move_to(at, number);
        default:
          trace("" + (number.order_map()) + ", #" + number + ", un-implemented.");
          return false;
      }
    }).call(this);
    if (ok) {
      this.order = command.number;
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
      return object.cid === cid;
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
      return obj.cid === cid;
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
    this.name = name;
    this.rank = rank;
    this.group = group;
    this.commands = commands;
    this.reserve = reserve;
    if (!this.group) this.group = CyberBorg.enum_droid();
    if (!this.group.is_wzarray) WZArray.bless(this.group);
    this.list = this.group;
    if (!this.commands) this.commands = WZArray.bless([]);
    if (!this.commands.is_wzarray) WZArray.bless(this.commands);
    if (!this.reserve) this.reserve = WZArray.bless([]);
    if (!this.reserve.is_wzarray) WZArray.bless(this.reserve);
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

  Group.prototype.layoffs = function(cid, reset) {
    var command, unit, _i, _len, _ref;
    if (reset == null) reset = null;
    _ref = this.group.in_cid(cid);
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      unit = _ref[_i];
      this.remove(unit);
      unit.cid = reset;
    }
    if (command = this.commands.get_command(cid)) return command.cid = reset;
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
    if (cyberBorg.power > command.power && (units = this.units(command))) {
      cid = CyberBorg.cid();
      for (_i = 0, _len = units.length; _i < _len; _i++) {
        unit = units[_i];
        if (unit.executes(command)) {
          unit.cid = cid;
          this.add(unit);
          count += 1;
        }
      }
      if (count) {
        command.cid = cid;
        cyberBorg.power -= command.cost;
      }
    }
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
    var group, list, object, _i, _j, _len, _len2, _ref, _ref2;
    list = [];
    _ref = this.groups;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      group = _ref[_i];
      _ref2 = group.list;
      for (_j = 0, _len2 = _ref2.length; _j < _len2; _j++) {
        object = _ref2[_j];
        if (test_of(object)) list.push(object);
      }
    }
    return WZArray.bless(list);
  };

  CyberBorg.prototype.for_one = function(test_of) {
    var group, object, _i, _j, _len, _len2, _ref, _ref2;
    _ref = this.groups;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      group = _ref[_i];
      _ref2 = group.list;
      for (_j = 0, _len2 = _ref2.length; _j < _len2; _j++) {
        object = _ref2[_j];
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
  var command_center, commands, dorder_build, light_factory, phase1, phase2, power_generator, research_facility, with_one_truck, with_three_trucks;
  light_factory = "A0LightFactory";
  command_center = "A0CommandCentre";
  research_facility = "A0ResearchFacility";
  power_generator = "A0PowerGenerator";
  dorder_build = function(arr) {
    var command;
    command = {
      number: DORDER_BUILD,
      cost: 100,
      structure: arr[0],
      at: {
        x: arr[1],
        y: arr[2]
      },
      cid: null
    };
    return command;
  };
  with_three_trucks = function(obj) {
    obj.like = /Truck/;
    obj.power = 100;
    obj.limit = 3;
    obj.min = 1;
    obj.max = 3;
    obj.help = 3;
    return obj;
  };
  with_one_truck = function(obj) {
    obj.like = /Truck/;
    obj.power = 390;
    obj.limit = 1;
    obj.min = 1;
    obj.max = 1;
    obj.help = 1;
    return obj;
  };
  phase1 = [with_three_trucks(dorder_build([light_factory, 10, 235])), with_three_trucks(dorder_build([research_facility, 7, 235])), with_three_trucks(dorder_build([command_center, 7, 238])), with_three_trucks(dorder_build([power_generator, 4, 235]))];
  phase2 = [with_one_truck(dorder_build([power_generator, 4, 238])), with_one_truck(dorder_build([research_facility, 4, 241])), with_one_truck(dorder_build([power_generator, 7, 241])), with_one_truck(dorder_build([research_facility, 10, 241])), with_one_truck(dorder_build([power_generator, 13, 241])), with_one_truck(dorder_build([research_facility, 13, 244])), with_one_truck(dorder_build([power_generator, 10, 244])), with_one_truck(dorder_build([research_facility, 7, 244]))];
  commands = phase1.concat(phase2);
  return WZArray.bless(commands);
};

CyberBorg.prototype.factory_commands = function() {
  var build, commands, mg1, truck, turret, whb1;
  build = function(obj) {
    obj.number = FORDER_MANUFACTURE;
    obj.like = /Factory/;
    obj.power = 440;
    obj.cost = 50;
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
  return WZArray.bless(commands);
};

CyberBorg.prototype.lab_commands = function() {
  var pursue;
  pursue = function(research) {
    var obj;
    obj = {
      research: research
    };
    obj.number = LORDER_RESEARCH;
    obj.like = /Research Facility/;
    obj.power = 390;
    obj.cost = 100;
    obj.limit = 5;
    obj.min = 1;
    obj.max = 1;
    obj.help = 1;
    return obj;
  };
  return [pursue('R-Wpn-MG1Mk1'), pursue('R-Struc-PowerModuleMk1'), pursue('R-Defense-Tower01'), pursue('R-Wpn-MG3Mk1'), pursue('R-Struc-RepairFacility'), pursue('R-Defense-WallTower02'), pursue('R-Defense-AASite-QuadMg1'), pursue('R-Vehicle-Body04'), pursue('R-Vehicle-Prop-VTOL'), pursue('R-Struc-VTOLFactory'), pursue('R-Wpn-Bomb01')];
};

CyberBorg.prototype.derricks_commands = function(derricks) {
  var commands, extractor, truck, truck_build;
  extractor = "A0ResourceExtractor";
  truck = /Truck/;
  truck_build = function(derrick) {
    return {
      power: 0,
      cost: 0,
      like: truck,
      limit: 3,
      min: 1,
      max: 1,
      help: 1,
      number: DORDER_BUILD,
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
      number: DORDER_SCOUT,
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

bug_report = function(label, droid, event) {
  var at, cid, command, dorder, number, _ref;
  command = null;
  dorder = droid.order;
  trace("" + label + ":\t" + (droid.namexy()) + "\tid:" + droid.id + "\tevent:" + event.name);
  trace("\t\torder number:" + dorder + " => " + (dorder.order_map()));
  if (cid = droid.cid) {
    command = cyberBorg.get_command(cid);
    if (command) {
      number = command.number;
      trace("\t\t" + (number.order_map()) + "\t#" + number + "\tcid:" + cid);
      if (command.structure) trace("\t\tstructure:" + command.structure);
      if (at = command.at) trace("\t\tat:(" + at.x + "," + at.y + ")");
      if (dorder === 0) {
        trace("\t\tBUG: Quitter.");
      } else {
        if (dorder !== command.number) trace("\t\tBUG: Order changed.");
      }
    } else {
      trace("\t\tBUG: Order on cid " + cid + " does not exist.");
    }
  }
  if (event.name === "Destroyed") {
    trace("\t\t" + ((_ref = event.group) != null ? _ref.name : void 0) + "'s " + (event.object.namexy()) + " was destroyed.");
  }
  return command;
};

gotcha_working = function(droid, command) {
  var number;
  if (CyberBorg.TRACE) centreView(droid.x, droid.y);
  if (droid.executes(command)) {
    number = command.number;
    return trace("\tRe-issued " + (number.order_map()) + ", #" + number + ", to " + droid.name + ".");
  } else {
    return trace("\t" + droid.name + " is a lazy bum!");
  }
};

gotcha_selected = function(event) {
  var count, droid, _i, _len, _ref;
  count = 0;
  _ref = cyberBorg.for_all(function(object) {
    return object.selected;
  });
  for (_i = 0, _len = _ref.length; _i < _len; _i++) {
    droid = _ref[_i];
    count += 1;
    bug_report("Selected", droid, event);
  }
  return count;
};

gotcha_idle = function(event) {
  var command, count, droid, _i, _len, _ref;
  count = 0;
  _ref = cyberBorg.for_all(function(object) {
    return object.order === 0;
  });
  for (_i = 0, _len = _ref.length; _i < _len; _i++) {
    droid = _ref[_i];
    count += 1;
    command = bug_report("Idle", droid, event);
    if (command && event.name === "Destroyed" && event.object.name === "Oil Derrick" && droid.name === 'Truck' && command.structure === 'A0ResourceExtractor') {
      gotcha_working(droid, command);
    }
  }
  return count;
};

gotcha_rogue = function(event) {
  var command, count, droid, rogue, _i, _len, _ref;
  count = 0;
  rogue = function(object) {
    var cid, _ref;
    if (cid = object.cid) {
      if (object.order !== ((_ref = cyberBorg.get_command(cid)) != null ? _ref.number : void 0)) {
        return true;
      }
    }
    return false;
  };
  _ref = cyberBorg.for_all(function(object) {
    return rogue(object);
  });
  for (_i = 0, _len = _ref.length; _i < _len; _i++) {
    droid = _ref[_i];
    count += 1;
    command = bug_report("Rogue", droid, event);
    if ((command != null ? command.number : void 0) === 28) {
      if (CyberBorg.TRACE) centreView(droid.x, droid.y);
      gotcha_working(droid, command);
    }
  }
  return count;
};

gotchas = function(event) {
  var count, counts, gotcha, _i, _len, _ref;
  counts = count = 0;
  _ref = [gotcha_selected, gotcha_idle, gotcha_rogue];
  for (_i = 0, _len = _ref.length; _i < _len; _i++) {
    gotcha = _ref[_i];
    if (count = gotcha(event)) {
      counts += count;
      trace("");
    }
  }
  if (counts) return trace("");
};

cyberBorg = new CyberBorg();

BASE = 'Base';

RESERVE = 'Reserve';

DERRICKS = 'Derricks';

SCOUTS = 'Scouts';

FACTORIES = 'Factories';

LABS = 'Labs';

events = function(event) {
  cyberBorg.update();
  switch (event.name) {
    case 'StartLevel':
      startLevel();
      break;
    case 'StructureBuilt':
      structureBuilt(event.structure, event.droid, event.group);
      break;
    case 'DroidBuilt':
      droidBuilt(event.droid, event.structure, event.group);
      break;
    case 'DroidIdle':
      droidIdle(event.droid, event.group);
      break;
    case 'Researched':
      researched(event.research, event.structure, event.group);
      break;
    case 'Destroyed':
      destroyed(event.object, event.group);
      break;
    case 'Chat':
      chat(event.sender, event.to, event.message);
      break;
    default:
      trace("" + event.name + " NOT HANDLED!");
  }
  group_executions(event);
  return gotchas(event);
};

startLevel = function() {
  var base, derricks, factories, groups, labs, reserve, resources, scouts;
  reserve = new Group(RESERVE, 0);
  resources = CyberBorg.get_resources(reserve.group.center());
  groups = cyberBorg.groups;
  groups.push(reserve);
  base = new Group(BASE, 100, [], cyberBorg.base_commands(), reserve.group);
  groups.push(base);
  derricks = new Group(DERRICKS, 90, [], cyberBorg.derricks_commands(resources), reserve.group);
  groups.push(derricks);
  scouts = new Group(SCOUTS, 80, [], cyberBorg.scouts_commands(resources), reserve.group);
  groups.push(scouts);
  factories = new Group(FACTORIES, 20, [], cyberBorg.factory_commands(), reserve.group);
  groups.push(factories);
  labs = new Group(LABS, 19, [], cyberBorg.lab_commands(), reserve.group);
  groups.push(labs);
  return groups.sort(function(a, b) {
    return b.rank - a.rank;
  });
};

structureBuilt = function(structure, droid, group) {
  if (droid != null ? droid.cid : void 0) group.layoffs(droid.cid);
  cyberBorg.groups.named(RESERVE).group.push(structure);
  if (structure.type === STRUCTURE) {
    switch (structure.stattype) {
      case HQ:
        return min_map_and_design_on(structure);
    }
  }
};

min_map_and_design_on = function(structure) {
  if (structure.player === selectedPlayer && structure.type === STRUCTURE && structure.stattype === HQ) {
    setMiniMap(true);
    return setDesign(true);
  }
};

droidBuilt = function(droid, structure, group) {
  if (structure != null ? structure.cid : void 0) group.layoffs(structure.cid);
  cyberBorg.groups.named(RESERVE).group.push(droid);
  return helping(droid);
};

helping = function(object) {
  var cid, command, employed, group, help_wanted, _i, _len, _ref;
  _ref = cyberBorg.groups;
  for (_i = 0, _len = _ref.length; _i < _len; _i++) {
    group = _ref[_i];
    command = group.commands.current();
    cid = command != null ? command.cid : void 0;
    if (cid && (help_wanted = command.help) && command.like.test(object.name)) {
      employed = group.list.counts_in_cid(cid);
      if (employed < help_wanted && object.executes(command)) {
        object.cid = cid;
        group.add(object);
        return true;
      }
    }
  }
  return false;
};

chat = function(sender, to, message) {
  var words;
  words = message.split(/\s+/);
  if (sender === 0) {
    switch (words[0]) {
      case 'report':
        return report(words[1]);
      case 'reload':
        return include("multiplay/skirmish/reloads.js");
      case 'trace':
        if (CyberBorg.TRACE) trace("Tracing off.");
        CyberBorg.TRACE = !CyberBorg.TRACE;
        if (CyberBorg.TRACE) return trace("Tracing on.");
        break;
      default:
        return console("What?");
    }
  }
};

report = function(who) {
  var droid, droids, group, _i, _len, _ref;
  if (group = cyberBorg.groups.named(who)) {
    droids = [];
    _ref = group.list;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      droid = _ref[_i];
      droids.push(droid.namexy());
    }
    if (droids.length) {
      return console(droids.join());
    } else {
      return console("Group empty");
    }
  } else {
    return console("There is not group " + who);
  }
};

researched = function(completed, structure, group) {
  var cid, research;
  if (structure) {
    completed = completed.name;
    research = structure.researching;
    cid = structure.cid;
    if (research === completed) {
      return group.layoffs(cid);
    } else {
      return structure.executes(cyberBorg.get_command(cid));
    }
  }
};

droidIdle = function(droid, group) {
  if (droid.cid) group.layoffs(droid.cid);
  return helping(droid);
};

destroyed = function(object, group) {};

group_executions = function(event) {
  var command, commands, group, groups, name, _i, _len, _results;
  groups = cyberBorg.groups;
  _results = [];
  for (_i = 0, _len = groups.length; _i < _len; _i++) {
    group = groups[_i];
    name = group.name;
    if (!((name === FACTORIES) || (name === BASE) || (name === LABS) || (name === SCOUTS) || (name === DERRICKS))) {
      continue;
    }
    commands = group.commands;
    _results.push((function() {
      var _results2;
      _results2 = [];
      while (command = commands.next()) {
        if (!group.execute(command)) {
          commands.revert();
          break;
        } else {
          _results2.push(void 0);
        }
      }
      return _results2;
    })());
  }
  return _results;
};
