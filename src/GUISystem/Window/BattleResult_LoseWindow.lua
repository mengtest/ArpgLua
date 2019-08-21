-- Name: 	BattleResult_LoseWindow.lua
-- Func：	战斗失败
-- Author:	WangShengdong
-- Data:	14-11-29

local BattleResult_LoseWindow = 
{
	mName		=	"BattleResult_LoseWindow",
	mRootNode	=	nil,
	mRootWidget	=	nil,
	mIsLoaded = false,
	mStarRunTime = 0.3,
	mMovexishu = 5,
}

function BattleResult_LoseWindow:Release()
end

function BattleResult_LoseWindow:Load(event)
	cclog("=====BattleResult_LoseWindow:Load=====begin")
	self.mIsLoaded = true
	self.mRootNode = cc.Node:create()
	GUISystem:GetRootNode():addChild(self.mRootNode)
	
	self.mEventData = {}
	if event.mData then
		self.mEventData[1] =  event.mData[1]
		self.mEventData[2] =  event.mData[2]
	end
	self:InitLayout2()
	CommonAnimation.PlayEffectId(5003)
	cclog("=====BattleResult_LoseWindow:Load=====end")
end

function BattleResult_LoseWindow:InitLayout2()
	self.mChibangeffectId = 8039
	self.mChibangeffect1 = "battleresults_lose_1"
	self.mChibangeffect2 = "battleresults_lose_2"

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
	self.mPanelLoseJump = self.mRootWidget:getChildByName("Panel_LoseJump")
	registerWidgetReleaseUpEvent(self.mPanelLoseJump:getChildByName("Button_ToHero"),handler(self, self.gotoHero))
	registerWidgetReleaseUpEvent(self.mPanelLoseJump:getChildByName("Button_ToEquip"),handler(self, self.gotoEquip))
	registerWidgetReleaseUpEvent(self.mPanelLoseJump:getChildByName("Button_ToTech"),handler(self, self.gotoTech))
	registerWidgetReleaseUpEvent(self.mPanelLoseJump:getChildByName("Button_ToSkill"),handler(self, self.gotoSkill))
	registerWidgetReleaseUpEvent(self.mPanelLoseJump:getChildByName("Button_ToBadge"),handler(self, self.gotoBadge))

	self.mPanelLoseJump:getChildByName("Button_ToHero"):loadTextureNormal("home_icon_herolist.png",1)
	self.mPanelLoseJump:getChildByName("Button_ToEquip"):loadTextureNormal("home_icon_equip.png",1)
	self.mPanelLoseJump:getChildByName("Button_ToTech"):loadTextureNormal("home_icon_technology.png",1)
	self.mPanelLoseJump:getChildByName("Button_ToSkill"):loadTextureNormal("home_icon_skill.png",1)
	self.mPanelLoseJump:getChildByName("Button_ToBadge"):loadTextureNormal("home_icon_badge.png",1)

	self.mPanel1:setVisible(true)
	self:showRewardStar2(event)
	self.mWaitServer = false

	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Panel_13"),handler(self, self.closeWindow))
	self.mIsclose = false
end

function BattleResult_LoseWindow:ShowCloseText()
	self.mIsclose = true
	self.mRootWidget:getChildByName("Label_TouchClose_Stroke"):setVisible(true)
end

function BattleResult_LoseWindow:gotoHero()
	EventSystem:PushEvent(Event.GUISYSTEM_HIDE_FIGHTWINDOW)
	EventSystem:PushEvent(Event.GUISYSTEM_SHOW_HEROINFOWINDOW,handler(self,self.closeWindow))
end

function BattleResult_LoseWindow:gotoEquip()
	EventSystem:PushEvent(Event.GUISYSTEM_HIDE_FIGHTWINDOW)
	EventSystem:PushEvent(Event.GUISYSTEM_SHOW_EQUIPINFOWINDOW,handler(self,self.closeWindow))
end

function BattleResult_LoseWindow:gotoTech()
	local function fun2( ... )
		EventSystem:PushEvent(Event.GUISYSTEM_HIDE_FIGHTWINDOW)
	end
	GUISystem:goTo("technology",handler(self,self.closeWindow),fun2)
end

function BattleResult_LoseWindow:gotoSkill()
	EventSystem:PushEvent(Event.GUISYSTEM_HIDE_FIGHTWINDOW)
	EventSystem:PushEvent(Event.GUISYSTEM_SHOW_HEROSKILLWINDOW,handler(self,self.closeWindow))
end

function BattleResult_LoseWindow:gotoBadge()
	local function fun2( ... )
		EventSystem:PushEvent(Event.GUISYSTEM_HIDE_FIGHTWINDOW)
	end
	GUISystem:goTo("badge",handler(self,self.closeWindow),fun2)
end

function BattleResult_LoseWindow:Show1V1()
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
	self.mFriendInfo:getChildByName("Label_PlayerName"):setString(globaldata:getPlayerBaseData("name"))
	self.mEnemyInfo:getChildByName("Label_PlayerName"):setString(globaldata.ArenaEnemyName)
	globaldata.mPvpDamageMax = 0
	for i=1,3 do
	    local panel = self.mFriendInfo:getChildByName(string.format("Panel_Hero_%d",i))
	    if globaldata:getBattleFormationInfoByIndex(i) then
	        local data = globaldata:getBattleFormationInfoByIndex(i)
	        local Icon = createHeroIcon(data.id, data.level, data.quality, data.advanceLevel)
	        panel:getChildByName("Panel_HeroIcon"):addChild(Icon)
	        local damageBar = createDamageAnim("left","battleresults_pvp_selfhero_bar.png")
	        self.mFriendDamageBarArr[i] = damageBar
	        panel:getChildByName("Image_DamageDealt_Bg"):addChild(damageBar)
	        if not globaldata.mFriendPvpDamage then
	        	globaldata.mFriendPvpDamage = {}
	        end
	        if not globaldata.mFriendPvpDamage[i] then
	        	globaldata.mFriendPvpDamage[i] = {}
	        	globaldata.mFriendPvpDamage[i].Damage = 0
	        end
	        globaldata.mFriendPvpDamage[i].Damage =  math.ceil(globaldata.mFriendPvpDamage[i].Damage)
	        panel:getChildByName("Label_DamageDealt"):setString(tostring(globaldata.mFriendPvpDamage[i].Damage))
	    end
	    if globaldata.mPvpDamageMax < globaldata.mFriendPvpDamage[i].Damage then
			globaldata.mPvpDamageMax = globaldata.mFriendPvpDamage[i].Damage
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

	        if not globaldata.mEnemyPvpDamage then
	        	globaldata.mEnemyPvpDamage = {}
	        end
	        if not globaldata.mEnemyPvpDamage[i] then
	        	globaldata.mEnemyPvpDamage[i] = {}
	        	globaldata.mEnemyPvpDamage[i].Damage = 0
	        end
	        globaldata.mEnemyPvpDamage[i].Damage =  math.ceil(globaldata.mEnemyPvpDamage[i].Damage)
	        panel:getChildByName("Label_DamageDealt"):setString(tostring(globaldata.mEnemyPvpDamage[i].Damage))
	    end
	    if globaldata.mPvpDamageMax < globaldata.mEnemyPvpDamage[i].Damage then
			globaldata.mPvpDamageMax = globaldata.mEnemyPvpDamage[i].Damage
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

-- 显示跳转按钮
function BattleResult_LoseWindow:ShowJumpBtn()
	if globaldata:getPlayerBaseData("level") < 4 then
		self.mPanelLoseJump:getChildByName("Panel_ToHero"):setVisible(true)
	elseif globaldata:getPlayerBaseData("level") < 6 then
		self.mPanelLoseJump:getChildByName("Panel_ToHero"):setVisible(true)
		self.mPanelLoseJump:getChildByName("Panel_ToSkill"):setVisible(true)
	elseif globaldata:getPlayerBaseData("level") < 33 then
		self.mPanelLoseJump:getChildByName("Panel_ToHero"):setVisible(true)
		self.mPanelLoseJump:getChildByName("Panel_ToSkill"):setVisible(true)
		self.mPanelLoseJump:getChildByName("Panel_ToEquip"):setVisible(true)
	elseif globaldata:getPlayerBaseData("level") < 39 then
		self.mPanelLoseJump:getChildByName("Panel_ToHero"):setVisible(true)
		self.mPanelLoseJump:getChildByName("Panel_ToSkill"):setVisible(true)
		self.mPanelLoseJump:getChildByName("Panel_ToEquip"):setVisible(true)
		self.mPanelLoseJump:getChildByName("Panel_ToBadge"):setVisible(true)
	elseif globaldata:getPlayerBaseData("level") >=39 then
		self.mPanelLoseJump:getChildByName("Panel_ToHero"):setVisible(true)
		self.mPanelLoseJump:getChildByName("Panel_ToSkill"):setVisible(true)
		self.mPanelLoseJump:getChildByName("Panel_ToEquip"):setVisible(true)
		self.mPanelLoseJump:getChildByName("Panel_ToBadge"):setVisible(true)
		self.mPanelLoseJump:getChildByName("Panel_ToTech"):setVisible(true)
	end

end

function BattleResult_LoseWindow:showRewardStar2(event)
	local function RunOver()
		if FightSystem.mFightType == "fuben" then
			if globaldata.PvpType == "tower" then
				self:ShowCloseText()
				self:ShowJumpBtn()
				self.mPanelLoseJump:setVisible(true)
				return
			end
			self:ShowCloseText()
			if not globaldata:isSectionVisited(1,1,3) then
				self.mPanelLoseJump:setVisible(false)
			else
				self:ShowJumpBtn()
				self.mPanelLoseJump:setVisible(true)
			end
			
		elseif FightSystem.mFightType == "arena" then
			if globaldata.PvpType == "arena" then
				self:ShowCloseText()
				self:Show1V1()
			elseif globaldata.PvpType == "brave" then
				self:ShowCloseText()
				self:ShowJumpBtn()
				self.mPanelLoseJump:setVisible(true)
			elseif globaldata.PvpType == "boss" then
				self:ShowCloseText()
			end
		end
	end
	local function ChibangFinish()
		--闯关星星完事直接结束
		if self.mEventData[1] then
			if self.mEventData[1] then
				self:ShowCloseText()
			end
			return
		end
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

function BattleResult_LoseWindow:Restart()
	if not globaldata:getTiligotoBattle() then return end
	EventSystem:PushEvent(Event.GUISYSTEM_HIDE_BATTLERESULT_LOSE)
	globaldata:requestEnterBattle()	
	FightSystem:reloadFightWindow()
end

function BattleResult_LoseWindow:closeWindow()
	if not self.mIsclose then return end
	if self.mEventData[1] then
		self.mEventData[2]()
		EventSystem:PushEvent(Event.GUISYSTEM_HIDE_BATTLERESULT_LOSE)
		return
	end
	if FightSystem.mFightType == "fuben" then
		local function CallFun1()
			EventSystem:PushEvent(Event.GUISYSTEM_HIDE_FIGHTWINDOW)
			EventSystem:PushEvent(Event.GUISYSTEM_HIDE_BATTLERESULT_LOSE)
		end
		if globaldata.PvpType == "wealth" then
			GUISystem:goTo("wealth",{"fail",CallFun1})
		elseif globaldata.PvpType == "blackMarket" then
			GUISystem:goTo("blackmarket",{"fail",CallFun1})
		elseif globaldata.PvpType == "tower" then
			GUISystem:goTo("towerex",{"fail",CallFun1})
		else
			CallFun1()
			Event.GUISYSTEM_SHOW_PVEENTRYWINDOW.mData = {}
			Event.GUISYSTEM_SHOW_PVEENTRYWINDOW.mData[1] = globaldata.clickedlevel
			EventSystem:PushEvent(Event.GUISYSTEM_SHOW_PVEENTRYWINDOW)
		end

	elseif FightSystem.mFightType == "arena" then
		if globaldata.PvpType == "arena" then
			local function xxx()
				EventSystem:PushEvent(Event.GUISYSTEM_HIDE_FIGHTWINDOW)
				EventSystem:PushEvent(Event.GUISYSTEM_HIDE_BATTLERESULT_LOSE)
			end
			GUISystem:goTo("arena",xxx)
		elseif globaldata.PvpType == "pk" then
			local function callFun()
				EventSystem:PushEvent(Event.GUISYSTEM_HIDE_FIGHTWINDOW)
				EventSystem:PushEvent(Event.GUISYSTEM_HIDE_BATTLERESULT_LOSE)
				showLoadingWindow("HomeWindow")
			end
			FightSystem:sendChangeCity(false,callFun)
		elseif globaldata.PvpType == "brave" then
			local function callFun()
				EventSystem:PushEvent(Event.GUISYSTEM_HIDE_FIGHTWINDOW)
				EventSystem:PushEvent(Event.GUISYSTEM_HIDE_BATTLERESULT_LOSE)
			end
			GUISystem:goTo("tower",{"fail",callFun})
		elseif globaldata.PvpType == "boss" then
			local function callFun()
				EventSystem:PushEvent(Event.GUISYSTEM_HIDE_FIGHTWINDOW)
				EventSystem:PushEvent(Event.GUISYSTEM_HIDE_BATTLERESULT_LOSE)
			end
			GUISystem:goTo("worldboss",callFun)
		end
		return
	elseif FightSystem.mFightType == "olpvp" then
		local function callFun()
			EventSystem:PushEvent(Event.GUISYSTEM_HIDE_FIGHTWINDOW)
			EventSystem:PushEvent(Event.GUISYSTEM_HIDE_BATTLERESULT_LOSE)
			showLoadingWindow("HomeWindow")
			FightSystem.mFightType = "none"
		end
		FightSystem:sendChangeCity(false,callFun)
	end
end

function BattleResult_LoseWindow:Destroy()
	if not self.mIsLoaded then return end
	self.mIsLoaded = false
	self.mRootNode:removeFromParent(true)
	self.mRootNode = nil
	self.mRootWidget = nil
	CommonAnimation:clearAllTextures()
	cclog("=====BattleResult_LoseWindow:Destroy=====")
end

function BattleResult_LoseWindow:onEventHandler(event)
	if event.mAction == Event.WINDOW_SHOW then
		self:Load(event)
	elseif event.mAction == Event.WINDOW_HIDE then
		self:Destroy()
	end
end

return BattleResult_LoseWindow