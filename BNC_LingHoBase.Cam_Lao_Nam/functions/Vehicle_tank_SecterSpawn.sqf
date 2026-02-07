if (!isServer) exitWith {};

/*
    Vehicle_tank_SecterSpawn.sqf
    Dynamically finds all Tank_SpawnPoint objects and determines
    which sector each one belongs to. Spawns a tank at each
    spawn point based on the owning side of the nearest sector.
    
    Spawn point naming: Tank_SpawnPoint_0, Tank_SpawnPoint_1, etc.
*/

// Wait for sectors to be initialized
waitUntil { count (allMissionObjects "ModuleSector_F") > 0 };
sleep 2; // Give sectors time to fully initialize

private _opforClass = "vn_o_armor_t54b_01";
private _bluforClass = "vn_b_armor_m48_01_01";

// --- FIND ALL TANK SPAWN POINTS ---
private _allSpawnPoints = [];
private _i = 0;
while {true} do {
    private _varName = format ["Tank_SpawnPoint_%1", _i];
    private _obj = missionNamespace getVariable [_varName, objNull];
    if (isNull _obj) exitWith {};
    _allSpawnPoints pushBack [_obj, _varName];
    _i = _i + 1;
};

if (count _allSpawnPoints == 0) exitWith {
    diag_log "[TANK SPAWN] ERROR: No Tank_SpawnPoint objects found!";
};

diag_log format ["[TANK SPAWN] Found %1 tank spawn point(s)", count _allSpawnPoints];

// --- FIND NEAREST SECTOR FOR EACH SPAWN POINT ---
private _allSectors = allMissionObjects "ModuleSector_F";
private _spawnConfigs = [];

{
    _x params ["_spawnObj", "_spawnName"];
    private _spawnPos = getPos _spawnObj;
    
    private _nearestSector = objNull;
    private _nearestDist = 99999;
    {
        private _dist = _spawnPos distance2D (getPos _x);
        if (_dist < _nearestDist) then {
            _nearestDist = _dist;
            _nearestSector = _x;
        };
    } forEach _allSectors;
    
    if (!isNull _nearestSector) then {
        _spawnConfigs pushBack [_spawnObj, _nearestSector, _spawnName];
        diag_log format ["[TANK SPAWN] %1 -> Sector at %2 (distance: %3m)", _spawnName, getPos _nearestSector, round _nearestDist];
    } else {
        diag_log format ["[TANK SPAWN] WARNING: No sector found for %1", _spawnName];
    };
} forEach _allSpawnPoints;

// --- GLOBAL STORAGE ---
if (isNil "BNC_SectorTanks") then { BNC_SectorTanks = []; };

// --- SPAWN LOOP FOR EACH SPAWN POINT ---
{
    _x params ["_spawnPoint", "_sectorModule", "_spawnName"];
    
    [_spawnPoint, _sectorModule, _bluforClass, _opforClass, _spawnName, _forEachIndex] spawn {
        params ["_spawnPoint", "_sectorModule", "_bluforClass", "_opforClass", "_spawnName", "_index"];
        
        private _currentTank = objNull;
        private _currentOwner = sideUnknown;
        
        while {true} do {
            private _pos = getPosATL _spawnPoint;
            private _dir = getDir _spawnPoint;
            private _owner = _sectorModule getVariable ["owner", sideUnknown];
            private _checkInterval = 20;
            
            // Check if current tank is destroyed
            if (!isNull _currentTank && {!alive _currentTank}) then {
                deleteVehicle _currentTank;
                _currentTank = objNull;
                _currentOwner = sideUnknown;
                _checkInterval = 180; // Cooldown for destroyed tank
            };
            
            // Check if ownership changed
            if (_owner != _currentOwner && {_owner in [west, east]}) then {
                private _canReplace = false;
                
                // Check if any living unit or vehicle is within 5 meters of spawn point
                private _nearUnits = nearestObjects [_pos, ["Man", "Vehicle"], 5];
                _nearUnits = _nearUnits select {alive _x};
                if (count _nearUnits > 0) exitWith {};
                
                if (!isNull _currentTank) then {
                    private _crew = crew _currentTank;
                    private _dist = _currentTank distance2D _pos;
                    
                    if ((count _crew) == 0 && {_dist <= 5}) then {
                        deleteVehicle _currentTank;
                        _currentTank = objNull;
                        _canReplace = true;
                    };
                } else {
                    _canReplace = true;
                };
                
                if (_canReplace) then {
                    private _class = if (_owner isEqualTo west) then { _bluforClass } else { _opforClass };
                    
                    _currentTank = createVehicle [_class, _pos, [], 0, "NONE"];
                    _currentTank setDir _dir;
                    _currentTank setPosATL _pos;
                    
                    _currentOwner = _owner;
                    
                    // Store in global array for reference
                    BNC_SectorTanks set [_index, [_currentTank, _currentOwner, _spawnName]];
                    publicVariable "BNC_SectorTanks";
                    
                    diag_log format ["[TANK SPAWN] Spawned %1 tank at %2", _owner, _spawnName];
                };
            };
            
            sleep _checkInterval;
        };
    };
} forEach _spawnConfigs;