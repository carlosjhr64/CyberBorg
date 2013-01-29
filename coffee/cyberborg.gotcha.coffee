# Let's find problems and fix'em.
class Gotcha
  constructor: (@ai, @trace=@ai.trace) ->

  start: (event) ->
    @trace.out "Power level: #{@ai.power} in #{event.name}"
    if structure = event.structure
      @trace.out "\t#{structure.namexy()}\tCost: #{structure.cost}"
    if research = event.research
      @trace.out "\t#{event.research.name}\tCost: #{research.power}"
    if droid = event.droid
      @trace.out "\t#{droid.namexy()}\tID:#{droid.id}\tCost: #{droid.cost}"

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
    @trace.blue(keyvals.sort().join(' '))

  # The bug report.
  bug_report: (label, droid, event) ->
    order = droid.order
    dorder = droid.dorder
    @trace.out "#{label}:\t#{droid.namexy()}\tid:#{droid.id}\t"
    @trace.out "\t\tevent: #{event.name}"
    @trace.out "\t\torder: #{order} => #{order.order_map()}"
    @trace.out "\t\tdorder: #{dorder} => #{dorder.order_map()}"
    if command = droid.command
      corder = command.order
      @trace.out "\t\t#{corder.order_map()}\t##{corder}\tcid:#{command.cid}"
      if command.structure
        @trace.out "\t\tstructure:#{command.structure}"
      if at = command.at
        @trace.out "\t\tat:(#{at.x},#{at.y})"
      if order is 0
        @trace.out "\t\tBUG: Quitter."
      else
        @trace.out "\t\tBUG: Order changed." unless order is droid.dorder
    if event.name is 'Destroyed'
      group = event.group?.name
      object = event.object.namexy()
      @trace.out "\t\t#{group}'s #{object} destroyed."

  # Re-issue command
  working: (droid, command = droid.command) ->
    centreView(droid.x, droid.y) if @trace.on
    if droid.executes(command)
      order = command.order
      if @trace.on
        @trace.green "\tRe-issued " +
        "#{order.order_map()}, ##{order}, to #{droid.name}."
    else
      @trace.red("\t#{droid.name} is a lazy bum!")

  # Report selected droids.
  selected: (event) ->
    count = 0
    # Selected units
    for droid in @ai.groups.for_all((object) -> object.selected)
      count += 1
      @bug_report("Selected", droid, event) if @trace.on
    return count

  # Report idle droids.
  idle: (event) ->
    count = 0
    # Idle units under command
    is_quitter = (object) -> object.order is 0 and object.command?
    for droid in @ai.groups.for_all(is_quitter)
      count += 1
      @bug_report("Quitter", droid, event) if @trace.on
      # OK, let's circumvent the game bugs...
      @working(droid)
    return count

  # Report droids under command which are acting their own...
  rogue: (event) ->
    count = 0
    rogue = (object) ->
      if object.command?
        # Units under command not idle but acting on different orders
        unless (object.order is 0) or (object.order is object.dorder)
          return true
      return false
    for droid in @ai.groups.for_all((object) -> rogue(object))
      count += 1
      @bug_report("Rogue", droid, event) if @trace.on
      command = droid.command
      if command?.order is 28
        centreView(droid.x, droid.y) if @trace.on
        @working(droid, command)
      else
        @trace.red("\tUncaught rogue case.")
    return count

  end: (event) ->
    counts = count = 0
    # JS had OOP troubles with the for..in...
    #for gotcha in [@selected, @idle, @rogue]
    if count = @selected(event) and @trace.on
      counts += count
      @trace.out ""
    if count = @idle(event) and @trace.on
      counts += count
      @trace.out ""
    if count = @rogue(event) and @trace.on
      counts += count
      @trace.out ""
    @trace.out "" if @trace.on and counts
