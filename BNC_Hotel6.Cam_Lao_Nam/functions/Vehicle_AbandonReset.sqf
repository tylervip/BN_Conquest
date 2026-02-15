/*  
==================================================================================================================
  Simple Vehicle Respawn Script v1.81 for Arma 3
  by Tophe of Östgöta 
  tweaked by Tylervip
  
  Put this in the vehicles init line:
  veh = [this] execVM "vehicle.sqf"

  
  Options:
  There are some optional settings. The format for these are:
  veh = [object, Delay, Deserted timer] execVM "vehicle.sqf"
  
  Default respawn delay is 30 seconds, to set a custom respawn delay time, put that in the init as well. 
  Like this:
  veh = [this, 15] execVM "vehicle.sqf"

  Default respawn time when vehicle is deserted, but not destroyed is 120 seconds. To set a custom timer for this 
  first set respawn delay, then the deserted vehicle timer. (0 = disabled) 
  Like this:  
  veh = [this, 15, 10] execVM "vehicle.sqf"
  
  Default values of all settings are:
  veh = [this, 30, 120] execVM "vehicle.sqf"
  
    
Contact & Bugreport: cwadensten@gmail.com
================================================================================================================== */
  
if (!isServer) exitWith {};

// Define variables
_unit = [_this,0,objNull,[objNull]] call BIS_fnc_param;
_delay = [_this,1,30,[0]] call BIS_fnc_param;
_deserted = [_this,2,120,[0]] call BIS_fnc_param;

// Set defaults for removed parameters
_respawns = 0;
_explode = false;
_dynamic = false;
_haveinit = false;

_hasname = false;
_unitname = vehicleVarName _unit;
if (isNil _unitname) then {_hasname = false;} else {_hasname = true;};
_run = true;

if (_delay < 0) then {_delay = 0};
if (_deserted < 0) then {_deserted = 0};

_dir = getDir _unit;
_position = getPosASL _unit;
_type = typeOf _unit;
_dead = false;
_nodelay = false;


// Start monitoring the vehicle
while {_run} do 
{   
    sleep (2 + random 10);
    if ((getDammage _unit > 0.8) and ({alive _x} count crew _unit == 0)) then {_dead = true};

    // Check if the vehicle is deserted.
    if (_deserted > 0) then
    {
        if ((getPosASL _unit distance _position > 5) and ({alive _x} count crew _unit == 0) and (getDammage _unit < 0.8)) then 
        {
            _timeout = time + _deserted;
            sleep 0.1;
            waitUntil {_timeout < time or !alive _unit or {alive _x} count crew _unit > 0};

            if ({alive _x} count crew _unit > 0) then {_dead = false}; 
            if ({alive _x} count crew _unit == 0) then {_dead = true; _nodelay =true}; 
            if !(alive _unit) then {_dead = true; _nodelay = false}; 
        };
    };

    // Respawn vehicle
    if (_dead) then 
    {   
        if (_nodelay) then {sleep 0.1; _nodelay = false;} else {sleep _delay;};
        sleep 0.1;

        deleteVehicle _unit;
        sleep 2;
        _unit = _type createVehicle _position;
        _unit setPosASL _position;
        _unit setDir _dir;
        if (["B_UAV", _type] call BIS_fnc_inString) then { createVehicleCrew _unit; };

        if (_hasname) then 
        {
            _unit setVehicleVarName _unitname;
            _unit call compile format ["%1=_This; PublicVariable '%1'",_unitname];
        };  
        _dead = false;
    };
};