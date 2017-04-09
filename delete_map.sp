#include <sourcemod>

#pragma semicolon 1

public Plugin:myinfo =
{
	name = "SM Delete Map",
	author = "Franc1sco steam: franug",
	description = ".",
	version = "1.0",
	url = "http://servers-cfg.foroactivo.com/"
};

public OnPluginStart()
{
	RegAdminCmd("sm_deletemap", Comando, ADMFLAG_BAN, "ok");
	
	CreateConVar("sm_DeleteMap_version", "1.0", "plugin info", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
}

public Action:Comando(client, args)
{

	MostrarMenu(client);
	return Plugin_Handled;
}

MostrarMenu(client)
{
	decl String:path[PLATFORM_MAX_PATH];
	Format(path, PLATFORM_MAX_PATH, "maplist.txt");
	new Handle:file = OpenFile(path, "r");
	if(file == INVALID_HANDLE)
	{
		SetFailState("Unable to read file %s", path);
	}
	
	new Handle:menu = CreateMenu(DIDMenuHandler);
	SetMenuTitle(menu, "Choose a map for delete");
	new String:linea[64], String:mapaactual[64];
	
	GetCurrentMap(mapaactual, 64);
	while(!IsEndOfFile(file) && ReadFileLine(file, linea, sizeof(linea)))
	{
		ReplaceString(linea, 64, "\n", "");
		if(StrContains(linea, mapaactual, false) != -1)
		{
			Format(linea, 64, "%s (Current map)", linea);
			AddMenuItem(menu, linea, linea, ITEMDRAW_DISABLED);
		}
		else
			AddMenuItem(menu, linea, linea);
	}
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
	
	CloseHandle(file);
}

public DIDMenuHandler(Handle:menu, MenuAction:action, client, itemNum) 
{
	if ( action == MenuAction_Select ) 
	{
		new String:info[64],String:mapa[PLATFORM_MAX_PATH];
        
		GetMenuItem(menu, itemNum, info, sizeof(info));
		
		Format(mapa, PLATFORM_MAX_PATH, "maps/%s.bsp", info);
		
		//PrintToChat(client, "borrando mapa %s", mapa);
		if(FileExists(mapa))
		{
			DeleteFile(mapa);
			PrintToChat(client, "[SM_DeleteMaps] The map %s has been deleted", info);
			LogMessage("[SM_DeleteMaps] Admin %L removed the map %s", client, info);
			
			Format(mapa, PLATFORM_MAX_PATH, "maps/%s.nav", info);
			if(FileExists(mapa)) DeleteFile(mapa);
			
			Format(mapa, PLATFORM_MAX_PATH, "maps/%s.txt", info);
			if(FileExists(mapa)) DeleteFile(mapa);
			
			Format(mapa, PLATFORM_MAX_PATH, "maps/%s.bsp.bz2", info);
			if(FileExists(mapa)) DeleteFile(mapa);
			
			ServerCommand("sm_writemaplist");
			ServerCommand("sm_writemaplist mapcycle.txt");
			//MostrarMenu(client);
		}
	}	
	else if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}