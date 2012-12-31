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

# every JS-ARRAY
# filter JS-ARRAY
# forEach JS-ARRAY
# idle WZ2100
Array::idle = ->
  selected = @filter(is_idle)
  WZArray.bless(selected)

#  in_group  WZ2100
Array::in_group = (group) ->
  #selected = this.filter( function(droid) { return(droid.group == group.group); });
  selected = @filter((droid) ->
    group.group.indexOfObject(droid) > Array.NONE
  )
  WZArray.bless(selected)

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

# not_built WZ2100
Array::not_built = ->
  selected = @filter(not_built)
  WZArray.bless(selected)

# not_in_group  WZ2100
Array::not_in_group = (group) ->
  #var selected = this.filter( function(droid) { return(droid.group != group.group); });
  selected = @filter((droid) ->
    group.group.indexOfObject(droid) is Array.NONE
  )
  WZArray.bless(selected)

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
  WZArray.bless(selected)

# factories WZ2100
Array::factories = ->
  selected = @filter(CyberBorg.is_factory)
  WZArray.bless(selected)

# unshift  JS-ARRAY
