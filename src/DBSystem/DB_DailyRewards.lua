-- Filename: DB_Skill.lua
-- Author: auto-created by XmlToScript tool.
-- Function: it`s auto-created by XmlToScript tool.
--ExcelVBA output tools start flag
module("DB_DailyRewards", package.seeall)
--{id,天数,奖励1,奖励2,奖励3,奖励4,}

DailyRewards = {
	[1] = {["ID"] = 1,["Days"] = 1,["Reward1"] = "3,0,200",["Reward2"] = "0,20011,10",["Reward3"] = "2,0,20000",["Reward4"] = "0,20280,10",},
	[2] = {["ID"] = 2,["Days"] = 2,["Reward1"] = "3,0,250",["Reward2"] = "0,20011,20",["Reward3"] = "2,0,50000",["Reward4"] = "0,51002,1",},
	[3] = {["ID"] = 3,["Days"] = 3,["Reward1"] = "3,0,300",["Reward2"] = "0,20011,30",["Reward3"] = "2,0,100000",["Reward4"] = "0,20283,10",},
	[4] = {["ID"] = 4,["Days"] = 4,["Reward1"] = "3,0,350",["Reward2"] = "0,20012,10",["Reward3"] = "2,0,150000",["Reward4"] = "0,52004,1",},
	[5] = {["ID"] = 5,["Days"] = 5,["Reward1"] = "3,0,400",["Reward2"] = "0,20012,20",["Reward3"] = "2,0,200000",["Reward4"] = "0,20280,20",},
	[6] = {["ID"] = 6,["Days"] = 6,["Reward1"] = "3,0,450",["Reward2"] = "0,20012,30",["Reward3"] = "2,0,250000",["Reward4"] = "0,52004,1",},
	[7] = {["ID"] = 7,["Days"] = 7,["Reward1"] = "3,0,500",["Reward2"] = "0,20014,5",["Reward3"] = "2,0,300000",["Reward4"] = "0,51001,1",},
}

function getDataById(key_id)
    local id_data = DailyRewards[key_id]

    return id_data
end

function getArrDataByField(fieldName, fieldValue)
    local arrData = {}
    for k, v in pairs(DailyRewards) do
        if v[fieldName] == fieldValue then
            arrData[#arrData+1] = v
        end
    end

    return arrData
end

function release()
    _G["DB_DailyRewards"] = nil
    package.loaded["DB_DailyRewards"] = nil
    package.loaded["DBSystem/DB_DailyRewards"] = nil
end
--ExcelVBA output tools end flag