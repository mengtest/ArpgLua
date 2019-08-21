-- Filename: DB_Skill.lua
-- Author: auto-created by XmlToScript tool.
-- Function: it`s auto-created by XmlToScript tool.
--ExcelVBA output tools start flag
module("DB_EventSpecific", package.seeall)
--{序号,结果（1，完美成功；2，比较成功；3，小成功；4,一般）,目标类型,目标值,}

EventSpecific = {
	[1] = {["ID"] = 1,["Event_SpecificResult"] = 1,["Event_Type"] = 1,["Event_Value"] = 100,},
	[2] = {["ID"] = 2,["Event_SpecificResult"] = 2,["Event_Type"] = 1,["Event_Value"] = 80,},
	[3] = {["ID"] = 3,["Event_SpecificResult"] = 3,["Event_Type"] = 1,["Event_Value"] = 50,},
	[4] = {["ID"] = 4,["Event_SpecificResult"] = 4,["Event_Type"] = 1,["Event_Value"] = 30,},
	[5] = {["ID"] = 5,["Event_SpecificResult"] = 1,["Event_Type"] = 2,["Event_Value"] = 20,},
	[6] = {["ID"] = 6,["Event_SpecificResult"] = 2,["Event_Type"] = 2,["Event_Value"] = 15,},
	[7] = {["ID"] = 7,["Event_SpecificResult"] = 3,["Event_Type"] = 2,["Event_Value"] = 10,},
	[8] = {["ID"] = 8,["Event_SpecificResult"] = 4,["Event_Type"] = 2,["Event_Value"] = 5,},
	[9] = {["ID"] = 9,["Event_SpecificResult"] = 1,["Event_Type"] = 2,["Event_Value"] = 20,},
	[10] = {["ID"] = 10,["Event_SpecificResult"] = 2,["Event_Type"] = 2,["Event_Value"] = 15,},
	[11] = {["ID"] = 11,["Event_SpecificResult"] = 3,["Event_Type"] = 2,["Event_Value"] = 10,},
	[12] = {["ID"] = 12,["Event_SpecificResult"] = 4,["Event_Type"] = 2,["Event_Value"] = 5,},
	[13] = {["ID"] = 13,["Event_SpecificResult"] = 1,["Event_Type"] = 1,["Event_Value"] = 100,},
	[14] = {["ID"] = 14,["Event_SpecificResult"] = 2,["Event_Type"] = 1,["Event_Value"] = 80,},
	[15] = {["ID"] = 15,["Event_SpecificResult"] = 3,["Event_Type"] = 1,["Event_Value"] = 50,},
	[16] = {["ID"] = 16,["Event_SpecificResult"] = 4,["Event_Type"] = 1,["Event_Value"] = 30,},
	[17] = {["ID"] = 17,["Event_SpecificResult"] = 1,["Event_Type"] = 2,["Event_Value"] = 20,},
	[18] = {["ID"] = 18,["Event_SpecificResult"] = 2,["Event_Type"] = 2,["Event_Value"] = 16,},
	[19] = {["ID"] = 19,["Event_SpecificResult"] = 3,["Event_Type"] = 2,["Event_Value"] = 10,},
	[20] = {["ID"] = 20,["Event_SpecificResult"] = 4,["Event_Type"] = 2,["Event_Value"] = 6,},
	[21] = {["ID"] = 21,["Event_SpecificResult"] = 1,["Event_Type"] = 1,["Event_Value"] = 100,},
	[22] = {["ID"] = 22,["Event_SpecificResult"] = 2,["Event_Type"] = 1,["Event_Value"] = 80,},
	[23] = {["ID"] = 23,["Event_SpecificResult"] = 3,["Event_Type"] = 1,["Event_Value"] = 50,},
	[24] = {["ID"] = 24,["Event_SpecificResult"] = 4,["Event_Type"] = 1,["Event_Value"] = 30,},
	[25] = {["ID"] = 25,["Event_SpecificResult"] = 1,["Event_Type"] = 2,["Event_Value"] = 20,},
	[26] = {["ID"] = 26,["Event_SpecificResult"] = 2,["Event_Type"] = 2,["Event_Value"] = 15,},
	[27] = {["ID"] = 27,["Event_SpecificResult"] = 3,["Event_Type"] = 2,["Event_Value"] = 10,},
	[28] = {["ID"] = 28,["Event_SpecificResult"] = 4,["Event_Type"] = 2,["Event_Value"] = 5,},
	[29] = {["ID"] = 29,["Event_SpecificResult"] = 1,["Event_Type"] = 2,["Event_Value"] = 20,},
	[30] = {["ID"] = 30,["Event_SpecificResult"] = 2,["Event_Type"] = 2,["Event_Value"] = 15,},
	[31] = {["ID"] = 31,["Event_SpecificResult"] = 3,["Event_Type"] = 2,["Event_Value"] = 10,},
	[32] = {["ID"] = 32,["Event_SpecificResult"] = 4,["Event_Type"] = 2,["Event_Value"] = 5,},
	[33] = {["ID"] = 33,["Event_SpecificResult"] = 1,["Event_Type"] = 1,["Event_Value"] = 100,},
	[34] = {["ID"] = 34,["Event_SpecificResult"] = 2,["Event_Type"] = 1,["Event_Value"] = 80,},
	[35] = {["ID"] = 35,["Event_SpecificResult"] = 3,["Event_Type"] = 1,["Event_Value"] = 50,},
	[36] = {["ID"] = 36,["Event_SpecificResult"] = 4,["Event_Type"] = 1,["Event_Value"] = 30,},
	[37] = {["ID"] = 37,["Event_SpecificResult"] = 1,["Event_Type"] = 1,["Event_Value"] = 100,},
	[38] = {["ID"] = 38,["Event_SpecificResult"] = 2,["Event_Type"] = 1,["Event_Value"] = 80,},
	[39] = {["ID"] = 39,["Event_SpecificResult"] = 3,["Event_Type"] = 1,["Event_Value"] = 50,},
	[40] = {["ID"] = 40,["Event_SpecificResult"] = 4,["Event_Type"] = 1,["Event_Value"] = 30,},
}

function getDataById(key_id)
    local id_data = EventSpecific[key_id]

    return id_data
end

function getArrDataByField(fieldName, fieldValue)
    local arrData = {}
    for k, v in pairs(EventSpecific) do
        if v[fieldName] == fieldValue then
            arrData[#arrData+1] = v
        end
    end

    return arrData
end

function release()
    _G["DB_EventSpecific"] = nil
    package.loaded["DB_EventSpecific"] = nil
    package.loaded["DBSystem/DB_EventSpecific"] = nil
end
--ExcelVBA output tools end flag