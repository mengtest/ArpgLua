-- Name: JumpController
-- Func: 角色跳跃控制器
-- Author: Johny
-- 除个别函数与跳跃状态无关外，其余已不再使用

JumpController = class("JumpController")


function JumpController:ctor(_role, _armature, _moveCon)
	self.mRole = _role
	self.mArmature = _armature
	self.mMoveCon = _moveCon
	self.mHalfDuring = 0
	--
	self:RegisterActionCallBack()
end

function JumpController:RegisterActionCallBack()
	self.mArmature:RegisterActionEnd("JumpController", handler(self, self.OnActionEvent))
	self.mArmature:RegisterActionCustomEvent("JumpController", handler(self, self.OnCustomEvent))
end

-- 跳到指定位置
function JumpController:jumpTo(_pos, _callback)
	self.mDestPos = _pos
	self.mJumpCallBack = _callback
	self:StartJump()
end

function JumpController:StartJump()
	self.mIsUping = true
	self.mArmature:ActionNow("jumpStart")
end

-- 移动（跳）
function JumpController:DirectionToJump(direction)
	if self.mHalfDuring > 0 then
		self:TickDuring()
	end
end

-- 处理时间
function JumpController:TickDuring()
	self.mHalfDuring = self.mHalfDuring -1
	-- 完成上升前一帧改变动作
	if self.mHalfDuring == 1 then
	   self.mRole:resumeAction()
	end
	--
	if self.mHalfDuring == 0 and self.mIsUping then
	   self.mHalfDuring = self.mHalfTime
	   self.mIsUping = false
	end
end

-- 跳跃中改变方向
function JumpController:ChangeDirectionInJump(_dir, _deg)
	if _dir ~= FightConfig.DIRECTION_CMD.STOP then
		
	end
end


-- 结束跳跃
function JumpController:FinishJump()
	self.mRole:resumeAction()
	self.mArmature:ActionNow("jumpEnd")
end


-- 给予方向和角度的过程控制跳跃
function JumpController:HandleJumpStart(_dir, _deg)
	self.mHalfTime = MathExt.GetDownTimeByDis(self.mRole.mJump)
	self.mHalfDuring = self.mHalfTime
	self.mArmature:ActionNow("jumping")
	--
	local _during = self.mHalfTime*2/30
	local _curX = self.mRole:getPositionX()
	local _curY = self.mRole:getPositionY()
	local _nextPos = cc.p(_curX, _curY)
	local _HorDis = self.mHalfTime*2 * self.mRole.mPropertyCon.mSpeed
	--
	local function jumpWithDir()
		_nextPos.x = math.cos(math.rad(_deg))*_HorDis + _curX
		local _posWall = TiledMoveHandler.findPosByLine_Up(_nextPos, self.mRole.mJump, 2)
		if _posWall and FightConfig.IsDirectionUp(_dir) then
			_nextPos.y = _posWall.y
		else
			_nextPos.y = math.sin(math.rad(_deg))*_HorDis*math.cos(math.rad(45)) + _curY
		end
		-- 在墙上跳
		if TiledMoveHandler.IsOnWall(cc.p(_curX,_curY)) then
		   local _posWall =  TiledMoveHandler.findPosByLine_Up(_nextPos, self.mRole.mJump, 2)
		   if _posWall then
		   	  _nextPos = _posWall
		   end
		end
		-- 检测屏幕边缘
	   _nextPos.x = self.mMoveCon:filtPosX(_nextPos.x)
	   if _nextPos.y < 0 then
	   	  _nextPos.y = 0
	   end
	   if not TiledMoveHandler.CanPosStand(_nextPos) then
		   	local _tmp = _nextPos.y
		   	_nextPos.y = TiledMoveHandler.findRoadDown(_nextPos.x, _nextPos.y)
		   	if _nextPos.y then
			   	  local _dis = _tmp - _nextPos.y
			   	  local _vt = MathExt.GetV0InJump(_dis)
			   	  local _during2 = MathExt.GetUpTimeInJump(_vt)/30
			   	  if FightConfig.IsDirectionLeft(_dir) then
			   	 	 _nextPos.x = _nextPos.x - _during2*30 * self.mRole.mPropertyCon.mSpeed
			   	  elseif FightConfig.IsDirectionRight(_dir) then
			   	  	 _nextPos.x = _nextPos.x + _during2*30 * self.mRole.mPropertyCon.mSpeed
			   	  end
		   	else
		   		_nextPos.y = _tmp
		   	end
		end
		local _ac = cc.JumpTo:create(_during, _nextPos, self.mRole.mJump, 1)
		local _callback = cc.CallFunc:create(handler(self,self.FinishJump))
		self.mRole.mArmature:runAction(cc.Sequence:create(_ac, _callback))
		--
		if TiledMoveHandler.IsOnRoad(cc.p(_curX,_curY),self.mRole.mSceneIndex) and TiledMoveHandler.IsOnRoad(_nextPos,self.mRole.mSceneIndex) then
		   self.mRole.mShadow:MoveTo(_during, _nextPos)
		end
	end
	local function jumpOriginal()
		local _ac = cc.JumpTo:create(_during, _nextPos, self.mRole.mJump, 1)
		local _callback = cc.CallFunc:create(handler(self,self.FinishJump))
		self.mRole.mArmature:runAction(cc.Sequence:create(_ac, _callback))
		self.mRole.mShadow:MoveTo(_during, _nextPos)
	end
	--
	if _dir ~= 0 then
	    jumpWithDir()
	else
		jumpOriginal()
	end
end

-- 指定位置跳跃
function JumpController:HandleJumpTo(_pos,call)
	if call then
		self.mJumpCallBack = call
	end

	local y = self.mRole:getPositionY()
	local x = self.mRole:getPositionX()

	local function jump2()
		self.mHalfTime = MathExt.GetDownTimeByDis(_pos.y-y)
		local _during = self.mHalfTime/30
		self.mArmature:ActionNow("jumping")
		local _ac = cc.JumpTo:create(_during, _pos, _pos.y-y , 1)
		local _callback = cc.CallFunc:create(handler(self,self.FinishJump))
		self.mRole.mArmature:runAction(cc.Sequence:create(_ac, _callback))
		self.mRole.mShadow:MoveTo(_during, _pos)
	end

	local function jump()
		self.mHalfTime = MathExt.GetDownTimeByDis(self.mRole.mJump)
		local _during = self.mHalfTime/30

		local timedown = MathExt.GetDownTimeByDis(y+self.mRole.mJump - _pos.y)
		local _during1 = timedown/30

		self.mArmature:ActionNow("jumping")
		local _ac = cc.JumpTo:create(_during, cc.p(x,y+self.mRole.mJump), 0, 1)
		local _ac1 = cc.JumpTo:create(_during1, _pos, 0, 1)
		local _callback = cc.CallFunc:create(handler(self,self.FinishJump))
		self.mRole.mArmature:runAction(cc.Sequence:create(_ac,_ac1, _callback))
		self.mRole.mShadow:MoveTo(_during+_during1, _pos)
	end

	local x = self.mRole:getPositionX()
	local x1 = math.abs(x-_pos.x)/2
	if x >  _pos.x then
		x = x - x1
	else
		x = x + x1
	end
	if y < _pos.y then
		jump2()
	else
		jump()
	end
end

-- 骨骼动作完成回调
function JumpController:OnActionEvent(_action)
	if _action == "jumpStart" then
		if self.mDestPos then
		   self:HandleJumpTo(self.mDestPos)
		   self.mDestPos = nil
		else
			local _dir,_deg = FightSystem.mTouchPad:getCurDirection()
			self:HandleJumpStart(_dir, _deg)
		end
    elseif _action == "jumpEnd" then
    	self.mRole.mFSM:ChangeToStateWithCondition("jumping", "idle")
    	if self.mJumpCallBack then
    	   self.mJumpCallBack()
    	   self.mJumpCallBack = nil
    	end
	end
end

-- 骨骼事件回调
function JumpController:OnCustomEvent(_action, _eventName)
	if _action == "jumping" then
	   if _eventName == "jump" then
	   	  --cclog("JumpController:OnCustomEvent=====" .. _action)
	   	  self.mRole:pauseAction()
	   end
	end
end
