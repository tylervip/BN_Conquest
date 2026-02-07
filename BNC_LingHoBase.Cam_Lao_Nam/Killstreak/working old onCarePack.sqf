player removeAction drop_Action_CarePackage;
 // Reset care package flag
 _caller setVariable ["ks_carepackage_added", false, true];

if (hasInterface) then {
    // === Create and attach smoke grenade ===
    private _smoke = "SmokeShellPurple" createVehicle [0,0,0];
    _smoke attachTo [player, [0.1, 0.5, 0.1], "RightHand"];
    player setVariable ["carePackageSmoke", _smoke];

    // === Show prompt ===
    ["<t color='#FF6600' size='1.2'>Throw Care Package Smoke</t>", 0, 0.8, 2, 0, 0, 6017] spawn BIS_fnc_dynamicText;

    // === Define crate drop logic ===
    player setVariable ["dropCarePackage", {
        params ["_smoke"];

        waitUntil { !isNull _smoke && (getPosATL _smoke select 2) < 0.2 };
        sleep 1;

        private _posASL = getPosASL _smoke vectorAdd [0, 0, 100];

        // === Create parachute and crate ===
        private _chute = "B_Parachute_02_F" createVehicle [0,0,0];
        _chute setPosASL _posASL;

        private _crate = "vn_b_ammobox_supply_05" createVehicle [0,0,0];
        _crate attachTo [_chute, [0,0,0]];
        _crate setVectorUp [0, 0, 0.2];
        _crate setVelocityModelSpace [0, 0, -10];
        _crate allowDamage false;

        // === Smoke on crate ===
        private _crateSmoke = "SmokeShellPurple" createVehicle [0,0,0];
        _crateSmoke attachTo [_crate, [0,0,0.3]];
        _crate setDir random 360;

        // === Detach when close to ground ===
        [_crate] spawn {
            params ["_crate"];
            waitUntil {
                sleep 0.1;
                (getPosATL _crate select 2) < 2
            };
            detach _crate;
        };

        // Load available killstreaks before adding action
        [] call compile preprocessFileLineNumbers "Killstreak\availableKillstreaks.sqf";

        private _ksList = missionNamespace getVariable ["killstreakOptions", []];
        if (_ksList isEqualTo []) exitWith { hint "No killstreaks available."; };

        private _selectedKS = selectRandom _ksList;
        private _ksName = _selectedKS select 0;
        private _ksFunc = _selectedKS select 1;

        // Add killstreak claim action to crate
        [_crate, _ksName, _ksFunc] spawn {
            params ["_crate", "_ksName", "_ksFunc"];

            waitUntil {
                !isNull _crate &&
                !isNull player &&
                player distance _crate < 5
            };

            _crate addAction [
                format ["Claim: %1", _ksName],
                {
                    params ["_crate", "_caller", "_id", "_args"];
                    _caller removeAction _id;

                    [_caller] call _args; //_args call [_caller]; //tryed _args call _caller;

                    deleteVehicle _crate;
                },
                _ksFunc,
                1.5, true, true, "", "true", 3, false
            ];
        };
    }];
    
    // === Add player action to throw smoke ===
    drop_Action_CarePackage = player addAction [
        "Throw Smoke for Care Package",
        {
            params ["_target", "_caller", "_id", "_args"];

            private _smoke = _caller getVariable ["carePackageSmoke", objNull];
            if (!isNull _smoke) then {
                detach _smoke;

                private _dir = getDir _caller;
                _smoke setVelocity [
                    sin(_dir) * 10,
                    cos(_dir) * 10,
                    3
                ];

                [_smoke] spawn (_caller getVariable "dropCarePackage");

                _caller removeAction _id;
                _caller setVariable ["carePackageSmoke", nil];
            } else {
                hint "Smoke grenade not found!";
            };
        },
        nil,
        1,
        true,
        true,
        "",
        "true",
        3,
        false
    ];

    // === Auto-drop after 10s if unused ===
    [_smoke, player] spawn {
        params ["_smoke", "_unit"];
        sleep 10;
        if (!isNull _smoke && attachedTo _smoke == _unit) then {
            detach _smoke;
            [_smoke] spawn (_unit getVariable "dropCarePackage");
            _unit removeAction drop_Action_CarePackage;
            _unit setVariable ["carePackageSmoke", nil];
        };
    };
};


