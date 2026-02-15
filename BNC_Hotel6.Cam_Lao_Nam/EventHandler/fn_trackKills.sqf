//fn_trackKills.sqf
params ["_unit", "_killer"];

// Reset streak if a player dies
if (isPlayer _unit) then {
    _unit setVariable ["killCount", 0, true];
};

// Exit if killer is null or suicide
if (isNull _killer) exitWith {};

// Only track kills between opposing sides
if (side group _killer == side group _unit) exitWith {};

// Get display names (fallback to classname for unnamed AI)
private _killerName = if (isPlayer _killer) then {
    name _killer
} else {
    format ["(AI)", name _killer]
};

private _victimName = if (isPlayer _unit) then {
    name _unit
} else {
    format ["(AI)", name _unit]
};

// Determine color (Red = East, Blue = West, Gray = Other)
private _getColor = {
    params ["_unit"];
    switch (side group _unit) do {
        case east: { "#FF0000" };
        case west: { "#0000FF" };
        default { "#AAAAAA" };
    };
};
private _killerColor = [_killer] call _getColor;
private _victimColor = [_unit] call _getColor;

// Show global kill feed this is the hint one
private _killFeed = if (_killer == _unit) then {
    parseText format ["<t color='%1'>%2</t> killed themselves", _killerColor, _killerName];
} else {
    parseText format [
        "<t color='%1'>%2</t> killed <t color='%3'>%4</t>",
        _killerColor, _killerName,
        _victimColor, _victimName
    ];
};
//[_killFeed] remoteExec ["hintSilent", 0];

// Killstreak tracking only for player killers
if (isPlayer _killer && _killer != _unit) then {
    private _kills = _killer getVariable ["killCount", 0];
    private _newKills = _kills + 1;
    _killer setVariable ["killCount", _newKills, true];
    
    // Calculate distance with fallback
    private _meters = if (!isNull _killer && !isNull _unit) then { round (_killer distance (getPos _unit)) } else { "unknown" };
    private _distanceText = if (_meters isEqualTo "unknown") then { "unknown distance" } else { format ["%1 m", _meters] };

    private _popupMessage = format ["<t color='#FF9900' size='0.6'>Killstreak: %1</t>", _newKills];
    [_popupMessage, 0.3, 0.7, 3, 0, 1, 7017] remoteExec ["BIS_fnc_dynamicText", _killer];

    // Select random kill verb
    private _killVerbs = ["fragged", "eliminated", "neutralized", "wasted", "dropped", "smoked", "taken out", "blasted", "downed", "terminated", "annihilated", "zapped", "crushed", "killed"];
    private _killVerb = selectRandom _killVerbs;

    //kill fead left side
    private _fragMessage = format [
        "<t size='0.5'><t color='%1'>%2</t> %5 <t color='%3'>%4</t> from %6 away</t>",
        _killerColor, _killerName,
        _victimColor, _victimName,
        _killVerb,
        _distanceText
    ];
    //[_fragMessage, -0.95, 0, 5, 0, 0, 7015] remoteExec ["BIS_fnc_dynamicText", 0];
    [format ["%1 %2 %3 from %4 away", _killerName, _killVerb, _victimName, _distanceText]] remoteExec ["systemChat", -2];
};