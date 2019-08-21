-- Filename: DB_Skill.lua
-- Author: auto-created by XmlToScript tool.
-- Function: it`s auto-created by XmlToScript tool.
--ExcelVBA output tools start flag
module("DB_PlayerIcon", package.seeall)
--{ID,类型,资源ID,开启条件-VIP等级,开启条件-拥有英雄ID,相应提示,}

PlayerIcon = {
	[1001] = {["ID"] = 1001,["Type"] = 1,["ResourceListID"] = 2701,["VIP"] = 0,["HeroID"] = 0,["Tips"] = 0,},
	[1002] = {["ID"] = 1002,["Type"] = 1,["ResourceListID"] = 2702,["VIP"] = 0,["HeroID"] = 0,["Tips"] = 0,},
	[1003] = {["ID"] = 1003,["Type"] = 1,["ResourceListID"] = 2703,["VIP"] = 0,["HeroID"] = 0,["Tips"] = 0,},
	[1101] = {["ID"] = 1101,["Type"] = 1,["ResourceListID"] = 2704,["VIP"] = 1,["HeroID"] = 0,["Tips"] = 5001,},
	[1102] = {["ID"] = 1102,["Type"] = 1,["ResourceListID"] = 2705,["VIP"] = 6,["HeroID"] = 0,["Tips"] = 5002,},
	[1103] = {["ID"] = 1103,["Type"] = 1,["ResourceListID"] = 2706,["VIP"] = 11,["HeroID"] = 0,["Tips"] = 5003,},
	[1104] = {["ID"] = 1104,["Type"] = 1,["ResourceListID"] = 2707,["VIP"] = 15,["HeroID"] = 0,["Tips"] = 5004,},
	[2001] = {["ID"] = 2001,["Type"] = 2,["ResourceListID"] = 2708,["VIP"] = 0,["HeroID"] = 0,["Tips"] = 0,},
	[2002] = {["ID"] = 2002,["Type"] = 2,["ResourceListID"] = 2709,["VIP"] = 0,["HeroID"] = 0,["Tips"] = 0,},
	[2003] = {["ID"] = 2003,["Type"] = 2,["ResourceListID"] = 2710,["VIP"] = 0,["HeroID"] = 0,["Tips"] = 0,},
	[2004] = {["ID"] = 2004,["Type"] = 2,["ResourceListID"] = 2711,["VIP"] = 0,["HeroID"] = 0,["Tips"] = 0,},
	[2102] = {["ID"] = 2102,["Type"] = 2,["ResourceListID"] = 2713,["VIP"] = 0,["HeroID"] = 2,["Tips"] = 5021,},
	[2104] = {["ID"] = 2104,["Type"] = 2,["ResourceListID"] = 2715,["VIP"] = 0,["HeroID"] = 4,["Tips"] = 5022,},
	[2105] = {["ID"] = 2105,["Type"] = 2,["ResourceListID"] = 2716,["VIP"] = 0,["HeroID"] = 5,["Tips"] = 5023,},
	[2106] = {["ID"] = 2106,["Type"] = 2,["ResourceListID"] = 2717,["VIP"] = 0,["HeroID"] = 6,["Tips"] = 5024,},
	[2107] = {["ID"] = 2107,["Type"] = 2,["ResourceListID"] = 2718,["VIP"] = 0,["HeroID"] = 7,["Tips"] = 5025,},
	[2108] = {["ID"] = 2108,["Type"] = 2,["ResourceListID"] = 2719,["VIP"] = 0,["HeroID"] = 8,["Tips"] = 5026,},
	[2110] = {["ID"] = 2110,["Type"] = 2,["ResourceListID"] = 2721,["VIP"] = 0,["HeroID"] = 10,["Tips"] = 5027,},
	[2111] = {["ID"] = 2111,["Type"] = 2,["ResourceListID"] = 2722,["VIP"] = 0,["HeroID"] = 11,["Tips"] = 5028,},
	[2112] = {["ID"] = 2112,["Type"] = 2,["ResourceListID"] = 2723,["VIP"] = 0,["HeroID"] = 12,["Tips"] = 5029,},
	[2113] = {["ID"] = 2113,["Type"] = 2,["ResourceListID"] = 2724,["VIP"] = 0,["HeroID"] = 13,["Tips"] = 5030,},
	[2114] = {["ID"] = 2114,["Type"] = 2,["ResourceListID"] = 2725,["VIP"] = 0,["HeroID"] = 14,["Tips"] = 5031,},
	[2115] = {["ID"] = 2115,["Type"] = 2,["ResourceListID"] = 2726,["VIP"] = 0,["HeroID"] = 15,["Tips"] = 5032,},
	[2117] = {["ID"] = 2117,["Type"] = 2,["ResourceListID"] = 2728,["VIP"] = 0,["HeroID"] = 17,["Tips"] = 5033,},
	[2119] = {["ID"] = 2119,["Type"] = 2,["ResourceListID"] = 2730,["VIP"] = 0,["HeroID"] = 19,["Tips"] = 5034,},
	[2121] = {["ID"] = 2121,["Type"] = 2,["ResourceListID"] = 2732,["VIP"] = 0,["HeroID"] = 21,["Tips"] = 5035,},
	[2122] = {["ID"] = 2122,["Type"] = 2,["ResourceListID"] = 2733,["VIP"] = 0,["HeroID"] = 22,["Tips"] = 5036,},
	[2123] = {["ID"] = 2123,["Type"] = 2,["ResourceListID"] = 2734,["VIP"] = 0,["HeroID"] = 23,["Tips"] = 5037,},
	[2124] = {["ID"] = 2124,["Type"] = 2,["ResourceListID"] = 2735,["VIP"] = 0,["HeroID"] = 24,["Tips"] = 5038,},
	[2201] = {["ID"] = 2201,["Type"] = 2,["ResourceListID"] = 2736,["VIP"] = 1,["HeroID"] = 0,["Tips"] = 5011,},
	[2202] = {["ID"] = 2202,["Type"] = 2,["ResourceListID"] = 2737,["VIP"] = 6,["HeroID"] = 0,["Tips"] = 5012,},
	[2203] = {["ID"] = 2203,["Type"] = 2,["ResourceListID"] = 2738,["VIP"] = 11,["HeroID"] = 0,["Tips"] = 5013,},
	[2204] = {["ID"] = 2204,["Type"] = 2,["ResourceListID"] = 2739,["VIP"] = 15,["HeroID"] = 0,["Tips"] = 5014,},
}

function getDataById(key_id)
    local id_data = PlayerIcon[key_id]

    return id_data
end

function getArrDataByField(fieldName, fieldValue)
    local arrData = {}
    for k, v in pairs(PlayerIcon) do
        if v[fieldName] == fieldValue then
            arrData[#arrData+1] = v
        end
    end

    return arrData
end

function release()
    _G["DB_PlayerIcon"] = nil
    package.loaded["DB_PlayerIcon"] = nil
    package.loaded["DBSystem/DB_PlayerIcon"] = nil
end
--ExcelVBA output tools end flag