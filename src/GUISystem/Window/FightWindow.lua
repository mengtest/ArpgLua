-- Name: FightWindow
-- Func: 战斗界面
-- Author: Johny


local FightWindow = {}
FightWindow.mName = "FightWindow"
FightWindow.mIsLoad = false
--@随窗口销毁的成员
FightWindow.mRootNode = nil


function FightWindow:Release()
	_G["FightWindow"] = nil
 	package.loaded["FightWindow"] = nil
 	package.loaded["GUISytem/FightWindow"] = nil
end


function FightWindow:Load(_data)
	cclog("=====FightWindow:Load=====1")
	local function externFunc()
		EventSystem:PushEvent(Event.GUISYSTEM_HIDE_TASKWINDOW)
		-- 战斗前清下lua层spine缓存，避免战斗内复用的是简模
		SpineDataCacheManager:destroyFightSpineList()
	end
	math.randomseed(os.clock()*1000+os.time())
	externFunc()

	PKHelper:HidePKInvite()
	-- load window
	self.mRootNode = cc.Node:create()
	GUISystem:GetRootNode():addChild(self.mRootNode)
	self.mIsLoad = true
	----
	InitFallData()
	-- 
	FightSystem:Load(self.mRootNode, _data)
	-- 初始分配艺术字数量
	--CocosCacheManager:initLabelBMFontList(100)

	cclog("=====FightWindow:Load=====2")
end

function FightWindow:Destroy(_param1)
	if not self.mRootNode then return end
	StorySystem.mCGManager:CGEnd()
	FightSystem:Unload()
	--CocosCacheManager:destroyLabelBMFontList()
	--destroy window

	PKHelper:ShowPKInvite()
	self.mIsLoad = false
	self.mRootNode:removeFromParent()
	self.mRootNode = nil
	----------
	if _param1 ~= "refight" then
	   FightSystem.mIsReFight = false
	   SpineDataCacheManager:destroyFightSpineList()
	   CommonAnimation:clearAllTexturesAndSpineData()
	else
	   FightSystem.mIsReFight = true
	end
end

--@接收事件
function FightWindow:onEventHandler(event)
	if event.mAction == Event.WINDOW_SHOW then
		self:Load(event.mData)
	elseif event.mAction == Event.WINDOW_HIDE then
		self:Destroy(event.mData)
	end	
end


return FightWindow