
Array.INIT = -1;

Array.NONE = -1;

Array.prototype.contains = function(droid) {
  return this.indexOfObject(droid) > Array.NONE;
};

Array.prototype.indexOfObject = function(droid) {
  var i, id;
  id = droid.id;
  i = 0;
  while (i < this.length) {
    if (this[i].id === id) return i;
    i++;
  }
  return Array.NONE;
};

Array.prototype.filters = function(type) {
  return WZArray.bless(this.filter(type));
};

Array.prototype.idle = function() {
  return this.filters(is_idle);
};

Array.prototype.in_group = function(group) {
  return this.filters(function(droid) {
    return group.group.indexOfObject(droid) > Array.NONE;
  });
};

Array.prototype.is = {};

Array.prototype.nearest = function(at) {
  this.sort(function(a, b) {
    return CyberBorg.nearest_metric(a, b, at);
  });
  return this;
};

Array.prototype.not_built = function() {
  return this.filters(not_built);
};

Array.prototype.not_in_group = function(group) {
  return this.filters(function(droid) {
    return group.group.indexOfObject(droid) === Array.NONE;
  });
};

Array.prototype.of = function(gameobj) {
  return this.is[gameobj.id];
};

Array.prototype.removeObject = function(droid) {
  var i;
  i = this.indexOfObject(droid);
  if (i > Array.NONE) this.splice(i, 1);
  return i;
};

Array.prototype.trucks = function() {
  return this.filters(CyberBorg.is_truck);
};

Array.prototype.factories = function() {
  return this.filters(CyberBorg.is_factory);
};
