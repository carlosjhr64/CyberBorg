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

  structure: (name, structureid, cost, obj={}) ->
    obj.name = name
    obj.structure = structureid
    obj.cost = cost
    obj

  command_center: (obj={}) ->
    @structure("Command Center", "A0CommandCentre", 100, obj)
  power_generator: (obj={}) ->
    @structure("Power Generator", "A0PowerGenerator", 50, obj)
  power_module: (obj={}) ->
    @structure("Power Module", "A0PowMod1", 0, obj)
  research_facility: (obj={}) ->
    @structure("Research Facility", "A0ResearchFacility", 100, obj)
  research_module: (obj={}) ->
    @structure("Research Module", "A0ResearchModule1", 100, obj)
  light_factory: (obj={}) ->
    @structure("Factory", "A0LightFactory", 100, obj)
  factory_module: (obj={}) ->
    @structure("Factory Module", "A0FacMod1", 100, obj)
  cyborg_factory: (obj={}) ->
    @structure("Cyborg Factory", "A0CyborgFactory", 100, obj)
  vtol_factory: (obj={}) ->
    @structure("VTOL Factory", "A0VTolFactory1", 100, obj)
  command_relay_center: (obj={}) ->
    @structure("Command Relay Center", "A0ComDroidControl", 100, obj)
  vtol_rearming_pad: (obj={}) ->
    @structure("VTOL Rearming Pad", "A0VtolPad", 100, obj)
  repair_facility: (obj={}) ->
    @structure("Repair Facility", "A0RepairCentre3", 100, obj)
  oil_derrick: (obj={}) ->
    @structure("Oil Derrick", "A0ResourceExtractor", 0, obj)

  ################
  ### Defenses ###
  ################

  # Walls
  tank_traps: (obj={}) ->
    @structure("Tank Traps", "A0TankTrap", 15, obj)
  hardcrete: (obj={}) ->
    @structure("Hardcrete Wall", "A0HardcreteMk1Wall", 25, obj)

  # Sensor structures
  sensor_tower: (obj={}) ->
    @structure("Sensor Tower", "Sys-SensoTower01", 60, obj)
  radar_detector_tower: (obj={}) ->
    @structure("Radar Detector Tower", "Sys-RadarDetector01", 100, obj)
  cb_tower: (obj={}) ->
     @structure("CB Tower", "Sys-CB-Tower01", 100, obj)
  hardened_sensor: (obj={}) ->
     @structure("Hardened Sensor Tower", "Sys-SensoTower02", 100, obj)
  vtol_cb_tower: (obj={}) ->
     @structure("VTOL CB Tower", "Sys-VTOL-CB-Tower01", 100, obj)
  vtol_strike_tower: (obj={}) ->
     @structure("VTOL Strike Tower", "Sys-VTOL-RadarTower01", 100, obj)
  wide_spectrum_sensor_tower: (obj={}) ->
     @structure("Wide Spectrum Sensor Tower", "Sys-SensoTowerWS", 250, obj)
  satellite_uplink_center: (obj={}) ->
     @structure("Satellite Uplink Center", "A0Sat-linkCentre", 1000, obj)

  # Weapons structures

  # Towers, emplacements, and Hardpoints.
  machinegun_guard_tower: (obj={}) ->
    @structure("Machinegun Guard Tower", "GuardTower1", 100, obj)
  pulse_laser_tower: (obj={}) ->
    @structure("Pulse Laser Tower", "GuardTower-BeamLas", 200, obj)
  needle_gun_tower: (obj={}) ->
    @structure("Needle Gun Tower", "GuardTower-Rail1", 275, obj)
  scourge_missile_tower: (obj={}) ->
    @structure("Scourge Missile Tower", "GuardTower-ATMiss", 325, obj)
  mini_rocket_tower: (obj={}) ->
    @structure("Mini-Rocket Tower", "GuardTower6", 100, obj)
  lancer_tower: (obj={}) ->
    @structure("Lancer Tower", "GuardTower5", 150, obj)
  hpv_emplacement: (obj={}) ->
    @structure("Hyper Velocity Cannon Emplacement", "Emplacement-HPVcannon", 200, obj)
  flashlight_emplacement: (obj={}) ->
    @structure("Flashlight Emplacement", "Emplacement-PrisLas", 275, obj)
  tank_killer_emplacement: (obj={}) ->
    @structure("Tank Killer Emplacement", "Emplacement-HvyATrocket", 275, obj)
  plasma_cannon_emplacement: (obj={}) ->
    @structure("Plasma Cannon Emplacement", "Emplacement-PlasmaCannon", 300, obj)
  railgun_emplacement: (obj={}) ->
    @structure("Railgun Emplacement", "Emplacement-Rail2", 350, obj)
  gauss_cannon_emplacement: (obj={}) ->
    @structure("Gauss Cannon Emplacement", "Emplacement-Rail3", 450, obj)
  heavy_laser_emplacement: (obj={}) ->
    @structure("Heavy Laser Emplacement", "Emplacement-HeavyLaser", 500, obj)
  heavy_machinegun_hardpoint: (obj={}) ->
    @structure("Heavy Machinegun Hardpoint", "WallTower01", 100, obj)
  light_cannon_hardpoint: (obj={}) ->
    @structure("Light Cannon Hardpoint", "WallTower02", 125, obj)
  assault_gun_hardpoint: (obj={}) ->
    @structure("Assault Gun Hardpoint", "Wall-RotMg", 150, obj)
  lancer_hardpoint: (obj={}) ->
    @structure("Lancer Hardpoint", "WallTower06", 175, obj)
  medium_cannon_hardpoint: (obj={}) ->
    @structure("Medium Cannon Hardpoint", "WallTower03", 200, obj)
  hpv_hardpoint: (obj={}) ->
    @structure("Hyper Velocity Cannon Hardpoint", "WallTower-HPVcannon", 225, obj)
  assault_cannon_hardpoint: (obj={}) ->
    @structure("Assault Cannon Hardpoint", "Wall-VulcanCan", 250, obj)
  heavy_cannon_hardpoint: (obj={}) ->
    @structure("Heavy Cannon Hardpoint", "WallTower04", 250, obj)
  twin_assault_gun_hardpoint: (obj={}) ->
    @structure("Twin Assault Gun Hardpoint", "WallTower-TwinAssaultGun", 250, obj)
  pulse_laser_hardpoint: (obj={}) ->
    @structure("Pulse Laser Hardpoint", "WallTower-PulseLas", 275, obj)
  tank_killer_hardpoint: (obj={}) ->
    @structure("Tank Killer Hardpoint", "WallTower-HvATrocket", 275, obj)
  emp_cannon_tower: (obj={}) ->
    @structure("EMP Cannon Tower", "WallTower-EMP", 350, obj)
  scourge_missile_hardpoint: (obj={}) ->
    @structure("Scourge Missile Hardpoint", "WallTower-Atmiss", 350, obj)
  rail_gun_hardpoint: (obj={}) ->
    @structure("Rail Gun Hardpoint", "WallTower-Rail2", 350, obj)
  gauss_cannon_hardpoint: (obj={}) ->
    @structure("Gauss Cannon Hardpoint", "WallTower-Rail3", 400, obj)
  nexus_link_tower: (obj={}) ->
    @structure("Nexus Link Tower", "Sys-SpyTower", 800, obj)

  # Bunkers
  flamer_bunker: (obj={}) ->
    @structure("Flamer Bunker", "PillBox5", 100, obj)
  machinegun_bunker: (obj={}) ->
    @structure("Machinegun Bunker", "PillBox1", 100, obj)
  plasmite_flamer_bunker: (obj={}) ->
    @structure("Plasmite Flamer Bunker", "Plasmite-flamer-bunker", 125, obj)
  inferno_bunker: (obj={}) ->
    @structure("Inferno Bunker", "Tower-Projector", 125, obj)
  light_cannon_bunker: (obj={}) ->
    @structure("Light Cannon Bunker", "PillBox4", 125, obj)
  rotary_mg_bunker: (obj={}) ->
    @structure("Rotary MG Bunker", "Pillbox-RotMG", 150, obj)
  twin_assault_cannon_bunker: (obj={}) ->
    @structure("Twin Assault Cannon Bunker", "PillBox-Cannon6", 225, obj)

  # Artillery
  mortar_pit: (obj={}) ->
    @structure("Mortar Pit", "Emplacement-MortarPit01", 125, obj)
  incendiary_mortar_pit: (obj={}) ->
    @structure("Incendiary Mortar Pit", "Emplacement-MortarPit-Incenediary", 135, obj)
  bombard_pit: (obj={}) ->
    @structure("Bombard Pit", "Emplacement-MortarPit02", 150, obj)
  pepperpot_pit: (obj={}) ->
    @structure("Pepperpot Pit", "Emplacement-RotMor", 325, obj)
  incendiary_howitzer_emplacement: (obj={}) ->
    @structure("Incendiary Howitzer Emplacement", "Emplacement-Howitzer-Incenediary", 325, obj)
  howitzer_emplacement: (obj={}) ->
    @structure("Howitzer Emplacement", "Emplacement-Howitzer105", 0, obj)
  ground_shaker_emplacement: (obj={}) ->
    @structure("Ground Shaker Emplacement", "Emplacement-Howitzer150", 425, obj)
  hellstorm_emplacement: (obj={}) ->
    @structure("Hellstorm Emplacement", "Emplacement-RotHow", 525, obj)
  emp_mortar_pit: (obj={}) ->
    @structure("EMP Mortar Pit", "Emplacement-MortarEMP", 150, obj)
  mini_roket_battery: (obj={}) ->
    @structure("Mini-Rocket Battery", "Emplacement-MRL-pit", 125, obj)
  ripple_rocket_battery: (obj={}) ->
    @structure("Ripple Rocket Battery", "Emplacement-Rocket06-IDF", 325, obj)
  seraph_missile_battery: (obj={}) ->
    @structure("Seraph Missile Battery", "Emplacement-MdART-pit", 450, obj)
  archangel_missile_emplacement: (obj={}) ->
    @structure("Archangel Missile Emplacement", "Emplacement-HvART-pit", 525, obj)

  # Anti-air structures
  sunburst_site: (obj={}) ->
    @structure("Sunburst AA Site", "P0-AASite-Sunburst", 250, obj)
  hurricane_site: (obj={}) ->
    @structure("Hurricane AA Site", "AASite-QuadMg1", 125, obj)
  whirlwind_site: (obj={}) ->
    @structure("Whirlwind AA Site", "AASite-QuadRotMg", 175, obj)
  avenger_site: (obj={}) ->
    @structure("Avenger AA Site", "P0-AASite-SAM1", 250, obj)
  stormbringer_site: (obj={}) ->
    @structure("Stormbringer AA Site", "P0-AASite-Laser", 350, obj)
  vindicator_site: (obj={}) ->
    @structure("Vindicator SAM Site", "P0-AASite-SAM2", 350, obj)
  flak_cannon_emplacement: (obj={}) ->
    @structure("AA Flak Cannon Emplacement", "AASite-QuadBof", 300, obj)
  vindicator_hardpoint: (obj={}) ->
    @structure("Vindicator Hardpoint", "WallTower-SamHvy", 400, obj)
  whirlwind_hardpoint: (obj={}) ->
    @structure("Whirlwind Hardpoint", "WallTower-QuadRotAAGun", 400, obj)
  avenger_hardpoint: (obj={}) ->
    @structure("Avenger Hardpoint", "WallTower-SamSite", 400, obj)
  flak_cannon_hardpoint: (obj={}) ->
    @structure("AA Flak Cannon Hardpoint", "WallTower-DoubleAAGun", 450, obj)

  # Weapons Structure-only // Superweapons
  laser_satellite: (obj={}) ->
    @turret("Laser Satellite Command Post", "A0LasSatCommand", 1000, DROID_WEAPON, obj)
  cannon_fortress: (obj={}) ->
    @turret("Cannon Fortress", "X-Super-Cannon", 1000, DROID_WEAPON, obj)
  heavy_rocket_bastion: (obj={}) ->
    @turret("Heavy Rocket Bastion", "X-Super-Rocket", 1250, DROID_WEAPON, obj)
  missile_fortress: (obj={}) ->
    @turret("Missile Fortress", "X-Super-Missile", 1600, DROID_WEAPON, obj)
  mass_driver: (obj={}) ->
    @turret("Mass Driver", "X-Super-MassDriver", 1800, DROID_WEAPON, obj)

  ###############
  ### Turrets ###
  ###############

  turret: (tname, turretid, tcost, dtype, obj={}) ->
    obj.tname = tname
    obj.turret = turretid
    obj.tcost = tcost
    obj.droid_type = dtype
    obj

  # Systems Truck
  truck: (obj={}) ->
    @turret("Truck", "Spade1Mk1", 17, DROID_CONSTRUCT, obj)

  # Systems Repair
  repair: (obj={}) ->
    @turret("Repair", "LightRepair1", 50, DROID_REPAIR, obj)
  heavy_repair: (obj={}) ->
    @turret("Heavy Repair", "HeavyRepair", 70, DROID_REPAIR, obj)

  # Systems Sensors
  wide_spectrum: (obj={}) ->
    @turret("Wide Spectrum", "Sensor-WideSpec", 5, DROID_SENSOR, obj)
  cb_radar: (obj={}) ->
    @turret("CB Radar", "Sys-CBTurret01", 20, DROID_SENSOR, obj)
  radar_detector: (obj={}) ->
    @turret("Radar Detector", "RadarDetector", 20, DROID_SENSOR, obj)
  sensor: (obj={}) ->
    @turret("Sensor", "SensorTurret1Mk1", 20, DROID_SENSOR, obj)
  vtol_cb_radar: (obj={}) ->
    @turret("VTOL CB Radar", "Sys-VTOLCBTurret01", 20, DROID_SENSOR, obj)
  vtol_strike: (obj={}) ->
    @turret("VTOL Strike", "Sys-VstrikeTurret01", 20, DROID_SENSOR, obj)

  # Systems Command
  command1: (obj={}) ->
    @turret("Command 1", "CommandTurret1", 250, DROID_COMMAND, obj)
  command2: (obj={}) ->
    @turret("Command 2", "CommandTurret2", 750, DROID_COMMAND, obj)
  command3: (obj={}) ->
    @turret("Command 3", "CommandTurret3", 1250, DROID_COMMAND, obj)
  command4: (obj={}) ->
    @turret("Command 4", "CommandTurret4", 1750, DROID_COMMAND, obj)

  # Weapons Machineguns
  machinegun: (obj={}) ->
    @turret("Machinegun", "MG1Mk1", 10, DROID_WEAPON, obj)
  twin_machinegun: (obj={}) ->
    @turret("Twin Machinegun", "MG2Mk1", 25, DROID_WEAPON, obj)
  heavy_machinegun: (obj={}) ->
    @turret("Heavy Machinegun", "MG3Mk1", 50, DROID_WEAPON, obj)
  assault_gun: (obj={}) ->
    @turret("Assault Gun", "MG4ROTARYMk1", 100, DROID_WEAPON, obj)
  twin_assault_gun: (obj={}) ->
    @turret("Twin Assault Gun", "MG5TWINROTARY", 100, DROID_WEAPON, obj)

  # Weapons Cannons
  light_cannon: (obj={}) ->
    @turret("Light Cannon", "Cannon1Mk1", 75, DROID_WEAPON, obj)
  medium_cannon: (obj={}) ->
    @turret("Medium Cannon", "Cannon2A-TMk1", 150, DROID_WEAPON, obj)
  assault_cannon: (obj={}) ->
    @turret("Assault Cannon", "Cannon5VulcanMk1", 150, DROID_WEAPON, obj)
  hpv: (obj={}) ->
    @turret("Hyper Velocity Cannon", "Cannon4AUTOMk1", 175, DROID_WEAPON, obj)
  heavy_cannon: (obj={}) ->
    @turret("Heavy Cannon", "Cannon375mmMk1", 250, DROID_WEAPON, obj)
  twin_assault_cannon: (obj={}) ->
    @turret("Twin Assault Cannon", "Cannon6TwinAslt", 250, DROID_WEAPON, obj)
  plasma_cannon: (obj={}) ->
    @turret("Plasma Cannon", "Laser4-PlasmaCannon", 750, DROID_WEAPON, obj)

  # Weapons Flamers
  flamer: (obj={}) ->
    @turret("Flamer", "Flame1Mk1", 40, DROID_WEAPON, obj)
  inferno: (obj={}) ->
    @turret("Inferno", "Flame2", 80, DROID_WEAPON, obj)
  plasmite_flamer: (obj={}) ->
    @turret("Plasmite Flamer", "PlasmiteFlamer", 80, DROID_WEAPON, obj)

  # Weapons Mortars and Howitzers
  mortart: (obj={}) ->
    @turret("Mortar", "Mortar1Mk1", 100, DROID_WEAPON, obj)
  incendiary_mortar: (obj={}) ->
    @turret("Incendiary Mortar", "Mortar-Incenediary", 150, DROID_WEAPON, obj)
  bombard: (obj={}) ->
    @turret("Bombard", "Mortar2Mk1", 200, DROID_WEAPON, obj)
  pepperpot: (obj={}) ->
    @turret("Pepperpot", "Mortar3ROTARYMk1", 300, DROID_WEAPON, obj)
  howitzer: (obj={}) ->
    @turret("Howitzer", "Howitzer105Mk1", 250, DROID_WEAPON, obj)
  incendiary_howitzer: (obj={}) ->
    @turret("Incendiary Howitzer", "Howitzer-Incenediary", 250, DROID_WEAPON, obj)
  ground_shaker: (obj={}) ->
    @turret("Ground Shaker", "Howitzer150Mk1", 350, DROID_WEAPON, obj)
  hellstorm: (obj={}) ->
    @turret("Hellstorm", "Howitzer03-Rot", 400, DROID_WEAPON, obj)

  # Weapons Rockets and Missiles
  mini_rocket_pod: (obj={}) ->
    @turret("Mini-Rocket Pod", "Rocket-Pod", 75, DROID_WEAPON, obj)
  mini_rocket_array: (obj={}) ->
    @turret("Mini-Rocket Array", "Rocket-MRL", 100, DROID_WEAPON, obj)
  bunker_buster: (obj={}) ->
    @turret("Bunker Buster", "Rocket-BB", 150, DROID_WEAPON, obj)
  lancer: (obj={}) ->
    @turret("Lancer", "Rocket-LtA-T", 150, DROID_WEAPON, obj)
  tank_killer: (obj={}) ->
    @turret("Tank Killer", "Rocket-HvyA-T", 200, DROID_WEAPON, obj)
  ripple_rockets: (obj={}) ->
    @turret("Ripple Rockets", "Rocket-IDF", 300, DROID_WEAPON, obj)
  scourge_missile: (obj={}) ->
    @turret("Scourge Missile", "Missile-A-T", 300, DROID_WEAPON, obj)
  seraph_missile_array: (obj={}) ->
    @turret("Seraph Missile Array", "Missile-MdArt", 400, DROID_WEAPON, obj)
  archangel_missile: (obj={}) ->
    @turret("Archangel Missile", "Missile-HvyArt", 500, DROID_WEAPON, obj)

  # Weapons Rail Guns
  needle_gun: (obj={}) ->
    @turret("Needle Gun", "RailGun1Mk1", 250, DROID_WEAPON, obj)
  rail_gun: (obj={}) ->
    @turret("Rail Gun", "RailGun2Mk1", 300, DROID_WEAPON, obj)
  gauss_cannon: (obj={}) ->
    @turret("Gauss Cannon", "RailGun3Mk1", 400, DROID_WEAPON, obj)

  # Weapons Lasers
  flashligh: (obj={}) ->
    @turret("Flashlight", "Laser3BEAMMk1", 150, DROID_WEAPON, obj)
  pulse_laser: (obj={}) ->
    @turret("Pulse Laser", "Laser2PULSEMk1", 200, DROID_WEAPON, obj)
  heavy_laser: (obj={}) ->
    @turret("Heavy Laser", "HeavyLaser", 400, DROID_WEAPON, obj)

  # Weapons Electronic
  emp_cannon: (obj={}) ->
    @turret("EMP Cannon", "EMP-Cannon", 200, DROID_WEAPON, obj)
  nexus_link: (obj={}) ->
    @turret("Nexus Link", "SpyTurret01", 400, DROID_WEAPON, obj)

  # Weapons Anti-air
  hurricane: (obj={}) ->
    @turret("Hurricane", "QuadMg1AAGun", 100, DROID_WEAPON, obj)
  whirlwind: (obj={}) ->
    @turret("Whirlwind", "QuadRotAAGun", 150, DROID_WEAPON, obj)
  sunburst: (obj={}) ->
    @turret("Sunburst", "Rocket-Sunburst", 200, DROID_WEAPON, obj)
  avenger: (obj={}) ->
    @turret("Avenger", "Missile-LtSAM", 200, DROID_WEAPON, obj)
  flak_cannon: (obj={}) ->
    @turret("Flak Cannon", "AAGun2Mk1", 250, DROID_WEAPON, obj)
  vindicator: (obj={}) ->
    @turret("Vindicator", "Missile-HvySAM", 300, DROID_WEAPON, obj)
  strormbringer: (obj={}) ->
    @turret("Stormbringer", "AAGunLaser", 500, DROID_WEAPON, obj)

 # VTOL Weapons
  vtol_machinegun: (obj={}) ->
    @turret("VTOL Machinegun", "MG1-VTOL", 10, DROID_WEAPON, obj)
  vtol_twin_machinegun: (obj={}) ->
    @turret("VTOL Twin Machinegun", "MG2-VTOL", 25, DROID_WEAPON, obj)
  vtol_heavy_machinegun: (obj={}) ->
    @turret("VTOL Heavy Machinegun", "MG3-VTOL", 50, DROID_WEAPON, obj)
  vtol_cannon: (obj={}) ->
    @turret("VTOL Cannon", "Cannon1-VTOL", 75, DROID_WEAPON, obj)
  vtol_mini_rocket: (obj={}) ->
    @turret("VTOL Mini-Rocket", "Rocket-VTOL-Pod", 75, DROID_WEAPON, obj)
  vtol_assault_gun: (obj={}) ->
    @turret("VTOL Assault Gun", "MG4ROTARY-VTOL", 100, DROID_WEAPON, obj)
  vtol_lancer: (obj={}) ->
    @turret("VTOL Lancer", "Rocket-VTOL-LtA-T", 100, DROID_WEAPON, obj)
  vtol_assault_cannon: (obj={}) ->
    @turret("VTOL Assault Cannon", "Cannon5Vulcan-VTOL", 150, DROID_WEAPON, obj)
  vtol_bunker_buster: (obj={}) ->
    @turret("VTOL Bunker Buster", "Rocket-VTOL-BB", 150, DROID_WEAPON, obj)
  vtol_flaslight: (obj={}) ->
    @turret("VTOL Flashlight", "Laser3BEAM-VTOL", 150, DROID_WEAPON, obj)
  vtol_hpv: (obj={}) ->
    @turret("VTOL Hyper Velocity Cannon", "Cannon4AUTO-VTOL", 175, DROID_WEAPON, obj)
  vtol_pulse_laser: (obj={}) ->
    @turret("VTOL Pulse Laser", "Laser2PULSE-VTOL", 200, DROID_WEAPON, obj)
  vtol_emp_missile_launcher: (obj={}) ->
    @turret("VTOL EMP Missile Launcher", "Bomb6-VTOL-EMP", 225, DROID_WEAPON, obj)
  vtol_tank_killer: (obj={}) ->
    @turret("VTOL Tank Killer", "Rocket-VTOL-HvyA-T", 250, DROID_WEAPON, obj)
  vtol_needle_gun: (obj={}) ->
    @turret("VTOL Needle Gun", "RailGun1-VTOL", 250, DROID_WEAPON, obj)
  vtol_rail_gun: (obj={}) ->
    @turret("VTOL Rail Gun", "RailGun2-VTOL", 300, DROID_WEAPON, obj)
  vtol_scourge_missile: (obj={}) ->
    @turret("VTOL Scourge Missile", "Missile-VTOL-AT", 300, DROID_WEAPON, obj)
  vtol_heavy_laser: (obj={}) ->
    @turret("VTOL Heavy Laser", "HeavyLaser-VTOL", 400, DROID_WEAPON, obj)

  # Weapons Bombs
  cluster_bomb: (obj={}) ->
    @turret("Cluster Bomb", "Bomb1-VTOL-LtHE", 150, DROID_WEAPON, obj)
  phosphor_bomb: (obj={}) ->
    @turret("Phospor Bomb", "Bomb3-VTOL-LtINC", 175, DROID_WEAPON, obj)
  heap_bomb: (obj={}) ->
    @turret("Heap Bomb", "Bomb2-VTOL-HvHE", 200, DROID_WEAPON, obj)
  plasmite_bomb: (obj={}) ->
    @turret("Plasmite Bomb", "Bomb5-VTOL-Plasmite", 225, DROID_WEAPON, obj)
  thermite_bomb: (obj={}) ->
    @turret("Thermite Bomb", "Bomb4-VTOL-HvyINC", 225, DROID_WEAPON, obj)

  # Weapons Air-to-air
  vtol_sunburst: (obj={}) ->
    @turret("VTOL Sunburst", "Rocket-VTOL-Sunburst", 150, DROID_WEAPON, obj)

  # TODO
  #gun: (obj={}) ->
  #  obj.name = "Gun"
  #  obj.turret = ["MG3Mk1", "MG2Mk1", "MG1Mk1"]
  #  obj.droid_type = DROID_WEAPON
  #  obj

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

  transport: (obj={}) -> @body("Transport", "TransporterBody", 325, obj)

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

  trucker: (obj={}) ->
    obj.like = /Truck$/
    obj

  scouter: (obj={}) ->
    obj.like = /^((Wheels)|(Hover))-((Viper)|(Bug))-.*Machinegun$/
    obj

  factory: (obj={}) ->
    obj.like = /^Factory$/
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
    name = "#{obj.pname}-#{obj.bname}-#{obj.tname}"
    name = "Truck" if name is "Wheels-Viper-Truck"
    obj.name = name
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

  # Example:
  # @pass @on_glut @none()
  pass: (obj={}) ->
    obj.cost = 0
    obj.order = CORDER_PASS
    # 1 just means success in this case. Normally,
    # it would be the number of units that succesfully executed the command.
    obj.execute = (group) ->
      if group.list.length >= obj.min
        if first = group.list.first()
          group.layoffs(first.command)
        return 1
      0
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
    obj.power = -100
    obj

  on_budget: (obj={}) ->
    obj.power = 0
    obj

  on_surplus: (obj={}) ->
    obj.power = 100
    obj

  on_plenty: (obj={}) ->
    obj.power = 400
    obj

  on_glut: (obj={}) ->
    obj.power = 1000
    obj

###############
### Aliases ###
###############
Command::maintains = Command::maintain
Command::manufactures = Command::manufacture
Command::scouts = Command::scout
