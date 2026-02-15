[] spawn {
    private _aiTypes = [
        "vn_b_men_sog_02", 
        "vn_b_men_sog_03", 
        "vn_b_men_sog_04", 
        "vn_b_men_sog_05", 
        "vn_b_men_sog_06", 
        "vn_b_men_sog_07", 
        "vn_b_men_sog_08", 
        "vn_b_men_sog_10", 
        "vn_b_men_sog_11", 
        "vn_b_men_sog_12", 
        "vn_b_men_sog_13", 
        "vn_b_men_sog_14", 
        "vn_b_men_sog_16", 
        "vn_b_men_sog_17", 
        "vn_b_men_sog_18", 
        "vn_b_men_sog_19", 
        "vn_b_men_sog_20"  
    ];

    private _side = west;
    private _maxAI = 32;
    private _spawnAmount = 1;
    private _maxSpawnAttempts = 15;
    private _spawnRadiusMin = 25;
    private _spawnRadiusMax = 100;
    private _safeRadius = 50;
    // Automatically detect all sector modules in the mission
    private _allSectors = allMissionObjects "ModuleSector_F";
    private _fallbackPos = getMarkerPos "west_AI_spawn";

    while {true} do {
        sleep 1;

        private _currentCount = count (allUnits select {side _x == _side && alive _x});
        if (_currentCount >= _maxAI) then {
            sleep 10;
            continue;
        };

        // Collect owned sectors - automatically detect all sectors
        private _ownedSectors = [];
        {
            private _sectorObj = _x;
            private _owner = _sectorObj getVariable ["owner", sideUnknown];
            if (_owner == _side) then {
                _ownedSectors pushBack _sectorObj;
            };
        } forEach _allSectors;

        private _spawnPos = _fallbackPos;
        private _validSpawn = false;

        if (count _ownedSectors > 0 && (random 1) > 0.1) then {
            private _sector = selectRandom _ownedSectors;
            private _sectorPos = getPos _sector;

            for "_attempt" from 1 to _maxSpawnAttempts do {
                private _angle = random 360;
                private _distance = _spawnRadiusMin + random (_spawnRadiusMax - _spawnRadiusMin);
                private _offset = [_distance * cos _angle, _distance * sin _angle, 0];
                private _candidatePos = _sectorPos vectorAdd _offset;

                private _nearBuildings = nearestObjects [_candidatePos, ["House", "Building"], 3];
                private _nearTrees = nearestTerrainObjects [_candidatePos, ["TREE"], 1];
                private _nearRocks = nearestTerrainObjects [_candidatePos, ["ROCK"], 30];
                private _isWater = surfaceIsWater _candidatePos;
                private _enemyNearbyCount = ({side _x != _side && _x distance2D _candidatePos < _safeRadius} count allUnits);

                if (
                    _nearBuildings isEqualTo [] &&
                    _nearTrees isEqualTo [] &&
                    _nearRocks isEqualTo [] &&
                    !_isWater &&
                    _enemyNearbyCount == 0
                ) then {
                    _spawnPos = _candidatePos;
                    _validSpawn = true;
                    break;
                };
            };

            if (!_validSpawn) then {
                _spawnPos = _fallbackPos;
                _validSpawn = true;
            };
        } else {
            _spawnPos = _fallbackPos;
            _validSpawn = true;
        };

        // --- AI spawning ---
        if (_validSpawn && !isNil "_spawnPos" && {!(surfaceIsWater _spawnPos)}) then {
            private _group = createGroup _side;

            for "_i" from 1 to _spawnAmount do {
                private _randomType = selectRandom _aiTypes;
                private _unit = _group createUnit [_randomType, _spawnPos, [], 0, "NONE"];

                [_unit] execVM "EventHandler\fn_registerEH.sqf";
                [_unit] call RNG_fnc_unit_init;
                _unit addEventHandler ["Killed", {
                    [west, -1] call BIS_fnc_respawnTickets;
                }];

                _unit setCombatMode "RED";
                _unit setBehaviour "COMBAT";
                
                [_unit] spawn {
                    params ["_unit"];
                    if (isNull _unit) exitWith {};

                    while {alive _unit} do {
                        private _sectors = allMissionObjects "ModuleSector_F";
                        private _enemySectors = _sectors select {
                            (_x getVariable ["owner", sideUnknown]) != side _unit
                        };

                        if (_enemySectors isNotEqualTo []) then {
                            private _targetSector = objNull;

                            if ((random 1) < 0.3) then {
                                private _farthest = _enemySectors select 0;
                                private _maxDist = _unit distance2D _farthest;
                                {
                                    private _dist = _unit distance2D _x;
                                    if (_dist > _maxDist) then {
                                        _maxDist = _dist;
                                        _farthest = _x;
                                    };
                                } forEach _enemySectors;
                                _targetSector = _farthest;
                            } else {
                                private _closest = _enemySectors select 0;
                                private _minDist = _unit distance2D _closest;
                                {
                                    private _dist = _unit distance2D _x;
                                    if (_dist < _minDist) then {
                                        _minDist = _dist;
                                        _closest = _x;
                                    };
                                } forEach _enemySectors;
                                _targetSector = _closest;
                            };

                            if (!isNull _targetSector) then {
                                private _grp = group _unit;
                                for "_wpI" from (count waypoints _grp - 1) to 0 step -1 do {
                                    deleteWaypoint [_grp, _wpI];
                                };

                                private _wp = _grp addWaypoint [position _targetSector, 0];
                                _wp setWaypointType "move";
                                _wp setWaypointBehaviour "COMBAT";
                                _wp setWaypointCombatMode "RED";
                                _wp setWaypointSpeed "FULL";
                            };
                        };

                        sleep 120 + random 40;
                    };
                };
            };
        };

        sleep 10;
    };
};
