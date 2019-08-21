-- Func: 拾取控制器
-- Author: Johny

PickupController = class("PickupController")


function PickupController:ctor(_role)
	self.mRole = _role
	self.mArmature = _role.mArmature
	self.mRoleManager = FightSystem.mRoleManager
	self.mBind = nil
end

function PickupController:Destroy()
	if self.mSlot then
		self.mRole.mArmature.mSpine:uncloseAttachment(self.mSlot)
	end
	self.mRole.mArmature.mSpine:uncloseAttachment(_SLOT_BIND)
	self.mRole = nil
	self.mBind = nil
end

function PickupController:Tick()

end

--------------------------拾取-------------------------------------
local _SLOT_BIND = "bind"
local _ATTACH_TRASH = "trash"
local _ATTACH_SHOTGUN = "shotgun"
local _ATTACH_BASEBALLBAT = "baseballbat"
--
function PickupController:findPickup()
	if self.mBind then return false end
	--
	return self:findPickup_Item()
end


function PickupController:OnFinishPickup()
	if self.mBind then
		self.mPickuping = false
	end
end


-- 找物品拾取
function PickupController:findPickup_Item()
	local _pickup = self.mRoleManager:findPickup(self.mRole:getPosition_pos())
	if not _pickup then return false end
	--
	self.mBind = _pickup
	self.mBind:pickupedByRole(self.mRole)
	self.mBind:setVisible(false)
	self.mBind.mState = "bind"
	self.mRole:PlaySkillByID(34, "pickup")
	--
	self.mPickuping = true
	self.mSlot = nil
	local att = nil
	if self.mBind.mBindType == 1 then
		self.mSlot = "daoju"
	elseif self.mBind.mBindType == 2  then
		self.mSlot = "daoju2"
	end
	att = self.mBind.mAnimation_BindModelName	
	self.mRole.mArmature:setAttachmentForSlot(self.mSlot,att)
	-- if self.mBind.mBindType == 2 then
	--    self.mArmature.mSpine:closeAttachment(_SLOT_BIND, _ATTACH_TRASH)
	-- end

	return true
end

-- 找个人拾取
function PickupController:findPickup_Role()
	local _pickup = self.mRoleManager:findPickupRole(self.mRole:getPosition_pos())
	if not _pickup then return false end
	--
	self.mBind = _pickup
	self.mBind.mBePickupedCon:OnPickuped(self.mRole)
	self.mRole:PlaySkillByID(34, "pickup")
	self.mArmature.mSpine:closeAttachment(_SLOT_BIND, nil)

	return true
end
-----------------------------------------------------------------------------------

function PickupController:getPickupType()
	if self.mRole.mGunCon.isEquip then return 3 end
	if self.mBind == nil then
		return 0
	else
		if self.mBind.mState == "leave" then
			return 0
		else
			return self.mBind.mBindType
		end
	end
end

local cmdStandList = {[0] = "stand", "bindStand1", "bindStand2", "bindStand3"}
function PickupController:getSpineCmd_Stand()
	local _tp = self:getPickupType()
	local _cmd = cmdStandList[_tp]
	if not _cmd then _cmd = "stand" return end
	return _cmd
end


local cmdRunList = {[0] = "run", "bindRun1", "bindRun2", "bindRun3"}
function PickupController:getSpineCmd_Run()
	local _tp = self:getPickupType()
	local _cmd = cmdRunList[_tp]
	if not _cmd then _cmd = "run" return end


	return _cmd
end

function PickupController:decreaseUseCount(_vcount)
	if not self.mBind then return end
	-- if self.mBind.mBindType_str == "role" then return end
	self.mBind.mBindCurUseCount = self.mBind.mBindCurUseCount - _vcount
	if self.mBind.mBindCurUseCount <= 0 then
	   self:leavePickup()
	end	
end

function PickupController:playPickupSkill()
	if not self.mBind then return false end
	if self.mBind.mState ~= "bind" then
		return false 
	end
	--
	self.mRole:PlaySkillByID(self.mBind.mBindNormalAttack, "pickup_hit")
	--
	return true
end

function PickupController:playPickuping()
	if self.mBind and self.mBind.mState == "bind" and self.mPickuping then return true end
end

function PickupController:isPickup()
	if not self.mBind then
		return false
	end
	if self.mBind.mState == "bind" then
		return self.mBind
	end
	return false
end

----------------投掷---------------------------------------------
function PickupController:throwPickup()
	if not self.mBind then return false end
	if self.mBind and self.mBind.mState == "leave" then return true end
	-- if self.mBind.mBindType_str == "role" then
	--    return self:throwPickup_role()
	-- else
	   return self:throwPickup_item()
	-- end
end

function PickupController:throwPickup_role()
	self.mRole:PlaySkillByID(self.mBind.mBindThrowAttack, "pickup_throw")

	return true
end

function PickupController:throwPickup_item()
	
	if self:getPickupType() == 3 then
	   self:leavePickup()
	return true end
	--
	if self.mRole:PlaySkillByID(self.mBind.mBindThrowAttack, "pickup_throw") then
		self.mBind.mState = "throw"
		self.mArmature:removeAttachmentForSlot(self.mSlot)
		self.mSlot = nil
	end
	
	return true
end

function PickupController:getThrowSkillID()
	return self.mBind.mBindThrowAttack
end
------------------------------------------------------------------------

------------丢弃----------------------------------------------------------
function PickupController:leavePickup()
	if not self.mBind then return false end
	--
	local _bindPos = self.mArmature.mSpine:getBonePosition("bind")
	if self.mRole.IsFaceLeft then
	   _bindPos.x = -_bindPos.x
	end
	local _curX = _bindPos.x + self.mRole:getPositionX()
	local _curY = _bindPos.y + self.mRole:getPositionY()
	local _toY = self.mRole:getPositionY()
	local _dis = math.abs(_curY - _toY)
	local _during = MathExt.GetDownTimeByDis(_dis)
	-- if self.mBind.mBindType_str == "role" then
	-- 	self.mBind:setPositionX(_curX)
	-- 	self.mBind:setPositionY(_curY)
	-- 	self.mBind:addToTiledLayer()
	--     self.mBind.mBePickupedCon:leave(_during, _curX, _toY)
	--     self.mBind = nil
	--     self:resetRole()
	-- else
		self.mBind:setPosition(cc.p(_curX, _curY))
		self:leavePickup_item(_during, _curX, _toY)
		self:resetRole()
	-- end
end

function PickupController:leavePickup_item(_during, _curX, _toY)
	if self.mBind.mState == "leave" then return end
	local function finishLeave()
		if self.mBind then
			CommonAnimation.FadeoutToDestroy(self.mBind, handler(self.mBind, self.mBind.OnFinishDeadAction))
			self.mBind = nil
		end
	end
	--
	self.mBind.mState = "leave"
	self.mBind:setVisible(true)
	local _ac1 = cc.MoveTo:create(_during/30, cc.p(_curX, _toY))
	local _ac = cc.EaseIn:create(_ac1, 2.0)
	local _delay = cc.DelayTime:create(1)
	local _callbcak = cc.CallFunc:create(finishLeave)
	self.mBind:runAction(cc.Sequence:create(_ac, _delay, _callbcak))
end
------------------------------------------------------------------------------------


--[[
   开始投掷
]]
function PickupController:OnThrowPickupStart()
	if not self.mBind then return end
	--
	-- if self.mBind.mBindType_str == "role" then
	-- 	self:OnThrowPickupStart_role()
	-- else
		self:OnThrowPickupStart_item()
	-- end
end

function PickupController:OnThrowPickupStart_role()
	self.mBind.mBePickupedCon:throwParabola(self.mRole)
end

function PickupController:OnThrowPickupStart_item()
	local _tp = self:getPickupType()
	if _tp == 1 then
	   self.mBind:throwHor(self.mRole)
	elseif _tp == 2 then
	   self.mBind:throwParabola(self.mRole)
	end
	self.mBind:setVisible(true)
end

--[[
   投掷技能结束
]]
function PickupController:OnFinishThrowPickup()
	self:resetRole()
	self.mBind = nil
end



function PickupController:resetRole()
	if self.mSlot then
		self.mArmature.mSpine:uncloseAttachment(self.mSlot)
	end
	self.mArmature.mSpine:uncloseAttachment(_SLOT_BIND)
	if self.mRole.mFSM:IsIdle() then
	   self.mArmature:ActionNow("stand",true)
	elseif self.mRole.mFSM:IsRuning() then
	   self.mArmature:ActionNow("run",true)
	end
end