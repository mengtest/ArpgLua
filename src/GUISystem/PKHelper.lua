--
--  PKHelper.lua
--  BetaProject
--
--  Created by 李川 on 16-3-15.
--  Copyright (c) 2016年 Bei Ta. All rights reserved.
--

PKHelper = {}

PKHelper.inviteNotice  = nil
PKHelper.pkInviteArr   = {}
PKHelper.pkSelfMain    = nil
PKHelper.pkEnemyDetail = nil
PKHelper.pkHeros       = {0,0,0}

function PKHelper:onReceivePkInvite(msgPacket)
	local inviteInfo      = {}
	inviteInfo.targetId   = msgPacket:GetString()
	inviteInfo.targetName = msgPacket:GetString()
	inviteInfo.combat     = msgPacket:GetInt()
	table.insert(self.pkInviteArr,inviteInfo)

	self:ShowPKInvite()
end

NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_RECEIVE_PK_REQUEST, handler(PKHelper, PKHelper.onReceivePkInvite))

function PKHelper:onPkInviteCancel(msgPacket)
	local cancelType = msgPacket:GetChar()  --1.对方主动取消 2.超时取消

	table.remove(self.pkInviteArr,1)

	self:HidePKInvite()
	self:CloseMainWin()
end

NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_CANCEL_PK_REQUEST, handler(PKHelper, PKHelper.onPkInviteCancel))

function PKHelper:onPkInviteAccept(msgPacket)
	table.remove(self.pkInviteArr,1)
	
	self:HidePKInvite()
	self:CloseMainWin()
end

NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_ACCEPT_PK_RESPONSE, handler(PKHelper, PKHelper.onPkInviteAccept))

function PKHelper:HidePKInvite()
	if self.inviteNotice ~= nil then 
		self.inviteNotice:removeFromParent(true)
		self.inviteNotice = nil
	end
end

function PKHelper:CancelInvite()
	if self.pkInviteArr[1] then
		table.remove(self.pkInviteArr,1)
	end
end

function PKHelper:doChangeHeroRequest(heros)
	local packet = NetSystem.mNetManager:GetSPacket()
	packet:SetType(PacketTyper._PTYPE_CS_CHANGE_PKHERO_REQUEST)
	packet:PushUShort(#heros)
	for i=1,#heros do
		packet:PushInt(heros[i])
	end
	packet:Send()
end

function PKHelper:CloseMainWin()
	if self.pkSelfMain then
		self.pkSelfMain:removeFromParent(true) 
		self.pkSelfMain = nil
	end

	if self.timeScheduler ~= nil then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.timeScheduler)
		self.timeScheduler = nil
	end
end

function PKHelper:UpdateHeros(heros,typ)
	local widget = nil
	if typ == 1 then
		widget = self.pkSelfMain
	else
		widget = self.pkEnemyDetail
	end 

	local combat = 0
	for i=1,#heros do
		if heros[i] ~= 0 then
			local heroObj = globaldata:findHeroById(heros[i])
			combat = combat + heroObj.combat
			self.pkHeros[i] = heros[i]
			globaldata.pkBattleHeroIdTbl[i] = heros[i]

			widget:getChildByName(string.format("Panel_Hero_%d",i)):removeAllChildren()
			widget:getChildByName(string.format("Panel_Hero_%d",i)):addChild(createHeroIcon(heroObj.id, heroObj.level, heroObj.quality, heroObj.advanceLevel))

		end
	end

	widget:getChildByName("Label_Zhanli"):setString(tostring(combat))
end

function PKHelper:DoPKInvite(playerId,playerName)
	self.pkSelfMain = GUIWidgetPool:createWidget("Duel_Main")
	self.pkSelfMain:getChildByName("Panel_Window"):setVisible(true)
	self.pkSelfMain:getChildByName("Panel_Wait"):setVisible(false)
	self.pkSelfMain:getChildByName("Label_WaitingTime"):setString("60")

	GUISystem.RootNode:addChild(self.pkSelfMain, GUISYS_ZORDER_PKNOTICE)

	local function doCancelPkRequest()
		local packet = NetSystem.mNetManager:GetSPacket()
		packet:SetType(PacketTyper._PTYPE_CS_CANCEL_PK_REQUEST)
		packet:PushString(playerId)
		packet:Send()
	end

	local function closeWindow()
		doCancelPkRequest()
		self:CloseMainWin()
	end

	local time = 60
	self.timeScheduler = nil

	local function UpdateTimeLine()
		if self.pkSelfMain == nil then return end
		time = time - 1
		if time == 0 then closeWindow() return end
		self.pkSelfMain:getChildByName("Label_WaitingTime"):setString(tostring(time))	
	end

	local function doSendPkRequest()
		if self.pkHeros[1] == 0 or self.pkHeros[2] == 0 or self.pkHeros[3] == 0 then MessageBox:showMessageBox1("上阵英雄不足！！！") return end
	 	local packet = NetSystem.mNetManager:GetSPacket()
		packet:SetType(PacketTyper._PTYPE_CS_SEND_PK_REQUEST)
		packet:PushString(playerId)
		packet:Send()
		GUISystem:showLoading()
	end

	local function sendPkResponse(msgPacket)
		local state = msgPacket:GetChar()
		GUISystem:hideLoading()
		if state == 0 then
			self.pkSelfMain:getChildByName("Panel_Window"):setVisible(false)
			self.pkSelfMain:getChildByName("Panel_Wait"):setVisible(true)

			local animNode = AnimManager:createAnimNode(8003)
			self.pkSelfMain:getChildByName("Panel_Wait"):getChildByName("Panel_Animation"):addChild(animNode:getRootNode(), 2000)
			animNode:play("tianti_vs_search1",true)	

			self.pkSelfMain:getChildByName("Label_EnemyName"):setString(playerName) 
			self.timeScheduler = cc.Director:getInstance():getScheduler():scheduleScriptFunc(UpdateTimeLine, 1, false)
		elseif state == 1 then
			MessageBox:showMessageBox1("失败")
		else

		end
	end 

	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_SEND_PK_RESPONSE, sendPkResponse)

	self:UpdateHeros(globaldata.pkBattleHeroIdTbl,1)

	registerWidgetReleaseUpEvent(self.pkSelfMain:getChildByName("Button_Close"),closeWindow)
	registerWidgetReleaseUpEvent(self.pkSelfMain:getChildByName("Button_ReplaceTeam"),
	function() 
		ShowRoleSelWindow(nil,function(heros) self:UpdateHeros(heros,1) self:doChangeHeroRequest(heros) end,globaldata.pkBattleHeroIdTbl,SELECTHERO.SHOWSELF) 
	end)
	registerWidgetReleaseUpEvent(self.pkSelfMain:getChildByName("Button_Send"),doSendPkRequest)
	registerWidgetReleaseUpEvent(self.pkSelfMain:getChildByName("Button_Cancel"),closeWindow)
end

function PKHelper:ShowPKInvite()
	if GUISystem:IsWindowShowed("FightWindow") or GUISystem:IsWindowShowed("FuckWindow") then return end
	if #self.pkInviteArr == 0 then self:HidePKInvite() return end

	self.inviteNotice = GUIWidgetPool:createWidget("Duel_Notice")

	local size = self.inviteNotice:getContentSize()
	local x = getGoldFightPosition_RU().x - size.width
	local y = getGoldFightPosition_RU().y - size.height

	local height = GUIWidgetPool:createWidget("RoleInfoPanel"):getContentSize().height

	local aniNode = AnimManager:createAnimNode(8040)
	self.inviteNotice:getChildByName("Panel_Animation"):addChild(aniNode:getRootNode(), 100)
	aniNode:play("duel_notice", true) 

	self.inviteNotice:getChildByName("Panel_14"):setTouchEnabled(false)
	self.inviteNotice:setPosition(x,y - height)
	GUISystem.RootNode:addChild(self.inviteNotice, GUISYS_ZORDER_PKNOTICE)
	
	local function ShowInviteDetail()
		self.pkEnemyDetail = GUIWidgetPool:createWidget("Duel_Request")
		GUISystem.RootNode:addChild(self.pkEnemyDetail, GUISYS_ZORDER_PKNOTICE)

		self.pkEnemyDetail:getChildByName("Label_Something"):setString(self.pkInviteArr[1].targetName)

		local function closeWindow()
			self.pkEnemyDetail:removeFromParent(true)
			self.pkEnemyDetail = nil
		end

		local function doPkRequest()
			if self.pkHeros[1] == 0 or self.pkHeros[2] == 0 or self.pkHeros[3] == 0 then MessageBox:showMessageBox1("上阵英雄不足！！！") return end

			table.remove(self.pkInviteArr,1)

			local packet = NetSystem.mNetManager:GetSPacket()
			packet:SetType(PacketTyper._PTYPE_CS_CONFIRM_PK_REQUEST)
			packet:PushChar(1) -- 同意
			packet:Send()

			self:HidePKInvite()
			closeWindow()
		end

		local function doIngorePkRequest()
			table.remove(self.pkInviteArr,1)
			local packet = NetSystem.mNetManager:GetSPacket()
			packet:SetType(PacketTyper._PTYPE_CS_CONFIRM_PK_REQUEST)
			packet:PushChar(0)   --无视
			packet:Send()

			self:HidePKInvite()
			closeWindow()
		end

		self:UpdateHeros(globaldata.pkBattleHeroIdTbl,2)

		registerWidgetReleaseUpEvent(self.pkEnemyDetail:getChildByName("Button_Close"),closeWindow)
		registerWidgetReleaseUpEvent(self.pkEnemyDetail:getChildByName("Button_Cancel"),doIngorePkRequest)
		registerWidgetReleaseUpEvent(self.pkEnemyDetail:getChildByName("Button_ReplaceTeam"),
		function() 
			ShowRoleSelWindow(nil,function(heros) self:UpdateHeros(heros,2) self:doChangeHeroRequest(heros) end,globaldata.pkBattleHeroIdTbl,SELECTHERO.SHOWSELF) 
		end)
		registerWidgetReleaseUpEvent(self.pkEnemyDetail:getChildByName("Button_Ready"),doPkRequest)
	end

	registerWidgetReleaseUpEvent(self.inviteNotice:getChildByName("Panel_Main"),ShowInviteDetail)
end