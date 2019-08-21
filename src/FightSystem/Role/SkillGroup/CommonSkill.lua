-- Name: 	CommonSkill
-- Author:	Johny

module("CommonSkill", package.seeall)

-- 给一个受击者附加技能状态
function attachState(_victim, _dbProc, _releaser, _level, _skillId , _processType)
	for i = 1, 4 do
		local keyState = TargetStateID_Table[i]
		local _stateID = _dbProc[keyState]
		if _stateID and _stateID > 0  then
			local _dbState = DB_SkillState.getDataById(_stateID)
			_victim.mBeatCon:BeatStateChange(_dbProc, _dbState, _releaser ,_level, _skillId , _processType)
		else
			break
		end
	end
end

function attachSelfState(_role, _dbProc, _level, _skillId, _processType)
	local _str1 = "SelfStateID"
	for i = 1, 4 do
		local keyState = SelfStateID_Table[i]
		local _stateID = _dbProc[keyState]
		if _stateID and _stateID > 0  then
			local _dbState = DB_SkillState.getDataById(_stateID)
			_role.mBeatCon:BeatStateChange(_dbProc, _dbState, _role ,_level, _skillId , _processType)
		else
			break
		end
	end
end

-- 获取技能伤害
function getDamageCount(_hiterPropCon, _dbProc, _VictimPropCon, _skillid)
	
	local function flowDamageStatus(_stringID, _holder, _hiter)
		  _holder.mFlowLabelCon:flowDamageStatus(_stringID, _hiter)
	end
	local _damageRatio = math.random(_dbProc.PhysicalDamageRatioMin, _dbProc.PhysicalDamageRatioMax) / 100
	local _damage = 1
	if not _skillid then
		_damage = (_damageRatio+_dbProc.PhysicalDamagePoint*1/10000) * _hiterPropCon.mHarm 
	elseif _hiterPropCon.mRole.mGroup == "friend" then
		local skilllevel = _hiterPropCon.mRole.mRoleData:SkillLevelById(_skillid)
		_damage = (_damageRatio+_dbProc.PhysicalDamagePoint*skilllevel/10000) * _hiterPropCon.mHarm
	elseif _hiterPropCon.mRole.mGroup == "enemyplayer" then
		local skilllevel = _hiterPropCon.mRole.mRoleData:SkillLevelById(_skillid)
		_damage = (_damageRatio+_dbProc.PhysicalDamagePoint*skilllevel/10000) * _hiterPropCon.mHarm
	else
		_damage = (_damageRatio+_dbProc.PhysicalDamagePoint*1/10000) * _hiterPropCon.mHarm 
	end
	-- 检测闪避
	local _hit = _hiterPropCon.mHit
	local _dodge = _VictimPropCon.mDodge
	-- 检测暴击
	local _damgeTP = "normal"
    local _critValue = 1
    local _crit = _hiterPropCon.mCrit
    local _Tough = _VictimPropCon.mTough
    local _critX = math.abs(_crit - _Tough)
    if _crit > _Tough then
       local _random = math.random(1, _critX + 1000)
       if _random <= _critX then
       	  -- 暴击成功
       	  _critValue = 2 + _hiterPropCon.mRole.mRoleData.WeaponCrit
       	 -- flowDamageStatus(392, _hiterPropCon.mRole, _hiterPropCon.mRole)
       	  _damgeTP = "crit"
       end

    end
    -- 计算伤害系数
    local _damgeRate = 1
    local _expose = _hiterPropCon.mExpose
    local _armor = _VictimPropCon.mArmor
    local _exposeX = math.abs(_expose - _armor)
    if _expose > _armor then
       _damgeRate = 1+_exposeX / (2*_exposeX + 1000)
    elseif _expose < _armor then
       _damgeRate = 1-_exposeX / (2*_exposeX + 1000)
    end
    -- 计算伤害结果

    _damage = _damage * _critValue * _damgeRate
    

    --cclog("伤害结果结算：  _damage: " .. _damage .. "==_critValue:  " .. _critValue .. "==_damgeRate: " .. _damgeRate)
    getReverseDamageByVic(_hiterPropCon,_VictimPropCon)
    local wSkillPer = 1
    if _hiterPropCon.mRole.mGroup == "friend" or _hiterPropCon.mRole.mGroup == "enemyplayer" then
		wSkillPer = wSkillPer + _hiterPropCon.mRole.mRoleData:PerHurtWeapSkillById(_skillid)
	end 
    local coefficient = RestraintGroup(_hiterPropCon.mGroup_Advance,_VictimPropCon.mMasters)
    return _VictimPropCon.mBuffHurtCoefficient*_damage*coefficient*wSkillPer, _damgeTP
end

-- 反伤对攻击者伤害
function getReverseDamageByVic(_hiterPropCon, _victimPropCon)
	if _victimPropCon.mBuffReverseHurt ~= 0 then
		_hiterPropCon.mRole.mBeatCon:Beated_debuff(_victimPropCon.mRole, _victimPropCon.mBuffReverseHurt)
	end
end

-- 获得对场景道具的伤害
function getDamageCount_SceneAni(_hiterPropCon, _dbProc)
	local _damageRatio = math.random(_dbProc.PhysicalDamageRatioMin, _dbProc.PhysicalDamageRatioMax) / 100
	local _damage = _damageRatio * _hiterPropCon.mPhyAtt +_dbProc.PhysicalDamagePoint

	return _damage
end

-- 击中显示部分
function hitVictimDisplay(_victim, _actionID, _hiter)
	if _actionID <=0 then return end
	local _actionDB = DB_SkillDisplay.getDataById(_actionID)
	local _HitEffect = _actionDB.HitEffect
	local _StaticFrameTime = _actionDB.StaticFrameTime
	local _TargetStaticFrameTime = _actionDB.TargetStaticFrameTime
	local function xxx2()
		-- 受击特效
		if _victim and type(_HitEffect) == "table" then
			local face = nil
			if _hiter:getPosition_pos().x > _victim:getPosition_pos().x then
				if _victim.IsFaceLeft then
					face = true		
				end
			else
				if not _victim.IsFaceLeft then
					face = true		
				end
			end
			if _HitEffect[3] == 0 then
				pinEffectOnBone(_HitEffect, _actionDB.HitEffectBone, _victim.mArmature.mSpine, _hiter,face)
			elseif _victim.mFSM:IsBeGriped() then
				pinEffectOnBone(_HitEffect, _actionDB.HitEffectBone, _victim.mArmature.mSpine, _hiter,face)
			end

		end
	end
	local function xxx3()
		-- 检查静止帧
		if _StaticFrameTime > 0 then
			_hiter:enableStaticFrame(_StaticFrameTime)
			 local _partner = _hiter.mSkillCon:getGroupSkillPartner()
			 if _partner then
			 	 _partner:enableStaticFrame(_StaticFrameTime)
			 end
		end
		if _TargetStaticFrameTime > 0 then
			_victim:enableStaticFrame(_TargetStaticFrameTime,2)
		end
	end
	caculateFuncDuring("hitVictimDisplay2", xxx2)
	caculateFuncDuring("hitVictimDisplay3", xxx3)
end

-- 场景道具击中显示部分
function hitSceneVictimDisplay(_victim, _actionID, _hiter)
	if _actionID <=0 then return end
	local _actionDB = DB_SkillDisplay.getDataById(_actionID)

	-- 受击声音
	if _actionDB.HitSoundEffect > 0 then
		CommonAnimation.PlayEffectId(_actionDB.HitSoundEffect)
	end

	-- 受击特效
	if _victim and type(_actionDB.HitEffect) == "table" then
		local face = nil
		if _hiter:getPosition_pos().x > _victim:getPosition_pos().x then
			if _victim.mIsFaceLeft then
				face = true		
			end
		else
			if not _victim.mIsFaceLeft then
				face = true		
			end
		end
	   pinEffectOnBone(_actionDB.HitEffect, _actionDB.HitEffectBone, _victim.mSpine, _hiter,face)
	end

end

-- 骨骼挂特效
function pinEffectOnBone(_pathID, _boneName, _spine, _hiter,_face)
	local _bonePos = _spine:getBonePosition(_boneName)
	local anim = _hiter.mEffectCon:GetEffectByResID(_pathID,_spine)
	anim:setPosition(_bonePos)
	if _face then
		anim:setScaleX(-1)
	end
end

-- 显示判定框
function showDebugRange_Rect(_rectMe, _root, _tag)
	local _pos1 = cc.p(_rectMe.x, _rectMe.y)
	local _debug = quickCreate9ImageView("debug_rectangle.png", _rectMe.width, _rectMe.height)
	_debug:setAnchorPoint(cc.p(0, 0))
	_debug:setPosition(_pos1)
	_debug:setTag(_tag)
	_root:addChild(_debug)
end

-- 全屏静止
function fullscreenStatic(_applicant, _during ,funCastAnimation,_isblack)
   local function showAllSceneAni()
   	  FightSystem.mRoleManager:hideAllSceneAni(false)
   end
   FightSystem:ApplyStaticFrameTime(_during, _applicant)
   if _isblack == 0 then
   		return
   end

   	local function BlackScreen()
   		 FightSystem.mRoleManager:hideAllSceneAni(true)
  		 local _layer = CommonAnimation.BlackScreen(FightSystem.mSceneManager:GetTiledLayer(_applicant.mSceneIndex) , (_during-5)/30, showAllSceneAni,funCastAnimation)
   	end
	local _ac1 = cc.DelayTime:create(0.15)
	local _ac2 = cc.CallFunc:create(BlackScreen)

  	 GUISystem.Windows["FightWindow"].mRootNode:runAction(cc.Sequence:create(_ac1,_ac2))
end

-- 全屏静止为合体技
function fullscreenStaticForComSkill(_applicant, _during)
   local function showAllSceneAni()
   	  FightSystem.mRoleManager:hideAllSceneAni(false)
   end
   FightSystem:ApplyStaticFrameTime(_during, _applicant)
   FightSystem.mRoleManager:hideAllSceneAni(true)
   local _layer = CommonAnimation.BlackScreenForComSkill(FightSystem.mSceneManager:GetTiledLayer(_applicant.mSceneIndex) , _during/30, showAllSceneAni)

   return _layer
end

-- 取消全屏静止
function cancelFullscreenStatic(_blacklayer)
   local function showAllSceneAni()
   	  FightSystem.mRoleManager:hideAllSceneAni(false)
   end
	CommonAnimation.fadeOutBlackScreen(_blacklayer, showAllSceneAni)
	FightSystem:cancelStaticFrameTime()
end