#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>

#define	TAG_INFO "\x03[Hệ Thống]\x05"
 
public Plugin myinfo =
{
	name = "Simble Player Joined/Left Notifier",
	author = "def (user00111), Lyseria",
	description = "some thing new",
	version = "1.3",
	url = ""
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion test = GetEngineVersion();
	if( test != Engine_Left4Dead && test != Engine_Left4Dead2 )
	{
		strcopy(error, err_max, "Ko nhìn tên à chỉ hỗ trợ l4d2 thôi.Vì tôi thích thế xD.");
		return APLRes_SilentFailure;
	}
	return APLRes_Success;
}

public void OnPluginStart()
{
	HookEvent("player_disconnect", Event_PlayerDisconnect, EventHookMode_Pre);
	HookUserMessage(GetUserMessageId("TextMsg"), thongbao, true);
}
/*
public void OnPluginEnd() {
  UnhookEvent("player_disconnect", Event_PlayerDisconnect, EventHookMode_Pre);
}
*/

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
Action thongbao (UserMsg msg_id, BfRead msg, const int[] players, int playersNum, bool reliable, bool init) {
	static char sMsg[254];
	msg.ReadString(sMsg, sizeof sMsg);

	if(StrContains(sMsg, "L4D_idle_spectator") != -1)
		return Plugin_Handled;

	return Plugin_Continue;
}

public Action Event_PlayerDisconnect (Event event, const char[] name, bool dontBroadcast)
{
	event.BroadcastDisabled = true;
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
			
		if(IsSurvivor(client))
		{
			PrintToChat(client,"%s Người chơi \x04%s\x01 thời khỏi game. (lý do: %s)", TAG_INFO, player_name, reason);
		}
	}
	return Plugin_Continue;
}

stock bool IsSurvivor(int client)
{
	return (client > 0 && client <= MaxClients && IsClientInGame(client) && GetClientTeam(client) == 2) && IsPlayerAlive(client) && !IsFakeClient(client);
}
