/*
    fn_repackAllMags.sqf
    Repacks all partial magazines in player inventory
    Called from init_magRepack.sqf
*/

private _repacked = [];
{
    private _mag = _x select 0;
    private _ammo = _x select 1;
    private _isLoaded = _x select 2;
    private _magMax = getNumber (configFile >> "CfgMagazines" >> _mag >> "count");
    
    if (!_isLoaded && _ammo > 0 && _ammo < _magMax && _magMax > 1) then {
        if !(_mag in _repacked) then {
            [_mag] call functions_fnc_ammo_repack;
            _repacked pushBack _mag;
        };
    };
} forEach magazinesAmmoFull player;
