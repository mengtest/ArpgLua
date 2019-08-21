-- Name: 	SectionEntryWindow
-- Func：	关卡入口
-- Author:	WangShengdong
-- Data:	14-11-13

local SectionEntryWindow = 
{
	mName 		= 	"SectionEntryWindow",
	mRootNode	=	nil,
	mRootWidget	=	nil,
	mSectionId  =   nil,	-- 关卡id
	mPveLevel	=	nil,	-- 难度级别
	mLogoWidget	=	nil,	-- 关卡图标
}

function SectionEntryWindow:Release()

end

function SectionEntryWindow:Load(event)
	cclog("=====SectionEntryWindow:Load=====begin")
	
	self.mLogoWidget = event.mData[1]
	self.mSectionId = event.mData[2]
	self.mPveLevel = event.mData[3]

	self.mRootNode = cc.Node:create()
	GUISystem:GetRootNode():addChild(self.mRootNode)
	self:InitLayout()

--	GUISystem:disableUserInput()

	cclog("=====SectionEntryWindow:Load=====end")
end

-- 扫荡十次
function SectionEntryWindow:OnSaodang10(widget)
	print("saodang x 10")
end

-- 扫荡一次
function SectionEntryWindow:OnSaodang(widget)
	EventSystem:PushEvent(Event.GUISYSTEM_SHOW_SAODANGREWARDWINDOW)
end

-- 闯关
function SectionEntryWindow:OnOpenSection(widget)
--[[
	Event.GUISYSTEM_SHOW_SELECTROLEWINDOW.mData = {self.mSectionId, self.mPveLevel}
	EventSystem:PushEvent(Event.GUISYSTEM_HIDE_SECTIONENTRYWINDOW)
	EventSystem:PushEvent(Event.GUISYSTEM_SHOW_SELECTROLEWINDOW)
]]	

end

-- 服务器回包响应
function SectionEntryWindow:onGoToBattle(msgPacket)
	-- globaldata:updateBattleFormation(msgPacket)
	-- --
	-- local function xxx()
	-- 	local _data = {}
	-- 	_data.mType = "fuben"
	-- 	_data.mHard = self.mSectionId --sectionInfo[1].MapUI_BoardConfigID
	-- 	_data.mPveLevel = self.mPveLevel
	-- 	Event.GUISYSTEM_SHOW_FIGHTWINDOW.mData = _data
	-- 	EventSystem:PushEvent(Event.GUISYSTEM_HIDE_PVEENTRYWINDOW)
	-- 	EventSystem:PushEvent(Event.GUISYSTEM_HIDE_SECTIONENTRYWINDOW)
	-- --	EventSystem:PushEvent(Event.GUISYSTEM_HIDE_SELECTROLEWINDOW)
	-- 	EventSystem:PushEvent(Event.GUISYSTEM_SHOW_FIGHTWINDOW)
	-- 	hideLoadingWindow()
	-- end
	-- nextTick_frameCount(xxx, 1)
end

function SectionEntryWindow:InitLayout()
	self.mRootWidget = GUIWidgetPool:createWidget("Section_Entry")
	
	self.mRootNode:addChild(self.mRootWidget)

	local function showLogo()
		self.mRootNode:addChild(self.mLogoWidget, 100)
		self.mLogoWidget:setTouchEnabled(false)
		local logoPos = cc.p(self.mRootWidget:getChildByName("Panel_LogoPos"):getWorldPosition())
		self.mLogoWidget:setPosition(logoPos)
	end
	showLogo()

	local function OnClose(widget, eventType)
		EventSystem:PushEvent(Event.GUISYSTEM_HIDE_SECTIONENTRYWINDOW)
	end
	registerWidgetReleaseUpEvent(self.mRootWidget, OnClose)
	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_close"), OnClose)
	
	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_Saodang10"), handler(self, self.OnSaodang10))
	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_Saodang"), handler(self, self.OnSaodang))
	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_OpenSection"), handler(self, self.OnOpenSection))
end

function SectionEntryWindow:Destroy()
	self.mRootNode:removeFromParent(true)
	self.mRootNode = nil
	self.mRootWidget = nil
	self.mSectionId = nil

	CommonAnimation:clearAllTextures()
	cclog("=====SectionEntryWindow:Destroy=====")
end

function SectionEntryWindow:onEventHandler(event)
	if event.mAction == Event.WINDOW_SHOW then
		self:Load(event)
	elseif event.mAction == Event.WINDOW_HIDE then
		self:Destroy()
	end
end

return SectionEntryWindow