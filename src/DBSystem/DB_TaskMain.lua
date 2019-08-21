-- Filename: DB_Skill.lua
-- Author: auto-created by XmlToScript tool.
-- Function: it`s auto-created by XmlToScript tool.
--ExcelVBA output tools start flag
module("DB_TaskMain", package.seeall)
--{序号,任务难度（1、简单；2、普通；3、困难）,任务名称,任务描述,任务图标,相对生效时间（分）,开启时间,结束时间,领取NPCID,玩家对话1,目标对话1,玩家对话2,目标对话2,玩家对话3,目标对话3,完成NPCID,玩家对话1,目标对话1,玩家对话2,目标对话2,玩家对话3,目标对话3,最低接取等级,最高接取等级,前置任务,后续任务,经验奖励,奖励1,奖励2,任务跳转类型,任务跳转参数1,任务跳转参数2,任务条件类型, 参数1, 参数2,}

TaskMain = {
	[1] = {["ID"] = 1,["Difficulty"] = 3,["IconID"] = 444,["LastTime"] = -1,["StartTime"] = -1,["EndTime"] = -1,["ACC_NPCID"] = -1,["ACC_Talk1"] = -1,["ACC_Talk2"] = -1,["ACC_Talk3"] = -1,["ACC_Talk4"] = -1,["ACC_Talk5"] = -1,["ACC_Talk6"] = -1,["FIN_NPCID"] = -1,["FIN_Talk1"] = -1,["FIN_Talk2"] = -1,["FIN_Talk3"] = -1,["FIN_Talk4"] = -1,["FIN_Talk5"] = -1,["FIN_Talk6"] = -1,["LowLevel"] = 1,["HighLevel"] = 999,["PreTask"] = -1,["AfterTask"] = -1,["EXP"] = "4,0,20",["Reward1"] = "0,20005,2",["Reward2"] = "2,0,5000",["TaskJump"] = 2,["TaskJumpPara1"] = 1,["TaskJumpPara2"] = -1,["TaskCondition"] = 40,["TaskConditionPara1"] = 2,},
}

function getDataById(key_id)
    local id_data = TaskMain[key_id]

    return id_data
end

function getArrDataByField(fieldName, fieldValue)
    local arrData = {}
    for k, v in pairs(TaskMain) do
        if v[fieldName] == fieldValue then
            arrData[#arrData+1] = v
        end
    end

    return arrData
end

function release()
    _G["DB_TaskMain"] = nil
    package.loaded["DB_TaskMain"] = nil
    package.loaded["DBSystem/DB_TaskMain"] = nil
end
--ExcelVBA output tools end flag