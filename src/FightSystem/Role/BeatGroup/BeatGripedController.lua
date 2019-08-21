-- Name: BeatGripedController
-- Author: Johny

BeatGripedController = class("BeatGripedController")


function BeatGripedController:ctor(_role)
	self.mRole = _role
	self.mHiter = nil
	self.mState = "normal"
	self.mNeedBindPos = false
	self.mNeedReverseWhenUngriped = false
	self.mIsRise = false
end

function BeatGripedController:Destroy()
	self.mRole = nil
	self.mHiter = nil
	self.mIsRise = nil
end

function BeatGripedController:Tick()
	if self.mIsRise then
		self:TickSelfGripedRise(self.mHiter)
	else
		self:TickSelfGripedPos(self.mHiter)
	end
end

-- 检查上升抓投位置
function BeatGripedController:TickSelfGripedRise(_hiter)
	if not _hiter then return end
	local _gripPos = _hiter.mArmature.mSpine:getBonePosition("grip")
	self.mRole:setPositionY(_gripPos.y+self.mRole:getShadowPos().y)
	self.mRole.mShadow:ShadowChangeScale()
end

-- 检查抓投位置
function BeatGripedController:TickSelfGripedPos(_hiter)
	if not self.mNeedBindPos then return end
	if self.mIsRise then return end
	if not _hiter.mArmature then return end
	local _hiterPos = _hiter:getPosition_pos()
	local _gripPos = _hiter.mArmature.mSpine:getBonePosition("grip")
	local flag = 1
	if _hiter.IsFaceLeft then
	  _gripPos.x = - _gripPos.x
	end
	local _hiterScale = _hiter.mArmature:getModelScale()
	local _hiterbonepos = cc.p(_gripPos.x*_hiterScale + _hiterPos.x, _gripPos.y*_hiterScale + _hiterPos.y)
	local _selfbonepos = self.mRole.mArmature.mSpine:getBonePosition("c-body")

	if self.mRole.IsFaceLeft then
		_selfbonepos.x = - _selfbonepos.x
		
	else
		flag = -1
	end

	local _selfScale = self.mRole.mArmature:getModelScale()
	
	local _selfRotation = self.mRole.mArmature.mSpine:getRotation()

	local _selfScale = self.mRole.mArmature:getModelScale()
	local w1 = _selfScale*_selfbonepos.x
	local h1 = _selfScale*_selfbonepos.y
	local r2 = math.sqrt(w1*w1 + h1*h1)

	local _selfRotation2 = math.rad(math.deg(cc.pToAngleSelf(_selfbonepos)) + _selfRotation)

	--cclog("c-bodyX===" ..w1 .."=c-bodyY===" ..h1)

	--cclog("c-bodypToAngleSelf===" .. math.deg(cc.pToAngleSelf(_selfbonepos)).. "==_selfRotation2==" .._selfRotation)

	local _gripPos_sceneX = _hiterbonepos.x - flag*r2*math.cos(_selfRotation2)
	local _gripPos_sceneY = _hiterbonepos.y - r2*math.sin(_selfRotation2)
	--cclog("COSX===" ..r2*math.cos(_selfRotation2) .. "=SINX===" ..r2*math.sin(_selfRotation2))
	--cclog("_gripPos_sceneX==" .. _gripPos_sceneX .. "=_gripPos_sceneY==".._gripPos_sceneY)

--[[

	local _selfRotation = self.mRole.mArmature:getRotation()
	local _gripPos_sceneX = _hiterbonepos.x - _selfbonepos.x *_selfScale
	local _gripPos_sceneY = _hiterbonepos.y - math.cos(math.rad(_selfRotation))*_selfbonepos.y*_selfScale
]]

	self.mRole:forceSetPositionX(_gripPos_sceneX)
	self.mRole:forceSetPositionY(_gripPos_sceneY)

	self.mRole.mShadow:setPositionX(_hiterPos.x)
	self.mRole.mShadow:setPositionY(_hiterPos.y)

	--SpineShadowRenderManager:offSetShadow(self.mRole,self.mRole.mSpineShadow,_gripPos)
	if self.mRole.mSpineShadow then
		 local _param1 = math.rad(self.mRole.mSpineShadow.mSkewX)
	     local _offsetY = math.cos(_param1) * _gripPos.y * self.mRole.mSpineShadow.mScaleY
		 local _offsetX = _offsetY * math.tan(_param1) 
	     self.mRole.mSpineShadow:setPositionX(_offsetX + self.mRole:getPositionX())
	     self.mRole.mSpineShadow:setPositionY(_offsetY + _hiterPos.y)
	end
	-- 保证层级小于攻击者
	local _zorder = _hiter:getLocalZOrder()
	self.mRole:setLocalZOrder(_zorder - 1)
end

-- 检查死亡
function BeatGripedController:TickStatus_dead(_hiter)
	if self.mRole.mPropertyCon:IsHpEmpty() then
	   self.mRole.mArmature:ActionNow("beBlowUpEnd")
	   self.mRole.mFSM:ForceChangeToState("dead")
	   self.mRole:RemoveSelf()
	else
	   self.mRole.mFSM:ForceChangeToState("idle")
	end
	self:ResetReverse()
end

function BeatGripedController:ResetReverse()
	 self.mRole.mArmature:setSpineRotation(0)
	  if self.mNeedReverseWhenUngriped then
	     self.mRole:TurnReverse()
	  end
end

-- 设置被抓头显示
function BeatGripedController:OnGripTargetAct(_dbprogress)
	local _action = _dbprogress.GripTargetAct[1]
	local _Frame = _dbprogress.GripTargetAct[2]
	if _action == "" then return end
	self.mRole.mArmature.mSpine:stopOnAnyAnimationAndFrame(_action,_Frame)
end

-- 被抓投
function BeatGripedController:OnGriped(_hiter, _action)
	if self.mRole.mFSM:IsAttacking() then
	   self.mRole.mSkillCon:FinishCurSkill()	  
	end
	if self.mRole.mFSM:ForceChangeToState("begriped") then
		self.mState  = "griped"
		self.mRole.mArmature:setNoReceiveAction(false)
		self.mRole.mArmature.mSpine:stopOnAnyAnimationAndFrame(_action[1],_action[2])
		self.mHiter = _hiter
		self.mRole:setPositionY(_hiter:getPositionY())
		self.mRole:syncShadowPosWithRolePos()
		self.mRole.mShadow:setStateForGriped(true)
		self.mRole.mArmature:setVisiMonsterBlood(false)
		self.mIsRise = false
	end
end

-- 腾空被抓投
function BeatGripedController:OnGripedAir(_hiter, _action)
	if self.mRole.mFSM:IsAttacking() then
	   self.mRole.mSkillCon:FinishCurSkill()	  
	end
	if self.mRole.mFSM:ForceChangeToState("begriped") then
		self.mState  = "griped"
		self.mRole.mArmature:setNoReceiveAction(false)
		self.mRole.mArmature.mSpine:stopOnAnyAnimationAndFrame(_action[1],_action[2])
		self.mHiter = _hiter
		local _gripPos = self.mHiter.mArmature.mSpine:getBonePosition("grip")
		self.mRole:setPositionY(_gripPos.y+self.mRole:getShadowPos().y)
		self.mRole.mShadow:setStateForGriped(true)
		--self.mRole.mArmature:setVisiMonsterBlood(false)
		self.mIsRise = true
		self.mRole.mShadow:ShadowChangeScale()
	end
end

-- 旋转抓投者
function BeatGripedController:OnRotated(_rotate,_hiter)
	self.mNeedBindPos = true
	if _rotate == 0 then return end
	-- if self.mHiter.IsFaceLeft then _rotate = - _rotate end
	if _hiter.IsFaceLeft then
		self.mRole:FaceRight()
	else
		self.mRole:FaceLeft()
	end
	self.mRole.mArmature:setSpineRotation(_rotate)
end

-- 空中位移
function BeatGripedController:OnRiseed(_hiter)
	self.mIsRise = true
	self.mRole.mShadow:setStateForGriped(true)
	local _gripPos = _hiter.mArmature.mSpine:getBonePosition("grip")
	self.mRole:setPositionY(_gripPos.y+self.mRole:getShadowPos().y)
	self.mRole.mShadow:ShadowChangeScale()
end

-- 释放抓投
function BeatGripedController:OnGripReleased(_needReverse)
	if not self.mHiter  then return end
	self.mState  = "ungriped"
	self.mNeedReverseWhenUngriped = _needReverse == 1
	if self.mIsRise then
		if self.mRole.mShadow:IsSameHorWithRole() <= 0 then
			self.mRole:setPositionY(self.mRole:getShadowPos().y)
			self.mRole.mShadow:ShadowRestoreScale()
			self.mRole:BackDis(0)
			self.mRole.mShadow:setStateForGriped(false)
			self.mRole:syncShadowPosWithRolePos()
			self.mRole.mArmature:setVisiMonsterBlood(true)
			self:TickStatus_dead(self.mHiter)
		else
			self.mRole.mFSM:ForceChangeToStateNoAction("becontroled")
			self.mRole:BackDis(0)
			self.mRole.mShadow:setStateForGriped(false)
			self:ResetReverse()
			self.mRole.mFEM:ChangeToBeatEffect(6)
		end
		self.mIsRise = nil
	else
		self.mRole:setPositionY(self.mHiter:getPositionY())
		self.mRole:BackDis(0)
		self.mRole.mShadow:setStateForGriped(false)
		self.mRole:syncShadowPosWithRolePos()
		self.mRole.mArmature:setVisiMonsterBlood(true)
		self:TickStatus_dead(self.mHiter)
	end
	self.mState = "normal"
	self.mHiter = nil
	self.mNeedBindPos = false
end

-- 释放抓投ForPVP
function BeatGripedController:OnGripReleasedForPVP()
	self.mState  = "ungriped"
	self.mNeedReverseWhenUngriped = nil
	self.mRole.mShadow:setStateForGriped(false)
	self.mRole.mArmature:setVisiMonsterBlood(true)
	self.mState = "normal"
	self.mHiter = nil
	self.mNeedBindPos = false
end