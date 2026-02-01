if (!isServer) exitWith {};

// --- WAIT FOR OBJECT AND SECTOR TO EXIST ---
waitUntil {
    (!isNil "sector_Alpha") &&
    { !(missionNamespace getVariable ["sector_Alpha", objNull] isEqualTo objNull) } &&
    { !isNull Heil_SpawnPoint }
};

private _spawnPoint = Heil_SpawnPoint;
private _sectorModule = missionNamespace getVariable ["sector_Alpha", objNull];

private _opforClass = "vn_o_air_mi2_04_01";
private _bluforClass = "vn_b_air_uh1c_04_01";

// --- GLOBAL STORAGE ---
if (isNil "SectorHeli_Current") then { SectorHeli_Current = objNull; };
if (isNil "SectorHeli_Owner") then { SectorHeli_Owner = sideUnknown; };

[_spawnPoint, _sectorModule, _bluforClass, _opforClass] spawn {
    params ["_spawnPoint", "_sectorModule", "_bluforClass", "_opforClass"];

    while {true} do {
        private _pos = getPosATL _spawnPoint;
        private _dir = getDir _spawnPoint;
        private _owner = _sectorModule getVariable ["owner", sideUnknown];
        private _checkInterval = 20; // Default interval for contested sector

        if (!isNull SectorHeli_Current && {!alive SectorHeli_Current}) then {
            deleteVehicle SectorHeli_Current;
            SectorHeli_Current = objNull;
            SectorHeli_Owner = sideUnknown;
            _checkInterval = 300; //cooldown for destroyed helicopter
        };

        if (_owner != SectorHeli_Owner && {_owner in [west, east]}) then {
            private _canReplace = false;

            // Check if any living unit or vehicle is within 5 meters of spawn point
            private _nearUnits = nearestObjects [_pos, ["Man", "Vehicle"], 5];
            _nearUnits = _nearUnits select {alive _x};
            if (count _nearUnits > 0) exitWith {
            };

            if (!isNull SectorHeli_Current) then {
                private _crew = crew SectorHeli_Current;
                private _dist = SectorHeli_Current distance2D _pos;

                if ((count _crew) == 0 && {_dist <= 2}) then {
                    deleteVehicle SectorHeli_Current;
                    SectorHeli_Current = objNull;
                    _canReplace = true;
                };
            } else {
                _canReplace = true;
            };

            if (_canReplace) then {
                private _class = if (_owner isEqualTo west) then { _bluforClass } else { _opforClass };

                SectorHeli_Current = createVehicle [_class, _pos, [], 0, "NONE"];
                SectorHeli_Current setDir _dir;
                SectorHeli_Current setPosATL _pos;
                publicVariable "SectorHeli_Current";

                SectorHeli_Owner = _owner;
                publicVariable "SectorHeli_Owner";
            };
        };

        sleep _checkInterval;
    };
};