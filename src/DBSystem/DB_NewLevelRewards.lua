-- Filename: DB_Skill.lua
-- Author: auto-created by XmlToScript tool.
-- Function: it`s auto-created by XmlToScript tool.
--ExcelVBA output tools start flag
module("DB_NewLevelRewards", package.seeall)
--{ID,所需等级,激活下一id,奖励物品,}

NewLevelRewards = {
	[1] = {["ID"] = 1,["level"] = 4,[" activate"] = 2,["rewards"] = {2,0,20000},},
	[2] = {["ID"] = 2,["level"] = 6,[" activate"] = 3,["rewards"] = {0,40007,50},},
	[3] = {["ID"] = 3,["level"] = 7,[" activate"] = 4,["rewards"] = {0,20011,10},},
	[4] = {["ID"] = 4,["level"] = 9,[" activate"] = 5,["rewards"] = {0,20278,10},},
	[5] = {["ID"] = 5,["level"] = 12,[" activate"] = 6,["rewards"] = {0,20282,5},},
	[6] = {["ID"] = 6,["level"] = 14,[" activate"] = 7,["rewards"] = {0,20282,5},},
	[7] = {["ID"] = 7,["level"] = 16,[" activate"] = 8,["rewards"] = {0,20401,6},},
	[8] = {["ID"] = 8,["level"] = 18,[" activate"] = 9,["rewards"] = {0,51001,1},},
	[9] = {["ID"] = 9,["level"] = 20,[" activate"] = 10,["rewards"] = {0,41001,5},},
	[10] = {["ID"] = 10,["level"] = 22,[" activate"] = 11,["rewards"] = {0,20278,5},},
	[11] = {["ID"] = 11,["level"] = 25,[" activate"] = 12,["rewards"] = {0,20278,5},},
	[12] = {["ID"] = 12,["level"] = 28,[" activate"] = 13,["rewards"] = {0,51003,1},},
	[13] = {["ID"] = 13,["level"] = 30,[" activate"] = 0,["rewards"] = {8,25002,2},},
}

function getDataById(key_id)
    local id_data = NewLevelRewards[key_id]

    return id_data
end

function getArrDataByField(fieldName, fieldValue)
    local arrData = {}
    for k, v in pairs(NewLevelRewards) do
        if v[fieldName] == fieldValue then
            arrData[#arrData+1] = v
        end
    end

    return arrData
end

function release()
    _G["DB_NewLevelRewards"] = nil
    package.loaded["DB_NewLevelRewards"] = nil
    package.loaded["DBSystem/DB_NewLevelRewards"] = nil
end
--ExcelVBA output tools end flag
