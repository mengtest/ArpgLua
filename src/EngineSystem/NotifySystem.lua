-- Name: NotifySystem
-- Func: 消息系统
-- Author: Johny

NotifySystem = {}
NotifySystem.mType = "NOTIFYSYSTEM"
NotifySystem.mCppAgent = nil

------------------------本地变量------------------------------
local  _NOTIFY_DB_KEY_TILI_CLOSED_  = "_NOTIFY_DB_KEY_TILI_CLOSED_"
local  _NOTIFY_DB_KEY_SHOPREFRESH_CLOSED_  = "_NOTIFY_DB_KEY_SHOPREFRESH_CLOSED_"
-- 领取体力时间
local  _GET_TL_TIME_1 = {
	hr  = 12,
	min =  0
}
local  _GET_TL_TIME_2 = {
	hr  = 18,
	min =  0
}
local  _GET_TL_TIME_3 = {
	hr  = 21,
	min =  0
}
--------------------------------------------------------------


function NotifySystem:Init()
    cclog("=====NotifySystem:Init=====1")

    -- init cppAgent
    self.mCppAgent = NotifyAgent:GetLuaInstance()

    cclog("=====NotifySystem:Init=====2")
end

function NotifySystem:Tick()
	self.mCppAgent:Tick()
end

function NotifySystem:Release()
	NotifyAgent:FreeInstance()
	--
	_G["NotifySystem"] = nil
	package.loaded["NotifySystem"] = nil
	package.loaded["NotifySystem/NotifySystem"] = nil
end

function NotifySystem:RegisterNotification_Daily(_hr, _min, _title, _hint)
	self.mCppAgent:RegisterNotification_Daily(_hr, _min, _title, _hint)
end

function NotifySystem:RegisterNotification_Time(_day, _hr, _min, _title, _hint)
	self.mCppAgent:RegisterNotification_Time(_day, _hr, _min, _title, _hint)
end

-- 清除所有后台通知，游戏进入前台时
function NotifySystem:ClearAllNotification()
	cclog("=====NotifySystem:ClearAllNotification=====")
	self.mCppAgent:ClearAllNotification()
end

-- 注册所有后台通知，游戏进入后台时
function NotifySystem:RegisterAllNotification()
	local function registerGetTlNotification()
		cclog("=====NotifySystem:RegisterAllNotification=====GetTl")
		self:RegisterNotification_Daily(_GET_TL_TIME_1.hr, _GET_TL_TIME_1.min, GAMPE_NAME, DB_Text.getDataById(104)[GAME_LANGUAGE])
		self:RegisterNotification_Daily(_GET_TL_TIME_2.hr, _GET_TL_TIME_2.min, GAMPE_NAME, DB_Text.getDataById(105)[GAME_LANGUAGE])
		self:RegisterNotification_Daily(_GET_TL_TIME_3.hr, _GET_TL_TIME_3.min, GAMPE_NAME, DB_Text.getDataById(106)[GAME_LANGUAGE])
	end
	registerGetTlNotification()
end

-- 注册延时通知
function NotifySystem:RegisterDelayNotification()
	cclog("=====NotifySystem:RegisterDelayNotification=====")
	NotifySystem:RegisterNotification_Time(0,0,0,"","")
end


--@接收事件
function NotifySystem:onEventHandler(event)

end



------------------------逻辑--------------------------------------
function NotifySystem:isNotifyTiliEnabled()
	return not DBSystem:Get_Boolean_FromSandBox(_NOTIFY_DB_KEY_TILI_CLOSED_)
end

function NotifySystem:enableNotifyTili(enabled)
   DBSystem:Save_Boolean_ToSandBox(_NOTIFY_DB_KEY_TILI_CLOSED_, not enabled)
end

function NotifySystem:registerNotifyTili()
	
end

function NotifySystem:isNotifyShopRefreshEnabled()
	return not DBSystem:Get_Boolean_FromSandBox(_NOTIFY_DB_KEY_SHOPREFRESH_CLOSED_)
end

function NotifySystem:enableNotifyShopRefresh(enabled)
	DBSystem:Save_Boolean_ToSandBox(_NOTIFY_DB_KEY_SHOPREFRESH_CLOSED_, not enabled)
end

function NotifySystem:registerNotifyShopRefresh()
	
end