/*
Description:
	Keybinding handler for grenade throwing
	Integrated with para_c keybinding system
	
Parameters:
	None (called by keybinding system)

Return:
	Boolean - true to consume the key event, false to allow other handlers

Example:
	call LEON_COD_fnc_handleThrowGrenade;

Author: leonz2020
Modified: Integrated with para_c keybinding system
*/

private _handled = false;

if ([player] call LEON_COD_fnc_isUnitAwake && count LEON_COD_PickableGrenades > 0) then {
	private _grenadeObj = LEON_COD_PickableGrenades select 0;
	private _grenadeType = typeOf _grenadeObj;
	
	if (player distance _grenadeObj <= 3) then {
		[_grenadeObj, _grenadeType, player] spawn {
			params ["_grenadeObj", "_grenadeType", "_unit"];
			
			[_unit, _grenadeObj] spawn LEON_COD_fnc_pickGrenade;
			sleep 0.6;  // Wait for pickup animation
			
			// Auto-throw all grenades
			[] spawn LEON_COD_fnc_throwGrenade;
		};
		_handled = true;
	} else {
		// Grenade too far, let default throw happen (if equipped)
		// For now, don't consume the key
		_handled = false;
	};
} else {
	// No nearby grenades, don't consume
	_handled = false;
};

_handled
