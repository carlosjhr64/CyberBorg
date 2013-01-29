// Generated by CoffeeScript 1.4.0
var Gotcha;

Gotcha = (function() {

  function Gotcha(ai, trace) {
    this.ai = ai;
    this.trace = trace != null ? trace : this.ai.trace;
  }

  Gotcha.prototype.start = function(event) {
    var droid, research, structure;
    this.trace.out("Power level: " + this.ai.power + " in " + event.name);
    if (structure = event.structure) {
      this.trace.out("\t" + (structure.namexy()) + "\tCost: " + structure.cost);
    }
    if (research = event.research) {
      this.trace.out("\t" + event.research.name + "\tCost: " + research.power);
    }
    if (droid = event.droid) {
      return this.trace.out("\t" + (droid.namexy()) + "\tID:" + droid.id + "\tCost: " + droid.cost);
    }
  };

  Gotcha.prototype.command = function(command) {
    var at, key, keyvals;
    keyvals = [];
    for (key in command) {
      switch (key) {
        case 'at':
          at = command.at;
          keyvals.push("" + key + ":{" + at.x + "," + at.y + "}");
          break;
        case 'execute':
          keyvals.push("execute:->");
          break;
        default:
          keyvals.push("" + key + ":" + command[key]);
      }
    }
    return this.trace.blue(keyvals.sort().join(' '));
  };

  Gotcha.prototype.bug_report = function(label, droid, event) {
    var at, command, corder, dorder, group, object, order, _ref;
    order = droid.order;
    dorder = droid.dorder;
    this.trace.out("" + label + ":\t" + (droid.namexy()) + "\tid:" + droid.id + "\t");
    this.trace.out("\t\tevent: " + event.name);
    this.trace.out("\t\torder: " + order + " => " + (order.order_map()));
    this.trace.out("\t\tdorder: " + dorder + " => " + (dorder.order_map()));
    if (command = droid.command) {
      corder = command.order;
      this.trace.out("\t\t" + (corder.order_map()) + "\t#" + corder + "\tcid:" + command.cid);
      if (command.structure) {
        this.trace.out("\t\tstructure:" + command.structure);
      }
      if (at = command.at) {
        this.trace.out("\t\tat:(" + at.x + "," + at.y + ")");
      }
      if (order === 0) {
        this.trace.out("\t\tBUG: Quitter.");
      } else {
        if (order !== droid.dorder) {
          this.trace.out("\t\tBUG: Order changed.");
        }
      }
    }
    if (event.name === 'Destroyed') {
      group = (_ref = event.group) != null ? _ref.name : void 0;
      object = event.object.namexy();
      return this.trace.out("\t\t" + group + "'s " + object + " destroyed.");
    }
  };

  Gotcha.prototype.working = function(droid, command) {
    var order;
    if (command == null) {
      command = droid.command;
    }
    if (this.trace.on) {
      centreView(droid.x, droid.y);
    }
    if (droid.executes(command)) {
      order = command.order;
      if (this.trace.on) {
        return this.trace.green("\tRe-issued " + ("" + (order.order_map()) + ", #" + order + ", to " + droid.name + "."));
      }
    } else {
      return this.trace.red("\t" + droid.name + " is a lazy bum!");
    }
  };

  Gotcha.prototype.selected = function(event) {
    var count, droid, _i, _len, _ref;
    count = 0;
    _ref = this.ai.groups.for_all(function(object) {
      return object.selected;
    });
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      droid = _ref[_i];
      count += 1;
      if (this.trace.on) {
        this.bug_report("Selected", droid, event);
      }
    }
    return count;
  };

  Gotcha.prototype.idle = function(event) {
    var count, droid, is_quitter, _i, _len, _ref;
    count = 0;
    is_quitter = function(object) {
      return object.order === 0 && (object.command != null);
    };
    _ref = this.ai.groups.for_all(is_quitter);
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      droid = _ref[_i];
      count += 1;
      if (this.trace.on) {
        this.bug_report("Quitter", droid, event);
      }
      this.working(droid);
    }
    return count;
  };

  Gotcha.prototype.rogue = function(event) {
    var command, count, droid, rogue, _i, _len, _ref;
    count = 0;
    rogue = function(object) {
      if (object.command != null) {
        if (!((object.order === 0) || (object.order === object.dorder))) {
          return true;
        }
      }
      return false;
    };
    _ref = this.ai.groups.for_all(function(object) {
      return rogue(object);
    });
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      droid = _ref[_i];
      count += 1;
      if (this.trace.on) {
        this.bug_report("Rogue", droid, event);
      }
      command = droid.command;
      if ((command != null ? command.order : void 0) === 28) {
        if (this.trace.on) {
          centreView(droid.x, droid.y);
        }
        this.working(droid, command);
      } else {
        this.trace.red("\tUncaught rogue case.");
      }
    }
    return count;
  };

  Gotcha.prototype.end = function(event) {
    var count, counts;
    counts = count = 0;
    if (count = this.selected(event) && this.trace.on) {
      counts += count;
      this.trace.out("");
    }
    if (count = this.idle(event) && this.trace.on) {
      counts += count;
      this.trace.out("");
    }
    if (count = this.rogue(event) && this.trace.on) {
      counts += count;
      this.trace.out("");
    }
    if (this.trace.on && counts) {
      return this.trace.out("");
    }
  };

  return Gotcha;

})();
