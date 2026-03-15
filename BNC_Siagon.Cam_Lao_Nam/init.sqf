//init.sqf
waitUntil {time > 1};
["Initialize", [true]] call BIS_fnc_dynamicGroups;
//missionNamespace setVariable ["stringKF", "   "];

// Initialize RNG AI settings
execVM "functions\RNGAI\RNG_init.sqf";

// Initialize VCOM AI (strategic long-range AI behavior)
// VCOM handles: flanking, formations, artillery, garrisoning, calling backup
// RNG handles: close-range tactical combat within RNG_range
execVM "functions\vcomai\Vcom\Functions\VCM_Functions\fn_VcomInit.sqf";

// Start the VCOM/RNG coordinator - manages handoff between the two systems
[] spawn RNG_fnc_aiCoordinator;

execVM "functions\spawnAI_east.sqf";
execVM "functions\spawnAI_west.sqf";
execVM "functions\save_loadout_box.sqf";

// Mobile Respawn System
call MRS_fnc_init;

execVM "Killstreak\availableKillstreaks.sqf";	//care_package

