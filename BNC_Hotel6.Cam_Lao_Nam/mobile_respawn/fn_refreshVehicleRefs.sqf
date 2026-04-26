/**
    File: mobile_respawn\fn_refreshVehicleRefs.sqf
    Author: TylenolVIP

    Description:
        Rebuilds local vehicle references from missionNamespace variables.
        This keeps client systems synced after server-side vehicle respawns.
*/

if (!hasInterface) exitWith {};
if (isNil "MRS_vehicleDefs") exitWith {};

private _updated = [];

{
    _x params ["_varName", "_markerName", "_side"];

    private _vehicle = missionNamespace getVariable [_varName, objNull];
    _updated pushBack [_vehicle, _markerName, _side, _varName];

    if (!isNull _vehicle) then {
        [_vehicle] call MRS_fnc_addVehicleActions;
    };
} forEach MRS_vehicleDefs;

MRS_vehicles = _updated;
