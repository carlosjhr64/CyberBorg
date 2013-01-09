# This AI is currently being built for the 8 player Sk-Concrete map,
# first position, played with no bases, T1.
# Hopefully, when done,  I'll be able to then abstract it to any map.
# So lets get CyberBorg to help us out.
cyberBorg = new CyberBorg()

# Define the group names
BASE      = 'Base'
RESERVE   = 'Reserve'
DERRICKS  = 'Derricks'
SCOUTS    = 'Scouts'
FACTORIES = 'Factories'
LABS      = 'Labs'

events = (event) ->
  cyberBorg.update()
  switch event.name
    when 'StartLevel' then startLevel()
    when 'StructureBuilt' then structureBuilt(event.structure, event.droid)
    when 'DroidBuilt' then droidBuilt(event.droid, event.structure)
    when 'DroidIdle' then droidIdle(event.droid)
    when 'Researched' then researched(event.research, event.structure)
    else debug("#{event.name} NOT HANDLED!")
  # Next see what the groups can execute
  group_executions(event)

# When Warzone 2100 starts the game, it calls eventStartLevel.
# eventStarLevel is WZ2100 JS API.
startLevel = () ->
  
  # The game starts...
  # Let's tell the player we're assisting.
  
  # Usually the game starts out with some number of trucks,
  # or droids in general.  Let's see what we have.
  # Group is a class provided by CyberBorg.
  # The constructor by default picks up all of the player's pieces.
  # We'll put them in a reserve for now.
  reserve = new Group(RESERVE,0)
  
  # The Reserve group will hold the droids ready to join a group.
  # Other groups can release droids they no longer need
  # into the reserve, and draw droids they need from the reserve.
  # The reserve may anticipate the needs of other groups and
  # order droids around to where they may be likely needed.
  # Thus it may show some initiative, just as
  # individual droids may show some initiative.
  # Let's tell the user how many units we have to start.
  #{reserve.group.counts(CyberBorg.is_truck)} of them are trucks."
  
  # cyberBorg can list all the resources available on the map and
  # sort them according to distance from where we are.
  # It will provide the AI a guide to our territorial expansion.
  resources = CyberBorg.get_resources(reserve.group.center())
  
  # So let's tell the player how many resource points there are.
  
  # We'll create many groups besides the Reserve, and
  # we'll list them in cyberBorg.groups.
  # We'll need to package in the array, name, and rank number.
  # Rank number will allow us to sort the groups by priority.
  # Groups with higher priority get fist dibs on any action.
  groups = cyberBorg.groups
  groups.push(reserve)
  
  # For this AI, we won't order individual droids directly.
  # All orders will be given to groups, which
  # will then be relayed down to an individual droid.
  # The Base group will be responsible for building the base.
  # The group starts out empty, with [].
  # Also, from the datafile, we give the Base group its orders list.
  # Finally, the base needs the reserve group.
  base = new Group(BASE, 100, [], cyberBorg.base_orders(), reserve.group)
  groups.push(base)
  derricks = new Group(DERRICKS, 90, [], cyberBorg.derricks_orders(resources), reserve.group)
  groups.push(derricks)
  scouts = new Group(SCOUTS, 80, [], cyberBorg.scouts_orders(resources), reserve.group)
  groups.push(scouts)
  
  # Structures are also considered units the AI can order.
  # Let's have a factory group... etc.  At this time,
  # the concept of a reserve does not look useful for structures, but
  # that could change.  Reserve just defaults to empty, [],
  # OK, we do use reserve as we are using the same abstractions as droids...
  factories = new Group(FACTORIES, 20, [], cyberBorg.factory_orders(), reserve.group)
  groups.push(factories)
  labs = new Group(LABS, 19, [], cyberBorg.lab_orders(), reserve.group)
  groups.push(labs)

  # This is probably the only time we'll need to sort groups.
  groups.sort (a, b) -> b.rank - a.rank
  
  # Our first concern is our base.
  # We'll build it up and here forth react to events in the game.
  # With only to trucks to start and base group with first dibs,
  # the AI guarantees that the first thing that happens
  # is that the base gets built.

#    When base group (or anyone else) builds a structure,
#    a "structure built" event triggers an eventStructureBuilt call.
#    eventStructureBuilt is WZ2100 JS API.
structureBuilt = (structure, droid) ->
  # So every time we build a structure, this function gets called.
  # Let's tell the player what got built.
  # namexy is a my hack on WZ2100's Object, which
  # returns the name and position of the game piece.

  # So the first thing that get built is a Factory.
  # It's just how this AI plays the game.
  # Another AI might choose a diffetent build order.
  # Anyways, when a factory gets built,
  # we need to get it started building droids.
  if (structure.type is STRUCTURE)
    groups = cyberBorg.groups
    switch structure.stattype
      when FACTORY then groups.named(FACTORIES).group.push(structure)
      when RESEARCH_LAB then groups.named(LABS).group.push(structure)
      when HQ then min_map_and_design_on(structure)
      # Because we've overridden rules.js eventStructureBuilt,
      # we need to need to enforce one of the rules in the game.
      # Unfortunately, rules.js is the human player's file.
      # We are in it's name space.
      # min_map_and_design_on turns on mini-map and design when HQ is built,
      # as per rules.js.
      # TODO check if this file is being runned by rules.js first.
      # May be being runned as a stand alone AI.


# This turns on minimap and design
# Will not be needed when this AI follows standard conventions.
min_map_and_design_on = (structure) ->
  if structure.player is selectedPlayer and
  structure.type is STRUCTURE and
  structure.stattype is HQ
    setMiniMap(true) # show minimap
    setDesign(true) # permit designs

# This is unit initiative?
helping = (object) ->
  reserve = cyberBorg.groups.named(RESERVE).group
  for group in cyberBorg.groups
    order = group.orders.current()
    if order and
    order.help and order.help > 0 and
    order.like.test(object.name) and
    object.executes(order)
      # If in reserved, we can add to group, but
      # otherwise the owning group gets to recall.
      group.add(object) if reserve.contains(object) # TODO TBD what if group is reserve?
      order.help -= 1
      return true
  return false

#  When a droid is built, it triggers a droid built event and
#  eventDroidBuilt(a WZ2100 JS API) is called.
droidBuilt = (droid, structure) ->
  # Tell the player what got built.
  
  # Now what with the new droid?
  # If it's a truck, maybe it should go to the nearest job?
  # Well, the style for this AI is to work with groups.
  # So what we'll do is add the new droids to the RESERVE.
  cyberBorg.groups.named(RESERVE).group.push(droid)
  helping(droid)

# Player commands...
# Some useful feedback and could be used for player commands.
chat = (sender, to, message) ->
  return null
  # TODO Just stop here for now

  cyberBorg.update()
  if sender is 0
    switch message
      when 'report base' then report('base')
      when 'report reserve' then report('reserve')
      else console("What?")

report = (who) ->
  return null
  # TODO Just stop here for now

  groups = cyberBorg.groups
  droids = []
  switch who
    when 'base'
      droids.push(droid.namexy()) for droid in groups.base.group
    when 'reserve'
      droids.push(droid.namexy()) for droid in groups.reserve.group
    else console("What???")

# The second structure that this AI builds is a research facility.
# When that happens, research_group gets called from eventStructureBuilt.
# This AI builds five research facilities (the standard limit).
# The AI also makes use of WZ2100 JS API's pursueResearch, which
# allows one to specify the desired technology rather than
# having to specify each technologyy in it's research path.
# This requires a bit a management.
#research_group = (structure, completed) ->
#  structure = new WZObject(structure)
#  orders = cyberBorg.groups.research.orders
#  # orders.of(structure) is the order previously given
#  # to the structure to pursue.
#  # orders.next(structure <-not doing this anymore) gives the next order for the structure.
#  # It may be that the structure was not already pursuing a research,
#  # so it's either or.
#  order = orders.of(structure) or orders.next(structure <- not  doing this )
#  # we need to know what the structure just got done researching, if anything.
#  if completed
#    pursuing #{order} got done with #{completed.name}."
#    # If we've reached the technology sought, then get the next order.
#    order = orders.next(structure <- not  doing this ) if order == completed.name
#    # Eventually, we run out of orders, so we need to check.
#  if order
#    # So let the player know what we're researching, and
#    # order the facilty to pursue it.
#    pursueResearch(structure, order)
#  else

# Every time a research facility is done researching a technology,
# a research event is triggered, and eventResearched is called.
# eventResearched is WZ2100 JS API.
# A new research tecnology can be acquired by picking up it's plan,
# which can be found from the ruins of a demolished facility.
# So we need to check that in fact
# the technology came from an active structure.
researched = (completed, structure) ->
  completed = completed.name # just interested in the name
  research = structure.researching
  structure.executes({function:'pursueResearch', research:research}) unless research is completed

droidIdle = (droid) ->
  # Anything else?  :)
  helping(droid)

  # I thinks this all goes away. :))
  #if groups.reserve.group.contains(droid)
  #  # groups that accept idle reserve droids
  #  groups.base.applying(droid) or
  #  groups.derricks_trucks.applying(droid) or
  #  groups.derricks_weapons.applying(droid)
  #if groups.derricks_trucks.group.contains(droid)
  #  derricks_trucks_group()
  #if groups.derricks_weapons.group.contains(droid)
  #  derricks_weapons_group()

#derricks_trucks_group = () ->
#  groups = cyberBorg.groups
#  derricks_trucks = groups.derricks_trucks
#  order = derricks_trucks.orders.next()
#  while order
#    builders = derricks_trucks.build(order)
#    # TODO if count is 0, either
#    # no trucks were found for the job or
#    # the structure was not available.  This is bad.
#    count = builders.length
#    if count is 0
#      derricks_trucks.orders.revert()
#      break
#    else
#      #{order.structure}(#{order.at.x},#{order.at.y})}."
#    order = derricks_trucks.orders.next()
#
#derricks_weapons_group = () ->
#  groups = cyberBorg.groups
#  derricks_weapons = groups.derricks_weapons
#  order = derricks_weapons.orders.next()
#  while order
#    fighters = derricks_weapons.execute(order)
#    # TODO if count is 0, then
#    # no weapons were found for the job.
#    count = fighters.length
#    if count is 0
#      derricks_weapons.orders.revert()
#      break
#    else
#      going to (#{order.at.x},#{order.at.y})}."
#    order = derricks_weapons.orders.next()

group_executions = (event) ->
  groups = cyberBorg.groups
  # TODO break out at full employment
  #break if reserve.length is 0 # TODO ?
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
