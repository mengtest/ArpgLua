-- Filename: DB_Skill.lua
-- Author: auto-created by XmlToScript tool.
-- Function: it`s auto-created by XmlToScript tool.
--ExcelVBA output tools start flag
module("DB_PlayerEXP", package.seeall)
--{功能ID,开启级别,对应图标名,对应父层,对应按钮,功能名称ID,锁定方式,是否需要开启提示,}

PlayerEXP = {
	[1] = {["ID"] = 1,["Player_Level"] = 1,["Player_Icon"] = "home_icon_playertitle.png",["Function_Father"] = "Image_PlayerTitle",["Function_Button"] = "Button_PlayerTitle",["Function_Name"] = 5308,["Lock"] = 2,["OpenNotice"] = 0,},
	[2] = {["ID"] = 2,["Player_Level"] = 4,["Player_Icon"] = "home_icon_skill.png",["Function_Father"] = "Image_Skill",["Function_Button"] = "Button_Skill",["Function_Name"] = 5318,["Lock"] = 2,["OpenNotice"] = 0,},
	[3] = {["ID"] = 3,["Player_Level"] = 6,["Player_Icon"] = "home_icon_equip.png",["Function_Father"] = "Image_Equip",["Function_Button"] = "Button_Equip",["Function_Name"] = 5303,["Lock"] = 2,["OpenNotice"] = 0,},
	[4] = {["ID"] = 4,["Player_Level"] = 7,["Player_Icon"] = "home_icon_lottery.png",["Function_Father"] = "Image_Get",["Function_Button"] = "Button_Get",["Function_Name"] = 5314,["Lock"] = 2,["OpenNotice"] = 0,},
	[5] = {["ID"] = 5,["Player_Level"] = 7,["Player_Icon"] = "home_icon_ranking.png",["Function_Father"] = "Image_RankingList",["Function_Button"] = "Button_RankingList",["Function_Name"] = 5319,["Lock"] = 2,["OpenNotice"] = 0,},
	[6] = {["ID"] = 6,["Player_Level"] = 8,["Player_Icon"] = "home_icon_task.png",["Function_Father"] = "Image_Task",["Function_Button"] = "Button_Task",["Function_Name"] = 5313,["Lock"] = 2,["OpenNotice"] = 0,},
	[7] = {["ID"] = 7,["Player_Level"] = 10,["Player_Icon"] = "home_icon_arena.png",["Function_Father"] = "Image_Arena",["Function_Button"] = "Button_Arena",["Function_Name"] = 5306,["Lock"] = 2,["OpenNotice"] = 0,},
	[8] = {["ID"] = 8,["Player_Level"] = 15,["Player_Icon"] = "home_icon_guild.png",["Function_Father"] = "Image_Banghui",["Function_Button"] = "Button_Banghui",["Function_Name"] = 5304,["Lock"] = 2,["OpenNotice"] = 0,},
	[9] = {["ID"] = 9,["Player_Level"] = 17,["Player_Icon"] = "home_icon_wealthmountain.png",["Function_Father"] = "Image_WealthMountain",["Function_Button"] = "Button_WealthMountain",["Function_Name"] = 5310,["Lock"] = 2,["OpenNotice"] = 0,},
	[10] = {["ID"] = 10,["Player_Level"] = 20,["Player_Icon"] = "home_icon_daydayup.png",["Function_Father"] = "Image_DayDayUp",["Function_Button"] = "Button_DayDayUp",["Function_Name"] = 5317,["Lock"] = 2,["OpenNotice"] = 0,},
	[11] = {["ID"] = 11,["Player_Level"] = 21,["Player_Icon"] = "home_icon_mountsguns.png",["Function_Father"] = "Image_MountsGuns",["Function_Button"] = "Button_MountsGuns",["Function_Name"] = 5320,["Lock"] = 2,["OpenNotice"] = 0,},
	[12] = {["ID"] = 12,["Player_Level"] = 22,["Player_Icon"] = "home_icon_worldboss.png",["Function_Father"] = "Image_WorldBoss",["Function_Button"] = "Button_WorldBoss",["Function_Name"] = 5312,["Lock"] = 2,["OpenNotice"] = 0,},
	[13] = {["ID"] = 13,["Player_Level"] = 26,["Player_Icon"] = "home_icon_tower.png",["Function_Father"] = "Image_Tower",["Function_Button"] = "Button_Tower",["Function_Name"] = 5309,["Lock"] = 2,["OpenNotice"] = 0,},
	[14] = {["ID"] = 14,["Player_Level"] = 30,["Player_Icon"] = "home_icon_tianti.png",["Function_Father"] = "Image_Tianti",["Function_Button"] = "Button_Tianti",["Function_Name"] = 5307,["Lock"] = 2,["OpenNotice"] = 0,},
	[15] = {["ID"] = 15,["Player_Level"] = 33,["Player_Icon"] = "home_icon_badge.png",["Function_Father"] = "Image_Badge",["Function_Button"] = "Button_Badge",["Function_Name"] = 5321,["Lock"] = 2,["OpenNotice"] = 0,},
	[16] = {["ID"] = 16,["Player_Level"] = 36,["Player_Icon"] = "home_icon_blackmarket.png",["Function_Father"] = "Image_BlackMarket",["Function_Button"] = "Button_BlackMarket",["Function_Name"] = 5311,["Lock"] = 2,["OpenNotice"] = 0,},
	[17] = {["ID"] = 17,["Player_Level"] = 39,["Player_Icon"] = "home_icon_technology.png",["Function_Father"] = "Image_Technology",["Function_Button"] = "Button_Technology",["Function_Name"] = 5305,["Lock"] = 2,["OpenNotice"] = 0,},
}

function getDataById(key_id)
    local id_data = PlayerEXP[key_id]

    return id_data
end

function getArrDataByField(fieldName, fieldValue)
    local arrData = {}
    for k, v in pairs(PlayerEXP) do
        if v[fieldName] == fieldValue then
            arrData[#arrData+1] = v
        end
    end

    return arrData
end

function release()
    _G["DB_PlayerEXP"] = nil
    package.loaded["DB_PlayerEXP"] = nil
    package.loaded["DBSystem/DB_PlayerEXP"] = nil
end
--ExcelVBA output tools end flag