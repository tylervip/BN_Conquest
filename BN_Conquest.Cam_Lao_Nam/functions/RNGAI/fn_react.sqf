//RNG AI by Toksa - Optimized for MP
params ["_unit", "_firer"];

// Only run where AI is local
if (!local _unit) exitWith {};

private _range = missionnamespace getvariable ["RNG_range",30];
if ((missionnamespace getvariable ["RNG_playergroup",true]) && {isPlayer (leader _unit)}) exitWith {};

if (!(_unit getvariable ["RNG_incombat",false]) && {vehicle _unit == _unit && {!(lifestate _unit == "INCAPACITATED") && {(_unit checkAIFeature "PATH") && (_unit checkAIFeature "MOVE") && !(isplayer (_unit getvariable ["bis_fnc_moduleremotecontrol_owner",objNull]))}}}) then {
	private _alltargets = _unit targets [true, _range];
	private _cooldown = _unit getvariable ["RNG_cooldown", (time - 1)];
	
	if (count _alltargets > 0) then {
		if ((behaviour _unit == "SAFE" OR behaviour _unit == "AWARE" OR count _alltargets == 0 OR _firer distance _unit > 100 OR vehicle _firer iskindof "Tank") && !(side _firer == side _unit) && time > _cooldown && getsuppression _unit > 0.5) then {
			[_unit, _firer] spawn RNG_fnc_cover;
		} else {
			[_unit, _firer] spawn RNG_fnc_combat;
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