// Author: Savage Game Design
// Author: Tylervip
// Keybinding definitions and macros for the keybindings menu UI
#include "\a3\ui_f\hpp\definedikcodes.inc"

//--- Key down actions (down = 1):
class grenade_throw
{
    defaultKey = DIK_G;
    shift = "false";
    ctrl = "false";
    alt = "false";
    function = "LEON_COD_fnc_handleThrowGrenade";
    down = 1;
    displayName = "Throw Back Grenades";
    access = 1;
};

class earplug_toggle
{
    defaultKey = DIK_6;
    shift = "false";
    ctrl = "false";
    alt = "false";
    function = "BNC_fnc_toggleEarplugs";
    down = 1;
    displayName = "Toggle Earplugs";
    access = 1;
};

//--- Key up actions (down = 0):
// Add key-up bindings here