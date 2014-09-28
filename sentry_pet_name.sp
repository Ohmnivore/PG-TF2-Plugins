#include <sourcemod>

//Some constants and global vars
static const String:NAME[] = "Sentry pet name";
static const String:DESCRIPTION[] = "Allows engineers to name their sentry, and displays that name to the players it kills.";
static const String:VERSION[] = "1.0";

new Handle:g_cvarEnable = INVALID_HANDLE;

static const String:SENTRY_1[] = "obj_sentrygun";
static const String:SENTRY_2[] = "obj_sentrygun2";
static const String:SENTRY_3[] = "obj_sentrygun3";

new String:SentryNames[33][64];
new bool:SentryNamed[33];
//end

//Plugin signature
public Plugin:myinfo =
{
	name = NAME,
	author = "-pg- Ohmnivore",
	description = DESCRIPTION,
	version = VERSION,
	url = "http://www.prestige-gaming.org/"
};
//end

//Creating conVars and hooking events
public OnPluginStart()
{
    CreateConVar("sm_sentryname_version", VERSION, "Sentry pet name plugin version.", FCVAR_PLUGIN|FCVAR_NOTIFY);
	RegAdminCmd("sentryname", setName, 0, "Usage: sentryname your new name here");
    g_cvarEnable = CreateConVar("sm_sentryname_enable", "0", DESCRIPTION, FCVAR_PLUGIN);
    HookEvent("player_death", onDeath, EventHookMode_Post);
    HookConVarChange(g_cvarEnable, EnableChanged);
    AutoExecConfig(false);
	
	for (new i = 0; i < 33; i++)
	{
		SentryNamed[i] = false;
	}
}
//end

//conVars reload handling
public EnableChanged(Handle:cvar, const String:oldval[], const String:newval[])
{
    if (strcmp(oldval, newval) != 0)
	{
        if (strcmp(newval, "1") == 0)
		{
            PrintToChatAll("%c[SM] %c%s %c%s!", 0x01, 0x04, NAME, 0x01, "enabled");
			SetConVarBool(cvar, true, false, true);
        }
		else
		{
            PrintToChatAll("%c[SM] %c%s %c%s!", 0x01, 0x04, NAME, 0x01, "disabled");
			SetConVarBool(cvar, false, false, true);
        }
    }
}
//end

//The actual code
public Action:onDeath(Handle:event, const String:name[], bool:dontBroadcast)
{
    if (GetConVarBool(g_cvarEnable))
    {
		new String:wepname[64];
		GetEventString(event, "weapon", wepname, sizeof(wepname));
		
		new attacker = GetEventInt(event, "attacker");
		new victim = GetEventInt(event, "userid");
		
		if (IsClientConnected(attacker) && IsClientConnected(victim))
		{
			if (StrEqual(wepname, SENTRY_1))
			{
				showName(attacker, victim, 1);
			}
			else if (StrEqual(wepname, SENTRY_2))
			{
				showName(attacker, victim, 2);
			}
			else if (StrEqual(wepname, SENTRY_3))
			{
				showName(attacker, victim, 3);
			}
		}
    }
}

showName(KillerID, VictimID, SentryLvl)
{
	new KillerID2 = GetClientUserId(KillerID);
	
	if (SentryNamed[KillerID2] == true)
	{
		new String:playername[64];
		GetClientName(KillerID, playername, sizeof(playername));
		
		PrintToChat(VictimID, "Got shrekt by %s's %s", playername, SentryNames[KillerID2]);
	}
}

public Action:setName(client, args)
{
	new clientid = GetClientUserId(client);
	new String:buffer[64];
	GetCmdArgString(buffer, sizeof(buffer));
	SentryNamed[clientid] = true;
	Format(SentryNames[clientid] , 64, buffer);  
	
	PrintToChat(client, "%c[SM] You have changed your sentry's name to %s.", 0x01, buffer);
	
	return Plugin_Handled;
}
//end