// Killstreak\availableKillstreaks.sqf
private _availableKillstreaks = [];

_availableKillstreaks pushBack [
    "Recon UAV",
    {
        params ["_caller"];
        drop_Action_ReconUAV = _caller addAction [
            "Call Recon UAV",
            { _this execVM "Killstreak\recon_uav.sqf"; }
        ];
    }
];

_availableKillstreaks pushBack [
    "Gunship Support",
    {
        params ["_caller"];
        drop_Action_Gunship = _caller addAction [
            "Call Gunship Support",
            { _this execVM "Killstreak\gunship_support.sqf"; }
        ];
    }
];

_availableKillstreaks pushBack [
    "Airstrike",
    {
        params ["_caller"];
        drop_Action_Airstrike = _caller addAction [
            "Call Airstrike",
            { _this execVM "Killstreak\airstrike.sqf"; }
        ];
    }
];

_availableKillstreaks pushBack [
    "Daisy Cutter",
    {
        params ["_caller"];
        drop_Action_DaisyCutter = _caller addAction [
            "Call Daisy Cutter",
            { _this execVM "Killstreak\daisy_cutter.sqf"; }
        ];
    }
];

_availableKillstreaks pushBack [
    "Napalm Strike",
    {
        params ["_caller"];
        drop_Action_Napalm = _caller addAction [
            "Call Napalm Strike",
            { _this execVM "Killstreak\napalm_strike.sqf"; }
        ];
    }
];

_availableKillstreaks pushBack [
    "Attack Helicopter",
    {
        params ["_caller"];
        drop_Action_AttackHelo = _caller addAction [
            "Call Attack Helicopter Support",
            { _this execVM "Killstreak\attack_helo.sqf"; }
        ];
    }
    
];

_availableKillstreaks pushBack [
    "2x Care Packages",
    {
        params ["_caller"];
        drop_Action_CarePackages = _caller addAction [
            "Call 2x Care Packages",
            {
                params ["_target", "_caller", "_id", "_args"];
                _caller removeAction _id;
                [_caller] spawn {
                    params ["_unit"];
                    _unit execVM "Killstreak\care_package.sqf";
                    sleep 6;
                    _unit execVM "Killstreak\care_package.sqf";
                };
            }
        ];
    }
];

missionNamespace setVariable ["killstreakOptions", _availableKillstreaks];
