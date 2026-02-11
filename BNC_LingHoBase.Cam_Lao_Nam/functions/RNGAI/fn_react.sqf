//RNG AI by Toksa - Optimized for MP
// Modified: More aggressive AI reaction - push instead of hide
params ["_unit", "_firer"];

// Only run where AI is local
if (!local _unit) exitWith {};

private _range = missionnamespace getvariable ["RNG_range",30];

if (!(_unit getvariable ["RNG_incombat",false]) && {vehicle _unit == _unit && {!(lifestate _unit == "INCAPACITATED") && {(_unit checkAIFeature "PATH") && (_unit checkAIFeature "MOVE") && !(isplayer (_unit getvariable ["bis_fnc_moduleremotecontrol_owner",objNull]))}}}) then {
	private _alltargets = _unit targets [true, _range];
	private _cooldown = _unit getvariable ["RNG_cooldown", (time - 1)];
	
	if (count _alltargets > 0) then {
		// === VCOM/RNG HANDOFF: Pause VCOM when RNG engages ===
		private _grp = group _unit;
		
		if (!(_grp getVariable ["RNG_vcom_paused", false])) then {
			_grp setVariable ["Vcm_Disable", true];
			_grp setVariable ["RNG_vcom_paused", true];
		};
		
		private _suppression = getSuppression _unit;
		private _firerDist = if (!isNull _firer) then {_firer distance _unit} else {999};
		// Check if any enemies are in buildings that need clearing
		private _buildingClearNeeded = false;
		private _buildingEnemy = objNull;
		private _debug = missionNamespace getVariable ["RNG_debug", false];
		{
			private _enemy = _x;
			private _nearBuildings = nearestObjects [_enemy, ["House", "Building"], 25, true];
			if (count _nearBuildings > 0) then {
				if (_debug) then {diag_log format["[RNG_react] Found %1 buildings near enemy %2", count _nearBuildings, _enemy];};
				{
					private _building = _x;
					private _buildingPositions = [_building] call BIS_fnc_buildingPositions;
					// Only clear building if it has usable positions and enemy is confirmed inside
					if (count _buildingPositions > 3) then {
						private _enemyPos = getPosATL _enemy;
						private _bounds = 3 boundingBox _building;
						if (_enemyPos inArea [(getPosATL _building), ((_bounds#1)#0), ((_bounds#1)#1), (getDir _building), true]) then {
							// Enemy confirmed inside building bounds
							_buildingClearNeeded = true;
							_buildingEnemy = _enemy;
							if (_debug) then {systemChat format["[REACT] BUILDING DETECTED: Enemy %1 is INSIDE building", name _enemy];};
						};
					};
				} forEach _nearBuildings;
			};
			if (_buildingClearNeeded) exitWith {};
		} forEach _alltargets;

		// If building clearing is needed, trigger it instead of normal RNG
		if (_buildingClearNeeded && {!(_grp getVariable ["RNG_building_clear", false])} && {missionNamespace getVariable ["RNG_building_clearing", true]} && {_unit distance _buildingEnemy <= 20}) then {
			if (_debug) then {systemChat format["[REACT] Building clear triggered for %1", groupId _grp];};
			[_grp, _buildingEnemy] spawn RNG_fnc_clearBuilding;
		} else {
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
				// AGGRESSIVE: Mostly combat, rarely cover
				if (random 1 < 0.1) then {
					// 10% chance cover push
					[_unit, _firer] spawn RNG_fnc_cover;
				} else {
					// 90% standard combat - dodge and fight
					[_unit, _firer] spawn RNG_fnc_combat;
				};
			};
				
			if (!isNull _firer) then {
				_unit setvariable ["RNG_target", _firer];
			};
		};
	};
};