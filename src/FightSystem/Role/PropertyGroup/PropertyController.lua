-- Name: PropertyController
-- Func: 角色属性控制器
-- Author: Johny

PropertyController = class("PropertyController")


function PropertyController:ctor(_role, _roledata)
	self.mRole = _role
	self.mRoleData = _roledata
	self.mMaxHP = _roledata.mMaxHP
	self.mCurHP = _roledata.mHP 
	self.mHarm = 1
	self.mBuffHurtCoefficient = 1
	self.mBuffReverseHurt = 0
	self.mMasters = 0
	self:HarmCount(_role, _roledata)
	self.mAdvanceLevel = _roledata.mAdvanceLevel --进阶等级
	self:setAdvanceLevelKey(self.mAdvanceLevel)

	self.mHarm_JC = self.mHarm 
	self.mMaxHP_JC = self.mMaxHP
	self.mPhyAtt_JC = _roledata.mPhyAtt -- 格斗	
	self.mExpose_JC = _roledata.mExpose -- 破甲
	self.mArmor_JC = _roledata.mArmor   -- 护甲
	self.mHit_JC = _roledata.mHit       -- 功夫
	self.mDodge_JC = _roledata.mDodge   -- 柔术
	self.mCrit_JC = _roledata.mCrit     -- 暴击
	self.mTough_JC = _roledata.mTough   -- 任性
	self:setAttRate(_roledata.mAttRate)  -- 攻击速度
	self:setSpeed(_roledata.mSpeed)   -- 移动速度

	self.mSpeed_JC = self.mSpeed
   	self.mSpeedY_JC = self.mSpeedY
    self.mAttRate_JC = self.mAttRate
	self.mAttRatePer_JC = self.mAttRatePer
	self.mJump_JC = _roledata.mJump     -- 跳跃力

	self.mPhyAtt = self.mPhyAtt_JC -- 格斗	
	self.mExpose = self.mExpose_JC -- 破甲
	self.mArmor = self.mArmor_JC   -- 护甲
	self.mHit = self.mHit_JC       -- 功夫
	self.mDodge = self.mDodge_JC   -- 柔术
	self.mCrit = self.mCrit_JC     -- 暴击
	self.mTough = self.mTough_JC   -- 任性
	self.mJump = self.mJump_JC    -- 跳跃力

	-- 怪物多管血
	if self.mRole.mGroup == "monster" then
		self.mRowHp = self.mMaxHP/_roledata.mInfoDB.Monster_HPCount
	end
end

-- 
function PropertyController:setAdvanceLevelKey(_level)
	if self.mMasters == 1 then
		self.mGroup_Advance = string.format("Gedou_%d",_level) 
	elseif self.mMasters == 2 then
		self.mGroup_Advance = string.format("Gongfu_%d",_level) 
	elseif self.mMasters == 3 then
		self.mGroup_Advance = string.format("Roushu_%d",_level) 
	elseif self.mMasters == 4 then
		self.mGroup_Advance = string.format("MRoushu_%d",_level)
	elseif self.mMasters == 5 then
		self.mGroup_Advance = string.format("MRoushu_%d",_level)
	elseif self.mMasters == 6 then
		self.mGroup_Advance = string.format("MRoushu_%d",_level)
	end
end

function PropertyController:copyProperty(property)

	self.mMaxHP = property.mMaxHP_JC
	self.mMaxHP_JC = self.mMaxHP
	self.mCurHP = property.mMaxHP_JC
	self.mHarm = 1
	self:HarmCountForCopy(property)
	self.mAdvanceLevel = property.mAdvanceLevel --进阶等级
	self:setAdvanceLevelKey(self.mAdvanceLevel)

	self.mPhyAtt = property.mPhyAtt_JC -- 格斗	
	self.mExpose = property.mExpose_JC -- 破甲
	self.mArmor = property.mArmor_JC   -- 护甲
	self.mHit = property.mHit_JC       -- 功夫
	self.mDodge = property.mDodge_JC   -- 柔术
	self.mCrit = property.mCrit_JC     -- 暴击
	self.mTough = property.mTough_JC   -- 任性
	self.mAttRate = property.mAttRate_JC
	self.mAttRatePer =  property.mAttRatePer_JC
	self.mJump = property.mJump_JC     -- 跳跃力

	self.mPhyAtt_JC = property.mPhyAtt_JC -- 格斗	
	self.mExpose_JC = property.mExpose_JC -- 破甲
	self.mArmor_JC = property.mArmor_JC   -- 护甲
	self.mHit_JC = property.mHit_JC       -- 功夫
	self.mDodge_JC = property.mDodge_JC   -- 柔术
	self.mCrit_JC = property.mCrit_JC     -- 暴击
	self.mTough_JC = property.mTough_JC   -- 任性
	self.mAttRate_JC = property.mAttRate_JC
	self.mAttRatePer_JC =  property.mAttRatePer_JC
	self.mJump_JC = property.mJump_JC     -- 跳跃力
end

function PropertyController:HarmCount(_role, _roledata)
	if self.mRole.mGroup == "monster" or self.mRole.mGroup == "summonmonster"  or self.mRole.mGroup == "summonfriend" then
		self.mMasters = self.mRoleData.mInfoDB.Monster_Group
		if self.mRoleData.mInfoDB.Monster_Group == 1 or self.mRoleData.mInfoDB.Monster_Group == 4 then
			self.mHarm = 0.7*_roledata.mPhyAtt + 0.3*_roledata.mHit + 0.3*_roledata.mDodge
		elseif self.mRoleData.mInfoDB.Monster_Group == 2 or self.mRoleData.mInfoDB.Monster_Group == 5 then
			self.mHarm = 0.3*_roledata.mPhyAtt + 0.7*_roledata.mHit + 0.3*_roledata.mDodge
		elseif self.mRoleData.mInfoDB.Monster_Group == 3 or self.mRoleData.mInfoDB.Monster_Group == 6 then
			self.mHarm = 0.3*_roledata.mPhyAtt + 0.3*_roledata.mHit + 0.7*_roledata.mDodge
		end
	elseif self.mRole.mGroup == "enemyplayer" or self.mRole.mGroup == "friend" then
		self.mMasters = self.mRoleData.mInfoDB.HeroGroup
		if self.mRoleData.mInfoDB.HeroGroup == 1 then
			self.mHarm = 0.7*_roledata.mPhyAtt + 0.3*_roledata.mHit + 0.3*_roledata.mDodge
		elseif self.mRoleData.mInfoDB.HeroGroup == 2 then
			self.mHarm = 0.3*_roledata.mPhyAtt + 0.7*_roledata.mHit + 0.3*_roledata.mDodge
		elseif self.mRoleData.mInfoDB.HeroGroup == 3 then
			self.mHarm = 0.3*_roledata.mPhyAtt + 0.3*_roledata.mHit + 0.7*_roledata.mDodge
		end
	end
end

function PropertyController:HarmCountForCopy(property)
	if self.mRole.mGroup == "monster" or self.mRole.mGroup == "summonmonster"  or self.mRole.mGroup == "summonfriend" then
		self.mMasters = self.mRoleData.mInfoDB.Monster_Group
		if self.mRoleData.mInfoDB.Monster_Group == 1 or self.mRoleData.mInfoDB.Monster_Group == 4 then
			self.mHarm = 0.7*property.mPhyAtt_JC + 0.3*property.mHit_JC + 0.3*property.mDodge_JC
		elseif self.mRoleData.mInfoDB.Monster_Group == 2 or self.mRoleData.mInfoDB.Monster_Group == 5 then
			self.mHarm = 0.3*property.mPhyAtt_JC + 0.7*property.mHit_JC + 0.3*property.mDodge_JC
		elseif self.mRoleData.mInfoDB.Monster_Group == 3 or self.mRoleData.mInfoDB.Monster_Group == 6 then
			self.mHarm = 0.3*property.mPhyAtt_JC + 0.3*property.mHit_JC + 0.7*property.mDodge_JC
		end
		self.mRole.mHarm = self.mHarm
	elseif self.mRole.mGroup == "enemyplayer" or self.mRole.mGroup == "friend" then
		self.mMasters = self.mRoleData.mInfoDB.HeroGroup
		if self.mRoleData.mInfoDB.HeroGroup == 1 then
			self.mHarm = 0.7*property.mPhyAtt_JC + 0.3*property.mHit_JC + 0.3*property.mDodge_JC
		elseif self.mRoleData.mInfoDB.HeroGroup == 2 then
			self.mHarm = 0.3*property.mPhyAtt_JC + 0.7*property.mHit_JC + 0.3*property.mDodge_JC
		elseif self.mRoleData.mInfoDB.HeroGroup == 3 then
			self.mHarm = 0.3*property.mPhyAtt_JC + 0.3*property.mHit_JC + 0.7*property.mDodge_JC
		end
		self.mRole.mHarm = self.mHarm
	end
end

-- 更新mHarm
function PropertyController:UpdateHarm()
	if self.mRole.mGroup == "monster" or self.mRole.mGroup == "summonmonster"  or self.mRole.mGroup == "summonfriend" then
		if self.mRoleData.mInfoDB.Monster_Group == 1 or self.mRoleData.mInfoDB.Monster_Group == 4 then
			self.mHarm = 0.7*self.mPhyAtt + 0.3*self.mHit + 0.3*self.mDodge
		elseif self.mRoleData.mInfoDB.Monster_Group == 2 or self.mRoleData.mInfoDB.Monster_Group == 5 then
			self.mHarm = 0.3*self.mPhyAtt + 0.7*self.mHit + 0.3*self.mDodge
		elseif self.mRoleData.mInfoDB.Monster_Group == 3 or self.mRoleData.mInfoDB.Monster_Group == 6 then
			self.mHarm = 0.3*self.mPhyAtt + 0.3*self.mHit + 0.7*self.mDodge
		end
		self.mRole.mHarm = self.mHarm
	elseif self.mRole.mGroup == "enemyplayer" or self.mRole.mGroup == "friend" then
		if self.mRoleData.mInfoDB.HeroGroup == 1 then
			self.mHarm = 0.7*self.mPhyAtt + 0.3*self.mHit + 0.3*self.mDodge
		elseif self.mRoleData.mInfoDB.HeroGroup == 2 then
			self.mHarm = 0.3*self.mPhyAtt + 0.7*self.mHit + 0.3*self.mDodge
		elseif self.mRoleData.mInfoDB.HeroGroup == 3 then
			self.mHarm = 0.3*self.mPhyAtt + 0.3*self.mHit + 0.7*self.mDodge
		end
		self.mRole.mHarm = self.mHarm
	end
end

function PropertyController:Destroy()
	self.mRole = nil
	self.mRoleData = nil
	self.mMaxHP = nil
	self.mCurHP = nil
	self.mPhyAtt = nil
	self.mExpose = nil
	self.mArmor = nil
	self.mHit = nil
	self.mDodge = nil
	self.mCrit = nil
	self.mTough = nil
	self.mAttRate = nil
	self.mSpeed = nil
	self.mJump = nil
end

function PropertyController:Tick()

end

-- 被伤害
function PropertyController:OnDamaged(_damage, _hiter)
	local function xxx()
		if self.mRoleData.mInfoDB == nil then return end
		if self.mRole.mFEM:IsBeatStFly() or self.mRole.mFEM:IsBeatStFlight() or self.mRole.mFEM:IsFreeFall() then
	  		self.mRole.mBeatCon.mBeatFlyCount = self.mRole.mBeatCon.mBeatFlyCount + 1
	  		if self.mRole.mBeatCon.mBeatFlyCount >= 23 then
	  			self.mRole.mBeatCon.mBeatFlyCount = 0
	  			self.mRole:AddBuff(196)
	  		end
	  	else
	  		self.mRole.mBeatCon.mBeatTiffCount = self.mRole.mBeatCon.mBeatTiffCount + 1
	  		if self.mRole.mBeatCon.mBeatTiffCount >= 50 then
	  			self.mRole.mBeatCon.mBeatTiffCount = 0
	  			self.mRole:AddBuff(196)
	  		end
	  	end
		FightSystem.mTouchPad:DoublehitNum(self.mRole,_hiter)
		if self.mCurHP <= 0 then
			local con = not self.mRole.mFSM:IsDeading()
			local con1 = not self.mRole.mFSM:IsFallingDown()
			local con2 = not self.mRole.mFSM:IsBeControlled()
			if con and con1 and con2 then
				self:handleDead(_hiter)	
			end
			return
		end
		--
		--cclog("PropertyController:OnDamaged====" .. _damage)
		if FightSystem.mFightType == "olpvp" then
			return
		end
		_damage = math.ceil(_damage)
		local CurHp = self.mCurHP
		self.mCurHP = self.mCurHP - _damage
		if self.mCurHP <= 0 then
			_damage = CurHp
		end
		if FightSystem.mFightType == "arena" and globaldata.PvpType == "arena" then
			
			if _hiter.mGroup == "friend" then
				local index = _hiter.mPosIndex
				if not globaldata.mFriendPvpDamage[index] then
					local DamagData = {}
					DamagData.Name = ""
					DamagData.Damage = _damage
					globaldata.mFriendPvpDamage[index] = DamagData
				else
					globaldata.mFriendPvpDamage[index].Damage = globaldata.mFriendPvpDamage[index].Damage + _damage
				end
			elseif _hiter.mGroup == "enemyplayer" then
				local index = _hiter.mPosIndex
				if not globaldata.mEnemyPvpDamage[index] then
					local DamagData = {}
					DamagData.Name = ""
					DamagData.Damage = _damage
					globaldata.mEnemyPvpDamage[index] = DamagData
				else
					globaldata.mEnemyPvpDamage[index].Damage = globaldata.mEnemyPvpDamage[index].Damage + _damage
				end
			end
		elseif FightSystem.mFightType == "arena" and globaldata.PvpType == "boss" then
			if _hiter.mGroup == "friend" or _hiter.mGroup == "summonfriend" then
				local index = 1
				if _hiter.mGroup == "friend" then
					index = _hiter.mPosIndex
				else
					if _hiter.mHost then
						index = _hiter.mHost.mPosIndex
					end
				end	
				if not globaldata.mFriendPvpDamage[index] then
					globaldata.mFriendPvpDamage[index] = _damage
				else
					globaldata.mFriendPvpDamage[index] = globaldata.mFriendPvpDamage[index] + _damage
				end
			end
		end
		FightSystem.mTouchPad:OnRolePropertyChangeEvent(1, -_damage, self.mRole, _hiter)
		-- 检查是否没血了
		--[[ --注掉涨MP
		if self.mRole.mGroup == "friend" or self.mRole.mGroup == "enemyplayer" or (FightSystem:GetModelByType(4) and self.mRole.mGroup == "monster" ) then
			self.mRole.mSkillCon:AddMp(1)
		end
		]]
		if self.mCurHP <= 0 then
			self.mCurHP = 0
			self:handleDead(_hiter)
			FightSystem:LastMonsterKilled(self.mRole)
			--[[ --注掉涨MP
			if self.mRole.mGroup == "monster" or self.mRole.mGroup == "enemyplayer" then
				if _hiter.mGroup == "friend" then
					_hiter.mSkillCon:AddMp(10)
				end
			end
			if self.mRole.mGroup == "friend" then
				if _hiter.mGroup == "enemyplayer" or ((FightSystem:GetModelByType(4) and _hiter.mGroup == "monster" )) then
					_hiter.mSkillCon:AddMp(10)
				end
			end
			]]
		end
	end
	
	caculateFuncDuring("PropertyController:OnDamaged",xxx)
end

-- 加血
function PropertyController:OnHealed(_healCount, _releaser)
	if _healCount <= 0 then return end
	self.mRole.mFlowLabelCon:FlowAddBlood(_healCount)
	--if self.mCurHP >= self.mMaxHP then return end
	self.mCurHP = self.mCurHP + _healCount
	if self.mCurHP > self.mMaxHP then
	   self.mCurHP = self.mMaxHP
	   _healCount = (self.mMaxHP - self.mCurHP)
	end
	FightSystem.mTouchPad:OnRolePropertyChangeEvent(1, _healCount, self.mRole, _hiter)
end

function PropertyController:IsHpEmpty()
	return self.mCurHP <= 0
end

function PropertyController:handleDead(_hiter,dir)
	local isfaceleft = nil
	if dir then
		isfaceleft = not self.mRole.IsFaceLeft
	else
		isfaceleft = _hiter.IsFaceLeft
	end
	self.mRole:playVoiceSound(6)
	if self.mRole.mFEM:IsFrozen() then
	   self.mRole.mFSM:ForceChangeToState("dead")
	   self.mRole:RemoveSelfByFrozen()
    elseif self.mRole.mFSM:IsFallingDown() then
		if self.mRole.mBeatCon.mFalldownCon.mDowningDuring > 0 then
			self.mRole.mFSM:ForceChangeToState("dead")
		else
			self.mRole.mFEM:changetoDeadFly(isfaceleft)
		end
	elseif self.mRole.mFSM:IsBeGriped() then
		cclog("被抓投中， 还不能死")
	else
		self.mRole.mFSM:ForceChangeToState("becontroled")
		self.mRole.mFEM:changetoDeadFly(isfaceleft)
	end
end

-- 改变属性
function PropertyController:ChangeProperty(_key, _valueDis, _valuePercent)
	if _key == "attrate" then
	   self:setAttRatePer(self.mAttRatePer * (1 + _valueDis))
	elseif _key == "speed" then
	   self:setSpeed(self.mSpeed*(1 + _valueDis))
	elseif _key == "hpmax" then
	   self.mMaxHP = self.mMaxHP + _valueDis + self.mMaxHP_JC*_valuePercent
	   if self.mMaxHP <= 0 then self.mMaxHP = 1 end
	elseif _key == "phyatt" then
	   self.mPhyAtt = self.mPhyAtt + _valueDis + self.mPhyAtt_JC*_valuePercent
	   if self.mPhyAtt <= 0 then self.mPhyAtt = 1 end
	   self:UpdateHarm()
	elseif _key == "expose" then
	   self.mExpose = self.mExpose + _valueDis + self.mExpose_JC*_valuePercent
	   if self.mExpose <= 0 then self.mExpose = 1 end
	elseif _key == "armor" then
	   self.mArmor = self.mArmor + _valueDis + self.mArmor_JC*_valuePercent
	   if self.mArmor <= 0 then self.mArmor = 1 end
	elseif _key == "hit" then
	   self.mHit = self.mHit + _valueDis + self.mHit_JC*_valuePercent
	   if self.mHit <= 0 then self.mHit = 1 end
	   self:UpdateHarm()
	elseif _key == "dodge" then
	   self.mDodge = self.mDodge + _valueDis + self.mDodge_JC*_valuePercent
	   if self.mDodge <= 0 then self.mDodge = 1 end
	   self:UpdateHarm()
	elseif _key == "crit" then
	   self.mCrit = self.mCrit + _valueDis + self.mCrit_JC*_valuePercent
	   if self.mCrit <= 0 then self.mCrit = 1 end
	elseif _key == "tough" then
	   self.mTough = self.mTough + _valueDis + self.mTough_JC*_valuePercent
	   if self.mTough <= 0 then self.mTough = 1 end
	end
end

-- 更新最后伤害

-- 恢复属性
function PropertyController:ResumeProperty(_key, _valueDis, _valuePercent)
	if _key == "attrate" then
	   self:resetAttRate()
	elseif _key == "speed" then
	   self:resetSpeed()
	elseif _key == "hpmax" then
	   self.mMaxHP = self.mMaxHP - _valueDis - self.mMaxHP_JC*_valuePercent
	   if self.mMaxHP <= 0 then self.mMaxHP = 1 end
	elseif _key == "phyatt" then
	   self.mPhyAtt = self.mPhyAtt - _valueDis - self.mPhyAtt_JC*_valuePercent
	   if self.mPhyAtt <= 0 then self.mPhyAtt = 1 end
	   self:UpdateHarm()
	elseif _key == "expose" then
	   self.mExpose = self.mExpose - _valueDis - self.mExpose_JC*_valuePercent
	   if self.mExpose <= 0 then self.mExpose = 1 end
	elseif _key == "armor" then
	   self.mArmor = self.mArmor - _valueDis - self.mArmor_JC*_valuePercent
	   if self.mArmor <= 0 then self.mArmor = 1 end
	elseif _key == "hit" then
	   self.mHit = self.mHit - _valueDis - self.mHit_JC*_valuePercent
	   if self.mHit <= 0 then self.mHit = 1 end
	   self:UpdateHarm()
	elseif _key == "dodge" then
	   self.mDodge = self.mDodge - _valueDis - self.mDodge_JC*_valuePercent
	   if self.mDodge <= 0 then self.mDodge = 1 end
	   self:UpdateHarm()
	elseif _key == "crit" then
	   self.mCrit = self.mCrit - _valueDis - self.mCrit_JC*_valuePercent
	   if self.mCrit <= 0 then self.mCrit = 1 end
	elseif _key == "tough" then
	   self.mTough = self.mTough - _valueDis - self.mTough_JC*_valuePercent
	   if self.mTough <= 0 then self.mTough = 1 end
	end
end

function PropertyController:setSpeed(_speed)
   -- 限制速度
   if _speed < 0 then _speed = 0 end
   self.mSpeed = _speed
   self.mSpeedY = _speed * math.sin(math.rad(30))
end

--	设置车速
function PropertyController:setHorseSpeed(_speed)
   -- 限制速度
   self.mSpeed = _speed
   self.mSpeed = math.floor(self.mSpeed)
   self.mSpeedY = self.mSpeed * math.sin(math.rad(30))
end

function PropertyController:resetSpeed()
    self:setSpeed(self.mRoleData.mSpeed)
end

-- 设置攻击速度
function PropertyController:setAttRate(_attrate)
	self.mAttRate = _attrate
	self.mAttRatePer =  self.mAttRate / 1000
end

-- 设置攻击速率
function PropertyController:setAttRatePer(_per)
	self.mAttRatePer = _per
end

function PropertyController:resetAttRate()
	self:setAttRate(self.mRoleData.mAttRate)
end