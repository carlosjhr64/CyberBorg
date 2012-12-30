#  This AI is being built for the 8 player Sk-Concrete map,
#  played with no bases, T1.

#  This AI will use a custom library, CyberBorg.
#  It provides some usefull classes, helper functions, and
#  it extends Array in useful ways for the game.
include "multiplay/skirmish/cyberborg.js"

#  To keep things tidy, we keep the data this AI uses in a separate file.
#  Let's bring it in.
include "multiplay/skirmish/cyberborg.data.js"

#  So lets get CyberBorg to help us out.
cyberBorg = new CyberBorg()

#  When Warzone 2100 starts the game, it calls eventStartLevel.
#  eventStarLevel is WZ2100 JS API.
eventStartLevel = ->
  
  # The game starts...
  # Let's tell the player we're assisting.
  console "This is player_assist.js"
  
  #
  #    Usually the game starts out with some number of trucks, or droids in general.
  #    Let's see what we have.
  #    Group is a class provided by cyberborg.
  #    The constructor by default picks up all of the player's pieces.
  #    We'll put them in a reserve for now.
  #  
  reserve = new Group()
  
  #
  #    The reserve will hold the droids ready to join a group.
  #    Other groups can release droids they no longer need
  #    into the reserve, and draw droids they need from the reserve.
  #    The reserve may anticipate the needs of other groups and
  #    order droids around to where they may be likely needed.
  #    Thus it may show some initiative, just as
  #    individual droids may show some initiative.
  #  
  
  #
  #     Let's tell the user how many units we have to start.
  #  
  console "We have #{reserve.group.length} droids available, and
    #{reserve.group.count(CyberBorg.is_truck)} of them are trucks."
  
  #
  #     cyberBorg can list all the resources available on the map and
  #     sort them according to distance from where we are.
  #     It will provide the AI a guide to our territorial expansion.
  #  
  derricks = cyberBorg.get_resources(reserve.group.center())
  
  #
  #     So let's tell the player how many resource points there are.
  #  
  console "There are #{derricks.length} resource points."
  
  #
  #     Let's store what we know so far as cyberBorg attributes.
  #  
  groups = CyberBorg.groups
  groups.reserve = reserve
  cyberBorg.derricks = derricks
  
  #
  #    For this AI, we won't order individual droids directly.
  #    All orders will be given to groups, which
  #    will then be relayed down to an individual droid.
  #    The base group will be responsible for building the base.
  #    The group starts out empty, with [].
  #    Also, from the datafile, we give base its orders list.
  #    Finally, the base needs the reserve group.
  #  
  groups.base = new Group([], cyberBorg.base_orders(), reserve.group)
  
  #
  #    Structures are also considered units the AI can order.
  #    Let's have a factory group... etc.
  #    At this time, the concept of a reserve does not look useful for structures, but
  #    that could change.  Reserve just defaults to empty, [],
  #  
  groups.factory = new Group([], cyberBorg.factory_orders())
  
  #
  #     Our first concern is our base.
  #     We'll build it up and here forth react to events in the game.
  #  
  base_group()

#
#    From above, eventStartLevel, we called build_base.
#    It will also get call many times as the game progresses.
#    It should be called every time base group is ready to build the next structure.
#
base_group = ->
  groups = CyberBorg.groups
  base = groups.base
  order = base.orders.next()
  if order
    builders = base.build(order)
    
    # TODO if count is 0, either
    # no trucks were found for the job or
    # the structure was not available.  This is bad.
    count = builders.length
    console "There are #{count} droids working on #{order.structure}."
    console "Base group was unable to complete base orders."  if builders.length is 0
  else
    console "Base orders complete?"

#
#    When base group (or anyone else) builds a structure,
#    a "structure built" event triggers an eventStructureBuilt call.
#    eventStructureBuilt is WZ2100 JS API.
#
eventStructureBuilt = (structure, droid) ->
  CyberBorg.update()
  structure = new WZObject(structure)
  droid = new WZObject(droid)
  groups = CyberBorg.groups
  
  # So every time we build a structure, this function gets called.
  # Let's tell the player what got built.
  # namexy is a my hack on WZ2100's Object, which
  # returns the name and position of the game piece.
  console "#{structure.namexy()} Built!"
  
  # We want to keep BASE_GROUP busy.
  # If the droid belongs to BASE_GROUP, it needs to move on to the next build order.
  base_group()  if groups.base.group.contains(droid)
  
  # So the first thing that get built is a Factory.
  # It's just how this AI plays the game.
  # Another AI might choose a diffetent build order.
  # Anyways, when a factory gets built, we need to get it started building droids.
  if (structure.type is STRUCTURE) and (structure.stattype is FACTORY)
    groups.factory.group.push(structure)
    factory_group()
  
  # Because we've overridden rules.js eventStructureBuilt,
  # we need to need to enforce one of the rules in the game.
  # Unfortunately, rules.js is the human player's file.
  # We are in it's name space.
  # min_map_and_design_on turns on mini-map and design when HQ is built,
  # as per rules.js.
  # TODO check if this file is being runned by rules.js first.
  # May be being runned as a stand alone AI.
  min_map_and_design_on structure  if structure.stattype is HQ

# If a new research facility get built, we need to get it started.
# TODO
#  if (structure.name == "Research Facility") {
#debug('Calling do_research');
#    do_research(structure); }
#debug('exiting eventStructureBuilt');
#

# Laid off trucks are placed in the RESERVE.
# This may be trucks that were in the BASE_GROUP, but
# are now no longer needed.
# make_busy finds ways to keep them working.
#  make_busy(my_trucks().in_group(RESERVE).idle());  // TODO it's kinda'of a hack :-??

# This turns on minimap and design
min_map_and_design_on = (structure) ->
  structure = new WZObject(structure)

  if structure.player is selectedPlayer and structure.type is STRUCTURE and structure.stattype is HQ
    setMiniMap true # show minimap
    setDesign true # permit designs

#  So we get the factory working.
#  In this AI, I only intend to keep one factory, so
#  production management is pretty simple.
factory_group = ->
  # FACTORY_ORDERS is a list of droids to build, and
  # we build them one at a time.
  groups = CyberBorg.groups
  factory = groups.factory
  order = factory.orders.next()
  if order
    if factory.buildDroid(order)
      console "Building #{order.name}."
    else
      # This can happen if the technologies required aren't available.
      # TODO tell research group what you need.
      console "#{order.name} rejected?"
  else
    console "Droid builds done?"

#  When a droid is built, it triggers a droid built event and
#  eventDroidBuilt(a WZ2100 JS API) is called.
eventDroidBuilt = (droid, structure) ->
  CyberBorg.update()
  droid = new WZObject(droid)
  structure = new WZObject(structure)
  groups = CyberBorg.groups
  
  # Tell the player what got built.
  console "Built #{droid.name}."
  
  # Now what with the new droid?
  # If it's a truck, maybe it should go to the nearest job?
  # Well, the style for this AI is to work with groups.
  # So what we'll do is add the new droids to the RESERVE.
  groups.reserve.group.push droid
  
  # If a factory just built a droid, it's ready for the next build.
  # It is possible that the droid was "created",
  # so we need to check that in fact it's factory built.
  factory_group()  if groups.factory.group.contains(structure)

# Player commands...
# Some useful debuging feedback and could be used for player commands.
eventChat = (sender, to, message) ->
  CyberBorg.update()
  if sender is 0
    switch message
      when 'report base' then report('base')
      when 'report reserve' then report('reserve')
      else console("What?")

# Report to player console droids' position...
report = (who) ->
  groups = CyberBorg.groups
  droids = []
  switch who
    when 'base'
      droids.push(droid.namexy()) for droid in groups.base.group
    when 'reserve'
      droids.push(droid.namexy()) for droid in groups.reserve.group
    else console("What???")
  console("#{droids.join(', ')}.") if droids.length
