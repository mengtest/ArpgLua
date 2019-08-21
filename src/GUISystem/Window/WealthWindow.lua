-- Name: 	WealthWindow
-- Func：	放课时间
-- Author:	lichuan
-- Data:	15-8-19


MONEY_MONSTER_ID	  =  836
SUSHI_MONSTER_ID	  =  568
STONE_MONSTER_ID	  =  840

local rewardArr = {
					{{0,20273,1},{0,20274,1},{0,20275,1},{0,20276,1},},
					{{0,20011,1},{0,20012,1},{0,20013,1},{0,20014,1},},
					{{0,20511,1},{0,20512,1},{0,20513,1},},
}

local WMInstance = nil

WealthModel = class("WealthModel")

function WealthModel:ctor()
	self.mName 		        = "WealthModel"
	self.mOwner             = nil
	self.mWealthInfo		= {{},{},{}}
	self.mHeroArr			= {}
	self.mWinData           = nil
	self:registerNetEvent()
end

function WealthModel:deinit()
	self.mName 		 = nil
	self.mOwner		 = nil
	self.mWealthInfo = {{},{},{}}
	self.mHeroArr    = {}
	self:unRegisterNetEvent()
end

function WealthModel:getInstance()
	if WMInstance == nil then  
        WMInstance = WealthModel.new()
    end  
    return WMInstance
end

function WealthModel:destroyInstance()
	if WMInstance then
		WMInstance:deinit()
    	WMInstance = nil
    end
end

function WealthModel:registerNetEvent()
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_REQUEST_WEALTH_INFO_, handler(self, self.onWealthInfoResponse))
end

function WealthModel:unRegisterNetEvent()
	NetSystem.mNetManager:UnregisterPacketHandler(PacketTyper._PTYPE_SC_REQUEST_WEALTH_INFO_)
end

function WealthModel:setOwner(owner)
	self.mOwner = owner
end

function WealthModel:doLoadWealthInfoRequest()
	local packet = NetSystem.mNetManager:GetSPacket()
    packet:SetType(PacketTyper._PTYPE_CS_REQUEST_WEALTH_INFO_)
    packet:Send()
    GUISystem:showLoading()
end

function WealthModel:onWealthInfoResponse(msgPacket)
	local typeCnt = msgPacket:GetChar()
	for i=1,typeCnt do
		local typ 		 = msgPacket:GetChar()
		local energyCost = msgPacket:GetChar()
		local leftCnt    = msgPacket:GetChar()
		if typ == WEALTHTYPE.MONEY then
			globaldata.wealthMoneyLeftCnt = leftCnt
		elseif typ == WEALTHTYPE.SUSHI then
			globaldata.wealthSushiLeftCnt = leftCnt
		elseif typ == WEALTHTYPE.STONE then
			globaldata.wealthStoneLeftCnt = leftCnt
		end
		local maxCnt 	 = msgPacket:GetChar()
		self.mWealthInfo[typ]  = {energyCost,leftCnt,maxCnt}
	end

	local heroCnt = msgPacket:GetUShort()

	for i=1,heroCnt do
		self.mHeroArr[i] = msgPacket:GetInt()
	end

	GUISystem:hideLoading()

	Event.GUISYSTEM_SHOW_WEALTHWINDOW.mData = self.mWinData

	if self.mWinData ~= nil and self.mWinData[2] ~= nil then     --for offline exit
		self.mWinData[2]()
	end

	EventSystem:PushEvent(Event.GUISYSTEM_SHOW_WEALTHWINDOW)
end

function WealthModel:doBattleRequest(typ,level,heros)
	globaldata.clickedlevel   = level
	globaldata.wealthType 	  = typ
	globaldata:doWealthBattleRequest(heros)
end

--==================================================================window begin==================================================================================================

local WealthWindow = 
{
	mName 				= "WealthWindow",
	mRootNode			=	nil,	
	mRootWidget 		= 	nil,
	mTopRoleInfoPanel	=	nil,	-- 顶部人物信息面板
	mWealthArr			=   {},
	mModel				=   nil,
	mWealthType			=   nil,
	mEventData			=   nil,
	mSpineArr			=   {},
	mNpcPanel			=   {},
	mAnimArr			=   {},

	mCurSel   			=   1,
}

function WealthWindow:Load(event)
	cclog("=====WealthWindow:Load=====begin")
	self.mRootNode = cc.Node:create()
	GUISystem:GetRootNode():addChild(self.mRootNode)

	self.mEventData    = event.mData
	self.mModel = WealthModel:getInstance()
	self.mModel:setOwner(self)

	self:InitLayout(event)

	local function doFuckTimeGuideOne_Step2()
		local guideBtn = self.mRootWidget:getChildByName("Panel_EXP")
		local size = guideBtn:getContentSize()
		local pos = guideBtn:getWorldPosition()
		local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
		FuckTimeGuideOne:step(2, touchRect)
	end
	FuckTimeGuideOne:step(1, nil, doFuckTimeGuideOne_Step2)
	
	cclog("=====WealthWindow:Load=====end")
end

function WealthWindow:InitLayout(event)

	if self.mRootWidget == nil then
		self.mRootWidget = GUIWidgetPool:createWidget("WealthMountain")
   		self.mRootNode:addChild(self.mRootWidget)
   	end

   	self.mRootWidget:getChildByName("Panel_Main"):setVisible(true)

    if self.mTopRoleInfoPanel == nil then
    	cclog("WealthWindow mTopRoleInfoPanel init") 
		self.mTopRoleInfoPanel = TopRoleInfoPanel:new()
		local topInfoPanel = self.mTopRoleInfoPanel:init(self.mRootNode,ROLE_TITLE_TYPE.TITLE_WEALTH, 
		function()
			GUISystem:playSound("homeBtnSound")
			if self.mEventData and self.mEventData[1] ~= nil then			
			   	--GUISystem:goTo("activity",tmpEventData)
			   	local function callFun()
				  EventSystem:PushEvent(Event.GUISYSTEM_HIDE_WEALTHWINDOW)
		          showLoadingWindow("HomeWindow")
		        end
				FightSystem:sendChangeCity(false,callFun)
			else
				EventSystem:PushEvent(Event.GUISYSTEM_HIDE_WEALTHWINDOW)
			end
		end)
	else
		self.mTopRoleInfoPanel:resetExitBtnCallFunc(
		function()
			GUISystem:playSound("homeBtnSound")		
		   	if self.mEventData and self.mEventData[1] ~= nil then			
		   	--GUISystem:goTo("activity",tmpEventData)
		   		local function callFun()
			 	 	EventSystem:PushEvent(Event.GUISYSTEM_HIDE_WEALTHWINDOW)
	          		showLoadingWindow("HomeWindow")
	        	end
				FightSystem:sendChangeCity(false,callFun)
			else
				EventSystem:PushEvent(Event.GUISYSTEM_HIDE_WEALTHWINDOW)
			end
		end) 
	end

	local idArr =  {MONEY_MONSTER_ID,SUSHI_MONSTER_ID,STONE_MONSTER_ID}

	self.mWealthArr[WEALTHTYPE.MONEY] = self.mRootWidget:getChildByName("Panel_Money")
	local desData1 = DB_Text.getDataById(WEALTHTYPE.MONEY + 235)
	local desStr1  = desData1.Text_CN
	self.mWealthArr[WEALTHTYPE.MONEY]:getChildByName("Label_Description"):setString(desStr1)
	self.mWealthArr[WEALTHTYPE.MONEY]:getChildByName("Label_LastTimes"):setString(string.format("剩余次数 %d / %d",self.mModel.mWealthInfo[WEALTHTYPE.MONEY][2],self.mModel.mWealthInfo[WEALTHTYPE.MONEY][3]))

	self.mWealthArr[WEALTHTYPE.SUSHI] = self.mRootWidget:getChildByName("Panel_EXP")
	local desData2 = DB_Text.getDataById(WEALTHTYPE.SUSHI + 235)
	local desStr2  = desData2.Text_CN
	self.mWealthArr[WEALTHTYPE.SUSHI]:getChildByName("Label_Description"):setString(desStr2)
	self.mWealthArr[WEALTHTYPE.SUSHI]:getChildByName("Label_LastTimes"):setString(string.format("剩余次数 %d / %d",self.mModel.mWealthInfo[WEALTHTYPE.SUSHI][2],self.mModel.mWealthInfo[WEALTHTYPE.SUSHI][3]))

	self.mWealthArr[WEALTHTYPE.STONE] = self.mRootWidget:getChildByName("Panel_Stone")
	local desData3 = DB_Text.getDataById(WEALTHTYPE.STONE + 235)
	local desStr3  = desData3.Text_CN
	self.mWealthArr[WEALTHTYPE.STONE]:getChildByName("Label_Description"):setString(desStr3)

	if globaldata.level < 30 then
		self.mWealthArr[WEALTHTYPE.STONE]:getChildByName("Label_LastTimes"):setString("30级开放")
	else
		self.mWealthArr[WEALTHTYPE.STONE]:getChildByName("Label_LastTimes"):setString(string.format("剩余次数 %d / %d",self.mModel.mWealthInfo[WEALTHTYPE.STONE][2],self.mModel.mWealthInfo[WEALTHTYPE.STONE][3]))
	end

	for i=1,#self.mWealthArr do
		for j=1,4 do
			local rewardPanel = self.mWealthArr[i]:getChildByName(string.format("Panel_Reward_%d",j))
			rewardPanel:setVisible(false)
			rewardPanel:removeAllChildren()

			if i == 3 and j > 3 then break end 

			local rewardWidget = createCommonWidget(rewardArr[i][j][1],rewardArr[i][j][2],rewardArr[i][j][3])
			rewardPanel:setVisible(true)
			rewardPanel:addChild(rewardWidget)
		end
	end

	for i=1,#self.mWealthArr do
		self.mNpcPanel[i] = self.mWealthArr[i]:getChildByName("Panel_NPC")
		self.mWealthArr[i]:setTag(i)
		registerWidgetReleaseUpEvent(self.mWealthArr[i],function(widget)
			if widget:getTag() == WEALTHTYPE.STONE and globaldata.level < 30 then
				MessageBox:showMessageBox1("功能未开放！")
			else
				self:ShowDifficultyInfo(widget:getTag())
			end
		end)
	end
end

function WealthWindow:ShowDifficultyInfo(typ)

	local function doFuckTimeGuideOne_Stop()
		FuckTimeGuideOne:stop()
	end
	FuckTimeGuideOne:step(3, nil, doFuckTimeGuideOne_Stop)

	local panelSelectDiff = GUIWidgetPool:createWidget("WealthMountain_Chosen")
	local topSize         = self.mTopRoleInfoPanel.mTopWidget:getContentSize()
	local y               = getGoldFightPosition_Middle().y
	local x               = getGoldFightPosition_Middle().x
	local limitData       = DB_AfterClass.getDataById(typ)
	local limits          = limitData.AfterClass_Difficulty

	self.mRootNode:addChild(panelSelectDiff,1000) 

	panelSelectDiff:getChildByName("Panel_Window"):setAnchorPoint(0.5,0.5)
	panelSelectDiff:getChildByName("Panel_Window"):setPosition(cc.p(x,y))
	panelSelectDiff:getChildByName("Label_TiliCost"):setString(tostring(self.mModel.mWealthInfo[typ][1])) -- 把2改成1  by wangsd 2015-11-26
	panelSelectDiff:getChildByName("Label_LastTimes"):setString(string.format("%d / %d",self.mModel.mWealthInfo[typ][2],self.mModel.mWealthInfo[typ][3]))

	registerWidgetReleaseUpEvent(panelSelectDiff:getChildByName("Button_Close"),function()
		panelSelectDiff:removeFromParent(true)
		panelSelectDiff = nil
	end)


	local diffcultyBtnArr = {}
	local diffculty       = nil
	local lstWidget       = nil 

	local function OnSelectDiffculty(widget)
		--if globaldata.level < limits[widget:getTag()] then MessageBox:showMessageBox1("玩家等级不足！！！") return end
		if lstWidget then lstWidget:getChildByName("Image_Chosen"):setVisible(false)end
		widget:getChildByName("Image_Chosen"):setVisible(true)

		diffculty    = widget:getTag()
		lstWidget    = widget
		self.mCurSel = diffculty

		local rewardData   = DB_SpecialMap.getDataById(typ * 100 + diffculty)
		local rewardArr    = {}
		rewardArr[1] = rewardData.SpecialMap_EasyDrop1
		rewardArr[2] = rewardData.SpecialMap_EasyDrop2
		rewardArr[3] = rewardData.SpecialMap_EasyDrop3
		rewardArr[4] = rewardData.SpecialMap_EasyDrop4
		

		for i=1,#rewardArr do
			local rewardPanel = panelSelectDiff:getChildByName(string.format("Panel_Reward_%d",i))
			rewardPanel:removeAllChildren()
			if rewardArr[i] ~= -1 then
				local itemWidget = createCommonWidget(rewardArr[i][1],rewardArr[i][2],rewardArr[i][3])
				rewardPanel:addChild(itemWidget)
			end
		end	
	end

	registerWidgetReleaseUpEvent(panelSelectDiff:getChildByName("Button_Fight"),
	function() 
		ShowRoleSelWindow(self,function(tye,diff,heros) self.mModel:doBattleRequest(tye,diff,heros) end,
		self.mModel.mHeroArr,SELECTHERO.SHOWSELF,typ,diffculty,limitData.AfterClass_Power[diffculty]) 
	end)
	 
	for i=1,5 do
		diffcultyBtnArr[i] = panelSelectDiff:getChildByName(string.format("Image_Difficulty_%d",i))
		diffcultyBtnArr[i]:setTag(i)
		diffcultyBtnArr[i]:getChildByName("Label_Power_Stroke"):setString(limitData.AfterClass_Power[i])
		registerWidgetReleaseUpEvent(diffcultyBtnArr[i],OnSelectDiffculty)
	end

	OnSelectDiffculty(diffcultyBtnArr[self.mCurSel])
end

function WealthWindow:Destroy()
	for i=1,#self.mNpcPanel do
		self.mNpcPanel[i]   = nil
	end	
	self.mNpcPanel = {}

	for i=1,#self.mSpineArr do
		SpineDataCacheManager:collectFightSpineByAtlas(self.mSpineArr[i])
		self.mSpineArr[i] = nil
	end

	if self.mTopRoleInfoPanel ~= nil then
		self.mTopRoleInfoPanel:destroy()
		self.mTopRoleInfoPanel = nil
	end

	self.mModel:destroyInstance()

	self.mCurSel   		   = 1
	self.mWealthArr		   = {}

    self.mEventData = nil

    self.mRootWidget = nil
    
	if self.mRootNode then
		self.mRootNode:removeFromParent(true)
		self.mRootNode = nil
	end
	----------------
	CommonAnimation.clearAllTextures()
end

function WealthWindow:DisableDraw()
	if self.mRootWidget then
		self.mRootWidget:setVisible(false)
	end
end

function WealthWindow:EnableDraw()
	if self.mRootWidget then
		self.mRootWidget:setVisible(true)
	end
end

function WealthWindow:onEventHandler(event)
	if event.mAction == Event.WINDOW_SHOW then
		self:Load(event)
		---------停止画主城镇界面
		EventSystem:PushEvent(Event.GUISYSTEM_DISABLEDRAW_HOMEWINDOW)
		---------
		NoticeSystem:doSingleUpdate(self.mName)
	elseif event.mAction == Event.WINDOW_HIDE then
		self:Destroy()
		---------开启画主城镇界面
		EventSystem:PushEvent(Event.GUISYSTEM_EABLEDRAW_HOMEWINDOW)
		---------
	elseif event.mAction == Event.WINDOW_ENABLE_DRAW then
		self:EnableDraw()
	elseif event.mAction == Event.WINDOW_DISABLE_DRAW then
		self:DisableDraw()
	end
end

return WealthWindow