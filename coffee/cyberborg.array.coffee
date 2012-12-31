class WZArray
  @INIT = -1
  @NONE = -1

  @bless = (array) ->
    return array if array.is_wzarray
    array[name] = method for name, method of WZArray.prototype
    array.is_wzarray = true
    array

  # Counts the number of type in list
  counts: (type) ->
    count = 0
    i = 0
    while i < @length
      count += 1  if type(this[i])
      i++
    count

  # True if list contains object
  contains: (object) ->
    @indexOfObject(object) > WZArray.NONE

  # indexOfObject
  indexOfObject: (object) ->
    id = object.id
    i = 0
    while i < @length
      return (i)  if this[i].id is id
      i++
    WZArray.NONE

  # Sorts list by distance.
  # Nearest object would be first on list.
  nearest: (at) ->
    @sort (a, b) ->
      CyberBorg.nearest_metric a, b, at
    this

  # Remove object from list.
  removeObject: (object) ->
    i = @indexOfObject(object)
    @splice i, 1  if i > WZArray.NONE
    i

  #  select objects from list in group
  in: (group) ->
    @filters((object) -> group.group.indexOfObject(object) > WZArray.NONE)

  # Ensures filtering results in a WZArray
  filters: (type) -> WZArray.bless(this.filter(type))

  # Selects from list objects that are idle in the game
  idle: -> @filters(CyberBorg.is_idle)

  # Returns the center of the list (group).
  center: ->
    at =
      x: 0
      y: 0
    n = @length
    i = 0
    while i < n
      at.x += this[i].x
      at.y += this[i].y
      i++
    at.x = at.x / n
    at.y = at.y / n
    at

  # first
  first: -> this[0]

  #  current WZ2100
  _current: WZArray.INIT
  current: this[@_current]

  # next WZ2100
  next: (gameobj) ->
    @_current += 1  if @_current < this.length
    order = this[@_current]
    @is[gameobj.id] = order  if gameobj
    order

  # previous WZ2100
  previous: (gameobj) ->
    @_current -= 1  if @_current > WZArray.init
    order = this[@_current]
    @is[gameobj.id] = order  if gameobj
    order

  # not_built WZ2100
  not_built: -> @filters(not_built) # TODO where is not_built

  # not_in  WZ2100
  not_in: (group) ->
    @filters((object) -> group.group.indexOfObject(object) is WZArray.NONE)

  # is WZ2100
  is: {}

  # of  WZ2100
  of: (gameobj) -> @is[gameobj.id]

  # trucks  WZ2100
  trucks: -> @filters(CyberBorg.is_truck)

  # factories WZ2100
  factories: -> @filters(CyberBorg.is_factory)
