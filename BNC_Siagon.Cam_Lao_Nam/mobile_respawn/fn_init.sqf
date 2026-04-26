/**
    File: mobile_respawn\fn_init.sqf
    Author: TylenolVIP
    
    Description:
        Initializes the mobile respawn system.
        Call this from init.sqf
    
    Usage:
        call MRS_fnc_init;
*/

// Wait for vehicles to be initialized
waitUntil { !isNil "mobile_respawn" && !isNil "mobile_respawn_1" };

// Shared definitions
// Format: [vehicleVarName, markerName, side]
MRS_vehicleDefs = [
    ["mobile_respawn", "marker_mobile_blu", west],
    ["mobile_respawn_1", "marker_mobile_red", east]
];

if (isServer) then {
    publicVariable "MRS_vehicleDefs";

    // Seconds before a destroyed command vehicle is recreated.
    MRS_respawnDelay = 120;
    publicVariable "MRS_respawnDelay";

    if (isNil "MRS_serverRespawnLoop") then {
        MRS_serverRespawnLoop = [] spawn MRS_fnc_serverRespawnLoop;
    };
};

if (!hasInterface) exitWith {};

waitUntil { !isNil "MRS_vehicleDefs" };
call MRS_fnc_refreshVehicleRefs;

// Define teleport sign configurations
// Format: [signObject, side]
MRS_teleportPairs = [];
if (!isNil "mobile_respawn_teleport" && {!isNull mobile_respawn_teleport}) then {
    MRS_teleportPairs pushBack [mobile_respawn_teleport, west];
};
if (!isNil "mobile_respawn_teleport_1" && {!isNull mobile_respawn_teleport_1}) then {
    MRS_teleportPairs pushBack [mobile_respawn_teleport_1, east];
};

// Initialize subsystems using spawn to ensure functions are available
[] spawn {
    // Small delay to ensure all functions are compiled
    uiSleep 0.5;
    
    call MRS_fnc_initMarkers;
    call MRS_fnc_initTeleport;

    if (!isNil "MRS_refreshLoop") then {
        terminate MRS_refreshLoop;
    };

    // Keep client references current after server recreates vehicles.
    MRS_refreshLoop = [] spawn {
        while {true} do {
            call MRS_fnc_refreshVehicleRefs;
            uiSleep 2;
        };
    };
    
    diag_log "[Mobile Respawn] System initialized";
};
