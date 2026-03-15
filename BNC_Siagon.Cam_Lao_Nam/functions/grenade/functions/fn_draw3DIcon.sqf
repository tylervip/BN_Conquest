/*
Description:
	Draw 3D icon (Vanilla version - No CBA/ACE required)

Parameters:
	None

Return:
	None

Example:
	call LEON_COD_fnc_draw3DIcon;

Author: leonz2020
Modified: Removed CBA/ACE dependencies for vanilla Arma 3
*/

if (!isNil "LEON_COD_3DIconID") exitWith {};

// Icon settings - Grenade icon white for pickup
if (isNil "LEON_COD_ColorPickUp") then { LEON_COD_ColorPickUp = [1, 1, 1, 1] };
if (isNil "LEON_COD_SizePickUp") then { LEON_COD_SizePickUp = 1 };

// Icon settings - Grenade warning icon red for nearby grenades
if (isNil "LEON_COD_ColorGrenade") then { LEON_COD_ColorGrenade = [0.94, 0.24, 0.24, 1] };
if (isNil "LEON_COD_SizeGrenade") then { LEON_COD_SizeGrenade = 1 };

LEON_COD_3DIconID = addMissionEventHandler ["Draw3D", {
	if (vehicle player == player && !isNil "LEON_COD_PickableGrenades" && {count LEON_COD_PickableGrenades > 0} && {[player] call LEON_COD_fnc_isUnitAwake && LEON_COD_PickableGrenades findIf { isNull (attachedTo _x) && alive _x && player distance _x <= 3 && vectorMagnitude velocity _x <= 10 && !lineIntersects [eyePos player, getPosASLVisual _x vectorAdd [0,0,(sizeOf (typeOf _x)) / 2], player, _x] } != -1 }) then {
		private _grenade = player getVariable ["LEON_COD_pickedGrenade", objNull];
		{
			_zoom = round ((([0.5, 0.5] distance2D (worldToScreen (positionCameraToWorld [0, 3, 2]))) * (getResolution select 5) / 2) * 10);
			_dir = round ([player, _x] call BIS_fnc_relativeDirTo);
			_dis = 3 / _zoom;
			_pos = [0,0,0];
			switch (true) do
			{
				case (_dir == 0):
				{
					_pos = [0, _dis, 2];
				};
				case (_dir == 90):
				{
					_pos = [_dis, 0, 2];
				};
				case (_dir == 180):
				{
					_pos = [0, -_dis, 2];
				};
				case (_dir == 270):
				{
					_pos = [-_dis, 0, 2];
				};
				default
				{
					if ((_dir > 90 && _dir < 180) || (_dir > 270 && _dir < 360)) then
					{
						_pos = [(cos (_dir % 90)) * _dis, (sin (_dir % 90)) * _dis, 2];
					} else {
						_pos = [(sin (_dir % 90)) * _dis, (cos (_dir % 90)) * _dis, 2];
					};
					if (_dir > 180) then { _pos set [0, (_pos select 0) * (-1)] };
					if (_dir > 90 && _dir < 270) then { _pos set [1, (_pos select 1) * (-1)] };
				};
			};
			_iconPos = positionCameraToWorld _pos;
			_color = LEON_COD_ColorGrenade;
			_size = LEON_COD_SizeGrenade;
			
			// First grenade in list and player doesn't have one picked up - show white Grenade icon
			if (_forEachIndex == 0 && isNull _grenade) then
			{
				_color = LEON_COD_ColorPickUp;
				_size = LEON_COD_SizePickUp;
			};
			drawIcon3D [getMissionPath "functions\grenade\icon\grenade.paa", _color, _iconPos, _size, _size, 0, "", 2]; 
		} forEach LEON_COD_PickableGrenades;
	};
}];