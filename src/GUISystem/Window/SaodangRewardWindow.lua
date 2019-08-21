-- Name: 	SaodangRewardWindow
-- Func：	扫荡奖励界面
-- Author:	WangShengdong
-- Data:	14-11-25

local SaodangRewardWindow = 
{
	mName 		= 	"SaodangRewardWindow",
	mRootNode	=	nil,
	mRootWidget	=	nil,
}

function SaodangRewardWindow:Release()

end

function SaodangRewardWindow:Load()
	cclog("=====SaodangRewardWindow:Load=====begin")

	self.RootNode = cc.Node:create()
	GUISystem:GetRootNode():addChild(self.RootNode)
	self:InitLayout()

	cclog("=====SaodangRewardWindow:Load=====end")
end

function SaodangRewardWindow:InitLayout()
	self.mRootWidget = GUIWidgetPool:createWidget("PVE_SaodangReward")

	self.RootNode:addChild(self.mRootWidget)

	local closeBtn = self.mRootWidget:getChildByName("Button_SaodangClose")
	local function closeWnd(widget)
		EventSystem:PushEvent(Event.GUISYSTEM_HIDE_SAODANGREWARDWINDOW)
	end
	registerWidgetReleaseUpEvent(closeBtn, closeWnd)
	self:InitRewardList()
end

-- 奖励列表
function SaodangRewardWindow:InitRewardList()
	local listWidget = self.mRootWidget:getChildByName("ListView_Reward")
--	listWidget:setClippingEnabled(false)

	for i = 1, 4 do
		local contentWidget = GUIWidgetPool:createWidget("Saodang_Content")
		listWidget:pushBackCustomItem(contentWidget)
	end
end

function SaodangRewardWindow:Destroy()
	self.RootNode:removeFromParent(true)
	self.RootNode = nil
	self.mRootWidget = nil
	CommonAnimation:clearAllTextures()
	cclog("=====SaodangRewardWindow:Destroy=====")
end

function SaodangRewardWindow:onEventHandler(event)
	if event.mAction == Event.WINDOW_SHOW then
		self:Load()
	elseif event.mAction == Event.WINDOW_HIDE then
		self:Destroy()
	end
end

return SaodangRewardWindow