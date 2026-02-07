/*
    custom_respawn/init_respawn.sqf
    Opens map on respawn and lets player redeploy to:
    - a friendly group member
    - a captured sector
    - a friendly base
    - a mobile respawn vehicle (when tent is deployed)
    Map stays open until a valid click is chosen.
*/

cutText [
    "<t color='#FF6000' size='1.2' font='PuristaBold' align='center'>
    Select a captured sector, your base, mobile respawn, or a group member to redeploy.
    </t>",
    "PLAIN DOWN", -1, true, true
];
openMap [true, false];

onMapSingleClick {
    params ["_ctrl", "_pos"];
    onMapSingleClick {};

    private _clickpos = _pos;
    private _side = side player;
    private _finalPos = [0,0,0];
    private _spawnVehicle = objNull;

    private _distance = 100;
    private _maxAttempts = 20;
    private _safeRadius = 25;
    private _clickRadius = 20;

    // ----------------------
    // Group member
    // ----------------------
    private _underFireMember = objNull;
    private _enemyNearbyMember = objNull;
    private _spawnOnVehicle = objNull;
    private _vehicleFull = false;
    {
        if (
            alive _x &&
            _x != player &&
            (_clickpos distance2D _x < _clickRadius)
        ) then {
            // Check if under fire
            if ((_x getVariable ["underFire", false]) || (_x getVariable ["inDebugRespawn", false])) then {
                _underFireMember = _x;
            } else {
                // Check if enemies nearby
                if ({ side _x2 != _side && _x2 distance2D _x < _safeRadius } count allUnits > 0) then {
                    _enemyNearbyMember = _x;
                } else {
                    _finalPos = getPosATL _x;
                    // Check if teammate is in a vehicle with room
                    private _veh = vehicle _x;
                    if (_veh != _x) then {
                        // Teammate is in a vehicle - check for empty seats
                        private _emptySeats = _veh emptyPositions "cargo";
                        if (_emptySeats > 0) then {
                            _spawnOnVehicle = _veh;
                        } else {
                            _vehicleFull = true;
                            _finalPos = [0,0,0]; // Block spawn - vehicle is full
                        };
                    };
                };
            };
        };
    } forEach units group player;

    // Show message if clicked on group member under fire
    if (!isNull _underFireMember && _finalPos isEqualTo [0,0,0]) exitWith {
        [
            format ["<t color='#FF6600' size='1.2' align='center'>%1 is under fire!<br/>Cannot spawn on this teammate.</t>", name _underFireMember],
            0, 0.8, 3, 0, 0, 7017
        ] spawn BIS_fnc_dynamicText;
        execVM "custom_respawn\init_respawn.sqf";
    };

    // Show message if enemies nearby
    if (!isNull _enemyNearbyMember && _finalPos isEqualTo [0,0,0]) exitWith {
        [
            format ["<t color='#FFAA00' size='1.2' align='center'>Enemies nearby %1!<br/>Cannot spawn on this teammate.</t>", name _enemyNearbyMember],
            0, 0.8, 3, 0, 0, 7017
        ] spawn BIS_fnc_dynamicText;
        execVM "custom_respawn\init_respawn.sqf";
    };

    // Show message if vehicle is full
    if (_vehicleFull && _finalPos isEqualTo [0,0,0]) exitWith {
        [
            "<t color='#FFAA00' size='1.2' align='center'>Vehicle is full!<br/>Cannot spawn on this teammate.</t>",
            0, 0.8, 3, 0, 0, 7017
        ] spawn BIS_fnc_dynamicText;
        execVM "custom_respawn\init_respawn.sqf";
    };

    // ----------------------
    // Sector - automatically detect all sectors
    // ----------------------
    if (_finalPos isEqualTo [0,0,0]) then {
        private _allSectors = allMissionObjects "ModuleSector_F";
        {
            private _sector = _x;
            private _sectorCenter = getPos _sector;
            private _owner = _sector getVariable ["owner", sideUnknown];

            if ((_clickpos distance2D _sectorCenter) < _clickRadius && _owner == _side) exitWith {
                for "_i" from 1 to _maxAttempts do {
                    private _angle = random 360;
                    private _spawnDist = 25 + random (_distance - 25);
                    private _candidatePos = _sectorCenter vectorAdd [
                        _spawnDist * cos _angle,
                        _spawnDist * sin _angle,
                        0
                    ];

                    if (
                        nearestObjects [_candidatePos, ["House","Building"], 5] isEqualTo [] &&
                        nearestTerrainObjects [_candidatePos, ["TREE"], 2] isEqualTo [] &&
                        nearestTerrainObjects [_candidatePos, ["ROCK"], 30] isEqualTo [] &&
                        !(surfaceIsWater _candidatePos) &&
                        ({ side _x2 != _side && _x2 distance2D _candidatePos < _safeRadius } count allUnits == 0)
                    ) exitWith {
                        _finalPos = _candidatePos;
                    };
                };
            };
        } forEach _allSectors;
    };

    // ----------------------
    // Base markers
    // ----------------------
    if (_finalPos isEqualTo [0,0,0]) then {
        {
            _x params ["_markerName", "_markerSide"];
            if (_side != _markerSide) then { continue };

            private _markerPos = getMarkerPos _markerName;
            if (_clickpos distance2D _markerPos < _clickRadius) exitWith {
                _finalPos = _markerPos getPos [random 15, random 360];
            };
        } forEach [["base_west", west], ["base_east", east]];
    };

    // ----------------------
    // Mobile respawn vehicle
    // ----------------------
    if (_finalPos isEqualTo [0,0,0]) then {
        {
            _x params ["_vehicle", "_markerName", "_vehicleSide"];
            
            // Validation checks
            if (_side != _vehicleSide) then { continue };
            if (isNil {_vehicle} || {isNull _vehicle}) then { continue };
            if (!alive _vehicle) then { continue };
            
            // Tent must be deployed (hide_tent: 0 = deployed, 1 = stowed)
            if ((_vehicle animationPhase "hide_tent") != 0) then { continue };
            
            private _vehiclePos = getPos _vehicle;
            if (_clickpos distance2D _vehiclePos < _clickRadius) exitWith {
                _finalPos = _vehiclePos;
                _spawnVehicle = _vehicle;
            };
        } forEach MRS_vehicles;
    };

    // ----------------------
    // Final
    // ----------------------
    if !(_finalPos isEqualTo [0,0,0]) then {
        player setPosATL _finalPos;
        // Mobile respawn vehicle takes priority
        if (!isNull _spawnVehicle) then {
            player moveInCargo _spawnVehicle;
        } else {
            // Check if spawning on teammate in vehicle
            if (!isNull _spawnOnVehicle && {alive _spawnOnVehicle}) then {
                private _emptySeats = _spawnOnVehicle emptyPositions "cargo";
                if (_emptySeats > 0) then {
                    player moveInCargo _spawnOnVehicle;
                };
            };
        };
        player setVariable ["inDebugRespawn", false, true];
        cutText ["", "PLAIN", -1, true, true];
        openMap [false,false];
    } else {
        [
            "<t color='#FF0000' size='1.2' align='center'>
            Invalid location. Please click again.
            </t>",
            0, 0.8, 1, 0, 0, 7017
        ] spawn BIS_fnc_dynamicText;

        execVM "custom_respawn\init_respawn.sqf";
    };
};