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
private _tankCooldown = 180; // Cooldown in seconds after tank is destroyed

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
        private _sectorName = _nearestSector getVariable ["name", "Unknown Sector"];
        diag_log format ["[TANK SPAWN] %1 -> Sector: %2", _spawnName, _sectorName];
    } else {
        diag_log format ["[TANK SPAWN] WARNING: No sector found for %1", _spawnName];
    };
} forEach _allSpawnPoints;

// --- GLOBAL STORAGE ---
if (isNil "BNC_SectorTanks") then { BNC_SectorTanks = []; };

// --- SPAWN LOOP FOR EACH SPAWN POINT ---
{
    _x params ["_spawnPoint", "_sectorModule", "_spawnName"];
    
    [_spawnPoint, _sectorModule, _bluforClass, _opforClass, _spawnName, _forEachIndex, _tankCooldown] spawn {
        params ["_spawnPoint", "_sectorModule", "_bluforClass", "_opforClass", "_spawnName", "_index", "_tankCooldown"];
        
        private _currentTank = objNull;
        private _currentOwner = sideUnknown;
        private _tankDestroyTime = -1;
        
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
                _tankDestroyTime = time; // Record destroy time for cooldown
            };

            // Check if ownership changed
            if (_owner != _currentOwner && {_owner in [west, east]}) then {
                // Don't spawn if tank is on cooldown from being destroyed
                if (_tankDestroyTime == -1 || {time - _tankDestroyTime >= _tankCooldown}) then {
                    // Remove existing tank if any
                    if (!isNull _currentTank) then {
                        deleteVehicle _currentTank;
                        _currentTank = objNull;
                    };
                    // Spawn new tank for new owner
                    private _class = if (_owner isEqualTo west) then { _bluforClass } else { _opforClass };
                    _currentTank = createVehicle [_class, _pos, [], 0, "NONE"];
                    _currentTank setDir _dir;
                    _currentTank setPosATL _pos;
                    _currentOwner = _owner;
                    BNC_SectorTanks set [_index, [_currentTank, _currentOwner, _spawnName]];
                    diag_log format ["[TANK SPAWN] Ownership changed, spawned %1 tank at %2", _owner, _spawnName];
                };
            };

            // Check if tank needs to respawn after cooldown (no ownership change needed)
            if (_currentTank isEqualTo objNull && {_tankDestroyTime != -1} && {time - _tankDestroyTime >= _tankCooldown} && {_owner in [west, east]}) then {
                private _class = if (_owner isEqualTo west) then { _bluforClass } else { _opforClass };
                _currentTank = createVehicle [_class, _pos, [], 0, "NONE"];
                _currentTank setDir _dir;
                _currentTank setPosATL _pos;
                _currentOwner = _owner;
                BNC_SectorTanks set [_index, [_currentTank, _currentOwner, _spawnName]];
                diag_log format ["[TANK SPAWN] Cooldown expired, respawned %1 tank at %2", _owner, _spawnName];
            };
            
            sleep _checkInterval;
        };
    };
} forEach _spawnConfigs;