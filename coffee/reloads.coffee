# Let's find problems and fix'em.

start_trace = (event) ->
  trace "Power level: #{cyberBorg.power} in #{event.name}"
  if structure = event.structure
    trace "\tStructure: #{structure.namexy()}\tCost: #{structure.cost}"
  if research = event.research
    trace "\tResearch: #{event.research.name}\tCost: #{research.power}"
  if droid = event.droid
    trace "\tDroid: #{droid.namexy()}\tID:#{droid.id}\tCost: #{droid.cost}"

# The bug report.
bug_report = (label,droid,event) ->
  command = null
  order = droid.order
  dorder = droid.dorder
  trace "#{label}:\t#{droid.namexy()}\tid:#{droid.id}\tevent:#{event.name}"
  trace "\t\torder:#{order} => #{order.order_map()}"
  trace "\t\tdorder:#{dorder} => #{dorder.order_map()}"
  if command = droid.command
    corder = command.order
    trace "\t\t#{corder.order_map()}\t##{corder}\tcid:#{command.cid}"
    if command.structure
      trace "\t\tstructure:#{command.structure}"
    if at = command.at
      trace "\t\tat:(#{at.x},#{at.y})"
    if order is 0
      trace "\t\tBUG: Quitter."
    else
      trace "\t\tBUG: Order changed." unless order is droid.dorder
  if event.name is "Destroyed"
    trace "\t\t#{event.group?.name}'s #{event.object.namexy()} was destroyed."
  return command

# Re-issue command
gotcha_working = (droid, command) ->
  centreView(droid.x, droid.y) if CyberBorg.TRACE
  if droid.executes(command)
    order = command.order
    trace("\t\033[1;32mRe-issued #{order.order_map()}, ##{order}, to #{droid.name}.\033[0m")
  else
    trace("\t\033[1;31#{droid.name} is a lazy bum!\033[0m")

# Report selected droids.
gotcha_selected = (event) ->
  count = 0
  for droid in cyberBorg.for_all((object) -> object.selected)
    count += 1
    bug_report("Selected", droid, event)
  return count

# Report idle droids.
gotcha_idle = (event) ->
  count = 0
  for droid in cyberBorg.for_all((object) -> object.order is 0)
    count += 1
    command = bug_report("Idle", droid, event)
    # OK, let's circumvent the game bugs...
    gotcha_working(droid, command)
  return count

# Report droids under command which are acting their own...
gotcha_rogue = (event) ->
  count = 0
  rogue = (object) ->
    if object.command
      return true unless (object.order is 0) or (object.order is object.dorder)
    return false
  for droid in cyberBorg.for_all((object) -> rogue(object))
    count += 1
    command = bug_report("Rogue", droid, event)
    if command?.order is 28
      centreView(droid.x, droid.y) if CyberBorg.TRACE
      gotcha_working(droid, command)
    else
      trace("\33[1;31mUncaught rogue case.\033[0m")
  return count

gotchas = (event) ->
  counts = count = 0
  for gotcha in [gotcha_selected, gotcha_idle, gotcha_rogue]
    if count = gotcha(event)
      counts += count
      trace ""
  trace "" if counts
