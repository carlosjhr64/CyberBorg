
Object.prototype.build = function(structure_id, pos, direction) {
  return orderDroidBuild(this, DORDER_BUILD, structure_id, pos.x, pos.y, direction);
};

Object.prototype.namexy = function() {
  return this.name + "(" + this.x + "," + this.y + ")";
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
