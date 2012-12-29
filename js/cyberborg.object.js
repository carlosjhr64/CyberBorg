
Object.prototype.build = function(structure_id, pos, direction) {
  return orderDroidBuild(this, DORDER_BUILD, structure_id, pos.x, pos.y, direction);
};

Object.prototype.namexy = function() {
  return "" + this.name + "(" + this.x + "," + this.y + ")";
};

Object.prototype.position = function() {
  return {
    x: this.x,
    y: this.y
  };
};

Object.prototype.is_truck = function() {
  return CyberBorg.is_truck(this);
};

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
