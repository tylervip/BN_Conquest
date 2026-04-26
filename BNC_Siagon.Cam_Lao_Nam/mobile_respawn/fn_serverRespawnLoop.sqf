/**
    File: mobile_respawn\fn_serverRespawnLoop.sqf
    Author: TylenolVIP

    Description:
        Server loop that respawns destroyed mobile respawn vehicles.
*/

if (!isServer) exitWith {};
if (isNil "MRS_vehicleDefs") exitWith {
    diag_log "[Mobile Respawn] serverRespawnLoop aborted: MRS_vehicleDefs is nil";
};

private _respawnDelay = missionNamespace getVariable ["MRS_respawnDelay", 45];
private _respawnInProgress = createHashMap;
private _templates = createHashMap;

// Cache initial spawn templates from placed editor vehicles.
{
    _x params ["_varName", "_markerName", "_side"];

    private _vehicle = missionNamespace getVariable [_varName, objNull];
    if (!isNull _vehicle) then {
        private _flagTexture = _vehicle getVariable ["vn_flag", getText (configOf _vehicle >> "vn_flag")];
        private _flagRaised = if (isNumber (configOf _vehicle >> "AnimationSources" >> "vn_flag_raise" >> "initPhase")) then {
            _vehicle animationSourcePhase "vn_flag_raise"
        } else {
            0
        };

        _templates set [_varName, [
            typeOf _vehicle,
            getPosATL _vehicle,
            getDir _vehicle,
            vectorDir _vehicle,
            vectorUp _vehicle,
            _flagTexture,
            _flagRaised
        ]];
    };
} forEach MRS_vehicleDefs;

while {true} do {
    {
        _x params ["_varName", "_markerName", "_side"];

        private _vehicle = missionNamespace getVariable [_varName, objNull];
        if (!isNull _vehicle && {alive _vehicle}) then { continue };

        if (_respawnInProgress getOrDefault [_varName, false]) then { continue };

        _respawnInProgress set [_varName, true];

        [_varName, _respawnDelay, _templates, _respawnInProgress] spawn {
            params ["_varName", "_delay", "_templates", "_respawnInProgress"];

            uiSleep _delay;

            // Skip if already recreated by another script.
            private _current = missionNamespace getVariable [_varName, objNull];
            if (!isNull _current && {alive _current}) exitWith {
                _respawnInProgress set [_varName, false];
            };

            private _template = _templates getOrDefault [_varName, []];
            if (_template isEqualTo []) exitWith {
                _respawnInProgress set [_varName, false];
                diag_log format ["[Mobile Respawn] No template found for %1", _varName];
            };

            _template params ["_type", "_posATL", "_dir", "_vectorDir", "_vectorUp", "_flagTexture", "_flagRaised"];

            if (!isNull _current) then {
                deleteVehicle _current;
            };

            private _newVehicle = _type createVehicle [0, 0, 0];
            _newVehicle setPosATL _posATL;
            _newVehicle setDir _dir;
            _newVehicle setVectorDirAndUp [_vectorDir, _vectorUp];

            if (_flagTexture != "") then {
                _newVehicle setVariable ["vn_flag", _flagTexture, true];
                _newVehicle forceFlagTexture _flagTexture;
            };

            if (_flagRaised > 0.5 && {isNumber (configOf _newVehicle >> "AnimationSources" >> "vn_flag_raise" >> "initPhase")}) then {
                _newVehicle animateSource ["vn_flag_raise", 1, true];
            };

            _newVehicle setVehicleVarName _varName;
            missionNamespace setVariable [_varName, _newVehicle, true];
            publicVariable _varName;

            _respawnInProgress set [_varName, false];
            diag_log format ["[Mobile Respawn] Respawned %1", _varName];
        };
    } forEach MRS_vehicleDefs;

    uiSleep 3;
};
