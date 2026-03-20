// Author: Savage Game Design
#include "..\..\config\ui\ui_def_base.inc"

[missionNamespace, "OnGameInterrupt", {
params ["_display"];

// Keybindings button
_newBtn = _display ctrlCreate ["para_RscButtonMenu", -1];
_newBtn ctrlSetPosition [safeZoneX + UIW(1), safeZoneY + UIH(1), UIW(15), UIH(1)];
_newBtn ctrlCommit 0;
_newBtn ctrlSetText "GAMEMODE KEYBINDINGS";
_newBtn ctrlAddEventHandler ["ButtonClick",{
params ["_btn"];
_escDisplay = ctrlParent _btn;
_escDisplay createDisplay "para_RscDisplayKeybindingsMenu";
}];
}] call BIS_fnc_addScriptedEventHandler;
