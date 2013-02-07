###
 Here I have here listed all of the events documented by
 the JS API as of 2013-01-09.  The ones not used are commented out.
 See:
   https://warzone.atlassian.net/wiki/display/jsapi/API
 Preliminary data wrapping into either WZArray or WZObject occurs here.
###

# Took me a while to recognize the role of GROUPS.
# It's a constant, referring to the same list
# of this player's pieces in the game.
# It acts as a whiteboard available to this process.
GROUPS = Groups.bless([])

# AI is actually a constant in this namespace.
# It's set just this once and one time only.
AI = new Ai()

eventChat = (sender,to, message) ->
  obj =
    name: 'Chat'
    sender: sender
    to: to
    message: message
  AI.events(obj)

eventDestroyed = (object) ->
  # At this time for the AI,
  # The destruction of an Oil Resource is of no consequence.
  # This might change.
  unless object.name is 'Oil Resource'
    group = null
    # Might not actually belong to us...
    if object.player is me and
    found = GROUPS.finds(object)
      group = found.group
      object = found.object
      # object is gone.
      # If not removed here, update later fails.
      group.list.removeObject(object)
    else
      object = new WZObject(object)
    obj =
      name: 'Destroyed'
      object: object
      group: group
    AI.events(obj)

eventDroidBuilt = (droid, structure) ->
  found = GROUPS.finds(structure)
  obj =
    name: 'DroidBuilt'
    # Here, droid is an new game object
    droid: new WZObject(droid)
    # But structrue is pre-existing
    structure: found.object
    group: found.group
  AI.events(obj)

eventDroidIdle = (droid) ->
  found = GROUPS.finds(droid)
  obj =
    name: 'DroidIdle'
    # Here, droid is pre-existing!
    droid: found.object
    group: found.group
  AI.events(obj)

eventResearched = (research, structure) ->
  found = GROUPS.finds(structure)
  obj =
    name: 'Researched'
    research: research
    structure: found?.object
    group: found?.group
  AI.events(obj)

eventStartLevel = () ->
  obj = name: 'StartLevel'
  AI.events(obj)

eventStructureBuilt = (structure, droid) ->
  found = GROUPS.finds(droid)
  obj =
    name: 'StructureBuilt'
    # Here, structure is new
    structure: new WZObject(structure)
    # But droid is prexisting!!!
    droid: found.object
    group: found.group
  AI.events(obj)

eventObjectSeen = (sensor, object) ->
  found = GROUPS.finds(sensor)
  obj =
    name: 'ObjectSeen'
    sensor: found.object
    groups: found.group
    object: new WZObject(object)
  unless object.name is "Oil Derrick" or object.name is "Truck"
    Trace.debug "Object Seen: #{object.name}"
  #AI.events(obj)

###
eventAttacked = (victim, attacker) ->
  obj =
    name: 'Attacked'
    victim: new WZObject(victim)
    attacker: new WZObject(attacker)
  AI.events(obj)

eventAttackedUnthrottled = (victim, attacker) ->
  obj =
    name: 'Attacked'
    victim: new WZObject(victim)
    attacker: new WZObject(attacker)
  AI.events(obj)

eventBeacon = (x, y, sender, to, message) ->
  obj =
    name: 'Beacon'
    at: x:x, y:y
    sender: sender
    to: to
    message: message
  AI.events(obj)

eventBeaconRemoved = (sender, to) ->
  obj =
    name: 'BeaconReamoved'
    sender: sender
    to: to
  AI.events(obj)

eventCheatMode = (entered) ->
  obj =
    name: 'CheatMode'
    entered: entered
  AI.events(obj)

eventGameInit = () ->
  obj = name: 'GameInit'
  AI.events(obj)

eventGameLoaded = () ->
  obj = name: 'GameLoaded'
  AI.events(obj)

eventGameSaved = () ->
  obj = name: 'GameSaved'
  AI.events(obj)

eventGameSaving = () ->
  obj = name: 'GameSaving'
  AI.events(obj)

eventGroupLoss = (object, group, size) ->
  obj =
    name: 'GroupLoss'
    object: new WZObject(object)
    group: group
    size: size
  AI.events(obj)

eventLaunchTransporter = () ->
  obj = name: 'LaunchTransporter'
  AI.events(obj)

eventMissionTimeout = () ->
  obj = name: 'MissionTimeout'
  AI.events(obj)

eventObjectTransfer = () ->
  obj = name: 'ObjectTransfer'
  AI.events(obj)

eventPickup = () ->
  obj = name: 'Pickup'
  AI.events(obj)

eventReinforcementsArrived = () ->
  obj = name: 'ReinforcementArrived'
  AI.events(obj)

eventSelectionChange = (selected) ->
  selected = selected.map( (object) -> new WZObject(object) )
  selected = WZArray.bless(selected)
  obj =
    name: 'SelectionChange'
    selected: selected
  AI.events(obj)

eventStructureReady = (structure) ->
  obj =
    name: 'StructureReady'
    structure: new WZObject(structure)
  AI.events(obj)

eventVideoDone = () ->
  obj = name: 'VideoDone'
  AI.events(obj)
###
