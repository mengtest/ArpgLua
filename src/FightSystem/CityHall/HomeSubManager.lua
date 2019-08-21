-- Func: Home子管理器
-- Author: Johny

require "FightSystem/CityHall/FriendFurnitureManager"

HomeSubManager = {}

function HomeSubManager:Release()
	self:Destroy()
	-----
	_G["HomeSubManager"] = nil
  	package.loaded["HomeSubManager"] = nil
  	package.loaded["FightSystem/CityHall/HomeSubManager"] = nil
end

function HomeSubManager:init(_hallManager)
	self.mHallManager = _hallManager
	self.mHome_MemberList = {}
	self.mFurnitrueList = {}
	self.mIsMyHome = true
	-- 注册收包
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_VISITHOME_FRIEND_, handler(self, self.onRequestFriendHomeInfo))
end

function HomeSubManager:Tick(delta)
	for k,v in pairs(self.mHome_MemberList) do
		v:Tick(delta)
	end
end

-- 载入
function HomeSubManager:Load(_root, _pos)
	self:loadFurniture(_root)
	self:loadMyTeamMembers(_root, _pos)
end

-- 销毁
function HomeSubManager:Destroy()
	self:unloadFuniture()
	self:unloadMyTeamMembers()
end

-- 载入家具
function HomeSubManager:loadFurniture(_root)
	if self.mIsMyHome then
		GUISystem.mFurnitManager = FurnitManager:new()
		GUISystem.mFurnitManager:init(_root)
	else
		FriendFurnitureManager:loadFurnitures(self.mFurnitrueList, _root)
	end
end

-- 卸载家具
function HomeSubManager:unloadFuniture()
	if self.mIsMyHome then 
		GUISystem.mFurnitManager:destroy()
		GUISystem.mFurnitManager = nil
	else
		self.mFurnitrueList = {}
		self.mIsMyHome = true
	end
end

-- 载入我的组员
function HomeSubManager:loadMyTeamMembers(_root, _rolePos)
	self.mHome_MemberList = {}
	local _membercount = globaldata:getBattleHeroCount()
	if _membercount < 2 then return end
	local function initOneMember(_idx)
		local _heroID = globaldata:getHeroInfoByBattleIndex(_idx, "id")
		local _rd = RoleData.new(0, "hallrole", _heroID, _rolePos)
		local _proplist = globaldata:getHeroInfoByBattleIndex(_idx, "propList")
		_rd.mSpeed = _proplist[9] / 125
		local _role = FightRole.new(_rd)
		_role.mGunCon:UpdateDB(_idx)
		local success = _role:changeHorse(globaldata:getHeroInfoByBattleIndex(_idx, "horse"))
		if not success then
			_role.mGunCon:EquipedGun()
		end
		_role.mAI:setHallOpenAI(true)
		_role:AddToRoot(_root)
		table.insert(self.mHome_MemberList, _role)
	end
	for idx = 2, _membercount do
		initOneMember(idx)
	end
end

-- 卸载我的组员
function HomeSubManager:unloadMyTeamMembers()
	for k,_role in pairs(self.mHome_MemberList) do
		_role:Destroy() 
		_role = nil
	end
	self.mHome_MemberList = {}
end

-- 更改组员
function HomeSubManager:changeMyTeamMembers(_root, _pos)
	self:unloadMyTeamMembers()
	self:loadMyTeamMembers(_root, _pos)
end

-- 是否在好友房间
function HomeSubManager:isInFriendHome()
	return self.mIsMyHome == false
end

--------------------回调-------------------------
-- 返回好友的家具信息
function HomeSubManager:onRequestFriendHomeInfo(_msgPacket)
	self.mIsMyHome = false
	local _cityid = _msgPacket:GetInt()
	local _furnitureNum = _msgPacket:GetUShort()
	for i = 1, _furnitureNum do
		local _struct = {}
		_struct.itemid = _msgPacket:GetInt()
		_struct.x = _msgPacket:GetUShort()
		_struct.y = _msgPacket:GetUShort()
		table.insert(self.mFurnitrueList, _struct)
	end
	GUISystem:hideLoading()
	HallManager:rmPlayerInfo()
    GUISystem:HideAllWindow()
    showLoadingWindow("HomeWindow")
	FightSystem.mHallManager:OnPreEnterCity(_cityid)
end