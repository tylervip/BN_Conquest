//init.sqf
waitUntil {time > 1};
["Initialize", [true]] call BIS_fnc_dynamicGroups;
//missionNamespace setVariable ["stringKF", "   "];

// Initialize RNG AI settings
execVM "functions\RNGAI\RNG_init.sqf";

execVM "functions\spawnAI_east.sqf";
execVM "functions\spawnAI_west.sqf";
execVM "functions\delete_Group.sqf";
execVM "functions\save_loadout_box.sqf";

// Mobile Respawn System
call MRS_fnc_init;

execVM "Killstreak\availableKillstreaks.sqf";	//care_package

