//delete_Group.sqf

[] spawn { 
    while {true} do { 
        { 
            if (count units _x == 0) then { 
                deleteGroup _x; 
            } 
        } forEach allGroups;
        sleep 500;
    }; 
};