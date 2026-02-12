// save_loadout_box.sqf

if (hasInterface) then {
    private _boxes = [];
    private _index = 0;

    // Loop through Arsenal_box_0, _1, _2, ... until a missing one is found
    while { true } do {
        private _boxName = format ["Arsenal_box_%1", _index];
        if (isNil _boxName) exitWith {};
        private _box = missionNamespace getVariable [_boxName, objNull];
        if (!isNull _box) then { _boxes pushBack _box; };
        _index = _index + 1;
    };

    {
        _x addAction [
            "<t color='#00ff00'>Save Respawn Loadout</t>",
            {
                player setVariable ["savedLoadout", getUnitLoadout player, false];
                hint "Loadout saved!";
            },
            nil,
            2,
            true,
            true,
            "",
            "_this distance _target < 5"
        ];

        _x addAction [
            "<t color='#ffff00'>Clean Up</t>",
            {
                {
                    deleteVehicle _x;
                } forEach (nearestObjects [player, ["WeaponHolder", "GroundWeaponHolder"], 20]);
                hint "Nearby gear cleaned up.";
            },
            nil,
            2,
            false,
            true,
            "",
            "_this distance _target < 5"
        ];
    } forEach _boxes;
};
