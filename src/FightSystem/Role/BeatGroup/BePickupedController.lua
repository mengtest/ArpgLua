-- Name: BePickupedController
-- Author: Johny

BePickupedController = class("BePickupedController")


function BePickupedController:ctor(_role)
	self.mRole = _role
	self.mArmature = _role.mArmature
	self.mHolder = nil
	self.mState = "normal"
	self.mDB_pickup = DB_SceneAnimationConfig.getDataById(9)
end

function BePickupedController:Destroy()
	self.mRole = nil
	self.mHolder = nil
end


function BePickupedController:Tick(delta)
	self:TickDuring()
	--
	if self.mState == "pickuped" then
	   self:TickSelfPickupedPos(self.mHolder)
	end
	--check相关状态
	self:TickAllStatus()
end

function BePickupedController:TickAllStatus()
	if self.mState == "pickuped" then
	   self.mRole.mShadow:setStateForGriped(true)
	   self.mRole.mShadow:setVisibleShadow(false)
	elseif self.mState == "unpickuped" then
	   self.mRole.mShadow:setStateForGriped(false)
	   self.mRole.mFSM:ForceChangeToState("idle")
	   self.mState = "normal"
	   self.mHolder = nil
	elseif self.mState == "throw" then
		self.mRole.mShadow:setVisibleShadow(true)
	elseif self.mState == "leave" then
		self.mRole.mShadow:setVisibleShadow(true)
	end
end

function BePickupedController:TickDuring()
	if self.mState ~= "pickuped" then return end
	if self.mBindDuring == 0 then return end
	--
	self.mBindDuring = self.mBindDuring - 1
	if self.mBindDuring == 0 then
	   self.mHolder.mPickupCon:leavePickup()
	end
end

-- 被抓投
function BePickupedController:OnPickuped(_holder)
	-- self.mRole.mFSM:ChangeToStateWithCondition("falldown", "bepickuped")
	-- self.mHolder = _holder
	-- self.mState  = "pickuped"
	-- self.mBindDuring = 5 * 30
	-- _holder.mArmature.mSpine:addChild(self.mRole.mArmature)
 --   	if not self.mRole.IsFaceLeft then
 --   	  self.mArmature:setScaleX(-1)
 --   	  self.mRole.IsFaceLeft = true
 --   end
end

function BePickupedController:TickSelfPickupedPos(_holder)
	local _bindPos = _holder.mArmature.mSpine:getBonePosition("bind")
	self.mRole:setPositionX(_bindPos.x)
	self.mRole:setPositionY(_bindPos.y)
	self.mRole:setLocalZOrder(_holder:getLocalZOrder() -1)
end

-- 抛物线投掷
function BePickupedController:throwParabola(_holder)
	local _rolePos = _holder:getPosition_pos()
	local _bindPos = _holder.mArmature.mSpine:getBonePosition("bind")
	if _holder.IsFaceLeft then
	   _bindPos.x = - _bindPos.x
	end
	local _curX = _bindPos.x + _rolePos.x
	local _curY = _bindPos.y + _rolePos.y
	local function findVictim()
		self.mArmature:setRotation(0)
		self.mArmature:ActionNow("beBlowUpEnd")
		--
		local _list = self:FindVictim(_holder)
		if #_list == 0 then return end
		for k,_victim in pairs(_list) do
			local _damage, _damageTP = self:getPickupThrowDamageCount(self.mRole, _victim)
			if _damageTP ~= "dodge" then
				_victim.mBeatCon:Beated(self.mRole, _damage, _damageTP)
				self:pickupThrowHit_display(_victim)
				self:pickupThrowHit_state(_victim)
			end
		end
	end
	--
	local function addToTiledLayer()
		self.mRole:addToTiledLayer()
		self.mRole:setPositionX(_curX)
		self.mRole:setPositionY(_curY)
	end
	--
	local function finishThrow()
	      self.mState  = "unpickuped"
	end
	--
	local function throwAction()
		local _dis = self.mDB_pickup.Animation_BindThrowFlyMaxTime * self.mDB_pickup.Animation_BindThrowFly
		-- 还原方向
		if not self.mRole.IsFaceLeft then
		   self.mRole.mArmature:setScaleX(1)
		end
		local _rotation = 360
		-- 根据持有者调整方向
		if _holder.IsFaceLeft then
		   _dis = - _dis
		   self.mRole:FaceRight()
		   _rotation = - _rotation
		else
		   self.mRole:FaceLeft()
		end
		local _nextPos = cc.p(_curX + _dis, _rolePos.y)
		local _during = self.mDB_pickup.Animation_BindThrowFlyMaxTime/30
		local _height = self.mDB_pickup.Animation_BindThrowOffsetHeight
		local _ac_1 = cc.JumpTo:create(_during, _nextPos, _height, 1)
		local _ac_2 = cc.RotateBy:create(_during, _rotation)
		local _ac = cc.Spawn:create(_ac_1, _ac_2)
		local _callbcak1 = cc.CallFunc:create(findVictim)
		local _delay = cc.DelayTime:create(1)
		local _callbcak2 = cc.CallFunc:create(finishThrow)
		self.mArmature:runAction(cc.Sequence:create(_ac, _callbcak1, _delay, _callbcak2))
	end
	--
	self.mArmature:ActionNow("injured2")
	self.mState = "throw"
	addToTiledLayer()
	throwAction()
end

function BePickupedController:FindVictim(_holder)
	local list = {}
	local _victimCount = FightSystem.mRoleManager:GetVicmCount(_holder)
	for i = 1, _victimCount do
		local _victim = FightSystem.mRoleManager:GetVicim(i, _holder)
		if _victim and self:IsCollideWithMe_Throw(_victim:getPosition_pos()) then
			table.insert(list, _victim)
		end
	end

	return list
end

-- 投掷碰撞检测
function BePickupedController:IsCollideWithMe_Throw(_pos)
	local _w = self.mDB_pickup.Animation_DamageRangeLength	
	local _h = self.mDB_pickup.Animation_DamageRangeWidth
	local _x = self.mRole:getPositionX() - _w/2
	local _y = self.mRole:getPositionY() - _h/2
	local _rect = cc.rect(_x, _y, _w, _h)
	if not cc.rectContainsPoint(_rect, _pos) then return false end
	--
	return true
end

function BePickupedController:leave(_during, _curX, _toY, _finishLeave)
	-- 还原方向
	if not self.mRole.mArmature.IsFaceLeft then
	   self.mRole.mArmature:setScaleX(1)
	end
	self.mState = "leave"
	local _ac1 = cc.MoveTo:create(_during/30, cc.p(_curX, _toY))
	local _ac = cc.EaseIn:create(_ac1, 2.0)
	self.mArmature:runAction(_ac)
	self.mState = "unpickuped"
end

function BePickupedController:getPickupThrowDamageCount(_holder, _victim)
	-- 获取投掷伤害
	local dbSkill = DB_SkillEssence.getDataById(self.mDB_pickup.Animation_BindThrowAttack)
	local dbProc = DB_SkillProcess.getDataById(dbSkill.ProcessID2)

	return CommonSkill.getDamageCount(_holder.mPropertyCon, dbProc, _victim.mPropertyCon)
end

function BePickupedController:pickupThrowHit_display(_victim)
	local dbSkill = DB_SkillEssence.getDataById(self.mDB_pickup.Animation_BindThrowAttack)
	local dbProc = DB_SkillProcess.getDataById(dbSkill.ProcessID2)
	CommonSkill.hitVictimDisplay(_victim, dbProc.ProcessDisplayID, self.mRole)
end

function BePickupedController:pickupThrowHit_state(_victim)
	local dbSkill = DB_SkillEssence.getDataById(self.mDB_pickup.Animation_BindThrowAttack)
	local dbProc = DB_SkillProcess.getDataById(dbSkill.ProcessID2)
	CommonSkill.attachState(_victim, dbProc, self.mRole)
end