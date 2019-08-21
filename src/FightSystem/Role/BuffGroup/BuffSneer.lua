-- Name: 嘲讽buFF
-- Author: tuanzhang

BuffSneer = class("BuffSneer")

function BuffSneer:ctor(_role, _buffCon, _releaser, _dbState, _dbEff, _level)
	self.mRole = _role
	self.mBuffCon = _buffCon
	self.mReleaser = _releaser
	self.mStateDbData = _dbState
	self.mStateID = _dbState.ID
	self.mEffMethod = 108
	self.mType = "buff"
	self.mName = "sneer"
	self.mDuringType = _dbState.TimeType
	self.mDuring = _dbState.LastTime
	self.SkillLevel = 1
	if _level then
		self.SkillLevel = _level
	end
	self.mEffect = {}

	self.mInterval = _dbEff.Data1
	self.mIntervalCounter = 0
	--
	if self.mRole.mGroup == "friend" and self.mRole.IsKeyRole then
		-- 做下TouchPad显示
		FightSystem.mTouchPad:DisabledSkill(true)
		FightSystem.mTouchPad:DisabledAttack(true)
		FightSystem.mTouchPad:DisabledMove(true)
		FightSystem.mTouchPad:setCancelledTouchMove(true)
	end
	self.mRole.mPickupCon:leavePickup()
	if self.mRole.mFSM:IsAttacking() then
		self.mRole.mSkillCon:FinishCurSkill()
		self.mRole.mFSM:ForceChangeToState("idle")
	end
	self.mRole.mAI:setSneerRole(self.mReleaser)
	self.mBuffCon:addLightEffect(_dbState,self)
end

function BuffSneer:Destroy()
	self.mRole = nil
	self.mBuffCon = nil
	self.mReleaser = nil
	self.mEffMethod = nil
	self.mType = nil
	self.mName = nil
	self.mDuring = nil
	self.mBasicDamage = nil
	if #self.mEffect ~= 0 then
		for i,v in ipairs(self.mEffect) do
			SpineDataCacheManager:collectFightSpineByAtlas(v.SpineEffect)
			v.SpineNode:removeFromParent()
		end
	end
	self.mEffect = nil
end

function BuffSneer:Tick(delta)
	if #self.mEffect ~= 0 then
		for i,v in ipairs(self.mEffect) do
			if v.HangType == 0 and v.HangBone ~= "" then
				local _bonePos = self.mRole.mArmature.mSpine:getBonePosition(v.HangBone)
				v.SpineNode:setPositionY(_bonePos.y*self.mRole.mArmature.mScale)
			end
		end
	end
	if self.mDuringType == 1 then return end
	if self.mDuring > 0 then
		self.mDuring = self.mDuring - 1
		if self.mReleaser and not self.mReleaser.mIsLiving then
			if self.mRole.mGroup == "friend" and self.mRole.IsKeyRole then
				-- 做下TouchPad显示
				FightSystem.mTouchPad:DisabledSkill(false)
				FightSystem.mTouchPad:DisabledAttack(false)
				FightSystem.mTouchPad:DisabledMove(false)
				FightSystem.mTouchPad:setCancelledTouchMove(false)
			end
			self.mRole.mAI:setSneerRole(nil)
			self.mRole.mAI:ResetAttack()
			self.mBuffCon:removeBuff(self)
		end
	else
		-- 回复Ai功能
		if self.mRole.mGroup == "friend" and self.mRole.IsKeyRole then
			-- 做下TouchPad显示
			FightSystem.mTouchPad:DisabledSkill(false)
			FightSystem.mTouchPad:DisabledAttack(false)
			FightSystem.mTouchPad:DisabledMove(false)
			FightSystem.mTouchPad:setCancelledTouchMove(false)
		end
		self.mRole.mAI:setSneerRole(nil)
		self.mRole.mAI:ResetAttack()
		self.mBuffCon:removeBuff(self)
	end
	
end