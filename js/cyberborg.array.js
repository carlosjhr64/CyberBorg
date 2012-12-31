var WZArray;

WZArray = (function() {

  function WZArray() {}

  WZArray.INIT = -1;

  WZArray.NONE = -1;

  WZArray.bless = function(array) {
    var method, name, _ref;
    if (array.is_wzarray) return array;
    _ref = WZArray.prototype;
    for (name in _ref) {
      method = _ref[name];
      array[name] = method;
    }
    array.is_wzarray = true;
    return array;
  };

  WZArray.prototype.counts = function(type) {
    var count, i;
    count = 0;
    i = 0;
    while (i < this.length) {
      if (type(this[i])) count += 1;
      i++;
    }
    return count;
  };

  WZArray.prototype.contains = function(object) {
    return this.indexOfObject(object) > WZArray.NONE;
  };

  WZArray.prototype.indexOfObject = function(object) {
    var i, id;
    id = object.id;
    i = 0;
    while (i < this.length) {
      if (this[i].id === id) return i;
      i++;
    }
    return WZArray.NONE;
  };

  WZArray.prototype.nearest = function(at) {
    this.sort(function(a, b) {
      return CyberBorg.nearest_metric(a, b, at);
    });
    return this;
  };

  WZArray.prototype.removeObject = function(object) {
    var i;
    i = this.indexOfObject(object);
    if (i > WZArray.NONE) this.splice(i, 1);
    return i;
  };

  WZArray.prototype["in"] = function(group) {
    return this.filters(function(object) {
      return group.group.indexOfObject(object) > WZArray.NONE;
    });
  };

  WZArray.prototype.filters = function(type) {
    return WZArray.bless(this.filter(type));
  };

  WZArray.prototype.idle = function() {
    return this.filters(is_idle);
  };

  WZArray.prototype.center = function() {
    var at, i, n;
    at = {
      x: 0,
      y: 0
    };
    n = this.length;
    i = 0;
    while (i < n) {
      at.x += this[i].x;
      at.y += this[i].y;
      i++;
    }
    at.x = at.x / n;
    at.y = at.y / n;
    return at;
  };

  WZArray.prototype.first = function() {
    return this[0];
  };

  WZArray.prototype._current = WZArray.INIT;

  WZArray.prototype.current = WZArray[WZArray._current];

  WZArray.prototype.next = function(gameobj) {
    var order;
    if (this._current < this.length) this._current += 1;
    order = this[this._current];
    if (gameobj) this.is[gameobj.id] = order;
    return order;
  };

  WZArray.prototype.previous = function(gameobj) {
    var order;
    if (this._current > WZArray.init) this._current -= 1;
    order = this[this._current];
    if (gameobj) this.is[gameobj.id] = order;
    return order;
  };

  WZArray.prototype.not_built = function() {
    return this.filters(not_built);
  };

  WZArray.prototype.not_in = function(group) {
    return this.filters(function(object) {
      return group.group.indexOfObject(object) === WZArray.NONE;
    });
  };

  WZArray.prototype.is = {};

  WZArray.prototype.of = function(gameobj) {
    return this.is[gameobj.id];
  };

  WZArray.prototype.trucks = function() {
    return this.filters(CyberBorg.is_truck);
  };

  WZArray.prototype.factories = function() {
    return this.filters(CyberBorg.is_factory);
  };

  return WZArray;

})();
