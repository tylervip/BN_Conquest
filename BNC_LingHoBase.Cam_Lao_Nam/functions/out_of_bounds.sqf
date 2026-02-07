//this code is in a trigger
//[thisTrigger] execVM "functions\out_of_bounds.sqf";

params ["_trigger"];

{
    if (
        isPlayer _x &&
        alive _x &&
        !(_x inArea _trigger) &&
        isNil {_x getVariable "zoneTimer"}
    ) then {
        private _unit = _x;

        if (local _unit) then {
            [_unit, _trigger] spawn {
                params ["_unit", "_trg"];
                private _countdown = 20;

                _unit setVariable ["zoneTimer", true, true];

                while {_countdown > 0 && !(_unit inArea _trg) && alive _unit} do {
                    private _msg = format [
                        "<t size='2' color='#FF0000' align='center'>WARNING: Return to the zone in %1 seconds!</t>",
                        _countdown
                    ];
                    [_msg] remoteExec ["BIS_fnc_dynamicText", _unit];
                    _countdown = _countdown - 1;
                    sleep 1;
                };

                _unit setVariable ["zoneTimer", nil, true];

                if (!alive _unit) exitWith {
                };

                if (_unit inArea _trg) then {
                    ["<t size='1.5' color='#00FF00' align='center'>You made it back to the zone!</t>"]
                        remoteExec ["BIS_fnc_dynamicText", _unit];
                    sleep 2;
                    [""] remoteExec ["BIS_fnc_dynamicText", _unit];
                } else {
                    ["<t size='2' color='#FF0000' align='center'>You failed to return.</t>"]
                        remoteExec ["BIS_fnc_dynamicText", _unit];
                    _unit setVelocity [0, 0, 500];
                    sleep 5;
                    _unit setDamage 1;
                };
            };
        };
    };
} forEach allPlayers;
