# Warzone 2100 Objects
class WZObject
  constructor: (object) ->
    @copy(object)
    @is_wzobject = true
  copy: (object) ->
    @game_time = gameTime
    @corder = CyberBorg.IS_IDLE
    @dorder = CyberBorg.IS_IDLE
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

  build_structure: (structure, at) ->
    if orderDroidBuild(@,
    DORDER_BUILD, structure, at.x, at.y, at.direction)
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
    if (cyberBorg.hq or command.name is 'Truck') and
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
      else
        trace("#{order.order_map()}, ##{order}, un-implemented.")
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
