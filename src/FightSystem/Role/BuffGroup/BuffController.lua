-- Name: BuffController
-- Author: Johny
require "FightSystem/Role/BuffGroup/BuffPoision"
require "FightSystem/Role/BuffGroup/BuffBlood"
require "FightSystem/Role/BuffGroup/BuffFired"
require "FightSystem/Role/BuffGroup/BuffElectricity"
require "FightSystem/Role/BuffGroup/BuffPullBack"
require "FightSystem/Role/BuffGroup/BuffPullAway"
require "FightSystem/Role/BuffGroup/BuffSheep"
require "FightSystem/Role/BuffGroup/BuffInvincible"
require "FightSystem/Role/BuffGroup/BuffNoControl"
require "FightSystem/Role/BuffGroup/BuffImmunity"
require "FightSystem/Role/BuffGroup/BuffDisperse"
require "FightSystem/Role/BuffGroup/BuffHeal"
require "FightSystem/Role/BuffGroup/BuffAttRate"
require "FightSystem/Role/BuffGroup/BuffSpeed"
require "FightSystem/Role/BuffGroup/BuffProperty"
require "FightSystem/Role/BuffGroup/BuffSkillReplaced"
require "FightSystem/Role/BuffGroup/BuffAddClip"
require "FightSystem/Role/BuffGroup/BuffAddGravitational"
require "FightSystem/Role/BuffGroup/BuffSneer"
require "FightSystem/Role/BuffGroup/BuffDamage"
require "FightSystem/Role/BuffGroup/BuffSilence"
require "FightSystem/Role/BuffGroup/BuffReverseHurt"
require "FightSystem/Role/BuffGroup/BuffSurplusBlood"
require "FightSystem/Role/BuffGroup/BuffBound"






BuffController = class("BuffController")

function BuffController:ctor(_role)
	self.mRole = _role
	self.mCurBuffList = {}
	self.mDeBuffList = {101, 102, 103, 104, 105, 106, 107}
	self.mBuffList = {201, 202, 203, 204, 205}
	self.mBuffRotateList = {}
	self.mBuffOlPvpInform = {[101] = true, [102] = true, [103] = true, [111] = true, [205] = true, [206] = true, [303] = true, [304] = true}
end

function BuffController:Destroy()
	self.mRole = nil
	for k,buff in pairs(self.mCurBuffList) do
		buff:Destroy()
	end
end

function BuffController:Tick(delta)
	if StorySystem.mCGManager.mCGRuning then return end
	for k,buff in pairs(self.mCurBuffList) do
		buff:Tick(delta)
	end
end

function BuffController:addBuff(_dbState,  _dbEff, _releaser, _dbProc, _level, _skillId, _processType, _subhost)
	local _effctMethod = _dbEff.ExcuteMethod
	if not self:canBeAdded(_effctMethod) then 
		return 
	end
	local _buff = nil
	local successRatioData = _dbState.SuccessRatio
	local num = math.random(1,100)
	if num > successRatioData then
		return
	end
	self:addBuffForOlPvp(_effctMethod,_dbState,  _dbEff, _releaser, _dbProc, _level, _skillId, _processType,_subhost)
	-- 用过程段时间
	if _effctMethod == 106 then
    	--cclog("添加buff: 推开 ==== 106 =====Group:   " .. self.mRole.mGroup .. "======" .. self.mRole.mInstanceID)
    	if self.mRole.mFSM:IsFallingDown() or self.mRole.mFSM:IsBeGriped() then return end
    	if not _dbProc then return end
    	_buff = BuffPullAway.new(self.mRole, self, _releaser, _dbState, _dbEff, _dbProc.LastTime)
    end
    if _effctMethod == 108 then
    	if self:hasNoControlBuffNow() then
    		return
    	end
    end
    if self.mCurBuffList[_dbState.ID] and _effctMethod ~= 106 then
	   	  if self.mCurBuffList[_dbState.ID].mDuringType ~= 1 then
	   	  	self.mCurBuffList[_dbState.ID].mDuring = _dbState.LastTime
	   	  	if not _level then
	   	  		_level = 1
	   	  	end
	   	  	self.mCurBuffList[_dbState.ID].SkillLevel = _level
	   	  end
	   	  return
	 end

    -- 用状态持续时间
	if _effctMethod == 101 then
		--cclog("添加buff: 中毒 ==== 101 =====Group:   " .. self.mRole.mGroup .. "======" .. self.mRole.mInstanceID)
		_buff = BuffPoision.new(self.mRole, self, _releaser, _dbState, _dbEff, _level, _processType, _subhost)
	elseif _effctMethod == 102 then
		--cclog("添加buff: 出血 ==== 102 =====Group:   " .. self.mRole.mGroup .. "======" .. self.mRole.mInstanceID)
		_buff = BuffBlood.new(self.mRole, self, _releaser, _dbState, _dbEff, _level, _processType, _subhost)	
	elseif _effctMethod == 103 then
		--cclog("添加buff: 灼烧 ==== 103 =====Group:   " .. self.mRole.mGroup .. "======" .. self.mRole.mInstanceID)
		_buff = BuffFired.new(self.mRole, self, _releaser, _dbState, _dbEff, _level, _processType, _subhost)	
	elseif _effctMethod == 104 then
		--cclog("添加buff: 感电 ==== 104 =====Group:   " .. self.mRole.mGroup .. "======" .. self.mRole.mInstanceID)
		_buff = BuffElectricity.new(self.mRole, self, _releaser, _dbState, _dbEff)
	elseif _effctMethod == 105 then
	   --cclog("添加buff: 拉回 ==== 105 =====Group:   " .. self.mRole.mGroup .. "======" .. self.mRole.mInstanceID)
	   if self.mRole.mFSM:IsBeGriped() then return end
       _buff = BuffPullBack.new(self.mRole, self, _releaser, _dbState, _dbEff)
    elseif _effctMethod == 107 then
    	--cclog("添加buff: 变形 ==== 107 =====Group:   " .. self.mRole.mGroup .. "======" .. self.mRole.mInstanceID)
    	_buff = BuffSheep.new(self.mRole, self, _releaser, _dbState, _dbEff)
   	elseif _effctMethod == 108 then
    	--cclog("添加buff: 嘲讽 ==== 108 =====Group:   " .. self.mRole.mGroup .. "======" .. self.mRole.mInstanceID)
    	_buff = BuffSneer.new(self.mRole, self, _releaser, _dbState, _dbEff)
   	elseif _effctMethod == 109 then
    	--cclog("添加buff: 沉默 ==== 109 =====Group:   " .. self.mRole.mGroup .. "======" .. self.mRole.mInstanceID)
    	_buff = BuffSilence.new(self.mRole, self, _releaser, _dbState, _dbEff)
    elseif _effctMethod == 110 then
    	--cclog("添加buff: 束缚 ==== 110 =====Group:   " .. self.mRole.mGroup .. "======" .. self.mRole.mInstanceID)
    	_buff = BuffBound.new(self.mRole, self, _releaser, _dbState, _dbEff)
    elseif _effctMethod == 111 then
    	--cclog("添加buff: 百分比扣血 ==== 109 =====Group:   " .. self.mRole.mGroup .. "======" .. self.mRole.mInstanceID)
    	_buff = BuffSurplusBlood.new(self.mRole, self, _releaser, _dbState, _dbEff)
    elseif _effctMethod == 201 then
    	--cclog("添加buff: 无敌 ==== 201 =====Group:   " .. self.mRole.mGroup .. "======" .. self.mRole.mInstanceID)
    	_buff = BuffInvincible.new(self.mRole, self, _releaser, _dbState, _dbEff)
    elseif _effctMethod == 202 then
    	--cclog("添加buff: 霸体 ==== 202 =====Group:   " .. self.mRole.mGroup .. "======" .. self.mRole.mInstanceID)
    	_buff = BuffNoControl.new(self.mRole, self, _releaser, _dbState, _dbEff)
    elseif _effctMethod == 203 then
    	--cclog("添加buff: 免疫 ==== 203 =====Group:   " .. self.mRole.mGroup .. "======" .. self.mRole.mInstanceID)
    	_buff = BuffImmunity.new(self.mRole, self, _releaser, _dbState, _dbEff)
    elseif _effctMethod == 204 then
    	--cclog("添加buff: 净化 ==== 204 =====Group:   " .. self.mRole.mGroup .. "======" .. self.mRole.mInstanceID)
    	_buff = BuffDisperse.new(self.mRole, self, _releaser, _dbState, _dbEff)
    elseif _effctMethod == 205 then
    	--cclog("添加buff: 治疗 ==== 205 =====Group:   " .. self.mRole.mGroup .. "======" .. self.mRole.mInstanceID)
    	_buff = BuffHeal.new(self.mRole, self, _releaser, _dbState, _dbEff, _level, _processType, _subhost)
   	elseif _effctMethod == 206 then
    	--cclog("添加buff: 反伤 ==== 206 =====Group:   " .. self.mRole.mGroup .. "======" .. self.mRole.mInstanceID)
    	_buff = BuffReverseHurt.new(self.mRole, self, _releaser, _dbState, _dbEff, _level, _processType, _subhost)
    elseif _effctMethod == 301 then
    	--cclog("添加buff: 攻速改变 ==== 301 =====Group:   " .. self.mRole.mGroup .. "======" .. self.mRole.mInstanceID)
    	_buff = BuffAttRate.new(self.mRole, self, _releaser, _dbState, _dbEff)
    elseif _effctMethod == 302 then
    	--cclog("添加buff: 速度改变 ==== 302 =====Group:   " .. self.mRole.mGroup .. "======" .. self.mRole.mInstanceID)
    	_buff = BuffSpeed.new(self.mRole, self, _releaser, _dbState, _dbEff)
    elseif _effctMethod == 303 then
    	--cclog("添加buff: 属性改变 ==== 303 =====Group:   " .. self.mRole.mGroup .. "======" .. self.mRole.mInstanceID)
    	_buff = BuffProperty.new(self.mRole, self, _releaser, _dbState, _dbEff)
    elseif _effctMethod == 304 then
    	--cclog("添加buff: 改变最终伤害 ==== 304 =====Group:   " .. self.mRole.mGroup .. "======" .. self.mRole.mInstanceID)
    	_buff = BuffDamage.new(self.mRole, self, _releaser, _dbState, _dbEff)	
    elseif _effctMethod == 401 then
    	--cclog("添加buff: 替换技能 ==== 401 =====Group:   " .. self.mRole.mGroup .. "======" .. self.mRole.mInstanceID)    	
    	_buff = BuffSkillReplaced.new(self.mRole, self, _releaser, _dbState, _dbEff)
    elseif _effctMethod == 402 then
    	--cclog("添加buff: 加弹夹 ==== 402 =====Group:   " .. self.mRole.mGroup .. "======" .. self.mRole.mInstanceID)    	
    	_buff = BuffAddClip.new(self.mRole, self, _releaser, _dbState, _dbEff)
    elseif _effctMethod == 403 then
    	--cclog("添加buff: 重力加速度 ==== 402 =====Group:   " .. self.mRole.mGroup .. "======" .. self.mRole.mInstanceID)    	
    	_buff = BuffAddGravitational.new(self.mRole, self, _releaser, _dbState, _dbEff)
    end

    if _buff then
    	if _dbState.StateDisplayText ~= 0 then
    		self.mRole.mFlowLabelCon:FlowBuffName(getDictionaryText(_dbState.StateDisplayText))
    	end
	   	self.mCurBuffList[_dbState.ID] = _buff
	end
end

-- 添加PVP通知服务器加BUff
function BuffController:addBuffForOlPvp(_effctMethod, _dbState,  _dbEff, _releaser, _dbProc, _level, _skillId , _processType,_subhost)
	if FightSystem.mFightType == "olpvp" and self.mBuffOlPvpInform[_effctMethod] then
    	if self.mRole.mGroup == "friend" then
	    	local con = nil
	    	local con1 = nil
	    	if _releaser.mGroup == self.mRole.mGroup then
	    		con1 = true
	    	end
			if globaldata.olpvpType == 0 or globaldata.olpvpType == 3 then
				con = true
			else
				local index = globaldata:convertOlindex(globaldata.olHoldindex)
				if index == self.mRole.mPosIndex then
					con = true
				end
			end
			if con then
				if not _processType then
					_processType = 0
				end
				local num = 0
				if globaldata.olHoldindex%2 == 0 then
					num = 1
				end
				local enemyindex = nil
				if con1 then
					enemyindex = _releaser.mPosIndex*2
				else
					enemyindex = _releaser.mPosIndex*2 - num
				end
				FightSystem:GetFightManager():SendDamgeBuff(_skillId,_processType,_dbProc.ID,_dbState.ID,enemyindex)
			end
		end
    end
end

-- 移除buff
function BuffController:removeBuff(_buff)
	self:removeBuffByID(_buff.mStateID)
end

-- 移除指定buff
function BuffController:removeBuffByID(_buffID)
	local buff = self.mCurBuffList[_buffID]
	if buff then
		buff:Destroy()
		self.mCurBuffList[_buffID] = nil
		self.mRole.mBeatCon:cancelTrapBuffID(_buffID)
	end
end

function BuffController:getCurBuffList()
	return self.mCurBuffList
end

-- 是否有无敌buff
function BuffController:hasInvincibleBuffNow()

	for k,buff in pairs(self.mCurBuffList) do
		if buff.mName == "invincible" then
		return true end
	end
	if self.mRole.Invincible then
		return true
	end
	
	return false
end

-- 是否有霸体buff
function BuffController:hasNoControlBuffNow()
	for k,buff in pairs(self.mCurBuffList) do
		if buff.mName == "nocontrol" then
		return true end
	end

	return false
end

-- 是否有免疫buff, 有则返回buff
function BuffController:hasImmunityBuffNow()

	for k,buff in pairs(self.mCurBuffList) do
		if buff.mName == "immunity" then
		return buff end
	end

	return nil
end

-- 是否能被添加上
function BuffController:canBeAdded(_buffID)
	if self:inDeBuffList(_buffID) then
	   if self:hasInvincibleBuffNow() then
	   return false end
	   local _immuBuff = self:hasImmunityBuffNow()
	   if _immuBuff then
	   	  if _immuBuff:isInImmuList(_buffID) then
	   	  return false end
	   end
	end

	return true
end

function BuffController:inDeBuffList(_buffID)
	for k,v in pairs(self.mDeBuffList) do
		if v == _buffID then
		return true end
	end

	return false
end

-- 是否有嘲讽
function BuffController:hasSneerBuffNow()
	for k,buff in pairs(self.mCurBuffList) do
		if buff.mName == "sneer" then
		return true end
	end

	return false
end

-- 是否有束缚
function BuffController:hasBoundBuffNow()
	for k,buff in pairs(self.mCurBuffList) do
		if buff.mName == "bound" then
		return true end
	end

	return false
end

-- 是否有沉默
function BuffController:hasSilenceBuffNow()
	for k,buff in pairs(self.mCurBuffList) do
		if buff.mName == "silence" then
		return true end
	end

	return false
end

function BuffController:inBuffList(_buffID)
	for k,v in pairs(self.mDeBuffList) do
		if v == _buffID then
		return true end
	end

	return false
end

-- 是否处于变形状态
function BuffController:isInSheepBuff()
	for k,buff in pairs(self.mCurBuffList) do
		if buff.mName == "sheep" then
		return true end
	end

	return false	
end

-- 添加特效
function BuffController:addLightEffect(_dbState, _mEffect ,_fun)
	local IsupdateRotate = false
	for i=1,4 do
		local key = string.format("LightEffect%d",i)
		local data = _dbState[key]

		local LightEffect = data[1]
		local LightEffectPriority = data[2]
		local LightEffectBone = data[3]
		local HangType = data[4]
		local IsRotate = data[5]
		if IsRotate == 1 then
			LightEffectPriority = 1
		end
		if LightEffect ~= 0 then

			local _root = nil
			if HangType ~= 0 then
				_root = self.mRole.mShadow
			else
				_root = self.mRole.mArmature
			end
			local EffectInfo = {}
			EffectInfo.SpineNode = cc.Node:create()
			_root:addChild(EffectInfo.SpineNode)
			if self.mRole.IsFaceLeft then
				EffectInfo.SpineNode:setScaleX(-1)
			else
				EffectInfo.SpineNode:setScaleX(1)
			end
			EffectInfo.SpineEffect = CommonAnimation.createCacheSpine_commonByResID(LightEffect,EffectInfo.SpineNode)
			EffectInfo.SpineEffect:setScale(self.mRole.mArmature.mScale)
			EffectInfo.SpineNode:setLocalZOrder(LightEffectPriority)
			EffectInfo.HangType = HangType
			EffectInfo.HangBone = LightEffectBone
			EffectInfo.SpineEffect:setPosition(0,0)
			_mEffect.mEffect[i] = EffectInfo
			if LightEffectBone ~= "" then
				_bonePos = self.mRole.mArmature.mSpine:getBonePosition(LightEffectBone)
				EffectInfo.SpineNode:setPositionY(_bonePos.y*self.mRole.mArmature.mScale)
			end
			if IsRotate == 1 then
				self.mBuffRotateList[_dbState.ID] = {EffectInfo.SpineEffect,0,_mEffect,EffectInfo.SpineNode}
				IsupdateRotate = true
				EffectInfo.SpineEffect:setToSetupPose()
				EffectInfo.SpineEffect:registerSpineEventHandler(_fun, 3)

			else
				EffectInfo.SpineEffect:setAnimation(0,"start",true)
			end
		else
			break
		end
	end
	if IsupdateRotate then
		self:UpdateRotateList()
	end
end


function BuffController:setTitleFlip(_flip)
	for k,v in pairs(self.mBuffRotateList) do
		v[4]:setScaleX(_flip)
	end
end

-- 旋转出特效
function BuffController:PopRotate()
	for k,v in pairs(self.mBuffRotateList) do
		if v[2] == 0 then
			v[1]:setAnimation(0,"start",true)
			v[1]:setVisible(true)
			v[2] = 1
			break
		end
	end
end

-- 更新旋转特效
function BuffController:UpdateRotateList()
	local RotateTotal = 0
	for k,v in pairs(self.mBuffRotateList) do
		v[1]:setToSetupPose()
		v[1]:setVisible(false)
		v[2] = 0
		RotateTotal = RotateTotal + 1
	end
	local runevent = math.ceil(8/RotateTotal)
	local index = 0
	for k,v in pairs(self.mBuffRotateList) do
		if index == 0 then
			v[1]:setAnimation(0,"start",true)
			v[1]:setVisible(true)
			v[2] = 1
			v[4]:setLocalZOrder(1)
		else
			v[1]:playAnimaFromAnyFrame("start",runevent*index*8,true)
			v[1]:setVisible(true)
			v[2] = 1
			if runevent*index*8 >= 16 and runevent*index*8 < 48 then
				v[4]:setLocalZOrder(-1)
			else
				v[4]:setLocalZOrder(1)
			end
		end
		index = index + 1
	end
end



-- 净化现有debuff
function BuffController:disperseDebuff(_type, _list)
	if _type == 1 then
	   for i=1,#self.mCurBuffList do
	   	   local _buff = self.mCurBuffList[i]
	   	   if isValueInTable(_buff.mEffMethod, _list) then
	   	   	  _buff:Destroy()
	   	   	  table.remove(self.mCurBuffList, i)
	   	   end
	   end
	elseif _type == 2 then
	   for i=1,#self.mCurBuffList do
	   	   local _buff = self.mCurBuffList[i]
	   	   if isValueInTable(_buff.mStateID, _list) then
	   	   	  _buff:Destroy()
	   	   	  table.remove(self.mCurBuffList, i)
	   	   end
	   end
	end
end