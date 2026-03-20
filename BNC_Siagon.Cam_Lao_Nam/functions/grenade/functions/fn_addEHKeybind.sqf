/*
Description:
	Add Vanilla keybind (No CBA/ACE required)
	
	Uses the default "throw" key (usually G):
	- G: Pick up nearby grenade and throw it, or throw equipped grenade

Parameters:
	None

Return:
	None

Example:
	call LEON_COD_fnc_addEHKeybind;

Author: leonz2020
Modified: Removed CBA/ACE dependencies for vanilla Arma 3
*/

if (!isNil "LEON_COD_keyDownID") exitWith {};

LEON_COD_keyDownID = (findDisplay 46) displayAddEventHandler ["KeyDown", {
	_handler = false;
	_keyCode = _this select 1;
	
	// Key code 22 is G
	if (_keyCode == 22) then {
		// G: Pick up nearby grenade and throw it, or throw equipped grenade
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
				_handler = true;
			} else {
				// Grenade too far, throw equipped grenade instead
				_handler = _this call LEON_COD_fnc_onKeyDown;
			};
		} else {
			// No nearby grenades, throw equipped grenade
			_handler = _this call LEON_COD_fnc_onKeyDown;
		};
	};
	_handler
}];
