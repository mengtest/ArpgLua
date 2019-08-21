-- Name: KnockFlyController
-- Author: Johny

KnockFlyController = class("KnockFlyController")


function KnockFlyController:ctor(_role)
	self.mRole = _role
	self.mIsFlying = false
	self.mIsFlyingUp = false
	self.mIsHangtime = false
	self.mStatictime = 0
	self:resetFlyCount()
end

function KnockFlyController:Destroy()
	cclog("KnockFlyController:Destroy")
	self.mRole = nil
	self.mIsFlying = nil
	self.mIsFlyingUp = nil
	self.mIsHangtime = nil
	self.mHiter = nil
	self.mStatictime = nil
end

function KnockFlyController:Tick(delta)
	if self.mRole:IsControlByStaticFrameTime() then return end
	if self.mStatictime > 0 then
		self.mStatictime = self.mStatictime - 1
		return
	end

	-- 判断是否产生位移
	if self.mIsFlying then
		-- 垂直位移
		self.mRole.mShadow:ShadowChangeScale()
		self:TickFly(delta)
		-- 水平位移
		self:TickXMove()
		-- 如果与影子持平则结束击飞转为倒地
		if self.mRole.mShadow:IsSameHorWithRole() <= 0 then
			self:HandleFallDown()
		end
	end
	--
end

function KnockFlyController:HandleFallDown()

	self.mRole.mFEM:ChangeToBeatEffect(0)
	if self.mRole.mPropertyCon:IsHpEmpty() then
	   self.mRole.mFSM:ForceChangeToState("dead")
	else
		self.mRole.mFSM:ForceChangeToState("falldown")
	end
	self:resetFlyCount()
	self.mRole:setPositionY(self.mRole.mShadow:getPositionY())
	self.mIsFlying = false
	self.mRole.mShadow:stopTickMoveY(false)

	self.mRole.mBeatCon.mFalldownCon:Start(self.mbeBlowUpEnd,self.mbeBlowUpStand,self.mDaoDiTime,self.mVXDaodi,self.mDB.ID)
	--voice
	self.mRole:playVoiceSound(5)
	-- 影子还原
	self.mRole.mShadow:ShadowRestoreScale()
	-- 震动
	if self.mRole.mGroup == "friend" or self.mRole.mGroup == "enemyplayer" then
		if self.mTopheight then
			local height = math.floor(self.mTopheight / 100)
			if height > 0 then
				shakeFallNodeType1(FightSystem.mSceneManager:GetSceneView(self.mRole.mSceneIndex),height,height*0.035)	
			end
			self.mTopheight = nil
		end
	else
		if self.mTopheight then
			local height = math.floor(self.mTopheight / 100)
			if height > 0 then
				shakeFallNodeType1(FightSystem.mSceneManager:GetSceneView(self.mRole.mSceneIndex),height,height*0.035)	
			end
			self.mTopheight = nil
		end
	end
end

-- 开始击飞(从地面起飞)
function KnockFlyController:Start(_dbSt, _dbSkillEff, _hiter, _dbProc, _isTurnflight)
	-- 扔手里拾取
	--doError("KnockFlyController:Start")
	if self.mRole:hasNoControlBuffNow() and self.mRole.mPropertyCon.mCurHP > 0 then
		return
	end
	self:registerActionStart()
	self:registerActionCustom()
	self:registerActionEnd()

	self.mRole.mArmature.mSpine:setTimeScale(1)
	self.IsFukong = false
	self.mbeBlowUpStart = "beBlowUpStart"
	self.mbeBlowUping = "beBlowUping"
	self.mbeBlowUpEnd = "beBlowUpEnd"
	self.mbeBlowUpStand = "beBlowUpStand"

	
	if _dbSkillEff.ExcuteMethod == 32 then
		self.mbeBlowUping = "beBlowUping2"
		self.mbeBlowUpEnd = "beBlowUpEnd2"
		self.mbeBlowUpStand = "beBlowUpStand2"
	end
	
	self.mRole.mBeatCon.mBeatTiffCount = 0
	self.mUpGG = MathExt._g_KnockFly_UP
	self.mDownGG = MathExt._g_KnockFly_DOWN
	if _isTurnflight then
		self:TurnFlightToFly(_dbSt, _dbSkillEff, _hiter, _dbProc)
		return
	end
	self.mDaoDiTime = _dbSkillEff.Data2
	self.mStatictime = 0
	self.mRole:resumeAction()
	if type(_hiter) == "boolean" then
		self.mIsFaceLeft = _hiter
	else
		if _hiter then
			self.mIsFaceLeft = _hiter.IsFaceLeft
		else
			self.mIsFaceLeft = self.mRole.IsFaceLeft
		end
	end
	
	self.mRole.mPickupCon:leavePickup()
	self.mFlyCount = self.mFlyCount + 1
	self.mDB = _dbSt
	-- 上升总高度
	self._Height = _dbSkillEff.Data3
	if self.mFlyCount == 1 then
	else
		self._Height = self._Height*0.6
	end

	-- 下落总时间 = 上升总时间
	self._Downduring = MathExt.GetDownTime_KnockFly(self._Height, self.mUpGG)
	self.HangTime = 3
	self.mHiter = _hiter
	self.mVX = _dbSkillEff.Data1 / (self._Downduring*2)
	-- 倒地距离
	self.mVXDaodi = _dbSkillEff.Data4 / 13

	-- 上升初速度
	self.mVH = MathExt.GetV0InUniformDeceleration(self.mUpGG, self._Downduring)
	self.mIsFlyingUp = true
	self.mIsHangtime = false
	self.mRole.mShadow:stopTickMoveY(true)
	-- 击飞第一个动作（一共3个动作组成）
	if self.mRole.mArmature.mSpine:getCurrentAniName() == "injured3" then
		self.mIsFlying = true
		return
	end
	self.mRole.mArmature:setNoReceiveAction(false)
	if self.mRole.mArmature.mSpine:getCurrentAniName() ~= "beBlowUpStart" then
		self.mRole.mArmature:ActionNow("beBlowUpStart")
	end
	self.mRole.mArmature:setNoReceiveAction(true)
end


-- 开始击飞(从地面起飞)
function KnockFlyController:StartForFlyDead(_dbSt, _dbSkillEff, _hiter)
	-- 扔手里拾取
	self:registerActionStart()
	self:registerActionCustom()
	self:registerActionEnd()
	self.mbeBlowUpStart = "beBlowUpStart"
	self.mbeBlowUping = "beBlowUping"
	self.mbeBlowUpEnd = "beBlowUpEnd"
	self.mbeBlowUpStand = "beBlowUpStand"
	self.mRole.mArmature.mSpine:setTimeScale(1)
	self.IsFukong = false
	self.mUpGG = MathExt._g_KnockFly_UP
	self.mDownGG = MathExt._g_KnockFly_DOWN
	self.mStatictime = 0
	self.mRole:resumeAction()
	if type(_hiter) == "boolean" then
		self.mIsFaceLeft = _hiter
	else
		if _hiter then
			self.mIsFaceLeft = _hiter.IsFaceLeft
		else
			self.mIsFaceLeft = self.mRole.IsFaceLeft
		end
	end
	self.mRole.mPickupCon:leavePickup()
	self.mFlyCount = self.mFlyCount + 1
	self.mDB = _dbSt
	self.mDaoDiTime = _dbSkillEff.Data2
	-- 上升总高度
	self._Height = _dbSkillEff.Data3
	if self.mFlyCount == 1 then
	else
		self._Height = self._Height*0.6
	end

	-- 下落总时间 = 上升总时间
	self._Downduring = MathExt.GetDownTime_KnockFly(self._Height, self.mUpGG)
	self.HangTime = 3
	self.mHiter = _hiter
	self.mVX = _dbSkillEff.Data1 / (self._Downduring*2)
	-- 倒地距离
	self.mVXDaodi = _dbSkillEff.Data4 / 13
	-- 上升初速度
	self.mVH = MathExt.GetV0InUniformDeceleration(self.mUpGG, self._Downduring)
	self.mIsFlyingUp = true
	self.mIsHangtime = false
	self.mRole.mShadow:stopTickMoveY(true)
	if self.mRole.mArmature.mSpine:getCurrentAniName() == "injured3" then
		self.mIsFlying = true
		return
	end
	-- 击飞第一个动作（一共3个动作组成）
	self.mRole.mArmature:setNoReceiveAction(false)
	if self.mRole.mArmature.mSpine:getCurrentAniName() ~= "beBlowUpStart" then
		self.mRole.mArmature:ActionNow("beBlowUpStart")
	end
	self.mRole.mArmature:setNoReceiveAction(true)
end

function KnockFlyController:TurnFlightToFly(_dbSt, _dbSkillEff, _hiter, _dbProc)
	self:registerActionStart()
	self:registerActionCustom()
	self:registerActionEnd()
	self.mRole.mArmature.mSpine:setTimeScale(1)
	self.IsFukong = false
	self.mbeBlowUpStart = "beBlowUpStart"
	self.mbeBlowUping = "beBlowUping"
	self.mbeBlowUpEnd = "beBlowUpEnd"
	self.mbeBlowUpStand = "beBlowUpStand"
	

	local _during = _dbProc.LastTime / FightSystem:getGameSpeedScale()
	self.mDuring = _during / _hiter.mPropertyCon.mAttRatePer
	self.mDuring = math.ceil(self.mDuring * _dbProc.ModifySpeed)

	self.mStatictime = 0
	self.mRole:resumeAction()
	if type(_hiter) == "boolean" then
		self.mIsFaceLeft = _hiter
	else
		if _hiter then
			self.mIsFaceLeft = _hiter.IsFaceLeft
		else
			self.mIsFaceLeft = self.mRole.IsFaceLeft
		end
	end
	
	self.mRole.mPickupCon:leavePickup()
	self.mFlyCount = self.mFlyCount + 1
	self.mDB = _dbSt
	self.mDaoDiTime = _dbSkillEff.Data2
	-- 上升总高度
	self._Height = _dbSkillEff.Data3
	-- 下落总时间 = 上升总时间
	self._Downduring = self.mDuring
	self.HangTime = 3
	self.mHiter = _hiter
	self.mVX = _dbSkillEff.Data1 / (self._Downduring*2)
	-- 倒地距离
	self.mVXDaodi = 0
	-- 上升初速度
	self.mUpGG = 2*self._Height/(self._Downduring*self._Downduring)
	self.mDownGG = 2*self._Height/(self._Downduring*self._Downduring)
	self.mVH = MathExt.GetV0InUniformDeceleration(self.mUpGG, self._Downduring)
	self.mIsFlyingUp = true
	self.mIsHangtime = false
	self.mRole.mShadow:stopTickMoveY(true)
	-- 击飞第一个动作（一共3个动作组成）
	self.mRole.mArmature:ActionNow("beBlowUpStart")
	self.mRole.mArmature:setNoReceiveAction(true)
end

-- 浮空击飞(已经处于击飞状态再次击飞)
function KnockFlyController:flowFlyStart()
	--doError("flowFlyStart")
	if not self.mRole:hasNoControlBuffNow() then
		self.mStatictime = FightConfig.KNOCKFLY_FLY_DURING
	end
end

-- 注册动作开始回调
function KnockFlyController:registerActionStart()
   local function _OnActionStart(_action)
   	  
   end

  -- self.mRole.mArmature:onAnimationStart("KnockFlyController",_OnActionStart)
end

function KnockFlyController:registerActionCustom()
	local function _OnActionCustom(_action,name)
		if not self.IsFukong then return end
		if _action == self.mbeBlowUping and name == "speedup2" then
			self.mRole.mArmature.mSpine:setTimeScale(2)
		elseif _action == self.mbeBlowUping and name == "speedup1" then
			self.mRole.mArmature.mSpine:setTimeScale(4/(self._Downduring-4))
		end
		
	end
	self.mRole.mArmature:RegisterActionCustomEvent("KnockFlyController",_OnActionCustom)
end

-- 注册动作完成回调
function KnockFlyController:registerActionEnd()
   local function _OnActionEnd(_action)
		 if _action == "beBlowUpStart" then
		 	self.mRole.mArmature:setNoReceiveAction(false)
   		 	self.mRole.mArmature:ActionNowWithSpeedScale(self.mbeBlowUping,20/(self._Downduring*2))
   		 	if self.mRole.mFEM:IsBeatStFly() then
   		 		self.mIsFlying = true
   		 	end
   		 elseif _action == self.mbeBlowUpStand then
   		 	--self.mRole.mArmature:setNoReceiveAction(false)
   		 	if self.mRole.mFEM:IsBeatStFly() and not self.mRole.mPropertyCon:IsHpEmpty() then
	   		 	self.mRole.mFSM:ForceChangeToState("idle")
		 	end
   		 elseif _action == self.mbeBlowUpEnd then
   		 elseif _action == self.mbeBlowUping then
   		 	self.mRole.mArmature.mSpine:setTimeScale(1)
   		 	self.IsFukong = false
   		 end
   end
   self.mRole.mArmature:RegisterActionEnd("KnockFlyController",_OnActionEnd)
end


function KnockFlyController:TickFly(delta)
	local _Y = self.mRole:getPositionY()
	local _disY = 0
	if self.mIsHangtime then
		self.HangTime = self.HangTime - 1
		if self.HangTime <= 0 then
			self.mIsFlyingUp = false
			self.mIsHangtime = false
			self.mTopheight = self.mRole.mShadow:GetHorHeight()
		end
		return 
	end

	if self.mIsFlyingUp then
		self.mVH = MathExt.GetV1InUniformDeceleration(self.mVH, self.mUpGG, 1*FightSystem:getGameSpeedScale())
		_disY = self.mVH*FightSystem:getGameSpeedScale()
		if self.mVH <= 0 then
		   self.mIsHangtime = true
			if self.mRole.mArmature.mSpine:getCurrentAniName() == "injured3" then
				self.mRole.mArmature:ActionNow(self.mbeBlowUping)
				self.mRole.mArmature.mSpine:setTimeScale(2)
				self.IsFukong = true
			end
		end
	else
		self.mVH = MathExt.GetV1InUniformAcceleration(self.mVH, self.mDownGG, 1*FightSystem:getGameSpeedScale())
		_disY = - self.mVH*FightSystem:getGameSpeedScale()
    end
    self.mRole:setPositionY(_disY + _Y)
   -- doError(self.mRole:getPositionY())
end

function KnockFlyController:TickXMove()
	--if self.mIsHangtime then return end
	local _x = self.mRole:getPositionX()
	local _dis = self.mVX*FightSystem:getGameSpeedScale()
	
	local _nextX = _x + _dis
	if self.mIsFaceLeft then
		_nextX = _x - _dis
	end
	_nextX = self.mRole.mMoveCon:filtPosX(_nextX)
	local _nextY = self.mRole:getShadowPos().y
	if TiledMoveHandler.CanPosStand(cc.p(_nextX, _nextY),self.mRole.mSceneIndex) then 
		self.mRole:setPositionX(_nextX,true)
	end
end

-- 重置击飞参数
function KnockFlyController:resetFlyCount()
	self.mFlyCount = 0	  -- 击飞接击飞
	self.mFlyCount_2 = 0  -- 击飞接普攻
	self.mUpGG = MathExt._g_KnockFly_UP
	self.mDownGG = MathExt._g_KnockFly_DOWN
end

function KnockFlyController:cancelKnockFlyByNoContr()
	self.mIsFlying = false
	self.mIsHangtime = false
	self.mStatictime = 0
	self.mRole.mFEM:ChangeToBeatEffect(0)
	self:resetFlyCount()
end

function KnockFlyController:cancelFlyTurnFlight()
	--doError("cancelFlyTurnFlight")
	self.mIsFlying = false
	self.mIsHangtime = false
	self.mStatictime = 0
	self:resetFlyCount()
	self.mRole:setPositionY(self._Height + self.mRole.mShadow:getPositionY())

end

function KnockFlyController:cancelFallDown()
end