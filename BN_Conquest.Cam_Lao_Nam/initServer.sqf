// Register EHs for all existing units (AI + players)
{
    [_x] execVM "EventHandler\fn_registerEH.sqf";
} forEach allUnits;

[] execVM "functions\Vehicle_tank_SecterSpawn.sqf";
[] execVM "functions\Vehicle_Heil_SecterSpawn.sqf";