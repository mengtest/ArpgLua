-- Filename: DB_Skill.lua
-- Author: auto-created by XmlToScript tool.
-- Function: it`s auto-created by XmlToScript tool.
--ExcelVBA output tools start flag
module("DB_AfterClass", package.seeall)
--{功能ID,功能,难度,推荐战力,}

AfterClass = {
	[1] = {["ID"] = 1,["AfterClass_Function"] = 1,["AfterClass_Difficulty"] = {10,30,50,65,80},["AfterClass_Power"] = {10000,60000,120000,240000,360000},},
	[2] = {["ID"] = 2,["AfterClass_Function"] = 2,["AfterClass_Difficulty"] = {10,30,50,65,80},["AfterClass_Power"] = {10000,60000,120000,240000,360000},},
	[3] = {["ID"] = 3,["AfterClass_Function"] = 3,["AfterClass_Difficulty"] = {10,30,50,65,80},["AfterClass_Power"] = {10000,60000,120000,240000,360000},},
}

function getDataById(key_id)
    local id_data = AfterClass[key_id]

    return id_data
end

function getArrDataByField(fieldName, fieldValue)
    local arrData = {}
    for k, v in pairs(AfterClass) do
        if v[fieldName] == fieldValue then
            arrData[#arrData+1] = v
        end
    end

    return arrData
end

function release()
    _G["DB_AfterClass"] = nil
    package.loaded["DB_AfterClass"] = nil
    package.loaded["DBSystem/DB_AfterClass"] = nil
end
--ExcelVBA output tools end flag