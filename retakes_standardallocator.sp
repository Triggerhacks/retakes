#include <sourcemod>
#include <cstrike>
#include <clientprefs>
#include "include/retakes.inc"
#include "retakes/generic.sp"

#pragma semicolon 1
#pragma newdecls required

#define MENU_TIME_LENGTH 15

char g_CTRifleChoice[MAXPLAYERS+1][WEAPON_STRING_LENGTH];
char g_TRifleChoice[MAXPLAYERS+1][WEAPON_STRING_LENGTH];
char g_CTPistolChoice[MAXPLAYERS+1][WEAPON_STRING_LENGTH];
char g_TPistolChoice[MAXPLAYERS+1][WEAPON_STRING_LENGTH];
char g_CTPistolRoundChoice[MAXPLAYERS+1][WEAPON_STRING_LENGTH];
char g_TPistolRoundChoice[MAXPLAYERS+1][WEAPON_STRING_LENGTH];
bool g_CTAwpChoice[MAXPLAYERS+1];
bool g_TAwpChoice[MAXPLAYERS+1];
Handle g_hCTRifleChoiceCookie;
Handle g_hTRifleChoiceCookie;
Handle g_hCTPistolChoiceCookie;
Handle g_hTPistolChoiceCookie;
Handle g_hCTPistolRoundChoiceCookie;
Handle g_hTPistolRoundChoiceCookie;
Handle g_hCTAwpChoiceCookie;
Handle g_hTAwpChoiceCookie;

public Plugin myinfo = {
    name = "CS:GO Retakes: edited standard weapon allocator",
    author = "splewis/Triggerhacks",
    description = "Defines a simple weapon allocation policy and lets players set weapon preferences. Edited to include multiple extra round types, weapons and pistols",
    version = PLUGIN_VERSION,
    url = "https://github.com/splewis/csgo-retakes"
};

public void OnPluginStart() {
    g_hCTRifleChoiceCookie = RegClientCookie("retakes_ctriflechoice", "", CookieAccess_Private);
    g_hTRifleChoiceCookie = RegClientCookie("retakes_triflechoice", "", CookieAccess_Private);
    g_hCTPistolChoiceCookie = RegClientCookie("retakes_ctpistolchoice", "", CookieAccess_Private);
    g_hTPistolChoiceCookie = RegClientCookie("retakes_tpistolchoice", "", CookieAccess_Private);
    g_hCTPistolRoundChoiceCookie = RegClientCookie("retakes_ctpistolroundchoice", "", CookieAccess_Private);
    g_hTPistolRoundChoiceCookie = RegClientCookie("retakes_tpistolroundchoice", "", CookieAccess_Private);
    g_hCTAwpChoiceCookie = RegClientCookie("retakes_ctawpchoice", "", CookieAccess_Private);
    g_hTAwpChoiceCookie = RegClientCookie("retakes_tawpchoice", "", CookieAccess_Private);
}

stock int GetRoundCount()
{
    return GameRules_GetProp("m_totalRoundsPlayed");
}

public void Retakes_OnGunsCommand(int client) {
    GiveWeaponsMenu(client);
}

public void Retakes_OnWeaponsAllocated(ArrayList tPlayers, ArrayList ctPlayers, Bombsite bombsite) {
    WeaponAllocator(tPlayers, ctPlayers, bombsite);
}

/**
 * Updates client weapon settings according to their cookies.
 */
public void OnClientCookiesCached(int client) {
    if (IsFakeClient(client))
        return;
    char ctrifle[WEAPON_STRING_LENGTH];
    char trifle[WEAPON_STRING_LENGTH];
    GetClientCookie(client, g_hCTRifleChoiceCookie, ctrifle, sizeof(ctrifle));
    GetClientCookie(client, g_hTRifleChoiceCookie, trifle, sizeof(trifle));
    g_CTRifleChoice[client] = ctrifle;
    g_TRifleChoice[client] = trifle;
    char ctpistol[WEAPON_STRING_LENGTH];
    char tpistol[WEAPON_STRING_LENGTH];
    GetClientCookie(client, g_hCTPistolChoiceCookie, ctpistol, sizeof(ctpistol));
    GetClientCookie(client, g_hTPistolChoiceCookie, tpistol, sizeof(tpistol));
    g_CTPistolChoice[client] = ctpistol;
    g_TPistolChoice[client] = tpistol;
    g_CTAwpChoice[client] = GetCookieBool(client, g_hCTAwpChoiceCookie);
    g_TAwpChoice[client] = GetCookieBool(client, g_hTAwpChoiceCookie);
    char ctpistolround[WEAPON_STRING_LENGTH];
    char tpistolround[WEAPON_STRING_LENGTH];
    GetClientCookie(client, g_hCTPistolRoundChoiceCookie, ctpistolround, sizeof(ctpistolround));
    GetClientCookie(client, g_hTPistolRoundChoiceCookie, tpistolround, sizeof(tpistolround));
    g_CTPistolRoundChoice[client] = ctpistolround;
    g_TPistolRoundChoice[client] = tpistolround;
}

static void SetNades(char nades[NADE_STRING_LENGTH]) {
    int rand = GetRandomInt(0, 5);
    switch(rand) {
        case 0: nades = "";
        case 1: nades = "s";
        case 2: nades = "f";
        case 3: nades = "h";
        case 4: nades = "i";
        case 5: nades = "m";
    }
}

public void WeaponAllocator(ArrayList tPlayers, ArrayList ctPlayers, Bombsite bombsite) {
	int tCount = tPlayers.Length;
	int ctCount = ctPlayers.Length;

	char primary[WEAPON_STRING_LENGTH];
	char secondary[WEAPON_STRING_LENGTH];
	char nades[NADE_STRING_LENGTH];
	int health = 100;
	int kevlar = 100;
	bool helmet = true;
	bool kit = true;
	bool ISPistolRound;

	bool giveTAwp = true;
	bool giveCTAwp = true;

	ISPistolRound = GetRoundCount()<=4?true : false;

	if (ISPistolRound) {
        for (int i = 0; i < tCount; i++) {
        int client = tPlayers.Get(i);

        if (StrEqual(g_TPistolRoundChoice[client], "r8", true)) {
            secondary = "weapon_revolver";
            kevlar = 0;
        } else if (StrEqual(g_TPistolRoundChoice[client], "deagle", true)) {
            secondary = "weapon_deagle";
            kevlar = 0;
        } else if (StrEqual(g_TPistolRoundChoice[client], "elite", true)) {
            secondary = "weapon_elite";
            kevlar = 0;
        } else if (StrEqual(g_TPistolRoundChoice[client], "tec9", true)) {
            secondary = "weapon_tec9";
            kevlar = 0;
        } else if (StrEqual(g_TPistolRoundChoice[client], "p250", true)) {
            secondary = "weapon_p250";
            kevlar = 0;
        } else if (StrEqual(g_TPistolRoundChoice[client], "cz75a", true)) {
            secondary = "weapon_cz75a";
            kevlar = 0;
        } else {
            secondary = "weapon_glock";
            kevlar = 100;
        }

        primary = "";
        health = 100;
        helmet = false;
        kit = false;
        SetNades(nades);

        Retakes_SetPlayerInfo(client, primary, secondary, nades, health, kevlar, helmet, kit);
    }

        for (int i = 0; i < ctCount; i++) {
        int client = ctPlayers.Get(i);

        if (StrEqual(g_CTPistolRoundChoice[client], "r8", true)) {
            secondary = "weapon_revolver";
            kevlar = 0;
        } else if (StrEqual(g_CTPistolRoundChoice[client], "hkp2000", true)) {
            secondary = "weapon_hkp2000";
            kevlar = 100;
        } else if (StrEqual(g_CTPistolRoundChoice[client], "deagle", true)) {
            secondary = "weapon_deagle";
            kevlar = 0;
        } else if (StrEqual(g_CTPistolRoundChoice[client], "elite", true)) {
            secondary = "weapon_elite";
            kevlar = 0;
        } else if (StrEqual(g_CTPistolRoundChoice[client], "fiveseven", true)) {
            secondary = "weapon_fiveseven";
            kevlar = 0;
        } else if (StrEqual(g_CTPistolRoundChoice[client], "p250", true)) {
            secondary = "weapon_p250";
            kevlar = 0;
        } else if (StrEqual(g_CTPistolRoundChoice[client], "cz75a", true)) {
            secondary = "weapon_cz75a";
            kevlar = 0;
        } else {
            secondary = "weapon_usp_silencer";
            kevlar = 100;
        }

        primary = "";
        kit = false;
        health = 100;
        helmet = false;
        SetNades(nades);

        Retakes_SetPlayerInfo(client, primary, secondary, nades, health, kevlar, helmet, kit);
    }

	} else {
        for (int i = 0; i < tCount; i++) {
        int client = tPlayers.Get(i);

        if (giveTAwp && g_TAwpChoice[client]) {
            primary = "weapon_awp";
            giveTAwp = false;
        } else if(StrEqual(g_TRifleChoice[client], "sg556", true)) {
            primary = "weapon_sg556";
        } else if(StrEqual(g_TRifleChoice[client], "galilar", true)) {
            primary = "weapon_galilar";
        } else {
            primary = "weapon_ak47";
        }

        if (StrEqual(g_TPistolChoice[client], "r8", true)) {
            secondary = "weapon_revolver";
        } else if (StrEqual(g_TPistolChoice[client], "deagle", true)) {
            secondary = "weapon_deagle";
        } else if (StrEqual(g_TPistolChoice[client], "elite", true)) {
            secondary = "weapon_elite";
        } else if (StrEqual(g_TPistolChoice[client], "tec9", true)) {
            secondary = "weapon_tec9";
        } else if (StrEqual(g_TPistolChoice[client], "p250", true)) {
            secondary = "weapon_p250";
        } else if (StrEqual(g_TPistolChoice[client], "cz75a", true)) {
            secondary = "weapon_cz75a";
        } else {
            secondary = "weapon_glock";
        }

        health = 100;
        kevlar = 100;
        helmet = true;
        kit = false;
        SetNades(nades);

        Retakes_SetPlayerInfo(client, primary, secondary, nades, health, kevlar, helmet, kit);
    }

        for (int i = 0; i < ctCount; i++) {
            int client = ctPlayers.Get(i);

            if (giveCTAwp && g_CTAwpChoice[client]) {
                primary = "weapon_awp";
                giveCTAwp = false;
            } else if (StrEqual(g_CTRifleChoice[client], "m4a1_silencer", true)) {
                primary = "weapon_m4a1_silencer";
            } else if (StrEqual(g_CTRifleChoice[client], "aug", true)) {
                primary = "weapon_aug";
            } else if (StrEqual(g_CTRifleChoice[client], "famas", true)) {
                primary = "weapon_famas";
            } else {
                primary = "weapon_m4a1";
            }

            if (StrEqual(g_CTPistolChoice[client], "r8", true)) {
                secondary = "weapon_revolver";
            } else if (StrEqual(g_CTPistolChoice[client], "hkp2000", true)) {
                secondary = "weapon_hkp2000";
            } else if (StrEqual(g_CTPistolChoice[client], "deagle", true)) {
                secondary = "weapon_deagle";
            } else if (StrEqual(g_CTPistolChoice[client], "elite", true)) {
                secondary = "weapon_elite";
            } else if (StrEqual(g_CTPistolChoice[client], "tec9", true)) {
                secondary = "weapon_tec9";
            } else if (StrEqual(g_CTPistolChoice[client], "p250", true)) {
                secondary = "weapon_p250";
            } else if (StrEqual(g_CTPistolChoice[client], "cz75a", true)) {
                secondary = "weapon_cz75a";
            } else {
                secondary = "weapon_usp_silencer";
            }
            
            kit = true;
            health = 100;
            kevlar = 100;
            helmet = true;
            SetNades(nades);

            Retakes_SetPlayerInfo(client, primary, secondary, nades, health, kevlar, helmet, kit);
        }
    }
}

public void GiveWeaponsMenu(int client) {
    Menu menu = new Menu(MenuHandler_GiveWeapons);
    menu.SetTitle("Select a Round Type");
    menu.AddItem("rifleround", "Rifle Rounds");
    menu.AddItem("pistolround", "Pistol Rounds");
    menu.Display(client, MENU_TIME_LENGTH);
}

public int MenuHandler_GiveWeapons(Menu menu, MenuAction action, int param1, int param2) {
    if (action == MenuAction_Select) {
        int client = param1;
        char info[32];
        menu.GetItem(param2, info, sizeof(info));
        if (StrEqual(info, "rifleround")) {
            CTRifleMenu(client);
        } else if (StrEqual(info, "pistolround")) {
            CTPistolRoundMenu(client);
        }
    }
}

public void CTRifleMenu(int client) {
    Menu menu = new Menu(MenuHandler_CTRifle);
    menu.SetTitle("Select a CT rifle:");
    menu.AddItem("m4a1", "M4A4");
    menu.AddItem("m4a1_silencer", "M4A1-S");
    menu.AddItem("aug", "AUG");
    menu.AddItem("famas", "FAMAS");
    menu.Display(client, MENU_TIME_LENGTH);
}

public int MenuHandler_CTRifle(Menu menu, MenuAction action, int param1, int param2) {
    if (action == MenuAction_Select) {
        int client = param1;
        char choice[WEAPON_STRING_LENGTH];
        menu.GetItem(param2, choice, sizeof(choice));
        g_CTRifleChoice[client] = choice;
        SetClientCookie(client, g_hCTRifleChoiceCookie, choice);
        TRifleMenu(client);
    } else if (action == MenuAction_End) {
        delete menu;
    }
}

public void TRifleMenu(int client) {
    Menu menu = new Menu(MenuHandler_TRifle);
    menu.SetTitle("Select a T rifle:");
    menu.AddItem("ak47", "AK-47");
    menu.AddItem("sg556", "SG-556");
    menu.AddItem("galilar", "GALIL");
    menu.Display(client, MENU_TIME_LENGTH);
}

public int MenuHandler_TRifle(Menu menu, MenuAction action, int param1, int param2) {
    if (action == MenuAction_Select) {
        int client = param1;
        char choice[WEAPON_STRING_LENGTH];
        menu.GetItem(param2, choice, sizeof(choice));
        g_TRifleChoice[client] = choice;
        SetClientCookie(client, g_hTRifleChoiceCookie, choice);
        CTPistolMenu(client);
    } else if (action == MenuAction_End) {
        delete menu;
    }
}

public void CTPistolMenu(int client) {
    Menu menu = new Menu(MenuHandler_CTPistol);
    menu.SetTitle("Select a CT Pistol:");
    menu.AddItem("usp_silencer", "USP-S");
    menu.AddItem("hkp2000", "P2000");
    menu.AddItem("deagle", "Deagle");
    menu.AddItem("p250", "P250");
    menu.AddItem("cz75a", "CZ75");
    menu.AddItem("fiveseven", "FiveSeven");
    menu.AddItem("elite", "Dual Barettas");
    menu.AddItem("r8", "R8");
    menu.Display(client, MENU_TIME_LENGTH);
}

public int MenuHandler_CTPistol(Menu menu, MenuAction action, int param1, int param2) {
    if (action == MenuAction_Select) {
        int client = param1;
        char choice[WEAPON_STRING_LENGTH];
        menu.GetItem(param2, choice, sizeof(choice));
        g_CTPistolChoice[client] = choice;
        SetClientCookie(client, g_hCTPistolChoiceCookie, choice);
        TPistolMenu(client);
    } else if (action == MenuAction_End) {
        delete menu;
    }
}

public void TPistolMenu(int client) {
    Menu menu = new Menu(MenuHandler_TPistol);
    menu.SetTitle("Select a T Pistol:");
    menu.AddItem("glock", "Glock");
    menu.AddItem("deagle", "Deagle");
    menu.AddItem("p250", "P250");
    menu.AddItem("cz75a", "CZ75");
    menu.AddItem("fiveseven", "FiveSeven");
    menu.AddItem("elite", "Dual Barettas");
    menu.AddItem("r8", "R8");
    menu.Display(client, MENU_TIME_LENGTH);
}

public int MenuHandler_TPistol(Menu menu, MenuAction action, int param1, int param2) {
    if (action == MenuAction_Select) {
        int client = param1;
        char choice[WEAPON_STRING_LENGTH];
        menu.GetItem(param2, choice, sizeof(choice));
        g_TPistolChoice[client] = choice;
        SetClientCookie(client, g_hTPistolChoiceCookie, choice);
        GiveCTAwpMenu(client);
    } else if (action == MenuAction_End) {
        delete menu;
    }
}

public void GiveCTAwpMenu(int client) {
    Menu menu = new Menu(MenuHandler_CTAWP);
    menu.SetTitle("Allow yourself to receive AWPs on CT side?");
    AddMenuBool(menu, true, "Yes");
    AddMenuBool(menu, false, "No");
    menu.Display(client, MENU_TIME_LENGTH);
}

public int MenuHandler_CTAWP(Menu menu, MenuAction action, int param1, int param2) {
    if (action == MenuAction_Select) {
        int client = param1;
        bool allowAwps = GetMenuBool(menu, param2);
        g_CTAwpChoice[client] = allowAwps;
        SetCookieBool(client, g_hCTAwpChoiceCookie, allowAwps);
        GiveTAwpMenu(client);
    } else if (action == MenuAction_End) {
        delete menu;
    }
}

public void GiveTAwpMenu(int client) {
    Menu menu = new Menu(MenuHandler_TAWP);
    menu.SetTitle("Allow yourself to receive AWPs on T side?");
    AddMenuBool(menu, true, "Yes");
    AddMenuBool(menu, false, "No");
    menu.Display(client, MENU_TIME_LENGTH);
}

public int MenuHandler_TAWP(Menu menu, MenuAction action, int param1, int param2) {
    if (action == MenuAction_Select) {
        int client = param1;
        bool allowAwps = GetMenuBool(menu, param2);
        g_TAwpChoice[client] = allowAwps;
        SetCookieBool(client, g_hTAwpChoiceCookie, allowAwps);
    } else if (action == MenuAction_End) {
        delete menu;
    }
}

public void CTPistolRoundMenu(int client) {
    Menu menu = new Menu(MenuHandler_CTPistolRound);
    menu.SetTitle("Select a CT Pistol:");
    menu.AddItem("usp_silencer", "USP-S");
    menu.AddItem("hkp2000", "P2000");
    menu.AddItem("deagle", "Deagle");
    menu.AddItem("p250", "P250");
    menu.AddItem("cz75a", "CZ75");
    menu.AddItem("fiveseven", "FiveSeven");
    menu.AddItem("elite", "Dual Barettas");
    menu.AddItem("r8", "R8");
    menu.Display(client, MENU_TIME_LENGTH);
}

public int MenuHandler_CTPistolRound(Menu menu, MenuAction action, int param1, int param2) {
    if (action == MenuAction_Select) {
        int client = param1;
        char choice[WEAPON_STRING_LENGTH];
        menu.GetItem(param2, choice, sizeof(choice));
        g_CTPistolRoundChoice[client] = choice;
        SetClientCookie(client, g_hCTPistolRoundChoiceCookie, choice);
        TPistolRoundMenu(client);
    } else if (action == MenuAction_End) {
        delete menu;
    }
}

public void TPistolRoundMenu(int client) {
    Menu menu = new Menu(MenuHandler_TPistolRound);
    menu.SetTitle("Select a T Pistol:");
    menu.AddItem("glock", "Glock");
    menu.AddItem("deagle", "Deagle");
    menu.AddItem("p250", "P250");
    menu.AddItem("cz75a", "CZ75");
    menu.AddItem("fiveseven", "FiveSeven");
    menu.AddItem("elite", "Dual Barettas");
    menu.AddItem("r8", "R8");
    menu.Display(client, MENU_TIME_LENGTH);
}

public int MenuHandler_TPistolRound(Menu menu, MenuAction action, int param1, int param2) {
    if (action == MenuAction_Select) {
        int client = param1;
        char choice[WEAPON_STRING_LENGTH];
        menu.GetItem(param2, choice, sizeof(choice));
        g_TPistolRoundChoice[client] = choice;
        SetClientCookie(client, g_hTPistolRoundChoiceCookie, choice);
    } else if (action == MenuAction_End) {
        delete menu;
    }
}