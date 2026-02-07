//RNG AI by Toksa - Optimized for MP
// Modified: Aggressive cover-push behavior - AI seeks cover while advancing on target
// Added: building/wall avoidance
params ["_unit", "_firer"];

// Only run where AI is local
if (!local _unit) exitWith {};

private _disabled = _unit getvariable ["RNG_disabled", false];
private _off = missionnamespace getvariable ["RNG_off", false];
if (isplayer _unit OR _disabled OR _off) exitWith {};

_unit setvariable ["RNG_incombat", true];
_unit setvariable ["RNG_cover", true];

private _exit = false;
private _pos = [0,0,0];
private _pushPhase = 0; // 0 = find cover, 1 = suppress from cover, 2 = push forward

_unit disableai "PATH";
_unit disableai "MOVE";
_unit disableai "ANIM";
_unit disableai "COVER";
_unit disableai "FSM";
_unit disableai "AIMINGERROR";

private _target = _firer;
private _anims = RNG_ANIM_Run;
private _objects = [];
private _starttime = time;
private _cancrouch = true;
private _lastCoverFind = 0;
private _suppressTime = 0;
private _currentDistToTarget = if (!isNull _target) then {_unit distance _target} else {100};

if (!(unitPos _unit == "Auto")) then {_cancrouch = false;};

// ============= PATH CLEARANCE CHECK =============
// Check if path to position is blocked by walls/buildings
private _fnc_isPathClear = {
	params ["_unit", "_targetPos"];
	private _unitPos = eyePos _unit;
	private _targetPosASL = if (count _targetPos == 3) then {
		ATLToASL [_targetPos select 0, _targetPos select 1, (_targetPos select 2) + 1]
	} else {
		_unitPos
	};
	
	// Check multiple heights and angles for obstacles
	private _intersects = lineIntersectsSurfaces [
		_unitPos,
		_targetPosASL,
		_unit,
		objNull,
		true,
		1,
		"GEOM",
		"NONE"
	];
	
	// Path is clear if no intersections
	(count _intersects == 0)
};

// ============= FIND CLEAR PATH AROUND OBSTACLE =============
private _fnc_findClearPath = {
	params ["_unit", "_blockedPos", "_target"];
	private _clearPos = [0,0,0];
	private _unitDir = _unit getDir _blockedPos;
	
	// Try different angles to find a clear path (flanking around obstacle)
	private _angles = [45, -45, 90, -90, 30, -30, 60, -60];
	{
		private _testAngle = _unitDir + _x;
		private _testDist = 8 + random 5;
		private _testPos = _unit getPos [_testDist, _testAngle];
		
		if ([_unit, _testPos] call _fnc_isPathClear) exitWith {
			_clearPos = _testPos;
		};
	} forEach _angles;
	
	// If still blocked, try shorter distances
	if (_clearPos isEqualTo [0,0,0]) then {
		{
			private _testAngle = _unitDir + _x;
			private _testPos = _unit getPos [4, _testAngle];
			if ([_unit, _testPos] call _fnc_isPathClear) exitWith {
				_clearPos = _testPos;
			};
		} forEach [90, -90, 135, -135, 180];
	};
	
	_clearPos
};

// ============= BUILDING POSITION FINDER =============
// Find positions inside buildings for cover
private _fnc_findBuildingPosition = {
	params ["_unit", "_target"];
	private _buildingPos = [0,0,0];
	private _nearBuildings = nearestObjects [_unit, ["House", "Building"], 40];
	
	{
		private _building = _x;
		private _positions = _building buildingPos -1;
		if (count _positions > 0) then {
			// Sort positions by distance to target (prefer closer to target = aggressive)
			private _sortedPos = [_positions, [], {_target distance _x}, "ASCEND"] call BIS_fnc_sortBy;
			{
				private _bPos = _x;
				// Check if we can reach this position
				if ([_unit, _bPos] call _fnc_isPathClear && {_unit distance _bPos < 30}) exitWith {
					_buildingPos = _bPos;
				};
			} forEach _sortedPos;
		};
		if !(_buildingPos isEqualTo [0,0,0]) exitWith {};
	} forEach _nearBuildings;
	
	_buildingPos
};

if (!(unitPos _unit == "Auto")) then {_cancrouch = false;};

// Start aggressive - prefer standing or crouching for mobility
if (_cancrouch) then {
	private _stance = selectrandom ["Up","Up","Crouch"]; // Favor standing for aggression
	if (!((unitpos _unit) == _stance)) then {
		_unit playactionnow _stance;
	};
	switch (true) do {
		case (_stance == "Up"): {_unit setunitpos "Up"};
		case (_stance == "Crouch"): {_unit setunitpos "Middle"};
	};
};

// Longer engagement time for aggressive push (6-10 seconds)
private _time = time + 6 + (random 4);
_unit playactionnow (_anims select 2); // Start moving forward

// Function to find aggressive cover position (closer to target)
// Includes building positions and path clearance checking
private _fnc_findAggressiveCover = {
	params ["_unit", "_target"];
	private _coverPos = [0,0,0];
	private _objectsDyn = nearestObjects [_unit, ["Wall","fence","Strategic","house","Land"], 80];
	private _objects = nearestTerrainObjects [_unit, ["Tree", "Bush","Wall","fence","Rock","house","Static","Thing","Building"], 80];
	_objects append _objectsDyn;
	
	if (!isNull _target && count _objects > 0) then {
		private _unitDist = _unit distance _target;
		// Find cover that's CLOSER to target than unit (aggressive advance)
		private _advanceCover = [_objects,[],{_target distance _x},"ASCEND",{
			private _objDist = _target distance _x;
			private _unitToObj = _unit distance _x;
			// Object should be: closer to target than us, but not too close (<10m), and reachable (<40m)
			(_objDist < _unitDist) && (_objDist > 10) && (_unitToObj < 40) && (_unitToObj > 3)
		}] call BIS_fnc_sortBy;
		
		if (count _advanceCover > 0) then {
			// Try positions and verify path is clear
			{
				private _testPos = getPos _x;
				if ([_unit, _testPos] call _fnc_isPathClear) exitWith {
					_coverPos = _testPos;
				};
			} forEach (_advanceCover select [0, 5]); // Check top 5
		};
		
		// If no clear outdoor cover, try building positions
		if (_coverPos isEqualTo [0,0,0]) then {
			private _buildingPos = [_unit, _target] call _fnc_findBuildingPosition;
			if !(_buildingPos isEqualTo [0,0,0]) then {
				_coverPos = _buildingPos;
			};
		};
		
		// Fallback: find any cover in the direction of target with clear path
		if (_coverPos isEqualTo [0,0,0]) then {
			private _dirToTarget = _unit getDir _target;
			private _flankCover = [_objects,[],{_unit distance _x},"ASCEND",{
				private _dirToObj = _unit getDir _x;
				private _angleDiff = abs(_dirToTarget - _dirToObj);
				if (_angleDiff > 180) then {_angleDiff = 360 - _angleDiff};
				// Within 60 degrees of target direction
				(_angleDiff < 60) && (_unit distance _x > 5) && (_unit distance _x < 35)
			}] call BIS_fnc_sortBy;
			
			{
				private _testPos = getPos _x;
				if ([_unit, _testPos] call _fnc_isPathClear) exitWith {
					_coverPos = _testPos;
				};
			} forEach (_flankCover select [0, 5]);
		};
	};
	_coverPos
};

// Initial cover find
_pos = [_unit, _target] call _fnc_findAggressiveCover;

// If no cover found, push directly toward target with slight offset (verify path is clear)
if (_pos isEqualTo [0,0,0] && !isNull _target) then {
	private _dirToTarget = _unit getDir _target;
	// Try different offsets until we find a clear path
	private _offsets = [-30, -15, 0, 15, 30] call BIS_fnc_arrayShuffle;
	{
		private _testPos = _unit getPos [15 + random 10, _dirToTarget + _x];
		if ([_unit, _testPos] call _fnc_isPathClear) exitWith {
			_pos = _testPos;
		};
	} forEach _offsets;
	
	// If still blocked, try shorter distance
	if (_pos isEqualTo [0,0,0]) then {
		{
			private _testPos = _unit getPos [6, _dirToTarget + _x];
			if ([_unit, _testPos] call _fnc_isPathClear) exitWith {
				_pos = _testPos;
			};
		} forEach [0, 45, -45, 90, -90];
	};
};

while {alive _unit} do {
	if (time > _time) then {_exit = true};
	if (!alive _unit OR _exit OR (lifestate _unit == "INCAPACITATED") OR !(vehicle _unit == _unit) OR isplayer _unit OR (isplayer (_unit getvariable ["bis_fnc_moduleremotecontrol_owner",objNull]))) exitwith {
		[_unit, _cancrouch, _target] spawn {
			params ["_unit", "_cancrouch", "_target"];
			_unit playactionnow "STOP";
			dostop _unit;
			_unit domove getpos _unit;
			_unit enableai "PATH";
			_unit enableai "MOVE";
			_unit enableai "ANIM";
			_unit enableai "FSM";
			_unit enableai "COVER";
			_unit dofollow leader _unit;
			_unit enableai "AIMINGERROR";
			if (_cancrouch) then {_unit setunitpos "Auto"};
			_unit setvariable ["RNG_incombat", false];
			_unit setvariable ["RNG_cover", false];
			// === VCOM/RNG HANDOFF: Resume VCOM if no other unit in group is in RNG combat ===
			private _grp = group _unit;
			if (_grp getVariable ["RNG_vcom_paused", false]) then {
				private _anyInCombat = false;
				{ if (_x getVariable ["RNG_incombat", false] || {_x getVariable ["RNG_cover", false]}) then { _anyInCombat = true; }; } forEach (units _grp);
				if (!_anyInCombat) then {
					_grp setVariable ["Vcm_Disable", false];
					_grp setVariable ["RNG_vcom_paused", false];
				};
			};
			// Shorter cooldown for aggressive re-engagement
			_unit setvariable ["RNG_cooldown", (time + 3)];
			if (!isNull _target && {vehicle _target iskindof "Tank"}) then {
				_unit setvariable ["RNG_cooldown", (time + 5)];
			};
			sleep 0.5;
		};
	};
	
	// Update target tracking
	if (!isNull _target) then {
		_unit dotarget _target;
		_unit dowatch _target;
	};
	
	
	// ===== PATH CLEARANCE CHECK - Avoid walls/buildings =====
	if (!(_pos isEqualTo [0,0,0]) && {!([_unit, _pos] call _fnc_isPathClear)}) then {
		// Path is blocked - find alternative route around obstacle
		private _clearPath = [_unit, _pos, _target] call _fnc_findClearPath;
		if !(_clearPath isEqualTo [0,0,0]) then {
			_pos = _clearPath;
		};
	};
	
	// Refresh cover position periodically (every 2-3 seconds) to keep pushing
	if (time > _lastCoverFind + 2 + random 1) then {
		_lastCoverFind = time;
		private _newPos = [_unit, _target] call _fnc_findAggressiveCover;
		if !(_newPos isEqualTo [0,0,0]) then {
			_pos = _newPos;
		};
		// Re-extend time if we're still far from target and making progress
		if (!isNull _target && {_unit distance _target > 25}) then {
			_time = _time max (time + 4);
		};
	};
	
	// Suppress fire while moving (aggressive)
	if (!isNull _target && {time > _suppressTime}) then {
		if (([_unit, "FIRE", _target] checkVisibility [aimpos _unit, aimpos _target]) > 0.3) then {
			// Quick suppressive burst while moving
			for "_i" from 1 to (2 + floor random 3) do {
				[_unit, currentmuzzle _unit] call BIS_fnc_fire;
				sleep 0.05;
			};
			_suppressTime = time + 0.8 + random 0.5;
		};
	};
	
	// Face toward target while moving
	if (!isNull _target) then {
		for "_i" from 1 to 5 do {
			_unit setVelocityTransformation
			[
				atltoasl (getposatl _unit),
				atltoasl (getposatl _unit),
				velocity _unit,
				[(velocity _unit) select 0,(velocity _unit) select 1,-1],
				vectordirvisual _unit,
				(aimpos _unit) vectorFromTo (aimpos _target),
				[0,0,1],
				[0,0,1],
				(_i*0.2)
			];
			_unit setvectorup [0,0,1];
			sleep 0.05;
		};
	};
	
	// Movement toward cover position
	if (!isnil "_pos" && {!(_pos isEqualTo [0,0,0])}) then {
		private _dist = _unit distance2D _pos;
		switch (true) do {
			// Reached cover - brief pause then find next cover
			case (_dist < 3): {
				_unit playactionnow "stop";
				_unit setVelocity [0, 0, 0];

				// Quick pause at cover (0.5-1s) then push again
				sleep (0.5 + random 0.5);
				// Find new forward cover
				private _newPos = [_unit, _target] call _fnc_findAggressiveCover;
				if !(_newPos isEqualTo [0,0,0]) then {
					_pos = _newPos;
				} else {
					// No more cover, direct assault - find clear path
					if (!isNull _target && {_unit distance _target > 15}) then {
						private _assaultDir = _unit getDir _target;
						private _foundPath = false;
						{
							private _testPos = _unit getPos [10, _assaultDir + _x];
							if ([_unit, _testPos] call _fnc_isPathClear) exitWith {
								_pos = _testPos;
								_foundPath = true;
							};
						} forEach [0, 30, -30, 60, -60, 90, -90];
						if (!_foundPath) then {_exit = true};
					} else {
						_exit = true;
					};
				};
			};
			// Move animations based on direction
			case ((_unit getreldir _pos) < 67.5 && {(_unit getreldir _pos) > 22.5}): {_unit playactionnow (_anims select 0)};
			case ((_unit getreldir _pos) < 342.5 && {(_unit getreldir _pos) > 297.5}): {_unit playactionnow (_anims select 1)};
			case ((_unit getreldir _pos) < 22.5 OR (_unit getreldir _pos) > 342.5): {_unit playactionnow (_anims select 2)};
			case ((_unit getreldir _pos) < 202.5 && {(_unit getreldir _pos) > 157.5}): {_unit playactionnow (_anims select 3)};
			case ((_unit getreldir _pos) < 157.5 && {(_unit getreldir _pos) > 112.5}): {_unit playactionnow (_anims select 4)};
			case ((_unit getreldir _pos) < 247.5 && {(_unit getreldir _pos) > 202.5}): {_unit playactionnow (_anims select 5)};
			case ((_unit getreldir _pos) < 112.5 && {(_unit getreldir _pos) > 67.5}): {_unit playactionnow (_anims select 6)};
			case ((_unit getreldir _pos) < 292.5 && {(_unit getreldir _pos) > 247.5}): {_unit playactionnow (_anims select 7)};
		};
	} else {
		_unit playactionnow "stop";
		_unit setVelocity [0, 0, 0];
	};
	
	// Stuck detection - improved with path finding
	if ((time - _starttime) % 1 > 0.5) then {
		if (("run" in animationstate _unit OR "evas" in animationstate _unit) && {((vectorMagnitude (velocityModelSpace _unit)) < 1)}) then {
			_unit playactionnow "stop";
			_unit setVelocity [0, 0, 0];

			sleep 0.2;
			// Find a clear path around the obstacle
			if (!isNull _target) then {
				private _clearPath = [_unit, _pos, _target] call _fnc_findClearPath;
				if !(_clearPath isEqualTo [0,0,0]) then {
					_pos = _clearPath;
				} else {
					// Last resort: try random flanking with path check
					private _flankDir = selectRandom [90, -90];
					private _flankDist = 8 + random 5;
					{
						private _testPos = _unit getPos [_flankDist, (_unit getDir _target) + _flankDir + _x];
						if ([_unit, _testPos] call _fnc_isPathClear) exitWith {
							_pos = _testPos;
						};
					} forEach [0, 20, -20, 40, -40];
				};
			};
		};
	};

	sleep 0.05;
};
