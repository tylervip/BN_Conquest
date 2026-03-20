// Author: Savage Game Design
#include "..\..\..\config\ui\ui_def_base.inc"

params ["_mode", "_args", "_class"];
if (_mode == "onLoad") then {
_args call para_c_fnc_keybindingsMenu_onLoad;
} else {
_args call para_c_fnc_keybindingsMenu_onUnload;
};
