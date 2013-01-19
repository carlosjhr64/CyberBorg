var bug_report, gotcha_idle, gotcha_rogue, gotcha_selected, gotcha_working, gotchas, start_trace;

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
  command = null;
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
    trace("\t\t" + ((_ref = event.group) != null ? _ref.name : void 0) + "'s " + (event.object.namexy()) + " was destroyed.");
  }
  return command;
};

gotcha_working = function(droid, command) {
  var order;
  if (CyberBorg.TRACE) centreView(droid.x, droid.y);
  if (droid.executes(command)) {
    order = command.order;
    return green_alert("\tRe-issued " + (order.order_map()) + ", #" + order + ", to " + droid.name + ".");
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
    gotcha_working(droid, command);
  }
  return count;
};

gotcha_rogue = function(event) {
  var command, count, droid, rogue, _i, _len, _ref;
  count = 0;
  rogue = function(object) {
    if (object.command) {
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
    command = bug_report("Rogue", droid, event);
    if ((command != null ? command.order : void 0) === 28) {
      if (CyberBorg.TRACE) centreView(droid.x, droid.y);
      gotcha_working(droid, command);
    } else {
      red_alert("\tUncaught rogue case.");
    }
  }
  return count;
};

gotchas = function(event) {
  var base, count, counts, gotcha, _i, _len, _ref, _ref2, _ref3;
  base = cyberBorg.groups.named(BASE).list;
  blue_alert("Base group first and last: " + ("" + ((_ref = base.first()) != null ? _ref.namexy() : void 0) + ", " + ((_ref2 = base.last()) != null ? _ref2.namexy() : void 0) + "."));
  counts = count = 0;
  _ref3 = [gotcha_selected, gotcha_idle, gotcha_rogue];
  for (_i = 0, _len = _ref3.length; _i < _len; _i++) {
    gotcha = _ref3[_i];
    if (count = gotcha(event)) {
      counts += count;
      trace("");
    }
  }
  if (counts) return trace("");
};
