-- Filename: DB_Skill.lua
-- Author: auto-created by XmlToScript tool.
-- Function: it`s auto-created by XmlToScript tool.
--ExcelVBA output tools start flag
module("DB_EventHero", package.seeall)
--{序号,实际对应的ID,开放等级,送礼感言,邀约感言,打招呼对白，心情1,打招呼对白，心情2,打招呼对白，心情3,打招呼对白，心情4,}

EventHero = {
	[1] = {["ID"] = 1,["real_ID"] = 1,["Event_OpenLevel"] = 1,["Event_Gift_text"] = 958,["Event_Date_text"] = 982,["Event_Hello_text_1"] = 503,},
	[2] = {["ID"] = 2,["real_ID"] = 2,["Event_OpenLevel"] = 1,["Event_Gift_text"] = 959,["Event_Date_text"] = 983,["Event_Hello_text_1"] = 503,},
	[3] = {["ID"] = 3,["real_ID"] = 3,["Event_OpenLevel"] = 1,["Event_Gift_text"] = 960,["Event_Date_text"] = 984,["Event_Hello_text_1"] = 503,},
	[4] = {["ID"] = 4,["real_ID"] = 4,["Event_OpenLevel"] = 1,["Event_Gift_text"] = 961,["Event_Date_text"] = 985,["Event_Hello_text_1"] = 503,},
	[5] = {["ID"] = 5,["real_ID"] = 5,["Event_OpenLevel"] = 2,["Event_Gift_text"] = 962,["Event_Date_text"] = 986,["Event_Hello_text_1"] = 503,},
	[6] = {["ID"] = 6,["real_ID"] = 6,["Event_OpenLevel"] = 2,["Event_Gift_text"] = 963,["Event_Date_text"] = 987,["Event_Hello_text_1"] = 503,},
	[7] = {["ID"] = 7,["real_ID"] = 7,["Event_OpenLevel"] = 2,["Event_Gift_text"] = 964,["Event_Date_text"] = 988,["Event_Hello_text_1"] = 503,},
	[8] = {["ID"] = 8,["real_ID"] = 8,["Event_OpenLevel"] = 2,["Event_Gift_text"] = 965,["Event_Date_text"] = 989,["Event_Hello_text_1"] = 503,},
	[9] = {["ID"] = 9,["real_ID"] = 9,["Event_OpenLevel"] = 2,["Event_Gift_text"] = 966,["Event_Date_text"] = 990,["Event_Hello_text_1"] = 503,},
	[10] = {["ID"] = 10,["real_ID"] = 10,["Event_OpenLevel"] = 3,["Event_Gift_text"] = 967,["Event_Date_text"] = 991,["Event_Hello_text_1"] = 503,},
	[11] = {["ID"] = 11,["real_ID"] = 11,["Event_OpenLevel"] = 3,["Event_Gift_text"] = 968,["Event_Date_text"] = 992,["Event_Hello_text_1"] = 503,},
	[12] = {["ID"] = 12,["real_ID"] = 12,["Event_OpenLevel"] = 3,["Event_Gift_text"] = 969,["Event_Date_text"] = 993,["Event_Hello_text_1"] = 503,},
	[13] = {["ID"] = 13,["real_ID"] = 13,["Event_OpenLevel"] = 3,["Event_Gift_text"] = 970,["Event_Date_text"] = 994,["Event_Hello_text_1"] = 503,},
	[14] = {["ID"] = 14,["real_ID"] = 14,["Event_OpenLevel"] = 3,["Event_Gift_text"] = 971,["Event_Date_text"] = 995,["Event_Hello_text_1"] = 503,},
	[15] = {["ID"] = 15,["real_ID"] = 15,["Event_OpenLevel"] = 4,["Event_Gift_text"] = 972,["Event_Date_text"] = 996,["Event_Hello_text_1"] = 503,},
	[16] = {["ID"] = 16,["real_ID"] = 16,["Event_OpenLevel"] = 4,["Event_Gift_text"] = 973,["Event_Date_text"] = 997,["Event_Hello_text_1"] = 503,},
	[17] = {["ID"] = 17,["real_ID"] = 17,["Event_OpenLevel"] = 4,["Event_Gift_text"] = 974,["Event_Date_text"] = 998,["Event_Hello_text_1"] = 503,},
	[18] = {["ID"] = 18,["real_ID"] = 18,["Event_OpenLevel"] = 4,["Event_Gift_text"] = 975,["Event_Date_text"] = 999,["Event_Hello_text_1"] = 503,},
	[19] = {["ID"] = 19,["real_ID"] = 19,["Event_OpenLevel"] = 4,["Event_Gift_text"] = 976,["Event_Date_text"] = 1000,["Event_Hello_text_1"] = 503,},
	[20] = {["ID"] = 20,["real_ID"] = 20,["Event_OpenLevel"] = 5,["Event_Gift_text"] = 977,["Event_Date_text"] = 1001,["Event_Hello_text_1"] = 503,},
	[21] = {["ID"] = 21,["real_ID"] = 21,["Event_OpenLevel"] = 5,["Event_Gift_text"] = 978,["Event_Date_text"] = 1002,["Event_Hello_text_1"] = 503,},
	[22] = {["ID"] = 22,["real_ID"] = 22,["Event_OpenLevel"] = 5,["Event_Gift_text"] = 979,["Event_Date_text"] = 1003,["Event_Hello_text_1"] = 503,},
	[23] = {["ID"] = 23,["real_ID"] = 23,["Event_OpenLevel"] = 5,["Event_Gift_text"] = 980,["Event_Date_text"] = 1004,["Event_Hello_text_1"] = 503,},
	[24] = {["ID"] = 24,["real_ID"] = 24,["Event_OpenLevel"] = 5,["Event_Gift_text"] = 981,["Event_Date_text"] = 1005,["Event_Hello_text_1"] = 503,},
}

function getDataById(key_id)
    local id_data = EventHero[key_id]

    return id_data
end

function getArrDataByField(fieldName, fieldValue)
    local arrData = {}
    for k, v in pairs(EventHero) do
        if v[fieldName] == fieldValue then
            arrData[#arrData+1] = v
        end
    end

    return arrData
end

function release()
    _G["DB_EventHero"] = nil
    package.loaded["DB_EventHero"] = nil
    package.loaded["DBSystem/DB_EventHero"] = nil
end
--ExcelVBA output tools end flag