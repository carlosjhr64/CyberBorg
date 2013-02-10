###################
### ***Array*** ###
###################

# There are some really common hacks on Array, we'll make'em on Array itself.
Array::first = ()-> @[0]
Array::last = ()-> @[@length-1]
Array::penultima = ()-> @[@length-2]
Array::shuffle = -> @sort -> 0.5 - Math.random()

#####################
### ***WZArray*** ###
#####################

# WZArray adds useful methods to the Array class,
# many which are specific to the game.
class WZArray
  # These constants add meaning and intent to just the number they hold.
  # The pre-existance index for next/previous.
  @INIT = -1
  # The no match index of indexOf.
  @NONE = -1

  ###############
  ### METRICS ###
  ###############

  @distance_metric = (a, b) ->
    x = a.x - b.x
    y = a.y - b.y
    x * x + y * y

  @nearest_metric = (a, b, at) ->
    WZArray.distance_metric(a, at) - WZArray.distance_metric(b, at)

  # Sometimes it's easier to take an existing object and augment.
  # We'll take an Array and "bless" into it the methods in this class.
  @bless = (array) ->
    if array.is_wzarray
      Trace.red "Warning: WZArray re'bless'ing"
      return array
    array[name] = method for name, method of WZArray.prototype
    array.is_wzarray = true
    array

  #############
  ### SORTS ###
  #############

  # Sorts list by distance.
  # Nearest object would be first on list.
  nearest: (at) ->
    @sort (a, b) -> WZArray.nearest_metric(a, b, at)

  ###############
  ### QUERIES ###
  ###############

  # indexOfObject takes a game object and returns it index in the array
  # if it's in the array. Game objects have a unique id which allows for
  # a quick id check.
  indexOfObject: (object) ->
    id = object.id
    i = 0
    while i < @length
      return (i)  if @[i].id is id
      i++
    WZArray.NONE

  # True if list contains the game object
  contains: (object) ->
    @indexOfObject(object) > WZArray.NONE

  # Remove object from list.
  removeObject: (object) ->
    i = @indexOfObject(object)
    @splice i, 1  if i > WZArray.NONE
    i

  ###############
  ### FILTERS ###
  ###############

  # Ensures filtering results in a WZArray.
  # Rather than override JS's filter,
  # we use the plural filtes to distinguis the two.
  # filters stays in WZArray, while filter returns Array.
  filters: (type) -> WZArray.bless(@.filter(type))

  # Some of these filters below might not be being used, but
  # why not keep them?

  # trucks in list
  trucks: -> @filters(CyberBorg.is_truck)

  weapons: -> @filters(CyberBorg.is_weapon)

  # factories in list
  factories: -> @filters(CyberBorg.is_factory)

  # game objects not built (b/c they're being built i.e.) in list.
  not_built: -> @filters(CyberBorg.is_not_built)

  # game object in list not in the given group.
  not_in: (group) ->
    @filters((object) -> group.list.indexOfObject(object) is WZArray.NONE)

  # select objects from list in group
  in: (group) ->
    @filters((object) -> group.list.indexOfObject(object) > WZArray.NONE)

  in_cid: (cid) -> @filters((object) -> object.command?.cid is cid)

  # select units in the list which name matches the pattern given.
  like: (rgx) -> @filters((object) -> rgx.test(object.name))

  #############
  ### EDITS ###
  #############

  # cuts of the list to n objects preserving class.
  cap: (n) -> WZArray.bless(@[0..(n - 1)])

  # concats the array given, blessing the result into the class.
  add: (arr) -> WZArray.bless(@concat(arr))

  ################
  ### SUMARIES ###
  ################

  # Counts the number of type in list
  counts: (type) ->
    count = 0
    for object in @
      count += 1 if type(object)
    count

  # Counts the number of game objects named by the given name.
  counts_named: (name) -> @counts((obj) -> obj.name == name)

  # Count the number of game object with the given cid
  counts_in_cid: (cid) -> @counts((obj) -> obj.command?.cid == cid)

  # Returns the center of the list (group).
  # Returns {x:x,y:y}
  center: ->
    at =
      x: 0
      y: 0
    n = @length
    i = 0
    while i < n
      at.x += @[i].x
      at.y += @[i].y
      i++
    at.x = at.x / n
    at.y = at.y / n
    at

  collision: (at) ->
    for object in @
      return true if object.x is at.x and object.y is at.y
    false

  #################
  ### ACCESSING ###
  #################

  get_command: (cid) ->
    for command in @
      return command if command.cid is cid
    return null

  ##############
  ### CURSOR ###
  ##############

  _current: WZArray.INIT
  current: () -> @[@_current]

  _next: () ->
    @_current += 1  if @_current < @.length
    @_current

  next: () -> @[@_next()]

  _previous: () ->
    @_current -= 1  if @_current > WZArray.INIT
    @_current
  # Aliasing _previous.
  # Can't just pass the ref b/c _previous may be overriden by subclasses.
  revert: () -> @_previous()

  previous: () -> @[@_previous()]

#####################
### ***Scouter*** ###
#####################

# Scouter overrides WZArray's cursor to allow loops within the array.
class Scouter
  @bless = (array) ->
    if array.is_scouter
      Trace.red "Warning: Scouter re'bless'ing"
      return array
    array[name] = method for name, method of Scouter.prototype
    array.offset = 0
    array.mod = @length
    array.index = WZArray.INIT
    array.is_scouter = true
    array

  _set_current: () ->
    # Note that the result is returned
    @_current = @offset + (@index % @mod)

  _next: () ->
    @index += 1
    @_set_current()

  _previous: () ->
    # Note that the result is returned
    if @index > -1
      @index -= 1
      @_set_current()
    else
      @_current = -1

####################
### ***Groups*** ###
####################
class Groups
  # This might bite me in the future, but
  # I don't see us ever using more than one reserve.
  @RESERVE = WZArray.bless([])

  @bless = (array) ->
    if array.is_groups
      Trace.red "Warning: Groups re'bless'ing"
      return array
    array[name] = method for name, method of Groups.prototype
    array.is_groups = true
    array

  # Need a way to register groups
  add_group: (params...) ->
    @push(new Group(params...))

  # Updates all game objects, group by group.
  update: () ->
    for group in @
      for object in group.list
        object.update() if object.game_time < gameTime
    for object in Groups.RESERVE
      object.update() if object.game_time < gameTime

  count: (test_of) ->
    n = 0
    for group in @
      for object in group.list
        n += 1 if test_of(object)
    for object in Groups.RESERVE
      n += 1 if test_of(object)
    return n

  for_all: (test_of) ->
    list = []
    for group in @
      for object in group.list
        list.push(object) if test_of(object)
    for object in Groups.RESERVE
      list.push(object) if test_of(object)
    return WZArray.bless(list)

  for_one: (test_of) ->
    for group in @
      for object in group.list
        return({object:object,group:group}) if test_of(object)
    for object in Groups.RESERVE
      if test_of(object)
        # Only time this happens in on eventDestroyed?
        return({object:object,group:{list:Groups.RESERVE}})
    return null

  # When we get pre-existing game objects from WZ's JS API,
  # we need to find them in our groups.
  # Otherwise we end up with duplicates.
  find: (target) -> @for_one((object) -> object.id is target.id)?.object

  # For cases where we want to get both our copy of the object and
  # the group it's in.
  finds: (target) -> @for_one((object)->  object.id is target.id)

  structure_at: (at) ->
    found = (object) ->
      object.x is at.x and
      object.y is at.y and
      object.type is STRUCTURE
    @for_one(found)?.object

  # Returns the first command found with the given cid
  get_command: (cid) ->
    for group in @
      for command in group.commands
        return command if command.cid is cid
    return null

  # Returns the first item with the given name.
  named: (name) ->
    for object in @
      return object if object.name is name
    null
