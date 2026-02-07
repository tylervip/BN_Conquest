// === Prevent Double Spawn Per Side ===
private _playerSide = side player;
private _existing = missionNamespace getVariable ["attackHeli_vehicles", []]; // Array of [side, vehicle]

private _myHeli = _existing findIf { 
    private _entry = _x;
    (_entry select 0) == _playerSide && !isNull (_entry select 1) && alive (_entry select 1)
};

if (_myHeli != -1) exitWith {
    hint "Attack helicopter already active for your side!";
};
player removeAction drop_Action_AttackHelo;

// === Map Click Target ===
openMap true;
mapclick = false;

onMapSingleClick {
    clickpos = _pos;
    mapclick = true;
    onMapSingleClick "";
    true;
};

cutText ["<t color='#FF6600' size='1.2' font='PuristaBold' align='center'>Select a location for the Attack helicopter</t>", "PLAIN", -1, true, true];
waitUntil { mapclick };
cutText ["", "PLAIN"];
openMap false;

private _targetPos = clickpos;

// --- Spawn Helicopter ---
private _attackHeliClass = "vn_b_air_ah1g_09";
private _spawnPos = player modelToWorld [0, -1200, 300];

attackHeli_vehicle = createVehicle [_attackHeliClass, _spawnPos, [], 0, "FLY"];
attackHeli_vehicle setDir (getDir player);
attackHeli_vehicle flyInHeight 100;
attackHeli_vehicle setVariable ["ks_attackHelo", true, true];

// === Store Helicopter Per Side ===
_existing pushBack [_playerSide, attackHeli_vehicle];
missionNamespace setVariable ["attackHeli_vehicles", _existing, true];

private _grp = createGroup _playerSide;

// === Aircrew list by side ===
private _crewClasses = switch (_playerSide) do {
    case east: {
        ["vn_o_men_aircrew_06", "vn_o_men_aircrew_07", "vn_o_men_aircrew_08"];
    };
    case west: {
        ["vn_b_men_aircrew_01", "vn_b_men_aircrew_02", "vn_b_men_aircrew_05", "vn_b_men_aircrew_06"];
    };
    default {
        hint "Unsupported side.";
        []
    };
};

if (count _crewClasses < 2) exitWith {
    hint "Not enough crew classes defined for this side.";
};

private _pilotClass = _crewClasses select 0;
private _gunnerClass = _crewClasses select 1;

private _pilot = _grp createUnit [_pilotClass, _spawnPos vectorAdd [0, 0, 0], [], 0, "NONE"];
private _gunner = _grp createUnit [_gunnerClass, _spawnPos vectorAdd [2, 2, 0], [], 0, "NONE"];

_pilot moveInDriver attackHeli_vehicle;
_gunner moveInGunner attackHeli_vehicle;

attackHeli_vehicle setCombatMode "RED";
attackHeli_vehicle setBehaviour "COMBAT";

// === Initial Waypoint at Clicked Position ===
private _wp = _grp addWaypoint [_targetPos, 0];
_wp setWaypointType "SAD";
_wp setWaypointSpeed "LIMITED";
_wp setWaypointBehaviour "COMBAT";

// === Reveal Nearby Units To Helicopter Crew ===
private _revealNearbyToHeli = {
    params ["_veh", "_grp"];

    while {alive _veh} do {
        sleep 5;

        private _nearby = nearestObjects [getPos _veh, ["Man"], 1000];

        {
            private _unit = _x;
            if (alive _unit) then {
                {
                    _x reveal _unit;
                } forEach units _grp;
            };
        } forEach _nearby;
    };
};

// --- Spawn the loop ---
[attackHeli_vehicle, _grp] spawn _revealNearbyToHeli;

// === Cleanup on Death or Group Wipe ===
[attackHeli_vehicle, _grp] spawn {
    params ["_veh", "_grp"];

    waitUntil {
        sleep 2;
        isNull _veh
        || {!alive _veh}
        || ({alive _x} count units _grp == 0)
    };

    sleep 30;

    {
        if (!isNull _x) then { deleteVehicle _x };
    } forEach units _grp;

    if (!isNull _veh) then { 
        deleteVehicle _veh;

        // Remove from missionNamespace array
        private _all = missionNamespace getVariable ["attackHeli_vehicles", []];
        _all = _all select {(_x select 1) != _veh};
        missionNamespace setVariable ["attackHeli_vehicles", _all, true];
    };

    deleteGroup _grp;
};

// === Exit After 3 Minutes ===
[attackHeli_vehicle] spawn {
    params ["_veh"];
    sleep 180;

    if (alive _veh) then {
        private _grp = group _veh;
        private _flyAwayPos = _veh modelToWorld [0, -5000, 1000];

        private _wpFlyAway = _grp addWaypoint [_flyAwayPos, 100];
        _wpFlyAway setWaypointType "MOVE";
        _wpFlyAway setWaypointSpeed "FULL";
        _wpFlyAway setWaypointBehaviour "CARELESS";

        // Remove old waypoints
        for "_i" from (count waypoints _grp) - 2 to 0 step -1 do {
            deleteWaypoint [_grp, _i];
        };

        sleep 60;

        {
            if (!isNull _x) then deleteVehicle _x;
        } forEach units _grp;

        deleteVehicle _veh;

        // Remove from missionNamespace array
        private _all = missionNamespace getVariable ["attackHeli_vehicles", []];
        _all = _all select {(_x select 1) != _veh};
        missionNamespace setVariable ["attackHeli_vehicles", _all, true];
    };
};

