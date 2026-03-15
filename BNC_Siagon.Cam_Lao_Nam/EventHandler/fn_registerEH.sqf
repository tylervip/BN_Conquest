//fn_registerEH.sqf
params ["_unit"];

_unit setVariable ["underFire", false, true];
_unit addEventHandler ["Suppressed", {
    params ["_unit"];
    [_unit] execVM "EventHandler\fn_trackSuppression.sqf";
}];

_unit addEventHandler ["Killed", {
    params ["_unit", "_killer"];
    [_unit, _killer] execVM "EventHandler\fn_trackKills.sqf";
    // Clean up dead units after 30 seconds
    [_unit] spawn {
        private _grp = group (_this select 0);
        sleep 30;
        deleteVehicle (_this select 0);
        if (!isNull _grp && {count (units _grp) == 0} && {count (units _grp select {isPlayer _x}) == 0}) then {
            deleteGroup _grp;
        };
    };
}];

// Clean up dead players on respawn
if (isPlayer _unit) then {
    _unit addEventHandler ["Respawn", {
        params ["_newUnit", "_oldUnit"];
        [_oldUnit] spawn {
            sleep 30;
            deleteVehicle (_this select 0);
        };
    }];
};

