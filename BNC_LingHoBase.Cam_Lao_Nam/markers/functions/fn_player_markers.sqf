/**
	File: 	fn_player_markers.sqf 
	Author: Adabou + TylenolVIP

	Public: yoink

	Description:
		main script for player markers 
	
	Parameter(s):
		- none 
	
	Returns:
		- nothing 

	Example(s):
		call map_fnc_player_markers
 */
//TODO: Cases of person in vehicle && Enemy spotting
private _activePlayerMarkers = [];
private _activeAIMarkers = [];

private _playerMarker = format ["player_marker_%1", getPlayerUID player];
private _playerMarkerType = "loc_ViewTower";
_playerMarker setMarkerTypeLocal _playerMarkerType;

//Player Markers:
{
	private _otherUnit = _x;
	//checking if we do anything today
	private _unitSameSide = [player, _otherUnit] call map_fnc_check_side;
	if !(_unitSameSide) then { continue }; //if yes then#

	//guaranteed unique name for marker
	private _unitMarker = format ["player_marker_%1", getPlayerUID _otherUnit];

	private _markerType = "loc_ViewTower";

	//easy Way to check if Marker exists
	if (markerShape _unitMarker == "") then {
		createMarkerLocal [_unitMarker, [0,0,0]];
	};
	_unitMarker setMarkerTextLocal name _otherUnit;
	_unitMarker setMarkerShapeLocal "ICON";
	_unitMarker setMarkerTypeLocal _markerType;

	//track markers:
	_activePlayerMarkers pushBack _unitMarker;

	if (group _x == group player) then {
		_unitMarker setMarkerColorLocal "ColorGreen";
	} else {
		_unitMarker setMarkerColorLocal "ColorBLUFOR";
	};
	
}forEach allPlayers;

markers_ai_units = [];
markers_ai_units = allUnits select {!(isPlayer _x)}; //exclude Players
{
	private _ai_unit = _x;
	//check if same side
	private _unitSameSide = [player, _ai_unit] call map_fnc_check_side;
	if !(_unitSameSide) then { continue }; //if yes then#

	private _ai_Marker = format ["ai_marker_%1", str _x];
	private _markerType = "loc_ViewTower";

	if (markerShape _ai_Marker == "") then {
		createMarkerLocal [_ai_Marker, [0,0,0]];
	};
	_ai_Marker setMarkerShapeLocal "ICON";
	_ai_Marker setMarkerTypeLocal _markerType;

	//track markers:
	_activeAIMarkers pushBack _ai_Marker;

	if (group _x == group player) then {
		_ai_Marker setMarkerColorLocal "ColorGreen";
	} else {
		_ai_Marker setMarkerColorLocal "ColorBLUFOR";
	};

}forEach markers_ai_units;


//pruning inactive markers 
private _inactiveMarkers = cqs_map_markers - (_activePlayerMarkers + _activeAIMarkers);
{
	deleteMarker _x;
}forEach _inactiveMarkers;

cqs_map_markers = _activePlayerMarkers + _activeAIMarkers;

