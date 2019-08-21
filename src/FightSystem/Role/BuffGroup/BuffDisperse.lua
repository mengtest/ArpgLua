-- Name: 净化状态
-- Author: Johny

BuffDisperse = class("BuffDisperse")

function BuffDisperse:ctor(_role, _buffCon, _releaser, _dbState, _dbEff)
	self.mRole = _role
	self.mBuffCon = _buffCon
	self.mReleaser = _releaser
	self.mStateDbData = _dbState
	self.mStateID = _dbState.ID
	self.mEffMethod = 204
	self.mType = "buff"
	self.mName = "disperse"
	self.mDuringType = _dbState.TimeType
	self.mDuring = _dbState.LastTime

	self.mEffect = {}

	self.mDisperseType = _dbEff.Data1 -- 1: effmethod 2: stateid
	self.mDisperseList = {}
	for i = 2,8 do
		local keyData = string.format("Data%d",i)
	    local _value = _dbEff[keyData]
	    if _value ~= 0 then
	       table.insert(self.mDisperseList, _value)
	    end
	end
	--
	self.mBuffCon:disperseDebuff(self.mDisperseType, self.mDisperseList)

	self.mBuffCon:addLightEffect(_dbState,self)
end


function BuffDisperse:Destroy()
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

function BuffDisperse:Tick(delta)
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