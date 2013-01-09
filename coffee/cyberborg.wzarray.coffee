class WZArray
  @INIT = -1
  @NONE = -1

  @bless = (array) ->
    return array if array.is_wzarray
    array[name] = method for name, method of WZArray.prototype
    array.is_wzarray = true
    array

  ###############
  ### QUERIES ###
  ###############

  # indexOfObject
  indexOfObject: (object) ->
    id = object.id
    i = 0
    while i < @length
      return (i)  if @[i].id is id
      i++
    WZArray.NONE

  # True if list contains object
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

  # Ensures filtering results in a WZArray
  filters: (type) -> WZArray.bless(@.filter(type))

  # trucks  WZ2100
  trucks: -> @filters(CyberBorg.is_truck)

  weapons: -> @filters(CyberBorg.is_weapon)

  # factories WZ2100
  factories: -> @filters(CyberBorg.is_factory)

  # not_built WZ2100
  not_built: -> @filters(CyberBorg.is_not_built)

  # not_in  WZ2100
  not_in: (group) ->
    @filters((object) -> group.group.indexOfObject(object) is WZArray.NONE)

  #  select objects from list in group
  in: (group) ->
    @filters((object) -> group.group.indexOfObject(object) > WZArray.NONE)

  # Selects from list objects that are idle in the game
  idle: -> @filters(CyberBorg.is_idle)

  like: (rgx) -> @filters((object) -> rgx.test(object.name))

  #############
  ### EDITS ###
  #############

  cap: (n) -> WZArray.bless(@[0..(n - 1)])

  add: (arr) -> WZArray.bless(@concat(arr))

  #############
  ### SORTS ###
  #############

  # Sorts list by distance.
  # Nearest object would be first on list.
  nearest: (at) ->
    @sort (a, b) -> CyberBorg.nearest_metric(a, b, at)

  ################
  ### SUMARIES ###
  ################

  # Counts the number of type in list
  counts: (type) ->
    count = 0
    i = 0
    while i < @length
      count += 1  if type(@[i])
      i++
    count

  counts_named: (name) ->
    count = 0
    i = 0
    while i < @length
      count += 1 if @[i].name == name
      i++
    count

  # Returns the center of the list (group).
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

  #################
  ### ACCESSING ###
  #################

  # first
  first: -> @[0]

  #  current WZ2100
  _current: WZArray.INIT
  current: () -> @[@_current]

  _next: () ->
    @_current += 1  if @_current < @.length

  # next WZ2100
  next: () ->
    @_next()
    @[@_current]

  revert: () ->
    @_current -= 1  if @_current > WZArray.INIT

  named: (name) ->
    i = 0
    while i < @length
      return(@[i]) if @[i].name == name
      i++
    null

  # previous WZ2100 is this needed?

  ##############
  ### STORES ###
  ##############

  ### Does not look like we'll need this after all
  # is WZ2100
  is: {}

  # of  WZ2100
  of: (object) -> @is[object.id]
  ###

