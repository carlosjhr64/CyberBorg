// *** Array Extensions ***
// TODO use map to convert only those objects that need this?
Array.INIT = -1;
Array.NONE = -1;
// center WZ2100
Array.prototype.center=function() {
  var at = {x:0,y:0}; var n = this.length;
  for (var i=0; i<n; i++){ at.x += this[i].x; at.y += this[i].y; }
  at.x = at.x/n; at.y = at.y/n;
  return(at);
}
//  concat  JS-ARRAY
//  constructor  JS-ARRAY
//  contains  WZ2100
Array.prototype.contains=function(droid) {
  return(this.indexOfObject(droid)>Array.NONE);
}
Array.prototype.indexOfObject=function(droid) {
  var id = droid.id;
  for(var i=0;i<this.length;i++){
    if (this[i].id == id) { return(i); }
  }
  return(Array.NONE);
}
//  count  WZ2100 (clobbers ruby?)
Array.prototype.count=function(type){
  var count = 0;
  for (var i=0;i<this.length;i++){
    if (type(this[i])) { count+=1; }
  }
  return(count);
}
//  current  WZ2100
Array.prototype.current = Array.INIT;
// every  JS-ARRAY
// filter  JS-ARRAY
// first
Array.prototype.first=function(){ return(this[0]); }
// forEach  JS-ARRAY
// idle WZ2100
Array.prototype.idle=function() {
  var selected = this.filter(is_idle);
  return(selected);
}
//  in_group  WZ2100
Array.prototype.in_group=function(group) {
  //selected = this.filter( function(droid) { return(droid.group == group.group); });
  var selected = this.filter( function(droid) { return(group.group.indexOf(droid)>Array.NONE); });
  return(selected);
}
// indexOf  JS-ARRAY
// is
Array.prototype.is = {};
// join  JS-ARRAY
// lastIndexOf  JS-ARRAY
// length  JS-ARRAY
// map  JS-ARRAY
// nearest WZ2100
Array.prototype.nearest=function(at) {
  this.sort( function(a,b){ return(CyberBorg.nearest_metric(a,b,at)) } );
  return(this);
}
// next WZ2100
Array.prototype.next=function(gameobj){
  if (this.current<this.length) { this.current += 1; }
  var order = this[this.current];
  if (gameobj) { this.is[gameobj.id] = order; }
  return(order);
}
// not_built WZ2100
Array.prototype.not_built=function(){
  var selected = this.filter(not_built);
  return(selected);
}
// not_in_group  WZ2100
Array.prototype.not_in_group=function(group) {
  //var selected = this.filter( function(droid) { return(droid.group != group.group); });
  var selected = this.filter( function(droid) { return(group.group.indexOf(droid)==Array.NONE); });
  return(selected);
}
// of  WZ2100
Array.prototype.of=function(gameobj){ return(this.is[gameobj.id]); }
// pop  JS-ARRAY
// push  JS-ARRAY
// reduceRight  JS-ARRAY
// reduce  JS-ARRAY
// reject!  RUBY
// remove  WS2100
Array.prototype.removeObject=function(droid){
  var i = this.indexOfObject(droid);
  if (i>Array.NONE) {  this.splice(i,1); }
  return(i);
}
// replace  RUBY
Array.prototype.reserve = [];
// reserve  WZ2100
// reverse  JS-ARRAY
// shift  JS-ARRAY
// slice  JS-ARRAY
// some  JS-ARRAY
// sort  JS-ARRAY
// splice  JS-ARRAY
// toSource  JS-ARRAY
// toString  JS-ARRAY
// trucks  WZ2100
Array.prototype.trucks=function() {
  var selected = this.filter(CyberBorg.is_truck);
  return(selected);
}
Array.prototype.factories=function() {
  var selected = this.filter(CyberBorg.is_factory);
  return(selected);
}
// unshift  JS-ARRAY
