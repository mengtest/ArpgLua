-- Name: FSM
-- Func: 战斗状态机， 仅限战斗中的人物使用
-- Author: Johny

FSM = class("FSM")

function FSM:ctor(_holder)
	-- init Var
	self.mHolder = _holder
	self.mCurState = "none"
	self.mStates = {"idle", "runing","attacking", "beatingstiff","dead", "becontroled", "begriped", "falldown",
				    "block",
					}
	self.mFunc_State_Change = nil
	-- 互斥状态
	self.mMutex = {["runing"] = {}
				   ,["idle"] = {}
				   ,["block"] = {"runing"}
				   ,["attacking"] = {"runing","beatingstiff"}
				   ,["beatingstiff"] = {"runing", "attacking", "block"}
				   ,["dead"] = {"idle", "runing","attacking", "beatingstiff","dead", "becontroled", "falldown", "block"}
				   ,["becontroled"] = {"runing","attacking", "beatingstiff", "block"}
				   ,["falldown"] = { "beatingstiff", "runing", "attacking","block"}
				   ,["begriped"] = {"idle", "runing","attacking", "beatingstiff","dead", "becontroled", "begriped", "falldown", "block"}
				  }
	-- 移动状态组
	self.mMoveStateGroup = {"runing"}
	-- 变形下可执行状态
	self.mSheepStateList = {"idle", "runing", "dead"}
end

function FSM:IsNotMutex(_from, _to)
	local _mutexTable = self.mMutex[_from]
	if _mutexTable == nil then
	return true end
	--
	-- if self.mHolder.mGroup == "monster" and self.mHolder.mRoleData.mInfoDB.Monster_Grade ~= 4 then
	-- 	if _from == "attacking" and _to == "beatingstiff" then
	-- 		return true
	-- 	end
	-- end
	for k,v in pairs(_mutexTable) do
		if v == _to then
			cclog(string.format("=====[FSM:IsNotMutex]===== from: %s  to: %s",self.mCurState,_to))
			return false 
		end
	end

	return true
end

-- 切换到某状态
function FSM:ChangeToState(_to, _data)
	if self.mHolder.mBuffCon:isInSheepBuff() then
	   if not isValueInTable(_to, self.mSheepStateList) then
	   return false end
	end
	if self.mHolder.mIsUpBenching then return false end
	--
	local _from = self.mCurState
	if self:IsNotMutex(_from, _to) then
		-- 切换攻击的时候需要特殊判断
		if _to == "attacking" then
			if not self.mHolder.mSkillCon:isSetSkillByID(_data[1]) then
				--doError(string.format("NOT   attacking====%d==",_data[1]))
				return false
			end
		end
		self.mCurState = _to
		self.mFunc_State_Change(_from, _to, _data)
		return true
	end

	return false
end

-- 试图切换到某状态
function FSM:IsCanChangeToState(_to, _data)
	if self.mHolder.mBuffCon:isInSheepBuff() then
	   if not isValueInTable(_to, self.mSheepStateList) then
	   return false end
	end
	--
	local _from = self.mCurState
	if self:IsNotMutex(_from, _to) then
		-- 切换攻击的时候需要特殊判断
		if _to == "attacking" then
			if not self.mHolder.mSkillCon:isSetSkillByID(_data[1]) then
				return false
			end
		end
		return true
	end
	return false
end

function FSM:ChangeToStateWithCondition(_from, _to, _data)
	if self.mHolder.mBuffCon:isInSheepBuff() then
	   if not isValueInTable(_to, self.mSheepStateList) then
	   return false end
	end
	--
	if self.mCurState == _from then
	   return self:ChangeToState(_to, _data)
	end

	return false
end

-- 无条件切换状态
function FSM:ForceChangeToState(_to, _data)
	if self.mHolder.mBuffCon:isInSheepBuff() then
	   if not isValueInTable(_to, self.mSheepStateList) then
	   return false end
	end
	if _to == "dead" then
		if self.mHolder.mAI then
			self.mHolder.mAI:setOpenAI(false)
		end
	end
	if _to == "begriped" then
		self.mHolder.mArmature:clearAnimationFunlist()
		self.mHolder.mArmature:clearAnimationEndFunlist()
	elseif self.mCurState == "falldown" and _to == "dead" then
		self.mHolder.mBeatCon.mFalldownCon.mIsFalldowning = true
		self.mHolder.mArmature:clearAnimationFunlist()
		self.mHolder.mArmature:clearAnimationEndFunlist()
	end
	if self.mCurState == "becontroled" and _to ~= "becontroled" then
		self.mHolder.mBeatCon:CancelAllBeat(self.mHolder.mFEM.mCurBeatEffect,_to)
	end

	local _from = self.mCurState
	cclog(string.format("[FSM:ForceChangeToState]===[ %s = %d ]===== from: %s   to:  %s",self.mHolder.mGroup,self.mHolder.mInstanceID,self.mCurState , _to))
	self.mCurState = _to
	self.mFunc_State_Change(_from, _to, _data)
	return true
end

-- 强制切换状态但是不做动作
function FSM:ForceChangeToStateNoAction(_to, _data)
	if self.mHolder.mBuffCon:isInSheepBuff() then
	   if not isValueInTable(_to, self.mSheepStateList) then
	   return false end
	end
	if self.mCurState == "becontroled" and _to ~= "becontroled" then
		self.mHolder.mBeatCon:CancelAllBeat(self.mHolder.mFEM.mCurBeatEffect,_to)
	end

	local _from = self.mCurState
	cclog(string.format("[FSM:ForceChangeToStateNoAction]===[ %s = %d ]===== from: %s   to:  %s",self.mHolder.mGroup,self.mHolder.mInstanceID,self.mCurState , _to))
	self.mCurState = _to
	return true
end

-- 无条件切换状态ForPVP
function FSM:ForceChangeToStateForpvp(_to, _data)
	if self.mHolder.mBuffCon:isInSheepBuff() then
	   if not isValueInTable(_to, self.mSheepStateList) then
	   return false end
	end
	if _to == "begriped" then
		self.mHolder.mArmature:clearAnimationFunlist()
		self.mHolder.mArmature:clearAnimationEndFunlist()
	elseif self.mCurState == "falldown" and _to == "dead" then
		self.mHolder.mBeatCon.mFalldownCon.mIsFalldowning = true
		self.mHolder.mArmature:clearAnimationFunlist()
		self.mHolder.mArmature:clearAnimationEndFunlist()
	end
	if self.mCurState == "becontroled" and _to ~= "becontroled" then
		self.mHolder.mBeatCon:CancelAllBeat(self.mHolder.mFEM.mCurBeatEffect,_to)
	elseif self.mCurState == "beatingstiff" and _to ~= "beatingstiff" then
		self.mHolder.mBeatCon.mInjuredStiffDuring = 0
	elseif self.mCurState == "falldown" and _to ~= "falldown" then
		self.mHolder.mBeatCon.mKnockFlyCon:cancelKnockFlyByNoContr()
		self.mHolder.mBeatCon.mFreefallCon:cancelFreeFall()
	elseif self.mCurState == "begriped" and _to ~= "begriped" then
		self.mHolder.mBeatCon.mBeatGripedCon:OnGripReleasedForPVP()
	end
	local _from = self.mCurState
	cclog(string.format("[FSM:ForceChangeToStateForpvp]===[ %s = %d ]===== from: %s   to:  %s",self.mHolder.mGroup,self.mHolder.mInstanceID,self.mCurState , _to))
	self.mCurState = _to
	self.mFunc_State_Change(_from, _to, _data)
	return true
end

-- 注册状态改变回调函数
function FSM:RegisterFunc_State_Change(_func)
	self.mFunc_State_Change = _func
end

-- 获取当前状态
function FSM:GetCurState()
	return self.mCurState
end

-- 获取该状态机的宿主
function FSM:GetHolder()
	return self.mHolder
end

-- 查询状态
function FSM:IsRuning()
	return self.mCurState == "runing"
end

function FSM:IsIdle()
	return self.mCurState == "idle"
end

function FSM:IsBlock()
	return self.mCurState == "block"
end

-- 处于硬直状态
function FSM:IsBeatingStiff()
	return self.mCurState == "beatingstiff"
end

-- 处于死亡状态
function FSM:IsDeading()
	return self.mCurState == "dead"
end

function FSM:IsBeControlled()
	return self.mCurState == "becontroled"
end

function FSM:IsFallingDown()
	return self.mCurState == "falldown"
end

function FSM:IsBeGriped()
	return self.mCurState == "begriped"
end

function FSM:IsAttacking()
	return self.mCurState == "attacking"
end

-- 当前是否是移动组中的状态
function FSM:IsWithinMoveState()
	return self:IsRuning()
end

-- 是否可被选定
function FSM:CanBeSelected()
	return not self:IsDeading()
end



-- 输出当前状态
function FSM:PrintCurState()
	cclog(string.format("=====[FSM:cclogCurState]=====CurState: %s",self.mCurState))
end

-- 输出所有状态
function FSM:PrintAllState()
	--cclog("====================================[FSM:cclogAllState]============================================")
	for k,v in pairs(self.mStates) do
		--cclog("=====state" .. k .. ":  " .. v)
	end
	--cclog("====================================[FSM:cclogAllState]============================================")
end
