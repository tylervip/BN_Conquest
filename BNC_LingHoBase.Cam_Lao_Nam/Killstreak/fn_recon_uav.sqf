/*
	File: 		Killstreak\fn_recon_uav.sqf
	Author: 	Legend
	modified:	tylervip
	Description:
		Reveal enemy player markers for a period,
		then hide them for a pause, repeatedly,
		while the UAV helicopter is alive.
*/

params ["_caller"];
private _callerSide = side _caller;
private _markerType = "KIA";
private _markerColor = "ColorOPFOR";

private _markerOnDuration = 3;   // How long markers stay visible (seconds)
private _markerOffDuration = 5;  // How long markers are hidden between scans (seconds)

// Determine UAV variable name based on side
private _uavVar = switch (_callerSide) do {
	case west: { "blufor_recon_uav" };
	case east: { "opfor_recon_uav" };
	default { "blufor_recon_uav" };
};

while {
	!isNil _uavVar &&
	{ alive (missionNamespace getVariable [_uavVar, objNull]) }
} do {
	private _markerNames = [];

	// Create markers for all enemy players
	{
		private _unit = _x;
		if (side (group _unit) == _callerSide) then { continue };

		private _markerName = format ["recon_uav_marker_%1", str _unit];
		private _pos = getPosVisual _unit;
		_markerNames pushBack _markerName;

		[
			_markerName,
			_pos,
			_markerType,
			_markerColor
		] remoteExec ["map_fnc_createTempMarker", _callerSide];

	} forEach allPlayers;

	// Markers visible for this duration
	sleep _markerOnDuration;

	// Delete markers to hide them
	{
		[_x] remoteExec ["deleteMarkerLocal", _callerSide];
	} forEach _markerNames;

	// Markers hidden for this duration
	sleep _markerOffDuration;
};
