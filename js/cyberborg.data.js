
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
  return [
    {
      min: 3,
      max: 3,
      structure: "A0LightFactory",
      at: {
        x: 9,
        y: 234
      }
    }, {
      min: 3,
      max: 3,
      structure: "A0ResearchFacility",
      at: {
        x: 6,
        y: 234
      }
    }, {
      min: 3,
      max: 3,
      structure: "A0CommandCentre",
      at: {
        x: 6,
        y: 237
      }
    }, {
      min: 3,
      max: 3,
      structure: "A0PowerGenerator",
      at: {
        x: 3,
        y: 234
      }
    }, {
      min: 1,
      max: 1,
      structure: "A0ResearchFacility",
      at: {
        x: 3,
        y: 237
      }
    }, {
      min: 1,
      max: 1,
      structure: "A0PowerGenerator",
      at: {
        x: 3,
        y: 240
      }
    }, {
      min: 1,
      max: 1,
      structure: "A0ResearchFacility",
      at: {
        x: 6,
        y: 240
      }
    }, {
      min: 1,
      max: 1,
      structure: "A0PowerGenerator",
      at: {
        x: 9,
        y: 240
      }
    }, {
      min: 1,
      max: 1,
      structure: "A0ResearchFacility",
      at: {
        x: 12,
        y: 240
      }
    }, {
      min: 1,
      max: 1,
      structure: "A0PowerGenerator",
      at: {
        x: 12,
        y: 243
      }
    }, {
      min: 1,
      max: 1,
      structure: "A0ResearchFacility",
      at: {
        x: 9,
        y: 243
      }
    }, {
      min: 1,
      max: 1,
      structure: "A0PowerGenerator",
      at: {
        x: 6,
        y: 243
      }
    }
  ];
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
