// Author: Savage Game Design
params
[
["_action","",[""]],
["_key",0,[0]],
["_shift",false],
["_ctrl",false],
["_alt",false]
];

private _old_key_data = profileNamespace getVariable [_action,[]];
if !(_old_key_data isEqualType []) then {_old_key_data = []};
if !(_old_key_data isEqualTo []) then
{
private _var_key = ["para_c_fnc_key"];
private _var_key_up = ["para_c_fnc_key_up"];
_var_key append _old_key_data;
_var_key_up append _old_key_data;
missionNamespace setVariable [(_var_key joinString "_"),nil];
missionNamespace setVariable [(_var_key_up joinString "_"),nil];
};

profileNamespace setVariable [_action,[_key,_shift,_ctrl,_alt]];

call para_c_fnc_init_key_down;
call para_c_fnc_init_key_up;
