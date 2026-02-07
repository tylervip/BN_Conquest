// === Reset reward flags ===
player setVariable ["ks_napalm_added", false];
player setVariable ["ks_daisy_added", false];
player setVariable ["ks_gunship_added", false];
player setVariable ["ks_airstrike_added", false];
player setVariable ["ks_attackhelo_added", false];
player setVariable ["ks_reconuav_added", false];
player setVariable ["ks_carepackage_added", false];

[] spawn {
    while {true} do {
        uiSleep 1;

        private _kills = player getVariable ["killCount", 0];

        if (_kills >= 5 && !(player getVariable ["ks_reconuav_added", false])) then {
            player setVariable ["ks_reconuav_added", true];
            drop_Action_ReconUAV = player addAction [
                "Call Recon UAV",
                { _this execVM "Killstreak\recon_uav.sqf"; },
                nil, 1.5, true, false, "", "_this == _target"
            ];
        };

        if (_kills >= 15 && !(player getVariable ["ks_gunship_added", false])) then {
            player setVariable ["ks_gunship_added", true];
            drop_Action_Gunship = player addAction [
                "Call Gunship Support",
                { _this execVM "Killstreak\gunship_support.sqf"; },
                nil, 1.5, true, false, "", "_this == _target"
            ];
        };

        if (_kills >= 1000 && !(player getVariable ["ks_airstrike_added", false])) then {
            player setVariable ["ks_airstrike_added", true];
            drop_Action_Airstrike = player addAction [
                "Call Air Strike",
                { _this execVM "Killstreak\airstrike.sqf"; },
                nil, 1.5, true, false, "", "_this == _target"
            ];
        };

        if (_kills >= 30 && !(player getVariable ["ks_daisy_added", false])) then {
            player setVariable ["ks_daisy_added", true];
            drop_Action_DaisyCutter = player addAction [
                "Call Daisy Cutter",
                { _this execVM "Killstreak\daisy_cutter.sqf"; },
                nil, 1.5, true, false, "", "_this == _target"
            ];
        };

        if (_kills >= 20 && !(player getVariable ["ks_napalm_added", false])) then {
            player setVariable ["ks_napalm_added", true];
            drop_Action_Napalm = player addAction [
                "Call Napalm Strike",
                { _this execVM "Killstreak\napalm_strike.sqf"; },
                nil, 1.5, true, false, "", "_this == _target"
            ];
        };

        if (_kills >= 18 && !(player getVariable ["ks_attackhelo_added", false])) then {
            player setVariable ["ks_attackhelo_added", true];
            drop_Action_AttackHelo = player addAction [
                "Call Attack Helicopter Support",
                { _this execVM "Killstreak\attack_helo.sqf"; },
                nil, 1.5, true, false, "", "_this == _target"
            ];
        };

        if (_kills >= 7 && !(player getVariable ["ks_carepackage_added", false])) then {
            player setVariable ["ks_carepackage_added", true];
            drop_Action_CarePackage = player addAction [
                "Call Care Package",
                { [] execVM "Killstreak\care_package.sqf"; },
                nil, 1.5, true, false, "", "_this == _target"
            ];
        };
    };
};

// === Reset flags on player death ===
player addEventHandler ["Killed", {
    player setVariable ["killCount", 0, true];
    player setVariable ["ks_napalm_added", false, true];
    player setVariable ["ks_daisy_added", false, true];
    player setVariable ["ks_gunship_added", false, true];
    player setVariable ["ks_airstrike_added", false, true];
    player setVariable ["ks_attackhelo_added", false, true];
    player setVariable ["ks_reconuav_added", false, true];
    player setVariable ["ks_carepackage_added", false, true];
}];
