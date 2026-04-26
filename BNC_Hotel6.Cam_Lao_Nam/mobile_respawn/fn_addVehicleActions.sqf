/**
    File: mobile_respawn\fn_addVehicleActions.sqf
    Author: TylenolVIP

    Description:
        Adds client-side actions to a mobile respawn vehicle.
*/

params ["_vehicle"];

if (!hasInterface) exitWith {};
if (isNull _vehicle) exitWith {};
if (_vehicle getVariable ["MRS_loadoutActionAdded", false]) exitWith {};

_vehicle setVariable ["MRS_loadoutActionAdded", true];

_vehicle addAction [
    "<t color='#00ff00'>Restore Loadout</t>",
    {
        if (player getVariable ["loadoutCooldown", 0] > time) exitWith {
            private _remaining = (player getVariable ["loadoutCooldown", 0]) - time;
            hint format ["Loadout restore on cooldown! %1 seconds remaining", ceil _remaining];
        };

        player setVariable ["loadoutCooldown", time + 60];
        player setUnitLoadout (player getVariable ["SavedLoadout", []]);
        hint "Loadout restored!";
    },
    nil,
    1.5,
    false,
    true,
    "",
    "_this distance _target < 5"
];
