-- Name: 剩余血量百分比扣血
-- Author: tuanzhang

BuffSurplusBlood = class("BuffSurplusBlood")

function BuffSurplusBlood:ctor(_role, _buffCon, _releaser, _dbState, _dbEff, _level)
	self.mRole = _role
	self.mBuffCon = _buffCon
	self.mReleaser = _releaser
	self.mStateDbData = _dbState
	self.mStateID = _dbState.ID
	self.mEffMethod = 111
	self.mType = "buff"
	self.mName = "surplusblood"
	self.mDuringType = _dbState.TimeType
	self.mDuring = 1--_dbState.LastTime
	self.SkillLevel = 1
	if _level then
		self.SkillLevel = _level
	end
	self.mEffect = {}
	self.mHurtCoefficient = _dbEff.Data1/1000
	local Basic = 1
	local Damage = self.mRole.mPropertyCon.mCurHP * self.mHurtCoefficient
	if self.mRole.mGroup == "monster" then
		if self.mRole.mRoleData.mInfoDB.Monster_Grade == 4 then
			Basic = 1/3
		elseif self.mRole.mRoleData.mInfoDB.Monster_Grade == 5 then
			Basic = 0
		end
	end
	Damage = Damage*Basic
	if Damage > 0 then
		self.mRole.mBeatCon:Beated_debuff(self.mReleaser, Damage)
	end
end

function BuffSurplusBlood:Destroy()
	self.mRole = nil
	self.mBuffCon = nil
	self.mReleaser = nil
	self.mEffMethod = nil
	self.mType = nil
	self.mName = nil
	self.mDuring = nil
	self.mEffect = nil
end

function BuffSurplusBlood:Tick(delta)

	if self.mDuringType == 1 then return end
	if self.mDuring > 0 then
		self.mDuring = self.mDuring - 1
	else
		self.mBuffCon:removeBuff(self)
	end
	
end