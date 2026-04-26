/**
    File: mobile_respawn\fn_getVehicleForSide.sqf
    Author: TylenolVIP
    
    Description:
        Gets the mobile respawn vehicle for a given side.
    
    Parameter(s):
        0: SIDE - Side to get vehicle for
    
    Returns:
        OBJECT - Vehicle, or objNull if not found
    
    Example:
        private _vehicle = [west] call MRS_fnc_getVehicleForSide;
*/

params ["_side"];

private _vehicle = objNull;

if (isNil "MRS_vehicles") exitWith { objNull };

{
    _x params ["_veh", "_marker", "_vehSide"];
    if (_vehSide == _side) exitWith {
        _vehicle = _veh;
    };
} forEach MRS_vehicles;

_vehicle
