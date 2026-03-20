// Earplug toggle initialization
// Keybinding handled by para_c keybinding system (keys.hpp - default key 6)
// This file initializes the earplug variable on mission start

[] spawn {
    waitUntil { !isNull player };
    sleep 2;
    
    // Initialize earplug toggle variable
    localNamespace setVariable ["vn_mf_earplugs", false];
};
