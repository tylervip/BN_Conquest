// Author: Savage Game Design
#include "..\..\..\config\ui\ui_def_base.inc"
#include "\a3\ui_f\hpp\definedikcodes.inc"

params ["_ctrlKeybinds", "_key", "_shift", "_ctrl", "_alt", "_row"];

private _forbiddenKeys = [DIK_LSHIFT, DIK_LCONTROL, DIK_LMENU];
if (_key in _forbiddenKeys) exitWith {
true
};
private _display = ctrlParent _ctrlKeybinds;
_ctrlKeybinds ctrlRemoveEventHandler ["KeyDown", _ctrlKeybinds getVariable ["editBindKeyEH", -1]];
_ctrlKeybinds lnbSetCurSelRow _row;
if (_key != DIK_ESCAPE) then {
private _usedKeys = _display getVariable ["usedKeys", []];
_name = [_key] call para_c_fnc_getKeyName;
if (_alt) then {_name = "ALT+" + _name};
if (_ctrl) then {_name = "CTRL+" + _name};
if (_shift) then {_name = "SHIFT+" + _name};
_ctrlKeybinds lnbSetText [[_row,1], _name];
_usedKeys set [_ctrlKeybinds lbValue _row, [_key, str _shift, str _ctrl, str _alt]];
_display setVariable ["usedKeys", _usedKeys];
};
[_ctrlKeybinds] call para_c_fnc_keybindingsMenu_updateColors;
true
