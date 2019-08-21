-- Name: 加弹夹
-- Author: tuanzhang

BuffAddClip = class("BuffAddClip")

function BuffAddClip:ctor(_role, _buffCon, _releaser, _dbState, _dbEff)
	self.mRole = _role
	self.mBuffCon = _buffCon
	self.mReleaser = _releaser
	self.mStateDbData = _dbState
	self.mStateID = _dbState.ID
	self.mEffMethod = 402
	self.mType = "buff"
	self.mName = "addclip"
	self.mDuringType = _dbState.TimeType
	self.mDuring = _dbState.LastTime
	--
	self.mEffect = {}

	self.mValue = _dbEff.Data1
	if _role.mGunCon.isHaveGun then
		local num = _role.mGunCon.mUseMaxCount*self.mValue
		if FightSystem.mRoleManager.mFriendBulletCount + num > _role.mGunCon.mUseMaxCount then
			FightSystem.mRoleManager.mFriendBulletCount = _role.mGunCon.mUseMaxCount
		else
			FightSystem.mRoleManager.mFriendBulletCountt = FightSystem.mRoleManager.mFriendBulletCount + num
		end
	end
	self.mBuffCon:addLightEffect(_dbState,self)
end

function BuffAddClip:Destroy()
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

function BuffAddClip:Tick(delta)
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