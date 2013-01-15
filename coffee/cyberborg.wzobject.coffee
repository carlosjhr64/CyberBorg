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
    # TODO z currently not used
    #@z = obj.x
    @selected = obj.selected
    @health = obj.health
    # TODO experience currently not used.
    # @experience = obj.experience
    # TODO try not to rely on order updates
    order = obj.order
    @order = order if order?
    # TODO we should be able to maintain status and modules
    # @status = obj.status
    # @modules = obj.modules

  namexy: () -> "#{@name}(#{@x},#{@y})"

  position: () -> x: @x, y: @y

  is_truck: () -> CyberBorg.is_truck(@)
  is_weapon: () -> CyberBorg.is_weapon(@)

  move_to: (at, order=DORDER_MOVE) ->
    if droidCanReach(@, at.x, at.y)
      orderDroidLoc(@, order, at.x, at.y)
      return true
    false

  repair_structure: (built) ->
    if built.health < 99 #%
      return orderDroidObj(@, DORDER_REPAIR, built)
    @move_to(built)

  build_structure: (structure, at) ->
    orderDroidBuild(@,
    DORDER_BUILD, structure, at.x, at.y, at.direction)

  maintain_structure: (structure, at) ->
    # Let's try to be a bit smarter....
    if built = cyberBorg.structure_at(at)
      return @repair_structure(built)
    @build_structure(structure, at)

  pursue_research: (research) ->
    if pursueResearch(@, research)
      @researching = research
      return true
    false

  build_droid: (command) ->
    buildDroid(@, command.name, command.body, command.propulsion, "",
    command.droid_type, command.turret)

  executes: (command) ->
    order = command.order
    at = command.at
    ok = switch order
      # ME STUFF
      when DORDER_MAINTAIN
        @maintain_structure(command.structure, at)
      when FORDER_MANUFACTURE
        @build_droid(command)
      when LORDER_RESEARCH
        @pursue_research(command.research)
      # STANDARD WZ JS
      when DORDER_BUILD
        @build_structure(command.structure, at)
      when DORDER_MOVE, DORDER_SCOUT
        @move_to(at, order)
      #when DORDER_ATTACK
      #  trace("TODO: need to implement order #{order}.") # TODO
      #when DORDER_CIRCLE
      #  trace("TODO: need to implement order #{order}.") # TODO
      #when DORDER_COMMANDERSUPPORT
      #  trace("TODO: need to implement order #{order}.") # TODO
      #when DORDER_DEMOLISH
      #  trace("TODO: need to implement order #{order}.") # TODO
      #when DORDER_DESTRUCT
      #  trace("TODO: need to implement order #{order}.") # TODO
      #when DORDER_DISEMBARK
      #  trace("TODO: need to implement order #{order}.") # TODO
      #when DORDER_DROIDREPAIR
      #  trace("TODO: need to implement order #{order}.") # TODO
      #when DORDER_EMBARK
      #  trace("TODO: need to implement order #{order}.") # TODO
      #when DORDER_FIRESUPPORT
      #  trace("TODO: need to implement order #{order}.") # TODO
      #when DORDER_GUARD
      #  trace("TODO: need to implement order #{order}.") # TODO
      #when DORDER_HELPBUILD
      #  trace("TODO: need to implement order #{order}.") # TODO
      #when DORDER_HOLD
      #  trace("TODO: need to implement order #{order}.") # TODO
      #when DORDER_LINEBUILD
      #  trace("TODO: need to implement order #{order}.") # TODO
      #when DORDER_NONE
      #  trace("TODO: need to implement order #{order}.") # TODO
      #when DORDER_OBSERVE
      #  trace("TODO: need to implement order #{order}.") # TODO
      #when DORDER_PATROL
      #  trace("TODO: need to implement order #{order}.") # TODO
      #when DORDER_REARM
      #  trace("TODO: need to implement order #{order}.") # TODO
      #when DORDER_RECOVER
      #  trace("TODO: need to implement order #{order}.") # TODO
      #when DORDER_RECYCLE
      #  trace("TODO: need to implement order #{order}.") # TODO
      #when DORDER_REPAIR
      #  trace("TODO: need to implement order #{order}.") # TODO
      #when DORDER_RETREAT
      #  trace("TODO: need to implement order #{order}.") # TODO
      #when DORDER_RTB
      #  trace("TODO: need to implement order #{order}.") # TODO
      #when DORDER_RTR
      #  trace("TODO: need to implement order #{order}.") # TODO
      #when DORDER_RTR_SPECIFIED
      #  trace("TODO: need to implement order #{order}.") # TODO
      #  trace("TODO: need to implement order #{order}.") # TODO
      #when DORDER_STOP
      #  trace("TODO: need to implement order #{order}.") # TODO
      #when DORDER_TEMP_HOLD
      #  trace("TODO: need to implement order #{order}.") # TODO
      #when DORDER_UNUSED
      #  trace("TODO: need to implement order #{order}.") # TODO
      else
        trace("#{order.order_map()}, ##{order}, un-implemented.")
        false
    # If the unit was able to take the command...
    if ok
      @order = command.order
      @command_time = gameTime
    return ok
