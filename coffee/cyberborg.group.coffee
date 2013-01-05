# The Group Class
class Group
  constructor: (@name, @rank, @group, @orders, @reserve) ->
    # If we're not given a list of droids,
    # get them from enumDroid (all of the player's pieces).
    if @group then WZArray.bless(@group) else @group = CyberBorg.enum_droid()
    @list = @group # alias
    # orders is a list of things for the group to do
    if @orders then WZArray.bless(@orders) else @orders = WZArray.bless([])
    # reserve are the units we can draw from.
    if @reserves then WZArray.bless(@reserves) else @reserves = WZArray.bless([])

  add: (droid) ->
    # Need to enforce the reserve codition
    if @reserve.contains(droid)
      @reserve.removeObject(droid)
      @group.push(droid)
    else
      throw new Error("Can't add #{droid.namexy} b/c it's not in reserve.")

  remove: (droid) ->
    if @group.contains(droid)
      @group.removeObject(droid)
      @reserve.push(droid)
    else
      throw new Error("Can't remove #{droid.namexy} b/c it's not in group.")

  ###

  # We have a droid applying for base group.
  # Returns true if droid gets employed.
  # This allows a chain of employment applications.
  applying: (droid) ->
    # See if we're employing
    name = droid.name
    # Group may be just about to start
    order = @orders.current() or @orders.first()
    employ = order.employ(name)
    return false if not employ or @group.counts_named(name) >= employ
    # OK, you're in!
    # TODO should help right away
    @add(droid)
    true

  recruit: (n, type, at) ->
    recruits = @reserve
    # NOTE: recruits won't be this.reserve if filtered!
    recruits = recruits.filters(type)  if type
    recruits.nearest at  if at
    i = 0
    while i < n
      break  unless recruits[0]
      droid = recruits.shift()
      @add(droid)
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
      @remove(droid)
      i++

  buildDroid: (order) ->
    factories = @group.factories().idle()
    i = 0
    while i < factories.length
      # Want factory.build(...)
      return (factories[i])  if buildDroid(factories[i], order.name, order.body, order.propulsion, "", order.droid_type, order.turret)
      i++
    null

  build: (order) -> #PREDICATE!  TODO this method goes away!
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
        pos = at
        #if structure != "A0ResourceExtractor"
        #  # TODO DEBUG why is pickStructLocation not giving me "at" back?
        #  # when I can actually build at "at"???
        #  pos = pickStructLocation(trucks[0], structure, at.x, at.y)
        if pos
          debug("#{structure}: at is #{at.x},#{at.y} but pos is #{pos.x},#{pos.y}")
          i = 0
          while i < trucks.length
            truck = trucks[i]
            if truck.execute(order)
              # TODO this should be better abstracted, use order.order
              truck.order = DORDER_BUILD
              builders.push(truck)
            i++
    builders

  ###

  units: (order) ->
    units = @group.idle()
    units = units.like(order.like) if order.like

    # Limits the maximum size of group (idle or not)
    if @group.length < order.limit
      # Do we need to recruit?
      if order.recruit and units.length < order.recruit
        # Note the reserve is expected to be idle
        reserve = @reserve
        reserve = reserve.like(order.like) if order.like
        # Just add reserve for now
        units = units.add(reserve)

      # Do we need to conscript?
      if order.constript and units.length < order.conscript
        debug("Order conscript not implemented")
        # TODO conscript some more units
        # This one get's complicated b/c it takes droids already employed in other groups.
        # Should check rank to ensure lower ranks don't take from higher ranks.
    
    # Check we have the minimum units required for the order.
    # If not, shotcut out of this function.
    return null if units.length < order.min

    # Sort by distance to site if given at.
    units.nearest(order.at) if order.at

    # Select units in and out of the group
    max = order.max
    count = 0
    for unit in units
      count += 1
      if count <= max
        @add(unit) if not @group.contains(unit)
      else
        if count > order.cut
          @remove(unit) if @group.contains(unit)

    # Let cap the units if more than max
    units = units.cap(max) if units.length > max
    units

  execute: (order, units=@units(order)) ->
    executers = [] # Going to return the units executing order.
    if units
      for unit in units
        if unit.executes(order)
          # Unit no longer idle
          unit.order = order.number
          executers.push(unit)
    return executers
