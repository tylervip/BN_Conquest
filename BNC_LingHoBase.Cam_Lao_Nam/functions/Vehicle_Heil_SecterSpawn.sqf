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
        diag_log format ["[HELI SPAWN] %1 -> Sector at %2 (distance: %3m)", _spawnName, getPos _nearestSector, round _nearestDist];
    } else {
        diag_log format ["[HELI SPAWN] WARNING: No sector found for %1", _spawnName];
    };
} forEach _allSpawnPoints;

// --- GLOBAL STORAGE ---
if (isNil "BNC_SectorHelis") then { BNC_SectorHelis = []; };

// --- SPAWN LOOP FOR EACH SPAWN POINT ---
{
    _x params ["_spawnPoint", "_sectorModule", "_spawnName"];
    
    [_spawnPoint, _sectorModule, _bluforClass, _opforClass, _spawnName, _forEachIndex] spawn {
        params ["_spawnPoint", "_sectorModule", "_bluforClass", "_opforClass", "_spawnName", "_index"];
        
        private _currentHeli = objNull;
        private _currentOwner = sideUnknown;
        
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
                _checkInterval = 300; // Cooldown for destroyed helicopter
            };
            
            // Check if ownership changed
            if (_owner != _currentOwner && {_owner in [west, east]}) then {
                private _canReplace = false;
                
                // Check if any living unit or vehicle is within 5 meters of spawn point
                private _nearUnits = nearestObjects [_pos, ["Man", "Vehicle"], 5];
                _nearUnits = _nearUnits select {alive _x};
                if (count _nearUnits > 0) exitWith {};
                
                if (!isNull _currentHeli) then {
                    private _crew = crew _currentHeli;
                    private _dist = _currentHeli distance2D _pos;
                    
                    if ((count _crew) == 0 && {_dist <= 2}) then {
                        deleteVehicle _currentHeli;
                        _currentHeli = objNull;
                        _canReplace = true;
                    };
                } else {
                    _canReplace = true;
                };
                
                if (_canReplace) then {
                    private _class = if (_owner isEqualTo west) then { _bluforClass } else { _opforClass };
                    
                    _currentHeli = createVehicle [_class, _pos, [], 0, "NONE"];
                    _currentHeli setDir _dir;
                    _currentHeli setPosATL _pos;
                    
                    _currentOwner = _owner;
                    
                    // Store in global array for reference
                    BNC_SectorHelis set [_index, [_currentHeli, _currentOwner, _spawnName]];
                    publicVariable "BNC_SectorHelis";
                    
                    diag_log format ["[HELI SPAWN] Spawned %1 helicopter at %2", _owner, _spawnName];
                };
            };
            
            sleep _checkInterval;
        };
    };
} forEach _spawnConfigs;