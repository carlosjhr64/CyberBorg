# The Group Class
class Group
  constructor: (@name, @rank, @group, @orders, @reserve) ->
    # If we're not given a list of droids,
    # get them from enumDroid (all of the player's pieces).
    @group = CyberBorg.enum_droid() unless @group
    WZArray.bless(@group) unless @group.is_wzarray
    @list = @group # alias
    # orders is a list of things for the group to do
    @orders = WZArray.bless([]) unless @orders
    WZArray.bless(@orders) unless @orders.is_wzarray
    # reserve are the units we can draw from.
    @reserve = WZArray.bless([]) unless @reserve
    WZArray.bless(@reserve) unless @reserve.is_wzarray
    # TODO check the orders for errors?

  add: (droid) ->
    # Need to enforce the reserve condition
    if @reserve.contains(droid)
      @reserve.removeObject(droid)
      @group.push(droid)
    else
      throw new Error("Can't add #{droid.namexy()} b/c it's not in reserve.")

  remove: (droid) ->
    if @group.contains(droid)
      @group.removeObject(droid)
      @reserve.push(droid)
      droid.order = CyberBorg.IS_IDLE
    else
      throw new Error("Can't remove #{droid.namexy()} b/c it's not in group.")

  units: (order) ->
    units = @group.idle().like(order.like)

    # Limits the maximum size of group (idle or not)
    if @group.length < order.limit
      # Do we need to recruit?
      if units.length < order.recruit
        # Note the reserve is expected to be idle
        # Just add reserve for now
        units = units.add(@reserve.like(order.like))

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
        @remove(unit) if @group.contains(unit)

    # Let's cap the units if more than max
    units = units.cap(max) if units.length > max
    # Will this order take help?
    order.help = order.recruit - units.length
    units

  execute: (order) ->
    executers = [] # Going to return the units executing order.
    units = @units(order)
    if units
      if cyberBorg.power > order.power
        for unit in units
          if unit.executes(order)
            executers.push(unit)
      else
        @remove(unit) for unit in units
    cyberBorg.power = cyberBorg.power - order.cost if executers.length > 0
    return executers
