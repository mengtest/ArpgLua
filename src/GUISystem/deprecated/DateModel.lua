-- Name: 	DateModel
-- Func：	闯关界面
-- Author:	lichuan
-- Data:	15-6-16


local DateInfo = {}
function DateInfo:new()
	local o = 
	{
		dateId		=	nil,	-- 活动Id	
		dateOpen	=	nil,	-- 是否开启	0:开启 1:关闭
		dateStatus	=   nil,
	}
	o = newObject(o, DateInfo)
	return o
end

function DateInfo:getKeyValue(key)
	if self[key] then
		return self[key]
	end
	return nil
end

-- 好感度对象
local FavorInfo = {}
function FavorInfo:new()
	local o = 
	{
		propType = nil,
		curValue = 0,
		nextValue = 0,
	}
	o = newObject(o, FavorInfo)
	return o
end

function FavorInfo:getKeyValue(key)
	if self[key] then
		return self[key]
	end
	return nil
end


DateModel = class("DateModel")

function DateModel:ctor(owner)
	self.mName 		    = "DateModel"
	self.mOwner			= owner
	self.mDateInfoArr   = {}
	self.mDateEntryInfo = {}

	self.mFavorLv 		= 0  -- 好感度等级
	self.mFavorValue 	= 0  -- 好感值
	self.mFavorMaxVal	= 0	 -- 最大好感值
	self.mPropList   	= {} -- 好感度增加属性列表

	self:registerNetEvent()
end

function DateModel:registerNetEvent()
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_REQUEST_DATE_INFO_, handler(self, self.onDateInfoResponse))
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_REQUEST_DATE_ENTER_, handler(self, self.onEntryInfoResponse))
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_REQUEST_DATE_FRESH_, handler(self, self.onRefreshEntryInfoResponse))
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_REQUEST_FAVOR_PLAYER_, handler(self, self.onPlayerFavorResponse))

	GUIEventManager:registerEvent("dateFinish", self, self.notifyDateFinish)
end

function DateModel:doDateInfoRequest()
    local packet = NetSystem.mNetManager:GetSPacket()
	packet:SetType(PacketTyper._PTYPE_CS_REQUEST_DATE_INFO_)
	packet:Send()
	GUISystem:showLoading()
end

function DateModel:onDateInfoResponse(msgPacket)
	local count = msgPacket:GetInt()
	for i = 1, count do
		local dateInfo = DateInfo:new()
		dateInfo.dateId     = msgPacket:GetInt()
		dateInfo.dateOpen   = msgPacket:GetChar()
		dateInfo.dateStatus = msgPacket:GetChar()
		table.insert(self.mDateInfoArr,dateInfo)		
	end
	GUISystem:hideLoading()
end

function DateModel:notifyDateFinish()
	for i=1,#self.mDateInfoArr do
		if self.mDateInfoArr[i].dateId == self.mOwner.mCurSelDateId then 
			self.mDateInfoArr[i].dateStatus = 0
			return
		end
	end
end

function DateModel:doPlayerFavorRequest()
	local packet = NetSystem.mNetManager:GetSPacket()
    packet:SetType(PacketTyper._PTYPE_CS_REQUEST_FAVOR_PLAYER_)
    packet:Send()
    GUISystem:showLoading()
end

function DateModel:onPlayerFavorResponse(msgPacket)
	self.mFavorLv     = msgPacket:GetInt()
	self.mFavorValue  = msgPacket:GetInt()
	self.mFavorMaxVal = msgPacket:GetInt()
	local favorCount = msgPacket:GetUShort()
	self.mPropList = {}
	for i = 1, favorCount do
		local favorInfo     = FavorInfo:new()
		favorInfo.propType  = msgPacket:GetChar()
		favorInfo.curValue  = msgPacket:GetInt()
		favorInfo.nextValue = msgPacket:GetInt()
		self.mPropList[favorInfo.propType] = favorInfo
	end
	GUISystem:hideLoading()

	self.mOwner:InitDateEventPanels()
	self.mOwner:UpdatePlayFavorInfo()
end


function DateModel:doEntryInfoRequest(dateId)
	local packet = NetSystem.mNetManager:GetSPacket()
    packet:SetType(PacketTyper._PTYPE_CS_REQUEST_DATE_ENTER_)
    packet:PushInt(dateId)
    packet:Send()
    GUISystem:showLoading()
end

function DateModel:onEntryInfoResponse(msgPacket)
	self.mDateEntryInfo = {}
	self.mDateEntryInfo.eventId    = msgPacket:GetInt()
	self.mDateEntryInfo.eventType  = msgPacket:GetChar()
	self.mDateEntryInfo.eventCount = msgPacket:GetUShort()
	self.mDateEntryInfo.heroIdArr  = {}
	for i = 1, self.mDateEntryInfo.eventCount do
		self.mDateEntryInfo.heroIdArr[i]             = {}
		self.mDateEntryInfo.heroIdArr[i].objectId    = msgPacket:GetInt()
		print("*********************",self.mDateEntryInfo.heroIdArr[i].objectId )
		if self.mDateEntryInfo.eventType == 1 then
			self.mDateEntryInfo.heroIdArr[i].favorLv     = msgPacket:GetUShort()
			self.mDateEntryInfo.heroIdArr[i].favorExp    = msgPacket:GetInt()
			self.mDateEntryInfo.heroIdArr[i].favorMaxExp = msgPacket:GetInt()
		end
	end

	self.mDateEntryInfo.freshCnt       = msgPacket:GetChar()
	self.mDateEntryInfo.freshMaxCnt    = msgPacket:GetChar()

	GUISystem:hideLoading()
	self.mOwner:ShowSelectPanel(self.mDateEntryInfo.eventId)
end

function  DateModel:doRefreshEntryInfoRequest()
	if self.mDateEntryInfo.freshCnt == 0 then return end
	local packet = NetSystem.mNetManager:GetSPacket()
    packet:SetType(PacketTyper._PTYPE_CS_REQUEST_DATE_FRESH_)
    packet:PushInt(self.mDateEntryInfo.eventId)
    packet:Send()
    GUISystem:showLoading()
end

function DateModel:onRefreshEntryInfoResponse(msgPacket)
	self.mDateEntryInfo = {}
	self.mDateEntryInfo.eventId = msgPacket:GetInt()
	self.mDateEntryInfo.eventType  = msgPacket:GetChar()
	self.mDateEntryInfo.eventCount = msgPacket:GetUShort()
	self.mDateEntryInfo.heroIdArr = {}
	for i = 1, self.mDateEntryInfo.eventCount do
		self.mDateEntryInfo.heroIdArr[i]             = {}
		self.mDateEntryInfo.heroIdArr[i].objectId    = msgPacket:GetInt()
		if self.mDateEntryInfo.eventType == 1 then
			self.mDateEntryInfo.heroIdArr[i].favorLv     = msgPacket:GetUShort()
			self.mDateEntryInfo.heroIdArr[i].favorExp    = msgPacket:GetInt()
			self.mDateEntryInfo.heroIdArr[i].favorMaxExp = msgPacket:GetInt()
		end
	end

	self.mDateEntryInfo.freshCnt       = msgPacket:GetChar()
	self.mDateEntryInfo.freshMaxCnt    = msgPacket:GetChar()

	GUISystem:hideLoading()
	self.mOwner:ShowSelectPanel(self.mDateEntryInfo.eventId)
end

function DateModel:deinit()
	GUIEventManager:unregister("dateFinish", self.notifyDateFinish)
	self.mName 		    = nil
	self.mOwner			= nil
	self.mDateInfoArr   = {}
	self.mDateEntryInfo = {}
end