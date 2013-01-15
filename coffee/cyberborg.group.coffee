# The Group Class
class Group
  constructor: (@name, @rank, @group, @commands, @reserve) ->
    # If we're not given a list of droids,
    # get them from enumDroid (all of the player's pieces).
    @group = CyberBorg.enum_droid() unless @group
    WZArray.bless(@group) unless @group.is_wzarray
    @list = @group # alias
    # commands is a list of things for the group to do
    @commands = WZArray.bless([]) unless @commands
    WZArray.bless(@commands) unless @commands.is_wzarray
    # reserve are the units we can draw from.
    @reserve = WZArray.bless([]) unless @reserve
    WZArray.bless(@reserve) unless @reserve.is_wzarray
    # TODO check the commands for errors?

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

  layoffs: (cid, reset=null) ->
    for unit in @group.in_cid(cid)
      @remove(unit)
      unit.cid = reset # droid laidoff
    if command = @commands.get_command(cid)
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
          unit.cid = cid
          @add(unit)
          count += 1
      if count
        command.cid = cid
        cyberBorg.power -= command.cost
    return count
