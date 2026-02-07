// earplug toggle keybind using User7
// earplugs.sqf

[] spawn {
    waitUntil { !isNull player };
    sleep 2;

    // Reminder loop every 10 minutes, starting immediately
    [] spawn {
        while {true} do {
            systemChat "To toggle earplugs, go to Options > Controls > Custom Controls, and bind User Action 7 to a key.";
            sleep 600; // 10 minutes
        };
    };

    // Define earplug toggle function
    vn_toggleEarplugs = {
        private _status = !(localNamespace getVariable ["vn_mf_earplugs", false]);
        localNamespace setVariable ["vn_mf_earplugs", _status];
        systemChat localize (["STR_VN_QOL_EARPLUGS_OUT", "STR_VN_QOL_EARPLUGS_IN"] select _status);
        0.5 fadeSound ([1, 0.2] select _status);
    };

    // Set up earplug toggle with cooldown
    vn_earplugCooldown = 0;

    addMissionEventHandler ["EachFrame", {
        if (inputAction "User7" > 0 && {time > vn_earplugCooldown}) then {
            [] call vn_toggleEarplugs;
            vn_earplugCooldown = time + 1;
        };
    }];
};
