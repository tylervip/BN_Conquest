/*
Description:
	Actions for key (Vanilla version - No CBA/ACE required)

Parameters:
	None

Return:
	<BOOLEAN>
	True if correct key pressed

Example:
	call LEON_COD_fnc_onKeyDown;

Author: leonz2020
Modified: Removed CBA/ACE dependencies for vanilla Arma 3
*/

_handler = false;
if ([player] call LEON_COD_fnc_isUnitAwake) then {
	// If player already has a grenade picked up, throw it
	if (!isNull (player getVariable ["LEON_COD_pickedGrenade", objNull])) then {
		[] spawn LEON_COD_fnc_throwGrenade;
		_handler = true;
	};
};
_handler
