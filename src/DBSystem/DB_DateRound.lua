-- Filename: DB_Skill.lua
-- Author: auto-created by XmlToScript tool.
-- Function: it`s auto-created by XmlToScript tool.
--ExcelVBA output tools start flag
module("DB_DateRound", package.seeall)
--{己方技能ID,对方技能-攒气-己方血量,对方技能-攒气-己方能量,对方技能-攒气-敌方血量,对方技能-攒气-敌方能量,对方技能-格挡-己方血量,对方技能-格挡-己方能量,对方技能-格挡-敌方血量,对方技能-格挡-敌方能量,对方技能-普攻-己方血量,对方技能-普攻-己方能量,对方技能-普攻-敌方血量,对方技能-普攻-敌方能量,}

DateRound = {
	[1] = {["SelfSkill_ID"] = 1,["Enemy_Skill1_SelfBlood"] = 0,["Enemy_Skill1_SelfEnergy"] = 1,["Enemy_Skill1_EnemyBlood"] = 0,["Enemy_Skill1_EnemyEnergy"] = 1,["Enemy_Skill2_SelfBlood"] = 0,["Enemy_Skill2_SelfEnergy"] = 1,["Enemy_Skill2_EnemyBlood"] = 0,["Enemy_Skill2_EnemyEnergy"] = 0,["Enemy_Skill3_SelfBlood"] = -1,["Enemy_Skill3_SelfEnergy"] = 0,["Enemy_Skill3_EnemyBlood"] = 0,["Enemy_Skill3_EnemyEnergy"] = 0,},
	[2] = {["SelfSkill_ID"] = 2,["Enemy_Skill1_SelfBlood"] = 0,["Enemy_Skill1_SelfEnergy"] = 0,["Enemy_Skill1_EnemyBlood"] = 0,["Enemy_Skill1_EnemyEnergy"] = 1,["Enemy_Skill2_SelfBlood"] = 0,["Enemy_Skill2_SelfEnergy"] = 0,["Enemy_Skill2_EnemyBlood"] = 0,["Enemy_Skill2_EnemyEnergy"] = 0,["Enemy_Skill3_SelfBlood"] = 0,["Enemy_Skill3_SelfEnergy"] = 1,["Enemy_Skill3_EnemyBlood"] = 0,["Enemy_Skill3_EnemyEnergy"] = 0,},
	[3] = {["SelfSkill_ID"] = 3,["Enemy_Skill1_SelfBlood"] = 0,["Enemy_Skill1_SelfEnergy"] = 0,["Enemy_Skill1_EnemyBlood"] = -1,["Enemy_Skill1_EnemyEnergy"] = 0,["Enemy_Skill2_SelfBlood"] = 0,["Enemy_Skill2_SelfEnergy"] = 0,["Enemy_Skill2_EnemyBlood"] = 0,["Enemy_Skill2_EnemyEnergy"] = 1,["Enemy_Skill3_SelfBlood"] = -1,["Enemy_Skill3_SelfEnergy"] = 0,["Enemy_Skill3_EnemyBlood"] = -1,["Enemy_Skill3_EnemyEnergy"] = 0,},
}

function getDataById(key_id)
    local id_data = DateRound[key_id]

    return id_data
end

function getArrDataByField(fieldName, fieldValue)
    local arrData = {}
    for k, v in pairs(DateRound) do
        if v[fieldName] == fieldValue then
            arrData[#arrData+1] = v
        end
    end

    return arrData
end

function release()
    _G["DB_DateRound"] = nil
    package.loaded["DB_DateRound"] = nil
    package.loaded["DBSystem/DB_DateRound"] = nil
end
--ExcelVBA output tools end flag