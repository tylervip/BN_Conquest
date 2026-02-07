/**
    File: mobile_respawn\fn_init.sqf
    Author: TylenolVIP
    
    Description:
        Initializes the mobile respawn system.
        Call this from init.sqf
    
    Usage:
        call MRS_fnc_init;
*/

if (!hasInterface) exitWith {};

// Wait for vehicles to be initialized
waitUntil { !isNil "mobile_respawn" && !isNil "mobile_respawn_1" };

// Define vehicle configurations
// Format: [vehicleObject, markerName, side]
MRS_vehicles = [
    [mobile_respawn, "marker_mobile_blu", west],
    [mobile_respawn_1, "marker_mobile_red", east]
];

// Define teleport sign configurations
// Format: [signObject, vehicleObject]
MRS_teleportPairs = [];
if (!isNil "mobile_respawn_teleport" && {!isNull mobile_respawn_teleport}) then {
    MRS_teleportPairs pushBack [mobile_respawn_teleport, mobile_respawn];
};
if (!isNil "mobile_respawn_teleport_1" && {!isNull mobile_respawn_teleport_1}) then {
    MRS_teleportPairs pushBack [mobile_respawn_teleport_1, mobile_respawn_1];
};

// Initialize subsystems using spawn to ensure functions are available
[] spawn {
    // Small delay to ensure all functions are compiled
    uiSleep 0.5;
    
    call MRS_fnc_initMarkers;
    call MRS_fnc_initTeleport;
    
    diag_log "[Mobile Respawn] System initialized";
};
