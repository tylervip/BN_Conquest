//Killstreak\napalm_strike.sqf

// Remove the Napalm Strike action from the player immediately
player removeAction drop_Action_Napalm;

openMap true;
mapclick = false;

onMapSingleClick {
    clickpos = _pos; 
    mapclick = true; 
    onMapSingleClick ''; 
    true;
};

cutText ["<t color='#FF6600' size='1.2' font='PuristaBold' align='center'>Choose the location for the Napalm Strike</t>", "PLAIN", -1, true, true];

waitUntil { mapclick };
cutText ["", "PLAIN"];
private _targetPos = clickpos;

// Create local marker for visual cue
private _napalmMarker = createMarker ["NapalmStrikeMarker", _targetPos];
_napalmMarker setMarkerColor "ColorRed";
_napalmMarker setMarkerShape "ELLIPSE";
_napalmMarker setMarkerSize [50, 50];

sleep 1;
openMap false;

// Setup
private _planeType = "vn_b_air_f4c_cas";
private _spawnaltitude = 750;
private _flyInaltitude = 50;

// Spawn position 1500m north of target
private _spawnPos = [
    _targetPos select 0,
    (_targetPos select 1) + 1500,
    _spawnaltitude
];

// Spawn plane
private _plane = createVehicle [_planeType, _spawnPos, [], 0, "FLY"];
_plane engineOn true;
_plane setDir 180;
_plane setposATL _spawnPos;
_plane flyInHeight _flyInaltitude;

// Add pilot
private _pilotGrp = createGroup civilian;
private _pilot = _pilotGrp createUnit ["C_Marshal_F", _spawnPos, [], 0, "NONE"];
[_pilot] joinSilent _pilotGrp;
_pilot moveInDriver _plane;

// Fly to target
private _wp = _pilotGrp addWaypoint [_targetPos, 0];
_wp setWaypointType "MOVE";
_wp setWaypointSpeed "FULL";
_wp setWaypointBehaviour "CARELESS";
_wp setWaypointCompletionRadius 50;

// Wait until plane reaches target, is destroyed, or no longer exists
private _startTime = time;
waitUntil { isNull _plane || _plane distance2D _targetPos < 40 || !alive _plane };

if (!alive _plane || isNull _plane) exitWith {
    // Plane destroyed or no longer exists — cleanup marker, pilot, group
    if (!isNil "_napalmMarker") then {
        deleteMarker _napalmMarker;
    };
    sleep 15;

    if (!isNull _pilot) then {
        deleteVehicle _pilot;
    };

    if (!isNull _pilotGrp) then {
        deleteGroup _pilotGrp;
    };

    // Delete wreck or plane object if it exists (handle wreck)
    if (!isNull _plane) then {
        deleteVehicle _plane;
    };
};


// Drop bomb
private _bombSpawnPos = [
    _targetPos select 0,
    _targetPos select 1,
    getPosASL _plane select 2
];

private _bomb = "vn_bomb_500_blu1b_fb_ammo" createVehicle _bombSpawnPos;
_bomb setVectorDirAndUp [[0, 0, -1], [0, 1, 0]];
_bomb setVelocity [0, 0, -60];

// Wait for impact
waitUntil { isNull _bomb || damage _bomb > 0.9 || !alive _bomb };

// Delete local marker
if (!isNil "_napalmMarker") then {
    deleteMarker _napalmMarker;
};

// Spawn fire effects
private _fires = [];
for "_i" from 1 to 20 do {
    private _radius = random 50;
    private _angle = random 360;

    private _xOffset = _radius * cos _angle;
    private _yOffset = _radius * sin _angle;

    private _firePos = [
        (_targetPos select 0) + _xOffset,
        (_targetPos select 1) + _yOffset,
        0
    ];

    private _fire = "test_EmptyObjectForFireBig" createVehicle _firePos;
    _fires pushBack _fire;
};

// Cleanup fires after 30 seconds
{
    [_x] spawn {
        params ["_f"];
        sleep 30;
        if (!isNull _f) then { deleteVehicle _f };
    };
} forEach _fires;

// Cleanup aircraft and pilot
sleep 30;

// Safely delete plane crew
private _driver = driver _plane;
if (!isNull _driver) then {
    deleteVehicleCrew _plane;
    deleteVehicle _driver;
};

// Delete pilot if still exists and not already removed
if (!isNull _pilot) then { deleteVehicle _pilot };

// Delete plane if it still exists
if (!isNull _plane) then { deleteVehicle _plane };

// Delete group if not already removed
if (!isNull _pilotGrp) then { deleteGroup _pilotGrp };

// Delete local marker
if (!isNil "_napalmMarker") then {
    deleteMarker _napalmMarker;
};