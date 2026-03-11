/**
	File: 	fn_player_markers_subsystem_init.sqf 
	Author: Adabou + TylenolVIP

	Public: yoink

	Description:
		initilization script of the map markers 
	
	Parameter(s):
		- none 
	
	Returns:
		- nothing 

	Example(s):
		call map_fnc_player_markers_subsystem_init
 */

cqs_map_markers = [];

cqs_map_markers_loop = [] spawn {
	while {isNil "abortMarkerManagement"} do{
		call map_fnc_player_markers;
		uiSleep 2;
	};
};
cqs_map_markers_eachFrame_handler = addMissionEventHandler ["EachFrame", map_fnc_player_markers_update];