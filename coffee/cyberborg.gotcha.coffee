# Let's find problems and fix'em.
class Gotcha
  constructor: (@ai) ->

  start: (event) ->
    Trace.out "Power: #{@ai.power}  Event: #{event.name}  " +
    "Time: #{gameTime}"
    if structure = event.structure
      Trace.out "\t#{structure.namexy()}\tCost: #{structure.cost}"
    if research = event.research
      Trace.out "\t#{event.research.name}\tCost: #{research.power}"
    if droid = event.droid
      Trace.out "\t#{droid.namexy()}\tID:#{droid.id}\tCost: #{droid.cost}"
    position = @ai.location.position
    too_dangerous = @ai.too_dangerous_level()
    for coordinate of position
      danger_level = position[coordinate]
      if danger_level > too_dangerous
        Trace.out "Danger area: #{coordinate} #{danger_level.to_i()}"

  command: (command) ->
    keyvals = []
    for key of command
      switch key
        when 'at'
          at = command.at
          keyvals.push("#{key}:{#{at.x},#{at.y}}")
        when 'execute'
          keyvals.push("execute:->")
        else
          keyvals.push("#{key}:#{command[key]}")
    Trace.blue(keyvals.sort().join(' '))

  # The bug report.
  bug_report: (label, droid, event) ->
    order = droid.order
    dorder = droid.dorder
    Trace.out "#{label}:\t#{droid.namexy()}\t" +
    "id:#{droid.id}\thealth:#{droid.health}"
    Trace.out "\tevent: #{event.name}"
    Trace.out "\torder: #{order} => #{order.order_map()}" if order?
    Trace.out "\tdorder: #{dorder} => #{dorder.order_map()}" if dorder?
    if command = droid.command
      corder = command.order
      Trace.out "\t\t#{corder?.order_map()}\t##{corder}\tcid:#{command.cid}"
      if command.structure
        Trace.out "\t\tstructure:#{command.structure}"
      if at = command.at
        Trace.out "\t\tat:(#{at.x},#{at.y})"
      if order is 0
        Trace.out "\t\tBUG: Quitter."
      else
        Trace.out "\t\tBUG: Order changed." unless order is droid.dorder
    if event.name is 'Destroyed'
      group = event.group?.name
      object = event.object.namexy()
      Trace.out "\t\t#{group}'s #{object} destroyed."

  # Re-issue command
  working: (droid, command = droid.command) ->
    if at = command.at
      if @ai.dangerous(at)
        GROUPS.finds(droid).group.layoffs(command)
        return
    if droid.executes(command)
      order = command.order
      if Trace.on
        Trace.blue "\tRe-issued " +
        "#{order.order_map()}, ##{order}, to #{droid.name}."
    else
      Trace.red("\t#{droid.name} is a lazy bum!")

  # Report selected droids.
  selected: (event) ->
    count = 0
    # Selected units
    for droid in GROUPS.for_all((object) -> object.selected)
      count += 1
      @bug_report("Selected", droid, event) if Trace.on
    return count

  # Report idle droids.
  idle: (event) ->
    count = 0
    # Idle units under command
    is_quitter = (object) -> object.order is 0 and object.command?
    for droid in GROUPS.for_all(is_quitter)
      count += 1
      @bug_report("Quitter", droid, event) if Trace.on
      # OK, let's circumvent the game bugs...
      @working(droid)
    return count

  @routed = (order) ->
    [ 0
      DORDER_RTB
      DORDER_RTR
      DORDER_RECYCLE
    ].indexOf(order) > WZArray.NONE

  # Report droids under command which are acting their own...
  rogue: (event) ->
    count = 0
    rogue = (object) ->
      if object.command?
        order = object.order
        # Units under command not idle but acting on different orders
        unless (order is object.dorder) or Gotcha.routed(order)
          return true
      return false
    for droid in GROUPS.for_all((object) -> rogue(object))
      count += 1
      @bug_report("Rogue", droid, event) if Trace.on
      command = droid.command
      if command?.order is 28
        @working(droid, command)
      else
        order = droid.order.order_map()
        Trace.red "\tUncaught rogue case: #{droid.namexy()} #{order}."
        dorder = droid.dorder?.order_map()
        corder = droid.corder?.order_map()
        Trace.red "\t\tWanted #{corder} => #{dorder}."
    return count

  end: (event) ->
    counts = count = 0
    # JS had OOP troubles with the for..in...
    #for gotcha in [@selected, @idle, @rogue]
    if count = @selected(event) and Trace.on
      counts += count
      Trace.out ""
    if count = @idle(event) and Trace.on
      counts += count
      Trace.out ""
    if count = @rogue(event) and Trace.on
      counts += count
      Trace.out ""
    Trace.out "" if Trace.on and counts
