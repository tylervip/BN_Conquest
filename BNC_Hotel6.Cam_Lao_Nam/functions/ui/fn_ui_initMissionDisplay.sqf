// Author: Savage Game Design
#define CONFIG_CLASS_VAR "BIS_fnc_initDisplay_configClass"

params
[
["_mode", "", [""]],
["_params", []],
["_class", "", [""]],
["_path", "default", [""]],
["_register", true, [true, 0]]
];

_display = _params param [0, displayNull];
if (isNull _display) exitWith {nil};

if (_register isEqualType true) then {_register = parseNumber _register};
if (_register > 0) then
{
_varDisplays = _path + "_displays";
_displays = (uiNamespace getVariable [_varDisplays, []]) - [displayNull];

if (_mode == "onLoad") exitWith
{
_display setVariable [CONFIG_CLASS_VAR, _class];
uiNamespace setVariable [_class, _display];
_displays pushBackUnique _display;
uiNamespace setVariable [_varDisplays, _displays];
};

if (_mode == "onUnload") exitWith
{
_displays = _displays - [_display];
uiNamespace setVariable [_varDisplays, _displays];
};
};

[_mode, _params, _class] call (missionNamespace getVariable ("para_c_fnc_" + _class));
nil
