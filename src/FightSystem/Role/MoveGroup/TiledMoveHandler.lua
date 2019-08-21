-- Name: TiledMoveHandler
-- Func: 格子上移动处理器
-- Author: Johny

module("TiledMoveHandler", package.seeall)

-- 地图标记：
-- 0: 不可达
-- 1: 可达
-- 2: 墙


-- 下台阶角度范围
DS_RANGE_MIN = -120
DS_RANGE_MAX = -60 
DS_LEFT_OFF = 20
DS_RIGHT_OFF = 20
--平滑移动
SM_LEFT_OFF = 45
SM_RIGHT_OFF = 45


-- 检测可达
-- 忽略部分不可达区域，使角色贴墙平滑行走
function CheckReachable(_deg, _curPos, _nextPos, _role)
	-- if _role.mFSM:IsJumping() then
	-- 	return "no"
	-- end
	-- 检测下墙
	-- local _tpCur = GetPropertyByPos(_curPos,_role.mSceneIndex)
	-- if tickCheckDownStairs(_deg, _curPos, _nextPos, _role, _tpCur, _tpNext) then
	-- 	return "no"
	-- if _tpCur == 2 and ((_deg > -180 and _deg < DS_RANGE_MIN) or (_deg > DS_RANGE_MAX and _deg < 0)) then
	-- 	return "x"
	-- end
	-- 检测平滑移动
	local _tpNext = GetPropertyByPos(_nextPos,_role.mSceneIndex)
	local _dir_Right = _deg >= -SM_LEFT_OFF and _deg <= SM_LEFT_OFF
	local _dir_Left = _deg >= 180-SM_RIGHT_OFF and _deg < 180 or _deg > -180 and _deg <= -180 + SM_RIGHT_OFF
	if _tpNext == 0 then
	   if _dir_Right or _dir_Left then
	   	  _curPos.x = _nextPos.x
	   	  local _tpNextX = GetPropertyByPos(_curPos,_role.mSceneIndex)
	   	  if _tpNextX ~= 0 then
	   	     return "x"
	   	  else
	   	  	 return "no"
	   	  end
	   else
	   	   return "no"
	   end
	end

	return "both"
end

-- function tickCheckDownStairs(_deg, _curPos, _nextPos, _role, _tpCur, _tpNext)
-- 	if _tpCur ~= 2 then return false end
-- 	--
-- 	local _dir_Down = _deg >= DS_RANGE_MIN and _deg <= DS_RANGE_MAX
-- 	local _dir_Left = _deg <= 180 and _deg > 180 - DS_LEFT_OFF or _deg > -180 and _deg < -180 + DS_LEFT_OFF
-- 	local _dir_Right = _deg >= - DS_RIGHT_OFF and _deg <= DS_RIGHT_OFF
-- 	local con2 = (_dir_Left or _dir_Right) and _tpNext == 0
-- 	if (_dir_Down or con2) and _role.mFSM:ChangeToState("downstairs") then
-- 		_role.mCurSpeedY = 0
-- 		_nextPos = findPosByLine_Down(_nextPos,_role.mSceneIndex)
-- 		if _nextPos then
-- 		   DownStairsToPos(_curPos, _nextPos, _role)
-- 		return true end
-- 	end

-- 	return false
-- end

-- function DownStairsToPos(_curPos, _nextPos, _role)
-- 	local function finishDownStairs()
-- 		_role.mFSM:ChangeToStateWithCondition("downstairs", "idle")
-- 	end
-- 	local _dir, _deg = FightSystem.mTouchPad:getCurDirection()
-- 	local _dis = cc.pGetDistance(_curPos, _nextPos)
-- 	local _during = MathExt.GetDownTimeByDis(_dis)
-- 	if FightConfig.IsDirectionLeft(_dir) or FightConfig.IsDirectionRight(_dir) then
-- 	   local _dis = math.cos(math.rad(_deg)) * _role.mPropertyCon.mSpeed * _during
-- 	   _nextPos.x = _nextPos.x + _dis
-- 	end
-- 	_during = MathExt.GetDownTimeByDis(_dis) / 30
-- 	local _ac = cc.EaseIn:create(cc.JumpTo:create(_during, _nextPos, 0, 1),2.0)
-- 	local _ac2 = cc.CallFunc:create(finishDownStairs)
-- 	_role.mArmature:runAction(cc.Sequence:create(_ac,_ac2))
-- end

-- -- 用于AI，简单下墙
-- function DownStairsToPos_AI(_role)
-- 	local _curPos = _role:getPosition_pos()
-- 	local _nextPos = findPosByLine_Down(_curPos,_role.mSceneIndex)
-- 	if _nextPos then
-- 		DownStairsToPos(_curPos, _nextPos, _role)
-- 	end
-- end

-- 该坐标是否可以落脚
function CanPosStand(_pos,_sceneIndex)
	local _tp = GetPropertyByPos(_pos,_sceneIndex)
	local con1 = _tp ~= 0
	return con1
end

-- -- 是否在墙上
-- function IsOnWall(_pos,_SceneIndex)
-- 	local _tp = GetPropertyByPos(_pos,_SceneIndex)
-- 	return _tp == 2
-- end

-- function IsOnRoad(_pos,_sceneIndex)
-- 	local _tp = GetPropertyByPos(_pos,_sceneIndex)
-- 	return _tp == 1
-- end


-- 根据pos得出tiledmap的properties
function GetPropertyByPos(_pos,_sceneIndex)
	local _tiledLayer = FightSystem.mSceneManager:GetTiledLayer(_sceneIndex)
	local _tiledX = math.floor(_pos.x/10)
	local _tiledY = math.floor(_pos.y/10)
	local _ret = _tiledLayer.mTiledMap:getPropertyByGiledPos(_tiledX, _tiledY)
	return _ret 
end

-- 修改目前tiledmap的数组中对应值
function setPropertyByGiledPos(_x, _y, _type)
	local _tiledLayer = FightSystem.mSceneManager:GetTiledLayer()
	_tiledLayer.mTiledMap:setPropertyByGiledPos(_x, _y)
end

-- -- 在直线上找
-- function findPosByLine_Up(_pos, _h, _tp)
-- 	local _tiledLayer = FightSystem.mSceneManager:GetTiledLayer()
-- 	local _tiledX = math.floor(_pos.x/10)
-- 	local _tiledY = math.floor(_pos.y/10)
-- 	local _tiledH = math.floor(_h/10) + _tiledY
-- 	for y = _tiledH, _tiledY, -1 do
-- 	    local _tp1 = _tiledLayer.mTiledMap:getPropertyByGiledPos(_tiledX, y)
-- 	    if _tp1 == _tp then
-- 	       return cc.p(_tiledX*10, y*10)
-- 	    end
-- 	end

-- 	return nil
-- end

-- -- 在直线上找
-- function findPosByLine_Down(_pos,_SceneIndex)
-- 	local _tiledLayer = FightSystem.mSceneManager:GetTiledLayer(_SceneIndex)
-- 	local _tiledX = math.floor(_pos.x/10)
-- 	local _tiledY = math.floor(_pos.y/10)
-- 	for y = _tiledY, 0, -1 do
-- 	    local _tp1 = _tiledLayer.mTiledMap:getPropertyByGiledPos(_tiledX, y)
-- 	    if _tp1 ~= 0 then
-- 	       return cc.p(_tiledX*10, y*10)
-- 	    end
-- 	end

-- 	return nil
-- end

-- -- 向上找墙
-- function findWallUp(_x, _y, _nextY)
-- 	local _tiledLayer = FightSystem.mSceneManager:GetTiledLayer()
-- 	local _tiledX = math.floor(_x/10)
-- 	local _tiledY = math.floor(_y/10)
-- 	local _tiledNextY = math.floor(_nextY/10)
-- 	local _bottomY = nil
-- 	local _wallY = nil
-- 	local _bottomFlag = true
-- 	for y = _tiledY, _tiledNextY do
-- 	    local _tp1 = _tiledLayer.mTiledMap:getPropertyByGiledPos(_tiledX, y)
-- 	    if _tp1 == 0 and _bottomFlag then
-- 	       _bottomY = (y-1) * 10
-- 	       _bottomFlag = false
-- 	    end
-- 	    if _tp1 == 2 then
-- 	       _wallY = y * 10
-- 	    break end
-- 	end

-- 	return _bottomY, _wallY
-- end

-- function findRoadDown(_x, _y)
-- 	local _tiledLayer = FightSystem.mSceneManager:GetTiledLayer()
-- 	local _tiledX = math.floor(_x/10)
-- 	local _tiledY = math.floor(_y/10)
-- 	local _roadY = nil
-- 	for y = _tiledY, 0, -1 do
-- 		local _tp1 = _tiledLayer.mTiledMap:getPropertyByGiledPos(_tiledX, y)
-- 		if _tp1 == 1 or _tp1 == 2 then
-- 			_roadY = y * 10
-- 		break end
-- 	end

-- 	return _roadY
-- end