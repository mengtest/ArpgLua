-- Filename: DB_Skill.lua
-- Author: auto-created by XmlToScript tool.
-- Function: it`s auto-created by XmlToScript tool.
--ExcelVBA output tools start flag
module("DB_Notice", package.seeall)
--{id,窗口,类型,}

Notice = {
	[1000] = {["ID"] = 1000,["WindowName"] = "HomeWindow",["Style"] = "server",},
	[1001] = {["ID"] = 1001,["WindowName"] = "DailyRewardWindow",["Style"] = "server",},
	[1002] = {["ID"] = 1002,["WindowName"] = "DailyRewardWindow",["Style"] = "server",},
	[1003] = {["ID"] = 1003,["WindowName"] = "DailyRewardWindow",["Style"] = "server",},
	[1004] = {["ID"] = 1004,["WindowName"] = "DailyRewardWindow",["Style"] = "server",},
	[1005] = {["ID"] = 1005,["WindowName"] = "DailyRewardWindow",["Style"] = "server",},
	[2000] = {["ID"] = 2000,["WindowName"] = "HomeWindow",["Style"] = "server",},
	[3001] = {["ID"] = 3001,["WindowName"] = "HomeWindow",["Style"] = "server",},
	[3002] = {["ID"] = 3002,["WindowName"] = "HomeWindow",["Style"] = "server",},
	[3003] = {["ID"] = 3003,["WindowName"] = "FriendWindow",["Style"] = "server",},
	[3004] = {["ID"] = 3004,["WindowName"] = "FriendWindow",["Style"] = "server",},
	[3101] = {["ID"] = 3101,["WindowName"] = "HomeWindow",["Style"] = "server",},
	[3102] = {["ID"] = 3102,["WindowName"] = "HomeWindow",["Style"] = "server",},
	[3103] = {["ID"] = 3103,["WindowName"] = "HomeWindow",["Style"] = "client",},
	[3104] = {["ID"] = 3104,["WindowName"] = "HomeWindow",["Style"] = "server",},
	[4000] = {["ID"] = 4000,["WindowName"] = "HomeWindow",["Style"] = "server",},
	[4001] = {["ID"] = 4001,["WindowName"] = "TaskWindow",["Style"] = "server",},
	[4002] = {["ID"] = 4002,["WindowName"] = "TaskWindow",["Style"] = "server",},
	[5000] = {["ID"] = 5000,["WindowName"] = "HomeWindow",["Style"] = "client",},
	[5001] = {["ID"] = 5001,["WindowName"] = "HeroInfoWindow",["Style"] = "client",},
	[5011] = {["ID"] = 5011,["WindowName"] = "HeroInfoWindow",["Style"] = "client",},
	[5012] = {["ID"] = 5012,["WindowName"] = "HeroInfoWindow",["Style"] = "client",},
	[5013] = {["ID"] = 5013,["WindowName"] = "HeroInfoWindow",["Style"] = "client",},
	[5021] = {["ID"] = 5021,["WindowName"] = "HeroInfoWindow",["Style"] = "client",},
	[6000] = {["ID"] = 6000,["WindowName"] = "HomeWindow",["Style"] = "client",},
	[6001] = {["ID"] = 6001,["WindowName"] = "EquipInfoWindow",["Style"] = "client",},
	[6010] = {["ID"] = 6010,["WindowName"] = "EquipInfoWindow",["Style"] = "client",},
	[6011] = {["ID"] = 6011,["WindowName"] = "EquipInfoWindow",["Style"] = "client",},
	[6012] = {["ID"] = 6012,["WindowName"] = "EquipInfoWindow",["Style"] = "client",},
	[7000] = {["ID"] = 7000,["WindowName"] = "HomeWindow",["Style"] = "server",},
	[7001] = {["ID"] = 7001,["WindowName"] = "ArenaWindow",["Style"] = "server",},
	[8000] = {["ID"] = 8000,["WindowName"] = "HomeWindow",["Style"] = "server",},
	[8010] = {["ID"] = 8010,["WindowName"] = "LadderWindow",["Style"] = "server",},
	[8020] = {["ID"] = 8020,["WindowName"] = "LadderWindow",["Style"] = "server",},
	[9000] = {["ID"] = 9000,["WindowName"] = "HomeWindow",["Style"] = "server",},
	[9001] = {["ID"] = 9001,["WindowName"] = "TowerWindow",["Style"] = "server",},
	[9002] = {["ID"] = 9002,["WindowName"] = "TowerWindow",["Style"] = "server",},
	[10000] = {["ID"] = 10000,["WindowName"] = "HomeWindow",["Style"] = "server",},
	[10010] = {["ID"] = 10010,["WindowName"] = "WealthWindow",["Style"] = "server",},
	[10020] = {["ID"] = 10020,["WindowName"] = "WealthWindow",["Style"] = "server",},
	[10030] = {["ID"] = 10030,["WindowName"] = "WealthWindow",["Style"] = "server",},
	[11000] = {["ID"] = 11000,["WindowName"] = "HomeWindow",["Style"] = "server",},
	[11010] = {["ID"] = 11010,["WindowName"] = "BlackMarketWindow",["Style"] = "server",},
	[11020] = {["ID"] = 11020,["WindowName"] = "BlackMarketWindow",["Style"] = "server",},
	[12000] = {["ID"] = 12000,["WindowName"] = "HomeWindow",["Style"] = "server",},
	[12001] = {["ID"] = 12001,["WindowName"] = "TowerExWindow",["Style"] = "server",},
	[13000] = {["ID"] = 13000,["WindowName"] = "HomeWindow",["Style"] = "server",},
	[14000] = {["ID"] = 14000,["WindowName"] = "HomeWindow",["Style"] = "server",},
	[14001] = {["ID"] = 14001,["WindowName"] = "TechnologyWindow",["Style"] = "server",},
	[14002] = {["ID"] = 14002,["WindowName"] = "TechnologyWindow",["Style"] = "client",},
	[15000] = {["ID"] = 15000,["WindowName"] = "HomeWindow",["Style"] = "client",},
	[15001] = {["ID"] = 15001,["WindowName"] = "HomeWindow",["Style"] = "client",},
	[15002] = {["ID"] = 15002,["WindowName"] = "HomeWindow",["Style"] = "client",},
	[15003] = {["ID"] = 15003,["WindowName"] = "HomeWindow",["Style"] = "client",},
	[16000] = {["ID"] = 16000,["WindowName"] = "HomeWindow",["Style"] = "client",},
	[16001] = {["ID"] = 16001,["WindowName"] = "HeroSkillWindow",["Style"] = "client",},
	[16002] = {["ID"] = 16002,["WindowName"] = "HeroSkillWindow",["Style"] = "client",},
	[16003] = {["ID"] = 16003,["WindowName"] = "HeroSkillWindow",["Style"] = "client",},
	[16004] = {["ID"] = 16004,["WindowName"] = "HeroSkillWindow",["Style"] = "client",},
	[17000] = {["ID"] = 17000,["WindowName"] = "HomeWindow",["Style"] = "server",},
	[17010] = {["ID"] = 17010,["WindowName"] = "HorseAndGunWindow",["Style"] = "client",},
	[17020] = {["ID"] = 17020,["WindowName"] = "HorseAndGunWindow",["Style"] = "client",},
	[17001] = {["ID"] = 17001,["WindowName"] = "HorseAndGunWindow",["Style"] = "client",},
	[17002] = {["ID"] = 17002,["WindowName"] = "HorseAndGunWindow",["Style"] = "client",},
	[17003] = {["ID"] = 17003,["WindowName"] = "HorseAndGunWindow",["Style"] = "client",},
	[17004] = {["ID"] = 17004,["WindowName"] = "HorseAndGunWindow",["Style"] = "client",},
	[18000] = {["ID"] = 18000,["WindowName"] = "HomeWindow",["Style"] = "server",},
	[18001] = {["ID"] = 18001,["WindowName"] = "BadgeWindow",["Style"] = "client",},
	[18002] = {["ID"] = 18002,["WindowName"] = "BadgeWindow",["Style"] = "client",},
	[18003] = {["ID"] = 18003,["WindowName"] = "BadgeWindow",["Style"] = "client",},
	[18004] = {["ID"] = 18004,["WindowName"] = "BadgeWindow",["Style"] = "client",},
}

function getDataById(key_id)
    local id_data = Notice[key_id]

    return id_data
end

function getArrDataByField(fieldName, fieldValue)
    local arrData = {}
    for k, v in pairs(Notice) do
        if v[fieldName] == fieldValue then
            arrData[#arrData+1] = v
        end
    end

    return arrData
end

function release()
    _G["DB_Notice"] = nil
    package.loaded["DB_Notice"] = nil
    package.loaded["DBSystem/DB_Notice"] = nil
end
--ExcelVBA output tools end flag