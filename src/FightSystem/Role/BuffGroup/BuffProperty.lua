-- Name: 改变攻速状态
-- Author: Johny

BuffProperty = class("BuffProperty")

function BuffProperty:ctor(_role, _buffCon, _releaser, _dbState, _dbEff)
	self.mRole = _role
	self.mBuffCon = _buffCon
	self.mReleaser = _releaser
	self.mStateID = _dbState.ID
	self.mEffMethod = 303
	self.mType = "midbuff"
	self.mName = "property"
	self.mDuringType = _dbState.TimeType
	self.mDuring = _dbState.LastTime
	self.mEffect = {}
	self.mValue = _dbEff.Data2

	self.mValuePercent = _dbEff.Data3/1000
	--
	local _table = {[0] = "hpmax", [1] = "phyatt",[2] = "expose",[3] =  "armor",[4] =  "hit",[5] =  "dodge",[6] =  "crit",[7] =  "tough"}
	self.mKey = _table[_dbEff.Data1]
	self.mRole.mPropertyCon:ChangeProperty(self.mKey, self.mValue, self.mValuePercent)
	self.mFirstRotate = false
	self.mBuffCon:addLightEffect(_dbState,self,handler(self, self.onCustomEvent))
end

function BuffProperty:onCustomEvent(event)
	if event.type == 'event' then
    	local num = tonumber(event.eventData.name)
		if type(num) == "number" then
			if num == 2 then
				self.mBuffCon.mBuffRotateList[self.mStateID][4]:setLocalZOrder(-1)
			elseif num == 6 then
				self.mBuffCon.mBuffRotateList[self.mStateID][4]:setLocalZOrder(1)
			end
		end
	end
end

function BuffProperty:Destroy()
	self.mRole.mPropertyCon:ResumeProperty(self.mKey,self.mValue, self.mValuePercent)
	if #self.mEffect ~= 0 then
		for i,v in ipairs(self.mEffect) do
			SpineDataCacheManager:collectFightSpineByAtlas(v.SpineEffect)
			v.SpineNode:removeFromParent()
		end
	end
	self.mEffect = nil
	if self.mBuffCon.mBuffRotateList[self.mStateID] then
		self.mBuffCon.mBuffRotateList[self.mStateID] = nil
		self.mBuffCon:UpdateRotateList()
	end
	self.mRole = nil
	self.mBuffCon = nil
	self.mReleaser = nil
	self.mName = nil
	self.mDuring = nil
end

function BuffProperty:Tick(delta)
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