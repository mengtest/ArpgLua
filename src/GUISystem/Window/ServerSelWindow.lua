-- Name: 	ServerSelWindow
-- Func：	服务器选择
-- Author:	WangShengdong
-- Data:	14-12-4

local ServerSelWindow = 
{
	mName				=	"ServerSelWindow",
	mRootNode			=	nil,
	mRootWidget			=	nil,
	mServerListWidget	=	nil,
	mServerItems		=	{},	-- 服务器控件列表
}

function ServerSelWindow:Release()

end

function ServerSelWindow:Load()
	cclog("=====ServerSelWindow:Load=====begin")

	self.mRootNode = cc.Node:create()
	GUISystem:GetRootNode():addChild(self.mRootNode)
	self:InitLayout()

	cclog("=====ServerSelWindow:Load=====end")
end

function ServerSelWindow:InitLayout()
	self.mRootWidget = GUIWidgetPool:createWidget("SelectServer")
	self.mRootNode:addChild(self.mRootWidget)

	self.mServerListWidget = self.mRootWidget:getChildByName("ListView_serverList")

	local function CloseWindow(widget)
		EventSystem:PushEvent(Event.GUISYSTEM_HIDE_SERVERSELWINDOW)
	end
	registerWidgetReleaseUpEvent(self.mRootWidget, CloseWindow)

	self:updateServerList()

end

-- 更新服务器列表
function ServerSelWindow:updateServerList()
	local serverItemRootWidget = GUIWidgetPool:createWidget("ServerItem")
	local serverItemWidget = serverItemRootWidget:getChildByName("Image_serverItem")

	-- 更新单个Item信息
	local function updateServerItemInfo(widget, info)
		widget:getChildByName("Label_2"):setString(info.name)
		local labelState = widget:getChildByName("Label_2_0")
		if '0' == info.state then
			labelState:setString("【维护】")
			labelState:setColor(cc.c3b(252, 65, 6))
		elseif '1' == info.state then
			labelState:setString("【流畅】")
			labelState:setColor(cc.c3b(2, 204, 62))
		elseif '2' == info.state then
			labelState:setString("【爆满】")
			labelState:setColor(cc.c3b(2, 204, 62))
		end
	end

	-- 列出所有服务器按钮
	local i = 1
	for k,info in pairs(NetSystem.mServerList) do
		self.mServerItems[i] = serverItemWidget:clone()
		self.mServerItems[i]:setTag(i)
		updateServerItemInfo(self.mServerItems[i], info)
		self.mServerListWidget:pushBackCustomItem(self.mServerItems[i])
		local function onTouch(widget, eventType)
			local imgSelected = widget:getChildByName("Image_selected")
			if eventType == ccui.TouchEventType.began then
		      	imgSelected:setVisible(true)
		    elseif eventType == ccui.TouchEventType.moved then

		    elseif eventType == ccui.TouchEventType.ended then
		    	imgSelected:setVisible(false)
		    	self:onServerSelected(widget)
		    elseif eventType == ccui.TouchEventType.canceled then
		    	imgSelected:setVisible(false)
		    end
		end
		self.mServerItems[i]:addTouchEventListener(onTouch)
		i = i + 1
	end
end

-- 响应
function ServerSelWindow:onServerSelected(widget)
	GUIEventManager:pushEvent("serverChanged", NetSystem.mServerList[widget:getTag()])
	EventSystem:PushEvent(Event.GUISYSTEM_HIDE_SERVERSELWINDOW)
end

function ServerSelWindow:Destroy()
	self.mRootNode:removeFromParent(true)
	self.mRootNode = nil
	self.mRootWidget = nil
	self.mServerItems = {}

	CommonAnimation:clearAllTextures()
end

function ServerSelWindow:onEventHandler(event)
	if event.mAction == Event.WINDOW_SHOW then
		self:Load()
	elseif event.mAction == Event.WINDOW_HIDE then
		self:Destroy()
	end
end

return ServerSelWindow
