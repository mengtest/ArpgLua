-- Name: MoveController
-- Func: 角色移动控制器
-- #移动的基础处理，及走和跑的细节处理
-- Author: Johny

require "FightSystem/Role/MoveGroup/JumpController"
require "FightSystem/Role/MoveGroup/BlockController"
require "FightSystem/Role/MoveGroup/TiledMoveHandler"

MoveController = class("MoveController")
local _rad = math.rad
local _cos = math.cos
local _sin = math.sin

function MoveController:ctor(_role, _armature)
	self.mRole = _role
	self.mArmature = _armature
	self.mMoveDeg = 0  -- 移动的角度，即y/x
	-- 记录当前与上次的移动方向
	self.mCurMoveDirection = 0
	self.mLastMoveDirection = 0

	--移动状态： stop, pause, runing
	self.mMoveStatus = "stop"
	self.mPause_MoveType = ""   -- 如果状态为暂停，检查恢复到什么状态

	-- 如果移动距离为0，则持续移动到stop为止
	self.mMoveDis = 0

	-- init 
	self.mJumpCon = JumpController.new(_role, _armature, self)

	self.mBlockCon = BlockController.new(_role, _armature)
end

function MoveController:Destroy()
	self.mRole = nil
	self.mArmature = nil
	self.mMoveDeg = 0
	self.mCurMoveDirection = 0
	self.mLastMoveDirection = 0
	self.mMoveStatus = nil
	self.mPause_MoveType = nil
	self.mMoveDis = 0
	-- self.mJumpCon = nil
	self.mBlockCon = nil
end


function MoveController:Tick(delta)
	self:tickMove(delta)
	-- self.mBlockCon:Tick(delta)
end

function MoveController:tickMove(delta)
	if self.mRole:hasBoundBuffNow() then return end
	if self:canMove() and not self.mRole:IsControlByStaticFrameTime() then
		self:DirectionToMove(delta, self.mCurMoveDirection, self.mMoveDeg)
	end
end

-- 是否可以移动
function MoveController:canMove()
	return pCall(self.mRole , handler(self.mRole["mFSM"], self.mRole["mFSM"].IsWithinMoveState)) or self.mRole.mSkillCon:canCurSkillMove()
end

function MoveController:setCurMoveDir(_dir)
	self.mLastMoveDirection = self.mCurMoveDirection
	self.mCurMoveDirection = _dir
end

-- 停止移动
function MoveController:StopMove()
	self:StopMoveStatus()
	self:setCurMoveDir(FightConfig.DIRECTION_CMD.STOP)
end

-- 开始移动
function MoveController:StartMove(_dir, _deg)
	self:setCurMoveDir(_dir)
	self.mMoveDeg = _deg
	self.mMoveDis_CallBack = nil
	if _dir == FightConfig.DIRECTION_CMD.DLEFT then
		self.mRole:FaceLeft()
	elseif _dir == FightConfig.DIRECTION_CMD.DRIGHT then
		self.mRole:FaceRight()
	else
		-- 2级方向
		if _dir == FightConfig.DIRECTION_CMD.DLEFTUP or _dir == FightConfig.DIRECTION_CMD.DLEFTDOWN then
			self.mRole:FaceLeft()
		elseif _dir == FightConfig.DIRECTION_CMD.DRIGHTUP or _dir == FightConfig.DIRECTION_CMD.DRIGHTDOWN then
			self.mRole:FaceRight()
		end
	end
	--
end

-- 通常被AI使用
function MoveController:StartMoveByPos(_pos, _callback)
	local _curPos = self.mRole:getPosition_pos()
	local _deg = MathExt.GetDegreeWithTwoPoint(_pos, _curPos)
	self.misAutoPos = true
	self.mMoveDeg = _deg
	self.mMoveDis = cc.pGetDistance(_curPos, _pos)
	self.mMoveDis_CallBack = nil
	self.mMoveDis_CallBack = _callback
	local _dir = FightConfig.GetDirectionByDegree(_deg)
	self:setCurMoveDir(_dir)
end

function MoveController:StartMoveForPveByPos(_pos, _callback)
	self.IsshowPve = true
	local _curPos = self.mRole:getPosition_pos()
	local _deg = MathExt.GetDegreeWithTwoPoint(_pos, _curPos)
	self.misAutoPos = true
	self.mMoveDeg = _deg
	self.mMoveDis = cc.pGetDistance(_curPos, _pos)
	self.mMoveDis_CallBack = nil
	self.mMoveDis_CallBack = _callback
	local _dir = FightConfig.GetDirectionByDegree(_deg)
	self:setCurMoveDir(_dir)
end


-- 移动（跑）
-- 仅2级方向，有tan值
function MoveController:DirectionToMove(delta, direction, _deg)
	if direction == FightConfig.DIRECTION_CMD.STOP then return end
	--
	local curPos = pCall(self.mRole, handler(self.mRole, self.mRole.getPosition_pos))
	local nextPos = cc.p(0,0)
	local _gameSpeedScale = FightSystem:getGameSpeedScale()
	local turnrun = 1
	if self.mRole.IsTurnRun then
		turnrun = 0.75
	end
	local _disX = self.mRole.mPropertyCon.mSpeed * delta * _gameSpeedScale*turnrun
	local _disY = self.mRole.mPropertyCon.mSpeedY * delta * _gameSpeedScale*turnrun
	-- doError(self.mRole.mPropertyCon.mSpeed)
	-- 上下左右
	if direction == FightConfig.DIRECTION_CMD.DUP then
		nextPos = cc.p(curPos.x, curPos.y + _disY)
	elseif direction == FightConfig.DIRECTION_CMD.DDOWN then
		nextPos = cc.p(curPos.x, curPos.y - _disY)
	elseif direction == FightConfig.DIRECTION_CMD.DLEFT then
		nextPos = cc.p(curPos.x - _disX, curPos.y)
		if not self.mRole.IsTurnRun then
			self.mRole:FaceLeft()
		end
	elseif direction == FightConfig.DIRECTION_CMD.DRIGHT then
		nextPos = cc.p(curPos.x + _disX, curPos.y)
		if not self.mRole.IsTurnRun then
			self.mRole:FaceRight()
		end
	else
		-- 2级方向
		local _r = MathExt.GetEllipseByCenterDis(_disX, _disY, _deg)
		nextPos.x = _cos(_rad(_deg))*_r + curPos.x
		nextPos.y = _sin(_rad(_deg))*_r + curPos.y
		if direction == FightConfig.DIRECTION_CMD.DLEFTUP or direction == FightConfig.DIRECTION_CMD.DLEFTDOWN then
			if not self.mRole.IsTurnRun then
				self.mRole:FaceLeft()
			end
		elseif direction == FightConfig.DIRECTION_CMD.DRIGHTUP or direction == FightConfig.DIRECTION_CMD.DRIGHTDOWN then
			if not self.mRole.IsTurnRun then
				self.mRole:FaceRight()
			end
		end
	end
	--
	local function xMove()
		if self:CanMoveTo_Hor(nextPos.x) then
			self.mRole:setPositionX(nextPos.x)
			if FightSystem.mFightType == "fuben" then
				FightSystem.mFubenManager:KeyRoleLeftRunScene(self.mRole,curPos.x,nextPos.x)
			end
		end
	end
	local function yMove()
		if self:CanMoveTo_Ver(nextPos.y) then
			self.mRole:setPositionY(nextPos.y)
		end
	end

	-- 达到2个条件才能移动位移
	local _ret = TiledMoveHandler.CheckReachable(_deg, curPos, nextPos, self.mRole)
	if _ret == "both" then
		xMove()
		yMove()
		self:CheckPosMoveFinish(curPos, nextPos)
	elseif _ret == "x" then
		xMove()
		if self.mRole.mAI.mIsfollow and self.mRole.mAI.mOpenAI then
			--self:FinishPosMove("notcanmove")
		else
			self:FinishPosMove("notcanmove")
		end
	else
		self:FinishPosMove("notcanmove")
	end

end


-- 检查固定距离移动是否结束
function MoveController:CheckPosMoveFinish(_curPos, _nextPos)
	local _dis = cc.pGetDistance(_curPos, _nextPos)
	if self.mMoveDis > 0 then
	   self.mMoveDis = self.mMoveDis - _dis
	   if self.mMoveDis <= 0 then
	   	  self:FinishPosMove("daoda")
	   end
	else
	   self:FinishPosMove("daoda")
	end
end

-- 结束固定距离移动
function MoveController:FinishPosMove(type)
	if (self.mRole.IsKeyRole and not self.mRole.mAI.mOpenAI and not self.IsshowPve ) then return end
	if self.mRole.mCityHall_IsMyRole and not self.misAutoPos then return end
	self.misAutoPos = nil
	self.mMoveDis = 0
	self.mMoveDeg = 0
	if FightSystem.mFightType == "olpvp" then
		self:StopMove()
	else
		self.mRole:StopMove()
	end
	
	-- 移动固定距离完成回调
	if self.mMoveDis_CallBack then
		self.mMoveDis_CallBack(type)
	end
end

-- 判断是否可移动
function MoveController:CanMoveTo_Hor(_nextX)
	if not self.mRole.IsKeyRole and not self.mRole.mCityHall_IsMyRole then return true end

	if self.mRole.mGroup == "hallrole" then
		return self:canMoveToEdge(_nextX)
	elseif FightSystem.mFightType == "arena" then
		return self:canMoveToEdgeForArena(_nextX)
	elseif FightSystem.mFightType == "olpvp" then
		return self:canMoveToEdge(_nextX)
	else
	   return  FightSystem.mFubenManager:RoleMovePos(_nextX,self.mRole)
	end
end

-- 判断是否可移动
function MoveController:CanMoveTo_Ver(_nextY)
	local  isKeyRole = self.mRole.IsKeyRole
	if self.mRole.mGroup == "monster" or not isKeyRole then
		return true
	end 

	local _sceneH = FightSystem.mSceneManager:GetSceneView(self.mRole.mSceneIndex):GetSceneHeight()
	-- check up beyond
	if _nextY + self.mRole.mSize.height >= _sceneH then
		return false
	end

	-- check down
	if _nextY <= 0.0 then
		return false
	end

	return true
end


function MoveController:canMoveToEdgeForArena(_nextX)
	local _curX = self.mRole:getPositionX()
	local _moveLeft = _curX - _nextX > 0
	local _keyRolewidth = FightConfig.MAP_EDGE + self.mRole.mSize.width/2
	if _nextX - _keyRolewidth <= 0 and _moveLeft then
		return false
	end
	if _nextX + _keyRolewidth >= FightSystem.mSceneManager:GetTiledLayer(self.mRole.mSceneIndex).mWidth and not _moveLeft then
		return false
	end
	return true
end

-- 是否可以移动,减去人物半身
function MoveController:canMoveToEdge(_nextX)
	local _curX = self.mRole:getPositionX()
	local _moveLeft = _curX - _nextX > 0
	local _keyRolewidth = self.mRole.mSize.width/2
	if _nextX - _keyRolewidth <= 0 and _moveLeft then
		return false
	end
	if _nextX + _keyRolewidth >= FightSystem.mSceneManager:GetTiledLayer(self.mRole.mSceneIndex).mWidth and not _moveLeft then
		return false
	end
	return true
end

function MoveController:GetCurPosition()
	return cc.p(self.mRole:getPositionX(), self.mRole:getPositionY())
end

function MoveController:ResumeMoveStatus()
	if self.mMoveStatus == "pause" then
		if self.mCurMoveDirection == FightConfig.DIRECTION_CMD.STOP then
			return false
		elseif self.mRole.mFSM:ChangeToState("runing") then

			self.mMoveStatus = "runing"
			return true
		end
	end
	return false
end

function MoveController:PauseMoveStatus(_dir, _deg)
	if not self.mRole.IsKeyRole then return end
	--
	self.mMoveStatus = "pause"
	if not _dir and not _deg then 
	   _dir,_deg = FightSystem.mTouchPad:getCurDirection()
	end
	self:setCurMoveDir(_dir)
	self.mMoveDeg = _deg
end

function MoveController:StopMoveStatus()
	self.mMoveStatus = "stop"
end

-- 过滤屏幕坐标
function MoveController:filtPosX(_posX)
	if StorySystem.mCGManager.mCGRuning then
		return _posX
	end
	if self.mRole.mGroup == "hallrole" then
	elseif FightSystem.mFightType == "fuben" then
		local _minX = FightSystem.mFubenManager:GetLeftLineX() + self.mRole.mSize.width/2
		local _maxX = FightSystem.mFubenManager:GetRightLineX() - self.mRole.mSize.width/2
		if _posX < _minX then
		   _posX = _minX
		elseif _posX > _maxX then
		   _posX = _maxX
		end
	elseif FightSystem.mFightType == "arena" then
		local _minX =  FightConfig.MAP_EDGE + self.mRole.mSize.width/2
		local _maxX = FightSystem.mSceneManager:GetTiledLayer(self.mRole.mSceneIndex).mWidth - FightConfig.MAP_EDGE - self.mRole.mSize.width/2
		if _posX < _minX then
		   _posX = _minX
		elseif _posX > _maxX then
		   _posX = _maxX
		end
	elseif FightSystem.mFightType == "olpvp" then
		local _minX =  self.mRole.mSize.width/2
		local _maxX = FightSystem.mSceneManager:GetTiledLayer(self.mRole.mSceneIndex).mWidth - self.mRole.mSize.width/2
		if _posX < _minX then
		   _posX = _minX
		elseif _posX > _maxX then
		   _posX = _maxX
		end
	end
	--
	return _posX
end