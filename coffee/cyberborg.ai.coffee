# This AI is currently being built for the 8 player Sk-Concrete map,
# first position (player 0), played with no bases, T1, and
# low power setting.  Hopefully, when done, I'll be able to then
# abstract it to any map.  So lets get CyberBorg to help us out.

class Ai
  constructor: () ->
    @hq = false
    @power = null # Used to keep track of power consumption.
    # Stalled units waiting for enough power to continue their command
    @stalled = []
    @dead = []
    @resurrects = {}
    @location = new Location()
    @gotcha = new Gotcha(@)
    @recycle_on_damage = 50.0
    @repair_on_damage = 50.0
    @repair_available = false
    @too_dangerous_level() # Sets @too_dangerous and @chances

  update: (event) ->
    @too_dangerous_level() # Updates @too_dangerous and @chances
    @power = CyberBorg.get_power()
    GROUPS.update()
    @gotcha.start(event)	if Trace.on

  switches: (event) ->
    switch event.name
      when 'StartLevel'
        @startLevel()
      when 'StructureBuilt'
        @structureBuilt(event.structure, event.droid, event.group)
      when 'DroidBuilt'
        @droidBuilt(event.droid, event.structure, event.group)
      when 'DroidIdle'
        @droidIdle(event.droid, event.group)
      when 'Researched'
        @researched(event.research, event.structure, event.group)
      when 'Destroyed'
        @destroyed(event.object, event.group)
      when 'ObjectSeen'
        @objectSeen(event.sensor, event.object, event.group)
      when 'Attacked'
        @attacked(event.victim, event.attacker, event.group)
      when 'Chat'
        @chat(event.sender, event.to, event.message)
      # We should catch all possibilities, but in case we missed something...
      else Trace.red("#{event.name} NOT HANDLED!")

  # Refactoring in this AI showed that it made sense to have a single
  # event function pass an object describing the event.
  # The original JS API event functions are found in cyberborg.events.coffee.
  # After some data wrapping, the event data are funnel into a single event
  # function here.
  events: (event) ->
    @update(event)
    @switches(event)
    # Next see what commands the groups can execute
    @group_executions(event)
    # Next, due to bugs either in this script or in the game...
    @gotcha.end(event)

  # When Warzone 2100 starts the game, it calls eventStartLevel.
  # eventStarLevel is WZ2100 JS API.
  # StartLevel event is then switched here by events above.
  startLevel: () ->
    # The game starts...
    # Usually the game starts out with some number of trucks,
    # or droids in general.  Let's see what we have.
    # CyberBorg.enum_droid returns the units we currently have.
    # We'll put them in a reserve for now.
    Groups.RESERVE.push(droid) for droid in CyberBorg.enum_droid()
    @script()

  # When base group (or anyone else) builds a structure,
  # a "structure built" event triggers an eventStructureBuilt call.
  # eventStructureBuilt is WZ2100 JS API.
  # We're then swithched to structureBuilt, here, from events.
  structureBuilt: (structure, droid, group) ->
    # The droid is now free... goes to reserve.
    group.layoffs(droid.command) if droid.command
    # So every time we build a structure, this function gets called.
    # And the first thing that gets built is a Factory (as I first wrote this,
    # may change and become part of what the AI figures out later).
    # Anyways, when a factory gets built, we need to get it started building
    # droids. So we push the structure into the reserve and it should get
    # picked up by the FACTORIES group in group_executions (below).
    Groups.RESERVE.push(structure)
    # There may be exceptional catches to be done per structure...
    if structure.type is STRUCTURE
      switch structure.stattype
        when HQ then @hq = true
    # There may be ongoing jobs so let's see what available.
    @helping(droid)

  location_costs: (at, cost=at.cost) ->
    # Want cummulative costs
    cost = (@location.value(at) || 0.0) + cost
    @location.value(at, cost)
    if Trace.on
      Trace.out "Cummulative costs at #{at.x},#{at.y} are $#{cost}."
      if cost > @too_dangerous
        Trace.green "Area is now set as dangerous!"

  destroyed: (object, group) ->
    # There might be other stuff to do...
    # The object has been removed from the group already.
    # We're given object and group as reference.
    if object.player is me
      switch object.type
        when STRUCTURE
          if @resurrects[object.namexy()]?
            @dead.push(object)
          @location_costs(object)
          switch object.stattype
            when HQ then @hq = false
        when DROID
          if @resurrects[object.name]?
            @dead.push(object)
          if at = object.command?.at
            @location_costs(at, object.cost)

  #  When a droid is built, it triggers a droid built event and
  #  eventDroidBuilt(a WZ2100 JS API) is called.
  #  We're swithed to droidBuilt by events above.
  droidBuilt: (droid, structure, group) ->
    # Structure free
    group.layoffs(structure.command) if structure?.command
    # Now what with the new droid?
    # If it's a truck, maybe it should go to the nearest job?
    # Well, the style for this AI is to work with groups.
    # So what we'll do is add the new droids to the reserve.
    Groups.RESERVE.push(droid)
    # There may be ongoing jobs so let's see what available.
    @helping(droid)

  # helping is called whenever a droid finds itself idle, as
  # when it first gets created.
  helping: (unit) ->
    for group in GROUPS
      command = group.commands.current()
      cid = command?.cid
      # So for each ongoing job, check if it'll take the droid.
      if cid and (help_wanted = command.help) and command.like.test(unit.name)
        continue if @dangerous(command)
        employed = group.list.counts_in_cid(cid)
        if employed < help_wanted and unit.executes(command)
          unit.command = command
          group.add(unit)
          return true
    return false

  # Player commands...
  # Some useful feedback and could be used for player commands.
  chat: (sender, to, message) ->
    words = message.split(/\s+/)
    if sender is me
      switch words[0]
        when 'report' then @report(words[1])
        when 'trace'
          # Toggle tracing
          Trace.green("Tracing off.") if Trace.on
          Trace.on = !Trace.on
          Trace.green("Tracing on.") if Trace.on
        #else console("What?")

  # Lists the units in the group by name, position, 'n stuff.
  report: (who) ->
    if who is 'Reserve'
      list = Groups.RESERVE
    else
      list = GROUPS.named(who)?.list
    if list
      empty = true
      for droid in list
        empty &&= false
        console "#{droid.namexy()} " +
        "corder:#{droid.corder?.order_map()} " +
        "dorder:#{droid.dorder?.order_map()} " +
        "order:#{droid.order?.order_map()} " +
        "health:#{droid.health}%"
      console "Group currently empty." if empty
    else console "There is not group #{who}"

  # The second structure that this AI builds is a research facility.
  # This AI may build five research facilities (the standard limit,
  # and again as first written).  The AI also makes use of
  # WZ2100 JS API's pursueResearch, which allows one to specify
  # the desired technology rather than having to specify
  # each technology in it's research path.
  # This requires a bit a management.
  # Every time a research facility is done researching a technology,
  # a Researched event is triggered, and eventResearched is called.
  # eventResearched is WZ2100 JS API.
  # We're switch here to researched from events above.
  # A new research tecnology can be acquired by picking up it's plan,
  # which can be found from the ruins of a demolished facility.
  # So we need to check that in fact
  # the technology came from an active structure.
  researched: (completed, structure, group) ->
    if structure # did we get the research from a structure?
      completed = completed.name # just interested in the name
      if command = structure.command
        research = structure.researching
        if research is completed
          group.layoffs(command)
        else
          # assume stalled...
          @stalled.push(structure)
      else
        # This happens when human player intervenes
        Trace.red "#{structure.namexy()} completed #{completed} without attached command."

  # A DroidIdle event occurs typically at the end of a move command.
  # The droid arrives and awaits new commands.
  # Originally from eventDroidIdle,
  # we're are switched here to droidIdle from events above.
  droidIdle: (droid, group) ->
    # "You WUT???  No, I quuuiiiit!" says the droid.
    group.layoffs(droid.command) if droid.command
    # Anything else?  :)
    @helping(droid)

  objectSeen: (sensor, object, group) ->
    # These should be short oppotunity orders...
    if object.droidType is DROID_CONSTRUCT
      attackers = GROUPS.droid_weapons_nearest(object, 3)
      for attacker in attackers
        orderDroidObj(attacker, DORDER_ATTACK, object)
      if Trace.on
        Trace.blue "#{attackers.length} attacking seen #{object.namexy()}"
    else if object.stattype is OIL_DRUM
      orderDroidObj(sensor, DORDER_RECOVER, object)
      if Trace.on
        Trace.blue "#{sensor.namexy()} recovers #{object.namexy()}"
    else
      if Trace.on
        Trace.out "#{sensor.namexy()} spies #{object.namexy()}"


  attacked: (victim, attacker, group) ->
    unless group?
      Trace.red "#{victim.namexy()} not in a group"
    defenders = GROUPS.droid_weapons_nearest(attacker, 3)
    for defender in defenders
      orderDroidObj(defender, DORDER_ATTACK, attacker)
    if victim.type is DROID
      # Tactic 1: Move away from attacker
      vx = victim.x
      vy = victim.y
      ax = attacker.x
      ay = attacker.y
      x = ((vx - ax)/2.0).to_i() + vx
      y = ((vy - ay)/2.0).to_i() + vy
      # If there are defenders...
      if first = defenders.first()
        # Tactic 2: Move towards nearest defender
        x2 = ((2.0*first.x + vx)/3.0).to_i()
        y2 = ((2.0*first.y + vy)/3.0).to_i()
        # Pick the tactic that places you farthest away from attacker!
        dx = ax - x
        dy = ay - y
        dx2 = ax - x2
        dy2 = ay - y2
        if dx2*dx2+dy2*dy2 > dx*dx+dy*dy
          x = x2
          y = y2
      if droidCanReach(victim, x, y)
        orderDroidLoc(victim, DORDER_MOVE, x, y)
      else
        # A bit of a failsafe.
        orderDroid(victim, DORDER_RTB)
    if Trace.on
      Trace.blue "#{defenders.length} attacking #{attacker.namexy()}"

  has: (power) ->
    if power?
      # Has enough power
      return true if @power >= power
      # Not enough power
      return false
    # No power requirements
    return true

  # Right now, only research labs are expected in the list
  stalled_units: () ->
    stalled = []
    while unit = @stalled.shift()
      if command = unit.command
        # regardless of the command's execution, we  deduct from power
        # the command's cost to make subsequent commands aware of
        # the actual power available to them.
        @power -= command.cost
        if @has(command.power)
          unless unit.executes(command)
            # Unexpected error... why would this ever happen?
            order = command.order.order_map()
            Trace.red "#{unit.name} could not execute #{order}"
            Trace.red "\t#{command.research}" if command.research
            if group = GROUPS.finds(unit)?.group
              # TODO TBD so layoffs the entire command?
              group.layoffs(command)
        else
          # push unit into stalled list
          stalled.push(unit)
      else
        Trace.red "Stalled #{unit.namexy()} did not have command."
    @stalled = stalled

  executes: (group, command) ->
    # We regardless deduct the command cost from available power b/c
    # we want to make the lower ranks aware of the power
    # actually available for them... that we're saving toward this
    # command's goals.
    @power -= command.cost
    unless @has(command.power) and group.execute(command)
      # If we are not able to execute the command,
      # deduct additional amount we want to save for.
      @power -= command.savings if command.savings?
      return false
    @gotcha.command(command) if Trace.on
    true

  resurrection: () ->
    dead = []
    for object in @dead
      name = object.name
      if object.type is STRUCTURE
        name = WZObject.namexy(name, object.x, object.y)
      if group_command = @resurrects[name]
        continue if @dangerous(group_command.last())
        if @executes(group_command...)
          Trace.blue "Resurrection!" if Trace.on
        else
          dead.push(object)
      else
        Trace.red "Error: no resurrection command for #{name}."
    @dead = dead

  routing: () ->
    for droid in GROUPS.for_all((object) -> object.type is DROID)
      # These route orders are not given as part of a group.
      # Rallying possible?
      if @repair_available
        if droid.health < @repair_on_damage
          if orderDroid(droid, DORDER_RTR)
            Trace.blue "#{droid.namexy()} to repair." if Trace.on
      else if droid.health < @recycle_on_damage
        if orderDroid(droid, DORDER_RECYCLE)
          Trace.blue "#{droid.namexy()} to recycle." if Trace.on

  dangerous: (command) ->
    # Enemy has made this location too expensive, so skip it?
    unless at = command.at
      return false
    if danger = @location.value(at)
      if danger > @too_dangerous
        # Give it a chance, about 1 in chances,
        # of doing something dangerous.
        # This also avoids loops of not doing anything.
        if Math.random() > @too_dangerous / (@chances*danger)
          return true
        else
          @location.value(at, 0)
          if Trace.on
            Trace.green "Re-classifying area #{at.x},#{at.y} as OK."
    false

  repairs: () ->
    # Healthy available trucks
    trucks = GROUPS.for_all(
      (obj) ->
        obj.droidType is DROID_CONSTRUCT and
        obj.health > AI.repair_on_damage
    )
    # Damaged resurrectable structures sorted by damage
    structures = GROUPS.for_all((obj) -> obj.type is STRUCTURE)
    structures = structures.filters((obj) -> obj.health < AI.repair_on_damage)
    # Basically, the structure must have been built under DORDER_MAINTAINANCE
    structures = structures.filters((obj) -> AI.resurrects[obj.namexy()]?)
    structures.sort((a,b) -> a.health - b.health)
    # Each structure repaired by the next nearest truck
    while structures.length and trucks.length
      structure = structures.shift()
      # Sort trucks by distance from structure
      trucks.nearest(structure)
      truck = trucks.shift()
      # If truck order is already DORDER_REPAIR,
      # just assume the structure is already being taken cared of.
      unless truck.order is DORDER_REPAIR
        if orderDroidObj(truck, DORDER_REPAIR, structure)
          if Trace.on
            Trace.blue "#{truck.namexy()} to repair #{structure.namexy()}."
    if trucks.length
      structures = CyberBorg.get_unbuilt_structures()
      while structures.length and trucks.length
        structure = structures.shift()
        trucks.nearest(structure)
        truck = trucks.shift()
        # If the truck order is already *build*,
        # just assume the structure is being taken cared of.
        unless truck.order is DORDER_HELPBUILD or
        truck.order is DORDER_BUILD
          if orderDroidObj(truck, DORDER_HELPBUILD, structure)
            if Trace.on
              Trace.blue "#{truck.namexy()} to build #{structure.namexy()}."

  # This is the work horse of the AI.
  # We iterate through all the groups,
  # higher ranks first,
  # and let them execute commands as they can.
  group_executions: (event) ->
    # Resurection orders are of highest rank in this AI.
    @resurrection()
    # This AI will order heavily damaged units to repair/recycle
    @routing()
    # This AI will order trucks to repair nearby structures
    @repairs()
    promotions = []
    for group in GROUPS
      name = group.name
      # For the sake of fairness to the human player,
      # this AI is crippled a bit without HQ.
      # Without HQ, only BASE, FACTORIES, and LABS group
      # continue the command cycle.
      continue unless @hq or @base_group(name)
      if name is LABS
        # So far stalled units are labs.
        # In any case, they'll execute just prior to the group itself.
        @stalled_units() # have any stalled unit try to execute their command.
      commands = group.commands
      while command = commands.next()
        continue if @dangerous(command)
        unless @hq or @allowed_hqless(command)
          commands.revert()
          break
        unless @executes(group, command)
          commands.revert()
          break
        if command.promote?
          promotions.push([name, command.promote])
        if name = command.name
          order = command.order
          if order is FORDER_MANUFACTURE
            @resurrects[name] = [group, command]
          else if order is DORDER_MAINTAIN
            at = command.at
            pos = at unless pos = Location.picked(at)
            name = WZObject.namexy(name, pos.x, pos.y)
            @resurrects[name] = [group, command]
    for name_promote in promotions
      if GROUPS.promote(name_promote...)
        if Trace.on
          Trace.blue("New Group Order:")
          for group in GROUPS
            Trace.blue "\t#{group.name}"
