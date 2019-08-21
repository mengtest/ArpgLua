-- Name: 	PartyMainWindow
-- Func：	公会信息
-- Author:	lichuan
-- Data:	16-2-2

require("GUISystem/Window/PartyTableViews")

local PMMInstance = nil

PartyMainModel = class("PartyMainModel")

function PartyMainModel:ctor(owner)
	self.mName		    = "PartyMainModel"
	self.mOwner         = owner
	self.mPartyName     = nil
	self.mMemberCnt     = nil
	self.mPartyId       = nil
	self.mPartyRole     = nil
	self.mBulletin		= nil
	self.mJoinLimitType = nil
	self.mJoinLimitLv   = nil
	self.mMemberMaxCnt  = nil
	self.mPartyLv       = nil
	self.mCurExp        = nil
	self.mMaxExp        = nil

	self.mMemberInfoArr = {}
	self.mApplyInfoArr  = {}

	self:registerNetEvent()
end

function PartyMainModel:deinit()
	self.mName  	    = nil
	self.mOwner 	    = nil
	self.mPartyName     = nil
	self.mMemberCnt     = nil
	self.mPartyId       = nil
	self.mPartyRole     = nil
	self.mBulletin		= nil
	self.mJoinLimitType = nil
	self.mJoinLimitLv   = nil
	self.mMemberMaxCnt  = nil
	self.mPartyLv       = nil
	self.mCurExp        = nil
	self.mMaxExp        = nil
	self.mMemberInfoArr = {}
	self.mApplyInfoArr  = {}

	self:unRegisterNetEvent()
end

function PartyMainModel:getInstance()
	if PMMInstance == nil then  
        PMMInstance = PartyMainModel.new()
    end  
    return PMMInstance
end

function PartyMainModel:destroyInstance()
	if PMMInstance then
		PMMInstance:deinit()
    	PMMInstance = nil
    end
end

function PartyMainModel:registerNetEvent()
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_PARTY_INFO_RESPONSE, handler(self, self.onPartyInfoResponse))
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_PARTY_MEMBERS_RESPONSE, handler(self, self.onLoadMembersResponse))
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_PARTY_APPLYLIST_RESPONSE, handler(self, self.onLoadApplyListResponse))
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_MODIFY_CONFIG_RESPONSE, handler(self, self.onModifyConfigResponse))
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_DISBAND_PARTY_RESPONSE, handler(self, self.onDisBandPartyResponse))
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_QUIT_PARTY_RESPONSE, handler(self, self.onQuitPartyResponse))
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_PARTY_APPOINT_RESPONSE, handler(self, self.onAppointResponse))
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_PARTY_FIRE_RESPONSE, handler(self, self.onFireResponse))
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_REFUSE_JOIN_RESPONSE, handler(self, self.onRefuseApplyResponse))
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_AGREE_JOIN_RESPONSE, handler(self, self.onAgreeApplyResponse))
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_MODIFY_BULLETIN_RESPONSE, handler(self, self.onModifyBulletinResponse))
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_GIVE_PARTY_RESPONSE, handler(self, self.onGivePartyResponse))
end

function PartyMainModel:unRegisterNetEvent()
	NetSystem.mNetManager:UnregisterPacketHandler(PacketTyper._PTYPE_SC_PARTY_INFO_RESPONSE)
	NetSystem.mNetManager:UnregisterPacketHandler(PacketTyper._PTYPE_SC_PARTY_MEMBERS_RESPONSE)
	NetSystem.mNetManager:UnregisterPacketHandler(PacketTyper._PTYPE_SC_PARTY_APPLYLIST_RESPONSE)
	NetSystem.mNetManager:UnregisterPacketHandler(PacketTyper._PTYPE_SC_MODIFY_CONFIG_RESPONSE)
	NetSystem.mNetManager:UnregisterPacketHandler(PacketTyper._PTYPE_SC_DISBAND_PARTY_RESPONSE)
	NetSystem.mNetManager:UnregisterPacketHandler(PacketTyper._PTYPE_SC_QUIT_PARTY_RESPONSE)
	NetSystem.mNetManager:UnregisterPacketHandler(PacketTyper._PTYPE_SC_PARTY_APPOINT_RESPONSE)
	NetSystem.mNetManager:UnregisterPacketHandler(PacketTyper._PTYPE_SC_PARTY_FIRE_RESPONSE)
	NetSystem.mNetManager:UnregisterPacketHandler(PacketTyper._PTYPE_SC_REFUSE_JOIN_RESPONSE)
	NetSystem.mNetManager:UnregisterPacketHandler(PacketTyper._PTYPE_SC_AGREE_JOIN_RESPONSE)
	NetSystem.mNetManager:UnregisterPacketHandler(PacketTyper._PTYPE_SC_MODIFY_BULLETIN_RESPONSE)
	NetSystem.mNetManager:UnregisterPacketHandler(PacketTyper._PTYPE_SC_GIVE_PARTY_RESPONSE)
end

function PartyMainModel:setOwner(owner)
	self.mOwner = owner
end

function PartyMainModel:doLoadPartyInfoRequest()
	if self.mPartyName then self.mOwner.mPPFs[1][2]:setVisible(true) return end
	local packet = NetSystem.mNetManager:GetSPacket()
    packet:SetType(PacketTyper._PTYPE_CS_PARTY_INFO_REQUEST)
    packet:Send()
    GUISystem:showLoading()
end

function PartyMainModel:onPartyInfoResponse(msgPacket)
	self.mPartyName     = msgPacket:GetString()
	self.mMemberCnt     = msgPacket:GetInt()
	self.mPartyId       = msgPacket:GetString()
	self.mPartyIconId	= msgPacket:GetInt()
	globaldata.partyIconId = self.mPartyIconId
	self.mPartyRole     = msgPacket:GetChar()
	self.mBulletin		= msgPacket:GetString()
	self.mJoinLimitType = msgPacket:GetInt()
	self.mJoinLimitLv   = msgPacket:GetInt()
	self.mMemberMaxCnt  = msgPacket:GetInt()
	self.mPartyLv       = msgPacket:GetInt()
	self.mCurExp        = msgPacket:GetInt()
	self.mMaxExp        = msgPacket:GetInt()

	local msgCnt = msgPacket:GetChar()

	self.mMsgdeque		 = {}
	for i=1,msgCnt do
		local msgTime    = msgPacket:GetString()
		local msgPlayer  = msgPacket:GetString()
		local msgContent = msgPacket:GetString()
		local msg        = {msgTime,msgPlayer,msgContent}
		table.insert(self.mMsgdeque,msg)
	end	

	GUISystem:hideLoading()

	if self.mOwner then
		self.mOwner:ShowPartyInfo()
	end
end

function PartyMainModel:doDisBandPartyRequest()
	local packet = NetSystem.mNetManager:GetSPacket()
    packet:SetType(PacketTyper._PTYPE_CS_DISBAND_PARTY_REQUEST)
    packet:Send()
    GUISystem:showLoading()
end

function PartyMainModel:onDisBandPartyResponse(msgPacket)
	local ret = msgPacket:GetChar()

	GUISystem:hideLoading()
	if ret == 0 then
		globaldata.partyId = ""
		UnionSubManager:leaveUnionHall()
	else
		MessageBox:showMessageBox1("解散失败！")
	end
end

function PartyMainModel:doQuitPartyRequest()
	local packet = NetSystem.mNetManager:GetSPacket()
    packet:SetType(PacketTyper._PTYPE_CS_QUIT_PARTY_REQUEST)
    packet:Send()
    GUISystem:showLoading()
end

function PartyMainModel:onQuitPartyResponse(msgPacket)
	local ret = msgPacket:GetChar()

	GUISystem:hideLoading()
	if ret == 0 then
		globaldata.partyId = ""
		UnionSubManager:leaveUnionHall()
	else
		MessageBox:showMessageBox1("退出失败！")
	end
end

function PartyMainModel:doLoadMembersRequest()
	local packet = NetSystem.mNetManager:GetSPacket()
    packet:SetType(PacketTyper._PTYPE_CS_PARTY_MEMBERS_REQUEST)
    packet:Send()
    GUISystem:showLoading()
end

function PartyMainModel:onLoadMembersResponse(msgPacket)
	local membersCnt = msgPacket:GetChar()
	self.mMemberInfoArr = {}
	self.mSmallMasterCnt = 0
	for i=1,membersCnt do
		local memberInfo                    = {}
		memberInfo.mMemberIdStr             = msgPacket:GetString()
		memberInfo.mMemberNameStr           = msgPacket:GetString()
		memberInfo.mMemberFightPower		= msgPacket:GetInt()
		memberInfo.mMemberFrameId           = msgPacket:GetInt()
		memberInfo.mMemberIconId            = msgPacket:GetInt()
		memberInfo.mMemberLv			    = msgPacket:GetInt()
		memberInfo.mContribution		    = msgPacket:GetInt()
		memberInfo.mFightRecord				= msgPacket:GetInt()
		memberInfo.mPosition				= msgPacket:GetInt()
		if memberInfo.mPosition == PARTYROLE.SMALLMASTER then
			self.mSmallMasterCnt = self.mSmallMasterCnt + 1
		end
		memberInfo.mLastOnLineTime			= msgPacket:GetString()

		table.insert(self.mMemberInfoArr,memberInfo)
	end

	table.sort(self.mMemberInfoArr, function(memberInfo1,memberInfo2) return memberInfo1.mPosition > memberInfo2.mPosition end)
	GUISystem:hideLoading()
	self.mOwner:ShowMembers()
end

function PartyMainModel:doVisitRequest()

	print("doVisitRequest")
end

function PartyMainModel:doAddFriendRequest(index)
	local packet = NetSystem.mNetManager:GetSPacket()
    packet:SetType(PacketTyper._PTYPE_CS_REQUEST_ADD_FRIEND_)
    packet:PushString(self.mMemberInfoArr[index + 1].mMemberIdStr)
    packet:Send()
end

function PartyMainModel:doChatRequest(index)
	local memberInfo = self.mMemberInfoArr[index + 1]
	if GUISystem:GetWindowByName("UnionHallWindow").mBottomChatPanel then
		GUISystem:GetWindowByName("UnionHallWindow").mBottomChatPanel:talkToSomebody(memberInfo.mMemberIdStr, memberInfo.mMemberNameStr)
	end
	EventSystem:PushEvent(Event.GUISYSTEM_HIDE_PARTYMAINWINDOW)
end

function PartyMainModel:doAppointRequest(index,position)
	self.mLastAppointPos = position
	--self.mMemberInfoArr[index + 1].mPosition = position
	local packet = NetSystem.mNetManager:GetSPacket()
    packet:SetType(PacketTyper._PTYPE_CS_PARTY_APPOINT_REQUEST)
    packet:PushChar(position)
    packet:PushString(self.mMemberInfoArr[index + 1].mMemberIdStr)
    packet:Send()
    GUISystem:showLoading()
end

function PartyMainModel:onAppointResponse(msgPacket)
	local ret = msgPacket:GetChar()

	GUISystem:hideLoading()
	if ret == 0 then 
		MessageBox:showMessageBox1("任命成功！")
		if self.mOwner.mMemberTV ~= nil then
			self.mOwner.mMemberTV:UpdateCurSel(self.mLastAppointPos)
		end
	else
		MessageBox:showMessageBox1("任命失败！")
	end
end

function PartyMainModel:doFireRequest(index)
	local packet = NetSystem.mNetManager:GetSPacket()
    packet:SetType(PacketTyper._PTYPE_CS_PARTY_FIRE_REQUEST)
    packet:PushString(self.mMemberInfoArr[index + 1].mMemberIdStr)
    packet:Send()
    GUISystem:showLoading()
end

function PartyMainModel:onFireResponse(msgPacket)
	local ret = msgPacket:GetChar()

	GUISystem:hideLoading()
	if ret == 0 then 
		table.remove(self.mMemberInfoArr,self.mOwner.mMemberTV:getCurSelIndex() + 1)
		if self.mOwner.mMemberTV ~= nil then
			self.mOwner.mMemberTV:UpdateTableView(#self.mMemberInfoArr)
		end
	end
end

function PartyMainModel:doLoadApplyListRequest()
	local packet = NetSystem.mNetManager:GetSPacket()
    packet:SetType(PacketTyper._PTYPE_CS_PARTY_APPLYLIST_REQUEST)
    packet:Send()
    GUISystem:showLoading()
end

function PartyMainModel:onLoadApplyListResponse(msgPacket)
	local applyCnt = msgPacket:GetChar()
	self.mApplyInfoArr = {}
	for i=1,applyCnt do
		local applyInfo                  = {}
		applyInfo.mPlayerIdStr           = msgPacket:GetString()
		applyInfo.mPlayerNameStr         = msgPacket:GetString()
		applyInfo.mPlayerFrameId         = msgPacket:GetInt()
		applyInfo.mPlayerIconId          = msgPacket:GetInt()
		applyInfo.mPlayerFightPower		 = msgPacket:GetInt()
		applyInfo.mPlayerLv				 = msgPacket:GetInt()
		applyInfo.mPosition              = msgPacket:GetInt()
		table.insert(self.mApplyInfoArr,applyInfo)
	end

	GUISystem:hideLoading()
	self.mOwner:ShowApplyList()
end

function PartyMainModel:doRefuseApplyRequest(index)
	self.mAgreeIndex = index
	local packet = NetSystem.mNetManager:GetSPacket()
    packet:SetType(PacketTyper._PTYPE_CS_REFUSE_JOIN_REQUEST)
    packet:PushString(self.mApplyInfoArr[index].mPlayerIdStr)
    packet:Send()
    GUISystem:showLoading()
end

function PartyMainModel:onRefuseApplyResponse(msgPacket)
	local ret = msgPacket:GetChar()

	GUISystem:hideLoading()
	if ret == 0 then 
		table.remove(self.mApplyInfoArr,self.mAgreeIndex)
		if self.mOwner.mApplyTV ~= nil then
			self.mOwner.mApplyTV:UpdateTableView(#self.mApplyInfoArr)
		end
	end
end

function PartyMainModel:doAgreeApplyRequest(index)
	self.mAgreeIndex = index
	local packet = NetSystem.mNetManager:GetSPacket()
    packet:SetType(PacketTyper._PTYPE_CS_AGREE_JOIN_REQUEST)
    packet:PushString(self.mApplyInfoArr[index].mPlayerIdStr)
    packet:Send()
    GUISystem:showLoading()
end

function PartyMainModel:onAgreeApplyResponse(msgPacket)
	local ret = msgPacket:GetChar()

	GUISystem:hideLoading()
	if ret == 0 then 
		self.mMemberCnt = self.mMemberCnt + 1

		table.remove(self.mApplyInfoArr,self.mAgreeIndex)
		if self.mOwner.mApplyTV ~= nil then
			self.mOwner.mApplyTV:UpdateTableView(#self.mApplyInfoArr)
		end
	end
end

function PartyMainModel:doModifyConfigRequest(partyName,limitType,levelLimit,iconId)
	if partyName == "" then return end

	self.mModifyPartyName  = partyName
	self.mModifyLimitType  = limitType
	self.mModifyLevelLimit = levelLimit
	self.mModifyIconId	   = iconId

	local packet = NetSystem.mNetManager:GetSPacket()
    packet:SetType(PacketTyper._PTYPE_CS_MODIFY_CONFIG_REQUEST)
    packet:PushString(partyName)
    packet:PushChar(limitType)
    packet:PushInt(levelLimit)
    packet:PushInt(iconId)
    packet:Send()
    GUISystem:showLoading()
end

function PartyMainModel:onModifyConfigResponse(msgPacket)
	local ret = msgPacket:GetChar()

	GUISystem:hideLoading()

	if ret == SUCCESS then
		self.mPartyName        = self.mModifyPartyName
		self.mJoinLimitType    = self.mModifyLimitType
		self.mJoinLimitLv      = self.mModifyLevelLimit
		self.mPartyIconId      = self.mModifyIconId
		globaldata.partyIconId = self.mPartyIconId

		if self.mOwner then
			local infoPanel = self.mOwner.mPPFs[1][2]
			local resId = DB_GuildIcon.getDataById(self.mPartyIconId).ResourceListID
			local resData = DB_ResourceList.getDataById(resId)
			infoPanel:getChildByName("Image_Icon"):loadTexture(resData.Res_path1)
		end
	end
end

function PartyMainModel:doModifyBulletin(bulletinStr)
	self.mBulletin = bulletinStr
	local packet = NetSystem.mNetManager:GetSPacket()
    packet:SetType(PacketTyper._PTYPE_CS_MODIFY_BULLETIN_REQUEST)
    packet:PushString(bulletinStr)
    packet:Send()
    GUISystem:showLoading()
end

function PartyMainModel:onModifyBulletinResponse(msgPacket)
	local ret = msgPacket:GetChar()

	GUISystem:hideLoading()
	if ret == 0 then 
		self.mOwner:UpdateBulletin()
	end
end

function PartyMainModel:doGivePartyRequest(index)
	local packet = NetSystem.mNetManager:GetSPacket()
    packet:SetType(PacketTyper._PTYPE_CS_GIVE_PARTY_REQUEST)
    packet:PushString(self.mMemberInfoArr[index + 1].mMemberIdStr)
    packet:Send()

    GUISystem:showLoading()
end

function PartyMainModel:onGivePartyResponse(msgPacket)
	local ret = msgPacket:GetChar()

	GUISystem:hideLoading()
	if ret == SUCCESS then
		self:doLoadMembersRequest()
		if self.mOwner then
			MessageBox:showMessageBox1()
			self.mOwner.mPPFs[3][1]:setVisible(false)
			self.mOwner.mPPFs[4][1]:setVisible(false)

			self.mPartyRole = PARTYROLE.MEMBER
		end
	end

	MessageBox:showMessageBox1(ret == SUCCESS and "移交成功！" or "移交失败！")
end

--==================================================================window begin=========================================================================

local PartyMainWindow = 
{
	mName 				= "PartyMainWindow",
	mRootNode			=	nil,	
	mRootWidget 		= 	nil,
	mTopRoleInfoPanel	=	nil,	-- 顶部人物信息面板
	mModel				=   nil,

	mPPFs               =   {{},{},{},{}},     --pages panel function

	mRecordTV 			=   nil,
	mMemberTV			=   nil,
	mApplyTV			=   nil,

	mBulletinEdit		 = nil,
	mModifyNameEdit		 = nil,
}

function PartyMainWindow:Load(event)
	cclog("=====PartyMainWindow:Load=====begin")

	self.mRootNode = cc.Node:create()
	GUISystem:GetRootNode():addChild(self.mRootNode)
	--self.mEventData    = event.mData
	self.mModel = PartyMainModel:getInstance()
	self.mModel:setOwner(self)

	
	self:InitLayout()
	
	cclog("=====PartyMainWindow:Load=====end")
end

function PartyMainWindow:InitLayout()
	if self.mRootWidget == nil then
		self.mRootWidget = GUIWidgetPool:createWidget("Guild_Main")
   		self.mRootNode:addChild(self.mRootWidget)
   	end

   	if self.mTopRoleInfoPanel == nil then
		cclog("PartyMainWindow mTopRoleInfoPanel init")
		self.mTopRoleInfoPanel = TopRoleInfoPanel:new()
		self.mTopRoleInfoPanel:init(self.mRootNode, ROLE_TITLE_TYPE.TITLE_PARTY,
		function()
			GUISystem:playSound("homeBtnSound")		
			EventSystem:PushEvent(Event.GUISYSTEM_HIDE_PARTYMAINWINDOW)	
		end)
	end

	local topSize = self.mTopRoleInfoPanel.mTopWidget:getContentSize()
	local y = getGoldFightPosition_Middle().y - topSize.height / 2
	local x = getGoldFightPosition_Middle().x

	local mainPanel = self.mRootWidget:getChildByName("Panel_Main")
	mainPanel:setVisible(true)
	mainPanel:setAnchorPoint(0.5,0.5)
	mainPanel:setPosition(cc.p(x,y))

	local imgName = {"guild_main_page_guildinfo","guild_main_page_memberlist","guild_main_page_joinapply","guild_main_page_setting"}
	local lastSel = nil

	local function OnPressPage(widget)
		if lastSel and lastSel == widget then return end

		local tag = widget:getTag()
		widget:loadTexture(string.format("%s%d.png",imgName[tag],1))

		if lastSel then
			local lastTag =  lastSel:getTag()
			lastSel:loadTexture(string.format("%s%d.png",imgName[lastTag],2))
			self.mPPFs[lastTag][2]:setVisible(false)
		end

		self.mPPFs[tag][3]()

		lastSel = widget
	end

	local panelWin = self.mRootWidget:getChildByName("Panel_Window")
	local panelPages = panelWin:getChildByName("Panel_Pages")

	self.mPPFs[1][1] = panelPages:getChildByName("Image_Page_GuildInfo")
	self.mPPFs[2][1] = panelPages:getChildByName("Image_Page_MemberList")
	self.mPPFs[3][1] = panelPages:getChildByName("Image_Page_JoinApply")
	self.mPPFs[4][1] = panelPages:getChildByName("Image_Page_Setting")

	self.mPPFs[1][2] = panelWin:getChildByName("Panel_GuildInfo")
	self.mPPFs[2][2] = panelWin:getChildByName("Panel_MemberList")
	self.mPPFs[3][2] = panelWin:getChildByName("Panel_JoinApply")
	self.mPPFs[4][2] = panelWin:getChildByName("Panel_Setting")

	self.mPPFs[1][3] = function() 
							self.mModel:doLoadPartyInfoRequest()
							if self.mMemberTV then self.mMemberTV.mTableView:setTouchEnabled(false) end
							if self.mApplyTV then self.mApplyTV.mTableView:setTouchEnabled(false) end 
						end
	self.mPPFs[2][3] = function() 
							self.mModel:doLoadMembersRequest() 
							if self.mMemberTV then self.mMemberTV.mTableView:setTouchEnabled(true) end
							if self.mApplyTV then self.mApplyTV.mTableView:setTouchEnabled(false) end
						end
	self.mPPFs[3][3] = function() 
							self.mModel:doLoadApplyListRequest() 
							if self.mMemberTV then self.mMemberTV.mTableView:setTouchEnabled(false) end
							if self.mApplyTV then self.mApplyTV.mTableView:setTouchEnabled(true) end
						end
	self.mPPFs[4][3] = function() 
							self:ShowConfigInfo() 
							if self.mMemberTV then self.mMemberTV.mTableView:setTouchEnabled(false) end
							if self.mApplyTV then self.mApplyTV.mTableView:setTouchEnabled(false) end
						end

	for i=1,#self.mPPFs do
		self.mPPFs[i][1]:setTag(i)
		registerWidgetReleaseUpEvent(self.mPPFs[i][1],OnPressPage)
	end

	OnPressPage(self.mPPFs[1][1])
end

function PartyMainWindow:ShowPartyInfo()
	local infoPanel = self.mPPFs[1][2]

	if self.mModel.mPartyRole == PARTYROLE.MASTER then
		infoPanel:getChildByName("Button_64"):setVisible(true)
	else
		infoPanel:getChildByName("Button_64"):setVisible(false)
	end

	if self.mModel.mPartyRole == PARTYROLE.MASTER then 
		self.mPPFs[4][1]:setVisible(true)
		self.mPPFs[3][1]:setVisible(true)
		self.mRootWidget:getChildByName("Image_Line3"):setVisible(true)
	elseif self.mModel.mPartyRole == PARTYROLE.SMALLMASTER then
		self.mPPFs[3][1]:setVisible(true)
		self.mPPFs[4][1]:setVisible(true)
		self.mRootWidget:getChildByName("Image_Line3"):setVisible(true)
	else
		self.mPPFs[3][1]:setVisible(false)
		self.mPPFs[4][1]:setVisible(false)
		self.mRootWidget:getChildByName("Image_Line3"):setVisible(false)
	end
	
	infoPanel:getChildByName("Label_Name"):setString(self.mModel.mPartyName)
	infoPanel:getChildByName("Label_ID"):setString(self.mModel.mPartyId)
	infoPanel:getChildByName("Label_Level"):setString(tostring(self.mModel.mPartyLv))
	infoPanel:getChildByName("Label_Notice"):setString(self.mModel.mBulletin)
    infoPanel:getChildByName("Label_guildEXP"):setString(string.format("%d/%d",self.mModel.mCurExp,self.mModel.mMaxExp))
	infoPanel:getChildByName("ProgressBar_GuildEXP"):setPercent(self.mModel.mCurExp / self.mModel.mMaxExp * 100)


	local resId = DB_GuildIcon.getDataById(self.mModel.mPartyIconId).ResourceListID
	local resData = DB_ResourceList.getDataById(resId)
	infoPanel:getChildByName("Image_Icon"):loadTexture(resData.Res_path1)

	if self.mRecordTV == nil then
		self.mRecordTV = RecordTableView:new(self,0)
		self.mRecordTV:init(infoPanel:getChildByName("Panel_Records"))
	end

	if self.mModel.mPartyRole == PARTYROLE.MASTER then
		infoPanel:getChildByName("Button_LeaveGuild"):getChildByName("Label_LeaveGuild"):setString("解散公会")
	else
		infoPanel:getChildByName("Button_LeaveGuild"):getChildByName("Label_LeaveGuild"):setString("退出公会")
	end

	registerWidgetReleaseUpEvent(infoPanel:getChildByName("Button_LeaveGuild"),
	function()
		if self.mModel.mPartyRole == PARTYROLE.MASTER then
			MessageBox:showMessageBox2("确定解散公会？",function() self.mModel:doDisBandPartyRequest() end,function() return end)			
		else
			MessageBox:showMessageBox2("确定退出公会？",function() self.mModel:doQuitPartyRequest() end,function() return end) 
		end
	end)

	registerWidgetReleaseUpEvent(infoPanel:getChildByName("Button_64"),function() self:InitBulletinPanel() end)

	infoPanel:setVisible(true)
end

function PartyMainWindow:ShowMembers()
	local memberPanel = self.mPPFs[2][2]

	if self.mMemberTV == nil then
		self.mMemberTV = MemberTableView:new(self,0)
		self.mMemberTV:init(memberPanel:getChildByName("Panel_TableView_MemberList"))
	else
		self.mMemberTV:UpdateTableView(#self.mModel.mMemberInfoArr)
	end

	registerWidgetReleaseUpEvent(memberPanel,
	function(widget) 
		widget:getChildByName("Panel_Options"):setVisible(false) 
		--widget:getChildByName("Panel_Position"):setVisible(false) 
	end)


	registerWidgetReleaseUpEvent(memberPanel:getChildByName("Button_Friends"),
	function(widget)		
		self.mModel:doAddFriendRequest(self.mMemberTV:getCurSelIndex())
		memberPanel:getChildByName("Panel_Close"):setVisible(false)
		--memberPanel:getChildByName("Panel_Position"):setVisible(false) 
		memberPanel:getChildByName("Panel_Options"):setVisible(false)  
	end)

	registerWidgetReleaseUpEvent(memberPanel:getChildByName("Button_Chat"),
	function(widget)
		memberPanel:getChildByName("Panel_Close"):setVisible(false)
		--memberPanel:getChildByName("Panel_Position"):setVisible(false)
		memberPanel:getChildByName("Panel_Options"):setVisible(false) 
		self.mModel:doChatRequest(self.mMemberTV:getCurSelIndex())
  
	end)

	registerWidgetReleaseUpEvent(memberPanel:getChildByName("Panel_Close"),
	function(widget)
		memberPanel:getChildByName("Panel_Close"):setVisible(false)
		--memberPanel:getChildByName("Panel_Position"):setVisible(false)
		memberPanel:getChildByName("Panel_Options"):setVisible(false)
	end) 

	local posImgArr = {}

	local function onPressPosition(widget)
		widget:loadTexture("guild_menberlist_position_2.png")
		local tag = widget:getTag()

		for i=1,#posImgArr do
			if posImgArr[i]:getTag() ~= tag then
				 posImgArr[i]:loadTexture("guild_menberlist_position_1.png")
			end
		end
		self.mModel:doAppointRequest(self.mMemberTV:getCurSelIndex(),tag)
		memberPanel:getChildByName("Panel_Close"):setVisible(false)
		memberPanel:getChildByName("Panel_Options"):setVisible(false) 
		--memberPanel:getChildByName("Panel_Position"):setVisible(false) 
	end



	registerWidgetReleaseUpEvent(memberPanel:getChildByName("Button_Appoint"),
	function(widget)
		if widget:getChildByName("Label_Appoint"):getString() == "撤职" then
			self.mModel:doAppointRequest(self.mMemberTV:getCurSelIndex(),1)
			--widget:getChildByName("Label_Appoint"):setString("任命副会长")
		else
			self.mModel:doAppointRequest(self.mMemberTV:getCurSelIndex(),2)
			--widget:getChildByName("Label_Appoint"):setString("撤职")
		end
		memberPanel:getChildByName("Panel_Close"):setVisible(false)
		memberPanel:getChildByName("Panel_Options"):setVisible(false) 
		--memberPanel:getChildByName("Panel_Position"):setVisible(false) 
	end)

	registerWidgetReleaseUpEvent(memberPanel:getChildByName("Button_TakeOut"),
	function(widget)
		self.mModel:doFireRequest(self.mMemberTV:getCurSelIndex()) 
		memberPanel:getChildByName("Panel_Close"):setVisible(false)
		memberPanel:getChildByName("Panel_Options"):setVisible(false) 
		--memberPanel:getChildByName("Panel_Position"):setVisible(false)
	end)

	registerWidgetReleaseUpEvent(memberPanel:getChildByName("Button_HandPower"),
	function(widget)
	 	self.mModel:doGivePartyRequest(self.mMemberTV:getCurSelIndex())
	 	memberPanel:getChildByName("Panel_Close"):setVisible(false)
	 	memberPanel:getChildByName("Panel_Options"):setVisible(false)
		--memberPanel:getChildByName("Panel_Position"):setVisible(false) 
	end)

	memberPanel:setVisible(true)
end

function PartyMainWindow:ShowApplyList()
	local applyPanel = self.mPPFs[3][2]

	if self.mApplyTV == nil then
		self.mApplyTV = ApplyTableView:new(self,0)
		self.mApplyTV:init(applyPanel:getChildByName("Panel_MenberList"))
	else
		self.mApplyTV:UpdateTableView(#self.mModel.mApplyInfoArr)
	end

	if #self.mModel.mApplyInfoArr == 0 then
		applyPanel:getChildByName("Label_Nobody"):setVisible(true)
	else
		applyPanel:getChildByName("Label_Nobody"):setVisible(false)
	end

	applyPanel:getChildByName("Label_MumberAmount"):setString(string.format("会员数：%d/%d",self.mModel.mMemberCnt,self.mModel.mMemberMaxCnt)) 

	applyPanel:setVisible(true)
end

function PartyMainWindow:ShowConfigInfo()
	local configPanel = self.mPPFs[4][2]

	local size = configPanel:getChildByName("Image_Write_Bg"):getContentSize()
	local pos = configPanel:getChildByName("Image_Write_Bg"):getPosition()
	local iconId = self.mModel.mPartyIconId

	local resId = DB_GuildIcon.getDataById(self.mModel.mPartyIconId).ResourceListID
	local resData = DB_ResourceList.getDataById(resId)
	configPanel:getChildByName("Image_180"):loadTexture(resData.Res_path1)

	local function ShowPartyIcon()
		local iconChosePanel = GUIWidgetPool:createWidget("Guild_IconReplace")
		iconChosePanel:setTouchEnabled(true)

		local function closeWindow()
			local resId = DB_GuildIcon.getDataById(iconId).ResourceListID
			local resData = DB_ResourceList.getDataById(resId)
			configPanel:getChildByName("Image_180"):loadTexture(resData.Res_path1)

			iconChosePanel:removeFromParent() 
			iconChosePanel = nil 
		end

		registerWidgetReleaseUpEvent(iconChosePanel,closeWindow)
		registerWidgetReleaseUpEvent(iconChosePanel:getChildByName("Button_Close"),closeWindow)
		registerWidgetReleaseUpEvent(iconChosePanel:getChildByName("Button_Save"),closeWindow)

		self.mRootNode:addChild(iconChosePanel,100)
		local lastSel = nil

		local function OnSelectIcon(widget)
			if lastSel then 
				lastSel:getChildByName("Image_Chose"):setVisible(false)
			end
			iconId = widget:getTag()
			widget:getChildByName("Image_Chose"):setVisible(true) 
			lastSel = widget
		end

		for i=1,12 do
			local resId = DB_GuildIcon.getDataById(i).ResourceListID
			local resData = DB_ResourceList.getDataById(resId)
			local icon = iconChosePanel:getChildByName(string.format("Panel_icon_%d",i))

			icon:setTag(i)
			icon:getChildByName("Image_Icon"):loadTexture(resData.Res_path1)
			registerWidgetReleaseUpEvent(icon,OnSelectIcon)
		end

		OnSelectIcon(iconChosePanel:getChildByName(string.format("Panel_icon_%d",iconId)))
	end

	registerWidgetReleaseUpEvent(configPanel:getChildByName("Button_Browse"),ShowPartyIcon) 

	self.mModifyNameEdit = cc.EditBox:create(size, cc.Scale9Sprite:create("editbox_bg.png"))
	self.mModifyNameEdit:setFont("res/fonts/font_3.ttf", 20)
	--self.mModifyNameEdit:setFontSize(10)
	configPanel:getChildByName("Image_Write_Bg"):addChild(self.mModifyNameEdit)
	self.mModifyNameEdit:setAnchorPoint(0,0)
	self.mModifyNameEdit:setPosition(pos)

	self.mModifyNameEdit:setText(self.mModel.mPartyName)
	--configPanel:getChildByName("Label_Name"):setString(self.mModel.mPartyName)
	configPanel:getChildByName("Label_Name"):setVisible(false) 

	local function editBoxTextEventHandle(strEventName,pSender)
		if strEventName == "began" then	
		elseif strEventName == "ended" then		
		elseif strEventName == "return" then	
		elseif strEventName == "changed" then	
		end
	end

	self.mModifyNameEdit:registerScriptEditBoxHandler(editBoxTextEventHandle)

	local levelLimitImageArr = {}
	local imageNameArr1 = {"guild_setting_check1.png","guild_setting_check1.png","guild_setting_check1.png"}
	local imageNameArr2 = {"guild_setting_check2.png","guild_setting_check2.png","guild_setting_check2.png"}

	levelLimitImageArr[1] = configPanel:getChildByName("Image_None")
	levelLimitImageArr[2] = configPanel:getChildByName("Image_Check")
	levelLimitImageArr[3] = configPanel:getChildByName("Image_Forbidden")

	local limitType = self.mModel.mJoinLimitType

	levelLimitImageArr[limitType]:loadTexture(imageNameArr2[limitType])

	local function onPressLimit(widget)
		limitType = widget:getTag()

		for i=1,#levelLimitImageArr do
			if levelLimitImageArr[i]:getTag() ~= limitType then
				levelLimitImageArr[i]:loadTexture(imageNameArr1[i])
			else
				levelLimitImageArr[i]:loadTexture(imageNameArr2[i])
			end
		end
	end

	for i=1,#levelLimitImageArr do
		levelLimitImageArr[i]:setTag(i)
		registerWidgetReleaseUpEvent(levelLimitImageArr[i],onPressLimit)

		if levelLimitImageArr[i]:getTag() ~= limitType then
			levelLimitImageArr[i]:loadTexture(imageNameArr1[i])
		else
			levelLimitImageArr[i]:loadTexture(imageNameArr2[i])
		end
	end

	configPanel:getChildByName("Label_233"):setString(tostring(self.mModel.mJoinLimitLv))

	local levelLimit = self.mModel.mJoinLimitLv
	registerWidgetReleaseUpEvent(configPanel:getChildByName("Button_Sub10"),function()
		levelLimit = levelLimit - 10
		if levelLimit < 0 then levelLimit = 0 end
		configPanel:getChildByName("Label_233"):setString(tostring(levelLimit))
	end)

	registerWidgetReleaseUpEvent(configPanel:getChildByName("Button_Add10"),function()
		levelLimit = levelLimit + 10
		if levelLimit > 90 then levelLimit = 90 end
		configPanel:getChildByName("Label_233"):setString(tostring(levelLimit))
	end)

	registerWidgetReleaseUpEvent(configPanel:getChildByName("Button_Sub1"),function()
		levelLimit = levelLimit - 1
		if levelLimit < 0 then levelLimit = 0 end
		configPanel:getChildByName("Label_233"):setString(tostring(levelLimit))
	end)

	registerWidgetReleaseUpEvent(configPanel:getChildByName("Button_Add1"),function()
		levelLimit = levelLimit + 1
		if levelLimit > 90 then levelLimit = 90 end
		configPanel:getChildByName("Label_233"):setString(tostring(levelLimit))
	end)

	registerWidgetReleaseUpEvent(configPanel:getChildByName("Button_SaveSetting"), function() self.mModel:doModifyConfigRequest(self.mModifyNameEdit:getText(),limitType,levelLimit,iconId) end)

	configPanel:setVisible(true)
end

local bulletinPanel = nil

function PartyMainWindow:InitBulletinPanel()
	bulletinPanel =  GUIWidgetPool:createWidget("Guild_Main_NoticeWrite")
	self.mRootWidget:addChild(bulletinPanel,1000)

	local posLD = getGoldFightPosition_LD()
	local editPanel =  bulletinPanel:getChildByName("Panel_Window")
	editPanel:setAnchorPoint(0.5,0.5) 

	bulletinPanel:getChildByName("Panel_Window"):setPosition(VisibleRect:center())
	bulletinPanel:getChildByName("Label_NoticeInput"):setVisible(false) --setString(self.mModel.mBulletin)

	local size = bulletinPanel:getChildByName("Panel_TextField_Bg"):getContentSize()
	local pos = bulletinPanel:getChildByName("Panel_TextField_Bg"):getPosition()

	self.mBulletinEdit = cc.EditBox:create(size, cc.Scale9Sprite:create("editbox_bg.png"))
	self.mBulletinEdit:setFont("font_3.ttf",25)
	self.mBulletinEdit:setAnchorPoint(0,0)
	self.mBulletinEdit:setPosition(pos)
	self.mBulletinEdit:setMaxLength(500)
	--self.mBulletinEdit:openKeyBoard()
	--self.mBulletinEdit:setPositionY(1000)
	self.mBulletinEdit:setText(self.mModel.mBulletin)

	bulletinPanel:getChildByName("Panel_TextField_Bg"):addChild(self.mBulletinEdit)

	local function editBoxTextEventHandle(strEventName,pSender)
		if strEventName == "began" then	
			--self.mBulletinEdit:setPositionY(1000)
			--self.mBulletinEdit:openKeyBoard()	
			--self.mBulletinEdit:setText(bulletinPanel:getChildByName("Label_NoticeInput"):getString())
		elseif strEventName == "ended" then	
			editPanel:setPosition(VisibleRect:center())
			--self.mBulletinEdit:closeKeyBoard()
		elseif strEventName == "return" then
			editPanel:setPosition(VisibleRect:center())
			--self.mBulletinEdit:setText("")
			--self.mBulletinEdit:closeKeyBoard()			
			--self.mBulletinEdit:setPositionY(0)	
		elseif strEventName == "changed" then
			--self.mBulletinEdit:setPositionY(1000)
			--bulletinPanel:getChildByName("Label_NoticeInput"):setString(G_AddChangeLineForText(self.mBulletinEdit:getText(),25,size.width))
		end
	end

	self.mBulletinEdit:registerScriptEditBoxHandler(editBoxTextEventHandle)
	
	registerWidgetReleaseUpEvent(bulletinPanel:getChildByName("Button_Close"),
	function() 
		if self.mBulletinEdit ~= nil then
			self.mBulletinEdit:closeKeyBoard()
			self.mBulletinEdit:removeFromParent(true)
			self.mBulletinEdit = nil 
		end

		bulletinPanel:removeFromParent()
		bulletinPanel = nil 
	end)
	registerWidgetReleaseUpEvent(bulletinPanel:getChildByName("Button_Done"),
	function() 
		self.mModel:doModifyBulletin(self.mBulletinEdit:getText()) --bulletinPanel:getChildByName("Label_NoticeInput"):getString()
		self.mBulletinEdit:setText("")
		if self.mBulletinEdit ~= nil then
			self.mBulletinEdit:removeFromParent(true)
			self.mBulletinEdit = nil 
		end  
	end)
end

function PartyMainWindow:UpdateBulletin()
	bulletinPanel:removeFromParent()
	bulletinPanel = nil 


	local label = self.mPPFs[1][2]:getChildByName("Label_Notice")
	local width = label:getContentSize().width
	label:setString(G_AddChangeLineForText(self.mModel.mBulletin,20,width))
end

function PartyMainWindow:Destroy()
	if self.mTopRoleInfoPanel ~= nil then
		self.mTopRoleInfoPanel:destroy()
		self.mTopRoleInfoPanel = nil
	end

	self.mModel:destroyInstance()
	self.mPPFs = {{},{},{},{}}

	if self.mPartyTV ~= nil then
		self.mPartyTV:Destroy()
		self.mPartyTV        = nil
	end

	if self.mRecordTV ~= nil then
		self.mRecordTV:Destroy()
		self.mRecordTV       = nil
	end

	if self.mMemberTV ~= nil then
		self.mMemberTV:Destroy()
		self.mMemberTV       = nil
	end

	if self.mApplyTV ~= nil then
		self.mApplyTV:Destroy()
		self.mApplyTV       = nil
	end

	if self.mBulletinEdit ~= nil then
		self.mBulletinEdit:removeFromParent(true)
		self.mBulletinEdit = nil 
	end

	if self.mModifyNameEdit ~= nil then
		self.mModifyNameEdit:removeFromParent(true)
		self.mModifyNameEdit = nil 
	end

    self.mRootWidget = nil
    
	if self.mRootNode then
		self.mRootNode:removeFromParent(true)
		self.mRootNode = nil
	end

	----------------
	CommonAnimation.clearAllTextures()
end

function PartyMainWindow:onEventHandler(event)
	if event.mAction == Event.WINDOW_SHOW then
		self:Load(event)
		---------停止画帮派界面
		EventSystem:PushEvent(Event.GUISYSTEM_DISABLEDRAW_UNIONHALLWINDOW)
		---------
	elseif event.mAction == Event.WINDOW_HIDE then
		self:Destroy()
		---------开启画帮派界面
		EventSystem:PushEvent(Event.GUISYSTEM_ENABLEDRAW_UNIONHALLWINDOW)
		---------
	end
end

return PartyMainWindow