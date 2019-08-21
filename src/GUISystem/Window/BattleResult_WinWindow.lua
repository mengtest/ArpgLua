-- Name: 	BattleResult_WinWindow.lua
-- Func：	战斗胜利
-- Author:	WangShengdong
-- Data:	14-11-29

local BattleResult_WinWindow = 
{
	mName		=	"BattleResult_WinWindow",
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

function BattleResult_WinWindow:Release()
end

function BattleResult_WinWindow:Load(event)
	cclog("=====BattleResult_WinWindow:Load=====begin")

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
	CommonAnimation.PlayEffectId(5001)
	cclog("=====BattleResult_WinWindow:Load=====end")
end

function BattleResult_WinWindow:InitLayout2(event)
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
	self.mPanelArena = self.mRootWidget:getChildByName("Panel_Arena")


	
	self.mPanel1:setVisible(true)
	self.mStars = globaldata.fubenstar
	self:showRewardStar2(globaldata.fubenstar,event)
	self.mWaitServer = false

	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Panel_13"),handler(self, self.closeWindow))
	self.mIsclose = false

	if FightSystem.mFightType == "arena" then
		if globaldata.PvpType == "arena" then
			GUISystem:showLoading()
		end
	end
end

function BattleResult_WinWindow:ShowCloseText()
	self.mIsclose = true
	self.mRootWidget:getChildByName("Label_TouchClose_Stroke"):setVisible(true)
end

function BattleResult_WinWindow:closeWindow()
	if not self.mIsclose then return end
	if self.mEventData[1] then
		self.mEventData[2]()
		EventSystem:PushEvent(Event.GUISYSTEM_HIDE_BATTLERESULT_WIN)
		return
	end
	if FightSystem.mFightType == "arena" then
		if globaldata.PvpType == "arena" then
			local function xxx()
				EventSystem:PushEvent(Event.GUISYSTEM_HIDE_FIGHTWINDOW)
				EventSystem:PushEvent(Event.GUISYSTEM_HIDE_BATTLERESULT_WIN)
			end
			GUISystem:goTo("arena", xxx)
		elseif globaldata.PvpType == "pk" then
			local function callFun()
				EventSystem:PushEvent(Event.GUISYSTEM_HIDE_FIGHTWINDOW)
				EventSystem:PushEvent(Event.GUISYSTEM_HIDE_BATTLERESULT_WIN)
				showLoadingWindow("HomeWindow")
			end
			FightSystem:sendChangeCity(false,callFun)
		elseif  globaldata.PvpType == "brave" then
			local function CallFun()
				EventSystem:PushEvent(Event.GUISYSTEM_HIDE_FIGHTWINDOW)
				EventSystem:PushEvent(Event.GUISYSTEM_HIDE_BATTLERESULT_WIN)
			end

			GUISystem:goTo("tower",{"success",CallFun})	
		elseif globaldata.PvpType == "boss" then
			local function callFun()
				EventSystem:PushEvent(Event.GUISYSTEM_HIDE_FIGHTWINDOW)
				EventSystem:PushEvent(Event.GUISYSTEM_HIDE_BATTLERESULT_WIN)
			end
			GUISystem:goTo("worldboss",callFun)
		end
		return
	elseif FightSystem.mFightType == "olpvp" then
		local function callFun()
			EventSystem:PushEvent(Event.GUISYSTEM_HIDE_FIGHTWINDOW)
			EventSystem:PushEvent(Event.GUISYSTEM_HIDE_BATTLERESULT_WIN)
			showLoadingWindow("HomeWindow")
			FightSystem.mFightType = "none"
		end
		FightSystem:sendChangeCity(false,callFun)
		return
	end

	if globaldata.showlevelup  then
		globaldata.showlevelup = false
		globaldata.wait = false
		globaldata:Showplayerlevelup()

		if globaldata.PvpType == "wealth" then
			EventSystem:PushEvent(Event.GUISYSTEM_HIDE_BATTLERESULT_WIN)
			globaldata.levelupbackwindow = "fuben"
		else
			EventSystem:PushEvent(Event.GUISYSTEM_HIDE_BATTLERESULT_WIN)
			globaldata.levelupbackwindow = "fuben"
		end
		return
	end
	if FightSystem.mFightType == "fuben" then
		if globaldata.PvpType == "wealth" then
			local function CallFun( ... )
				EventSystem:PushEvent(Event.GUISYSTEM_HIDE_FIGHTWINDOW)
				EventSystem:PushEvent(Event.GUISYSTEM_HIDE_BATTLERESULT_WIN)
			end
			GUISystem:goTo("wealth",{"success",CallFun})
		elseif globaldata.PvpType == "blackMarket" then
			local function CallFun( ... )
				EventSystem:PushEvent(Event.GUISYSTEM_HIDE_FIGHTWINDOW)
				EventSystem:PushEvent(Event.GUISYSTEM_HIDE_BATTLERESULT_WIN)
			end
			GUISystem:goTo("blackmarket",{"success",CallFun})
		elseif globaldata.PvpType == "tower" then
			local function CallFun( ... )
				EventSystem:PushEvent(Event.GUISYSTEM_HIDE_FIGHTWINDOW)
				EventSystem:PushEvent(Event.GUISYSTEM_HIDE_BATTLERESULT_WIN)
			end
			GUISystem:goTo("towerex",{"success",CallFun})
		else
			EventSystem:PushEvent(Event.GUISYSTEM_HIDE_FIGHTWINDOW)
			EventSystem:PushEvent(Event.GUISYSTEM_HIDE_BATTLERESULT_WIN)
			Event.GUISYSTEM_SHOW_PVEENTRYWINDOW.mData = {}
			Event.GUISYSTEM_SHOW_PVEENTRYWINDOW.mData[1] = globaldata.clickedlevel
			EventSystem:PushEvent(Event.GUISYSTEM_SHOW_PVEENTRYWINDOW)
		end
	end

end

function BattleResult_WinWindow:ShowStep3()
	self.mRootWidget:getChildByName("Panel_Win1"):setVisible(false)
	self.mRootWidget:getChildByName("Panel_Result"):setVisible(false)
	self.mRootWidget:getChildByName("Panel_Win2"):setVisible(false)

	local panelWin3 = self.mRootWidget:getChildByName("Panel_Win3")
	panelWin3:setVisible(true)

	local reward = self.mRootWidget:getChildByName("Panel_Win3"):getChildByName("Panel_reward")
	self:ShowConstItem(reward)
	self:ShowTurnCard(reward)
end

function BattleResult_WinWindow:ShowTurnCard(turncard)
	for i=1,globaldata.fubenbalancedata.rewardnumcount do
		local cardpos = turncard:getChildByName("Panel_TurnCard_" .. i)
		local card = TurnCardWidget.new(i)
		self.mRewardCardList[i] = card
		local itemtype = globaldata.fubenbalancedata.rewarditemlist[i].type
		local id = globaldata.fubenbalancedata.rewarditemlist[i].id
		local num = globaldata.fubenbalancedata.rewarditemlist[i].num
		local isget = globaldata.fubenbalancedata.rewarditemlist[i].isget
		if isget == 0 then
			self.mTrueCard = card
		end
		card:setItemIcon(itemtype,id,num,isget)
		card:CallTouchback(handler(self,self.TouchCallBack))
		card:setCardfront(true)
		--card:setCanTouch(true)
		cardpos:addChild(card)
		self.mPosTurnCardList[i] = cc.p(cardpos:getPositionX(),cardpos:getPositionY())
	end

	self:RunCard()
end

function BattleResult_WinWindow:RunCard()
	local function runFinish()
		for i=1,globaldata.fubenbalancedata.rewardnumcount do
			self.mRewardCardList[i]:setCanTouch(true)
		end

		local function doPos( )
			local num = math.random(1,3)

			local num1 = math.random(1,3)

			local x1 = self.mRewardCardList[num]:getParent():getPositionX()

			local x2 = self.mRewardCardList[num1]:getParent():getPositionX()
				
			self.mRewardCardList[num]:getParent():setPositionX(x2)

			self.mRewardCardList[num1]:getParent():setPositionX(x1)
		end 
		nextTick(doPos)
	end

	local function doMiddle()
		
		local function NextdoMiddle()
			for i=1,globaldata.fubenbalancedata.rewardnumcount do
			--self.mRewardCardList[i]:setCardfront(false)

				local scheduler = cc.Director:getInstance():getScheduler()
				if self.schedulerHandler then
					scheduler:unscheduleScriptEntry(self.schedulerHandler)
				end
				self.schedulerHandler = nil
				self.mRewardCardList[i]:getParent():stopAllActions()

				local pos = nil
				if i == 1 then
					pos = self.mPosTurnCardList[i]
					local act1 = cc.MoveTo:create(0.2, pos)
					local act2 = cc.CallFunc:create(runFinish)
					self.mRewardCardList[i]:getParent():runAction(cc.Sequence:create(act1, act2))
				elseif i == 3 then
					pos = self.mPosTurnCardList[i]
					local act1 = cc.MoveTo:create(0.2, pos)
					self.mRewardCardList[i]:getParent():runAction(act1)
				end
			end
		end
		nextTick(NextdoMiddle)
	end

	local function Daopai()

		local time =  {0.1,0.1,0.05,0.05,0.05,0.05,      0.05,0.05,0.05,0.05,0.1,0.1}
		local time1 = {0.05,0.05,0.05,0.05,0.05,0.05,    0.05,0.05,0.1,0.1,0.1,0.1}
		local time2 = {0.05,0.05,0.05,0.05,0.05,0.05,    0.1,0.1,0.1,0.1,0.1,0.1}

		local timeX = {time,time1,time2}

		local ra = 80
		local rb = 20

		local x2 = self.mRewardCardList[2]:getParent():getPositionX()
		local y2 = self.mRewardCardList[2]:getParent():getPositionY()

		local  actArrList = {}
		local  actArrList1 = {}
		local  actArrList2 = {}

		local  actArrListX = {actArrList,actArrList1,actArrList2}

		for i=1,2 do

			for j=1,3 do
				local mo1 = cc.MoveTo:create(timeX[j][(i-1)*6+1], cc.p(x2+ra,y2+rb))
				local scale1 = cc.ScaleTo:create(timeX[j][(i-1)*6+1], 0.95, 0.95)
				local spawn1 = cc.Spawn:create(mo1, scale1)
				table.insert( actArrListX[j], spawn1 )
			end

			for j=1,3 do
				local mo2 = cc.MoveTo:create(timeX[j][(i-1)*6+2], cc.p(x2+ra,y2+rb*2))
				local scale2 = cc.ScaleTo:create(timeX[j][(i-1)*6+2], 0.9, 0.9)
				local spawn2 = cc.Spawn:create(mo2, scale2)
				table.insert( actArrListX[j], spawn2 )
			end


			for j=1,3 do
				local mo3 = cc.MoveTo:create(timeX[j][(i-1)*6+3], cc.p(x2,y2+rb*3))
				local scale3 = cc.ScaleTo:create(timeX[j][(i-1)*6+3], 0.85, 0.85)
				local spawn3 = cc.Spawn:create(mo3, scale3)
				table.insert( actArrListX[j], spawn3 )
			end

			for j=1,3 do
				local mo4 = cc.MoveTo:create(timeX[j][(i-1)*6+4], cc.p(x2-ra,y2+rb*2))
				local scale4 = cc.ScaleTo:create(timeX[j][(i-1)*6+4], 0.9, 0.9)
				local spawn4 = cc.Spawn:create(mo4, scale4)
				table.insert( actArrListX[j], spawn4 )
			end

			for j=1,3 do
				local mo5 = cc.MoveTo:create(timeX[j][(i-1)*6+5], cc.p(x2-ra,y2+rb))
				local scale5 = cc.ScaleTo:create(timeX[j][(i-1)*6+5], 0.95, 0.95)
				local spawn5 = cc.Spawn:create(mo5, scale5)
				table.insert( actArrListX[j], spawn5 )
			end

			for j=1,3 do
				local mo6 = cc.MoveTo:create(timeX[j][(i-1)*6+6], cc.p(x2,y2))
				local scale6 = cc.ScaleTo:create(timeX[j][(i-1)*6+6], 1.0, 1.0)
				local spawn6 = cc.Spawn:create(mo6, scale6)
				table.insert( actArrListX[j], spawn6 )	
			end
		end
		local a = cc.Sequence:create(actArrListX[1])
		local b = cc.Sequence:create(actArrListX[2])
		local c = cc.Sequence:create(actArrListX[3])

		self.mRewardCardList[1]:getParent():runAction(cc.Sequence:create(a))

		local de1 = cc.DelayTime:create(0.2)
		self.mRewardCardList[2]:getParent():runAction(cc.Sequence:create(de1,b))

		local de2 = cc.DelayTime:create(0.3)
		local funcall = cc.CallFunc:create(doMiddle)
		self.mRewardCardList[3]:getParent():runAction(cc.Sequence:create(de2,c,funcall))

		local function TickZOrder()
		    for i=1,globaldata.fubenbalancedata.rewardnumcount do
		    	self.mRewardCardList[i]:getParent():setLocalZOrder(1140-self.mRewardCardList[i]:getParent():getPositionY())
		    	self.mRewardCardList[i]:getParent():setOpacity(255 - (self.mRewardCardList[i]:getParent():getPositionY() - y2) )
		    end
		end
		local scheduler = cc.Director:getInstance():getScheduler()
		self.schedulerHandler = scheduler:scheduleScriptFunc(TickZOrder, 0, false)

	end

	local function Turnover()
		for i=1,globaldata.fubenbalancedata.rewardnumcount do
			self.mRewardCardList[i]:setTurnCard()
		end
	end
	local act1t = cc.DelayTime:create(0.5)
	local act2t = cc.CallFunc:create(Turnover)
	self.mTrueCard:runAction(cc.Sequence:create(act1t, act2t))
	local function TurnCardPos()
		local act0 = cc.DelayTime:create(0.5)
		local pos = self.mPosTurnCardList[2]--cc.p(self.mPosTurnCardList[2].x,self.mPosTurnCardList[2].y)
		cclog("POS+=========="..pos.x)
		local act1 = cc.MoveTo:create(0.2, pos)
		local act2 = cc.CallFunc:create(Daopai)
		self.mRewardCardList[1]:getParent():runAction(cc.Sequence:create(act0, act1,act2))

		local act0_1 = cc.DelayTime:create(0.5)
		local act1_1 = cc.MoveTo:create(0.2, pos)
		self.mRewardCardList[3]:getParent():runAction(cc.Sequence:create(act0_1, act1_1))
	end

	local act1 = cc.DelayTime:create(1.6)
	local act2 = cc.CallFunc:create(TurnCardPos)
	self.mTrueCard:runAction(cc.Sequence:create(act1, act2))
end


function BattleResult_WinWindow:ShowPanelArenaReward()
	self.mPanelArena:getChildByName("Panel_Diamonds"):setVisible(true)

	local index = 0

	for i=1,globaldata.FubenconstRewardNum do
		local item = globaldata.FubenconstRewardList[i]
		if item.itemType ~= 9 then
			index = index + 1
			local actWidget = self.mPanelArena:getChildByName("Panel_Diamonds")
			local widget = createCommonWidget(item.itemType,item.itemId,item.itemNum)
			widget:retain()
			local function addAnimAndItem()
				-- 特效
				local animNode = AnimManager:createAnimNode(8005)
				widget:getChildByName("Panel_Animation"):addChild(animNode:getRootNode())
				animNode:play("item_born", false)

				-- 物品
				actWidget:addChild(widget)
				widget:release()
			end

			local act0 = cc.DelayTime:create(0.3*(index-1))
			local act1 = cc.CallFunc:create(addAnimAndItem)
			actWidget:runAction(cc.Sequence:create(act0, act1))
		end
	end

	local function FinishPanel4()
		self:ShowCloseText()
	end

	local actdelay1 = cc.DelayTime:create(1)
	local actcall1 = cc.CallFunc:create(FinishPanel4)

	self.mPanelArena:runAction(cc.Sequence:create(actdelay1, actcall1))
end

function BattleResult_WinWindow:ShowPanel4()

	self.mPanel4:setVisible(true)

	local function CardReward( ... )
		local zhentype = globaldata.fubenbalancedata.rewarditemlist[self.mZhenbaoindex].type 
		local zhenid = globaldata.fubenbalancedata.rewarditemlist[self.mZhenbaoindex].id 
		local zhennum = globaldata.fubenbalancedata.rewarditemlist[self.mZhenbaoindex].num
		local widget = createCommonWidget(zhentype,zhenid,zhennum)
		self.mPanel4:getChildByName("Panel_Item_1"):addChild(widget)
		local animNode = AnimManager:createAnimNode(8005)
		widget:getChildByName("Panel_Animation"):addChild(animNode:getRootNode())
		animNode:play("item_born", false)
	end
	local index = 1
	if FightSystem.mFightType == "fuben" and (globaldata.PvpType == "tower" or globaldata.PvpType == "blackMarket" or globaldata.PvpType == "wealth")  then
		index = 0
	elseif FightSystem.mFightType == "arena" and globaldata.PvpType == "arena" then
		index = 0
	else
		CardReward()
	end
	for i=1,globaldata.FubenconstRewardNum do
		local item = globaldata.FubenconstRewardList[i]
		if item.itemType ~= 9 then
			index = index + 1
			local actWidget = self.mPanel4:getChildByName("Panel_Item_"..index)
			local widget = createCommonWidget(item.itemType,item.itemId,item.itemNum)
			widget:retain()
			local function addAnimAndItem()
				-- 特效
				local animNode = AnimManager:createAnimNode(8005)
				widget:getChildByName("Panel_Animation"):addChild(animNode:getRootNode())
				animNode:play("item_born", false)

				-- 物品
				actWidget:addChild(widget)
				widget:release()
			end

			local act0 = cc.DelayTime:create(0.15*(index-1))
			local act1 = cc.CallFunc:create(addAnimAndItem)
			actWidget:runAction(cc.Sequence:create(act0, act1))
		end
	end

	local function FinishPanel4()
		self:ShowCloseText()
	end

	local actdelay1 = cc.DelayTime:create(1)
	local actcall1 = cc.CallFunc:create(FinishPanel4)

	self.mPanel4:runAction(cc.Sequence:create(actdelay1, actcall1))
end

function BattleResult_WinWindow:TouchCallBack(index)
	if self.mZhenbaoindex ~= index then
		local temptype = globaldata.fubenbalancedata.rewarditemlist[self.mZhenbaoindex].type
		local tempid = globaldata.fubenbalancedata.rewarditemlist[self.mZhenbaoindex].id
		local tempnum = globaldata.fubenbalancedata.rewarditemlist[self.mZhenbaoindex].num

		globaldata.fubenbalancedata.rewarditemlist[self.mZhenbaoindex].type = globaldata.fubenbalancedata.rewarditemlist[index].type
		globaldata.fubenbalancedata.rewarditemlist[self.mZhenbaoindex].id = globaldata.fubenbalancedata.rewarditemlist[index].id
		globaldata.fubenbalancedata.rewarditemlist[self.mZhenbaoindex].num = globaldata.fubenbalancedata.rewarditemlist[index].num

		globaldata.fubenbalancedata.rewarditemlist[index].type = temptype
		globaldata.fubenbalancedata.rewarditemlist[index].id = tempid
		globaldata.fubenbalancedata.rewarditemlist[index].num = tempnum

		self.mZhenbaoindex = index

	end

	for i=1,globaldata.fubenbalancedata.rewardnumcount do
		local itemtype = globaldata.fubenbalancedata.rewarditemlist[i].type
		local id = globaldata.fubenbalancedata.rewarditemlist[i].id
		local num = globaldata.fubenbalancedata.rewarditemlist[i].num
		local isget = globaldata.fubenbalancedata.rewarditemlist[i].isget
		self.mRewardCardList[i]:setItemIcon(itemtype,id,num,isget)
		self.mRewardCardList[i]:setCanTouch(false)
	end
	self.mRewardCardList[index]:setTurnCard(true)

	local function DoTurnCard()
		for i=1,globaldata.fubenbalancedata.rewardnumcount do
			if index ~= self.mRewardCardList[i].mIndex then
				self.mRewardCardList[i]:setTurnCard()
			end
		end
	end
	local function TurnCardFinish()
		self.mPanelCards:setVisible(false)
		self.mPanel3:setVisible(false)
		local  function show4( ... )
			self:ShowPanel4()
		end
		local act0 = cc.DelayTime:create(0.5)
		local act1 = cc.CallFunc:create(show4)
		self.mPanel3:runAction(cc.Sequence:create(act0,act1))
		
	end
	local act0 = cc.DelayTime:create(self.mTrueCardTime)
	local act1 = cc.CallFunc:create(DoTurnCard)
	local act2 = cc.DelayTime:create(0.8)
	local act3 = cc.FadeOut:create(0.2)
	local act4 = cc.CallFunc:create(TurnCardFinish)

	self.mPanelCards:runAction(cc.Sequence:create(act0,act1,act2,act3,act4))
	CommonAnimation.PlayEffectId(5002)	
end

function BattleResult_WinWindow:ShowConstItem(reward)
	reward:setPosition(getGoldFightPosition_Middle())
	for i=1,globaldata.FubenconstRewardNum do
		local item = globaldata.FubenconstRewardList[i]

		if item.itemType == 0 or item.itemType == 1 then
			local widget = createCommonWidget(item.itemType,item.itemId,item.itemNum)
			reward:getChildByName("Panel_RewardPos_"..i):addChild(widget)
		else
			if item.itemType ~= 9 then
				local backBarbg=cc.Sprite:create(getImgNameByTypeAndId(item.itemType))
	       		backBarbg:setAnchorPoint(cc.p(0,0))
	       		reward:getChildByName("Panel_RewardPos_"..i):addChild(backBarbg)
			end
		end
	end
end

function BattleResult_WinWindow:RunProgress2()
	local fubenData =  globaldata.fubenbalancedata
	for i = 1,fubenData.heroCount do
		local heroInfo    = fubenData.heroinfoList[i]
		local prelevel    = heroInfo.heropreLevel
		local afterlevel  = heroInfo.herocurLevel
		local afterexp    = heroInfo.herocurExp
		local aftermaxexp = heroInfo.herocurMaxExp
		local addExp      = heroInfo.heroaddheroExp
		local value       = (afterexp/aftermaxexp)*100
		self.Heroexplist[i]:setRunProgress(prelevel,afterlevel,value,addExp)
	end
end

function BattleResult_WinWindow:rotateWindow()
	shakeNode(self.mRootWidget:getChildByName("Panel_Win1"),5,0.05)
end

function BattleResult_WinWindow:ServerBackresult()
	if self.mWaitServer then
		GUISystem:hideLoading()
		self:ShowPanel2()
	end
end

-- 翻卡
function BattleResult_WinWindow:ShowPanelCard()
	-- 放课时间不抽卡
	if FightSystem.mFightType == "fuben" and (globaldata.PvpType == "wealth" or globaldata.PvpType == "blackMarket" ) then
		self.mPanel3:setVisible(false)
		self:ShowPanel4()
		return
	end
	self.mPanelCards:setVisible(true)
	local card1 = self.mPanelCards:getChildByName("Panel_Card_1")
	local card2 = self.mPanelCards:getChildByName("Panel_Card_2")
	local card3 = self.mPanelCards:getChildByName("Panel_Card_3")

	for i=1,globaldata.fubenbalancedata.rewardnumcount do
		local cardpos = self.mPanelCards:getChildByName(string.format("Panel_Card_%d",i))
		local card = TurnCardWidget.new(i)
		self.mRewardCardList[i] = card
		local itemtype = globaldata.fubenbalancedata.rewarditemlist[i].type
		local id = globaldata.fubenbalancedata.rewarditemlist[i].id
		local num = globaldata.fubenbalancedata.rewarditemlist[i].num
		local isget = globaldata.fubenbalancedata.rewarditemlist[i].isget
		if isget == 0 then
			self.mZhenbaoindex = i
		end
		card:CallTouchback(handler(self,self.TouchCallBack))
		card:setCardfront(false)
		card:setCanTouch(false)
		card:setVisible(false)
		cardpos:addChild(card)
		self.mPosTurnCardList[i] = cc.p(cardpos:getPositionX(),cardpos:getPositionY())
	end

	local function playCard1()
		local function Finish(evt)
			if evt == "1" then
				self.mRewardCardList[1]:setVisible(true)
			end
		end
		local star = AnimManager:createAnimNode(8036)
		card1:getChildByName("Panel_AnimationCard"):addChild(star:getRootNode(), 100)
		star:play("battleresults_card",false,nil,Finish)
	end

	local function playCard2()
		local function Finish( evt )
			if evt == "1" then
				self.mRewardCardList[2]:setVisible(true)
			end
		end
		local star = AnimManager:createAnimNode(8036)
		card2:getChildByName("Panel_AnimationCard"):addChild(star:getRootNode(), 100)
		star:play("battleresults_card",false,nil,Finish)
	end

	local function playCard3()
		local function playStarFinish()
			self.mPanelCards:getChildByName("Label_Notice_Stroke"):setVisible(true)
			for k,v in pairs(self.mRewardCardList) do
				v:setCanTouch(true)
			end
		end
		local function Finish(evt)
			if evt == "1" then
				self.mRewardCardList[3]:setVisible(true)
			end
		end
		local star = AnimManager:createAnimNode(8036)
		card3:getChildByName("Panel_AnimationCard"):addChild(star:getRootNode(), 100)
		star:play("battleresults_card",false,playStarFinish,Finish)
	end
	local Actionlist = {}
	local actplay1 = cc.CallFunc:create(playCard1)
	table.insert(Actionlist,actplay1)
	local delay1 = cc.DelayTime:create(self.mShowCardNext)
	local actplay2 = cc.CallFunc:create(playCard2)
	table.insert(Actionlist,delay1)
	table.insert(Actionlist,actplay2)
	local delay2 = cc.DelayTime:create(self.mShowCardNext)
	local actplay3 = cc.CallFunc:create(playCard3)
	table.insert(Actionlist,delay2)
	table.insert(Actionlist,actplay3)
	self.mPanelCards:runAction(cc.Sequence:create(Actionlist))

end

-- 英雄头像
function BattleResult_WinWindow:ShowPanel3()
	self.mPanel3:setVisible(true)
	local fubenData = globaldata.fubenbalancedata
	local function RiseOver()
		for i = 1, fubenData.heroCount do
			local widget = self.mPanel3:getChildByName(string.format("Panel_Hero_%d",i))
			widget:getChildByName("Image_HeroEXP_Bg"):setVisible(true)
			widget:getChildByName("Label_EXP"):setVisible(true)
		end
		self:RunProgress2()
		local delay1 = cc.DelayTime:create((self.mShowCard+1)/2)
    	local callfun1 = cc.CallFunc:create(handler(self,self.ShowPanelCard))
		self.mPanel1:runAction(cc.Sequence:create(delay1,callfun1))

	end
	for i = 1, fubenData.heroCount do
		local widget = self.mPanel3:getChildByName(string.format("Panel_Hero_%d",i))
		local heroInfo = fubenData.heroinfoList[i]
		local heroId   = heroInfo.heroid
		local level    = heroInfo.heropreLevel
		local exp      = heroInfo.heropreExp
		local MaxExp   = heroInfo.heropreMaxExp
		local value    = (exp/MaxExp)*100
		local hero     = HeroExpWidget.new(widget,heroId,level,value)
		self.Heroexplist[i] = hero
		widget:addChild(hero)
		widget:setVisible(true)
		widget:getChildByName("Image_HeroEXP_Bg"):setVisible(false)
		widget:getChildByName("Label_EXP"):setVisible(false)
	end
	local point = self.mPanel3:getChildByName("Panel_HeroPoint_1")
	local point2 = self.mPanel3:getChildByName("Panel_HeroPoint_2")
	point:setVisible(true)
    point:setOpacity(0)
    local actionTo1 = cc.FadeIn:create(self.mHeroRunandShow)
    local moveTo1 = cc.MoveTo:create(self.mHeroRunandShow,cc.p(point2:getPositionX(),point2:getPositionY()))
    local delay1 = cc.DelayTime:create(self.mHeroRunandShow)
    local callfun = cc.CallFunc:create(RiseOver)
    point:runAction(cc.Sequence:create(cc.Spawn:create(actionTo1,moveTo1),delay1,callfun))
end

-- 经验和金币
function BattleResult_WinWindow:ShowPanel2()
	if FightSystem.mFightType == "fuben" and globaldata.PvpType == "blackMarket" then
		self:ShowPanel4()
		return
	elseif FightSystem.mFightType == "fuben" and globaldata.PvpType == "tower" then
		self:ShowPanel4()
		return
	elseif FightSystem.mFightType == "arena" and globaldata.PvpType == "arena" then
		self:Show1V1()
		return
	end
	self.mPanel2:setVisible(true)
	self.mPanel2:getChildByName("Label_EXP_Stroke"):setString(tostring(globaldata.fubenbalancedata.addPlayerExp))
	self.mPanel2:getChildByName("Label_Gold_Stroke"):setString(tostring(globaldata.fubenbalancedata.money))
	local delay = cc.DelayTime:create(self.mPanel2Time)
	local actplay2 = cc.CallFunc:create(handler(self,self.ShowPanel3))
	self.mPanel2:runAction(cc.Sequence:create(delay,actplay2))

end

function BattleResult_WinWindow:WaitServerResult()
	if FightSystem:GetFightManager().mSendresult == "back" then
		self:ShowPanel2()
	else
		GUISystem:showLoading()
		self.mWaitServer = true
	end
end

function BattleResult_WinWindow:Show1V1()
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

	if globaldata.ArenaReward == 1 then
		local function ShowOver()
			self.mPanelPVP1v1:setVisible(false)
			self.mPanelArena:setVisible(true)
			if globaldata.oldHighRank == 0 then
				self.mPanelArena:getChildByName("Panel_ArenaRanking_First"):setVisible(true)
				self.mPanelArena:getChildByName("Panel_ArenaRanking_First"):getChildByName("Label_Rangking_Stroke"):setString(tostring(globaldata.newHighRank))
			else
				self.mPanelArena:getChildByName("Panel_ArenaRanking"):setVisible(true)
				self.mPanelArena:getChildByName("Panel_ArenaRanking"):getChildByName("Label_Rangking1_Stroke"):setString(tostring(globaldata.oldHighRank))
				self.mPanelArena:getChildByName("Panel_ArenaRanking"):getChildByName("Label_Rangking2_Stroke"):setString(tostring(globaldata.newHighRank))
			end
			self:ShowPanelArenaReward()
		end
		local act1t = cc.DelayTime:create(1)
		local act2t = cc.CallFunc:create(ShowOver)
		self.mFriendInfo:runAction(cc.Sequence:create(act1t,act2t))
	else
		self:ShowCloseText()
	end


end

function BattleResult_WinWindow:showRewardStar2(starts,event)
	local function RunOver()
		if FightSystem.mFightType == "arena" and globaldata.PvpType == "arena" then
			if FightSystem:GetFightManager().mSendresult == "back" then
				self:Show1V1()
			else
				GUISystem:showLoading()
				self.mWaitServer = true
			end
			return
		end
		if FightSystem.mFightType == "fuben" and globaldata.PvpType == "blackMarket" then
			self:WaitServerResult()
			return
		end
		if FightSystem.mFightType == "fuben" and globaldata.PvpType == "tower" then
			self:WaitServerResult()
			return
		end
		local function PlayGuangxian()
			local guangxian = AnimManager:createAnimNode(8035)
			local function GuangxianOver()
				guangxian:play("battleresults_lightline_2",true)
				self:WaitServerResult()
			end
			
			self.mPanel1:getChildByName("Panel_LightBg"):addChild(guangxian:getRootNode(), 100)
			guangxian:play("battleresults_lightline_1",false,GuangxianOver)
		end	
		PlayGuangxian()
	end
	local function MoveXingxing()

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
		self.mPanel1:getChildByName("Panel_Wings_1"):runAction(cc.Sequence:create(EaseInmove,actplay1))
		self.mPanel1:getChildByName("Panel_Star_1_1"):runAction(cc.Sequence:create(EaseInmove1))
		self.mPanel1:getChildByName("Panel_Star_2_1"):runAction(cc.Sequence:create(EaseInmove2))
		self.mPanel1:getChildByName("Panel_Star_3_1"):runAction(cc.Sequence:create(EaseInmove3))

	end
	local function playStar1()
		local star = AnimManager:createAnimNode(8034)
		local function playStarFinish()
			star:play("battleresults_star_2",true)
			if self.mStars == 1 then
				MoveXingxing()
			end
		end
		self.mPanel1:getChildByName("Panel_Star_1_1"):addChild(star:getRootNode(), 100)
		star:play("battleresults_star_1",false,playStarFinish)
	end

	local function playStar2()
		local star = AnimManager:createAnimNode(8034)
		local function playStarFinish()
			star:play("battleresults_star_2",true)
			if self.mStars == 2 then
				MoveXingxing()
			end
		end
		self.mPanel1:getChildByName("Panel_Star_2_1"):addChild(star:getRootNode(), 100)
		star:play("battleresults_star_1",false,playStarFinish)
	end

	local function playStar3()
		local star = AnimManager:createAnimNode(8034)
		local function playStarFinish()
			star:play("battleresults_star_2",true)
			if self.mStars == 3 then
				MoveXingxing()
			end
		end
		self.mPanel1:getChildByName("Panel_Star_3_1"):addChild(star:getRootNode(), 100)
		star:play("battleresults_star_1",false,playStarFinish)
	end
	local function ChibangFinish()
		--闯关星星完事直接结束
		self.ChibangNode:play("battleresults_win_2",true)
		if self.mEventData[1] then
			if self.mEventData[1] then
				self:ShowCloseText()
			end
			return
		end
		if FightSystem.mFightType == "arena" and globaldata.PvpType == "brave" then
			self:ShowCloseText()
			return 
		elseif FightSystem.mFightType == "arena" and globaldata.PvpType == "boss" then
			self:ShowCloseText()
			return 
		elseif FightSystem.mFightType == "fuben" and globaldata.PvpType == "wealth" then
			local pos1 = self.mPanel1:getChildByName("Panel_Wings_2")
			local move = cc.MoveTo:create(self.mStarRunTime, cc.p(pos1:getPositionX(),pos1:getPositionY()))
			local EaseInmove = cc.EaseIn:create(move, self.mMovexishu)
			local actplay1 = cc.CallFunc:create(RunOver)
			self.mPanel1:getChildByName("Panel_Wings_1"):runAction(cc.Sequence:create(move,actplay1))
			return
		elseif FightSystem.mFightType == "fuben" and globaldata.PvpType == "blackMarket" then
			local pos1 = self.mPanel1:getChildByName("Panel_Wings_2")
			local move = cc.MoveTo:create(self.mStarRunTime, cc.p(pos1:getPositionX(),pos1:getPositionY()))
			local EaseInmove = cc.EaseIn:create(move, self.mMovexishu)
			local actplay1 = cc.CallFunc:create(RunOver)
			self.mPanel1:getChildByName("Panel_Wings_1"):runAction(cc.Sequence:create(move,actplay1))
			return
		elseif FightSystem.mFightType == "fuben" and globaldata.PvpType == "tower" then
			local pos1 = self.mPanel1:getChildByName("Panel_Wings_2")
			local move = cc.MoveTo:create(self.mStarRunTime, cc.p(pos1:getPositionX(),pos1:getPositionY()))
			local EaseInmove = cc.EaseIn:create(move, self.mMovexishu)
			local actplay1 = cc.CallFunc:create(RunOver)
			self.mPanel1:getChildByName("Panel_Wings_1"):runAction(cc.Sequence:create(move,actplay1))
			return 
		elseif FightSystem.mFightType == "arena" and globaldata.PvpType == "arena" then
			local pos1 = self.mPanel1:getChildByName("Panel_Wings_2")
			local move = cc.MoveTo:create(self.mStarRunTime, cc.p(pos1:getPositionX(),pos1:getPositionY()))
			local EaseInmove = cc.EaseIn:create(move, self.mMovexishu)
			local actplay1 = cc.CallFunc:create(RunOver)
			self.mPanel1:getChildByName("Panel_Wings_1"):runAction(cc.Sequence:create(move,actplay1))
			return
		end
		-- 开始第一个星星
		for i=1,3 do
			self.mPanel1:getChildByName(string.format("Panel_Star_%d_1",i)):setVisible(true)
		end

		if FightSystem.mFightType == "fuben" and globaldata.PvpType == "fuben" then
			local IndexS = 1
			self.mPanel1:getChildByName(string.format("Panel_Star_%d_1",IndexS)):getChildByName("Label_Text"):setString(getDictionaryText(FightSystem:GetFightManager().mSanxingText[1]))
			if FightSystem:GetFightManager().SanxingResult[1] ~= 0 then
				IndexS = IndexS + 1
				self.mPanel1:getChildByName(string.format("Panel_Star_%d_1",IndexS)):getChildByName("Label_Text"):setString(getDictionaryText(FightSystem:GetFightManager().mSanxingText[2]))
			else
				IndexS = 1
				self.mPanel1:getChildByName(string.format("Panel_Star_%d_1",3)):getChildByName("Label_Text"):setString(getDictionaryText(FightSystem:GetFightManager().mSanxingText[2]))
			end
			IndexS = IndexS + 1
			self.mPanel1:getChildByName(string.format("Panel_Star_%d_1",IndexS)):getChildByName("Label_Text"):setString(getDictionaryText(FightSystem:GetFightManager().mSanxingText[3]))
			
		end


		local Actionlist = {}

			if self.mStars == 1 then
				local actplay1 = cc.CallFunc:create(playStar1)
				table.insert(Actionlist,actplay1)
			elseif self.mStars == 2 then
				local actplay1 = cc.CallFunc:create(playStar1)
				table.insert(Actionlist,actplay1)
				local delay = cc.DelayTime:create(self.mStarWait)
				local actplay2 = cc.CallFunc:create(playStar2)
				table.insert(Actionlist,delay)
				table.insert(Actionlist,actplay2)
			elseif self.mStars == 3 then
				local actplay1 = cc.CallFunc:create(playStar1)
				table.insert(Actionlist,actplay1)
				local delay1 = cc.DelayTime:create(self.mStarWait)
				local actplay2 = cc.CallFunc:create(playStar2)
				table.insert(Actionlist,delay1)
				table.insert(Actionlist,actplay2)
				local delay2 = cc.DelayTime:create(self.mStarWait)
				local actplay3 = cc.CallFunc:create(playStar3)
				table.insert(Actionlist,delay2)
				table.insert(Actionlist,actplay3)
			end
		self.mPanel1:getChildByName("Panel_Wings_1"):runAction(cc.Sequence:create(Actionlist))
	end
	self.ChibangNode = AnimManager:createAnimNode(8033)
	self.mPanel1:getChildByName("Panel_Wings_1"):addChild(self.ChibangNode:getRootNode(), 100)
	self.ChibangNode:play("battleresults_win_1",false,ChibangFinish)
end

function BattleResult_WinWindow:Destroy()

	if not self.mIsLoaded then return end
	self.mIsLoaded = false
	self.mRootNode:removeFromParent(true)
	self.mRootNode = nil
	self.mRootWidget = nil
	self.mTakeCardlist = {}
	self.Heroexplist = {}
	self.mRewardCardList = {}
	self.mTrueCard = nil
	self.mPosTurnCardList = {}
	self.misFlagFinishCard = false
	self.mWaitServer = nil
	---------
	CommonAnimation:clearAllTextures()
	cclog("=====BattleResult_WinWindow:Destroy=====")
end

function BattleResult_WinWindow:onEventHandler(event)
	if event.mAction == Event.WINDOW_SHOW then
		self:Load(event)
	elseif event.mAction == Event.WINDOW_HIDE then
		self:Destroy()
	end
end

return BattleResult_WinWindow