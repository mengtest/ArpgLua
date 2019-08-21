-- Name: 	TechnologyWindow
-- Func：	黑科技
-- Author:	lichuan
-- Data:	16-1-20

BAG_GUESS  = 1
BAG_NORMAL = 2

local TechInfo = {}
function TechInfo:new()
	local o = 
	{
		mTechName   			    = nil,	-- 科技名称
		mTechLv			            = nil,	-- 科技等级
		mTechUsedAFs                = {},   -- 用到的神器
		mTechHoleCnt                = 0,    -- 开放孔数
	}
	o = newObject(o, TechInfo)
	return o
end

function TechInfo:getKeyValue(key)
	if self[key] then
		return self[key]
	end
	return nil
end

local TecMInstance = nil

TechnologyModel = class("TechnologyModel")

function TechnologyModel:ctor()
	self.mName          = "TechnologyModel"
	self.mOwner         = nil

	--self:InitBagNormal()
	self:InitBagGuess()

	self.mTechInfo      = {}

	self.mTechCombat	= nil
	self.mCurGuessIdx   = nil

	self:registerNetEvent()
end

function TechnologyModel:deinit()
	self.mName  		= nil
	self.mOwner 		= nil
	self.mUnUsedAFs     = {}
	self.mGuessBag      = {}
	self.mTechInfo      = {}

	self.mTechCombat	= nil
	self.mCurGuessIdx   = nil

	self:unRegisterNetEvent()
end

function TechnologyModel:getInstance()
	if TecMInstance == nil then  
        TecMInstance = TechnologyModel.new()
    end  
    return TecMInstance
end

function TechnologyModel:destroyInstance()
	if TecMInstance then
		TecMInstance:deinit()
    	TecMInstance = nil
    end
end

function TechnologyModel:registerNetEvent()
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_ARTIFACT_INFO_RESPONSE, handler(self, self.onLoadArtiFactInfoResponse))
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_ARTIFACT_COMPOSE_RESPONSE, handler(self, self.onArtiFactComposeResponse))
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_ARTIFACT_SPLIT_RESPONSE, handler(self, self.onArtiFactSplitResponse))
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_TECH_UPGRADE_RESPONSE, handler(self, self.onUpGradeTechResponse))
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_ONEKEY_PICKUP_RESPONSE, handler(self, self.onOneKeyPickUpResponse))
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_PICKUP_RESPONSE, handler(self, self.onPickUpResponse))
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_GUESS_RESPONSE, handler(self, self.onGuessResponse))
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_GUESS_TEN_RESPONSE, handler(self, self.onGuessTenResponse))
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_GUESS_MASTER_RESPONSE, handler(self, self.onGuessMasterResponse))
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_ONEKEY_SWALLOW_RESPONSE, handler(self, self.onOneKeySwallowGuessResponse))
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_ONEKEY_SWALLOWN_RESPONSE, handler(self, self.onOneKeySwallowNormalResponse))
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_EXPAND_AFBAG_RESPONSE, handler(self, self.onExpandAfBagResponse))
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_SORT_AFBAG_RESPONSE, handler(self, self.onSortAfBagResponse))
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_ARITIFACT_SWALLOW_RESPONSE, handler(self, self.onSwallowResponse))
end

function TechnologyModel:unRegisterNetEvent()
	NetSystem.mNetManager:UnregisterPacketHandler(PacketTyper._PTYPE_SC_ARTIFACT_INFO_RESPONSE)
	NetSystem.mNetManager:UnregisterPacketHandler(PacketTyper._PTYPE_SC_ARTIFACT_COMPOSE_RESPONSE)
	NetSystem.mNetManager:UnregisterPacketHandler(PacketTyper._PTYPE_SC_ARTIFACT_SPLIT_RESPONSE)
	NetSystem.mNetManager:UnregisterPacketHandler(PacketTyper._PTYPE_SC_TECH_UPGRADE_RESPONSE)
	NetSystem.mNetManager:UnregisterPacketHandler(PacketTyper._PTYPE_SC_ONEKEY_PICKUP_RESPONSE)
	NetSystem.mNetManager:UnregisterPacketHandler(PacketTyper._PTYPE_SC_PICKUP_RESPONSE)
	NetSystem.mNetManager:UnregisterPacketHandler(PacketTyper._PTYPE_SC_GUESS_RESPONSE)
	NetSystem.mNetManager:UnregisterPacketHandler(PacketTyper._PTYPE_SC_GUESS_TEN_RESPONSE)
	NetSystem.mNetManager:UnregisterPacketHandler(PacketTyper._PTYPE_SC_GUESS_MASTER_RESPONSE)
	NetSystem.mNetManager:UnregisterPacketHandler(PacketTyper._PTYPE_SC_ONEKEY_SWALLOW_RESPONSE)
	NetSystem.mNetManager:UnregisterPacketHandler(PacketTyper._PTYPE_SC_EXPAND_AFBAG_RESPONSE)
	NetSystem.mNetManager:UnregisterPacketHandler(PacketTyper._PTYPE_SC_SORT_AFBAG_RESPONSE)
	NetSystem.mNetManager:UnregisterPacketHandler(PacketTyper._PTYPE_SC_ONEKEY_SWALLOWN_RESPONSE)
	NetSystem.mNetManager:UnregisterPacketHandler(PacketTyper._PTYPE_SC_ARITIFACT_SWALLOW_RESPONSE)
end

function TechnologyModel:setOwner(owner)
	self.mOwner = owner
end

function TechnologyModel:InitBagNormal()
	self.mUnUsedAFs     = {}
	for i=1,self.mBagCellCnt do
		self.mUnUsedAFs[i] = nil
	end
end

function TechnologyModel:InitBagGuess()
	self.mGuessBag      = {}

	for i=1,16 do
		self.mGuessBag[i] = nil
	end
end

function TechnologyModel:doLoadArtiFactInfoRequest()
	local packet = NetSystem.mNetManager:GetSPacket()
    packet:SetType(PacketTyper._PTYPE_CS_ARTIFACT_INFO_REQUEST)
    packet:Send()
    GUISystem:showLoading()
end

function TechnologyModel:onLoadArtiFactInfoResponse(msgPacket)
	self.mTechCombat = msgPacket:GetInt()

	local techInfo1  = TechInfo:new()
	techInfo1.mTechLv     = msgPacket:GetInt()
	techInfo1.mTechName   = msgPacket:GetString()
	techInfo1.mTechHoleCnt = msgPacket:GetInt()
	techInfo1.mTechUsedAFs = {}

	for i=1,techInfo1.mTechHoleCnt do
		local afInfo = {}
		afInfo.Id  = msgPacket:GetInt()
		afInfo.Lv  = msgPacket:GetInt()
		afInfo.Ex  = msgPacket:GetInt()
		afInfo.Idx = msgPacket:GetInt()

		table.insert(techInfo1.mTechUsedAFs,afInfo)
	end

	self.mTechInfo[1] = techInfo1

	local techInfo2  = TechInfo:new()
	techInfo2.mTechLv     = msgPacket:GetInt()
	techInfo2.mTechName   = msgPacket:GetString()
	techInfo2.mTechHoleCnt = msgPacket:GetInt()
	techInfo2.mTechUsedAFs = {}

	for i=1,techInfo2.mTechHoleCnt do
		local afInfo = {}
		afInfo.Id  = msgPacket:GetInt()
		afInfo.Lv  = msgPacket:GetInt()
		afInfo.Ex  = msgPacket:GetInt()
		afInfo.Idx = msgPacket:GetInt()


		table.insert(techInfo2.mTechUsedAFs,afInfo)
	end

	self.mTechInfo[2] = techInfo2

	self.mBagCellCnt = msgPacket:GetInt()
	self:InitBagNormal()

	local unUsedCnt = msgPacket:GetInt()
	for i=1,unUsedCnt do
		local afInfo = {}
		afInfo.Id  = msgPacket:GetInt()
		afInfo.Lv  = msgPacket:GetInt()
		afInfo.Ex  = msgPacket:GetInt()
		afInfo.Idx = msgPacket:GetInt()

		self.mUnUsedAFs[afInfo.Idx] = afInfo
	end

	local guessAfCnt = msgPacket:GetUShort()
	for i=1,guessAfCnt do
		local afInfo = {}
		afInfo.Id  = msgPacket:GetInt()
		afInfo.Lv  = msgPacket:GetInt()
		afInfo.Ex  = msgPacket:GetInt()
		afInfo.Idx = msgPacket:GetInt()

		self.mGuessBag[afInfo.Idx] = afInfo
	end

	self.mCurGuessIdx = msgPacket:GetInt()
	self.mGuessPrice  = msgPacket:GetInt()
	self.mMasterPrice = msgPacket:GetInt()

	GUISystem:hideLoading()
	if self.mEndFunc2 then
		self.mEndFunc2()
		self.mEndFunc2 = nil
	end

	EventSystem:PushEvent(Event.GUISYSTEM_SHOW_TECHNOLOGYWINDOW) 
end

function TechnologyModel:doWearArtifactRequest(afId,techType,index)
	local packet = NetSystem.mNetManager:GetSPacket()
    packet:SetType(PacketTyper._PTYPE_CS_WEAR_ARTIFACT_REQUEST)
    packet:PushInt(afId)
    packet:PushInt(techType)
    packet:PushInt(index)
    packet:Send()
end

function TechnologyModel:doSwallowRequest(type1,index1,type2,index2)
	local packet = NetSystem.mNetManager:GetSPacket()
    packet:SetType(PacketTyper._PTYPE_CS_ARITIFACT_SWALLOW_REQUEST)
    packet:PushInt(type1)
    packet:PushInt(index1)
    packet:PushInt(type2)
    packet:PushInt(index2)
    packet:Send()
end

function TechnologyModel:onSwallowResponse(msgPacket) self.mTechCombat = msgPacket:GetInt()
	if self.mOwner then
		self.mOwner.mRootWidget:getChildByName("Label_Zhanli"):setString(tostring(self.mTechCombat))
	end
end

function TechnologyModel:doSwallowOperate(af1 ,af2,callBackFunc)
	local afData1     = DB_ArtifactConfig.getDataById(af1.Id)
	local factor1     = afData1.Breaknumber
	local af1Lv       = afData1.Quality
	local af1NameId   = afData1.Name
	local af1NameData = DB_Text.getDataById(af1NameId)
	local af1NameStr  = af1NameData.Text_CN

	local afData2     = DB_ArtifactConfig.getDataById(af2.Id)
	local factor2     = afData2.Breaknumber
	local af2Lv       = afData2.Quality
	local af2NameId   = afData2.Name
	local af2NameData = DB_Text.getDataById(af2NameId)
	local af2NameStr  = af2NameData.Text_CN

	local function OnCancel() 
		return nil
	end

	if af1Lv > af2Lv then
		local exAdd   = factor2 * math.pow(2,af2.Lv - 1) + af2.Ex
		local exTotal = factor1 * math.pow(2,af1.Lv - 1) + af1.Ex - factor1 + exAdd

		local function OnOK()
			for i=1,10 do
				local tmp =  factor1 * math.pow(2,i) - factor1

				if i == 10 and tmp <= exTotal then
					af1.Lv = 10
					af1.Ex = 0		
				else
					if tmp > exTotal then
						af1.Lv = i
						af1.Ex = exTotal - factor1 * math.pow(2,i - 1) + factor1
						break
					end
				end 
			end
			callBackFunc(af1)
			print("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"..af1.Id)
			return af1
		end
		
		MessageBox:showMessageBox2(string.format("%s将吞噬%s获得%d点经验",af1NameStr,af2NameStr,exAdd),OnOK,OnCancel)	
	else
		local exAdd   = factor1 * math.pow(2,af1.Lv - 1) + af1.Ex
		local exTotal = factor2 * math.pow(2,af2.Lv - 1) + af2.Ex - factor2 + exAdd

		local function OnOK()
			for i=1,10 do
				local tmp =  factor2 * math.pow(2,i) - factor2
				if i == 10 and tmp <= exTotal then
					af2.Lv = 10
					af2.Ex = 0
				else
					if tmp > exTotal then
						af2.Lv = i
						af2.Ex = exTotal - factor2 * math.pow(2,i - 1) + factor2
						break
					end
				end
			end
			callBackFunc(af2)
			print("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"..af2.Id)
			return af2
		end

		MessageBox:showMessageBox2(string.format("%s将吞噬%s获得%d点经验",af2NameStr,af1NameStr,exAdd),OnOK,OnCancel)	
	end
end

function TechnologyModel:doTakeOffArtifactRequest(techType,index)
	local packet = NetSystem.mNetManager:GetSPacket()
    packet:SetType(PacketTyper._PTYPE_CS_TAKEOFF_ARTIFACT_REQUEST)
    packet:PushInt(techType)
    packet:PushInt(index)
    packet:Send()
end

function TechnologyModel:doOneKeySwallowGuessRequest()
	local packet = NetSystem.mNetManager:GetSPacket()
    packet:SetType(PacketTyper._PTYPE_CS_ONEKEY_SWALLOW_REQUEST)
    packet:Send()
	GUISystem:showLoading()
end

function TechnologyModel:onOneKeySwallowGuessResponse(msgPacket)
	local ret = msgPacket:GetChar()

	GUISystem:hideLoading()
	if ret == SUCCESS then
		self:InitBagGuess()

		local cnt = msgPacket:GetUShort()
		for i=1,cnt do
			local afInfo = {}
			afInfo.Id  = msgPacket:GetInt()
			afInfo.Lv  = msgPacket:GetInt()
			afInfo.Ex  = msgPacket:GetInt()
			afInfo.Idx = msgPacket:GetInt()

			self.mGuessBag[afInfo.Idx] = afInfo
		end

		if self.mOwner and self.mOwner.mGuessPanel then
			self.mOwner:RefreshAFBagG()
		end
	end
end

function TechnologyModel:doOneKeySwallowNormalRequest(swallowType)
	local packet = NetSystem.mNetManager:GetSPacket()
    packet:SetType(PacketTyper._PTYPE_CS_ONEKEY_SWALLOWN_REQUEST)
    packet:PushInt(swallowType)
    packet:Send()
	GUISystem:showLoading()
end

function TechnologyModel:onOneKeySwallowNormalResponse(msgPacket)
	local ret = msgPacket:GetChar()

	GUISystem:hideLoading()
	if ret == SUCCESS then
		self:InitBagNormal()

		local cnt = msgPacket:GetUShort()
		for i=1,cnt do
			local afInfo = {}
			afInfo.Id  = msgPacket:GetInt()
			afInfo.Lv  = msgPacket:GetInt()
			afInfo.Ex  = msgPacket:GetInt()
			afInfo.Idx = msgPacket:GetInt()

			self.mUnUsedAFs[afInfo.Idx] = afInfo
		end

		if self.mOwner then
			self.mOwner:RefreshAFBag()
		end
	end
end

function TechnologyModel:doOneKeyPickUpRequest()
	local packet = NetSystem.mNetManager:GetSPacket()
    packet:SetType(PacketTyper._PTYPE_CS_ONEKEY_PICKUP_REQUEST)
    packet:Send()
    GUISystem:showLoading()
end

function TechnologyModel:onOneKeyPickUpResponse(msgPacket)
	local ret = msgPacket:GetChar()

	GUISystem:hideLoading()
	if ret == SUCCESS then
		self:InitBagNormal()

		local cnt = msgPacket:GetUShort()
		for i=1,cnt do
			local afInfo = {}
			afInfo.Id  = msgPacket:GetInt()
			afInfo.Lv  = msgPacket:GetInt()
			afInfo.Ex  = msgPacket:GetInt()
			afInfo.Idx = msgPacket:GetInt()

			self.mUnUsedAFs[afInfo.Idx] = afInfo
		end

		if self.mOwner then
			self:InitBagGuess()	
			self.mOwner:RefreshAFBag()
			self.mOwner:RefreshAFBagG()
		end
	end
end

function TechnologyModel:doPickUpRequest(afInfo)
	self.mPickUpAf = afInfo
	local packet = NetSystem.mNetManager:GetSPacket()
    packet:SetType(PacketTyper._PTYPE_CS_PICKUP_REQUEST)
    packet:PushInt(afInfo.Idx)
    print("?????????????????????????????????????????????",afInfo.Idx)
    packet:Send()
    GUISystem:showLoading()
end

function TechnologyModel:onPickUpResponse(msgPacket)
	local ret = msgPacket:GetChar()

	GUISystem:hideLoading()
	if ret == SUCCESS and self.mOwner then
		if self.mOwner then
			self.mOwner:DeleteOneFromGuessBag(self.mPickUpAf.Idx)
		end
		self.mGuessBag[self.mPickUpAf.Idx] = nil

		for i=1,self.mBagCellCnt do
			if self.mUnUsedAFs[i] == nil then
				self.mUnUsedAFs[i] = self.mPickUpAf
				self.mUnUsedAFs[i].Idx = i
				break
			end
		end

		if self.mOwner then
			self.mOwner:RefreshAFBag()
		end
	end
end

function TechnologyModel:doGuessRequest()
	local packet = NetSystem.mNetManager:GetSPacket()
    packet:SetType(PacketTyper._PTYPE_CS_GUESS_REQUEST)
    packet:Send()
    GUISystem:showLoading()
end

function TechnologyModel:onGuessResponse(msgPacket)
	local ret = msgPacket:GetChar()

	if ret == SUCCESS then
		self.mCurGuessIdx = msgPacket:GetInt()
		self.mGuessPrice  = msgPacket:GetInt()

		print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!",self.mCurGuessIdx)
		local cnt = msgPacket:GetUShort()
		for i=1,cnt do
			local afInfo = {}
			afInfo.Id  = msgPacket:GetInt()
			afInfo.Lv  = msgPacket:GetInt()
			afInfo.Ex  = msgPacket:GetInt()
			afInfo.Idx = msgPacket:GetInt()

			--print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!",afInfo.Idx)
			self.mGuessBag[afInfo.Idx] = afInfo
			if self.mOwner then
				self.mOwner:AddOneToGuessBag(afInfo)
			end
		end

		if self.mOwner and self.mOwner.mGuessPanel then			
			self.mOwner.mGuessPanel:getChildByName("Label_Gold"):setString(tostring(self.mGuessPrice))
		end
	end
end

function TechnologyModel:doGuessTenRequest()
	local packet = NetSystem.mNetManager:GetSPacket()
    packet:SetType(PacketTyper._PTYPE_CS_GUESS_TEN_REQUEST)
    packet:Send()
    GUISystem:showLoading()
end

function TechnologyModel:onGuessTenResponse(msgPacket)
	local ret = msgPacket:GetChar()

	GUISystem:hideLoading()
	if ret == SUCCESS then
		self.mCurGuessIdx = msgPacket:GetInt()
		self.mGuessPrice  = msgPacket:GetInt()

		local cnt = msgPacket:GetUShort()

		for i=1,cnt do
			local afInfo = {}
			afInfo.Id  = msgPacket:GetInt()
			afInfo.Lv  = msgPacket:GetInt()
			afInfo.Ex  = msgPacket:GetInt()
			afInfo.Idx = msgPacket:GetInt()

			print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!",afInfo.Idx)
			self.mGuessBag[afInfo.Idx] = afInfo
		end

		if self.mOwner and self.mOwner.mGuessPanel then
			self.mOwner:RefreshAFBagG()
			self.mOwner.mGuessPanel:getChildByName("Label_Gold"):setString(tostring(self.mGuessPrice))
		end
	end	
end

function TechnologyModel:doGuessMasterRequest()
	local function OnOK()
		local packet = NetSystem.mNetManager:GetSPacket()
		packet:SetType(PacketTyper._PTYPE_CS_GUESS_MASTER_REQUEST)
		packet:Send()
		GUISystem:showLoading()
	end

	local function OnCancel()
	end

	if self.mCurGuessIdx >= 4 then
		MessageBox:showMessageBox2("已是大师级别是否继续聘用？",OnOK,OnCancel)
	else
		OnOK()
	end
end

function TechnologyModel:onGuessMasterResponse(msgPacket)
	local ret = msgPacket:GetChar()

	GUISystem:hideLoading()
	if ret == SUCCESS then
		self.mCurGuessIdx = msgPacket:GetInt()
		self.mGuessPrice  = msgPacket:GetInt()
		self.mMasterPrice = msgPacket:GetInt()
		if self.mOwner and self.mOwner.mGuessPanel then
			self.mOwner:RefreshAFBagG()
			self.mOwner.mGuessPanel:getChildByName("Label_Gold"):setString(tostring(self.mGuessPrice))
			self.mOwner.mGuessPanel:getChildByName("Label_Diamond_Stroke"):setString(tostring(self.mMasterPrice))
			self.mOwner.mGuessPanel:getChildByName("Image_Notice_14002"):setVisible(self.mMasterPrice == 0)
		end	
	end
end

function TechnologyModel:doExpandAfBagRequest()
	local packet = NetSystem.mNetManager:GetSPacket()
    packet:SetType(PacketTyper._PTYPE_CS_EXPAND_AFBAG_REQUEST)
    packet:Send()
    GUISystem:showLoading()
end

function TechnologyModel:onExpandAfBagResponse(msgPacket)
	local ret = msgPacket:GetChar()

	GUISystem:hideLoading()
	if ret == SUCCESS then
		self.mBagCellCnt = self.mBagCellCnt + 4
		if self.mOwner then
			self.mOwner:RefreshAFBag()
		end
	end
end

function TechnologyModel:doSortAfBagRequest()
	local packet = NetSystem.mNetManager:GetSPacket()
    packet:SetType(PacketTyper._PTYPE_CS_SORT_AFBAG_REQUEST)
    packet:Send()
    GUISystem:showLoading()
end

function TechnologyModel:onSortAfBagResponse(msgPacket)
	local ret = msgPacket:GetChar()

	GUISystem:hideLoading()
	if ret == SUCCESS then
		local cnt = msgPacket:GetUShort()

		for i = cnt + 1,self.mBagCellCnt do
			self.mUnUsedAFs[i] = nil
		end
		for i=1,cnt do
			local afInfo = {}
			afInfo.Id  = msgPacket:GetInt()
			afInfo.Lv  = msgPacket:GetInt()
			afInfo.Ex  = msgPacket:GetInt()
			afInfo.Idx = msgPacket:GetInt()

			self.mUnUsedAFs[afInfo.Idx] = afInfo
		end

		if self.mOwner then
			self.mOwner:RefreshAFBag()
		end
	end
end

--==========================================================afWidget  begin ==================================================================

AFItem = class("AFItem", function() return cc.Node:create() end)

function AFItem:ctor(afInfo,bShowBg,bTouch,nAnim,oWner)
	self.mOwner    = oWner
	self.mTag      = afInfo.Id
	self.mIsInTech = not bShowBg
	self.mInfo     = afInfo

	self:CreateWidget(afInfo.Id,bShowBg,bTouch,nAnim)
end

function AFItem:getTag()
	return self.mTag
end

function AFItem:setInfo(afInfo,bagType)
	self.mInfo = afInfo
	self.mBagType = bagType
end

function AFItem:getInfo()
	return self.mInfo
end

function AFItem:setAnchorPoint(x,y)
	if self.mAFWidget == nil then return end
	self.mAFWidget:setAnchorPoint(x,y)
end

function AFItem:CreateWidget(nTag,bShowBg,bTouch,nAnim)
	local afWidget  = GUIWidgetPool:createWidget("Technology_ItemCell")
	afWidget:setTag(nTag)
	afWidget:setTouchEnabled(bTouch)

	self.mAFWidget = afWidget
	self:addChild(afWidget)

	local animNode = AnimManager:createAnimNode(8030)

	if nAnim == 0 then   --0 no anim; 01 no define; 10 play 2; 11 play 1 and 2 

	elseif nAnim == 2 then
		afWidget:getChildByName("Panel_Animation"):addChild(animNode:getRootNode(), 100) 
		animNode:play("hero_skillchosen_2",true)
	elseif nAnim == 3 then
		afWidget:getChildByName("Panel_Animation"):addChild(animNode:getRootNode(), 100)
		animNode:play("hero_skillchosen_1",false,function() animNode:play("hero_skillchosen_2",true) end)
	end


	local afId       = afWidget:getTag() print("afid is "..tostring(afId))
	local afData     = DB_ArtifactConfig.getDataById(afId)
	local afIconId   = afData.IconID
	local afQuality  = afData.Quality
	local imgData    = DB_ResourceList.getDataById(afIconId)
	local imgAddr    = imgData.Res_path1
	local afNameId   = afData.Name
	local afNameData = DB_Text.getDataById(afNameId)
	local afNameStr  = afNameData.Text_CN
	local factor 	 =  afData.Breaknumber

	afWidget:getChildByName("Image_Icon"):loadTexture(imgAddr,1)	

	if not bShowBg then
		--afWidget:getChildByName("Image_Quality"):setVisible(false)
		afWidget:getChildByName("Image_Quality_Bg"):setVisible(false)
		afWidget:getChildByName("Label_Name"):setVisible(false)
		afWidget:getChildByName("Label_Level_Stroke"):setVisible(false)
	else
		afWidget:getChildByName("Label_Level_Stroke"):setVisible(true)
		afWidget:getChildByName("Label_Level_Stroke"):setString(tostring(self.mInfo.Lv))
		afWidget:getChildByName("Label_Name"):setVisible(true)
		afWidget:getChildByName("Label_Name"):setString(afNameStr)
		--afWidget:getChildByName("Image_Quality"):setVisible(true)
		afWidget:getChildByName("Image_Quality_Bg"):setVisible(true)
		--afWidget:getChildByName("Image_Quality"):loadTexture(string.format("backpack_diamond_quality_%d.png",afQuality))
		afWidget:getChildByName("Image_Quality_Bg"):loadTexture(string.format("backpack_diamond_quality_%d.png",afQuality == 0 and 1 or afQuality))
	end

	if bTouch == false then
		afWidget:getChildByName("Label_Level_Stroke"):setVisible(false)
		afWidget:getChildByName("Label_Name"):setVisible(false)
	end

	registerWidgetReleaseUpEvent(afWidget,handler(self,self.ShowArtifactDetail))
end

function AFItem:ShowArtifactDetail(widget)
	local detailBox = GUIWidgetPool:createWidget("Technology_ItemInfo")

	local afId       = widget:getTag()
	local afData     = DB_ArtifactConfig.getDataById(afId)
	local afNameId   = afData.Name
	local afNameData = DB_Text.getDataById(afNameId)
	local afNameStr  = afNameData.Text_CN
	local desId      = afData.Description
	local desData    = DB_Text.getDataById(desId)
	local desStr     = desData.Text_CN
	local afQuality  = afData.Quality
	local items      = {}
	items[1]         = afData.Repair_cost1
	items[2]         = afData.Repair_cost2
	items[3]         = afData.Repair_cost3
	items[4]         = afData.Repair_cost4

	local factor 	 =  afData.Breaknumber

	detailBox:getChildByName("Panel_Main"):setTouchEnabled(true)
	detailBox:getChildByName("Label_Name&Level"):setString(string.format("%s Lv %d",afNameStr,self.mInfo.Lv))
	detailBox:getChildByName("Label_Des"):setString(desStr)
	detailBox:getChildByName("ProgressBar_EXP"):setPercent(self.mInfo.Ex / (factor * math.pow(2,self.mInfo.Lv - 1))*100)
	detailBox:getChildByName("Label_EXP_Prograss"):setString(string.format("%d/%d",self.mInfo.Ex,factor * math.pow(2,self.mInfo.Lv - 1))) 
	detailBox:getChildByName("Panel_Item"):addChild(AFItem.new(self.mInfo,true,false,0,self.mOwner.mRootWidget))

	local lev = self.mInfo.Lv
	local attriStr = {"生命","格斗","破甲","护甲","功夫","柔术","暴击","韧性",}
	local attris   = {{1,afData.InitHP + (lev - 1)*afData.InitHPleveladd,   0},
					  {2,afData.InitPhyAttack + (lev - 1)*afData.InitPhyAttackleveladd,0},
					  {3,afData.InitArmorPene + (lev - 1)*afData.InitArmorPeneleveladd,0},
					  {4,afData.InitArmor + (lev - 1)*afData.InitArmorleveladd,0},
					  {5,afData.InitHit + (lev - 1)*afData.InitHitleveladd,      0},
					  {6,afData.InitDodge + (lev - 1)*afData.InitDodgeleveladd,    0},
					  {7,afData.InitCrit + (lev - 1)*afData.InitCritleveladd, 0},
					  {8,afData.InitTenacity + (lev - 1)*afData.InitTenacityleveladd, 0}}


	local attris2 = {}
	for i=1,#attris do
		if attris[i][2] ~= 0 then
			table.insert(attris2,attris[i])
		end
	end

	for i=1,3 do
		local panel = detailBox:getChildByName(string.format("Panel_Property_%d",i))
		if i <= #attris2 then
			local strIdx = attris2[i][1]
			panel:setVisible(true)
			panel:getChildByName("Label_Name"):setString(attriStr[strIdx])
			panel:getChildByName("Label_More"):setString(tostring(attris2[i][2]))
		else
			panel:setVisible(false)
		end
	end

	self.mOwner.mRootNode:addChild(detailBox,500)

	local function closeWindow() 
		detailBox:removeFromParent() 
		detailBox = nil 
	end

	registerWidgetReleaseUpEvent(detailBox,closeWindow)

	if self.mBagType == BAG_GUESS then
		detailBox:getChildByName("Button_Get"):setVisible(true)
	end

	registerWidgetReleaseUpEvent(detailBox:getChildByName("Button_Get"),function() self.mOwner.mModel:doPickUpRequest(self.mInfo) closeWindow() end)

end

--==========================================================window  begin ==================================================================

local TechnologyWindow = 
{
	mName 				= "TechnologyWindow",
	mRootNode			=	nil,	
	mRootWidget 		= 	nil,
	mTopRoleInfoPanel	=	nil,	-- 顶部人物信息面板
	mModel				=   nil,
	mTechItemTV         =   nil,
	mTouchLayer         =   nil,
	mRectRArr           =   {},
	mRectLArr1          =   {},
	mRectLArr2          =   {},

	mUsedAFWidget1      =   {nil,nil,nil,nil,nil,nil},
	mUsedAFWidget2      =   {nil,nil,nil,nil,nil,nil},

	mCurAFBagPage		=   1,
	mCallFuncAfterDestroy	=	nil,

	mAFWidget 			= { nil,nil,nil,nil,
						   	nil,nil,nil,nil,
							nil,nil,nil,nil,
							nil,nil,nil,nil,},
}


function TechnologyWindow:Load(event)
	cclog("=====TechnologyWindow:Load=====begin")

	self.mRootNode = cc.Node:create()
	GUISystem:GetRootNode():addChild(self.mRootNode)

	self.mModel = TechnologyModel:getInstance()
	self.mModel:setOwner(self)

	TextureSystem:loadPlist_zodiac()

	self:InitLayout(event)

	local function doTechnologyGuideOne_Stop()
		TechnologyGuideOne:stop()
	end
	TechnologyGuideOne:step(1, nil, doTechnologyGuideOne_Stop)

	cclog("=====TechnologyWindow:Load=====end")
end

function TechnologyWindow:GetCurType()
	if self.mBoard1:isVisible() then return 1 else return 2 end
end

function TechnologyWindow:InitLayout(event)
	self.mRootWidget = GUIWidgetPool:createWidget("Technology_Main")
	self.mRootNode:addChild(self.mRootWidget) 

	local function closeWindow()
		GUISystem:playSound("homeBtnSound")
		if self.mModel.mEndFunc then
			self.mModel.mEndFunc()
		end
		EventSystem:PushEvent(Event.GUISYSTEM_HIDE_TECHNOLOGYWINDOW)
	end

	if self.mTopRoleInfoPanel == nil then
		cclog("TechnologyWindow mTopRoleInfoPanel init")
		self.mTopRoleInfoPanel = TopRoleInfoPanel:new()
		self.mTopRoleInfoPanel:init(self.mRootNode,ROLE_TITLE_TYPE.TITLE_TECHNOLOGY, closeWindow)
	end

	local topSize = self.mTopRoleInfoPanel.mTopWidget:getContentSize()
	local y = getGoldFightPosition_Middle().y - topSize.height / 2
	local x = getGoldFightPosition_Middle().x

	self.mRootWidget:getChildByName("Panel_Main"):setAnchorPoint(0.5,0.5)
	self.mRootWidget:getChildByName("Panel_Main"):setPosition(cc.p(x,y))

	self:InitBoard()

	local prevBtn = self.mRootWidget:getChildByName("Button_FrontPage")
	local nextBtn = self.mRootWidget:getChildByName("Button_NextPage")

	registerWidgetReleaseUpEvent(prevBtn,handler(self,self.OnPressBtnAFBag))
	registerWidgetReleaseUpEvent(nextBtn,handler(self,self.OnPressBtnAFBag))	
	
	self.mPanelRight = self.mRootWidget:getChildByName("Panel_Right")
	self.mPanelRight:setVisible(false)
	local pos 		 = cc.p(self.mPanelRight:getPosition())
	local size 		 = self.mPanelRight:getContentSize()

	local function runBegin()
		self.mPanelRight:setPositionX(VisibleRect:right().x)
		self.mPanelRight:setVisible(true)
		GUISystem:disableUserInput()
	end

	local function runEnd()
		self:OnPressBtnAFBag(prevBtn)
		self:InitTouch()
		GUISystem:enableUserInput()
	end

	local actBegin = cc.CallFunc:create(runBegin)
	local actMove  = cc.MoveTo:create(0.2, pos)
	local actEnd   = cc.CallFunc:create(runEnd)

	self.mPanelRight:runAction(cc.Sequence:create(actBegin,actMove,actEnd)) 

	local function ShowSwallowOption()
		local optionPanel = GUIWidgetPool:createWidget("Technology_EatOption")

		local function closeWindow()
			optionPanel:removeFromParent() 
			optionPanel = nil
		end

		local checkBoxArr = {optionPanel:getChildByName("CheckBox_Green"),
							 optionPanel:getChildByName("CheckBox_Blue"),
							 optionPanel:getChildByName("CheckBox_Purple"),
							 }
		local swallowType = 1
		checkBoxArr[swallowType]:setSelectedState(true)

		for i=1,3 do
			checkBoxArr[i]:setTag(i)
			registerWidgetReleaseUpEvent(checkBoxArr[i],function(widget)
				swallowType = widget:getTag()
				
				for i=1,#checkBoxArr do
					if i ~= widget:getTag() then
						checkBoxArr[i]:setSelectedState(false)	
					end
				end
			end)			
		end

		--registerWidgetReleaseUpEvent(optionPanel,closeWindow)
		registerWidgetReleaseUpEvent(optionPanel:getChildByName("Button_Do"),
		function()
			if checkBoxArr[1]:getSelectedState() == false and checkBoxArr[2]:getSelectedState() == false and checkBoxArr[3]:getSelectedState() == false then
				MessageBox:showMessageBox1("请选择吞噬类型！")
				return
			end 
			closeWindow()
			self.mModel:doOneKeySwallowNormalRequest(swallowType) 
		end)
		registerWidgetReleaseUpEvent(optionPanel:getChildByName("Button_Cancel"),closeWindow)

		self.mRootNode:addChild(optionPanel,200)
	end

	registerWidgetReleaseUpEvent(self.mPanelRight:getChildByName("Button_AutoEar"),ShowSwallowOption)
	registerWidgetReleaseUpEvent(self.mPanelRight:getChildByName("Button_Gamble"),handler(self,self.ShowGuessStar))
	registerWidgetReleaseUpEvent(self.mPanelRight:getChildByName("Button_Fixing"),function() self.mModel:doSortAfBagRequest() end)
	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_Rule"),
	function() 
		local rulePanel = GUIWidgetPool:createWidget("Technology_Rule")

		self.mRootNode:addChild(rulePanel,1000)
		
		registerWidgetReleaseUpEvent(rulePanel:getChildByName("Button_Close"),function() rulePanel:removeFromParent()  rulePanel = nil end) 
		registerWidgetReleaseUpEvent(rulePanel,function() rulePanel:removeFromParent()  rulePanel = nil end)

		local textData = DB_Text.getDataById(1733)
		local textStr  = textData.Text_CN
		richTextCreate(rulePanel:getChildByName("Panel_Text"),textStr,true,nil,false)
	end)

end

function TechnologyWindow:ShowGuessStar()
	local guessPanel = GUIWidgetPool:createWidget("Technology_Gamble")

	self.mGuessPanel = guessPanel

	guessPanel:getChildByName("Panel_Main"):setTouchEnabled(true)
	--registerWidgetReleaseUpEvent(guessPanel,function() guessPanel:removeFromParent() guessPanel = nil end)
	registerWidgetReleaseUpEvent(guessPanel:getChildByName("Button_Back"),function() guessPanel:removeFromParent() guessPanel = nil end)
	registerWidgetReleaseUpEvent(guessPanel:getChildByName("Button_AutoEat"),function() self.mModel:doOneKeySwallowGuessRequest() end)
	registerWidgetReleaseUpEvent(guessPanel:getChildByName("Button_AutoSave"),function() self.mModel:doOneKeyPickUpRequest() end)
	--registerWidgetReleaseUpEvent(guessPanel:getChildByName("Button_Manual"),handler(self,self.ShowIllustratedBook))
	registerWidgetReleaseUpEvent(guessPanel:getChildByName("Button_10Times"),function() self.mModel:doGuessTenRequest() end)
	registerWidgetReleaseUpEvent(guessPanel:getChildByName("Button_Master"),function() self.mModel:doGuessMasterRequest() end)
	registerWidgetReleaseUpEvent(guessPanel:getChildByName("Button_Do"),function() self.mModel:doGuessRequest() end)

	self.mRootNode:addChild(guessPanel,200)

	self.mGuessPanel:getChildByName("Label_Gold"):setString(tostring(self.mModel.mGuessPrice))
	self.mGuessPanel:getChildByName("Label_Diamond_Stroke"):setString(self.mModel.mMasterPrice == 0 and "免费" or tostring(self.mModel.mMasterPrice))
	self.mGuessPanel:getChildByName("Image_Notice_14002"):setVisible(self.mModel.mMasterPrice == 0)

	self:RefreshAFBagG()
end

function TechnologyWindow:ShowIllustratedBook()
	print("ShowIllustratedBook")
end

function TechnologyWindow:InitTouch()
	local beginIdx 	 = nil
	local endIdx   	 = nil
	local movArtFact = nil
	local direction  = nil
	local LTOR = 1
	local RTOL = 2
	local LTOL = 3

	local function FindInxByTouch(pos,rects)
		for i=1,#rects do
			if cc.rectContainsPoint(rects[i], pos) then
				return i
			end
		end
		return 0
	end

	local function FindInxByTouchEx(pos,rects)
		for k,v in pairs(rects) do
			if cc.rectContainsPoint(v, pos) then
				return k
			end
		end
		return 0
	end

	local function PtInRect(pos)
		local posL       = self.mBoard1:getWorldPosition()
		local sizeL      = self.mBoard1:getContentSize()
		local rectL      = cc.rect(posL.x,posL.y,sizeL.width,sizeL.height)

		local posR       = self.mArtiFactLst:getWorldPosition()
		local sizeR      = self.mBoard1:getContentSize()
		local rectR      = cc.rect(posR.x,posR.y,sizeR.width,sizeR.height)

		if cc.rectContainsPoint(rectL,pos) then
			return 1
		elseif cc.rectContainsPoint(rectR,pos) then
			return 2
		else
			return 0
		end
	end

	local function GetCurBoard()
		if self.mBoard1:isVisible() then return self.mBoard1 else return self.mBoard2 end
	end

	local function isAfInTech(id)
		local idArrIdx = nil
		if self.mBoard1:isVisible() then idArrIdx = 1 else idArrIdx = 2 end
		local techAfIds = self.mModel.mTechInfo[idArrIdx].mTechUsedAFs
		for i=1,#techAfIds do
			if id == techAfIds[i].Id then 
				return true 
			end
		end
		return false 
	end

	local function canMove(srcId,desIdx)
		local afData = DB_ArtifactConfig.getDataById(srcId)
		local srcLv  = afData.Quality
		local srcTyp = afData.Type
		
		local idArrIdx = nil if self.mBoard1:isVisible() then idArrIdx = 1 else idArrIdx = 2 end
		local techAfIds = self.mModel.mTechInfo[idArrIdx].mTechUsedAFs
		local desAfInfo = techAfIds[desIdx]
		local types = {}

		for i=1,#techAfIds do			
			if i ~= desIdx then
				if techAfIds[i].Id ~= 0 then
					local afData = DB_ArtifactConfig.getDataById(techAfIds[i].Id)
					local srcTyp = afData.Type
					table.insert(types,srcTyp)
				end
			end
		end

		local function isTypeExist(typ)
			for i=1,#types do
				if typ == types[i] then
					return true
				end
			end
			return false
		end

		local desLv = nil
		if desAfInfo and desAfInfo.Id ~= 0 then
			local desafData = DB_ArtifactConfig.getDataById(desAfInfo.Id)
			desLv  = desafData.Quality  
		else
			desLv = 0
		end

		if srcLv <= desLv then
			return true
		else
			return not isTypeExist(srcTyp)
		end
	end

	local function cleanAfOnBoard(af) af.Id  = 0 af.Lv  = 0 af.Ex  = 0 af.Idx = 0 end

	local function onTouchBegan(touch, event)
		local touchBegan = touch:getLocationInView()
    	touchBegan = cc.Director:getInstance():convertToGL(touchBegan)

    	local rects = nil
    	local idArrIdx = nil
    	local afInfo = nil  

    	if self.mBoard1:isVisible() then rects = self.mRectLArr1 idArrIdx = 1 else rects = self.mRectLArr2 idArrIdx = 2 end

    	direction = PtInRect(touchBegan)
    	if direction == LTOR then
    		beginIdx = FindInxByTouch(touchBegan,rects)
    		if beginIdx ~= 0 then 
    			GetCurBoard():getChildByName(string.format("Panel_Item_%d",beginIdx)):setOpacity(125)
    			afInfo = self.mModel.mTechInfo[idArrIdx].mTechUsedAFs[beginIdx]
    		end
    	else
    		beginIdx = FindInxByTouchEx(touchBegan,self.mRectRArr)
    		if beginIdx ~= 0 then
    			self.mArtiFactLst:getChildByName(string.format("Panel_Item_%d",beginIdx)):setOpacity(125)
    			afInfo = self.mModel.mUnUsedAFs[ 16 * (self.mCurAFBagPage -1 ) + beginIdx]
    		end
    	end   	

    	if beginIdx ~= 0 and afInfo and afInfo.Id ~= 0 then
    		print("asdfasdfasdfasdfasdfasdfasdfasdfasdfasdfasfd",beginIdx,afInfo.Id) 
    		movArtFact = AFItem.new(afInfo,false,true,0,self)
    		movArtFact:setInfo(afInfo)
    		movArtFact:setAnchorPoint(0.5,0.5)
    		self.mRootWidget:addChild(movArtFact)
    	end

		return true
	end

	local function onTouchEnded(touch, event)
		local touchEnd = touch:getLocationInView()
		touchEnd = cc.Director:getInstance():convertToGL(touchEnd)

		local rects    = nil
		local idArrIdx = nil

		if self.mBoard1:isVisible() then
			rects    = self.mRectLArr1 
			idArrIdx = 1
		else 
			rects    = self.mRectLArr2 
			idArrIdx = 2
		end

		if direction == LTOR then          --从左边拖
			local des = PtInRect(touchEnd)
			if des == 1 then       --法阵互换
				endIdx = FindInxByTouch(touchEnd,rects)
    			if endIdx > self.mModel.mTechInfo[idArrIdx].mTechHoleCnt then --未开放
    				print(string.format("technology %d hole %d is not open",idArrIdx,endIdx))
    				local item = GetCurBoard():getChildByName(string.format("Panel_Item_%d",beginIdx))
    				if item then
    					item:setOpacity(255) 
    				end
    			else
	    			if beginIdx ~= 0 and endIdx ~= 0 then 
						if beginIdx ~= endIdx then
							local afSrc    = self.mModel.mTechInfo[idArrIdx].mTechUsedAFs[beginIdx]
							local afDesc   = self.mModel.mTechInfo[idArrIdx].mTechUsedAFs[endIdx]
							local afResult = nil

							local Idx = beginIdx
							local function OperateSuccessFunc(afResult)
				    			if afResult ~= nil then
				    				afDesc.Id   = afResult.Id
	    							afDesc.Lv 	= afResult.Lv
	    							afDesc.Ex 	= afResult.Ex	
	    							afDesc.Idx 	= endIdx
	    						end

	    						GetCurBoard():getChildByName(string.format("Panel_Item_%d",Idx)):removeAllChildren()
	    						GetCurBoard():getChildByName(string.format("Panel_Tech_%d",Idx)):getChildByName("Label_Name_Stroke"):setString("")
	    						cleanAfOnBoard(afSrc)
	    						self.mModel:doSwallowRequest(idArrIdx,Idx,idArrIdx,endIdx)
	    						local afData   = DB_ArtifactConfig.getDataById(afDesc.Id)
								local nameId   = afData.Name
								local nameData = DB_Text.getDataById(nameId)
								local af       = AFItem.new(afDesc,false,true,3,self)
								local label    = GetCurBoard():getChildByName(string.format("Panel_Tech_%d",endIdx)):getChildByName("Label_Name_Stroke")

								af:setInfo(afDesc)
								label:setVisible(true)
					    		label:setString(string.format("%sLv%d",nameData.Text_CN,afDesc.Lv))
					    		GetCurBoard():getChildByName(string.format("Panel_Item_%d",endIdx)):addChild(af)	
			    			end
							
		    				if afSrc and afSrc.Id ~= 0 then
		    					if afDesc.Id == 0 then 	--目标孔没有神器 
		    						afDesc.Id   = afSrc.Id
		    						afDesc.Lv 	= afSrc.Lv
		    						afDesc.Ex 	= afSrc.Ex	
		    						afDesc.Idx 	= endIdx
		    						afResult 	= afDesc
		    						OperateSuccessFunc()		    						
		    					else 						--目标孔有神器 
					    			self.mModel:doSwallowOperate(afSrc,afDesc,OperateSuccessFunc)
					    			GetCurBoard():getChildByName(string.format("Panel_Item_%d",Idx)):setOpacity(255)
		    						GetCurBoard():getChildByName(string.format("Panel_Item_%d",endIdx)):setOpacity(255)
		    					end		    					
		    				end
		    			else
	    					GetCurBoard():getChildByName(string.format("Panel_Item_%d",beginIdx)):setOpacity(255)
	   					end
	   				elseif beginIdx ~= 0 and endIdx == 0 then 
	   					GetCurBoard():getChildByName(string.format("Panel_Item_%d",beginIdx)):setOpacity(255)
	    			end
    			end
    		elseif des == 2 then --从法阵拖到背包
    			endIdx = FindInxByTouchEx(touchEnd,self.mRectRArr)

    			if endIdx == 0 then
					if beginIdx ~= 0 then
    					GetCurBoard():getChildByName(string.format("Panel_Item_%d",beginIdx)):setOpacity(255)
    				end

			    	if movArtFact ~= nil then 
						movArtFact:removeFromParent()
						movArtFact = nil
					end

    				return 
    			end 

    			local afDescIdx = endIdx + 16 * (self.mCurAFBagPage - 1) 
				local afSrc     = self.mModel.mTechInfo[idArrIdx].mTechUsedAFs[beginIdx]
				local afDesc    = self.mModel.mUnUsedAFs[afDescIdx]
				local bagBgImg  = self.mArtiFactLst:getChildByName(string.format("Panel_Item_%d",endIdx)):getChildByName("Image_Lock")
				local afResult  = nil
				local Idx = beginIdx

				if bagBgImg:isVisible() == false then
					if beginIdx ~= 0 and afSrc and afSrc.Id ~= 0 then

						local function OperateSuccessFunc(afResult)
							if afResult then
								afDesc.Id  = afResult.Id
								afDesc.Lv  = afResult.Lv
								afDesc.Ex  = afResult.Ex
								afDesc.Idx = afDescIdx
							end

							GetCurBoard():getChildByName(string.format("Panel_Item_%d",Idx)):removeAllChildren()
							GetCurBoard():getChildByName(string.format("Panel_Tech_%d",Idx)):getChildByName("Label_Name_Stroke"):setString("")
							self.mModel:doSwallowRequest(idArrIdx,Idx,3,afDescIdx)
							--刷新背包 并去掉法阵里的神器
							cleanAfOnBoard(afSrc) 
							self:RefreshAFBag()
						end
						
						if afDesc == nil then	--没有卸下
							self.mModel.mUnUsedAFs[afDescIdx] = {}
							afDesc	   = self.mModel.mUnUsedAFs[afDescIdx]
							afDesc.Id  = afSrc.Id
							afDesc.Lv  = afSrc.Lv
							afDesc.Ex  = afSrc.Ex
							afDesc.Idx = afDescIdx
							afResult   = afDesc
							OperateSuccessFunc()
						else					--有就吞噬
							self.mModel:doSwallowOperate(afSrc,afDesc,OperateSuccessFunc)
							GetCurBoard():getChildByName(string.format("Panel_Item_%d",beginIdx)):setOpacity(255)
						end						
		    		end
		    	else
					if beginIdx ~= 0 then
    					GetCurBoard():getChildByName(string.format("Panel_Item_%d",beginIdx)):setOpacity(255)
    				end
		    	end	
    		else --没有操作恢复法阵状态
    			if beginIdx ~= 0 then
    				GetCurBoard():getChildByName(string.format("Panel_Item_%d",beginIdx)):setOpacity(255)
    			end
    		end
    	else--从右边拖
    		endIdx = FindInxByTouch(touchEnd,rects)
    		if beginIdx ~= 0 then
	    		if endIdx == 0 then
	    			endIdx = FindInxByTouchEx(touchEnd,self.mRectRArr) 
	    			if endIdx ~= 0 then  		--从背包到背包
	    				local bagBgImg  = self.mArtiFactLst:getChildByName(string.format("Panel_Item_%d",endIdx)):getChildByName("Image_Lock")

						if bagBgImg:isVisible() == false then
		    				local afDescIdx = endIdx + 16 * (self.mCurAFBagPage - 1)
		    				local afSrcIdx  = beginIdx + 16 * (self.mCurAFBagPage - 1)
		    				if beginIdx ~= endIdx then 
								local afSrc    = self.mModel.mUnUsedAFs[afSrcIdx]
				    			local afDesc   = self.mModel.mUnUsedAFs[afDescIdx]
				    			local afResult = nil
				    			print("ssssssssssssssssssssssssssssssssss",beginIdx,endIdx)

				    			function OperateSuccessFunc(afResult)
					    			self.mModel:doSwallowRequest(3,afSrcIdx,3,afDescIdx)		
					    			self.mModel.mUnUsedAFs[afSrcIdx] = nil

					    			if afResult then
					    				afDesc.Id = afResult.Id
					    				afDesc.Lv = afResult.Lv
					    				afDesc.Ex = afResult.Ex
					    				afDesc.Idx = afDescIdx
					    			end

					    			self:RefreshAFBag()
				    			end

				    			if afSrc then
					    			if afDesc == nil then --目标位置没有东西
					    				self.mModel.mUnUsedAFs[afDescIdx] = {}
					    				afDesc     = self.mModel.mUnUsedAFs[afDescIdx]
					    				afDesc.Id  = afSrc.Id
					    				afDesc.Lv  = afSrc.Lv
					    				afDesc.Ex  = afSrc.Ex
					    				afDesc.Idx = afDescIdx

					    				OperateSuccessFunc()
					    			else
					    				self.mModel:doSwallowOperate(afSrc,afDesc,OperateSuccessFunc)
					    			end
					    		end
				    		end
				    	end
	    		    end
	    		else							--从背包到法阵
	    			local afSrcIdx = beginIdx + 16 * (self.mCurAFBagPage - 1)
					if self.mModel.mUnUsedAFs[afSrcIdx] then
			    		if not canMove(self.mModel.mUnUsedAFs[afSrcIdx].Id,endIdx) then
			    			self.mArtiFactLst:getChildByName(string.format("Panel_Item_%d",beginIdx)):setOpacity(255)
				    		beginIdx = 0
							if movArtFact ~= nil then 
								movArtFact:removeFromParent()
								movArtFact = nil
							end
							MessageBox:showMessageBox1("同种类型的星座不能出现在同一个法阵中!")
							print("operate is not allowed!!!")
							return
						end
					end

					if endIdx <= self.mModel.mTechInfo[idArrIdx].mTechHoleCnt then	--当前位置开放		    			
		    			local afSrc    = self.mModel.mUnUsedAFs[afSrcIdx]
		    			local afDesc   = self.mModel.mTechInfo[idArrIdx].mTechUsedAFs[endIdx]
		    			local afResult = nil

 						local function OperateSuccessFunc(afResult)
			    			if afResult then
			    				afDesc.Id = afResult.Id
			    				afDesc.Lv = afResult.Lv
			    				afDesc.Ex = afResult.Ex
			    				afDesc.Idx = endIdx
			    			end

				    	    self.mModel:doSwallowRequest(3,afSrcIdx,idArrIdx,endIdx)
			    	    	self.mModel.mUnUsedAFs[afSrcIdx] = nil

				    		local desContainer = GetCurBoard():getChildByName(string.format("Panel_Item_%d",endIdx))
			    			local af           = AFItem.new(afDesc,false,true,3,self)
			    			local label        = GetCurBoard():getChildByName(string.format("Panel_Tech_%d",endIdx)):getChildByName("Label_Name_Stroke")
							local afData       = DB_ArtifactConfig.getDataById(afDesc.Id)
							local nameId       = afData.Name
							local nameData     = DB_Text.getDataById(nameId)

				    		af:setInfo(afDesc)
				    		desContainer:removeAllChildren()
				    		desContainer:addChild(af)
				    		desContainer:setOpacity(255)
							label:setVisible(true)
							label:setString(string.format("%sLv%d",nameData.Text_CN,afDesc.Lv))
					    	
					    	self:RefreshAFBag()
					    end

		    			if afSrc then
				    		if afDesc.Id ~= 0 then 						--孔上原先有东西
				    			self.mModel:doSwallowOperate(afSrc,afDesc,OperateSuccessFunc)
				    		else
			    				afDesc.Id  = afSrc.Id
			    				afDesc.Lv  = afSrc.Lv
			    				afDesc.Ex  = afSrc.Ex
			    				afDesc.Idx = endIdx
			    				OperateSuccessFunc()
				    	    end 
				    	end	    
		    		end 
				end
    		end
    	end

    	if beginIdx ~= 0 then	
    		self.mArtiFactLst:getChildByName(string.format("Panel_Item_%d",beginIdx)):setOpacity(255)
    		beginIdx = 0
    	end

		if movArtFact ~= nil then 
			movArtFact:removeFromParent()
			movArtFact = nil
		end

		cclog("弹起,解除屏蔽", os.date("%c"))
		GUISystem:enableUserInput2()
		return true
	end

	local function onTouchMoved(touch, event)
		local touchMov = touch:getLocationInView()
		touchMov = cc.Director:getInstance():convertToGL(touchMov)
		if movArtFact ~= nil then
			movArtFact:setPosition(touchMov)
		end
	end

	local function onTouchCancelled(touch, event)
	end

	self.mTouchLayer = cc.Layer:create()
	self.mRootWidget:addChild(self.mTouchLayer)
	self.mTouchLayer:setPosition(self.mRootWidget:getPosition())
	self.mTouchLayer:setContentSize(self.mRootWidget:getContentSize())
	-- register touch event
	local listener = cc.EventListenerTouchOneByOne:create()
	--listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    listener:registerScriptHandler(onTouchCancelled,cc.Handler.EVENT_TOUCH_CANCELLED )

    local eventDispatcher = self.mTouchLayer:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self.mTouchLayer)
end

function TechnologyWindow:InitBoard()
	self.mPanelRight = self.mRootWidget:getChildByName("Panel_Right")
	local panelLeft  = self.mRootWidget:getChildByName("Panel_Left")
	self.mBoard1  = panelLeft:getChildByName("Panel_Board_1")
	self.mBoard2  = panelLeft:getChildByName("Panel_Board_2")

	local leftSize   = panelLeft:getContentSize()
	local rightSize  = self.mPanelRight:getContentSize()

	self.mPanelRight:setPositionX(getGoldFightPosition_RD().x - rightSize.width)
	panelLeft:setPositionX((getGoldFightPosition_RD().x - rightSize.width) / 2 - leftSize.width / 2 )

	for i=1,6 do
		local techPanel = self.mBoard1:getChildByName(string.format("Panel_Tech_%d",i))
		local container = self.mBoard1:getChildByName(string.format("Panel_Item_%d",i))
		local nameLabel = techPanel:getChildByName("Label_Name_Stroke")
		local pos       = container:getWorldPosition()
		local size      = container:getContentSize()
		local rect      = cc.rect(pos.x,pos.y,size.width,size.height)

		local afInfo = self.mModel.mTechInfo[1].mTechUsedAFs[i]

		nameLabel:setVisible(false)

		if afInfo and afInfo.Id ~= 0 then
			local af = AFItem.new(afInfo,false,true,2,self)
			af:setInfo(afInfo)
			container:addChild(af)

			local afData = DB_ArtifactConfig.getDataById(afInfo.Id)
			local nameId = afData.Name
			local nameData = DB_Text.getDataById(nameId)

			nameLabel:setVisible(true)
			nameLabel:setString(string.format("%sLv%d",nameData.Text_CN,afInfo.Lv))

		end

		if i > self.mModel.mTechInfo[1].mTechHoleCnt then
			techPanel:getChildByName("Image_Lock"):setVisible(true)
			techPanel:getChildByName("Image_Lock"):setTouchEnabled(true)
		end

		registerWidgetReleaseUpEvent(techPanel:getChildByName("Image_Lock"),
		function()
			MessageBox:showMessageBox1(string.format("需求玩家等级%d",config.TechBoardFactorBase1 + config.TechBoardFactorEx1*(i - 1)))
		end)

		table.insert(self.mRectLArr1,rect)
	end

	for i=1,6 do
		local techPanel = self.mBoard2:getChildByName(string.format("Panel_Tech_%d",i))
		local container = self.mBoard2:getChildByName(string.format("Panel_Item_%d",i))
		local nameLabel = techPanel:getChildByName("Label_Name_Stroke")
		local pos       = container:getWorldPosition()
		local size      = container:getContentSize()
		local rect      = cc.rect(pos.x,pos.y,size.width,size.height)

		local afInfo = self.mModel.mTechInfo[2].mTechUsedAFs[i]

		nameLabel:setVisible(false)

		if afInfo and afInfo.Id ~= 0 then
			local af = AFItem.new(afInfo,false,true,2,self)
			af:setInfo(afInfo)
			container:addChild(af)

			local afData = DB_ArtifactConfig.getDataById(afInfo.Id)
			local nameId = afData.Name
			local nameData = DB_Text.getDataById(nameId)

			nameLabel:setVisible(true)
			nameLabel:setString(string.format("%sLv%d",nameData.Text_CN,afInfo.Lv))
		end

		if i > self.mModel.mTechInfo[2].mTechHoleCnt then
			techPanel:getChildByName("Image_Lock"):setVisible(true)
			techPanel:getChildByName("Image_Lock"):setTouchEnabled(true)
		end

		registerWidgetReleaseUpEvent(techPanel:getChildByName("Image_Lock"),
		function()
			MessageBox:showMessageBox1(string.format("需求玩家等级%d", config.TechBoardFactorBase2 + config.TechBoardFactorEx2* (i - 1)))
		end)

		table.insert(self.mRectLArr2,rect)
	end

	local boardBg = self.mRootWidget:getChildByName("Image_Bg")
	local leftBtn = panelLeft:getChildByName("Button_Arrow_Left")
	local rightBtn = panelLeft:getChildByName("Button_Arrow_Right")

	local function OnPressBtn(widget)
		local isLeft = false
		local typ    = 1 
		if widget == leftBtn then isLeft = true typ = 1 else isLeft = false typ = 2 end 
		self.mBoard1:setVisible(isLeft)
		self.mBoard2:setVisible(not isLeft)
		boardBg:loadTexture(string.format("technology_bg_%d.png",typ))
		leftBtn:setVisible(not isLeft)
		rightBtn:setVisible(isLeft)

		panelLeft:getChildByName("Label_Name"):setString(self.mModel.mTechInfo[typ].mTechName)
		panelLeft:getChildByName("Label_Zhanli"):setString(tostring(self.mModel.mTechCombat))
	end

	registerWidgetReleaseUpEvent(leftBtn,OnPressBtn)
	registerWidgetReleaseUpEvent(rightBtn,OnPressBtn)

	OnPressBtn(leftBtn)
end

function TechnologyWindow:OnPressBtnAFBag(widget)
	local prevBtn = self.mRootWidget:getChildByName("Button_FrontPage")
	local nextBtn = self.mRootWidget:getChildByName("Button_NextPage")
	local totalPage  = 4
	if totalPage == 0 then totalPage = 1 end
	
	if widget == prevBtn then 
		self.mCurAFBagPage = self.mCurAFBagPage - 1
		if self.mCurAFBagPage < 1 then self.mCurAFBagPage = 1 end
	else
		self.mCurAFBagPage = self.mCurAFBagPage + 1
		if self.mCurAFBagPage > totalPage then self.mCurAFBagPage = totalPage end
	end

	if self.mCurAFBagPage == 1 then
		prevBtn:setVisible(false)
		prevBtn:setTouchEnabled(false)
		if totalPage == 1 then
			nextBtn:setVisible(false)
			nextBtn:setTouchEnabled(false)
		end
	elseif self.mCurAFBagPage == totalPage then
		nextBtn:setVisible(false)
		nextBtn:setTouchEnabled(false)
	else
		nextBtn:setVisible(true)
		nextBtn:setTouchEnabled(true)
		prevBtn:setVisible(true)
		prevBtn:setTouchEnabled(true)
	end

	self.mRootWidget:getChildByName("Label_Page"):setString(string.format("%d/%d",self.mCurAFBagPage,totalPage))
	self:RefreshAFBag()
end

function TechnologyWindow:RefreshAFBag()
	self.mArtiFactLst = self.mRootWidget:getChildByName("Panel_TechList")	
	self.mRectRArr  = {}

	for i=1,16 do
		local container = self.mArtiFactLst:getChildByName(string.format("Panel_Item_%d",i)):getChildByName("Panel_Item")
		local curIdx    = (self.mCurAFBagPage - 1) * 16 + i
		local lockImg   = self.mArtiFactLst:getChildByName(string.format("Panel_Item_%d",i)):getChildByName("Image_Lock")
		local lockBg   = self.mArtiFactLst:getChildByName(string.format("Panel_Item_%d",i)):getChildByName("Image_Bg")

		if curIdx <= self.mModel.mBagCellCnt then
			lockImg:setVisible(false)
			lockBg:setVisible(true)
			container:setVisible(true)
			registerWidgetReleaseUpEvent(lockImg,function() print("do not buy bagCellCnt") end)
		else
			lockImg:setVisible(true)
			lockBg:setVisible(false)
			container:setVisible(false)
			registerWidgetReleaseUpEvent(lockImg,function() self.mModel:doExpandAfBagRequest() end)
		end

		local afInfo = self.mModel.mUnUsedAFs[curIdx]

		container:setVisible(true)
		container:removeAllChildren()

		local pos  = container:getWorldPosition()
		local size = container:getContentSize()
		local rect = cc.rect(pos.x,pos.y,size.width,size.height)
		if afInfo then
			if afInfo.Id ~= 0 then
				local item = AFItem.new(afInfo,true,true,0,self)
				item:setInfo(afInfo,BAG_NORMAL)
				container:addChild(item)
			end
		end					
		self.mRectRArr[i] = rect
	end
end

function TechnologyWindow:RefreshAFBagG()
	for i=1,5 do
		local panelTmp = self.mGuessPanel:getChildByName("Panel_MasterList_2"):getChildByName(string.format("Panel_Master_%d",i))
		local panelBack = self.mGuessPanel:getChildByName("Panel_MasterList_1"):getChildByName(string.format("Panel_Master_%d",i))
		if i ~= self.mModel.mCurGuessIdx then
			panelTmp:setVisible(false)
			panelBack:setVisible(true)
		else
			panelTmp:setVisible(true)
			panelBack:setVisible(false)			
		end
	end

	for i=1,16 do
		local afInfo    = self.mModel.mGuessBag[i]
		self:AddOneToGuessBag(afInfo)
		if afInfo == nil then
			local container = self.mGuessPanel:getChildByName(string.format("Panel_Item_%d",i)):getChildByName("Panel_Item")
			container:removeAllChildren()
		end
	end
end

function TechnologyWindow:AddOneToGuessBag(afInfo)
	for i=1,5 do
		local panelTmp = self.mGuessPanel:getChildByName("Panel_MasterList_2"):getChildByName(string.format("Panel_Master_%d",i))
		local panelBack = self.mGuessPanel:getChildByName("Panel_MasterList_1"):getChildByName(string.format("Panel_Master_%d",i))
		if i ~= self.mModel.mCurGuessIdx then
			panelTmp:setVisible(false)
			panelBack:setVisible(true)
		else
			panelTmp:setVisible(true)
			panelBack:setVisible(false)			
		end
	end
	
	if afInfo then
		local container = self.mGuessPanel:getChildByName(string.format("Panel_Item_%d",afInfo.Idx)):getChildByName("Panel_Item")
		local item      = AFItem.new(afInfo,true,true,0,self)
		item:setInfo(afInfo,BAG_GUESS)
		container:removeAllChildren()
		container:setVisible(true)
		container:addChild(item,100)
	end
end

function TechnologyWindow:DeleteOneFromGuessBag(index)
	self.mGuessPanel:getChildByName(string.format("Panel_Item_%d",index)):getChildByName("Panel_Item"):removeAllChildren()
end

function TechnologyWindow:Destroy()
	self.mCurAFBagPage = 1
	
	self.mModel:destroyInstance()

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
	TextureSystem:unloadPlist_zodiac()
	CommonAnimation.clearAllTextures()
end

function TechnologyWindow:onEventHandler(event, func)
	if event.mAction == Event.WINDOW_SHOW then
		GUIWidgetPool:preLoadWidget("Technology_ItemCell", true)
		self:Load(event)
		---------停止画主城镇界面
		EventSystem:PushEvent(Event.GUISYSTEM_DISABLEDRAW_HOMEWINDOW)
		---------
		self.mCallFuncAfterDestroy = func
		-- 红点刷新
		NoticeSystem:doSingleUpdate(self.mName)
		
	elseif event.mAction == Event.WINDOW_HIDE then
		self:Destroy()
		---------开启画主城镇界面
		EventSystem:PushEvent(Event.GUISYSTEM_EABLEDRAW_HOMEWINDOW)
		GUIWidgetPool:preLoadWidget("Technology_ItemCell", false)
		---------
		if self.mCallFuncAfterDestroy then
			self.mCallFuncAfterDestroy()
			self.mCallFuncAfterDestroy = nil
		end
	end
end

return TechnologyWindow