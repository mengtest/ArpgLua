-- Filename: DB_Skill.lua
-- Author: auto-created by XmlToScript tool.
-- Function: it`s auto-created by XmlToScript tool.
--ExcelVBA output tools start flag
module("DB_VipBag", package.seeall)
--{level,originalPrice,discountPrice,previewId,rewardCount,物品1,物品2,物品3,物品4,}

VipBag = {
	[1] = {["level"] = 1,["originalPrice"] = 248,["discountPrice"] = 18,["previewId"] = 1,["rewardCount"] = 3,["Item1"] = "0,20503,3",["Item2"] = "0,20506,3",["Item3"] = "0,20043,1",},
	[2] = {["level"] = 2,["originalPrice"] = 480,["discountPrice"] = 48,["previewId"] = 2,["rewardCount"] = 3,["Item1"] = "0,20503,5",["Item2"] = "0,20506,5",["Item3"] = "0,20043,2",},
	[3] = {["level"] = 3,["originalPrice"] = 880,["discountPrice"] = 98,["previewId"] = 3,["rewardCount"] = 3,["Item1"] = "0,20502,5",["Item2"] = "0,20505,5",["Item3"] = "0,20043,3",},
	[4] = {["level"] = 4,["originalPrice"] = 1480,["discountPrice"] = 158,["previewId"] = 4,["rewardCount"] = 3,["Item1"] = "0,20502,8",["Item2"] = "0,20505,8",["Item3"] = "0,20043,4",},
	[5] = {["level"] = 5,["originalPrice"] = 2480,["discountPrice"] = 258,["previewId"] = 5,["rewardCount"] = 3,["Item1"] = "0,20501,8",["Item2"] = "0,20504,8",["Item3"] = "0,20280,10",},
	[6] = {["level"] = 6,["originalPrice"] = 6480,["discountPrice"] = 398,["previewId"] = 6,["rewardCount"] = 4,["Item1"] = "0,20501,12",["Item2"] = "0,20504,12",["Item3"] = "0,20280,10",["Item4"] = "0,21001,5",},
	[7] = {["level"] = 7,["originalPrice"] = 13480,["discountPrice"] = 598,["previewId"] = 7,["rewardCount"] = 4,["Item1"] = "0,20501,20",["Item2"] = "0,20504,20",["Item3"] = "0,20280,10",["Item4"] = "0,21001,10",},
	[8] = {["level"] = 8,["originalPrice"] = 23480,["discountPrice"] = 798,["previewId"] = 8,["rewardCount"] = 4,["Item1"] = "0,20501,30",["Item2"] = "0,20504,30",["Item3"] = "0,20283,10",["Item4"] = "0,21001,15",},
	[9] = {["level"] = 9,["originalPrice"] = 38480,["discountPrice"] = 998,["previewId"] = 9,["rewardCount"] = 4,["Item1"] = "8,25002,2",["Item2"] = "8,25007,2",["Item3"] = "0,20283,10",["Item4"] = "0,21005,5",},
	[10] = {["level"] = 10,["originalPrice"] = 68480,["discountPrice"] = 1298,["previewId"] = 10,["rewardCount"] = 4,["Item1"] = "8,25003,1",["Item2"] = "8,25002,1",["Item3"] = "0,20283,20",["Item4"] = "0,21005,5",},
	[11] = {["level"] = 11,["originalPrice"] = 98480,["discountPrice"] = 1888,["previewId"] = 11,["rewardCount"] = 4,["Item1"] = "8,25003,1",["Item2"] = "8,25013,1",["Item3"] = "0,20283,20",["Item4"] = "0,21005,10",},
	[12] = {["level"] = 12,["originalPrice"] = 128480,["discountPrice"] = 2888,["previewId"] = 12,["rewardCount"] = 4,["Item1"] = "8,25003,2",["Item2"] = "8,25018,2",["Item3"] = "0,20283,20",["Item4"] = "0,21005,10",},
	[13] = {["level"] = 13,["originalPrice"] = 158480,["discountPrice"] = 4298,["previewId"] = 13,["rewardCount"] = 4,["Item1"] = "8,25024,1",["Item2"] = "8,25023,1",["Item3"] = "0,20283,20",["Item4"] = "0,21005,15",},
	[14] = {["level"] = 14,["originalPrice"] = 188480,["discountPrice"] = 8888,["previewId"] = 14,["rewardCount"] = 4,["Item1"] = "8,25024,2",["Item2"] = "8,25028,1",["Item3"] = "0,20283,20",["Item4"] = "0,21009,5",},
	[15] = {["level"] = 15,["originalPrice"] = 218480,["discountPrice"] = 12888,["previewId"] = 15,["rewardCount"] = 4,["Item1"] = "8,25010,1",["Item2"] = "8,25008,1",["Item3"] = "0,20283,20",["Item4"] = "0,21009,10",},
	[16] = {["level"] = 16,["originalPrice"] = 248480,["discountPrice"] = 18888,["previewId"] = 16,["rewardCount"] = 4,["Item1"] = "8,25005,1",["Item2"] = "8,25004,1",["Item3"] = "0,20283,20",["Item4"] = "0,21009,15",},
}

function getDataById(key_id)
    local id_data = VipBag[key_id]

    return id_data
end

function getArrDataByField(fieldName, fieldValue)
    local arrData = {}
    for k, v in pairs(VipBag) do
        if v[fieldName] == fieldValue then
            arrData[#arrData+1] = v
        end
    end

    return arrData
end

function release()
    _G["DB_VipBag"] = nil
    package.loaded["DB_VipBag"] = nil
    package.loaded["DBSystem/DB_VipBag"] = nil
end
--ExcelVBA output tools end flag