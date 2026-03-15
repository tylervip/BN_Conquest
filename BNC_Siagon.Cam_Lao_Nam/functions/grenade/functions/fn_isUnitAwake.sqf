/*
Description:
	Check if unit is awake (alive and not incapacitated)
	Vanilla version - No ACE required

Parameters:
	<OBJECT> - The unit to check

Return:
    <BOOLEAN> - True if unit is awake

Example:
	[_unit] call LEON_COD_fnc_isUnitAwake;

Author: leonz2020
Modified: Removed ACE dependencies for vanilla Arma 3
*/
params ["_unit"];

// Returns true if unit is alive and NOT incapacitated/unconscious
!(!alive _unit || (lifeState _unit == "INCAPACITATED" && incapacitatedState _unit == "UNCONSCIOUS"))