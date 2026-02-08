// Register EHs for all existing units (AI + players)
{
    [_x] execVM "EventHandler\fn_registerEH.sqf";
} forEach allUnits;

// Remove player body on disconnect
addMissionEventHandler ["HandleDisconnect", {
    params ["_unit", "_id", "_uid", "_name"];
    deleteVehicle _unit;
    false
}];

[] execVM "functions\Vehicle_tank_SecterSpawn.sqf";
[] execVM "functions\Vehicle_Heil_SecterSpawn.sqf";