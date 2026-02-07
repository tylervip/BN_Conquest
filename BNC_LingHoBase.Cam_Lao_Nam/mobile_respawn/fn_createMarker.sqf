/**
    File: mobile_respawn\fn_createMarker.sqf
    Author: TylenolVIP
    
    Description:
        Creates a marker for a mobile respawn vehicle.
    
    Parameter(s):
        0: OBJECT - Vehicle
        1: STRING - Marker name
        2: SIDE   - Side (west/east)
    
    Returns:
        STRING - Created marker name, or "" if failed
    
    Example:
        [mobile_respawn, "marker_mobile_blu", west] call MRS_fnc_createMarker;
*/

params ["_vehicle", "_markerName", "_side"];

// Validation
if (side player != _side) exitWith { "" };
if (isNull _vehicle) exitWith { "" };

// Create marker if it doesn't exist
if (markerShape _markerName == "") then {
    createMarkerLocal [_markerName, getPos _vehicle];
};

// Configure marker
_markerName setMarkerShapeLocal "ICON";
_markerName setMarkerTypeLocal "loc_Truck";
_markerName setMarkerSizeLocal [1, 1];
_markerName setMarkerTextLocal "Mobile Respawn";
_markerName setMarkerColorLocal (switch (_side) do {
    case west: { "ColorWEST" };
    case east: { "ColorEAST" };
    default { "ColorUNKNOWN" };
});

// Set visibility based on tent state (hide_tent: 0 = deployed, 1 = stowed)
private _tentDeployed = (_vehicle animationPhase "hide_tent") == 0;
_markerName setMarkerAlphaLocal ([0, 1] select _tentDeployed);

// Track marker
MRS_markers pushBackUnique _markerName;

// Store reference on vehicle
_vehicle setVariable ["MRS_markerName", _markerName];

_markerName
