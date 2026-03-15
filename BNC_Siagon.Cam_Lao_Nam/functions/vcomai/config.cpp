class CfgPatches 
{
	class VCOM_AI 
	{
		units[] = {};
		weapons[] = {}; 
		requiredAddons[] = {};	
		author[]= {"Genesis"}; 		
	};
};



class CfgFunctions
{
	#include "vcom\cfgFunctions.hpp"
	class VCOMlaunch
	{
		class VCOM_Initialization
		{
			class Init
			{
				file = "functions\vcomai\vcom\Functions\VCM_Functions\fn_VcomInit.sqf";
				postInit = 1;
			};
		};

	};
};


// CBA removed - using DefaultSettings directly

class CfgRemoteExec
{
	// List of script functions allowed to be sent from client via remoteExec
	class Functions
	{
		mode = 2;
		jip = 1;		
		
		class vcm_serverask { allowedTargets = 0;jip = 1; };
		class VCM_PublicScript { allowedTargets = 0;jip = 1; };
		class SpawnScript { allowedTargets = 0;jip = 1; };
		class enableSimulationGlobal { allowedTargets = 0;jip = 1; };
		class VCM_fnc_KnowAbout { allowedTargets = 0;jip = 1; };	
	};
	
	
};
