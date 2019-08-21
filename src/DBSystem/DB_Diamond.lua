-- Filename: DB_Skill.lua
-- Author: auto-created by XmlToScript tool.
-- Function: it`s auto-created by XmlToScript tool.
--ExcelVBA output tools start flag
module("DB_Diamond", package.seeall)
--{id,宝石类型,名字,客户端排序ID,图标,等级,品质,描述,价格,合成的下一级宝石ID,属性数,增加的属性类型,属性值,增加的属性类型2,属性值2,增加的属性类型3,属性值3,}

Diamond = {
	[25001] = {["ID"] = 25001,["diamondType"] = 1,["Name"] = 173,["ClientIndex"] = 18,["Icon"] = 151,["Level"] = 1,["Quality"] = 2,["description"] = 203,["Money"] = 1250,["NextID"] = 25002,["Count"] = 3,["Type1"] = 1,["value1"] = 30,["Type2"] = 4,["value2"] = 30,["Type3"] = 5,["value3"] = 30,},
	[25002] = {["ID"] = 25002,["diamondType"] = 1,["Name"] = 174,["ClientIndex"] = 18,["Icon"] = 152,["Level"] = 2,["Quality"] = 3,["description"] = 204,["Money"] = 5000,["NextID"] = 25003,["Count"] = 3,["Type1"] = 1,["value1"] = 90,["Type2"] = 4,["value2"] = 90,["Type3"] = 5,["value3"] = 90,},
	[25003] = {["ID"] = 25003,["diamondType"] = 1,["Name"] = 175,["ClientIndex"] = 18,["Icon"] = 153,["Level"] = 3,["Quality"] = 3,["description"] = 205,["Money"] = 20000,["NextID"] = 25004,["Count"] = 3,["Type1"] = 1,["value1"] = 180,["Type2"] = 4,["value2"] = 180,["Type3"] = 5,["value3"] = 180,},
	[25004] = {["ID"] = 25004,["diamondType"] = 1,["Name"] = 176,["ClientIndex"] = 18,["Icon"] = 154,["Level"] = 4,["Quality"] = 4,["description"] = 206,["Money"] = 50000,["NextID"] = 25005,["Count"] = 3,["Type1"] = 1,["value1"] = 300,["Type2"] = 4,["value2"] = 300,["Type3"] = 5,["value3"] = 300,},
	[25005] = {["ID"] = 25005,["diamondType"] = 1,["Name"] = 177,["ClientIndex"] = 18,["Icon"] = 155,["Level"] = 5,["Quality"] = 4,["description"] = 207,["Money"] = 100000,["NextID"] = 25031,["Count"] = 3,["Type1"] = 1,["value1"] = 450,["Type2"] = 4,["value2"] = 450,["Type3"] = 5,["value3"] = 450,},
	[25006] = {["ID"] = 25006,["diamondType"] = 2,["Name"] = 178,["ClientIndex"] = 18,["Icon"] = 156,["Level"] = 1,["Quality"] = 2,["description"] = 208,["Money"] = 1250,["NextID"] = 25007,["Count"] = 1,["Type1"] = 0,["value1"] = 500,},
	[25007] = {["ID"] = 25007,["diamondType"] = 2,["Name"] = 179,["ClientIndex"] = 18,["Icon"] = 157,["Level"] = 2,["Quality"] = 3,["description"] = 209,["Money"] = 5000,["NextID"] = 25008,["Count"] = 1,["Type1"] = 0,["value1"] = 1500,},
	[25008] = {["ID"] = 25008,["diamondType"] = 2,["Name"] = 180,["ClientIndex"] = 18,["Icon"] = 158,["Level"] = 3,["Quality"] = 3,["description"] = 210,["Money"] = 20000,["NextID"] = 25009,["Count"] = 1,["Type1"] = 0,["value1"] = 3000,},
	[25009] = {["ID"] = 25009,["diamondType"] = 2,["Name"] = 181,["ClientIndex"] = 18,["Icon"] = 159,["Level"] = 4,["Quality"] = 4,["description"] = 211,["Money"] = 50000,["NextID"] = 25010,["Count"] = 1,["Type1"] = 0,["value1"] = 5000,},
	[25010] = {["ID"] = 25010,["diamondType"] = 2,["Name"] = 182,["ClientIndex"] = 18,["Icon"] = 160,["Level"] = 5,["Quality"] = 4,["description"] = 212,["Money"] = 100000,["NextID"] = 25032,["Count"] = 1,["Type1"] = 0,["value1"] = 7500,},
	[25011] = {["ID"] = 25011,["diamondType"] = 3,["Name"] = 183,["ClientIndex"] = 18,["Icon"] = 161,["Level"] = 1,["Quality"] = 2,["description"] = 213,["Money"] = 1250,["NextID"] = 25012,["Count"] = 1,["Type1"] = 2,["value1"] = 50,},
	[25012] = {["ID"] = 25012,["diamondType"] = 3,["Name"] = 184,["ClientIndex"] = 18,["Icon"] = 162,["Level"] = 2,["Quality"] = 3,["description"] = 214,["Money"] = 5000,["NextID"] = 25013,["Count"] = 1,["Type1"] = 2,["value1"] = 150,},
	[25013] = {["ID"] = 25013,["diamondType"] = 3,["Name"] = 185,["ClientIndex"] = 18,["Icon"] = 163,["Level"] = 3,["Quality"] = 3,["description"] = 215,["Money"] = 20000,["NextID"] = 25014,["Count"] = 1,["Type1"] = 2,["value1"] = 300,},
	[25014] = {["ID"] = 25014,["diamondType"] = 3,["Name"] = 186,["ClientIndex"] = 18,["Icon"] = 164,["Level"] = 4,["Quality"] = 4,["description"] = 216,["Money"] = 50000,["NextID"] = 25015,["Count"] = 1,["Type1"] = 2,["value1"] = 500,},
	[25015] = {["ID"] = 25015,["diamondType"] = 3,["Name"] = 187,["ClientIndex"] = 18,["Icon"] = 165,["Level"] = 5,["Quality"] = 4,["description"] = 217,["Money"] = 100000,["NextID"] = 25033,["Count"] = 1,["Type1"] = 2,["value1"] = 750,},
	[25016] = {["ID"] = 25016,["diamondType"] = 4,["Name"] = 188,["ClientIndex"] = 18,["Icon"] = 166,["Level"] = 1,["Quality"] = 2,["description"] = 218,["Money"] = 1250,["NextID"] = 25017,["Count"] = 1,["Type1"] = 3,["value1"] = 50,},
	[25017] = {["ID"] = 25017,["diamondType"] = 4,["Name"] = 189,["ClientIndex"] = 18,["Icon"] = 167,["Level"] = 2,["Quality"] = 3,["description"] = 219,["Money"] = 5000,["NextID"] = 25018,["Count"] = 1,["Type1"] = 3,["value1"] = 150,},
	[25018] = {["ID"] = 25018,["diamondType"] = 4,["Name"] = 190,["ClientIndex"] = 18,["Icon"] = 168,["Level"] = 3,["Quality"] = 3,["description"] = 220,["Money"] = 20000,["NextID"] = 25019,["Count"] = 1,["Type1"] = 3,["value1"] = 300,},
	[25019] = {["ID"] = 25019,["diamondType"] = 4,["Name"] = 191,["ClientIndex"] = 18,["Icon"] = 169,["Level"] = 4,["Quality"] = 4,["description"] = 221,["Money"] = 50000,["NextID"] = 25020,["Count"] = 1,["Type1"] = 3,["value1"] = 500,},
	[25020] = {["ID"] = 25020,["diamondType"] = 4,["Name"] = 192,["ClientIndex"] = 18,["Icon"] = 170,["Level"] = 5,["Quality"] = 4,["description"] = 222,["Money"] = 100000,["NextID"] = 25034,["Count"] = 1,["Type1"] = 3,["value1"] = 750,},
	[25021] = {["ID"] = 25021,["diamondType"] = 5,["Name"] = 193,["ClientIndex"] = 18,["Icon"] = 171,["Level"] = 1,["Quality"] = 2,["description"] = 223,["Money"] = 1250,["NextID"] = 25022,["Count"] = 1,["Type1"] = 6,["value1"] = 50,},
	[25022] = {["ID"] = 25022,["diamondType"] = 5,["Name"] = 194,["ClientIndex"] = 18,["Icon"] = 172,["Level"] = 2,["Quality"] = 3,["description"] = 224,["Money"] = 5000,["NextID"] = 25023,["Count"] = 1,["Type1"] = 6,["value1"] = 150,},
	[25023] = {["ID"] = 25023,["diamondType"] = 5,["Name"] = 195,["ClientIndex"] = 18,["Icon"] = 173,["Level"] = 3,["Quality"] = 3,["description"] = 225,["Money"] = 20000,["NextID"] = 25024,["Count"] = 1,["Type1"] = 6,["value1"] = 300,},
	[25024] = {["ID"] = 25024,["diamondType"] = 5,["Name"] = 196,["ClientIndex"] = 18,["Icon"] = 174,["Level"] = 4,["Quality"] = 4,["description"] = 226,["Money"] = 50000,["NextID"] = 25025,["Count"] = 1,["Type1"] = 6,["value1"] = 500,},
	[25025] = {["ID"] = 25025,["diamondType"] = 5,["Name"] = 197,["ClientIndex"] = 18,["Icon"] = 175,["Level"] = 5,["Quality"] = 4,["description"] = 227,["Money"] = 100000,["NextID"] = 25035,["Count"] = 1,["Type1"] = 6,["value1"] = 750,},
	[25026] = {["ID"] = 25026,["diamondType"] = 6,["Name"] = 198,["ClientIndex"] = 18,["Icon"] = 510,["Level"] = 1,["Quality"] = 2,["description"] = 228,["Money"] = 1250,["NextID"] = 25027,["Count"] = 1,["Type1"] = 7,["value1"] = 50,},
	[25027] = {["ID"] = 25027,["diamondType"] = 6,["Name"] = 199,["ClientIndex"] = 18,["Icon"] = 511,["Level"] = 2,["Quality"] = 3,["description"] = 229,["Money"] = 5000,["NextID"] = 25028,["Count"] = 1,["Type1"] = 7,["value1"] = 150,},
	[25028] = {["ID"] = 25028,["diamondType"] = 6,["Name"] = 200,["ClientIndex"] = 18,["Icon"] = 512,["Level"] = 3,["Quality"] = 3,["description"] = 230,["Money"] = 20000,["NextID"] = 25029,["Count"] = 1,["Type1"] = 7,["value1"] = 300,},
	[25029] = {["ID"] = 25029,["diamondType"] = 6,["Name"] = 201,["ClientIndex"] = 18,["Icon"] = 513,["Level"] = 4,["Quality"] = 4,["description"] = 231,["Money"] = 50000,["NextID"] = 25030,["Count"] = 1,["Type1"] = 7,["value1"] = 500,},
	[25030] = {["ID"] = 25030,["diamondType"] = 6,["Name"] = 202,["ClientIndex"] = 18,["Icon"] = 514,["Level"] = 5,["Quality"] = 4,["description"] = 232,["Money"] = 100000,["NextID"] = 25036,["Count"] = 1,["Type1"] = 7,["value1"] = 750,},
	[25031] = {["ID"] = 25031,["diamondType"] = 1,["Name"] = 1244,["ClientIndex"] = 18,["Icon"] = 155,["Level"] = 6,["Quality"] = 5,["description"] = 1250,["Money"] = 150000,["NextID"] = -1,["Count"] = 3,["Type1"] = 1,["value1"] = 900,["Type2"] = 4,["value2"] = 900,["Type3"] = 5,["value3"] = 900,},
	[25032] = {["ID"] = 25032,["diamondType"] = 2,["Name"] = 1245,["ClientIndex"] = 18,["Icon"] = 160,["Level"] = 6,["Quality"] = 5,["description"] = 1251,["Money"] = 150000,["NextID"] = -1,["Count"] = 1,["Type1"] = 0,["value1"] = 15000,},
	[25033] = {["ID"] = 25033,["diamondType"] = 3,["Name"] = 1246,["ClientIndex"] = 18,["Icon"] = 165,["Level"] = 6,["Quality"] = 5,["description"] = 1252,["Money"] = 150000,["NextID"] = -1,["Count"] = 1,["Type1"] = 2,["value1"] = 1500,},
	[25034] = {["ID"] = 25034,["diamondType"] = 4,["Name"] = 1247,["ClientIndex"] = 18,["Icon"] = 170,["Level"] = 6,["Quality"] = 5,["description"] = 1253,["Money"] = 150000,["NextID"] = -1,["Count"] = 1,["Type1"] = 3,["value1"] = 1500,},
	[25035] = {["ID"] = 25035,["diamondType"] = 5,["Name"] = 1248,["ClientIndex"] = 18,["Icon"] = 175,["Level"] = 6,["Quality"] = 5,["description"] = 1254,["Money"] = 150000,["NextID"] = -1,["Count"] = 1,["Type1"] = 6,["value1"] = 1500,},
	[25036] = {["ID"] = 25036,["diamondType"] = 6,["Name"] = 1249,["ClientIndex"] = 18,["Icon"] = 514,["Level"] = 6,["Quality"] = 5,["description"] = 1255,["Money"] = 150000,["NextID"] = -1,["Count"] = 1,["Type1"] = 7,["value1"] = 1500,},
}

function getDataById(key_id)
    local id_data = Diamond[key_id]

    return id_data
end

function getArrDataByField(fieldName, fieldValue)
    local arrData = {}
    for k, v in pairs(Diamond) do
        if v[fieldName] == fieldValue then
            arrData[#arrData+1] = v
        end
    end

    return arrData
end

function release()
    _G["DB_Diamond"] = nil
    package.loaded["DB_Diamond"] = nil
    package.loaded["DBSystem/DB_Diamond"] = nil
end
--ExcelVBA output tools end flag