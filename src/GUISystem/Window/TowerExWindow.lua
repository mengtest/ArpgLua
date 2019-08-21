-- Name: 	TowerExWindow
-- Func：	闯关界面
-- Author:	lichuan
-- Data:	15-4-30

local gradeStrings = {"幼稚园一年1班","幼稚园一年2班","幼稚园一年3班","幼稚园一年4班","幼稚园一年5班","幼稚园一年6班","幼稚园一年7班","幼稚园一年8班","幼稚园一年9班","幼稚园一年10班",
					"幼稚园二年1班","幼稚园二年2班","幼稚园二年3班","幼稚园二年4班","幼稚园二年5班","幼稚园二年6班","幼稚园二年7班","幼稚园二年8班","幼稚园二年9班","幼稚园二年10班",
					"幼稚园三年1班","幼稚园三年2班","幼稚园三年3班","幼稚园三年4班","幼稚园三年5班","幼稚园三年6班","幼稚园三年7班","幼稚园三年8班","幼稚园三年9班","幼稚园三年10班",
					"国小一年1班","国小一年2班","国小一年3班","国小一年4班","国小一年5班","国小一年6班","国小一年7班","国小一年8班","国小一年9班","国小一年10班",
					"国小二年1班","国小二年2班","国小二年3班","国小二年4班","国小二年5班","国小二年6班","国小二年7班","国小二年8班","国小二年9班","国小二年10班",
					"国小三年1班","国小三年2班","国小三年3班","国小三年4班","国小三年5班","国小三年6班","国小三年7班","国小三年8班","国小三年9班","国小三年10班",
					"国中一年1班","国中一年2班","国中一年3班","国中一年4班","国中一年5班","国中一年6班","国中一年7班","国中一年8班","国中一年9班","国中一年10班",
					"国中二年1班","国中二年2班","国中二年3班","国中二年4班","国中二年5班","国中二年6班","国中二年7班","国中二年8班","国中二年9班","国中二年10班",
					"国中三年1班","国中三年2班","国中三年3班","国中三年4班","国中三年5班","国中三年6班","国中三年7班","国中三年8班","国中三年9班","国中三年10班",
					"高校一年1班","高校一年2班","高校一年3班","高校一年4班","高校一年5班","高校一年6班","高校一年7班","高校一年8班","高校一年9班","高校一年10班",
					"高校二年1班","高校二年2班","高校二年3班","高校二年4班","高校二年5班","高校二年6班","高校二年7班","高校二年8班","高校二年9班","高校二年10班",
					"高校三年1班","高校三年2班","高校三年3班","高校三年4班","高校三年5班","高校三年6班","高校三年7班","高校三年8班","高校三年9班","高校三年10班",
					"大学一年1班","大学一年2班","大学一年3班","大学一年4班","大学一年5班","大学一年6班","大学一年7班","大学一年8班","大学一年9班","大学一年10班",
					"大学二年1班","大学二年2班","大学二年3班","大学二年4班","大学二年5班","大学二年6班","大学二年7班","大学二年8班","大学二年9班","大学二年10班",
					"大学三年1班","大学三年2班","大学三年3班","大学三年4班","大学三年5班","大学三年6班","大学三年7班","大学三年8班","大学三年9班","大学三年10班",
					"大学四年1班","大学四年2班","大学四年3班","大学四年4班","大学四年5班","大学四年6班","大学四年7班","大学四年8班","大学四年9班","大学四年10班",
					"研究所一年1班","研究所一年2班","研究所一年3班","研究所一年4班","研究所一年5班","研究所一年6班","研究所一年7班","研究所一年8班","研究所一年9班","研究所一年10班",
					"研究所二年1班","研究所二年2班","研究所二年3班","研究所二年4班","研究所二年5班","研究所二年6班","研究所二年7班","研究所二年8班","研究所二年9班","研究所二年10班",
					"研究所三年1班","研究所三年2班","研究所三年3班","研究所三年4班","研究所三年5班","研究所三年6班","研究所三年7班","研究所三年8班","研究所三年9班","研究所三年10班",
					"研究所四年1班","研究所四年2班","研究所四年3班","研究所四年4班","研究所四年5班","研究所四年6班","研究所四年7班","研究所四年8班","研究所四年9班","研究所四年10班",
}

local TMInstance = nil 

TowerExModel = class("TowerExModel")

function TowerExModel:ctor()  
    self.mName 		    = "TowerExModel"
	self.mWinData       = nil 
	self.mCurFloorNum	= nil
	self.mResetCnt		= nil
	self.mLastRecord    = nil

	self.mHeroArr		= {0,0,0}

	self:registerNetEvent()
end

function TowerExModel:deinit()
	self.mName 		    = nil
	self.mOwner			= nil
	self.mWinData       = nil 
	self.mCurFloorNum	= nil
	self.mResetCnt		= nil
	self.mLastRecord    = nil

	self.mHeroArr		= {0,0,0}

	self:unRegisterNetEvent()
end 

function TowerExModel:getInstance()
	if TMInstance == nil then  
        TMInstance = TowerExModel.new()
    end  
    return TMInstance
end

function TowerExModel:destroyInstance()
	if TMInstance then
		TMInstance:deinit()
    	TMInstance = nil
    end
end

function TowerExModel:registerNetEvent()
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_TOWEREX_INFO_RESPONSE, handler(self, self.onLoadTowerExInfoResponse))
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_TOWEREX_RESET_RESPONSE, handler(self, self.onResetTowerExInfoResponse))
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_TOWEREX_GETREWARD_RESPONSE, handler(self, self.onGetRewardResponse))
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_TOWEREX_SWEEP_RESPONSE, handler(self, self.onTowerExSweepResponse))
end

function TowerExModel:unRegisterNetEvent()
	NetSystem.mNetManager:UnregisterPacketHandler(PacketTyper._PTYPE_SC_TOWEREX_INFO_RESPONSE)
	NetSystem.mNetManager:UnregisterPacketHandler(PacketTyper._PTYPE_SC_TOWEREX_RESET_RESPONSE)
	NetSystem.mNetManager:UnregisterPacketHandler(PacketTyper._PTYPE_SC_TOWEREX_GETREWARD_RESPONSE)
	NetSystem.mNetManager:UnregisterPacketHandler(PacketTyper._PTYPE_SC_TOWEREX_SWEEP_RESPONSE)
end

function TowerExModel:setOwner(owner)
	self.mOwner = owner
end

function TowerExModel:doLoadTowerExInfoRequest()
	local packet = NetSystem.mNetManager:GetSPacket()
    packet:SetType(PacketTyper._PTYPE_CS_TOWEREX_INFO_REQUEST)
    packet:Send()
	GUISystem:showLoading()
end

function TowerExModel:onLoadTowerExInfoResponse(msgPacket)
	self.mCurFloorNum     = msgPacket:GetInt()
	self.mResetCnt        = msgPacket:GetInt()
	self.mRewardState 	  = msgPacket:GetChar()
	cclog(string.format("self.mRewardState is %d",self.mRewardState))
	self.mCurFloorNum 	  = self.mCurFloorNum + 1 -- server index from 0

	local heroCnt = msgPacket:GetUShort()
	for i=1,heroCnt do
		self.mHeroArr[i] = msgPacket:GetInt()
	end

	GUISystem:hideLoading()

	Event.GUISYSTEM_SHOW_TOWEREXWINDOW.mData = self.mWinData

	if self.mWinData ~= nil and self.mWinData[2] ~= nil then     --for offline exit
		self.mWinData[2]()
	end

	EventSystem:PushEvent(Event.GUISYSTEM_SHOW_TOWEREXWINDOW)
end

function TowerExModel:doResetTowerExInfoRequest()
	local function OK()
		local packet = NetSystem.mNetManager:GetSPacket()
	    packet:SetType(PacketTyper._PTYPE_CS_TOWEREX_RESET_REQUEST)
	    packet:Send()
		GUISystem:showLoading()
	end

	local function Calcel( ... )
	end

	if self.mCurFloorNum < 2 then
		MessageBox:showMessageBox1("当前闯关为全新进度，无需重置")
		return
	else
		MessageBox:showMessageBox2("重置操作不可撤销，是否放弃本次挑战进度？",OK,Cancel)
	end
end

function TowerExModel:onResetTowerExInfoResponse(msgPacket)
	self.mCurFloorNum     = msgPacket:GetInt()
	self.mResetCnt        = msgPacket:GetInt()
	self.mRewardState     = msgPacket:GetChar()
	self.mCurFloorNum 	  = self.mCurFloorNum + 1 -- server index from 0
	GUISystem:hideLoading()

	if self.mOwner then
		self.mOwner:ClearAllSpine()
		self.mOwner:InitFloors()
	end
end

function TowerExModel:doClimbTowerExRequest(heros)
	globaldata:doTowerExBattleRequest(heros)
end

function TowerExModel:doGetRewardRequest(floorNum)
	local packet = NetSystem.mNetManager:GetSPacket()
    packet:SetType(PacketTyper._PTYPE_CS_TOWEREX_GETREWARD_REQUEST)
    packet:PushInt(floorNum)
    packet:Send()
	GUISystem:showLoading()
end

function TowerExModel:onGetRewardResponse(msgPacket)
	local cnt = msgPacket:GetUShort()
	local itemList = {}
	for i=1,cnt do
		local itemType  = msgPacket:GetInt()
		local itemId    = msgPacket:GetInt()
		local itemCount = msgPacket:GetInt()
		itemList[i] = {itemType, itemId, itemCount}
	end

	self.mRewardState = REWARDSTATE.HAVERECEIVED
	GUISystem:hideLoading()
	MessageBox:showMessageBox_ItemAlreadyGot(itemList)
end

function TowerExModel:doTowerExSweepRequest()
	local packet = NetSystem.mNetManager:GetSPacket()
    packet:SetType(PacketTyper._PTYPE_CS_TOWEREX_SWEEP_REQUEST)
    packet:Send()
	GUISystem:showLoading()
end

function TowerExModel:onTowerExSweepResponse(msgPacket)
	self.mCurFloorNum       = msgPacket:GetInt()
	self.mResetCnt          = msgPacket:GetInt()
	self.mRewardState   = msgPacket:GetChar()
	self.mCurFloorNum 	    = self.mCurFloorNum + 1 -- server index from 0

	local sweepInfos = {}
	local cnt = msgPacket:GetUShort()
	for i = 1,cnt do
		local sweeoInfo     = {}
		sweeoInfo.floorNum  = msgPacket:GetInt()
		sweeoInfo.rewards   = {}
		local rewardCnt  	= msgPacket:GetUShort()
		for j = 1,rewardCnt do
			local itemType  = msgPacket:GetInt()
			local itemId    = msgPacket:GetInt()
			local itemCount = msgPacket:GetInt()
			table.insert(sweeoInfo.rewards,{itemType,itemId,itemCount})
		end

		table.insert(sweepInfos,sweeoInfo)
	end

	local sweeoInfo     = {}
	sweeoInfo.rewards   = {}
	local rewardCnt  	= msgPacket:GetUShort()

	for j = 1,rewardCnt do
		local itemType  = msgPacket:GetInt()
		local itemId    = msgPacket:GetInt()
		local itemCount = msgPacket:GetInt()
		table.insert(sweeoInfo.rewards,{itemType,itemId,itemCount})
	end
	table.insert(sweepInfos,sweeoInfo)

	GUISystem:hideLoading()
	if self.mOwner then
		self.mOwner:ShowSweepReward(sweepInfos)
		self.mOwner:ClearAllSpine()
		self.mOwner:InitFloors()
	end
end

--==========================================================window  begin ==================================================================

local TowerExWindow = 
{
	mName 				= "TowerExWindow",
	mRootNode			=	nil,	
	mRootWidget 		= 	nil,
	mTopRoleInfoPanel	=	nil,	-- 顶部人物信息面板
	mModel				=   nil,

	mStartPoint         = nil,
	mEndPoint           = nil,
	mTower              = nil,
	mFloorSize			= nil,
	mFloorDq 			= nil,
	mSweep 		= false,
}

function TowerExWindow:Load(event)
	cclog("=====TowerExWindow:Load=====begin")

	self.mRootNode = cc.Node:create()
	GUISystem:GetRootNode():addChild(self.mRootNode)
	
	self.mModel = TowerExModel:getInstance()

	self.mModel:setOwner(self)

	self:InitLayout(event)

	local function doGonghuiGuideOne_Stop()
		DayDayUpGuideOne:stop()
	end
	DayDayUpGuideOne:step(1, nil, doGonghuiGuideOne_Stop)

	cclog("=====TowerExWindow:Load=====end")
end

function TowerExWindow:InitLayout(event)
	self.mData = event.mData

	if self.mRootWidget == nil then
		self.mRootWidget = GUIWidgetPool:createWidget("DayDayUp_Main")
    	self.mRootNode:addChild(self.mRootWidget,100)
    end

    if self.mTopRoleInfoPanel == nil then
    	cclog("TowerExWindow mTopRoleInfoPanel init")    
		self.mTopRoleInfoPanel = TopRoleInfoPanel:new()
		local topInfoPanel = self.mTopRoleInfoPanel:init(self.mRootNode,ROLE_TITLE_TYPE.TITLE_TOWEREX, 
		function()
			GUISystem:playSound("homeBtnSound")
			if self.mData and self.mData[1] ~= nil then			
			   	local function callFun()
				  	EventSystem:PushEvent(Event.GUISYSTEM_HIDE_TOWEREXWINDOW)
		          	showLoadingWindow("HomeWindow")
		        end
				FightSystem:sendChangeCity(false,callFun)
			else
				EventSystem:PushEvent(Event.GUISYSTEM_HIDE_TOWEREXWINDOW)
			end	
		end)
	end

	self:InitFloors()

	local btnsPanel = self.mRootWidget:getChildByName("Panel_Window")
	btnsPanel:setPositionX(getGoldFightPosition_RD().x - btnsPanel:getContentSize().width)

	self.mRootWidget:getChildByName("Panel_Main"):setLocalZOrder(51)
	registerWidgetReleaseUpEvent(btnsPanel:getChildByName("Button_Fight"),
	function ()
		if self.mModel.mRewardState == REWARDSTATE.CANRECEIVE  then MessageBox:showMessageBox1("上一关奖励还未领取！") return end
		if self.mModel.mCurFloorNum > config.TowerExTotalFloor then MessageBox:showMessageBox1("恭喜您已到最高关卡！") return end
		ShowRoleSelWindow(self,function(heros) self.mModel:doClimbTowerExRequest(heros) end,self.mModel.mHeroArr,SELECTHERO.SHOWSELF) 
	end)

	registerWidgetReleaseUpEvent(btnsPanel:getChildByName("Button_RankingList"),function() GUISystem:goTo("rankinglist",{RANKTYPE.MAIN.ORGANIZE,RANKTYPE.MINOR.ALLFIGHTPOWER}) end)
	registerWidgetReleaseUpEvent(btnsPanel:getChildByName("Button_Rule"),
	function()
		local rulePanel = GUIWidgetPool:createWidget("DayDayUp_Rule")

		self.mRootNode:addChild(rulePanel,1000)
		
		registerWidgetReleaseUpEvent(rulePanel:getChildByName("Button_Close"),function() rulePanel:removeFromParent()  rulePanel = nil end) 
		registerWidgetReleaseUpEvent(rulePanel,function() rulePanel:removeFromParent()  rulePanel = nil end)

		local textData = DB_Text.getDataById(1741)
		local textStr  = textData.Text_CN
		richTextCreate(rulePanel:getChildByName("Panel_Text"),textStr,true,nil,false)
	end)
	registerWidgetReleaseUpEvent(btnsPanel:getChildByName("Button_Saodang"),function() self.mModel:doTowerExSweepRequest() end) --self.mSweep = true self:HeroRun()
	registerWidgetReleaseUpEvent(btnsPanel:getChildByName("Button_Reset"),function() self.mModel:doResetTowerExInfoRequest() end)

	if self.mData and self.mData[1] == "success" then
		self:HeroRun()
	end
end

function TowerExWindow:InitFloors()
	local floorCnt    = 5
	local pointLD     = getGoldFightPosition_LD()
	local floorWidget = nil
	self.mTower = cc.Layer:create()

	local bottomFloorNum = nil

	if self.mData and self.mData[1] == "success" then
		bottomFloorNum = self.mModel.mCurFloorNum - 2
		self.mModel.mCurFloorNum = self.mModel.mCurFloorNum - 1
	else
		bottomFloorNum = self.mModel.mCurFloorNum - 1
	end

	self.mFloorDq = deque.new()
	for i=1,floorCnt do
		local floor = GUIWidgetPool:createWidget("DayDayUp_FloorCell")
		floor:setTag(bottomFloorNum + i - 1)
		local spine = self:setFloorLayout(floor)
		floorWidget = floor		
		if not self.mFloorSize then self.mFloorSize = floor:getContentSize() end  
		floor:setPositionY(self.mFloorSize.height*(i - 1))
		self.mTower:addChild(floor,1000)

		local floorInfo = {}
		floorInfo.floor = floor
		floorInfo.spine = spine

		deque.pushFront(self.mFloorDq,floorInfo)
	end

	self.mTower:setContentSize(cc.size(self.mFloorSize.width,self.mFloorSize.height * floorCnt))

	local screenWidth = getGoldFightPosition_RD().x - pointLD.x

	self.mTower:setPosition(cc.p(getGoldFightPosition_Middle().x - self.mFloorSize.width / 2,pointLD.y))
	self.mRootWidget:addChild(self.mTower,50)

	local floorNum   = floorWidget:getChildByName("Panel_FloorNum")
	local pos        = cc.p(floorWidget:getPosition())

	self.mHero       = self.mRootWidget:getChildByName("Panel_Hero")	
	self.mEndPoint   = cc.p(pos.x + 240,getGoldFightPosition_LD().y + self.mFloorSize.height + 16)
	self.mStartPoint = cc.p(self.mEndPoint.x + self.mFloorSize.height,self.mEndPoint.y)

	local heroId     = globaldata:getHeroInfoByBattleIndex(1, "id")
	local heroData   = DB_HeroConfig.getDataById(heroId)

	self.mHeroZoom   = heroData.UIResouceZoom
	self.mSpineCache = SpineDataCacheManager:getSimpleSpineByHeroID(heroId,self.mHero)	
	self.mSpineCache:setScale(0.8 * heroData.UIResouceZoom)
	self.mHero:setScaleX(1)

	self.mHero:setPosition((self.mModel.mCurFloorNum % 2 ~= 0 and self.mEndPoint) or self.mStartPoint)

	self.mRootWidget:getChildByName("Label_ResetTimes"):setString(string.format("%d/2",self.mModel.mResetCnt))
end

function TowerExWindow:ShowSweepReward(sweepInfos)
	local widget =  GUIWidgetPool:createWidget("Tower_SaodangReward")
	local closeBtn = widget:getChildByName("Button_Close")
	self.mRootNode:addChild(widget,1000)

	local function closeWindow()
		widget:getChildByName("ListView_Reward"):removeAllChildren()
		widget:removeFromParent(true)
		widget = nil
	end

	widget:getChildByName("ListView_Reward"):removeAllChildren()
	widget:getChildByName("Label_MaxNum"):setString(string.format("快速通关至%d关",
	self.mModel.mCurFloorNum > config.TowerExTotalFloor and config.TowerExTotalFloor or self.mModel.mCurFloorNum))

	for i=1,#sweepInfos do
		local item = GUIWidgetPool:createWidget("Tower_SaodangContent")
		if i == #sweepInfos then
			item:getChildByName("Label_Name"):setString("额外奖励")
		else
			item:getChildByName("Label_Name"):setString(string.format("第%d战",sweepInfos[i].floorNum + 1))
		end

		for j=1,#sweepInfos[i].rewards do
			local rewardWidget = createCommonWidget(sweepInfos[i].rewards[j][1],sweepInfos[i].rewards[j][2],sweepInfos[i].rewards[j][3])
			local labelCnt = rewardWidget:getChildByName("Label_Count_Stroke")
			labelCnt:setVisible(true)
			labelCnt:setString(sweepInfos[i].rewards[j][3])
			item:getChildByName("Panel_Reward_"..j):addChild(rewardWidget)
		end
		
		if #sweepInfos[i].rewards ~= 0 then
			widget:getChildByName("ListView_Reward"):pushBackCustomItem(item)
		end
	end

	registerWidgetReleaseUpEvent(widget,closeWindow)
	registerWidgetReleaseUpEvent(closeBtn,closeWindow)
end

function TowerExWindow:setFloorLayout(floor)
	local floorNum = floor:getTag()
	local bkImg = (floorNum >= self.mModel.mCurFloorNum and "dayup_floorname_bg_1.png" or "dayup_floorname_bg_2.png")

	floor:getChildByName("Image_Bg"):loadTexture(string.format("dayup_floor_bg_%d.png",1 - math.mod(floorNum,2)))
	floor:getChildByName("Panel_FloorNum"):getChildByName("Image_Bg"):loadTexture(bkImg)
	

	if floorNum == 0 or floorNum > 200 then
		floor:getChildByName("Label_FloorName"):setVisible(false)
		floor:getChildByName("Label_FloorNum"):setVisible(false)
		floor:getChildByName("Panel_Enemy"):setVisible(false)
		floor:getChildByName("Panel_Reward"):setVisible(false)
		return nil
	else
		floor:getChildByName("Label_FloorName"):setVisible(true)
		floor:getChildByName("Label_FloorNum"):setVisible(true)
		floor:getChildByName("Panel_Enemy"):setVisible((floorNum >= self.mModel.mCurFloorNum and true or false))
		floor:getChildByName("Panel_Reward"):setVisible(true)
		floor:getChildByName("Label_FloorName"):setString(gradeStrings[floorNum])
		floor:getChildByName("Label_FloorNum"):setString(string.format("第%d关",floorNum))

		if floorNum % 5 == 0 then
			floor:getChildByName("Panel_Reward"):setVisible(true)
			
			self.mRewardAnims = AnimManager:createAnimNode(8058)
			floor:getChildByName("Panel_RewardAnimetion"):addChild(self.mRewardAnims:getRootNode(), 100)

			if self.mModel.mRewardState == REWARDSTATE.CANNOTRECEIVE then
				self.mRewardAnims:play("fight_daydayup_reward_1", true)
				floor:getChildByName("Panel_Reward"):setTouchEnabled(false)
			elseif self.mModel.mRewardState == REWARDSTATE.CANRECEIVE then
				self.mRewardAnims:play("fight_daydayup_reward_1", true)
				floor:getChildByName("Panel_Reward"):setTouchEnabled(true)

				registerWidgetReleaseUpEvent(floor:getChildByName("Panel_Reward"),function() 
					floor:getChildByName("Panel_Reward"):setTouchEnabled(false)
					self.mRewardAnims:play("fight_daydayup_reward_2", false, 
					function()
						self.mModel:doGetRewardRequest(floorNum)
						floor:getChildByName("Panel_Reward"):setTouchEnabled(false)
						self.mRewardAnims:play("fight_daydayup_reward_3", true) 
					end)
				end)
			else
				self.mRewardAnims:play("fight_daydayup_reward_3", true)
				floor:getChildByName("Panel_Reward"):setTouchEnabled(false)
				registerWidgetReleaseUpEvent(floor:getChildByName("Panel_Reward"),function() end)
			end	
		else
			floor:getChildByName("Panel_Reward"):setVisible(false)
			registerWidgetReleaseUpEvent(floor:getChildByName("Panel_Reward"),function() end)
		end	

		local monsterInfo = DB_SpecialMap.getDataById(floorNum + 1000)
		local monsterId   = monsterInfo.SpecialMap_BossPicture
		local spine 	  = SpineDataCacheManager:getSimpleSpineByMonsterID(monsterId,floor:getChildByName("Panel_Enemy"))
		local monsterData = DB_MonsterConfig.getDataById(monsterId)


		spine:setScale(monsterData.Monster_ModelZoom * 0.8)
		floor:getChildByName("Panel_Enemy"):setScaleX(-1)
		return spine
	end
end

function TowerExWindow:HeroRun()
	local function runBegin()
		self.mSpineCache:setAnimation(0, "run", true)
		self.mHero:setScaleX((self.mModel.mCurFloorNum % 2 == 0 and -1) or 1)

		local ntLastFloorInfo = deque.getNextToLast(self.mFloorDq)
		if ntLastFloorInfo then
			ntLastFloorInfo.floor:getChildByName("Panel_Enemy"):runAction(cc.FadeOut:create(1))
		end

		self:FloorMoveDown()
		GUISystem:disableUserInput()
	end

	local function runFinish()
		self.mSpineCache:setAnimation(0, "stand", true)
		self.mModel.mCurFloorNum = self.mModel.mCurFloorNum + 1
		if self.mData and self.mData[1] then
			self.mData[1] = "reset"    -- for reset
		end

		local topFloor    = deque.getFront(self.mFloorDq).floor
		local topFloorPos = cc.p(topFloor:getPosition())
		local bottomInfo  = deque.popBack(self.mFloorDq)
		local bottomFloor = bottomInfo.floor

		SpineDataCacheManager:collectFightSpineByAtlas(bottomInfo.spine)
		bottomFloor:setPosition(cc.p(topFloorPos.x,topFloorPos.y + self.mFloorSize.height))
		bottomFloor:setTag(topFloor:getTag() + 1)
		local spine = self:setFloorLayout(bottomFloor)

		local floorInfo = {}
		floorInfo.floor = bottomFloor
		floorInfo.spine = spine

		deque.pushFront(self.mFloorDq,floorInfo)
		deque.getBack(self.mFloorDq).floor:getChildByName("Panel_FloorNum"):getChildByName("Image_Bg"):loadTexture("dayup_floorname_bg_2.png") 

		--self.mSpineCache:setScale(0.8 * self.mHeroZoom)

		self.mHero:setScaleX(1)
		GUISystem:enableUserInput()
	end

	local endPoint = self.mModel.mCurFloorNum % 2 == 0 and self.mEndPoint or self.mStartPoint
	local actBegin = cc.CallFunc:create(runBegin)
	local actMove  = cc.MoveTo:create(1,endPoint)
	local actDelay = cc.DelayTime:create(0.1)
	local actEnd   = cc.CallFunc:create(runFinish)
	self.mHero:runAction(cc.Sequence:create(actBegin,actMove,actDelay,actEnd))
end

function TowerExWindow:FloorMoveDown()
	local towerCurPos = cc.p(self.mTower:getPosition())
	local towerEndPos = cc.p(towerCurPos.x,towerCurPos.y - self.mFloorSize.height)
	local actMove  =  cc.MoveTo:create(1, towerEndPos)
	self.mTower:runAction(cc.Sequence:create(actMove))
end

function TowerExWindow:ClearAllSpine()
	SpineDataCacheManager:collectFightSpineByAtlas(self.mSpineCache)
	self.mSpineCache = nil

	while not deque.empty(self.mFloorDq) do
		local floorInfo = deque.popFront(self.mFloorDq)
		SpineDataCacheManager:collectFightSpineByAtlas(floorInfo.spine)
	end
end

function TowerExWindow:Destroy()
	self:ClearAllSpine()

	self.mModel:destroyInstance()

	if self.mTopRoleInfoPanel ~= nil then 
		self.mTopRoleInfoPanel:destroy()
		self.mTopRoleInfoPanel = nil
	end

	self.mRootWidget = nil

	if self.mRootNode then
		self.mRootNode:removeFromParent(true)
		self.mRootNode = nil
	end

	self.mStartPoint    = nil
	self.mEndPoint      = nil
	self.mTower         = nil
	self.mFloorSize		= nil
	self.mFloorDq 		= nil
	self.mSweep 		= false

	----------------
	CommonAnimation.clearAllTextures()
end

function TowerExWindow:DisableDraw()
	if self.mRootWidget then
		self.mRootWidget:setVisible(false)
	end
end

function TowerExWindow:EnableDraw()
	if self.mRootWidget then
		self.mRootWidget:setVisible(true)
	end
end

function TowerExWindow:onEventHandler(event)
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

return TowerExWindow