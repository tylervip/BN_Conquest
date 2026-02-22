/*
initPlayerLocal.sqf
*/
params ["_player", "_didJIP"];

["InitializePlayer", [player, true]] call BIS_fnc_dynamicGroups;

//disable AI radio chatter
enableSentences false;

//Map markers 
call map_fnc_player_markers_subsystem_init;

//onPlayerRespawn.sqf
player setUnitTrait ["Medic", true];
player setUnitTrait ["Engineer", true];
player setUnitTrait ["ExplosiveSpecialist", true];
player setUnitTrait ["UAVHacker", true];
player setUnitTrait ["CamouflageCoef", 0.5];      // Makes player 50% harder to spot
player setUnitTrait ["AudibleCoef", 0.5];         // Makes player 50% quieter
player setUnitTrait ["loadCoef", 0.5];            // Reduces effect of weight by 50%
player enableStamina false;
player enableFatigue false;

[] execVM "Killstreak\init_killstreak.sqf";

[] execVM "functions\earplugs.sqf";
[]execVM "functions\magRepack\init_magRepack.sqf";
[player] execVM "EventHandler\fn_registerEH.sqf";

// Initialize curator for player
[player] call BNC_fnc_curator_init;

// Remove player body on disconnect
addMissionEventHandler ["HandleDisconnect", {
    params ["_unit", "_id", "_uid", "_name"];
    deleteVehicle _unit;
    private _grp = group _unit;
    if (_grp != objNull) then {
        if (count (units _grp) == 0 && {count (units _grp select {isPlayer _x}) == 0}) then {
            deleteGroup _grp;
        };
    };
    false
}];