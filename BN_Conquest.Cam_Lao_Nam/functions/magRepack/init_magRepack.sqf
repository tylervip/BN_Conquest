/*
    init_magRepack.sqf
    Adds "Repack Ammo" action to player when they have partial magazines
    Call from initPlayerLocal.sqf via: [] execVM "functions\magRepack\init_magRepack.sqf";
*/

[] spawn {
    waitUntil { !isNull player };
    sleep 1;

    // Add action to player
    player addAction [
        "<t color='#ffff00'>Repack Ammo</t>",
        { [] call functions_fnc_repackAllMags; },
        nil,
        1.5,
        false,
        true,
        "",
        "({_x select 1 > 0 && _x select 1 < getNumber (configFile >> 'CfgMagazines' >> (_x select 0) >> 'count') && !(_x select 2)} count (magazinesAmmoFull _this)) > 1",
        3
    ];
};


