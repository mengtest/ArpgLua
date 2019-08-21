-- Name: 	AndroidLaunchWindow
-- Func：	安卓进入游戏第一个窗口
-- Author:	Johny

local AndroidLaunchWindow = 
{
	mName 			= "AndroidLaunchWindow",
	mRootNode 		= nil,
}

function AndroidLaunchWindow:Release()

end

function AndroidLaunchWindow:Load()
	cclog("AndroidLaunchWindow:Load=====begin")
	self.mRootNode = cc.Node:create()
	GUISystem:GetRootNode():addChild(self.mRootNode)
	self:InitLayout()
	cclog("AndroidLaunchWindow:Load=====end")
end


function AndroidLaunchWindow:InitLayout()
	local layer = cc.LayerColor:create(G_COLOR_C4B.WHITE,GG_GetWinSize().width,GG_GetWinSize().height)
	self.mRootNode:addChild(layer)
	local logo = cc.Sprite:create("res/image/logo/beta.png")
	logo:setPosition(layer:getContentSize().width/2, layer:getContentSize().height/2)
	layer:addChild(logo)
end

function AndroidLaunchWindow:Destroy()
	self.mRootNode:removeFromParent()
	self.mRootNode = nil
end

function AndroidLaunchWindow:onEventHandler(event)
	if event.mAction == Event.WINDOW_SHOW then
		self:Load()
	elseif event.mAction == Event.WINDOW_HIDE then
		self:Destroy()
	end
end

return AndroidLaunchWindow