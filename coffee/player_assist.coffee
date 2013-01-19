# This AI is currently being built for the 8 player Sk-Concrete map,
# first position (player 0), played with no bases, T1, and
# low power setting.  Hopefully, when done, I'll be able to then
# abstract it to any map.  So lets get CyberBorg to help us out.
cyberBorg = new CyberBorg()

# Really want to keep the number of globals down, but
# these are a convenience...
# Define the group names
BASE      = 'Base'	# will build the base
DERRICKS  = 'Derricks'	# will build derricks
SCOUTS    = 'Scouts'	# will scout and guard the area
FACTORIES = 'Factories'	# builds droids
LABS      = 'Labs'	# research facilities

# Refactoring in this AI showed that it made sense to have a single
# event function pass an object describing the event.
# The original JS API event functions are found in cyberborg.events.coffee.
# After some data wrapping, the event data are funnel into a single event
# function here.
events = (event) ->
  cyberBorg.update()
  start_trace(event)

  switch event.name
    when 'StartLevel'
      startLevel()
    when 'StructureBuilt'
      structureBuilt(event.structure, event.droid, event.group)
    when 'DroidBuilt'
      droidBuilt(event.droid, event.structure, event.group)
    when 'DroidIdle'
      droidIdle(event.droid, event.group)
    when 'Researched'
      researched(event.research, event.structure, event.group)
    when 'Destroyed'
      destroyed(event.object, event.group)
    when 'Chat'
      chat(event.sender, event.to, event.message)
    # We should catch all possibilities, but in case we missed something...
    else red_alert("#{event.name} NOT HANDLED!")

  # Next see what commands the groups can execute
  group_executions(event)
  # Next, due to bugs either in this script or in the game...
  gotchas(event)

# When Warzone 2100 starts the game, it calls eventStartLevel.
# eventStarLevel is WZ2100 JS API.
# StartLevel event is then switched here by events above.
startLevel = () ->
  # The game starts...
 
  # Usually the game starts out with some number of trucks,
  # or droids in general.  Let's see what we have.
  # CyberBorg.enum_droid returns the units we currently have.
  # We'll put them in a reserve for now.
  cyberBorg.reserve = reserve = CyberBorg.enum_droid()

  # cyberBorg can list all the resources available on the map and
  # sort them according to distance from where we are.
  # It will provide the AI a guide to our territorial expansion.
  resources = CyberBorg.get_resources(reserve.center())

  # We'll create many groups besides the reserve, and
  # we'll keep them in cyberBorg.groups.
  groups = cyberBorg.groups

  # For this AI, we won't command individual droids directly.
  # All commands will be given to groups, which
  # will then be relayed down to an individual droid.
  # Group is a class provided by CyberBorg.
  # Rank is used to determine which group gets to pick units first.
  # Rank number will allow us to sort the groups by priority.
  # Groups with higher priority get first dibs on any action.
  # Groups can release droids they no longer need
  # into the reserve, and draw droids they need from the reserve.
  # The Base group will be responsible for building the base.
  # The group starts out empty, with [].
  # Also, from a datafile, we give the Base group its commands list.
  # The datafile defines the function that returns the group's commands.
  # For example, cyberBorg.base_commands in the case of BASE group.
  # Finally, the base needs the reserve list.

  base = new Group(BASE, 100, [],
  cyberBorg.base_commands(), reserve)
  groups.push(base)

  derricks = new Group(DERRICKS, 90, [],
  cyberBorg.derricks_commands(resources), reserve)
  groups.push(derricks)

  scouts = new Group(SCOUTS, 70, [],
  cyberBorg.scouts_commands(resources), reserve)
  groups.push(scouts)
  
  # Structures are also considered units the AI can command.
  # Let's have a factory group... etc.
  # So do use reserve for structure units, just as we do for droids...
  factories = new Group(FACTORIES, 20, [],
  cyberBorg.factory_commands(), reserve)
  groups.push(factories)
  labs = new Group(LABS, 19, [],
  cyberBorg.lab_commands(), reserve)
  groups.push(labs)

  # This is probably the only time we'll need to sort groups.
  groups.sort (a, b) -> b.rank - a.rank
  
  # Our first concern is our base.
  # We'll build it up and here forth react to events in the game.
  # With only two trucks (usually) to start and base group with first dibs,
  # the AI guarantees that the first thing that happens
  # is that the base gets built.

# When base group (or anyone else) builds a structure,
# a "structure built" event triggers an eventStructureBuilt call.
# eventStructureBuilt is WZ2100 JS API.
# We're then swithched to structureBuilt, here, from events.
structureBuilt = (structure, droid, group) ->
  # The droid is now free... goes to reserve.
  group.layoffs(droid.command) if droid.command
  # So every time we build a structure, this function gets called.
  # And the first thing that gets built is a Factory (as I first wrote this,
  # may change and become part of what the AI figures out later).
  # Anyways, when a factory gets built,
  # we need to get it started building droids.
  # So we push the structure into the RESERVE and
  # it should get picked up by the FACTORIES group in group_executions (below).
  cyberBorg.reserve.push(structure)
  # There may be exceptional catches to be done per structure...
  if (structure.type is STRUCTURE)
    switch structure.stattype
      # Because we've overridden rules.js eventStructureBuilt,
      # we need to need to enforce one of the rules in the game.
      # Unfortunately, rules.js is the human player's file.
      # We are in it's name space.
      # min_map_and_design_on turns on mini-map and design when HQ is built,
      # as per rules.js.
      # TODO check if this file is being runned by rules.js first.
      # May be being runned as a stand alone AI.
      when HQ then min_map_and_design(structure, true)
  # There may be ongoing jobs so let's see what available.
  helping(droid)

destroyed = (object, group) ->
  # There might be other stuff to do...
  # The object has been removed from the group already.
  # We're given object and group as reference.
  if object.type is STRUCTURE
    switch object.stattype
      when HQ then min_map_and_design(object, false)

# This turns on minimap and design.
# Will not be needed when this AI follows standard conventions.
min_map_and_design = (structure, flag) ->
  if structure.player is selectedPlayer and
  structure.type is STRUCTURE and
  structure.stattype is HQ
    cyberBorg.hq = flag
    setMiniMap(flag) # show minimap
    setDesign(flag) # permit designs

#  When a droid is built, it triggers a droid built event and
#  eventDroidBuilt(a WZ2100 JS API) is called.
#  We're swithed to droidBuilt by events above.
droidBuilt = (droid, structure, group) ->
  # Structure free
  group.layoffs(structure.command) if structure?.command
  # Now what with the new droid?
  # If it's a truck, maybe it should go to the nearest job?
  # Well, the style for this AI is to work with groups.
  # So what we'll do is add the new droids to the RESERVE.
  cyberBorg.reserve.push(droid)
  # There may be ongoing jobs so let's see what available.
  helping(droid)

# helping is called whenever a droid finds itself idle, as
# when it first gets created.
helping = (unit) ->
  for group in cyberBorg.groups
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
chat = (sender, to, message) ->
  words = message.split(/\s+/)
  if sender is 0
    switch words[0]
      when 'report' then report(words[1])
      # TODO some way to modify tha AI while in play?
      when 'reload' then include("multiplay/skirmish/reloads.js")
      # Toggle tracing
      when 'trace'
        green_alert("Tracing off.") if CyberBorg.TRACE
        CyberBorg.TRACE = !CyberBorg.TRACE
        green_alert("Tracing on.") if CyberBorg.TRACE
      else console("What?")

# Lists the units in the group by name and position.
# TODO could add more info like jobs in progress.
report = (who) ->
  if group = cyberBorg.groups.named(who)
    droids = []
    droids.push(droid.namexy()) for droid in group.list
    if droids.length then console(droids.join())
    else console("Group empty")
  else console("There is not group #{who}")

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
researched = (completed, structure, group) ->
  if structure # did we get the research from a structure?
    completed = completed.name # just interested in the name
    research = structure.researching
    command = structure.command
    if research is completed
      group.layoffs(command)
    else
      # assume stalled...
      cyberBorg.stalled.push(structure)

# A DroidIdle event occurs typically at the end of a move command.
# The droid arrives and awaits new commands.
# Origianally from eventDroidIdle,
# we're are switched here to droidIdle from events above.
droidIdle = (droid, group) ->
  # "You WUT???  No, I quuuiiiit!" says the droid.
  group.layoffs(droid.command) if droid.command
  # Anything else?  :)
  helping(droid)

# Right now, only research labs are expected in the list
stalled_units = () ->
  stalled = []
  while unit = cyberBorg.stalled.shift()
    command = unit.command
    # regardless of the command's execution, we  deduct from power
    # the command's cost to make subsequent commands aware of
    # the actual power available to them.
    cyberBorg.power -= command.cost
    if cyberBorg.power > command.power
      unless unit.executes(command)
        # Unexpected error... why would this ever happen?
        throw new Error(
          "#{structure.namexy()} could not pursue #{command.research}"
        )
    else
      # push unit into stalled list
      stalled.push(unit)
  cyberBorg.stalled = stalled

# This is the work horse of the AI.
# We iterate through all the groups,
# higher ranks first,
# and let them execute commands as they can.
group_executions = (event) ->
  groups = cyberBorg.groups
  # TODO TBD if a lower rank group releases droids, should we restart?
  # Maybe this should be broken up into phases.
  # A layoff phase followed by an employment phase.
  for group in groups
    name = group.name
    # For the sake of fairness to the human player,
    # this AI is crippled a bit without HQ.
    # Without HQ, only BASE, FACTORIES, and LABS group
    # continue the command cycle.
    continue unless cyberBorg.hq or
    name is BASE or name is FACTORIES or name is LABS
    commands = group.commands
    while command = commands.next()
      unless group.execute(command)
        commands.revert()
        break
  # For now, stalled units will be consider of lowest rank...
  stalled_units() # have any stalled unit try to excute their command.
