-- Name: FightSystem
-- Func: 战斗系统
-- Author: Johny


require "FightSystem/FCmdParseSystem"
require "FightSystem/Pad/CityHallTouchPad"
require "FightSystem/Pad/FightTouchPad2"
require "FightSystem/FightConfig"
require "FightSystem/MathExt"
require "FightSystem/Role/RoleManager"
require "FightSystem/Role/SpineShadowRenderManager"
require "FightSystem/Scene/FightSceneManager"
require "FightSystem/Scene/ShowSceneManager"
require "FightSystem/Role/SkillGroup/CommonSkill"
require "FightSystem/CityHall/HallManager"
require "FightSystem/Fuben/FubenManager"
require "FightSystem/Pvp/PvpArenaManager"
require "FightSystem/OnlinePvp/OnlinePvpManager"



-- Class
FightSystem = {}
FightSystem.mType = "FIGHTSYSTEM"

------------------------本地变量------------------------------
local  _FIGHT_DB_KEY_SHEILDOP_  = "_FIGHT_DB_KEY_SHEILDOP_"
local  _FIGHT_DB_KEY_ADVANCDEJOYSTICK_  = "_FIGHT_DB_KEY_ADVANCDEJOYSTICK_"

local  _FIGHT_DB_KEY_FUBENAUTO_ 		 = "_FIGHT_DB_KEY_FUBENAUTO_"
local  _FIGHT_DB_KEY_CHUANGGUANAUTO_ 	 = "_FIGHT_DB_KEY_CHUANGGUANAUTO_"
local  _FIGHT_DB_KEY_PATAAUTO_ 			 = "_FIGHT_DB_KEY_PATAAUTO_"
local  _FIGHT_DB_KEY_FANGKESHIJIANAUTO_  = "_FIGHT_DB_KEY_FANGKESHIJIANAUTO_"
local  _FIGHT_DB_KEY_HEISHIAUTO_ 		 = "_FIGHT_DB_KEY_HEISHIAUTO_"
local  _FIGHT_DB_KEY_BOSSAUTO_ 			 = "_FIGHT_DB_KEY_BOSSAUTO_"
local  _FIGHT_DB_KEY_WUDAOGUANAUTO_ 	 = "_FIGHT_DB_KEY_WUDAOGUANAUTO_"

local  _FIGHT_DB_KEY_GAMEPERFORMANCE_ 	 = "_FIGHT_DB_KEY_GAMEPERFORMANCE_"

local  _FIGHT_DB_KEY_SHOWGUANQIA_ 	 = "_FIGHT_DB_KEY_SHOWGUANQIA_"




-- 城镇管理器
FightSystem.mHallManager = HallManager

-- 副本管理器
FightSystem.mFubenManager = nil
-- PVP管理器
FightSystem.mPvpArenaManager = nil
-- OLPVP管理器
FightSystem.mOnlinePvpManager = nil
-- 主线任务
FightSystem.mTaskMainManager = nil

FightSystem.mTouchPad = nil
FightSystem.mAstarTickNum = 0

-- 记录是否为重新加载战斗
FightSystem.mIsReFight = false

-- 记录战斗场景ID List
FightSystem.mAISceneIDlist = {}

function FightSystem:Init()
	self.mHasInitAll = false
	--是否启动spine渲染
	EngineSystem:closeSpineRender(FightConfig.__DEBUG_CLOSELOAD_SPINE_)
	---
	self.mStatus = "pause"
	self.mFightType = "none"
	--
	self.mSpineAgent = SpineAgent:GetLuaInstance()
	self.mSpineAgent:RegisterLuaHandler(handler(self, self.onSpineActionEvent))
end

function FightSystem:init2()
	--性能是否优化
	globaldata.gameperformance = self:isEnabledGameperformance()
	self.mHasInitAll = true
	self.mSceneManager = FightSceneManager
	self.mSceneManager:Init()
	self.mShowSceneManager = ShowSceneManager
	self.mShowSceneManager:Init()
	self.mRoleManager = RoleManager
	self.mRoleManager:Init()
	self.mSpineShadowRenderManager = SpineShadowRenderManager
	self.mSpineShadowRenderManager:init()
	--
	self.mHallManager:init()

    -- 静止帧，唯一
	self.mStaticFrameTime = 0
	self.mStaticFrameTimeApplicant = nil
	-- 战斗结束
	self.mIsWithinFightFinish = false


	self.mNotifactionList = {}

	----
	self.mFubenManager = FubenManager
	self.mPvpArenaManager = PvpArenaManager
	self.mOnlinePvpManager = OnlinePvpManager
	self.mTaskMainManager = require "FightSystem/TaskMain/TaskMainManager"
end

function FightSystem:Release()
	if not self.mSceneManager then return end
	self.mSceneManager:Release()
	self.mShowSceneManager:Release()
	self.mRoleManager:Release()
	self.mSpineShadowRenderManager:destroy()
	SpineAgent:FreeInstance()
	--
	_G["FightSystem"] = nil
  	package.loaded["FightSystem"] = nil
  	package.loaded["FightSystem/FightSystem"] = nil
end
--------------------------------------------------------------
-- 是否开启屏蔽其他玩家
function FightSystem:isEnabledSheildOP()
	return DBSystem:Get_Boolean_FromSandBox(_FIGHT_DB_KEY_SHEILDOP_)
end

-- 开启屏蔽其他玩家
function FightSystem:enabledSheildOP(enabled)
	DBSystem:Save_Boolean_ToSandBox(_FIGHT_DB_KEY_SHEILDOP_, enabled)
end
------------------------------------------------------------------
-- 是否启用高级摇杆
function FightSystem:isEnabledAdvancedJoystick()
	return DBSystem:Get_Boolean_FromSandBox(_FIGHT_DB_KEY_ADVANCDEJOYSTICK_)
end

-- 启用高级摇杆
function FightSystem:enableAdvancedJoystick(enabled)
	DBSystem:Save_Boolean_ToSandBox(_FIGHT_DB_KEY_ADVANCDEJOYSTICK_, enabled)
end

---------------------------------------------------------------
-- 副本自动战斗战斗
function FightSystem:isEnabledFubenAuto()
	local key = string.format("%s%s",globaldata.playerId,_FIGHT_DB_KEY_FUBENAUTO_)
	return DBSystem:Get_Boolean_FromSandBox(key)
end

-- 闯关自动战斗战斗
function FightSystem:isEnabledChuangGuanAuto()
	local key = string.format("%s%s",globaldata.playerId,_FIGHT_DB_KEY_CHUANGGUANAUTO_)
	return DBSystem:Get_Boolean_FromSandBox(key)
end

-- 爬塔自动战斗战斗
function FightSystem:isEnabledPataAuto()
	local key = string.format("%s%s",globaldata.playerId,_FIGHT_DB_KEY_PATAAUTO_)
	return DBSystem:Get_Boolean_FromSandBox(key)
end

-- 放课时间自动战斗战斗
function FightSystem:isEnabledFangkeAuto()
	local key = string.format("%s%s",globaldata.playerId,_FIGHT_DB_KEY_FANGKESHIJIANAUTO_)
	return DBSystem:Get_Boolean_FromSandBox(key)
end

-- 黑市委托自动战斗战斗
function FightSystem:isEnabledHeishiAuto()
	local key = string.format("%s%s",globaldata.playerId,_FIGHT_DB_KEY_HEISHIAUTO_)
	return DBSystem:Get_Boolean_FromSandBox(key)
end

-- 世界boss自动战斗战斗
function FightSystem:isEnabledBossAuto()
	local key = string.format("%s%s",globaldata.playerId,_FIGHT_DB_KEY_BOSSAUTO_)
	return DBSystem:Get_Boolean_FromSandBox(key)
end

-- 武道馆自动战斗战斗
function FightSystem:isEnabledWudaoguanAuto()
	local key = string.format("%s%s",globaldata.playerId,_FIGHT_DB_KEY_WUDAOGUANAUTO_)
	return DBSystem:Get_Boolean_FromSandBox(key)
end

-- 副本自动战斗保存
function FightSystem:enableFubenAuto(enabled)
	local key = string.format("%s%s",globaldata.playerId,_FIGHT_DB_KEY_FUBENAUTO_)
	DBSystem:Save_Boolean_ToSandBox(key, enabled)
end

-- 闯关自动战斗保存
function FightSystem:enableChuangGuanAuto(enabled)
	local key = string.format("%s%s",globaldata.playerId,_FIGHT_DB_KEY_CHUANGGUANAUTO_)
	DBSystem:Save_Boolean_ToSandBox(key, enabled)
end

-- 爬塔自动战斗保存
function FightSystem:enablePataAuto(enabled)
	local key = string.format("%s%s",globaldata.playerId,_FIGHT_DB_KEY_PATAAUTO_)
	DBSystem:Save_Boolean_ToSandBox(key, enabled)
end

-- 放课时间自动战斗保存
function FightSystem:enableFangkeAuto(enabled)
	local key = string.format("%s%s",globaldata.playerId,_FIGHT_DB_KEY_FANGKESHIJIANAUTO_)
	DBSystem:Save_Boolean_ToSandBox(key, enabled)
end

-- 黑市委托自动战斗保存
function FightSystem:enableHeishiAuto(enabled)
	local key = string.format("%s%s",globaldata.playerId,_FIGHT_DB_KEY_HEISHIAUTO_)
	DBSystem:Save_Boolean_ToSandBox(key, enabled)
end

-- 世界boss自动战斗保存
function FightSystem:enableBossAuto(enabled)
	local key = string.format("%s%s",globaldata.playerId,_FIGHT_DB_KEY_BOSSAUTO_)
	DBSystem:Save_Boolean_ToSandBox(key, enabled)
end

-- 武道馆自动战斗保存
function FightSystem:enableWudaoguanAuto(enabled)
	local key = string.format("%s%s",globaldata.playerId,_FIGHT_DB_KEY_WUDAOGUANAUTO_)
	DBSystem:Save_Boolean_ToSandBox(key, enabled)
end
---------------------------------------------------------------
-- 本地展示关卡
function FightSystem:isEnabledShowGuanqia()
	local key = string.format("%s%s",globaldata.playerId,_FIGHT_DB_KEY_SHOWGUANQIA_)
	return DBSystem:Get_Boolean_FromSandBox(key)
end

function FightSystem:enableShowGuanqia(enabled)
	local key = string.format("%s%s",globaldata.playerId,_FIGHT_DB_KEY_SHOWGUANQIA_)
	DBSystem:Save_Boolean_ToSandBox(key, enabled)
end

---------------------------------------------------------------
-- 性能优化
function FightSystem:isEnabledGameperformance()
	local key = string.format("%s%s",globaldata.playerId,_FIGHT_DB_KEY_GAMEPERFORMANCE_)
	return DBSystem:Get_Boolean_FromSandBox(key)
end

function FightSystem:enableGameperformance(enabled)
	local key = string.format("%s%s",globaldata.playerId,_FIGHT_DB_KEY_GAMEPERFORMANCE_)
	DBSystem:Save_Boolean_ToSandBox(key, enabled)
	globaldata.gameperformance = enabled
end

---------------------------------------------------------------
-- 输出内存中骨骼数据信息
function FightSystem:logCachedSpineDataInfo()
	cclog(self.mSpineAgent:getSpineDataCachedInfo())
end

-- 获取色相4维矩阵
function FightSystem:getHueMat4(_hue)
	return self.mSpineAgent:getHueMat4(_hue)
end

-- 获取当前keyrole
function FightSystem:GetKeyRole(_IsCamera)
	if self.mStatus == "runing" then
	   return self.mRoleManager:GetKeyRole(_IsCamera)
	elseif self.mStatus == "runing_hall" then
	   return self.mHallManager.mMyRole
	end

	return nil
end

-- 是否处于城镇大厅
function FightSystem:isInCityHall()
	return self.mStatus == "runing_hall"
end

-- 请求更换场景
function FightSystem:sendChangeCity(_cityID,callFun)
	if not _cityID then _cityID = globaldata:getCityHallData("cityid") end
	if callFun then
		globaldata.CityCallFun = callFun
	end
	local packet = NetSystem.mNetManager:GetSPacket()
	packet:SetType(PacketTyper._PTYPE_CS_CITYHALL_CHANGECITY)
	packet:PushInt(_cityID)
	packet:Send()
	GUISystem:showLoading()
end

-- 载入副本管理器
function FightSystem:Load(rootNode, _data)
	self.mStatus = "runing"
	self.misVictory = false
	-- load fuben
	self.mFightType = _data.mType
	if _data.mType == "fuben" then
		self.mFubenManager:Init(rootNode,_data.mHard,_data.mPveLevel)
	elseif _data.mType == "arena" then
		self.mPvpArenaManager:Init( rootNode)
	elseif _data.mType == "olpvp" then
		self.mOnlinePvpManager:Init( rootNode)
	end
	-- debug 游戏速度
	self:debugGameSpeedScale()
end

function FightSystem:debugGameSpeedScale()
	if not FightConfig.__DEBUG_FIGHT_DIRECTOR_TIMESCALE then return end
	self:setGameSpeedScale(FightConfig.__DEBUG_FIGHT_DIRECTOR_TIMESCALE)
end

-- 获得当前管理器
function FightSystem:GetFightManager()
	if self.mStatus == "runing" or self.mStatus == "pause" then
	   if self.mFightType == "fuben" then
			return self.mFubenManager
		elseif self.mFightType == "arena" then
			return self.mPvpArenaManager
		elseif self.mFightType == "olpvp" then
			return self.mOnlinePvpManager
		end
	elseif self.mStatus == "runing_hall" then
	   return self.mHallManager
	end
end

-- 获得当前模式
function FightSystem:GetModelByType(_type)
	if self.mFightType == "fuben" then
		return self.mFubenManager:isTypeModel(_type)
	end	
	return false
end

-- 卸载副本管理器
function FightSystem:Unload()
	self.mStatus = "pause"
	self.mIsWithinFightFinish = nil
	self.mTickCount = nil
	self.mCurFrame = nil
	self.mFightFinishSlowDuring = nil
	self:cancelStaticFrameTime()
	self:setGameSpeedScale(1)
	-- 销毁role
	self.mRoleManager:UnloadRoles()
	-- 销毁场景动画
	self.mRoleManager:unloadSceneAni()
	-- 销毁场景
	self.mSceneManager:UnloadSceneView()
	-- 销毁展示场景
	self.mShowSceneManager:UnloadSceneView()
	-- unload fuben
	self:GetFightManager():Destroy()
	self.mAISceneIDlist = {}	
end

-- 载入城镇管理器
function FightSystem:LoadCityHall(_root, _zorder)
	self.mStatus = "runing_hall"
	self.mHallManager:Load(_root, _zorder)
end

-- 卸载城镇管理器
function FightSystem:UnloadCityHall()
	self.mStatus = "pause"
	self.mHallManager:Destroy()
end

-- Display TouchPad
function FightSystem:LoadTouchPad(zorder, rootNode,time)
  	self.mTouchPad = FightTouchPad2.new()
  	self.mTouchPad:Init(zorder, self:GetKeyRole(),time)
  	rootNode:addChild(self.mTouchPad)
end

-- 卸载Touchpad
function FightSystem:UnloadTouchPad()
	self.mTouchPad:Destroy()
	self.mTouchPad = nil
end

-- load cityhall touchpad
-- 只有方向键
function FightSystem:LoadSimpleTouchPad(_zorder, _root)
	self.mTouchPad = CityHallTouchPad.new()
  	self.mTouchPad:Init(_zorder)
  	_root:addChild(self.mTouchPad)
end

function FightSystem:Tick(delta)
	if not self.mHasInitAll then return end
	-- self.mSpineAgent:Tick()
	local function xxx()
		if self.mStatus == "runing" then
			self:TickAstarNum(delta)
			self.mRoleManager:Tick(delta)
			self.mSceneManager:Tick(delta)
			-- -- 检查静止帧
			self:TickStaticFrameTime()
			-- -- 检查战斗结束
			self:TickFightFinish()
			-- --
			self:GetFightManager():Tick(delta)
	    end
	    --
	    if self.mStatus == "runing_hall" then
	       self.mHallManager:Tick(delta)
	       self.mSceneManager:Tick(delta)
	    end
	    --
	    self.mShowSceneManager:Tick(delta)
	    self.mSpineShadowRenderManager:Tick()
	end
	caculateFuncDuring("FightSystem:Tick", xxx)
end

--
function FightSystem:TickStaticFrameTime()
	if self.mStaticFrameTime > 0 then
		self.mStaticFrameTime = self.mStaticFrameTime - 1
		if self.mStaticFrameTime == 0 then
			self.mStaticFrameTimeApplicant:finishFullScreenStatic()
			self.mStaticFrameTimeApplicant = nil
		end
	end
end

function FightSystem:TickAstarNum()
	if self.mAstarTickNum >30 then
		self.mAstarTickNum = 0
	else
		self.mAstarTickNum = self.mAstarTickNum + 1
	end	
end
--
function FightSystem:TickFightFinish()
	if not self.mIsWithinFightFinish then return end
	--
	if self.mFightFinishSlowDuring > 0 then
	    self.mFightFinishSlowDuring = self.mFightFinishSlowDuring -1
	else
		self.mTickCount = self.mTickCount + 1
		if self.mTickCount % 2 == 0 then
		   -- cclog("战斗读帧==" .. self.mTickCount)
	   	   self.mCurFrame = self.mCurFrame + 1
	   	   -- cclog("战斗读帧==当前帧===" .. self.mCurFrame)
	   	 --  doError(string.format("AAA=%f=",self.mCurFrame/30))
	   	   cc.Director:getInstance():getScheduler():setTimeScale(self.mCurFrame/30)
	   	   if self.mCurFrame == 30 then
	   	   	  cclog("战斗慢动作结束")
	   	   	  self.mIsWithinFightFinish = false
	   	   	  FightSystem.mSceneManager.mCamera:ZoominPoseback(0.1)
	   	   	  self.mRoleManager:playVictory()
	   	   end
		end
	end
end


-- 申请全屏静止，申请者不受影响
function FightSystem:ApplyStaticFrameTime(_during, _applicant)
	if self.mStaticFrameTime == 0 then
		-- cclog("Warning:   FightSystem:EnableStaticFrameTime=====已有人申请静止帧===== " .. _during)
		_applicant.mStaticFrameTime_Unlock = true
		self.mStaticFrameTime = _during
		self.mStaticFrameTimeApplicant = _applicant
		FightSystem.mRoleManager:StopEachSpineTick(true)
		FightSystem.mRoleManager:pauseAllActions()
	end
end

-- 取消静止帧
function FightSystem:cancelStaticFrameTime()
	self.mStaticFrameTime = 0
	if self.mStaticFrameTimeApplicant then
		self.mStaticFrameTimeApplicant:finishFullScreenStatic()
		self.mStaticFrameTimeApplicant = nil
	end
end

-- 查看静止帧状态
function FightSystem:IsWithinStaticFrameTime()
	return self.mStaticFrameTime > 0
end


-- 检查是否为最后一个怪物死亡
function FightSystem:LastMonsterKilled(_role)
	if self:GetFightManager():GetSlowmotion(_role) and self:GetFightManager():GetSlowmotion(_role) == 1 then
		local group = _role.mGroup
		if FightSystem.mFightType == "arena" and globaldata.PvpType == "arena" then
			self:GetFightManager().mFinishTick = true
			self:SetFightFinishSlow()
		else
			if FightSystem:GetFightManager().mResult then return end
			local  function CallBack()
				FightSystem.mRoleManager:StopEachSpineTick(false)
				if group == "monster" or group == "enemyplayer" then
					FightSystem.mRoleManager:removeAllFlyEnemy()
				end
				self:GetFightManager().mFinishTick = true
				self:SetFightFinishSlow()
			end
			if _role.mGroup == "monster" or _role.mGroup == "enemyplayer" then
				FightSystem.mSceneManager.mCamera:UpdateCameraForKeyRole(cc.p(_role:getPositionX(),_role:getPositionY()),_role.IsFaceLeft)
				local actionTo1 = cc.DelayTime:create(FightConfig.CAMERA_SPEED)
	      	    local actionTo2 = cc.CallFunc:create(CallBack)
				FightSystem.mSceneManager:GetSceneView():runAction(cc.Sequence:create(actionTo1,actionTo2))
				FightSystem.mRoleManager.keyRoleTempId.id = _role.mInstanceID
				FightSystem.mRoleManager.keyRoleTempId.group = _role.mGroup
				if not FightSystem:GetFightManager().mResult then
					GUISystem:disableUserInput()
				end
			elseif _role.mGroup == "friend" then
				FightSystem.mSceneManager.mCamera:UpdateCameraForKeyRole(cc.p(_role:getPositionX(),_role:getPositionY()),_role.IsFaceLeft)
				local actionTo1 = cc.DelayTime:create(FightConfig.CAMERA_SPEED)
	      	    local actionTo2 = cc.CallFunc:create(CallBack)
				FightSystem.mSceneManager:GetSceneView():runAction(cc.Sequence:create(actionTo1,actionTo2))
				FightSystem.mRoleManager.keyRoleTempId.id = _role.mInstanceID
				FightSystem.mRoleManager.keyRoleTempId.group = _role.mGroup
				if not FightSystem:GetFightManager().mResult then
					GUISystem:disableUserInput()
				end
			end
		end
	end
end

-- 启动战斗结束慢动作
function FightSystem:SetFightFinishSlow()
	self.mIsWithinFightFinish = true
	self.mTickCount = 0
	self.mCurFrame = 3
	self.mFightFinishSlowDuring = 45
	--doError(string.format("BBB=%f=",self.mCurFrame/30))
	self:setGameSpeedScale(self.mCurFrame/30)
end

-- 设置游戏的速度
function FightSystem:setGameSpeedScale(_scale)
	cc.Director:getInstance():getScheduler():setTimeScale(_scale)
end

-- 获取当前游戏速度
function FightSystem:getGameSpeedScale()
	return cc.Director:getInstance():getScheduler():getTimeScale()
end

-- 获得TildemapProperty
function FightSystem:getMapInfo(pos,_sceneindex)
	local _tiledX = math.floor(pos.x/10)
	local _tiledY = math.floor(pos.y/10)
	return self.mSceneManager:GetTiledLayer(_sceneindex).mTiledMap:getPropertyByGiledPos(_tiledX,_tiledY)
end

-- TildemapPos
function FightSystem:getMapInfoByTildepos(pos,_sceneindex)
	return self.mSceneManager:GetTiledLayer(_sceneindex).mTiledMap:getPropertyByGiledPos(pos.x,pos.y)
end

-- 获得当前SceneView
function FightSystem:GetFightSceneView()
	return FightSystem.mSceneManager:GetSceneView(FightSystem.mSceneManager.mArenaViewIndex)
end

-- 获得当前
function FightSystem:GetFightTiledLayer()
	return self:GetFightSceneView().mTiledLayer
end

-- 设置TildemapProperty
function FightSystem:setMapInfo(pos,type)
	self.mSceneManager:GetTiledLayer().mTiledMap:setPropertyByGiledPos(pos.x,pos.y,type)
end

-- 设置Tilde 矩形
function FightSystem:setMapInfoForRect(pos,width,hight,type)
	local _x = pos.x 
	local _y = pos.y
	local _w = width
	local _h = hight
	local _tiledW = math.floor((_x )/10)
	local _tiledW1 = math.floor((_x + _w )/10)
	local _tiledH = math.floor(_y/10)
	local _tiledH1 = math.floor((_y + _h)/10)
	for x = _tiledW, _tiledW1 do
		for y = _tiledH,_tiledH1 do
			self:setMapInfo(cc.p(x,y),type)
		end
	end
end

-- 获得getReachablePaths
function FightSystem:GetReachablePaths(posstart,posended,_sceneIndex)
	return self.mSceneManager:GetTiledLayer(_sceneIndex).mTiledMap:getReachablePaths(posstart,posended)
end

-- 获得当前场景根节点的偏移量
function FightSystem:getCurrentViewOffset()
	return cc.p(self.mSceneManager:GetTiledLayer():getPositionX(),self.mSceneManager.mSceneView:getPositionY())
end

----------------战斗通知机制------------------
--keylist:
--	      1. roledamaged
--		  2. fireddamage
--        3. skilldamage
--        4. subobjectdamage
--        5. keyrolechanged
--        6. anyrolemoved
--        7. keyrolestopmoved
--        101. hall_myrolemove
--        102. hall_myrolestopmove
--		  103. hall_anytouch
--        201. scenelayermoved
function FightSystem:RegisterNotifaction(_key, _subKey, _func)
	if not self.mNotifactionList[_key] then
	   self.mNotifactionList[_key] = {}
	end
	local _table = self.mNotifactionList[_key]
	_table[_subKey] = _func
end

function FightSystem:UnRegisterNotification(_key, _subKey)
	local _table = self.mNotifactionList[_key]
	if _table then
	   for k,v in pairs(_table) do
	       if k == _subKey then
	       	  _table[k] = nil
	       return end
	   end
	end
end

function FightSystem:PushNotification(_key, ...)
	local _table = self.mNotifactionList[_key]
	if not _table then return end
	for k,_func in pairs(_table) do
	    _func(...)
	end
end


--------------------回调----------------------
-- spine 动作实时更新
function FightSystem:onSpineActionEvent(_group, _instanceid, _action)
	-- 找对应list
	local _list = nil
	if _group == "monster" then
	   _list = self.mRoleManager.mEnemyRoles
	elseif _group == "friend" then
	   _list = self.mRoleManager.mFriendRoles
	else
		return
	end
	-- 开始找具体的模型
	for k,_role in pairs(_list) do
	    if _role.mInstanceID == _instanceid then
           _role.mArmature:debugShowActionName(_action)
	    return end
	end
end

-- 通知事件
function FightSystem:onEventHandler(event)
	
end



-------------------快捷接口-------------------------
-- 战斗重新开始
function FightSystem:reloadFightWindow()
	Event.GUISYSTEM_HIDE_FIGHTWINDOW.mData = "refight"
	EventSystem:PushEvent(Event.GUISYSTEM_HIDE_FIGHTWINDOW)
	Event.GUISYSTEM_HIDE_FIGHTWINDOW.mData = nil
	showLoadingWindow("FightWindow")
end