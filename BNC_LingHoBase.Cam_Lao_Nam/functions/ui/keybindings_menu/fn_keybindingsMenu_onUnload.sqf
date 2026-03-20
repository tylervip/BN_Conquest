// Author: Savage Game Design
#include "..\..\..\config\ui\ui_def_base.inc"

params ["_display", "_exitCode"];
if (_exitCode == 1) then {
private _ctrlKeybinds = _display displayCtrl PARA_KEYBINDINGSMENU_KEYBINDS_IDC;
private _usedKeys = _display getVariable ["usedKeys", []];
for "_i" from 0 to (lnbSize _ctrlKeybinds select 0) -1 do {
private _keyBind = [_ctrlKeybinds lbData _i];
_keyBind append (_usedKeys select (_ctrlKeybinds lbValue _i));
_keyBind call para_c_fnc_change_key_bind;
};
};
