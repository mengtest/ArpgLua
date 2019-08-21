-- Filename: DB_Skill.lua
-- Author: auto-created by XmlToScript tool.
-- Function: it`s auto-created by XmlToScript tool.
--ExcelVBA output tools start flag
module("DB_MessageBox_Consume", package.seeall)
--{ID,显示窗口层,数据数量,数据1控件名,数据2控件名,数据3控件名,数据4控件名,}

MessageBox_Consume = {
	[1] = {["ID"] = 1,["WindowName"] = "Panel_Tili",["DataNum"] = 2,["Data1"] = "Label_TiliNum",["Data1"] = "Label_LastTimes",},
	[2] = {["ID"] = 2,["WindowName"] = "Panel_VIPpackage",["DataNum"] = 1,["Data1"] = "Label_VIP",},
	[3] = {["ID"] = 3,["WindowName"] = "Panel_PVETimes",["DataNum"] = 1,["Data1"] = "Label_LastTimes",},
	[4] = {["ID"] = 4,["WindowName"] = "Panel_ArenaTimes",["DataNum"] = 2,["Data1"] = "Label_Times",["Data1"] = "Label_LastTimes",},
	[5] = {["ID"] = 5,["WindowName"] = "Panel_ShopRefresh",["DataNum"] = 1,["Data1"] = "Label_LastTimes",},
	[6] = {["ID"] = 6,["WindowName"] = "Panel_Shopping",["DataNum"] = 3,["Data1"] = "Label_Num",["Data1"] = "Label_Name",["Data1"] = "Panel_Item",},
	[7] = {["ID"] = 7,["WindowName"] = "Panel_BlackMaket",["DataNum"] = 0,},
	[8] = {["ID"] = 8,["WindowName"] = "Panel_CreatGuild",["DataNum"] = 0,},
}

function getDataById(key_id)
    local id_data = MessageBox_Consume[key_id]

    return id_data
end

function getArrDataByField(fieldName, fieldValue)
    local arrData = {}
    for k, v in pairs(MessageBox_Consume) do
        if v[fieldName] == fieldValue then
            arrData[#arrData+1] = v
        end
    end

    return arrData
end

function release()
    _G["DB_MessageBox_Consume"] = nil
    package.loaded["DB_MessageBox_Consume"] = nil
    package.loaded["DBSystem/DB_MessageBox_Consume"] = nil
end
--ExcelVBA output tools end flag
