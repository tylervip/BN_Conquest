/**
    File: mobile_respawn_marker.sqf
    Description: Manages markers for mobile respawn vehicles
    Shows/hides markers based on tent deployment state
*/

if (hasInterface) then {
    // Wait for vehicles to be initialized
    waitUntil { !isNil "mobile_respawn" && !isNil "mobile_respawn_1" };
    
    // Track mobile respawn markers
    mobileRespawnMarkers = [];
    
    // Create marker for vehicle
    private _createMobileMarker = {
        params ["_vehicle", "_markerName", "_side"];
        
        if (side player != _side) exitWith {};
        if (isNull _vehicle) exitWith {};
        
        // Check if marker already exists
        if (markerShape _markerName == "") then {
            createMarkerLocal [_markerName, getPos _vehicle];
        };
        
        _markerName setMarkerShapeLocal "ICON";
        _markerName setMarkerTypeLocal "loc_Truck";
        _markerName setMarkerSizeLocal [1, 1];
        _markerName setMarkerColorLocal (switch (_side) do {
            case west: {"ColorWEST"};
            case east: {"ColorEAST"};
            default {"ColorUNKNOWN"};
        });
        _markerName setMarkerTextLocal "Mobile Respawn";
        
        // Set initial visibility based on tent state
        if (_vehicle animationPhase "hide_tent" == 1) then {
            _markerName setMarkerAlphaLocal 1;  // Tent deployed = marker visible
        } else {
            _markerName setMarkerAlphaLocal 0;  // Tent stowed = marker hidden
        };
        
        // Add to tracking array
        mobileRespawnMarkers pushBackUnique _markerName;
        
        // Store vehicle reference on marker for later checks
        _vehicle setVariable ["mobileMarkerName", _markerName];
    };
    
    // Create initial markers
    [mobile_respawn, "marker_mobile_blu", west] call _createMobileMarker;
    [mobile_respawn_1, "marker_mobile_red", east] call _createMobileMarker;
    
    // Update loop - manage marker positions and visibility
    mobileMarkerLoop = [] spawn {
        private _lastBluVehicle = mobile_respawn;
        private _lastRedVehicle = mobile_respawn_1;
        private _createMarkerFunc = {
            params ["_vehicle", "_markerName", "_side"];
            
            if (side player != _side) exitWith {};
            if (isNull _vehicle) exitWith {};
            
            // Check if marker already exists
            if (markerShape _markerName == "") then {
                createMarkerLocal [_markerName, getPos _vehicle];
            };
            
            _markerName setMarkerShapeLocal "ICON";
            _markerName setMarkerTypeLocal "loc_Truck";
            _markerName setMarkerSizeLocal [1, 1];
            _markerName setMarkerColorLocal (switch (_side) do {
                case west: {"ColorWEST"};
                case east: {"ColorEAST"};
                default {"ColorUNKNOWN"};
            });
            _markerName setMarkerTextLocal "Mobile Respawn";
            
            // Set initial visibility based on tent state
            if (_vehicle animationPhase "hide_tent" == 0) then {
                _markerName setMarkerAlphaLocal 1;
            } else {
                _markerName setMarkerAlphaLocal 0;
            };
            
            // Add to tracking array
            mobileRespawnMarkers pushBackUnique _markerName;
        };
        
        while {!isNil "mobileRespawnMarkers"} do {
            // Check if vehicles have respawned (different object reference)
            if (!isNull mobile_respawn && mobile_respawn != _lastBluVehicle) then {
                _lastBluVehicle = mobile_respawn;
                // Vehicle respawned, recreate marker
                if (side player == west) then {
                    deleteMarkerLocal "marker_mobile_blu";
                    private _idx = mobileRespawnMarkers find "marker_mobile_blu";
                    if (_idx >= 0) then {
                        mobileRespawnMarkers deleteAt _idx;
                    };
                    [mobile_respawn, "marker_mobile_blu", west] call _createMarkerFunc;
                };
            };
            
            if (!isNull mobile_respawn_1 && mobile_respawn_1 != _lastRedVehicle) then {
                _lastRedVehicle = mobile_respawn_1;
                // Vehicle respawned, recreate marker
                if (side player == east) then {
                    deleteMarkerLocal "marker_mobile_red";
                    private _idx = mobileRespawnMarkers find "marker_mobile_red";
                    if (_idx >= 0) then {
                        mobileRespawnMarkers deleteAt _idx;
                    };
                    [mobile_respawn_1, "marker_mobile_red", east] call _createMarkerFunc;
                };
            };
            
            {
                private _markerName = _x;
                if (markerShape _markerName != "") then {
                    // Determine which vehicle this marker belongs to
                    private _vehicle = if (_markerName find "blu" > -1) then {
                        mobile_respawn
                    } else {
                        mobile_respawn_1
                    };
                    
                    if (!isNull _vehicle && alive _vehicle) then {
                        // Update position
                        _markerName setMarkerPosLocal (getPos _vehicle);
                        
                        // Update visibility based on tent animation
                        if (_vehicle animationPhase "hide_tent" == 0) then {
                            _markerName setMarkerAlphaLocal 1;  // Tent deployed
                        } else {
                            _markerName setMarkerAlphaLocal 0;  // Tent stowed
                        };
                    } else {
                        // Vehicle dead, delete marker
                        deleteMarkerLocal _markerName;
                        private _idx = mobileRespawnMarkers find _markerName;
                        if (_idx >= 0) then {
                            mobileRespawnMarkers deleteAt _idx;
                        };
                    };
                };
            } forEach mobileRespawnMarkers;
            
            uiSleep 1;
        };
    };
};
