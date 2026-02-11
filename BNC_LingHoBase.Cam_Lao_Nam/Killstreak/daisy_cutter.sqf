// daisy_cutter.sqf

// Remove the DaisyCutter Strike action from the player immediately
player removeAction drop_Action_DaisyCutter;

openMap true;
mapclick = false;

onMapSingleClick {
    clickpos = _pos; 
    mapclick = true; 
    onMapSingleClick ''; 
    true;
};

cutText ["<t color='#FF6600' size='1.2' font='PuristaBold' align='center'>Choose the location for the Daisy Cutter</t>", "PLAIN", -1, true, true];

waitUntil { mapclick };
cutText ["", "PLAIN"];
private _targetPos = clickpos;

// Create local marker for visual cue
private _DaisyCutterMarker = createMarker ["DaisyCutterMarker", _targetPos];
_DaisyCutterMarker setMarkerColor "ColorRed";
_DaisyCutterMarker setMarkerShape "ELLIPSE";
_DaisyCutterMarker setMarkerSize [50, 50];

sleep 1;
openMap false;

// Setup
private _planeType = "vn_b_air_f4c_cas";
private _spawnaltitude = 1000;
private _flyInaltitude = 200;
private _SpawnPosition = 2500;// Spawn position north of target

private _spawnPos = [
    _targetPos select 0,
    (_targetPos select 1) + _SpawnPosition,
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
    if (!isNil "_DaisyCutterMarker") then {
        deleteMarker _DaisyCutterMarker;
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
    (getPosASL _plane select 2) - 10 // Slightly below plane altitude
];

private _bomb = "vn_bomb_15000_blu82_dc_parachute_ammo" createVehicle _bombSpawnPos;
_bomb setVectorDirAndUp [[0, 0, -1], [0, 1, 0]];
_bomb setVelocity [0, 0, 0];

// Wait for impact
waitUntil { isNull _bomb || damage _bomb > 0.9 || !alive _bomb };

// Delete marker
if (!isNil "_DaisyCutterMarker") then {
    deleteMarker _DaisyCutterMarker;
};

// Fly away from target
private _exitPos = _targetPos vectorAdd [sin(random 360) * 2000, cos(random 360) * 2000, 0];
private _exitWP = _pilotGrp addWaypoint [_exitPos, 0];
_exitWP setWaypointType "MOVE";
_exitWP setWaypointSpeed "FULL";
_exitWP setWaypointBehaviour "CARELESS";

// Wait for plane to fly away
waitUntil {
	sleep 1;
	!alive _plane || _plane distance2D _targetPos > 1500
};

// Cleanup aircraft and pilot
sleep 10;

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
if (!isNil "_DaisyCutterMarker") then {
    deleteMarker _DaisyCutterMarker;
};