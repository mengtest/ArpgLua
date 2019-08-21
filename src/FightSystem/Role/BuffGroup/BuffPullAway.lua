-- Name: 推开状态
-- Author: Johny

BuffPullAway = class("BuffPullAway")

function BuffPullAway:ctor(_role, _buffCon, _releaser, _dbState, _dbEff, _during)
	self.mRole = _role
	self.mBuffCon = _buffCon
	self.mReleaser = _releaser
	self.IsFaceLeft = _releaser.IsFaceLeft
	self.mStateID = _dbState.ID
	self.mEffMethod = 106
	self.mType = "debuff"
	self.mName = "pullaway"
	self.mDuringType = _dbState.TimeType
	self.mDuring = math.ceil(_during / _releaser.mPropertyCon.mAttRatePer)
	self.mEffect = {}
	--
	local _dis = _dbEff.Data1
	local num = math.random(90,100)
	_dis = math.ceil(_dis*num*0.01)
	local _hiterX = _releaser:getPositionX()
	local _x = self.mRole:getPositionX()
	_dis = _dis - math.abs(_hiterX - _x)
	if _dis <= 0 then 
		self.mDuring = 0
	else
		self.mV, self.mA = MathExt.GetAandV0InUniformDeceleration_0(_dis, self.mDuring)
	end
	self.mBuffCon:addLightEffect(_dbState,self)
end

function BuffPullAway:Destroy()
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

function BuffPullAway:Tick(delta)
	if #self.mEffect ~= 0 then
		for i,v in ipairs(self.mEffect) do
			if v.HangType == 0 and v.HangBone ~= "" then
				local _bonePos = self.mRole.mArmature.mSpine:getBonePosition(v.HangBone)
				v.SpineNode:setPositionY(_bonePos.y*self.mRole.mArmature.mScale)
			end
		end
	end
	if self.mRole.mFSM:IsBeGriped() then
		self.mBuffCon:removeBuff(self)
		return
	end
	if self.mDuringType == 1 then return end
	if self.mDuring > 0 then
		if self.mV > 0 then
			local Vt = MathExt.GetV1InUniformDeceleration(self.mV, self.mA, 1)
			local dis = (self.mV+Vt)/2
			if not self.mRole:hasNoControlBuffNow() then
				self.mRole:BeatAwayDis(dis, self.IsFaceLeft)
			end
			self.mV = Vt
		end
		if not self.mRole:IsControlByStaticFrameTime() then
			self.mDuring = self.mDuring - 1
		end
	else
		self.mBuffCon:removeBuff(self)
	end
	
end