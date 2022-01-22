#include <csgoturkiye>
#include <multicolors>
#include <cstrike>

#pragma semicolon 1

public Plugin myinfo = 
{
	name = "Admin Tag and Name Obligation", 
	author = "oppa", 
	description = "If a previously registered command is used, except for the specified authorities, if it does not fulfill the conditions, it is blocked from using it.", 
	version = "1.0", 
	url = "csgo-turkiye.com"
};

ConVar cv_tag_enabled = null, cv_tag = null, cv_name_enabled = null, cv_name = null, cv_flags = null;
bool b_tag_enabled, b_name_enabled;
char s_tag_client[32], s_name[32], s_flags[32];

public void OnPluginStart(){
    LoadTranslations("csgotr-admin_tag_and_name_obligation.phrases.txt");
    CVAR_Load();
    RegAdminCmd("sm_atano_reload", CMD_RELOAD, ADMFLAG_ROOT);
}

public void OnMapStart()
{
    CVAR_Load();
}

public Action CMD_RELOAD(int client, int args)
{
	LoadConfig();
}

void CVAR_Load(){
    PluginSetting();
    LoadConfig();
    cv_tag_enabled = CreateConVar("sm_atano_tag_enabled", "1", "Tag Control On/Off", 0, true, 0.0, true, 1.0);
    cv_tag = CreateConVar("sm_atano_tag", "csgo-turkiye.com", "It is the abbreviation of your steam group, enter your steam group tag here.");	
    cv_name_enabled = CreateConVar("sm_atano_name_enabled", "1", "Name Control On/Off", 0, true, 0.0, true, 1.0);
    cv_name = CreateConVar("sm_atano_name", "csgo-turkiye.com", "Enter what should be in the name, for example your IP address.");	
    cv_flags = CreateConVar( "sm_atano_admin_flag", "", "For whom should these conditions not be sought? ROOT is automatically allowed. You can put a comma (,) between letters. Maximum 32 characters." );
    AutoExecConfig(true, "admin_tag_and_name_obligation","CSGO_Turkiye");
    b_tag_enabled = GetConVarBool(cv_tag_enabled);
    GetConVarString(cv_tag, s_tag_client, sizeof(s_tag_client));
    b_name_enabled = GetConVarBool(cv_name_enabled);
    GetConVarString(cv_name, s_name, sizeof(s_name));
    GetConVarString(cv_flags, s_flags, sizeof(s_flags));
    HookConVarChange(cv_tag_enabled, OnCvarChanged);
    HookConVarChange(cv_tag, OnCvarChanged);
    HookConVarChange(cv_name_enabled, OnCvarChanged);
    HookConVarChange(cv_name, OnCvarChanged); 
    HookConVarChange(cv_flags, OnCvarChanged); 
}

public void OnCvarChanged(Handle convar, const char[] oldVal, const char[] newVal)
{
    if(convar == cv_tag_enabled) b_tag_enabled = GetConVarBool(convar);
    else if(convar == cv_tag) GetConVarString(convar, s_tag_client, sizeof(s_tag_client));
    else if(convar == cv_name_enabled) b_name_enabled = GetConVarBool(convar);
    else if(convar == cv_name) GetConVarString(convar, s_name, sizeof(s_name));
    else if(convar == cv_flags) GetConVarString(convar, s_flags, sizeof(s_flags));
}

public void LoadConfig(){
    char s_file[PLATFORM_MAX_PATH], s_temp[255];
    BuildPath(Path_SM, s_file, sizeof(s_file), "configs/CSGO-Turkiye_com/admin_tag_and_name_obligation.ini");
    if (!FileExists(s_file))SetFailState("%s %t", s_tag_client, "File Error");
    Handle h_file = OpenFile(s_file, "r");
    while (!IsEndOfFile(h_file))
	{
		ReadFileLine(h_file, s_temp, sizeof(s_temp));
		TrimString(s_temp);
		AddCommandListener(CommandControl, s_temp);
	}
    delete h_file;
}

public Action CommandControl(int client, const char[] command, int args)
{
    if(IsValidClient(client) && CheckAdminFlag(client, "-") && !CheckAdminFlag(client, s_flags))
    {
        char s_user_name[32], s_user_tag[32];
        GetClientName(client, s_user_name, sizeof(s_user_name));
        CS_GetClientClanTag(client, s_user_tag, sizeof(s_user_tag));
        if(b_tag_enabled && b_name_enabled && (!StrEqual(s_user_tag, s_tag_client) || StrContains(s_user_name, s_name) == -1)){
            CPrintToChat(client, "%s%s %t", s_tag_color, s_tag, "Tag and Name", s_tag_client, s_name);
            return Plugin_Stop;
        }else if(b_tag_enabled && !StrEqual(s_user_tag, s_tag_client)){
            CPrintToChat(client, "%s%s %t", s_tag_color, s_tag, "Tag", s_tag_client);
            return Plugin_Stop;
        }else if(b_name_enabled && StrContains(s_user_name, s_name, false) == -1){
            CPrintToChat(client, "%s%s %t", s_tag_color, s_tag, "Name", s_name);
            return Plugin_Stop;
        }             
	}
    return Plugin_Continue;
}

