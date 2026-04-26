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
			class draw3DIcon {};
			class handleThrowGrenade {};
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
			class serverRespawnLoop {};
			class refreshVehicleRefs {};
			class addVehicleActions {};
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
		class outOfBounds {
			file = "functions\outOfBounds";
			class outOfBounds {};
			class opforBase {};
			class bluforBase {};
		};
		class utils {
			file = "functions";
			class toggleEarplugs {};
		};
	};

	
	// VCOM AI System
	#include "..\functions\vcomai\Vcom\cfgFunctions.hpp"
	

// Paradigm Keybinding System
class para_c
{
tag = "para_c";

class keyhandler
{
file = "functions\keyhandler";
class init_key_down {};
class init_key_up {};
class change_key_bind {};
class get_key_bind {};
class getKeyName {};
class eh_key_down {};
class eh_key_up {};
class initKeyHandlers { postInit = 1; };
};

class ui_core
{
file = "functions\ui";
class initEscapeMenu { postInit = 1; };
class ui_initMissionDisplay {};
};

class keybindings_menu
{
file = "functions\ui\keybindings_menu";
class para_RscDisplayKeybindingsMenu {};
class keybindingsMenu_onLoad {};
class keybindingsMenu_onUnload {};
class keybindingsMenu_editBind {};
class keybindingsMenu_editBind_input {};
class keybindingsMenu_reset {};
class keybindingsMenu_updateColors {};
};
};
};