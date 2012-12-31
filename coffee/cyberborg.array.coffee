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
  @splice i, 1  if i > Array.NONE
  i

