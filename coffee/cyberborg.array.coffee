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
# filters WZArray
Array::filters = (type) -> WZArray.bless(this.filter(type))

# forEach JS-ARRAY
# idle WZ2100
Array::idle = -> @filters(is_idle)

#  in_group  WZ2100
Array::in_group = (group) ->
  @filters((droid) -> group.group.indexOfObject(droid) > Array.NONE)

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
Array::not_built = -> @filters(not_built)

# not_in_group  WZ2100
Array::not_in_group = (group) ->
  @filters((droid) -> group.group.indexOfObject(droid) is Array.NONE)

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
Array::trucks = -> @filters(CyberBorg.is_truck)

# factories WZ2100
Array::factories = -> @filters(CyberBorg.is_factory)

# unshift  JS-ARRAY
