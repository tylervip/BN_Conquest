//RNG AI by Toksa - Optimized for MP
// Added: building/wall avoidance
params ["_unit", "_firer"];

// Only run where AI is local
if (!local _unit) exitWith {};

private _disabled = _unit getvariable ["RNG_disabled", false];
private _off = missionnamespace getvariable ["RNG_off", false];
if (isplayer _unit or _disabled or _off) exitWith {};

_unit setvariable ["RNG_incombat", true];
[_unit] spawn RNG_fnc_turning;

private _exit = false;
private _suppressed = false;
private _types = ["AGR","RND","CVR","DFS"];
private _weight = [1.5,0.8,1.0,0.8];
private _type = _types selectRandomWeighted _weight;
private _suppression = 0;
private _pos = [0,0,0];

_unit disableai "PATH";
_unit disableai "MOVE";
_unit disableai "COVER";
_unit disableai "FSM";
_unit disableai "AIMINGERROR";

private _target = objNull;
private _anims = RNG_ANIM_Tact;
private _line = [];
private _targetpos = [0,0,0];
private _infront = objNull;
private _weapon = currentweapon _unit;
private _starttime = time;
private _cancrouch = true;
private _targettimeout = time;
private _dodge = false;
private _skill = ((1 - (_unit skillfinal "general")) * 5);
private _lastObjectCheck = 0;
private _objects = [];
private _lastAimedAtCheck = 0;
private _isBeingAimedAt = false;
private _lastDodgeTime = 0;

// ============= AIMED-AT DETECTION =============
private _fnc_isBeingAimedAt = {
	params ["_unit"];
	private _aimedAt = false;
	private _nearEnemies = _unit targets [true, 200];
	{
		if (alive _x && {side _x != side _unit}) then {
			private _aimDir = _x getreldir getpos _unit;
			if (_aimDir < 12 OR _aimDir > 348) then {
				if (([_x, "FIRE", _unit] checkVisibility [eyepos _x, aimpos _unit]) > 0.2) then {
					_aimedAt = true;
				};
			};
		};
		if (_aimedAt) exitWith {};
	} forEach _nearEnemies;
	_aimedAt
};

// ============= PATH CLEARANCE CHECK =============
private _fnc_isPathClear = {
	params ["_unit", "_targetPos"];
	private _unitPos = eyePos _unit;
	private _targetPosASL = if (count _targetPos == 3) then {
		ATLToASL [_targetPos select 0, _targetPos select 1, (_targetPos select 2) + 1]
	} else {
		_unitPos
	};
	private _intersects = lineIntersectsSurfaces [_unitPos, _targetPosASL, _unit, objNull, true, 1, "GEOM", "NONE"];
	(count _intersects == 0)
};

// ============= FIND CLEAR PATH AROUND OBSTACLE =============
private _fnc_findClearPath = {
	params ["_unit", "_blockedPos", "_target"];
	private _clearPos = [0,0,0];
	private _unitDir = _unit getDir _blockedPos;
	private _angles = [45, -45, 90, -90, 30, -30, 60, -60];
	{
		private _testAngle = _unitDir + _x;
		private _testPos = _unit getPos [8 + random 5, _testAngle];
		if ([_unit, _testPos] call _fnc_isPathClear) exitWith {
			_clearPos = _testPos;
		};
	} forEach _angles;
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

if (!isNull _firer && {([_unit, "FIRE", _firer] checkVisibility [aimpos _unit, aimpos _firer]) > 0}) then {_target = _firer};

if (!(unitPos _unit == "AUTO")) then {_cancrouch = false;};
sleep (random 0.5);

while {alive _unit} do {
	
	if (getSuppression _unit > 0.9 && {_target distance _unit > 30}) then {_cooldown=_unit getvariable ["RNG_cooldown",(time -1)]; if (time > _cooldown) then {_suppressed=true;_exit=true};};
	if (!alive _unit OR _exit OR !(vehicle _unit == _unit) OR (lifestate _unit =="INCAPACITATED") OR isplayer _unit OR (isplayer (_unit getvariable ["bis_fnc_moduleremotecontrol_owner",objNull]))) exitwith {
		[_unit,_suppressed,_cancrouch] spawn {
			_unit = _this select 0;
			_suppressed = _this select 1;
			_cancrouch=_this select 2;
			_unit playactionnow "STOP";
			dostop _unit;
			if (_suppressed) then {
			_unit setvariable ["RNG_incombat",false];
			[_unit,objNull] spawn RNG_fnc_cover;
			} else {
				dostop _unit;
				_unit domove getpos _unit;
				_unit enableai "PATH";
				_unit enableai "MOVE";
				_unit enableai "FSM";
				_unit enableai "COVER";
				_unit dofollow leader _unit;
				_unit enableai "AIMINGERROR";
				if (_cancrouch) then {_unit setunitpos "AUTO"};
				_unit setvariable ["RNG_incombat",false];
				// === VCOM/RNG HANDOFF: Resume VCOM if no other unit in group is in RNG combat ===

				sleep 0.1;
			};
		};
	};
	if (!(currentweapon _unit == _weapon)) then {sleep 2;_weapon = currentweapon _unit};
	if ((time - _starttime) % 5 > 4) then {
		
		_suppression=getsuppression _unit;
		if (getsuppression _unit == -1) then {
		_suppression=0;
		} else {
			_weight set [4,_suppression];
		};
		_type=_types selectRandomWeighted _weight;
	};
	if ((time - _starttime) % 30 > 29) then {
		private _sortedtargets=[];
		private _alltargets=_unit targets [true,300];
		_sortedtargets = [_alltargets,[],{_unit distance _x},"ASCEND",{([_unit, "FIRE",_x] checkVisibility [aimpos _unit, aimpos _x]) > 0}] call BIS_fnc_sortBy;
		sleep 0.1;
		if (!isnil "_sortedtargets" && {count _sortedtargets==0}) then {
			_exit=true;
		};
		
	};
	if ((time - _starttime) % 1 > 0.5) then {
		private _alltargets=_unit targets [true,300];
		private _targets = [_alltargets,[],{_unit distance _x},"ASCEND",{([_unit, "FIRE",_x] checkVisibility [aimpos _unit, aimpos _x]) > 0}] call BIS_fnc_sortBy;
		sleep 0.02;
		if (count _targets > 0) then {
			_target=_targets select 0;
			_unit dotarget _target;
			_unit dowatch _target;
			_unit lookat _target;
		_targettimeout=time + 5;
		} else {
			if ((time > _targettimeout) OR !alive _target) then {
				_target=objNull;
			};
		};
	};
	
	if ((time - _starttime) % 4 > 3.5) then {
		if (_cancrouch) then {
			// Check if any enemy is aiming at us
			private _beingAimedAt = [_unit] call _fnc_isBeingAimedAt;
			private _stance = if (_beingAimedAt) then {
				// Being aimed at - crouch but never prone
				"MIDDLE"
			} else {
				// Not aimed at - mostly stand, sometimes crouch
				["UP","UP","MIDDLE"] selectRandomWeighted [1,1,0.4]
			};
			if (!_beingAimedAt && {!isNull _target} && {_target distance2D _unit > 150}) then {_stance=["UP","MIDDLE"] selectRandomWeighted [1,0.5];};
			if (!((unitpos _unit) == _stance)) then {
			_unit playactionnow _stance;
			};
			switch (true) do {
				case (_stance=="MIDDLE") : {_unit setunitpos "MIDDLE";};
				case (_stance=="UP") : {_unit setunitpos "UP";};
				default {};
			};
		};
	};
	// Optimized: Cache object search every 2 seconds instead of every frame
	if (time > _lastObjectCheck) then {
		_lastObjectCheck = time + 2;
		private _objectsDyn = nearestObjects [_unit, ["Wall","fence","Strategic","NonStrategic","house","Land"], 60];
		_objects = nearestTerrainObjects [_unit, ["Tree", "Bush","Wall","fence","Rock","house","Static","Thing","Building"], 60];
		_objects append _objectsDyn;
	};
	if (count _objects > 0) then {
		_targetpos=[_objects,getpos _target] call BIS_fnc_nearestPosition;
		switch (true) do {
			case (_type=="AGR"): {_targetpos=[_objects,getpos _target] call BIS_fnc_nearestPosition;};
			case (_type=="RND"): {if (count _objects > 2) then {_targetpos = _objects select 1;} else {_targetpos = _objects select 0;};};
			case (_type=="DFS"): {
				if (!isNull _target) then {
					private _sortedobjects= [_objects,[],{_unit distance _x},"ASCEND",{([_target, "FIRE",_x] checkVisibility [aimpos _target, getposasl _x]) < 1}] call BIS_fnc_sortBy;
					if (count _sortedobjects > 0) then {
						_targetpos=_sortedobjects select 0;
					};
					} else {_type=_types selectRandomWeighted _weight;};
			};
			case (_type=="CVR"): {	if (!isnull _target) then {
				private _sortedobjects= [_objects,[],{_unit distance _x},"ASCEND",{_target distance _x > _unit distance _x}] call BIS_fnc_sortBy;
				if (count _sortedobjects > 0) then {
					_targetpos=_sortedobjects select 0;
				};
				} else {
					_targetpos=[_objects,getpos _target] call BIS_fnc_nearestPosition;
				};};

		};
		if (typename _targetpos == "OBJECT") then {
		_line=lineIntersectsSurfaces [[(aimpos _unit) select 0,(aimpos _unit) select 1,((aimpos _unit) select 2) - 0.5], getposASL _targetpos, _unit, objNull, true, 1,"FIRE"];
		} else {
			_line=lineIntersectsSurfaces [[(aimpos _unit) select 0,(aimpos _unit) select 1,((aimpos _unit) select 2) - 0.5],_targetpos, _unit, objNull, true, 1,"FIRE"];
		};
		if (!((count _line) == 0)) then {
			_pos=(_line select 0) select 0; 
		};
		
		// ===== PATH CLEARANCE CHECK - Avoid walls/buildings =====
		if (!isNil "_pos" && {!(_pos isEqualTo [0,0,0])}) then {
			if (!([_unit, _pos] call _fnc_isPathClear)) then {
				private _clearPath = [_unit, _pos, _target] call _fnc_findClearPath;
				if !(_clearPath isEqualTo [0,0,0]) then {
					_pos = _clearPath;
				};
			};
		};
		
		////Leaning - Simplified to prevent snapping
		if ((time - _starttime) % 3 > 2.5 && {!isNull _target}) then {
			// Simple leaning without position resets
			if (([_unit, "VIEW",_target] checkVisibility [eyepos _unit, aimpos _target]) < 0.5) then {
				// If visibility is blocked, try a quick lean
				if (random 1 < 0.7) then { // 30% chance to lean
					_leanDir = selectRandom ["AdjustL", "AdjustR"];
					_unit playactionnow _leanDir;
					sleep 0.5;
					_unit playactionnow "AdjustF"; // Return to normal
				};
			};
		};
		
		_reldir=_unit getreldir getpos _target;
		if ((([_unit, "VIEW",_target] checkVisibility [eyepos _unit, aimpos _target]) > 0 OR ([_unit, "VIEW",_target] checkVisibility [aimpos _unit, eyepos _target]) > 0) && {!isnull _target}) then {
		_anims=RNG_ANIM_Tact;
		} else {	
			if ((time > (_targettimeout - 2)) OR !alive _target) then {
				_anims=RNG_ANIM_Run;
			};
		};
		
		///dodgin - check if any enemy is aiming at this unit
		
		_dodge=false;
		// Continuous aimed-at check (every 0.3s)
		if (time > _lastAimedAtCheck + 0.3) then {
			_lastAimedAtCheck = time;
			_isBeingAimedAt = [_unit] call _fnc_isBeingAimedAt;
			
			if (_isBeingAimedAt) then {
				_dodge = true;
				
				// Crouch when aimed at but never prone
				if (_cancrouch && {unitPos _unit != "MIDDLE"}) then {
					_unit playactionnow "Crouch";
					_unit setunitpos "MIDDLE";
				};
				
				// Use tactical movement so they can fire while dodging
				_anims = RNG_ANIM_Tact;
			} else {
				// Not aimed at - stand up for speed
				if (_cancrouch && {unitPos _unit == "MIDDLE"} && {getSuppression _unit < 0.3}) then {
					_unit playactionnow "Up";
					_unit setunitpos "UP";
				};
			};
		};
		
		// ===== FIRE WHILE DODGING =====
		// When moving out of the way, keep shooting at the target
		if (_dodge && {!isNull _target} && {alive _target}) then {
			private _reldir = _unit getreldir getpos _target;
			if ((_reldir < 30 OR _reldir > 330) && {([_unit, "FIRE", _target] checkVisibility [eyepos _unit, aimpos _target]) > 0.2}) then {
				if (!(unitCombatMode _unit == "BLUE") && {_unit ammo currentweapon _unit > 0}) then {
					for "_i" from 1 to (2 + floor random 4) do {
						[_unit, currentmuzzle _unit] call BIS_fnc_fire;
						sleep 0.03;
					};
				};
			};
		};
		if (isnil "_pos" OR {((_unit distance2D _pos) > 70)} OR _dodge) then {
			// When dodging from being aimed at, use tighter faster sidesteps
			private _dodgeDist = if (_dodge) then {8 + random 6} else {20};
			_leftpos=lineIntersectsSurfaces [aimPos _unit,(AGLtoASL (_unit getrelpos [_dodgeDist,270])), _unit, objNull, true, 1,"FIRE"];
			_rightpos=lineIntersectsSurfaces [aimPos _unit,(AGLtoASL (_unit getrelpos [_dodgeDist,90])), _unit, objNull, true, 1,"FIRE"];
			// Also try diagonal dodges when aimed at
			private _fwdLeftPos = if (_dodge) then {
				lineIntersectsSurfaces [aimPos _unit,(AGLtoASL (_unit getrelpos [_dodgeDist,315])), _unit, objNull, true, 1,"FIRE"]
			} else {[]};
			private _fwdRightPos = if (_dodge) then {
				lineIntersectsSurfaces [aimPos _unit,(AGLtoASL (_unit getrelpos [_dodgeDist,45])), _unit, objNull, true, 1,"FIRE"]
			} else {[]};
			private _hasLeft = count _leftpos > 0;
			private _hasRight = count _rightpos > 0;
			private _hasFwdLeft = count _fwdLeftPos > 0;
			private _hasFwdRight = count _fwdRightPos > 0;
			if (_hasLeft || _hasRight || _hasFwdLeft || _hasFwdRight) then {
				private _leftP = if (_hasLeft) then {(_leftpos select 0) select 0} else {[0,0,0]};
				private _rightP = if (_hasRight) then {(_rightpos select 0) select 0} else {[0,0,0]};
				private _fwdLP = if (_hasFwdLeft) then {(_fwdLeftPos select 0) select 0} else {[0,0,0]};
				private _fwdRP = if (_hasFwdRight) then {(_fwdRightPos select 0) select 0} else {[0,0,0]};
				if (_dodge) then {
					// When dodging, pick from all available directions randomly
					private _options = [];
					if (_hasLeft) then {_options pushBack _leftP};
					if (_hasRight) then {_options pushBack _rightP};
					if (_hasFwdLeft) then {_options pushBack _fwdLP};
					if (_hasFwdRight) then {_options pushBack _fwdRP};
					if (count _options > 0) then {
						_pos = selectRandom _options;
					};
				} else {
					switch (true) do {
						case (_hasLeft && _hasRight && {(_leftP distance2D _unit) > (_rightP distance2D _unit)}) : {_pos = _rightP;};
						case (_hasLeft && _hasRight && {(_leftP distance2D _unit) < (_rightP distance2D _unit)}) : {_pos = _leftP;};
						case (_hasLeft) : {_pos = _leftP;};
						case (_hasRight) : {_pos = _rightP;};
						default {};
					};
				};
			};
		};
		if (!isnil "_pos" && {((_unit distance2D _pos) < 70)}) then {
			
			///debug pos - ar1 setPosASL [_pos select 0,_pos select 1,(_pos select 2) + 2.5];
			switch (true) do {
				case ((_unit distance2D _pos)< (1.5 + (vectorMagnitude (velocityModelSpace _unit))*0.25)): {_unit playactionnow "stop";};
				case ((_unit getreldir _pos) < 67.5 && {(_unit getreldir _pos) > 22.5}): {_unit playactionnow (_anims select 0)};
				case ((_unit getreldir _pos) < 342.5 && {(_unit getreldir _pos) > 297.5}): {_unit playactionnow (_anims select 1);};
				case ((_unit getreldir _pos) < 22.5 OR (_unit getreldir _pos) > 342.5): {_unit playactionnow (_anims select 2);};
				case ((_unit getreldir _pos) < 202.5 && {(_unit getreldir _pos) > 157.5}): {_unit playactionnow (_anims select 3);};
				case ((_unit getreldir _pos) < 157.5 && {(_unit getreldir _pos) > 112.5}): {_unit playactionnow (_anims select 4);};
				case ((_unit getreldir _pos) < 247.5 && {(_unit getreldir _pos) > 202.5}): {_unit playactionnow (_anims select 5);};
				case ((_unit getreldir _pos) < 112.5 && {(_unit getreldir _pos) > 67.5}): {_unit playactionnow (_anims select 6);};
				case ((_unit getreldir _pos) < 292.5 && {(_unit getreldir _pos) > 247.5}): {_unit playactionnow (_anims select 7);};
				default {};
			};
			} else {
				_unit playactionnow "stop";
			};
			if ((time - _starttime) % 1 > 0.5) then {
				if (("tacs" in animationstate _unit OR "run" in animationstate _unit OR "evas" in animationstate _unit) && {((vectorMagnitude (velocityModelSpace _unit)) < 1.5)}) then {
					_unit playactionnow "stop";

					// Find clear path if stuck
					if (!isnil "_pos" && {!(_pos isEqualTo [0,0,0])}) then {
						if (!([_unit, _pos] call _fnc_isPathClear)) then {
							private _clearPath = [_unit, _pos, _target] call _fnc_findClearPath;
							if !(_clearPath isEqualTo [0,0,0]) then {
								_pos = _clearPath;
							};
						};
					};
					_type=_types selectRandomWeighted _weight;
				};
				if ((_unit ammo currentweapon _unit < 2) && {_cancrouch && {!("reload" in (gesturestate _unit))}}) then {
					// Crouch to reload but never go prone
					if (!((unitpos _unit) == "MIDDLE")) then {
						_unit playactionnow "MIDDLE";
					};
					_unit setunitpos "MIDDLE";
				};
			private _randomstop=random 15;
			// Don't randomly stop if being aimed at
			if (!_isBeingAimedAt && {_randomstop > (15 - _skill)}) then {_unit playactionnow "stop";sleep (_skill/10)};
			};
			if ((animationstate _unit == "amovpercmstpsraswrfldnon" OR animationstate _unit == "amovpknlmstpsraswrfldnon") && {((vectorMagnitude (velocityModelSpace _unit)) < 1)}) then {_unit playactionnow "stop";};
	_unit setvariable ["RNG_target", _target];
	} else {_exit=true};
	sleep 0.05;
};
