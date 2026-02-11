// Killstreak\care_package.sqf

if (!hasInterface || !isPlayer player) exitWith {};

waitUntil { !isNull player && time > 0 };
sleep 0.1;

// Remove old action if any
player removeAction drop_Action_CarePackage;

// Create smoke grenade and attach to player's right hand
private _smoke = createVehicle ["vn_m18_purple_ammo", [0, 0, 0], [], 0, "NONE"];
_smoke attachTo [player, [-0.1, 0.2, 0], "RightHand"];
player setVariable ["carePackageSmoke", _smoke];

// Show prompt
["<t color='#FF6600' size='1.2'>Throw Care Package Smoke</t>", 0, 0.8, 2, 0, 0, 6017] spawn BIS_fnc_dynamicText;

// Store function to remoteExec later
player setVariable ["dropCarePackage", {
    params ["_smoke"];
    [_smoke, player] remoteExec ["killstreak_fnc_spawnCarePackage", 2];
}];

// Add action to throw smoke manually
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
    10,
    true,
    true,
    "",
    "true",
    3,
    false
];

// Auto-throw after 5 seconds
[_smoke, player] spawn {
    params ["_smoke", "_unit"];
    sleep 5;
    if (!isNull _smoke && attachedTo _smoke == _unit) then {
        detach _smoke;
        [_smoke] spawn (_unit getVariable "dropCarePackage");
        _unit removeAction drop_Action_CarePackage;
        _unit setVariable ["carePackageSmoke", nil];
        _unit setVariable ["ks_carepackage_added", true, true];
    };
};
