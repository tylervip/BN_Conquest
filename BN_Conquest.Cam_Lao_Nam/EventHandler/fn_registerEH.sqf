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
}];

// Clean up dead players
if (isPlayer _unit) then {
    _unit addEventHandler ["Respawn", {
        params ["_newUnit", "_oldUnit"];
        [_oldUnit] spawn {
            sleep 30;
            deleteVehicle _this;
        };
    }];
};
// Clean up dead AI
if (!isPlayer _unit) then {
    _unit addEventHandler ["Killed", {
        params ["_unit"];
        [_unit] spawn {
            sleep 30;
            deleteVehicle _this;
        };
    }];
};

