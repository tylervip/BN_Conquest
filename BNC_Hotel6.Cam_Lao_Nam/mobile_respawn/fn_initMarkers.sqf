/**
    File: mobile_respawn\fn_initMarkers.sqf
    Author: TylenolVIP
    
    Description:
        Initializes the marker system for mobile respawn vehicles.
        Creates markers and starts the update loop.
    
    Usage:
        call MRS_fnc_initMarkers;
*/

// Initialize marker tracking array
MRS_markers = [];

// Track last known vehicle references for respawn detection
private _lastVehicles = createHashMap;

// Create initial markers for player's side
{
    _x params ["_vehicle", "_markerName", "_side"];
    if (side player == _side) then {
        [_vehicle, _markerName, _side] call MRS_fnc_createMarker;
        _lastVehicles set [_markerName, _vehicle];
    };
} forEach MRS_vehicles;

// Start update loop
MRS_markerLoop = [_lastVehicles] spawn {
    params ["_lastVehicles"];
    
    while {!isNil "MRS_markers"} do {
        // Check for vehicle respawns
        {
            _x params ["_vehicle", "_markerName", "_side"];
            if (side player != _side) then { continue };
            
            private _lastVeh = _lastVehicles getOrDefault [_markerName, objNull];
            
            // Vehicle respawned (different object reference)
            if (!isNull _vehicle && _vehicle != _lastVeh) then {
                _lastVehicles set [_markerName, _vehicle];
                [_markerName] call MRS_fnc_deleteMarker;
                [_vehicle, _markerName, _side] call MRS_fnc_createMarker;
            };
        } forEach MRS_vehicles;
        
        // Update existing markers
        {
            private _markerName = _x;
            if (markerShape _markerName == "") then { continue };
            
            // Find vehicle for this marker
            private _vehicle = objNull;
            private _side = sideUnknown;
            {
                _x params ["_veh", "_mkr", "_s"];
                if (_mkr == _markerName) exitWith {
                    _vehicle = _veh;
                    _side = _s;
                };
            } forEach MRS_vehicles;
            
            if (!isNull _vehicle && alive _vehicle) then {
                // Update position
                _markerName setMarkerPosLocal (getPos _vehicle);
                
                // Update visibility (hide_tent: 0 = deployed, 1 = stowed)
                private _tentDeployed = (_vehicle animationPhase "hide_tent") == 0;
                _markerName setMarkerAlphaLocal ([0, 1] select _tentDeployed);
            } else {
                // Vehicle dead
                [_markerName] call MRS_fnc_deleteMarker;
            };
        } forEach MRS_markers;
        
        uiSleep 1;
    };
};

diag_log "[Mobile Respawn] Markers initialized";
