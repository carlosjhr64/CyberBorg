# This AI is currently being built for the 8 player Sk-Concrete map,
# first position (player 0), played with no bases, T1, and
# low power setting.  Hopefully, when done, I'll be able to then
# abstract it to any map.  So lets get CyberBorg to help us out.

class Ai
  @RESERVE = 'Reserve'

  constructor: () ->
    @trace = new Trace()
    @hq = false
    @power = null # Used to keep track of power consumption.
    @groups = Groups.bless([])
    # Stalled units waiting for enough power to continue their command
    @stalled = []
    @gotcha = new Gotcha(@)

  update: (event) ->
    @power = playerPower(me)
    @groups.update()
    @gotcha.start(event)	if @trace.on

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
      when 'Chat'
        @chat(event.sender, event.to, event.message)
      # We should catch all possibilities, but in case we missed something...
      else @trace.red("#{event.name} NOT HANDLED!")

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
    @groups.reserve = CyberBorg.enum_droid()
    script(@)
    # This is probably the only time we'll need to sort groups.
    @groups.sort (a, b) -> a.rank - b.rank

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
    @groups.reserve.push(structure)
    # There may be exceptional catches to be done per structure...
    if structure.type is STRUCTURE
      switch structure.stattype
        when HQ then @hq = true
    # There may be ongoing jobs so let's see what available.
    @helping(droid)

  destroyed: (object, group) ->
    # There might be other stuff to do...
    # The object has been removed from the group already.
    # We're given object and group as reference.
    if object.player is me and object.type is STRUCTURE
      switch object.stattype
        when HQ then @hq = false

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
    @groups.reserve.push(droid)
    # There may be ongoing jobs so let's see what available.
    @helping(droid)

  # helping is called whenever a droid finds itself idle, as
  # when it first gets created.
  helping: (unit) ->
    for group in @groups
      command = group.commands.current()
      cid = command?.cid
      # So for each ongoing job, check if it'll take the droid.
      if cid and (help_wanted = command.help) and command.like.test(unit.name)
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
        # In reloads.js, I have code that can be safely edited and reloaded
        # while in play.  Mostly contains tracing, but also contains in play
        # bug fixes.
        when 'reload' then include("multiplay/skirmish/cyberborg-reloads.js")
        # Toggle tracing
        when 'trace'
          @trace.green("Tracing off.") if @trace.on
          @trace.on = !@trace.on
          @trace.green("Tracing on.") if @trace.on
        else console("What?")

  # Lists the units in the group by name, position, 'n stuff.
  report: (who) ->
    if who is Ai.RESERVE
      list = @groups.reserve
    else
      list = @groups.named(who)?.list
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
      research = structure.researching
      command = structure.command
      if research is completed
        group.layoffs(command)
      else
        # assume stalled...
        @stalled.push(structure)

  # A DroidIdle event occurs typically at the end of a move command.
  # The droid arrives and awaits new commands.
  # Originally from eventDroidIdle,
  # we're are switched here to droidIdle from events above.
  droidIdle: (droid, group) ->
    # "You WUT???  No, I quuuiiiit!" says the droid.
    group.layoffs(droid.command) if droid.command
    # Anything else?  :)
    @helping(droid)

  # Right now, only research labs are expected in the list
  stalled_units: () ->
    stalled = []
    while unit = @stalled.shift()
      command = unit.command
      # regardless of the command's execution, we  deduct from power
      # the command's cost to make subsequent commands aware of
      # the actual power available to them.
      @power -= command.cost
      if @power > command.power
        unless unit.executes(command)
          # Unexpected error... why would this ever happen?
          order = command.order.order_map()
          @trace.red "#{unit.name} could not execute #{order}"
          @trace.red "\t#{command.research}" if command.research
      else
        # push unit into stalled list
        stalled.push(unit)
    @stalled = stalled

  has: (power) ->
    if power?
      # Has enough power
      return true if @power >= power
      # Not enough power
      return false
    # No power requirements
    return true

  # This is the work horse of the AI.
  # We iterate through all the groups,
  # higher ranks first,
  # and let them execute commands as they can.
  group_executions: (event) ->
    for group in @groups
      name = group.name
      # For the sake of fairness to the human player,
      # this AI is crippled a bit without HQ.
      # Without HQ, only BASE, FACTORIES, and LABS group
      # continue the command cycle.
      continue unless @hq or base_group(name)
      commands = group.commands
      while command = commands.next()
        # We regardless deduct the command cost from available power b/c
        # we want to make the lower ranks aware of the power
        # actually available for them... that we're saving toward this
        # command's goals.
        @power -= command.cost
        unless @has(command.power) and group.execute(command)
          # If we are not able to execute the command,
          # deduct additional amount we want to save for.
          @power -= command.savings if command.savings?
          commands.revert()
          break
        @gotcha.command(command) if @trace.on
    # For now, stalled units will be consider of lowest rank...
    @stalled_units() # have any stalled unit try to execute their command.
