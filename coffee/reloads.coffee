# Let's find problems and fix'em.
# The bug report.
bug_report = (label,droid,event) ->
  command = null
  dorder = droid.order
  trace "#{label}:\t#{droid.namexy()}\tid:#{droid.id}\tevent:#{event.name}"
  trace "\t\torder number:#{dorder} => #{dorder.order_map()}"
  if command = droid.command
    number = command.number
    trace "\t\t#{number.order_map()}\t##{number}\tcid:#{command.cid}"
    if command.structure
      trace "\t\tstructure:#{command.structure}"
    if at = command.at
      trace "\t\tat:(#{at.x},#{at.y})"
    if dorder is 0
      trace "\t\tBUG: Quitter."
    else
      trace "\t\tBUG: Order changed." unless dorder is command.number
  if event.name is "Destroyed"
    trace "\t\t#{event.group?.name}'s #{event.object.namexy()} was destroyed."
  return command

# Re-issue command
gotcha_working = (droid, command) ->
  centreView(droid.x, droid.y) if CyberBorg.TRACE
  if droid.executes(command)
    number = command.number
    trace("\tRe-issued #{number.order_map()}, ##{number}, to #{droid.name}.")
  else
    trace("\t#{droid.name} is a lazy bum!")

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
    if command and
    event.name is "Destroyed" and
    event.object.name is "Oil Derrick" and
    droid.name is 'Truck' and
    command.structure is 'A0ResourceExtractor'
      gotcha_working(droid, command)
  return count

# Report droids under command which are acting their own...
gotcha_rogue = (event) ->
  count = 0
  rogue = (object) ->
    if object.command
      return true unless object.order is object.command.number
    return false
  for droid in cyberBorg.for_all((object) -> rogue(object))
    count += 1
    command = bug_report("Rogue", droid, event)
    if command?.number is 28
      centreView(droid.x, droid.y) if CyberBorg.TRACE
      gotcha_working(droid, command)
  return count

gotchas = (event) ->
  counts = count = 0
  for gotcha in [gotcha_selected, gotcha_idle, gotcha_rogue]
    if count = gotcha(event)
      counts += count
      trace ""
  trace "" if counts
