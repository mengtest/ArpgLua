-- Name: FalldownController
-- Author: tuanzhang

FalldownController = class("FalldownController")


function FalldownController:ctor(_role)
	self.mRole = _role
	self.mIsFalldowning = false
	self.mDowningDuring = -1
end

function FalldownController:Destroy()
	cclog("FalldownController:Destroy")
	self.mRole = nil
	self.mIsFalldowning = nil
end

function FalldownController:Tick(delta)
	if self.mRole:IsControlByStaticFrameTime() then return end
	if self.mRole.mFSM:IsFallingDown() or self.mRole.mFSM:IsDeading() then
	
		if self.mIsFalldowning then
			self:TickFalldown()
		end
		if not self.mRole.mFSM:IsDeading() and self.mVXDaodi and self.mVXDaodi ~= 0 then
			local _dis = self.mVXDaodi*FightSystem:getGameSpeedScale()
			self.mRole:BackDis(_dis)
		end
	end
	
end

function FalldownController:setNoStandUp(state)
	self.IsStandUp = state
end

function FalldownController:TickFalldown()
	self.mDowningDuring = self.mDowningDuring - 1
	if self.mDowningDuring <= 0 then
		self.mIsFalldowning = false
	   	if self.mRole.mFSM:IsDeading() then
	   	   self.mRole:RemoveSelf()
	   	else
	   		if self.IsStandUp then return end
			if self.mRole.mGroup == "friend" or self.mRole.mGroup == "enemyplayer" then
				self.mRole:AddBuff(188)
			elseif self.mRole.mGroup == "monster" and self.mRole.mRoleData.mInfoDB.Monster_Grade == 4 then
				self.mRole:AddBuff(188)
			end
			self.mRole.mBeatCon.mBeatFlyCount = 0
			self.mRole.mBeatCon.mBeatTiffCount = 0
           self.mRole.mArmature:ActionNow(self.mUpStand)
           if self.mTrapBuffID then
           		self.mRole.mBeatCon:cancelTrapBuffID(self.mTrapBuffID)
           end
		end
	end 
end

-- 开始倒地
function FalldownController:Start(_UpEnd, _UpStand, time ,_vxDaodi, _trapBuffID)
	self.mVXDaodi = _vxDaodi
	self.mUpEnd = _UpEnd
	self.mUpStand = _UpStand
	self.mTrapBuffID = _trapBuffID
	if self.mUpEnd == "" then
		self.mIsFalldowning = true
	end
	self.mDowningDuring = time
	if self.mUpEnd ~= "" then
		self.mRole.mArmature:ActionNow(self.mUpEnd)
	end
	self:registerActionEnd()
end

-- 注册动作完成回调
function FalldownController:registerActionEnd()
   local function _OnActionEnd(_action)
   		 if self.mRole.mFSM:IsFallingDown() or self.mRole.mFSM:IsDeading() then
			 if _action == self.mUpStand then
			 	if not self.mRole.mPropertyCon:IsHpEmpty() then
			 		self.mRole.mFSM:ForceChangeToState("idle")
			 	end
			 elseif _action == self.mUpEnd then
			 	self.mIsFalldowning = true
			 	self.mVXDaodi = nil
			 end
		 end
   end
   self.mRole.mArmature:RegisterActionEnd("FalldownController",_OnActionEnd)
end

-- 取消倒地
function FalldownController:CancelFallDown()
	-- if not self.mRole.mFSM:IsDeading() then
	-- 	self.mIsFalldowning = nil
	-- end
	self.mIsFalldowning = nil
	self.mDowningDuring = -1
	self.mVXDaodi = nil
end