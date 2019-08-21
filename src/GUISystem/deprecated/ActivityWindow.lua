-- Name: 	ActivityWindow
-- Func：	活动窗口
-- Author:	WangShengdong
-- Data:	15-3-30

local ActivityItem = {}

--------- 记录变量, 窗口关闭后依然记录--------------------
__IsEnterWorkWindow__ = false        -- 本次打开活动窗口，是否进入打工了
__IsEnterTowerWindow__ = false        -- 本次打开活动窗口，是否进入闯关了
__IsEnterFuckWindow__ = false        -- 本次打开活动窗口，是否进入约会了
__IsEnterWealthWindow__ = false        -- 本次打开活动窗口，是否进入财富之山了

-- 是否进入了任一窗口
local function IsEnterAnyWindow()
	return __IsEnterWorkWindow__ or __IsEnterTowerWindow__ or __IsEnterFuckWindow__ or __IsEnterWealthWindow__
end

-- 重置所有进入窗口变量
local function ResetAllWindowVar()
	__IsEnterWorkWindow__ = false
	__IsEnterTowerWindow__ = false        
	__IsEnterFuckWindow__ = false        
	__IsEnterWealthWindow__ = false   
end
-----------------------------------------------------------
function ActivityItem:new()
	local o = 
	{
		mId 		=	nil,
		mRootNode 	=	nil,
	}
	o = newObject(o, ActivityItem)
	return o
end

function ActivityItem:init(i, func)
	self.mRootNode = GUIWidgetPool:createWidget("ActivitiesList")
	self.mId = i
	self.mRootNode:setTag(i)

	if func then
		registerWidgetReleaseUpEvent(self.mRootNode, func)
	end

	local info = DB_Activity.getDataById(i)
	-- 名称
	local nameId = info.name
	local name = getDictionaryText(nameId)
	self.mRootNode:getChildByName("Label_Title"):setString(name)
	-- 小图标
	--[[local iconId = info.Icon
	local iconImgName = DB_ResourceList.getDataById(iconId).Res_path1
	self.mRootNode:getChildByName("Image_Icon"):loadTexture(iconImgName)]]--
end

function ActivityItem:getRootNode()
	return self.mRootNode
end

function ActivityItem:setSelected(selected)
	if selected then
		self.mRootNode:getChildByName("Image_Bg"):loadTexture("welfare_page_bg2.png")
	else
		self.mRootNode:getChildByName("Image_Bg"):loadTexture("welfare_page_bg1.png")
	end
end

local ActivityWindow = 
{
	mName					=	"ActivityWindow",
	mRootNode 				= 	nil,
	mRootWidget 			= 	nil,
	mActivityWidget 		=	nil,
	mActivityList 			=	{},
	mLastClickedWidget		=	nil,
	mTopRoleInfoPanel	    =	nil,
	mIsLoaded 		        =   false,
}

function ActivityWindow:Release()

end

function ActivityWindow:Load(event)
	cclog("=====MailWindow:Load=====begin")

	self.mRootNode = cc.Node:create()
	GUISystem:GetRootNode():addChild(self.mRootNode)

	self.mIsLoaded = true
	-- 初始化布局相关
	self:InitLayout(event)

	-- 初始化活动项
	self:initActivityItems()

	cclog("=====MailWindow:Load=====end")
end

function ActivityWindow:initActivityItems()
	for i = 1, 3 do
		self.mActivityList[i] = ActivityItem:new()
		self.mActivityList[i]:init(i, handler(self,self.onItemClicked))
		self.mActivityWidget:pushBackCustomItem(self.mActivityList[i]:getRootNode())
	end

	-- 默认第一项
	self:onItemClicked(self.mActivityWidget:getChildren()[1],false)
end

function ActivityWindow:onItemClicked(widget,bSound)
	if bSound == nil then  GUISystem:playSound("tabPageSound") end

	if self.mLastClickedWidget == widget then
		return
	end

	-- 设置选中状态
	if self.mLastClickedWidget then
		self.mActivityList[self.mLastClickedWidget:getTag()]:setSelected(false)
	end
	self.mActivityList[widget:getTag()]:setSelected(true)
	self.mLastClickedWidget = widget
	-- 显示活动信息
	self:updateActivityInfo()
end

function ActivityWindow:updateActivityInfo()
	local id = self.mLastClickedWidget:getTag()
	local info = DB_Activity.getDataById(id)
	-- 名称
	local nameId = info.name
	local name = getDictionaryText(nameId)
	self.mRootWidget:getChildByName("Label_ActivityName"):setString(name)
	-- 大图
	local bigImgId = info.picture
	local bigImgName = DB_ResourceList.getDataById(bigImgId).Res_path1
	self.mRootWidget:getChildByName("Image_Pic"):loadTexture(bigImgName)
	-- 描述
	local descId = info.description
	local desc = getDictionaryText(descId)
	self.mRootWidget:getChildByName("Label_ActivityDesc"):setString(desc)
	-- 奖励
	for i = 1, 3 do
		self.mRootWidget:getChildByName("Panel_Reward"..i):removeAllChildren()
	end

	-- 奖励1
	local item1 = extern_string_split_(info.reward1,',')

	if item1 then
		--local widget1 = createItemWidget(tonumber(item1[3]),tonumber(item1[4]))
		--local imgName = DB_ResourceList.getDataById(tonumber(item1[1])).Res_path1
		--widget1:getChildByName("Image_Item"):loadTexture(imgName, 1)
		local widget1 = createCommonWidget(tonumber(item1[1]),tonumber(item1[2]),tonumber(item1[3]))
		--MessageBox:setTouchShowInfo(widget1,tonumber(item1[1]),tonumber(item1[2]))
		self.mRootWidget:getChildByName("Panel_Reward1"):addChild(widget1)
	end

	-- 奖励2
	local item2 = extern_string_split_(info.reward2,',')
	if item2 then
		--local widget2 = createItemWidget(tonumber(item2[3]),tonumber(item2[4]))
		--local imgName = DB_ResourceList.getDataById(tonumber(item2[1])).Res_path1
		--widget2:getChildByName("Image_Item"):loadTexture(imgName, 1)
		local widget2 = createCommonWidget(tonumber(item2[1]),tonumber(item2[2]),tonumber(item2[3]))
		--MessageBox:setTouchShowInfo(widget2,tonumber(item2[1]),tonumber(item2[2]))
		self.mRootWidget:getChildByName("Panel_Reward2"):addChild(widget2)
	end

	-- 奖励3
	local item3 = extern_string_split_(info.reward3,',')
	if item3 then
		--local widget3 = createItemWidget(tonumber(item2[3]),tonumber(item2[4]))
		--local imgName = DB_ResourceList.getDataById(tonumber(item3[1])).Res_path1
		--widget3:getChildByName("Image_Item"):loadTexture(imgName, 1)
		local widget3 = createCommonWidget(tonumber(item3[1]),tonumber(item3[2]),tonumber(item3[3]))
		--MessageBox:setTouchShowInfo(widget3,tonumber(item3[1]),tonumber(item3[2]))
		self.mRootWidget:getChildByName("Panel_Reward3"):addChild(widget3)
	end
end

function ActivityWindow:requestEnterActivity()
	GUISystem:playSound("homeBtnSound")
	EventSystem:PushEvent(Event.GUISYSTEM_HIDE_HOMEWINDOW)
	local tag = self.mLastClickedWidget:getTag()
	if 0 == tag then
		--GUISystem:goTo("dagong")
		__IsEnterWorkWindow__ = true
	elseif 1 == tag then
		GUISystem:goTo("tower")
		__IsEnterTowerWindow__ = true
	elseif 2 == tag then
		GUISystem:goTo("yuehui")
		__IsEnterFuckWindow__ = true
	elseif 3 == tag then
		EventSystem:PushEvent(Event.GUISYSTEM_SHOW_WEALTHWINDOW)
		__IsEnterWealthWindow__ = true
	end
end

function ActivityWindow:InitLayout(event)
	self.mRootWidget =  GUIWidgetPool:createWidget("ActivitiesMain")
	self.mRootNode:addChild(self.mRootWidget)
	local _tmpEvent = event.mData
	local function closeWindow()
		GUISystem:playSound("homeBtnSound")
		if _tmpEvent ~= nil or IsEnterAnyWindow() then
			local function callFun()
			  EventSystem:PushEvent(Event.GUISYSTEM_HIDE_ACTIVITYWINDOW)
	          showLoadingWindow("HomeWindow")
	          ResetAllWindowVar()
	        end
			FightSystem:sendChangeCity(false,callFun)
		else
			EventSystem:PushEvent(Event.GUISYSTEM_HIDE_ACTIVITYWINDOW)
		end
	end
	self.mTopRoleInfoPanel = TopRoleInfoPanel:new()
	local topInfoPanel = self.mTopRoleInfoPanel:init(self.mRootNode, closeWindow)

	self.mActivityWidget = self.mRootWidget:getChildByName("ListView_List")

	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_Enter"), handler(self, self.requestEnterActivity))
end

function ActivityWindow:Destroy()
	if not self.mIsLoaded then return end
  	self.mIsLoaded = false
	self.mRootNode:removeFromParent(true)
	self.mRootNode = nil
	self.mRootWidget = nil
	self.mLastClickedWidget = nil
	self.mActivityWidget = nil
	self.mActivityList = {}

	self.mTopRoleInfoPanel:destroy()
	self.mTopRoleInfoPanel = nil

	CommonAnimation.clearAllTextures()
end

function ActivityWindow:onEventHandler(event)
	if event.mAction == Event.WINDOW_SHOW then
		if GUISystem:canShow(self.mName) then
			self:Load(event)
		end
	elseif event.mAction == Event.WINDOW_HIDE then
		self:Destroy()
	end
end

return ActivityWindow


