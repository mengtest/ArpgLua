-- Name: 拉回状态
-- Author: Johny

BuffPullBack = class("BuffPullBack")

function BuffPullBack:ctor(_role, _buffCon, _releaser, _dbState, _dbEff)
	self.mRole = _role
	self.mBuffCon = _buffCon
	self.mReleaser = _releaser
	self.mStateID = _dbState.ID
	self.mEffMethod = 105
	self.mType = "debuff"
	self.mName = "pullback"
	self.mDuringType = _dbState.TimeType
	self.mDuring = _dbState.LastTime
	self.mEffect = {}
	self.mV = _dbEff.Data1
	self.mBuffCon:addLightEffect(_dbState,self)
end

function BuffPullBack:Destroy()
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

function BuffPullBack:Tick(delta)
	if #self.mEffect ~= 0 then
		for i,v in ipairs(self.mEffect) do
			if v.HangType == 0 and v.HangBone ~= "" then
				local _bonePos = self.mRole.mArmature.mSpine:getBonePosition(v.HangBone)
				v.SpineNode:setPositionY(_bonePos.y*self.mRole.mArmature.mScale)
			end
		end
	end
	if self.mDuringType == 1 then return end
	if not self.mReleaser.mIsLiving or self.mRole.mFSM:IsBeGriped() then 
	   self.mBuffCon:removeBuff(self)
	return end
	---
	if self.mDuring > 0 then
		local _curPos = self.mRole:getShadowPos()
		local _dePos = self.mReleaser:getPosition_pos()
		local _dis = MathExt.GetDisByTwoPoint(_curPos, _dePos)
		if _dis > self.mV then
			if not self.mRole:hasNoControlBuffNow() then
				local _deg = MathExt.GetDegreeWithTwoPoint(_curPos, _dePos)
				local _nextX = _curPos.x - math.cos(math.rad(_deg)) * self.mV
				local _nextY = _curPos.y - math.sin(math.rad(_deg)) * self.mV

				if self.mRole.mShadow:IsSameHorWithRole() <= 0 then
					_nextX = self.mRole.mMoveCon:filtPosX(_nextX)
					self.mRole:setPositionX(_nextX)
					if TiledMoveHandler.CanPosStand(cc.p(self.mRole:getPosition_pos().x, _nextY),self.mRole.mSceneIndex) then
						self.mRole:setPositionY(_nextY)
					end				
				else
					_nextX = self.mRole.mMoveCon:filtPosX(_nextX)
					if TiledMoveHandler.CanPosStand(cc.p(_nextX, _nextY),self.mRole.mSceneIndex) then 
						self.mRole:setPositionX(_nextX,true)
						self.mRole:setShadowPosY(_nextY)
						self.mRole:setPositionY(self.mRole:getPositionY() - (_curPos.y - _nextY))
					end
				end
			end
		end
		if not self.mRole:IsControlByStaticFrameTime() then
			self.mDuring = self.mDuring - 1
		end
	else
		self.mBuffCon:removeBuff(self)
	end
end