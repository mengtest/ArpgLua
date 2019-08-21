-- Name: OnlinePvpManager
-- Func: PVP Online竞技场数据处理器
-- Author: tuanzhang

OnlinePvpManager = {}

function OnlinePvpManager:initVars()
	self.mBoardMaxTime = nil		--最大通关时间
	self.mCurTime = 0			    --当前剩余时间
	self.mtablemonster = {}			--控制器里面
	self.isTick = false
	self.mtick = 0
	self.mCurControllerKill = 0
	self.mResultTick = -1
	self.mMoneytable = {}
	self.mCurBoardMonster = nil

	self.mLeftLineX = 0  --大于等于0的数
	self.mRightLineX = 0  --大于等于0的数

	self.mLeftMAXLineX = 0   --大于等于0的数
	self.mRightMAXLineX = 0  --大于等于0的数

	self.mResult = nil
	--CG列表

	--副本当前替补
	self.mSubstitutionCount = 0
	--副本敌人替补
	self.mSubstitutionEnemyCount = 0
	--当前Player index 
	self.mPlayerIndex = 0

	self.mFinishTick = nil

	self.mServerTime = 0

	self.mUselessCount = 0

	self.IsrealTime = false

	-- 等待
	self.IsWaitTick = false

	self.mDeadRole = nil

	self.mRoundIndex = 1
end

function OnlinePvpManager:Destroy()

	

	NetSystem.mNetManager2:UnregisterPacketHandler(PacketTyper2.B2C_FIGHT_SYNC_POS_PVP_SERVER)
	
	NetSystem.mNetManager2:UnregisterPacketHandler(PacketTyper2.B2C_FIGHT_SYNC_OL_PVP_SERVER)

	NetSystem.mNetManager2:UnregisterPacketHandler(PacketTyper2.B2C_FIGHT_SYNC_ROLEPROPERTY_PVP_SERVER)

	NetSystem.mNetManager2:UnregisterPacketHandler(PacketTyper2.B2C_FIGHT_OLPVP_ROUND_READY_SERVER)

	NetSystem.mNetManager2:UnregisterPacketHandler(PacketTyper2.B2C_FIGHT_OLPVP_ROUNDFINISH_SERVER)

	NetSystem.mNetManager2:UnregisterPacketHandler(PacketTyper2.B2C_COUNT_TIME_SERVER)
	FightSystem:UnloadTouchPad()
	self.mBoardMaxTime = nil		--最大通关时间
	self.mControllerData = nil		--控制器数据
	self.mCurTime = nil				--当前剩余时间
	self.mtablemonster = nil
	self.isTick = nil
	self.mtick = nil
	self.mCurControllerKill = nil
	self.mResultTick = nil
	self.mResult = nil
	self.misTickBornMonster = nil
	self.mCurBoardMonster = nil
	self.mRoot = nil
	self.mFinishTick = nil
	self.mRoundIndex = nil
	self.MyRoleRoundHp = nil
	self.EnemyRoleRoundHp = nil
	GUISystem:enableUserInput()
end

function OnlinePvpManager:Release()
	--
	_G["OnlinePvpManager"] = nil
  	package.loaded["OnlinePvpManager"] = nil
  	package.loaded["FightSystem/OnlinePvp/OnlinePvpManager"] = nil
end

function OnlinePvpManager:Init(rootNode)

	debugLog("OnlinePvpManager:Init====" ..os.clock())

	self:initVars()
	self.mRoleManager = FightSystem.mRoleManager
	self.mRoot = rootNode
	self.isTick = true
	self.TimeUpdate = 0
	self.TimeUpdateSceond = 0
	-- 同步位置
	NetSystem.mNetManager2:RegisterPacketHandler(PacketTyper2.B2C_FIGHT_SYNC_POS_PVP_SERVER, handler(self,self.SyncEnemyPos))
	
	NetSystem.mNetManager2:RegisterPacketHandler(PacketTyper2.B2C_FIGHT_SYNC_OL_PVP_SERVER, handler(self,self.SyncPlayFightInfo))

	NetSystem.mNetManager2:RegisterPacketHandler(PacketTyper2.B2C_FIGHT_SYNC_ROLEPROPERTY_PVP_SERVER, handler(self,self.SyncRolePropertyChangeEvent))

	NetSystem.mNetManager2:RegisterPacketHandler(PacketTyper2.B2C_FIGHT_OLPVP_ROUND_READY_SERVER, handler(self,self.OlPvpRound))

	NetSystem.mNetManager2:RegisterPacketHandler(PacketTyper2.B2C_FIGHT_OLPVP_ROUNDFINISH_SERVER, handler(self,self.OlPvpRoundFinish))

	NetSystem.mNetManager2:RegisterPacketHandler(PacketTyper2.B2C_COUNT_TIME_SERVER, handler(self,self.OlPvpCountTime))


	--当前加载场景
	self:LoadBraveInfo()

	FightSystem:LoadTouchPad(FightConfig.FIGHTWINDOW_Z_TOUCHPAD, rootNode,self.mCurTime)
	FightSystem.mTouchPad:SetTime(self.mCurTime)
	
	FightSystem.mTouchPad:HideOlPvpBtn()
	local role = FightSystem.mRoleManager:FindEnemyRoleById(1)

	FightSystem.mTouchPad:InitKofMonsterHead()
	FightSystem:GetFightSceneView():setPositionY(math.abs(getGoldFightPosition_LD().y))
	
	self.mFriendShowPos = {}
	self.mEnemyShowPos = {}
	for i=1,3 do
		-- local con_sub1 = cc.Sprite:create()
		-- con_sub1:setProperty("Frame", string.format("fight_p%d.png",i))
  --     	con_sub1:setAnchorPoint(cc.p(0.5,0.5))
		-- FightSystem.mTouchPad:addChild(con_sub1,30)
		-- self.mFriendShowPos[i] = con_sub1
		-- con_sub1:setVisible(false)

		local con_sub = cc.Sprite:create()
		con_sub:setProperty("Frame", "fight_corner_enemy.png")
      	con_sub:setAnchorPoint(cc.p(0.5,0.5))
		FightSystem.mTouchPad:addChild(con_sub,30)
		self.mEnemyShowPos[i] = con_sub
		con_sub:setVisible(false)
	end

	self.mScreenWidth = getGoldFightScreenWidth()
	

	-- 放学校名
	--self:ShowSchool()
	CommonAnimation.ChangeBGM(globaldata.pvpmucicId)

	debugLog("OnlinePvpManager:Init22222====" ..os.clock())
	local role = FightSystem.mRoleManager:FindEnemyRoleById(1)
	if role then
		FightSystem.mSceneManager.mCamera:BeginCamera(role:getShadowPos(),role.IsFaceLeft)
	end
	FightSystem.mSceneManager.mCamera:setStopTick(true)
	self:SendReadyPercentage(100)
	globaldata:RequeststartFight_OL()
end


function OnlinePvpManager:LoadBraveInfo()
	self:setNeedData()
	self.Mapwidth = FightSystem.mSceneManager:GetTiledLayer().mWidth
	
	self:LoadFriendPlay()
	self:LoadEnemyPlay()

	self.Role_X = math.floor(self.MyRole:getShadowPos().x) 
	self.Role_Y = math.floor(self.MyRole:getShadowPos().y)

	self:ChangeFace(self.MyRole.IsFaceLeft)

	self.mCurBoardMonster = globaldata:getBattleEnemyFormationCount()
		
	local _count = globaldata:getBattleFormationCount()
	self.mSubstitutionCount = _count - 1

	local _count = globaldata:getBattleEnemyFormationCount()
	self.mSubstitutionEnemyCount = _count - 1

end

function OnlinePvpManager:LoadFriendPlay()
	local _count = globaldata:getBattleFormationCount()
	for i=1,_count do
		local _pos = cc.p(globaldata.pvpFriendPosList[i].x*self.Mapwidth,globaldata.pvpFriendPosList[i].y*770)
		local role = FightSystem.mRoleManager:LoadFriendOlPvpRoles(i, _pos)
		role.mSkillCon.mMp = 0
		self:RoleDirec(role ,globaldata.olHoldindex)

		if globaldata.olpvpType == 0 then
			self.MyRole = role
			self.MyRole:RegisterFuncStopMove(handler(self,self.StopMovecall))
			self.MyRole:setKeyRole(true)
			break
		elseif globaldata.olpvpType == 1 then
			local index = globaldata:convertOlindex(globaldata.olHoldindex)
			if index == i then
				self.MyRole = role
				self.MyRole:RegisterFuncStopMove(handler(self,self.StopMovecall))
				self.MyRole:setKeyRole(true)
			end
		elseif globaldata.olpvpType == 2 then
			local index = globaldata:convertOlindex(globaldata.olHoldindex)
			if index == i then
				self.MyRole = role
				self.MyRole:RegisterFuncStopMove(handler(self,self.StopMovecall))
				self.MyRole:setKeyRole(true)
			end
		elseif globaldata.olpvpType == 3 then
			self.MyRole = role
			self.MyRole:RegisterFuncStopMove(handler(self,self.StopMovecall))
			self.MyRole:setKeyRole(true)
			break
		end
	end
end

function OnlinePvpManager:LoadEnemyPlay()
	local _count = globaldata:getBattleEnemyFormationCount()
	for i=1,_count do
		local _pos = cc.p(globaldata.pvpEnemyPosList[i].x*self.Mapwidth,globaldata.pvpEnemyPosList[i].y*770)
		local role = FightSystem.mRoleManager:LoadOnlineEnemyPlayer(i, _pos)
		role.mSkillCon.mMp = 0
		self:RoleDirec(role ,globaldata.olHoldindex+1)
		if globaldata.olpvpType == 0 or globaldata.olpvpType == 3 then
			self.mEnemyRole = role
			break
		end
	end
end

-- 发送坐标
function OnlinePvpManager:SendMyPos()
	local _face = self:getFaceChar(self.MyRole.IsFaceLeft)
	self.Role_Face = _face
	self.Role_X = math.floor(self.MyRole:getShadowPos().x) 
	self.Role_Y = math.floor(self.MyRole:getShadowPos().y)
	self:SendMyRolePos(1,self.Role_Face,self.Role_X,self.Role_Y)
end

--查找当前副本需要的数值
function OnlinePvpManager:setNeedData()

	--暂时用
	local _mapID = globaldata.pvpmapId
	FightSystem.mSceneManager:LoadSceneView(FightConfig.FIGHTWINDOW_Z_SCENEVIEW, self.mRoot, _mapID)

	self.mBoardMaxTime = globaldata.pvpmaxTime
	
	self.mLeftLineX = 0   --大于等于0的数
	self.mRightLineX = FightSystem.mSceneManager:GetTiledLayer().mWidth --大于等于0的数

	self.mLeftMAXLineX = 0   --大于等于0的数
	self.mRightMAXLineX = FightSystem.mSceneManager:GetTiledLayer().mWidth --大于等于0的数
	if globaldata.olpvpType == 0 or globaldata.olpvpType == 3 then
		self.mCurTime = 90
	else
		self.mCurTime = 120
	end
	--self.mCurTime = 99--self.mBoardMaxTime

end

-- Sync 战斗信息  施放技能
function OnlinePvpManager:PlaySkill_SyncPVP(_role,_skillid , _randomNum)
	local _x = math.floor(_role:getShadowPos().x)
	local _y = math.floor(_role:getShadowPos().y)
	local _face = nil
	if _role.IsFaceLeft then
		_face = 0
	else
		_face = 1
	end

	local packet = NetSystem.mNetManager2:GetSPacket()
    packet:SetType(PacketTyper2.C2B_FIGHT_SYNC_OL_PVP_CLIENT)
    packet:PushChar(1) -- 放技能
    packet:PushChar(_face)
    packet:PushInt(_skillid)
    packet:PushUShort(_x)
	packet:PushUShort(_y)
	packet:PushInt(_randomNum)
    packet:Send(false)
	--globaldata:SendSyncSkill(face,_skillid,_x,_y)
end

-- Sync 战斗信息  设置格挡
function OnlinePvpManager:Block_SyncPVP(_role, _type)
	local _x = math.floor(_role:getShadowPos().x)
	local _y = math.floor(_role:getShadowPos().y)
	local _face = nil
	if _role.IsFaceLeft then
		_face = 0
	else
		_face = 1
	end
	local packet = NetSystem.mNetManager2:GetSPacket()
    packet:SetType(PacketTyper2.C2B_FIGHT_SYNC_OL_PVP_CLIENT)
    packet:PushChar(2) -- 放技能
    packet:PushChar(_type) -- 1：开始格挡，2:取消格挡
    packet:PushChar(_face)
    packet:PushUShort(_x)
	packet:PushUShort(_y)
    packet:Send(false)
end

-- Sync 战斗信息  取消技能
function OnlinePvpManager:CancelSkill_SyncPVP(_skillid)
	local packet = NetSystem.mNetManager2:GetSPacket()
    packet:SetType(PacketTyper2.C2B_FIGHT_SYNC_OL_PVP_CLIENT)
    packet:PushChar(3) -- 取消放技能
    packet:PushInt(_skillid)
    packet:Send(false)
end

-- 同步血量
function OnlinePvpManager:SyncRolePropertyChangeEvent(msgPacket)
	local index = msgPacket:GetChar()
	local _role = self:FindRoleByIndex(index)
	if not _role then
		return
	end
	local hp = msgPacket:GetInt()
	local currole = nil
	local _hiter = nil

	local _damage = _role.mPropertyCon.mCurHP - hp
	_role.mPropertyCon.mCurHP = hp

	-- if _role.mGroup == "friend" then
	-- 	local data = globaldata:getBattleFormationInfoByIndex(_role.mPosIndex)
	-- 	data.propList[1] = hp
	-- else
	-- 	local data = globaldata:getBattleEnemyFormationInfoByIndex(_role.mPosIndex)
	-- 	data.propList[1] = hp
	-- end

	FightSystem.mTouchPad:OnRolePropertyChangeEvent(1, -_damage, _role)
	if -_damage > 0 then
		_role.mFlowLabelCon:FlowAddBlood(-_damage)
	else
		_role.mFlowLabelCon:FlowDamage(1,_damage)
	end
	

	-- if _role.mGroup == "friend" then
	-- 	debugLog("SyncRolePropertyChangeEvent========" .. index .. "===========" .._role.mPosIndex)
	-- end

	currole = _role

	--[[ --注掉涨MP
	if currole.mGroup == "friend" or currole.mGroup == "enemyplayer" then
		currole.mSkillCon:AddMp(1)
	end
	]]

	if currole.mPropertyCon.mCurHP <= 0   then
		--doError("SyncRolePropertyChangeEvent====GROUP=="..  currole.mGroup .. "===" .. currole.mPosIndex)
		if currole.mGroup == "friend" then
			if globaldata.olpvpType == 1 then
				local index = globaldata:convertOlindex(globaldata.olHoldindex)
				if index == currole.mPosIndex then
					FightSystem.mTouchPad.mHolder = nil
					self.MyRole = nil
				end
				currole.mPropertyCon:handleDead(nil,true)
			elseif globaldata.olpvpType == 2 then
				local index = globaldata:convertOlindex(globaldata.olHoldindex)
				if index == currole.mPosIndex then
					FightSystem.mTouchPad.mHolder = nil
					self.MyRole = nil
				end
				currole.mPropertyCon:handleDead(nil,true)
			elseif globaldata.olpvpType == 0 or globaldata.olpvpType == 3 then
				if currole.mPosIndex < globaldata:getBattleFormationCount() then
					self.IsWaitTick = true
					currole.mPropertyCon:handleDead(nil,true)
					-- self:RedayNextFight()
					-- self.mEnemyRole:CancelAttack()
					-- self.mEnemyRole.mFSM:ForceChangeToState("idle")
				else
					FightSystem.mTouchPad.mHolder = nil
					self.MyRole = nil
					currole.mPropertyCon:handleDead(nil,true)
				end
			end		
		elseif currole.mGroup == "enemyplayer" then
			if globaldata.olpvpType == 0 or globaldata.olpvpType == 3 then
				if currole.mPosIndex < globaldata:getBattleEnemyFormationCount() then
					self.IsWaitTick = true
					currole.mPropertyCon:handleDead(nil,true)
					-- self:RedayNextFight()
					-- self.MyRole:CancelAttack()
					-- self.MyRole.mFSM:ForceChangeToState("idle")
				else
					currole.mPropertyCon:handleDead(nil,true)
				end
			elseif globaldata.olpvpType == 1 then
				currole.mPropertyCon:handleDead(nil,true)
			elseif globaldata.olpvpType == 2 then
				currole.mPropertyCon:handleDead(nil,true)
			end
		end
	end
end

-- 人的朝向
function OnlinePvpManager:RoleDirec( _role , _index)
	if _index%2 == 0 then
		_role:FaceLeft()
	else
		_role:FaceRight()
	end
end

--[[
-- 上下一个人准备
function OnlinePvpManager:AddTeamPlayer(_role)
	if _role.mGroup == "friend" then

		local _pos = cc.p(globaldata.pvpFriendPosList[_role.mPosIndex+1].x*self.Mapwidth,globaldata.pvpFriendPosList[_role.mPosIndex+1].y*770)
		local role = FightSystem.mRoleManager:LoadFriendOlPvpRoles(_role.mPosIndex+1, _pos)
		role.mSkillCon.mMp = 0
		FightSystem.mTouchPad.mHolder = role
		self.MyRole = role
		self.MyRole:RegisterFuncStopMove(handler(self,self.StopMovecall))
		self.MyRole:setKeyRole(true)
		FightSystem.mTouchPad.mHolder.mSkillCon:SetFinishSkillCallBackHandler("FightTouchPad2", handler(FightSystem.mTouchPad, FightSystem.mTouchPad.OnSkillFinish))
		FightSystem.mTouchPad:ResetAttack()
		FightSystem.mTouchPad:UpdateSkillBtn()
		FightSystem.mTouchPad:UpdateSkillCoolDowm()

		-- 血条头像
		FightSystem.mTouchPad:ShowTeamsCount(role.mGroup ,role.mPosIndex)

		-- 敌人坐标
		self.mEnemyRole:setPositionX(globaldata.pvpEnemyPosList[self.mEnemyRole.mPosIndex].x*self.Mapwidth)
		self.mEnemyRole:setPositionY(globaldata.pvpEnemyPosList[self.mEnemyRole.mPosIndex].y*770)
		self:RoleDirec(self.mEnemyRole ,globaldata.olHoldindex+1)
		self:RoleDirec(self.MyRole ,globaldata.olHoldindex )

		FightSystem.mRoleManager:RemoveRoleByIdx(_role.mGroup, _role.mInstanceID)
	elseif _role.mGroup == "enemyplayer" then
		local _pos = cc.p(globaldata.pvpEnemyPosList[_role.mPosIndex+1].x*self.Mapwidth,globaldata.pvpEnemyPosList[_role.mPosIndex+1].y*770)
		local role = FightSystem.mRoleManager:LoadOnlineEnemyPlayer(_role.mPosIndex+1, _pos)
		role.mSkillCon.mMp = 0
		self.mEnemyRole = role
		FightSystem.mTouchPad:ShowTeamsCount(role.mGroup ,role.mPosIndex)

		-- 我的坐标
		self.MyRole:setPositionX(globaldata.pvpFriendPosList[self.MyRole.mPosIndex].x*self.Mapwidth)
		self.MyRole:setPositionY(globaldata.pvpFriendPosList[self.MyRole.mPosIndex].y*770)
		self:RoleDirec(self.MyRole ,globaldata.olHoldindex )
		self:RoleDirec(self.mEnemyRole ,globaldata.olHoldindex+1 )
		FightSystem.mRoleManager:RemoveRoleByIdx(_role.mGroup, _role.mInstanceID)
	end
end
]]
-- 准备下一场战斗
function OnlinePvpManager:RedayNextFight()
	self.IsWaitTick = true
	--GUISystem:showLoadingForPvp()
	FightSystem.mTouchPad.mHolder = nil
	FightSystem.mTouchPad:setCancelledTouchMove(true)
end

-- 准备下一场
function OnlinePvpManager:OlPvpRound()
	self.mServerTime = 0
	--GUISystem:hideLoadingForPvp()
	self.mCurTime = 90
	FightSystem.mTouchPad:SetTime(self.mCurTime)
	FightSystem.mTouchPad:RemoveLoadNextRound()

	local function callfun( ... )
		self.IsWaitTick = false
		FightSystem.mTouchPad:setCancelledTouchMove(false)
	end
	FightSystem.mSceneManager.mCamera:setStopTick(false)
	FightSystem.mSceneManager.mCamera:UpdateCameraForOLPvp(self.MyRole:getShadowPos(),self.MyRole.IsFaceLeft,2)
	FightSystem.mTouchPad:RoundFight(self.mRoundIndex,callfun)
	--GUISystem:PVPBlacklayout(handler(self,self.EnterBlack))
end

function OnlinePvpManager:DeadRolefalldown(_role)
	if _role then
		_role.mFSM:ForceChangeToStateForpvp("falldown")
		_role.mArmature:setPosition_ArmatureX(self.mDeadRole:getShadowPos().x)
		_role.mArmature:setPosition_ArmatureY(self.mDeadRole:getShadowPos().y)
		_role.mArmature:ActionNow("beBlowUpEnd")
	end
end

function OnlinePvpManager:LoadNextPlayers(result)
	FightSystem.mTouchPad:ResetShowSkill()
	FightSystem.mTouchPad:setCancelledTouchMove(false)
	if globaldata.mFriendCurLive <= 3 then
		local _pos = cc.p(globaldata.pvpFriendPosList[1].x*self.Mapwidth,globaldata.pvpFriendPosList[1].y*770)
		local role = FightSystem.mRoleManager:LoadFriendOlPvpRoles(globaldata.mFriendCurLive, _pos)
		role.mSkillCon.mMp = 0
		FightSystem.mTouchPad.mHolder = role
		self.MyRole = role
		self.MyRole:RegisterFuncStopMove(handler(self,self.StopMovecall))
		self.MyRole:setKeyRole(true)
		FightSystem.mTouchPad.mHolder.mSkillCon:SetFinishSkillCallBackHandler("FightTouchPad2", handler(FightSystem.mTouchPad, FightSystem.mTouchPad.OnSkillFinish))
		FightSystem.mTouchPad:ResetAttack()
		FightSystem.mTouchPad:UpdateSkillBtn()
		FightSystem.mTouchPad:UpdateSkillCoolDowm()
		FightSystem.mTouchPad.mIsAttackBtnDown = false
		self:RoleDirec(self.MyRole ,globaldata.olHoldindex )
	end
	if globaldata.mEnemyCurLive <= 3 then
		local _pos = cc.p(globaldata.pvpEnemyPosList[1].x*self.Mapwidth,globaldata.pvpEnemyPosList[1].y*770)
		local role = FightSystem.mRoleManager:LoadOnlineEnemyPlayer(globaldata.mEnemyCurLive, _pos)
		role.mSkillCon.mMp = 0
		self.mEnemyRole = role
		self:RoleDirec(self.mEnemyRole ,globaldata.olHoldindex+1 )
	end
	self:SendReadyPercentage(100)
	if result == 0 then
		-- 我方胜利
		if self.MyRoleRoundHp then
			self.MyRole.mPropertyCon.mCurHP = self.MyRoleRoundHp
			self.MyRoleRoundHp = nil
		end
		if self.MyRoleMp then
			self.MyRole.mSkillCon.mMp = self.MyRoleMp
			self.MyRoleMp = nil
		end
	elseif result == 1 then
		-- 敌方胜利
		if self.EnemyRoleRoundHp then
			self.mEnemyRole.mPropertyCon.mCurHP = self.EnemyRoleRoundHp
			self.EnemyRoleRoundHp = nil
		end
		if self.EnemyRoleMp then
			self.mEnemyRole.mSkillCon.mMp = self.EnemyRoleMp
			self.EnemyRoleMp = nil
		end
	end

	if result == 0 then
		FightSystem.mTouchPad:ShowTeamsCount("enemyplayer" ,globaldata.mEnemyCurLive )
	elseif result == 1 then
		FightSystem.mTouchPad:ShowTeamsCount("friend" ,globaldata.mFriendCurLive )
	elseif result == 2 then
		FightSystem.mTouchPad:ShowTeamsCount("enemyplayer" ,globaldata.mEnemyCurLive )
		FightSystem.mTouchPad:ShowTeamsCount("friend" ,globaldata.mFriendCurLive )
	end
	FightSystem.mSceneManager.mCamera:BeginCamera(self.mEnemyRole:getShadowPos(),self.mEnemyRole.IsFaceLeft)
	FightSystem.mSceneManager.mCamera:setStopTick(true)
	local packet = NetSystem.mNetManager2:GetSPacket()
	packet:SetType(PacketTyper2.C2B_FIGHT_OLPVP_ROUND_READY_CLIENT)
	packet:Send(false)
end


function OnlinePvpManager:OlPvpCountTime(msgPacket)
	local Time = msgPacket:GetInt()
	if math.abs(Time - self.mCurTime) >= 1 then
		self.mCurTime = Time
		FightSystem.mTouchPad:SetTime(self.mCurTime)
	end
end

function OnlinePvpManager:OlPvpRoundFinish(msgPacket)
	local success = msgPacket:GetChar()
	self.mRoundIndex = self.mRoundIndex + 1
	--doError("OlPvpRoundFinish=="..success)
	self:RedayNextFight()
	local function resetFightPlayer()
		-- 重新加载人物
		self.MyRoleRoundHp = self.MyRole.mPropertyCon.mCurHP
		self.EnemyRoleRoundHp = self.mEnemyRole.mPropertyCon.mCurHP
		self.MyRoleMp = self.MyRole.mSkillCon.mMp	
		self.EnemyRoleMp = self.mEnemyRole.mSkillCon.mMp
		if success == 0 then
			self.EnemyRoleMp = 0
		elseif success == 1 then
			self.MyRoleMp = 0
		elseif success == 2 then	
			self.MyRoleMp = 0
			self.EnemyRoleMp = 0
		end
		self.MyRole:RemoveOlPvpSelf()
		self.mEnemyRole:RemoveOlPvpSelf()
		FightSystem:cancelStaticFrameTime()
		self.MyRole = nil
		self.mEnemyRole = nil
		self:LoadAppointRole(success)
	end
	local function ShowRoundover()
		FightSystem.mTouchPad:RemoveRoundResult()
		FightSystem.mTouchPad:LoadNextRoundLoading(resetFightPlayer)
	end
	if success == 0 then
		-- 胜
		globaldata.mEnemyCurLive = globaldata.mEnemyCurLive + 1
		FightSystem.mTouchPad:OlPVPRoundResult(success,ShowRoundover,self.MyRole.mGroup,globaldata.mFriendCurLive)
	elseif success == 1 then
		globaldata.mFriendCurLive = globaldata.mFriendCurLive + 1
		FightSystem.mTouchPad:OlPVPRoundResult(success,ShowRoundover,self.mEnemyRole.mGroup,globaldata.mEnemyCurLive)
	elseif success == 2 then
		-- 平局
		globaldata.mFriendCurLive = globaldata.mFriendCurLive + 1
		globaldata.mEnemyCurLive = globaldata.mEnemyCurLive + 1
		FightSystem.mTouchPad:OlPVPRoundResult(success,ShowRoundover)
	end
end


--设置副本控制难度系数
function OnlinePvpManager:Tick(delta)
	if not self.isTick then return end
	if self.mFinishTick then return end
	if self.IsWaitTick then return end
	FightSystem.mTouchPad:Tick(delta)
	self:LookViewPos()
	self:TickServerTime(delta)
	self:UpdatePos(delta)
	self:OlPvpTime(delta)
end

function OnlinePvpManager:TickServerTime( delta )
	if self.mServerTime == 0 then return end
	self.mServerTime = self.mServerTime + delta
end

function OnlinePvpManager:LookViewPos()
	if not self.MyRole then return end
	local function showViewPos(_role ,index)
		if not _role then
			self.mEnemyShowPos[index]:setVisible(false)
			return
		end
		local _Ex = _role:getShadowPos().x
		local _Ey = _role:getShadowPos().y+100
		local  mPosTiled = math.abs(FightSystem:GetFightTiledLayer():getPositionX())
		if mPosTiled > _Ex then
			self.mEnemyShowPos[index]:setVisible(true)
			local deltaPos = FightSystem:getCurrentViewOffset()
			local _y = _Ey + deltaPos.y
			 if _y <= getGoldFightPosition_LD().y then
			 	_y = getGoldFightPosition_LD().y
			 elseif _y >= getGoldFightPosition_LU().y then
			 	_y = getGoldFightPosition_LU().y
			 end
			self.mEnemyShowPos[index]:setPosition(cc.p(getGoldFightPosition_LD().x,_y))

		elseif mPosTiled + self.mScreenWidth < _Ex then
			self.mEnemyShowPos[index]:setVisible(true)
			local deltaPos = FightSystem:getCurrentViewOffset()
			local _y = _Ey + deltaPos.y
			 if _y <= getGoldFightPosition_LD().y then
			 	_y = getGoldFightPosition_LD().y
			 elseif _y >= getGoldFightPosition_LU().y then
			 	_y = getGoldFightPosition_LU().y
			 end
			self.mEnemyShowPos[index]:setPosition(cc.p(getGoldFightPosition_RD().x,_y))
		else
			self.mEnemyShowPos[index]:setVisible(false)
		end
	end
	if globaldata.olpvpType == 0 or globaldata.olpvpType == 3 then
		local Erole = FightSystem.mRoleManager:GetEnemyTable()[1]
		showViewPos(Erole,1)
	elseif globaldata.olpvpType == 1 then
		local enemyplayers = FightSystem.mRoleManager:GetEnemyTable()
		for k,v in pairs(enemyplayers) do
			showViewPos(v,k)
		end
	elseif globaldata.olpvpType == 2 then
		local enemyplayers = FightSystem.mRoleManager:GetEnemyTable()
		for k,v in pairs(enemyplayers) do
			showViewPos(v,k)
		end
	end
end

-- 标记人物方向
function OnlinePvpManager:ChangeFace(_face)
	if _face then
		self.Role_Face = 0 
	else
		self.Role_Face = 1
	end
end

-- 方向转换
function OnlinePvpManager:getFaceChar(_face)
	if _face then
		return 0
	else
		return 1
	end
end

-- 人停之后发送位置
function OnlinePvpManager:StopMovecall( _role )
	local _state = 4
	local _face = self:getFaceChar(_role.IsFaceLeft)
	self.Role_Face = _face
	self.Role_X = math.floor(_role:getShadowPos().x)
	self.Role_Y = math.floor(_role:getShadowPos().y)
	self:SendMyRolePos(_state,self.Role_Face,self.Role_X,self.Role_Y)
end

-- 上传人物
function OnlinePvpManager:UpdatePos(delta)
	if not self.MyRole then return end
	if self.MyRole.mFSM:IsAttacking() and self.MyRole.mMoveCon:canMove() then
			local _X = math.floor(self.MyRole:getShadowPos().x)
			local _Y = math.floor(self.MyRole:getShadowPos().y)
		    --debugLog("OnlinePvpManager:UpdatePos==X=" .._X  .."=Y==" .. _Y)
	end

	if self.MyRole.mFSM:IsIdle() or self.MyRole.mFSM:IsRuning() or (self.MyRole.mFSM:IsAttacking() and self.MyRole.mMoveCon:canMove()) then 
		local _state = 1
		if self.MyRole.mFSM:IsIdle() then
			_state = 1
		elseif self.MyRole.mFSM:IsRuning() then
			_state = 2
		elseif self.MyRole.mFSM:IsAttacking() then
			_state = 3
		end
		if self.TimeUpdate >= 0.1 then
			self.TimeUpdate = self.TimeUpdate - 0.1
			local _X = math.floor(self.MyRole:getShadowPos().x)
			local _Y = math.floor(self.MyRole:getShadowPos().y)
			local _face = self:getFaceChar(self.MyRole.IsFaceLeft)
			if self.Role_Face ~= _face then
				self.Role_Face = _face
				self.Role_X = _X
				self.Role_Y = _Y
				self:SendMyRolePos(_state,self.Role_Face,self.Role_X,self.Role_Y)
				return
			end
			if math.abs(self.Role_X - _X) > 10  or math.abs(self.Role_Y - _Y) > 10 then
				self.Role_Face = _face
				self.Role_X = _X
				self.Role_Y = _Y
				self:SendMyRolePos(_state,self.Role_Face,self.Role_X,self.Role_Y)
			end
			return
		end
		if self.TimeUpdateSceond > 0.5 then
			self.TimeUpdateSceond = self.TimeUpdateSceond - 0.5
			local _face = self:getFaceChar(self.MyRole.IsFaceLeft)
			self.Role_Face = _face
			local _X = math.floor(self.MyRole:getShadowPos().x)
			local _Y = math.floor(self.MyRole:getShadowPos().y)
			self.Role_X = _X
			self.Role_Y = _Y
			self:SendMyRolePos(_state,self.Role_Face,self.Role_X,self.Role_Y)
			return
		end

		self.TimeUpdateSceond = self.TimeUpdateSceond + delta
		self.TimeUpdate = self.TimeUpdate + delta
	end
end


-- 发位置
function OnlinePvpManager:SendMyRolePos(_state,_face, _x, _y)
	local packet = NetSystem.mNetManager2:GetSPacket()
	packet:SetType(PacketTyper2.C2B_FIGHT_SYNC_POS_PVP_CLIENT)
	packet:PushChar(_state)
	packet:PushChar(_face)
	packet:PushUShort(_x)
	packet:PushUShort(_y)
	packet:Send(false)
end

function OnlinePvpManager:SyncPlayFightInfo(msgPacket)
	self:ReceiveServerTime(msgPacket)
	local index = msgPacket:GetChar()
	local role = self:FindRoleByIndex(index)
	if not role then
		return
	end
	local operate = msgPacket:GetChar()
	if operate == 1 then
		self:SyncPlaySkillPos(role,msgPacket)
	elseif operate == 2 then
		self:SyncBlockPos(role,msgPacket)
	end
end

-- 接受服务器时间处理
function OnlinePvpManager:ReceiveServerTime(msgPacket)
	local time = msgPacket:GetInt()
	time = time/1000
	if self.mServerTime == 0 then
		self.mServerTime = time
		self.IsrealTime = true
		return 
	end
	if self.mUselessCount > 2 then
		self.mServerTime = time
		self.IsrealTime = true
		return
	end
	if math.abs(self.mServerTime - time) < 1 then
		self.mServerTime = time
		self.IsrealTime = true
	else
		self.mUselessCount = self.mUselessCount + 1
		self.IsrealTime = false
		--debugLog("ReceiveServerTimeBBBBBBBB============" .. self.mServerTime.. "==SENDTIME==".. time)
	end
end

-- 服务器同步玩家放技能
function OnlinePvpManager:SyncPlaySkillPos(_role,msgPacket)

	local isleftface = msgPacket:GetChar()  -- 0 是左侧 1 是右侧
	local skill = msgPacket:GetInt()
	local posx = msgPacket:GetUShort()
	local posy = msgPacket:GetUShort()
	local _randomNum = msgPacket:GetInt()
	math.randomseed(_randomNum)
	local _curface = self:getFaceChar(_role.IsFaceLeft)
	if isleftface == 0 then
		_role:FaceLeft()
	else
		_role:FaceRight()
	end

	_role:setPositionX(posx)
	_role:setPositionY(posy)
	_role:syncShadowPosWithRolePos()
	if _role:PlaySkillByID(skill) then
		debugLog("GROUP===" .. _role.mGroup.."=====FSM===" .. _role.mFSM.mCurState .."===skill==" .. skill)
	else
		debugLog("NOOoooooooooGROUP===" .. _role.mGroup.."=====FSM===" .. _role.mFSM.mCurState .."===skill==" .. skill)
	end
	
end

-- 服务器同步玩家放技能
function OnlinePvpManager:SyncBlockPos(_role,msgPacket)

	local _blocktype = msgPacket:GetChar()  -- 1开始格挡 2取消格挡
	local isleftface = msgPacket:GetChar()  -- 0 是左侧 1 是右侧
	local posx = msgPacket:GetUShort()
	local posy = msgPacket:GetUShort()
	local non = nil
	if _blocktype == 1 then
		-- 开始格挡
		non = _role:PlayBlock()
	else
		-- 取消格挡
		non = _role:StopBlock()
	end

	if non then
		if isleftface == 0 then
			_role:FaceLeft()
		else
			_role:FaceRight()
		end
		_role:setPositionX(posx)
		_role:setPositionY(posy)
		_role:syncShadowPosWithRolePos()
	end
end

-- 服务器同步玩家数据
function OnlinePvpManager:SyncEnemyPos(msgPacket)
	self:ReceiveServerTime(msgPacket)
	local index = msgPacket:GetChar()
	local role = self:FindRoleByIndex(index)
	if not role then return end
	if not self.IsrealTime  then return end
	local RoleState = msgPacket:GetChar()
	self.SyncFace = msgPacket:GetChar()
	local posx = msgPacket:GetUShort()
	local posy = msgPacket:GetUShort()

	local curpos = role:getShadowPos()
	local sendpos = cc.p(posx,posy)
	if cc.pGetDistance(curpos,sendpos)  > 100 and not (role.mFSM:IsIdle() or role.mFSM:IsRuning()) then
		if role.mFSM:IsBeatingStiff() or role.mFSM:IsBeControlled() or role.mFSM:IsFallingDown() then
			role:ForcesetPosandShadow(sendpos)
			role.mFSM:ForceChangeToStateForpvp("idle")
			role.mShadow:stopTickMove(false)
			local _curface = self:getFaceChar(role.IsFaceLeft)
			if self.SyncFace ~= _curface then
				if self.SyncFace == 0 then
					role:FaceLeft()
				else
					role:FaceRight()
				end
			end
			return
		end
	end

	local _curface = self:getFaceChar(role.IsFaceLeft)
	if self.SyncFace ~= _curface then
		if self.SyncFace == 0 then
			role:FaceLeft()
		else
			role:FaceRight()
		end
	end

	if math.abs(role:getShadowPos().x - posx) > 10 or math.abs(role:getShadowPos().y - posy) > 10 then
		function WalkGoalPos()
			if RoleState == 1 or RoleState == 4 then
				role:StopMove()
			end
		end
		if RoleState == 4 then
			role:WalkingByPos(cc.p(posx, posy),WalkGoalPos)
		elseif role.mFSM:IsIdle() and RoleState == 1 then
			--role:WalkingByPos(cc.p(posx, posy),WalkGoalPos)
		elseif RoleState == 3 then
			--debugLog("OnlinePvpManager:SyncEnemyPos1111111111111111==X=" ..posx  .."=Y==" .. posy)
			role:WalkingByPosAttacking(cc.p(posx, posy),WalkGoalPos)
		else
			role:WalkingByPos(cc.p(posx, posy),WalkGoalPos)
		end
	else
		if role.mFSM:IsIdle() or role.mFSM:IsRuning() then
			role:StopMove()
		end
	end
end

function OnlinePvpManager:FindRoleByIndex( _index )
	local id , team = globaldata:convertOlindex(_index)
	local role = nil
	if team == "friend" then
		role = FightSystem.mRoleManager:FindFriendRoleById(id)
	elseif team == "enemy" then
		role = FightSystem.mRoleManager:FindEnemyRoleById(id)
	end
	return role
end



-- 有人被击杀通知
function OnlinePvpManager:OnRoleKilled(_group, _pos)
	if self:IsArena() then
		self:OnKilledArena(_group, _pos)
	else
		self:OnKilledOther(_group, _pos)
	end
end

-- 胜负
function OnlinePvpManager:ArenaResult(_sessionindex,_group)
	if self.SessionArr[_sessionindex] == 0 then
		self.SessionArr[_sessionindex] = 1
		if _group == "friend" then
			self.mEnemysession = self.mEnemysession + 1
		else
			self.mFriendsession = self.mFriendsession + 1
		end
		if self.mEnemysession == 2 then
			self:Result("fail")
			return false
		end
		if self.mFriendsession == 2 then
			self:Result("success")
			return false
		end
		return _sessionindex
	end
	return false
end

function OnlinePvpManager:IsArena( _group, _pos )
	return globaldata.PvpType == "arena" 
end

function OnlinePvpManager:OnKilledArena(_group, _pos)
		
end


function OnlinePvpManager:OnKilledOther(_group, _pos)
	if _group == "friend"  then
		if #FightSystem.mRoleManager.mFriendRoles == 0 then
			self:Result("fail")
		end
	elseif _group == "enemyplayer" then
		self.mCurControllerKill = self.mCurControllerKill + 1 
		if self.mCurControllerKill ==  self.mCurBoardMonster then
			self:Result("success")
			return 
		end
	end
end

function OnlinePvpManager:Result(_result)
	if self.mResult then return end
	self.mResult = _result
	self:SendPvpResult(_result)
	self.mResultTick = 0
end



function OnlinePvpManager:SendPvpResult(_result)

end

function OnlinePvpManager:GetSlowmotion(_role)
	if _role.mGroup == "enemyplayer" then
		return self:GetLastBoardMonsterCount(_role)
	elseif _role.mGroup == "friend" then
		return self:GetLastFriendCount(_role)
	end
end

function OnlinePvpManager:GetLastFriendCount(_role)
	if self:IsArena() then
		return nil
	else
		local count = 0
		for k,v in pairs(FightSystem.mRoleManager.mFriendRoles) do
			if v.mGroup == "friend" then
				if v.mPropertyCon.mCurHP > 0 then
					count = count + 1
				end
			end
		end
		if count == 0 then
			return 1
		end
		return nil
	end
end

function OnlinePvpManager:GetLastBoardMonsterCount(_role)
	return self.mCurBoardMonster - self.mCurControllerKill
end

function OnlinePvpManager:OlPvpTime(delta)
	if self.mtick >= 1 then
		self.mtick = 0
		self.mCurTime = self.mCurTime - 1
		if self.mCurTime < 0 then return end
		FightSystem.mTouchPad:SetTime(self.mCurTime)
	else     	  
		self.mtick = self.mtick + delta	
	end
end

function OnlinePvpManager:ShowSchool()
	local _dbText = getDictionaryText(globaldata.pvpmapNameId)
	CommonAnimation.ScreenMiddlelabelText(FightSystem.mTouchPad,_dbText,3)
end

function OnlinePvpManager:SendReadyPercentage(percentage)
	local packet = NetSystem.mNetManager2:GetSPacket()
    packet:SetType(PacketTyper2.C2B_FIGHT_OLPVP_LOAD_PERCENT_CLIENT)
    packet:PushChar(percentage)
    packet:Send(false)
end

function OnlinePvpManager:SendDamgeProcess(_skillId, _type, _processId, _count, _index, _perhurt)
	debugLog("OnlinePvpManager:SendDamgeProcess========" .. _skillId .. "==".._type.. "==".._processId.. "==".._count.. "==".._index.."==_perhurt==".._perhurt)

	local packet = NetSystem.mNetManager2:GetSPacket()
    packet:SetType(PacketTyper2.C2B_FIGHT_OLPVP_DAMGE_PROCESS_CLIENT)
    packet:PushInt(_skillId)
    packet:PushChar(_type)
    packet:PushInt(_processId)
    packet:PushUShort(_count)
    packet:PushChar(_index)
    _perhurt = math.ceil(_perhurt*1000)
    packet:PushInt(_perhurt)
    packet:Send(false)
end

function OnlinePvpManager:SendDamgeBuff(_skillId, _processType, _processId, _dbStateId, _index)
	debugLog("OnlinePvpManager:SendDamgeBuff========".. _skillId .. "==".._processType.. "==".._processId.. "==".._dbStateId.. "==".._index)
	
	local packet = NetSystem.mNetManager2:GetSPacket()
    packet:SetType(PacketTyper2.C2B_FIGHT_OLPVP_DAMGE_BUFF_CLIENT)
    packet:PushInt(_skillId)
    packet:PushChar(_processType)
    packet:PushInt(_processId)
    packet:PushInt(_dbStateId)
    packet:PushChar(_index)
    packet:Send(false)
end



function OnlinePvpManager:LoadAppointRole(result)
		-- 预加载角色
	local function _loadRoles()
		_co2 = coroutine.create(function()
			debugLog("OnPreEnterPVP==role==" ..os.clock())
			-- 加载友方第一个
			if result == 1 then
				if globaldata.mFriendCurLive <=3 then
					local _json, _atlas, _scale, _soundList, _skillList = globaldata:getMyFightTeamSpineData(globaldata.mFriendCurLive)
					CommonAnimation.preloadSoundList(_soundList)
					CommonAnimation.preloadSkillSoundAndEffect(_skillList)
					self:SendReadyPercentage(40)
					coroutine.yield()
					CommonAnimation.preloadSpine_common(_json, _atlas, _scale)
					debugLog("OnPreEnterPVP==role1==" ..os.clock())
					self:SendReadyPercentage(60)
					coroutine.yield()
				end
			elseif result == 0 then
				-- 加载敌方第一个
				if globaldata.mEnemyCurLive <=3 then
					debugLog("OnPreEnterPVP==roleA==" ..os.clock())
					local _json, _atlas, _scale, _soundList, _skillList = globaldata:getEnemyFightTeamSpineData(globaldata.mEnemyCurLive)
					CommonAnimation.preloadSoundList(_soundList)
					CommonAnimation.preloadSkillSoundAndEffect(_skillList)
					self:SendReadyPercentage(40)
					coroutine.yield()
					CommonAnimation.preloadSpine_common(_json, _atlas, _scale)
					debugLog("OnPreEnterPVP==roleB==" ..os.clock())
					self:SendReadyPercentage(60)
					coroutine.yield()
				end
			elseif result == 2 then
				if globaldata.mFriendCurLive <=3 then
					local _json, _atlas, _scale, _soundList, _skillList = globaldata:getMyFightTeamSpineData(globaldata.mFriendCurLive)
					CommonAnimation.preloadSoundList(_soundList)
					CommonAnimation.preloadSkillSoundAndEffect(_skillList)
					self:SendReadyPercentage(10)
					coroutine.yield()
					CommonAnimation.preloadSpine_common(_json, _atlas, _scale)
					debugLog("OnPreEnterPVP==role1==" ..os.clock())
					self:SendReadyPercentage(30)
					coroutine.yield()
				end
				-- 加载敌方第一个
				if globaldata.mEnemyCurLive <=3 then
					debugLog("OnPreEnterPVP==roleA==" ..os.clock())
					local _json, _atlas, _scale, _soundList, _skillList = globaldata:getEnemyFightTeamSpineData(globaldata.mEnemyCurLive)
					CommonAnimation.preloadSoundList(_soundList)
					CommonAnimation.preloadSkillSoundAndEffect(_skillList)
					self:SendReadyPercentage(40)
					coroutine.yield()
					CommonAnimation.preloadSpine_common(_json, _atlas, _scale)
					debugLog("OnPreEnterPVP==roleB==" ..os.clock())
					self:SendReadyPercentage(60)
					coroutine.yield()
				end
			end
		end)
	end
	_loadRoles()
	-- 开始协同
	local _handler = 0
	local function xxx()
		coroutine.resume(_co2)
		if coroutine.status(_co2) == "dead" then
			
			self:LoadNextPlayers(result)

			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(_handler)
		end
	end
	_handler = nextTick_eachSecond(xxx, 0.1)
end

----------------回调--------------------------
-- 回包了，准备进入PVP
function OnlinePvpManager:OnPreEnterPVP(_mapID)
	debugLog("OnPreEnterPVP==111==" ..os.clock())
	local function _enterPVP()
		local _data = {}
		_data.mType = "olpvp"
		Event.GUISYSTEM_SHOW_FIGHTWINDOW.mData = _data
		EventSystem:PushEvent(Event.GUISYSTEM_SHOW_FIGHTWINDOW)
	end

	local function onMatchRedayCallBack()
		if GUISystem.Windows["LadderLoadingWindow"].mRootNode then
			GUISystem.Windows["LadderLoadingWindow"]:WindowGoOut()
		end
		FightSystem.mSceneManager.mCamera:setStopTick(false)
		FightSystem.mSceneManager.mCamera:UpdateCameraForOLPvp(self.MyRole:getShadowPos(),self.MyRole.IsFaceLeft,2)
		FightSystem.mTouchPad:RoundFight(self.mRoundIndex)
		self:SendMyPos()
	end

	NetSystem.mNetManager2:RegisterPacketHandler(PacketTyper2.B2C_PTYPE_SC_REDAY_OL_PVP_SERVER, onMatchRedayCallBack)

	-- local function redayPVP()
	-- 	local packet = NetSystem.mNetManager:GetSPacket()
 --   	 	packet:SetType(PacketTyper._PTYPE_CS_REDAY_OL_PVP_)
 --   		packet:Send()
	-- end
	
	-- 预加载角色
	local function _loadRoles()
		_co2 = coroutine.create(function()
			debugLog("OnPreEnterPVP==role==" ..os.clock())
			-- 加载友方第一个
			local _json, _atlas, _scale, _soundList, _skillList = globaldata:getMyFightTeamSpineData(globaldata.mFriendCurLive)
			CommonAnimation.preloadSoundList(_soundList)
			CommonAnimation.preloadSkillSoundAndEffect(_skillList)
			self:SendReadyPercentage(10)
			coroutine.yield()
			CommonAnimation.preloadSpine_common(_json, _atlas, _scale)
			debugLog("OnPreEnterPVP==role1==" ..os.clock())
			self:SendReadyPercentage(30)
			coroutine.yield()
				
			-- 加载敌方第一个
			debugLog("OnPreEnterPVP==roleA==" ..os.clock())
			local _json, _atlas, _scale, _soundList, _skillList = globaldata:getEnemyFightTeamSpineData(globaldata.mEnemyCurLive)
			CommonAnimation.preloadSoundList(_soundList)
			CommonAnimation.preloadSkillSoundAndEffect(_skillList)
			self:SendReadyPercentage(40)
			coroutine.yield()
			CommonAnimation.preloadSpine_common(_json, _atlas, _scale)
			debugLog("OnPreEnterPVP==roleB==" ..os.clock())
			self:SendReadyPercentage(60)
			coroutine.yield()
			
		end)
	end
	_loadRoles()
	-- 开始协同
	local _handler = 0
	local function xxx()
		coroutine.resume(_co2)
		if coroutine.status(_co2) == "dead" then
			_enterPVP()
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(_handler)
		end
	end
	_handler = nextTick_eachSecond(xxx, 0.1)
end

-- 多人战斗
function OnlinePvpManager:OnPreEnterPVPForMore(_mapID)


	local function _enterPVP()
		local _data = {}
		_data.mType = "olpvp"
		Event.GUISYSTEM_SHOW_FIGHTWINDOW.mData = _data
		EventSystem:PushEvent(Event.GUISYSTEM_SHOW_FIGHTWINDOW)
	end

	local function onMatchRedayCallBack()
		if GUISystem.Windows["LadderLoadingWindow"].mRootNode then
			GUISystem.Windows["LadderLoadingWindow"]:WindowGoOut()
		end
		FightSystem.mSceneManager.mCamera:setStopTick(false)
		FightSystem.mSceneManager.mCamera:UpdateCameraForOLPvp(self.MyRole:getShadowPos(),self.MyRole.IsFaceLeft,2)
		FightSystem.mTouchPad:RoundFight(1)
		self:SendMyPos()
	end

	NetSystem.mNetManager2:RegisterPacketHandler(PacketTyper2.B2C_PTYPE_SC_REDAY_OL_PVP_SERVER, onMatchRedayCallBack)

	-- local function redayPVP()
	-- 	local packet = NetSystem.mNetManager:GetSPacket()
 --   	 	packet:SetType(PacketTyper._PTYPE_CS_REDAY_OL_PVP_)
 --   		packet:Send()
	-- end
	
	-- 预加载角色
	local function _loadRoles()
		_co2 = coroutine.create(function()
			-- myteam
			local _count = globaldata:getBattleFormationCount()
			for i = 1, _count do
				local _json, _atlas, _scale, _soundList, _skillList = globaldata:getMyFightTeamSpineData(i)
				CommonAnimation.preloadSoundList(_soundList)
				CommonAnimation.preloadSkillSoundAndEffect(_skillList)
				self:SendReadyPercentage(5 + 10*(i-1))
				coroutine.yield()
				CommonAnimation.preloadSpine_common(_json, _atlas, _scale)
				self:SendReadyPercentage(10 + 10*(i-1))
				coroutine.yield()
			end
			-- monster
			_count = globaldata:getBattleEnemyFormationCount()
			for i = 1, _count do
				local _json, _atlas, _scale, _soundList, _skillList = globaldata:getEnemyFightTeamSpineData(i)
				CommonAnimation.preloadSoundList(_soundList)
				CommonAnimation.preloadSkillSoundAndEffect(_skillList)
				self:SendReadyPercentage(35 + 10*(i-1))
				coroutine.yield()
				CommonAnimation.preloadSpine_common(_json, _atlas, _scale)
				self:SendReadyPercentage(40 + 10*(i-1))
				coroutine.yield()
			end
		end)
	end
	_loadRoles()
	-- 开始协同
	local _handler = 0
	local function xxx()
		coroutine.resume(_co2)
		if coroutine.status(_co2) == "dead" then
			_enterPVP()
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(_handler)
		end
	end
	_handler = nextTick_eachSecond(xxx, 0.1)
end

