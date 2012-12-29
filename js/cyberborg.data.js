
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

CyberBorg.prototype.base_orders = function() {
  var cc, lf, order, p, p11, p33, pg, rf;
  lf = "A0LightFactory";
  cc = "A0CommandCentre";
  rf = "A0ResearchFacility";
  pg = "A0PowerGenerator";
  p = function(n, x) {
    return {
      min: n,
      max: x
    };
  };
  p33 = function() {
    return p(3, 3);
  };
  p11 = function() {
    return p(1, 1);
  };
  order = function(p, str, x, y) {
    p.structure = str;
    p.at = {
      x: x,
      y: y
    };
    return p;
  };
  return [order(p33(), lf, 9, 234), order(p33(), rf, 6, 234), order(p33(), cc, 6, 237), order(p33(), pg, 3, 234), order(p11(), rf, 3, 237), order(p11(), pg, 3, 240), order(p11(), rf, 6, 240), order(p11(), pg, 9, 240), order(p11(), rf, 12, 240), order(p11(), pg, 12, 243), order(p11(), rf, 9, 243), order(p11(), pg, 6, 243)];
};

CyberBorg.prototype.factory_orders = function() {
  var mg1, orders, truck, whb1;
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
  mg1 = {
    name: "MgWhB1",
    turret: "MG1Mk1",
    droid_type: DROID_WEAPON
  };
  orders = [];
  2..times(function() {
    return orders.push(whb1(truck));
  });
  12..times(function() {
    return orders.push(whb1(mg1));
  });
  return orders;
};
