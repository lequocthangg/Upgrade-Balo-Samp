//Slot Balo
#define MAX_BALO 4
//Color
#define COLOR_WHITE 0xFFFFFFFF
#define COLOR_BLACK 0x000000FF
#define COLOR_RED 0xFF0000FF
#define COLOR_GREEN 0x00FF00FF
#define COLOR_BLUE 0x0000FFFF
#define COLOR_YELLOW 0xFFFF00FF
#define COLOR_ORANGE 0xFFA500FF
#define COLOR_PURPLE 0x800080FF
#define COLOR_PINK 0xFFC0CBFF
#define COLOR_CYAN 0x00FFFFFF
#define COLOR_GREY 0x808080FF
#define COLOR_BROWN 0xA52A2AFF
//
#define INVALID_BALO_ID        (0)
//
#define DIALOG_PROGRESS1 (1)
#define DIALOG_NOTHING  (2)
//Balo Phôi
#define DIALOG_SELECT_BALO_PHOI (3)
#define DIALOG_SELECT_BALO (4)
#define DIALOG_PROGRESS (5)
#define DIALOG_SHOW_BALO_INFO  (6)   
#define DIALOG_LOADING (7)
#define DIALOG_UPGRADE_SUCCESS (8)


enum Balo {
    tt_tenBalo[128],
    tt_succhua,
    tt_BaloID,   
    tt_Level,     
    tt_ObjectID
};

new BaloInfo[MAX_BALO][Balo];
new PlayerBalo[MAX_PLAYERS];
new PlayerObject[MAX_PLAYERS];

//Max Phôi
new PlayerPhoi[MAX_PLAYERS][3];
forward Float:GetPhoiSuccessRate(level);

//Timer
new gPlayerUpgradingBaloID[MAX_PLAYERS] = {-1, ...}; 
new gPlayerUpgradeStartTime[MAX_PLAYERS]; 
//

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    if (dialogid == DIALOG_PROGRESS1) {
        if (response) {
            
            gPlayerUpgradingBaloID[playerid] = GetPVarInt(playerid, "SelectedBaloID");
            gPlayerUpgradeStartTime[playerid] = gettime();
            ShowPlayerDialog(playerid, DIALOG_LOADING, DIALOG_STYLE_MSGBOX, "Nang Cap Balo", "Dang nang cap balo... Vui long doi 10 giay.", "OK", "");
            SetTimerEx("OnUpgradeComplete", 10000, false, "i", playerid);
        }
        return 1;
    }
    if (dialogid == DIALOG_LOADING) {
        return ShowPlayerDialog(playerid, DIALOG_LOADING, DIALOG_STYLE_MSGBOX, "Nang Cap Balo", "Dang nang cap balo... Vui long doi 10 giay.", "OK", "");
    }
    if (dialogid == DIALOG_SELECT_BALO) {
        if (response) {
            if (strlen(inputtext) == 0) {
                return SendClientMessage(playerid, -1, "{FF0000}[Loi] Khong co ID Balo duoc nhap. Qua trinh nang cap da bi huy.");
            }
            new baloID = strval(inputtext);

            if (BaloInfo[baloID][tt_BaloID] == 0) {
                return SendClientMessage(playerid, -1, "{FF0000}[Loi] Balo khong ton tai!");
            }

            if (BaloInfo[baloID][tt_Level] >= 5) {
                return SendClientMessage(playerid, -1, "{FF0000}[Loi] Khong the nang cap balo cap do nay!");
            }
            new Float:tiLeThanhCong = GetSuccessRate(BaloInfo[baloID][tt_Level]);
            new baloName[32];
            format(baloName, sizeof(baloName), "%s", BaloInfo[baloID][tt_tenBalo]);
            new message[256];
            format(message, sizeof(message), "{FFFFFF}{ff0000}[!] {FFA500}Thong tin Balo chinh:\n\
                {FFFFFF}{ff0000}[!]  {00FF00}ID: {FFFFFF}%d\n\
                {FFFFFF}{ff0000}[!]  {00FF00}Ten: {FFFFFF}%s\n\
                {FFFFFF}{ff0000}[!]  {00FF00}Cap do: {FFFFFF}%d\n\
                {FFFFFF}{ff0000}[!]  {00FF00}Ty le thanh cong: {00FF00}%.1f%%",
                baloID, baloName, BaloInfo[baloID][tt_Level], tiLeThanhCong);
            SendClientMessage(playerid, -1, message);
            new baloList[1024];
            format(baloList, sizeof(baloList), "{FFFFFF}{ff0000}[!] {FFA500}Danh sach Balo phoi:\n\n");

            for (new i = 0; i < MAX_BALO; i++) {
                if (BaloInfo[i][tt_BaloID] != 0 && i != baloID) {
                    new Float:phoiSuccessRate = GetPhoiSuccessRate(BaloInfo[i][tt_Level]);
                    format(baloList, sizeof(baloList), "%s{FFFFFF}{ff0000}[!]  {00FF00}ID: {FFFFFF}%d\n{FFFFFF}{ff0000}[!]  {00FF00}Ten: {FFFFFF}%s\n{FFFFFF}{ff0000}[!]  {00FF00}Cap do: {FFFFFF}%d\n{FFFFFF}{ff0000}[!]  {00FF00}Ty le tang: {00FF00}%.1f%%\n\n",
                        baloList, i, BaloInfo[i][tt_tenBalo], BaloInfo[i][tt_Level], phoiSuccessRate);
                }
            }  
            ShowPlayerDialog(playerid, DIALOG_SELECT_BALO_PHOI, DIALOG_STYLE_INPUT, "{FFA500}Chon Balo Phoi", baloList, "OK", "Bo qua");
            SetPVarInt(playerid, "SelectedBaloID", baloID);
        }
        return 1;
    }

    if (dialogid == DIALOG_UPGRADE_SUCCESS) {
        if (response) {
            SendClientMessage(playerid, -1, "{00FF00}[Thong bao] Ban da dong thong bao nang cap Balo hoan tat.");
        }
        return 1;
    }

    if (dialogid == DIALOG_SELECT_BALO_PHOI) {
        if (response) {
            new baloPhoiIDs[3], baloPhoiIDCount = 0;
            StringssangID(inputtext, baloPhoiIDs, baloPhoiIDCount);
            if (baloPhoiIDCount == 0) {
                return SendClientMessage(playerid, -1, "{FF0000}[Loi] Ban chua nhap ID balo phoi nao!");
            }     	
            new baloID = GetPVarInt(playerid, "SelectedBaloID");
            new Float:tiLeThanhCongTruoc = GetSuccessRate(BaloInfo[baloID][tt_Level]);
            new Float:tiLeThanhCong = tiLeThanhCongTruoc;           
            new dialogMsg[1024], lineMsg[1024], totalPhoi = 0;
            format(dialogMsg, sizeof(dialogMsg), "{FFFFFF}{ff0000}[!] {FFA500}Thong tin Balo phoi da chon:\n\n");
            for (new i = 0; i < baloPhoiIDCount; i++) {
                new phoiID = baloPhoiIDs[i];                
                if (phoiID < 0 || phoiID >= MAX_BALO) {
                    format(lineMsg, sizeof(lineMsg), "{FF0000}{ff0000}[!]  Phoi %d: ID khong hop le! (0-%d)\n", i + 1, MAX_BALO - 1);
                    strcat(dialogMsg, lineMsg);
                    return 1;
                }                
                if (BaloInfo[phoiID][tt_BaloID] != 1) {
                    format(lineMsg, sizeof(lineMsg), "{FF0000}{ff0000}[!]  Phoi %d: Balo khong ton tai!\n", i + 1);
                    strcat(dialogMsg, lineMsg);
                    return 1;
                }               
                tiLeThanhCong += GetPhoiSuccessRate(BaloInfo[phoiID][tt_Level]);
                totalPhoi++;               
                format(lineMsg, sizeof(lineMsg), "{FFFFFF}{ff0000}[!]  {00FF00}ID: {FFFFFF}%d\n{FFFFFF}{ff0000}[!]  {00FF00}Ten: {FFFFFF}%s\n{FFFFFF}{ff0000}[!]  {00FF00}Cap do: {FFFFFF}%d\n{FFFFFF}{ff0000}[!]  {00FF00}Ty le tang: {00FF00}%.1f%%\n\n",
                    phoiID, BaloInfo[phoiID][tt_tenBalo], BaloInfo[phoiID][tt_Level], GetPhoiSuccessRate(BaloInfo[phoiID][tt_Level]));
                strcat(dialogMsg, lineMsg);
            }            
            if (totalPhoi == 0) {
                strcat(dialogMsg, "{FFFF00}{ff0000}[!]  Khong su dung balo phoi!\n");
            }            
            format(lineMsg, sizeof(lineMsg), "\n{FFFFFF}{ff0000}[!] {FFA500}Ty le cuoi cung :\n\
                {FFFFFF}{ff0000}[!]  {00FF00}Ty le goc: {FFFFFF}%.1f%%\n\
                {FFFFFF}{ff0000}[!]  {00FF00}Ty le moi: {FFFFFF}%.1f%%",
                tiLeThanhCongTruoc,
                tiLeThanhCong
            );
            strcat(dialogMsg, lineMsg);            
            ShowPlayerDialog(playerid, DIALOG_PROGRESS1, DIALOG_STYLE_MSGBOX,
                "{FFA500}Xac nhan nang cap",
                dialogMsg,
                "Nang cap",
                "Huy"
            );
        }
        return 1;
    }
    return 1;
}

forward CreateFireworkExplosion(Float:x, Float:y, Float:z);
public CreateFireworkExplosion(Float:x, Float:y, Float:z) {
    CreateExplosion(x, y, z, 0, 2.0);
    return 1;
}

forward OnUpgradeComplete(playerid);
public OnUpgradeComplete(playerid) {
    new baloID = gPlayerUpgradingBaloID[playerid];    
    if (baloID == -1 || BaloInfo[baloID][tt_BaloID] == 0) {
        SendClientMessage(playerid, -1, "{FF0000}[Loi] Qua trinh nang cap bi loi. Vui long thu lai.");
        return 1;
    }   
    new Float:successRate = GetSuccessRate(BaloInfo[baloID][tt_Level]);    
    new success = (random(100) < successRate) ? 1 : 0;   
    if (success) {
        BaloInfo[baloID][tt_Level]++;          
        BaloInfo[baloID][tt_succhua] = GetLevelBalo(BaloInfo[baloID][tt_Level]);     
        BaloInfo[baloID][tt_ObjectID] = GetObjectID(BaloInfo[baloID][tt_Level]);       
        new Float:x, Float:y, Float:z;
        GetPlayerPos(playerid, x, y, z);
        new Float:fireworkX = x, Float:fireworkY = y, Float:fireworkZ = z + 10.0;  
        for (new i = 0; i < 10; i++) {
            SetTimerEx("CreateFireworkExplosion", i * 500, false, "fff", fireworkX, fireworkY, fireworkZ); 
        }     
        new message[1024];
        format(message, sizeof(message), "{00FF00}Nang cap thanh cong!\n\n{FFFFFF}Balo da duoc nang len cap do {00FF00}%d{FFFFFF}.", BaloInfo[baloID][tt_Level]);
        ShowPlayerDialog(playerid, DIALOG_UPGRADE_SUCCESS, DIALOG_STYLE_MSGBOX, "{00FF00}Thanh cong", message, "Dong", "");
    } else {       
        new message[1024];
        format(message, sizeof(message), "{00FF00}Nang cap that bai!\n\n{FFFFFF}Balo khong thay doi.");
        ShowPlayerDialog(playerid, DIALOG_UPGRADE_SUCCESS, DIALOG_STYLE_MSGBOX, "{00FF00}That Bai", message, "Dong", "");  
    }  
    gPlayerUpgradingBaloID[playerid] = -1;
    return 1;
}

stock Addbalo(const name[], const level) {
    new BaloID = -1;
    for (new i = 0; i < MAX_BALO; i++) {
        if (BaloInfo[i][tt_BaloID] == 0) {
            BaloID = i;
            break;
        }
    }
    if (BaloID == -1) return -1;
    BaloInfo[BaloID][tt_Level] = level;
    BaloInfo[BaloID][tt_succhua] = GetLevelBalo(BaloInfo[BaloID][tt_Level]);
    BaloInfo[BaloID][tt_ObjectID] = GetObjectID(BaloInfo[BaloID][tt_Level]);
    format(BaloInfo[BaloID][tt_tenBalo], 1024, "%s", name);
    BaloInfo[BaloID][tt_BaloID] = 1; 
    return BaloID;
}

stock nangcapbalo(baloID) {
    if (BaloInfo[baloID][tt_BaloID] == 0) return -1;
    if (BaloInfo[baloID][tt_Level] >= 5) return -1;
    GetLevelBalo(BaloInfo[baloID][tt_Level]);
    BaloInfo[baloID][tt_Level]++;
    BaloInfo[baloID][tt_succhua] = GetLevelBalo(BaloInfo[baloID][tt_Level]);
    BaloInfo[baloID][tt_ObjectID] = GetObjectID(BaloInfo[baloID][tt_Level]);
    return 1;
}

stock GetLevelBalo(level) {
    new succhua;
    switch(level){
        case 0: succhua = 50;
        case 1: succhua = 200;
        case 2: succhua = 400;
        case 3: succhua = 600;
        case 4: succhua = 1000;
        case 5: succhua = 1500;
        default: succhua = 0;
    }
    return succhua;
}

stock GetObjectID(level) {
    new objectID;
    switch(level){
        case 0: objectID = 1000; 
        case 1: objectID = 1001; 
        case 2: objectID = 1002; 
        case 3: objectID = 1003; 
        case 4: objectID = 1004; 
        case 5: objectID = 1005; 
        default: objectID = -1;
    }
    return objectID;
}

stock GetSuccessRate(level) {
    switch (level) {
        case 0: return 50;
        case 1: return 40;
        case 2: return 30;
        case 3: return 20;
        case 4: return 5;
        default: return 0;
    }
}

stock Float:GetPhoiSuccessRate(level) {
    switch (level) {
        case 0: return 5.0;
        case 1: return 10.0;
        case 2: return 15.0;
        case 3: return 20.0;
        case 4: return 25.0;
        case 5: return 30.0;
        default: return 0;
    }
}

stock StringssangID(const inputtext[], outputIDs[], &count, delimiter = ',') { 
    new len = strlen(inputtext);
    new pos = 0, start = 0;
    count = 0;

    while (pos < len && count < 3) {
        if (inputtext[pos] == delimiter || pos == len - 1) {
            new temp[10];
            if (pos == len - 1) {
                strmid(temp, inputtext, start, pos + 1);
            } else {
                strmid(temp, inputtext, start, pos);
            }
            start = pos + 1;

            outputIDs[count] = strval(temp);
            count++;
        }
        pos++;
    }
    return 1;
}

CMD:ncb(playerid, params[]) {
    new baloList[1024];
    format(baloList, sizeof(baloList), "{FFFFFF}So tien hien co: {FFFF00}$%d{FFFFFF}\n\n", GetPlayerMoney(playerid));
    for (new i = 0; i < MAX_BALO; i++) {
        if (BaloInfo[i][tt_BaloID] != 0) {
            new succhuaTiepTheo;
            new succhuaTiepTheoStr[32];
            new tiLeThanhCong = GetSuccessRate(BaloInfo[i][tt_Level]);
            if (BaloInfo[i][tt_Level] < 5) {
                succhuaTiepTheo = GetLevelBalo(BaloInfo[i][tt_Level] + 1);
                format(succhuaTiepTheoStr, sizeof(succhuaTiepTheoStr), "%d", succhuaTiepTheo);
            } else {
                format(succhuaTiepTheoStr, sizeof(succhuaTiepTheoStr), "Chua mo");
            }
            format(baloList, sizeof(baloList), "{FFFFFF}%s ID : {FF0000}%d{FFFFFF}  \t\tTen : {FFFF00}%s{FFFFFF}  \t\tCap Do : {FFFF00}%d{FFFFFF}  \t\tSuc Chua : {FF0000}%d{FFFFFF} \t\tSuc Chua Cap Tiep Theo: {FF0000}%s{FFFFFF} \t\tTi Le Thanh Cong: {00FF00}%d%%{FFFFFF}\n\n", baloList, i, BaloInfo[i][tt_tenBalo], BaloInfo[i][tt_Level], BaloInfo[i][tt_succhua], succhuaTiepTheoStr, tiLeThanhCong);
        }
    }
    ShowPlayerDialog(playerid, DIALOG_SELECT_BALO, DIALOG_STYLE_INPUT, "Danh sach Balo hien co:", baloList, "OK", "Cancel");
    return 1;
}

CMD:addbalo(playerid, params[]) {
    new name[128], level;
    if (sscanf(params, "s[128]i", name, level)) return SendClientMessage(playerid, -1, "Sai cu phap: /addbalo [ten balo] [level]");
    if (level > 5) return SendClientMessage(playerid, -1, "Khong the add balo cap do nay");
    if (Addbalo(name, level) == -1) return SendClientMessage(playerid, -1, "Khong the them balo moi");
    SendClientMessage(playerid, -1, "Da them balo moi");
    return 1;
}

CMD:deobalo(playerid, params[]) {
    new baloID;
    if (sscanf(params, "i", baloID)) 
        return SendClientMessage(playerid, -1, "Sai cu phap: /deobalo [ID Balo]");
    
    if (BaloInfo[baloID][tt_BaloID] == 0) 
        return SendClientMessage(playerid, -1, "Balo khong ton tai");

    if (PlayerObject[playerid] != INVALID_OBJECT_ID) {
        DestroyPlayerObject(playerid, PlayerObject[playerid]);
        PlayerObject[playerid] = INVALID_OBJECT_ID;
    }
    new objectID = BaloInfo[baloID][tt_ObjectID];
    PlayerObject[playerid] = CreatePlayerObject(
        playerid, 
        objectID, 
        0.0, 0.0, 0.0,   
        0.0, 0.0, 0.0,  
        1.0             
    );
    AttachPlayerObjectToPlayer(
        playerid,               
        PlayerObject[playerid],  
        playerid,               
        0.0, 0.0, 0.0,         
        0.0, 0.0, 0.0          
    );

    PlayerBalo[playerid] = baloID;
    SendClientMessage(playerid, -1, "Da deo balo");
    return 1;
}