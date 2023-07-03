#pragma semicolon 1
#pragma newdecls required
#include <sourcemod>
#include <left4dhooks>

public Plugin myinfo =
{
	name = "Player Join Left Notifier Extra",
	author = "Lyseria",
	description = "Yêu cầu left4hooks 1.33",
	version = "1.9",
	url = ""
};

public void OnPluginStart()
{
	HookEvent("player_connect",	Event_PlayerConnect, EventHookMode_Pre);
	HookEvent("player_disconnect", Event_PlayerDisconnect, EventHookMode_Pre);
}

public void Event_PlayerConnect(Event event, const char[] name, bool dontBroadcast)
{
	char networkid[5];
	event.GetString("networkid", networkid, sizeof networkid);
	if (strcmp(networkid, "BOT") == 0)
		return;

	int maxplayers = GetMaxPlayers();
	if (maxplayers < 1)
		return;

	int players = GetRealPlayers(-1);
	if (players < 1)
		return;
			
	char player_name[MAX_NAME_LENGTH];
	event.GetString("name", player_name, sizeof player_name);
	PrintToChatAll("\x03[★] \x04%s \x05chuẩn bị gia nhập server.\x03 - \x05Số người:\x04 %d/%d", player_name, players, maxplayers);
	
	char file[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, file, sizeof(file), "logs/join.log");
	LogToFileEx(file, "Người chơi %s gia nhập server của bạn.", player_name);
}

public void Event_PlayerDisconnect(Event event, const char[] name, bool dontBroadcast)
{
	event.BroadcastDisabled = true;

	int client = GetClientOfUserId(event.GetInt("userid"));
	if (!client || IsFakeClient(client))
		return;

	int maxplayers = GetMaxPlayers();
	if (maxplayers < 1)
		return;

	int players = GetRealPlayers(client);
	if (players < 1)
		return;

	char player_name[MAX_NAME_LENGTH], reason[100];
	event.GetString("name", player_name, sizeof player_name);
	event.GetString("reason", reason, sizeof reason);

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
		
	PrintToChatAll("\x03[☆] \x04%s \x05rời phòng.\x03 Lý do: %s. \x05Còn lại:\x04 %d/%d", player_name, reason, players, maxplayers);
	
	char file[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, file, sizeof(file), "logs/disconnect.log");
	LogToFileEx(file, "Người chơi %s rời khỏi server của bạn. %s", player_name, reason);
}

int GetMaxPlayers()
{
	ConVar count = FindConVar("sv_maxplayers");
	if (count)
	{
		int maxplayers = count.IntValue;
		return maxplayers != -1 ? maxplayers : GetModePlayers();
	}
	return GetModePlayers();
}

int GetModePlayers()
{
	return LoadFromAddress(L4D_GetPointer(POINTER_SERVER) + view_as<Address>(L4D_GetServerOS() ? 380 : 384), NumberType_Int32);
}

int GetRealPlayers(int client)
{
	int players;
	for (int i = 1; i <= MaxClients; i++)
	{
		if (i != client && !IsFakeClient(i) && IsClientConnected(i))
		//if (i != client && !IsFakeClient(i))
			players++;
	}
	return players;
}
