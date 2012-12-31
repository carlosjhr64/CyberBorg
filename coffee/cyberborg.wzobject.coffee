# Warzone 2100 Objects
class WZObject
  constructor: (object) ->
    @copy(object)
    @is_wzobject = true
  copy: (object) ->
    @game_time = gameTime
    @[key] = object[key] for key of object

  # TODO only needs to update volatile data :-??
  update: () -> @copy(objFromId(@))

  build: (structure_id, pos, direction) ->
    orderDroidBuild(@, DORDER_BUILD, structure_id, pos.x, pos.y, direction)

  namexy: () -> "#{@name}(#{@x},#{@y})"

  position: () -> x: @x, y: @y

  is_truck: () -> CyberBorg.is_truck(@)
