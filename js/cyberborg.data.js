
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
  var command_center, data, light_factory, order, orders, p, p11, p33, phase1, phase2, power_generator, research_facility, _i, _j, _len, _len2;
  light_factory = "A0LightFactory";
  command_center = "A0CommandCentre";
  research_facility = "A0ResearchFacility";
  power_generator = "A0PowerGenerator";
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
    p = params[3];
    p.structure = params[0];
    p.at = {
      x: params[1],
      y: params[2]
    };
    return p;
  };
  phase1 = [[light_factory, 9, 234], [research_facility, 6, 234], [command_center, 6, 237], [power_generator, 3, 234]];
  for (_i = 0, _len = phase1.length; _i < _len; _i++) {
    data = phase1[_i];
    data.push(p33());
  }
  phase2 = [[research_facility, 3, 237], [power_generator, 3, 240], [research_facility, 6, 240], [power_generator, 9, 240], [research_facility, 12, 240], [power_generator, 12, 243], [research_facility, 9, 243], [power_generator, 6, 243]];
  for (_j = 0, _len2 = phase2.length; _j < _len2; _j++) {
    data = phase2[_j];
    data.push(p11());
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
