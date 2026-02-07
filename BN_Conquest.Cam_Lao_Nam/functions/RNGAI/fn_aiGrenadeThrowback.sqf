// fn_aiGrenadeThrowback.sqf
// AI Grenade Throwback System
// Gives AI a chance to pick up and throw back enemy grenades
// Called per-unit from fn_unit_init.sqf
//
// Uses RNG_AI_GRENADE_CHANCE from RNG_init.sqf (0-100, default 35)
// Higher skill AI have better chance and react faster

params ["_unit"];

if (!local _unit) exitWith {};
if (isPlayer _unit) exitWith {};

// Monitor loop - runs while unit is alive
[_unit] spawn {
	params ["_unit"];
	
	private _grenadeChance = missionNamespace getVariable ["RNG_AI_GRENADE_CHANCE", 35];
	
	while {alive _unit && {!isPlayer _unit}} do {
		sleep (0.5 + random 0.5);
		
		if (!alive _unit || isPlayer _unit || vehicle _unit != _unit) then { continue; };
		if (lifeState _unit == "INCAPACITATED") then { continue; };
		
		// Check for nearby grenades (within 8m detection radius)
		private _nearGrenades = nearestObjects [_unit, ["GrenadeHand"], 8];
		
		// Filter: only unattached, still moving grenades that aren't from friendlies
		private _threats = _nearGrenades select {
			isNull (attachedTo _x) && 
			alive _x &&
			_unit distance _x < 8
		};
		
		if (count _threats == 0) then { continue; };
		
		// Found a grenade! Check if AI reacts
		private _grenade = _threats select 0;
		private _dist = _unit distance _grenade;
		
		// Skill-based chance modifier: better AI react more often
		private _skill = _unit skillFinal "general";
		private _finalChance = _grenadeChance * (0.5 + _skill * 0.5); // 50-100% of base chance
		
		// Distance modifier: closer grenades are easier to notice
		private _distMod = linearConversion [1, 8, _dist, 1.2, 0.5, true];
		_finalChance = _finalChance * _distMod;
		
		// Already in combat? More alert = better reaction
		if (_unit getVariable ["RNG_incombat", false]) then {
			_finalChance = _finalChance * 1.3;
		};
		
		// Roll the dice
		if (random 100 > _finalChance) then {
			// Failed the check - AI doesn't react to throwback, but still tries to dodge
			[_unit, _grenade] spawn {
				params ["_unit", "_grenade"];
				if (!alive _unit) exitWith {};
				// Dodge away from grenade
				private _awayDir = _grenade getDir _unit;
				private _dodgePos = _unit getPos [6 + random 4, _awayDir];
				_unit doMove _dodgePos;
				_unit setUnitPos "DOWN";
				sleep 3;
				if (alive _unit) then { _unit setUnitPos "AUTO"; };
			};
			continue;
		};
		
		// === AI THROWS BACK THE GRENADE ===
		
		// Reaction delay based on skill (better AI react faster)
		private _reactionTime = linearConversion [0.3, 1.0, _skill, 1.2, 0.3, true];
		sleep _reactionTime;
		
		// Grenade might have exploded during reaction time
		if (!alive _grenade || isNull _grenade) then { continue; };
		// Grenade might have moved too far
		if (_unit distance _grenade > 5) then { continue; };
		// Unit might have died
		if (!alive _unit) then { continue; };
		
		// Disable AI movement temporarily
		private _wasInCombat = _unit getVariable ["RNG_incombat", false];
		
		_unit disableAI "MOVE";
		_unit disableAI "PATH";
		
		// Face the grenade
		_unit doWatch (getPosATL _grenade);
		sleep 0.2;
		
		// "Pick up" - attach grenade to unit's hand
		_grenade attachTo [_unit, [-0.06, -0.04, 0.045], "righthand", true];
		_unit setVariable ["RNG_holdingGrenade", true];
		
		// Brief hold then throw
		sleep (0.2 + random 0.3);
		
		if (!alive _unit || isNull _grenade) exitWith {
			_unit enableAI "MOVE";
			_unit enableAI "PATH";
			_unit setVariable ["RNG_holdingGrenade", false];
		};
		
		// Determine throw direction - toward nearest known enemy, or just away
		private _throwDir = direction _unit;
		private _throwTarget = objNull;
		
		private _targets = _unit targets [true, 150];
		if (count _targets > 0) then {
			_throwTarget = _targets select 0;
			_throwDir = _unit getDir _throwTarget;
		};
		
		// Detach and throw
		detach _grenade;
		_unit setVariable ["RNG_holdingGrenade", false];
		
		// Calculate throw velocity toward target/direction
		private _throwSpeed = 14 + random 4; // Throw force
		private _throwUp = 5 + random 3;     // Upward arc
		
		// Add some inaccuracy based on skill (lower skill = less accurate throw)
		private _accuracy = linearConversion [0.3, 1.0, _skill, 15, 3, true]; // degrees of error
		_throwDir = _throwDir + (random _accuracy) - (random _accuracy);
		
		_grenade setVelocity [
			sin(_throwDir) * _throwSpeed,
			cos(_throwDir) * _throwSpeed,
			_throwUp
		];
		
		// Re-enable AI
		_unit enableAI "MOVE";
		_unit enableAI "PATH";
		
		// Log for debug
		if (missionNamespace getVariable ["VCM_Debug", false]) then {
			diag_log format ["RNG_AI: %1 threw back a grenade!", _unit];
		};
		
		// Short cooldown before checking again
		sleep 3;
	};
};
