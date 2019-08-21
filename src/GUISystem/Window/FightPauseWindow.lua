-- Name: 	FightPauseWindow
-- Func：	暂停界面
-- Author:	Long
-- Data:	15-01-21

local FightPauseWindow = 
{
	mName 				= "FightPauseWindow",
	mIsLoaded   		=   false,
	mRootNode			=	nil,	
	mRootWidget 		= 	nil,
	mPrevWin			=   nil,
}

function FightPauseWindow:Release()
end


function FightPauseWindow:Load(event)
	cclog("=====FightPauseWindow:Load=====begin")

	self.mIsLoaded =   true
	self.mPrevWin  = event.mData
	self.mRootNode = cc.Node:create()
	GUISystem:GetRootNode():addChild(self.mRootNode)
	self:InitLayout(event)

	cclog("=====FightPauseWindow:Load=====end")
end

function FightPauseWindow:InitLayout()	
   	self.mRootWidget = GUIWidgetPool:createWidget("FightPause")
	self.mRootNode:addChild(self.mRootWidget)

	local btlStart = self.mRootWidget:getChildByName("Button_FightPause_resume")
	registerWidgetReleaseUpEvent(btlStart, handler(self, self.FightResume))

	local btagain = self.mRootWidget:getChildByName("Button_FightPause_again")
	registerWidgetReleaseUpEvent(btagain, handler(self, self.FightAgain))

	local btexit = self.mRootWidget:getChildByName("Button_FightPause_exitgame")
	registerWidgetReleaseUpEvent(btexit, handler(self, self.FightExit))

	self.mTouchMove = self.mRootWidget:getChildByName("Image_Move_1")
	registerWidgetReleaseUpEvent(self.mTouchMove, handler(self, self.onMoveTypeMove))

	self.mTouchFix = self.mRootWidget:getChildByName("Image_Move_2")
	registerWidgetReleaseUpEvent(self.mTouchFix, handler(self, self.onMoveTypeFix))

	if FightSystem:isEnabledAdvancedJoystick() then
		self.mTouchMove:loadTexture("public_checkbox1.png")
	else
		self.mTouchFix:loadTexture("public_checkbox1.png")
	end

	if not globaldata:isSectionVisited(1,1,1) then
		ShaderManager:DoUIWidgetDisabled(btexit, true)
    	btexit:setEnabled(false)
	end
	if (FightSystem.mFightType == "fuben" and globaldata.PvpType == "blackMarket") or (FightSystem.mFightType == "arena" and globaldata.PvpType == "boss") then
		ShaderManager:DoUIWidgetDisabled(btagain, true)
    	btagain:setEnabled(false)
	end

	local function doAdapter()
		-- 背景适配
		local winSize = cc.Director:getInstance():getVisibleSize()
		local oldSize = self.mRootWidget:getChildByName("Image_Bg"):getContentSize()
		oldSize.width = winSize.width
		self.mRootWidget:getChildByName("Image_Bg"):setContentSize(oldSize)
	end
	doAdapter()

end

function FightPauseWindow:FightResume()
	EventSystem:PushEvent(Event.GUISYSTEM_HIDE_FIGHTPAUSEWINDOW)
	if self.mPrevWin ~= WINDOW_FROM.GAME then
		GameApp:Resume()
	end
end

function FightPauseWindow:FightAgain()
	EventSystem:PushEvent(Event.GUISYSTEM_HIDE_BATTLERESULT_WIN)
	EventSystem:PushEvent(Event.GUISYSTEM_HIDE_BATTLERESULT_LOSE)
	if self.mPrevWin == WINDOW_FROM.GAME then 
		GUISystem.Windows["Game2048Window"]:gameInit()
		EventSystem:PushEvent(Event.GUISYSTEM_HIDE_FIGHTPAUSEWINDOW)
	else
		FightSystem:setGameSpeedScale(1)
		GameApp:Resume()
		if FightSystem.mFightType == "fuben" then
			if globaldata.PvpType == "wealth" then
				EventSystem:PushEvent(Event.GUISYSTEM_HIDE_FIGHTPAUSEWINDOW)
				if globaldata:doWealthBattleRequest(globaldata.wealthBattleHeros) == 0 then -- 添加globaldata.battleHeroIdTbl参数 by wangsd 2015-11-26
					globaldata.fightagain = true
				end
			elseif globaldata.PvpType == "tower" then
				EventSystem:PushEvent(Event.GUISYSTEM_HIDE_FIGHTPAUSEWINDOW)
				globaldata:doTowerExBattleRequest(globaldata.towerExBattleHeros)
				globaldata.fightagain = true
			else
				if not globaldata:getTiligotoBattle() then return end
				local fubentype = "fb%d-%d"
				if globaldata.clickedlevel == 2 then
					fubentype = "fbjy%d-%d"
				end
				local key = string.format(fubentype,globaldata.clickedchapter,globaldata.clickedsection)
				AnySDKManager:td_task_fail(key, "restart")
				EventSystem:PushEvent(Event.GUISYSTEM_HIDE_FIGHTPAUSEWINDOW)
				GUISystem:showLoading()
				globaldata:requestEnterBattle(true)
			end
		elseif FightSystem.mFightType == "arena" then
			if globaldata.PvpType == "arena" then

			elseif globaldata.PvpType == "pk" then
				local packet = NetSystem.mNetManager:GetSPacket()
			    packet:SetType(PacketTyper._PTYPE_CS_REQUEST_PLAYER_PK_)
			    packet:PushString(globaldata.mPkplayerId)
			    packet:Send()
			    GUISystem:showLoading()
			    EventSystem:PushEvent(Event.GUISYSTEM_HIDE_FIGHTPAUSEWINDOW)
			    globaldata.fightagain = true
			elseif globaldata.PvpType == "brave" then
				local packet = NetSystem.mNetManager:GetSPacket()
				packet:SetType(PacketTyper._PTYPE_CS_REQUEST_CHALLENGE_BRAVE)
				packet:PushUShort(#globaldata.towerBattleHeros)
				for i=1,#globaldata.towerBattleHeros do
					packet:PushInt(globaldata.towerBattleHeros[i])
				end
				packet:Send()
				GUISystem:showLoading()
				EventSystem:PushEvent(Event.GUISYSTEM_HIDE_FIGHTPAUSEWINDOW)
				globaldata.fightagain = true
			end
		end
	end
end

-- 移动控制
function FightPauseWindow:onMoveTypeMove()
	if FightSystem:isEnabledAdvancedJoystick() then return end 
	FightSystem:enableAdvancedJoystick(true)
	self.mTouchMove:loadTexture("public_checkbox1.png")
	self.mTouchFix:loadTexture("public_checkbox1_bg.png")
	FightSystem.mTouchPad:InitLeftPad_MOVE()
end

-- 固定控制
function FightPauseWindow:onMoveTypeFix()
	if not FightSystem:isEnabledAdvancedJoystick() then return end 
	FightSystem:enableAdvancedJoystick(false)
	self.mTouchFix:loadTexture("public_checkbox1.png")
	self.mTouchMove:loadTexture("public_checkbox1_bg.png")
	FightSystem.mTouchPad:InitLeftPad_FIX()
end

function FightPauseWindow:FightExit()
	if self.mPrevWin == WINDOW_FROM.GAME then
		EventSystem:PushEvent(Event.GUISYSTEM_HIDE_FIGHTPAUSEWINDOW)
		EventSystem:PushEvent(Event.GUISYSTEM_HIDE_GAME2048WINDOW)
	elseif self.mPrevWin == WINDOW_FROM.CARDGAME then
		EventSystem:PushEvent(Event.GUISYSTEM_HIDE_FIGHTPAUSEWINDOW)
		EventSystem:PushEvent(Event.GUISYSTEM_HIDE_CARDGAMEWINDOW)
	elseif self.mPrevWin == WINDOW_FROM.HEROGUESS then
		EventSystem:PushEvent(Event.GUISYSTEM_HIDE_FIGHTPAUSEWINDOW)
		EventSystem:PushEvent(Event.GUISYSTEM_HIDE_HEROGUESSWINDOW)
	elseif self.mPrevWin == WINDOW_FROM.ROUND then
		EventSystem:PushEvent(Event.GUISYSTEM_HIDE_FIGHTPAUSEWINDOW)
		EventSystem:PushEvent(Event.GUISYSTEM_HIDE_ROUNDGAMEWINDOW)
	else
		GameApp:Resume()
		FightSystem:setGameSpeedScale(1)
		EventSystem:PushEvent(Event.GUISYSTEM_HIDE_FIGHTPAUSEWINDOW)
		local function Funcall()
			EventSystem:PushEvent(Event.GUISYSTEM_HIDE_FIGHTWINDOW)
		end
		if FightSystem.mFightType == "fuben" then
			if globaldata.PvpType == "wealth" then
				GUISystem:goTo("wealth",{"fail",Funcall})
			elseif globaldata.PvpType == "blackMarket" then
				GUISystem:goTo("blackmarket",{"fail",Funcall})
			elseif globaldata.PvpType == "tower" then
				GUISystem:goTo("towerex",{"fail",Funcall})
			else
				local fubentype = "fb%d-%d"
				if globaldata.clickedlevel == 2 then
					fubentype = "fbjy%d-%d"
				end
				local key = string.format(fubentype,globaldata.clickedchapter,globaldata.clickedsection)
				AnySDKManager:td_task_fail(key, "quit")
				Funcall()
				Event.GUISYSTEM_SHOW_PVEENTRYWINDOW.mData = {}
				Event.GUISYSTEM_SHOW_PVEENTRYWINDOW.mData[1] = globaldata.clickedlevel
				EventSystem:PushEvent(Event.GUISYSTEM_SHOW_PVEENTRYWINDOW)
			end
		elseif FightSystem.mFightType == "arena" then
			if globaldata.PvpType == "brave" then
				GUISystem:goTo("tower",{"fail",Funcall})
			elseif globaldata.PvpType == "boss" then
				GUISystem:goTo("worldboss",Funcall)
			else
				local function callFun()
					showLoadingWindow("HomeWindow")
				end
				FightSystem:sendChangeCity(false,callFun)
			end
		end
	end
end

function FightPauseWindow:Destroy()
	if not self.mIsLoaded then return end
	self.mIsLoaded = false
	self.mRootNode:removeFromParent()
	self.mRootNode = nil
	self.mPrevWin  = nil

	CommonAnimation:clearAllTextures()
end

function FightPauseWindow:onEventHandler(event)
	if event.mAction == Event.WINDOW_SHOW then
		self:Load(event)
	elseif event.mAction == Event.WINDOW_HIDE then
		self:Destroy()
	end
end

return FightPauseWindow