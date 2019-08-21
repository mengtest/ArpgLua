-- Filename: DB_Skill.lua
-- Author: auto-created by XmlToScript tool.
-- Function: it`s auto-created by XmlToScript tool.
--ExcelVBA output tools start flag
module("DB_EventGift", package.seeall)
--{}

EventGift = {
	[1] = {["礼物ID"] = 1,},
	[2] = {["礼物ID"] = 2,},
	[3] = {["礼物ID"] = 3,},
	[4] = {["礼物ID"] = 4,},
	[5] = {["礼物ID"] = 5,},
	[6] = {["礼物ID"] = 6,},
	[7] = {["礼物ID"] = 7,},
	[8] = {["礼物ID"] = 8,},
	[9] = {["礼物ID"] = 9,},
	[10] = {["礼物ID"] = 10,},
	[11] = {["礼物ID"] = 11,},
	[12] = {["礼物ID"] = 12,},
	[13] = {["礼物ID"] = 13,},
	[14] = {["礼物ID"] = 14,},
	[15] = {["礼物ID"] = 15,},
	[16] = {["礼物ID"] = 16,},
	[17] = {["礼物ID"] = 17,},
	[18] = {["礼物ID"] = 18,},
	[19] = {["礼物ID"] = 19,},
	[20] = {["礼物ID"] = 20,},
}

function getDataById(key_id)
    local id_data = EventGift[key_id]

    return id_data
end

function getArrDataByField(fieldName, fieldValue)
    local arrData = {}
    for k, v in pairs(EventGift) do
        if v[fieldName] == fieldValue then
            arrData[#arrData+1] = v
        end
    end

    return arrData
end

function release()
    _G["DB_EventGift"] = nil
    package.loaded["DB_EventGift"] = nil
    package.loaded["DBSystem/DB_EventGift"] = nil
end
--ExcelVBA output tools end flag