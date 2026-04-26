/**
    File: mobile_respawn\fn_initTeleport.sqf
    Author: TylenolVIP
    
    Description:
        Initializes teleport actions on mobile respawn signs.
    
    Usage:
        call MRS_fnc_initTeleport;
*/

{
    _x params ["_sign", "_side"];

    if (_sign getVariable ["MRS_teleportActionAdded", false]) then { continue };
    _sign setVariable ["MRS_teleportActionAdded", true];
    
    _sign addAction [
        "<t color='#FFFF00'>Command Tank</t>",
        {
            params ["_target", "_caller", "_actionId", "_args"];
            private _side = _args select 0;
            private _vehicle = [_side] call MRS_fnc_getVehicleForSide;

            if (isNull _vehicle || {!alive _vehicle}) exitWith {
                hint "Mobile respawn is unavailable right now.";
            };
            
            // Check if vehicle is moving
            private _pos1 = getPosATL _vehicle;
            uiSleep 0.2;
            private _pos2 = getPosATL _vehicle;
            
            if (_pos1 distance2D _pos2 > 0.1) then {
                ["CommandTankMoving"] call BIS_fnc_showNotification;
            } else {
                // Check tent status (hide_tent: 0 = deployed, 1 = stowed)
                if ((_vehicle animationPhase "hide_tent") == 0) then {
                    _caller moveInCargo _vehicle;
                } else {
                    ["CommandTankNotDeployed"] call BIS_fnc_showNotification;
                };
            };
        },
        [_side],
        1,
        false,
        true,
        "",
        "_this distance _target < 5"
    ];
} forEach MRS_teleportPairs;

diag_log "[Mobile Respawn] Teleport actions initialized";
