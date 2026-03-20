/*
Description:
	Initial for Grenade throwback (Vanilla version - No CBA/ACE required)

Parameters:
	None

Return:
	None

Example:
	None

Author: leonz2020
Modified: Removed CBA/ACE dependencies for vanilla Arma 3
*/
if (!hasInterface) exitWith {};

// Vanilla only - no ACE
LEON_COD_isACELoaded = false;

LEON_COD_PickableGrenades = [];
LEON_COD_LastThrownGrenade = objNull;  // Track the last grenade thrown

[] spawn {
	// Initialize the 3D icon system
	call LEON_COD_fnc_draw3DIcon;
	
	// Main loop - detect nearby grenades
	while {true} do {
		private _grenades = [];
		waitUntil {
			sleep 0.1; 
			_grenades = (nearestObjects [player, ["GrenadeHand", "IRStrobeBase"], 3]);
			vehicle player == player && _grenades findIf {isNull (attachedTo _x) && vectorMagnitude velocity _x <= 10} != -1
		};
		
		if ([player] call LEON_COD_fnc_isUnitAwake) then {
			LEON_COD_PickableGrenades = _grenades select { 
				isNull (attachedTo _x) && 
				vectorMagnitude velocity _x <= 5 && 
				!lineIntersects [eyePos player, getPosASLVisual _x vectorAdd [0,0,(sizeOf (typeOf _x)) / 2], player, _x]
			};
		};
	};
};