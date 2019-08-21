-- Name: 最终伤害量
-- Author: tuanzhang

BuffDamage = class("BuffDamage")

function BuffDamage:ctor(_role, _buffCon, _releaser, _dbState, _dbEff, _level)
	self.mRole = _role
	self.mBuffCon = _buffCon
	self.mReleaser = _releaser
	self.mStateDbData = _dbState
	self.mStateID = _dbState.ID
	self.mEffMethod = 304
	self.mType = "buff"
	self.mName = "damageper"
	self.mDuringType = _dbState.TimeType
	self.mDuring = _dbState.LastTime
	self.SkillLevel = 1
	if _level then
		self.SkillLevel = _level
	end
	self.mEffect = {}

	self.mHurtCoefficient = _dbEff.Data1/1000

	self.mRole.mPropertyCon.mBuffHurtCoefficient = self.mRole.mPropertyCon.mBuffHurtCoefficient + self.mHurtCoefficient
	--
	--
	self.mBuffCon:addLightEffect(_dbState,self)
end

function BuffDamage:Destroy()
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

function BuffDamage:Tick(delta)
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
		self.mRole.mPropertyCon.mBuffHurtCoefficient = self.mRole.mPropertyCon.mBuffHurtCoefficient - self.mHurtCoefficient
		self.mBuffCon:removeBuff(self)
	end
	
end