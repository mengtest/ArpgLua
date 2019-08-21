-- Name: 免疫状态
-- Author: Johny

BuffImmunity = class("BuffImmunity")

function BuffImmunity:ctor(_role, _buffCon, _releaser, _dbState, _dbEff)
	self.mRole = _role
	self.mBuffCon = _buffCon
	self.mReleaser = _releaser
	self.mStateID = _dbState.ID
	self.mEffMethod = 203
	self.mType = "buff"
	self.mName = "immunity"
	self.mDuringType = _dbState.TimeType
	self.mDuring = _dbState.LastTime
	self.mEffect = {}
	self.mImmuList = {}
	--
	for i = 1,8 do
		local keyData = string.format("Data%d",i)
	    local _effMethod = _dbEff[keyData]
	    if _effMethod ~= 0 then
	       table.insert(self.mImmuList, _effMethod)
	    end
	end
	self.mBuffCon:addLightEffect(_dbState,self)
end

function BuffImmunity:Destroy()
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

function BuffImmunity:Tick(delta)
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

-- 是否在免疫list
function BuffImmunity:isInImmuList(_effMethod)
	return isValueInTable(_effMethod, self.mImmuList)
end