# Let's find problems and fix'em.
start_trace = (event) ->
  ai.trace.out "Power level: #{ai.power} in #{event.name}"
  if structure = event.structure
    ai.trace.out "\tStructure: #{structure.namexy()}\tCost: #{structure.cost}"
  if research = event.research
    ai.trace.out "\tResearch: #{event.research.name}\tCost: #{research.power}"
  if droid = event.droid
    ai.trace.out "\tDroid: #{droid.namexy()}\tID:#{droid.id}\tCost: #{droid.cost}"

trace_command = (command) ->
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
  ai.trace.blue(keyvals.sort().join(' '))

# The bug report.
bug_report = (label, droid, event) ->
  order = droid.order
  dorder = droid.dorder
  ai.trace.out "#{label}:\t#{droid.namexy()}\tid:#{droid.id}\tevent:#{event.name}"
  ai.trace.out "\t\torder:#{order} => #{order.order_map()}"
  ai.trace.out "\t\tdorder:#{dorder} => #{dorder.order_map()}"
  if command = droid.command
    corder = command.order
    ai.trace.out "\t\t#{corder.order_map()}\t##{corder}\tcid:#{command.cid}"
    if command.structure
      ai.trace.out "\t\tstructure:#{command.structure}"
    if at = command.at
      ai.trace.out "\t\tat:(#{at.x},#{at.y})"
    if order is 0
      ai.trace.out "\t\tBUG: Quitter."
    else
      ai.trace.out "\t\tBUG: Order changed." unless order is droid.dorder
  if event.name is 'Destroyed'
    ai.trace.out "\t\t#{event.group?.name}'s #{event.object.namexy()} was destroyed."

# Re-issue command
gotcha_working = (droid, command = droid.command) ->
  centreView(droid.x, droid.y) if ai.trace.on
  if droid.executes(command)
    order = command.order
    if ai.trace.on
      ai.trace.green "\tRe-issued " +
      "#{order.order_map()}, ##{order}, to #{droid.name}."
  else
    ai.trace.red("\t#{droid.name} is a lazy bum!")

# Report selected droids.
gotcha_selected = (event) ->
  count = 0
  # Selected units
  for droid in ai.groups.for_all((object) -> object.selected)
    count += 1
    bug_report("Selected", droid, event) if ai.trace.on
  return count

# Report idle droids.
gotcha_idle = (event) ->
  count = 0
  # Idle units under command
  is_quitter = (object) -> object.order is 0 and object.command?
  for droid in ai.groups.for_all(is_quitter)
    count += 1
    bug_report("Quitter", droid, event) if ai.trace.on
    # OK, let's circumvent the game bugs...
    gotcha_working(droid)
  return count

# Report droids under command which are acting their own...
gotcha_rogue = (event) ->
  count = 0
  rogue = (object) ->
    if object.command?
      # Units under command not idle but acting on different orders
      return true unless (object.order is 0) or (object.order is object.dorder)
    return false
  for droid in ai.groups.for_all((object) -> rogue(object))
    count += 1
    bug_report("Rogue", droid, event) if ai.trace.on
    command = droid.command
    if command?.order is 28
      centreView(droid.x, droid.y) if ai.trace.on
      gotcha_working(droid, command)
    else
      ai.trace.red("\tUncaught rogue case.")
  return count

gotchas = (event) ->
  counts = count = 0
  for gotcha in [gotcha_selected, gotcha_idle, gotcha_rogue]
    if count = gotcha(event)
      counts += count
      ai.trace.out "" if ai.trace.on
  ai.trace.out "" if ai.trace.on and counts
