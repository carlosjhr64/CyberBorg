# This AI is currently being built for the 8 player Sk-Concrete map,
# first position, played with no bases, T1.
# Hopefully, when done,  I'll be able to then abstract it to any map.
# So lets get CyberBorg to help us out.
cyberBorg = new CyberBorg()

# When Warzone 2100 starts the game, it calls eventStartLevel.
# eventStarLevel is WZ2100 JS API.
eventStartLevel = ->
  
  # The game starts...
  # Let's tell the player we're assisting.
  console "This is player_assist.js"
  
  # Usually the game starts out with some number of trucks,
  # or droids in general.  Let's see what we have.
  # Group is a class provided by CyberBorg.
  # The constructor by default picks up all of the player's pieces.
  # We'll put them in a reserve for now.
  reserve = new Group('Reserve',0)
  
  # The Reserve group will hold the droids ready to join a group.
  # Other groups can release droids they no longer need
  # into the reserve, and draw droids they need from the reserve.
  # The reserve may anticipate the needs of other groups and
  # order droids around to where they may be likely needed.
  # Thus it may show some initiative, just as
  # individual droids may show some initiative.
  # Let's tell the user how many units we have to start.
  console "We have #{reserve.group.length} droids available, and
  #{reserve.group.counts(CyberBorg.is_truck)} of them are trucks."
  
  # cyberBorg can list all the resources available on the map and
  # sort them according to distance from where we are.
  # It will provide the AI a guide to our territorial expansion.
  resources = CyberBorg.get_resources(reserve.group.center())
  
  # So let's tell the player how many resource points there are.
  console "There are #{resources.length} resource points."
  
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
  base = new Group('Base', 100, [], cyberBorg.base_orders(), reserve.group)
  groups.push(base)
  derricks = new Group('Derricks', 90, [], cyberBorg.derricks_orders(resources), reserve.group)
  groups.push(derricks)
  scouts = new Group('Scouts', 80, [], cyberBorg.scouts_orders(resources), reserve.group)
  groups.push(scouts)
  
  # Structures are also considered units the AI can order.
  # Let's have a factory group... etc.  At this time,
  # the concept of a reserve does not look useful for structures, but
  # that could change.  Reserve just defaults to empty, [],
  factories = new Group('Factories', 20, [], cyberBorg.factory_orders())
  groups.push(factories)
  labs = new Group('Labs', 19, [], cyberBorg.lab_orders())
  groups.push(labs)

  # This is probably the only time we'll need to sort groups.
  groups.sort (a, b) -> b.rank - a.rank
  
  # Our first concern is our base.
  # We'll build it up and here forth react to events in the game.
  # With only to trucks to start and base group with first dibs,
  # the AI guarantees that the first thing that happens
  # is that the base gets built.
  group_executions()

#    When base group (or anyone else) builds a structure,
#    a "structure built" event triggers an eventStructureBuilt call.
#    eventStructureBuilt is WZ2100 JS API.
eventStructureBuilt = (structure, droid) ->
  debug("in eventStructureBuilt")
  return null
  # TODO Just stop here for now

  cyberBorg.update()
  structure = new WZObject(structure)
  droid = new WZObject(droid)
  groups = cyberBorg.groups
  
  # So every time we build a structure, this function gets called.
  # Let's tell the player what got built.
  # namexy is a my hack on WZ2100's Object, which
  # returns the name and position of the game piece.
  console "#{structure.namexy()} Built!"

  # So the first thing that get built is a Factory.
  # It's just how this AI plays the game.
  # Another AI might choose a diffetent build order.
  # Anyways, when a factory gets built,
  # we need to get it started building droids.
  if (structure.type is STRUCTURE)
    switch structure.stattype
      when FACTORY
        groups.named('Factories').list.push(structure)
      when RESEARCH_LAB
        groups.named('Labs').list.push(structure)
      when HQ
        # Because we've overridden rules.js eventStructureBuilt,
        # we need to need to enforce one of the rules in the game.
        # Unfortunately, rules.js is the human player's file.
        # We are in it's name space.
        # min_map_and_design_on turns on mini-map and design when HQ is built,
        # as per rules.js.
        # TODO check if this file is being runned by rules.js first.
        # May be being runned as a stand alone AI.
        min_map_and_design_on structure

  # Next see what the groups can execute
  group_executions(name:'StructureBuilt', structure:structure, droid:droid)

# This turns on minimap and design
# Will not be needed when this AI follows standard conventions.
min_map_and_design_on = (structure) ->
  debug("min_map_and_design_on")
  return null
  # TODO Just stop here for now

  structure = new WZObject(structure)

  if structure.player is selectedPlayer and
  structure.type is STRUCTURE and
  structure.stattype is HQ
    setMiniMap true # show minimap
    setDesign true # permit designs

#  When a droid is built, it triggers a droid built event and
#  eventDroidBuilt(a WZ2100 JS API) is called.
eventDroidBuilt = (droid, structure) ->
  debug("in eventDroidBuilt")
  return null
  # TODO Just stop here for now

  cyberBorg.update()
  droid = new WZObject(droid)
  structure = new WZObject(structure)
  groups = cyberBorg.groups
  
  # Tell the player what got built.
  console "Built #{droid.name}."
  
  # Now what with the new droid?
  # If it's a truck, maybe it should go to the nearest job?
  # Well, the style for this AI is to work with groups.
  # So what we'll do is add the new droids to the RESERVE.
  groups.named('Reseve').list.push(droid)
  
  # If a factory just built a droid, it's ready for the next build.
  # Next see what the groups can execute
  group_executions(name:'DroidBuilt', structure:structure, droid:droid)

# Player commands...
# Some useful debuging feedback and could be used for player commands.
eventChat = (sender, to, message) ->
  debug("in eventChat")
  return null
  # TODO Just stop here for now

  cyberBorg.update()
  if sender is 0
    switch message
      when 'report base' then report('base')
      when 'report reserve' then report('reserve')
      else console("What?")

# Report to player console droids' position...
report = (who) ->
  debug("in report")
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
  console("#{droids.join(', ')}.") if droids.length

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
#  # orders.next(structure) gives the next order for the structure.
#  # It may be that the structure was not already pursuing a research,
#  # so it's either or.
#  order = orders.of(structure) or orders.next(structure)
#  # we need to know what the structure just got done researching, if anything.
#  if completed
#    console "#{structure.namexy()}
#    pursuing #{order} got done with #{completed.name}."
#    # If we've reached the technology sought, then get the next order.
#    order = orders.next(structure) if order == completed.name
#    # Eventually, we run out of orders, so we need to check.
#  if order
#    # So let the player know what we're researching, and
#    # order the facilty to pursue it.
#    console("#{structure.namexy()} is doing #{order}.")
#    pursueResearch(structure, order)
#  else
#    console('Research orders complete?')

# Every time a research facility is done researching a technology,
# a research event is triggered, and eventResearched is called.
# eventResearched is WZ2100 JS API.
# A new research tecnology can be acquired by picking up it's plan,
# which can be found from the ruins of a demolished facility.
# So we need to check that in fact
# the technology came from an active structure.
eventResearched = (completed, structure) ->
  debug("in eventResearched")
  return null
  # TODO Just stop here for now

  structure = new WZObject(structure)
  group_executions(name:'Researched', structure:structure, research:completed)

eventDroidIdle = (droid) ->
  debug("in eventDroidIdle")
  return null
  # TODO Just stop here for now

  droid = new WZObject(droid)
  groups = cyberBorg.groups

  group_executions(name:'DroidIdle', droid:droid)
  # I thinks this all goes away. :))
  #if groups.reserve.group.contains(droid)
  #  # groups that accept idle reserve droids
  #  console("Idle droid applies...")
  #  groups.base.applying(droid) or
  #  groups.derricks_trucks.applying(droid) or
  #  groups.derricks_weapons.applying(droid)
  #if groups.derricks_trucks.group.contains(droid)
  #  console("Derricks truck reporting for duty!")
  #  derricks_trucks_group()
  #if groups.derricks_weapons.group.contains(droid)
  #  console("Derricks weapons reporting for duty!")
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
#      console "Derricks group has orders pending."
#      derricks_trucks.orders.revert()
#      break
#    else
#      console "There are #{count} droids working on
#      #{order.structure}(#{order.at.x},#{order.at.y})}."
#    order = derricks_trucks.orders.next()
#  console "Derricks trucks orders complete!" if !order
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
#      console "Derricks weapons group has orders pending."
#      derricks_weapons.orders.revert()
#      break
#    else
#      console "There are #{count} weapons working
#      going to (#{order.at.x},#{order.at.y})}."
#    order = derricks_weapons.orders.next()
#  console "Derricks weapons orders complete!" if !order

group_executions = (event) ->
  groups = cyberBorg.groups
  for group in groups
    name = group.name
    orders = group.orders
    order = orders.next()

    # TODO to delete start
    debug("#{name} has #{orders.length} orders")
    debug(order)
    continue unless name is 'Base'
    # TODO delete end
    if order
      while order
        debug("#{name} #{order.function}") # TODO :-??
        executers = group.execute(order)
        count = executers.length
        if count is 0
          orders.revert()
          console("Group #{name} has pending orders.")
          break
        console("There are #{count} #{name} units
        working on #{order.function}.")
        order = orders.next()
      console "Group #{name} orders complete!" if !order
