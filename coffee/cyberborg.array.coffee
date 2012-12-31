class WZArray
  @INIT = -1
  @NONE = -1

  @bless = (array) ->
    # TODO when "is" is WZArray, uncoment below
    #return array if array.is # if array.is, very likely already blessed.
    array[name] = method for name, method of WZArray.prototype
    array

  # *** Array Extensions ***
  # concat JS-ARRAY
  # constructor JS-ARRAY
  # contains WZ2100
  Array::contains = (droid) ->
    @indexOfObject(droid) > WZArray.NONE

  # indexOfObject WZ2100
  Array::indexOfObject = (droid) ->
    id = droid.id
    i = 0
    while i < @length
      return (i)  if this[i].id is id
      i++
    WZArray.NONE

  # join  JS-ARRAY
  # lastIndexOf  JS-ARRAY
  # length  JS-ARRAY
  # map  JS-ARRAY
  # nearest WZ2100
  Array::nearest = (at) ->
    @sort (a, b) ->
      CyberBorg.nearest_metric a, b, at
    this

  # pop JS-ARRAY
  # push JS-ARRAY
  # reduceRight JS-ARRAY
  # reduce  JS-ARRAY
  # reject! RUBY
  # remove WS2100
  Array::removeObject = (droid) ->
    i = @indexOfObject(droid)
    @splice i, 1  if i > WZArray.NONE
    i

  #  in_group  WZ2100
  in_group: (group) ->
    @filters((droid) -> group.group.indexOfObject(droid) > WZArray.NONE)

  # every JS-ARRAY
  # filter JS-ARRAY
  # filters WZArray
  filters: (type) -> WZArray.bless(this.filter(type))

  # forEach JS-ARRAY
  # idle WZ2100
  idle: -> @filters(is_idle)

  # center WZ2100
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
  first: ->
    this[0]

  # count WZ2100 (clobbers ruby?) TODO
  count: (type) ->
    count = 0
    i = 0
    while i < @length
      count += 1  if type(this[i])
      i++
    count

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
  not_built: -> @filters(not_built)

  # not_in_group  WZ2100
  not_in_group: (group) ->
    @filters((droid) -> group.group.indexOfObject(droid) is WZArray.NONE)

  # indexOf  JS-ARRAY
  # is WZ2100
  is: {}

  # of  WZ2100
  of: (gameobj) ->
    @is[gameobj.id]

  # replace  RUBY
  # reverse  JS-ARRAY
  # shift  JS-ARRAY
  # slice  JS-ARRAY
  # some  JS-ARRAY
  # sort  JS-ARRAY
  # splice  JS-ARRAY
  # toSource  JS-ARRAY
  # toString  JS-ARRAY
  # trucks  WZ2100
  trucks: -> @filters(CyberBorg.is_truck)

  # factories WZ2100
  factories: -> @filters(CyberBorg.is_factory)

  # unshift  JS-ARRAY
