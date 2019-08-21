-- Name: 	FriendModel
-- Func：	好友模型
-- Author:	lichuan
-- Data:	15-5-12

local FriendInfo = {}
function FriendInfo:new()
	local o = 
	{
		mFriendIdStr 			    = nil,	-- 好友ID
		mFriendNameStr			    = nil,	-- 好友名字
		mFriendFrameId              = nil,  -- 好友头像边框
		mFriendIconId			    = 0,	-- 好友头像ID
		mFriendLv		            = 0,	-- 好友等级
		mFriendFightPower		    = 0,	-- 好友战力
		mFriendCanSend				= nil,	-- 是否可以赠送体力
		mFriendCanGet				= nil,	-- 是否可以领取体力
		mIsFriend					= 0,	-- 是否好友
		mFriendIsOnline		        = 0,	-- 好友在线
		mFriendLastOnlineTime	    = 0,	-- 上次在线时间
	}
	o = newObject(o, FriendInfo)
	return o
end

function FriendInfo:getKeyValue(key)
	if self[key] then
		return self[key]
	end
	return nil
end

local FMInstance = nil

FriendModel = class("FriendModel")

function FriendModel:ctor()
	self.mName 		       = "FriendModel"
	self.mOwner			   = nil
	self.mFriendDataSource = {}
	self.mSearchDataSource = {}
	self.mApplyDataSource  = {}
	self.mDataSource 	   = {}
	self:registerNetEvent()
end

function FriendModel:deinit()
	self.mName 		       = nil
	self.mOwner			   = nil
	self.mFriendDataSource = {}
	self.mSearchDataSource = {}
	self.mApplyDataSource  = {}
	self.mDataSource 	   = {}
	self:unRegisterNetEvent()
end

function FriendModel:getInstance()
	if FMInstance == nil then  
        FMInstance = FriendModel.new()
    end  
    return FMInstance
end

function FriendModel:destroyInstance()
	if FMInstance then
		FMInstance:deinit()
    	FMInstance = nil
    end
end

function FriendModel:registerNetEvent()
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_REQUEST_FRIEND_LIST_,			  handler(self, self.onFriendListResponse))
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_REQUEST_FRIEND_RECOMMOND_LIST_, handler(self, self.onRecommListResponse))
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_REQUEST_FRIEND_APPLY_LIST_, 	  handler(self, self.onApplyListResponse))
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_SEARCH_FRIEND_,                 handler(self, self.onSearchListResponse))

	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_AUTO_RECEIVE_ENERGY,            handler(self, self.onAutoReceiveResponse))
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_REQUEST_ADD_FRIEND_,            handler(self, self.onAddFriendResponse))
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_DELETE_FRIEND_,                 handler(self, self.onDelFriendResponse))

	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_SEND_ENERGY_,                   handler(self,self.onSendEnergyResponse))
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_RECEIVE_ENERGY, 				  handler(self,onReceiveEnergyResponse))
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_REQUEST_AGREE_ADD_,             handler(self, self.onFriendAgreeResponse))
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_REQUEST_REFUSE_ADD_,            handler(self, self.onFriendRefuseResponse))
end

function FriendModel:unRegisterNetEvent()
	NetSystem.mNetManager:UnregisterPacketHandler(PacketTyper._PTYPE_SC_REQUEST_FRIEND_LIST_)
	NetSystem.mNetManager:UnregisterPacketHandler(PacketTyper._PTYPE_SC_REQUEST_FRIEND_RECOMMOND_LIST_)
	NetSystem.mNetManager:UnregisterPacketHandler(PacketTyper._PTYPE_SC_REQUEST_FRIEND_APPLY_LIST_)
	NetSystem.mNetManager:UnregisterPacketHandler(PacketTyper._PTYPE_SC_SEARCH_FRIEND_)

	NetSystem.mNetManager:UnregisterPacketHandler(PacketTyper._PTYPE_SC_AUTO_RECEIVE_ENERGY)
	NetSystem.mNetManager:UnregisterPacketHandler(PacketTyper._PTYPE_SC_REQUEST_ADD_FRIEND_)
	NetSystem.mNetManager:UnregisterPacketHandler(PacketTyper._PTYPE_SC_DELETE_FRIEND_)

	NetSystem.mNetManager:UnregisterPacketHandler(PacketTyper._PTYPE_SC_SEND_ENERGY_)
	NetSystem.mNetManager:UnregisterPacketHandler(PacketTyper._PTYPE_SC_RECEIVE_ENERGY)
	NetSystem.mNetManager:UnregisterPacketHandler(PacketTyper._PTYPE_SC_REQUEST_AGREE_ADD_)
	NetSystem.mNetManager:UnregisterPacketHandler(PacketTyper._PTYPE_SC_REQUEST_REFUSE_ADD_)
end 

function FriendModel:setOwner(owner)
	self.mOwner = owner
end

-- 初始化数据源
function FriendModel:doLoadDataRequest(type,param)
	self.mFriendDataSource = {}
	self.mSearchDataSource = {}
	self.mApplyDataSource  = {}

	local function requstSourceList()
		local packet = NetSystem.mNetManager:GetSPacket()
	    packet:SetType(type)
	    if param ~= nil then
	    	packet:PushString(tostring(param))
	    end
	    packet:Send()
    	GUISystem:showLoading()
	end
	requstSourceList()
end

function FriendModel:reLoad()
	if #self.mFriendDataSource ~= 0 then
		self:doLoadDataRequest(PacketTyper._PTYPE_CS_REQUEST_FRIEND_LIST_,nil)
	elseif #self.mSearchDataSource ~= 0 then
		--self:doLoadDataRequest(PacketTyper._PTYPE_CS_REQUEST_FRIEND_RECOMMOND_LIST_,nil)
	elseif #self.mApplyDataSource ~= 0 then
		self:doLoadDataRequest(PacketTyper._PTYPE_CS_REQUEST_FRIEND_APPLY_LIST_,nil)
	end
end

function FriendModel:onFriendListResponse(msgPacket)
	local friendCnt = msgPacket:GetUShort()
	for j = 1, friendCnt do
		local friendInfo                     = FriendInfo:new()
		friendInfo.mFriendIdStr              = msgPacket:GetString()
		friendInfo.mFriendNameStr            = msgPacket:GetString()
		friendInfo.mFriendFrameId            = msgPacket:GetInt()
		friendInfo.mFriendIconId             = msgPacket:GetInt()
		friendInfo.mFriendLv                 = msgPacket:GetInt()
		friendInfo.mFriendFightPower         = msgPacket:GetInt()
		friendInfo.mFriendCanSend			 = msgPacket:GetChar()
		friendInfo.mFriendCanGet			 = msgPacket:GetChar()
		friendInfo.mFriendIsOnline           = msgPacket:GetChar()
		if friendInfo.mFriendIsOnline == 1 then
			friendInfo.mFriendLastOnlineTime = msgPacket:GetString()
		end
		table.insert(self.mFriendDataSource,friendInfo)
	end

	GUISystem:hideLoading()

	self.mDataSource = {}
	self.mDataSource = self.mFriendDataSource
	globaldata.friendList = self.mFriendDataSource
	self.mOwner.mFriendTableView:UpdateTableView(#self.mFriendDataSource)
	self.mOwner:UpdateLayout()
end

function FriendModel:onRecommListResponse(msgPacket)
	local recommCnt = msgPacket:GetUShort()
	for j = 1, recommCnt do
		local recommInfo                     = FriendInfo:new()
		recommInfo.mFriendIdStr              = msgPacket:GetString()
		recommInfo.mFriendNameStr            = msgPacket:GetString()
		recommInfo.mFriendFrameId            = msgPacket:GetInt()
		recommInfo.mFriendIconId             = msgPacket:GetInt()
		recommInfo.mFriendLv                 = msgPacket:GetInt()
		recommInfo.mFriendFightPower         = msgPacket:GetInt()
		recommInfo.mFriendIsOnline           = msgPacket:GetChar()
		--doError(recommInfo.mFriendIsOnline)
		if recommInfo.mFriendIsOnline == 1 then
			recommInfo.mFriendLastOnlineTime = msgPacket:GetString()
		end

		table.insert(self.mSearchDataSource,recommInfo)
	end

	GUISystem:hideLoading()

	self.mDataSource = {}
	self.mDataSource = self.mSearchDataSource
	self.mOwner.mFriendTableView:UpdateTableView(#self.mSearchDataSource)
	self.mOwner:UpdateLayout()
end


function FriendModel:onSearchListResponse(msgPacket)
	local searchCnt = msgPacket:GetUShort()
	for j = 1, searchCnt do
		local searchInfo                     = FriendInfo:new()
		searchInfo.mFriendIdStr              = msgPacket:GetString()
		searchInfo.mFriendNameStr            = msgPacket:GetString()
		searchInfo.mFriendFrameId            = msgPacket:GetInt()
		searchInfo.mFriendIconId             = msgPacket:GetInt()
		searchInfo.mFriendLv                 = msgPacket:GetInt()
		searchInfo.mFriendFightPower         = msgPacket:GetInt()
		searchInfo.mIsFriend        		 = msgPacket:GetChar()
		searchInfo.mFriendIsOnline           = msgPacket:GetChar()
		if searchInfo.mFriendIsOnline == 1 then
			searchInfo.mFriendLastOnlineTime = msgPacket:GetString()
			print(searchInfo.mFriendLastOnlineTime)
		end

		table.insert(self.mSearchDataSource,searchInfo)
	end

	GUISystem:hideLoading()

	self.mDataSource = {}
	self.mDataSource = self.mSearchDataSource
	self.mOwner.mFriendTableView:UpdateTableView(#self.mSearchDataSource)
	self.mOwner:UpdateLayout()
end

function FriendModel:onApplyListResponse(msgPacket)
	local friendCnt = msgPacket:GetUShort()
	for j = 1, friendCnt do
		local friendInfo                     = FriendInfo:new()
		friendInfo.mFriendIdStr              = msgPacket:GetString()
		friendInfo.mFriendNameStr            = msgPacket:GetString()
		friendInfo.mFriendFrameId            = msgPacket:GetInt()
		friendInfo.mFriendIconId             = msgPacket:GetInt()
		friendInfo.mFriendLv                 = msgPacket:GetInt()
		friendInfo.mFriendFightPower         = msgPacket:GetInt()
		friendInfo.mFriendLastOnlineTime     = msgPacket:GetString()
		table.insert(self.mApplyDataSource,friendInfo)
	end

	GUISystem:hideLoading()

	self.mDataSource = {}
	self.mDataSource = self.mApplyDataSource

	if self.mOwner then
		self.mOwner:UpdateLayout()
		if self.mOwner.mFriendTableView then
			self.mOwner.mFriendTableView:UpdateTableView(#self.mApplyDataSource)
		end
	end	
end

function FriendModel:doAddFriendRequest(widget)
	local friendIdIndex = widget:getTag() + 1
	self.mLstAddBtn = widget
    local packet = NetSystem.mNetManager:GetSPacket()
    packet:SetType(PacketTyper._PTYPE_CS_REQUEST_ADD_FRIEND_)
    packet:PushString(self.mDataSource[friendIdIndex].mFriendIdStr)
    if self.mDataSource[friendIdIndex].mFriendIdStr == nil then 
    	doError("friend id is nil")
    end
    packet:Send()
    GUISystem:showLoading()
end

function FriendModel:doAddFriendByIdxRequest(friendIdIndex)
    local packet = NetSystem.mNetManager:GetSPacket()
    packet:SetType(PacketTyper._PTYPE_CS_REQUEST_ADD_FRIEND_)
    packet:PushString(self.mDataSource[friendIdIndex].mFriendIdStr)
    if self.mDataSource[friendIdIndex].mFriendIdStr == nil then 
    	doError("friend id is nil")
    end
    packet:Send()
    GUISystem:showLoading()
end

function FriendModel:onAddFriendResponse(msgPacket)
	local ret = msgPacket:GetChar()

	if ret == 0 then
		if self.mOwner ~= nil then
			if self.mOwner.mPageCurSel == 2 then
				self.mLstAddBtn:setVisible(false)
			else
				self:reLoad()
			end
		end
	end
	GUISystem:hideLoading()
end

function FriendModel:doDelFriendRequest(friendIdIndex)
	local packet = NetSystem.mNetManager:GetSPacket()
    packet:SetType(PacketTyper._PTYPE_CS_DELETE_FRIEND_)
    packet:PushString(self.mDataSource[friendIdIndex].mFriendIdStr)
    packet:Send()
    GUISystem:showLoading()
end

function FriendModel:onDelFriendResponse(msgPacket)
	local ret = msgPacket:GetChar()
	if ret == 0 and self.mOwner ~= nil then
		self:reLoad()
	end
	GUISystem:hideLoading()
end

function FriendModel:doAutoReceiveRequest()
	local packet = NetSystem.mNetManager:GetSPacket()
	packet:SetType(PacketTyper._PTYPE_CS_AUTO_RECEIVE_ENERGY)
	packet:Send()
	 GUISystem:showLoading()
end

function FriendModel:onAutoReceiveResponse(msgPacket)
	local ret = msgPacket:GetChar()
	if ret == 0 then
		self:reLoad()
	end
	GUISystem:hideLoading()
end

function FriendModel:doSendEnergyRequest(friendIdIndex)
	local packet = NetSystem.mNetManager:GetSPacket()
    packet:SetType(PacketTyper._PTYPE_CS_SEND_ENERGY_)
    packet:PushString(self.mDataSource[friendIdIndex].mFriendIdStr)
    packet:Send()
	GUISystem:showLoading()
end

function FriendModel:onSendEnergyResponse(msgPacket)
	local ret = msgPacket:GetChar()
	if ret == 0 then
		self:reLoad()
	end
	GUISystem:hideLoading()
end

function FriendModel:doReceiveEnergyRequest(friendIdIndex)
	local packet = NetSystem.mNetManager:GetSPacket()
    packet:SetType(PacketTyper._PTYPE_CS_RECEIVE_ENERGY)
    packet:PushString(self.mDataSource[friendIdIndex].mFriendIdStr)
    packet:Send()
	GUISystem:showLoading()
end

function FriendModel:onReceiveEnergyResponse(msgPacket)
	local ret = msgPacket:GetChar()
	if ret == 0 then
		self:reLoad()
	end
	GUISystem:hideLoading()
end

function FriendModel:doAgreeAddRequest(friendIdIndex)
	local packet = NetSystem.mNetManager:GetSPacket()
	packet:SetType(PacketTyper._PTYPE_CS_REQUEST_AGREE_ADD_)
	packet:PushString(self.mDataSource[friendIdIndex].mFriendIdStr)
	packet:Send()
	GUISystem:showLoading()
end

function FriendModel:onFriendAgreeResponse(msgPacket)
	local ret = msgPacket:GetChar()
	if ret == 0 and self.mOwner ~= nil then
		self:reLoad()
	end
	GUISystem:hideLoading()
end

function FriendModel:doRefuseAddRequest(friendIdIndex)
	local packet = NetSystem.mNetManager:GetSPacket()
	packet:SetType(PacketTyper._PTYPE_CS_REQUEST_REFUSE_ADD_)
	packet:PushString(self.mDataSource[friendIdIndex].mFriendIdStr)
	packet:Send()
	GUISystem:showLoading()
end

function FriendModel:onFriendRefuseResponse(msgPacket)
	local ret = msgPacket:GetChar()
	if ret == 0 then
		self:reLoad()
	end
	GUISystem:hideLoading()
end

function FriendModel:doFightRequest(friendIdIndex)
	PKHelper:DoPKInvite(self.mDataSource[friendIdIndex].mFriendIdStr,self.mDataSource[friendIdIndex].mFriendNameStr)
end

function FriendModel:doLoadPlayerInfoRequest(friendIdIndex)
    local packet = NetSystem.mNetManager:GetSPacket()
   	packet:SetType(PacketTyper._PTYPE_CS_REQUEST_PLAYER_INFO_)
    packet:PushString(self.mDataSource[friendIdIndex].mFriendIdStr)
   	packet:Send()
   	globaldata.requestType = "FriendWindow"
    GUISystem:showLoading()
end