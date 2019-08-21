-- Filename: DB_Skill.lua
-- Author: auto-created by XmlToScript tool.
-- Function: it`s auto-created by XmlToScript tool.
--ExcelVBA output tools start flag
module("DB_TaskRewards", package.seeall)
--{序号,奖励内容1,奖励内容2,奖励内容3,}

TaskRewards = {
	[1] = {["ID"] = 1,["Activity"] = 20,["Reward1"] = "2,0,50",["Reward2"] = "0,20011,10",["Reward3"] = "0,40007,50",},
	[2] = {["ID"] = 2,["Activity"] = 50,["Reward1"] = "2,0,100",["Reward2"] = "0,20012,3",["Reward3"] = "0,21001,10",},
	[3] = {["ID"] = 3,["Activity"] = 80,["Reward1"] = "3,0,20",["Reward2"] = "0,20013,2",["Reward3"] = "0,21005,6",},
	[4] = {["ID"] = 4,["Activity"] = 110,["Reward1"] = "3,0,50",["Reward2"] = "0,20511,1",["Reward3"] = "0,21009,3",},
}

function getDataById(key_id)
    local id_data = TaskRewards[key_id]

    return id_data
end

function getArrDataByField(fieldName, fieldValue)
    local arrData = {}
    for k, v in pairs(TaskRewards) do
        if v[fieldName] == fieldValue then
            arrData[#arrData+1] = v
        end
    end

    return arrData
end

function release()
    _G["DB_TaskRewards"] = nil
    package.loaded["DB_TaskRewards"] = nil
    package.loaded["DBSystem/DB_TaskRewards"] = nil
end
--ExcelVBA output tools end flag