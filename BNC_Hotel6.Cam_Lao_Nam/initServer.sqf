// Register EHs for all existing units (AI + players)
{
    [_x] execVM "EventHandler\fn_registerEH.sqf";
} forEach allUnits;

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

[] execVM "functions\Vehicle_tank_SecterSpawn.sqf";
[] execVM "functions\Vehicle_Heil_SecterSpawn.sqf";