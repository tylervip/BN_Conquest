/*
Description:
	Toggle earplugs keybinding handler
	Integrated with para_c keybinding system
	
Parameters:
	None (called by keybinding system)

Return:
	Boolean - true to consume the key event

Example:
	call BNC_fnc_toggleEarplugs;

Author: Tylervip
Modified: Integrated with para_c keybinding system
*/

private _status = !(localNamespace getVariable ["vn_mf_earplugs", false]);
localNamespace setVariable ["vn_mf_earplugs", _status];
systemChat localize (["STR_VN_QOL_EARPLUGS_OUT", "STR_VN_QOL_EARPLUGS_IN"] select _status);
0.5 fadeSound ([1, 0.2] select _status);

true
