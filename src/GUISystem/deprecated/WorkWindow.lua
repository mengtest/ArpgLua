-- Name: 	WorkWindow
-- Func：	打工窗口
-- Author:	WangShengdong
-- Data:	14-1-22

local workers = 5	--打工者数量

local costTime = {10800, 36000}
local payVal = {}
payVal[1] = {24000, 72000}
payVal[2] = {12, 36}
payVal[3] = {12, 36}
local payName = {"金币", "钻石", "耐力"}

local WorkWindow = 
{
	mName						=	"WorkWindow",
	mRootNode 					= 	nil,
	mRootWidget 				= 	nil,
	mTopRoleInfoPanel			=	nil,
	mActivityWindow				=	nil,			-- 活动窗口
	mLastSelectedActivityIndex	=	nil,			-- 最后选择的活动	
}

function WorkWindow:Release()

end

function WorkWindow:Load(event)
	cclog("=====WorkWindow:Load=====begin")

	-- 接收打工信息
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_REQUEST_WORK_INFO_, handler(self, self.onRequestWorkInfo))

	GUIEventManager:registerEvent("updateWorkerInfo", self, self.onWorkInfoChanged)

	self.mRootNode = cc.Node:create()
	GUISystem:GetRootNode():addChild(self.mRootNode)

	self:InitLayout(event)

	cclog("=====WorkWindow:Load=====end")
end

function WorkWindow:InitLayout(event)
	self.mRootWidget =  GUIWidgetPool:createWidget("Work")
	self.mRootNode:addChild(self.mRootWidget)
	self.mActivityWindow = self.mRootWidget:getChildByName("Panel_Main")

	local function closeWindow()
		GUISystem:playSound("homeBtnSound")
		EventSystem:PushEvent(Event.GUISYSTEM_HIDE_WORKWINDOW)
	end

	self.mTopRoleInfoPanel = TopRoleInfoPanel:new()
	local topInfoPanel = self.mTopRoleInfoPanel:init(self.mRootNode, closeWindow)

	local function doAdapter()
	    local topInfoPanelSize = topInfoPanel:getContentSize()
	    local newHeight = getGoldFightPosition_LU().y - topInfoPanelSize.height - getGoldFightPosition_LD().y
	    local newPosY = newHeight/2 + getGoldFightPosition_LD().y - self.mRootWidget:getChildByName("Panel_Main"):getContentSize().height/2
	    self.mRootWidget:getChildByName("Panel_Main"):setVisible(false)
		local function doSomething()
			self.mRootWidget:getChildByName("Panel_Main"):setPositionY(newPosY)
			self.mRootWidget:getChildByName("Panel_Main"):setVisible(true)
		end
		doSomething()
	end
	doAdapter()

	self.mActivityWindow:getChildByName("Radio_Position_Left_Label"):setVisible(false)
	self.mActivityWindow:getChildByName("Paint_Position_Left_Label"):setVisible(false)
	self.mActivityWindow:getChildByName("Sport_Position_Left_Label"):setVisible(false)

	local  function getWorkInfo()
		local packet = NetSystem.mNetManager:GetSPacket()
    	packet:SetType(PacketTyper._PTYPE_CS_REQUEST_WORK_INFO_)
    	packet:Send()
    	GUISystem:showLoading()
	end

	getWorkInfo()

	registerWidgetReleaseUpEvent(self.mActivityWindow:getChildByName("Image_Music"), handler(self, self.OnSelectWork))
	registerWidgetReleaseUpEvent(self.mActivityWindow:getChildByName("Image_Painting"), handler(self, self.OnSelectWork))
	registerWidgetReleaseUpEvent(self.mActivityWindow:getChildByName("Image_Sports"), handler(self, self.OnSelectWork))

end

function WorkWindow:setWorkInfo()
	self.mActivityWindow:getChildByName("Radio_Position_Left_Label"):setVisible(true)
	self.mActivityWindow:getChildByName("Paint_Position_Left_Label"):setVisible(true)
	self.mActivityWindow:getChildByName("Sport_Position_Left_Label"):setVisible(true)
	self.mActivityWindow:getChildByName("Radio_Position_Left_Label"):setString("空余职位   "..(5 - #globaldata.workers[1]).."/5")
	self.mActivityWindow:getChildByName("Paint_Position_Left_Label"):setString("空余职位   "..(5 - #globaldata.workers[2]).."/5")
	self.mActivityWindow:getChildByName("Sport_Position_Left_Label"):setString("空余职位   "..(5 - #globaldata.workers[3]).."/5")
end


function WorkWindow:onWorkInfoChanged()
	self:setWorkInfo()
end

-- 请求打工回包
function WorkWindow:onRequestWorkInfo(msgPacket)
	-- 清除Worker定时器
	globaldata:cleanWorkers()
	-- 接收信息
	globaldata:updateWorkInfoFromServer(msgPacket)

	self:setWorkInfo()
		
	GUISystem:hideLoading()
end

function WorkWindow:OnSelectWork(widget)
	self.mLastSelectedActivityIndex = widget:getTag()
	
	Event.GUISYSTEM_SHOW_WORKPOSITIONWINDOW.mData = self.mLastSelectedActivityIndex
	EventSystem:PushEvent(Event.GUISYSTEM_SHOW_WORKPOSITIONWINDOW)
end


function WorkWindow:Destroy()
	GUIEventManager:unregister("updateWorkerInfo", self.onWorkInfoChanged)

	self.mRootNode:removeFromParent(true)
	self.mRootNode = nil
	self.mRootWidget = nil
	self.mActivityWindow = nil

	self.mLastSelectedActivityIndex	=	nil

	self.mTopRoleInfoPanel:destroy()
	self.mTopRoleInfoPanel = nil

	-- 清除Worker定时器
	globaldata:cleanWorkers()
	----------------
	SpineDataCacheManager:destroyFightSpineList()
	CommonAnimation:clearAllTexturesAndSpineData()
end

function WorkWindow:onEventHandler(event)
	if event.mAction == Event.WINDOW_SHOW then
		self:Load(event)
	elseif event.mAction == Event.WINDOW_HIDE then
		self:Destroy()
	end
end


return WorkWindow