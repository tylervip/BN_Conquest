if (hasInterface) then {
    [] spawn {
        // Create and attach fake smoke grenade
        private _smoke = "SmokeShellRed" createVehicle [0,0,0];
        _smoke attachTo [player, [0.1, 1.1, 0.1], "RightHand"];

        // Show prompt
        ["<t color='#FF6600' size='1.2'>Hold to Throw Care Package Smoke</t>", 0, 0.8, 2, 0, 0, 7017] spawn BIS_fnc_dynamicText;

        // Add HoldAction to grenade
        _smoke addAction [
            "Throw Smoke for Care Package",
            {
                params ["_target", "_caller", "_id", "_args"];
                detach _target;

                private _dir = getDir _caller;
                _target setVelocity [
                    sin(_dir) * 10,
                    cos(_dir) * 10,
                    3
                ];

                // Spawn crate after it lands
                [_target] spawn {
                    params ["_smoke"];
                    waitUntil { isTouchingGround _smoke };
                    sleep 1;

                    private _pos = getPos _smoke;
                    deleteVehicle _smoke;

                    private _crate = "Box_NATO_Ammo_F" createVehicle _pos;
                    _crate setDir random 360;
                };
            },
            nil,  // no args
            1.5,  // priority
            true,  // showWindow
            true,  // hideOnUse
            "",  // condition
            "true",  // statement
            3,  // duration to hold
            false  // removeOnCompletion
        ];
    };
};
