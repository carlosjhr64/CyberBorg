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

  layoffs: (oid, reset=null) ->
    for unit in @group.in_oid(oid)
      @remove(unit)
      unit.oid = reset # droid laidoff
    if order = @orders.get_order(oid)
      order.oid = reset # order completed

  units: (order) ->
    min = order.min
    limit = order.limit
    size = @group.length

    # Check the group limit
    return null if size + min > limit

    units = @reserve.like(order.like)
    # Check we have the minimum units required for the order.
    # If not, shortcut out of this function.
    return null if units.length < min

    # Sort by distance to site if given at.
    units.nearest(order.at) if order.at

    max = order.max
    if size + max > limit
      max = limit - size

    # Let's cap the units if more than max
    units = units.cap(max) if units.length > max

    return units

  execute: (order) ->
    count = 0
    if cyberBorg.power > order.power and units = @units(order)
      oid = CyberBorg.oid() # A unique order id.
      for unit in units
        if unit.executes(order)
          unit.oid = oid
          @add(unit)
          count += 1
      if count
        order.oid = oid
        cyberBorg.power -= order.cost
    return count
