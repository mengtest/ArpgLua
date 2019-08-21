-- Name: 治疗状态
-- Author: Johny

BuffHeal = class("BuffHeal")

function BuffHeal:ctor(_role, _buffCon, _releaser, _dbState, _dbEff, _level)
	self.mRole = _role
	self.mBuffCon = _buffCon
	self.mReleaser = _releaser
	self.mStateID = _dbState.ID
	self.mEffMethod = 205
	self.mType = "buff"
	self.mName = "heal"
	self.mDuringType = _dbState.TimeType
	self.mDuring = _dbState.LastTime
	self.SkillLevel = 1
	if _level then
		self.SkillLevel = _level
	end
	self.mEffect = {}
	self.mInterval = _dbEff.Data1
	self.mIntervalCounter = 0
	self.mBasicDamage = _dbEff.Data2
	self.mDamageData3 = _dbEff.Data3
	self.mDamageData4 = _dbEff.Data4/1000
	self.mDamageData5 = _dbEff.Data5/1000
	--
	local MaxHp = 0
	if self.mReleaser.mGroup ~= "sceneani" then
		MaxHp = self.mReleaser.mRoleMaxHp
	end
	self.mToTalDamage = self.mBasicDamage + self.mDamageData3*self.SkillLevel + MaxHp*(self.mDamageData4+self.mDamageData5*self.SkillLevel)
	self.mBuffCon:addLightEffect(_dbState,self)
end

function BuffHeal:Destroy()
	self.mRole = nil
	self.mBuffCon = nil
	self.mReleaser = nil
	self.mEffMethod = nil
	self.mType = nil
	self.mName = nil
	self.mDuring = nil
	if #self.mEffect ~= 0 then
		for i,v in ipairs(self.mEffect) do
			SpineDataCacheManager:collectFightSpineByAtlas(v.SpineEffect)
			v.SpineNode:removeFromParent()
		end
	end
	self.mEffect = nil
end

function BuffHeal:Tick(delta)
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
		if self.mIntervalCounter == 0 then
		   self.mIntervalCounter = self.mInterval
		   local _healCount = self.mToTalDamage
		   if self.mRole.mPropertyCon.mCurHP <=0 then
		   		self.mDuring = 0
		   		self.mBuffCon:removeBuff(self)
		   		return
		   else
		   		if FightSystem.mFightType == "olpvp" then
		   		else
		   			self.mRole.mPropertyCon:OnHealed(_healCount, self.mReleaser)
		   		end
		   end
		end
		self.mIntervalCounter = self.mIntervalCounter - 1
		if not self.mRole:IsControlByStaticFrameTime() then
			self.mDuring = self.mDuring - 1
		end
	else
		self.mBuffCon:removeBuff(self)
	end
	
end