/*
Description:
	Check if unit is down (dead or incapacitated)
	Vanilla version - No ACE required

Parameters:
	<OBJECT> - The unit to check

Return:
    <BOOLEAN> - True if unit is down

Example:
	[_unit] call LEON_COD_fnc_isUnitDown;

Author: leonz2020
Modified: Removed ACE dependencies for vanilla Arma 3
*/
params ["_unit"];

// Returns true if unit is dead OR incapacitated/unconscious
(!alive _unit || (lifeState _unit == "INCAPACITATED" && incapacitatedState _unit == "UNCONSCIOUS"))