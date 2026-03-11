//Killstreak\gunship_support.sqf

// === Prevent Double Spawn Per Side ===
private _playerSide = side player;
private _existing = missionNamespace getVariable ["gunship_vehicles", []]; // Array of [side, vehicle]

private _myGunship = _existing findIf { 
    private _entry = _x;
    (_entry select 0) == _playerSide && !isNull (_entry select 1) && alive (_entry select 1)
};

if (!isNil "_myGunship" && _myGunship != -1) exitWith {
    hint "Gunship already active for your side!";
};
player removeAction drop_Action_Gunship;

// === Map Click Target ===
openMap true;
mapclick = false;
onMapSingleClick {
    clickpos = _pos;
    mapclick = true;
    onMapSingleClick '';
    true;
};
cutText ["<t color='#FF6600' size='1.2' font='PuristaBold' align='center'>Select a location for the gunship support</t>", "PLAIN", -1, true, true];
waitUntil { mapclick };
cutText ["", "PLAIN"];
openMap false;
private _targetPos = clickpos;

// === Gunship Setup ===
private _gunshipClass = "vn_b_air_ach47_02_01";
private _spawnPos = player modelToWorld [0, -1500, 0];

// === Spawn Gunship ===
gunship_vehicle = createVehicle [_gunshipClass, _spawnPos, [], 0, "FLY"];
gunship_vehicle setDir (getDir player);
gunship_vehicle flyInHeight 30;
gunship_vehicle setVariable ["ks_gunship", true, true];

// === Store Gunship Per Side ===
_existing pushBack [_playerSide, gunship_vehicle];
missionNamespace setVariable ["gunship_vehicles", _existing, true];

// === Aircrew List by Side ===
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

// === Spawn Crew ===
private _grp = createGroup _playerSide;
private _crew = [];
for "_i" from 0 to 8 do {
    private _class = selectRandom _crewClasses;
    private _unit = _grp createUnit [_class, _spawnPos, [], 0, "NONE"];
    _unit moveInAny gunship_vehicle;
    _crew pushBack _unit;
};

// === Confirm All Moved In ===
waitUntil {
    sleep 0.25;
    { _x in gunship_vehicle } count _crew == count _crew
};

// === Combat Behavior ===
gunship_vehicle setCombatMode "RED";
gunship_vehicle setBehaviour "COMBAT";

// === Attack / Loiter Waypoint ===
private _wp = _grp addWaypoint [_targetPos, 50];
_wp setWaypointType "LOITER";
_wp setWaypointSpeed "LIMITED";
_wp setWaypointBehaviour "COMBAT";
_wp setWaypointLoiterRadius 150;
_wp setWaypointLoiterType "CIRCLE";

// === Reveal Nearby Units To Gunship Crew ===
private _revealNearbyToGunship = {
    params ["_gunshipVeh", "_gunshipGrp"];
    while {alive _gunshipVeh} do {
        sleep 5;

        private _nearby = nearestObjects [getPos _gunshipVeh, ["Man"], 1000];

        {
            private _unit = _x;
            if (alive _unit) then {
                {
                    _x reveal _unit;
                } forEach units _gunshipGrp;
            };
        } forEach _nearby;
    };
};
[gunship_vehicle, _grp] spawn _revealNearbyToGunship;

// === Cleanup Script ===
[gunship_vehicle, _grp] spawn {
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
        private _all = missionNamespace getVariable ["gunship_vehicles", []];
        _all = _all select {(_x select 1) != _veh};
        missionNamespace setVariable ["gunship_vehicles", _all, true];
    };

    deleteGroup _grp;
};

// === Exit After 5 Minutes ===
[gunship_vehicle] spawn {
    params ["_veh"];
    sleep 300;

    if (alive _veh) then {
        private _grp = group _veh;
        private _flyAwayPos = _veh modelToWorld [0, -5000, 1000];

        // Fly-Away Waypoint
        private _wpFlyAway = _grp addWaypoint [_flyAwayPos, 100];
        _wpFlyAway setWaypointType "MOVE";
        _wpFlyAway setWaypointSpeed "FULL";
        _wpFlyAway setWaypointBehaviour "CARELESS";

        // Remove old waypoints
        for "_i" from (count waypoints _grp) - 2 to 0 step -1 do {
            deleteWaypoint [_grp, _i];
        };

        // Cleanup after 60s
        sleep 60;
        {
            if (!isNull _x) then { deleteVehicle _x };
        } forEach units _grp;
        deleteVehicle _veh;

        // Remove from missionNamespace array
        private _all = missionNamespace getVariable ["gunship_vehicles", []];
        _all = _all select {(_x select 1) != _veh};
        missionNamespace setVariable ["gunship_vehicles", _all, true];
    };
};
