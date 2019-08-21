-- Name: 改变攻速状态
-- Author: Johny

BuffAttRate = class("BuffAttRate")

function BuffAttRate:ctor(_role, _buffCon, _releaser, _dbState, _dbEff)
	self.mRole = _role
	self.mBuffCon = _buffCon
	self.mReleaser = _releaser
	self.mStateDbData = _dbState
	self.mStateID = _dbState.ID
	self.mEffMethod = 301
	self.mType = "midbuff"
	self.mName = "attrate"
	self.mDuringType = _dbState.TimeType
	self.mDuring = _dbState.LastTime

	self.mEffect = {}

	self.mValue = _dbEff.Data1
	--
	self.mRole.mPropertyCon:ChangeProperty("attrate", self.mValue)
	self.mBuffCon:addLightEffect(_dbState,self)
end


function BuffAttRate:Destroy()
	self.mRole.mPropertyCon:ResumeProperty("attrate")
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

function BuffAttRate:Tick(delta)
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