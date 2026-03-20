// Author: Savage Game Design
params
[
["_action","",[""]]
];
private _key_bind = [];
private _config = (missionConfigFile >> "gamemode" >> "keys" >> _action);
if (isClass _config) then
{
_defaultValue = [getNumber(_config >> "defaultKey"),getText(_config >> "shift"),getText(_config >> "ctrl"),getText(_config >> "alt")];
_key_bind = profileNamespace getVariable [_action, _defaultValue];
if !(_key_bind isEqualType []) then {_key_bind = _defaultValue};
};
_key_bind
