if (!isServer) exitWith {};

// --- WAIT FOR OBJECT AND SECTOR TO EXIST ---
waitUntil {
    (!isNil "sector_Charlie") &&
    { !(missionNamespace getVariable ["sector_Charlie", objNull] isEqualTo objNull) } &&
    { !isNull Tank_SpawnPoint }
};

private _spawnPoint = Tank_SpawnPoint;
private _sectorModule = missionNamespace getVariable ["sector_Charlie", objNull];

private _opforClass = "vn_o_armor_t54b_01";
private _bluforClass = "vn_b_armor_m48_01_01";

// --- GLOBAL STORAGE ---
if (isNil "SectorTank_Current") then { SectorTank_Current = objNull; };
if (isNil "SectorTank_Owner") then { SectorTank_Owner = sideUnknown; };

[_spawnPoint, _sectorModule, _bluforClass, _opforClass] spawn {
    params ["_spawnPoint", "_sectorModule", "_bluforClass", "_opforClass"];

    while {true} do {
        private _pos = getPosATL _spawnPoint;
        private _dir = getDir _spawnPoint;
        private _owner = _sectorModule getVariable ["owner", sideUnknown];
        private _checkInterval = 20; // Default interval for contested sector

        if (!isNull SectorTank_Current && {!alive SectorTank_Current}) then {
            deleteVehicle SectorTank_Current;  // Cleanup wreck
            SectorTank_Current = objNull;
            SectorTank_Owner = sideUnknown;
            _checkInterval = 180; // Longer cooldown for destroyed tank
        };

        if (_owner != SectorTank_Owner && {_owner in [west, east]}) then {
            private _canReplace = false;

            // Check if any unit is within 5 meters of spawn point
            private _nearUnits = nearestObjects [_pos, ["Man", "Vehicle"], 5];
            if (count _nearUnits > 0) exitWith {
                // Someone is nearby, skip spawning this time
            };

            if (!isNull SectorTank_Current) then {
                private _crew = crew SectorTank_Current;
                private _dist = SectorTank_Current distance2D _pos;

                if ((count _crew) == 0 && {_dist <= 5}) then {
                    deleteVehicle SectorTank_Current;  // Cleanup wreck before replace
                    SectorTank_Current = objNull;
                    _canReplace = true;
                };
            } else {
                _canReplace = true;
            };

            if (_canReplace) then {
                private _class = if (_owner isEqualTo west) then { _bluforClass } else { _opforClass };

                SectorTank_Current = createVehicle [_class, _pos, [], 0, "NONE"];
                SectorTank_Current setDir _dir;
                SectorTank_Current setPosATL _pos;
                publicVariable "SectorTank_Current";

                SectorTank_Owner = _owner;
                publicVariable "SectorTank_Owner";
            };
        };

        sleep _checkInterval;
    };
};