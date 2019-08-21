-- Name: 替换技能状态
-- Author: Johny

BuffSkillReplaced = class("BuffSkillReplaced")

function BuffSkillReplaced:ctor(_role, _buffCon, _releaser, _dbState, _dbEff)
	self.mRole = _role
	self.mBuffCon = _buffCon
	self.mReleaser = _releaser
	self.mStateID = _dbState.ID
	self.mEffMethod = 401
	self.mType = "midbuff"
	self.mName = "skillreplaced"
	self.mDuringType = _dbState.TimeType
	self.mDuring = _dbState.LastTime
	self.mEffect = {}
	self.mSkillField = _dbEff.Data1
	self.mSkillID = _dbEff.Data2
	--
	self.mRole.mRoleData:setField("m" .. self.mSkillField, self.mSkillID)
	self.mBuffCon:addLightEffect(_dbState,self)
end

function BuffSkillReplaced:Destroy()
	self.mRole.mPropertyCon:ResumeProperty("speed")
	self.mRole = nil
	self.mBuffCon = nil
	self.mReleaser = nil
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

function BuffSkillReplaced:Tick(delta)
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
		if not self.mRole:IsControlByStaticFrameTime() then
			self.mDuring = self.mDuring - 1
		end
	else
		self.mBuffCon:removeBuff(self)
	end
end