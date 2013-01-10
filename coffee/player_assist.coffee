# This AI is currently being built for the 8 player Sk-Concrete map,
# first position (player 0), played with no bases, T1, and
# low power setting.  Hopefully, when done, I'll be able to then
# abstract it to any map.  So lets get CyberBorg to help us out.
cyberBorg = new CyberBorg()

# Really want to keep the number of globals down, but
# these are a convenience...
# Define the group names
BASE      = 'Base'	# will build the base
RESERVE   = 'Reserve'	# are the free units
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
  switch event.name
    when 'StartLevel'     then startLevel()
    when 'StructureBuilt' then structureBuilt(event.structure, event.droid, event.group)
    when 'DroidBuilt'     then droidBuilt(event.droid, event.structure)
    when 'DroidIdle'      then droidIdle(event.droid, event.group)
    when 'Researched'     then researched(event.research, event.structure)
    when 'Destroyed'      then destroyed(event.object, event.group)
    when 'Chat'           then chat(event.sender, event.to, event.message)
    # We should catch all possibilities, but in case we missed something...
    else trace("#{event.name} NOT HANDLED!")
  # Next see what orders the groups can execute
  group_executions(event)

# When Warzone 2100 starts the game, it calls eventStartLevel.
# eventStarLevel is WZ2100 JS API.
# StartLevel event is then switched here by events above.
startLevel = () ->
  # The game starts...
  
  # Usually the game starts out with some number of trucks,
  # or droids in general.  Let's see what we have.
  # Group is a class provided by CyberBorg.
  # The constructor by default picks up all of the player's pieces.
  # We'll put them in a reserve for now.
  # So the group name is RESERVE, and it'll have the lowest rank
  # among the groups, 0.
  # Rank is used to determine which group gets to pick units first.
  # Rank number will allow us to sort the groups by priority.
  # Groups with higher priority get first dibs on any action.
  reserve = new Group(RESERVE,0)
  
  # The Reserve group will hold the droids ready to join a group.
  # Other groups can release droids they no longer need
  # into the reserve, and draw droids they need from the reserve.
  # The reserve may anticipate the needs of other groups and
  # order droids around to where they may be likely needed.
  # Thus it may show some initiative, just as
  # individual droids may show some initiative.
  
  # cyberBorg can list all the resources available on the map and
  # sort them according to distance from where we are.
  # It will provide the AI a guide to our territorial expansion.
  resources = CyberBorg.get_resources(reserve.group.center())
  
  # We'll create many groups besides the Reserve, and
  # we'll keep them in cyberBorg.groups.
  groups = cyberBorg.groups
  groups.push(reserve)
  
  # For this AI, we won't order individual droids directly.
  # All orders will be given to groups, which
  # will then be relayed down to an individual droid.
  # The Base group will be responsible for building the base.
  # The group starts out empty, with [].
  # Also, from a datafile, we give the Base group its orders list.
  # The datafile defined the function that returns the group's orders.
  # For example, cyberBorg.base_orders in the case of BASE group.
  # Finally, the base needs the reserve group.
  base = new Group(BASE, 100, [],
  cyberBorg.base_orders(), reserve.group)
  groups.push(base)
  derricks = new Group(DERRICKS, 90, [],
  cyberBorg.derricks_orders(resources), reserve.group)
  groups.push(derricks)
  scouts = new Group(SCOUTS, 80, [],
  cyberBorg.scouts_orders(resources), reserve.group)
  groups.push(scouts)
  
  # Structures are also considered units the AI can order.
  # Let's have a factory group... etc.
  # So do use reserve for structure units, just as we do for droids...
  factories = new Group(FACTORIES, 20, [],
  cyberBorg.factory_orders(), reserve.group)
  groups.push(factories)
  labs = new Group(LABS, 19, [],
  cyberBorg.lab_orders(), reserve.group)
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
  group.remove(droid)
  # So every time we build a structure, this function gets called.
  # And the first thing that gets built is a Factory (as I first wrote this,
  # may change and become part of what the AI figures out later).
  # Anyways, when a factory gets built,
  # we need to get it started building droids.
  # So we push the structure into the RESERVE and
  # it should get picked up by the FACTORIES group in group_executions (below).
  cyberBorg.groups.named(RESERVE).group.push(structure)
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
      when HQ then min_map_and_design_on(structure)

# This turns on minimap and design.
# Will not be needed when this AI follows standard conventions.
min_map_and_design_on = (structure) ->
  if structure.player is selectedPlayer and
  structure.type is STRUCTURE and
  structure.stattype is HQ
    setMiniMap(true) # show minimap
    setDesign(true) # permit designs

#  When a droid is built, it triggers a droid built event and
#  eventDroidBuilt(a WZ2100 JS API) is called.
#  We're swithed to droidBuilt by events above.
droidBuilt = (droid, structure) ->
  # Now what with the new droid?
  # If it's a truck, maybe it should go to the nearest job?
  # Well, the style for this AI is to work with groups.
  # So what we'll do is add the new droids to the RESERVE.
  cyberBorg.groups.named(RESERVE).group.push(droid)
  # There may be ongoing jobs so let's see what available.
  helping(droid)

# helping is called whenever a droid finds itself idle, as
# when it first gets created.
helping = (object) ->
  reserve = cyberBorg.groups.named(RESERVE).group
  for group in cyberBorg.groups
    # TODO TBD what if group is reserve?
    continue if group is reserve
    order = group.orders.current()
    # So for each ongoing job, check if it'll take the droid.
    if order and
    order.help and order.help > 0 and
    order.like.test(object.name) and
    object.executes(order)
      # If droid is in RESERVE, we can add to the working group, but
      # otherwise the group owning the droid gets to recall.
      group.add(object) if reserve.contains(object)
      order.help -= 1
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
researched = (completed, structure) ->
  if structure # did we get the research from a structure?
    completed = completed.name # just interested in the name
    research = structure.researching
    unless research is completed
      structure.executes({function:'pursueResearch', research:research})

# A DroidIdle event occurs typically at the end of a move command.
# The droid arrives and awaits new orders.
# Origianally from eventDroidIdle,
# we're are switched here to droidIdle from events above.
droidIdle = (droid, group) ->
  # "I quuuiiiit!" says the droid.
  # "I wanna better job"
  group.remove(droid)
  # group not actually used, but might be usefull in the future.
  # Anything else?  :)
  helping(droid)

# This is the work horse of the AI.
# We iterate through all the groups,
# higher ranks first,
# and let them execute orders as they can.
group_executions = (event) ->
  groups = cyberBorg.groups
  # TODO TBD if a lower rank group releases droids, should we restart?
  # Maybe this should be broken up into phases.
  # A layoff phase followed by an employment phase.
  for group in groups
    name = group.name
    continue unless (name is FACTORIES) or (name is BASE) or (name is LABS) or
    (name is SCOUTS) or (name is DERRICKS)
    orders = group.orders
    order = orders.next()
    if order
      while order
        executers = group.execute(order)
        count = executers.length
        if count is 0
          orders.revert()
          break
        order = orders.next()

destroyed = (object, group) ->
  # There might me other stuff to do...
  # The object has been removed the the group already.
  # We're given object and group as reference.
