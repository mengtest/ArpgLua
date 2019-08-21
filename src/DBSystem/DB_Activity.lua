-- Filename: DB_Skill.lua
-- Author: auto-created by XmlToScript tool.
-- Function: it`s auto-created by XmlToScript tool.
--ExcelVBA output tools start flag
module("DB_Activity", package.seeall)
--{属性类型,名称,描述,图片ID,图标ID,开启时间,结束时间,最小级别,活动次数,显示奖励1,显示奖励2,显示奖励3,}

Activity = {
	[1] = {["ID"] = 1,["name"] = 583,["description"] = 586,["picture"] = 432,["Icon"] = 435,["starttime"] = -1,["endtime"] = -1,["minlevel"] = 1,["times"] = 2,["reward1"] = "0,20015,1",["reward2"] = "0,20015,1",["reward3"] = "0,20015,1",},
	[2] = {["ID"] = 2,["name"] = 584,["description"] = 587,["picture"] = 430,["Icon"] = 433,["starttime"] = -1,["endtime"] = -1,["minlevel"] = 1,["times"] = 2,["reward1"] = "0,20015,1",["reward2"] = "0,20015,1",["reward3"] = "0,20015,1",},
	[3] = {["ID"] = 3,["name"] = 44,["description"] = 45,["picture"] = 430,["Icon"] = 433,["starttime"] = -1,["endtime"] = -1,["minlevel"] = 1,["times"] = 2,["reward1"] = "0,20015,1",["reward2"] = "0,20015,1",["reward3"] = "0,20015,1",},
}

function getDataById(key_id)
    local id_data = Activity[key_id]

    return id_data
end

function getArrDataByField(fieldName, fieldValue)
    local arrData = {}
    for k, v in pairs(Activity) do
        if v[fieldName] == fieldValue then
            arrData[#arrData+1] = v
        end
    end

    return arrData
end

function release()
    _G["DB_Activity"] = nil
    package.loaded["DB_Activity"] = nil
    package.loaded["DBSystem/DB_Activity"] = nil
end
--ExcelVBA output tools end flag
