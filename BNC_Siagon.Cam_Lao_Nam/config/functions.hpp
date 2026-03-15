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
            class repackAllMags {};
		};
	};
	
	class LEON_COD
	{
		class grenade
		{
			file = "functions\grenade\functions";
			
			class preInit { preInit = 1; };
			class addEHKeybind {};
			class draw3DIcon {};
			class isUnitAwake {};
			class isUnitDown {};
			class onKeyDown {};
			class pickGrenade {};
			class throwGrenade {};
		};
	};
	
	// Mobile Respawn System
	class MRS {
		class main {
			file = "mobile_respawn";
			class init {};
			class initMarkers {};
			class initTeleport {};
		};
		class markers {
			file = "mobile_respawn";
			class createMarker {};
			class deleteMarker {};
		};
		class helpers {
			file = "mobile_respawn";
			class isTentDeployed {};
			class getVehicleForSide {};
			class canSpawnAt {};
		};
	};
	
	// RNG AI System
	class RNG {
		class core {
			file = "functions\RNGAI";
			class unit_init {};
			class combat {};
			class react {};
			class cover {};
			class turning {};
			class clearBuilding {};
			class aiCoordinator {};
			class aiGrenadeThrowback {};
		};
	};
	
	// BNC Core Functions
	class BNC {
		class curator {
			file = "functions";
			class curator_init {};
		};
		class gameplay {
			file = "functions";
			class outOfBounds {};
			class opforBase {};
			class bluforBase {};
		};
	};

	
	// VCOM AI System
	#include "..\functions\vcomai\Vcom\cfgFunctions.hpp"
	

};