// Author: Savage Game Design
#include "..\..\..\config\ui\ui_def_base.inc"

params ["_display"];
_ctrlKeybinds = _display displayCtrl PARA_KEYBINDINGSMENU_KEYBINDS_IDC;
_keyActions = "getNumber(_x >> 'access') > 0" configClasses (missionConfigFile >> "gamemode" >> "keys");
_usedKeys = [];
_keyActions apply {
_actionName = configName _x;
_actionDisplayname = getText(_x >> "displayName");
private _key_bind = [_actionName] call para_c_fnc_get_key_bind;
_key_bind params ["_keyID", "_keyShift", "_keyCtrl", "_keyAlt"];
_usedKeys pushBack _key_bind;
_keyID = _key_bind param[0,""];
_keyname = [_keyID] call para_c_fnc_getKeyName;
if (_keyAlt == "true") then {_keyname = "ALT+" + _keyname};
if (_keyCtrl == "true") then {_keyname = "CTRL+" + _keyname};
if (_keyShift == "true") then {_keyname = "SHIFT+" + _keyname};
_row = _ctrlKeybinds lnbAddRow [_actionDisplayname, _keyname];
_ctrlKeybinds lbSetData [_row, _actionName];
_ctrlKeybinds lbSetValue [_row, count _usedKeys -1];
};
_display setVariable ["usedKeys", _usedKeys];
_ctrlKeybinds ctrlAddEventHandler ["LBDblClick", para_c_fnc_keybindingsMenu_editBind];
_ctrlReset = _display displayCtrl PARA_KEYBINDINGSMENU_RESET_IDC;
_ctrlReset ctrlAddEventHandler ["ButtonClick", para_c_fnc_keybindingsMenu_reset];
