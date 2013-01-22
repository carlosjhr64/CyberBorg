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
