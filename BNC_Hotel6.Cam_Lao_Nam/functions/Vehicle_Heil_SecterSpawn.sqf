if (!isServer) exitWith {};

/*
    Vehicle_Heil_SecterSpawn.sqf
    Dynamically finds all Heil_SpawnPoint objects and determines
    which sector each one belongs to. Spawns a helicopter at each
    spawn point based on the owning side of the nearest sector.
    
    Spawn point naming: Heil_SpawnPoint_0, Heil_SpawnPoint_1, etc.
*/

// Wait for sectors to be initialized
waitUntil { count (allMissionObjects "ModuleSector_F") > 0 };
sleep 2; // Give sectors time to fully initialize

private _opforClass = "vn_o_air_mi2_04_01";
private _bluforClass = "vn_b_air_uh1c_04_01";
private _heliCooldown = 300; // Cooldown in seconds after helicopter is destroyed

// --- FIND ALL HELI SPAWN POINTS ---
// Search for all objects with variable names matching Heil_SpawnPoint pattern
private _allSpawnPoints = [];
private _i = 0;
while {true} do {
    private _varName = format ["Heil_SpawnPoint_%1", _i];
    private _obj = missionNamespace getVariable [_varName, objNull];
    if (isNull _obj) exitWith {};
    _allSpawnPoints pushBack [_obj, _varName];
    _i = _i + 1;
};

if (count _allSpawnPoints == 0) exitWith {
    diag_log "[HELI SPAWN] ERROR: No Heil_SpawnPoint objects found!";
};

diag_log format ["[HELI SPAWN] Found %1 helicopter spawn point(s)", count _allSpawnPoints];

// --- FIND NEAREST SECTOR FOR EACH SPAWN POINT ---
private _allSectors = allMissionObjects "ModuleSector_F";
private _spawnConfigs = [];

{
    _x params ["_spawnObj", "_spawnName"];
    private _spawnPos = getPos _spawnObj;
    
    // Find nearest sector to this spawn point
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
        diag_log format ["[HELI SPAWN] %1 -> Sector: %2", _spawnName, _sectorName];
    } else {
        diag_log format ["[HELI SPAWN] WARNING: No sector found for %1", _spawnName];
    };
} forEach _allSpawnPoints;

// --- GLOBAL STORAGE ---
if (isNil "BNC_SectorHelis") then { BNC_SectorHelis = []; };

// --- SPAWN LOOP FOR EACH SPAWN POINT ---
{
    _x params ["_spawnPoint", "_sectorModule", "_spawnName"];
    
    [_spawnPoint, _sectorModule, _bluforClass, _opforClass, _spawnName, _forEachIndex, _heliCooldown] spawn {
        params ["_spawnPoint", "_sectorModule", "_bluforClass", "_opforClass", "_spawnName", "_index", "_heliCooldown"];
        
        private _currentHeli = objNull;
        private _currentOwner = sideUnknown;
        private _heliDestroyTime = -1;
        
        while {true} do {
            private _pos = getPosATL _spawnPoint;
            private _dir = getDir _spawnPoint;
            private _owner = _sectorModule getVariable ["owner", sideUnknown];
            private _checkInterval = 20;
            
            // Check if current heli is destroyed
            if (!isNull _currentHeli && {!alive _currentHeli}) then {
                deleteVehicle _currentHeli;
                _currentHeli = objNull;
                _currentOwner = sideUnknown;
                _heliDestroyTime = time; // Record destroy time for cooldown
            };

            // Check if ownership changed
            if (_owner != _currentOwner && {_owner in [west, east]}) then {
                // Don't spawn if heli is on cooldown from being destroyed
                if (_heliDestroyTime == -1 || {time - _heliDestroyTime >= _heliCooldown}) then {
                    // Remove existing heli if any
                    if (!isNull _currentHeli) then {
                        deleteVehicle _currentHeli;
                        _currentHeli = objNull;
                    };
                    // Spawn new heli for new owner
                    private _class = if (_owner isEqualTo west) then { _bluforClass } else { _opforClass };
                    _currentHeli = createVehicle [_class, _pos, [], 0, "NONE"];
                    _currentHeli setDir _dir;
                    _currentHeli setPosATL _pos;
                    _currentOwner = _owner;
                    BNC_SectorHelis set [_index, [_currentHeli, _currentOwner, _spawnName]];
                    diag_log format ["[HELI SPAWN] Ownership changed, spawned %1 helicopter at %2", _owner, _spawnName];
                };
            };

            // Check if heli needs to respawn after cooldown (no ownership change needed)
            if (_currentHeli isEqualTo objNull && {_heliDestroyTime != -1} && {time - _heliDestroyTime >= _heliCooldown} && {_owner in [west, east]}) then {
                private _class = if (_owner isEqualTo west) then { _bluforClass } else { _opforClass };
                _currentHeli = createVehicle [_class, _pos, [], 0, "NONE"];
                _currentHeli setDir _dir;
                _currentHeli setPosATL _pos;
                _currentOwner = _owner;
                BNC_SectorHelis set [_index, [_currentHeli, _currentOwner, _spawnName]];
                diag_log format ["[HELI SPAWN] Cooldown expired, respawned %1 helicopter at %2", _owner, _spawnName];
            };
            
            sleep _checkInterval;
        };
    };
} forEach _spawnConfigs;