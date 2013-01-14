var bug_report, gotchas;

bug_report = function(label, droid, event) {
  var at, number, oid, order, _ref;
  order = null;
  oid = droid.oid;
  trace("" + label + ":\t" + (droid.namexy()) + "\tid:" + droid.id + "\tevent:" + event.name);
  number = droid.order;
  trace("\t\toid:" + oid + "\torder number:" + number + " => " + CyberBorg.ORDER_MAP[number]);
  if (oid) {
    order = cyberBorg.get_order(oid);
    if (order) {
      trace("\t\tfunction:" + order["function"] + "\tnumber:" + order.number);
      if (order.structure) trace("\t\tstructure:" + order.structure);
      if (at = order.at) trace("\t\tat:(" + at.x + "," + at.y + ")");
      if (number === 0) trace("\t\tBUG: Quitter.");
      if (number !== order.number) trace("\t\tBUG: Order changed.");
    } else {
      trace("\t\tBUG: Order on oid does not exist.");
    }
  }
  if (event.name === "Destroyed") {
    trace("\t\t" + ((_ref = event.group) != null ? _ref.name : void 0) + "'s " + (event.object.namexy()) + " was destroyed.");
  }
  return order;
};

gotchas = function(event) {
  var droid, nwl, order, _i, _j, _k, _len, _len2, _len3, _ref, _ref2, _ref3;
  nwl = false;
  _ref = cyberBorg.for_all(function(object) {
    return object.selected;
  });
  for (_i = 0, _len = _ref.length; _i < _len; _i++) {
    droid = _ref[_i];
    nwl = true;
    bug_report("Selected", droid, event);
  }
  _ref2 = cyberBorg.for_all(function(object) {
    return object.order === 0;
  });
  for (_j = 0, _len2 = _ref2.length; _j < _len2; _j++) {
    droid = _ref2[_j];
    nwl = true;
    order = bug_report("Idle", droid, event);
    if (event.name === "Destroyed" && event.object.name === "Oil Derrick") {
      if (order && order["function"] === 'orderDroidBuild' && order.structure === 'A0ResourceExtractor') {
        if (droid.executes(order)) {
          trace("\tRe-issued derrick build order");
        } else {
          trace("\tOh! The Humanity!!!");
        }
      }
    }
  }
  _ref3 = cyberBorg.for_all(function(object) {
    return object.oid && object.order === 25;
  });
  for (_k = 0, _len3 = _ref3.length; _k < _len3; _k++) {
    droid = _ref3[_k];
    nwl = true;
    order = bug_report("Guarding", droid, event);
    if ((order != null ? order.number : void 0) === 28) {
      cameraSlide(droid.x, droid.y);
      if (droid.executes(order)) {
        trace("\tRe-issued scout move order");
      } else {
        trace("\tLazy scout!");
      }
    }
  }
  if (nwl) return trace("");
};
