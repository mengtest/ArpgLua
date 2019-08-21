-- Name: AIController
-- Func: AI控制器
-- Author: Johny

AIController = class("AIController")

AIController.DIS_DIRECTION = 0.0
--设置
AIController.TagAction_RoleRun = 1000
AIController.TagAction_ShadowRun = 1001

require "FightSystem/Role/AIGroup/AI_Condition"

function AIController:ctor(_role)
	self.mRole = _role
	self.NormalSkill_key = nil
	self.SpecialSkill_key = nil
	self.mAI_ID = nil
	self.mRoleData = _role.mRoleData
	self.TimerIdList = {}
	self.RunTimerIdList = {}
	self.mMonsterType = nil
	if self.mRole.mGroup == "friend" or self.mRole.mGroup == "cgfriend" or self.mRole.mGroup == "hallrole" then
		self.mSkillMaxNum = 4
		self.NormalSkill_key = "mRole_NormalSkill"
		self.SpecialSkill_key = "mRole_SpecialSkill"
		--怪物视野
		self.mMonsterView = FightSystem.mSceneManager:GetTiledLayer(self.mRole.mSceneIndex).mWidth
		if FightSystem.mFightType == "fuben" and not FightSystem:GetModelByType(4) then
			self.mAI_ID = self.mRoleData.mRole_AIConfig[1]
		else
			self.mAI_ID = self.mRoleData.mRole_AIConfig[2]
		end
	elseif self.mRole.mGroup =="enemyplayer" then
		self.mSkillMaxNum = 4
		self.NormalSkill_key = "mRole_NormalSkill"
		self.SpecialSkill_key = "mRole_SpecialSkill"
		--怪物视野
		self.mMonsterView = FightSystem.mSceneManager:GetTiledLayer(self.mRole.mSceneIndex).mWidth
		self.mAI_ID = self.mRoleData.mRole_AIConfig[2]
	elseif self.mRole.mGroup == "monster" or self.mRole.mGroup == "summonmonster"  then
		self.mSkillMaxNum = 4
		self.NormalSkill_key = "mRole_NormalSkill"
		self.SpecialSkill_key = "mRole_SpecialSkill"
		--怪物视野
		self.mMonsterView = self.mRoleData.mSight
		--cclog("MONSTER  mMonsterView ==" ..self.mMonsterView)
		self.mAI_ID = self.mRoleData.mRole_AIConfig
		self.mMonsterType = self.mRoleData.mInfoDB.Monster_Type
		if type(self.mRoleData.mInfoDB.Monster_Relax) == "table" then
			self.mMonsterRelax = self.mRoleData.mInfoDB.Monster_Relax
			self.mRelaxTime = 0
			self.mRole.mArmature:RegisterActionEnd("Monster_Relax",handler(self,self.OnActionEnd))
		end
	elseif  self.mRole.mGroup == "summonfriend" then
		self.mSkillMaxNum = 4
		self.NormalSkill_key = "mRole_NormalSkill"
		self.SpecialSkill_key = "mRole_SpecialSkill"
		--怪物视野
		self.mMonsterView = self.mRoleData.mSight
		self.mAI_ID = self.mRoleData.mRole_AIConfig
	end
	self.mSkillNorSkill1 = string.format("%s%d",self.NormalSkill_key,1)
	self.mOpenAI = false
	self.mActionOpen = true
	--cclog("AI_IDIDID=="..self.mAI_ID)
	self.mAIData = DB_AIConfig.getDataById(self.mAI_ID)
	self.tableCondition = {}
	self:Init_condition()
	self.AIDaiji = true
	self.mNormalSkill_Index = 0
	self.mNormalSkill_ID = 0
	self.mCallNormalSkill_ID = 0

	self.mBlockproba = 100*self.mAIData.AI_BlockFrequency[1]
	self.mBlockproba_start = self.mAIData.AI_BlockFrequency[2]
	self.mBlockproba_end = self.mAIData.AI_BlockFrequency[3]
	-- self.mBlockWait1 = self.mAIData.AI_BlockFrequency[4]
	-- self.mBlockWait2 = self.mAIData.AI_BlockFrequency[5]
	-- self.mBlockWaitTime = nil

	self.mInitiative = 100*self.mAIData.AI_Initiative[1]
	self.mLockInitiativeType = self.mAIData.AI_Initiative[2]

	--cclog("SSSSSSSSSSSSSSS======"..self.mInitiative)
	self.mAttackFrequency = 100*self.mAIData.AI_AttackFrequency[1]
	self.mAttackCoefficient = self.mAIData.AI_AttackFrequency[2]

	self.mWaiting = self.mAIData.AI_WaitingTime
	self.mRandomWaitTime = 0
	--针对远程怪
	self.mInitiative_ticktime = 0
	self.mAICurState = "none"
	self.mCurstateTime = 0
	self.mR200_Pos = 0

	self.mGongjiticktime = 0
	self.mGongjistate = "none"
	self.mSkillkey = nil
	self.mIsfollow = false
	self.mAstarPosTable = {}
	self.RunGoldPos = nil
	self.mTestTick = "none"
	--跳进不可达区域
	self.JumpAccessible = true
	--Ai 技能前摇
	self.SkillDelaylist = {}
	-- 锁定role InstanceID
	self.mLockInstanceID = nil

	-- 技能锁定 role 
	self.mSkillLockrole = nil
	--Ai技能冷却
	self.Skillspecial = {}
	self.Curspecialskill = nil
	-- 当前AI敌对 instanceId
	self.AILockinstance = nil
	-- 格挡之后操作

	self.mBlocktime = nil

	self.mAIStatePer = nil

	-- Ai场景执行ID
	self.mSceneListID = {}
	-- AI激活标记
	self.mActivateFriendAI = nil
	-- 主角激活
	self.mActivateAIKeyRole = nil
	-- 嘲讽对象
	self.mSneerRole = nil
end

function AIController:Destroy()
	self.mRoleData = nil
	--怪物视野
	self.mMonsterView = nil
	self.mOpenAI = nil
	self.mAIData = nil
	self.tableCondition = nil
	self.AIDaiji = true
	self.mNormalSkill_Index = nil
	self.mNormalSkill_ID = nil
	self.mCallNormalSkill_ID = nil
	self.mInitiative = nil
	self.mAttackFrequency = nil
	--针对远程怪
	self.mInitiative_ticktime = nil
	-- 互斥状态
	self.mAICurState = nil
	self.mCurstateTime = nil
	self.mR200_Pos = nil
	self.mGongjiticktime = nil
	self.mGongjistate = nil
	self.mSkillkey = nil
	--到达目标点
	self.DaodaGoalPos = nil
	self.AILockinstance = nil
	self.mRandomWaitTime = nil
end

function AIController:Tick(delta)
	if self.mIsDead then return end

	if StorySystem.mCGManager.mCGRuning then return end

	if self:AutoNextBoard(delta) then
		return
	end

	if self.mIsfollow and self.mOpenAI then
		self:FriendFollow(delta)
		return
	end
	if self.mRole.mFSM:IsDeading() then
		self.mNormalSkill_ID = 0
		self.mCallNormalSkill_ID = 0
		self.mIsDead = true
		return
	end
	self:TickSpeakPao(delta)
	if self:AIBuffState(delta) then
		return
	end
	if self.mOpenAI then
		if self:IsHallRole(delta) then return end
		if FightSystem.mFightType == "fuben" then
			if  FightSystem.mFubenManager.misAutoNextBoard then
				return 
			end
		end

		if self.mRole.mGroup == "friend" then
			if FightConfig.__DEBUG_FRIEND_AI_ then return end
		end
		if self.mRole.mGroup == "enemyplayer" or self.mRole.mGroup == "monster" then
			if FightConfig.__DEBUG_ENEMY_AI_ then return end
		end
		self:TickActionDelay(delta)
		self:TickCondition(delta)
		self:TickRunTimer(delta)
		self:TickSkillTimer(delta)
		if self.JumpAccessible then
			if FightSystem:getMapInfo(cc.p(self.mRole:getPositionX(),self.mRole:getPositionY()),self.mRole.mSceneIndex) ~= 1 then return end
			self:Celue_Tick(delta)
		end
	else
		if not self.mRole.IsShowTimeBorn then
			self:TickActivateCondition(delta)
		end
	end
end

function AIController:IsHallRole(delta)
	if self.mRole.mGroup == "hallrole" then
		if  self.mAICurState == "daiji"  then
			if self.mCurstateTime >= self.mRandomWaitTime then
				self.mCurstateTime = 0
				self.mAICurState = "none"
			else
				self.mCurstateTime = self.mCurstateTime + delta
				return true
			end
		elseif self.mAICurState == "move_r" then
			if self.mRole.mFSM:IsRuning() then
				return true
			end
			--*0125*self.mRole:WalkingByPos(self.mR200_Pos,handler(self,self.HallRolehoverGoalPos))
			self:WalkTurnRun(self.mR200_Pos,handler(self,self.HallRolehoverGoalPos))
			return true
		end
	
		self:Hover(delta)
		return true
	end
	return false
end

function AIController:HallRolehoverGoalPos()
	self:HallRoleDaiji()
end

function AIController:AutoNextBoard(delta)
	if FightSystem.mFightType ~= "fuben" then
		return false
	end
	if FightSystem.mFubenManager.misAutoNextBoard then
		if  FightSystem.mTouchPad.mAutoTouchAttack then
			if self.mRole.IsKeyRole then
				-- self.mRole:OnFTCommand(FightConfig.DIRECTION_CMD.DRIGHT, 0)
				
				if self.mRole.mFSM:IsRuning() then return true end

				local keyrolepos = FightSystem:GetKeyRole():getShadowPos()
				for k,v in pairs(FightSystem.mRoleManager:GetFriendTable()) do
					if not v.IsKeyRole then
						local leng = cc.pGetDistance(keyrolepos,v:getShadowPos())
						if leng > 150 then
							return true
						end
					end
				end
				local roles = FightSystem.mRoleManager:GetEnemyTable()
				local enemy = nil
				for k,v in pairs(roles) do
					if v.mRoleData.mInfoDB.Monster_Type ~= 2 then
						enemy = v
						break
					end
				end
				if enemy then
					self.DaodaGoalPos = enemy:getShadowPos()
					self.mRole:WalkingByPos(enemy:getShadowPos(),handler(self,self.OnStopNextBoardPos))
				else
					local _cmd = string.format("pve_%s+%d_move_%d_%d", self.mRole.mGroup, self.mRole.mInstanceID, FightConfig.DIRECTION_CMD.DRIGHT, 0)
					FCmdParseSystem.parseCommand(_cmd)
				end
				return true
			end	
		end	
	end
	return false
end

-- 设置AI跟随

function AIController:setAIFollow(isfollow)
	self.mIsfollow = isfollow
	if self.mIsfollow then
		self.mAstarPosTable = {}
	end	
	self:ResetAttack()
end

function AIController:FriendFollow(delta)
	local goalpos = self:FollowKeyRolePos(self.mRole.mPosIndex)
 	local monpos = self.mRole:getShadowPos()
	local leng = cc.pGetDistance(goalpos,monpos)
	local keyrole = FightSystem.mRoleManager:GetKeyRole()
	if not self.mRole.mFSM:IsAttacking() then 
		
			if leng > 100 then
				if self.mRole.mFSM:IsRuning() then
					return
				end
				-- if self.mTestTick == "findroad" then
				-- 	return
				-- end
				self.mRole:WalkingByPos(goalpos,handler(self,self.OnFollowStopGoalPos))
				
			end

			if leng < 50 then
				if not self.mRole.mFSM:IsIdle() then
					self:AIAllStop()
					-- local _cmd = string.format("pve_%s+%d_move_0_0", self.mRole.mGroup, self.mRole.mInstanceID)
					-- FCmdParseSystem.parseCommand(_cmd)
				end	
			end
	end		
end

function AIController:FollowKeyRolePos(roleid)
	local keyrole = FightSystem.mRoleManager:GetKeyRole()
	local goalposx = nil
	local goalposy = nil
	local posx = 0
	local posy = 0
	if keyrole.mPosIndex == 1 then
			if roleid == 2 then
				posy = 30
			elseif roleid == 3 then
				posy = -30
			end	
	elseif  keyrole.mPosIndex == 2 then
			if roleid == 1 then
				posy = 30
			elseif roleid == 3 then
				posy = -30
			end	
	elseif  keyrole.mPosIndex == 3 then
			if roleid == 1 then
				posy = 30
			elseif roleid == 2 then
				posy = -30
			end	
	end	
	if keyrole.IsFaceLeft then
		posx = 30
	else 
		posx = -30
	end	
	if self.mRole.mGroup == "summonfriend" then
		goalposx = keyrole:getShadowPos().x + posx
		goalposy = keyrole:getShadowPos().y
	else
		goalposx = keyrole:getShadowPos().x + posx
		goalposy = keyrole:getShadowPos().y + posy
	end

	-- if goalposy < 0 then
	-- 	goalposy = 0
	-- else
	-- 	if FightSystem:getMapInfo(cc.p(goalposx,goalposy),self.mRole.mSceneIndex) ~= 1 then
	-- 		for i=goalposy-10,0,-10 do
	-- 			if FightSystem:getMapInfo(cc.p(goalposx,i),self.mRole.mSceneIndex) == 1 then
	-- 				goalposy = i
	-- 				break
	-- 			end	
	-- 		end
	-- 	end
	-- end	

	if FightSystem:getMapInfo(cc.p(goalposx,goalposy),self.mRole.mSceneIndex) ~= 1 then
		goalposx = keyrole:getShadowPos().x
		goalposy = keyrole:getShadowPos().y
	end

	return cc.p(goalposx,goalposy)
end

function AIController:setActivateAI(_posX)
	self.mActivatePosX = _posX
end

function AIController:setOpenAI(open)
	if open then
		self.mActivateAIKeyRole = nil
		self.mActivateFriendAI = nil
		self.mRole:UnloadGun()
		self.mRole.mPickupCon:leavePickup()
	end
	self.mOpenAI = open	
	self.mAICurState = "none"
	self.mCurstateTime = 0
	self.mNormalSkill_Index = 0
	self.mNormalSkill_ID = 0
	self.mCallNormalSkill_ID = 0
	self:AIAllStop()
	self.Curspecialskill = nil
end

function AIController:isOpenAI()
	return self.mOpenAI
end

function AIController:setHallOpenAI(open)
	self.mOpenAI = open
end

function AIController:Init_condition()
	for i=1, self.mAIData.AI_ConditionCount do
		local condition = AICondition.new(i,self.mAIData,self,self.mRole)
		table.insert(self.tableCondition,condition)
	end
end

function AIController:RemoveCondition(index)
	for k,v in pairs(self.tableCondition) do
		if index == v.mIndex then
			table.remove(self.tableCondition,k)
		end
	end
end

function AIController:TickSpeakPao(delta)
	if not self.mSpeakId then return end
	if self.mSpeakDelayTime and self.mSpeakDelayTime > 0 then
		self.mSpeakDelayTime = self.mSpeakDelayTime - delta
		if self.mSpeakDelayTime <= 0 then
			self.mSpeakDelayTime = nil
			self:ShowSpeakPao(self.mSpeakId)
		end
	end
	if not self.mSpeakDelayTime and self.mSpeakContinueTime and self.mSpeakContinueTime > 0 then
		self.mSpeakContinueTime = self.mSpeakContinueTime - delta
		if self.mSpeakContinueTime <= 0 then
			self.mSpeakContinueTime = nil
			self:HideSpeakPao()
		end
	end
end

function AIController:TickActivateCondition(delta)
	if self.mRole.mGroup == "monster" and self.mActivatePosX then
		self:PlayRelax(delta)
		local friendRoles = FightSystem.mRoleManager:GetFriendTable(self.mRole.mSceneIndex)
		for k,v in pairs(friendRoles) do
			if v:getPositionX() >= self.mActivatePosX then 
				self:ActivateCondition()
				return
			end	
		end
	end
end

function AIController:OnActionEnd(_action)
	if self.mActivatePosX and self.mMonsterRelax  and (_action == "relax" or _action == "relax2" ) then
		if self.mRole.mFSM:IsIdle() then
			self.mRole.mArmature:ActionNow("stand", true)
		end
	end
end

function AIController:PlayRelax(delta)
	if self.mMonsterRelax then
		self.mRelaxTime = self.mRelaxTime + delta
		if self.mRelaxTime > 2 then
			self.mRelaxTime = 0
			local num = math.random(1,2)
			if num == 1 then
				self.mRelaxTime = -3
				local index = math.random(1,#self.mMonsterRelax)
				if self.mRole.mFSM:IsIdle() then
					self.mRole.mArmature:ActionNow(self.mMonsterRelax[index],false)
				end
			end
		end
	end
end

function AIController:ActivateCondition()
	if self.mActivateFriendAI then
		self.mActivateFriendAI = nil
		self:setOpenAI(true)
	end
	if self.mActivatePosX then
		self.mRole.mArmature:UnRegisterActionEnd("Monster_Relax")
		self.mMonsterRelax = nil
		self.mActivatePosX = nil
		self:setOpenAI(true)
	end
end

function AIController:TickActionDelay(delta)
	if not self.mActionDelaytime then return end
	self.mActionDelaytime = self.mActionDelaytime - delta
	if self.mActionDelaytime <= 0 then
		self.mActionDelaytime = nil
		self.mActionOpen = true
	end
	
end

function AIController:AIActionDelay(time)
	self.mActionDelaytime = time
	self.mActionOpen = false
end

function AIController:setSneerRole(_role)
	self.mSneerRole = _role
	if _role then
		self.mCurAIBuffState = "sneer"
	else
		self.mCurAIBuffState = nil
	end
end

-- 被嘲讽之后
function AIController:AIBuffState(delta)
	if self.mCurAIBuffState and self.mCurAIBuffState == "sneer" then
		if self.mSneerRole and self.mSneerRole.mIsLiving then
			if self.mRole.mFSM:IsAttacking() then
				return false
			end
			local con1 = self.mRole.mFSM:IsIdle()
			local con2 = self.mRole.mFSM:IsRuning()
			local con4 = self.mRole:IsControlByStaticFrameTime()
			if (con1 or con2) and not con4 then
				local pos = self.mSneerRole:getShadowPos()
				local isAttackRange = self.mRole.mSkillCon:IsInSkillRangeBySkillID("pos",self.mRoleData[self.mSkillNorSkill1],pos,true,{150,100})
				if isAttackRange then
					--怪物有攻击范围攻击
					self.mRole:PlaySkillByID(self.mRoleData[self.mSkillNorSkill1])
				else	
					if FightSystem:getMapInfo(pos,self.mRole.mSceneIndex) ~= 1 then
						self:ResetAttack()
						self.mCurAIBuffState = nil
						return false
					end
					self.mRole:WalkingByPos(pos,handler(self,self.OnSneerpGoalPos))
				end
			end
		else
			self.mCurAIBuffState = nil
			if self.mRole.mGroup == "friend" and self.mRole.IsKeyRole then
				-- 做下TouchPad显示
				FightSystem.mTouchPad:DisabledSkill(false)
				FightSystem.mTouchPad:DisabledAttack(false)
				FightSystem.mTouchPad:DisabledMove(false)
				FightSystem.mTouchPad:setCancelledTouchMove(false)
			end
			self:ResetAttack()
			return false
		end
		return true
	end
	return false
end

function AIController:Celue_Tick(delta)
	if not self.mActionOpen then return end
	if self:IsFrameTimeorIsBeatingStiff() then 
		return 
	end
	-- if TiledMoveHandler.IsOnWall(self.mRole:getPosition_pos(),self.mRole.mSceneIndex) then
	-- 	return
	-- end
	if self.mAIData.AI_BaseType == 1 then
		self:NearFightTick(delta)
	elseif self.mAIData.AI_BaseType == 2  then
		self:FarFightTick(delta)
	elseif self.mAIData.AI_BaseType == 3  then
		self:DeadmanFightTick(delta)
	elseif self.mAIData.AI_BaseType == 4  then
		self:GudingFightTick(delta)
	end	
end

-- 有目标调整人物方向
function AIController:GoalTurnByPosX()
	local role = self:LockGoalRole()
	if role and (self.mRole.mFSM:IsIdle() or self.mRole.mFSM:IsRuning()) then
		if self.mAICurState == "findgoal" or self.mAICurState =="find_attacking" or self.mAICurState == "daiji" or self.mAICurState == "paolu" or self.mAICurState =="move_r" then
			Pos = role:getShadowPos()
			self:TargetTurnByPosX(Pos.x)
			return true
		end
	end
	return false
end

function AIController:AttackRoleByMove(delta)
	if self.mRole.mFSM:IsAttacking() and self.mRole.mMoveCon:canMove() then
		if self.mRole.mGroup == "friend" or self.mRole.mGroup == "monster" or self.mRole.mGroup == "enemyplayer" then
			local goalRole ,_type = self:GetRoleByNearPos()
			if goalRole then
				local Pos = nil
				if _type == "sceneAni" then
					Pos = goalRole:getPosition_pos()
				else
					Pos = goalRole:getShadowPos()
				end
				if cc.pGetDistance(self.mRole:getShadowPos(),Pos) > 20 then
					self.mRole.mMoveCon:StartMoveByPos(Pos)
				end
			end
		end
	end
end

function AIController:NearFightTick(delta)
	self:AttackRoleByMove()
	if self.mAICurState == "findgoal" then
		if self.mRole.mGroup == "friend" or self.mRole.mGroup =="enemyplayer" or self.mRole.mGroup == "cgfriend" or self.mRole.mGroup == "summonfriend" then
			self:FindFriendgoal(delta) 
		elseif  self.mRole.mGroup == "monster" or self.mRole.mGroup == "summonmonster" then
			if self.mMonsterType and self.mMonsterType == 2 then
				self:DeadmanFindgoal(delta)
			else
				self:Findgoal(delta)
			end
		else
			self:ResetAttack()
		end
	elseif  self.mAICurState == "astarwalk"  then

	elseif  self.mAICurState == "soonspecoalskill"  then
		if self.Curspecialskill then
			if #self.SkillDelaylist == 0 and  not self.mRole.mFSM:IsAttacking() then
				self:ResetAttack()
				return
			end
			if not self:IsAIcanWork() then
				self.Curspecialskill = nil
				self:ResetAttack()
			end
			return
		end
		local specialCount = nil
		for k,v in pairs(self.Skillspecial) do
			specialCount = true
			break
		end
		if not specialCount then
			self:ResetAttack()
			return 
		else
			self:SoonSkillgoal(delta)
			return
		end
	elseif  self.mAICurState == "blocking"  then
		if not self.mBlocktime then return end
		self.mBlocktime = self.mBlocktime - delta
		local function FunBlockend()
			self:ResetAttack()
		end
		if self.mBlocktime <= 0 then
			self.mBlocktime = nil
			if not self.mRole:StopBlock(FunBlockend) then
				self:ResetAttack()
			end
		end 
	elseif  self.mAICurState == "find_attacking"  then
		self:FindAttackGoal(delta)
	elseif  self.mAICurState == "daiji"  then
		self.mNormalSkill_Index = 0
		self.mNormalSkill_ID = 0
		self.mCallNormalSkill_ID = 0
		if self.mCurstateTime >= self.mRandomWaitTime then
			self.mCurstateTime = 0
			self.mAICurState = "none"
		else
			self.mCurstateTime = self.mCurstateTime + delta
			return
		end
	elseif  self.mAICurState == "paolu"  then
		if self.mRole.mGroup == "friend" or self.mRole.mGroup =="enemyplayer" or self.mRole.mGroup == "cgfriend" or self.mRole.mGroup == "summonfriend" then
			-- 人找怪物
			self:PlayerFindMonster(delta)
		end
	elseif  self.mAICurState == "taoquangongji"  then
		self:XunhuanGongji()
	elseif  self.mAICurState == "move_r"  then
			self.mNormalSkill_Index = 0
			self.mNormalSkill_ID = 0
			self.mCallNormalSkill_ID = 0
			if self.mRole.mFSM:IsRuning() then
				return
			end
		
			--*0125*self.mRole:WalkingByPos(self.mR200_Pos,handler(self,self.OnMovehoverGoalPos))
			self:WalkTurnRun(self.mR200_Pos,handler(self,self.OnMovehoverGoalPos))
	elseif  self.mAICurState == "none"  then
			self.mGongjistate = "none"
			self.mGongjiticktime = 0
			self.mNormalSkill_Index = 0
			self.mNormalSkill_ID = 0
			self.mCallNormalSkill_ID = 0
			if self.mMonsterType and self.mMonsterType == 2 then
				self:InitiativeDeadMan()
			else
				self:InitiativeLevel()
			end
			
	end
end

function AIController:FarFightTick(delta)

end

function AIController:DeadmanFightTick(delta)

end

function AIController:GudingFightTick(delta)

end

function AIController:GetRoleByFarPos()

end

function AIController:GetRoleByNearPos( resetfindrole )
	local role = nil
	local _type = nil
	if not resetfindrole and self.mNearRole and self.mNearRole.mIsLiving and self.mNearRole.mGroup ~= "sceneani" and self.mNearRole.mPropertyCon.mCurHP > 0 then
		return self.mNearRole , self.mNearRtype
	end
	if FightSystem.mFightType == "arena" then
		role, _type = self:GetRoleByNearArenaPos(resetfindrole)
	elseif FightSystem.mFightType == "fuben" then
		if FightSystem:GetFightManager().mFubenModel == 7 and self.mRole.mGroup == "monster" then
			if self.mNearRole and not self.mNearRole.mInstanceID then return nil end
			role, _type  = self:GetModelSceneAni(FightSystem:GetFightManager().mFubenModelParameter)
		else
			role, _type = self:GetRoleByNearFubenPos(resetfindrole)
		end
	end
	return role , _type
end

function AIController:GetModelSceneAni(InstanceID)
	for k,v in pairs(FightSystem.mRoleManager.mSceneAniList) do
		if v.mDB.ID == InstanceID then
			return v , "sceneAni"
		end
	end
	return nil
end

function AIController:LockGoalRole()
	if FightSystem.mFightType == "fuben" then	
		local enemyroles = self:GetRolesTable()
		if not enemyroles or #enemyroles == 0 then
			return nil
		end
		if self.AILockinstance then
			for k,v in pairs(enemyroles) do
				if v.mInstanceID == self.AILockinstance then
					if v.mPropertyCon.mCurHP > 0 and v:CanbeBeated() then
						return v
					else
						return nil
					end
				end
			end
		end
	end
	return nil
end

function AIController:GetRoleByNearFubenPos()
	local GoalRole = nil
	--[[
	local CurmOnsterView = self.mMonsterView

	local Left = 0
	local Right = 0
	if FightSystem.mFightType == "fuben" then
		Left = FightSystem.mFubenManager:GetLeftLineX()
		Right = FightSystem.mFubenManager:GetRightLineX()
	elseif FightSystem.mFightType == "arena" then
		Left = 0
		Right = FightSystem.mSceneManager:GetTiledLayer(self.mRole.mSceneIndex).mWidth
	end
	
	if self.mRole:getPositionX() < Left then
		CurmOnsterView = CurmOnsterView + 1140
	elseif self.mRole:getPositionX() > Right then
		CurmOnsterView = CurmOnsterView + 1140
	end
	]]
	local enemyroles = self:GetRolesTable()
	if not enemyroles or #enemyroles == 0 then
		return nil
	end
	if self.AILockinstance then
		for k,v in pairs(enemyroles) do
			if v.mInstanceID == self.AILockinstance then
				if v.mPropertyCon.mCurHP > 0 and v:CanbeBeated() then
					return v
				else
					self.AILockinstance = nil
					break
				end
				
			end
		end
	end
	--[[
	local index = 0
	local roleshortDis = nil
	local shortDisleng = nil
	local function xxxx( ... )
			for k,v in pairs(enemyroles) do
				if v.mPropertyCon.mCurHP > 0 and v:CanbeBeated() then
					 local goalpos = cc.p(v:getPosition_pos())
					 if self.mRole.mGroup == "friend" or self.mRole.mGroup == "summonfriend" then
					 	 if goalpos.x >= Left and goalpos.x<= Right then
					 	 	 if globaldata.PvpType == "blackMarket" and v.mGroup == "monster" then
					 	 	 
					 	 	 else
					 	 	 	local monpos = self.mRole:getShadowPos()
								local leng1 = cc.pGetDistance(goalpos,monpos)
								index = index + 1
								roles[index] = v
								if not shortDisleng then
									roleshortDis = v
									shortDisleng = leng1
								elseif shortDisleng > leng1 then
									roleshortDis = v
									shortDisleng = leng1
								end
					 	 	 end
					 	 end	
					 else
					 	 local monpos = self.mRole:getShadowPos()
						 local leng1 = cc.pGetDistance(goalpos,monpos)

						 if CurmOnsterView >= leng1 then
						 	index = index + 1
							roles[index] = v
							if not shortDisleng then
								roleshortDis = v
								shortDisleng = leng1
							elseif shortDisleng > leng1 then
								roleshortDis = v
								shortDisleng = leng1
							end
						 end
					 end	
				end
			end
	end
	]]
	local roles = {}
	local index = 0
	local roleshortDis = nil
	local shortDisleng = 1000000
	local monpos = self.mRole:getShadowPos()
	local function xxxx( ... )
		for k,v in pairs(enemyroles) do
			if v.mPropertyCon.mCurHP > 0 then
				local goalpos = v:getPosition_pos()
				local leng1 = (goalpos.x - monpos.x)*(goalpos.x - monpos.x) + (goalpos.y - monpos.y)*(goalpos.y - monpos.y)
				index = index + 1
				roles[index] = v
				if shortDisleng > leng1 then
					roleshortDis = v
					shortDisleng = leng1
				end
			end
		end
	end
	xxxx()

	if #roles == 0 then
		return nil
	end
	local num = math.random(1,#roles)
	if self.mLockInitiativeType == 0 then
		if roles[num] then
			if self:ExamineRole(roles[num]) then
				self.AILockinstance = roles[num].mInstanceID
			end
		end
		return self:ExamineRole(roles[num])
	elseif self.mLockInitiativeType == 1 then
		return self:ExamineRole(roles[num])
	elseif self.mLockInitiativeType == 2 then
		return self:ExamineRole(roleshortDis)
	end
end

function AIController:ExamineRole(role)
	if not role then return false end
	local CurmOnsterView = self.mMonsterView
	local Left = 0
	local Right = 0
	if FightSystem.mFightType == "fuben" then
		Left = FightSystem.mFubenManager:GetLeftLineX()
		Right = FightSystem.mFubenManager:GetRightLineX()
	elseif FightSystem.mFightType == "arena" then
		Left = 0
		Right = FightSystem.mSceneManager:GetTiledLayer(self.mRole.mSceneIndex).mWidth
	end
	
	if self.mRole:getPositionX() < Left then
		CurmOnsterView = CurmOnsterView + 1140
	elseif self.mRole:getPositionX() > Right then
		CurmOnsterView = CurmOnsterView + 1140
	end
	if role:CanbeBeated() then
		 local goalpos = cc.p(role:getPosition_pos())
		 if self.mRole.mGroup == "friend" or self.mRole.mGroup == "summonfriend" then
		 	 if goalpos.x >= Left and goalpos.x <= Right then
		 	 	 if globaldata.PvpType == "blackMarket" and role.mGroup == "monster" then
					return false
		 	 	 end
		 	 else
		 	 	return false
		 	 end	
		 else
			return role
		 end	
	else
		return false
	end
	return role
end

function AIController:GetRoleByNearArenaPos()
	local leng = -1
	local GoalRole = nil
	local enemyroles = self:GetRolesTable()
	if not enemyroles or #enemyroles == 0 then
		return nil
	end
	local monpos = self.mRole:getShadowPos()
	for k,v in pairs(enemyroles) do
		 if v.mPropertyCon.mCurHP > 0 then
		 	 local goalpos = v:getPosition_pos()
			 local leng1 = (goalpos.x - monpos.x)*(goalpos.x - monpos.x) + (goalpos.y - monpos.y)*(goalpos.y - monpos.y)
			 if leng == -1 then
		 		leng = leng1
		 		GoalRole = v
			 else 
		 		if leng > leng1 then
		 			leng = leng1
		 			GoalRole = v
		 		end	
			 end
		 end
	end
	return self:ExamineRole(GoalRole) 
end

function AIController:GetRolesTable()
	if self.mRole.mGroup == "friend" or self.mRole.mGroup == "cgfriend" or self.mRole.mGroup == "summonfriend" then
		return FightSystem.mRoleManager:GetEnemyTable(self.mRole.mSceneIndex)
	elseif self.mRole.mGroup =="enemyplayer" or self.mRole.mGroup == "monster" or self.mRole.mGroup == "summonmonster" then
		return FightSystem.mRoleManager:GetFriendTable(self.mRole.mSceneIndex)
	end
end

function AIController:XunhuanGongji()
	if  self.mRole:IsControlByStaticFrameTime() then return end
	if not self:IsAIcanWork() or self.mRole.mFSM:IsIdle() then self:ResetAttack() return end
	if  self.mNormalSkill_ID ==  self.mCallNormalSkill_ID then
		self.mCallNormalSkill_ID = 0

		if not self:IsCoefficient(self.mNormalSkill_Index) then
			self:ResetAttack()
			return
		end
		if self.mNormalSkill_Index == 0 then

			local lockrole , _type= self:GetRoleByNearPos()
			if not _type then
				_type = "role"
			end
			if not lockrole then
				self:ResetAttack()
                return 
			end
			local keyskill = self.mSkillNorSkill1

			if _type == "sceneAni" then
				self:TargetTurnByPosX(lockrole:getPosition_pos().x)
			else
				self:TargetTurnByPosX(lockrole:getShadowPos().x)
			end

			local gongji = self.mRole.mSkillCon:IsInSkillRangeBySkillID(_type, self.mRoleData[keyskill],lockrole)
			if not gongji then 
				self:ResetAttack()
                return 
			end
			if not self.mRole:PlaySkillByID(self.mRoleData[keyskill]) then
                  self:ResetAttack()
                  return 
            end 
			self.mNormalSkill_ID = self.mRoleData[keyskill]
			self.mNormalSkill_Index = 1
		else 
			local nextskill = self.mNormalSkill_Index + 1
			if nextskill > self.mRoleData.mNormalSkillMaxCount then
				self:Daiji_state()
				self.mNormalSkill_Index = 0
				self.mCallNormalSkill_ID = 0
				self.mNormalSkill_ID = 0
				return
			end
			--[[
			local tempnextskill = nextskill
			if self.mRole.mGroup =="enemyplayer" or self.mRole.mGroup == "friend" then
				 if nextskill == 4 then
          			local num = 0--math.random(0,1)
          			tempnextskill = nextskill + num
     			 end
			end
			]]

			local key1 = string.format("%s%d",self.NormalSkill_key,nextskill)
			if self.mRoleData[key1] == 0 then
				self:Daiji_state()
				self.mNormalSkill_Index = 0
				self.mCallNormalSkill_ID = 0
				self.mNormalSkill_ID = 0
				return
			else
			
				local lockrole , _type = self:GetRoleByNearPos()
				if not _type then
					_type = "role"
				end
				if not lockrole then
					self:ResetAttack()
	                return 
				end

				if _type == "sceneAni" then
					self:TargetTurnByPosX(lockrole:getPosition_pos().x)
				else
					self:TargetTurnByPosX(lockrole:getShadowPos().x)
				end	
				local gongji = self.mRole.mSkillCon:IsInSkillRangeBySkillID(_type, self.mRoleData[key1],lockrole)
				if not gongji then 
					self:ResetAttack()
	                return 
				end
				if not self.mRole:PlaySkillByID(self.mRoleData[key1]) then
	                  self:ResetAttack()
	                  return 
	            end 
				self.mNormalSkill_ID = self.mRoleData[key1]
				self.mNormalSkill_Index = nextskill
			end	
		end
	end
end

function AIController:IsCoefficient(_index)
	if _index < 3 then return true end
	local j = _index 
	local AttackCoefficient = self.mAttackCoefficient
	AttackCoefficient = AttackCoefficient*100
	local num = math.random(1,100)
	if AttackCoefficient < num then
		return false
	end
	return true
end

function AIController:Far_Escapefrom(role,delta)
 	
end

-- 状态转换回调
function AIController:OnFSMEvent(_from, _to, _data)
	--cclog("=====AIController:OnFSMEvent=====From:  " .. _from .. "===To:  " .. _to)
	if self.mActivateAIKeyRole and self.mRole.mGroup == "friend" then
		self.mActivateAIKeyRole = nil
		local roles = FightSystem.mRoleManager:GetFriendTable()
		for k,v in pairs(roles) do
			if not v.IsKeyRole then
				if v.mGroup == "friend" then
					v.mAI:ActivateCondition()
				end
			end
		end
	end
	if self.mAICurState == "paolu" then
		if _to ~= "runing" then
			if self.mBehaviorWalk then
				self:ResetAttack()
				self.mBehaviorWalk = true
			else
				self:ResetAttack()
			end
			return
		end
	end
	if self.mAICurState == "astarwalk" then
		if _to == "idle" or _to == "runing" then
		else
			self:ResetAttack()
		end
	end
	if _to == "idle" then

	elseif _to == "runing" then

	elseif _to == "jumping" then

	elseif _to == "attacking" then

	elseif _to == "dead" then
	
	elseif _to == "beatingstiff" then

	end
end

function  AIController:InitiativeDeadMan()
	local random_Initiative = math.random(1, 100)
	if random_Initiative <= self.mInitiative then
		local Role = self:GetRoleByNearPos()
		if Role then
			self.mAICurState = "findgoal"
		else
			self:Daiji_state()
		end
	else
		self:Daiji_state()
	end
end

-- AI智能程度
function  AIController:InitiativeLevel()
	local random_Initiative = math.random(1, 100)
	if random_Initiative <= self.mInitiative then
		--当前达到主动性范围
		local Role , Rtype = self:GetRoleByNearPos(true)
		if Role then
			--寻找人
			self.mNearRole = Role
			self.mNearRtype = Rtype
			self.mAICurState = "findgoal"
		else
			--cclog("self:Hover(delta) 111==" ..self.mInitiative)
			self:Hover()
		end	
	else
		--cclog("self:Hover(delta) 222==" ..self.mInitiative)
		self:Hover()
	end		
end

--徘徊
function  AIController:Hover()
	local random_num = math.random(1, 2)
	if  FightConfig.__DEBUG_AI_NOPAIHUAI then
		random_num = 1
	end
	
	if random_num == 1 then
		self:Daiji_state()
	else
		self.mAICurState = "move_r"
		self:Run_Migration_Pos()
	end
end

function  AIController:Run_Migration_Pos()
	local  x = self.mRole:getShadowPos().x
	local  y = self.mRole:getShadowPos().y

	local random_X = math.random(1,300)
	local random_Y = math.random(1,300)
	
	x = x + FightConfig.TABLE_RUNRANGE[random_X]
	y = y + FightConfig.TABLE_RUNRANGE[random_Y]

	if FightSystem:GetFightManager().mLeftLineX > x + self.mRole.mSize.width/2 then
		x = FightSystem:GetFightManager().mLeftLineX + self.mRole.mSize.width/2
	end

	if FightSystem:GetFightManager().mRightLineX < x - self.mRole.mSize.width/2 then
		x = FightSystem:GetFightManager().mRightLineX - self.mRole.mSize.width/2
	end

	if y < 0 then
		y = 0
	else
		if FightSystem:getMapInfo(cc.p(x,y),self.mRole.mSceneIndex) ~= 1 then
			for i=y-10,0,-10 do
				if FightSystem:getMapInfo(cc.p(x,i),self.mRole.mSceneIndex) == 1 then
					y = i
					break
				end	
			end
		end
	end	
	self.mR200_Pos = cc.p(x,y)
	--cclog("AIController:Hover  x == " .. x .. " ---------y == " .. y)
end

-- 嘲讽行走
function  AIController:OnSneerGoalPos(type)
	if not self:IsAIcanWork() then
		self:ResetAttack()
		return 
	end
	if type == "daoda" then
		self:AIAllStop()
	elseif type == "notcanmove" then
		if FightSystem:getMapInfo(self.DaodaGoalPos,self.mRole.mSceneIndex) ~= 1 then
			self:ResetAttack()
			return
		end
		local function xxx()
			return FightSystem:GetReachablePaths(self.mRole:getShadowPos(),self.DaodaGoalPos,self.mRole.mSceneIndex)
		end
		local aa = caculateFuncDuring("FightSystem:GetReachablePaths", xxx)
		if #aa == 0 then
			self:ResetAttack()
			return
		end
		self:AstarRun(aa)
		self:AstarRunAction()
	end
end

function  AIController:OnStopGoalPos(type)
	if not self:IsAIcanWork() then
		self:ResetAttack()
		return 
	end
	if type == "daoda" then
		if self.mBehaviorWalk then
			self:ResetAttack()
		else
			self.mAICurState = "find_attacking"
			self.mCurstateTime = 0
			self:AIAllStop()
		end
	elseif type == "notcanmove" then
		if FightSystem:getMapInfo(self.DaodaGoalPos,self.mRole.mSceneIndex) ~= 1 then
			self:ResetAttack()
			return
		end
		local function xxx()
			return FightSystem:GetReachablePaths(self.mRole:getShadowPos(),self.DaodaGoalPos,self.mRole.mSceneIndex)
		end
		local aa = caculateFuncDuring("FightSystem:GetReachablePaths", xxx)
		if #aa == 0 then
			self:ResetAttack()
			return
		end
		self.mTestTick = "findroad"
		self.mAICurState = "astarwalk"
		self:AstarRun(aa)
		self:AstarRunAction()
		--self.mRole.mFSM:ChangeToState("runing")
	end
end

function  AIController:OnStopNextBoardPos(type)
	if not self:IsAIcanWork() then
		self:ResetAttack()
		return 
	end
	if type == "daoda" then
		self.mAICurState = "none"
		self:AIAllStop()
	elseif type == "notcanmove" then
		if FightSystem:getMapInfo(self.DaodaGoalPos,self.mRole.mSceneIndex) ~= 1 then
			self:ResetAttack()
			return
		end
		local function xxx()
			return FightSystem:GetReachablePaths(self.mRole:getShadowPos(),self.DaodaGoalPos,self.mRole.mSceneIndex)
		end
		local aa = caculateFuncDuring("FightSystem:GetReachablePaths", xxx)
		if #aa == 0  then
			return
		end
		self.mTestTick = "findroad"
		self:AstarRun(aa)
		self:AstarRunAction()
		--self.mRole.mFSM:ChangeToState("runing")
	end
end

function  AIController:OnMovehoverGoalPos(type)
	self:Daiji_state()
end

function  AIController:OnFollowStopGoalPos(type)
	--cclog("AIController:OnStopGoalPos==" .. type)
	if not self:IsAIcanWork() then 
		--cclog("ResetAttack===7")
		self:ResetAttack()
		return 
	end
	if type == "daoda" then
		self.mAICurState = "none"
	elseif type == "notcanmove" then
		local goalpos = self:FollowKeyRolePos(self.mRole.mPosIndex)
	 	local monpos = self.mRole:getShadowPos()
		local leng = cc.pGetDistance(goalpos,monpos)
		if FightSystem:getMapInfo(goalpos,self.mRole.mSceneIndex) ~= 1 then
			return
		end
		if FightSystem:getMapInfo(goalpos,self.mRole.mSceneIndex) ~= 1 then
			self:ResetAttack()
			return
		end
		-- local function xxx()
		-- 	doError(string.format("X=%f,Y=%f",self.mRole:getShadowPos().x,self.mRole:getShadowPos().y))
		-- 	doError(string.format("DaodaGoalPos =X=%f,Y=%f",self.DaodaGoalPos.x,self.DaodaGoalPos.y))
		-- 	return 
		-- end
		local aa = FightSystem:GetReachablePaths(self.mRole:getShadowPos(),self.DaodaGoalPos,self.mRole.mSceneIndex)
		if not aa or #aa == 0  then
			return
		end
		self:AstarRun(aa)
		self:AstarRunAction()
		--self.mRole.mFSM:ChangeToState("runing")	
	end	
end


function AIController:AstarGoalPos()
	--cclog("AIController:AstarGoalPos")

	if not self:IsAIcanWork() then 
		self:ResetAttack()
		self:AIAllStop()
		return 
	end
	if #self.mAstarPosTable  == 0 then
		-- 
		if self.mBehaviorWalk then
			self:ResetAttack()
			self:AIAllStop()
		else
			self.mAICurState = "find_attacking"
			self:AIAllStop()
		end
	else
		self:AstarRunAction()
	end
end

function AIController:AttackFindSkill()
	local  skillID = self.mSkillNorSkill1
	-- for i=1, self.mSkillMaxNum do
	-- 	local key =self.SpecialSkill_key .. i

	-- 	if self.mRoleData[key] ~= 0 then
	-- 		if not self.mRole.mSkillCon:IsSkillInCoolDown(self.mRoleData[key]) then
	-- 			skillID = key
	-- 			return skillID
	-- 		end
	-- 	else
	-- 		return skillID
	-- 	end	
	-- end
	return skillID
end

function AIController:ResetAttack(_type)
	--[[
	if self.mAICurState == "blocking" then
		if self.mRole.mFSM:IsBlock() then
			self.mRole.mFSM:ForceChangeToState("idle")
		end
	end
	]]
	-- if _type then
	-- 	self.mAICurState = "none"
	-- else
	-- 	if self.mAICurState ~= "soonspecoalskill" then
	-- 		self.mAICurState = "none"
	-- 	end
	-- end
	self.mBehaviorWalk = false
	if self.mWaitsoonskill then
		self.mAICurState = "soonspecoalskill"
		self.mWaitsoonskill = nil
	else
		self.mAICurState = "none"
		self.Skillspecial = {}
		self.SkillDelaylist = {}
		self.Curspecialskill = nil
	end
	self.mCurstateTime = 0
	self.mNormalSkill_Index = 0
	self.mNormalSkill_ID = 0
	self.mCallNormalSkill_ID = 0
	self.mBlockWaitTime = nil
	self.mBlocktime = nil
	self.IsWaitTime = nil
	self:AIAllStop()
end

-- hallrole 待机
function AIController:HallRoleDaiji()
	self.mAICurState = "none"
	local count = self.mWaiting[2] - self.mWaiting[1]
	local ran = math.random(1,100)
	self.mRandomWaitTime = self.mWaiting[1] + ran*0.01*count
end

--待机
function AIController:Daiji_state()
	self.mAICurState = "daiji"
	self.mCurstateTime = 0
	self.mNormalSkill_Index = 0
	self.mNormalSkill_ID = 0
	self.mCallNormalSkill_ID = 0
	local count = self.mWaiting[2] - self.mWaiting[1]
	local ran = math.random(1,100)
	self.mRandomWaitTime = self.mWaiting[1] + ran*0.01*count
	self:AIAllStop()
end

-- 格挡随机
function AIController:AIBlock()
	if self.mBlockproba >= math.random(1,100) then
		if self.mRole.mFSM:IsIdle() or self.mRole.mFSM:IsRuning() then
			if not self.mRole:PlayBlock() then return false end
			local count = self.mBlockproba_end - self.mBlockproba_start
			local ran = math.random(1,100)
			self.mBlocktime = self.mBlockproba_start + count*0.01*ran
			self.mAIStatePer = self.mAICurState 
			self.mAICurState = "blocking"
			return true
		else
			return false
		end
	else
		return false
	end
end

-- 技能回调格挡
function AIController:BlockBySkill(_role,_skillID)
	if self.AILockinstance == _role.mInstanceID then
		if self.mRole.mFSM:IsIdle() or self.mRole.mFSM:IsRuning() then
			if not self.Curspecialskill then
				local gongji = _role.mSkillCon:IsInSkillRangeBySkillID("role", _skillID,self.mRole)
				if gongji then
					self:AIBlock()
				end
			end	
		end
	end
end

--等待格挡随机
function AIController:TickWaitBlock(delta)
	-- if self.mBlockWaitTime then
	-- 	self.mBlockWaitTime = self.mBlockWaitTime - delta
	-- 	if self.mBlockWaitTime <= 0 then
	-- 		self.mBlockWaitTime = nil
	-- 		return false
	-- 	end
	-- 	return true
	-- end
	-- return false
end


-- 设置等待格挡时间
function AIController:SetWaitBlockTime()
	-- if self.IsWaitTime then return false end
	-- self.IsWaitTime = true
	-- if self.mBlockWait1 == 0 then
	-- 	return false
	-- else
	-- 	local count =  self.mBlockWait2 - self.mBlockWait1
	-- 	local ran = math.random(1,100)
	-- 	self.mBlockWaitTime = self.mBlockWait1 + count*0.01*ran
	-- 	return true
	-- end
end

--到达当前 目的地
function AIController:FindAttackGoal(delta)
	if self:TickWaitBlock(delta) then return end

	local goalRole , _type = self:GetRoleByNearPos()
	if goalRole then
		local Pos = nil
		local skill = nil
		local isAttackRange = nil
		if _type == "sceneAni" then
			--Pos = goalRole:getPosition_pos()
			self:TargetTurnByPosX(goalRole:getPosition_pos().x)
			skill,isAttackRange = self:SkillFindSceneAni(goalRole)
		else
			Pos = goalRole:getShadowPos()
			self.DaodaGoalPos = Pos
			self:TargetTurnByPosX(Pos.x)
			skill,isAttackRange = self:SkillFindRole(self.DaodaGoalPos)
		end
		if isAttackRange then
			if self.mAttackFrequency >= math.random(1,100) then
				self.IsWaitTime = false
				--debugLog("AAAAAAAAAAAAA=======2=========="..self.mSkillkey.. "=====FACE==" ..face .."==WO==POS="..self.mRole:getShadowPos().x .."=====DIREN==POSX" ..Pos.x)
				self:SkillPlay(skill)
			else
				self.IsWaitTime = false
				self:Daiji_state()
				return
			end
		else
			self:Daiji_state()
		end
	else
		self:Daiji_state()
	end		
end

function AIController:SkillFindSceneAni(_sceneAni)
	local isAttackRange = nil
	local skill = nil
	for k,v in pairs(self.Skillspecial) do
		if v.AI_BehaviorParam4 ~= 1 then
			skill = k
			break
		end
	end
	if skill then
		isAttackRange = self.mRole.mSkillCon:IsInSkillRangeBySkillID("sceneAni", skill,_sceneAni)
	else
		self.mSkillkey = self.mSkillNorSkill1
		isAttackRange = self.mRole.mSkillCon:IsInSkillRangeBySkillID("sceneAni", self.mRoleData[self.mSkillkey],_sceneAni)	 
	end
	return skill,isAttackRange
end

function AIController:SkillFindRole(pos)
	local isAttackRange = nil
	local skill = nil
	for k,v in pairs(self.Skillspecial) do
		if v.AI_BehaviorParam4 ~= 1 then
			skill = k
			break
		end
	end
	if skill then
		isAttackRange = self.mRole.mSkillCon:IsInSkillRangeBySkillID("pos", skill,pos)
	else
		self.mSkillkey = self.mSkillNorSkill1
		isAttackRange = self.mRole.mSkillCon:IsInSkillRangeBySkillID("pos", self.mRoleData[self.mSkillkey],pos)	 
	end
	return skill,isAttackRange
end

function AIController:GetputSkill()
	local skill = nil
	for k,v in pairs(self.Skillspecial) do
		if v.AI_BehaviorParam4 ~= 1 then
			skill = k
			break
		end
	end
	if skill then
		return skill
	else
		return self.mRoleData[self.mSkillNorSkill1]
	end
end

function AIController:SkillSoonPlay(skill)
	if skill then
		for k,v in pairs(self.Skillspecial) do
			if v.AI_BehaviorParam1 == skill then
				if self.mRole:isCanPlaySkillByID(skill) then
					self:Behavior_SkillId(v.AI_BehaviorParam1,v.AI_BehaviorParam2,v.AI_BehaviorParam3)
					break
				end
			end
		end
	end
end

function AIController:SkillPlay(skill)
	if self.mCurAIBuffState then return end
	if skill then
		for k,v in pairs(self.Skillspecial) do
			if v.AI_BehaviorParam1 == skill then
				if self.mRole:isCanPlaySkillByID(skill) then
					self:Behavior_SkillId(v.AI_BehaviorParam1,v.AI_BehaviorParam2,v.AI_BehaviorParam3)
					break
				end
			end
		end
	else
		if not self:IsCoefficient(0) then
			self:ResetAttack()
			return 
		end
		if not self.mRole:PlaySkillByID(self.mRoleData[self.mSkillkey]) then
			self:ResetAttack()
			return 
		else

			self.mNormalSkill_ID = self.mRoleData[self.mSkillkey]
			self.mCallNormalSkill_ID = 0
			self.mNormalSkill_Index = 1
			self.mAICurState = "taoquangongji"
		end
	end
end

-- 木桩找人
function AIController:DeadmanFindgoal(delta)
	local goalRole ,_type = self:GetRoleByNearPos()
	if goalRole then
		local Pos = nil
		if _type == "sceneAni" then
			Pos = goalRole:getPosition_pos()
		else
			Pos = goalRole:getShadowPos()
		end
		if self.mRole.mFSM:IsIdle() then
			--看当前技能
			local skill,isAttackRange = self:SkillFindRole(Pos)
			if isAttackRange then
				--怪物有攻击范围攻击
				if self.mAttackFrequency >= math.random(1,100) then
					self:SkillPlay(skill)
				else
					self:Daiji_state()
					return
				end
			end
		else
			self.mAICurState = "none"
			self.mCurstateTime = 0
		end
	end
end

function AIController:TargetTurnByPosX(_x)
	-- if self.mRole:getShadowPos().x < _x then
	-- 	if self.mRole.IsFaceLeft then
	-- 		self.mRole:FaceRight()
	-- 	end
	-- elseif self.mRole:getShadowPos().x > _x then
	-- 	if not self.mRole.IsFaceLeft then
	-- 		self.mRole:FaceLeft()
	-- 	end
	-- end
end

function AIController:WalkTurnRun(_pos,_callfun)
	local tiaozheng = self:GoalTurnByPosX()
	local _curPos = self.mRole:getPosition_pos()
	local _deg = MathExt.GetDegreeWithTwoPoint(_pos, _curPos)
	local _dir = FightConfig.GetDirectionByDegree(_deg)
	if _dir == FightConfig.DIRECTION_CMD.DLEFT or _dir == FightConfig.DIRECTION_CMD.DLEFTUP  or _dir == FightConfig.DIRECTION_CMD.DLEFTDOWN then
		if not self.mRole.IsFaceLeft and tiaozheng then
			self.mRole:WalkingByPos(_pos,_callfun,true)
			return
		end
	elseif _dir == FightConfig.DIRECTION_CMD.DRIGHT or _dir == FightConfig.DIRECTION_CMD.DRIGHTUP  or _dir == FightConfig.DIRECTION_CMD.DRIGHTDOWN then
		if self.mRole.IsFaceLeft and tiaozheng then
			self.mRole:WalkingByPos(_pos,_callfun,true)
			return
		end
	end
	self.mRole:WalkingByPos(_pos,_callfun)
end

function AIController:Findgoal(delta)
	if self:TickWaitBlock(delta) then return end
	local goalRole ,_type = self:GetRoleByNearPos()
	local Collision = nil
	if goalRole then
		local Pos = nil
		local skill = nil
		local isAttackRange = nil
		if _type == "sceneAni" then
			self:TargetTurnByPosX(goalRole:getPosition_pos().x)
			Pos = goalRole:getCollisionRandomPos()
			Collision = goalRole.mCollision
			skill,isAttackRange = self:SkillFindSceneAni(goalRole)
		else
			Pos = goalRole:getShadowPos()
			self:TargetTurnByPosX(Pos.x)
			skill,isAttackRange = self:SkillFindRole(Pos)
		end
		if self.mRole.mFSM:IsIdle() then
			--看当前技能
			self.DaodaGoalPos = Pos
			if isAttackRange then
				--怪物有攻击范围攻击
				if self.mAttackFrequency >= math.random(1,100) then
					self.IsWaitTime = false
					--debugLog("AAAAAAAAAAAAA=======1=========="..self.mSkillkey.. "=====FACE==" ..face .."==WO==POS="..self.mRole:getShadowPos().x .."=====DIREN==POSX" ..Pos.x)
					self:SkillPlay(skill)
				else
					self.IsWaitTime = false
					self:Daiji_state()
					return
				end
			else
				if FightSystem:getMapInfo(Pos,self.mRole.mSceneIndex) ~= 1 then
					self:ResetAttack()
					return
				end
				self.DaodaGoalPos = Pos
				local putskill = self:GetputSkill()
				local skilldata = self.mRole.mSkillCon:getInSkillRangeBySkillID(putskill)
				if skilldata then
					if _type ~= "sceneAni" then
						self.DaodaGoalPos = self:FindAIRunPos(skilldata,self.DaodaGoalPos)
					else
						if Collision and Collision == 0 then
							self.DaodaGoalPos = self:FindAIRunPos(skilldata,self.DaodaGoalPos)
						end
					end
				else
					self.mAICurState = "none"
					self.mCurstateTime = 0
				end
				if FightSystem:getMapInfo(self.DaodaGoalPos,self.mRole.mSceneIndex) ~= 1 then
					self.DaodaGoalPos = Pos
				end
				--*0125*self.mRole:WalkingByPos(self.DaodaGoalPos,handler(self,self.OnStopGoalPos))
				self:WalkTurnRun(self.DaodaGoalPos,handler(self,self.OnStopGoalPos))
				self.mAICurState = "paolu"
				self.mCurstateTime = 0
			end
		else
			self.mAICurState = "none"
			self.mCurstateTime = 0
		end
	else
		self.mAICurState = "none"
		self.mCurstateTime = 0
	end
end

--找到AI要跑到的点
function AIController:FindAIRunPos(data,pos)
	if data.DamageType == 1 then
	   return self:RunPosRange_Type1( data.DamageLength, data.DamageWidth, pos, _offset)
	elseif data.DamageType == 2 then
		return self:RunPosRange_Type2( data.DamageLength, data.DamageWidth, pos, _offset)
	end
	return pos
end

--当前矩形
function AIController:RunPosRange_Type1(_len,_width,pos,_offset)
	--cclog("RunPosRange_Type1===" .. _len)
	local maxX = math.ceil(pos.x + _len)-1
	local minX = math.ceil(pos.x - _len)+1

	local maxY = math.ceil(pos.y + _width/2)-1
	local minY = math.ceil(pos.y - _width/2)+1

	if FightSystem:GetFightManager().mLeftLineX > minX then
		minX = FightSystem:GetFightManager().mLeftLineX
	end

	if FightSystem:GetFightManager().mRightLineX < maxX then
		maxX = FightSystem:GetFightManager().mRightLineX
	end
	local X = math.random(minX,maxX)
	local Poslist = {}
	
	for j = minY,maxY,10 do
		if FightSystem:getMapInfo(cc.p(X,j),self.mRole.mSceneIndex)  == 1 then
			table.insert(Poslist,cc.p(X,j))
		end
	end
	
	if #Poslist == 0 then
		return pos
	end
	local num = math.random(1,#Poslist)
	return Poslist[num]
end

--当前椭圆
function AIController:RunPosRange_Type2(_len,_width,pos,_offset)
	--cclog("RunPosRange_Type2===" .. _len)
	local Xnum = math.random(-_len/2,_len/2)
	local y1 = -(_width/_len)math.sqrt(_len*_len - Xnum*Xnum)
	local y2= - y1

	local maxY = math.ceil(pos.y + y2)-1
	local minY = math.ceil(pos.y + y1)+1

	local X = math.ceil(pos.x + Xnum)-1

	if FightSystem:GetFightManager().mLeftLineX > X then
		X = FightSystem:GetFightManager().mLeftLineX
	end
	if FightSystem:GetFightManager().mRightLineX < X then
		X = FightSystem:GetFightManager().mRightLineX
	end

	local Poslist = {}
	for i = minY,maxY,10 do
		if FightSystem:getMapInfo(cc.p(X,i),self.mRole.mSceneIndex)  == 1 then
			table.insert(Poslist,cc.p(X,i))
		end
	end
	if #Poslist == 0 then
		return pos
	end
	local num = math.random(1,#Poslist)
	return Poslist[num]
end

function AIController:FindFriendgoal(delta)
	--if self:TickWaitBlock(delta) then return end
	local goalRole ,_type= self:GetRoleByNearPos()
	if goalRole then
		local Pos = nil
		if _type == "sceneAni" then
			Pos = goalRole:getPosition_pos()
		else
			Pos = goalRole:getShadowPos()
		end
		if self.mRole.mFSM:IsIdle() then
			--看当前技能
			self.DaodaGoalPos = Pos
			self:TargetTurnByPosX(Pos.x)
			local skill,isAttackRange = self:SkillFindRole(self.DaodaGoalPos)
			if isAttackRange then
				--怪物有攻击范围攻击
				if self.mAttackFrequency >= math.random(1,100) then
					self.IsWaitTime = false
					self:SkillPlay(skill)
				else
					self.IsWaitTime = false
					self:Daiji_state()
					return
				end
			else	
				if FightSystem:getMapInfo(Pos,self.mRole.mSceneIndex) ~= 1 then
					self:ResetAttack()
					return
				end
				--*0125*self.mRole:WalkingByPos(Pos,handler(self,self.OnStopGoalPos))
				self:WalkTurnRun(Pos,handler(self,self.OnStopGoalPos))
				self.DaodaGoalPos = Pos
				self.mAICurState = "paolu"
				self.mCurstateTime = 0
			end
		else
			self:ResetAttack()
		end
	else
		self:ResetAttack()
	end
end

-- 立即执行技能
function AIController:SoonSkillgoal(delta)
	local goalRole , _type = self:GetRoleByNearPos()
	if goalRole then

		local Pos = nil
		local skill = nil
		local isAttackRange = nil
		if _type == "sceneAni" then
			Pos = goalRole:getCollisionRandomPos()
			self:TargetTurnByPosX(Pos.x)
			skill,isAttackRange = self:SkillFindSceneAni(goalRole)
		else
			Pos = goalRole:getShadowPos()
			self:TargetTurnByPosX(Pos.x)
			skill,isAttackRange = self:SkillFindRole(Pos)
		end
		self.DaodaGoalPos = Pos
		if self.mMonsterType and self.mMonsterType == 2 then
			-- 木桩
			if isAttackRange then
				self:AIAllStop()
				self:SkillSoonPlay(skill)
			end
			return
		end
		if isAttackRange then
			--怪物有攻击范围攻击
			self:AIAllStop()
			self:SkillSoonPlay(skill)
		else
			self.mNormalSkill_Index = 0
			self.mNormalSkill_ID = 0
			self.mCallNormalSkill_ID = 0
			local a = cc.pGetDistance(self.mRole:getShadowPos(),Pos)
			if a < 10 then
				if self.mRole:getShadowPos().x < Pos.x then
					if self.mRole.IsFaceLeft then
						self.mRole:FaceRight()
					end
				end
				if self.mRole:getShadowPos().x > Pos.x then
					if not self.mRole.IsFaceLeft then
						self.mRole:FaceLeft()
					end
				end
				if not self.mRole.mFSM:IsIdle() then
					self:AIAllStop()
				end
			else
				-- if self.mTestTick == "findroad" then
				-- 	return 
				-- end
				if FightSystem:getMapInfo(Pos,self.mRole.mSceneIndex) ~= 1 then
					return
				end
				if self.mRole.mFSM:IsRuning() then
					return
				end
				self.DaodaGoalPos = Pos
				self:WalkTurnRun(Pos,handler(self,self.OnStopGoalPos))
				--*0125*self.mRole:WalkingByPos(Pos,handler(self,self.OnStopGoalPos))
			end	
		end
	else
		self:ResetAttack()
	end
end

function AIController:PlayerFindMonster(delta)
	if self:TickWaitBlock(delta) then return end
	local goalRole , _type = self:GetRoleByNearPos()
	if goalRole then
		local Pos = nil
		if _type == "sceneAni" then
			Pos = goalRole:getPosition_pos()
			self:TargetTurnByPosX(Pos.x)
		else
			Pos = goalRole:getShadowPos()
			self:TargetTurnByPosX(Pos.x)
		end
		self.DaodaGoalPos = Pos
		local skill,isAttackRange = self:SkillFindRole(self.DaodaGoalPos)
		if isAttackRange then
			--怪物有攻击范围攻击
			if self.mAttackFrequency >= math.random(1,100) then
				self.IsWaitTime = false
				self:AIAllStop()
				self:SkillPlay(skill)
			else
				self.IsWaitTime = false
				self:Daiji_state()
				return
			end	
		else
			self.mNormalSkill_Index = 0
			self.mNormalSkill_ID = 0
			self.mCallNormalSkill_ID = 0
			local a = cc.pGetDistance(self.mRole:getShadowPos(),Pos)
			if a < 10 then
				--cclog("warn-----------------------")
				if self.mRole:getShadowPos().x < Pos.x then
					if self.mRole.IsFaceLeft then
						self.mRole:FaceRight()
					end
				end
				if self.mRole:getShadowPos().x > Pos.x then
					if not self.mRole.IsFaceLeft then
						self.mRole:FaceLeft()
					end
				end
				if not self.mRole.mFSM:IsIdle() then
					self:AIAllStop()
				end
			else
				-- if self.mTestTick == "findroad" then
				-- 	return 
				-- end
				if FightSystem:getMapInfo(Pos,self.mRole.mSceneIndex) ~= 1 then
					return
				end
				if self.mRole.mFSM:IsRuning() then
					return
				end
				self.DaodaGoalPos = Pos
				self.mRole:WalkingByPos(Pos,handler(self,self.OnStopGoalPos))
			end	
		end
	else
		self.mAICurState = "none"
		self.mCurstateTime = 0
	end
end

function AIController:AstarRunAction()
	local _pos = self.mAstarPosTable[1]
	self.mRole:WalkingByPos(_pos,handler(self,self.AstarGoalPos))
	table.remove(self.mAstarPosTable,1)
end



function AIController:AstarRun(tablepos)
	self.mAstarPosTable = {}
	for i = 1,#tablepos do
		local los = tablepos[i]
		self.mAstarPosTable[i] = cc.p(los[1],los[2])
	end
end

--  检查是否是idle or runing or attacking
function AIController:IsAIcanWork()
	local con = self.mRole.mFSM:IsRuning() or self.mRole.mFSM:IsIdle() 

	local con1 = con or self.mRole.mFSM:IsAttacking() 
		
	return con1
end
--	静止帧和应制
function AIController:IsFrameTimeorIsBeatingStiff()
	local con = self.mRole.mFSM:IsBeatingStiff()
	local con1 = self.mRole.mFSM:IsDeading()
	local con2 = self.mRole.mFSM:IsBeControlled()
	local con3 = self.mRole.mFSM:IsFallingDown()
	local con4 = self.mRole:IsControlByStaticFrameTime()
	if con or con1 or con2 or con3 or con4 then
		return true
	end
	return false
end

function AIController:AIAllStop()
	self:StopAutoRun()
	self.mRole:StopMove()
end

function AIController:StopAutoRun()
	self.mTestTick = "none"
	self.RunGoldPos = nil
	self.mAstarPosTable = {}
	--self.mRole.mArmature:stopActionByTag(AIController.TagAction_RoleRun)
	--self.mRole.mShadow:stopActionByTag(AIController.TagAction_ShadowRun)
end


--[[
	Ai执行行为释放
]]

-- 立即执行当前技能
function AIController:SoonPlaySkill()
	if self.Curspecialskill then return end
	if self.mRole.mFSM:IsAttacking() then
		-- self.mRole.mSkillCon:FinishCurSkill()
		-- self.mRole.mFSM:ForceChangeToState("idle")
	end
	-- if self.mRole.mFSM:IsBlock() then
	-- 	self.mRole.mFSM:ForceChangeToState("idle")
	-- 	self.mBlocktime = nil
	-- end
	if not self.mWaitsoonskill then
		self.mWaitsoonskill = "soonspecoalskill"
	end
	-- if self.mAICurState == "paolu" or self.mAICurState == "astarwalk" then
	-- else
	-- 	if not self.mWaitsoonskill then
	-- 		self.mWaitsoonskill = "soonspecoalskill"
	-- 	end
	-- end
end

function AIController:TickCondition(delta)

	for k,v in pairs(self.tableCondition) do
		v:Tick(delta)
	end
end

function AIController:Behavior_Speak(_speakID, _delayTime, _continueTime)
	self.mSpeakId = _speakID
	self.mSpeakDelayTime = _delayTime
	self.mSpeakContinueTime = _continueTime
	if self.mSpeakDelayTime == 0 then
		self.mSpeakDelayTime = nil
		self:ShowSpeakPao(self.mSpeakId)
	end
end

function AIController:ShowSpeakPao(_speakID)
	self.mRole.mArmature:SpeakPao(_speakID)
end

function AIController:HideSpeakPao()
	self.mRole.mArmature:HideSpeakPao()
	self.mSpeakId = nil
end

function AIController:Behavior_SkillId(skillid,talk,delaytime)
	if self.mCurAIBuffState then return end
	self:AIAllStop()
	local time = {}
	if type(talk) == "table" then
		if #talk ~= 0 then
			if self.mRole.mGroup == "monster" then
				self.mRole:AddBuff(188)
			end
			local num = math.random(1,#talk)
			CommonAnimation.PlayEffectId(talk[num])
		end
	end
	if delaytime == 0 then
		if self.mRole:PlaySkillByID(skillid) then
			self.Skillspecial[skillid] = nil
			self.Curspecialskill = skillid
		end
	else
		time.SkillId = skillid
		time.Delaytime = delaytime
		self.mRole:showSkillRangeByID(skillid)
		self.Curspecialskill = skillid
		self.Skillspecial[skillid] = nil
		table.insert(self.SkillDelaylist,time)
	end
end

function AIController:Behavior_Jumpgoal(pos)
	local flag = false
	self.mRole:setInvincible(true)
	local function finishjump()
		self.JumpAccessible = flag
		self.mRole:setInvincible(false)
		self.mRole.mFSM:ForceChangeToState("idle")
	end
	self:ResetAttack()
	self.mRole:jumpByPos(cc.p(pos[1],pos[2]),finishjump)
	self.JumpAccessible = false
	if FightSystem:getMapInfo(cc.p(pos[1],pos[2]),self.mRole.mSceneIndex) == 1 then
		flag = true
	else
		flag = false
	end
end

function AIController:Behavior_Walkgoal(pos)
	local Walkpos = cc.p(pos[1],pos[2])
	if FightSystem:getMapInfo(Walkpos,self.mRole.mSceneIndex) ~= 1 then return end
	self:ResetAttack()
	local pao = self.mRole:WalkingByPos(Walkpos,handler(self,self.OnStopGoalPos))
	if pao then
		self.DaodaGoalPos = Walkpos
		self.mAICurState = "paolu"
		self.mCurstateTime = 0
		self.mBehaviorWalk = true
	end
end

function AIController:OpenTimer(id,time,loop)
	local Timer = {}
	Timer.id = id
	Timer.time = time
	Timer.looptime = 0
	if loop == 1 then
		Timer.looptime = Timer.time
	end
	table.insert(self.RunTimerIdList,Timer)
end

function AIController:CloseTimer(id)
	for k,v in pairs(self.RunTimerIdList) do
		if v.id == id then
			table.remove(self.RunTimerIdList,k)
		end
	end
end

function AIController:TickRunTimer(delta)
	for k,v in pairs(self.RunTimerIdList) do
		v.time = v.time - delta
		if v.time <= 0 then
			local id = v.id
			 self.TimerIdList[id] =  id 
			for k,v in pairs(self.tableCondition) do
				if v.mTimerKey[id] then
					if v.mTimerKey[id] == id then
						v.mTimerKey[id] = nil
					end
				end
			end
			if v.looptime ~= 0 then
				v.time = v.looptime
			else
				table.remove(self.RunTimerIdList,k)
			end
		end
	end
end

function AIController:TickSkillTimer(delta)
	if self.mCurAIBuffState then return end
	for k,v in pairs(self.SkillDelaylist) do
		v.Delaytime = v.Delaytime - delta
		if v.Delaytime <= 0 then
			self.mRole.mSkillCon:cancelSkillRange()
			if self.mRole:PlaySkillByID(v.SkillId) then
				self.Skillspecial[v.SkillId] = nil
				table.remove(self.SkillDelaylist,k)
			end
		end
	end
end

function AIController:Summon(id,pos)
	local pos = cc.p(self.mRole:getShadowPos().x + pos[1],self.mRole:getShadowPos().y + pos[2])
	local goalposx = pos.x
	local goalposy = pos.y
	if FightSystem:getMapInfo(cc.p(goalposx,goalposy),self.mRole.mSceneIndex) ~= 1 then
		for i=goalposy-10,0,-10 do
			if FightSystem:getMapInfo(cc.p(goalposx,i),self.mRole.mSceneIndex) == 1 then
				goalposy = i
				break
			end	
		end
	end
	pos.y = goalposy
	self.mRole.mSummonCon:addSummon(id,pos,300)
end

function AIController:ConditionAddBuff(id)

	self.mRole:AddBuff(id)

end

function AIController:AddSkillCool(condition,param)
	if self.Skillspecial[param] then
		if self.Skillspecial[param].AI_BehaviorParam1 == param then
			return
		end
	end
	for k,v in pairs(self.SkillDelaylist) do
		if v.SkillId == param then
			return
		end
	end
	local cooltime,max,upTimes,upMaxTimes = self.mRole.mSkillCon:SkillInCoolDownTime(param,"ai")
    local _db = DB_SkillEssence.getDataById(param)
    local ss = true
    if self.mRole.mGroup == "friend" or self.mRole.mGroup == "enemyplayer" then
    	if _db.CostMp ~= 0 then
	    	if upTimes > 0 then
	    		ss = false
	    	end
    	end
    end
	if cooltime <= 0 and ss then
		local Behavior = {}
		Behavior.AI_Behavior = condition.AI_Behavior
		Behavior.AI_BehaviorParam1 = condition.AI_BehaviorParam1
		Behavior.AI_BehaviorParam2 = condition.AI_BehaviorParam2
		Behavior.AI_BehaviorParam3 = condition.AI_BehaviorParam3
		Behavior.AI_BehaviorParam4 = 0
		self.Skillspecial[param] = Behavior
		self:SoonPlaySkill()
	end
end

--[[
   技能结束回调
]]
function AIController:OnSkillFinish(skillID)
	if not self.mOpenAI then return end
	if self.mCurAIBuffState then return end
	if self.Curspecialskill  then
		if self.Curspecialskill == skillID then
			for k,v in pairs(self.Skillspecial) do
				self.mAICurState = "soonspecoalskill"
			 	self.Curspecialskill = nil
			 	return
			end
			self.Curspecialskill = nil
			self:Daiji_state()
		else
			self.Curspecialskill = nil
			if self.mAICurState == "taoquangongji" then
				self.mCallNormalSkill_ID = skillID
				self:XunhuanGongji()
			else
				self:ResetAttack(true)
			end
		end
	else
		if self.mAICurState == "taoquangongji" then
			self.mCallNormalSkill_ID = skillID
			self:XunhuanGongji()
		else
			self:ResetAttack()
		end
	end
end