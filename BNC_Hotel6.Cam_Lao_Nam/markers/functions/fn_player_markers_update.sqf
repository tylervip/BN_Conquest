/**
	File: 	fn_player_markers_update.sqf 
	Author: Adabou + TylenolVIP

	Public: yoink

	Description:
		updates the markers 
	
	Parameter(s):
		- none 
	
	Returns:
		- nothing 

	Example(s):
		call map_fnc_player_markers_update
*/

{
	private _unitMarker = format ["player_marker_%1", getPlayerUID _x];
	_unitMarker setMarkerPosLocal getPos _x;
	_unitMarker setMarkerDirLocal getDir _x;
} forEach allPlayers;

//private _ai_units = [];
//_ai_units = allUnits select {!(isPlayer _x)}; //exclude Players
{
	private _ai_Marker = format ["ai_marker_%1", str _x];
	_ai_Marker setMarkerPosLocal getPos _x;
	_ai_Marker setMarkerDirLocal getDir _x;
} forEach markers_ai_units;