-- Filename: DB_Skill.lua
-- Author: auto-created by XmlToScript tool.
-- Function: it`s auto-created by XmlToScript tool.
--ExcelVBA output tools start flag
module("DB_CommandText", package.seeall)
--{英文文本,中文文本,}

CommandText = {
	["TEST"] = "测试",
	["REGISTER"] = "玩家注册",
	["GM_ORDER"] = "GM指令",
	["SERVER_INIT"] = "服务器启动初始化",
	["USE_ITEM"] = "使用物品",
	["SELL_ITEM"] = "出售物品",
	["SELL_EQUIP"] = "出售装备",
	["FAST_REGISTER"] = "快速注册",
	["GUEST_LOGIN"] = "游客登录查询Account表是否存在",
	["ROLE_LIST"] = "查询玩家角色列表",
	["PLAYER_REG_SAVE"] = "玩家注册",
	["PLAYER_REG_UPDATE"] = "玩家注册更新",
	["ID_GENERATOR"] = "IDGenerator",
	["PLAYER_LOGIN"] = "玩家登陆",
	["PLAYER_LEVEL_UP"] = "玩家升级",
	["BUY_VITALITY"] = "主界面购买体力",
	["BUY_STAMINA"] = "主界面购买耐力",
	["GOLDEN_TOUCH"] = "主界面点金",
	["HERO_ADVANCE"] = "英雄进阶",
	["HERO_EVOLUTE"] = "英雄培养",
	["EQUIP_BAPTIZE"] = "装备洗炼",
	["EQUIP_STRENGTHEN"] = "装备强化",
	["SHOP_BUY"] = "商店购买",
	["GIFT_BUY"] = "礼物购买",
	["ALLIANCE_SHOP_BUY"] = "学校商店兑换",
	["SHOP_REFRESH"] = "商店刷新",
	["HERO_GACHA"] = "英雄召唤",
	["HERO_WORK"] = "英雄打工",
	["HERO_TALENT_RESET"] = "英雄天赋重置",
	["STOP_WORK"] = "英雄终止打工",
	["EVENT_REFRESH"] = "刷新活动",
	["EVENT_SUBMIT"] = "提交活动",
	["MAIL_ATTACH"] = "邮件附件",
	["MAP_STAGE"] = "副本战斗",
	["MAP_CLEAR"] = "副本扫荡",
	["STARS_REWARD"] = "星星奖励",
	["BUY_ARENA"] = "购买竞技场",
	["AUTO_HONOR"] = "声望自动累加",
	["LOGIN_HONOR"] = "登陆增加声望值",
	["EQUIP_BESET"] = "装备镶嵌",
	["EQUIP_UNBESET"] = "卸载镶嵌",
	["FRIEND_SEND"] = "还有赠送",
	["COMPETE_RESULT"] = "完成结果",
	["COMPETE_CLEAR"] = "完成清除",
	["TASK_REWARD"] = "任务奖励",
	["TASK_REFRESH"] = "任务刷新",
	["DAILY_REWARD"] = "登录奖励",
	["SCHEDULE_REWARD"] = "签到奖励",
	["GIFT_REWARD"] = "礼物奖励",
	["SKILL_LEVELUP"] = "技能升级",
	["MONEY_CREATE"] = "创建公会",
	["COST_CONTRIBUTION"] = "消耗个人建设点数，获得金币",
	["VISIT_ALLIANCE"] = "公会访问",
	["DONATE_ALLIANCE"] = "公会捐献",
	["ALLIANCE_SKILL"] = "公会技能训练",
	["BUY_VIP_BAG"] = "购买vip礼包",
	["PVP_DAILY_REWARD"] = "制霸之战每日奖励",
	["GET_CONTRIBUTION"] = "捐赠获得贡献点数",
	["VISIT_SENIOR"] = "拜访前辈",
	["VITALITY_REWARD"] = "领取体力值",
	["SEND_GIFT"] = "使用物品",
	["HERO_WILL_REWARD"] = "英雄好感度升级",
	["BLACK_TASK_REWARD"] = "黑市任务奖励",
	["GUARD_REFRESH"] = "守护刷新",
	["ARTIFACT_PRODUCE"] = "神器合成",
	["ARTIFACT_RESOLVE"] = "神器分解",
	["ARTIFACT_DIVINATION"] = "神器占卜",
	["ARTIFACT_BUY_PAGE"] = "神器购买仓库格子",
	["BLACK_GRAB_REWARD"] = "掠夺胜利奖励",
	["DATE_GAME_REWARD"] = "参加小游戏",
	["PVP1_DAILY_REWARD"] = "pvp日常奖励",
	["PVP_REWARD"] = "pvp奖励",
	["BOSS_RANK_REWARD"] = "boss排名奖励",
	["BOSS_CHALLENGE_BUY"] = "boss挑战购买",
	["TOWER_CHALLENGE"] = "爬塔挑战",
	["TOWER_CLEAR"] = "爬塔清除",
	["TOWER_REWARD"] = "爬塔奖励",
	["CHANGE_COLOR"] = "染色",
}

function getDataById(key_id)
    local id_data = CommandText[key_id]

    return id_data
end

function getArrDataByField(fieldName, fieldValue)
    local arrData = {}
    for k, v in pairs(CommandText) do
        if v[fieldName] == fieldValue then
            arrData[#arrData+1] = v
        end
    end

    return arrData
end

function release()
    _G["DB_CommandText"] = nil
    package.loaded["DB_CommandText"] = nil
    package.loaded["DBSystem/DB_CommandText"] = nil
end
--ExcelVBA output tools end flag
