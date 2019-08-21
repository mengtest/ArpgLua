-- Name: 	WorldBossResultWindow.lua
-- Func：	战斗胜利
-- Author:	WangShengdong
-- Data:	14-11-29

local WorldBossResultWindow = 
{
	mName		=	"WorldBossResultWindow",
	mIsLoaded   =   false,
	mRootNode	=	nil,
	mRootWidget	=	nil,
	mTakeCardlist = {},
	Heroexplist = {},
	mRewardCardList = {},
	mTrueCard = nil,
	mPosTurnCardList = {},
	misFlagFinishCard = false,
	mStarWait = 0.2,
	mStarScale = 0.5,
	mStarRunTime = 0.3,
	mPanel2Time = 0.5,
	mHeroRunandShow = 0.2, -- 英雄头像出现
	mShowCard = 0.5,
	mShowCardNext = 0.2,
	mTrueCardTime = 0.5, -- 后两张卡翻的时间
	mMovexishu = 5,
}

function WorldBossResultWindow:Release()
end

function WorldBossResultWindow:Load(event)
	cclog("=====WorldBossResultWindow:Load=====begin")

	self.mIsLoaded = true
	self.mRootNode = cc.Node:create()

	GUISystem:GetRootNode():addChild(self.mRootNode)
	GUISystem:enableUserInput()
	
	self.mEventData = {}
	if event.mData then
		self.mEventData[1] =  event.mData[1]
		self.mEventData[2] =  event.mData[2]
	end
	self:InitLayout2(event)
	cclog("=====WorldBossResultWindow:Load=====end")
end

function WorldBossResultWindow:InitLayout2(event)
	self.mRootWidget = GUIWidgetPool:createWidget("WorldBoss_BattleResult")
	self.mRootNode:addChild(self.mRootWidget,1000)

	self.mRootWidget:getChildByName("Image_Bg"):setPosition(getGoldFightPosition_Middle())
		-- 背景适配
	local winSize = cc.Director:getInstance():getVisibleSize()
	self.mRootWidget:getChildByName("Image_Bg"):setContentSize(cc.size(winSize.width,self.mRootWidget:getChildByName("Image_Bg"):getContentSize().height))

	self:ShowDamageDealt()

	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Panel_13"),handler(self, self.closeWindow))
	self.mIsclose = false
	self:ShowCloseText()
	GUISystem:showLoading()
end

function WorldBossResultWindow:ShowDamageDealt()
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
	local count = globaldata:getBattleFormationCount()
	local DamageMax = 0
	local TotalDamage = 0
	for i=1,count do
		local Damage = globaldata.mFriendPvpDamage[i]
		if not Damage then
			globaldata.mFriendPvpDamage[i] = 0
			Damage = 0
		end
		if DamageMax < Damage then
			DamageMax = Damage
		end
		TotalDamage = TotalDamage + Damage
	end
	for i=1,count do
		local widget = self.mRootWidget:getChildByName(string.format("Panel_Hero_%d",i))
		widget:setVisible(true)
		widget:getChildByName("Label_DamageDealt"):setString(tostring(globaldata.mFriendPvpDamage[i]))
		local data = globaldata:getBattleFormationInfoByIndex(i)
	    local Icon = createHeroIcon(data.id, data.level, data.quality, data.advanceLevel)
	    widget:getChildByName("Panel_HeroIcon"):addChild(Icon)
	    local damageBar = createDamageAnim("left","battleresults_pvp_selfhero_bar.png")
	    widget:getChildByName("Image_DamageDealt_Bg"):addChild(damageBar)
	    if DamageMax == 0 then
	    	damageBar:setPercentage(0)
	    else
	    	local actProgress = cc.ProgressTo:create(0.5, (globaldata.mFriendPvpDamage[i] / DamageMax)*100)
			damageBar:runAction(actProgress)
	    end

	end
	self.mRootWidget:getChildByName("Label_DamageTotal"):setString(tostring(TotalDamage))
	
end

function WorldBossResultWindow:ShowCloseText()
	self.mIsclose = true
	self.mRootWidget:getChildByName("Label_TouchClose_Stroke"):setVisible(true)
end

function WorldBossResultWindow:closeWindow()
	if not self.mIsclose then return end
	if FightSystem.mFightType == "arena" and globaldata.PvpType == "boss" then
		local function callFun()
			EventSystem:PushEvent(Event.GUISYSTEM_HIDE_FIGHTWINDOW)
			EventSystem:PushEvent(Event.GUISYSTEM_HIDE_WORLDBOSSRESULTWINDOW)
		end
		GUISystem:goTo("worldboss",callFun)
	end
end


function WorldBossResultWindow:Destroy()

	if not self.mIsLoaded then return end
	self.mIsLoaded = false
	self.mRootNode:removeFromParent(true)
	self.mRootNode = nil
	self.mRootWidget = nil
	---------
	CommonAnimation:clearAllTextures()
	cclog("=====WorldBossResultWindow:Destroy=====")
end

function WorldBossResultWindow:onEventHandler(event)
	if event.mAction == Event.WINDOW_SHOW then
		self:Load(event)
	elseif event.mAction == Event.WINDOW_HIDE then
		self:Destroy()
	end
end

return WorldBossResultWindow