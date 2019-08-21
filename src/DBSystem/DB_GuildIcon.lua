-- Filename: DB_Skill.lua
-- Author: auto-created by XmlToScript tool.
-- Function: it`s auto-created by XmlToScript tool.
--ExcelVBA output tools start flag
module("DB_GuildIcon", package.seeall)
--{ID,资源ID,开启条件-公会等级,相应提示,}

GuildIcon = {
	[1] = {["ID"] = 1,["ResourceListID"] = 2801,["VIP"] = 0,["Tips"] = 0,},
	[2] = {["ID"] = 2,["ResourceListID"] = 2802,["VIP"] = 0,["Tips"] = 0,},
	[3] = {["ID"] = 3,["ResourceListID"] = 2803,["VIP"] = 0,["Tips"] = 0,},
	[4] = {["ID"] = 4,["ResourceListID"] = 2804,["VIP"] = 0,["Tips"] = 0,},
	[5] = {["ID"] = 5,["ResourceListID"] = 2805,["VIP"] = 0,["Tips"] = 0,},
	[6] = {["ID"] = 6,["ResourceListID"] = 2806,["VIP"] = 0,["Tips"] = 0,},
	[7] = {["ID"] = 7,["ResourceListID"] = 2807,["VIP"] = 0,["Tips"] = 0,},
	[8] = {["ID"] = 8,["ResourceListID"] = 2808,["VIP"] = 0,["Tips"] = 0,},
	[9] = {["ID"] = 9,["ResourceListID"] = 2809,["VIP"] = 0,["Tips"] = 0,},
	[10] = {["ID"] = 10,["ResourceListID"] = 2810,["VIP"] = 0,["Tips"] = 0,},
	[11] = {["ID"] = 11,["ResourceListID"] = 2811,["VIP"] = 0,["Tips"] = 0,},
	[12] = {["ID"] = 12,["ResourceListID"] = 2812,["VIP"] = 0,["Tips"] = 0,},
}

function getDataById(key_id)
    local id_data = GuildIcon[key_id]

    return id_data
end

function getArrDataByField(fieldName, fieldValue)
    local arrData = {}
    for k, v in pairs(GuildIcon) do
        if v[fieldName] == fieldValue then
            arrData[#arrData+1] = v
        end
    end

    return arrData
end

function release()
    _G["DB_GuildIcon"] = nil
    package.loaded["DB_GuildIcon"] = nil
    package.loaded["DBSystem/DB_GuildIcon"] = nil
end
--ExcelVBA output tools end flag