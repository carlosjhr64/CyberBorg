# The Group Class
class Group
  constructor: (@name, @rank, @group=[], @commands=[], @reserve=[]) ->
    for list in [@group, @commands, @reserve]
      WZArray.bless(list) unless list.is_wzarray
    @list = @group # alias

  add: (droid) ->
    # Need to enforce the reserve condition
    if @reserve.contains(droid)
      @reserve.removeObject(droid)
      @group.push(droid)
    else
      throw new Error("Can't add #{droid.namexy()} b/c it's not in reserve.")

  remove: (droid) ->
    # Need to enforce the group to reserve condition
    if @group.contains(droid)
      @group.removeObject(droid)
      @reserve.push(droid)
    else
      red_alert "Can't remove #{droid.name} b/c it's not in group."

  layoffs: (command) ->
    # Ensure the AI's process...
    if command.cid?
      for unit in @group.in_cid(command.cid)
        @remove(unit)
        unit.order = IS_LAIDOFF
        unit.command = null # droid laidoff
      command.cid = null # command completed
    else
      red_alert "Command without cid"

  units: (command) ->
    min = command.min
    limit = command.limit
    size = @group.length

    # Check the group limit
    return null if size + min > limit

    units = @reserve.like(command.like)
    # Check we have the minimum units required for the command.
    # If not, shortcut out of this function.
    return null if units.length < min

    # Sort by distance to site if given at.
    units.nearest(command.at) if command.at

    max = command.max
    if size + max > limit
      max = limit - size

    # Let's cap the units if more than max
    units = units.cap(max) if units.length > max

    return units

  order_units: (command) ->
    count = 0
    if units = @units(command)
      cid = CyberBorg.cid() # A unique command id.
      for unit in units
        if unit.executes(command)
          unit.command = command
          @add(unit)
          count += 1
      command.cid = cid if count
    count

  execute: (command) ->
    count = 0
    # If the power requirement is zero, just go ahead...
    if ((command.power is 0) or (cyberBorg.power > command.power))
      count = @order_units(command)
      # Does the command have it's own execute?
      if command.execute?
        # b/c we now execute volatile code,
        # we enclose it in a try/catch block.
        try
          count = command.execute(@)
        catch error
          red_alert error
          count = 0
    # We regardless deduct the command cost from available power b/c
    # we want to make the lower ranks aware of the power
    # actually available for them... that we're saving toward this
    # command's goals.
    cyberBorg.power -= command.cost
    return count
