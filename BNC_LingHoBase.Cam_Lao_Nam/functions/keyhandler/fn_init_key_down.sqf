// Author: Savage Game Design
{
private _var_key = ["para_c_fnc_key"];
private _var_key_data = profileNamespace getVariable [configName _x,[getNumber(_x >> "defaultKey"),getText(_x >> "shift"),getText(_x >> "ctrl"),getText(_x >> "alt")]];
if (_var_key_data isEqualType 0) then
{
_var_key_data = [getNumber(_x >> "defaultKey"),getText(_x >> "shift"),getText(_x >> "ctrl"),getText(_x >> "alt")];
profileNamespace setVariable [configName _x,_var_key_data];
};
_var_key append _var_key_data;
missionNamespace setVariable [(_var_key joinString "_"),getText(_x >> "function")];
} forEach ("getNumber(_x >> 'down') == 1" configClasses (missionConfigFile >> "gamemode" >> "keys"));
