CyberBorg.prototype.base_orders=function(){
  return( [
  // Phase 1  Build up the initial base as fast a posible
  {min:3, max:3, structure:"A0LightFactory",     at:{x:9, y:234}},
  {min:3, max:3, structure:"A0ResearchFacility", at:{x:6, y:234}},
  {min:3, max:3, structure:"A0CommandCentre",    at:{x:6, y:237}},
  {min:3, max:3, structure:"A0PowerGenerator",   at:{x:3, y:234}},
  // Phase 2  Just have one truck max out the base with research and power
  {min:1, max:1, structure:"A0ResearchFacility", at:{x:3, y:237}},
  {min:1, max:1, structure:"A0PowerGenerator",   at:{x:3, y:240}},
  {min:1, max:1, structure:"A0ResearchFacility", at:{x:6, y:240}},
  {min:1, max:1, structure:"A0PowerGenerator",   at:{x:9, y:240}},
  {min:1, max:1, structure:"A0ResearchFacility", at:{x:12,y:240}},
  {min:1, max:1, structure:"A0PowerGenerator",   at:{x:12,y:243}},
  {min:1, max:1, structure:"A0ResearchFacility", at:{x:9, y:243}},
  {min:1, max:1, structure:"A0PowerGenerator",   at:{x:6, y:243}},
  ]);
}
CyberBorg.prototype.factory_orders=function(){
  return([
  {name:"Truck", body:"Body1REC", propulsion:"wheeled01", droid_type:DROID_CONSTRUCT, turret:"Spade1Mk1",},
  {name:"Truck", body:"Body1REC", propulsion:"wheeled01", droid_type:DROID_CONSTRUCT, turret:"Spade1Mk1",},
  {name:"MgWhB1", body:"Body1REC", propulsion:"wheeled01", droid_type:DROID_WEAPON, turret:"MG1Mk1",},
  {name:"MgWhB1", body:"Body1REC", propulsion:"wheeled01", droid_type:DROID_WEAPON, turret:"MG1Mk1",},
  {name:"MgWhB1", body:"Body1REC", propulsion:"wheeled01", droid_type:DROID_WEAPON, turret:"MG1Mk1",},
  {name:"MgWhB1", body:"Body1REC", propulsion:"wheeled01", droid_type:DROID_WEAPON, turret:"MG1Mk1",},
  {name:"MgWhB1", body:"Body1REC", propulsion:"wheeled01", droid_type:DROID_WEAPON, turret:"MG1Mk1",},
  {name:"MgWhB1", body:"Body1REC", propulsion:"wheeled01", droid_type:DROID_WEAPON, turret:"MG1Mk1",},
  {name:"MgWhB1", body:"Body1REC", propulsion:"wheeled01", droid_type:DROID_WEAPON, turret:"MG1Mk1",},
  {name:"MgWhB1", body:"Body1REC", propulsion:"wheeled01", droid_type:DROID_WEAPON, turret:"MG1Mk1",},
  {name:"MgWhB1", body:"Body1REC", propulsion:"wheeled01", droid_type:DROID_WEAPON, turret:"MG1Mk1",},
  {name:"MgWhB1", body:"Body1REC", propulsion:"wheeled01", droid_type:DROID_WEAPON, turret:"MG1Mk1",},
  {name:"MgWhB1", body:"Body1REC", propulsion:"wheeled01", droid_type:DROID_WEAPON, turret:"MG1Mk1",},
  {name:"MgWhB1", body:"Body1REC", propulsion:"wheeled01", droid_type:DROID_WEAPON, turret:"MG1Mk1",},
  ]);
}
