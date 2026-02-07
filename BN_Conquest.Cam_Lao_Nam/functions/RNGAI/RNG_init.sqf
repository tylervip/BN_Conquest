// RNG AI Settings
// Disables the entire RNG AI system when true
RNG_off = false;
// Which sides have RNG AI enabled: "ALL", "EAST", "WEST", "GUER"
RNG_sides = "ALL";
// Activation range in meters for AI to react and use RNG behavior
RNG_range = 100;
// Disable RNG AI on player-led groups (true = disabled on player groups)
RNG_playergroup = true;

// Animation arrays - defined once globally for performance
RNG_ANIM_Tact = ["TactRF","TactLF","TactF","TactB","TactRB","TactLB","TactR","TactL"];
RNG_ANIM_Run = ["FastRF","FastLF","FastF","FastB","FastRB","FastLB","FastR","FastL"];