-- Name: 	PartyBuildWindow
-- Func：	帮会建设界面
-- Author:	lichuan
-- Data:	16-2-28

local PBMInstance = nil

PartyBuildModel = class("PartyBuildModel")

function PartyBuildModel:ctor()
	self.mName		    = "PartyBuildModel"
	self.mOwner         = nil
	self.mPartyRole     = nil
	self:registerNetEvent()
end

function PartyBuildModel:deinit()
	self.mName  	     = nil
	self.mOwner 	     = nil
	self.mPartyRole      = nil
	self:unRegisterNetEvent()
end

function PartyBuildModel:getInstance()
	if PBMInstance == nil then  
        PBMInstance = PartyBuildModel.new()
    end  
    return PBMInstance
end

function PartyBuildModel:destroyInstance()
	if PBMInstance then
		PBMInstance:deinit()
    	PBMInstance = nil
    end
end

function PartyBuildModel:registerNetEvent()
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_DONATE_PARTY_RESPONSE, handler(self, self.onDonateResponse))
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_BUILD_PARTY_RESPONSE, handler(self, self.onBuildPartyResponse))
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_BUILD_INFO_RESPONSE, handler(self, self.onLoadBuildInfoResponse))
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_DONATE_INFO_RESPONSE, handler(self, self.onLoadDonateInfoResponse))
end

function PartyBuildModel:unRegisterNetEvent()
	NetSystem.mNetManager:UnregisterPacketHandler(PacketTyper._PTYPE_SC_DONATE_PARTY_RESPONSE)
	NetSystem.mNetManager:UnregisterPacketHandler(PacketTyper._PTYPE_SC_BUILD_PARTY_RESPONSE)
	NetSystem.mNetManager:UnregisterPacketHandler(PacketTyper._PTYPE_SC_BUILD_INFO_RESPONSE)
	NetSystem.mNetManager:UnregisterPacketHandler(PacketTyper._PTYPE_SC_DONATE_INFO_RESPONSE)
end

function PartyBuildModel:setOwner(owner)
	self.mOwner = owner
end

function PartyBuildModel:doLoadBuildInfoRequest()
	local packet = NetSystem.mNetManager:GetSPacket()
    packet:SetType(PacketTyper._PTYPE_CS_BUILD_INFO_REQUEST)
    packet:Send()
    GUISystem:showLoading()
end

function PartyBuildModel:onLoadBuildInfoResponse(msgPacket)
	self.mPartyIconId     = msgPacket:GetInt()
	self.mBuildValue      = msgPacket:GetInt()
	self.mContriValue     = msgPacket:GetInt()
	local partyLv         = msgPacket:GetInt()

	local typeLv1         = msgPacket:GetInt()
	local needValue1      = msgPacket:GetInt()
	local needPartyLv1    = msgPacket:GetInt()
	
	local typeLv2         = msgPacket:GetInt()
	local needValue2      = msgPacket:GetInt()
	local needPartyLv2    = msgPacket:GetInt()

	local typeLv3         = msgPacket:GetInt()
	local needValue3      = msgPacket:GetInt()
	local needPartyLv3    = msgPacket:GetInt()

	self.mPartyRole 	  = msgPacket:GetChar()

	local infoArr =  {{self.mBuildValue,self.mContriValue,partyLv},{typeLv1,needValue1,needPartyLv1},{typeLv2,needValue2,needPartyLv2},{typeLv3,needValue3,needPartyLv3}}

	GUISystem:hideLoading()

	Event.GUISYSTEM_SHOW_PARTYBUILDWINDOW.mData = infoArr
	EventSystem:PushEvent(Event.GUISYSTEM_SHOW_PARTYBUILDWINDOW)
end

function PartyBuildModel:doLoadDonateInfoRequest()
	local packet = NetSystem.mNetManager:GetSPacket()
    packet:SetType(PacketTyper._PTYPE_CS_DONATE_INFO_REQUEST)
    packet:Send()
    GUISystem:showLoading()
end

function PartyBuildModel:onLoadDonateInfoResponse(msgPacket)
	local vipLv     = msgPacket:GetInt()
	local donateCnt = msgPacket:GetInt()
	local leftCnt   = msgPacket:GetInt()

	if leftCnt < 0 then leftCnt = 0 end

	local donateInfoArr = {{0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0}}

	local optionCnt = msgPacket:GetInt()

	if optionCnt < 0 then optionCnt = 0 end

	if optionCnt > 0 then
		for i=1,optionCnt do
			donateInfoArr[i][1] = msgPacket:GetInt()
			donateInfoArr[i][2] = msgPacket:GetInt()
			donateInfoArr[i][3] = msgPacket:GetInt()
			donateInfoArr[i][4] = msgPacket:GetInt()
		end
	end

	donateInfoArr[4][1] = vipLv
	donateInfoArr[4][2] = donateCnt
	donateInfoArr[4][3] = leftCnt
	donateInfoArr[4][4] = optionCnt

	GUISystem:hideLoading()
	self.mOwner:ShowDonateOption(donateInfoArr)
end

function PartyBuildModel:doDonateRequest(index)
	local packet = NetSystem.mNetManager:GetSPacket()
    packet:SetType(PacketTyper._PTYPE_CS_DONATE_PARTY_REQUEST)
    packet:PushChar(index)
    packet:Send()
    GUISystem:showLoading()
end

function PartyBuildModel:onDonateResponse(msgPacket)
	local ret = msgPacket:GetChar()

	GUISystem:hideLoading()

	if ret == 0 then 
		self.mBuildValue  =  msgPacket:GetInt()
		self.mContriValue =  msgPacket:GetInt()
		local partyLv         = msgPacket:GetInt()

		local typeLv1         = msgPacket:GetInt()
		local needValue1      = msgPacket:GetInt()
		local needPartyLv1    = msgPacket:GetInt()
		
		local typeLv2         = msgPacket:GetInt()
		local needValue2      = msgPacket:GetInt()
		local needPartyLv2    = msgPacket:GetInt()

		local typeLv3         = msgPacket:GetInt()
		local needValue3      = msgPacket:GetInt()
		local needPartyLv3    = msgPacket:GetInt()

		GUISystem:hideLoading()
		local infoArr =  {	{self.mBuildValue,self.mContriValue,partyLv},
							{typeLv1,needValue1,needPartyLv1},
							{typeLv2,needValue2,needPartyLv2},
							{typeLv3,needValue3,needPartyLv3},	}		

		MessageBox:showMessageBox1("捐赠成功！")
		self.mOwner:UpdateBuildInfo(infoArr)
		self:doLoadDonateInfoRequest()
	else
		MessageBox:showMessageBox1("捐赠失败！")
	end
end

function PartyBuildModel:doBuildPartyRequest(type)
	local packet = NetSystem.mNetManager:GetSPacket()
    packet:SetType(PacketTyper._PTYPE_CS_BUILD_PARTY_REQUEST)
    packet:PushChar(type)
    packet:Send()
    GUISystem:showLoading()
end

function PartyBuildModel:onBuildPartyResponse(msgPacket)
	local ret = msgPacket:GetChar()

	if ret == 0 then
		self.mBuildValue      = msgPacket:GetInt()
		self.mContriValue     = msgPacket:GetInt()
		local partyLv         = msgPacket:GetInt()

		local typeLv1         = msgPacket:GetInt()
		local needValue1      = msgPacket:GetInt()
		local needPartyLv1    = msgPacket:GetInt()
		
		local typeLv2         = msgPacket:GetInt()
		local needValue2      = msgPacket:GetInt()
		local needPartyLv2    = msgPacket:GetInt()

		local typeLv3         = msgPacket:GetInt()
		local needValue3      = msgPacket:GetInt()
		local needPartyLv3    = msgPacket:GetInt()

		GUISystem:hideLoading()
		local infoArr =  {	{self.mBuildValue,self.mContriValue,partyLv},
							{typeLv1,needValue1,needPartyLv1},
							{typeLv2,needValue2,needPartyLv2},
							{typeLv3,needValue3,needPartyLv3},	}
		self.mOwner:UpdateBuildInfo(infoArr)
	end
end

--==================================================================window begin=========================================================================
local PartyBuildWindow = 
{
	mName 				= "PartyBuildWindow",
	mRootNode			=	nil,	
	mRootWidget 		= 	nil,
	mTopRoleInfoPanel	=	nil,	-- 顶部人物信息面板
	mModel				=   nil,
}

function PartyBuildWindow:Load(event)
	cclog("=====PartyBuildWindow:Load=====begin")

	self.mRootNode = cc.Node:create()
	GUISystem:GetRootNode():addChild(self.mRootNode)

	self.mEventData    = event.mData
	self.mModel = PartyBuildModel:getInstance()
	self.mModel:setOwner(self)
	
	self:InitLayout()
	
	cclog("=====PartyBuildWindow:Load=====end")
end

function PartyBuildWindow:InitLayout()
	if self.mRootWidget == nil then
		self.mRootWidget = GUIWidgetPool:createWidget("Guild_Build")
   		self.mRootNode:addChild(self.mRootWidget)
   	end

   	if self.mTopRoleInfoPanel == nil then
		cclog("PartyBuildWindow mTopRoleInfoPanel init")
		self.mTopRoleInfoPanel = TopRoleInfoPanel:new()
		self.mTopRoleInfoPanel:init(self.mRootNode, ROLE_TITLE_TYPE.TITLE_PARTY_BUILD,
		function()
			GUISystem:playSound("homeBtnSound")		
			EventSystem:PushEvent(Event.GUISYSTEM_HIDE_PARTYBUILDWINDOW)	
		end)
	end

	local topSize = self.mTopRoleInfoPanel.mTopWidget:getContentSize()
	local y = getGoldFightPosition_Middle().y - topSize.height / 2
	local x = getGoldFightPosition_Middle().x

	local mainPanel = self.mRootWidget:getChildByName("Panel_Main")
	mainPanel:setAnchorPoint(0.5,0.5)
	mainPanel:setPosition(cc.p(x,y))

	local resId = DB_GuildIcon.getDataById(self.mModel.mPartyIconId).ResourceListID
	local resData = DB_ResourceList.getDataById(resId)
	mainPanel:getChildByName("Image_Icon"):loadTexture(resData.Res_path1)
	

	self:UpdateBuildInfo(self.mEventData)
end

function PartyBuildWindow:UpdateBuildInfo(infoArr)
	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_Donation"),function() self.mModel:doLoadDonateInfoRequest() end)

	self.mBuildThree = {}
	local triangle = self.mRootWidget:getChildByName("Panel_Triangle")
	self.mBuildThree[1] = triangle:getChildByName("Panel_Weapon")
	self.mBuildThree[2] = triangle:getChildByName("Panel_Armor")
	self.mBuildThree[3] = triangle:getChildByName("Panel_Intelligence")


	for i=1,#self.mBuildThree do
		if self.mModel.mPartyRole == PARTYROLE.MASTER or self.mModel.mPartyRole == PARTYROLE.SMALLMASTER then
			self.mBuildThree[i]:getChildByName("Button_Up"):setVisible(true)
		else
			self.mBuildThree[i]:getChildByName("Button_Up"):setVisible(false)
		end

		self.mBuildThree[i]:setTag(i)
		self.mBuildThree[i]:setTouchEnabled(true)
		self.mBuildThree[i]:getChildByName("Button_Up"):setTag(i)
		self.mBuildThree[i]:getChildByName("Label_75"):setString(string.format("Lv %d",infoArr[1 +  i][1]))
		self.mBuildThree[i]:getChildByName("Label_81"):setString(tostring(infoArr[1 +  i][2]))

		local partyCurLv   = infoArr[1][3]
		local needParyLv   = infoArr[1 + i][3]
		local buildValue   = infoArr[1][1]
		local needBuildVal = infoArr[1 + i][2] 

		if partyCurLv >= needParyLv and buildValue >= needBuildVal then
			self.mBuildThree[i]:getChildByName("Button_Up"):setTouchEnabled(true)
			ShaderManager:DoUIWidgetDisabled(self.mBuildThree[i]:getChildByName("Button_Up"), false)
		else
			self.mBuildThree[i]:getChildByName("Button_Up"):setTouchEnabled(false)
			ShaderManager:DoUIWidgetDisabled(self.mBuildThree[i]:getChildByName("Button_Up"), true)
		end

		registerWidgetReleaseUpEvent(self.mBuildThree[i]:getChildByName("Button_Up"),function(widget) self.mModel:doBuildPartyRequest(widget:getTag()) end)

		local nameId = {241,242,240}
		local desId  = {244,245,243}

		local function ShowBuildTip(widget)
			local tipWidget = GUIWidgetPool:createWidget("Guild_Build_Des")
			local typ       = widget:getTag()
			local nameData  = DB_Text.getDataById(nameId[typ])
			local nameStr   = nameData.Text_CN
			local desData   = DB_Text.getDataById(desId[typ])
			local desStr    = desData.Text_CN
			local size      = tipWidget:getChildByName("Panel_Window"):getContentSize()
			local pos       = widget:getWorldPosition()

			tipWidget:getChildByName("Panel_Window"):setPosition(cc.p(pos.x - size.width,pos.y))
			tipWidget:getChildByName("Label_Title"):setString(nameStr)
			tipWidget:getChildByName("Label_Des"):setString(desStr)

			self.mRootNode:addChild(tipWidget,1000)			

			registerWidgetReleaseUpEvent(tipWidget,function()
				tipWidget:removeFromParent(true)
				tipWidget = nil
			end)

		end
		registerWidgetReleaseUpEvent(self.mBuildThree[i],ShowBuildTip)
	end

	self.mRootWidget:getChildByName("Label_Points"):setString(tostring(infoArr[1][1]))
	self.mRootWidget:getChildByName("Label_MyContribution"):setString(tostring(infoArr[1][2])) 
end

local donatePanel = nil

function PartyBuildWindow:ShowDonateOption(donateInfoArr)
	if donatePanel == nil then
		donatePanel = GUIWidgetPool:createWidget("Guild_Build_Donation")
		donatePanel:getChildByName("Panel_Window"):setTouchEnabled(true)
		self.mRootWidget:addChild(donatePanel,100)
	end

	local checkBoxArr = {}
	for i=1,3 do
		local optionPanel = donatePanel:getChildByName(string.format("Panel_Option%d",i))
		optionPanel:getChildByName("Label_GuildExpNumber"):setString(tostring(donateInfoArr[i][1]))
		optionPanel:getChildByName("Label_GuildPointsNumber_3"):setString(tostring(donateInfoArr[i][2]))
		optionPanel:getChildByName("Label_GuildPointsNumber_3_4"):setString(tostring(donateInfoArr[i][3]))
		optionPanel:getChildByName("Label_PayNumber"):setString(tostring(donateInfoArr[i][4]))
		checkBoxArr[i] = optionPanel:getChildByName("CheckBox_chosen")
		checkBoxArr[i]:setTag(i)
		registerWidgetReleaseUpEvent(checkBoxArr[i],function(widget)
			for i=1,#checkBoxArr do
				if i ~= widget:getTag() then
					checkBoxArr[i]:setSelectedState(false)
				end
			end
		end)			
	end

	donatePanel:getChildByName("Label_VipTimes"):setString(string.format("VIP%d 每日有 %d 次捐赠机会",donateInfoArr[#donateInfoArr][1],donateInfoArr[#donateInfoArr][2]))
	donatePanel:getChildByName("Label_LastTimes"):setString(string.format("剩余%d次",donateInfoArr[#donateInfoArr][3]))

	if donateInfoArr[#donateInfoArr][3] <= 0 then
		donatePanel:getChildByName("Button_Confirm"):setTouchEnabled(false)
		ShaderManager:DoUIWidgetDisabled(donatePanel:getChildByName("Button_Confirm"), true)   
	end

	self.mRootWidget:getChildByName("Label_Points"):setString(tostring(self.mModel.mBuildValue))
	self.mRootWidget:getChildByName("Label_MyContribution"):setString(tostring(self.mModel.mContriValue)) 

	registerWidgetReleaseUpEvent(donatePanel:getChildByName("Button_Close"),function() donatePanel:removeFromParent() donatePanel = nil self.mModel:doLoadBuildInfoRequest() end)
	registerWidgetReleaseUpEvent(donatePanel,function() donatePanel:removeFromParent() donatePanel = nil self.mModel:doLoadBuildInfoRequest() end)
	registerWidgetReleaseUpEvent(donatePanel:getChildByName("Button_Confirm"),
	function()
		for i=1,#checkBoxArr do
			if checkBoxArr[i]:getSelectedState() then
				self.mModel:doDonateRequest(checkBoxArr[i]:getTag())
				break 
			end
		end		
	end)
end

function PartyBuildWindow:Destroy()
	if donatePanel then
		donatePanel:removeFromParent(true)
		donatePanel = nil
	end
	
	if self.mTopRoleInfoPanel ~= nil then
		self.mTopRoleInfoPanel:destroy()
		self.mTopRoleInfoPanel = nil
	end

	self.mModel:destroyInstance()

    self.mRootWidget = nil
    
	if self.mRootNode then
		self.mRootNode:removeFromParent(true)
		self.mRootNode = nil
	end

	----------------
	CommonAnimation.clearAllTextures()
end

function PartyBuildWindow:onEventHandler(event)
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

return PartyBuildWindow