DERRICKS  = 'Derricks'	# will build derricks
SCOUTS    = 'Scouts'	# will scout and guard the area
script = () ->
  groups = cyberBorg.groups
  reserve = cyberBorg.reserve
  resources = cyberBorg.resources


  derricks = new Group(DERRICKS, 90, [],
  cyberBorg.derricks_commands(resources), reserve)
  groups.push(derricks)

  scouts = new Group(SCOUTS, 70, [],
  cyberBorg.scouts_commands(resources), reserve)
  groups.push(scouts)
