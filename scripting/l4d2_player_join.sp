#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>

#define	TAG_INFO "\x03[Hệ Thống]\x05"
 
public Plugin myinfo =
{
	name = "Simble Player Joined/Left Notifier",
	author = "def (user00111), Lyseria",
	description = "New syntax",
	version = "1.1",
	url = ""
};

public void OnPluginStart()
{
	HookEvent("player_disconnect", Event_PlayerDisconnect, EventHookMode_Pre);
}

public void OnClientPutInServer(int client)
{
	if (IsFakeClient(client))
	  return;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i))
		{
			if (!IsFakeClient(i))
			{
				if (i != client)
				{
			    PrintToChat(i, "%s Người chơi \x04%N\x05 tham gia vào game.", TAG_INFO, client);
				}
			}
		}
	}
}

public Action Event_PlayerDisconnect (Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	if ((client != 0) && !IsFakeClient(client))
	{
		char reason[100];
		char player_name[MAX_NAME_LENGTH];
		
		GetEventString(event, "reason", reason, sizeof(reason));
		GetEventString(event, "name", player_name, sizeof(player_name));		
		
		if (StrContains(reason, "kicked", false) != -1) 
			strcopy(reason, sizeof(reason), "Bị Kick");
		else if (StrContains(reason, "banned", false) != -1)
			strcopy(reason, sizeof(reason), "Bị Ban");
		else if (StrContains(reason, "timed out", false) != -1)
			strcopy(reason, sizeof(reason), "Kết nối thất bại"); 
		else if (StrContains(reason, "by user", false) != -1)
			strcopy(reason, sizeof(reason), "Thoát game");
		else if (StrContains(reason, "connection rejected", false) != -1)
			strcopy(reason, sizeof(reason), "Kết nối bị từ chối");
		else if (StrContains(reason, "ping is too high", false) != -1)
			strcopy(reason, sizeof(reason), "Ping quá cao");
		else if (StrContains(reason, "Steam Connection lost", false) != -1)
			strcopy(reason, sizeof(reason), "Mất kết nối với Steam");
		else if (StrContains(reason, "No Steam logon", false) != -1)
			strcopy(reason, sizeof(reason), "Crash Game");
		else if (StrContains(reason, "Disconnected", false) != -1)
			strcopy(reason, sizeof(reason), "Văng Game");
			
		
		PrintToChatAll("%s Người chơi \x04%s\x05 ngắt kết nối máy chủ cục bộ. \x03(Lý do: %s)", TAG_INFO, player_name, reason);
		if (!dontBroadcast)
		  SetEventBroadcast(event, true);
	}
	return Plugin_Continue;
}