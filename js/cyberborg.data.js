
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
  var cc, data, lf, order, orders, p, p11, p33, pg, phase1, phase2, rf, _i, _j, _len, _len2;
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
  order = function(params) {
    p = params[0];
    p.structure = params[1];
    p.at = {
      x: params[2],
      y: params[3]
    };
    return p;
  };
  phase1 = [[lf, 9, 234], [rf, 6, 234], [cc, 6, 237], [pg, 3, 234]];
  for (_i = 0, _len = phase1.length; _i < _len; _i++) {
    data = phase1[_i];
    data.unshift(p33());
  }
  phase2 = [[rf, 3, 237], [pg, 3, 240], [rf, 6, 240], [pg, 9, 240], [rf, 12, 240], [pg, 12, 243], [rf, 9, 243], [pg, 6, 243]];
  for (_j = 0, _len2 = phase2.length; _j < _len2; _j++) {
    data = phase2[_j];
    data.unshift(p11());
  }
  orders = phase1.concat(phase2);
  return orders.map(function(data) {
    return order(data);
  });
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
