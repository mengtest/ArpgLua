-- Name: 	PartySkillWindow
-- Func：	帮会技能界面
-- Author:	lichuan
-- Data:	16-2-28
--==================================================================window begin=========================================================================

local PartySkillInfo = {}
function PartySkillInfo:new()
	local o = 
	{
		mId                = 0,
		mLv                = 0,
		mLimtLv            = 0,
		mNameId            = 0,
		mDesId             = 0,
		mIconId            = 0,
		mUpNeddPlayLv      = 0,
		mBuildName         = 0,
		mUpNeedBuildLv     = 0,

		mPreId             = 0,
		mPreIconId         = 0,
		mPreNameId         = 0,
		mPreLv			   = 0,	
		
		mUpNeedMoney       = 0,
		mUpNeedContri      = 0,

		mCostItems         = {},
		mAttriArr          = {},
		mCanUpgrade        = 0,
	}
	o = newObject(o, PartySkillInfo)
	return o
end

function PartySkillInfo:getKeyValue(key)
	if self[key] then
		return self[key]
	end
	return nil
end

local PSMInstance = nil

PartySkillModel = class("PartySkillModel")

function PartySkillModel:ctor()
	self.mName		    = "PartySkillModel"
	self.mOwner         = nil

	self.mSkillInfoArr = {}

	self:registerNetEvent()
end

function PartySkillModel:deinit()
	self.mName  	     = nil
	self.mOwner 	     = nil
	self.mRefresh        = false

	self.mSkillInfoArr = {}

	self:unRegisterNetEvent()
end

function PartySkillModel:getInstance()
	if PSMInstance == nil then  
        PSMInstance = PartySkillModel.new()
    end  
    return PSMInstance
end

function PartySkillModel:destroyInstance()
	if PSMInstance then
		PSMInstance:deinit()
    	PSMInstance = nil
    end
end

function PartySkillModel:registerNetEvent()
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_LOAD_SKILLINFO_RESPONSE, handler(self, self.onLoadPartySkillInfoResponse))
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_UPGREDE_SKILL_RESPONSE, handler(self, self.onUpgradeSkillResponse))
end

function PartySkillModel:unRegisterNetEvent()
	NetSystem.mNetManager:UnregisterPacketHandler(PacketTyper._PTYPE_SC_LOAD_SKILLINFO_RESPONSE)
	NetSystem.mNetManager:UnregisterPacketHandler(PacketTyper._PTYPE_SC_UPGREDE_SKILL_RESPONSE)
end

function PartySkillModel:setOwner(owner)
	self.mOwner = owner
end

function PartySkillModel:doLoadPartySkillInfoRequest()
	local packet = NetSystem.mNetManager:GetSPacket()
    packet:SetType(PacketTyper._PTYPE_CS_LOAD_SKILLINFO_REQUEST)
    packet:Send()
    GUISystem:showLoading()
end

function PartySkillModel:onLoadPartySkillInfoResponse(msgPacket)
	local skillCnt = msgPacket:GetInt()
	self.mSkillInfoArr = {}
	for i=1,skillCnt do
		local skillInfo            = PartySkillInfo:new()
		skillInfo.mId              = msgPacket:GetInt()
		skillInfo.mLv              = msgPacket:GetInt()
		skillInfo.mLimtLv          = msgPacket:GetInt()	
		skillInfo.mNameId          = msgPacket:GetInt()
		skillInfo.mDesId           = msgPacket:GetInt()

		skillInfo.mIconId          = msgPacket:GetInt()
		skillInfo.mUpNeddPlayLv    = msgPacket:GetInt()
		skillInfo.mBuildName       = msgPacket:GetString()
		skillInfo.mUpNeedBuildLv   = msgPacket:GetInt()

		skillInfo.mPreId           = msgPacket:GetInt()
		if skillInfo.mPreId ~= 0 then
			skillInfo.mPreIconId       = msgPacket:GetInt()
			skillInfo.mPreNameId       = msgPacket:GetInt()
			skillInfo.mPreLv           = msgPacket:GetInt()
		end

		skillInfo.mUpNeedMoney     = msgPacket:GetInt()
		skillInfo.mUpNeedContri    = msgPacket:GetInt()

		skillInfo.mCostItems     = {}
		local itemCnt            = msgPacket:GetUShort()

		for i=1,itemCnt do
			skillInfo.mCostItems[i] = {}
			skillInfo.mCostItems[i][1] = msgPacket:GetInt()
			skillInfo.mCostItems[i][2] = msgPacket:GetInt()
			skillInfo.mCostItems[i][3] = msgPacket:GetInt()

			print(skillInfo.mCostItems[i][1],skillInfo.mCostItems[i][2],skillInfo.mCostItems[i][3])
		end

		local attriCnt = msgPacket:GetInt()
		for i=1,attriCnt do
			skillInfo.mAttriArr[i] = {}
			skillInfo.mAttriArr[i][1] = msgPacket:GetString()
			skillInfo.mAttriArr[i][2] = msgPacket:GetInt()
			skillInfo.mAttriArr[i][3] = msgPacket:GetInt()
		end

		skillInfo.mCanUpgrade	   = msgPacket:GetChar()
		table.insert(self.mSkillInfoArr,skillInfo)
	end
	GUISystem:hideLoading()

	if self.mRefresh == true then
		self.mOwner:InitSkillInfo()
	else
		EventSystem:PushEvent(Event.GUISYSTEM_SHOW_PARTYSKILLWINDOW)
	end
end

function PartySkillModel:doUpgradeSkillRequest(index)
	if index == 0 then return end
	local packet = NetSystem.mNetManager:GetSPacket()
    packet:SetType(PacketTyper._PTYPE_CS_UPGREDE_SKILL_REQUEST)
    packet:PushString(self.mSkillInfoArr[index].mId)
    packet:Send()
    GUISystem:showLoading()
end

function PartySkillModel:onUpgradeSkillResponse(msgPacket)
	local ret = msgPacket:GetChar()

	GUISystem:hideLoading()
	if ret == 0 then
		self.mRefresh        = true
		self:doLoadPartySkillInfoRequest()
	else
		MessageBox:showMessageBox1("学习失败！")
	end
end


local PartySkillWindow = 
{
	mName 				= "PartySkillWindow",
	mRootNode			=	nil,	
	mRootWidget 		= 	nil,
	mTopRoleInfoPanel	=	nil,	-- 顶部人物信息面板
	mModel				=   nil,
}

function PartySkillWindow:Load(event)
	cclog("=====PartySkillWindow:Load=====begin")

	self.mRootNode = cc.Node:create()
	GUISystem:GetRootNode():addChild(self.mRootNode)

	--self.mEventData    = event.mData
	self.mModel = PartySkillModel:getInstance()
	self.mModel:setOwner(self)
	

	TextureSystem:loadPlist_iconskill()
	self:InitLayout()
	
	cclog("=====PartySkillWindow:Load=====end")
end

function PartySkillWindow:InitLayout()
	if self.mRootWidget == nil then
		self.mRootWidget = GUIWidgetPool:createWidget("Guild_Skill")
   		self.mRootNode:addChild(self.mRootWidget)
   	end

   	if self.mTopRoleInfoPanel == nil then
		cclog("PartySkillWindow mTopRoleInfoPanel init")
		self.mTopRoleInfoPanel = TopRoleInfoPanel:new()
		self.mTopRoleInfoPanel:init(self.mRootNode, ROLE_TITLE_TYPE.TITLE_PARTY_SKILL,
		function()
			GUISystem:playSound("homeBtnSound")		
			EventSystem:PushEvent(Event.GUISYSTEM_HIDE_PARTYSKILLWINDOW)	
		end)
	end

	local topSize = self.mTopRoleInfoPanel.mTopWidget:getContentSize()
	local y = getGoldFightPosition_Middle().y - topSize.height / 2
	local x = getGoldFightPosition_Middle().x

	local mainPanel = self.mRootWidget:getChildByName("Panel_Window")
	mainPanel:setAnchorPoint(0.5,0.5)
	mainPanel:setPosition(cc.p(x,y))

	self:InitSkillInfo()
end

function PartySkillWindow:InitSkillInfo()
	SKILL_BASE_TAG    = 2933
	SKILL_SPECIAL_TAG = 2935

	local lastSkillWidget = nil
	local function OnPressSkill(widget)
		local tag = widget:getTag()
		if lastSkillWidget ~= widget then
			widget:getChildByName("Image_SkillBg"):loadTexture("guild_skill_skilltree_bg_1.png")

			if lastSkillWidget ~= nil then
				lastSkillWidget:getChildByName("Image_SkillBg"):loadTexture("guild_skill_skilltree_bg_2.png")
			end
			lastSkillWidget  = widget
			self.mSkillIndex = tag
			self:UpdateSkillInfo(tag)
		end
	end

	local function OnPressPage(widget)
		local tag = widget:getTag()

		if self.mSkillType ~= tag then
			if tag == SKILL_BASE_TAG then
				self.mRootWidget:getChildByName("ScrollView_SkillTree_1"):setVisible(true)
				self.mRootWidget:getChildByName("ScrollView_SkillTree_2"):setVisible(false)
			else
				self.mRootWidget:getChildByName("ScrollView_SkillTree_2"):setVisible(true)
				self.mRootWidget:getChildByName("ScrollView_SkillTree_1"):setVisible(false)
			end
			self.mSkillType  = tag
			self.mSkillIndex = 0
		end

		if tag == SKILL_BASE_TAG then
			widget:loadTexture("guild_skill_page_1_1.png")
			self.mRootWidget:getChildByName("Image_Page_2"):loadTexture("guild_skill_page_2_2.png")
			if self.mSkillIndex ~= 0 then
				OnPressSkill(self.mRootWidget:getChildByName(string.format("Panel_Skill_%d",self.mSkillIndex)))
			else
				OnPressSkill(self.mRootWidget:getChildByName("Panel_Skill_11"))
			end
		else
			widget:loadTexture("guild_skill_page_2_1.png")
			self.mRootWidget:getChildByName("Image_Page_1"):loadTexture("guild_skill_page_1_2.png")
			if self.mSkillIndex ~= 0 then
				OnPressSkill(self.mRootWidget:getChildByName(string.format("Panel_Skill_%d",self.mSkillIndex)))
			else
				OnPressSkill(self.mRootWidget:getChildByName("Panel_Skill_1"))
			end
		end
	end

	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Image_Page_1"),OnPressPage)
	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Image_Page_2"),OnPressPage)
	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_Upgrade"),function() self.mModel:doUpgradeSkillRequest(self.mSkillIndex) end)
	
	for i=1,19 do
		local skillInfo = self.mModel.mSkillInfoArr[i]
		if skillInfo then  
			local panel     = self.mRootWidget:getChildByName(string.format("Panel_Skill_%d",i))
			local imgData   = DB_ResourceList.getDataById(skillInfo.mIconId)
			local imgAddr   = imgData.Res_path1

			panel:getChildByName("Label_SkillLevel"):setString(string.format("%d/%d",skillInfo.mLv,skillInfo.mLimtLv))
			panel:setTag(i)
			panel:getChildByName("Image_SkillIcon"):loadTexture(imgAddr,1)
			registerWidgetPushDownEvent(panel,OnPressSkill)
		end
	end

	if self.mSkillType == SKILL_BASE_TAG or self.mSkillType == 0 then
		OnPressPage(self.mRootWidget:getChildByName("Image_Page_1"))
	else
		OnPressPage(self.mRootWidget:getChildByName("Image_Page_2"))
	end
end

function PartySkillWindow:UpdateSkillInfo(index)
	local skillInfoPanel = self.mRootWidget:getChildByName("Panel_SkillInfo")
	local skillInfo = self.mModel.mSkillInfoArr[index]

	local nameData  = DB_Text.getDataById(skillInfo.mNameId)
	local nameStr   = nameData.Text_CN

	local desData   = DB_Text.getDataById(skillInfo.mDesId)
	local desStr    = desData.Text_CN
	local skillAttrPanel = nil

	local imgData   = DB_ResourceList.getDataById(skillInfo.mIconId)
	local imgAddr   = imgData.Res_path1

	skillInfoPanel:getChildByName("Image_CurSkillIcon"):loadTexture(imgAddr,1)
	skillInfoPanel:getChildByName("Label_CurSkillName_Stroke"):setString(nameStr)
	skillInfoPanel:getChildByName("Label_CurSkillLevel"):setString(string.format("%d/%d",skillInfo.mLv,skillInfo.mLimtLv))
	skillInfoPanel:getChildByName("Label_CurSkillDes"):setString(desStr)

	local skillUpgradePanel = self.mRootWidget:getChildByName("Panel_SkillUpgrade")
	local skillFullPanel    = self.mRootWidget:getChildByName("Panel_SkillFullLevel")
	local preSkillPanel     = skillUpgradePanel:getChildByName("Panel_PreSkill")

	if skillInfo.mLv == skillInfo.mLimtLv then
		skillFullPanel:setVisible(true)
		skillUpgradePanel:setVisible(false)
		skillAttrPanel = skillFullPanel
	else
		skillFullPanel:setVisible(false)
		skillUpgradePanel:setVisible(true)
		skillAttrPanel = skillUpgradePanel
	end 

	if skillInfo.mPreId ~= 0 then
		local preNameData  = DB_Text.getDataById(skillInfo.mPreNameId)
		local preNameStr   = preNameData.Text_CN

		local imgData   = DB_ResourceList.getDataById(skillInfo.mPreIconId)
		local imgAddr   = imgData.Res_path1
		preSkillPanel:setVisible(true)

		preSkillPanel:getChildByName("Image_PreSkillIcon"):loadTexture(imgAddr,1)
		preSkillPanel:getChildByName("Label_PreSkillNameLevel"):setString(string.format("%s Lv%d",preNameStr,skillInfo.mPreLv))
	else
		preSkillPanel:setVisible(false)
	end
		 
	skillUpgradePanel:getChildByName("Label_RequiredPlayerLevel"):setString(tostring(skillInfo.mUpNeddPlayLv))
	skillUpgradePanel:getChildByName("Label_RequiredBuildIngLevel"):setString(string.format("%s Lv%d",skillInfo.mBuildName,skillInfo.mUpNeedBuildLv))
	skillUpgradePanel:getChildByName("Label_RequiredContribution"):setString(tostring(skillInfo.mUpNeedContri))

	local contriPanel = skillUpgradePanel:getChildByName("Panel_RequiredContribution")
	local moneyPanel = skillUpgradePanel:getChildByName("Panel_RequiredCurrency")

	if skillInfo.mUpNeedContri == 0 then
		contriPanel:setVisible(false)
	else
		contriPanel:setVisible(true)
		contriPanel:getChildByName("Label_RequiredContribution"):setString(tostring(skillInfo.mUpNeedContri))
	end
	
	if skillInfo.mUpNeedMoney == 0 then
		moneyPanel:setVisible(false)
	else
		moneyPanel:setVisible(true)
		moneyPanel:getChildByName("Label_RequiredContribution"):setString(tostring(skillInfo.mUpNeedMoney))
	end

	for i=1,4 do
		skillAttrPanel:getChildByName(string.format("Panel_Property_%d",i)):setVisible(false)
	end
	
	for i=1,#skillInfo.mAttriArr do 
		local attrPanel = skillAttrPanel:getChildByName(string.format("Panel_Property_%d",i))
		attrPanel:setVisible(true)
		
		attrPanel:getChildByName("Label_PropertyName"):setString(tostring(skillInfo.mAttriArr[i][1]))
		attrPanel:getChildByName("Label_PropertyCur"):setString(tostring(skillInfo.mAttriArr[i][2]))
		if skillInfo.mLv < skillInfo.mLimtLv then
			attrPanel:getChildByName("Label_PropertyNext"):setString(tostring(skillInfo.mAttriArr[i][3]))
		end		
	end

	if #skillInfo.mCostItems == 0 then 
		skillUpgradePanel:getChildByName("Panel_RequiredItem"):setVisible(false)
	else
		skillUpgradePanel:getChildByName("Panel_RequiredItem"):setVisible(true)
	end

	for i=1,#skillInfo.mCostItems do
		local rewardPanel  = skillUpgradePanel:getChildByName(string.format("Panel_Item_%d",i))
		local rewardWidget = createCommonWidget(skillInfo.mCostItems[i][1],skillInfo.mCostItems[i][2],skillInfo.mCostItems[i][3])

		rewardPanel:setVisible(true)
		rewardPanel:removeAllChildren() 
		rewardPanel:addChild(rewardWidget)
	end

	local btnUp = skillUpgradePanel:getChildByName("Button_Upgrade")
	if skillInfo.mCanUpgrade ==  1 then
		btnUp:setTouchEnabled(true)
		ShaderManager:DoUIWidgetDisabled(btnUp, false)
		skillUpgradePanel:getChildByName("Panel_Demand_1"):setVisible(false)
		skillUpgradePanel:getChildByName("Panel_Demand_2"):setVisible(true)
	else
		btnUp:setTouchEnabled(false) 
		ShaderManager:DoUIWidgetDisabled(btnUp, true)
		skillUpgradePanel:getChildByName("Panel_Demand_1"):setVisible(true)
		skillUpgradePanel:getChildByName("Panel_Demand_2"):setVisible(false)
	end
end

function PartySkillWindow:Destroy()
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
	TextureSystem:unloadPlist_iconskill()
	CommonAnimation.clearAllTextures()
end

function PartySkillWindow:onEventHandler(event)
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

return PartySkillWindow