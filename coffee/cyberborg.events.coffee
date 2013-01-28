###
 Here I have here listed all of the events documented by
 the JS API as of 2013-01-09.  The ones not used are commented out.
 See:
   https://warzone.atlassian.net/wiki/display/jsapi/API
 Preliminary data wrapping into either WZArray or WZObject occurs here.
###

ai = new Ai()

eventChat = (sender,to, message) ->
  obj =
    name: 'Chat'
    sender: sender
    to: to
    message: message
  ai.events(obj)

eventDestroyed = (object) ->
  # At this time for the AI,
  # The destruction of an Oil Resource is of no consequence.
  # This might change.
  unless object.name is 'Oil Resource'
    group = null
    # Might not actually belong to us...
    if object.player is me and
    found = ai.groups.finds(object)
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
    ai.events(obj)

eventDroidBuilt = (droid, structure) ->
  found = ai.groups.finds(structure)
  obj =
    name: 'DroidBuilt'
    # Here, droid is an new game object
    droid: new WZObject(droid)
    # But structrue is pre-existing
    structure: found.object
    group: found.group
  ai.events(obj)

eventDroidIdle = (droid) ->
  found = ai.groups.finds(droid)
  obj =
    name: 'DroidIdle'
    # Here, droid is pre-existing!
    droid: found.object
    group: found.group
  ai.events(obj)

eventResearched = (research, structure) ->
  found = ai.groups.finds(structure)
  obj =
    name: 'Researched'
    research: research
    structure: found?.object
    group: found?.group
  ai.events(obj)

eventStartLevel = () ->
  obj = name: 'StartLevel'
  ai.events(obj)

eventStructureBuilt = (structure, droid) ->
  found = ai.groups.finds(droid)
  obj =
    name: 'StructureBuilt'
    # Here, structure is new
    structure: new WZObject(structure)
    # But droid is prexisting!!!
    droid: found.object
    group: found.group
  ai.events(obj)

###
eventAttacked = (victim, attacker) ->
  obj =
    name: 'Attacked'
    victim: new WZObject(victim)
    attacker: new WZObject(attacker)
  ai.events(obj)

eventAttackedUnthrottled = (victim, attacker) ->
  obj =
    name: 'Attacked'
    victim: new WZObject(victim)
    attacker: new WZObject(attacker)
  ai.events(obj)

eventBeacon = (x, y, sender, to, message) ->
  obj =
    name: 'Beacon'
    at: x:x, y:y
    sender: sender
    to: to
    message: message
  ai.events(obj)

eventBeaconRemoved = (sender, to) ->
  obj =
    name: 'BeaconReamoved'
    sender: sender
    to: to
  ai.events(obj)

eventCheatMode = (entered) ->
  obj =
    name: 'CheatMode'
    entered: entered
  ai.events(obj)

eventGameInit = () ->
  obj = name: 'GameInit'
  ai.events(obj)

eventGameLoaded = () ->
  obj = name: 'GameLoaded'
  ai.events(obj)

eventGameSaved = () ->
  obj = name: 'GameSaved'
  ai.events(obj)

eventGameSaving = () ->
  obj = name: 'GameSaving'
  ai.events(obj)

eventGroupLoss = (object, group, size) ->
  obj =
    name: 'GroupLoss'
    object: new WZObject(object)
    group: group
    size: size
  ai.events(obj)

eventLaunchTransporter = () ->
  obj = name: 'LaunchTransporter'
  ai.events(obj)

eventMissionTimeout = () ->
  obj = name: 'MissionTimeout'
  ai.events(obj)

eventObjectSeen = (sensor, object) ->
  obj =
    name: 'ObjectSeen'
    sensor: new WZObject(sensor)
    object: new WZObject(object)
  ai.events(obj)

eventObjectTransfer = () ->
  obj = name: 'ObjectTransfer'
  ai.events(obj)

eventPickup = () ->
  obj = name: 'Pickup'
  ai.events(obj)

eventReinforcementsArrived = () ->
  obj = name: 'ReinforcementArrived'
  ai.events(obj)

eventSelectionChange = (selected) ->
  selected = selected.map( (object) -> new WZObject(object) )
  selected = WZArray.bless(selected)
  obj =
    name: 'SelectionChange'
    selected: selected
  ai.events(obj)

eventStructureReady = (structure) ->
  obj =
    name: 'StructureReady'
    structure: new WZObject(structure)
  ai.events(obj)

eventVideoDone = () ->
  obj = name: 'VideoDone'
  ai.events(obj)
###
