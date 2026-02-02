/*
Description:
	Add Vanilla keybind (No CBA/ACE required)
	
	Uses the default "throw" key (usually G) with modifiers:
	- G: Throw picked up grenade
	- Shift+G: Pick up a nearby grenade

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
	// Check if the throw key is pressed (default: G)
	if ((_this select 1) in actionKeys "throw") then {
		_shift = (_this select 2);  // Shift modifier
		
		if (_shift) then {
			// Shift+G: Pick up a nearby grenade and throw it after (unless it's a smoke)
			// Check if within 3m of a grenade
			if ([player] call LEON_COD_fnc_isUnitAwake && count LEON_COD_PickableGrenades > 0) then {
				private _grenadeObj = LEON_COD_PickableGrenades select 0;
				private _grenadeType = typeOf _grenadeObj;
				
				if (player distance _grenadeObj <= 3) then {
					[_grenadeObj, _grenadeType, player] spawn {
						params ["_grenadeObj", "_grenadeType", "_unit"];
						
						[_unit, _grenadeObj] spawn LEON_COD_fnc_pickGrenade;
						sleep 0.6;  // Wait for pickup animation
						
						// Auto-throw if it contains "grenade" or "rdg2"
						private _isGrenade = ((_grenadeType find "grenade") >= 0) || ((_grenadeType find "rdg2") >= 0);
						
						if (_isGrenade) then {
							[] spawn LEON_COD_fnc_throwGrenade;
						} else {
						};
						// If it's not a hand grenade (smoke, etc), player must press G to throw
					};
					_handler = true;
				};
			};
		} else {
			// G: Throw grenade
			_handler = _this call LEON_COD_fnc_onKeyDown;
		};
	};
	_handler
}];
