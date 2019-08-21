-- Name: 	DateModel
-- Func：	闯关界面
-- Author:	lichuan
-- Data:	15-6-16

require "GUISystem/Common"

AllHeroModel = class("AllHeroModel")

function AllHeroModel:ctor(owner)
	self.mName 		     = "AllHeroModel"
	self.mOwner			 = owner
	self.mHeroArr		 = {}
	self.mJinjieNeedItem = {}

	self:readHeroId()
	self:registerNetEvent()
end

function AllHeroModel:registerNetEvent()
	--NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_REQUEST_JINJIEINFO_, handler(self, self.onJinjieInfoResponse))
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_REQUEST_DOJINJIE_, handler(self, self.onJinjieResponse))
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_REQUEST_DOJINHUA_, handler(self, self.onJinhuaResponse))
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_REQUEST_DOPEIYANG_, handler(self, self.onUseItemResponse))
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_GET_SKILL_UPGRADE_REQUEST_, handler(self, self.onSkillUpgradeResponse))
end

function AllHeroModel:readHeroId()
	for i=1,4 do
		self.mHeroArr[i] = {}
	end
	
	for i=1,24 do
		local heroData     = DB_HeroConfig.getDataById(i)
		local heroId       = heroData.ID
		local heroSchoolId = heroData.College
		table.insert(self.mHeroArr[1],heroId) 
		table.insert(self.mHeroArr[heroSchoolId + 1],heroId)
	end
end

function AllHeroModel:doJinjieInfoRequest()
	local heroObj = globaldata:findHeroById(self.mOwner.mSelectHeroId)
	local guid    = heroObj:getKeyValue("guid")
	local packet  = NetSystem.mNetManager:GetSPacket()

    packet:SetType(PacketTyper._PTYPE_CS_REQUEST_JINJIEINFO_)
    packet:PushString(guid)
    packet:PushInt(self.mOwner.mSelectHeroId)
    packet:Send()
	GUISystem:showLoading()
end

function AllHeroModel:onJinjieInfoResponse(msgPacket)
	local heroUid            = msgPacket:GetString()
	local heroId             = msgPacket:GetInt()
	local nameStr            = msgPacket:GetString()
	local curAdvanceLv       = msgPacket:GetInt()
	local curFightPower      = msgPacket:GetInt()
	local isMaxAdvanceLv     = msgPacket:GetChar()

	if isMaxAdvanceLv ~= 0 then 
		local nextAdvanceLv  = msgPacket:GetInt()
		local nextFightPower = msgPacket:GetInt()
		local costItemCnt    = msgPacket:GetUShort()
		self.mJinjieNeedItem = {}
		for i=1,costItemCnt do
			local itemInfo       = RewardInfo:new()
			itemInfo.mRewardType = msgPacket:GetInt()
			itemInfo.mItemId     = msgPacket:GetInt()
			itemInfo.mItemCnt    = msgPacket:GetInt()
			table.insert(self.mJinjieNeedItem,itemInfo)
		end
	end

	self.mOwner:UpdateJnjieInfo()
	GUISystem:hideLoading()
end

function AllHeroModel:doJinjieRequest()
	local heroObj = globaldata:findHeroById(self.mOwner.mSelectHeroId)
	local guid    = heroObj:getKeyValue("guid")

	local packet = NetSystem.mNetManager:GetSPacket()
    packet:SetType(PacketTyper._PTYPE_CS_REQUEST_DOJINJIE_)
    packet:PushString(guid)
    packet:PushInt(self.mOwner.mSelectHeroId)
    packet:Send()
    GUISystem:showLoading()
end

function AllHeroModel:onJinjieResponse(msgPacket)
	globaldata:updateOneHeroInfo(msgPacket)
	--self:doJinjieInfoRequest()
	self.mOwner:UpdateJnjieInfo()
	GUIEventManager:pushEvent("combatChanged")
	GUISystem:hideLoading()
end


function AllHeroModel:doJinhuaRequest()
	local heroObj = globaldata:findHeroById(self.mOwner.mSelectHeroId)
	local guid    = heroObj:getKeyValue("guid")

	local packet = NetSystem.mNetManager:GetSPacket()
    packet:SetType(PacketTyper._PTYPE_CS_REQUEST_DOJINHUA_)
    packet:PushString(guid)
    packet:PushInt(self.mOwner.mSelectHeroId)
    packet:Send()
    GUISystem:showLoading()
end

function AllHeroModel:onJinhuaResponse(msgPacket)
	globaldata:updateOneHeroInfo(msgPacket)
	GUIEventManager:pushEvent("updateJinHua")
	self.mOwner:UpdateJinhuaInfo()
	GUISystem:hideLoading()
end

function AllHeroModel:doUseItemRequest(itemId)
	local heroObj = globaldata:findHeroById(self.mOwner.mSelectHeroId)
	local guid    = heroObj:getKeyValue("guid")

	local packet = NetSystem.mNetManager:GetSPacket()
    packet:SetType(PacketTyper._PTYPE_CS_REQUEST_DOPEIYANG_)
    packet:PushString(guid)
    packet:PushInt(self.mOwner.mSelectHeroId)
    packet:PushUShort(1)
    packet:PushInt(itemId)
    packet:PushInt(1)
    packet:Send()
    GUISystem:showLoading()
end

function AllHeroModel:onUseItemResponse(msgPacket)
	globaldata:updateOneHeroInfo(msgPacket)
	--self.mOwner:UpdateUseItemInfo()
	GUISystem:hideLoading()
end

function AllHeroModel:doGetHeroRequest(fragmentId)
	local packet = NetSystem.mNetManager:GetSPacket()
	 packet:SetType(PacketTyper._PTYPE_CS_REQUEST_USEITEM_)
	 packet:PushInt(fragmentId)
	 packet:PushInt(10)
	 packet:Send()
end

function AllHeroModel:doSkillUpgradeRequest(heroId,skillId,skillIndex)
	self.mSkillIndex = skillIndex
	local packet = NetSystem.mNetManager:GetSPacket()
	packet:SetType(PacketTyper._PTYPE_CS_GET_SKILL_UPGRADE_REQUEST_)
    packet:PushInt(heroId)
    packet:PushInt(skillId)
    packet:Send()
	GUISystem:showLoading()
end

function AllHeroModel:onSkillUpgradeResponse(msgPacket)
	local skillId = msgPacket:GetInt()
	local skillType = msgPacket:GetChar()
	local skillLevel = msgPacket:GetInt()
	local skillPrice = msgPacket:GetInt()

	local heroInfo = globaldata:findHeroById(self.mOwner.mSelectHeroId)
	skillInfoArr = heroInfo.skillList

	for i=1,#skillInfoArr do
		if skillInfoArr[i].mSkillId == skillId then 
			skillInfoArr[i].mSkillType = skillType
			skillInfoArr[i].mSkillLevel = skillLevel
			skillInfoArr[i].mPrice = skillPrice
		end
	end


	if self.mOwner ~= nil then 
		self.mOwner:NotifySkillInfo(skillLevel,self.mSkillIndex,skillPrice)
	end
	
	GUISystem:hideLoading()
end


function AllHeroModel:deinit()
	self.mName 		     = nil
	self.mOwner			 = nil
	self.mJinjieNeedItem = {}
	self.mHeroArr		 = {}
end