// Author: Savage Game Design
params
[
"_displayorcontrol",
"_dikcode",
"_shift",
"_ctrl",
"_alt"
];

private _return = false;

private _var_key = ["para_c_fnc_key"];
_var_key append [_dikcode,_shift,_ctrl,_alt];

para_keydown_shift = _shift;
para_keydown_ctrl = _ctrl;
para_keydown_alt = _alt;

private _fnc_name = missionNamespace getVariable [(_var_key joinString "_"),""];
if !(_fnc_name isEqualTo "") then
{
private _fnc = missionNamespace getVariable [_fnc_name,{}];
_return = if !(_fnc isEqualTo {}) then _fnc;
};
_return
