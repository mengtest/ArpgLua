-- Name: AnySDKManager
-- Func: anysdk管理器
-- Author: Johny

require "AnySDK/ChannelSDKConfig"
require "AnySDK/TDConfig"

AnySDKManager = {}

--------------------------------------本地变量----------------------------------
local CHANNEL_CALLBACK_TYPE = {}
CHANNEL_CALLBACK_TYPE.LOGIN 	= 1
CHANNEL_CALLBACK_TYPE.PAYMENT 	= 2
--------------------------------------本地变量----------------------------------

function AnySDKManager:init()
	self.misLoginingBySDK = false
	-- 初始化
	self.mCurChannelId = ChannelSDKConfig.chanelIdList.guest
	self.mSDKParam1 = ""
	self.mSDKParam2 = ""
    -- channel sdk
    if ChannelSDKConfig.ENABLE then
    	self.mChannelSDKManager = SDKManager:GetLuaInstance()
    	self.mChannelSDKManager:RegisterLuaHandler(handler(self, self.channel_onChannelCallBack))
    	self.mCurChannelId = self.mChannelSDKManager:getChannelId()
    end

	-- talkingdata
	if TDConfig.ENABLE_TD then
		TalkingDataGA:setVerboseLogDisabled()
		TalkingDataGA:onStart(TDConfig.APPKEY, self:getChannelName())
		--注册收包回调函数
		NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_NOTIFY_JEWEL_TD, handler(self, self.td_onNotifyAboutJewel))
	end
	self.mHasInit = true
end

function AnySDKManager:destroy()
	if not self.mHasInit then return end
	self.mHasInit = false
	if TDConfig.ENABLE_TD then
		NetSystem.mNetManager:UnRegisterPacketHandler(PacketTyper._PTYPE_SC_NOTIFY_JEWEL_TD, handler(self, self.td_onNotifyAboutJewel))
		TalkingDataGA:onKill()
	end
	if not ChannelSDKConfig.ENABLE then return end
	SDKManager:FreeInstance()
	self.mChannelSDKManager = nil
end

-- 获取当前渠道号
function AnySDKManager:getChannelId()
	return self.mCurChannelId
end
-- 获取当前渠道名
function AnySDKManager:getChannelName()
	return ChannelSDKConfig.channelNameMap[self.mCurChannelId]
end

-- 是否为游客登录
function AnySDKManager:isLoginByGuest()
	return self.mCurChannelId == ChannelSDKConfig.chanelIdList.guest
end

-- 获取渠道参数1
function AnySDKManager:getSDKParam1()
	return self.mSDKParam1
end

-- 获取渠道参数2
function AnySDKManager:getSDKParam2()
	return self.mSDKParam2
end

-- @获取玩家唯一id,1003解包后可获得
function AnySDKManager:getAccountID()
	return globaldata.playerId
end

-- 获取用户名,密码（仅游客）
-- @return  游客则返回用户名，密码，没有则返回-1
--			渠道则返回0
function AnySDKManager:getUserNameAndPwd()
	if self.mCurChannelId == ChannelSDKConfig.chanelIdList.guest then
		local accountFileName = cc.FileUtils:getInstance():getWritablePath().."account.json"
	    local accountFile = io.open(accountFileName, "r")
	    if not accountFile then
	       return -1
	    end
	    local jsonString = accountFile:read("*a")
	    if "" == jsonString then
	       io.close(accountFile)
	       return -1
	    end
	    -- 验证账号密码不为空
	    local luaTable = json.decode(jsonString)
	    if not luaTable.account or not luaTable.pwd then
	       io.close(accountFile)
	       return -1
	    end 

	    io.close(accountFile)
	    return luaTable.account, luaTable.pwd
	else
		return 0
	end
end

-- SDK登录接口
function AnySDKManager:loginBySDK()
	self.misLoginingBySDK = true
	GUISystem:showLoading(true)
	AnySDKManager:user_login()
end

---------------------------------分析器相关-----------------------------------
--@副本战斗胜利统计-封装
function AnySDKManager:td_fbSucc(taskName, starCount)
	self:td_task_Complete(taskName)
	self:td_event_fbsucc_starcount(taskName, starCount)
end


--@自定义事件-副本过关星级统计
function AnySDKManager:td_event_fbsucc_starcount(eventName, starCount)
	if not TDConfig.ENABLE_TD then return end
	local data = {}
	data["starCount"] = starCount
	self:td_event(eventName, data)
end
--@自定义事件
--[[local eventData = {key1="value1",key2="value2",key3="value3"}]]--
function AnySDKManager:td_event(_eventName, _eventData)
	if not TDConfig.ENABLE_TD then return end
	TalkingDataGA:onEvent(_eventName,_eventData)
end
--@获取deviceid
function AnySDKManager:td_getDeviceId()
	if not TDConfig.ENABLE_TD then return "PC" end
	return TalkingDataGA:getDeviceId()
end

--@统计帐号信息,1003返回后调用
function AnySDKManager:td_accountinfo(_name, _lv, _serverName)
	if not TDConfig.ENABLE_TD then return end
	cclog("td_accountinfo=" .. self.mSDKParam1 .. "=" .. _name .. "=" .. _lv .. "=" .. _serverName)
	TDGAAccount:setAccount(self:getAccountID())
	TDGAAccount:setAccountName(_name)
	TDGAAccount:setAccountType(TDConfig.kAccountRegistered)
	TDGAAccount:setLevel(_lv)
	TDGAAccount:setGameServer(_serverName)
end
--@统计任务--开始
function AnySDKManager:td_task_begin(_taskName)
	cclog("td_task_begin=" .. _taskName)
	if not TDConfig.ENABLE_TD then return end
	TDGAMission:onBegin(_taskName)
end
--@统计任务--完成
function AnySDKManager:td_task_Complete(_taskName)
	cclog("td_task_Complete=" .. _taskName)
	if not TDConfig.ENABLE_TD then return end
	TDGAMission:onCompleted(_taskName)
end
--@统计任务--失败
function AnySDKManager:td_task_fail(_taskName, _reason)
	cclog("td_task_fail=" .. _taskName)
	if not TDConfig.ENABLE_TD then return end
	TDGAMission:onFailed(_taskName,_reason)
end
--@统计充值--请求
function AnySDKManager:td_charge_request(_orderID, _itemName, _currencyAmount, _vAmount, _payType)
	if not TDConfig.ENABLE_TD then return end
	TDGAVirtualCurrency:onChargeRequest(_orderID,_itemName,_currencyAmount,"CNY", _vAmount, _payType)
end
--@统计充值--成功
function AnySDKManager:td_charge_succ(_orderID)
	if not TDConfig.ENABLE_TD then return end
	TDGAVirtualCurrency:onChargeSuccess(_orderID)
end
--@钻石--获得
function AnySDKManager:td_jewel_reward(_num, _reason)
	if not TDConfig.ENABLE_TD then return end
	TDGAVirtualCurrency:onReward(_num, _reason)
end
--@钻石--消耗
--ps: _price为单价
function AnySDKManager:td_jewel_purchase(_itemName, _Num, _price)
	if not TDConfig.ENABLE_TD then return end
	TDGAItem:onPurchase(_itemName,_Num,_price)
end
--[[
	无法统计： 无法知晓物品的来源
	--@统计道具--使用(消耗钻石的)
	function AnySDKManager:td_item_use(_itemName, _Num)
		if not ChannelSDKConfig.ENABLE then return end
		TDGAItem:onUse(_itemName, _Num)
	end
	
	无法统计： 无法获取
	--@设置坐标
	function AnySDKManager:td_setLocation()
		if not ChannelSDKConfig.ENABLE then return end
		TalkingDataGA:setLocation(39.9497,116.4137)
	end
]]


--@服务器通知回调
--tp: 1:获得  2：消耗
function AnySDKManager:td_onNotifyAboutJewel(msgPacket)
	local tp = msgPacket:GetInt()
	if tp == 1 then
	   local reason = msgPacket:GetString()
	   local cnt = msgPacket:GetInt()
	   self:td_jewel_reward(cnt, reason)
	elseif tp == 2 then
	   local reason = msgPacket:GetString()
	   local cost = msgPacket:GetInt()
	   self:td_jewel_purchase(reason, 1, cost)
	end
end
---------------------------------分析器相关-----------------------------------

---------------------------------渠道相关-----------------------------------
-- 登录回调
--[[
	@ret:
	1: 成功(uid和sessionid不为空)
	2: 失败
	3: 取消
	4: 正在登陆
	5: 退出登录
]]
function AnySDKManager:channel_onLoginCallBack(ret, param1, param2)
	if not ChannelSDKConfig.ENABLE then return end
	local ret2 = tonumber(ret)
	cclog("----AnySDKManager:channel_onLoginCallBack----" .. ret2)
	GUISystem:hideLoading()
	if ret2 == 1 then
	   cclog("----AnySDKManager:channel_onLoginCallBack--succ----" .. param1 .. "=" .. param2)
	   self.mSDKParam1 = param1
	   self.mSDKParam2 = param2
	   NetSystem:connectToGameServer()
	elseif ret2 == 2 then
	elseif ret2 == 3 then
	elseif ret2 == 4 then
	elseif ret2 == 5 then
		cclog("----AnySDKManager:channel_onLoginCallBack--logout")
	end
	self.misLoginingBySDK = false
end
-- 渠道回调
function AnySDKManager:channel_onChannelCallBack(tp, param1, param2, param3)
	if not ChannelSDKConfig.ENABLE then return end
	cclog("[AnySDKManager:channel_onChannelCallBack]==" .. tp)
	if tp == CHANNEL_CALLBACK_TYPE.LOGIN then
		self:channel_onLoginCallBack(param1, param2, param3)
	elseif tp == CHANNEL_CALLBACK_TYPE.PAYMENT then

	end
end

-- 用户登录
function AnySDKManager:user_login()
	if not ChannelSDKConfig.ENABLE then return end
	self.mChannelSDKManager:user_login()
end

-- 显示悬浮框
function AnySDKManager:user_showToolBar(showed)
	if not ChannelSDKConfig.ENABLE then return end
	self.mChannelSDKManager:user_showToolBar(showed)
end
---------------------------------渠道相关-----------------------------------