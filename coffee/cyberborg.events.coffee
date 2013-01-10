###
 Here I have here listed all of the events documented by
 the JS API as of 2013-01-09.  The ones not used are commented out.
 See:
   https://warzone.atlassian.net/wiki/display/jsapi/API
 Preliminary data wrapping into either WZArray or WZObject occurs here.
###

###
eventAttacked = (victim, attacker) ->
  obj =
    name: 'Attacked'
    victim: new WZObject(victim)
    attacker: new WZObject(attacker)
  events(obj)

eventAttackedUnthrottled = (victim, attacker) ->
  obj =
    name: 'Attacked'
    victim: new WZObject(victim)
    attacker: new WZObject(attacker)
  events(obj)

eventBeacon = (x, y, sender, to, message) ->
  obj =
    name: 'Beacon'
    at: x:x, y:y
    sender: sender
    to: to
    message: message
  events(obj)

eventBeaconRemoved = (sender, to) ->
  obj =
    name: 'BeaconReamoved'
    sender: sender
    to: to
  events(obj)

###

eventChat = (sender,to, message) ->
  obj =
    name: 'Chat'
    sender: sender
    to: to
    message: message
  events(obj)

###

eventCheatMode = (entered) ->
  obj =
    name: 'CheatMode'
    entered: entered
  events(obj)

eventDestroyed = (object) ->
  obj =
    name: 'Destroyed'
    object: new WZObject(object)
  events(obj)

###

eventDroidBuilt = (droid, structure) ->
  obj =
    name: 'DroidBuilt'
    # Here, droid is an new game object
    droid: new WZObject(droid)
    # But structrue is pre-existing
    structure: cyberBorg.find(structure)
  events(obj)

eventDroidIdle = (droid) ->
  obj =
    name: 'DroidIdle'
    # Here, droid is pre-existing!
    droid: cyberBorg.find(droid)
  events(obj)

###

eventGameInit = () ->
  obj = name: 'GameInit'
  events(obj)

eventGameLoaded = () ->
  obj = name: 'GameLoaded'
  events(obj)

eventGameSaved = () ->
  obj = name: 'GameSaved'
  events(obj)

eventGameSaving = () ->
  obj = name: 'GameSaving'
  events(obj)

eventGroupLoss = (object, group, size) ->
  obj =
    name: 'GroupLoss'
    object: new WZObject(object)
    group: group
    size: size
  events(obj)

eventLaunchTransporter = () ->
  obj = name: 'LaunchTransporter'
  events(obj)

eventMissionTimeout = () ->
  obj = name: 'MissionTimeout'
  events(obj)

eventObjectSeen = (sensor, object) ->
  obj =
    name: 'ObjectSeen'
    sensor: new WZObject(sensor)
    object: new WZObject(object)
  events(obj)

eventObjectTransfer = () ->
  obj = name: 'ObjectTransfer'
  events(obj)

eventPickup = () ->
  obj = name: 'Pickup'
  events(obj)

eventReinforcementsArrived = () ->
  obj = name: 'ReinforcementArrived'
  events(obj)

###

eventResearched = (research, structure) ->
  obj =
    name: 'Researched'
    research: research
    structure: cyberBorg.find(structure)
  events(obj)

###

eventSelectionChange = (selected) ->
  selected = selected.map( (object) -> new WZObject(object) )
  selected = WZArray.bless(selected)
  obj =
    name: 'SelectionChange'
    selected: selected
  events(obj)

###

eventStartLevel = () ->
  obj = name: 'StartLevel'
  events(obj)

eventStructureBuilt = (structure, droid) ->
  obj =
    name: 'StructureBuilt'
    # Here, structure is new
    structure: new WZObject(structure)
    # But droid is prexisting!!!
    droid: cyberBorg.find(droid)
  events(obj)

###

eventStructureReady = (structure) ->
  obj =
    name: 'StructureReady'
    structure: new WZObject(structure)
  events(obj)

eventVideoDone = () ->
  obj = name: 'VideoDone'
  events(obj)
###
