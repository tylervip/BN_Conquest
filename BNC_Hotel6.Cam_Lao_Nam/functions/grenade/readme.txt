================================================================================
                        COD GRENADE THROWBACK SYSTEM
                              Vanilla Version
================================================================================

Original Author: leonz2020
Modified: Removed CBA/ACE dependencies for vanilla Arma 3

================================================================================
DESCRIPTION
================================================================================
This system allows players to pick up and throw back enemy grenades, similar 
to the mechanic found in Call of Duty games.

When a grenade lands near you:
  - A 3D icon appears directly above the grenade in the world
  - White icon = grenade available to pick up (press G)
  - Red icon = warning that grenades are nearby
  - Press your THROW key (default: G) to pick up the grenade
  - Press THROW again to throw it back at the enemy

================================================================================
FEATURES
================================================================================
- Automatically detects grenades within 3 meters
- Only picks up grenades that are on the ground and moving slowly
- Visual indicator shows nearby throwable grenades
- White icon = first grenade available to pick up (Shift+G)
- Red icon = additional grenades nearby (warning)
- Works with all vanilla grenade types (GrenadeHand, IRStrobeBase, etc.)
- No external mods required (vanilla Arma 3 compatible)
- Tracks last thrown grenade to prevent infinite loops
- Respects unit state (checks if player is awake/conscious)

========================================when the mission starts.

Main initialization file: fn_preInit.sqf (runs at preInit)
Functions are defined in: config\functions.hpp
Functions are located in: functions\grenade\functions\

The fn_preInit.sqf:
  1. Creates the LEON_COD_PickableGrenades array to track grenades
  2. Initializes the keybind event handler
  3. Starts the 3D icon drawing system

The system automatically registers event handlers for all grenades that 
spawn or are thrown during the mission
Functions are located in: functions\grenade\functions\

The fn_preInit.sqf runs at mission start (preInit) and handles all setup.
 (custom PAA texture)
└── functions\
    ├── fn_preInit.sqf      - Main initialization (runs automatically)
    ├── fn_addEHKeybind.sqf - Sets up keyboard event handler (G and Shift+G)
    ├── fn_draw3DIcon.sqf   - Draws 3D grenade indicators above grenades
    ├── fn_isUnitAwake.sqf  - Checks if player is conscious and can interact
    ├── fn_isUnitDown.sqf   - Checks if player is down/incapacitated
    ├── fn_onKeyDown.sqf    - Handles key press logic (pick up or throw)
    ├── fn_pickGrenade.sqf  - Picks up a grenade and attaches to player
    └── fn_throwGrenade.sqf - Throws picked up grenade back to enemy

Function Workflow:
  1. fn_preInit.sqf initializes everything on mission start
  2. fn_addEHKeybind.sqf waits for G or Shift+G keypresses
  3. fn_onKeyDown.sqf determines if player should pick up or throw
  4. fn_pickGrenade.sqf attaches grenade to player's hand
  5. fn_throwGrenade.sqf throws grenade with proper velocity and direction
  6. fn_draw3DIcon.sqf continuously draws red/white icons above grenades (runs automatically)
    ├── fn_addEHKeybind.sqf - Sets up the throw key handler
    ├── fn_draw3DIcon.sqf   - Draws 3D grenade indicators
    ├── fn_isUnitAwake.sqf  - Checks if player can interact
    ├── fn_isUnitDown.sqf   - Checks if player is incapacitated
    ├── fn_onKeyDown.sqf    - Handles key press logic
    ├── fn_pickGrenade.sqf  - Picks up grenade
    └── fn_throwGrenade.sqf - Throws grenade back

================================================================================
CUSTOMIZATION
================================================================================
You can customize the icon colors and sizes by editing fn_draw3DIcon.sqf:

Pick Up Icon (white - appears for first grenade):
  LEON_COD_ColorPickUp   = [1, 1, 1, 1]           // RGBA (white)
  LEON_COD_SizePickUp    = 1                      // Size multiplier

Grenade Warning Icon (red - appears for nearby grenades):
  LEON_COD_IconGrenade   = "functions\grenade\icon\grenade.paa"
  LEON_COD_ColorGrenade  = [0.94, 0.24, 0.24, 1]  // RGBA (red)
  LEON_COD_SizeGrenade   = 1                       // Size multiplier

The 3D icons are drawn directly above each grenade object in world space.

================================================================================
CONTROLS
================================================================================
Default Key: G (throw grenade key)

G (alone):
  - Throw the grenade you've picked up

Shift+G:
  - Pick up a nearby grenade

The system uses your configured "throw" action key from Arma 3 controls.

Note: You can only pick up grenades within 3 meters, when the grenade is 
on the ground (not attached to anything), and moving slowly (≤10 m/s).

================================================================================
