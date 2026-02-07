//onPlayerRespawn.sqf
player setUnitTrait ["Medic", true];
player setUnitTrait ["Engineer", true];
player setUnitTrait ["ExplosiveSpecialist", true];
player setUnitTrait ["UAVHacker", true];
player setUnitTrait ["CamouflageCoef", 0.5];// Makes player 50% harder to spot
player setUnitTrait ["AudibleCoef", 0.5];// Makes player 50% quieter
player setUnitTrait ["loadCoef", 0.5];// Reduces effect of weight by 50%
player enableStamina false;
player enableFatigue false;
//player setVariable ["killCount", 0];//killCount reset

//loads last savedLoadout
player setUnitLoadout(player getVariable["SavedLoadout", []]);

player setVariable ["inDebugRespawn", true, true];
[] execVM "functions\magRepack\init_magRepack.sqf";

execVM "custom_respawn\init_respawn.sqf";
