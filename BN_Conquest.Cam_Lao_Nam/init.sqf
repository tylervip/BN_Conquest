//init.sqf
waitUntil {time > 1};
["Initialize", [true]] call BIS_fnc_dynamicGroups;
//missionNamespace setVariable ["stringKF", "   "];
execVM "functions\spawnAI_east.sqf";
execVM "functions\spawnAI_west.sqf";
execVM "functions\delete_Group.sqf";
execVM "functions\save_loadout_box.sqf";

//execVM "functions\mobile_respawn_marker.sqf";
execVM "functions\mobile_respawn_teleport.sqf";

execVM "Killstreak\availableKillstreaks.sqf";	//care_package
//[] execVM "functions\grenade\fn_grenadeThrowback.sqf";

