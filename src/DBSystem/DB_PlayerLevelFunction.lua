-- Filename: DB_Skill.lua
-- Author: auto-created by XmlToScript tool.
-- Function: it`s auto-created by XmlToScript tool.
--ExcelVBA output tools start flag
module("DB_PlayerLevelFunction", package.seeall)
--{id,玩家等级,功能名称ID,功能开放等级,功能图标ID,功能描述ID,}

PlayerLevelFunction = {
	[1] = {["ID"] = 1,["Level"] = 1,["NameID"] = 5318,["OpenLevel"] = 4,["IconID"] = 547,["FunctionDescID"] = 5368,},
	[2] = {["ID"] = 2,["Level"] = 2,["NameID"] = 5318,["OpenLevel"] = 4,["IconID"] = 547,["FunctionDescID"] = 5368,},
	[3] = {["ID"] = 3,["Level"] = 3,["NameID"] = 5318,["OpenLevel"] = 4,["IconID"] = 547,["FunctionDescID"] = 5368,},
	[4] = {["ID"] = 4,["Level"] = 4,["NameID"] = 5303,["OpenLevel"] = 6,["IconID"] = 533,["FunctionDescID"] = 5353,},
	[5] = {["ID"] = 5,["Level"] = 5,["NameID"] = 5303,["OpenLevel"] = 6,["IconID"] = 533,["FunctionDescID"] = 5353,},
	[6] = {["ID"] = 6,["Level"] = 6,["NameID"] = 5314,["OpenLevel"] = 7,["IconID"] = 545,["FunctionDescID"] = 5364,},
	[7] = {["ID"] = 7,["Level"] = 7,["NameID"] = 5322,["OpenLevel"] = 8,["IconID"] = 537,["FunctionDescID"] = 5372,},
	[8] = {["ID"] = 8,["Level"] = 8,["NameID"] = 5306,["OpenLevel"] = 10,["IconID"] = 538,["FunctionDescID"] = 5356,},
	[9] = {["ID"] = 9,["Level"] = 9,["NameID"] = 5306,["OpenLevel"] = 10,["IconID"] = 538,["FunctionDescID"] = 5356,},
	[10] = {["ID"] = 10,["Level"] = 10,["NameID"] = 5323,["OpenLevel"] = 13,["IconID"] = 537,["FunctionDescID"] = 5373,},
	[11] = {["ID"] = 11,["Level"] = 11,["NameID"] = 5323,["OpenLevel"] = 13,["IconID"] = 537,["FunctionDescID"] = 5373,},
	[12] = {["ID"] = 12,["Level"] = 12,["NameID"] = 5323,["OpenLevel"] = 13,["IconID"] = 537,["FunctionDescID"] = 5373,},
	[13] = {["ID"] = 13,["Level"] = 13,["NameID"] = 5304,["OpenLevel"] = 15,["IconID"] = 534,["FunctionDescID"] = 5354,},
	[14] = {["ID"] = 14,["Level"] = 14,["NameID"] = 5304,["OpenLevel"] = 15,["IconID"] = 534,["FunctionDescID"] = 5354,},
	[15] = {["ID"] = 15,["Level"] = 15,["NameID"] = 5310,["OpenLevel"] = 17,["IconID"] = 542,["FunctionDescID"] = 5360,},
	[16] = {["ID"] = 16,["Level"] = 16,["NameID"] = 5310,["OpenLevel"] = 17,["IconID"] = 542,["FunctionDescID"] = 5360,},
	[17] = {["ID"] = 17,["Level"] = 17,["NameID"] = 5317,["OpenLevel"] = 20,["IconID"] = 546,["FunctionDescID"] = 5367,},
	[18] = {["ID"] = 18,["Level"] = 18,["NameID"] = 5317,["OpenLevel"] = 20,["IconID"] = 546,["FunctionDescID"] = 5367,},
	[19] = {["ID"] = 19,["Level"] = 19,["NameID"] = 5317,["OpenLevel"] = 20,["IconID"] = 546,["FunctionDescID"] = 5367,},
	[20] = {["ID"] = 20,["Level"] = 20,["NameID"] = 5320,["OpenLevel"] = 21,["IconID"] = 549,["FunctionDescID"] = 5370,},
	[21] = {["ID"] = 21,["Level"] = 21,["NameID"] = 5312,["OpenLevel"] = 22,["IconID"] = 544,["FunctionDescID"] = 5362,},
	[22] = {["ID"] = 22,["Level"] = 22,["NameID"] = 5309,["OpenLevel"] = 26,["IconID"] = 541,["FunctionDescID"] = 5359,},
	[23] = {["ID"] = 23,["Level"] = 23,["NameID"] = 5309,["OpenLevel"] = 26,["IconID"] = 541,["FunctionDescID"] = 5359,},
	[24] = {["ID"] = 24,["Level"] = 24,["NameID"] = 5309,["OpenLevel"] = 26,["IconID"] = 541,["FunctionDescID"] = 5359,},
	[25] = {["ID"] = 25,["Level"] = 25,["NameID"] = 5309,["OpenLevel"] = 26,["IconID"] = 541,["FunctionDescID"] = 5359,},
	[26] = {["ID"] = 26,["Level"] = 26,["NameID"] = 5307,["OpenLevel"] = 30,["IconID"] = 539,["FunctionDescID"] = 5357,},
	[27] = {["ID"] = 27,["Level"] = 27,["NameID"] = 5307,["OpenLevel"] = 30,["IconID"] = 539,["FunctionDescID"] = 5357,},
	[28] = {["ID"] = 28,["Level"] = 28,["NameID"] = 5307,["OpenLevel"] = 30,["IconID"] = 539,["FunctionDescID"] = 5357,},
	[29] = {["ID"] = 29,["Level"] = 29,["NameID"] = 5307,["OpenLevel"] = 30,["IconID"] = 539,["FunctionDescID"] = 5357,},
	[30] = {["ID"] = 30,["Level"] = 30,["NameID"] = 5321,["OpenLevel"] = 33,["IconID"] = 550,["FunctionDescID"] = 5371,},
	[31] = {["ID"] = 31,["Level"] = 31,["NameID"] = 5321,["OpenLevel"] = 33,["IconID"] = 550,["FunctionDescID"] = 5371,},
	[32] = {["ID"] = 32,["Level"] = 32,["NameID"] = 5321,["OpenLevel"] = 33,["IconID"] = 550,["FunctionDescID"] = 5371,},
	[33] = {["ID"] = 33,["Level"] = 33,["NameID"] = 5311,["OpenLevel"] = 36,["IconID"] = 543,["FunctionDescID"] = 5361,},
	[34] = {["ID"] = 34,["Level"] = 34,["NameID"] = 5311,["OpenLevel"] = 36,["IconID"] = 543,["FunctionDescID"] = 5361,},
	[35] = {["ID"] = 35,["Level"] = 35,["NameID"] = 5311,["OpenLevel"] = 36,["IconID"] = 543,["FunctionDescID"] = 5361,},
	[36] = {["ID"] = 36,["Level"] = 36,["NameID"] = 5305,["OpenLevel"] = 39,["IconID"] = 535,["FunctionDescID"] = 5355,},
	[37] = {["ID"] = 37,["Level"] = 37,["NameID"] = 5305,["OpenLevel"] = 39,["IconID"] = 535,["FunctionDescID"] = 5355,},
	[38] = {["ID"] = 38,["Level"] = 38,["NameID"] = 5305,["OpenLevel"] = 39,["IconID"] = 535,["FunctionDescID"] = 5355,},
}

function getDataById(key_id)
    local id_data = PlayerLevelFunction[key_id]

    return id_data
end

function getArrDataByField(fieldName, fieldValue)
    local arrData = {}
    for k, v in pairs(PlayerLevelFunction) do
        if v[fieldName] == fieldValue then
            arrData[#arrData+1] = v
        end
    end

    return arrData
end

function release()
    _G["DB_PlayerLevelFunction"] = nil
    package.loaded["DB_PlayerLevelFunction"] = nil
    package.loaded["DBSystem/DB_PlayerLevelFunction"] = nil
end
--ExcelVBA output tools end flag