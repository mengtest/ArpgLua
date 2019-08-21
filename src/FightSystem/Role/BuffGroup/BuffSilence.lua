-- Name: 沉默BUFF
-- Author: tuanzhang

BuffSilence = class("BuffSilence")

function BuffSilence:ctor(_role, _buffCon, _releaser, _dbState, _dbEff, _level)
	self.mRole = _role
	self.mBuffCon = _buffCon
	self.mReleaser = _releaser
	self.mStateDbData = _dbState
	self.mStateID = _dbState.ID
	self.mEffMethod = 109
	self.mType = "buff"
	self.mName = "silence"
	self.mDuringType = _dbState.TimeType
	self.mDuring = 150--_dbState.LastTime
	self.SkillLevel = 1
	if _level then
		self.SkillLevel = _level
	end
	self.mEffect = {}
	--
	--
	self.mBuffCon:addLightEffect(_dbState,self)
	if self.mRole.mGroup == "friend" and self.mRole.IsKeyRole then
		-- 做下TouchPad显示
		FightSystem.mTouchPad:DisabledSkill(true)
	end
	if self.mRole.mFSM:IsAttacking() then
		self.mRole.mSkillCon:FinishCurSkill()
		self.mRole.mFSM:ForceChangeToState("idle")
	end
	self.mRole.mAI:ResetAttack()
	self.mRole.mAI.IsNoExecuteSkill = true
end

function BuffSilence:Destroy()
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

function BuffSilence:Tick(delta)
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
	else
		self.mRole.mAI.IsNoExecuteSkill = false
		if self.mRole.mGroup == "friend" and self.mRole.IsKeyRole then
			-- 做下TouchPad显示
			FightSystem.mTouchPad:DisabledSkill(false)
		end
		self.mBuffCon:removeBuff(self)
	end
	
end