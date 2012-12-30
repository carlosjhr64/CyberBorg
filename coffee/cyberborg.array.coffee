# *** Array Extensions ***
# TODO use map to convert only those objects that need this?
Array.INIT = -1
Array.NONE = -1

# concat JS-ARRAY

# constructor JS-ARRAY

# contains WZ2100
Array::contains = (droid) ->
  @indexOfObject(droid) > Array.NONE

# indexOfObject WZ2100
Array::indexOfObject = (droid) ->
  id = droid.id
  i = 0

  while i < @length
    return (i)  if this[i].id is id
    i++
  Array.NONE

# count WZ2100 (clobbers ruby?) TODO
Array::count = (type) ->
  count = 0
  i = 0

  while i < @length
    count += 1  if type(this[i])
    i++
  count

#  current WZ2100
Array::current = Array.INIT

# every JS-ARRAY

# filter JS-ARRAY

# first
Array::first = ->
  this[0]

# forEach JS-ARRAY

# idle WZ2100
Array::idle = ->
  selected = @filter(is_idle)
  selected

#  in_group  WZ2100
Array::in_group = (group) ->
  #selected = this.filter( function(droid) { return(droid.group == group.group); });
  selected = @filter((droid) ->
    group.group.indexOf(droid) > Array.NONE
  )
  selected

# indexOf  JS-ARRAY

# is WZ2100
Array::is = {}

# join  JS-ARRAY

# lastIndexOf  JS-ARRAY

# length  JS-ARRAY

# map  JS-ARRAY

# nearest WZ2100
Array::nearest = (at) ->
  @sort (a, b) ->
    CyberBorg.nearest_metric a, b, at
  this

# next WZ2100
Array::next = (gameobj) ->
  @current += 1  if @current < @length
  order = this[@current]
  @is[gameobj.id] = order  if gameobj
  order

# not_built WZ2100
Array::not_built = ->
  selected = @filter(not_built)
  selected

# not_in_group  WZ2100
Array::not_in_group = (group) ->
  #var selected = this.filter( function(droid) { return(droid.group != group.group); });
  selected = @filter((droid) ->
    group.group.indexOf(droid) is Array.NONE
  )
  selected

# of  WZ2100
Array::of = (gameobj) ->
  @is[gameobj.id]

# pop JS-ARRAY

# push JS-ARRAY

# reduceRight JS-ARRAY

# reduce  JS-ARRAY

# reject! RUBY

# remove WS2100
Array::removeObject = (droid) ->
  i = @indexOfObject(droid)
  @splice i, 1  if i > Array.NONE
  i

# replace  RUBY

# reserve WZ2100 TODO is used?
Array::reserve = []

# reverse  JS-ARRAY

# shift  JS-ARRAY

# slice  JS-ARRAY

# some  JS-ARRAY

# sort  JS-ARRAY

# splice  JS-ARRAY

# toSource  JS-ARRAY

# toString  JS-ARRAY

# trucks  WZ2100
Array::trucks = ->
  selected = @filter(CyberBorg.is_truck)
  selected

# factories WZ2100
Array::factories = ->
  selected = @filter(CyberBorg.is_factory)
  selected

# unshift  JS-ARRAY
