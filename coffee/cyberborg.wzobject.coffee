# Warzone 2100 Objects
class WZObject
  constructor: (object) ->
    @copy(object)
    @is_wzobject = true
  copy: (object) ->
    @game_time = gameTime
    @[key] = object[key] for key of object

  update: () ->
    obj = objFromId(@)
    @x = obj.x
    @y = obj.y
    @z = obj.x
    @selected = obj.selected
    @health = obj.health
    @experience = obj.experience
    # TODO we should be able to maintain status and modules
    # @status = obj.status
    # @modules = obj.modules
    @order = obj.order # TODO we're going to maintain this

  namexy: () -> "#{@name}(#{@x},#{@y})"

  position: () -> x: @x, y: @y

  is_truck: () -> CyberBorg.is_truck(@)
  is_weapon: () -> CyberBorg.is_weapon(@)

  move_to: (at, number=DORDER_MOVE) ->
    if droidCanReach(@, at.x, at.y)
      orderDroidLoc(@, number, at.x, at.y)
      @order = number
      return true
    return false

  repair_structure: (built) ->
    if built.health < 99 #%
      if orderDroidObj(@, DORDER_REPAIR, built)
        @order = DORDER_REPAIR
        return true
    else
      return @move_to(built)

  maintain_structure: (structure, at) ->
    # Let's try to be a bit smarter....
    if built = cyberBorg.structure_at(at)
      return @repair_structure(built)
    else
      if orderDroidBuild(@,
      DORDER_BUILD, structure, at.x, at.y, at.direction)
        @order = DORDER_BUILD
        return true
    return false

  executes_dorder: (order) ->
    ok = false
    number = order.number
    at = order.at
    switch number
      when DORDER_ATTACK
        trace("TODO: need to implement number #{number}.") # TODO
      when DORDER_BUILD
        ok = @maintain_structure(order.structure, at)
      #when DORDER_CIRCLE
      #  trace("TODO: need to implement number #{number}.") # TODO
      #when DORDER_COMMANDERSUPPORT
      #  trace("TODO: need to implement number #{number}.") # TODO
      when DORDER_DEMOLISH
        trace("TODO: need to implement number #{number}.") # TODO
      #when DORDER_DESTRUCT
      #  trace("TODO: need to implement number #{number}.") # TODO
      when DORDER_DISEMBARK
        trace("TODO: need to implement number #{number}.") # TODO
      #when DORDER_DROIDREPAIR
      #  trace("TODO: need to implement number #{number}.") # TODO
      when DORDER_EMBARK
        trace("TODO: need to implement number #{number}.") # TODO
      when DORDER_FIRESUPPORT
        trace("TODO: need to implement number #{number}.") # TODO
      #when DORDER_GUARD
      #  trace("TODO: need to implement number #{number}.") # TODO
      when DORDER_HELPBUILD
        trace("TODO: need to implement number #{number}.") # TODO
      when DORDER_HOLD
        trace("TODO: need to implement number #{number}.") # TODO
      when DORDER_LINEBUILD
        trace("TODO: need to implement number #{number}.") # TODO
      when DORDER_MOVE, DORDER_SCOUT
        ok = @move_to(at, number)
      #when DORDER_NONE
      #  trace("TODO: need to implement number #{number}.") # TODO
      when DORDER_OBSERVE
        trace("TODO: need to implement number #{number}.") # TODO
      when DORDER_PATROL
        trace("TODO: need to implement number #{number}.") # TODO
      when DORDER_REARM
        trace("TODO: need to implement number #{number}.") # TODO
      when DORDER_RECOVER
        trace("TODO: need to implement number #{number}.") # TODO
      #when DORDER_RECYCLE
      #  trace("TODO: need to implement number #{number}.") # TODO
      when DORDER_REPAIR
        trace("TODO: need to implement number #{number}.") # TODO
      when DORDER_RETREAT
        trace("TODO: need to implement number #{number}.") # TODO
      when DORDER_RTB
        trace("TODO: need to implement number #{number}.") # TODO
      when DORDER_RTR
        trace("TODO: need to implement number #{number}.") # TODO
      #when DORDER_RTR_SPECIFIED
      #  trace("TODO: need to implement number #{number}.") # TODO
      #  trace("TODO: need to implement number #{number}.") # TODO
      when DORDER_STOP
        trace("TODO: need to implement number #{number}.") # TODO
      #when DORDER_TEMP_HOLD
      #  trace("TODO: need to implement number #{number}.") # TODO
      #when DORDER_UNUSED
      #  trace("TODO: need to implement number #{number}.") # TODO
      else
        trace("Order number #{number} not listed.") # TODO
    return ok

  executes: (order) ->
    ok = switch order.function
      when 'buildDroid'
        buildDroid(@,
        order.name, order.body, order.propulsion, "",
        order.droid_type, order.turret)
      when 'pursueResearch'
        if pursueResearch(@, order.research)
          @researching = order.research
          true
        else
          false
      else @executes_dorder(order)
    @order_time = gameTime if ok
    return ok
