# ***Order Attributes***
# order:     order number
# like:      the unit name pattern
# power:     minimum power b/4 starting
# cost:      the power cost of the command
# limit:     the maximum group size
# min:       minimum number of units required to execute command.
# max:       maximum allowed number of units to execute command.
# help:      the number of helping units the job is willing to take.
# at:        preferred location (and direction).
# structure: structure to be built
# research:  technology to be researched
# body:
# propulsion:
# turret:
# cid:       the command id is set at the time the command is given.
# { name: min: max: order: employ: at: ... }

# CyberBorg::base_commands = (reserve, resources) ->

class Command
  @to_at = (o) -> {x: o.x.to_i(), y: o.y.to_i()}

  # @savings is... TODO
  constructor: (@limit=0, @savings=0) ->
    # Center point of our trucks.
    # ie. (10.5,236)
    @tc = Command.to_at Groups.RESERVE.trucks().center()
    Trace.out "Trucks around #{@tc.x}, #{@tc.y}" if Trace.on

    # cyberBorg can list all the resources available on the map and
    # sort them according to distance from where we are.
    # It will provide the AI a guide to our territorial expansion.
    @resources = CyberBorg.get_resources(@tc)

    # Center point of our first 4 resources.
    # ie. (12, 236.5)
    @rc = Command.to_at WZArray.bless(@resources[0..3]).center()
    Trace.out "Resources around #{@rc.x}, #{@rc.y}." if Trace.on

    # Which x direction towards resources
    @dx = 1
    @dx = -1 if @tc.x > @rc.x
    # Which y direction towards resources
    @dy = 1
    @dy = -1 if @tc.y > @rc.y

    # Spacing between maintain points
    @s = 4

    # Which way is the greater offset?
    @horizontal = false
    if (@rc.x-@tc.x)*@dx > (@rc.y-@tc.y)*@dy
      @horizontal = true

    # So let's see how many locations this will work,
    # and find ways to improve the heuristics.
    # We'll assume maintain is relative to trucks.
    @x = @tc.x
    @y = @tc.y

  #######################
  ### Base Structures ###
  #######################

  structure: (structureid, cost, obj={}) ->
    obj.structure = structureid
    obj.cost = cost
    obj

  command_center: (obj={}) -> @structure("A0CommandCentre", 100, obj)
  power_generator: (obj={}) -> @structure("A0PowerGenerator", 50, obj)
  power_module: (obj={}) -> @structure("A0PowMod1", 0, obj)
  research_facility: (obj={}) -> @structure("A0ResearchFacility", 100, obj)
  research_module: (obj={}) -> @structure("A0ResearchModule1", 100, obj)
  light_factory: (obj={}) -> @structure("A0LightFactory", 100, obj)
  factory_module: (obj={}) -> @structure("A0FacMod1", 100, obj)
  cyborg_factory: (obj={}) -> @structure("A0CyborgFactory", 100, obj)
  vtol_factory: (obj={}) -> @structure("A0VTolFactory1", 100, obj)
  command_relay_center: (obj={}) -> @structure("A0ComDroidControl", 100, obj)
  vtol_rearming_pad: (obj={}) -> @structure("A0VtolPad", 100, obj)
  repair_facility: (obj={}) -> @structure("A0RepairCentre3", 100, obj)
  oil_derrick: (obj={}) -> @structure("A0ResourceExtractor", 0, obj)

  ################
  ### Defenses ###
  ################

  ##############
  ### Turrets ###
  ##############

  trucker: (obj={}) ->
    obj.like = /Truck/
    obj.name = "Truck"
    obj.turret = "Spade1Mk1"
    obj.droid_type = DROID_CONSTRUCT
    obj

  gunner: (obj={}) ->
    obj.like = /Gun/
    obj.name = "Gun"
    obj.turret = ["MG3Mk1", "MG2Mk1", "MG1Mk1"]
    obj.droid_type = DROID_WEAPON
    obj

  ###############
  ### Cyborgs ###
  ###############

  ##############
  ### Bodies ###
  ##############

  body: (bname, bodyid, cost, obj={}) ->
    obj.body = bodyid
    obj.bname = bname
    obj.bcost = cost
    obj

  viper: (obj={}) -> @body("Viper", "Body1REC", 30, obj)
  cobra: (obj={}) -> @body("Cobra", "Body5REC", 46, obj)
  python: (obj={}) -> @body("Python", "Body11ABT", 60, obj)

  bug: (obj={}) -> @body("Bug", "Body4ABT", 25, obj)
  scorpion: (obj={}) -> @body("Scorpion", "Body8MBT", 39, obj)
  mantis: (obj={}) -> @body("Mantis", "Body12SUP", 52, obj)

  leopard: (obj={}) -> @body("Leopard", "Body2SUP", 41, obj)
  panther: (obj={}) -> @body("Panther", "Body6SUPP", 57, obj)
  tiger: (obj={}) -> @body("Tiger", "Body9REC", 71, obj)

  retaliation: (obj={}) -> @body("Retaliation", "Body3MBT", 68, obj)
  retribution: (obj={}) -> @body("Retribution", "Body7ABT", 100, obj)
  vengeance: (obj={}) -> @body("Vengeance", "Body10MBT", 130, obj)

  wyvern: (obj={}) -> @body("Wyvern", "Body13SUP", 156, obj)
  dragon: (obj={}) -> @body("Dragon", "Body14SUP", 182, obj)

  ##################
  ### Propulsion ###
  ##################

  propulsion: (pname, propulsionid, pcost, obj={}) ->
    obj.pname = pname
    obj.propulsion = propulsionid
    obj.pcost = pcost
    obj

  wheels: (obj={}) -> @propulsion("Wheels", "wheeled01", 1.5, obj)
  half_tracks: (obj={}) -> @propulsion("Half-tracks", "HalfTrack", 1.75, obj)
  hover: (obj={}) -> @propulsion("Hover", "hover01", 2.0, obj)
  tracks: (obj={}) -> @propulsion("Tracks", "tracked", 2.25, obj)
  vtol: (obj={}) -> @propulsion("VTOL", "V-Tol", 2.50, obj)

  ################
  ### Research ###
  ################

  ############
  ### Who? ###
  ############

  none: (obj={}) ->
    obj.like = /none/
    obj.limit = 0
    obj.min = 0
    obj.max = 0
    obj.help = 0
    obj

  truck: (obj={}) ->
    obj.like = /Truck/
    obj

  gun: (obj={}) ->
    obj.like = /Gun/
    obj

  factory: (obj={}) ->
    obj.like = /Factory/
    obj

  ##############
  ### Where? ###
  ##############

  at: (x, y, obj={}) ->
    obj.at = {x:x, y:y}
    obj

  ##############
  ### Orders ###
  ##############

  pursue: (research, cost, obj={}) ->
    obj.research = research
    obj.order = LORDER_RESEARCH
    obj.like = /Research Facility/
    obj.power = 0 # This just means we've not gone negative.
    obj.cost = cost
    obj.limit = @limit
    obj.min = 1
    obj.max = 1
    obj.help = 1
    obj

  manufacture: (obj={}) ->
    cost = 100 # TODO
    if obj.body and obj.propulsion and obj.turret
      # makeTemplate... :-??
      cost = 100
    obj.order = FORDER_MANUFACTURE
    obj.like = /Factory/
    obj.cost = cost
    obj

  maintain: (obj={}) ->
    if @savings > 0
      @savings -= obj.cost
    obj.order = DORDER_MAINTAIN
    obj.savings = @savings
    obj

  scout: (obj={}) ->
    obj.cost = 0
    obj.order = DORDER_SCOUT
    obj

  pass: (obj={}) ->
    obj.cost = 0
    obj.order = CORDER_PASS
    # 1 just means success in this case. Normally,
    # it would be the number of units that succesfully executed the command.
    obj.execute = (units) -> 1
    obj.cid = null
    obj

  #################
  ### How many? ###
  #################

  three: (obj={}) ->
    obj.limit = @limit # maximum group size
    obj.min = 1 # it will execute the command only with at least this amount
    obj.max = 3 # it will execute the command with no more than this amount
    obj.help = 0
    obj

  two: (obj={}) ->
    obj.limit = @limit # maximum group size
    obj.min = 1
    obj.max = 2
    obj.help = 0
    obj

  one: (obj={}) ->
    obj.limit = @limit # maximum group size
    obj.min = 1
    obj.max = 1
    obj.help = 0
    obj

  with_help: (obj={}) ->
    obj.help = 3
    obj

  ##########################
  ### Power requirements ###
  ##########################

  immediately: (obj={}) ->
    obj.power = null
    obj

  on_income: (obj={}) ->
    obj.power = -obj.cost/2
    obj

  on_budget: (obj={}) ->
    obj.power = 0
    obj

  on_surplus: (obj={}) ->
    obj.power = obj.cost
    obj

  on_glut: (obj={}) ->
    obj.power = 3*obj.cost
    obj

###############
### Aliases ###
###############
Command::maintains = Command::maintain
Command::manufactures = Command::manufacture
Command::trucks = Command::truck
Command::scouts = Command::scout
