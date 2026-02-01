if (hasInterface) then {
    private _createMarkerForVehicle = {
        params ["_vehicle", "_markerName", "_side"];

        if (side player != _side) exitWith {};

        private _marker = createMarkerLocal [_markerName, getPos _vehicle];
        _marker setMarkerShapeLocal "ICON";
        _marker setMarkerTypeLocal "b_hq";
        _marker setMarkerSizeLocal [1, 1];
        _marker setMarkerColorLocal (switch (_side) do {
            case west: {"ColorWEST"};
            case east: {"ColorEAST"};
            case independent: {"ColorGUER"};
            default {"ColorUNKNOWN"};
        });
        _marker setMarkerAlphaLocal 0;

        _vehicle setVariable ["sideMarker", _marker];

        // Keep updating position
        [_vehicle, _marker] spawn {
            params ["_veh", "_mrk"];
            while {alive _veh} do {
                _mrk setMarkerPosLocal (getPos _veh);
                uiSleep 1;
            };
            deleteMarkerLocal _mrk;
        };

        // Add animation event handler
        _vehicle addEventHandler ["AnimChanged", {
            params ["_unit", "_animSource", "_phase"];

            if (_unit animationPhase 'hide_tent' == 1) then {
                private _marker = _unit getVariable ["sideMarker", ""];
                if (_marker isEqualTo "") exitWith {};

                if (_phase == 0) then {
                    _marker setMarkerAlphaLocal 1;
                } else {
                    _marker setMarkerAlphaLocal 0;
                };
            };
        }];

        // Initial state
        if (_vehicle animationPhase "hide_tent" == 0) then {
            _marker setMarkerAlphaLocal 1;
        };
    };

    // Setup for both vehicles
    if (!isNil "mobile_respawn" && {!isNull mobile_respawn}) then {
        [mobile_respawn, "marker_blu", west] call _createMarkerForVehicle;
    };

    if (!isNil "mobile_respawn_1" && {!isNull mobile_respawn_1}) then {
        [mobile_respawn_1, "marker_red", east] call _createMarkerForVehicle;
    };
};
