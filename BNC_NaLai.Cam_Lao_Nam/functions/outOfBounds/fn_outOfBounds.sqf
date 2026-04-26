// Uses the ModuleCoverMap_F editor area as the playable zone.

if (!hasInterface) exitWith {};
if (missionNamespace getVariable ["BNC_outOfBoundsLoopRunning", false]) exitWith {};
missionNamespace setVariable ["BNC_outOfBoundsLoopRunning", true];

[] spawn {
    waitUntil { !isNull player };

    private _coverMap = objNull;
    {
        if (typeOf _x == "ModuleCoverMap_F") exitWith {
            _coverMap = _x;
        };
    } forEach allMissionObjects "ModuleCoverMap_F";

    if (isNull _coverMap) exitWith {
        missionNamespace setVariable ["BNC_outOfBoundsLoopRunning", false];
        diag_log "[BNC][outOfBounds] ModuleCoverMap_F not found. Zone check skipped.";
    };

    private _coverArea = _coverMap getVariable ["objectArea", []];
    if ((count _coverArea) < 4) then {
        _coverArea = triggerArea _coverMap;
    };

    if ((count _coverArea) < 4) then {
        private _sizeAFromVar = _coverMap getVariable ["sizeA", -1];
        private _sizeBFromVar = _coverMap getVariable ["sizeB", -1];
        if (_sizeAFromVar > 0 && {_sizeBFromVar > 0}) then {
            _coverArea = [_sizeAFromVar, _sizeBFromVar, getDir _coverMap, true];
        };
    };

    if ((count _coverArea) < 4) exitWith {
        missionNamespace setVariable ["BNC_outOfBoundsLoopRunning", false];
        diag_log "[BNC][outOfBounds] Could not read ModuleCoverMap_F area (objectArea/triggerArea/size vars). Zone check skipped.";
    };

    private _sizeA = _coverArea param [0, -1];
    private _sizeB = _coverArea param [1, -1];
    private _angle = _coverArea param [2, 0];
    private _isRectangle = _coverArea param [3, false];

    if (_sizeA <= 0 || {_sizeB <= 0}) exitWith {
        missionNamespace setVariable ["BNC_outOfBoundsLoopRunning", false];
        diag_log "[BNC][outOfBounds] ModuleCoverMap_F size is invalid. Zone check skipped.";
    };

    private _zoneArea = [getPosATL _coverMap, _sizeA, _sizeB, _angle, _isRectangle];

    while {true} do {
        {
            if (
                isPlayer _x &&
                alive _x &&
                !(_x inArea _zoneArea) &&
                isNil {_x getVariable "zoneTimer"}
            ) then {
                private _unit = _x;

                if (local _unit) then {
                    [_unit, _zoneArea] spawn {
                        params ["_unit", "_zoneAreaInner"];
                        private _countdown = 20;

                        _unit setVariable ["zoneTimer", true, true];

                        while {_countdown > 0 && !(_unit inArea _zoneAreaInner) && alive _unit} do {
                            private _msg = format [
                                "<t size='2' color='#FF0000' align='center'>WARNING: Return to the zone in %1 seconds!</t>",
                                _countdown
                            ];
                            [_msg] remoteExec ["BIS_fnc_dynamicText", _unit];
                            _countdown = _countdown - 1;
                            sleep 1;
                        };

                        _unit setVariable ["zoneTimer", nil, true];

                        if (!alive _unit) exitWith {};

                        if (_unit inArea _zoneAreaInner) then {
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

        sleep 0.1;
    };
};