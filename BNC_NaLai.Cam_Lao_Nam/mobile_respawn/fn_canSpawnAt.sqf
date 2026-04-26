/**
    File: mobile_respawn\fn_canSpawnAt.sqf
    Author: TylenolVIP
    
    Description:
        Checks if a player can spawn at a mobile respawn vehicle.
    
    Parameter(s):
        0: OBJECT - Vehicle to check
        1: SIDE   - Player's side
    
    Returns:
        BOOL - True if spawn is allowed
    
    Example:
        private _canSpawn = [mobile_respawn, west] call MRS_fnc_canSpawnAt;
*/

params ["_vehicle", "_side"];

// Basic checks
if (isNil {_vehicle}) exitWith { false };
if (isNull _vehicle) exitWith { false };
if (!alive _vehicle) exitWith { false };

// Get vehicle's side from config
private _vehicleSide = sideUnknown;
if (isNil "MRS_vehicles") exitWith { false };
{
    _x params ["_veh", "_marker", "_vehSide"];
    if (_veh == _vehicle) exitWith {
        _vehicleSide = _vehSide;
    };
} forEach MRS_vehicles;

// Side check
if (_side != _vehicleSide) exitWith { false };

// Tent must be deployed
if !([_vehicle] call MRS_fnc_isTentDeployed) exitWith { false };

true
