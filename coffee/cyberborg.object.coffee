# Object extensions for Droids
# TODO use map to convert only those objects that need this?
Object::build = (structure_id, pos, direction) ->
  orderDroidBuild this, DORDER_BUILD, structure_id, pos.x, pos.y, direction

Object::namexy = ->
  @name + "(" + @x + "," + @y + ")"

Object::position = ->
  x: @x
  y: @y

Object::is_truck = ->
  CyberBorg.is_truck this
