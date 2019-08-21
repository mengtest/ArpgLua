-- Filename: DB_Skill.lua
-- Author: auto-created by XmlToScript tool.
-- Function: it`s auto-created by XmlToScript tool.
--ExcelVBA output tools start flag
module("DB_MapRewardsNormal", package.seeall)
--{序号,副本章节,难度,4星,4星,4星,4星,12星,12星,12星,12星,}

MapRewardsNormal = {
	[1] = {["ID"] = 1,["MapR_Chapter"] = 1,["MapR_Difficulty"] = 2,["MapR_4stars1"] = 2,0,8000,["MapR_4stars2"] = 0,20011,5,["MapR_4stars3"] = 0,40007,30,["MapR_4stars4"] = 0,20502,5,["MapR_12stars1"] = 2,0,12000,["MapR_12stars2"] = 0,40007,60,["MapR_12stars3"] = 0,20501,5,["MapR_12stars4"] = 3,0,90,},
	[2] = {["ID"] = 2,["MapR_Chapter"] = 2,["MapR_Difficulty"] = 2,["MapR_4stars1"] = 2,0,12000,["MapR_4stars2"] = 0,20011,10,["MapR_4stars3"] = 0,40007,35,["MapR_4stars4"] = 0,20502,5,["MapR_12stars1"] = 2,0,18000,["MapR_12stars2"] = 0,40007,70,["MapR_12stars3"] = 0,20501,5,["MapR_12stars4"] = 3,0,90,},
	[3] = {["ID"] = 3,["MapR_Chapter"] = 3,["MapR_Difficulty"] = 2,["MapR_4stars1"] = 2,0,16000,["MapR_4stars2"] = 0,20011,15,["MapR_4stars3"] = 0,40007,40,["MapR_4stars4"] = 0,20502,5,["MapR_12stars1"] = 2,0,24000,["MapR_12stars2"] = 0,40007,80,["MapR_12stars3"] = 0,20501,5,["MapR_12stars4"] = 3,0,90,},
	[4] = {["ID"] = 4,["MapR_Chapter"] = 4,["MapR_Difficulty"] = 2,["MapR_4stars1"] = 2,0,20000,["MapR_4stars2"] = 0,20011,20,["MapR_4stars3"] = 0,40007,45,["MapR_4stars4"] = 0,20502,5,["MapR_12stars1"] = 2,0,30000,["MapR_12stars2"] = 0,40007,90,["MapR_12stars3"] = 0,20501,5,["MapR_12stars4"] = 3,0,90,},
	[5] = {["ID"] = 5,["MapR_Chapter"] = 5,["MapR_Difficulty"] = 2,["MapR_4stars1"] = 2,0,24000,["MapR_4stars2"] = 0,20012,5,["MapR_4stars3"] = 0,40007,50,["MapR_4stars4"] = 0,20502,5,["MapR_12stars1"] = 2,0,36000,["MapR_12stars2"] = 0,40007,100,["MapR_12stars3"] = 0,20501,5,["MapR_12stars4"] = 3,0,90,},
	[6] = {["ID"] = 6,["MapR_Chapter"] = 6,["MapR_Difficulty"] = 2,["MapR_4stars1"] = 2,0,28000,["MapR_4stars2"] = 0,20012,6,["MapR_4stars3"] = 0,40007,55,["MapR_4stars4"] = 0,20502,5,["MapR_12stars1"] = 2,0,42000,["MapR_12stars2"] = 0,40007,110,["MapR_12stars3"] = 0,20501,5,["MapR_12stars4"] = 3,0,90,},
	[7] = {["ID"] = 7,["MapR_Chapter"] = 7,["MapR_Difficulty"] = 2,["MapR_4stars1"] = 2,0,32000,["MapR_4stars2"] = 0,20012,7,["MapR_4stars3"] = 0,40007,60,["MapR_4stars4"] = 0,20502,5,["MapR_12stars1"] = 2,0,48000,["MapR_12stars2"] = 0,40007,120,["MapR_12stars3"] = 0,20501,5,["MapR_12stars4"] = 3,0,90,},
	[8] = {["ID"] = 8,["MapR_Chapter"] = 8,["MapR_Difficulty"] = 2,["MapR_4stars1"] = 2,0,36000,["MapR_4stars2"] = 0,20013,4,["MapR_4stars3"] = 0,40007,65,["MapR_4stars4"] = 0,20502,5,["MapR_12stars1"] = 2,0,54000,["MapR_12stars2"] = 0,40007,130,["MapR_12stars3"] = 0,20501,5,["MapR_12stars4"] = 3,0,90,},
	[9] = {["ID"] = 9,["MapR_Chapter"] = 9,["MapR_Difficulty"] = 2,["MapR_4stars1"] = 2,0,40000,["MapR_4stars2"] = 0,20013,5,["MapR_4stars3"] = 0,40007,70,["MapR_4stars4"] = 0,20502,5,["MapR_12stars1"] = 2,0,60000,["MapR_12stars2"] = 0,40007,140,["MapR_12stars3"] = 0,20501,5,["MapR_12stars4"] = 3,0,90,},
	[10] = {["ID"] = 10,["MapR_Chapter"] = 10,["MapR_Difficulty"] = 2,["MapR_4stars1"] = 2,0,44000,["MapR_4stars2"] = 0,20013,6,["MapR_4stars3"] = 0,40007,75,["MapR_4stars4"] = 0,20502,5,["MapR_12stars1"] = 2,0,66000,["MapR_12stars2"] = 0,40007,150,["MapR_12stars3"] = 0,20501,5,["MapR_12stars4"] = 3,0,90,},
}

function getDataById(key_id)
    local id_data = MapRewardsNormal[key_id]

    return id_data
end

function getArrDataByField(fieldName, fieldValue)
    local arrData = {}
    for k, v in pairs(MapRewardsNormal) do
        if v[fieldName] == fieldValue then
            arrData[#arrData+1] = v
        end
    end

    return arrData
end

function release()
    _G["DB_MapRewardsNormal"] = nil
    package.loaded["DB_MapRewardsNormal"] = nil
    package.loaded["DBSystem/DB_MapRewardsNormal"] = nil
end
--ExcelVBA output tools end flag