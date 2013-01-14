var bug_report, gotcha_idle, gotcha_rogue, gotcha_selected, gotcha_working, gotchas;

bug_report = function(label, droid, event) {
  var at, number, oid, order, _ref;
  order = null;
  number = droid.order;
  trace("" + label + ":\t" + (droid.namexy()) + "\tid:" + droid.id + "\tevent:" + event.name);
  trace("\t\torder number:" + number + " => " + CyberBorg.ORDER_MAP[number]);
  if (oid = droid.oid) {
    order = cyberBorg.get_order(oid);
    if (order) {
      trace("\t\tfunction:" + order["function"] + "\tnumber:" + order.number + "\toid:" + oid);
      if (order.structure) trace("\t\tstructure:" + order.structure);
      if (at = order.at) trace("\t\tat:(" + at.x + "," + at.y + ")");
      if (number === 0) {
        trace("\t\tBUG: Quitter.");
      } else {
        if (number !== order.number) trace("\t\tBUG: Order changed.");
      }
    } else {
      trace("\t\tBUG: Order on oid " + oid + " does not exist.");
    }
  }
  if (event.name === "Destroyed") {
    trace("\t\t" + ((_ref = event.group) != null ? _ref.name : void 0) + "'s " + (event.object.namexy()) + " was destroyed.");
  }
  return order;
};

gotcha_working = function(droid, order) {
  if (CyberBorg.TRACE) centreView(droid.x, droid.y);
  if (droid.executes(order)) {
    return trace("\tRe-issued " + order["function"] + " to " + droid.name + ".");
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
  var count, droid, order, _i, _len, _ref;
  count = 0;
  _ref = cyberBorg.for_all(function(object) {
    return object.order === 0;
  });
  for (_i = 0, _len = _ref.length; _i < _len; _i++) {
    droid = _ref[_i];
    count += 1;
    order = bug_report("Idle", droid, event);
    if (order && event.name === "Destroyed" && event.object.name === "Oil Derrick" && order["function"] === 'orderDroidBuild' && order.structure === 'A0ResourceExtractor') {
      gotcha_working(droid, order);
    }
  }
  return count;
};

gotcha_rogue = function(event) {
  var count, droid, order, rogue, _i, _len, _ref;
  count = 0;
  rogue = function(object) {
    var oid, _ref;
    if (oid = object.oid) {
      if (object.order !== ((_ref = cyberBorg.get_order(oid)) != null ? _ref.number : void 0)) {
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
    order = bug_report("Rogue", droid, event);
    if ((order != null ? order.number : void 0) === 28) {
      if (CyberBorg.TRACE) centreView(droid.x, droid.y);
      gotcha_working(droid, order);
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
