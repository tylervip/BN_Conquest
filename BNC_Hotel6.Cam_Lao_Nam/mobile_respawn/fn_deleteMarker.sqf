/**
    File: mobile_respawn\fn_deleteMarker.sqf
    Author: TylenolVIP
    
    Description:
        Deletes a mobile respawn marker and removes it from tracking.
    
    Parameter(s):
        0: STRING - Marker name
    
    Returns:
        Nothing
    
    Example:
        ["marker_mobile_blu"] call MRS_fnc_deleteMarker;
*/

params ["_markerName"];

deleteMarkerLocal _markerName;

private _idx = MRS_markers find _markerName;
if (_idx >= 0) then {
    MRS_markers deleteAt _idx;
};
