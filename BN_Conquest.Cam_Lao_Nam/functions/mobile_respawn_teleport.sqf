// mobile_respawn_teleport.sqf

if (hasInterface) then {
    private _pairs = [];

    if (!isNil "mobile_respawn_teleport" && {!isNull mobile_respawn_teleport} &&
        !isNil "mobile_respawn" && {!isNull mobile_respawn}) then {
        _pairs pushBack [mobile_respawn_teleport, mobile_respawn];
    };

    if (!isNil "mobile_respawn_teleport_1" && {!isNull mobile_respawn_teleport_1} &&
        !isNil "mobile_respawn_1" && {!isNull mobile_respawn_1}) then {
        _pairs pushBack [mobile_respawn_teleport_1, mobile_respawn_1];
    };

    {
        private _sign = _x select 0;
        private _vehicle = _x select 1;

        _sign addAction [
            "<t color='#FFFF00'>Command Tank</t>",
            {
                params ["_target", "_caller", "_actionId", "_args"];
                private _vehicle = _args select 0;

                private _pos1 = getPosATL _vehicle;
                uiSleep 0.2;
                private _pos2 = getPosATL _vehicle;

                if (_pos1 distance2D _pos2 > 0.1) then {
                    ["CommandTankMoving"] call BIS_fnc_showNotification;
                } else {
                    if (_vehicle animationPhase 'hide_tent' == 0) then {
                        _caller moveInCargo _vehicle;
                    } else {
                        ["CommandTankNotDeployed"] call BIS_fnc_showNotification;
                    };
                };
            },
            [_vehicle],
            1,
            false,
            true,
            "",
            "_this distance _target < 5"
        ];
    } forEach _pairs;
};