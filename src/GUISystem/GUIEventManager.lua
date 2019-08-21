-- Name: 	GUIEventManager.lua
-- Func：	GUI事件管理器(单一event,多handler)
-- Author:	WangShengdong
-- Data:	14-12-4

GUIEventDef = 
{
	-- logic
	"serverChanged",			-- 更换选择服务器
	"showItemDetailInfo",		-- 点击背包中Item显示详细信息
	"confirmItemSell",			-- 商品确认售出
	"loadingResource",			-- 加载资源中
	"finishLoadingRes",			-- 资源加载完毕
	"connectToServerSuccess",	-- 成功连接到服务器
	"xilianPriceChanged",		-- 洗练价格变化
	"equipStrengthenSuccess",	-- 装备强化成功
	"bagpackGridCountChanged",	-- 背包中格子数量发生变化
	"movingDiamond", 			-- 镶嵌拖动宝石
	"diamondXiangqianSuccess",	-- 宝石镶嵌成功
	"diamondPutoffSuccess", 	-- 宝石脱掉成功
	"updateJinHua",				-- 进阶
	"updateWorkerInfo",			-- 更新打工信息
	"sendChatInfo", 			-- 发送聊天信息
	"furnitChanged", 			-- 家具变化
	"updatePingStatus",		    -- 更新ping值
	
	-- globaldata
	"roleBaseInfoChanged",		-- 玩家基础数据修改
	"itemInfoChanged",			-- 玩家物品数据修改
	"battleTeamChanged",		-- 玩家阵容
	"equipChanged",				-- 装备调整	
	"combatChanged",			-- 战力变化	
	"updateMailInfo", 			-- 邮件信息变化	
	"deleteMailSuccess", 		-- 删除邮件成功	
	"clearAllMail",				-- 清空邮件
	"playerLevelup",			-- 玩家升级	
	"chapterInfoChanged",		-- 章节变化
	"shopFreshed",				-- 商城刷新
	"arenaChallCountChanged",	-- 竞技场剩余挑战次数变化
	"starRewardGot", 			-- 领取星星奖励
	"taskSyncHappen",			-- 任务同步
	"heroAddSync",				-- 合成英雄
	"dateFinish",				-- 约会完成
	"autoSkillUpdate",			-- 技能自动强化
}

-- 事件处理器
GUIEventHandler = {}

function GUIEventHandler:new(name)
	local o = {
        mName = name,
        mHandlerMap = {},  
    }
    o = newObject(o, GUIEventHandler)
    return o
end

function GUIEventHandler:addHandler(obj, handler)
	if "function" == type(handler) and not self.mHandlerMap[handler] then
		print("register event handler:", obj, handler)
		self.mHandlerMap[handler] = {owner = obj, func = handler}
	end
	print("event: '"..self.mName.."' has "..tostring(self:getHandlerCount()).." handlers")
end

function GUIEventHandler:removeHandler(handler)
	if self.mHandlerMap[handler] then
		print("remove event handler:", self.mHandlerMap[handler].owner, self.mHandlerMap[handler].handler)
		self.mHandlerMap[handler] = nil
	end
	print("event: '"..self.mName.."' has "..tostring(self:getHandlerCount()).." handlers")
end

function GUIEventHandler:getHandlerCount()
	local count = 0
	for k, v in pairs(self.mHandlerMap) do
		count = count + 1
	end
	return count
end

function GUIEventHandler:handle(...)
	for k, v in pairs(self.mHandlerMap) do
		v.func(v.owner, ...)
	end
end

-- 事件管理器
GUIEventManager = 
{
	mEventMap = {},
}

function GUIEventManager:registerEvent(name, obj, handler)
	if not self.mEventMap[name] then
		self.mEventMap[name] = GUIEventHandler:new(name)
	end
	self.mEventMap[name]:addHandler(obj, handler)
end

function GUIEventManager:unregister(name, handler)
	if self.mEventMap[name] then
		self.mEventMap[name]:removeHandler(handler)
	end
end

function GUIEventManager:unregisterAllHandler(name)
	if self.mEventMap[name] then
		self.mEventMap[name] = nil
	end
end

function GUIEventManager:dispatchEvent(name, ...)
	if self.mEventMap[name] then
		self.mEventMap[name]:handle(...)
	end
end

function GUIEventManager:pushEvent(name, ...)
	self:dispatchEvent(name, ...)
end












