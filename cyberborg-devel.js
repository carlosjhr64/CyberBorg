var BASE, CORDER_PASS, CyberBorg, DERRICKS, DORDER_MAINTAIN, FACTORIES, FORDER_MANUFACTURE, Group, IS_LAIDOFF, LABS, LORDER_RESEARCH, RESERVE, SCOUTS, Scouter, WZArray, WZObject, blue_alert, bug_report, chat, cyberBorg, destroyed, droidBuilt, droidIdle, eventChat, eventDestroyed, eventDroidBuilt, eventDroidIdle, eventResearched, eventStartLevel, eventStructureBuilt, events, gotcha_idle, gotcha_rogue, gotcha_selected, gotcha_working, gotchas, green_alert, group_executions, helping, red_alert, report, researched, stalled_units, startLevel, start_trace, structureBuilt, trace,
  __slice = Array.prototype.slice;

trace = function(message) {
  if (cyberBorg.trace) return debug(message);
};

red_alert = function(message) {
  var previous_state;
  previous_state = cyberBorg.trace;
  if (cyberBorg.trace || (selectedPlayer === me)) {
    cyberBorg.trace = true;
    trace("\033[1;31m" + message + "\033[0m");
  }
  return cyberBorg.trace = previous_state;
};

green_alert = function(message) {
  if (cyberBorg.trace) return trace("\033[1;32m" + message + "\033[0m");
};

blue_alert = function(message) {
  if (cyberBorg.trace) return trace("\033[1;34m" + message + "\033[0m");
};

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

Number.prototype.to_i = function() {
  return parseInt(this.toFixed(0));
};

Number.prototype.order_map = function() {
  return CyberBorg.ORDER_MAP[this];
};

WZObject = (function() {

  function WZObject(object) {
    this.copy(object);
    this.is_wzobject = true;
  }

  WZObject.prototype.copy = function(object) {
    var key, _results;
    this.game_time = gameTime;
    this.corder = IS_LAIDOFF;
    this.dorder = IS_LAIDOFF;
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

  WZObject.prototype.pick_struct_location = function(structure, at) {
    var pos;
    if (structure === 'A0ResourceExtractor') return at;
    pos = cyberBorg.location(at);
    if (!pos) {
      pos = pickStructLocation(this, structure, at.x, at.y);
      if (pos) {
        cyberBorg.location(at, pos);
        if (!(pos.x === at.x && pos.y === at.y)) {
          red_alert(("Game AI moved build " + structure + " ") + ("from " + at.x + "," + at.y + " to " + pos.x + "," + pos.y));
        }
      }
    }
    return pos;
  };

  WZObject.prototype.build_structure = function(structure, at) {
    var pos;
    if (pos = this.pick_struct_location(structure, at)) {
      if (orderDroidBuild(this, DORDER_BUILD, structure, pos.x, pos.y, at.direction)) {
        this.order = DORDER_BUILD;
        return true;
      }
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
    if ((cyberBorg.hq || command.name === 'Truck') && buildDroid(this, command.name, command.body, command.propulsion, "", command.droid_type, command.turret)) {
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
        case CORDER_PASS:
          this.order = CORDER_PASS;
          return true;
        default:
          red_alert("" + (order.order_map()) + ", #" + order + ", un-implemented.");
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
      red_alert("Warning: WZArray re'bless'ing");
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
    var count, object, _i, _len;
    count = 0;
    for (_i = 0, _len = this.length; _i < _len; _i++) {
      object = this[_i];
      if (type(object)) count += 1;
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
      red_alert("Warning: Scouter re'bless'ing");
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
      return this.reserve.push(droid);
    } else {
      return red_alert("Can't remove " + droid.name + " b/c it's not in group.");
    }
  };

  Group.prototype.layoffs = function(command) {
    var unit, _i, _len, _ref;
    if (command.cid != null) {
      _ref = this.group.in_cid(command.cid);
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        unit = _ref[_i];
        this.remove(unit);
        unit.order = IS_LAIDOFF;
        unit.command = null;
      }
      return command.cid = null;
    } else {
      return red_alert("Command without cid");
    }
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

  Group.prototype.order_units = function(command) {
    var cid, count, unit, units, _i, _len;
    count = 0;
    if (units = this.units(command)) {
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
    return count;
  };

  Group.prototype.execute = function(command) {
    var count;
    count = 0;
    if ((command.power === 0) || (cyberBorg.power > command.power)) {
      count = this.order_units(command);
      if (command.execute != null) {
        try {
          count = command.execute(this);
        } catch (error) {
          red_alert(error);
          count = 0;
        }
      }
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

  CyberBorg.ORDER_MAP = ['DORDER_NONE', 'DORDER_STOP', 'DORDER_MOVE', 'DORDER_ATTACK', 'DORDER_BUILD', 'DORDER_HELPBUILD', 'DORDER_LINEBUILD', 'DORDER_DEMOLISH', 'DORDER_REPAIR', 'DORDER_OBSERVE', 'DORDER_FIRESUPPORT', 'DORDER_RETREAT', 'DORDER_DESTRUCT', 'DORDER_RTB', 'DORDER_RTR', 'DORDER_RUN', 'DORDER_EMBARK', 'DORDER_DISEMBARK', 'DORDER_ATTACKTARGET', 'DORDER_COMMANDERSUPPORT', 'DORDER_BUILDMODULE', 'DORDER_RECYCLE', 'DORDER_TRANSPORTOUT', 'DORDER_TRANSPORTIN', 'DORDER_TRANSPORTRETURN', 'DORDER_GUARD', 'DORDER_DROIDREPAIR', 'DORDER_RESTORE', 'DORDER_SCOUT', 'DORDER_RUNBURN', 'DORDER_UNUSED', 'DORDER_PATROL', 'DORDER_REARM', 'DORDER_RECOVER', 'DORDER_LEAVEMAP', 'DORDER_RTR_SPECIFIED', 'DORDER_CIRCLE', 'DORDER_HOLD', null, null, 'DORDER_CIRCLE', null, null, null, null, null, null, null, null, null, 'DORDER_MAINTAIN', 'FORDER_MANUFACTURE', 'LORDER_RESEARCH', 'CORDER_PASS', 'IS_LAIDOFF'];

  /* CLASS VARIABLES
  */

  CyberBorg.CID = 0;

  /* CONSTRUCTOR
  */

  function CyberBorg() {
    this.groups = WZArray.bless([]);
    this.power = 0;
    this.stalled = [];
    this.reserve = null;
    this.hq = false;
    this.pos = [];
    this.trace = selectedPlayer === me;
  }

  /* UPDATES
  */

  CyberBorg.prototype.update = function() {
    var group, object, _i, _len, _ref, _results;
    this.power = playerPower(me);
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

  CyberBorg.prototype.location = function(at, pos) {
    var key;
    key = "" + at.x + "." + at.y;
    if (pos) this.pos[key] = pos;
    return this.pos[key];
  };

  CyberBorg.prototype.for_all = function(test_of) {
    var group, list, object, _i, _j, _k, _len, _len2, _len3, _ref, _ref2, _ref3;
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
    _ref3 = this.reserve;
    for (_k = 0, _len3 = _ref3.length; _k < _len3; _k++) {
      object = _ref3[_k];
      if (test_of(object)) list.push(object);
    }
    return WZArray.bless(list);
  };

  CyberBorg.prototype.for_one = function(test_of) {
    var group, object, _i, _j, _k, _len, _len2, _len3, _ref, _ref2, _ref3;
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
    _ref3 = this.reserve;
    for (_k = 0, _len3 = _ref3.length; _k < _len3; _k++) {
      object = _ref3[_k];
      if (test_of(object)) {
        return {
          object: object,
          group: {
            list: this.reserve
          }
        };
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

  CyberBorg.enum_struct = function() {
    var array, params;
    params = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    array = enumStruct.apply(null, params).map(function(object) {
      return new WZObject(object);
    });
    return WZArray.bless(array);
  };

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
    return CyberBorg.enum_feature(ALL_PLAYERS, "OilResource").nearest(at);
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

CORDER_PASS = CyberBorg.ORDER_MAP.indexOf('CORDER_PASS');

IS_LAIDOFF = CyberBorg.ORDER_MAP.indexOf('IS_LAIDOFF');

CyberBorg.prototype.base_commands = function(reserve, resources) {
  var block, build, builds, command_center, commands, costs, dx, dy, immediately, light_factory, more, none, on_budget, on_glut, on_income, on_surplus, one, pass, power_generator, rc, research_facility, rx, ry, s, savings, tc, three, truck, trucks, two, with_help, x, y;
  light_factory = "A0LightFactory";
  command_center = "A0CommandCentre";
  research_facility = "A0ResearchFacility";
  power_generator = "A0PowerGenerator";
  none = function(obj) {
    if (obj == null) obj = {};
    obj.like = /none/;
    obj.limit = 0;
    obj.min = 0;
    obj.max = 0;
    obj.help = 0;
    return obj;
  };
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
    if (obj == null) obj = {};
    obj.like = /Truck/;
    return obj;
  };
  truck = trucks;
  three = function(obj) {
    if (obj == null) obj = {};
    obj.limit = 3;
    obj.min = 1;
    obj.max = 3;
    obj.help = 0;
    return obj;
  };
  two = function(obj) {
    if (obj == null) obj = {};
    obj.limit = 2;
    obj.min = 1;
    obj.max = 2;
    obj.help = 0;
    return obj;
  };
  one = function(obj) {
    if (obj == null) obj = {};
    obj.limit = 1;
    obj.min = 1;
    obj.max = 1;
    obj.help = 0;
    return obj;
  };
  with_help = function(obj) {
    if (obj == null) obj = {};
    obj.help = 3;
    return obj;
  };
  immediately = function(obj) {
    if (obj == null) obj = {};
    obj.power = 0;
    return obj;
  };
  pass = function(obj) {
    if (obj == null) obj = {};
    obj.cost = 0;
    obj.order = CORDER_PASS;
    obj.execute = function(units) {
      return 1;
    };
    obj.cid = null;
    return obj;
  };
  on_income = function(obj) {
    var cost;
    if (obj == null) obj = {};
    cost = obj.cost || 100;
    obj.power = cost / 2;
    return obj;
  };
  on_budget = function(obj) {
    var cost;
    if (obj == null) obj = {};
    cost = obj.cost || 100;
    obj.power = cost;
    return obj;
  };
  on_surplus = function(obj) {
    var cost;
    if (obj == null) obj = {};
    cost = obj.cost || 100;
    obj.power = 2 * cost;
    return obj;
  };
  on_glut = function(obj) {
    var cost;
    if (obj == null) obj = {};
    cost = obj.cost || 100;
    obj.power = 4 * cost;
    return obj;
  };
  tc = reserve.trucks().center();
  if (cyberBorg.trace) trace("Trucks around " + tc.x + ", " + tc.y);
  x = tc.x.to_i();
  y = tc.y.to_i();
  rc = WZArray.bless(resources.slice(0, 4)).center();
  if (cyberBorg.trace) trace("Resources around " + rc.x + ", " + rc.y + ".");
  rx = rc.x.to_i();
  ry = rc.y.to_i();
  dx = 1;
  if (x > rx) dx = -1;
  dy = 1;
  if (y > ry) dy = -1;
  s = 4;
  block = [with_help(immediately(three(trucks(build([light_factory, x - s * dx, y - s * dy]))))), with_help(immediately(three(trucks(build([research_facility, x, y - s * dy]))))), with_help(immediately(three(trucks(build([command_center, x + s * dx, y - s * dy]))))), immediately(three(trucks(build([power_generator, x + s * dx, y])))), on_surplus(one(truck(builds([power_generator, x, y])))), pass(on_glut(none())), on_budget(one(truck(builds([research_facility, x - s * dx, y])))), on_budget(one(truck(builds([power_generator, x - s * dx, y + s * dy])))), pass(on_glut(none())), on_budget(one(truck(builds([research_facility, x, y + s * dy])))), on_budget(one(truck(builds([power_generator, x + s * dx, y + s * dy]))))];
  more = null;
  if ((rx - x) * dx > (ry - y) * dy) {
    more = [pass(on_glut(none())), on_budget(one(truck(builds([research_facility, x + 2 * s * dx, y + s * dy])))), on_budget(one(truck(builds([power_generator, x + 2 * s * dx, y])))), pass(on_glut(none())), on_budget(one(truck(builds([research_facility, x + 2 * s * dx, y - s * dy]))))];
  } else {
    more = [pass(on_glut(none())), on_budget(one(truck(builds([research_facility, x + s * dx, y + 2 * s * dy])))), on_budget(one(truck(builds([power_generator, x, y + 2 * s * dy])))), pass(on_glut(none())), on_budget(one(truck(builds([research_facility, x - s * dx, y + 2 * s * dy]))))];
  }
  commands = block.concat(more);
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

start_trace = function(event) {
  var droid, research, structure;
  trace("Power level: " + cyberBorg.power + " in " + event.name);
  if (structure = event.structure) {
    trace("\tStructure: " + (structure.namexy()) + "\tCost: " + structure.cost);
  }
  if (research = event.research) {
    trace("\tResearch: " + event.research.name + "\tCost: " + research.power);
  }
  if (droid = event.droid) {
    return trace("\tDroid: " + (droid.namexy()) + "\tID:" + droid.id + "\tCost: " + droid.cost);
  }
};

bug_report = function(label, droid, event) {
  var at, command, corder, dorder, order, _ref;
  order = droid.order;
  dorder = droid.dorder;
  trace("" + label + ":\t" + (droid.namexy()) + "\tid:" + droid.id + "\tevent:" + event.name);
  trace("\t\torder:" + order + " => " + (order.order_map()));
  trace("\t\tdorder:" + dorder + " => " + (dorder.order_map()));
  if (command = droid.command) {
    corder = command.order;
    trace("\t\t" + (corder.order_map()) + "\t#" + corder + "\tcid:" + command.cid);
    if (command.structure) trace("\t\tstructure:" + command.structure);
    if (at = command.at) trace("\t\tat:(" + at.x + "," + at.y + ")");
    if (order === 0) {
      trace("\t\tBUG: Quitter.");
    } else {
      if (order !== droid.dorder) trace("\t\tBUG: Order changed.");
    }
  }
  if (event.name === "Destroyed") {
    return trace("\t\t" + ((_ref = event.group) != null ? _ref.name : void 0) + "'s " + (event.object.namexy()) + " was destroyed.");
  }
};

gotcha_working = function(droid, command) {
  var order;
  if (command == null) command = droid.command;
  if (cyberBorg.trace) centreView(droid.x, droid.y);
  if (droid.executes(command)) {
    order = command.order;
    if (cyberBorg.trace) {
      return green_alert("\tRe-issued " + (order.order_map()) + ", #" + order + ", to " + droid.name + ".");
    }
  } else {
    return red_alert("\t" + droid.name + " is a lazy bum!");
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
    if (cyberBorg.trace) bug_report("Selected", droid, event);
  }
  return count;
};

gotcha_idle = function(event) {
  var count, droid, _i, _len, _ref;
  count = 0;
  _ref = cyberBorg.for_all(function(object) {
    return object.order === 0 && (object.command != null);
  });
  for (_i = 0, _len = _ref.length; _i < _len; _i++) {
    droid = _ref[_i];
    count += 1;
    if (cyberBorg.trace) bug_report("Idle", droid, event);
    gotcha_working(droid);
  }
  return count;
};

gotcha_rogue = function(event) {
  var command, count, droid, rogue, _i, _len, _ref;
  count = 0;
  rogue = function(object) {
    if (object.command != null) {
      if (!((object.order === 0) || (object.order === object.dorder))) return true;
    }
    return false;
  };
  _ref = cyberBorg.for_all(function(object) {
    return rogue(object);
  });
  for (_i = 0, _len = _ref.length; _i < _len; _i++) {
    droid = _ref[_i];
    count += 1;
    if (cyberBorg.trace) bug_report("Rogue", droid, event);
    command = droid.command;
    if ((command != null ? command.order : void 0) === 28) {
      if (cyberBorg.trace) centreView(droid.x, droid.y);
      gotcha_working(droid, command);
    } else {
      red_alert("\tUncaught rogue case.");
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
      if (cyberBorg.trace) trace("");
    }
  }
  if (cyberBorg.trace && counts) return trace("");
};

cyberBorg = new CyberBorg();

BASE = 'Base';

DERRICKS = 'Derricks';

SCOUTS = 'Scouts';

FACTORIES = 'Factories';

LABS = 'Labs';

RESERVE = 'Reserve';

events = function(event) {
  cyberBorg.update();
  if (cyberBorg.trace) start_trace(event);
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
      red_alert("" + event.name + " NOT HANDLED!");
  }
  group_executions(event);
  return gotchas(event);
};

startLevel = function() {
  var base, derricks, factories, groups, labs, reserve, resources, scouts;
  cyberBorg.reserve = reserve = CyberBorg.enum_droid();
  resources = CyberBorg.get_resources(reserve.center());
  groups = cyberBorg.groups;
  base = new Group(BASE, 100, [], cyberBorg.base_commands(reserve, resources), reserve);
  groups.push(base);
  derricks = new Group(DERRICKS, 90, [], cyberBorg.derricks_commands(resources), reserve);
  groups.push(derricks);
  scouts = new Group(SCOUTS, 70, [], cyberBorg.scouts_commands(resources), reserve);
  groups.push(scouts);
  factories = new Group(FACTORIES, 20, [], cyberBorg.factory_commands(), reserve);
  groups.push(factories);
  labs = new Group(LABS, 19, [], cyberBorg.lab_commands(), reserve);
  groups.push(labs);
  return groups.sort(function(a, b) {
    return b.rank - a.rank;
  });
};

structureBuilt = function(structure, droid, group) {
  if (droid.command) group.layoffs(droid.command);
  cyberBorg.reserve.push(structure);
  if (structure.type === STRUCTURE) {
    switch (structure.stattype) {
      case HQ:
        cyberBorg.hq = true;
    }
  }
  return helping(droid);
};

destroyed = function(object, group) {
  if (object.player === me && object.type === STRUCTURE) {
    switch (object.stattype) {
      case HQ:
        return cyberBorg.hq = false;
    }
  }
};

droidBuilt = function(droid, structure, group) {
  if (structure != null ? structure.command : void 0) {
    group.layoffs(structure.command);
  }
  cyberBorg.reserve.push(droid);
  return helping(droid);
};

helping = function(unit) {
  var cid, command, employed, group, help_wanted, _i, _len, _ref;
  _ref = cyberBorg.groups;
  for (_i = 0, _len = _ref.length; _i < _len; _i++) {
    group = _ref[_i];
    command = group.commands.current();
    cid = command != null ? command.cid : void 0;
    if (cid && (help_wanted = command.help) && command.like.test(unit.name)) {
      employed = group.list.counts_in_cid(cid);
      if (employed < help_wanted && unit.executes(command)) {
        unit.command = command;
        group.add(unit);
        return true;
      }
    }
  }
  return false;
};

chat = function(sender, to, message) {
  var words;
  words = message.split(/\s+/);
  if (sender === me) {
    switch (words[0]) {
      case 'report':
        return report(words[1]);
      case 'reload':
        return include("multiplay/skirmish/reloads.js");
      case 'trace':
        if (cyberBorg.trace) green_alert("Tracing off.");
        cyberBorg.trace = !cyberBorg.trace;
        if (cyberBorg.trace) return green_alert("Tracing on.");
        break;
      default:
        return console("What?");
    }
  }
};

report = function(who) {
  var droid, empty, list, _i, _len, _ref, _ref2, _ref3, _ref4;
  if (who === RESERVE) {
    list = cyberBorg.reserve;
  } else {
    list = (_ref = cyberBorg.groups.named(who)) != null ? _ref.list : void 0;
  }
  if (list) {
    empty = true;
    for (_i = 0, _len = list.length; _i < _len; _i++) {
      droid = list[_i];
      empty && (empty = false);
      console(("" + (droid.namexy()) + " ") + ("corder:" + ((_ref2 = droid.corder) != null ? _ref2.order_map() : void 0) + " ") + ("dorder:" + ((_ref3 = droid.dorder) != null ? _ref3.order_map() : void 0) + " ") + ("order:" + ((_ref4 = droid.order) != null ? _ref4.order_map() : void 0) + " ") + ("health:" + droid.health + "%"));
    }
    if (empty) return console("Group currently empty.");
  } else {
    return console("There is not group " + who);
  }
};

researched = function(completed, structure, group) {
  var command, research;
  if (structure) {
    completed = completed.name;
    research = structure.researching;
    command = structure.command;
    if (research === completed) {
      return group.layoffs(command);
    } else {
      return cyberBorg.stalled.push(structure);
    }
  }
};

droidIdle = function(droid, group) {
  if (droid.command) group.layoffs(droid.command);
  return helping(droid);
};

stalled_units = function() {
  var command, stalled, unit;
  stalled = [];
  while (unit = cyberBorg.stalled.shift()) {
    command = unit.command;
    cyberBorg.power -= command.cost;
    if (cyberBorg.power > command.power) {
      if (!unit.executes(command)) {
        red_alert("" + unit.name + " could not execute " + (command.order.order_map()));
        if (command.research) red_alert("\t" + command.research);
      }
    } else {
      stalled.push(unit);
    }
  }
  return cyberBorg.stalled = stalled;
};

group_executions = function(event) {
  var command, commands, group, groups, name, _i, _len;
  groups = cyberBorg.groups;
  for (_i = 0, _len = groups.length; _i < _len; _i++) {
    group = groups[_i];
    name = group.name;
    if (!(cyberBorg.hq || name === BASE || name === FACTORIES || name === LABS)) {
      continue;
    }
    commands = group.commands;
    while (command = commands.next()) {
      if (!group.execute(command)) {
        commands.revert();
        break;
      }
    }
  }
  return stalled_units();
};
