if (isNil "killFeedHints") then {
    killFeedHints = [];
};

showKillFeedHint = {
    params ["_text"];

    private _maxLines = 5;

    // Add message
    killFeedHints pushBack _text;

    // Trim to max lines
    if (count killFeedHints > _maxLines) then {
        killFeedHints deleteAt 0;
    };

    // Function to rebuild and display combined hints
    private _updateDisplay = {
        private _combined = "";
        {
            _combined = _combined + _x + "\n";
        } forEach killFeedHints;

        hintSilent _combined;
    };

    call _updateDisplay;

    // Schedule removal of this specific message after 10 seconds
    private _localText = _text;
    [] spawn {
        sleep 10;
        if (isNil "killFeedHints") exitWith {};

        // Remove the exact message from the array
        killFeedHints = killFeedHints - [_localText];

        // Update the displayed hints
        call _updateDisplay;
    };
};


        // Initialize array if nil
        if (isNil "killFeedHints") then { killFeedHints = []; };

        // Max number of messages to keep
        private _maxMessages = 7;

        // Format message
        private _fragMessage = format [
            "<t size='0.6'><t color='%1'>%2</t> fragged <t color='%3'>%4</t>",
            _killerColor, _killerName,
            _victimColor, _victimName
        ];

        // Add new message
        killFeedHints pushBack _fragMessage;

        // Keep only last _maxMessages messages
        if (count killFeedHints > _maxMessages) then {
            killFeedHints deleteAt 0;
        };

        // Combine messages
        private _combined = "";
        {
            _combined = _combined + _x + "<br/>";
        } forEach killFeedHints;

        // Show on left side with fade time (7 seconds)
        [_combined, -0.95, 0, 10, 0, 0, 7015] remoteExec ["BIS_fnc_dynamicText", -2];