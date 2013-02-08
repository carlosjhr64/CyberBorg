class Command
  @to_at = (o) -> {x: o.x.to_i(), y: o.y.to_i()}

  # See *script*'s Command::base_commands for an explanation of @savings.
  constructor: (@limit=0, @savings=0) ->
    # Presumably, the initial amount of power at game start.
    @power = CyberBorg.get_power()

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

  structure: (name, structureid, obj={}) ->
    obj.name = name
    obj.structure = structureid
    obj.cost = Ini.strid(structureid).buildpower
    obj

  command_center: (obj={}) -> @structure(
    "Command Center", "A0CommandCentre", obj)
  power_generator: (obj={}) -> @structure(
    "Power Generator", "A0PowerGenerator", obj)
  power_module: (obj={}) -> @structure(
    "Power Module", "A0PowMod1", obj)
  research_facility: (obj={}) -> @structure(
    "Research Facility", "A0ResearchFacility", obj)
  research_module: (obj={}) -> @structure(
    "Research Module", "A0ResearchModule1", obj)
  light_factory: (obj={}) -> @structure(
    "Factory", "A0LightFactory", obj)
  factory_module: (obj={}) -> @structure(
    "Factory Module", "A0FacMod1", obj)
  cyborg_factory: (obj={}) -> @structure(
    "Cyborg Factory", "A0CyborgFactory", obj)
  vtol_factory: (obj={}) -> @structure(
    "VTOL Factory", "A0VTolFactory1", obj)
  command_relay_center: (obj={}) -> @structure(
    "Command Relay Center", "A0ComDroidControl", obj)
  vtol_rearming_pad: (obj={}) -> @structure(
    "VTOL Rearming Pad", "A0VtolPad", obj)
  repair_facility: (obj={}) -> @structure(
    "Repair Facility", "A0RepairCentre3", obj)
  oil_derrick: (obj={}) -> @structure(
    "Oil Derrick", "A0ResourceExtractor", obj)

  ################
  ### Defenses ###
  ################

  # Walls
  tank_traps: (obj={}) -> @structure(
    "Tank Traps", "A0TankTrap", obj)
  hardcrete: (obj={}) -> @structure(
    "Hardcrete Wall", "A0HardcreteMk1Wall", obj)

  # Sensor structures
  sensor_tower: (obj={}) -> @structure(
    "Sensor Tower", "Sys-SensoTower01", obj)
  radar_detector_tower: (obj={}) -> @structure(
    "Radar Detector Tower", "Sys-RadarDetector01", obj)
  cb_tower: (obj={}) -> @structure(
    "CB Tower", "Sys-CB-Tower01", obj)
  hardened_sensor: (obj={}) -> @structure(
    "Hardened Sensor Tower", "Sys-SensoTower02", obj)
  vtol_cb_tower: (obj={}) -> @structure(
    "VTOL CB Tower", "Sys-VTOL-CB-Tower01", obj)
  vtol_strike_tower: (obj={}) -> @structure(
    "VTOL Strike Tower", "Sys-VTOL-RadarTower01", obj)
  wide_spectrum_sensor_tower: (obj={}) -> @structure(
    "Wide Spectrum Sensor Tower", "Sys-SensoTowerWS", obj)
  satellite_uplink_center: (obj={}) -> @structure(
    "Satellite Uplink Center", "A0Sat-linkCentre", obj)

  # Weapons structures

  # Towers, emplacements, and Hardpoints.
  machinegun_guard_tower: (obj={}) -> @structure(
    "Machinegun Guard Tower", "GuardTower1", obj)
  pulse_laser_tower: (obj={}) -> @structure(
    "Pulse Laser Tower", "GuardTower-BeamLas", obj)
  needle_gun_tower: (obj={}) -> @structure(
    "Needle Gun Tower", "GuardTower-Rail1", obj)
  scourge_missile_tower: (obj={}) -> @structure(
    "Scourge Missile Tower", "GuardTower-ATMiss", obj)
  mini_rocket_tower: (obj={}) -> @structure(
    "Mini-Rocket Tower", "GuardTower6", obj)
  lancer_tower: (obj={}) -> @structure(
    "Lancer Tower", "GuardTower5", obj)
  hpv_emplacement: (obj={}) -> @structure(
    "Hyper Velocity Cannon Emplacement", "Emplacement-HPVcannon", obj)
  flashlight_emplacement: (obj={}) -> @structure(
    "Flashlight Emplacement", "Emplacement-PrisLas", obj)
  tank_killer_emplacement: (obj={}) -> @structure(
    "Tank Killer Emplacement", "Emplacement-HvyATrocket", obj)
  plasma_cannon_emplacement: (obj={}) -> @structure(
    "Plasma Cannon Emplacement", "Emplacement-PlasmaCannon", obj)
  railgun_emplacement: (obj={}) -> @structure(
    "Railgun Emplacement", "Emplacement-Rail2", obj)
  gauss_cannon_emplacement: (obj={}) -> @structure(
    "Gauss Cannon Emplacement", "Emplacement-Rail3", obj)
  heavy_laser_emplacement: (obj={}) -> @structure(
    "Heavy Laser Emplacement", "Emplacement-HeavyLaser", obj)
  heavy_machinegun_hardpoint: (obj={}) -> @structure(
    "Heavy Machinegun Hardpoint", "WallTower01", obj)
  light_cannon_hardpoint: (obj={}) -> @structure(
    "Light Cannon Hardpoint", "WallTower02", obj)
  assault_gun_hardpoint: (obj={}) -> @structure(
    "Assault Gun Hardpoint", "Wall-RotMg", obj)
  lancer_hardpoint: (obj={}) -> @structure(
    "Lancer Hardpoint", "WallTower06", obj)
  medium_cannon_hardpoint: (obj={}) -> @structure(
    "Medium Cannon Hardpoint", "WallTower03", obj)
  hpv_hardpoint: (obj={}) -> @structure(
    "Hyper Velocity Cannon Hardpoint", "WallTower-HPVcannon", obj)
  assault_cannon_hardpoint: (obj={}) -> @structure(
    "Assault Cannon Hardpoint", "Wall-VulcanCan", obj)
  heavy_cannon_hardpoint: (obj={}) -> @structure(
    "Heavy Cannon Hardpoint", "WallTower04", obj)
  twin_assault_gun_hardpoint: (obj={}) -> @structure(
    "Twin Assault Gun Hardpoint", "WallTower-TwinAssaultGun", obj)
  pulse_laser_hardpoint: (obj={}) -> @structure(
    "Pulse Laser Hardpoint", "WallTower-PulseLas", obj)
  tank_killer_hardpoint: (obj={}) -> @structure(
    "Tank Killer Hardpoint", "WallTower-HvATrocket", obj)
  emp_cannon_tower: (obj={}) -> @structure(
    "EMP Cannon Tower", "WallTower-EMP", obj)
  scourge_missile_hardpoint: (obj={}) -> @structure(
    "Scourge Missile Hardpoint", "WallTower-Atmiss", obj)
  rail_gun_hardpoint: (obj={}) -> @structure(
    "Rail Gun Hardpoint", "WallTower-Rail2", obj)
  gauss_cannon_hardpoint: (obj={}) -> @structure(
    "Gauss Cannon Hardpoint", "WallTower-Rail3", obj)
  nexus_link_tower: (obj={}) -> @structure(
    "Nexus Link Tower", "Sys-SpyTower", obj)

  # Bunkers
  flamer_bunker: (obj={}) -> @structure(
    "Flamer Bunker", "PillBox5", obj)
  machinegun_bunker: (obj={}) -> @structure(
    "Machinegun Bunker", "PillBox1", obj)
  plasmite_flamer_bunker: (obj={}) -> @structure(
    "Plasmite Flamer Bunker", "Plasmite-flamer-bunker", obj)
  inferno_bunker: (obj={}) -> @structure(
    "Inferno Bunker", "Tower-Projector", obj)
  light_cannon_bunker: (obj={}) -> @structure(
    "Light Cannon Bunker", "PillBox4", obj)
  rotary_mg_bunker: (obj={}) -> @structure(
    "Rotary MG Bunker", "Pillbox-RotMG", obj)
  twin_assault_cannon_bunker: (obj={}) -> @structure(
    "Twin Assault Cannon Bunker", "PillBox-Cannon6", obj)

  # Artillery
  mortar_pit: (obj={}) -> @structure(
    "Mortar Pit", "Emplacement-MortarPit01", obj)
  incendiary_mortar_pit: (obj={}) -> @structure(
    "Incendiary Mortar Pit", "Emplacement-MortarPit-Incenediary", obj)
  bombard_pit: (obj={}) -> @structure(
    "Bombard Pit", "Emplacement-MortarPit02", obj)
  pepperpot_pit: (obj={}) -> @structure(
    "Pepperpot Pit", "Emplacement-RotMor", obj)
  incendiary_howitzer_emplacement: (obj={}) -> @structure(
    "Incendiary Howitzer Emplacement",
    "Emplacement-Howitzer-Incenediary", obj)
  howitzer_emplacement: (obj={}) -> @structure(
    "Howitzer Emplacement", "Emplacement-Howitzer105", obj)
  ground_shaker_emplacement: (obj={}) -> @structure(
    "Ground Shaker Emplacement", "Emplacement-Howitzer150", obj)
  hellstorm_emplacement: (obj={}) -> @structure(
    "Hellstorm Emplacement", "Emplacement-RotHow", obj)
  emp_mortar_pit: (obj={}) -> @structure(
    "EMP Mortar Pit", "Emplacement-MortarEMP", obj)
  mini_roket_battery: (obj={}) -> @structure(
    "Mini-Rocket Battery", "Emplacement-MRL-pit", obj)
  ripple_rocket_battery: (obj={}) -> @structure(
    "Ripple Rocket Battery", "Emplacement-Rocket06-IDF", obj)
  seraph_missile_battery: (obj={}) -> @structure(
    "Seraph Missile Battery", "Emplacement-MdART-pit", obj)
  archangel_missile_emplacement: (obj={}) -> @structure(
    "Archangel Missile Emplacement", "Emplacement-HvART-pit", obj)

  # Anti-air structures
  sunburst_site: (obj={}) -> @structure(
    "Sunburst AA Site", "P0-AASite-Sunburst", obj)
  hurricane_site: (obj={}) -> @structure(
    "Hurricane AA Site", "AASite-QuadMg1", obj)
  whirlwind_site: (obj={}) -> @structure(
    "Whirlwind AA Site", "AASite-QuadRotMg", obj)
  avenger_site: (obj={}) -> @structure(
    "Avenger AA Site", "P0-AASite-SAM1", obj)
  stormbringer_site: (obj={}) -> @structure(
    "Stormbringer AA Site", "P0-AASite-Laser", obj)
  vindicator_site: (obj={}) -> @structure(
    "Vindicator SAM Site", "P0-AASite-SAM2", obj)
  flak_cannon_emplacement: (obj={}) -> @structure(
    "AA Flak Cannon Emplacement", "AASite-QuadBof", obj)
  vindicator_hardpoint: (obj={}) -> @structure(
    "Vindicator Hardpoint", "WallTower-SamHvy", obj)
  whirlwind_hardpoint: (obj={}) -> @structure(
    "Whirlwind Hardpoint", "WallTower-QuadRotAAGun", obj)
  avenger_hardpoint: (obj={}) -> @structure(
    "Avenger Hardpoint", "WallTower-SamSite", obj)
  flak_cannon_hardpoint: (obj={}) -> @structure(
    "AA Flak Cannon Hardpoint", "WallTower-DoubleAAGun", obj)

  # Weapons Structure-only // Superweapons
  laser_satellite: (obj={}) -> @structure(
    "Laser Satellite Command Post", "A0LasSatCommand", obj)
  cannon_fortress: (obj={}) -> @structure(
    "Cannon Fortress", "X-Super-Cannon", obj)
  heavy_rocket_bastion: (obj={}) -> @structure(
    "Heavy Rocket Bastion", "X-Super-Rocket", obj)
  missile_fortress: (obj={}) -> @structure(
    "Missile Fortress", "X-Super-Missile", obj)
  mass_driver: (obj={}) -> @structure(
    "Mass Driver", "X-Super-MassDriver", obj)

  ###############
  ### Turrets ###
  ###############

  turret: (turretid, dtype, obj={}) ->
    obj.turret = turretid
    # The rest we can get from Ini.
    data = Ini.strid(turretid)
    obj.tname = data.name
    obj.tcost = data.buildpower
    if data.weaponclass?
      if data.weaponsubclass is "COMMAND"
        obj.droid_type = DROID_COMMAND
      else
        obj.droid_type = DROID_WEAPON
    else if data.constructpoints?
      obj.droid_type = DROID_CONSTRUCT
    else if data.repairpoints?
      obj.droid_type = DROID_REPAIR
    else if data.sensorkey?
      obj.droid_type = DROID_SENSOR
    else
      Trace.red "Warning: Could not determine droid_type"
      obj.droid_type = DROID_ANY
    obj

  # Systems Truck
  truck: (obj={}) -> @turret("Spade1Mk1", obj)

  # Systems Repair
  repair: (obj={}) -> @turret("LightRepair1", obj)
  heavy_repair: (obj={}) -> @turret("HeavyRepair", obj)

  # Systems Sensors
  wide_spectrum: (obj={}) -> @turret("Sensor-WideSpec", obj)
  cb_radar: (obj={}) -> @turret("Sys-CBTurret01", obj)
  radar_detector: (obj={}) -> @turret("RadarDetector", obj)
  sensor: (obj={}) -> @turret("SensorTurret1Mk1", obj)
  vtol_cb_radar: (obj={}) -> @turret("Sys-VTOLCBTurret01", obj)
  vtol_strike: (obj={}) -> @turret("Sys-VstrikeTurret01", obj)

  # Systems Command
  command1: (obj={}) -> @turret("CommandTurret1", obj)
  command2: (obj={}) -> @turret("CommandTurret2", obj)
  command3: (obj={}) -> @turret("CommandTurret3", obj)
  command4: (obj={}) -> @turret("CommandTurret4", obj)

  # Weapons Machineguns
  machinegun: (obj={}) -> @turret("MG1Mk1", obj)
  twin_machinegun: (obj={}) -> @turret("MG2Mk1", obj)
  heavy_machinegun: (obj={}) -> @turret("MG3Mk1", obj)
  assault_gun: (obj={}) -> @turret("MG4ROTARYMk1", obj)
  twin_assault_gun: (obj={}) -> @turret("MG5TWINROTARY", obj)

  # Weapons Cannons
  light_cannon: (obj={}) -> @turret("Cannon1Mk1", obj)
  medium_cannon: (obj={}) -> @turret("Cannon2A-TMk1", obj)
  assault_cannon: (obj={}) -> @turret("Cannon5VulcanMk1", obj)
  hpv: (obj={}) -> @turret("Cannon4AUTOMk1", obj)
  heavy_cannon: (obj={}) -> @turret("Cannon375mmMk1", obj)
  twin_assault_cannon: (obj={}) -> @turret("Cannon6TwinAslt", obj)
  plasma_cannon: (obj={}) -> @turret("Laser4-PlasmaCannon", obj)

  # Weapons Flamers
  flamer: (obj={}) -> @turret("Flame1Mk1", obj)
  inferno: (obj={}) -> @turret("Flame2", obj)
  plasmite_flamer: (obj={}) -> @turret("PlasmiteFlamer", obj)

  # Weapons Mortars and Howitzers
  mortart: (obj={}) -> @turret("Mortar1Mk1", obj)
  incendiary_mortar: (obj={}) -> @turret("Mortar-Incenediary", obj)
  bombard: (obj={}) -> @turret("Mortar2Mk1", obj)
  pepperpot: (obj={}) -> @turret("Mortar3ROTARYMk1", obj)
  howitzer: (obj={}) -> @turret("Howitzer105Mk1", obj)
  incendiary_howitzer: (obj={}) -> @turret("Howitzer-Incenediary", obj)
  ground_shaker: (obj={}) -> @turret("Howitzer150Mk1", obj)
  hellstorm: (obj={}) -> @turret("Howitzer03-Rot", obj)

  # Weapons Rockets and Missiles
  mini_rocket_pod: (obj={}) -> @turret("Rocket-Pod", obj)
  mini_rocket_array: (obj={}) -> @turret("Rocket-MRL", obj)
  bunker_buster: (obj={}) -> @turret("Rocket-BB", obj)
  lancer: (obj={}) -> @turret("Rocket-LtA-T", obj)
  tank_killer: (obj={}) -> @turret("Rocket-HvyA-T", obj)
  ripple_rockets: (obj={}) -> @turret("Rocket-IDF", obj)
  scourge_missile: (obj={}) -> @turret("Missile-A-T", obj)
  seraph_missile_array: (obj={}) -> @turret("Missile-MdArt", obj)
  archangel_missile: (obj={}) -> @turret("Missile-HvyArt", obj)

  # Weapons Rail Guns
  needle_gun: (obj={}) -> @turret("RailGun1Mk1", obj)
  rail_gun: (obj={}) -> @turret("RailGun2Mk1", obj)
  gauss_cannon: (obj={}) -> @turret("RailGun3Mk1", obj)

  # Weapons Lasers
  flashligh: (obj={}) -> @turret("Laser3BEAMMk1", obj)
  pulse_laser: (obj={}) -> @turret("Laser2PULSEMk1", obj)
  heavy_laser: (obj={}) -> @turret("HeavyLaser", obj)

  # Weapons Electronic
  emp_cannon: (obj={}) -> @turret("EMP-Cannon", obj)
  nexus_link: (obj={}) -> @turret("SpyTurret01", obj)

  # Weapons Anti-air
  hurricane: (obj={}) -> @turret("QuadMg1AAGun", obj)
  whirlwind: (obj={}) -> @turret("QuadRotAAGun", obj)
  sunburst: (obj={}) -> @turret("Rocket-Sunburst", obj)
  avenger: (obj={}) -> @turret("Missile-LtSAM", obj)
  flak_cannon: (obj={}) -> @turret("AAGun2Mk1", obj)
  vindicator: (obj={}) -> @turret("Missile-HvySAM", obj)
  strormbringer: (obj={}) -> @turret("AAGunLaser", obj)

 # VTOL Weapons
  vtol_machinegun: (obj={}) -> @turret("MG1-VTOL", obj)
  vtol_twin_machinegun: (obj={}) -> @turret("MG2-VTOL", obj)
  vtol_heavy_machinegun: (obj={}) -> @turret("MG3-VTOL", obj)
  vtol_cannon: (obj={}) -> @turret("Cannon1-VTOL", obj)
  vtol_mini_rocket: (obj={}) -> @turret("Rocket-VTOL-Pod", obj)
  vtol_assault_gun: (obj={}) -> @turret("MG4ROTARY-VTOL", obj)
  vtol_lancer: (obj={}) -> @turret("Rocket-VTOL-LtA-T", obj)
  vtol_assault_cannon: (obj={}) -> @turret("Cannon5Vulcan-VTOL", obj)
  vtol_bunker_buster: (obj={}) -> @turret("Rocket-VTOL-BB", obj)
  vtol_flaslight: (obj={}) -> @turret("Laser3BEAM-VTOL", obj)
  vtol_hpv: (obj={}) -> @turret("Cannon4AUTO-VTOL", obj)
  vtol_pulse_laser: (obj={}) -> @turret("Laser2PULSE-VTOL", obj)
  vtol_emp_missile_launcher: (obj={}) -> @turret("Bomb6-VTOL-EMP", obj)
  vtol_tank_killer: (obj={}) -> @turret("Rocket-VTOL-HvyA-T", obj)
  vtol_needle_gun: (obj={}) -> @turret("RailGun1-VTOL", obj)
  vtol_rail_gun: (obj={}) -> @turret("RailGun2-VTOL", obj)
  vtol_scourge_missile: (obj={}) -> @turret("Missile-VTOL-AT", obj)
  vtol_heavy_laser: (obj={}) -> @turret("HeavyLaser-VTOL", obj)

  # Weapons Bombs
  cluster_bomb: (obj={}) -> @turret("Bomb1-VTOL-LtHE", obj)
  phosphor_bomb: (obj={}) -> @turret("Bomb3-VTOL-LtINC", obj)
  heap_bomb: (obj={}) -> @turret("Bomb2-VTOL-HvHE", obj)
  plasmite_bomb: (obj={}) -> @turret("Bomb5-VTOL-Plasmite", obj)
  thermite_bomb: (obj={}) -> @turret("Bomb4-VTOL-HvyINC", obj)

  # Weapons Air-to-air
  vtol_sunburst: (obj={}) -> @turret("Rocket-VTOL-Sunburst", obj)

  ###############
  ### Cyborgs ###
  ###############

  # TODO cyborgid are not uptodate?
  cyborg: (name, cyborgid, cost, obj={}) ->
    obj.name = name
    obj.cyborgid = cyborgid
    obj.cost = cost
    obj

  # Systems cyborgs
  combat_engineer: (obj={}) -> @cyborg(
    "Combat Engineer", "Cyb-ComEng", 10, obj)
  cyborg_mechanic: (obj={}) -> @cyborg(
    "Cyborg Mechanic", "Cyb-Mechanic", 35, obj)

  # Weapons cyborgs
  machinegunner: (obj={}) -> @cyborg(
    "Machinegunner", "Cyb-Chain-GROUND", 40, obj)
  cyborg_flamer: (obj={}) -> @cyborg(
    "Cyborg Flamer", "Cyb-Flamer-GROUND", 50, obj)
  heavy_gunner: (obj={}) -> @cyborg(
    "Heavy Gunner", "Cyb-Cannon-GROUND", 60, obj)
  grenadier: (obj={}) -> @cyborg(
    "Granadier", "Cyb-Gren", 80, obj)
  thermite_flamer: (obj={}) -> @cyborg(
    "Thermite Flamer", "Cyb-Thermite", 80, obj)
  assault_gunner: (obj={}) -> @cyborg(
    "Assault Gunner", "Cyb-RotMG-GROUND", 90, obj)
  flashlight_gunner: (obj={}) -> @cyborg(
    "Flashlight Gunner", "Cyb-Laser1-GROUND", 100, obj)
  lancer: (obj={}) -> @cyborg(
    "Lancer", "Cyb-Rocket-GROUND", 125, obj)
  needle_gunner: (obj={}) -> @cyborg(
    "Needle Gunner", "Cyb-Rail1-GROUND", 160, obj)
  scourge: (obj={}) -> @cyborg(
    "Scourge", "Cyb-Atmiss-GROUND", 250, obj)
  # Weapons super cyborgs
  super_heavy_gunner: (obj={}) -> @cyborg(
    "Super Heavy-Gunner", "Cyb-Hvy-Mcannon", 75, obj)
  super_auto_cannon: (obj={}) -> @cyborg(
    "Super Auto-Cannon Cyborg", "Cyb-Hvy-Acannon", 125, obj)
  super_hpv: (obj={}) -> @cyborg(
    "Super HPV Cyborg", "Cyb-Hvy-HPV", 150, obj)
  super_pulse_laser: (obj={}) -> @cyborg(
    "Super Pulse Laser Cyborg", "Cyb-Hvy-PulseLsr", 150, obj)
  super_scourge: (obj={}) -> @cyborg(
    "Super Scourge Cyborg", "Cyb-Hvy-A-T", 235, obj)
  super_rail_gunner: (obj={}) -> @cyborg(
    "Super Rail-Gunner", "Cyb-Hvy-RailGunner", 240, obj)
  super_tank_killer: (obj={}) -> @cyborg(
    "Super Tank-Killer Cyborg", "Cyb-Hvy-TK", 250, obj)

  ##################
  ### Transports ###
  ##################

  # Transport
  cyborg_transport: (obj={}) -> @cyborg(
    "Cyborg Transport", "Transporter", 50, obj)

  ##############
  ### Bodies ###
  ##############

  body: (bodyid, obj={}) ->
    obj.body = bodyid
    data = Ini.strid(bodyid)
    obj.bname = data.name
    obj.bcost = data.buildpower
    obj

  viper: (obj={}) -> @body("Body1REC", obj)
  cobra: (obj={}) -> @body("Body5REC", obj)
  python: (obj={}) -> @body("Body11ABT", obj)

  bug: (obj={}) -> @body("Body4ABT", obj)
  scorpion: (obj={}) -> @body("Body8MBT", obj)
  mantis: (obj={}) -> @body("Body12SUP", obj)

  leopard: (obj={}) -> @body("Body2SUP", obj)
  panther: (obj={}) -> @body("Body6SUPP", obj)
  tiger: (obj={}) -> @body("Body9REC", obj)

  retaliation: (obj={}) -> @body("Body3MBT", obj)
  retribution: (obj={}) -> @body("Body7ABT", obj)
  vengeance: (obj={}) -> @body("Body10MBT", obj)

  wyvern: (obj={}) -> @body("Body13SUP", obj)
  dragon: (obj={}) -> @body("Body14SUP", obj)

  transport: (obj={}) -> @body("TransporterBody", obj)

  ##################
  ### Propulsion ###
  ##################

  propulsion: (propulsionid, obj={}) ->
    obj.propulsion = propulsionid
    data = Ini.strid(propulsionid)
    obj.pname = data.name
    obj.pcost = data.buildpower
    obj

  wheels: (obj={}) -> @propulsion("wheeled01", obj)
  half_tracks: (obj={}) -> @propulsion("HalfTrack", obj)
  hover: (obj={}) -> @propulsion("hover01", obj)
  tracks: (obj={}) -> @propulsion("tracked", obj)
  vtol: (obj={}) -> @propulsion("V-Tol", obj)

  ################
  ### Research ###
  ################

  ################
  ### Designs ####
  ################

  # TODO
  #gun: (obj={}) ->
  #  obj.name = "Gun"
  #  obj.turret = ["MG3Mk1", "MG2Mk1", "MG1Mk1"]
  #  obj.droid_type = DROID_WEAPON
  #  obj


  ############
  ### Who? ###
  ############

  like: (input, obj={}) ->
    if name = input.name
      obj.like = new RegExp(name)
      return obj
    if name = input.pname
      obj.like = new RegExp("^#{name}")
      return obj
    if name = input.bname
      obj.like = new RegExp("^#{name}")
      return obj
    if name = input.tname
      obj.like = new RegExp("^#{name}")
      return obj
    null

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

  ##############
  ### Where? ###
  ##############

  at: (x, y, obj={}) ->
    obj.at = {x:x, y:y}
    obj

  ##############
  ### Orders ###
  ##############

  @rms_cost_of = (research)->
    cost = 100 # default
    data = Ini.strid(research)
    if cost = data?.researchpower
      if requiredresearch = data.requiredresearch
        if typeof(requiredresearch) is "string"
          requiredresearch = [requiredresearch]
        rms = cost*cost
        count = 1
        for strid in requiredresearch
          if cost = Ini.strid(strid)?.researchpower
            rms += cost*cost
            count += 1
          else
            Trace.red "Warning: could not get data on #{strid}"
        cost = Math.sqrt(rms/count).to_i()
    else
      Trace.red "Warning: Could not get data on #{research}"
    cost

  pursue: (research, obj={}) ->
    obj.research = research
    cost = Command.rms_cost_of(research)
    obj.cost = cost
    obj.order = LORDER_RESEARCH
    obj.like = /Research Facility/
    obj.power = 0 # This just means we've not gone negative.
    obj.limit = @limit
    obj.min = 1
    obj.max = 1
    obj.help = 1
    obj

  manufacture: (obj={}) ->
    obj.order = FORDER_MANUFACTURE
    obj.like = /Factory/
    name = "#{obj.pname}-#{obj.bname}-#{obj.tname}"
    name = "Truck" if name is "Wheels-Viper-Truck"
    obj.name = name
    obj.cost = ((1.0 + obj.pcost/100.0) * obj.bcost) + obj.tcost
    obj

  maintain: (obj={}) ->
    if @savings > 0
      @savings -= obj.cost
      @savings = 0 if @savings < 0
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
    obj.execute = (executers, group) ->
      if executers.length >= obj.min
        if first = executers.first()
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
