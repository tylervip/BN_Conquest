//functions.hpp
class CfgFunctions {

	class map
	{
		class core 
		{
			file = "markers\functions";

			class player_markers	{};
			class player_markers_subsystem_init	{};
			class player_markers_update	{};
		};

		class helpers
		{
			file = "markers\helpers";

			class check_side	{};
			class createTempMarker {};
		};
	};
	class killstreak
	{
		class core
		{
			file = "Killstreak";

			class recon_uav {};
			class spawnCarePackage {};
		};
	};
	class functions
	{
		class magRepack
		{
			file = "functions\magRepack";
            class ammo_repack {};
		};
	};
};