// This code goes into the OPFOR base trigger's On Activation field
// [thisTrigger] execVM "functions\blufor_base.sqf";

params ["_trigger"];

{
    if (isPlayer _x && alive _x && side _x == west && isNil {_x getVariable "RedZoneTimer"}) then {
        private _unit = _x;
        
        if (local _unit) then {
            if (_unit inArea _trigger) then {
                // BLUFOR entering OPFOR base logic
                [_unit, _trigger] spawn {
                    params ["_unit", "_trg"];
                    private _countdown = 20;

                    _unit setVariable ["RedZoneTimer", true, true];

                    while {_countdown > 0 && (_unit inArea _trg) && alive _unit} do {
                        private _msg = format [
                            "<t size='2' color='#FF0000' align='center'>WARNING: You are in the OPFOR base! Leave in %1 seconds!</t>",
                            _countdown
                        ];
                        [_msg] remoteExec ["BIS_fnc_dynamicText", _unit];
                        _countdown = _countdown - 1;
                        sleep 1;
                    };

                    _unit setVariable ["RedZoneTimer", nil, true];

                    if (!alive _unit) exitWith {
                    };

                    // If the player is still in the area after the countdown, they failed
                    if (_unit inArea _trg) then {
                        ["<t size='2' color='#FF0000' align='center'>You failed to leave the OPFOR base.</t>"]
                            remoteExec ["BIS_fnc_dynamicText", _unit];
                        _unit setVelocity [0, 0, 500];
                        sleep 5;
                        _unit setDamage 1;
                    } else {
                        // If the player left the base, success message
                        ["<t size='1.5' color='#00FF00' align='center'>You successfully left the OPFOR base!</t>"]
                            remoteExec ["BIS_fnc_dynamicText", _unit];
                        sleep 2;
                        [""] remoteExec ["BIS_fnc_dynamicText", _unit];
                    };
                };
            };
        };
    };
} forEach allPlayers;
