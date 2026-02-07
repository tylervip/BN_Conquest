/*
Description:
	Pick up grenade (Vanilla version - No CBA/ACE required)

Parameters:
	<OBJECT> - The unit which gonna pick up grenade
    <OBJECT> - The grenade

Return:
    None

Example:
	[_unit, _grenade] call LEON_COD_fnc_pickGrenade;

Author: leonz2020
Modified: Removed CBA/ACE dependencies for vanilla Arma 3
*/

params ["_unit", "_grenade"];

// Vanilla grenade pickup - attach to player's hand
[_grenade, clientOwner] remoteExec ["setOwner", 0];
_grenade attachTo [_unit, [-0.06,-0.04,0.045], "righthand", true];
_unit setVariable ["LEON_COD_pickedGrenade", _grenade];

// Handle if player dies while holding grenade
if (isNil "LEON_COD_killedEHID") then {
	LEON_COD_killedEHID = _unit addEventHandler ["Killed", {
		private _unit = _this select 0;
		private _grenade = _unit getVariable ["LEON_COD_pickedGrenade", objNull];
		if (!isNull _grenade) then {
			detach _grenade;
			_unit setVariable ["LEON_COD_pickedGrenade", objNull];
		};
	}];
};
