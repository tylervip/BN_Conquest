/*
    Repack partial magazines for a single type
*/

params ["_mag"];

if (isNil "_mag" || _mag == "") exitWith {};

// Max bullets per mag
private _magMax = getNumber (configFile >> "CfgMagazines" >> _mag >> "count");
if (_magMax <= 1) exitWith {}; // skip single-bullet mags

// Count total bullets in partial magazines only
private _total = 0;
{
    if (_mag isEqualTo (_x select 0) && !(_x select 2)) then {
        _total = _total + (_x select 1);
    };
} forEach magazinesAmmoFull player;

if (_total <= 0) exitWith { hint "No partial mags to repack"; };

// Remove all partial mags
{
    if (_mag isEqualTo (_x select 0) && !(_x select 2)) then {
        player removeMagazine (_x select 0);
    };
} forEach magazinesAmmoFull player;

// Add full mags
for "_i" from 1 to floor (_total / _magMax) do {
    player addMagazine [_mag, _magMax];
};

// Add leftover partial mag
private _rem = _total % _magMax;
if (_rem > 0) then {
    player addMagazine [_mag, _rem];
};

// Show hint
hintSilent "Mags Repacked";
sleep 2;
hintSilent "";