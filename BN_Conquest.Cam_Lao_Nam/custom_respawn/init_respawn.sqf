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
openMap [true, true];

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
    {
        if (
            alive _x &&
            _x != player &&
            !(_x getVariable ["underFire", false]) &&
            !(_x getVariable ["inDebugRespawn", false]) &&
            (_clickpos distance2D _x < _clickRadius) &&
            ({ side _x2 != _side && _x2 distance2D _x < _safeRadius } count allUnits == 0)
        ) exitWith {
            _finalPos = getPosATL _x;
        };
    } forEach units group player;

    // ----------------------
    // Sector
    // ----------------------
    if (_finalPos isEqualTo [0,0,0]) then {
        {
            private _sector = missionNamespace getVariable [format ["sector_%1", _x], objNull];
            if (isNull _sector) exitWith {};

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
        } forEach ["Alpha","Bravo","Charlie","Delta","Echo","Foxtrot","Golf"];
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
            _x params ["_vehicle", "_vehicleSide"];
            if (_side != _vehicleSide) then { continue };
            if (isNil {_vehicle} || {isNull _vehicle}) then { continue };
            if (!alive _vehicle) then { continue };
            
            // Only allow spawn if tent is deployed  (hide_tent == 0) - marker is visible
            if (_vehicle animationPhase "hide_tent" == 1) then { continue };
            
            private _vehiclePos = getPos _vehicle;
            if (_clickpos distance2D _vehiclePos < _clickRadius) exitWith {
                _finalPos = _vehiclePos;
                _spawnVehicle = _vehicle;
            };
        } forEach [[mobile_respawn, west], [mobile_respawn_1, east]];
    };

    // ----------------------
    // Final
    // ----------------------
    if !(_finalPos isEqualTo [0,0,0]) then {
        player setPosATL _finalPos;
        if (!isNull _spawnVehicle) then {
            player moveInCargo _spawnVehicle;
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