# Warzone 2100 Objects
class WZObject
  constructor: (object) ->
    @copy(object)
    @is_wzobject = true
  copy: (object) ->
    @game_time = gameTime
    @corder = IS_LAIDOFF
    @dorder = IS_LAIDOFF
    @[key] = object[key] for key of object

  update: () ->
    obj = objFromId(@)
    @x = obj.x
    @y = obj.y
    # todo: z currently not used
    #@z = obj.x
    @selected = obj.selected
    @health = obj.health
    # todo: experience currently not used.
    # @experience = obj.experience
    # todo: try not to rely on order updates
    order = obj.order
    @order = order if order?
    # todo: we should be able to maintain status and modules
    # @status = obj.status
    # @modules = obj.modules

  namexy: () -> "#{@name}(#{@x},#{@y})"

  position: () -> x: @x, y: @y

  is_truck: () -> CyberBorg.is_truck(@)
  is_weapon: () -> CyberBorg.is_weapon(@)

  move_to: (at, order=DORDER_MOVE) ->
    if droidCanReach(@, at.x, at.y)
      orderDroidLoc(@, order, at.x, at.y)
      @order = order
      return true
    false

  repair_structure: (built) ->
    if built.health < 99 #%
      if orderDroidObj(@, DORDER_REPAIR, built)
        @order = DORDER_REPAIR
        return true
      else
        return false
    @move_to(built)

  pick_struct_location: (structure, at) ->
    # If it's a derrick, that position is well defined.
    # Just give at back in that case.
    return at if structure is 'A0ResourceExtractor'
    # We may already have a positon hashed.
    pos = cyberBorg.location(at)
    unless pos
      pos = pickStructLocation(@, structure, at.x, at.y)
      if pos
        # Hash the position so as to not have to call pickStructLocation again.
        cyberBorg.location(at, pos)
        unless pos.x is at.x and pos.y is at.y
          # We don't like changes to our AI.
          # WUT U DO!???
          ai.trace.red "Game AI moved build #{structure} "+
          "from #{at.x},#{at.y} to #{pos.x},#{pos.y}"
    pos

  build_structure: (structure, at) ->
    if pos = @pick_struct_location(structure, at)
      if orderDroidBuild(@,
      DORDER_BUILD, structure, pos.x, pos.y, at.direction)
        @order = DORDER_BUILD
        return true
    false

  # Let's try to be a bit smarter....
  maintain_structure: (structure, at) ->
    if built = cyberBorg.structure_at(at)
      return @repair_structure(built)
    @build_structure(structure, at)

  pursue_research: (research) ->
    if pursueResearch(@, research)
      @researching = research
      @order = LORDER_RESEARCH
      return true
    false

  build_droid: (command) ->
    # For the sake of fairness to the human player,
    # this AI is crippled a bit without HQ.
    # Without HQ, factories can only build trucks.
    if (ai.hq or allowed_hqless_build(command)) and
    buildDroid(@, command.name, command.body, command.propulsion, "",
    command.droid_type, command.turret)
      @order = FORDER_MANUFACTURE
      return true
    false

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
      when CORDER_PASS
        @order = CORDER_PASS
        true
      else
        ai.trace.red "#{order.order_map()}, ##{order}, un-implemented."
        false
    # If the unit was able to take the command...
    if ok
      # corder is not always the actual order implemented.
      @corder = command.order
      # The game's AI may intervene and change the unit's order,
      # so we keep this AI's orginal dorder.
      @dorder = @order
      # As of the time of this comment, command_time is not used, but
      # was previously useful, may be useful later.
      @command_time = gameTime
    return ok
