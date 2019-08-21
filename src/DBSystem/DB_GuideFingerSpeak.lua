-- Filename: DB_Skill.lua
-- Author: auto-created by XmlToScript tool.
-- Function: it`s auto-created by XmlToScript tool.
--ExcelVBA output tools start flag
module("DB_GuideFingerSpeak", package.seeall)
--{ID,数量,对话1,对话2,对话3,对话4,对话5,对话6,对话7,对话8,对话9,对话10,}

GuideFingerSpeak = {
	[1] = {["ID"] = 1,["Number"] = 2,["Speak_1"] = 1001,["Speak_2"] = 1001,["Speak_3"] = -1,["Speak_4"] = -1,["Speak_5"] = -1,["Speak_6"] = -1,},
	[2] = {["ID"] = 2,["Number"] = 4,["Speak_1"] = 1001,["Speak_2"] = 1001,["Speak_3"] = 1001,["Speak_4"] = 1001,["Speak_5"] = -1,["Speak_6"] = -1,},
	[3] = {["ID"] = 3,["Number"] = 6,["Speak_1"] = 1001,["Speak_2"] = 1001,["Speak_3"] = 1001,["Speak_4"] = 1001,["Speak_5"] = 1001,["Speak_6"] = 1001,},
	[4] = {["ID"] = 4,["Number"] = 2,["Speak_1"] = 1001,["Speak_2"] = 1001,["Speak_3"] = -1,["Speak_4"] = -1,["Speak_5"] = -1,["Speak_6"] = -1,},
	[5] = {["ID"] = 5,["Number"] = 4,["Speak_1"] = 1001,["Speak_2"] = 1001,["Speak_3"] = 1001,["Speak_4"] = 1001,["Speak_5"] = -1,["Speak_6"] = -1,},
}

function getDataById(key_id)
    local id_data = GuideFingerSpeak[key_id]

    return id_data
end

function getArrDataByField(fieldName, fieldValue)
    local arrData = {}
    for k, v in pairs(GuideFingerSpeak) do
        if v[fieldName] == fieldValue then
            arrData[#arrData+1] = v
        end
    end

    return arrData
end

function release()
    _G["DB_GuideFingerSpeak"] = nil
    package.loaded["DB_GuideFingerSpeak"] = nil
    package.loaded["DBSystem/DB_GuideFingerSpeak"] = nil
end
--ExcelVBA output tools end flag