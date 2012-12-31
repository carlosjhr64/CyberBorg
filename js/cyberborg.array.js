
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

Array.prototype.idle = function() {
  var selected;
  selected = this.filter(is_idle);
  return selected;
};

Array.prototype.in_group = function(group) {
  var selected;
  selected = this.filter(function(droid) {
    return group.group.indexOf(droid) > Array.NONE;
  });
  return selected;
};

Array.prototype.is = {};

Array.prototype.nearest = function(at) {
  this.sort(function(a, b) {
    return CyberBorg.nearest_metric(a, b, at);
  });
  return this;
};

Array.prototype.not_built = function() {
  var selected;
  selected = this.filter(not_built);
  return selected;
};

Array.prototype.not_in_group = function(group) {
  var selected;
  selected = this.filter(function(droid) {
    return group.group.indexOf(droid) === Array.NONE;
  });
  return selected;
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

Array.prototype.reserve = [];

Array.prototype.trucks = function() {
  var selected;
  selected = this.filter(CyberBorg.is_truck);
  return selected;
};

Array.prototype.factories = function() {
  var selected;
  selected = this.filter(CyberBorg.is_factory);
  return selected;
};
