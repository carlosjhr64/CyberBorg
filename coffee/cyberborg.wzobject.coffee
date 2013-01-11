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
        trace("TODO: need to implement number #{number}.") # TODO
      when DORDER_BUILD
        # Let's try to be a bit smarter....
        if structure = cyberBorg.structure_at(at)
          if structure.health < 100 #%
            if orderDroidObj(@, DORDER_REPAIR, structure)
              ok = true
              @order = DORDER_REPAIR
          else
            # Job done!  :P
            # Let's just go to the site.
            pos = CyberBorg.get_free_spots(at)?.shuffle().first()
            pos = at unless pos
            if droidCanReach(@, pos.x, pos.y)
              orderDroidLoc(@, DORDER_MOVE, pos.x, pos.y)
              ok = true
              @order = DORDER_MOVE
        else
          if orderDroidBuild(@,
          DORDER_BUILD, order.structure, at.x, at.y, order.direction)
            ok = true
            @order = number
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
        pos = CyberBorg.get_free_spots(at)?.shuffle().first()
        pos = at unless pos
        if droidCanReach(@, pos.x, pos.y)
          orderDroidLoc(@, number, at.x, at.y)
          ok = true
          @order = number
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
        trace("DEBUG: Order number #{number} not listed.") # TODO
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
