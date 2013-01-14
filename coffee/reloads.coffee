# Let's find problems and fix'em.
# The bug report.
bug_report = (label,droid,event) ->
  order = null
  dorder = droid.order
  trace "#{label}:\t#{droid.namexy()}\tid:#{droid.id}\tevent:#{event.name}"
  trace "\t\torder number:#{dorder} => #{dorder.order_map()}"
  if oid = droid.oid
    order = cyberBorg.get_order(oid)
    if order
      number = order.number
      trace "\t\t#{number.order_map()}\t##{number}\toid:#{oid}"
      if order.structure
        trace "\t\tstructure:#{order.structure}"
      if at = order.at
        trace "\t\tat:(#{at.x},#{at.y})"
      if dorder is 0
        trace "\t\tBUG: Quitter."
      else
        trace "\t\tBUG: Order changed." unless dorder is order.number
    else
      trace "\t\tBUG: Order on oid #{oid} does not exist."
  if event.name is "Destroyed"
    trace "\t\t#{event.group?.name}'s #{event.object.namexy()} was destroyed."
  return order

# Re-issue order
gotcha_working = (droid, order) ->
  centreView(droid.x, droid.y) if CyberBorg.TRACE
  if droid.executes(order)
    number = order.number
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
    order = bug_report("Idle", droid, event)
    # OK, let's circumvent the game bugs...
    if order and
    event.name is "Destroyed" and
    event.object.name is "Oil Derrick" and
    droid.name is 'Truck' and
    order.structure is 'A0ResourceExtractor'
      gotcha_working(droid, order)
  return count

# Report droids under orders which are acting their own...
gotcha_rogue = (event) ->
  count = 0
  rogue = (object) ->
    if oid = object.oid
      return true unless object.order is cyberBorg.get_order(oid)?.number
    return false
  for droid in cyberBorg.for_all((object) -> rogue(object))
    count += 1
    order = bug_report("Rogue", droid, event)
    if order?.number is 28
      centreView(droid.x, droid.y) if CyberBorg.TRACE
      gotcha_working(droid, order)
  return count

gotchas = (event) ->
  counts = count = 0
  for gotcha in [gotcha_selected, gotcha_idle, gotcha_rogue]
    if count = gotcha(event)
      counts += count
      trace ""
  trace "" if counts
