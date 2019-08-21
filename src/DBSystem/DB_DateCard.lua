-- Filename: DB_Skill.lua
-- Author: auto-created by XmlToScript tool.
-- Function: it`s auto-created by XmlToScript tool.
--ExcelVBA output tools start flag
module("DB_DateCard", package.seeall)
--{卡牌,类型,（英雄图片ID）,属性,发放权重,}

DateCard = {
	[1] = {["ID"] = 1,["Date_CardType"] = 1,["Date_CardIconID"] = 46,["Figure"] = -1,["Weight"] = 5,},
	[2] = {["ID"] = 2,["Date_CardType"] = 2,["Date_CardIconID"] = 47,["Figure"] = -1,["Weight"] = 5,},
	[3] = {["ID"] = 3,["Date_CardType"] = 3,["Date_CardIconID"] = 48,["Figure"] = -1,["Weight"] = 5,},
	[4] = {["ID"] = 4,["Date_CardType"] = 4,["Date_CardIconID"] = 49,["Figure"] = -1,["Weight"] = 5,},
	[5] = {["ID"] = 5,["Date_CardType"] = 5,["Date_CardIconID"] = 323,["Figure"] = 77,["Weight"] = 1,},
	[6] = {["ID"] = 6,["Date_CardType"] = 5,["Date_CardIconID"] = 324,["Figure"] = 67,["Weight"] = 1,},
	[7] = {["ID"] = 7,["Date_CardType"] = 5,["Date_CardIconID"] = 325,["Figure"] = 99,["Weight"] = 1,},
	[8] = {["ID"] = 8,["Date_CardType"] = 5,["Date_CardIconID"] = 326,["Figure"] = 67,["Weight"] = 1,},
	[9] = {["ID"] = 9,["Date_CardType"] = 5,["Date_CardIconID"] = 327,["Figure"] = 99,["Weight"] = 1,},
	[10] = {["ID"] = 10,["Date_CardType"] = 5,["Date_CardIconID"] = 328,["Figure"] = 76,["Weight"] = 1,},
	[11] = {["ID"] = 11,["Date_CardType"] = 5,["Date_CardIconID"] = 329,["Figure"] = 89,["Weight"] = 1,},
	[12] = {["ID"] = 12,["Date_CardType"] = 5,["Date_CardIconID"] = 330,["Figure"] = 62,["Weight"] = 1,},
	[13] = {["ID"] = 13,["Date_CardType"] = 5,["Date_CardIconID"] = 331,["Figure"] = 62,["Weight"] = 1,},
	[14] = {["ID"] = 14,["Date_CardType"] = 5,["Date_CardIconID"] = 332,["Figure"] = 98,["Weight"] = 1,},
	[15] = {["ID"] = 15,["Date_CardType"] = 5,["Date_CardIconID"] = 333,["Figure"] = 98,["Weight"] = 1,},
	[16] = {["ID"] = 16,["Date_CardType"] = 5,["Date_CardIconID"] = 334,["Figure"] = 70,["Weight"] = 1,},
	[17] = {["ID"] = 17,["Date_CardType"] = 5,["Date_CardIconID"] = 335,["Figure"] = 84,["Weight"] = 1,},
	[18] = {["ID"] = 18,["Date_CardType"] = 5,["Date_CardIconID"] = 336,["Figure"] = 92,["Weight"] = 1,},
	[19] = {["ID"] = 19,["Date_CardType"] = 5,["Date_CardIconID"] = 337,["Figure"] = 82,["Weight"] = 1,},
	[20] = {["ID"] = 20,["Date_CardType"] = 5,["Date_CardIconID"] = 338,["Figure"] = 61,["Weight"] = 1,},
	[21] = {["ID"] = 21,["Date_CardType"] = 5,["Date_CardIconID"] = 339,["Figure"] = 69,["Weight"] = 1,},
	[22] = {["ID"] = 22,["Date_CardType"] = 5,["Date_CardIconID"] = 340,["Figure"] = 94,["Weight"] = 1,},
	[23] = {["ID"] = 23,["Date_CardType"] = 5,["Date_CardIconID"] = 341,["Figure"] = 75,["Weight"] = 1,},
	[24] = {["ID"] = 24,["Date_CardType"] = 5,["Date_CardIconID"] = 342,["Figure"] = 92,["Weight"] = 1,},
	[25] = {["ID"] = 25,["Date_CardType"] = 5,["Date_CardIconID"] = 343,["Figure"] = 72,["Weight"] = 1,},
	[26] = {["ID"] = 26,["Date_CardType"] = 5,["Date_CardIconID"] = 344,["Figure"] = 70,["Weight"] = 1,},
	[27] = {["ID"] = 27,["Date_CardType"] = 5,["Date_CardIconID"] = 345,["Figure"] = 98,["Weight"] = 1,},
	[28] = {["ID"] = 28,["Date_CardType"] = 5,["Date_CardIconID"] = 346,["Figure"] = 60,["Weight"] = 1,},
	[29] = {["ID"] = 29,["Date_CardType"] = 6,["Date_CardIconID"] = 323,["Figure"] = 72,["Weight"] = 1,},
	[30] = {["ID"] = 30,["Date_CardType"] = 6,["Date_CardIconID"] = 324,["Figure"] = 96,["Weight"] = 1,},
	[31] = {["ID"] = 31,["Date_CardType"] = 6,["Date_CardIconID"] = 325,["Figure"] = 93,["Weight"] = 1,},
	[32] = {["ID"] = 32,["Date_CardType"] = 6,["Date_CardIconID"] = 326,["Figure"] = 64,["Weight"] = 1,},
	[33] = {["ID"] = 33,["Date_CardType"] = 6,["Date_CardIconID"] = 327,["Figure"] = 94,["Weight"] = 1,},
	[34] = {["ID"] = 34,["Date_CardType"] = 6,["Date_CardIconID"] = 328,["Figure"] = 87,["Weight"] = 1,},
	[35] = {["ID"] = 35,["Date_CardType"] = 6,["Date_CardIconID"] = 329,["Figure"] = 98,["Weight"] = 1,},
	[36] = {["ID"] = 36,["Date_CardType"] = 6,["Date_CardIconID"] = 330,["Figure"] = 83,["Weight"] = 1,},
	[37] = {["ID"] = 37,["Date_CardType"] = 6,["Date_CardIconID"] = 331,["Figure"] = 84,["Weight"] = 1,},
	[38] = {["ID"] = 38,["Date_CardType"] = 6,["Date_CardIconID"] = 332,["Figure"] = 95,["Weight"] = 1,},
	[39] = {["ID"] = 39,["Date_CardType"] = 6,["Date_CardIconID"] = 333,["Figure"] = 62,["Weight"] = 1,},
	[40] = {["ID"] = 40,["Date_CardType"] = 6,["Date_CardIconID"] = 334,["Figure"] = 71,["Weight"] = 1,},
	[41] = {["ID"] = 41,["Date_CardType"] = 6,["Date_CardIconID"] = 335,["Figure"] = 70,["Weight"] = 1,},
	[42] = {["ID"] = 42,["Date_CardType"] = 6,["Date_CardIconID"] = 336,["Figure"] = 91,["Weight"] = 1,},
	[43] = {["ID"] = 43,["Date_CardType"] = 6,["Date_CardIconID"] = 337,["Figure"] = 61,["Weight"] = 1,},
	[44] = {["ID"] = 44,["Date_CardType"] = 6,["Date_CardIconID"] = 338,["Figure"] = 89,["Weight"] = 1,},
	[45] = {["ID"] = 45,["Date_CardType"] = 6,["Date_CardIconID"] = 339,["Figure"] = 76,["Weight"] = 1,},
	[46] = {["ID"] = 46,["Date_CardType"] = 6,["Date_CardIconID"] = 340,["Figure"] = 95,["Weight"] = 1,},
	[47] = {["ID"] = 47,["Date_CardType"] = 6,["Date_CardIconID"] = 341,["Figure"] = 74,["Weight"] = 1,},
	[48] = {["ID"] = 48,["Date_CardType"] = 6,["Date_CardIconID"] = 342,["Figure"] = 96,["Weight"] = 1,},
	[49] = {["ID"] = 49,["Date_CardType"] = 6,["Date_CardIconID"] = 343,["Figure"] = 89,["Weight"] = 1,},
	[50] = {["ID"] = 50,["Date_CardType"] = 6,["Date_CardIconID"] = 344,["Figure"] = 99,["Weight"] = 1,},
	[51] = {["ID"] = 51,["Date_CardType"] = 6,["Date_CardIconID"] = 345,["Figure"] = 84,["Weight"] = 1,},
	[52] = {["ID"] = 52,["Date_CardType"] = 6,["Date_CardIconID"] = 346,["Figure"] = 73,["Weight"] = 1,},
	[53] = {["ID"] = 53,["Date_CardType"] = 7,["Date_CardIconID"] = 323,["Figure"] = 63,["Weight"] = 1,},
	[54] = {["ID"] = 54,["Date_CardType"] = 7,["Date_CardIconID"] = 324,["Figure"] = 68,["Weight"] = 1,},
	[55] = {["ID"] = 55,["Date_CardType"] = 7,["Date_CardIconID"] = 325,["Figure"] = 76,["Weight"] = 1,},
	[56] = {["ID"] = 56,["Date_CardType"] = 7,["Date_CardIconID"] = 326,["Figure"] = 99,["Weight"] = 1,},
	[57] = {["ID"] = 57,["Date_CardType"] = 7,["Date_CardIconID"] = 327,["Figure"] = 92,["Weight"] = 1,},
	[58] = {["ID"] = 58,["Date_CardType"] = 7,["Date_CardIconID"] = 328,["Figure"] = 64,["Weight"] = 1,},
	[59] = {["ID"] = 59,["Date_CardType"] = 7,["Date_CardIconID"] = 329,["Figure"] = 84,["Weight"] = 1,},
	[60] = {["ID"] = 60,["Date_CardType"] = 7,["Date_CardIconID"] = 330,["Figure"] = 75,["Weight"] = 1,},
	[61] = {["ID"] = 61,["Date_CardType"] = 7,["Date_CardIconID"] = 331,["Figure"] = 69,["Weight"] = 1,},
	[62] = {["ID"] = 62,["Date_CardType"] = 7,["Date_CardIconID"] = 332,["Figure"] = 87,["Weight"] = 1,},
	[63] = {["ID"] = 63,["Date_CardType"] = 7,["Date_CardIconID"] = 333,["Figure"] = 61,["Weight"] = 1,},
	[64] = {["ID"] = 64,["Date_CardType"] = 7,["Date_CardIconID"] = 334,["Figure"] = 93,["Weight"] = 1,},
	[65] = {["ID"] = 65,["Date_CardType"] = 7,["Date_CardIconID"] = 335,["Figure"] = 94,["Weight"] = 1,},
	[66] = {["ID"] = 66,["Date_CardType"] = 7,["Date_CardIconID"] = 336,["Figure"] = 83,["Weight"] = 1,},
	[67] = {["ID"] = 67,["Date_CardType"] = 7,["Date_CardIconID"] = 337,["Figure"] = 67,["Weight"] = 1,},
	[68] = {["ID"] = 68,["Date_CardType"] = 7,["Date_CardIconID"] = 338,["Figure"] = 70,["Weight"] = 1,},
	[69] = {["ID"] = 69,["Date_CardType"] = 7,["Date_CardIconID"] = 339,["Figure"] = 99,["Weight"] = 1,},
	[70] = {["ID"] = 70,["Date_CardType"] = 7,["Date_CardIconID"] = 340,["Figure"] = 93,["Weight"] = 1,},
	[71] = {["ID"] = 71,["Date_CardType"] = 7,["Date_CardIconID"] = 341,["Figure"] = 72,["Weight"] = 1,},
	[72] = {["ID"] = 72,["Date_CardType"] = 7,["Date_CardIconID"] = 342,["Figure"] = 95,["Weight"] = 1,},
	[73] = {["ID"] = 73,["Date_CardType"] = 7,["Date_CardIconID"] = 343,["Figure"] = 94,["Weight"] = 1,},
	[74] = {["ID"] = 74,["Date_CardType"] = 7,["Date_CardIconID"] = 344,["Figure"] = 87,["Weight"] = 1,},
	[75] = {["ID"] = 75,["Date_CardType"] = 7,["Date_CardIconID"] = 345,["Figure"] = 98,["Weight"] = 1,},
	[76] = {["ID"] = 76,["Date_CardType"] = 7,["Date_CardIconID"] = 346,["Figure"] = 61,["Weight"] = 1,},
}

function getDataById(key_id)
    local id_data = DateCard[key_id]

    return id_data
end

function getArrDataByField(fieldName, fieldValue)
    local arrData = {}
    for k, v in pairs(DateCard) do
        if v[fieldName] == fieldValue then
            arrData[#arrData+1] = v
        end
    end

    return arrData
end

function release()
    _G["DB_DateCard"] = nil
    package.loaded["DB_DateCard"] = nil
    package.loaded["DBSystem/DB_DateCard"] = nil
end
--ExcelVBA output tools end flag