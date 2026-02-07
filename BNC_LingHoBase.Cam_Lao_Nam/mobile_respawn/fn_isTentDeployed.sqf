/**
    File: mobile_respawn\fn_isTentDeployed.sqf
    Author: TylenolVIP
    
    Description:
        Checks if a vehicle's tent is deployed.
    
    Parameter(s):
        0: OBJECT - Vehicle to check
    
    Returns:
        BOOL - True if tent is deployed, false otherwise
    
    Example:
        private _deployed = [mobile_respawn] call MRS_fnc_isTentDeployed;
*/

params ["_vehicle"];

if (isNull _vehicle) exitWith { false };

// hide_tent animation: 0 = deployed, 1 = stowed (hidden)
(_vehicle animationPhase "hide_tent") == 0
