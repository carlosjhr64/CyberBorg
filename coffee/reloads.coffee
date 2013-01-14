# Let's find problems and fix'em
bug_report = (label,droid,event) ->
  order = null
  oid = droid.oid
  trace "#{label}:\t#{droid.namexy()}\tid:#{droid.id}\tevent:#{event.name}"
  number = droid.order
  trace "\t\toid:#{oid}\torder number:#{number} => #{CyberBorg.ORDER_MAP[number]}"
  if oid
    order = cyberBorg.get_order(oid)
    if order
      trace "\t\tfunction:#{order.function}\tnumber:#{order.number}"
      if order.structure
        trace "\t\tstructure:#{order.structure}"
      if at = order.at
        trace "\t\tat:(#{at.x},#{at.y})"
      trace "\t\tBUG: Quitter." if number is 0
      trace "\t\tBUG: Order changed." unless number is order.number
    else
      trace "\t\tBUG: Order on oid does not exist."
  if event.name is "Destroyed"
    trace "\t\t#{event.group?.name}'s #{event.object.namexy()} was destroyed."
  return order

gotchas = (event) ->
  nwl = false
  ###
  for droid in cyberBorg.for_all((object) -> object.selected)
    nwl = true
    bug_report("Selected", droid, event)
  for droid in cyberBorg.for_all((object) -> object.order is 0)
    nwl = true
    order = bug_report("Idle", droid, event)
    # OK, let's circumvent the game bugs...
    if event.name is "Destroyed" and event.object.name is "Oil Derrick"
      if order and order.function is 'orderDroidBuild' and
      order.structure is 'A0ResourceExtractor'
        if droid.executes(order)
          trace("\tRe-issued derrick build order")
        else
          trace("\tOh! The Humanity!!!")
  ###
  # Find droids under orders which are guarding instead
  for droid in cyberBorg.for_all((object) -> object.oid and object.order is 25 )
    nwl = true
    order = bug_report("Guarding", droid, event)
    if order?.number is 28
      cameraSlice(droid.x, droid.y)
      if droid.executes(order)
        trace("\tRe-issued scout move order")
      else
        trace("\tLazy scout!")
  trace("") if nwl
