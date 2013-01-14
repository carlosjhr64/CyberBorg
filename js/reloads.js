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
  var droid, nwl, order, _i, _len, _ref;
  nwl = false;
  /*
    for droid in cyberBorg.for_all((object) -> object.selected)
      nwl = true
      bug_report("Selected", droid, event)
    for droid in cyberBorg.for_all((object) -> object.order is 0)
      nwl = true
      order = bug_report("Idle", droid, event)
      # OK, let's circumvent the game bugs...
      if event.name is "Destroyed" and event.object.name is "Oil Derrick"
        if order and order.function is 'orderDroidBuild' and
        order.structure is 'A0ResourceExtractor'
          if droid.executes(order)
            trace("\tRe-issued derrick build order")
          else
            trace("\tOh! The Humanity!!!")
  */
  _ref = cyberBorg.for_all(function(object) {
    return object.oid && object.order === 25;
  });
  for (_i = 0, _len = _ref.length; _i < _len; _i++) {
    droid = _ref[_i];
    nwl = true;
    order = bug_report("Guarding", droid, event);
    if ((order != null ? order.number : void 0) === 28) {
      cameraSlice(droid.x, droid.y);
      if (droid.executes(order)) {
        trace("\tRe-issued scout move order");
      } else {
        trace("\tLazy scout!");
      }
    }
  }
  if (nwl) return trace("");
};
