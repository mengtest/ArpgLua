-- Name: 	NoticeSystem
-- Func: 	通知系统(红点)
-- Author: 	wangshengdong
-- Date:	2016-1-27
-- PS:  在GUIWidgetPool中初始化

-- 战队红点
require "NoticeSystem/HeroNoticeInnerImpl"
require "NoticeSystem/HeroNoticeHelper"

-- 装备红点
require "NoticeSystem/EquipNoticeInnerImpl"
require "NoticeSystem/EquipNoticeHelper"

-- 主城红点
require "NoticeSystem/HomeNoticeInnerImpl"
require "NoticeSystem/HomeNoticeHelper"

-- 副本红点
require "NoticeSystem/PveNoticeInnerImpl"
require "NoticeSystem/PveNoticeHelper"

-- 徽章红点
require "NoticeSystem/BadgeNoticeInnerImpl"
require "NoticeSystem/BadgeNoticeHelper"

-- 时装红点
require "NoticeSystem/FashionNoticeInnerImpl"
require "NoticeSystem/FashionNoticeHelper"

-- 技能红点
require "NoticeSystem/SkillNoticeInnerImpl"
require "NoticeSystem/SkillNoticeHelper"


---------------------------------------------------------------pair----------------------------------------------------------

pairObject ={}

function pairObject:new(firstVal, secondVal)
	local o =
	{
		first 	= firstVal,
		second 	= secondVal
	}
	o = newObject(o, pairObject)
	return o
end

function makePair(val1, val2)
	local obj = pairObject:new(val1, val2)
	return obj
end

---------------------------------------------------------------pair----------------------------------------------------------

------------------------------------------------------------- handler--------------------------------------------------------

noticeHandler = {}

function noticeHandler:new(handlerName)
	local o = 
	{
		mName 		= 	handlerName,
		mPairsList	=	{}
	}
	o = newObject(o, noticeHandler)
	return o
end

function noticeHandler:insertPairObj(obj)
	self.mPairsList[obj.first] = obj
end

function noticeHandler:resetPairObj(firstVal, secondVal)
	if self.mPairsList[firstVal] then
		self.mPairsList[firstVal] = makePair(firstVal, secondVal)
		print("重置:", firstVal, secondVal)
	end
end

function noticeHandler:getSecondVal(firVal)
	return self.mPairsList[firVal].second
end

function noticeHandler:doUpdate()
	local window = GUISystem:GetWindowByName(self.mName)
	-- homewindow 特殊处理
	if self.mName == "HomeWindow" and not window.mIsLoaded then return end
	local rootNode = window.mRootNode
	local rootWidget = window.mRootWidget
	if rootWidget then -- 窗口处于显示状态
		for k, v in pairs(self.mPairsList) do
			local redName = "Image_Notice_"..tostring(v.first)
			print("窗口名字:", self.mName, "红点控件名字:", redName)
			local redWidget = rootWidget:getChildByName(redName)
		--	if redWidget then
				if 1 == v.second then -- 不显示
					redWidget:setVisible(false)
				elseif 0 == v.second then -- 显示
					redWidget:setVisible(true)
				end
		--	end
		end
	end
end

------------------------------------------------------------- handler--------------------------------------------------------

NoticeSystem = 
{
	mHandlerList = {}
}

-- 初始化
function NoticeSystem:init()
	for k, v in pairs(DB_Notice.Notice) do
		local TableData = DB_Notice.getDataById(k)
		local noticeId = k
		local noticeHandlerName = TableData["WindowName"]
		local noticeStyle = TableData["Style"]
		if "server" == noticeStyle then
			-- 没有则创建
			if not self.mHandlerList[noticeHandlerName] then
				self.mHandlerList[noticeHandlerName] = noticeHandler:new(noticeHandlerName)
			end
			-- 插入
			self.mHandlerList[noticeHandlerName]:insertPairObj(makePair(noticeId, 1))
		end
	end
end

-- 销毁
function NoticeSystem:destroy()
	
end

-- 执行刷新(全部)
function NoticeSystem:doAllUpdate()
	for k, v in pairs(self.mHandlerList) do
		v:doUpdate()
	end
end

-- 执行刷新(单个)
function NoticeSystem:doSingleUpdate(handlerName)
	if self.mHandlerList[handlerName] then
		self.mHandlerList[handlerName]:doUpdate()
	end
end

-- 重置
function NoticeSystem:resetPair(firstVal, secondVal)
	local noticeData = DB_Notice.getDataById(firstVal)
	if noticeData then -- 有此ID
		local handler = self.mHandlerList[noticeData["WindowName"]]
		if handler then -- 有此处理器
			-- 处理器重置
			handler:resetPairObj(firstVal, secondVal)
			-- 执行刷新(全部)
			self:doAllUpdate()
		end
	end
end