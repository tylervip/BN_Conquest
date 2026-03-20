// Author: Savage Game Design
// Initialize keybinding variable mappings
call para_c_fnc_init_key_down;
call para_c_fnc_init_key_up;

// Wait for display 46 (main game display) then attach key handlers
[] spawn {
waitUntil {!isNull (findDisplay 46)};
(findDisplay 46) displayAddEventHandler ["KeyDown", "_this call para_c_fnc_eh_key_down"];
(findDisplay 46) displayAddEventHandler ["KeyUp", "_this call para_c_fnc_eh_key_up"];
};
