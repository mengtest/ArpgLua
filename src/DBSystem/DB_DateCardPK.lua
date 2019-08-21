-- Filename: DB_Skill.lua
-- Author: auto-created by XmlToScript tool.
-- Function: it`s auto-created by XmlToScript tool.
--ExcelVBA output tools start flag
module("DB_DateCardPK", package.seeall)
--{己方出牌,对方属性牌大-己方血量,对方属性牌大-己方怒气,对方属性牌大-对方血量,对方属性牌大-对方怒气,对方属性牌相等-己方血量,对方属性牌相等-己方怒气,对方属性牌相等-对方血量,对方属性牌相等-对方怒气,对方属性牌小-己方血量,对方属性牌小-己方怒气,对方属性牌小-对方血量,对方属性牌小-对方怒气,对方必杀-己方血量,对方必杀-己方怒气,对方必杀-对方血量,对方必杀-对方怒气,对方无视-己方血量,对方无视-己方怒气,对方无视-对方血量,对方无视-对方怒气,对方暴怒-己方血量,对方暴怒-己方怒气,对方暴怒-对方血量,对方暴怒-对方怒气,对方安抚-己方血量,对方暴怒-己方怒气,对方暴怒-对方血量,对方暴怒-对方怒气,}

DateCardPK = {
	[1] = {["SelfCard_Type"] = 1,["Bigger_SelfBlood"] = 0,["Bigger_SelfAnger"] = 0,["Bigger_EnemyBlood"] = -2,["Bigger_EnemyAnger"] = 2,["Equal_SelfBlood"] = 0,["Equal_SelfAnger"] = 0,["Equal_EnemyBlood"] = -2,["Equal_EnemyAnger"] = 2,["Smaller_SelfBlood"] = 0,["Smaller_SelfAnger"] = 0,["Smaller_EnemyBlood"] = -2,["Smaller_EnemyAnger"] = 2,["Kill_SelfBlood"] = 0,["Kill_SelfAnger"] = 2,["Kill_EnemyBlood"] = 0,["Kill_EnemyAnger"] = 2,["Ignore_SelfBlood"] = 0,["Ignore_SelfAnger"] = 4,["Ignore_EnemyBlood"] = 0,["Ignore_EnemyAnger"] = 0,["Angry_SelfBlood"] = 0,["Angry_SelfAnger"] = 0,["Angry_EnemyBlood"] = -2,["Angry_EnemyAnger"] = 10,["Appease_SelfBlood"] = 0,["Appease_SelfAnger"] = -10,["Appease_EnemyBlood"] = -2,["Appease_EnemyAnger"] = 2,},
	[2] = {["SelfCard_Type"] = 2,["Bigger_SelfBlood"] = 0,["Bigger_SelfAnger"] = 0,["Bigger_EnemyBlood"] = 0,["Bigger_EnemyAnger"] = 2,["Equal_SelfBlood"] = 0,["Equal_SelfAnger"] = 0,["Equal_EnemyBlood"] = 0,["Equal_EnemyAnger"] = 2,["Smaller_SelfBlood"] = 0,["Smaller_SelfAnger"] = 0,["Smaller_EnemyBlood"] = 0,["Smaller_EnemyAnger"] = 2,["Kill_SelfBlood"] = 0,["Kill_SelfAnger"] = 0,["Kill_EnemyBlood"] = 0,["Kill_EnemyAnger"] = 4,["Ignore_SelfBlood"] = 0,["Ignore_SelfAnger"] = 0,["Ignore_EnemyBlood"] = 0,["Ignore_EnemyAnger"] = 0,["Angry_SelfBlood"] = 0,["Angry_SelfAnger"] = 0,["Angry_EnemyBlood"] = 0,["Angry_EnemyAnger"] = 10,["Appease_SelfBlood"] = 0,["Appease_SelfAnger"] = -10,["Appease_EnemyBlood"] = 0,["Appease_EnemyAnger"] = 0,},
	[3] = {["SelfCard_Type"] = 3,["Bigger_SelfBlood"] = -1,["Bigger_SelfAnger"] = 10,["Bigger_EnemyBlood"] = 0,["Bigger_EnemyAnger"] = 0,["Equal_SelfBlood"] = -1,["Equal_SelfAnger"] = 10,["Equal_EnemyBlood"] = 0,["Equal_EnemyAnger"] = 0,["Smaller_SelfBlood"] = -1,["Smaller_SelfAnger"] = 10,["Smaller_EnemyBlood"] = 0,["Smaller_EnemyAnger"] = 0,["Kill_SelfBlood"] = -2,["Kill_SelfAnger"] = 10,["Kill_EnemyBlood"] = 0,["Kill_EnemyAnger"] = 0,["Ignore_SelfBlood"] = 0,["Ignore_SelfAnger"] = 10,["Ignore_EnemyBlood"] = 0,["Ignore_EnemyAnger"] = 0,["Angry_SelfBlood"] = 0,["Angry_SelfAnger"] = 10,["Angry_EnemyBlood"] = 0,["Angry_EnemyAnger"] = 10,["Appease_SelfBlood"] = 0,["Appease_SelfAnger"] = 0,["Appease_EnemyBlood"] = 0,["Appease_EnemyAnger"] = 0,},
	[4] = {["SelfCard_Type"] = 4,["Bigger_SelfBlood"] = -1,["Bigger_SelfAnger"] = 1,["Bigger_EnemyBlood"] = 0,["Bigger_EnemyAnger"] = -10,["Equal_SelfBlood"] = -1,["Equal_SelfAnger"] = 1,["Equal_EnemyBlood"] = 0,["Equal_EnemyAnger"] = -10,["Smaller_SelfBlood"] = -1,["Smaller_SelfAnger"] = 1,["Smaller_EnemyBlood"] = 0,["Smaller_EnemyAnger"] = -10,["Kill_SelfBlood"] = -2,["Kill_SelfAnger"] = 2,["Kill_EnemyBlood"] = 0,["Kill_EnemyAnger"] = -10,["Ignore_SelfBlood"] = 0,["Ignore_SelfAnger"] = 0,["Ignore_EnemyBlood"] = 0,["Ignore_EnemyAnger"] = -10,["Angry_SelfBlood"] = 0,["Angry_SelfAnger"] = 0,["Angry_EnemyBlood"] = 0,["Angry_EnemyAnger"] = 0,["Appease_SelfBlood"] = 0,["Appease_SelfAnger"] = -10,["Appease_EnemyBlood"] = 0,["Appease_EnemyAnger"] = -10,},
	[5] = {["SelfCard_Type"] = 5,["Bigger_SelfBlood"] = -1,["Bigger_SelfAnger"] = 1,["Bigger_EnemyBlood"] = 0,["Bigger_EnemyAnger"] = 0,["Equal_SelfBlood"] = 0,["Equal_SelfAnger"] = 1,["Equal_EnemyBlood"] = 0,["Equal_EnemyAnger"] = 1,["Smaller_SelfBlood"] = 0,["Smaller_SelfAnger"] = 0,["Smaller_EnemyBlood"] = -1,["Smaller_EnemyAnger"] = 1,["Kill_SelfBlood"] = -2,["Kill_SelfAnger"] = 2,["Kill_EnemyBlood"] = 0,["Kill_EnemyAnger"] = 0,["Ignore_SelfBlood"] = 0,["Ignore_SelfAnger"] = 2,["Ignore_EnemyBlood"] = 0,["Ignore_EnemyAnger"] = 0,["Angry_SelfBlood"] = 0,["Angry_SelfAnger"] = 0,["Angry_EnemyBlood"] = -1,["Angry_EnemyAnger"] = 11,["Appease_SelfBlood"] = 0,["Appease_SelfAnger"] = -10,["Appease_EnemyBlood"] = -1,["Appease_EnemyAnger"] = 1,},
}

function getDataById(key_id)
    local id_data = DateCardPK[key_id]

    return id_data
end

function getArrDataByField(fieldName, fieldValue)
    local arrData = {}
    for k, v in pairs(DateCardPK) do
        if v[fieldName] == fieldValue then
            arrData[#arrData+1] = v
        end
    end

    return arrData
end

function release()
    _G["DB_DateCardPK"] = nil
    package.loaded["DB_DateCardPK"] = nil
    package.loaded["DBSystem/DB_DateCardPK"] = nil
end
--ExcelVBA output tools end flag