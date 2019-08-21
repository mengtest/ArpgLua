-- Name: 	GangWarsWindow
-- Func：	帮战界面
-- Author:	tuanzhang
-- Data:	16-01-21

local GangWarsWindow = 
{
	mName					=	"GangWarsWindow",
	mRootNode				=	nil,
	mRootWidget				=	nil,
	----------------------------------------
		
}

function GangWarsWindow:Release()

end

function GangWarsWindow:Load()
	cclog("=====GangWarsWindow:Load=====begin")

	self.mRootNode = cc.Node:create()
	GUISystem:GetRootNode():addChild(self.mRootNode)
	------
	self:InitLayout()

	cclog("=====GangWarsWindow:Load=====end")
end

function GangWarsWindow:goToBattle(_heros)
	local HeroId = 0
	for k,v in pairs(_heros) do
		if v ~= 0 then
			HeroId = v
			break
		end
	end
	if HeroId == 0 then
		MessageBox:showMessageBox1("必须保证有一个英雄上阵")
		return
	end
	GUISystem:playSound("homeBtnSound")
	if HeroId ~= 0 then
		local packet = NetSystem.mNetManager:GetSPacket()
		packet:SetType(PacketTyper._PTYPE_CS_BANGHUI_CHANGEHERO_REQUEST)
		packet:PushInt(HeroId)
		packet:Send()
		self.mCurHeroID = HeroId
		self:ChangeHeroIcon(self.mCurHeroID)
		return
	end
end

function GangWarsWindow:ChangeheroBtn()
	ShowRoleSelWindow(self,function(heros) self:goToBattle(heros) end,{self.mCurHeroID,0,0},SELECTHERO.SHOWSELF)
end

function GangWarsWindow:ShowRoomInfo(widget,data)
	for i=1,3 do
		if data.mBanghuiTeamCount >= i then
			-- you
			local heropanle = widget:getChildByName(string.format("Panel_Hero_%d",i))
			heropanle:setVisible(true)
			local heroInfo = data.mBanghuiList[i]
			local heroicon = createHeroIcon(heroInfo.mFightHeroId, heroInfo.mFightHeroLevel, heroInfo.mFightHeroquality, heroInfo.mFightHeroadvanceLv)
			heropanle:getChildByName("Panel_HeroIcon"):removeAllChildren(true)
			heropanle:getChildByName("Panel_HeroIcon"):addChild(heroicon)
			heropanle:getChildByName("Label_PlayerName"):setString(heroInfo.mPlayerName)
			heropanle:getChildByName("Label_PlayerName"):setVisible(true)
			if heroInfo.mIsLeader == 1 then
				heropanle:getChildByName("Image_Captain"):setVisible(true)
			else
				heropanle:getChildByName("Image_Captain"):setVisible(false)
			end
		else
			--没有
			widget:getChildByName(string.format("Panel_Hero_%d",i)):setVisible(false)
		end
	end
end

function GangWarsWindow:ShowMyTeamInfo(widget,data)
	self.IsMycaptain = false
	self.mPlayerIdList = {}
	self.mTeamWidget:getChildByName("Button_GetReady"):setVisible(true)
	self.mTeamWidget:getChildByName("Button_LeaveTeam"):setVisible(true)
	local CountReady = 0
	for i=1,3 do
		if data.mBanghuiTeamCount >= i then
			-- you
			local heropanle = widget:getChildByName(string.format("Panel_Hero_%d",i))
			heropanle:setVisible(true)
			local heroInfo = data.mBanghuiList[i]
			local heroicon = createHeroIcon(heroInfo.mFightHeroId, heroInfo.mFightHeroLevel, heroInfo.mFightHeroquality, heroInfo.mFightHeroadvanceLv)
			heropanle:getChildByName("Panel_HeroIcon"):removeAllChildren(true)
			heropanle:getChildByName("Panel_HeroIcon"):addChild(heroicon)
			heropanle:getChildByName("Label_PlayerName"):setString(heroInfo.mPlayerName)
			heropanle:getChildByName("Label_PlayerName"):setVisible(true)
			

			if heroInfo.mIsLeader == 1 then
				heropanle:getChildByName("Image_Captain"):setVisible(true)
				heropanle:getChildByName("Button_GetOutTeam"):setVisible(false)
				if heroInfo.mPlayerId == globaldata.playerId then
					self.IsMycaptain = true
				end
			else
				heropanle:getChildByName("Button_GetOutTeam"):setVisible(false)
				heropanle:getChildByName("Button_GetOutTeam"):setTag(i)
				self.mPlayerIdList[i] = heroInfo.mPlayerId
				registerWidgetReleaseUpEvent(heropanle:getChildByName("Button_GetOutTeam"),handler(self,self.onKickPlayerBtn))
				heropanle:getChildByName("Image_Captain"):setVisible(false)
			end
			if heroInfo.mIsReady == 1 then
				CountReady = CountReady + 1
				heropanle:getChildByName("Image_Ready"):setVisible(true)
			else
				heropanle:getChildByName("Image_Ready"):setVisible(false)
			end
			if heroInfo.mPlayerId == globaldata.playerId then
				if heroInfo.mIsReady == 1 then
					self.mTeamWidget:getChildByName("Button_GetReady"):getChildByName("Label_GetReady"):setString("取消")
					self.mTeamWidget:getChildByName("Button_GetReady"):setEnabled(true)
					self.mTeamWidget:getChildByName("Button_ChangeHero"):setEnabled(false)
					ShaderManager:DoUIWidgetDisabled(self.mTeamWidget:getChildByName("Button_GetReady"), false)
					ShaderManager:DoUIWidgetDisabled(self.mTeamWidget:getChildByName("Button_ChangeHero"), true)
				else
					self.mTeamWidget:getChildByName("Button_GetReady"):getChildByName("Label_GetReady"):setString("准备")
					self.mTeamWidget:getChildByName("Button_GetReady"):setEnabled(true)
					self.mTeamWidget:getChildByName("Button_ChangeHero"):setEnabled(true)
					ShaderManager:DoUIWidgetDisabled(self.mTeamWidget:getChildByName("Button_GetReady"),false)
					ShaderManager:DoUIWidgetDisabled(self.mTeamWidget:getChildByName("Button_ChangeHero"),false)
				end
			end
		else
			--没有
			local panelhero = widget:getChildByName(string.format("Panel_Hero_%d",i))
			panelhero:getChildByName("Panel_HeroIcon"):removeAllChildren()
			panelhero:getChildByName("Label_PlayerName"):setVisible(false)
			panelhero:getChildByName("Button_GetOutTeam"):setVisible(false)
			panelhero:getChildByName("Image_Ready"):setVisible(false)
			panelhero:getChildByName("Image_Captain"):setVisible(false)
		end
	end
	for i=1,3 do
		if data.mBanghuiTeamCount >= i then
			-- you
			local heropanle = widget:getChildByName(string.format("Panel_Hero_%d",i))
			local heroInfo = data.mBanghuiList[i]
			if self.IsMycaptain then
				if heroInfo.mIsLeader == 1 then
					heropanle:getChildByName("Button_GetOutTeam"):setVisible(false)
				else
					heropanle:getChildByName("Button_GetOutTeam"):setVisible(true)
				end
			end	
		end
	end
	if CountReady == 3 then
		self.mTeamWidget:getChildByName("Label_Matching"):setVisible(true)
	else
		self.mTeamWidget:getChildByName("Label_Matching"):setVisible(false)
	end
	if self.IsMycaptain then
		if CountReady >= 2 then
			ShaderManager:DoUIWidgetDisabled(self.mTeamWidget:getChildByName("Button_GetReady"),false)
    		self.mTeamWidget:getChildByName("Button_GetReady"):setEnabled(true)
			self.mTeamWidget:getChildByName("Button_GetReady"):getChildByName("Label_GetReady"):setString("开始")
		else
			ShaderManager:DoUIWidgetDisabled(self.mTeamWidget:getChildByName("Button_GetReady"), true)
    		self.mTeamWidget:getChildByName("Button_GetReady"):setEnabled(false)
			self.mTeamWidget:getChildByName("Button_GetReady"):getChildByName("Label_GetReady"):setString("开始")
		end		
	end
end

function GangWarsWindow:onKickPlayerBtn(widget)
	local playerId = self.mPlayerIdList[widget:getTag()]
	local function requestTeamFightBanghui()
		local packet = NetSystem.mNetManager:GetSPacket()
		packet:SetType(PacketTyper._PTYPE_CS_BANGHUI_KICKPLAYER_REQUEST)
		packet:PushString(playerId)
		packet:Send()
		GUISystem:showLoading()
	end
	requestTeamFightBanghui()
end

function GangWarsWindow:refreshAllJoinBtn(_isVjoin)
	local isvis = true
	for k,v in pairs(globaldata.GangData.teamFightList) do
		if not isvis then
			break
		end
		for i=1,v.mBanghuiTeamCount do
			if v.mBanghuiList[i].mPlayerId == globaldata.playerId then
				isvis = false
				break
			end
		end
	end
	for k,v in pairs(globaldata.GangData.teamFightList) do
		if self.TeamRoomList[k] then
			self.TeamRoomList[k]:getChildByName("Button_Join"):setVisible(isvis)
		end
	end
end

function GangWarsWindow:UpdateBanghuiFigth()
	self.TeamRoomList = {}
	self.mListViewTeamList:removeAllChildren()
	if globaldata.GangData.teamNum > 0 then
		for k,v in pairs(globaldata.GangData.teamFightList) do
			self:AddBanghuiFigthTeam(k,v)
		end
	end
end

function GangWarsWindow:AddBanghuiFigthTeam(roomId,data)
	local teamcell =	self.TempTeamCell:clone()
	local joinBtn = teamcell:getChildByName("Button_Join")
	joinBtn:setTag(roomId)
	registerWidgetReleaseUpEvent(joinBtn,handler(self,self.JoinTeamBtn))
	if data.mBanghuiTeamCount == 3 then
		joinBtn:setVisible(false)
	end
	self:ShowRoomInfo(teamcell,data)
	self.TeamRoomList[roomId] = teamcell
	self.mListViewTeamList:pushBackCustomItem(teamcell)
	return teamcell
end

function GangWarsWindow:onRequestTeamListBanghuiSYNC(msgPacket)
	local roomData =  globaldata:onRequestTeamListBanghuiSYNC(msgPacket)
	if roomData.mBanghuiTeamCount == 0 then
		if self.TeamRoomList[roomData.mBanghuiRoomId] then
			self.mListViewTeamList:removeItem(self.mListViewTeamList:getIndex(self.TeamRoomList[roomData.mBanghuiRoomId]))
			self.TeamRoomList[roomData.mBanghuiRoomId] = nil	
			globaldata.GangData.teamFightList[roomData.mBanghuiRoomId] = nil
		end
	else
		if self.TeamRoomList[roomData.mBanghuiRoomId] then
			globaldata.GangData.teamFightList[roomData.mBanghuiRoomId] = roomData
			self:ShowRoomInfo(self.TeamRoomList[roomData.mBanghuiRoomId],roomData)
		else
			globaldata.GangData.teamFightList[roomData.mBanghuiRoomId] = roomData
			local item = self:AddBanghuiFigthTeam(roomData.mBanghuiRoomId,roomData)
			self.TeamRoomList[roomData.mBanghuiRoomId] = item
		end
	end
	self:refreshAllJoinBtn()
end

function GangWarsWindow:TeamFight()
	local function onRequestTeamFightBanghui(msgPacket)
		globaldata:onRequestFightBanghuiData(msgPacket)
		self.mTeamWidget:getChildByName("Button_CreatTeam"):setVisible(true)
		if self.mTeamWidget:isVisible() then
			self:UpdateBanghuiFigth()
		else
			self:UpdateBanghuiFigth()
			self.mTeamWidget:setVisible(true)
			GUISystem:hideLoading()
		end
	end
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_FIGHT_BANGHUI_RESPONSE, onRequestTeamFightBanghui)

	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_FIGHT_BANGHUI_SYNC, handler(self,self.onRequestTeamListBanghuiSYNC))

	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_BANGHUI_JOINTEAM_RESPONSE,handler(self,self.onRequestJoinTeamBanghui))

	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_BANGHUI_KICKPLAYER_REQUEST,handler(self,self.onKickedPlayerBanghui))

	local function requestTeamFightBanghui()
		local packet = NetSystem.mNetManager:GetSPacket()
		packet:SetType(PacketTyper._PTYPE_CS_FIGHT_BANGHUI_REQUEST)
		packet:Send()
		GUISystem:showLoading()
	end
	requestTeamFightBanghui()
end

function GangWarsWindow:TeamFightClose()

	local function onRequestExitFight(msgPacket)
		NetSystem.mNetManager:UnregisterPacketHandler(PacketTyper._PTYPE_SC_FIGHT_BANGHUI_SYNC)
		self.mTeamWidget:setVisible(false)
		self:resetMyTeam()
		GUISystem:hideLoading()
	end
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_BANGHUI_EXIT_RESPONSE, onRequestExitFight)
	local packet = NetSystem.mNetManager:GetSPacket()
	packet:SetType(PacketTyper._PTYPE_CS_BANGHUI_EXIT_REQUEST)
	packet:Send()
	GUISystem:showLoading()
end

function GangWarsWindow:UpdateMyTeam()
	self:ShowMyTeamInfo(self.mPanelMyTeam,globaldata.GangData.mOwnTeam)

end

function GangWarsWindow:resetMyTeam()
	for i=1,3 do
		local heropanle = self.mPanelMyTeam:getChildByName(string.format("Panel_Hero_%d",i))
		heropanle:getChildByName("Panel_HeroIcon"):removeAllChildren()
		heropanle:getChildByName("Label_PlayerName"):setVisible(false)
		heropanle:getChildByName("Button_GetOutTeam"):setVisible(false)
		heropanle:getChildByName("Image_Ready"):setVisible(false)
		heropanle:getChildByName("Image_Captain"):setVisible(false)
	end

	self.mTeamWidget:getChildByName("Button_GetReady"):setVisible(false)
	self.mTeamWidget:getChildByName("Button_LeaveTeam"):setVisible(false)
end

-- 队伍变化同步
function GangWarsWindow:onRequestJoinTeamBanghui(msgPacket)
	globaldata:onRequestCreateTeamFight(msgPacket)
	self:UpdateMyTeam()
	GUISystem:hideLoading()
end

-- 被踢玩家
function GangWarsWindow:onKickedPlayerBanghui(msgPacket)
	self:resetMyTeam()
	self.mTeamWidget:getChildByName("Button_CreatTeam"):setVisible(true)

end


-- 加入队伍
function GangWarsWindow:JoinTeamBtn(widget)
	self.mTeamWidget:getChildByName("Button_CreatTeam"):setVisible(false)
	local _roomId = widget:getTag()
	local packet = NetSystem.mNetManager:GetSPacket()
	packet:SetType(PacketTyper._PTYPE_CS_BANGHUI_JOINTEAM_REQUEST)
	packet:PushInt(_roomId)
	packet:PushInt(self.mCurHeroID)
	packet:Send()
	GUISystem:showLoading()
end

-- 创建队伍
function GangWarsWindow:CreatTeam()
	local function onRequestCreateTeamBanghui(msgPacket)
		self.mTeamWidget:getChildByName("Button_CreatTeam"):setVisible(false)
		globaldata:onRequestCreateTeamFight(msgPacket)
		self:UpdateMyTeam()

		GUISystem:hideLoading()
	end
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_BANGHUI_CREATETEAM_RESPONSE, onRequestCreateTeamBanghui)
	local packet = NetSystem.mNetManager:GetSPacket()
	packet:SetType(PacketTyper._PTYPE_CS_BANGHUI_CREATETEAM_REQUEST)
	packet:PushInt(self.mCurHeroID)
	packet:Send()
	GUISystem:showLoading()
end

-- 离开队伍
function GangWarsWindow:LeaveTeam()
	local function onRequestLeaveTeamBanghui(msgPacket)
		local result = msgPacket:GetChar()
		if result == 0 then
			--离开成功
			self:resetMyTeam()
			self.mTeamWidget:getChildByName("Button_CreatTeam"):setVisible(true)
		end
		GUISystem:hideLoading()
	end
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_BANGHUI_LEAVETEAM_RESPONSE, onRequestLeaveTeamBanghui)
	local packet = NetSystem.mNetManager:GetSPacket()
	packet:SetType(PacketTyper._PTYPE_CS_BANGHUI_LEAVETEAM_REQUEST)
	packet:Send()
	GUISystem:showLoading()
end

-- 准备
function GangWarsWindow:onGetReady()
	local packet = NetSystem.mNetManager:GetSPacket()
	packet:SetType(PacketTyper._PTYPE_SC_BANGHUI_READY_REQUEST)
	packet:Send()
end


-- 换我的英雄
function GangWarsWindow:ChangeHeroIcon(heroId)
	local heroObj = globaldata:findHeroById(heroId)
	local heroicon = createHeroIcon(heroObj.id, heroObj.level, heroObj.quality, heroObj.advanceLevel)
	self.mTeamWidget:getChildByName("Panel_MyHero"):addChild(heroicon)
end


function GangWarsWindow:InitLayout()

	self.mRootWidget = GUIWidgetPool:createWidget("Guild_War")
	self.mRootNode:addChild(self.mRootWidget)


	self.mListViewTeamList = self.mRootWidget:getChildByName("ListView_TeamList")
	self.mGuildRankingList = self.mRootWidget:getChildByName("ListView_GuildRankingList")
	self.mListViewMyGuild = self.mRootWidget:getChildByName("ListView_MyGuild")
	self.mTeamWidget = self.mRootWidget:getChildByName("Panel_TeamWindow")
	self.mMainWidget = self.mRootWidget:getChildByName("Panel_Main")
	--更换英雄
	registerWidgetReleaseUpEvent(self.mTeamWidget:getChildByName("Button_ChangeHero"),handler(self,self.ChangeheroBtn))
	-- 组队战斗
	registerWidgetReleaseUpEvent(self.mMainWidget:getChildByName("Button_Fight"),handler(self,self.TeamFight))
	-- 关主队界面
	registerWidgetReleaseUpEvent(self.mTeamWidget:getChildByName("Button_Close"),handler(self,self.TeamFightClose))
	-- 创建队伍
	registerWidgetReleaseUpEvent(self.mTeamWidget:getChildByName("Button_CreatTeam"),handler(self,self.CreatTeam))
	-- 离开队伍
	registerWidgetReleaseUpEvent(self.mTeamWidget:getChildByName("Button_LeaveTeam"),handler(self,self.LeaveTeam))
	-- 准备
	registerWidgetReleaseUpEvent(self.mTeamWidget:getChildByName("Button_GetReady"),handler(self,self.onGetReady))
	
	self.mPanelMyTeam = self.mTeamWidget:getChildByName("Panel_MyTeam")
	self.mPanelMyTeam:setVisible(true)
	self:resetMyTeam()
	self:ChangeHeroIcon(globaldata.leaderHeroId)

	self.mCurHeroID = globaldata.leaderHeroId

	local function closeWindow()
		EventSystem:PushEvent(Event.GUISYSTEM_HIDE_GANGWARSWINDOW)
	end
	self.mTopRoleInfoPanel = TopRoleInfoPanel:new()
	local topInfoPanel = self.mTopRoleInfoPanel:init(self.mRootWidget,ROLE_TITLE_TYPE.TITLE_GANGWARS,closeWindow)

	local function doAdapter()
	    local topInfoPanelSize = topInfoPanel:getContentSize()
	    local newHeight = getGoldFightPosition_LU().y - topInfoPanelSize.height - getGoldFightPosition_LD().y
	    local newPosY = newHeight/2 + getGoldFightPosition_LD().y - self.mRootWidget:getChildByName("Panel_Main"):getContentSize().height/2
	    self.mRootWidget:getChildByName("Panel_Main"):setVisible(false)
		local function doSomething()
			self.mRootWidget:getChildByName("Panel_Main"):setPositionY(newPosY)
			self.mRootWidget:getChildByName("Panel_Main"):setVisible(true)
		end
		doSomething()
		--nextTick(doSomething)
	end
	doAdapter()
	self.TempTeamCell =	GUIWidgetPool:createWidget("Guild_War_TeamCell") 
	self.TempTeamCell:retain()

	self.TempRankingCell =	GUIWidgetPool:createWidget("Guild_War_GuildRanking_Cell") 
	self.TempRankingCell:retain()

	-- 添加信息
	for i=1,globaldata.GangData.rankNum  do
		local sss =	self.TempRankingCell:clone()
		sss:getChildByName("Label_Ranking"):setString(string.format("%d",i))
		sss:getChildByName("Label_Name"):setString(globaldata.GangData.rankList[i].mBanghuiName)
		sss:getChildByName("Label_Points"):setString(string.format("%d",globaldata.GangData.rankList[i].mScore))
		self.mGuildRankingList:pushBackCustomItem(sss)
	end

	for i=1,globaldata.GangData.memberrankNum do
		local sss =	self.TempRankingCell:clone()
		sss:getChildByName("Label_Ranking"):setString(string.format("%d",i))
		sss:getChildByName("Label_Name"):setString(globaldata.GangData.memberrankList[i].mBanghuiName)
		sss:getChildByName("Label_Points"):setString(string.format("%d",globaldata.GangData.memberrankList[i].mScore))
		self.mListViewMyGuild:pushBackCustomItem(sss)
	end
	self:InitMyFightInfo()
end

-- 
function GangWarsWindow:InitMyFightInfo()
	self.mMainWidget:getChildByName("Label_MyFightNum"):setString(tostring(globaldata.GangData.mMyFighgCount))
	self.mMainWidget:getChildByName("Label_MyWinNum"):setString(tostring(globaldata.GangData.mMyWinTimes))
	self.mMainWidget:getChildByName("Label_MyPoints"):setString(tostring(globaldata.GangData.mOwnScore))
end
-- 

function GangWarsWindow:Destroy()
	NetSystem.mNetManager:UnregisterPacketHandler(PacketTyper._PTYPE_SC_BANGHUI_EXIT_RESPONSE)
	NetSystem.mNetManager:UnregisterPacketHandler(PacketTyper._PTYPE_SC_FIGHT_BANGHUI_RESPONSE)
	NetSystem.mNetManager:UnregisterPacketHandler(PacketTyper._PTYPE_SC_FIGHT_BANGHUI_SYNC)
	NetSystem.mNetManager:UnregisterPacketHandler(PacketTyper._PTYPE_SC_BANGHUI_JOINTEAM_RESPONSE)
	NetSystem.mNetManager:UnregisterPacketHandler(PacketTyper._PTYPE_SC_BANGHUI_KICKPLAYER_REQUEST)
	NetSystem.mNetManager:UnregisterPacketHandler(PacketTyper._PTYPE_SC_BANGHUI_CREATETEAM_RESPONSE)
	NetSystem.mNetManager:UnregisterPacketHandler(PacketTyper._PTYPE_SC_BANGHUI_LEAVETEAM_RESPONSE)

	self.mTopRoleInfoPanel:destroy()
	self.mTopRoleInfoPanel = nil

	if self.TempTeamCell then
		self.TempTeamCell:release()
		self.TempTeamCell = nil
	end

	if self.TempRankingCell then
		self.TempRankingCell:release()
		self.TempRankingCell = nil
	end

	self.mRootNode:removeFromParent(true)
	self.mRootNode = nil
	self.mRootWidget = nil

	------------
	CommonAnimation.clearAllTextures()
end

function GangWarsWindow:DisableDraw()
	if self.mRootWidget then
		self.mRootWidget:setVisible(false)
	end
end

function GangWarsWindow:EnableDraw()
	if self.mRootWidget then
		self.mRootWidget:setVisible(true)
	end
end

function GangWarsWindow:onEventHandler(event)
	if event.mAction == Event.WINDOW_SHOW then
		if GUISystem:canShow(self.mName) then
			self:Load(event)
			---------停止画帮派界面
			EventSystem:PushEvent(Event.GUISYSTEM_DISABLEDRAW_UNIONHALLWINDOW)
			---------
		end
	elseif event.mAction == Event.WINDOW_HIDE then
		self:Destroy()
		---------开启画帮派界面
		EventSystem:PushEvent(Event.GUISYSTEM_ENABLEDRAW_UNIONHALLWINDOW)
		---------
	elseif event.mAction == Event.WINDOW_ENABLE_DRAW then
		self:EnableDraw()
	elseif event.mAction == Event.WINDOW_DISABLE_DRAW then
		self:DisableDraw()
	end
end

return GangWarsWindow