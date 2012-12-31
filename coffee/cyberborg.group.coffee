# The Group Class
class Group
  constructor: (@group, @orders, @reserve) ->
    # If we're not given a list of droids,
    # get them from enumDroid (all of the player's pieces).
    if @group then WZArray.bless(@group) else @group = CyberBorg.enum_droid()
    # orders is a list of things for the group to do
    if @orders then WZArray.bless(@orders) else @orders = WZArray.bless([])
    # reserve are the units we can draw from.
    if @reserves then WZArray.bless(@reserves) else @reserves = WZArray.bless([])

  recruit: (n, type, at) ->
    recruits = @reserve
    # NOTE: recruits won't be this.reserve if filtered!
    recruits = recruits.filters(type)  if type
    recruits.nearest at  if at
    i = 0
    while i < n
      break  unless recruits[0]
      droid = recruits.shift()
      @reserve.removeObject(droid)
      @group.push(droid)
      i++

  cut: (n, type, at) ->
    cuts = @group
    # NOTE: cuts won't be this.group if filtered!
    cuts = cuts.filters(type)  if type
    cuts.nearest at  if at
    i = 0
    while i < n
      droid = cuts.pop()
      break  unless droid
      @group.removeObject(droid)
      @reserve.push(droid)
      i++

  buildDroid: (order) ->
    factories = @group.factories().idle()
    i = 0
    while i < factories.length
      return (factories[i])  if buildDroid(factories[i], order.name, order.body, order.propulsion, "", order.droid_type, order.turret)
      i++
    null

  build: (order) ->
    builders = [] # going to return the number of builders
    structure = order.structure
    if isStructureAvailable(structure)
      at = order.at # where to build the structure
      # Get available trucks
      trucks = @group.trucks().idle()
      count = trucks.length
      if count < order.min
        @recruit(order.min - count, CyberBorg.is_truck, at)
        # Note that reserve trucks should always be idle for this to work.
        trucks = @group.trucks().idle()
      else
        if count > order.max
          @cut(count - order.min, CyberBorg.is_truck, at)
          trucks = @group.trucks().idle()
      if trucks.length > 0
        trucks.nearest(at) # sort by distance
        # assume nearest one can do
        pos = pickStructLocation(trucks[0], structure, at.x, at.y)
        if pos
          i = 0
          while i < trucks.length
            builders.push trucks[i]  if trucks[i].build(structure, pos)
            i++
    builders
