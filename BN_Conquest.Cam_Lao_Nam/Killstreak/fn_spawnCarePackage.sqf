// Killstreak\fn_spawnCarePackage.sqf
// SERVER-SIDE function to spawn the care package

params ["_smoke", "_caller"];

// Wait until smoke hits something (terrain, object, etc.)
waitUntil {
    !isNull _smoke;

    private _pos = getPosASL _smoke;
    private _below = _pos vectorAdd [0,0,-2];
    private _intersections = lineIntersectsSurfaces [_pos, _below, _smoke, objNull, true, 1];

    count _intersections > 0
};

// Position crate 100m above smoke
private _posASL = getPosASL _smoke vectorAdd [0, 0, 100];

// Create parachute
private _chute = createVehicle ["B_Parachute_02_F", [0, 0, 0], [], 0, "CAN_COLLIDE"];
_chute setPosASL _posASL;

// Create supply crate and attach to chute
private _crate = createVehicle ["vn_b_ammobox_supply_05", [0, 0, 0], [], 0, "CAN_COLLIDE"];
_crate attachTo [_chute, [0, 0, 0]];
_crate setVectorUp [0, 0, 1];
_crate setVelocity [0, 0, -10];
_crate allowDamage false;

// Add purple smoke to crate
private _crateSmoke = createVehicle ["vn_m18_purple_ammo", [0, 0, 0], [], 0, "CAN_COLLIDE"];
_crateSmoke attachTo [_crate, [0, 0, 0.3]];

// Randomize crate direction
_crate setDir random 360;

// Detach crate near ground, delete parachute
[_crate, _chute] spawn {
    params ["_crate", "_chute"];
    waitUntil {
        sleep 0.1;
        !isNull _crate;
        private _pos = getPosASL _crate;
        private _below = _pos vectorAdd [0,0,-2];
        private _hits = lineIntersectsSurfaces [_pos, _below, _crate, objNull, true, 1];
        count _hits > 0
    };
    detach _crate;
    sleep 1;
    deleteVehicle _chute;
};

// Load available killstreaks
[] call compile preprocessFileLineNumbers "Killstreak\availableKillstreaks.sqf";
private _ksList = missionNamespace getVariable ["killstreakOptions", []];

// Fallback if none available
if (_ksList isEqualTo []) exitWith {
    if (local _caller) then {
        hint "No killstreaks available.";
    };
};

// Pick random killstreak
private _selectedKS = selectRandom _ksList;
private _ksName = _selectedKS select 0;
private _ksFunc = _selectedKS select 1;

[
    _crate,
    [
        format ["Claim: %1", _ksName],
        {
            params ["_crate", "_caller", "_actionId", "_ksFunc"];
            [_caller] call _ksFunc;
            deleteVehicle _crate;
        },
        _ksFunc,
        1.5,
        true,
        true,
        "",
        "_this distance _target < 5",
        3,
        false
    ]
] remoteExec ["addAction", 0, _crate];