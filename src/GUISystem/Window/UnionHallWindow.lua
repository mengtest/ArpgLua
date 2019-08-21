-- Name: 	UnionHallWindow
-- Func：	帮派大厅窗口
-- Author:	Johny


local UnionHallWindow = 
{
	mName 				=   "UnionHallWindow",
	mIsLoaded 		    =   false,
	mRootNode			=	nil,	
	mRootWidget 		= 	nil,
	mBottomChatPanel    =   nil,
	mTopRoleInfoPanel   =   nil,
}

function UnionHallWindow:Release()
end


function UnionHallWindow:Load()
	if self.mIsLoaded then 
	   self:EnableDraw()
	return end
	cclog("=====UnionHallWindow:Load=====begin")
	self.mIsLoaded = true
	self.mRootNode = cc.Node:create()
	GUISystem:GetRootNode():addChild(self.mRootNode)
	-- 载入UI
	self:InitLayout(self.mRootNode, 3)
	-- 载入大厅和人
	FightSystem:LoadCityHall(self.mRootNode, 1)
end


function UnionHallWindow:InitLayout(_root, _zorder)
	local function backToCity()
		UnionSubManager:leaveUnionHall()
	end
	self.mTopRoleInfoPanel = TopRoleInfoPanel:new()
	local topInfoPanel = self.mTopRoleInfoPanel:init(self.mRootNode,ROLE_TITLE_TYPE.TITLE_UNION, backToCity)
    _root:addChild(topInfoPanel, _zorder)

    -- 载入聊天窗口
	self.mBottomChatPanel = BottomChatPanel:new()
	self.mBottomChatPanel:init(_root)
end

function UnionHallWindow:Destroy()
	if not self.mIsLoaded then return end
	self.mIsLoaded = false
	-- 清理聊天
	self.mBottomChatPanel:destroy()
	self.mBottomChatPanel = nil
	-- 清理titlebar
	self.mTopRoleInfoPanel:destroy()
	self.mTopRoleInfoPanel = nil
	FightSystem:UnloadCityHall()
	self.mRootNode:removeFromParent(true)
	self.mRootNode = nil
	-- 清理战斗内spine缓存(因为场景动画共用)
	SpineDataCacheManager:destroyFightSpineList()
	CommonAnimation:clearAllTexturesAndSpineData()
end

function UnionHallWindow:DisableDraw()
	if self.mRootNode then
		self.mRootNode:setVisible(false)
	end
end

function UnionHallWindow:EnableDraw()
	if self.mRootNode then
		self.mRootNode:setVisible(true)
	end
end

function UnionHallWindow:onEventHandler(event)
	if event.mAction == Event.WINDOW_SHOW then
		self:Load()
	elseif event.mAction == Event.WINDOW_HIDE then
		self:Destroy()
	elseif event.mAction == Event.WINDOW_ENABLE_DRAW then
		self:EnableDraw()
	elseif event.mAction == Event.WINDOW_DISABLE_DRAW then
		self:DisableDraw()
	end
end

return UnionHallWindow