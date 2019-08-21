-- Filename: DB_Skill.lua
-- Author: auto-created by XmlToScript tool.
-- Function: it`s auto-created by XmlToScript tool.
--ExcelVBA output tools start flag
module("DB_LevelRewards", package.seeall)
--{id,等级,奖励1,奖励2,奖励3,奖励4,}

LevelRewards = {
	[1] = {["ID"] = 1,["level"] = 10,["Reward1"] = {3,0,100},["Reward2"] = {0,40001,3},["Reward3"] = {0,40002,3},["Reward4"] = {0,20278,10},},
	[2] = {["ID"] = 2,["level"] = 20,["Reward1"] = {3,0,200},["Reward2"] = {0,21003,5},["Reward3"] = {0,21001,60},["Reward4"] = {0,52002,1},},
	[3] = {["ID"] = 3,["level"] = 25,["Reward1"] = {3,0,250},["Reward2"] = {0,21002,5},["Reward3"] = {0,21001,60},["Reward4"] = {0,20278,10},},
	[4] = {["ID"] = 4,["level"] = 30,["Reward1"] = {3,0,300},["Reward2"] = {0,21004,5},["Reward3"] = {0,21001,60},["Reward4"] = {0,20278,10},},
	[5] = {["ID"] = 5,["level"] = 35,["Reward1"] = {3,0,350},["Reward2"] = {0,20401,5},["Reward3"] = {0,20513,2},["Reward4"] = {0,51101,1},},
	[6] = {["ID"] = 6,["level"] = 40,["Reward1"] = {3,0,400},["Reward2"] = {0,21007,5},["Reward3"] = {0,21005,30},["Reward4"] = {0,52002,1},},
	[7] = {["ID"] = 7,["level"] = 45,["Reward1"] = {3,0,450},["Reward2"] = {0,21006,5},["Reward3"] = {0,21005,40},["Reward4"] = {0,20278,20},},
	[8] = {["ID"] = 8,["level"] = 50,["Reward1"] = {3,0,500},["Reward2"] = {0,21008,5},["Reward3"] = {0,21005,50},["Reward4"] = {0,51003,1},},
}

function getDataById(key_id)
    local id_data = LevelRewards[key_id]

    return id_data
end

function getArrDataByField(fieldName, fieldValue)
    local arrData = {}
    for k, v in pairs(LevelRewards) do
        if v[fieldName] == fieldValue then
            arrData[#arrData+1] = v
        end
    end

    return arrData
end

function release()
    _G["DB_LevelRewards"] = nil
    package.loaded["DB_LevelRewards"] = nil
    package.loaded["DBSystem/DB_LevelRewards"] = nil
end
--ExcelVBA output tools end flag