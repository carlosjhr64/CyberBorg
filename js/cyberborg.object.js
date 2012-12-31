var getObjectClass;

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

getObjectClass = function(obj) {
  var arr;
  if (obj && obj.constructor && obj.constructor.toString) {
    arr = obj.constructor.toString().match(/function\s*(\w+)/);
    if (arr && (arr.length === 2)) return arr[1];
  }
  return;
};
