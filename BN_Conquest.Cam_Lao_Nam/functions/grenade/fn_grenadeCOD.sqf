private _grenadeClasses = [
    "HandGrenade_Stone",
    "HandGrenade",
    "MiniGrenade",
    "SmokeShell",
    "SmokeShellYellow",
    "SmokeShellGreen",
    "SmokeShellRed",
    "SmokeShellPurple",
    "SmokeShellOrange",
    "SmokeShellBlue",
    "Chemlight_green",
    "Chemlight_red",
    "Chemlight_yellow",
    "Chemlight_blue",
    "B_IR_Grenade",
    "O_IR_Grenade",
    "I_IR_Grenade",
    "O_R_IR_Grenade",
    "I_E_IR_Grenade",
    "vn_rdg2_mag",
    "vn_molotov_grenade_mag",
    "vn_f1_grenade_mag",
    "vn_rg42_grenade_mag",
    "vn_rgd5_grenade_mag",
    "vn_rgd33_grenade_mag",
    "vn_rkg3_grenade_mag",
    "vn_t67_grenade_mag",
    "vn_chicom_grenade_mag",
    "vn_m18_purple_mag",
    "vn_m18_red_mag",
    "vn_m18_yellow_mag",
    "vn_m18_white_mag",
    "vn_m18_green_mag",
    "vn_m34_grenade_mag",
    "vn_m14_grenade_mag",
    "vn_m14_early_grenade_mag",
    "vn_m7_grenade_mag",
    "vn_m61_grenade_mag",
    "vn_v40_grenade_mag",
    "vn_m67_grenade_mag",
    "vn_satchelcharge_02_throw_mag"
];

if (!isNil "LEON_GRENADE_ICON_ID") then { removeMissionEventHandler ["Draw3D", LEON_GRENADE_ICON_ID]; };

LEON_GRENADE_ICON_ID = addMissionEventHandler ["Draw3D",
{
    if ((vehicle player != player) || (lifeState player == "INCAPACITATED" && incapacitatedState player == "UNCONSCIOUS")) exitWith
    {
        LEON_PICKABLE_GRENADE = [];
        if (!isNil "LEON_GRENADE_ICON_ID") then { removeMissionEventHandler ["Draw3D", LEON_GRENADE_ICON_ID]; };
    };

    // Filter grenades by class, attached, alive, distance, velocity, and line of sight
    LEON_PICKABLE_GRENADE = nearestObjects [player, _grenadeClasses, 3]; 
    LEON_PICKABLE_GRENADE = LEON_PICKABLE_GRENADE select { isNull attachedTo _x && alive _x && (player distance _x) <= 3 && (vectorMagnitude velocity _x) <= 10 && !lineIntersects [eyePos player, getPosASLVisual _x vectorAdd [0,0,(sizeOf (typeOf _x)) / 2], player, _x] };

    if (count LEON_PICKABLE_GRENADE == 0) exitWith
    {
        LEON_PICKABLE_GRENADE = [];
        if (!isNil "LEON_GRENADE_ICON_ID") then { removeMissionEventHandler ["Draw3D", LEON_GRENADE_ICON_ID]; };
    };

    {
        private _zoom = round ((([0.5, 0.5] distance2D (worldToScreen (positionCameraToWorld [0, 3, 2]))) * (getResolution select 5) / 2) * 10);
        private _dir = round ([player, _x] call BIS_fnc_relativeDirTo);
        private _dis = 3 / _zoom;
        private _pos = [0,0,0];
        switch (true) do
        {
            case (_dir == 0):    { _pos = [0, _dis, 2]; };
            case (_dir == 90):   { _pos = [_dis, 0, 2]; };
            case (_dir == 180):  { _pos = [0, -_dis, 2]; };
            case (_dir == 270):  { _pos = [-_dis, 0, 2]; };
            default
            {
                if ((_dir > 90 && _dir < 180) || (_dir > 270 && _dir < 360)) then
                {
                    _pos = [(cos (_dir % 90)) * _dis, (sin (_dir % 90)) * _dis, 2];
                } else {
                    _pos = [(sin (_dir % 90)) * _dis, (cos (_dir % 90)) * _dis, 2];
                };
                if (_dir > 180) then { _pos set [0, (_pos select 0) * (-1)]; };
                if (_dir > 90 && _dir < 270) then { _pos set [1, (_pos select 1) * (-1)]; };
            };
        };
        private _iconPos = positionCameraToWorld _pos;
        private _text = "";
        if (_forEachIndex == 0 && isNull LEON_PICKED_GRENADE) then
        {
            _text = "Shift + G";
        };
        drawIcon3D [getMissionPath "functions\grenade\grenade.paa", [0.94,0.24,0.24,1], _iconPos, 2.5, 2.5, 0, _text, 2];
    } forEach LEON_PICKABLE_GRENADE;
}];
