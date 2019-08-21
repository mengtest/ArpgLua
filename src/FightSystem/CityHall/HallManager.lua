
-- Func: 城镇大厅管理器
-- Author: Johny

require "FightSystem/CityHall/HallNPC"
require "FightSystem/CityHall/HallTranspoint"
require "FightSystem/CityHall/CheckPlayerInfo"
-- require "FightSystem/CityHall/HomeSubManager"
require "FightSystem/CityHall/UnionSubManager"


HallManager = {}
-------------------【局部变量】-------------------
local _FIRST_CITYID_   = 1 -- 第一个城的ID
local _HOME_STARTPOS_ = cc.p(100,300)
local _SYNCMYPOS_INTERVAL_ = 60
local _PLACE_ = {}
_PLACE_.Town  =  1
_PLACE_.Home  =  2
_PLACE_.Union =  3
local _PLACE_FLAG_ = {}
_PLACE_FLAG_.Home    = 0
_PLACE_FLAG_.Town    = 1
_PLACE_FLAG_.Union   = 2
local OPLIST_MAXCOUNT  =  15  -- 最大其他玩家列表数量
local OP_MAX_DIS     =  0.5 * 1140
--------------------------------------------------
-- 是否是帮派大厅
function HallManager:isUnionHall(flag)
	return flag == _PLACE_FLAG_.Union
end

-- 是否是城镇
function HallManager:isTownHall(flag)
	return flag == _PLACE_FLAG_.Town
end

-- 目前主角在Home
function HallManager:isInHomeHall()
	return self.mPlace == _PLACE_.Home
end

-- 目前主角在城镇
function HallManager:isInCityHall()
	return self.mPlace == _PLACE_.Town
end

-- 目前主角在帮派
function HallManager:isInUnionHall()
	return self.mPlace == _PLACE_.Union
end

----------
function HallManager:init()
	self.mHasLoaded = false
	self.mPlace = -1			--当前所在地区
	self.mOPDataList = {}
	self.mLastBGMID = -1        --记录上次BGM的id
	self.mCurCityID = -1
	-- self.mHomeSubManager = HomeSubManager
	-- self.mHomeSubManager:init(self)
	self.mUnionSubManager = UnionSubManager
	self.mUnionSubManager:init(self)
	-- 注册其他玩家信息同步回调
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_CITYHALL_OP_MOVE, handler(self, self.OnOPMove))
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_CITYHALL_OP_ENTERVIEW, handler(self, self.OnOPEnterView))
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_CITYHALL_OP_LEAVEVIEW, handler(self, self.OnOPLeftView))
end

-- 城镇销毁时播放所属音乐(外部调用)
function HallManager:playHallBGMAfterDestroyed()
	if self.mLastBGMID == -1 then
	   local _db = DB_CityConfig.getDataById(_FIRST_CITYID_)
	   self.mLastBGMID = _db.City_BGM
	end
	if not self.mHasLoaded then
		CommonAnimation.ChangeBGM(self.mLastBGMID)
	end
end

-- 加载 -- 与destroy相对
function HallManager:Load(_root, _zorder)
	math.randomseed(os.clock()*1000+os.time())
	self.mHasLoaded = true
	self.mRoot = _root
	self.mZOrder = _zorder
	self.mTranspointList = {}
	self.mNPCList = {}  -- NPC列表
	self.mOPList = {}  -- 其他玩家列表
	self.mOPListCount = 0  -- 其他玩家数量
	self.mHallRoleIDCounter = 0  -- 城镇大厅角色计数器 , 0 始终为自己
	self.mLastPosMyRole = cc.p(0, 0)  -- 上次我的坐标
	self.mOPMenu = nil
	self.mSyncMyPosInterval = 0 -- 同步坐标间隔
	-- 注册回调
	GUIEventManager:registerEvent("battleTeamChanged", self, self.OnTeamMemberChanged)
	GUIEventManager:registerEvent("equipChanged", self, self.OnTeamMemberChanged)
	FightSystem:RegisterNotifaction("hall_myrolemove", "HallManager", handler(self, self.OnMyRoleMove))
	FightSystem:RegisterNotifaction("hall_myrolestopmove", "HallManager", handler(self, self.OnMyRoleStopMove))
	FightSystem:RegisterNotifaction("hall_anytouch", "HallManager", handler(self, self.OnAnyRegionTouched))
	-- 初始化
	FightSystem:LoadSimpleTouchPad(_zorder + 1, _root)
	local _cityid = globaldata:getCityHallData("cityid")
	local _pos = cc.p(globaldata:getCityHallData("posx"), globaldata:getCityHallData("posy"))
	local _dir = globaldata:getCityHallData("direction")
	self:transferToCity(_cityid, _pos, _dir)
	GUIEventManager:registerEvent("roleBaseInfoChanged", self, self.onRoleBaseChange)
	----
	self:checkRenderAllOP()
end

-- 同步VIp
function HallManager:onRoleBaseChange()
	if self.mMyRole then
		self.mMyRole:setTitle(string.format("Lv.%s %s",tostring(globaldata:getPlayerBaseData("level")), tostring(globaldata:getPlayerBaseData("name"))), globaldata.partyName,globaldata.mytitleId)
    	self.mMyRole.mArmature.mViptitle:getChildByName("Label_PlayerLevelName_Stroke"):setColor(cc.c3b(76,255,80))
    	--self.mMyRole.mArmature:setVipTitle(globaldata:getPlayerBaseData("vipLevel"))
    	self.mMyRole.mArmature:setTitleData(globaldata.mytitleId)
	end
end

-- 销毁 -- 与load相对
function HallManager:Destroy()
	cclog("HallManager:Destroy")
	self.mHasLoaded = false
	self.mHasInitScene = false
	self:clearOPDataList()
	----
	GUIEventManager:unregister("battleTeamChanged", self.OnTeamMemberChanged)
	GUIEventManager:unregister("equipChanged", self.OnTeamMemberChanged)
	GUIEventManager:unregister("roleBaseInfoChanged", self.onRoleBaseChange)
	FightSystem:UnRegisterNotification("hall_myrolemove", "HallManager")
	FightSystem:UnRegisterNotification("hall_myrolestopmove", "HallManager")
	FightSystem:UnRegisterNotification("hall_anytouch", "HallManager")
	--
	-- if self.mPlace == _PLACE_.Home then
	-- 	self.mHomeSubManager:Destroy()
	-- end
	if self.mPlace == _PLACE_.Union then
		self.mUnionSubManager:Destroy()
	end
	self:unloadSceneAni()
	self:unloadTranspoint()
	self:unloadMyRole()
	self:unloadNPC()
	self:unloadAllOP()
	self:rmPlayerInfo()
	FightSystem.mSceneManager:UnloadSceneView()
	FightSystem:UnloadTouchPad()
end

function HallManager:Tick(delta)
	if not self.mHasInitScene then return end
	-- myrole
	self.mMyRole:Tick(delta)

	-- otherplayer
	for k,v in pairs(self.mOPList) do
		v:Tick(delta)
	end

	-- tp
	for k,v in pairs(self.mTranspointList) do
		v:Tick(delta)
	end

	-- npc
	for k,v in pairs(self.mNPCList) do
		v:Tick(delta)
	end

	-- touchpad
	FightSystem.mTouchPad:Tick(delta)

	--
	-- self.mHomeSubManager:Tick(delta)


	-- 监视我的位置
	self:monitorMyPos(delta)
end

-- 监视我的位置
function HallManager:monitorMyPos(delta)
	if self.mIsMyRoleStop then return end
	if self.mSyncMyPosInterval == _SYNCMYPOS_INTERVAL_ then 
	   self:updateMyPos()
	   self.mSyncMyPosInterval = 0
	return end
	self.mSyncMyPosInterval = self.mSyncMyPosInterval + 1
end

function HallManager:transferToCity(_cityID, _rolePos, _dir)
	local function unloadAll()
		self:unloadSceneAni()
		self:unloadTranspoint()
		self:unloadNPC()
		self:unloadAllOP()
		self:unloadMyRole()
	end
	unloadAll()
	-- init setting
	self.mCurCityID = _cityID
	self.mDB = DB_CityConfig.getDataById(self.mCurCityID)
	if not self.mDB then doError(string.format("Can not find DB, cityID ======= %d",_cityID)) end
	-- play bgm
	CommonAnimation.ChangeBGM(self.mDB.City_BGM)
	self.mLastBGMID = self.mDB.City_BGM
	-- 初始化具体场景
	if self.mDB.PublicMap == _PLACE_FLAG_.Town then
		self.mPlace = _PLACE_.Town
		self:initNormalScene(_rolePos, _dir)
	elseif self.mDB.PublicMap == _PLACE_FLAG_.Union then
		self.mPlace = _PLACE_.Union
		self:initUnionScene(_rolePos)
	else
		self.mPlace = _PLACE_.Home
	end
end

-- 初始化正常场景
function HallManager:initNormalScene(_rolePos, _dir)
	local _co = coroutine.create(function()
		self:loadScene()
		coroutine.yield()
		self:loadSceneAni()
		self:loadTranspoint()
		self:loadNPC(self.mScene)
		coroutine.yield()
		self:loadMyRole(self.mScene, _rolePos, _dir)
		self:loadOPsFromCache()
		coroutine.yield()
		hideLoadingWindow()
		self.mHasInitScene = true
	end)
	----- 开始协同
	local _handler = 0
	local function xxx()
		coroutine.resume(_co)
		if coroutine.status(_co) == "dead" then
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(_handler)
		end
	end
	_handler = nextTick_eachSecond(xxx, 0.03)
end

-- 特殊处理帮派的初始化
function HallManager:initUnionScene(_rolePos)
	local _co = coroutine.create(function()
		self:loadScene()
		coroutine.yield()
		self:loadNPC(self.mScene)
		self:loadMyRole(self.mScene, _rolePos, 1)
		coroutine.yield()
		self.mUnionSubManager:Load(self.mScene, _rolePos, self.mDB)
		self:loadOPsFromCache()
		coroutine.yield()
		hideLoadingWindow()
		self.mHasInitScene = true
	end)
	----- 开始协同
	local _handler = 0
	local function xxx()
		coroutine.resume(_co)
		if coroutine.status(_co) == "dead" then
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(_handler)
		end
	end
	_handler = nextTick_eachSecond(xxx, 0.03)
end

-- 载入场景
function HallManager:loadScene()
	FightSystem.mSceneManager:changeSceneView(self.mZOrder, self.mRoot, self.mDB.MapID,true)
	local _scene = FightSystem.mSceneManager:GetTiledLayer()
	self.mScene = _scene
end

-- 载入传送点
function HallManager:loadTranspoint()
	for i = 1,4 do
		local _srcpos = self.mDB[string.format("TransPoint%dMin", i)]
		local _srcsize = self.mDB[string.format("TransPoint%dMax", i)]
		local _cg = self.mDB[string.format("TransPoint%dCG", i)]
		local _id = self.mDB[string.format("TargetCity%dID", i)]
		local _pos = self.mDB[string.format("TargetCity%dPos", i)]
		if _id > 0 then
		   	local _tp = HallTranspoint.new(i, _srcpos, _srcsize, _cg, _id, _pos)
	        table.insert(self.mTranspointList, _tp)
	    else
	    	break
		end
	end
end

-- 载入NPC
function HallManager:loadNPC(_scene)
	for i = 1, 8 do
	    local _npcID = self.mDB[string.format("NPC%dID", i)]
	    local _npcPos = self.mDB[string.format("NPC%dPos", i)]
	    local _npcFunc = self.mDB[string.format("NPC%dFunction", i)]
	    local _npcVoice = self.mDB[string.format("NPC%dVoice", i)]
	    if _npcID > 0 then
	       local _npc = HallNPC.new(_npcID, _npcPos, _npcFunc, _npcVoice, _scene)
	       table.insert(self.mNPCList, _npc)
	   	else
	    	break
	    end
	end
end

-- 载入场景
function HallManager:loadSceneAni()
	if self.mDB.ControllerID <= 0 then return end
	local _dbController = DB_ControllerConfig.getDataById(self.mDB.ControllerID)
	local _table = {}
	for i = 1 ,_dbController.Controller_MonsterCount do
		local index = i
		local Controller_ID = string.format("Controller_ID%d",i)
		local Controller_Type = string.format("Controller_Type%d",i)
		local Controller_DelayTime = string.format("Controller_DelayTime%d",i)
		local Controller_PositionX = string.format("Controller_PositionX%d",i)
		local Controller_PositionY = string.format("Controller_PositionY%d",i)
		local monster = MonsterObject.new()

		monster.ID = _dbController[Controller_ID]
		monster.Type = _dbController[Controller_Type]
		if monster.Type == 1 then
			monsternum = monsternum + 1
		end	
		monster.DelayTime = _dbController[Controller_DelayTime]
		monster.PositionX = _dbController[Controller_PositionX]
		monster.PositionY = _dbController[Controller_PositionY]
		_table[monster] = monster
	end

	for k,item in pairs(_table) do
		FightSystem.mRoleManager:LoadSceneAnimation(item.ID,cc.p(item.PositionX,item.PositionY),nil,nil,true)
	end
end

function HallManager:unloadSceneAni()
	FightSystem.mRoleManager:unloadSceneAni()
end


function HallManager:unloadTranspoint()
	for k,v in pairs(self.mTranspointList) do
		v:Destroy()
	end
	self.mTranspointList = {}
end

function HallManager:unloadNPC()
	for k,v in pairs(self.mNPCList) do
		v:Destroy()
	end
	self.mNPCList = {}
end

function HallManager:loadMyRole(_root, _rolePos, _dir)
	local _heroID = globaldata:getHeroInfoByBattleIndex(globaldata.leaderHeroId, "id")
	local _rd = RoleData.new(0, "hallrole", _heroID, _rolePos)
	local _proplist = globaldata:getHeroInfoByBattleIndex(globaldata.leaderHeroId, "propList")
	-- _rd.mSpeed = _proplist[9] / 125
	self.mMyRole = FightRole.new(_rd)
	self.mMyRole:setSpineRenderType(cc.RENDER_TYPE_HERO)
	self.mMyRole.IsCityKeyRole = true
	local Equipsuccess = self.mMyRole:changeFashion(globaldata.fashionEquipList)
	-- 时装
	--[[
	local Dress = globaldata:getHeroInfoByBattleIndex(globaldata.leaderHeroId, "dress")
	if Dress then
		SpineDataCacheManager:collectFightSpineByAtlas(self.mMyRole.mArmature.mSpine)
		local dress = Dress
		local _resID = self.mMyRole.mRoleData.mSimpleModel
		local _resDB = DB_ResourceList.getDataById(_resID)
		local _atlas = _resDB.Res_path1
		local _atlas1 = string.format("%d.",dress.FashionDressIndex)
		_atlas = string.gsub(_atlas,"%.",_atlas1)
		self.mMyRole.mArmature.mAtlas = _atlas
		self.mMyRole.mArmature.mSpine = SpineDataCacheManager:getFightSpineByatlas(_resDB.Res_path2,_atlas,self.mMyRole.mRoleData.mSimpleModelScale,self.mMyRole.mArmature)
		self.mMyRole.mFSM:ChangeToState("idle")
	end
	self.mMyRole.mGunCon:UpdateDB(globaldata.leaderHeroId)
	local success = self.mMyRole:changeHorse(globaldata:getHeroInfoByBattleIndex(globaldata.leaderHeroId, "horse"))
	local Equipsuccess = nil
	if not success then
		Equipsuccess = self.mMyRole.mGunCon:EquipedGun()
	end
	]]
	self.mMyRole.mCityHall_IsMyRole = true
	for i=1,4 do
		local data = globaldata:getHeroInfoByBattleIndex(globaldata.leaderHeroId, "changecolor",i)
		ShaderManager:changeColorspineByData(self.mMyRole.mArmature.mSpine,data,globaldata.leaderHeroId)
	end
	if not Equipsuccess then
		if self.mMyRole.mRoleData.mInfoDB.relax ~= "" then
			self.mMyRole:InitHallRelax(self.mMyRole.mRoleData.mInfoDB.relax)
		end
	end
	self.mMyRole:AddToRoot(_root)
	self.mMyRole:setTitle(string.format("Lv.%s %s",tostring(globaldata:getPlayerBaseData("level")), tostring(globaldata:getPlayerBaseData("name"))), globaldata.partyName,globaldata.mytitleId)
    self.mMyRole.mArmature.mViptitle:getChildByName("Label_PlayerLevelName_Stroke"):setColor(cc.c3b(76,255,80))
    self.mMyRole.mArmature:setTitleData(globaldata.mytitleId)
	if _dir == 0 then
	   self.mMyRole:FaceLeft()
	else
	   self.mMyRole:FaceRight()
	end
	self.mLastPosMyRole = _rolePos
	self.mIsMyRoleStop = true

	if FightSystem.mTaskMainManager.mIsAutoFind then
		FightSystem.mTaskMainManager:AutoRoadCity()
	end
end

function HallManager:unloadMyRole()
	if not self.mMyRole then return end
	self.mMyRole:Destroy()
	self.mMyRole = nil
end

-------------------------------大场景专用-------------------------------------
-- 初始化其他玩家
function HallManager:loadOPsFromCache()
	local function loadRole(_heroid, _pos, _table)
		local _playerid = _table["playerid"]
		self.mHallRoleIDCounter = self.mHallRoleIDCounter + 1
		local _rd = RoleData.new(self.mHallRoleIDCounter, "hallrole", _heroid, _pos)
		_rd:setField("playerid", _playerid)
		_rd:setField("name", _table["name"])
		self:loadOP(_rd, _playerid, _table)
	end
	local co = coroutine.create(function()
					for _playerid,_table in pairs(self.mOPDataList) do
						local _op = nil
						if self.mOPList then
						   _op= self.mOPList[_playerid]
						end
						local _pos = cc.p(_table["posx"], _table["posy"])
						local _heroid = _table["heroid"]
						if not _op then
							loadRole(_heroid, _pos, _table)
						else
							--已存在，更新角色
							local curHeroID = _op.mRoleData.mInfoDB.ID
							local curHorseID = nil
							if _op.mHorse then
								curHorseID = _op.mHorse.mHorseID
							end
							local curWeapon = _op.mGunCon.mCurweaponId
							local serverHorseID = nil
							if _table["horse"] then
								serverHorseID = _table["horse"]
							end
							if curHeroID == _heroid and curHorseID == serverHorseID and (curHorseID or curWeapon == _table["weapon"]) then
								for i=1,4 do
									local data = _table.changeColorList[i]
									if data and data.colorType > 0 then
										ShaderManager:changeColorspineByData(_op.mArmature.mSpine,data,_op.mRoleData.mInfoDB.ID)
										_op:ResetHallrelaxTime()
									end
								end
								_op.mArmature:setTitleData(_table["title"])
							else
								_op:Destroy()
								self.mOPList[_playerid] = nil
								loadRole(_heroid, _pos, _table)
							end
						end
						coroutine.yield()
					end
			 	end)
	----- 开始协同
	local _handler = 0
	local function xxx()
		coroutine.resume(co)
		if coroutine.status(co) == "dead" then
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(_handler)
		end
	end
	_handler = nextTick_eachSecond(xxx, 0)
end

-- 加载其他玩家
function HallManager:loadOP(_rd, _playerid, _db)
	-- 限制oplist
	local function checkOPListLimited()
		local maxDisPlayerID = 0
		local maxDisX = 0
		local maxDisY = 0
		local myPos = self.mMyRole:getPosition_pos()
		if self.mOPListCount >= OPLIST_MAXCOUNT then return false end
		
		return true
	end
	if not checkOPListLimited() then return end
	-- 加载其他玩家到list
	local function loadOP_sub()
		local _op = FightRole.new(_rd)
		_op:setSpineRenderType(cc.RENDER_TYPE_HERO)
		local success = _op:changeFashionById(_db["horse"],_db["weapon"])
		--[[
		-- 时装
		if _db["dress"] then
			local dress = DB_EquipmentConfig.getDataById(_db["dress"])
			if dress.RoleLimit == _op.mRoleData.mInfoDB.ID then
				local _resID = _op.mRoleData.mSimpleModel
				local _resDB = DB_ResourceList.getDataById(_resID)
				local _atlas = _resDB.Res_path1
				local _atlas1 = string.format("%d.",dress.FashionDressIndex)
				_atlas = string.gsub(_atlas,"%.",_atlas1)
				_op.mArmature.mAtlas =  _atlas
				SpineDataCacheManager:collectFightSpineByAtlas(_op.mArmature.mSpine)
				_op.mArmature.mSpine = SpineDataCacheManager:getFightSpineByatlas(_resDB.Res_path2,_atlas,_op.mRoleData.mSimpleModelScale,_op.mArmature)
				_op.mFSM:ChangeToState("idle")
			end
		end
		-- 坐骑
		if _db["horse"] then
			local HorseID = DB_EquipmentConfig.getDataById(_db["horse"]).FashionHorseID
			success = _op:changeHorse(HorseID)
			if not success then
				if _db["weapon"] then
					_op.mGunCon:ShowRoleEquipedByGunId(_db["weapon"])
				end
			end
		else
			if _db["weapon"] then
				_op.mGunCon:ShowRoleEquipedByGunId(_db["weapon"])
			end
		end
		]]
		for i=1,4 do
			local data = _db.changeColorList[i]
			if data and data.colorType > 0 then
				ShaderManager:changeColorspineByData(_op.mArmature.mSpine,data,_op.mRoleData.mInfoDB.ID)
			end
		end
		-- 查看是否可以渲染该玩家
		self:checkRenderTheOP(_op)
		--
		_op:AddToRoot(self.mScene)
		self.mOPList[_playerid] = _op
		self.mOPListCount = self.mOPListCount + 1
		self.mOPDataList[_playerid] = nil
		if not success then
			if _op.mRoleData.mInfoDB.relax ~= "" then
				_op:InitHallRelax(_op.mRoleData.mInfoDB.relax)
			end
		end
		_op:setTitle(string.format("Lv.%s %s",_db["level"], _db["name"]), string.format("%s", _db["allianname"]),_db["title"])
	    _op.mArmature:setTitleData(_db["title"])
	    -- 朝向
		if _db["dir"] == 0 then
			_op:FaceLeft()
		else
			_op:FaceRight()
		end
		--
		_op:addTouchRegion(handler(self, self.OnOPCliked))
	end
	loadOP_sub()
end

-- 清空OP数据表
function HallManager:clearOPDataList()
	self.mOPDataList = {}
end

-- 卸载其他玩家
function HallManager:unloadOP(_playerid)
	local _op = self.mOPList[_playerid]
	if not _op then return end
	_op:Destroy()
	self.mOPList[_playerid] = nil
	self.mOPListCount = self.mOPListCount - 1
	cclog(string.format("HallManager:unloadOP==playerid: %s",_playerid))
end

-- 卸载所有其他玩家
function HallManager:unloadAllOP()
	if not self.mOPList then return end
	for k,v in pairs(self.mOPList) do
		v:Destroy()
	end
	self.mOPList = {}
	self.mOPListCount = 0
end

-- 查看是否渲染所有其他玩家
function HallManager:checkRenderAllOP()
	local enabled = not FightSystem:isEnabledSheildOP()
	for k,op in pairs(self.mOPList) do
		op:enableRender(enabled)
	end
end

-- 查看该玩家是否可以渲染
function HallManager:checkRenderTheOP(op)
	local enabled = not FightSystem:isEnabledSheildOP()
	op:enableRender(enabled)
end

-- 清空op数据表和清除在线玩家节点
function HallManager:clearOPDataListAndUnloadAllOP()
	self:clearOPDataList()
	self:unloadAllOP()
end
-------------------------------------------------------------------------------

-- 发送自己的坐标给服务器
function HallManager:sendMyPosToServer(_pos, _dir)
	local packet = NetSystem.mNetManager:GetSPacket()
	packet:SetType(PacketTyper._PTYPE_CS_CITYHALL_MYPOS)
	packet:PushShort(_pos.x)
	packet:PushShort(_pos.y)
	packet:PushChar(_dir)
	packet:Send()
end

-- 更新我的坐标和方向（0：左边 1：右边）
function HallManager:updateMyPos()
	if not self.mMyRole then return end
	local _pos = self.mMyRole:getPosition_pos()
	local _dir = 1
	if self.mMyRole.IsFaceLeft then
	   _dir = 0
	end
	globaldata:setCityHallData("posx", _pos.x)
	globaldata:setCityHallData("posy", _pos.y)
	if self.mPlace == _PLACE_.Town or self.mPlace == _PLACE_.Union then
		self:sendMyPosToServer(_pos, _dir)
	end
end

-- show 其他玩家菜单
function HallManager:showOPMenu(_op)
	globaldata.menupos = cc.p(_op:getPositionX(),_op:getPositionY())
	--FightSystem:PushNotification("hall_anytouch")
	local packet = NetSystem.mNetManager:GetSPacket()
	packet:SetType(PacketTyper._PTYPE_CS_REQUEST_PLAYER_INFO_)
	packet:PushString(_op.mRoleData.playerid)
	packet:Send()
	globaldata.requestType = "hallcity"
	GUISystem:showLoading()
end

--
function HallManager:getMyRole()
	return self.mMyRole
end

-- 移除玩家信息框
function HallManager:rmPlayerInfo()
	if self.mPlayerInfo then
		self.mPlayerInfo:removeFromParent() 
		self.mPlayerInfo = nil
	end
end

function HallManager:PlayerInfoTouch()
	self:rmPlayerInfo()
end

-- 显示当前玩家信息
function HallManager:ShowPlayInfo(data,_pos)
	self:rmPlayerInfo()
	self.mPlayerInfo = CheckPlayerInfo.new(data)
	-- local tilpos = _pos.x + FightSystem.mSceneManager:GetTiledLayer():getPositionX()
	-- local x = getGoldFightPosition_LU().x + ( _pos.x + FightSystem.mSceneManager:GetTiledLayer():getPositionX())
 --    local y =  _pos.y + getGoldFightPosition_LD().y
 --    local pos = cc.p(x,y)
	-- if tilpos < getGoldFightPosition_Middle().x then
	-- 	self.mPlayerInfo:setPosition(cc.p(pos.x, pos.y+100))
	-- else
	-- 	self.mPlayerInfo:setPosition(cc.p(pos.x-self.mPlayerInfo.mWidth, pos.y+100))
	-- end
	--local width = self.mPlayerInfo.mRootWidget:getBoundingBox().width
	--local height = self.mPlayerInfo.mRootWidget:getBoundingBox().height
	--self.mPlayerInfo:setPosition(cc.p(getGoldFightPosition_Middle().x -width/2,getGoldFightPosition_Middle().y - height/2) )

	if self.mPlace == _PLACE_.Town then
	   GUISystem.Windows["HomeWindow"].mRootNode:addChild(self.mPlayerInfo,2000)
	elseif self.mPlace == _PLACE_.Union then
	   GUISystem.Windows["UnionHallWindow"].mRootNode:addChild(self.mPlayerInfo,2000)
	end

	registerWidgetReleaseUpEvent(self.mPlayerInfo.mRootWidget:getChildByName("Panel_20"), handler(self, self.PlayerInfoTouch))
	

end

-----------------------------------回调-----------------------------
-- 服务器回包了，准备进入城镇
function HallManager:OnPreEnterCity(_cityid)
	local cityDB = DB_CityConfig.getDataById(_cityid)
	if not cityDB then
	   G_ErrorReport(string.format("HallManager:OnPreEnterCity,can not find citydb,cityid: %d", _cityid))
	   _cityid = 1
	   cityDB = DB_CityConfig.getDataById(_cityid)
	end 
	globaldata:setCityHallData("cityid", _cityid)
	if cityDB.PublicMap == _PLACE_FLAG_.Town then
		EventSystem:PushEvent(Event.GUISYSTEM_SHOW_HOMEWINDOW)
	elseif cityDB.PublicMap == _PLACE_FLAG_.Union then
		EventSystem:PushEvent(Event.GUISYSTEM_SHOW_UNIONHALLWINDOW)
	end
	if globaldata.showguanqialayer then
		globaldata.showguanqialayer = false
		local function xxx()
			GUISystem:CanCelBlackShowPvelayout()
		end
		nextTick_eachSecond(xxx,0.5)
	end
end


-- 成员更换回调
function HallManager:OnTeamMemberChanged(_isLeader, _index)
	if not self.mMyRole then return end
	local _pos = self.mMyRole:getPosition_pos()
	local function changeleader()
		self:unloadMyRole()
		self:loadMyRole(self.mScene, _pos)
	end
	changeleader()
	-- if self.mPlace == _PLACE_.Home then
	-- 	self.mHomeSubManager:changeMyTeamMembers(self.mScene, _pos)
	-- end
end

-- 成员换染色
function HallManager:OnMyRoleChangedColor(data)
	if not self.mMyRole then return end
	self.mMyRole:ResetHallrelaxTime()
	ShaderManager:changeColorspineByData(self.mMyRole.mArmature.mSpine,data,globaldata.leaderHeroId)
end

-- 成员重置染色
function HallManager:OnMyRoleResetColor(part)
	if not self.mMyRole then return end
	ShaderManager:ResumeColor_spine(self.mMyRole.mArmature.mSpine,part)
end

-- 将其他玩家信息载入缓存
function HallManager:insertOPList(msgPacket)
	local _cnt = msgPacket:GetUShort()
	for i = 1,_cnt do
		local _playerid = msgPacket:GetString()
		local _heroid = msgPacket:GetInt()
		local _level = msgPacket:GetUShort()
		local _viplv = msgPacket:GetChar()
		local _title = msgPacket:GetInt()
		local _name = msgPacket:GetString()
		local _allianname = msgPacket:GetString()
		local _posx = msgPacket:GetUShort()
		local _posy = msgPacket:GetUShort()
		local _dir = msgPacket:GetChar()
		local _table = {
				["playerid"] = _playerid,
                ["heroid"] = _heroid,
                ["level"] = _level,
                ["vipLevel"] = _viplv,
                ["title"] = _title,
                ["name"] = _name,
                ["allianname"] = _allianname,
                ["posx"] = _posx,
                ["posy"] = _posy,
                ["dir"] = _dir,
            }
	    local fashionEquipNum = msgPacket:GetChar()
	    for ii=1,fashionEquipNum do
			local equipType = msgPacket:GetChar()
			local equipId = msgPacket:GetInt()
			if equipType == 2 then
				_table["weapon"] = equipId
			elseif equipType == 1 then
				_table["horse"] = equipId
			end
		end
		_table.changeColorCount = msgPacket:GetUShort()
		_table.changeColorList = {}
		for i=1,_table.changeColorCount do
			local Colordata = {}
			Colordata.partType = msgPacket:GetChar()
			Colordata.colorType = msgPacket:GetChar()
			if Colordata.colorType > 0 then
				Colordata.colorArrCount = msgPacket:GetUShort()
				Colordata.colorArr = {}
				for i=1,Colordata.colorArrCount do
					Colordata.colorArr[i] = msgPacket:GetUShort()
				end
			end
			_table.changeColorList[i] = Colordata
		end
		-- 筛除自己
		if _playerid ~= globaldata.playerId then
			self.mOPDataList[_playerid] = _table
		end
	end
end

-- 从oplist中移除
function HallManager:removeOPFromList(msgPacket)
	local _cnt = msgPacket:GetUShort()
	for i = 1,_cnt do
		local _playerid = msgPacket:GetString()
		self.mOPDataList[_playerid] = nil
	end
end

-- 玩家进入视野:1203
function HallManager:OnOPEnterView(msgPacket)
	self:insertOPList(msgPacket)
	if self.mHasLoaded then
	   self:loadOPsFromCache()
	end
end

-- 玩家离开视野:1205
function HallManager:OnOPLeftView(msgPacket)
	if self.mHasLoaded then
		local _cnt = msgPacket:GetUShort()
		for i = 1,_cnt do
			local _playerid = msgPacket:GetString()
			self:unloadOP(_playerid)
		end
	else
		self:removeOPFromList(msgPacket)
	end
end

-- 其他玩家移动:1201
function HallManager:OnOPMove(msgPacket)
	if not self.mHasLoaded then return end
	local _playerid = msgPacket:GetString()
	local _op = self.mOPList[_playerid]
	if not _op then return end
	local _posx = msgPacket:GetUShort()
	local _posy = msgPacket:GetUShort()
	local _dir = msgPacket:GetChar()
	-- 处理方向
	if _dir == 0 then
	   _op:FaceLeft()
	else
	   _op:FaceRight()
	end
	---处理移动
	local dis = cc.pGetDistance(cc.p(self.mMyRole:getPositionX(),self.mMyRole:getPositionY()),cc.p(_posx,_posy))
	local function handleBeyondDis()
		self:unloadOP(_playerid)
	end
	-- 终点超出与主角最大距离则移动完移除
	if dis >= OP_MAX_DIS then
	   _op:WalkingByPos(cc.p(_posx, _posy), handleBeyondDis)
	elseif dis > 20 then
		_op:WalkingByPos(cc.p(_posx, _posy))
	end
end

-- 我的队长移动了
function HallManager:OnMyRoleMove()
	self.mIsMyRoleStop = false
	local myPos = self.mMyRole:getPosition_pos()
	FightSystem.mTouchPad:setMyRolePosDisplay(myPos)
end

-- 我的队长停止移动
function HallManager:OnMyRoleStopMove()
	local function isFaceOP(faceleft_me, posX_me,posX_op)
		local dis = posX_op - posX_me
		if dis > 0 and not faceleft_me then
		   return true
		elseif dis < 0 and faceleft_me then
		   return true
		else
		   return false
		end 
	end
	if not self.mIsMyRoleStop then
		self:updateMyPos()
		self.mIsMyRoleStop = true
		---检查我移动后其他玩家超出最大距离移除
		local myPosX = self.mMyRole:getPositionX()
		local myPosY = self.mMyRole:getPositionY()	
		for playerid, op in pairs(self.mOPList) do
			local dis = cc.pGetDistance(cc.p(myPosX, myPosY),cc.p(op:getPositionX(), op:getPositionY()))
			if dis >= OP_MAX_DIS and not isFaceOP(self.mMyRole.IsFaceLeft, myPosX, op:getPositionX()) then
			   self:unloadOP(playerid)
			end
		end
	end
end

-- 空白区域被触摸
function HallManager:OnAnyRegionTouched()
	
end

-- 其他玩家被点击了
function HallManager:OnOPCliked(_widget, _pushorrelease, _op)
    if _pushorrelease == 1 then
      -- 按下
      if FightSystem.mTouchPad.mBeganFlag then
          self.TouchFlag = true
      end
     elseif _pushorrelease == 2 then
      -- 抬起
      if self.TouchFlag then 
        self.TouchFlag = false 
        return 
      end
      --
      self:showOPMenu(_op)
    end
end