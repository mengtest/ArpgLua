-- Name: 	LadderResultWindow
-- Func：	天梯结算
-- Author:	lichuan
-- Data:	15-9-18

local LadderResultWindow = 
{
	mName 			= "LadderResultWindow",
	mRootNode 		= nil,
	mRootWidget 	= nil,
	mHeroPicArr     = {},
	mSelfPanel	    = nil,
	mEnemyPanel     = nil,

	mDamageBarArr   = {},
	mBattleType     = nil,
	mBattleRet 		= nil,
	mDetailArr 		= {},
	mStarRunTime 	= 0.3,
	mMovexishu = 5,
}

function LadderResultWindow:Load(event)
	self.mRootNode = cc.Node:create()
	GUISystem:GetRootNode():addChild(self.mRootNode)

	self.mBattleRet  = event.mData[1][1]
	self.mBattleType = event.mData[1][2]
	self.mDetailArr  = event.mData[2]	

	--self:InitLayout(event)

	self:InitLayout2(event)
end

function LadderResultWindow:InitLayout2(event)

	if self.mBattleRet == BATTLE_RESULT.SUCCESS then
		self.mChibangeffectId = 8033
		self.mChibangeffect1 = "battleresults_win_1"
		self.mChibangeffect2 = "battleresults_win_2"
		CommonAnimation.PlayEffectId(5001)
	else
		self.mChibangeffectId = 8039
		self.mChibangeffect1 = "battleresults_lose_1"
		self.mChibangeffect2 = "battleresults_lose_2"
		CommonAnimation.PlayEffectId(5003)
	end
	self.mRootWidget = GUIWidgetPool:createWidget("BattleResult_Win")
	self.mRootNode:addChild(self.mRootWidget,1000)
	self.mRootWidget:getChildByName("Image_Bg"):setPosition(getGoldFightPosition_Middle())
		-- 背景适配
	local winSize = cc.Director:getInstance():getVisibleSize()
	self.mRootWidget:getChildByName("Image_Bg"):setContentSize(cc.size(winSize.width,self.mRootWidget:getChildByName("Image_Bg"):getContentSize().height))
	self.mPanel1 = self.mRootWidget:getChildByName("Panel_1")
	self.mPanel2 = self.mRootWidget:getChildByName("Panel_2")
	self.mPanel3 = self.mRootWidget:getChildByName("Panel_3")
	self.mPanel4 = self.mRootWidget:getChildByName("Panel_4")
	self.mPanelCards = self.mRootWidget:getChildByName("Panel_Cards")
	self.mPanelPVP1v1 = self.mRootWidget:getChildByName("Panel_PVP_1v1")
	self.mPanelPVP3v3 = self.mRootWidget:getChildByName("Panel_PVP_3v3")
	self.mPanel1:setVisible(true)
	self.mStars = globaldata.fubenstar
	self:showRewardStar2(globaldata.fubenstar)
	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Panel_13"),handler(self, self.closeWindow))
	self.mIsclose = false
end

function LadderResultWindow:ShowCloseText()
	self.mIsclose = true
	self.mRootWidget:getChildByName("Label_TouchClose_Stroke"):setVisible(true)
end

function LadderResultWindow:Show1V1()
	self.mPanelPVP1v1:getChildByName("Panel_TiantiScore"):setVisible(false)

	--self.mPanelPVP1v1:getChildByName("Panel_TiantiScore"):getChildByName("Label_ScoreTotal"):setString(tostring(globaldata.mPvpTotalScore))

	local signstr = nil
	if self.mBattleRet == BATTLE_RESULT.SUCCESS then
		signstr = "+%d"
	else
		signstr = "-%d"
	end
	--self.mPanelPVP1v1:getChildByName("Panel_TiantiScore"):getChildByName("Label_ScoreChange"):setString(string.format(signstr,math.abs(globaldata.mPvpWinScore)))
	self.mPanelPVP1v1:setVisible(true)
	self.mFriendInfo = self.mPanelPVP1v1:getChildByName("Panel_Self")
	self.mEnemyInfo = self.mPanelPVP1v1:getChildByName("Panel_Enemy")
	self.mFriendDamageBarArr = {}
	self.mEnemyDamageBarArr = {}

	local function createDamageAnim(beginPos,_strpng)
		local xuetiao = cc.Sprite:create(_strpng)
    	local aniBar_ = cc.ProgressTimer:create(xuetiao)
   	 	aniBar_:setType(2)
    	--aniBar_:setSlopbarParam(1, 0.025)
    	-- Setup for a bar starting from the bottom since the midpoint is 0 for the y
    	if beginPos == "left" then
   	 		aniBar_:setMidpoint(cc.p(0,1))
   	 	else
   	 		aniBar_:setMidpoint(cc.p(1,0))
   	 	end
    	-- Setup for a vertical bar since the bar change rate is 0 for x meaning no horizontal change
    	aniBar_:setAnchorPoint(cc.p(0,0))
    	aniBar_:setBarChangeRate(cc.p(1, 0))
    	aniBar_:setPosition(0,0)
    	aniBar_:setPercentage(0)
    	return aniBar_
	end
	self.mFriendInfo:getChildByName("Label_PlayerName"):setString(globaldata.mFriendPvpDamage[1].Name)
	self.mEnemyInfo:getChildByName("Label_PlayerName"):setString(globaldata.mEnemyPvpDamage[1].Name)

	for i=1,3 do
	    local panel = self.mFriendInfo:getChildByName(string.format("Panel_Hero_%d",i))
	    if globaldata:getBattleFormationInfoByIndex(i) then
	        local data = globaldata:getBattleFormationInfoByIndex(i)
	        local Icon = createHeroIcon(data.id, data.level, data.quality, data.advanceLevel)
	        panel:getChildByName("Panel_HeroIcon"):addChild(Icon)
	        local damageBar = createDamageAnim("left","battleresults_pvp_selfhero_bar.png")
	        self.mFriendDamageBarArr[i] = damageBar
	        panel:getChildByName("Image_DamageDealt_Bg"):addChild(damageBar)
	        panel:getChildByName("Label_DamageDealt"):setString(globaldata.mFriendPvpDamage[i].Damage)

	    end
	end
	for i=1,3 do
	    local panel = self.mEnemyInfo:getChildByName(string.format("Panel_Hero_%d",i))
	    if globaldata:getBattleEnemyFormationInfoByIndex(i) then
	        local data = globaldata:getBattleEnemyFormationInfoByIndex(i)
	        local Icon = createHeroIcon(data.id, data.level, data.quality, data.advanceLevel)
	        panel:getChildByName("Panel_HeroIcon"):addChild(Icon)
	        local damageBar = createDamageAnim("right","battleresults_pvp_enemyhero_bar.png")
	        self.mEnemyDamageBarArr[i] = damageBar
	        panel:getChildByName("Image_DamageDealt_Bg"):addChild(damageBar)
	        panel:getChildByName("Label_DamageDealt"):setString(globaldata.mEnemyPvpDamage[i].Damage)
	    end
	end
	for i=1,3 do
		if globaldata.mPvpDamageMax == 0 then
			self.mFriendDamageBarArr[i]:setPercentage(0)
		else
			local actProgress = cc.ProgressTo:create(0.5, (globaldata.mFriendPvpDamage[i].Damage / globaldata.mPvpDamageMax)*100)
			self.mFriendDamageBarArr[i]:runAction(actProgress)
		end	
	end
	for i=1,3 do
		if globaldata.mPvpDamageMax == 0 then
			self.mEnemyDamageBarArr[i]:setPercentage(0)
		else
			local actProgress = cc.ProgressTo:create(0.5, (globaldata.mEnemyPvpDamage[i].Damage / globaldata.mPvpDamageMax)*100)
			self.mEnemyDamageBarArr[i]:runAction(actProgress)
		end
	end
	self:ShowCloseText()
end

function LadderResultWindow:Show3V3()
	self.mPanelPVP3v3:getChildByName("Panel_TiantiScore"):setVisible(false)
	--self.mPanelPVP3v3:getChildByName("Panel_TiantiScore"):getChildByName("Label_ScoreTotal"):setString(tostring(globaldata.mPvpTotalScore))
	local signstr = nil
	if self.mBattleRet == BATTLE_RESULT.SUCCESS then
		signstr = "+%d"
	else
		signstr = "-%d"
	end
	--self.mPanelPVP3v3:getChildByName("Panel_TiantiScore"):setVisible(false)
	--self.mPanelPVP3v3:getChildByName("Panel_TiantiScore"):getChildByName("Label_ScoreChange"):setString(string.format(signstr,math.abs(globaldata.mPvpWinScore)))
	self.mPanelPVP3v3:setVisible(true)
	self.mFriendInfo = self.mPanelPVP3v3:getChildByName("Panel_Self")
	self.mEnemyInfo = self.mPanelPVP3v3:getChildByName("Panel_Enemy")
	self.mFriendDamageBarArr = {}
	self.mEnemyDamageBarArr = {}

	local function createDamageAnim(beginPos,_strpng)
		local xuetiao = cc.Sprite:create(_strpng)
    	local aniBar_ = cc.ProgressTimer:create(xuetiao)
   	 	aniBar_:setType(2)
    	--aniBar_:setSlopbarParam(1, 0.025)
    	-- Setup for a bar starting from the bottom since the midpoint is 0 for the y
    	if beginPos == "left" then
   	 		aniBar_:setMidpoint(cc.p(0,1))
   	 	else
   	 		aniBar_:setMidpoint(cc.p(1,0))
   	 	end
    	-- Setup for a vertical bar since the bar change rate is 0 for x meaning no horizontal change
    	aniBar_:setAnchorPoint(cc.p(0,0))
    	aniBar_:setBarChangeRate(cc.p(1, 0))
    	aniBar_:setPosition(0,0)
    	aniBar_:setPercentage(0)
    	return aniBar_
	end
	for i=1,3 do
	    local panel = self.mFriendInfo:getChildByName(string.format("Panel_Hero_%d",i))
	    if globaldata:getBattleFormationInfoByIndex(i) then
	        local data = globaldata:getBattleFormationInfoByIndex(i)
	        local Icon = createHeroIcon(data.id, data.level, data.quality, data.advanceLevel)
	        panel:getChildByName("Panel_HeroIcon"):addChild(Icon)
	        local damageBar = createDamageAnim("left","battleresults_pvp_selfhero_bar.png")
	        self.mFriendDamageBarArr[i] = damageBar
	        panel:getChildByName("Image_DamageDealt_Bg"):addChild(damageBar)
	        panel:getChildByName("Label_PlayerName"):setString(globaldata.mFriendPvpDamage[i].Name)
	        panel:getChildByName("Label_DamageDealt"):setString(globaldata.mFriendPvpDamage[i].Damage)
	    end
	end
	for i=1,3 do
	    local panel = self.mEnemyInfo:getChildByName(string.format("Panel_Hero_%d",i))
	    if globaldata:getBattleEnemyFormationInfoByIndex(i) then
	        local data = globaldata:getBattleEnemyFormationInfoByIndex(i)
	        local Icon = createHeroIcon(data.id, data.level, data.quality, data.advanceLevel)
	        panel:getChildByName("Panel_HeroIcon"):addChild(Icon)
	        local damageBar = createDamageAnim("right","battleresults_pvp_enemyhero_bar.png")
	        self.mEnemyDamageBarArr[i] = damageBar
	        panel:getChildByName("Image_DamageDealt_Bg"):addChild(damageBar)
	        panel:getChildByName("Label_PlayerName"):setString(globaldata.mEnemyPvpDamage[i].Name)
	        panel:getChildByName("Label_DamageDealt"):setString(globaldata.mEnemyPvpDamage[i].Damage)
	    end
	end
	for i=1,3 do
		if globaldata.mPvpDamageMax == 0 then
			self.mFriendDamageBarArr[i]:setPercentage(0)
		else
			local actProgress = cc.ProgressTo:create(0.5, (globaldata.mFriendPvpDamage[i].Damage / globaldata.mPvpDamageMax)*100)
			self.mFriendDamageBarArr[i]:runAction(actProgress)
		end
	end
	for i=1,3 do
		if globaldata.mPvpDamageMax == 0 then
			self.mEnemyDamageBarArr[i]:setPercentage(0)
		else
			local actProgress = cc.ProgressTo:create(0.5, (globaldata.mEnemyPvpDamage[i].Damage / globaldata.mPvpDamageMax)*100)
			self.mEnemyDamageBarArr[i]:runAction(actProgress)
		end
	end
	self:ShowCloseText()
end

function LadderResultWindow:showRewardStar2()
	local function RunOver()
		if self.mBattleType == BATTLE_TYPE.MULTI then
			self:Show3V3()
		elseif self.mBattleType == BATTLE_TYPE.SINGLE then
			self:Show1V1()
		elseif self.mBattleType == BATTLE_TYPE.BANGHUI then
			self:Show3V3()
		elseif self.mBattleType == 3 then
			-- 是切磋
			self:Show1V1()
		end
	end
	local function PlayGuangxian()
		local guangxian = AnimManager:createAnimNode(8035)
		local function GuangxianOver()
			guangxian:play("battleresults_lightline_2",true)
			self:WaitServerResult()
		end
		local pos1 = self.mPanel1:getChildByName("Panel_Wings_2")
		local pos2 = self.mPanel1:getChildByName("Panel_Star_1_2")
		local pos3 = self.mPanel1:getChildByName("Panel_Star_2_2")
		local pos4 = self.mPanel1:getChildByName("Panel_Star_3_2")

		local move = cc.MoveTo:create(self.mStarRunTime, cc.p(pos1:getPositionX(),pos1:getPositionY()))
		local EaseInmove = cc.EaseIn:create(move, self.mMovexishu)
		local actplay1 = cc.CallFunc:create(RunOver)
		local move1 = cc.MoveTo:create(self.mStarRunTime, cc.p(pos2:getPositionX(),pos2:getPositionY()))
		local EaseInmove1 = cc.EaseIn:create(move1, self.mMovexishu)
		--local scale1 = cc.ScaleTo:create(self.mStarRunTime, 0.5, 0.5)
		local move2 = cc.MoveTo:create(self.mStarRunTime, cc.p(pos3:getPositionX(),pos3:getPositionY()))
		local EaseInmove2 = cc.EaseIn:create(move2, self.mMovexishu)
		--local scale2 = cc.ScaleTo:create(self.mStarRunTime, 0.5, 0.5)
		local move3 = cc.MoveTo:create(self.mStarRunTime, cc.p(pos4:getPositionX(),pos4:getPositionY()))
		local EaseInmove3 = cc.EaseIn:create(move3, self.mMovexishu)
		--local scale3 = cc.ScaleTo:create(self.mStarRunTime, 0.5, 0.5)
		self.mPanel1:getChildByName("Panel_Wings_1"):runAction(cc.Sequence:create(EaseInmove))
		self.mPanel1:getChildByName("Panel_Star_1_1"):runAction(cc.Sequence:create(EaseInmove1))
		self.mPanel1:getChildByName("Panel_Star_2_1"):runAction(cc.Sequence:create(EaseInmove2))
		self.mPanel1:getChildByName("Panel_Star_3_1"):runAction(cc.Sequence:create(EaseInmove3))
		self.mPanel1:getChildByName("Panel_LightBg"):addChild(guangxian:getRootNode(), 100)
		guangxian:play("battleresults_lightline_1",false,GuangxianOver)

	end
	local function ChibangFinish()
		--闯关星星完事直接结束
		self.ChibangNode:play(self.mChibangeffect2,true)
		local pos1 = self.mPanel1:getChildByName("Panel_Wings_2")
		local move = cc.MoveTo:create(self.mStarRunTime, cc.p(pos1:getPositionX(),pos1:getPositionY()))
		local EaseInmove = cc.EaseIn:create(move, self.mMovexishu)
		local actplay1 = cc.CallFunc:create(RunOver)
		self.mPanel1:getChildByName("Panel_Wings_1"):runAction(cc.Sequence:create(EaseInmove,actplay1))
	end
	self.ChibangNode = AnimManager:createAnimNode(self.mChibangeffectId)
	self.mPanel1:getChildByName("Panel_Wings_1"):addChild(self.ChibangNode:getRootNode(), 100)
	self.ChibangNode:play(self.mChibangeffect1,false,ChibangFinish)
end

function LadderResultWindow:closeWindow()
	if not self.mIsclose then return end
	
	if self.mBattleType == 2 then
	    local function xxx()
	        local function callFun()
	          GUISystem:HideAllWindow()
	          showLoadingWindow("HomeWindow")
	        end
	        FightSystem:sendChangeCity(5,callFun)
	    end
	    xxx()
	elseif self.mBattleType == 3 then
		-- 
		local function callFun()
			EventSystem:PushEvent(Event.GUISYSTEM_HIDE_FIGHTWINDOW)
			EventSystem:PushEvent(Event.GUISYSTEM_HIDE_LADDERRESULTWINDOW)
			showLoadingWindow("HomeWindow")
			FightSystem.mFightType = "none"
		end
		FightSystem:sendChangeCity(false,callFun)
	else
		local function CallFun( ... )
			EventSystem:PushEvent(Event.GUISYSTEM_HIDE_FIGHTWINDOW)
			EventSystem:PushEvent(Event.GUISYSTEM_HIDE_LADDERRESULTWINDOW)
			FightSystem.mFightType = "none"
		end
		GUISystem:goTo("ladder",{self.mBattleRet,CallFun})
	end
end

function LadderResultWindow:Destroy()

	damageLIdx 		   = 1
	damageRIdx         = 1
	self.mHeroPicArr   = {}
	self.mDamageBarArr = {}

	if self.mRootNode then
		self.mRootNode:removeFromParent(true)
		self.mRootNode = nil
	end


	self.mBattleType   = nil
	self.mBattleRet    = nil
	self.mDetailArr    = {}

	CommonAnimation:clearAllTextures()
	cclog("=====LadderResultWindow:Destroy=====")

end

function LadderResultWindow:onEventHandler(event)
	if event.mAction == Event.WINDOW_SHOW then
		self:Load(event)
	elseif event.mAction == Event.WINDOW_HIDE then
		self:Destroy()
	end
end

return LadderResultWindow