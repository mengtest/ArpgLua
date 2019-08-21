-- Name: 	DateWindow
-- Func：	伙伴窗口
-- Author:	WangShengdong
-- Data:	15-2-2

require("GUISystem/Window/DateModel")

local eventCount = 6

local DateWindow = 
{
	mName				=	"DateWindow",
	mRootNode			=	nil,
	mRootWidget			=	nil,
	mTopRoleInfoPanel	=	nil,	-- 顶部人物信息面板
	mMainWindow			=	nil,	-- 主窗口
	mSelectWindow		=	nil,	-- 选择窗口
	mPlayerWindow 		=	nil, 	-- 玩家窗口
	mHeroWindow 		=	nil,    -- 英雄窗口
	mDateLayerArr		=   {},

	mModel				=   nil,
	mSelectHeroId       =   nil,
	mCurSelDateId       =   nil,
}

function DateWindow:Release()

end

function DateWindow:Load(Event)
	cclog("=====DateWindow:Load=====begin")

	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_REQUEST_FAVOR_ALLHERO_, handler(self, self.onShowHeroWindow))

	self.mRootNode = cc.Node:create()
	GUISystem:GetRootNode():addChild(self.mRootNode)

	self.mModel = DateModel.new(self)
	self:InitLayout()

	cclog("=====DateWindow:Load=====end")
end

function DateWindow:InitLayout()
	self.mRootWidget = GUIWidgetPool:createWidget("DateWindow")
	self.mRootNode:addChild(self.mRootWidget)

	local function closeWindow()
		GUISystem:playSound("homeBtnSound")
		EventSystem:PushEvent(Event.GUISYSTEM_HIDE_DATEWINDOW)
	end

	self.mTopRoleInfoPanel = TopRoleInfoPanel:new()
	local topInfoPanel = self.mTopRoleInfoPanel:init(self.mRootNode, closeWindow)

	self.mMainWindow = self.mRootWidget:getChildByName("Panel_FirstWindow")

	self.mPlayerWindow = self.mRootWidget:getChildByName("Panel_PlayerLevel")
	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_Level"), function() GUISystem:playSound("homeBtnSound") self.mPlayerWindow:setVisible(true);self.mPlayerWindow:setTouchEnabled(true) end)
	registerWidgetReleaseUpEvent(self.mPlayerWindow:getChildByName("Button_Close"), function() GUISystem:playSound("homeBtnSound") self.mPlayerWindow:setVisible(false);self.mPlayerWindow:setTouchEnabled(false) end)
	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_Rule"), function() 
		GUISystem:playSound("homeBtnSound") 
		EventSystem:PushEvent(Event.GUISYSTEM_SHOW_GAME2048WINDOW) end)

	local function showHeroWindow()
		local packet = NetSystem.mNetManager:GetSPacket()
    	packet:SetType(PacketTyper._PTYPE_CS_REQUEST_FAVOR_ALLHERO_)
    	packet:Send()
	end
	--registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_MyFriends"), showHeroWindow)

	self.mHeroWindow = self.mRootWidget:getChildByName("Panel_HeroLevel")

	self:InitTouch()

	self.mModel:doDateInfoRequest()
	self.mModel:doPlayerFavorRequest()
end

function DateWindow:InitTouch()
	local touchLayer = self.mRootWidget:getChildByName("Panel_Scene")
	--touchLayer:setTouchSwallowed(false)
	touchLayer:setTouchEnabled(false)

	FightSystem.mShowSceneManager:LoadSceneView(1,touchLayer , 17)
	FightSystem.mShowSceneManager.mSceneView:setPositionY(-getGoldFightPosition_LD().y)

	local lastPos = cc.p(0,0)

	local function onTouchMoved(touch, event)
		debugLog("=====onTouchMoved=====")

		local curPos = touch:getLocation()
		local distanceX = curPos.x - lastPos.x

		if distanceX <= 0 then
			local _disX = math.abs(distanceX)
			local  mPosTiled =  math.abs(FightSystem.mShowSceneManager:GetWallGround():getPositionX())

			local endPos = nil if #self.mModel.mDateInfoArr == 4 then endPos = 1140+400 else endPos = 1140*2 end

    		if  _disX + mPosTiled + getGoldFightScreenWidth() >= endPos then
       	  		 _disX = math.abs(endPos - mPosTiled- getGoldFightScreenWidth())
    		end
			FightSystem.mShowSceneManager.mSceneView:MoveAllLayersLeft(math.abs(_disX))
		else
			--doError(math.abs(FightSystem.mShowSceneManager:GetWallGround():getPositionX()))
			local _disX = distanceX
			local  mPosTiled = math.abs(FightSystem.mShowSceneManager:GetWallGround():getPositionX())
	    	if  math.abs(mPosTiled) - math.abs(distanceX) <= 0 then
	       		_disX = math.abs( 0 - mPosTiled)
	    	end
			FightSystem.mShowSceneManager.mSceneView:MoveAllLayersRight(_disX)
		end

		lastPos = touch:getLocation()
 	end

    local function onTouchBegan(touch, event)
    	debugLog("=====onTouchBegan=====")
    	lastPos = touch:getLocation()
        return true
    end

	local function onTouchEnded(touch, event)
	  	debugLog("=====onTouchEnded=====")
	    lastPos = cc.p(0,0)
	end

	local function onTouchCancelled(touch, event)
	  debugLog("=====onTouchCancelled======")
	end

	-- register touch event
	local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    listener:registerScriptHandler(onTouchCancelled,cc.Handler.EVENT_TOUCH_CANCELLED )

    local eventDispatcher = touchLayer:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, touchLayer)
end

function DateWindow:onShowHeroWindow(msgPacket)
	globaldata:updateHeroFavorInfoFromServerPacket(msgPacket)
	EventSystem:PushEvent(Event.GUISYSTEM_SHOW_DATEHEROWINDOW)
end

function DateWindow:UpdatePlayFavorInfo()
	self.mMainWindow:getChildByName("Label_PlayerFavor"):setString(string.format("%d/%d",self.mModel.mFavorValue,self.mModel.mFavorMaxVal))
	self.mMainWindow:getChildByName("ProgressBar_Playerfavor"):setPercent(self.mModel.mFavorValue / self.mModel.mFavorMaxVal * 100)
	self.mMainWindow:getChildByName("Image_HeartLeft"):getChildByName("Label_Level"):setString(tostring(self.mModel.mFavorLv))
	self.mMainWindow:getChildByName("Image_HeartRight"):getChildByName("Label_Level"):setString(tostring(self.mModel.mFavorLv + 1))

	-- 显示值、级别信息
	self.mPlayerWindow:getChildByName("Label_Explain"):setString(string.format("当前个人总好感度%d，阵容加成%d级",self.mModel.mFavorValue,self.mModel.mFavorLv))
	self.mPlayerWindow:getChildByName("Image_LevelL"):getChildByName("Label_Level"):setString(tostring(self.mModel.mFavorLv))
	self.mPlayerWindow:getChildByName("Image_LevelR"):getChildByName("Label_Level"):setString(tostring(self.mModel.mFavorLv + 1))

	-- 显示属性信息
	for i = 1, 8 do
		local labelWidget = self.mPlayerWindow:getChildByName("Label_Property"..tostring(i))
		labelWidget:setString(globaldata:getTypeString(i-1))
		local propInfo = self.mModel.mPropList[i-1]
		labelWidget:getChildByName("Label_Value1"):setString("+"..tostring(propInfo:getKeyValue("curValue")))
		labelWidget:getChildByName("Label_Value2"):setString("+"..tostring(propInfo:getKeyValue("nextValue")))
	end
end

function DateWindow:InitDateEventPanels()
	local posArr = {cc.p(135,180), cc.p(485,368),cc.p(740,220),cc.p(1060,425),cc.p(1400,270),cc.p(1759,325),}
	local widget = GUIWidgetPool:createWidget("DateEvent")
	local contentSize = widget:getContentSize()

	for i=1,6 do
		self.mDateLayerArr[i] = cc.Layer:create()
		self.mDateLayerArr[i]:setContentSize(contentSize)
		self.mDateLayerArr[i]:setTouchEnabled(false)
		self.mDateLayerArr[i]:setPosition(posArr[i])

		FightSystem.mShowSceneManager:GetWallGround():addChild(self.mDateLayerArr[i])
	end

	local index = 1

	local function eventItemAnimation(widgetArr)
		local function scaleBegin()
			widgetArr[1]:setVisible(true)
		end

		print("eventItemAnimation")

		local function scaleEnd()
			table.remove(widgetArr,1)
			if #widgetArr ~= 0 then
			 	eventItemAnimation(widgetArr) 
			 else 
			 	return 
			 end
		end

		local animBegin = cc.CallFunc:create(scaleBegin)
		local animBig   = cc.ScaleTo:create(0.1,1.1)
		local animSmall = cc.ScaleTo:create(0.1,1)
		local animEnd   = cc.CallFunc:create(scaleEnd)

		widgetArr[1]:runAction(cc.Sequence:create(animBegin,animBig,animSmall,animEnd))
	end

	local eventWidgetArr = {}

	for i = 1, #self.mModel.mDateInfoArr do -- 开放的
		if 0 == self.mModel.mDateInfoArr[i].dateOpen then
			local eventWidget = createDateEventItem(self.mModel.mDateInfoArr[i])
			
			registerWidgetReleaseUpEvent(eventWidget:getChildByName("Button_Bg"), 
			function(widget) 
			GUISystem:playSound("homeBtnSound")
			self.mCurSelDateId = widget:getTag()
			self.mModel:doEntryInfoRequest(widget:getTag()) 
			end)

			table.insert(eventWidgetArr,eventWidget)
			self.mDateLayerArr[index]:addChild(eventWidget)

			index = index + 1
		end
	end

	for i = 1, #self.mModel.mDateInfoArr do -- 未开放的
		if 1 == self.mModel.mDateInfoArr[i].dateOpen then
			local eventWidget = createDateEventItem(self.mModel.mDateInfoArr[i])
 
			registerWidgetReleaseUpEvent(eventWidget:getChildByName("Button_Bg"), function(widget) GUISystem:playSound("homeBtnSound") MessageBox:showMessageBox1("活动未开放！ ") end)

			table.insert(eventWidgetArr,eventWidget)

			self.mDateLayerArr[index]:addChild(eventWidget)
			
			index = index + 1
		end
	end

	eventItemAnimation(eventWidgetArr)
end

function DateWindow:ShowSelectPanel(dataId)	
	local dateInfo     = DB_EventTotal.getDataById(dataId)
	local dateNameId   = dateInfo.Event_TotalText
	local dateNameData = DB_ResourceList.getDataById(dateNameId)
	local dateImgName  = dateNameData.Res_path1

	local panel = self.mRootWidget:getChildByName("Panel_SelectHero")
	panel:getChildByName("Image_DateName"):loadTexture(dateImgName)
	panel:setVisible(true)
	panel:setTouchEnabled(true)

	registerWidgetReleaseUpEvent(panel:getChildByName("Button_50"),function () 
		GUISystem:playSound("homeBtnSound") 
		panel:setVisible(false)
		panel:setTouchEnabled(false)
		self.mSelectHeroId = nil end)
	registerWidgetReleaseUpEvent(panel:getChildByName("Button_Refresh"), function() GUISystem:playSound("homeBtnSound") self.mModel:doRefreshEntryInfoRequest() end)

	local favorLv      = 0
	local favorExp 	   = 0
	local favorMaxExp  = 0

	local function OnPressBtnStart(widget)
		GUISystem:playSound("homeBtnSound")
		if self.mModel.mDateEntryInfo.eventType == 1 then 
			if self.mSelectHeroId == nil then 
				MessageBox:showMessageBox1("请选择约会对象")
				return
			end
			Event.GUISYSTEM_SHOW_DATEPLAYWINDOW.mData = {self.mModel.mDateEntryInfo.eventId,self.mModel.mDateEntryInfo.eventType,self.mSelectHeroId,favorLv,favorExp,favorMaxExp}
		else
			Event.GUISYSTEM_SHOW_DATEPLAYWINDOW.mData = {self.mModel.mDateEntryInfo.eventId,self.mModel.mDateEntryInfo.eventType,self.mSelectHeroId,favorLv,favorExp,favorMaxExp}
		end
		self.mSelectHeroId = nil
		EventSystem:PushEvent(Event.GUISYSTEM_SHOW_DATEPLAYWINDOW)
		panel:setVisible(false)
	end

	registerWidgetReleaseUpEvent(panel:getChildByName("Button_Start"), OnPressBtnStart)

	panel:getChildByName("Label_LastTimes"):setString(string.format("今日剩余次数 %d/%d",self.mModel.mDateEntryInfo.freshCnt, self.mModel.mDateEntryInfo.freshMaxCnt))

	local widgetArr = {}

	for i = 1, 3 do
		self.mRootWidget:getChildByName("Panel_SelectHero"):getChildByName("Panel_Hero"..tostring(i)):removeAllChildren()
	end

	local function OnClickeDateObjectItem(widget)
		self.mSelectHeroId = widget:getTag()

		widget:getChildByName("Image_Bg"):loadTexture("date_hero_bg2.png")
		for i=1,#widgetArr do
			if widgetArr[i] ~= widget then 
				widgetArr[i]:getChildByName("Image_Bg"):loadTexture("date_hero_bg1.png")
			else
				local entryInfo = self.mModel.mDateEntryInfo.heroIdArr[i]
				favorLv      = entryInfo.favorLv
				favorExp 	 = entryInfo.favorExp
				favorMaxExp  = entryInfo.favorMaxExp
			end
		end
	end

	if 1 == self.mModel.mDateEntryInfo.eventType then 		--个人
		self.mRootWidget:getChildByName("Panel_School"):setVisible(false)
		for i = 1, 3 do
			local entryInfo = self.mModel.mDateEntryInfo.heroIdArr[i]
			local widget = createDateObjectItem(entryInfo.objectId,entryInfo.favorLv,entryInfo.favorExp,entryInfo.favorMaxExp,self.mModel.mDateEntryInfo.eventType)
			self.mRootWidget:getChildByName("Panel_SelectHero"):getChildByName("Panel_Hero"..tostring(i)):addChild(widget)
			registerWidgetReleaseUpEvent(widget, OnClickeDateObjectItem)
			widget:setTag(self.mModel.mDateEntryInfo.heroIdArr[i].objectId)
			widgetArr[i] = widget
		end
	elseif 2 == self.mModel.mDateEntryInfo.eventType then 	 --学校
		self.mRootWidget:getChildByName("Panel_School"):setVisible(true)

		local entryInfo      = self.mModel.mDateEntryInfo.heroIdArr[1]
		local objectId	     = self.mModel.mDateEntryInfo.heroIdArr[1].objectId

		local objectData     = DB_EventObject.getDataById(objectId)
		local objectNameId   = objectData.Event_ObjectName
		local objectName     = getDictionaryText(objectNameId)
		local objectPicUrlID = objectData.Event_ObjectBust
		local objectData     = DB_ResourceList.getDataById(objectPicUrlID)
		local objectPicUrl   = objectData.Res_path1

		self.mSelectHeroId   = objectId

		self.mRootWidget:getChildByName("Label_SchoolName"):setString(objectName)
		self.mRootWidget:getChildByName("Image_School"):loadTexture(objectPicUrl)
	end
end

function DateWindow:Destroy()
	FightSystem.mShowSceneManager:UnloadSceneView()
	self.mRootNode:removeFromParent(true)
	self.mRootNode         = nil
	self.mRootWidget       = nil
	self.mTopRoleInfoPanel:destroy()
	self.mTopRoleInfoPanel = nil

	self.mDateLayerArr     = {}
	self.mData             = nil

	self.mModel:deinit()
	self.mModel            = nil
	self.mSelectHeroId     = nil

	self.mCurSelDateId     = nil
	
	CommonAnimation:clearAllTextures()
	cclog("=====DateWindow:Destroy=====")
end

function DateWindow:onEventHandler(event)
	if event.mAction == Event.WINDOW_SHOW then
		self:Load(event)
	elseif event.mAction == Event.WINDOW_HIDE then
		self:Destroy()
	end
end

return DateWindow