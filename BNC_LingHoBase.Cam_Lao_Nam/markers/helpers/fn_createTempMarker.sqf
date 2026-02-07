// File: markers/functions/helpers/fn_createTempMarker.sqf
// Tag: map_fnc_

params ["_markerName", "_position", "_markerType", "_markerColor"];

createMarkerLocal [_markerName, _position];
_markerName setMarkerTypeLocal _markerType;
_markerName setMarkerColorLocal _markerColor;
_markerName setMarkerAlphaLocal 1;