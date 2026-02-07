// custom_respawn/working_Teleport.sqf
cutText ["<t color='#FF6000' size='1.2' font='PuristaBold' align='center'>Select a captured sector, your base, or a group member to redeploy.</t>", "PLAIN DOWN", -1, true, true];
openMap [true, false];

onMapSingleClick {
    params ["_ctrl", "_pos"];
    onMapSingleClick {};

    private _clickpos = _pos;
    private _side = side player;
    private _valid = false;
    private _finalPos = [0,0,0];

    private _distance = 100;
    private _maxAttempts = 20;
    private _safeRadius = 25;
    private _clickRadius = 20;

    // Check for valid group member
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
            _valid = true;
        };
    } forEach units group player;

    // Check for valid sector
    if (!_valid) then {
        {
            private _sectorName = format ["sector_%1", _x];
            private _sector = missionNamespace getVariable [_sectorName, objNull];
            if (isNull _sector) exitWith {};

            private _sectorCenter = getPos _sector;
            private _owner = _sector getVariable ["owner", sideUnknown];

            if ((_clickpos distance2D _sectorCenter) < _clickRadius && _owner == _side) exitWith {
                for "_i" from 1 to _maxAttempts do {
                    private _angle = random 360;
                    private _spawnDist = 25 + random (_distance - 25);
                    private _offset = [
                        _spawnDist * cos _angle,
                        _spawnDist * sin _angle,
                        0
                    ];
                    private _candidatePos = _sectorCenter vectorAdd _offset;

                    private _nearObjects = nearestObjects [_candidatePos, ["House", "Building"], 5];
                    private _nearTrees = nearestTerrainObjects [_candidatePos, ["TREE"], 2];
                    private _nearRocks = nearestTerrainObjects [_candidatePos, ["ROCK"], 30];

                    if (
                        _nearObjects isEqualTo [] &&
                        _nearTrees isEqualTo [] &&
                        _nearRocks isEqualTo [] &&
                        !(surfaceIsWater _candidatePos) &&
                        ({side _x2 != _side && _x2 distance2D _candidatePos < _safeRadius} count allUnits == 0)
                    ) exitWith {
                        _finalPos = _candidatePos;
                        _valid = true;
                    };
                };
            };
        } forEach ["Alpha", "Bravo", "Charlie", "Delta", "Echo", "Foxtrot", "Golf"];
    };

    // Check for valid base marker
    if (!_valid) then {
        private _baseMarkers = [
            ["base_west", west],
            ["base_east", east]
        ];
        {
            private _markerName = _x select 0;
            private _markerSide = _x select 1;
            private _markerPos = getMarkerPos _markerName;

            if (_side isEqualTo _markerSide && (_clickpos distance2D _markerPos < _clickRadius)) exitWith {
                private _angle = random 360;
                private _radius = random 15;
                private _offset = [
                    _radius * cos _angle,
                    _radius * sin _angle,
                    0
                ];
                _finalPos = _markerPos vectorAdd _offset;
                _valid = true;
            };
        } forEach _baseMarkers;
    };

    // Final teleport
    if (_valid) then {
        player setPosATL _finalPos;
        player setVariable ["inDebugRespawn", false, true];
        cutText ["", "PLAIN", -1, true, true];
        openMap [false,false];
    } else {
        ["<t color='#FF0000' size='1.2' align='center'>Invalid location. Please click again.</t>", 0, 0.8, 1, 0, 0, 7017] spawn BIS_fnc_dynamicText;

        execVM "custom_respawn\init_respawn.sqf";
    };
};