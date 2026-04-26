// Uses marker opfor_protection for OPFOR base protection zone.

if (!hasInterface) exitWith {};
if (missionNamespace getVariable ["BNC_opforBaseLoopRunning", false]) exitWith {};
missionNamespace setVariable ["BNC_opforBaseLoopRunning", true];

[] spawn {
    waitUntil { !isNull player };

    private _baseMarker = "opfor_protection";

    while {true} do {
        {
            if (
                isPlayer _x &&
                alive _x &&
                side _x == west &&
                (_x inArea _baseMarker) &&
                isNil {_x getVariable "RedZoneTimer"}
            ) then {
                private _unit = _x;

                if (local _unit) then {
                    [_unit, _baseMarker] spawn {
                        params ["_unit", "_areaMarker"];
                        private _countdown = 20;

                        _unit setVariable ["RedZoneTimer", true, true];

                        while {_countdown > 0 && (_unit inArea _areaMarker) && alive _unit} do {
                            private _msg = format [
                                "<t size='2' color='#FF0000' align='center'>WARNING: You are in the OPFOR base! Leave in %1 seconds!</t>",
                                _countdown
                            ];
                            [_msg] remoteExec ["BIS_fnc_dynamicText", _unit];
                            _countdown = _countdown - 1;
                            sleep 1;
                        };

                        _unit setVariable ["RedZoneTimer", nil, true];

                        if (!alive _unit) exitWith {};

                        if (_unit inArea _areaMarker) then {
                            ["<t size='2' color='#FF0000' align='center'>You failed to leave the OPFOR base.</t>"]
                                remoteExec ["BIS_fnc_dynamicText", _unit];
                            _unit setVelocity [0, 0, 500];
                            sleep 5;
                            _unit setDamage 1;
                        } else {
                            ["<t size='1.5' color='#00FF00' align='center'>You successfully left the OPFOR base!</t>"]
                                remoteExec ["BIS_fnc_dynamicText", _unit];
                            sleep 2;
                            [""] remoteExec ["BIS_fnc_dynamicText", _unit];
                        };
                    };
                };
            };
        } forEach allPlayers;

        sleep 0.1;
    };
};