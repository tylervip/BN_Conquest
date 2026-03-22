// Register EHs for all existing units (AI + players)
{
    [_x] execVM "EventHandler\fn_registerEH.sqf";
} forEach allUnits;

// Remove player body on disconnect
if (isServer) then {
    addMissionEventHandler ["HandleDisconnect", {
        params ["_unit", "_id", "_uid", "_name"];
        if (!isNull _unit) then {
            deleteVehicle _unit;
            private _grp = group _unit;
            if (!isNull _grp) then {
                if (count (units _grp) == 0 && {count (units _grp select {isPlayer _x}) == 0}) then {
                    deleteGroup _grp;
                };
            };
        };
        false
    }];
};

[] execVM "functions\Vehicle_tank_SecterSpawn.sqf";
[] execVM "functions\Vehicle_Heil_SecterSpawn.sqf";