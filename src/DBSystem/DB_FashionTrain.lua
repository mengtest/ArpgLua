-- Filename: DB_Skill.lua
-- Author: auto-created by XmlToScript tool.
-- Function: it`s auto-created by XmlToScript tool.
--ExcelVBA output tools start flag
module("DB_FashionTrain", package.seeall)
--{技能id,技能名称,技能图标,技能描述,所需材料id,效果,初始数值,每10级数值,}

FashionTrain = {
	[1] = {1,5951,233,6000,51501,1,60,300,},
	[2] = {2,5952,233,6001,51501,2,3,15,},
	[3] = {3,5953,233,6002,51501,3,3,15,},
	[4] = {4,5954,233,6003,51502,4,3,15,},
	[5] = {5,5955,233,6004,51502,5,3,15,},
	[6] = {6,5956,233,6005,51502,6,3,15,},
	[7] = {7,5957,233,6006,51503,7,3,15,},
	[8] = {8,5958,233,6007,51503,8,3,15,},
	[10] = {10,5960,233,6008,51501,17,1,10,},
	[11] = {11,5961,233,6009,51503,18,1,10,},
	[12] = {12,5962,233,6010,51503,19,1,10,},
	[13] = {13,5963,233,6011,51503,20,2,15,},
}
local mt = {}
local t_DB = {
["ID"] = 1,["name"] = 2,["IconID"] = 3,["textid"] = 4,["consumeid"] = 5,["Type"] = 6,["value"] = 7,["valueadd"] = 8,
}
mt.__index =    function (table, key)
                return table[t_DB[key]]
            end

function getDataById(key_id)
    local id_data = FashionTrain[key_id]

    if id_data == nil then
        return nil
    end
    if getmetatable(id_data) ~= nil then
        return id_data
    end
    setmetatable(id_data, mt)
    return id_data
end

function getArrDataByField(fieldName, fieldValue)
    local arrData = {}
    for k, v in pairs(FashionTrain) do
        if getmetatable(v) == nil then
            setmetatable(v, mt)
        end
        if v[fieldName] == fieldValue then
            arrData[#arrData+1] = v
        end
    end

    return arrData
end

function release()
    _G["DB_FashionTrain"] = nil
    package.loaded["DB_FashionTrain"] = nil
    package.loaded["DBSystem/DB_FashionTrain"] = nil
end
--ExcelVBA output tools end flag