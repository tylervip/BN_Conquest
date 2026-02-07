// === Prevent Double Spawn Per Side ===
private _uavVar = switch (side player) do {
    case west: { "blufor_recon_uav" };
    case east: { "opfor_recon_uav" };
    default { "blufor_recon_uav" }; // Default to BLUFOR variable
};

if (!isNil { missionNamespace getVariable _uavVar } && { alive (missionNamespace getVariable _uavVar) }) exitWith {
    hint "Recon UAV already active for your side!";
};

// Remove the action to drop the Recon UAV
player removeAction drop_Action_ReconUAV;

// Determine the helicopter and pilot type based on player's side
private _vehicleType = switch (side player) do {
    case west: { "vn_b_air_oh6a_01" }; // BLUFOR
    case east: { "vn_o_air_mi2_01_02" }; // OPFOR
    default { "vn_b_air_oh6a_01" }; // Default to BLUFOR if side is unclear
};
private _pilotType = switch (side player) do {
    case west: { "vn_b_men_aircrew_01" }; // BLUFOR pilot
    case east: { "vn_o_men_aircrew_06" }; // OPFOR pilot
    default { "B_Helipilot_F" }; // Default to vanilla BLUFOR pilot
};

// Get the map center from the ModuleCoverMap_F module
private _mapCenter = [0, 0, 0]; // Default fallback
{
    if (typeOf _x == "ModuleCoverMap_F") exitWith {
        _mapCenter = getPos _x;
    };
} forEach allMissionObjects "ModuleCoverMap_F";

// Spawn position relative to the player
private _spawnPos = player modelToWorld [0, -750, 0];
_spawnPos set [2, 1000]; // Set spawn height to 200m

// Create the helicopter and its crew
private _vehGroup = createGroup side player;
private _helicopter = createVehicle [_vehicleType, _spawnPos, [], 0, "FLY"];
missionNamespace setVariable [_uavVar, _helicopter, true]; // Set side-specific variable
private _pilot = _vehGroup createUnit [_pilotType, _spawnPos, [], 0, "NONE"];
_pilot moveInDriver _helicopter;

// Ensure the helicopter flies at a reasonable height
_helicopter flyInHeight 100;

// Set up the loiter waypoint at the map center
private _wp = _vehGroup addWaypoint [_mapCenter, 50];
_wp setWaypointType "LOITER";
_wp setWaypointSpeed "FULL";
_wp setWaypointBehaviour "CARELESS";
_wp setWaypointLoiterRadius 500;
_wp setWaypointLoiterType "CIRCLE";

sleep 10; // time to get to AO
// Trigger the killstreak function on the server
[player] remoteExec ["killstreak_fnc_recon_uav", 2];

// Cleanup after 1 minutes
[_helicopter, _uavVar] spawn {
    params ["_veh", "_uavVar"];
    sleep 60; // 1 minutes

    if (alive _veh) then {
        private _grp = group _veh;
        private _flyAwayPos = _veh modelToWorld [0, -5000, 500];

        // Fly-away waypoint
        private _wpFlyAway = _grp addWaypoint [_flyAwayPos, 100];
        _wpFlyAway setWaypointType "MOVE";
        _wpFlyAway setWaypointSpeed "FULL";
        _wpFlyAway setWaypointBehaviour "CARELESS";

        // Remove old waypoints
        for "_i" from (count waypoints _grp) - 2 to 0 step -1 do {
            deleteWaypoint [_grp, _i];
        };

        // Cleanup after 60 seconds
        sleep 30;
        {
            if (!isNull _x) then { deleteVehicle _x };
        } forEach units _grp;
        deleteVehicle _veh;
        missionNamespace setVariable [_uavVar, nil, true]; // Clear side-specific variable
    };
};