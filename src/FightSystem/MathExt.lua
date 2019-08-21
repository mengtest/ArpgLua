-- Name: MathExt
-- Func: 数学补充
-- Author: Johny

module("MathExt", package.seeall)

-- 游戏每秒帧数
_game_frame = 30

-------------- 重力加速度(-- 像素/帧)-----------------
-- 跳跃，自由落体
_g = 2.5  
-- 击飞
_g_KnockFly_UP = 2.5
_g_KnockFly_DOWN = 2.5


-- 匀减速中求末速度
function GetV1InUniformDeceleration(_v0, _a, _t)
	local _ret = _v0 - _a * _t
	return _ret
end

-- 匀减速中求加速度
function GetAInUniformDeceleration(_v0, _t)
	return _v0 / _t
end

-- 匀减速中求初速度
function GetV0InUniformDeceleration(_a, _t)
	return _a * _t
end

-- 匀速减速单位时间移动距离
function GetDisInUniformDeceleration(_v0, _a, _t)
	--cclog("GetDisInUniformDeceleration")
	local _ret = _v0 * _t - 0.5 * _a * math.pow(_t, 2)
	--cclog(_ret)
	return _ret
end

-- 匀加速中求末速度
function GetV1InUniformAcceleration(_v0, _a, _t)
	-- cclog("GetV1InUniformAcceleration === " .. _a)
	local _ret = _v0 + _a * _t
	return _ret
end

-- 匀加速求加速度
function GetAInUniformAcceleration(_dis, _t)
	local _a =  (2 * _dis) / math.pow(_t, 2)
	return _a
end

-- 获取跳跃初速度
function GetV0InJump(_h)
	return math.sqrt(2 * _g * _h)
end

-- 获取跳跃高度
function GetHInJumpByDuring(_t)
	return 0.5 * _g * math.pow(_t, 2)
end

-- 获取跳跃上升时间
function GetUpTimeInJump(_v)
	local _during =  math.floor(_v / _g)
	return _during
end

-- 获取自由落体时间
function GetDownTimeByDis(_dis)
	local _V = GetV0InJump(_dis)
	return GetUpTimeInJump(_V)
end

-- 获取击飞下降时间
function GetDownTime_KnockFly(_h, _gg)
	local _v = math.sqrt(2 * _gg * _h)
	return math.floor(_v / _gg)
end

-- 获取匀减速到0的加速度
function GetAandV0InUniformDeceleration_0(_s, _t)
	local _a =  (2 * _s) / math.pow(_t, 2)
	local _v0 = (2 * _s) / _t

	return _v0, _a
end


-- 判断点在椭圆内
function IsPosInEllipse(_x, _y, _a, _b)
	local _ret = math.pow(_x, 2) / math.pow(_a, 2) + math.pow(_y, 2) / math.pow(_b, 2)
	
	return _ret <= 1
end

-- 判断点在扇形中
function IsPosInSector(_cX, _cY, _r, _theta, _pX, _pY, _uX)
	local _uY = 0
    local _dx = _pX - _cX
    local _dy = _pY - _cY
    local length = cc.pGetDistance(cc.p(_cX, _cY), cc.p(_pX, _pY))
 	--cclog("IsPosInSector===" .. length .. "===" .. _r)
    if length > _r then
       return false
    end

    _dx = _dx / length;
    _dy = _dy / length;
 
    local _deg = math.deg(math.acos(_dx * _uX + _dy * _uY))
    --cclog("IsPosInSector====" .. _deg .. "===" .. _theta)
    return _deg < _theta;
end

-- 计算2个向量的夹角
function GetDegreeWithTwoPoint(_pt1, _pt2)
	  local _subPoint = cc.pSub(_pt1, _pt2)
      local _deg = math.deg(cc.pToAngleSelf(_subPoint))
      return _deg
end

-- 计算2个点的距离
function GetDisByTwoPoint(_pt1, _pt2)
	return cc.pGetLength(cc.p(_pt1.x - _pt2.x, _pt1.y - _pt2.y))
end

-- 椭圆上任意一点到椭圆圆心的距离
function GetEllipseByCenterDis(_ra, _rb, _deg)
	local  deg = _deg
	deg = math.abs(deg)
	if deg == 0 or deg == 180 then
		return _ra
	end
	if deg == 90 then
		return _rb
	end	
	if deg > 90 and deg < 180 then
		deg = 180 - deg							
	end
	local rad = math.rad(deg)
	local sina = math.sin(rad)
	local cosa = math.cos(rad)
	local ra_square = _ra*_ra
	local rb_square = _rb*_rb
	local sina_square = sina*sina
	local cosa_square = cosa*cosa
	local r = math.sqrt((ra_square * rb_square) / (ra_square * sina_square + rb_square * cosa_square ) ) 
	return r
end


function release()
	_G["MathExt"] = nil
	package.loaded["MathExt"] = nil
	package.loaded["FightSystem/MathExt"] = nil
end