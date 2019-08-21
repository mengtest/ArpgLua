-- Name: BeatController
-- Func: 角色受击控制器
-- Author: Johny

require "FightSystem/Role/BeatGroup/KnockBackController"
require "FightSystem/Role/BeatGroup/KnockStunedController"
require "FightSystem/Role/BeatGroup/KnockFlyController"
require "FightSystem/Role/BeatGroup/KnockFlightHitController"
require "FightSystem/Role/BeatGroup/FreefallController"
require "FightSystem/Role/BeatGroup/BeatGripedController"
require "FightSystem/Role/BeatGroup/SleepController"
require "FightSystem/Role/BeatGroup/FrozenController"
require "FightSystem/Role/BeatGroup/FalldownController"
require "FightSystem/Role/BeatGroup/ImmobilizedController"

BeatController = class("BeatController")


function BeatController:ctor(_role)
	self.mRole = _role
	self.mInjuredStiffDuring = 0
	self.mFlashDuring = 0
	self.mCurInjuredAction = ""
	self.mKnockBackCon = KnockBackController.new(_role)
	self.mKnockStunedCon = KnockStunedController.new(_role)
	self.mKnockFlyCon = KnockFlyController.new(_role)
	self.mKnockFlightCon = KnockFlightHitController.new(_role)
	self.mFreefallCon = FreefallController.new(_role)
	self.mSleepCon = SleepController.new(_role)
	self.mFrozenCon = FrozenController.new(_role)
	self.mBeatGripedCon = BeatGripedController.new(_role)
	self.mFalldownCon = FalldownController.new(_role)
	self.mImmobilizedCon = ImmobilizedController.new(_role)
	--
	self.mBeatFlyCount = 0
	-- 在地上硬直计数
	self.mBeatTiffCount = 0
	self:registerActionCustom()
end

function BeatController:Destroy()
	cclog("BeatController:Destroy")
	self.mKnockBackCon:Destroy()
	self.mKnockBackCon = nil
	self.mKnockStunedCon:Destroy()
	self.mKnockStunedCon = nil
	self.mKnockFlyCon:Destroy()
	self.mKnockFlyCon = nil
	self.mKnockFlightCon:Destroy()
	self.mKnockFlightCon = nil
	self.mFreefallCon:Destroy()
	self.mFreefallCon = nil
	self.mBeatGripedCon:Destroy()
	self.mBeatGripedCon = nil
	self.mSleepCon:Destroy()
	self.mSleepCon = nil
	self.mFrozenCon:Destroy()
	self.mFrozenCon = nil
	self.mFalldownCon:Destroy()
	self.mFalldownCon = nil
	self.mImmobilizedCon:Destroy()
	self.mImmobilizedCon = nil
	self.mBeatFlyCount = nil
	self.mBeatTiffCount = nil
end

function BeatController:RegisterBeatStCallBack()
	self.mRole.mFEM:RegisterFunc_BeatEffect_Change(handler(self,self.OnBeatEffectChange))
end

function BeatController:registerActionCustom()
	local function _OnActionCustom(_action,name)
		if self.mInjuredShake and self.mInjuredShake ~= 0 then
			if _action == "injured1" or _action == "injured2" then
				if name == "1" then
					self.mRole.mArmature:pauseAction(true)
				end
			end
		end
	end
	self.mRole.mArmature:RegisterActionCustomEvent("BeatController",_OnActionCustom)
end

function BeatController:Tick(delta)
	self:TickBeatFlash()
	if pCall(self.mRole, handler(self.mRole, self.mRole.IsControlByStaticFrameTime)) then
	return end
	--
	self:TickBeatStiff()
	self.mKnockBackCon:Tick(delta)
	self.mKnockStunedCon:Tick(delta)
	self.mBeatGripedCon:Tick(delta)
	self.mKnockFlyCon:Tick(delta)
	self.mKnockFlightCon:Tick(delta)
	self.mFreefallCon:Tick(delta)
	self.mSleepCon:Tick(delta)
	self.mFrozenCon:Tick(delta)
	self.mFalldownCon:Tick(delta)
	self.mImmobilizedCon:Tick(delta)
	
end

-- 检测格挡
function BeatController:checkBlocked(_hiter)
	if _hiter:getPositionX() >= self.mRole:getPositionX() then
		if not self.mRole.IsFaceLeft and self.mRole.mFSM:IsBlock() then
			return true
		end
	end
	if _hiter:getPositionX() <= self.mRole:getPositionX() then
		if self.mRole.IsFaceLeft and self.mRole.mFSM:IsBlock() then
			return true
		end
	end
	return false
end

-- debuff受击,hitter很可能下一帧被移除,注意野指针问题
function BeatController:Beated_debuff(_hiter, _damage)
	local function xxx()
	    if self.mRole.mBuffCon:hasInvincibleBuffNow() then return end
	    if FightSystem.mFightType == "olpvp" then return end
		self.mRole.mFlowLabelCon:FlowDamage("normal", _damage, _hiter)
		self.mRole.mPropertyCon:OnDamaged(_damage, _hiter)
	end
	caculateFuncDuring("BeatController:Beated_debuff", xxx)
end

-- 技能受击, 受击总入口点
function BeatController:Beated(_hiter, _damage, _damgeTP, _skillProcID)
	    if self.mRole.mBuffCon:hasInvincibleBuffNow() then return end
	    local data = DB_SkillProcess.getDataById(_skillProcID)
	    local DisplayID = data.ProcessDisplayID
    	local _actionDB = nil
	    local hitAnimation = nil
		local ScreenShake = nil
	    if DisplayID ~= 0 then
	    	_actionDB = DB_SkillDisplay.getDataById(DisplayID)
		    hitAnimation = _actionDB.HitTextAnimation
			ScreenShake = _actionDB.ScreenShake
	    end
	    local xxx1State = nil
	    local xxx3State = nil
	    for i = 1, 4 do
			local _stateID = data[TargetStateID_Table[i]]
			if _stateID == 0 then break end
			local _dbState = DB_SkillState.getDataById(_stateID)
			local _dbEff = DB_SkillEffect.getDataById(_dbState.EffectID1)
			local ExcuteMethod = _dbEff.ExcuteMethod
			if ExcuteMethod <= 100 then
				xxx1State = true
				if ExcuteMethod == 3 or ExcuteMethod == 31 or ExcuteMethod == 32 then
					xxx3State = true
					break
				end
			end
		end
	    local function xxx1()
	    	-- 受击者转向
			if self.mRole.mGroup == "monster" or self.mRole.mGroup == "summonmonster" or self.mRole.mGroup == "summonfriend" then
				if self.mRole.mFSM:IsFallingDown() then
					if xxx1State then
						if _hiter.IsFaceLeft then
							self.mRole:FaceRight()
						else
							self.mRole:FaceLeft()
						end
					end
				else
					-- 被打激活
					self.mRole.mAI:ActivateCondition()
					if not self.mRole:hasNoControlBuffNow() and self.mRole.mFSM:IsBeControlled() then
						if _hiter.IsFaceLeft then
							self.mRole:FaceRight()
						else
							self.mRole:FaceLeft()
						end
					end
				end
			else
				if self.mRole.mGroup == "friend" or self.mRole.mGroup == "enemyplayer" then
					self.mRole.mAI:ActivateCondition()
					if not self.mRole:hasNoControlBuffNow() and self.mRole.mFSM:IsBeControlled() then
						if _hiter.IsFaceLeft then
							self.mRole:FaceRight()
						else
							self.mRole:FaceLeft()
						end
					end
				end
			end
	    end
		--------------------
		local function xxx2()
			if not FightConfig.__DEBUG_CLOSELOAD_FLOWLABEL_ then
				--if FightConfig.__DEBUG_DAMAGE_FONTNUM then
					if (self.mRole.mGroup == "friend" and self.mRole.IsKeyRole) or (_hiter.mGroup == "friend" and _hiter.IsKeyRole) then
						self.mRole.mFlowLabelCon:FlowDamage(_damgeTP,_damage,_hiter)
					elseif (self.mRole.mGroup == "summonfriend" and self.mRole.mHost.IsKeyRole) or (_hiter.mGroup == "summonfriend" and _hiter.mHost.IsKeyRole) then
						self.mRole.mFlowLabelCon:FlowDamage(_damgeTP,_damage,_hiter)
					end
				-- else
				-- 	if DisplayID ~= 0 and hitAnimation ~= 0 then
				-- 		self.mRole.mFlowLabelCon:FlowDamageEffect(_hiter,hitAnimation)
				-- 	end
				-- end
			end
			self.mRole.mPropertyCon:OnDamaged(_damage, _hiter)
		end
		--------------
		local function xxx3()
		  	-- 受害者状态检查
			if self.mRole.mFEM:IsBeatStFly() then
				if not xxx3State then
					self.mKnockFlyCon:flowFlyStart()
				end
			end
		end
		----------------
		local function xxx4()
		    if not _hiter.IsKeyRole then return end
			if DisplayID ~= 0 then
				-- 检查震屏
				local amplitude = ScreenShake[2]
				if _hiter.IsFaceLeft then
					amplitude = - amplitude
				end
				if ScreenShake[1] ~= 0 and ScreenShake[4] ~= 1 then
					if ScreenShake[1] == 1 then
						shakeNode(FightSystem.mSceneManager:GetSceneView(self.mRole.mSceneIndex),ScreenShake[2],ScreenShake[3],ScreenShake[5])
					elseif ScreenShake[1] == 2 then
						shakeNodeType1(FightSystem.mSceneManager:GetSceneView(self.mRole.mSceneIndex),ScreenShake[2],ScreenShake[3],ScreenShake[5])
					elseif  ScreenShake[1] == 3 then
						shakeNodeType2(FightSystem.mSceneManager:GetSceneView(self.mRole.mSceneIndex),amplitude,ScreenShake[3],ScreenShake[5])
					end
				end
			end
		end
		------------------
		local function xxx5()
			local _params = {}
			_params["procid"] = _skillProcID
			self.mRole:OnBeatedEvent(_hiter, _damage, _params)
			--FightSystem:PushNotification("skilldamage")
		end
		caculateFuncDuring("BeatController:Beated1", xxx1)
		caculateFuncDuring("BeatController:Beated2", xxx2)
		caculateFuncDuring("BeatController:Beated3", xxx3)
		caculateFuncDuring("BeatController:Beated4", xxx4)
		caculateFuncDuring("BeatController:Beated5", xxx5)
end

-- 子物体受击
function BeatController:Beated_SubObject(_subobj, _hiter, _damage, _damgeTP, _subData, _disPlay)
	if self.mRole.mBuffCon:hasInvincibleBuffNow() then return end

	local xxx1State = nil
    local xxx3State = nil
    for i = 1, 4 do
		local _stateID = _subData[TargetStateID_Table[i]]
		if _stateID == 0 then break end
		local _dbState = DB_SkillState.getDataById(_stateID)
		local _dbEff = DB_SkillEffect.getDataById(_dbState.EffectID1)
		local ExcuteMethod = _dbEff.ExcuteMethod
		if ExcuteMethod <= 100 then
			xxx1State = true
			if ExcuteMethod == 3 or ExcuteMethod == 31 or ExcuteMethod == 32 then
				xxx3State = true
				break
			end
		end
	end

	local function xxx1()
		--if FightConfig.__DEBUG_DAMAGE_FONTNUM then
			if (self.mRole.mGroup == "friend" and self.mRole.IsKeyRole) or (_hiter.mGroup == "friend" and _hiter.IsKeyRole) then
				self.mRole.mFlowLabelCon:FlowDamage(_damgeTP,_damage,_hiter)
			end
		-- else
		-- 	if _disPlay and _disPlay.HitTextAnimation ~= 0 then
		-- 		self.mRole.mFlowLabelCon:FlowDamageEffect(_hiter,_disPlay.HitTextAnimation)
		-- 	end
		-- end

		self.mRole.mPropertyCon:OnDamaged(_damage, _hiter)
	end
	local function xxx2()
		-- 受击者转向
		if self.mRole.mGroup == "monster" or self.mRole.mGroup == "summonmonster" or self.mRole.mGroup == "summonfriend" then
			if self.mRole.mFSM:IsFallingDown() then
				if xxx1State then
					if _subobj.IsFaceLeft then
						self.mRole:FaceRight()
					else
						self.mRole:FaceLeft()
					end
				end
			else
				-- 被打激活
				self.mRole.mAI:ActivateCondition()
				if not self.mRole:hasNoControlBuffNow() and self.mRole.mFSM:IsBeControlled() then
					if _subobj.IsFaceLeft then
						self.mRole:FaceRight()
					else
						self.mRole:FaceLeft()
					end
				end
			end
		else
			if self.mRole.mGroup == "friend" or self.mRole.mGroup == "enemyplayer" then
				if not self.mRole:hasNoControlBuffNow() and self.mRole.mFSM:IsBeControlled() then
					if _subobj.IsFaceLeft then
						self.mRole:FaceRight()
					else
						self.mRole:FaceLeft()
					end
				end
			end
		end
	end
	local function xxx3()
		-- 受害者状态检查
		if self.mRole.mFEM:IsBeatStFly() then
			if not xxx3State then
				self.mKnockFlyCon:flowFlyStart()
			end
		end
		local _params = {}
		self.mRole:OnBeatedEvent(_hiter, _damage, _params)
		--FightSystem:PushNotification("skilldamage")
	end
	--[[ --注掉涨MP
	local function xxx4()
		if _subData.GetMp ~= 0 and ( _hiter.mGroup == "friend" or _hiter.mGroup == "enemyplayer" ) then
			_hiter.mSkillCon:AddMp(_subData.GetMp)
		end
		if _subData.GetMp ~= 0 and ( FightSystem:GetModelByType(4) and _hiter.mGroup == "monster" ) then
			_hiter.mSkillCon:AddMp(_subData.GetMp)
		end
	end
	]]
	xxx1()
	xxx2()
	xxx3()
	--xxx4()
end

-- 进入硬直状态
--   1. 播动作
--   2. 结束当前技能
function BeatController:BeatStiff(_during,_durjuredShake, _juredType,_hiter)
	if not _hiter then return end
	-- if FightSystem.mFightType == "arena" or FightSystem.mFightType == "olpvp" or FightSystem:GetModelByType(4) then
	-- 	return
	-- end

	if self:checkBlocked(_hiter) then
		self.mRole.mMoveCon.mBlockCon:HitBlock()
		return
	end
	if self.mRole:hasNoControlBuffNow() then return end
	if self.mRole.mFSM:ChangeToState("beatingstiff") then
		self:PlayBeatAction(_juredType)
		self.mInjuredStiffDuring = _during + 1 -- 下一帧播放硬直，补一帧
		if _durjuredShake > 0 then
			self.mInjuredShake = _durjuredShake/2 - 1
			self.mInjuredShake = math.floor(self.mInjuredShake)
			self.mIsshakeLeft = false
			if _hiter:getPositionX() >= self.mRole:getPositionX() then
				self.mInjuredShake = -self.mInjuredShake
				self.mIsshakeLeft = true
			end
		end
	end
end

-- 播放受伤动作
function BeatController:PlayBeatAction(_juredType)
	if _juredType == "" then
		if self.mCurInjuredAction == "injured1" then
			self.mRole.mArmature:ActionNow("injured2")
			self.mCurInjuredAction = "injured2"
			self.mRole:playVoiceSound(2)
		else
			self.mRole.mArmature:ActionNow("injured1")
			self.mCurInjuredAction = "injured1"
			self.mRole:playVoiceSound(1)
		end
	else
		self.mRole.mArmature:ActionNow(_juredType)
		if _juredType == "injured1" then
			self.mRole:playVoiceSound(2)
		elseif _juredType == "injured2" then
			self.mRole:playVoiceSound(1)
		end
	end
end

-- 启用闪白, 在静止帧下被攻击
function BeatController:BeatFlash()
	self.mFlashDuring = 2
	ShaderManager:changeColor_spine(self.mRole.mArmature.mSpine, G_COLOR_VEC4.WHITE)
end

-- 硬直处理
function BeatController:TickBeatStiff()
	if self.mInjuredStiffDuring > 0 then
		if not self.mRole.mFSM:IsBeatingStiff() then
			self.mInjuredStiffDuring = 0
			self.mInjuredShake = nil
	   		self.mIsshakeLeft = nil
	   		self.mRole.mArmature.mSpine:setPositionX(0)
			return
		end
	   self.mInjuredStiffDuring = self.mInjuredStiffDuring -1
	   if self.mInjuredStiffDuring == 0 then
	   		self.mRole.mFSM:ChangeToStateWithCondition("beatingstiff", "idle")
	   		self.mCurInjuredAction = ""
	   		self.mInjuredShake = nil
	   		self.mIsshakeLeft = nil
	   		self.mRole.mArmature.mSpine:setPositionX(0)
	   end
	   if self.mInjuredShake and self.mInjuredShake == 0 then
	   	  self.mRole.mArmature:pauseAction(false)
	   	  self.mInjuredShake = nil
	   end
	   if self.mInjuredShake and self.mInjuredShake ~= 0 then
	   		self.mRole.mArmature.mSpine:setPositionX(self.mInjuredShake)
	   		if  self.mInjuredShake > 0 then
	   			if self.mIsshakeLeft then
	   				self.mInjuredShake = -(self.mInjuredShake - 1)
	   			else
	   				self.mInjuredShake = -self.mInjuredShake
	   			end
	   		else
	   			if not self.mIsshakeLeft then
	   				self.mInjuredShake = -(self.mInjuredShake + 1 )
	   			else
	   				self.mInjuredShake = -self.mInjuredShake
	   			end
	   		end
	   end
	end
end

-- 闪白处理
function BeatController:TickBeatFlash()
	if self.mFlashDuring > 0 then
       self.mFlashDuring = self.mFlashDuring -1
       if self.mFlashDuring == 0 then
       	  ShaderManager:ResumeColor_spine(self.mRole.mArmature.mSpine)
       end
	end
end

-- 受击状态处理
function BeatController:BeatStateChange(_dbProc, _skillstDB, _hiter ,_level, _skillId, _processType,_subhost)
	local _dbEff = DB_SkillEffect.getDataById(_skillstDB.EffectID1)
	local _excuteMethod = _dbEff.ExcuteMethod
	if self:checkBlocked(_hiter) then 
		self.mRole.mMoveCon.mBlockCon:HitBlock()
		return 
	end
	if _excuteMethod <= 100 then
		if self.mRole:hasNoControlBuffNow() then return end
		if self.mRole.mBuffCon:hasInvincibleBuffNow() then return end
		local successRatioData = _skillstDB.SuccessRatio
		local num = math.random(1,100)
		if num > successRatioData then return end
		if not self.mRole.mFSM:ChangeToState("becontroled") then return end
		local _table = {}
		_table[1] = _skillstDB
		_table[2] = _hiter
		_table[3] = _dbProc
		if self.mRole.mFEM:ChangeToBeatEffect(_excuteMethod, _table) then
			-- if _skillstDB.StateDisplayText ~= 0 then
			--    self.mRole.mFlowLabelCon:FlowBuffName( getDictionaryText(_skillstDB.StateDisplayText))
			-- end
		end
	else
	   --debugLog("添加buff=======" .. _excuteMethod)
       self.mRole.mBuffCon:addBuff(_skillstDB, _dbEff, _hiter, _dbProc, _level, _skillId, _processType,_subhost)
	end
end
-- 取消所有BeatCon
function BeatController:CancelAllBeat(_state,_to)
	if _state == "knockback" then
		self.mKnockBackCon:cancelKnockBack()
	elseif _state == "knockflight" then
		self.mKnockFlightCon:cancelKnockFlightHitByNoCon()
	elseif _state == "freefall" then
		self.mFreefallCon:cancelFreeFall()
	elseif _state == "knockfly" then
		self.mKnockFlyCon:cancelKnockFlyByNoContr()
	elseif _state == "frozen" then
		if _to and _to ~= "dead" then
			self.mFrozenCon:cancelFrozen()
		end
	elseif _state == "immobilized" then
		self.mImmobilizedCon:cancelImmobilized()
	end
	self.mRole.mFEM.mCurBeatEffect = "none"
end

function BeatController:CancelFallDown()
	self.mFalldownCon:CancelFallDown()
	self.mKnockBackCon:cancelKnockBack()
end

-- 陷阱状态添加
function BeatController:TrapStateChange(_dbProc, _skillstDB, _hiter)
	if self.mTrapBuffID == _skillstDB.ID then return end
	local _dbEff = DB_SkillEffect.getDataById(_skillstDB.EffectID1)
	local _excuteMethod = _dbEff.ExcuteMethod
	if _excuteMethod <= 100 then
		if self.mRole.mBuffCon:hasInvincibleBuffNow() then return end
		if self.mRole:hasNoControlBuffNow() then return end
	end
	self.mTrapBuffID = _skillstDB.ID
	self:BeatStateChange(_dbProc, _skillstDB, _hiter)
end

-- 取消陷阱状态标记
function BeatController:cancelTrapBuffID(_stateID)
	if _stateID ~= self.mTrapBuffID then return end
	self.mTrapBuffID = 0
end


--[[
	受击效果回调
]]
function BeatController:OnBeatEffectChange(_from, _to, _data, _isTurnflight)
	--debugLog("=====BeatController:OnBeatEffectChange=====From:  " .. _from .. "===To:  " .. _to)
	--
	self:CancelFallDown()
	if _from == "knockback" then
	   self.mKnockBackCon:cancelKnockBack()
	elseif _from == "knockstunned" then

	elseif _from == "knockfly" and _to == "knockflight" then
	   self.mKnockFlyCon:cancelFlyTurnFlight()
	elseif _from == "freefall" then
		self.mFreefallCon:cancelFreeFall()
	end

	------------------------------------
	if _to == "none" then return end
	if _to == "freefall" then
		self.mFreefallCon:Start()
		return
	end

	local _stDB = _data[1]
	local _hiter= _data[2]
	local _dbProc= _data[3]
	
	if _to == "dead_knockfly" then
		local _dbEff = DB_SkillEffect.getDataById(_stDB.EffectID1)
		self.mKnockFlyCon:StartForFlyDead(_stDB, _dbEff, _hiter)
		return
	end

	if _to == "knockback" then
		local _dbEff = DB_SkillEffect.getDataById(_stDB.EffectID1)
		self.mKnockBackCon:Start(_stDB, _dbEff, _hiter)
	elseif _to == "knockstunned" then
		local _dbEff = DB_SkillEffect.getDataById(_stDB.EffectID1)
		self.mKnockStunedCon:Start(_stDB, _dbEff)
	elseif _to == "knockfly" then
		local _dbEff = DB_SkillEffect.getDataById(_stDB.EffectID1)
		self.mKnockFlyCon:Start(_stDB, _dbEff, _hiter,_dbProc, _isTurnflight)
	elseif _to == "knockflight" then
		local _dbEff = DB_SkillEffect.getDataById(_stDB.EffectID1)
		self.mKnockFlightCon:Start(_stDB, _dbEff, _hiter,_dbProc,_from)
	elseif _to == "frozen" then
		if not self.mRole.mPropertyCon:IsHpEmpty() then
			local _dbEff = DB_SkillEffect.getDataById(_stDB.EffectID1)
			self.mFrozenCon:Start(_stDB, _dbEff, _hiter)
		end
	elseif _to == "immobilized" then
		if not self.mRole.mPropertyCon:IsHpEmpty() then
			local _dbEff = DB_SkillEffect.getDataById(_stDB.EffectID1)
			self.mImmobilizedCon:Start(_stDB, _dbEff, _hiter)
		end
	elseif _to == "sleep" then
	    local _dbEff = DB_SkillEffect.getDataById(_stDB.EffectID1)
		self.mSleepCon:Start(_stDB, _dbEff, _hiter)
	elseif _to == "falldown" then 
		local _dbEff = DB_SkillEffect.getDataById(_stDB.EffectID1)
		if _dbEff.ExcuteMethod == 13 then
			if self.mRole.mPropertyCon:IsHpEmpty() then
	  			self.mRole.mFSM:ForceChangeToState("dead")
			else
				self.mRole.mFSM:ForceChangeToState("falldown")
			end
			self.mFalldownCon:Start("beBlowUpEnd", "beBlowUpStand", _dbEff.Data1)
		elseif _dbEff.ExcuteMethod == 14 then
			if self.mRole.mPropertyCon:IsHpEmpty() then
	  			self.mRole.mFSM:ForceChangeToState("dead")
			else
				self.mRole.mFSM:ForceChangeToState("falldown")
			end
			self.mFalldownCon:Start("beBlowUpEnd2", "beBlowUpStand2", _dbEff.Data1)
		end
	end

end