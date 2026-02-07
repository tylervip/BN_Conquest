/**
	File: fn_check_side.sqf 
	Author: Adabou + TylenolVIP
	Public: Yoink 

	Description:
		Simple Test to see what side something belongs to 
		- Comparison Operation, True if same 

	Parameter(s):
		_player - Callee [Object]
		_target - Target to compare to Player [Object]
	
	Returns: 
		BOOL 
	
	Example(s):
		[_player, _target] call map_fnc_check_side
*/

params ["_player", "_target"];

private _playerSide = side _player;
private _targetSide = side _target;

if (_playerSide != _targetSide) exitWith {
	false
};

true