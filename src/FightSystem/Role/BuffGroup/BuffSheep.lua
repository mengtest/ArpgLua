-- Name: 变形状态
-- Author: Johny

BuffSheep = class("BuffSheep")

function BuffSheep:ctor(_role, _buffCon, _releaser, _dbState, _dbEff)
	self.mRole = _role
	self.mBuffCon = _buffCon
	self.mReleaser = _releaser
	self.mStateID = _dbState.ID
	self.mEffMethod = 107
	self.mType = "debuff"
	self.mName = "sheep"
	self.mDuringType = _dbState.TimeType
	self.mDuring = _dbState.LastTime
	self.mEffect = {}
	self.mResID = _dbEff.Data1
	local _resDB = DB_ResourceList.getDataById(self.mResID)
	CommonAnimation.changeSpine_common(self.mRole.mArmature.mSpine,_resDB.Res_path2, _resDB.Res_path1)
	self.mBuffCon:addLightEffect(_dbState,self)
end

function BuffSheep:Destroy()

	CommonAnimation.changeSpine_common(self.mRole.mArmature.mSpine,self.mRole.mArmature.mJson, self.mRole.mArmature.mAtlas)
	self.mRole = nil
	self.mBuffCon = nil
	self.mReleaser = nil
	self.mName = nil
	self.mDuring = nil
	self.mV = nil
	if #self.mEffect ~= 0 then
		for i,v in ipairs(self.mEffect) do
			SpineDataCacheManager:collectFightSpineByAtlas(v.SpineEffect)
			v.SpineNode:removeFromParent()
		end
	end
	self.mEffect = nil
end

function BuffSheep:Tick(delta)
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