//Killstreak\airstrike.sqf

player removeAction drop_Action_Airstrike;

// === Map Click Target ===
openMap true;
mapclick = false;

onMapSingleClick {
	clickpos = _pos;
	mapclick = true;
	onMapSingleClick "";
	true;
};

cutText ["<t color='#FF6600' size='1.2' font='PuristaBold' align='center'>Select location for Airstrike</t>", "PLAIN", -1, true, true];

waitUntil { mapclick };
cutText ["", "PLAIN"];
openMap false;

private _targetPos = clickpos;

// === Create marker ===
private _strikeMarker = createMarker ["AirStrikeMarker", _targetPos];
_strikeMarker setMarkerColor "ColorRed";
_strikeMarker setMarkerShape "ELLIPSE";
_strikeMarker setMarkerSize [100, 100];

sleep 1;

// === Spawn multiple aircraft from same vector ===
private _planeType = "vn_b_air_f4c_cas";
private _spawnAltitude = 1000;
private _flyInAltitude = 100;
private _spawnDistance = 2500; // Spawn 2500m north of target

// Spawn 2 planes staggered from north
private _planes = [];
private _staggerOffsets = [0, 100]; // Stagger them 100m apart
private _lateralOffsets = [-50, 50]; // Left and right 50m spread

{
	private _offset = _x;
	private _lateralOffset = _lateralOffsets select _forEachIndex;
	private _spawnPos = [
		(_targetPos select 0) + _lateralOffset,
		(_targetPos select 1) + _spawnDistance + _offset,
		_spawnAltitude
	];
	
	// Spawn plane
	private _plane = createVehicle [_planeType, _spawnPos, [], 0, "FLY"];
	_plane engineOn true;
	_plane setDir 180;
	_plane setposATL _spawnPos;
	_plane flyInHeight _flyInAltitude;
	
	// Create civilian pilot group
	private _pilotGrp = createGroup civilian;
	private _pilot = _pilotGrp createUnit ["C_Marshal_F", _spawnPos, [], 0, "NONE"];
	_pilot moveInDriver _plane;
	
	// Add waypoint to target
	private _wp = _pilotGrp addWaypoint [_targetPos, 0];
	_wp setWaypointType "MOVE";
	_wp setWaypointSpeed "FULL";
	_wp setWaypointBehaviour "CARELESS";
	_wp setWaypointCompletionRadius 75;
	
	// Combat setup
	_plane setCombatMode "RED";
	_plane setBehaviour "CARELESS";
	
	_planes pushBack [_plane, _pilotGrp, _pilot, _targetPos];
	
} forEach _staggerOffsets;

// === Bombing runs ===
{
	private _plane = _x select 0;
	private _pilotGrp = _x select 1;
	private _pilot = _x select 2;
	private _tPos = _x select 3;
	
	[_plane, _pilotGrp, _pilot, _tPos, _strikeMarker] spawn {
		params ["_plane", "_grp", "_pilot", "_targetPos", "_marker"];
		
		// Wait until plane reaches target
		waitUntil {
			sleep 0.5;
			!alive _plane || _plane distance2D _targetPos < 80 || !alive _pilot
		};
		
		// Target reached
		if (alive _plane && alive _pilot) then {
			_plane setVariable ["targetReached", true];
		};
		
		// FAILSAFE: If plane destroyed mid-flight, cleanup immediately
		if (!alive _plane || isNull _plane) exitWith {
			// Plane destroyed or no longer exists — cleanup immediately
			if (!isNil "_marker") then {
				deleteMarker _marker;
			};
			sleep 15;
			
			if (!isNull _pilot) then {
				deleteVehicle _pilot;
			};
			
			if (!isNull _grp) then {
				deleteGroup _grp;
			};
			
			// Delete wreck or plane object if it exists
			if (!isNull _plane) then {
				deleteVehicle _plane;
			};
		};
		
		if (alive _plane && alive _pilot) then {
			// Drop multiple bombs across target area
			private _bombCount = 4;
			private _bombs = [];
			for "_i" from 0 to _bombCount do {
				private _offset = [
					(random 200) - 100,
					(random 200) - 100,
					0
				];
				
				private _bombPos = [
					(_targetPos select 0) + (_offset select 0),
					(_targetPos select 1) + (_offset select 1),
					(getPosASL _plane select 2) - 10
				];
				
				private _bomb = "vn_bomb_500_mk82_he_ammo" createVehicle _bombPos;
				_bomb setVectorDirAndUp [[0, 0, -1], [0, 1, 0]];
				_bomb setVelocity [0, 0, -80];
				_bombs pushBack _bomb;
				
				sleep 0.1;
			};
			
			// Wait for bombs to impact
			waitUntil {
				sleep 0.5;
				_plane getVariable ["targetReached", false]
			};
			
			// Fly away from target
			private _exitPos = _targetPos vectorAdd [sin(random 360) * 2000, cos(random 360) * 2000, 0];
			private _exitWP = _grp addWaypoint [_exitPos, 0];
			_exitWP setWaypointType "MOVE";
			_exitWP setWaypointSpeed "FULL";
			_exitWP setWaypointBehaviour "CARELESS";
		};
		
		// Delete marker
		if (!isNil "_marker") then {
			deleteMarker _marker;
		};
		
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
		if (!isNull _grp) then { deleteGroup _grp };
		
		// Delete local marker
		if (!isNil "_marker") then {
			deleteMarker _marker;
		};
	};
	
} forEach _planes;