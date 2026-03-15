// fn_aiCoordinator.sqf
// Coordination layer between VCOM AI (strategic/long-range) and RNG AI (tactical/close-range)
// When enemies are within RNG_range, RNG takes over and VCOM is paused on that group.
// When enemies leave RNG_range, VCOM resumes strategic control.
//
// Run on server only. Call: [] spawn RNG_fnc_aiCoordinator;

if (!isServer) exitWith {};

diag_log "AI_COORDINATOR: Starting VCOM/RNG integration coordinator";

// Wait for both systems to initialize
waitUntil {!isNil "RNG_range" && !isNil "Vcm_ActivateAI"};

diag_log format ["AI_COORDINATOR: Both systems ready. RNG_range = %1", RNG_range];

private _checkInterval = 2; // seconds between coordination checks

while {true} do {
    sleep _checkInterval;

    private _range = missionNamespace getVariable ["RNG_range", 100];
    private _rngOff = missionNamespace getVariable ["RNG_off", false];

    {
        private _group = _x;

        // Skip player-led groups, empty groups, non-local groups
        if (isPlayer (leader _group) || {count (units _group) == 0} || {!local _group}) then {
            continue;
        };

        // Skip if RNG is globally off
        if (_rngOff) then {
            // Make sure VCOM isn't stuck disabled from a previous RNG session
            if (_group getVariable ["RNG_vcom_paused", false]) then {
                _group setVariable ["Vcm_Disable", false];
                _group setVariable ["RNG_vcom_paused", false];
                {
                    _x setVariable ["RNG_disabled", false];
                } forEach (units _group);
                diag_log format ["AI_COORDINATOR: RNG off - Resumed VCOM on group %1", _group];
            };
            continue;
        };

        // Check if any unit in the group has enemies within RNG_range
        private _hasCloseEnemy = false;
        {
            private _unit = _x;
            if (alive _unit && {!isPlayer _unit} && {vehicle _unit == _unit}) then {
                private _targets = _unit targets [true, _range];
                if (count _targets > 0) then {
                    _hasCloseEnemy = true;
                };
            };
            if (_hasCloseEnemy) then { break; };
        } forEach (units _group);

        private _vcomPaused = _group getVariable ["RNG_vcom_paused", false];

        if (_hasCloseEnemy) then {
            // Enemies within RNG_range: RNG takes over, pause VCOM
            if (!_vcomPaused) then {
                _group setVariable ["Vcm_Disable", true];
                _group setVariable ["RNG_vcom_paused", true];
                // Ensure RNG is enabled on all units
                {
                    _x setVariable ["RNG_disabled", false];
                } forEach (units _group);
            };
        } else {
            // No close enemies: VCOM resumes strategic control
            if (_vcomPaused) then {
                // Only hand back to VCOM if no unit is in active RNG combat
                private _anyInCombat = false;
                {
                    if (_x getVariable ["RNG_incombat", false] || {_x getVariable ["RNG_cover", false]}) then {
                        _anyInCombat = true;
                    };
                    if (_anyInCombat) then { break; };
                } forEach (units _group);

                if (!_anyInCombat) then {
                    _group setVariable ["Vcm_Disable", false];
                    _group setVariable ["RNG_vcom_paused", false];
                    diag_log format ["AI_COORDINATOR: Resumed VCOM on group %1 - no close enemies", _group];
                };
            };
        };
    } forEach allGroups;
};
