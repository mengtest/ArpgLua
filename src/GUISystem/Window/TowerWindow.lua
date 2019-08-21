-- Name: 	TowerWindow
-- Func：	闯关界面
-- Author:	lichuan
-- Data:	15-4-30

local TMInstance = nil 

TowerModel = class("TowerModel")

function TowerModel:ctor()  
    self.mName 		    = "TowerModel"
	self.mWinData       = nil 
	self.mLastRecord    = -1
	self.mCurRecord	    = -1
	self.mResetCnt	    = -1	
	self.mPlayerCnt	    = -1	
	self.mPlayerHeroArr = {}
	self.mRewardCnt	    = -1
	self.mRewardArr	    = {}
	self.mRewardState   = {}
	self.mBattleHeros   = {0,0,0}
	self.mHeroHpInfos   = {}

	self.mPlayerNameArr   = {}
	self.mPlayerIconIdArr = {}
	self.mPlayerFrameIdArr = {}
	
	self.mTowerHeroTeam = {}

	self:registerNetEvent()
end

function TowerModel:deinit()
	self.mName 		    = nil
	self.mOwner			= nil
	self.mLastRecord    = -1
	self.mCurRecord	    = -1
	self.mResetCnt	    = -1	
	self.mPlayerCnt	    = -1	
	self.mPlayerHeroArr = {}
	self.mRewardCnt	    = -1
	self.mRewardArr	    = nil
	self.mRewardState   = {}
	self.mBattleHeros   = {0,0,0}
	self.mHeroHpInfos   = {}

	self.mPlayerNameArr   = {}
	self.mPlayerIconIdArr = {}
	self.mPlayerFrameIdArr = {}

	self.mTowerHeroTeam = {}

	self:unRegisterNetEvent()
end 

function TowerModel:getInstance()
	if TMInstance == nil then  
        TMInstance = TowerModel.new()
    end  
    return TMInstance
end

function TowerModel:destroyInstance()
	if TMInstance then
		TMInstance:deinit()
    	TMInstance = nil
    end
end

function TowerModel:registerNetEvent()
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_CHALLENGE_INFO_, handler(self, self.onChallengeInfoResponse))
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_CHALLENGE_RESET_, handler(self, self.onResetResponse))
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_REQUEST_SWEEP_, handler(self, self.onSweepResponse))
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_GETTOWER_REWARD_RESPONSE_, handler(self,self.onGetRewardResponse))
end

function TowerModel:unRegisterNetEvent()
	NetSystem.mNetManager:UnregisterPacketHandler(PacketTyper._PTYPE_SC_CHALLENGE_INFO_)
	NetSystem.mNetManager:UnregisterPacketHandler(PacketTyper._PTYPE_SC_CHALLENGE_RESET_)
	NetSystem.mNetManager:UnregisterPacketHandler(PacketTyper._PTYPE_SC_REQUEST_SWEEP_)
	NetSystem.mNetManager:UnregisterPacketHandler(PacketTyper._PTYPE_SC_GETTOWER_REWARD_RESPONSE_)
end

function TowerModel:setOwner(owner)
	self.mOwner = owner
end

function TowerModel:doChallengeInfoRequest()
	local packet = NetSystem.mNetManager:GetSPacket()
	packet:SetType(PacketTyper._PTYPE_CS_CHALLENGE_INFO_)
	packet:Send()
	GUISystem:showLoading()
end

function TowerModel:onChallengeInfoResponse(msgPacket)
	self.mLastRecord = msgPacket:GetInt()
	self.mCurRecord  = msgPacket:GetInt()
	self.mResetCnt   = msgPacket:GetChar()
	self.mSweepState = msgPacket:GetChar() -- 0:可以 1:不可以 2: 扫荡过
	self.mPlayerCnt  = msgPacket:GetUShort()

	if self.mPlayerCnt > 15 then self.mPlayerCnt = 15 end
	if self.mCurRecord > 14 then self.mCurRecord = 14 end

	for i = 1,self.mPlayerCnt do
		self.mPlayerHeroArr[i] = {}

		self.mPlayerNameArr[i]    = msgPacket:GetString()
		self.mPlayerIconIdArr[i]  = msgPacket:GetInt()
		self.mPlayerFrameIdArr[i] = msgPacket:GetInt()

		local heroCnt = msgPacket:GetUShort()
		for j=1,heroCnt do
			local playerHero            = {}
			playerHero.mHeroId          = msgPacket:GetInt()
			playerHero.mHeroAdvanceLv   = msgPacket:GetChar()
			playerHero.mHeroQuality     = msgPacket:GetChar()
			playerHero.mHeroLevel       = msgPacket:GetInt()
			playerHero.mCombat          = msgPacket:GetInt()
			playerHero.mHeroCurHp		= msgPacket:GetInt()
			playerHero.mHeroTotalHp		= msgPacket:GetInt()

			table.insert(self.mPlayerHeroArr[i],playerHero)
		end

		self.mRewardArr[i] = {}
		self.mRewardCnt  = msgPacket:GetUShort()
		
		for k = 1,self.mRewardCnt do
			local rewardInfo            = {}
			rewardInfo.mRewardType      = msgPacket:GetInt()
			rewardInfo.mItemId          = msgPacket:GetInt()
			rewardInfo.mItemCnt         = msgPacket:GetInt()
			table.insert(self.mRewardArr[i],rewardInfo)
		end

		self.mRewardState[i] = msgPacket:GetChar()
	end

	local battleHeroCnt = msgPacket:GetUShort()
	for i=1,battleHeroCnt do
		self.mBattleHeros[i] = msgPacket:GetInt()
	end

	self.mTowerHeroTeam = {}

	local heroCnt = msgPacket:GetUShort()
	for i=1,heroCnt do
		local heroId  = msgPacket:GetInt()
		local curHp   = msgPacket:GetInt()
		local totalHp = msgPacket:GetInt()

		table.insert(self.mTowerHeroTeam,heroId)
		self.mHeroHpInfos[heroId] = {}
		self.mHeroHpInfos[heroId].curHp = curHp
		self.mHeroHpInfos[heroId].totalHp = totalHp

		cclog(string.format("heroId is %d,curHp is %d,totalHp is %d",heroId,curHp,totalHp))
	end

	GUISystem:hideLoading()

	print("self.mCurRecord is ",self.mCurRecord)

	if self.mBupdate ~= true then
		Event.GUISYSTEM_SHOW_TOWERWINDOW.mData = self.mWinData
		
		if self.mWinData ~= nil and self.mWinData[2] ~= nil then     --for offline exit
			self.mWinData[2]()
		end

		EventSystem:PushEvent(Event.GUISYSTEM_SHOW_TOWERWINDOW)
	else
		self.mOwner:AdapterMachine()
		self.mOwner:UpdateLayOut()
	end
end

function TowerModel:getHpInfoById(id)
	return self.mHeroHpInfos[id]
end

function TowerModel:doSweepRequest()
	local packet = NetSystem.mNetManager:GetSPacket()
	packet:SetType(PacketTyper._PTYPE_CS_REQUEST_SWEEP_)
	packet:Send()
	GUISystem:showLoading()
end

function TowerModel:onSweepResponse(msgPacket)
	local sweepCnt     = msgPacket:GetUShort()
	local rewardArr    = {}
	local rewardIdxArr = {}

	for i=1,sweepCnt do
		rewardArr[i] = {}
		rewardIdxArr[i]				    = msgPacket:GetUShort()
		local rewardCnt  				= msgPacket:GetUShort()
		for j=1,rewardCnt do
			local rewardInfo            = {}
			rewardInfo.mRewardType      = msgPacket:GetInt()
			rewardInfo.mItemId          = msgPacket:GetInt()
			rewardInfo.mItemCnt         = msgPacket:GetInt()
			table.insert(rewardArr[i],rewardInfo)
		end
	end

	GUISystem:hideLoading()
	self.mOwner:ShowSweepReward(rewardArr,rewardIdxArr)
	self.mBupdate = true
	self:doChallengeInfoRequest()
end

function TowerModel:doResetRequest()
	local function OnOK()
		local packet = NetSystem.mNetManager:GetSPacket()
		packet:SetType(PacketTyper._PTYPE_CS_CHALLENGE_RESET_)
		packet:Send()
		GUISystem:showLoading()
	end

	if self.mResetCnt == 0 then
		MessageBox:showMessageBox1("今日重置次数已用完!")
	else
		if self.mCurRecord ~= 0 or self:getDeadHeroCnt() > 0 then

			if self.mRewardState[15] == REWARDSTATE.CANRECEIVE then
				MessageBox:showMessageBox1("还有奖励未领取！")
			elseif self.mRewardState[15] == REWARDSTATE.HAVERECEIVED then
				OnOK()
			else
			 	if self:getAliveHeroCnt() > 0 then
			 		MessageBox:showMessageBox2("还有可战斗的英雄，确定要放弃此次闯关机会吗？", OnOK)
				else
				 	OnOK()
			 	end
			end
		else
		 	MessageBox:showMessageBox1("当前闯关为全新进度，无需重置！")
		end
	end
end

function TowerModel:getDeadHeroCnt()
	local deadCnt = 0
	for k,v in pairs(self.mHeroHpInfos) do
		if v.curHp <= 0 then
			deadCnt = deadCnt + 1
		end
	end
	return deadCnt
end

function TowerModel:getAliveHeroCnt()
	local aliveCnt = 0
	for k,v in pairs(self.mHeroHpInfos) do
		if v.curHp > 0 then
			aliveCnt = aliveCnt + 1
		end
	end
	return aliveCnt
end

function TowerModel:getFirstActivityRewardIdx()
	for i=1,#self.mRewardState do
		if self.mRewardState[i] == REWARDSTATE.CANRECEIVE then
			return i
		end
	end

	return 0
end

function TowerModel:onResetResponse(msgPacket)
	self.mBupdate = true
	self.mResetCnt = msgPacket:GetChar()
	GUISystem:hideLoading()

	self.mTowerHeroTeam = {}
	self:doChallengeInfoRequest()
	if self.mOwner then
		self.mOwner.mRootWidget:getChildByName("ScrollView_Map"):jumpToPercentHorizontal(1)
	end
end

function TowerModel:doGetRewardRequest(index)
	self.mLastGetIdx = index
	local packet = NetSystem.mNetManager:GetSPacket()
	packet:SetType(PacketTyper._PTYPE_CS_GETTOWER_REWARD_REQUEST_)
	packet:PushInt(index)
	packet:Send()
	GUISystem:showLoading()
end

-- 返回闯关奖励 3209
function TowerModel:onGetRewardResponse(msgPacket)
	local ret = msgPacket:GetChar()
	if ret == FAILED then return end

	self.mRewardState[self.mLastGetIdx] = REWARDSTATE.HAVERECEIVED

	local itemList = {}
	local rewardCount = msgPacket:GetUShort()
	for i = 1, rewardCount do
		local itemType  = msgPacket:GetInt()
		local itemId    = msgPacket:GetInt()
		local itemCount = msgPacket:GetInt()
		itemList[i]     = {itemType, itemId, itemCount}
	end
	GUISystem:hideLoading()
	if rewardCount == 0 then return end

	if self.mOwner then
		local mapSV = self.mOwner.mRootWidget:getChildByName("ScrollView_Map")
		local btn = mapSV:getChildByName(string.format("Button_Box_%d",self.mLastGetIdx))

		btn:loadTextureNormal("tower_box_open.png")
		btn:setTouchEnabled(false)

		if self.mLastGetIdx < 14 then
			mapSV:getChildByName(string.format("Button_Box_%d",self.mLastGetIdx + 2)):setVisible(true)
			mapSV:getChildByName(string.format("Panel_Section_%d",self.mLastGetIdx + 2)):setVisible(true)
		end

		self.mOwner.mRewardAni[self.mLastGetIdx]:play("tower_cursection_2",true)
		if self.mLastGetIdx ~= 15 then
			self.mOwner.mSectionAni[self.mLastGetIdx + 1]:play("tower_cursection_1",true)
		end
	end
	MessageBox:showMessageBox_ItemAlreadyGot(itemList, false)
end

function TowerModel:doChallengeRequest(heros)
	for i=1,#heros do
		globaldata.towerBattleHeros[i] = heros[i]
	end

	local packet = NetSystem.mNetManager:GetSPacket()
	packet:SetType(PacketTyper._PTYPE_CS_REQUEST_CHALLENGE_BRAVE)
	packet:PushUShort(#heros) 
	for i=1,#heros do
		packet:PushInt(heros[i])
	end
	packet:Send()
	GUISystem:showLoading()
end

--==========================================================window  begin ==================================================================

local TowerWindow = 
{
	mName 				= "TowerWindow",
	mRootNode			=	nil,	
	mRootWidget 		= 	nil,
	mTopRoleInfoPanel	=	nil,	-- 顶部人物信息面板
	mRankWindow 		=	nil,    -- 排行榜窗口
	mResetWindow 		=	nil,    -- 重置窗口
	mSaodangWindow 		=	nil,    -- 扫荡窗口
	mModel				=   nil,

	mAnimWidet          =   {},
	mSectionAni         =   {},
	mRewardAni          =   {},

}

function TowerWindow:Release()
end

function TowerWindow:Load(event)
	cclog("=====TowerWindow:Load=====begin")

	self.mRootNode = cc.Node:create()
	GUISystem:GetRootNode():addChild(self.mRootNode)
	
	self.mModel = TowerModel:getInstance()

	self.mModel:setOwner(self)

	self:InitLayout(event)
	self.mCurSection = self.mModel.mCurRecord + 1

	local function doParkGuideOne_Stop()
		ParkGuideOne:stop()
	end

	local function doParkGuideOne_Step5()
		ParkGuideOne:step(5, nil, doParkGuideOne_Stop)
	end

	local function doParkGuideOne_Step4()
		local guideBtn = self.mRootWidget:getChildByName("Image_Saodang")
		local size = guideBtn:getContentSize()
		local pos = guideBtn:getWorldPosition()
		pos.x = pos.x - size.width/2
		pos.y = pos.y - size.height/2
		local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
		ParkGuideOne:step(4, touchRect, nil, doParkGuideOne_Step5)
	end

	local function doParkGuideOne_Step3()
		local guideBtn = self.mRootWidget:getChildByName("Panel_Box_1")
		local size = guideBtn:getContentSize()
		local pos = guideBtn:getWorldPosition()
		local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
		ParkGuideOne:step(3, touchRect, nil, doParkGuideOne_Step4)
	end


	local function doParkGuideOne_Step2()
		local guideBtn = self.mRootWidget:getChildByName("Panel_Section_1")
		local size = guideBtn:getContentSize()
		local pos = guideBtn:getWorldPosition()
		local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
		ParkGuideOne:step(2, touchRect, nil, doParkGuideOne_Step3)
	end
	ParkGuideOne:step(1, nil, doParkGuideOne_Step2)

	cclog("=====TowerWindow:Load=====end")
end

function TowerWindow:InitLayout(event)
	self.mData = event.mData

	if self.mRootWidget == nil then
		self.mRootWidget = GUIWidgetPool:createWidget("Tower_Main")
    	self.mRootNode:addChild(self.mRootWidget)
    end

    if self.mTopRoleInfoPanel == nil then
    	cclog("TowerWindow mTopRoleInfoPanel init")    
		self.mTopRoleInfoPanel = TopRoleInfoPanel:new()
		local topInfoPanel = self.mTopRoleInfoPanel:init(self.mRootNode,ROLE_TITLE_TYPE.TITLE_TOWER, 
		function()
			GUISystem:playSound("homeBtnSound")
			if self.mData and self.mData[1] ~= nil then			
			   	local function callFun()
			   		__IsEnterFightWindow__ = false
				  	EventSystem:PushEvent(Event.GUISYSTEM_HIDE_TOWERWINDOW)
		          	showLoadingWindow("HomeWindow")
		        end
				FightSystem:sendChangeCity(false,callFun)
			else
				EventSystem:PushEvent(Event.GUISYSTEM_HIDE_TOWERWINDOW)
			end	
		end)
	end

	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_Rule"),
	function() 
		GUISystem:playSound("homeBtnSound") 
		local rulePanel = GUIWidgetPool:createWidget("Tower_Rule")
		self.mRootNode:addChild(rulePanel,1000)
		
		registerWidgetReleaseUpEvent(rulePanel:getChildByName("Button_Close"),function() rulePanel:removeFromParent()  rulePanel = nil end)
		registerWidgetReleaseUpEvent(rulePanel,function() rulePanel:removeFromParent()  rulePanel = nil end)

		local textData = DB_Text.getDataById(1721)
		local textStr  = textData.Text_CN
		richTextCreate(rulePanel:getChildByName("Panel_Text"),textStr,true,nil,false)
	end)
	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_Saodang"),  function() GUISystem:playSound("homeBtnSound") self.mModel:doSweepRequest() end)
	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_Reset"), function() GUISystem:playSound("homeBtnSound") self.mModel:doResetRequest() end)
	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_Fight"), 
	function() 
		GUISystem:playSound("homeBtnSound")
		if self.mCurSection > self.mModel.mCurRecord + 1 then 
			MessageBox:showMessageBox1("关卡未开启")
		else
			ShowRoleSelWindow(self,function(heros) self.mModel:doChallengeRequest(heros) end,
			self.mModel.mBattleHeros,SELECTHERO.SHOWBOTH,self.mModel.mPlayerHeroArr[self.mCurSection])
		end 
	end)

	self:AdapterMachine()
	self:UpdateLayOut()

	local function goToShop()
		GUISystem:goTo("shangcheng", 2)
	end
	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_Shop"), goToShop)
end

function TowerWindow:AdapterMachine()
	local bottomPanel = self.mRootWidget:getChildByName("Panel_Bottom")
	local size = bottomPanel:getContentSize()
	bottomPanel:setPosition(getGoldFightPosition_RD().x - size.width,getGoldFightPosition_RD().y)

	local mapSV = self.mRootWidget:getChildByName("ScrollView_Map")
	local height = mapSV:getContentSize().height
	self.mRootWidget:getChildByName("ScrollView_Map"):setContentSize(cc.size(getGoldFightPosition_RD().x - getGoldFightPosition_LD().x,height))

	local curPos = cc.p(mapSV:getChildByName(string.format("Panel_Section_%d",self.mModel.mCurRecord + 1)):getPosition())
	local totalWidth = mapSV:getInnerContainerSize().width	

	local screenWidth = getGoldFightPosition_RD().x - getGoldFightPosition_LD().x

	if self.mModel.mCurRecord + 1 < 13 then 
		mapSV:setInnerContainerSize(cc.size(curPos.x + screenWidth / 2,height))
	else
		mapSV:setInnerContainerSize(cc.size(2850 - 60,height))
	end

	mapSV:jumpToPercentHorizontal(100)
end

function TowerWindow:UIAnimation()
	local function TeamAnimation()
		local teamPanel = self.mRootWidget:getChildByName("Panel_Bg3")
		local teamPos   = cc.p(teamPanel:getPosition()) 
		local teamSize  = teamPanel:getContentSize() 

		local function runBegin()
			teamPanel:setPositionY(self.mTopRoleInfoPanel.mTopWidget:getPositionY() + teamSize.height)
			teamPanel:setOpacity(0)
		end

		local actBegin = cc.CallFunc:create(runBegin)
		local actMove  = cc.MoveTo:create(0.2, teamPos)
		local actFade  = cc.FadeIn:create(0.2)
		local actSpawn = cc.Spawn:create(actMove,actFade)

		teamPanel:runAction(cc.Sequence:create(actBegin,actSpawn))
	end

	local function BottomAnimation()
		local bottomPanel = self.mRootWidget:getChildByName("Panel_Bottom")
		local bottomPos   = cc.p(bottomPanel:getPosition()) 
		local bottomSize  = bottomPanel:getContentSize() 

		local function runBegin()
			bottomPanel:setPositionY(getGoldFightPosition_LD().y - bottomSize.height)
			bottomPanel:setOpacity(0)
		end

		local actBegin = cc.CallFunc:create(runBegin)
		local actMove  = cc.MoveTo:create(0.2, bottomPos)
		local actFade  = cc.FadeIn:create(0.2)
		local actSpawn = cc.Spawn:create(actMove,actFade)

		bottomPanel:runAction(cc.Sequence:create(actBegin,actSpawn))
	end

	TeamAnimation()
	BottomAnimation()
end 

function TowerWindow:UpdateLayOut()
	local mapSV = self.mRootWidget:getChildByName("ScrollView_Map")
	local circleIdx = self.mModel:getFirstActivityRewardIdx()

	for i=1,15 do
		local sectionBtn  = mapSV:getChildByName(string.format("Panel_Section_%d",i))
		local rewardBtn   = mapSV:getChildByName(string.format("Button_Box_%d",i))
		local rewardPanel = mapSV:getChildByName(string.format("Panel_Box_%d",i))
		local heroInfo    = self.mModel.mPlayerHeroArr[i][1]
		local heroData    = DB_HeroConfig.getDataById(heroInfo.mHeroId)
		local iconId      = heroData.IconID
		local iconData    = DB_ResourceList.getDataById(iconId)

		sectionBtn:setTag(i)
		rewardBtn:setTag(i)

		if config.TowerEnemyCnt == 3 then
			sectionBtn:getChildByName("Image_PlayerIcon"):loadTexture(FindFrameIconbyId(self.mModel.mPlayerIconIdArr[i]))
		else
			sectionBtn:getChildByName("Image_PlayerIcon"):loadTexture(iconData.Res_path1,1)
		end

		registerWidgetReleaseUpEvent(sectionBtn,handler(self,self.ShowSectionInfo))

		if self.mSectionAni[i] == nil then
			self.mSectionAni[i] = AnimManager:createAnimNode(8061)
			sectionBtn:getChildByName("Panel_Animation"):addChild(self.mSectionAni[i]:getRootNode(), 100)
		end

		if self.mRewardAni[i] == nil then
			self.mRewardAni[i]  = AnimManager:createAnimNode(8061)
			rewardPanel:getChildByName("Panel_Animation"):addChild(self.mRewardAni[i]:getRootNode(), 100)
		end

		self.mSectionAni[i]:play("tower_cursection_2",true)
		self.mRewardAni[i]:play("tower_cursection_2",true)

		if i < self.mModel.mCurRecord + 1 then
			ShaderManager:DoUIWidgetDisabled(sectionBtn:getChildByName("Image_PlayerIcon"),true)
			sectionBtn:getChildByName("Image_SectionNum_Bg"):loadTexture("tower_section_num_bg2.png")
		else
			ShaderManager:DoUIWidgetDisabled(sectionBtn:getChildByName("Image_PlayerIcon"),false)
			sectionBtn:getChildByName("Image_SectionNum_Bg"):loadTexture("tower_section_num_bg1.png")
		end

		if self.mModel.mCurRecord + 1 == 15 and self.mModel.mRewardState[i] ~= REWARDSTATE.CANNOTRECEIVE then
			ShaderManager:DoUIWidgetDisabled(sectionBtn:getChildByName("Image_PlayerIcon"),true)
			sectionBtn:getChildByName("Image_SectionNum_Bg"):loadTexture("tower_section_num_bg2.png")
		end

		if i > self.mModel.mCurRecord + (circleIdx ~= 0 and 1 or 2) then
			sectionBtn:setVisible(false)
			rewardPanel:setVisible(false)
		else
			sectionBtn:setVisible(true)
			rewardPanel:setVisible(true)
		end

		if self.mModel.mRewardState[i] == REWARDSTATE.CANRECEIVE then
			rewardBtn:loadTextureNormal("tower_box_close.png")
			rewardBtn:setTouchEnabled(true)
			registerWidgetReleaseUpEvent(rewardBtn,function() self.mModel:doGetRewardRequest(rewardBtn:getTag()) end)
		elseif self.mModel.mRewardState[i] == REWARDSTATE.CANNOTRECEIVE then
			rewardBtn:loadTextureNormal("tower_box_close.png")
			rewardBtn:setTouchEnabled(true)
			registerWidgetReleaseUpEvent(rewardBtn,handler(self,self.ShowReward))
		elseif self.mModel.mRewardState[i] == REWARDSTATE.HAVERECEIVED then
			rewardBtn:loadTextureNormal("tower_box_open.png")
			rewardBtn:setTouchEnabled(false)
			--registerWidgetReleaseUpEvent(rewardBtn,handler(self,self.ShowReward))
		end
	end

	if self.mModel.mRewardState[15] == REWARDSTATE.HAVERECEIVED then
		circleIdx = 15
	end

	if circleIdx == 0 then
		self.mSectionAni[self.mModel.mCurRecord + 1]:play("tower_cursection_1",true)
	else
		self.mRewardAni[circleIdx]:play("tower_cursection_1",true)
	end

	if self.mModel.mSweepState == 0 then --可以扫荡
		self.mRootWidget:getChildByName("Image_Saodang"):setVisible(true)
		self.mRootWidget:getChildByName("Label_Saodang"):setVisible(true)
		self.mRootWidget:getChildByName("Image_Reset"):setVisible(false)
		self.mRootWidget:getChildByName("Label_Reset"):setVisible(false)
	elseif self.mModel.mSweepState == 1 then --不可以扫荡
    	self.mRootWidget:getChildByName("Image_Saodang"):setVisible(false)
    	self.mRootWidget:getChildByName("Label_Saodang"):setVisible(false)
    	self.mRootWidget:getChildByName("Image_Reset"):setVisible(true)
    	self.mRootWidget:getChildByName("Label_Reset"):setVisible(true)
	elseif self.mModel.mSweepState == 2 then --扫荡过
	    self.mRootWidget:getChildByName("Image_Saodang"):setVisible(false)
		self.mRootWidget:getChildByName("Label_Saodang"):setVisible(false)
		self.mRootWidget:getChildByName("Image_Reset"):setVisible(true)
		self.mRootWidget:getChildByName("Label_Reset"):setVisible(true)
		if self.mModel.mResetCnt == 0 then
			ShaderManager:DoUIWidgetDisabled(self.mRootWidget:getChildByName("Button_Reset"), true) 
			self.mRootWidget:getChildByName("Button_Reset"):setTouchEnabled(false)
		end
	end

	self.mRootWidget:getChildByName("Label_SaodangNum"):setString(tostring(self.mModel.mLastRecord - config.TowerSweepValue))
	self.mRootWidget:getChildByName("Label_ResetNum"):setString(tostring(self.mModel.mResetCnt))
end

function TowerWindow:ShowSectionInfo(widget)
	local index      = widget:getTag()
	self.mCurSection = index

	local enemyPanel =  self.mRootWidget:getChildByName("Panel_Enemy")

	if config.TowerEnemyCnt == 1 then
		local heroInfo   = self.mModel.mPlayerHeroArr[index][1]
		
		local heroData   = DB_HeroConfig.getDataById(heroInfo.mHeroId)
		local nameId     = heroData.Name
		local nameData   = DB_Text.getDataById(nameId)
		local nameStr    = nameData.Text_CN
		local iconId     = heroData.IconID
		local iconData   = DB_ResourceList.getDataById(iconId)

		enemyPanel:getChildByName("Image_HeroIcon"):loadTexture(iconData.Res_path1,1)
		enemyPanel:getChildByName("Label_HeadName"):setString(nameStr) 
		enemyPanel:getChildByName("Label_Blood_Stroke"):setString(string.format("%d/%d",heroInfo.mHeroCurHp,heroInfo.mHeroTotalHp))
		enemyPanel:getChildByName("Label_Zhanli"):setString(string.format("战力%d",heroInfo.mCombat)) 
		enemyPanel:getChildByName("ProgressBar_HeroBlood"):setPercent(heroInfo.mHeroCurHp / heroInfo.mHeroTotalHp * 100)
	else
		enemyPanel:getChildByName("Label_HeadName"):setString(self.mModel.mPlayerNameArr[index])
		local playerHead = GUIWidgetPool:createWidget("PlayerHead")
		playerHead:getChildByName("Label_Level"):setVisible(false)
		playerHead:getChildByName("Image_Level_Bg"):setVisible(false)
		playerHead:getChildByName("Panel_7"):setTouchEnabled(false) 
    	playerHead:getChildByName("Image_PlayerHead_Bg"):loadTexture(FindFrameIconbyId(self.mModel.mPlayerFrameIdArr[index]))
		playerHead:getChildByName("Image_PlayerHead"):loadTexture(FindFrameIconbyId(self.mModel.mPlayerIconIdArr[index]))
		enemyPanel:getChildByName("Panel_PlayerHead"):removeAllChildren()
		enemyPanel:getChildByName("Panel_PlayerHead"):addChild(playerHead)
		for i=1,#self.mModel.mPlayerHeroArr[index] do
			local heroInfoPanel  = enemyPanel:getChildByName(string.format("Panel_Hero_%d",i))
			local heroPanel      =  heroInfoPanel:getChildByName("Panel_HeroIcon")
			local heroInfo       = self.mModel.mPlayerHeroArr[index][i]
			local heroWidget     = createHeroIcon(heroInfo.mHeroId,heroInfo.mHeroLevel,heroInfo.mHeroQuality,heroInfo.mHeroAdvanceLv)
			heroWidget:getChildByName("Label_Level_Stroke"):setVisible(false)
			heroWidget:getChildByName("Panel_Star"):setVisible(false)
			heroWidget:getChildByName("Image_HeroDead"):setVisible(heroInfo.mHeroCurHp == 0)
			--heroInfoPanel:getChildByName("Label_Zhanli"):setString(heroInfo.mCombat) 
			heroInfoPanel:getChildByName("ProgressBar_HeroBlood"):setPercent(heroInfo.mHeroCurHp / heroInfo.mHeroTotalHp * 100)

			heroPanel:removeAllChildren()
			heroPanel:addChild(heroWidget)
		end
	end

	local pos = cc.p(enemyPanel:getChildByName("Panel_HeroList"):getPosition())
	if self.mCurSection ~= self.mModel.mCurRecord + 1 then	
		enemyPanel:getChildByName("Button_Fight"):setVisible(false)
		if config.TowerEnemyCnt == 3 then
			enemyPanel:getChildByName("Panel_HeroList"):setPositionY(pos.y - 50)
			enemyPanel:getChildByName("Image_Line"):setVisible(false)
		end
	else
		enemyPanel:getChildByName("Button_Fight"):setVisible(true)
		if config.TowerEnemyCnt == 3 then
			enemyPanel:getChildByName("Image_Line"):setVisible(true)
		end
	end

	if index ~= 1 and self.mModel.mRewardState[index - 1] == REWARDSTATE.CANRECEIVE then
		enemyPanel:getChildByName("Button_Fight"):setVisible(false)
		if config.TowerEnemyCnt == 3 then
			enemyPanel:getChildByName("Panel_HeroList"):setPositionY(pos.y - 50)
			enemyPanel:getChildByName("Image_Line"):setVisible(false)
		end
	end

	if index == 15 and self.mModel.mRewardState[15] ~= REWARDSTATE.CANNOTRECEIVE then
		enemyPanel:getChildByName("Button_Fight"):setVisible(false)
		if config.TowerEnemyCnt == 3 then
			enemyPanel:getChildByName("Panel_HeroList"):setPositionY(pos.y - 50)
			enemyPanel:getChildByName("Image_Line"):setVisible(false)
		end
	end


	local  btn = self.mRootWidget:getChildByName("Button_Fight")

	btn:setTouchEnabled(not (self.mModel.mCurRecord + 1 > index))
	ShaderManager:DoUIWidgetDisabled(btn, (self.mModel.mCurRecord + 1 > index))
	enemyPanel:setVisible(true)

	registerWidgetReleaseUpEvent(enemyPanel,
	function() 
		enemyPanel:setVisible(false)
		enemyPanel:getChildByName("Panel_HeroList"):setPositionY(pos.y) 
	end)
end

function TowerWindow:ShowReward(widget)
	local index = widget:getTag()
	local infoWidget =  GUIWidgetPool:createWidget("Tower_Reward")

	--assert(#self.mModel.mRewardArr[index] == 1,"rewardItem cnt is over flow")

	--for i=1,#self.mModel.mRewardArr[index] do
		local item = self.mModel.mRewardArr[index][1]
		local rewardWidget = createCommonWidget(item.mRewardType,item.mItemId,item.mItemCnt)
		local labelCnt = rewardWidget:getChildByName("Label_Count_Stroke")
		labelCnt:setVisible(false)

		infoWidget:getChildByName("Label_Reward1_Num"):setString(tostring(item.mItemCnt))
		infoWidget:getChildByName("Panel_Reward_1"):addChild(rewardWidget)
	--end

	self.mRootNode:addChild(infoWidget,1)

	registerWidgetReleaseUpEvent(infoWidget,function() infoWidget:removeFromParent(true); infoWidget = nil end)
end

function TowerWindow:ShowSweepReward(rewardArr,rewardIdxArr)
	local widget   =  GUIWidgetPool:createWidget("Tower_SaodangReward")
	local lstView  = widget:getChildByName("ListView_Reward")
	local closeBtn = widget:getChildByName("Button_Close")
	local i      = 1

	lstView:removeAllChildren()

	local function addCell()
		if i <= #rewardArr then
			local item     = GUIWidgetPool:createWidget("Tower_SaodangContent")
			local size     = item:getContentSize()
			local runBegin = cc.CallFunc:create(function() lstView:jumpToPercentVertical(100) end)			
			local j        = 1
			local function addItem()
				if rewardArr[i] and j <= #rewardArr[i] then
					local rewardWidget = createCommonWidget(rewardArr[i][j].mRewardType,rewardArr[i][j].mItemId,rewardArr[i][j].mItemCnt)
					local labelCnt 	   = rewardWidget:getChildByName("Label_Count_Stroke")
					local runEnd       = cc.CallFunc:create(function()  j = j + 1 addItem() end)
					
					labelCnt:setVisible(true)
					labelCnt:setString(tostring(rewardArr[i][j].mItemCnt))

					rewardWidget:setAnchorPoint(0.5,0.5)
					rewardWidget:setPositionY(rewardWidget:getPositionY() + rewardWidget:getContentSize().height / 2)
					rewardWidget:runAction(cc.Sequence:create(cc.ScaleTo:create(0.1, 1.2),cc.ScaleTo:create(0.1, 1),runEnd))

					item:getChildByName("Panel_Reward_"..j):addChild(rewardWidget)
				else
					i = i + 1
					addCell()
				end
			end

			local runEnd   = cc.CallFunc:create(function() addItem() end)

			item:getChildByName("Label_Name"):setString(string.format("第%d战",rewardIdxArr[i]))
			item:setAnchorPoint(0.5,0.5)
			item:runAction(cc.Sequence:create(runBegin,cc.ScaleTo:create(0.2, 1.2),cc.ScaleTo:create(0.2, 1),runEnd))
			lstView:setInnerContainerSize(cc.size(size.width,size.height * i + (i - 1)*3))
			lstView:pushBackCustomItem(item)
		end
	end

	addCell()

	self.mRootNode:addChild(widget,1)

	widget:getChildByName("Label_MaxNum"):setString("快速通关至"..tostring(self.mModel.mLastRecord - config.TowerSweepValue).."关")
	registerWidgetReleaseUpEvent(widget,function() widget:removeFromParent(true); widget = nil end)
	registerWidgetReleaseUpEvent(closeBtn,function() widget:removeFromParent(true); widget = nil end)
end

function TowerWindow:GetHpInfoById(id)
	return self.mModel:getHpInfoById(id)
end

function TowerWindow:GetTowerHeroTeam()
	return self.mModel.mTowerHeroTeam
end

function TowerWindow:Destroy()
	self.mModel:destroyInstance()

	for i=1,#self.mSectionAni do
		self.mSectionAni[i]:destroy()
		self.mSectionAni[i] = nil
	end

	for i=1,#self.mRewardAni do
		self.mRewardAni[i]:destroy()
		self.mRewardAni[i] = nil
	end

	if self.mTopRoleInfoPanel ~= nil then 
		self.mTopRoleInfoPanel:destroy()
		self.mTopRoleInfoPanel = nil
	end

	self.mRootWidget = nil

	if self.mRootNode then
		self.mRootNode:removeFromParent(true)
		self.mRootNode = nil
	end
	----------------
	CommonAnimation.clearAllTextures()
end

function TowerWindow:DisableDraw()
	if self.mRootWidget then
		self.mRootWidget:setVisible(false)
	end
end

function TowerWindow:EnableDraw()
	if self.mRootWidget then
		self.mRootWidget:setVisible(true)
	end
end

function TowerWindow:onEventHandler(event)
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

return TowerWindow