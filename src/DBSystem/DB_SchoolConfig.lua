-- Filename: DB_Skill.lua
-- Author: auto-created by XmlToScript tool.
-- Function: it`s auto-created by XmlToScript tool.
--ExcelVBA output tools start flag
module("DB_SchoolConfig", package.seeall)
--{序号,名字显示,图标,}

SchoolConfig = {
	[1] = {["ID"] = 1,["Name"] = 356,["Icon"] = 84,},
	[2] = {["ID"] = 2,["Name"] = 357,["Icon"] = 84,},
	[3] = {["ID"] = 3,["Name"] = 358,["Icon"] = 84,},
	[4] = {["ID"] = 4,["Name"] = 359,["Icon"] = 84,},
	[5] = {["ID"] = 5,["Name"] = 360,["Icon"] = 84,},
	[6] = {["ID"] = 6,["Name"] = 361,["Icon"] = 84,},
}

function getDataById(key_id)
    local id_data = SchoolConfig[key_id]

    return id_data
end

function getArrDataByField(fieldName, fieldValue)
    local arrData = {}
    for k, v in pairs(SchoolConfig) do
        if v[fieldName] == fieldValue then
            arrData[#arrData+1] = v
        end
    end

    return arrData
end

function release()
    _G["DB_SchoolConfig"] = nil
    package.loaded["DB_SchoolConfig"] = nil
    package.loaded["DBSystem/DB_SchoolConfig"] = nil
end
--ExcelVBA output tools end flag