// Author: Savage Game Design
#include "..\..\..\config\ui\ui_def_base.inc"

params ["_ctrlKeybinds", "_row"];
[
_ctrlKeybinds,
COLOR_KEYBINDINGS_NORMAL_UNSELECTED,
COLOR_KEYBINDINGS_DOUBLEBIND_UNSELECTED,
COLOR_KEYBINDINGS_NORMAL_SELECTED
] call para_c_fnc_keybindingsMenu_updateColors;
_ehID = _ctrlKeybinds ctrlAddEventHandler ["KeyDown", format [
"(_this + [%1]) call para_c_fnc_keybindingsMenu_editBind_input;",
_row
]];
_ctrlKeybinds setVariable ["editBindKeyEH", _ehID];
