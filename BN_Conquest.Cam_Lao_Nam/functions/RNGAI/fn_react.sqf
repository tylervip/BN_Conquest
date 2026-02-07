//RNG AI by Toksa - Optimized for MP
// Modified: More aggressive AI reaction - push instead of hide
params ["_unit", "_firer"];

// Only run where AI is local
if (!local _unit) exitWith {};

private _range = missionnamespace getvariable ["RNG_range",30];
if ((missionnamespace getvariable ["RNG_playergroup",true]) && {isPlayer (leader _unit)}) exitWith {};

if (!(_unit getvariable ["RNG_incombat",false]) && {vehicle _unit == _unit && {!(lifestate _unit == "INCAPACITATED") && {(_unit checkAIFeature "PATH") && (_unit checkAIFeature "MOVE") && !(isplayer (_unit getvariable ["bis_fnc_moduleremotecontrol_owner",objNull]))}}}) then {
	private _alltargets = _unit targets [true, _range];
	private _cooldown = _unit getvariable ["RNG_cooldown", (time - 1)];
	
	if (count _alltargets > 0) then {
		private _suppression = getSuppression _unit;
		private _firerDist = if (!isNull _firer) then {_firer distance _unit} else {999};
		
		// Determine behavior: aggressive push vs defensive cover
		// Only go defensive if: very suppressed AND target is far OR vehicle threat
		private _goDefensive = (
			(behaviour _unit == "SAFE" OR behaviour _unit == "AWARE") && 
			(_suppression > 0.8) && 
			(_firerDist > 80)
		) OR (
			!isNull _firer && {vehicle _firer iskindof "Tank"}
		);
		
		if (_goDefensive && time > _cooldown && !(side _firer == side _unit)) then {
			// Defensive cover only against heavy suppression or vehicles
			[_unit, _firer] spawn RNG_fnc_cover;
		} else {
			// AGGRESSIVE: Push with cover
			// Higher chance to use aggressive cover-push instead of pure combat
			if (random 1 < 0.6) then {
				// Aggressive cover push - advance while using cover
				[_unit, _firer] spawn RNG_fnc_cover;
			} else {
				// Standard combat behavior
				[_unit, _firer] spawn RNG_fnc_combat;
			};
			
			if (!isNull _firer) then {
				_unit setvariable ["RNG_target", _firer];
			};
			// Optimized: Reduced radius and limited iterations
			private _friendly = _unit nearEntities ["Man", 50];
			private _unitTargets = _unit targets [true, 50];
			{
				if (side _x == side _unit && {count _unitTargets > 0}) then {
					_x reveal [_unitTargets select 0, 1.5];
				};
			} forEach (_friendly select [0, 5]); // Limit to 5 friendlies max
		};
	};
};