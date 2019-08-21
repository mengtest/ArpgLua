-- Name: FEM
-- Func: 人物效果机， 仅限战斗中的人物使用
-- Author: Johny

FEM = class("FEM")

function FEM:ctor(_holder)
	-- init Var
	self.mHolder = _holder
	--受击效果
	self.mCurBeatEffect = "none"
	self.mBeatEffects = {[0] = "none", "knockback", "knockstunned","knockfly", "frozen", "sleep", "freefall","immobilized",[11] = "knockback",[13] = "falldown",[14] = "falldown",[31] = "knockflight",[32] = "knockfly"}  -- 状态间互斥
	self.mFunc_BeatEffect_Change = nil
	self.mSwitchList = {
						["none"] = {"knockback", "knockstunned","knockfly", "frozen","immobilized", "sleep","knockflight","falldown","freefall"},
						["knockfly"] = {"none", "knockfly", "sleep","knockflight"},
						["knockflight"] = {"none", "knockflight", "sleep","freefall"},
						["freefall"] = {"none","knockflight", "knockfly", "sleep"},
					    ["knockstunned"] = {"none", "knockstunned","knockflight", "knockfly", "frozen", "immobilized","sleep"},
					    ["knockback"] = {"none", "knockstunned", "knockflight", "knockfly", "frozen","immobilized", "sleep","knockback"},
					    ["frozen"] = {"none","frozen"},
					    ["sleep"] = {"none", "frozen","immobilized"},
					    ["falldown"] = {"none", "knockfly","knockflight","knockstunned","knockback","frozen","immobilized"},
					    ["immobilized"] = {"none","immobilized"},
				  	   }

	self.mList1 = {"knockback", "knockstunned", "knockfly","knockflight"}
	self.mList2 = {"frozen", "sleep"}
end

------------------------------受击效果---------------------------------------
-- 切换到某效果
function FEM:ChangeToBeatEffect(_effectID, _data)
	local _to = self.mBeatEffects[_effectID]
	if not self:canSwitch(self.mCurBeatEffect, _to) then return false end
	local _isTurnflight = false
	if self.mCurBeatEffect ~= "knockfly" and self.mCurBeatEffect ~= "freefall" and self.mCurBeatEffect ~= "knockflight" and _to == "knockflight" then
		_to = "knockfly"
		_isTurnflight = true
	end
--	doError(string.format("ChangeToBeatEffect==%s===",self.mCurBeatEffect))
	cclog(string.format("=====[FEM:ChangeToBeatEffect]=====from: %s  == to:  %s",self.mCurBeatEffect,_to))
	local _from = self.mCurBeatEffect
	self.mCurBeatEffect = _to
	self.mFunc_BeatEffect_Change(_from, _to, _data,_isTurnflight)
	return true
end

-- 忽略buff切换状态
function FEM:ChangeToBeatEffectBeglectBuff(_effectID)
	local _to = self.mBeatEffects[_effectID]
	cclog(string.format("=====[FEM:ChangeToBeatEffect]=====from: %s  == to:  %s",self.mCurBeatEffect,_to))
	local _from = self.mCurBeatEffect
	self.mCurBeatEffect = _to
	self.mFunc_BeatEffect_Change(_from, _to)
	return true
end

-- 转成死亡击飞状态
function FEM:changetoDeadFly(_hiterDir)
	local _to = "dead_knockfly"
	--cclog("=====[FEM:changetoDeadFly]=====from: " .. self.mCurBeatEffect .. "to:  " .. _to)
	local _from = self.mCurBeatEffect
	self.mCurBeatEffect = "knockfly"
	local _data = DB_SkillState.getDataById(5)
	local _tb = {_data, _hiterDir}
	self.mFunc_BeatEffect_Change(_from, _to, _tb)
end

-- 注册效果改变回调函数
function FEM:RegisterFunc_BeatEffect_Change(_func)
	self.mFunc_BeatEffect_Change = _func
end

-- 检查是否为没有受击状态
function FEM:IsBeatStNone()
	return self.mCurBeatEffect == "none"
end

-- 击飞状态
function FEM:IsBeatStFly()
	return self.mCurBeatEffect == "knockfly"
end

-- 浮空击飞状态
function FEM:IsBeatStFlight()
	return self.mCurBeatEffect == "knockflight"
end

-- 击退状态
function FEM:IsBeatStBack()
	return self.mCurBeatEffect == "knockback"
end

-- 击晕状态
function FEM:IsBeatStstunned()
	return self.mCurBeatEffect == "knockstunned"
end

-- 冰冻状态
function FEM:IsFrozen()
	return self.mCurBeatEffect == "frozen"
end

-- 定身状态
function FEM:IsImmobilized()
	return self.mCurBeatEffect == "immobilized"
end

-- 自由落体状态
function FEM:IsFreeFall()
	return self.mCurBeatEffect == "freefall"
end

function FEM:IsBeatStFlyByID(_id)
	local _effect = self.mBeatEffects[_id]
	return _effect == "knockfly"
end

-- 获取当前状态
function FEM:getCurState()
	return self.mCurBeatEffect
end

function FEM:canSwitch(_from, _to)
	if not self:canSwitch_state(_from, _to) then return false end
	return self:canSwitch_buff(_to)
end

-- 检查状态间
function FEM:canSwitch_state(_from, _to)
	local _switchlist = self.mSwitchList[_from]
	if _switchlist == nil then return false end
	--
	for k,v in pairs(_switchlist) do
		if v == _to then
	    return true end
	end

	return false
end

-- 检查与buff的转换
function FEM:canSwitch_buff(_to)
	if self.mHolder.mBuffCon:hasInvincibleBuffNow() then return false end
	if self:inList1(_to) then
	   if self.mHolder.mFSM:IsFallingDown() then return false end
	   if self.mHolder:hasNoControlBuffNow() then return false end
	end

	return true
end

function FEM:inList1(_effect)
	for k,v in pairs(self.mList1) do
		if v == _effect then
		return true end
	end

	return false
end

function FEM:inList2(_effect)
	for k,v in pairs(self.mList2) do
		if v == _effect then
		return true end
	end

	return false
end
------------------------------受击效果---------------------------------------