// RNG AI Settings
// Works WITH VCOM AI: VCOM handles strategic behavior (flanking, formations, backup)
// RNG takes over when enemies are within RNG_range for close-combat tactics
// The coordinator (fn_aiCoordinator.sqf) manages the handoff between systems

// Disables the entire RNG AI system when true
RNG_off = false;
// Which sides have RNG AI enabled: "ALL", "EAST", "WEST", "GUER"
RNG_sides = "ALL";
// Activation range in meters - when enemies are closer than this, RNG takes over from VCOM
RNG_range = 50;
// Disable RNG AI on player-led groups (true = disabled on player groups)
RNG_playergroup = true;

// Chance (0-100) that AI will attempt to throw back a grenade near them
// Modified by AI skill level and distance to grenade
RNG_AI_GRENADE_CHANCE = 50;

// Enable building clearing when enemies are detected in buildings
RNG_building_clearing = true;

// Debug output for RNG AI system
RNG_debug = false;

if (RNG_debug) then {
	systemChat "RNG AI System Initialized";
	systemChat format["RNG_off: %1", RNG_off];
	systemChat format["RNG_range: %1m", RNG_range];
	systemChat format["RNG_building_clearing: %1", RNG_building_clearing];
	systemChat format["RNG_AI_GRENADE_CHANCE: %1%%", RNG_AI_GRENADE_CHANCE];
};
RNG_ANIM_Tact = ["TactRF","TactLF","TactF","TactB","TactRB","TactLB","TactR","TactL"];
RNG_ANIM_Run = ["FastRF","FastLF","FastF","FastB","FastRB","FastLB","FastR","FastL"];

