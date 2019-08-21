-- Filename: DB_Skill.lua
-- Author: auto-created by XmlToScript tool.
-- Function: it`s auto-created by XmlToScript tool.
--ExcelVBA output tools start flag
module("DB_Rule", package.seeall)
--{序号,活动名称,活动规则,}

Rule = {
	[1] = {["ID"] = 1,["Name"] = 1,["Rule"] = 1,},
	[2] = {["ID"] = 2,["Name"] = 1,["Rule"] = 1,},
	[3] = {["ID"] = 3,["Name"] = 1,["Rule"] = 1,},
	[4] = {["ID"] = 4,["Name"] = 1,["Rule"] = 1,},
}

function getDataById(key_id)
    local id_data = Rule[key_id]

    return id_data
end

function getArrDataByField(fieldName, fieldValue)
    local arrData = {}
    for k, v in pairs(Rule) do
        if v[fieldName] == fieldValue then
            arrData[#arrData+1] = v
        end
    end

    return arrData
end

function release()
    _G["DB_Rule"] = nil
    package.loaded["DB_Rule"] = nil
    package.loaded["DBSystem/DB_Rule"] = nil
end
--ExcelVBA output tools end flag