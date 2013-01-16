# The Group Class
class Group
  constructor: (@name, @rank, @group=[], @commands=[], @reserve=[]) ->
    for list in [@group, @commands, @reserve]
      WZArray.bless(list) unless list.is_wzarray
    @list = @group # alias
    # TODO check the commands for errors?

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
      droid.order = CyberBorg.IS_IDLE
    else
      throw new Error("Can't remove #{droid.namexy()} b/c it's not in group.")

  layoffs: (command, reset=null) ->
    # Ensure the AI's process...
    throw new Error("Command without cid") unless command.cid
    for unit in @group.in_cid(command.cid)
      @remove(unit)
      unit.command = reset # droid laidoff
    command.cid = reset # command completed

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

  execute: (command) ->
    count = 0
    if cyberBorg.power > command.power and units = @units(command)
      cid = CyberBorg.cid() # A unique command id.
      for unit in units
        if unit.executes(command)
          unit.command = command
          @add(unit)
          count += 1
      if count
        command.cid = cid
        cyberBorg.power -= command.cost
    return count
