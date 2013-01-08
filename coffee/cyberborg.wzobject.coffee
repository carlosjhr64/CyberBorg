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

  namexy: () -> "#{@name}(#{@x},#{@y})"

  position: () -> x: @x, y: @y

  is_truck: () -> CyberBorg.is_truck(@)
  is_weapon: () -> CyberBorg.is_weapon(@)

  executes_dorder: (order) ->
    ok = false
    number = order.number
    at = order.at
    switch number
      when DORDER_ATTACK
        debug("TODO: need to implement number #{number}.") # TODO
      when DORDER_BUILD
        if orderDroidBuild(@, DORDER_BUILD, order.structure, at.x, at.y, order.direction)
          ok = true
          @order = number
      #when DORDER_CIRCLE
      #  debug("TODO: need to implement number #{number}.") # TODO
      #when DORDER_COMMANDERSUPPORT
      #  debug("TODO: need to implement number #{number}.") # TODO
      when DORDER_DEMOLISH
        debug("TODO: need to implement number #{number}.") # TODO
      #when DORDER_DESTRUCT
      #  debug("TODO: need to implement number #{number}.") # TODO
      when DORDER_DISEMBARK
        debug("TODO: need to implement number #{number}.") # TODO
      #when DORDER_DROIDREPAIR
      #  debug("TODO: need to implement number #{number}.") # TODO
      when DORDER_EMBARK
        debug("TODO: need to implement number #{number}.") # TODO
      when DORDER_FIRESUPPORT
        debug("TODO: need to implement number #{number}.") # TODO
      #when DORDER_GUARD
      #  debug("TODO: need to implement number #{number}.") # TODO
      when DORDER_HELPBUILD
        debug("TODO: need to implement number #{number}.") # TODO
      when DORDER_HOLD
        debug("TODO: need to implement number #{number}.") # TODO
      when DORDER_LINEBUILD
        debug("TODO: need to implement number #{number}.") # TODO
      when DORDER_MOVE, DORDER_SCOUT
        if orderDroidLoc(@, number, at.x, at.y)
          ok = true
          @order = number
      #when DORDER_NONE
      #  debug("TODO: need to implement number #{number}.") # TODO
      when DORDER_OBSERVE
        debug("TODO: need to implement number #{number}.") # TODO
      when DORDER_PATROL
        debug("TODO: need to implement number #{number}.") # TODO
      when DORDER_REARM
        debug("TODO: need to implement number #{number}.") # TODO
      when DORDER_RECOVER
        debug("TODO: need to implement number #{number}.") # TODO
      #when DORDER_RECYCLE
      #  debug("TODO: need to implement number #{number}.") # TODO
      when DORDER_REPAIR
        debug("TODO: need to implement number #{number}.") # TODO
      when DORDER_RETREAT
        debug("TODO: need to implement number #{number}.") # TODO
      when DORDER_RTB
        debug("TODO: need to implement number #{number}.") # TODO
      when DORDER_RTR
        debug("TODO: need to implement number #{number}.") # TODO
      #when DORDER_RTR_SPECIFIED
      #  debug("TODO: need to implement number #{number}.") # TODO
      #  debug("TODO: need to implement number #{number}.") # TODO
      when DORDER_STOP
        debug("TODO: need to implement number #{number}.") # TODO
      #when DORDER_TEMP_HOLD
      #  debug("TODO: need to implement number #{number}.") # TODO
      #when DORDER_UNUSED
      #  debug("TODO: need to implement number #{number}.") # TODO
      else
        debug("DEBUG: Order number #{number} not listed.") # TODO
    return ok

  executes: (order) ->
    ok = switch order.function
      when 'buildDroid'
        buildDroid(@, order.name, order.body, order.propulsion, "", order.droid_type, order.turret)
      when 'pursueResearch' then pursueResearch(@, order.research)
      else @executes_dorder(order)
    @order_time = gameTime if ok
    return ok
