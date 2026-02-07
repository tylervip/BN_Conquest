//Parameters
[] spawn
{
	VCM_PublicScript = compileFinal "[] call (_this select 0);";
	VCM_ServerAsk = compileFinal "(_this select 1) publicVariableClient (_this select 0);";
	
	/*
	"AwareFormationSoft" enableAIFeature false;
	"CombatFormationSoft" enableAIFeature false;
	*/
	
	if (isServer) then
	{
		// Always load DefaultSettings directly (no CBA/filepatching)
		[] call compile preprocessFileLineNumbers "functions\vcomai\Vcom\Functions\VCOMAI_DefaultSettings.sqf";
		[Vcm_Settings] remoteExec ["VCM_PublicScript",0,false];
	}
	else
	{
		private _id = clientOwner;
		["Vcm_Settings",_id] remoteExec ["VCM_ServerAsk",2,false];
		waitUntil {!(isNil "Vcm_Settings")};
		[] call Vcm_Settings;
	};
	
	waitUntil {!(isNil "VCM_AIMagLimit")};
	
	//CBA/ACE disabled - hardcoded
	CBAACT = false;
	VCOM_EM_ENABLED = false;
	
	
	//Global actions compiles
	Vcm_PMN = compileFinal "(_this select 0) playMoveNow (_this select 1);";
	Vcm_SM = compileFinal "(_this select 0) switchMove (_this select 1);";
	Vcm_PAN = compileFinal "(_this select 0) playActionNow (_this select 1);";
	VCOM_MINEARRAY = [];
	VCM_CoverQueue = [];
	
	//OnEachFrame monitor for mines. Should make them more responsive, without a significant impact on FPS.
	["VCMMINEMONITOR", "onEachFrame", {[] call VCM_fnc_MineMonitor}] call BIS_fnc_addStackedEventHandler;
	
	//Below is loop to check for new AI spawning in to be added to the list
	
	[] spawn
	{
		sleep 2;
		if (hasInterface) then
		{
			//Event handlers for players	
			player addEventHandler ["Fired",{_this call VCM_fnc_HearingAids;}];
			player spawn VCM_fnc_IRCHECK;
			player addEventHandler ["Respawn",{_this spawn VCM_fnc_IRCHECK;}];
			if (Vcm_PlayerAISkills) then {[] spawn VCM_fnc_PLAYERSQUAD;};
		};
		
		[] spawn VCM_fnc_AIDRIVEBEHAVIOR;
		[] spawn VCM_fnc_Scheduler;
	};
};