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

// Add loadout restoration action to each vehicle
{
    _x params ["_vehicle"];
    _vehicle addAction [
        "<t color='#00ff00'>Restore Loadout</t>",
        {
            if (player getVariable ["loadoutCooldown", 0] > time) exitWith {
                private _remaining = (player getVariable ["loadoutCooldown", 0]) - time;
                hint format ["Loadout restore on cooldown! %1 seconds remaining", ceil _remaining];
            };
            player setVariable ["loadoutCooldown", time + 60];
            player setUnitLoadout (player getVariable ["SavedLoadout", []]);
            hint "Loadout restored!";
        },
        nil,
        1.5,
        false,
        true,
        "(_this distance _target) < 3"
    ];
} forEach MRS_vehicles;

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
