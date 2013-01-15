var bug_report, gotcha_idle, gotcha_rogue, gotcha_selected, gotcha_working, gotchas;

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
