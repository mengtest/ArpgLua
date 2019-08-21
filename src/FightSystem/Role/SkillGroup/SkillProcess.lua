-- Name: SkillProcess
-- Func: 技能对象
-- Author: Johny

require "FightSystem/Role/SkillGroup/SkillProcessMove"


SkillProcess = class("SkillProcess")

function SkillProcess:ctor(_proNum, _proID, _skill, _role)
	self.mProNum = _proNum
	self.mRole = _role
	self.mRoleManager = FightSystem.mRoleManager
	self.mSkillCon = self.mRole.mSkillCon
	self.mSkill = _skill
	self.mSkillID = self.mSkill.mSkillID
	self.mProID = _proID
	self.mDB = DB_SkillProcess.getDataById(_proID)
	GG_CheckNil(self.mDB, string.format("No process DB, skillID: %d, proID: %d", _skill.mSkillID, _proID))
	self.mType = self.mDB.Type
	self.mProcessDisplayID = self.mDB.ProcessDisplayID
	self.mSummonNPCID = self.mDB.SummonNPCID
	self.mSummonPos = self.mDB.SummonPos
	self.mSummonLastTime = self.mDB.SummonLastTime
	self.mTurnFace = self.mDB.ProcessTrunAround
	self.mSummonSceneAniID = self.mDB.SummonSceneAniID

	self.mSummonSceneAniPos = self.mDB.SummonSceneAniPos

	self.mDamageType = self.mDB.DamageType

	self.mGetMp = self.mDB.GetMp

	self.mGripTag = self.mDB.GripTag

	self.mGripDirection = self.mDB.GripDirection

	self.mGripTurnTime = self.mDB.GripTurnTime

	self.mInjuredStiff = self.mDB.InjuredStiff

	self.mInjuredShake = self.mDB.InjuredShake

	self.mInjuredType = self.mDB.TargetInjuredAct


	-- 获取受游戏速度影响的过程段时间
	local _during = self.mDB.LastTime / FightSystem:getGameSpeedScale()
	-- 获取时间判断是否为组合技
	if self.mRole.mRoleData.mGSID1 == _skill.mSkillID or self.mRole.mRoleData.mGSID2 == _skill.mSkillID then
		self.mDuring = _during
		self.mTimeScale = 1
	else
		self.mDuring = _during / self.mRole.mPropertyCon.mAttRatePer
		self.mDuring = math.ceil(self.mDuring * self.mDB.ModifySpeed)
		self.mTimeScale = self.mRole.mPropertyCon.mAttRatePer* self.mDB.ModifySpeed    -- 过程段时间比例
	end
	-- 技能移动控制器初始化
	self.mFirstTick = false
    self.mMoveHandler = nil
    if self.mDB.MinMoveDistance ~= 0 then
    	self.mMoveHandler = SkillProcessMove.new(_role, self.mDB, self.mDuring)
    end

    
    -- MaxCycleTime 
    self.mMaxCycleTime = self.mDB.MaxCycleTime

    self.IsNoneGripPro = nil

end

function SkillProcess:Tick(delta)
	if self.mMoveHandler then
		self.mMoveHandler:Tick()	
	end
	
	-- if not self.mFirstTick then
	-- 	self.mFirstTick = true
	-- 	self:HandleFirstTick()
	-- end




	--
	--self.mDuring = self.mDuring -1
	-- if self.mDuring == 0 then
	-- 	self.mSkill:OnProcessFinish(self)
	-- end
	--
end

function SkillProcess:Finish()
	if self.mRole and self.IsGhost then
		self.IsGhost = nil
		self.mRole.mArmature:stopActionByTag(300)
	end
end

-- 执行第一帧该做的
function SkillProcess:HandleFirstTick(_isloopskill)
	local function xxx()
		if self.mTurnFace  == 1 then
			self.mRole:TurnReverse()
		end
		if self.mType == 1 then
		   self:HandleType1()
		elseif self.mType == 2 then
		   self:HandleType2()
		elseif self.mType == 3 then
		   self.mMaxCycleTime = self.mMaxCycleTime -1
		   self:HandleType3(_isloopskill)
		elseif self.mType == 31 then
			self.mRole.mGunCon:decreaseUseCount(1,true)
			self:HandleType3(_isloopskill)
		elseif self.mType == 4 then
			self:HandleType4()
		end
	end
	caculateFuncDuring("SkillProcess:HandleFirstTick", xxx)
end

-- type: 1
function SkillProcess:HandleType1()
	self:CheckMp()
	self:HandleDisplay(self.mProcessDisplayID)
	self:HandleSubObject()
	self:HandleSelfState()
	self:HandleSummon()
	self:HandleSummonSceneAni()
	self:HandleGrip()
end

-- 召唤
function SkillProcess:HandleSummon()
	if self.mSummonNPCID == 0 then return end
	self.mRole.mSummonCon:addSummon(self.mSummonNPCID, self.mSummonPos, self.mSummonLastTime)
end

-- 召唤场景动画
function SkillProcess:HandleSummonSceneAni()
	if self.mSummonSceneAniID == 0 then return end
	local pos = cc.p(self.mSummonSceneAniPos[1],self.mSummonSceneAniPos[2])
	if self.mRole.IsFaceLeft then
		pos.x = -pos.x
	end
	local _pos = cc.p(self.mRole:getPositionX() + pos.x, self.mRole:getPositionY() + pos.y)
	local goalposx = _pos.x
	local goalposy = _pos.y
	if FightSystem:getMapInfo(cc.p(goalposx,goalposy),self.mRole.mSceneIndex) ~= 1 then
		for i=goalposy-10,0,-10 do
			if FightSystem:getMapInfo(cc.p(goalposx,i),self.mRole.mSceneIndex) == 1 then
				goalposy = i
				break
			end	
		end
	end
	_pos.y = goalposy
	local TiledLayer = FightSystem.mSceneManager:GetTiledLayer(self.mRole.mSceneIndex)
	FightSystem.mRoleManager:LoadSceneAnimation(self.mSummonSceneAniID, _pos,nil,TiledLayer)
end

-- type: 2
function SkillProcess:HandleType2()
	self:HandleDisplay(self.mProcessDisplayID)
	self:HandleSubObject()
	self:HandleGrip()
	self:HandleSummon()
	self:HandleSummonSceneAni()
	if self.mSkill.mSkillType == 1 then
	   --caculateFuncDuring("SkillProcess:HandleType2--HandleRangeVictims", handler(self,self.HandleRangeVictims))
	   self:HandleRangeVictims()
	   self:HandleRangeSubs()
	   self:FindSceneAni()
	elseif self.mSkill.mSkillType == 2 then
		self:HandleBless()
	end
	self:HandleSelfState()
end

-- type: 3
function SkillProcess:HandleType3(_isloopskill)
	self:HandleDisplay(self.mProcessDisplayID,_isloopskill)
	self:HandleSubObject()
	self:HandleGrip()
	self:HandleSummon()
	self:HandleSummonSceneAni()
	if self.mSkill.mSkillType == 1 then
	   self:HandleRangeVictims()
	   self:HandleRangeSubs()
	   self:FindSceneAni()
	elseif self.mSkill.mSkillType == 2 then
		   self:HandleBless()
	end
	self:HandleSelfState()
end

-- type: 4
function SkillProcess:HandleType4()
	local con = FightSystem.mFightType == "olpvp"
	self:HandleDisplay(self.mProcessDisplayID,nil,con)
	self:HandleSubObject()
	self:HandleGrip()
	self:HandleSummon()
	self:HandleSummonSceneAni()
	if self.mSkill.mSkillType == 1 then
	   self:HandleRangeVictims()
	   self:HandleRangeSubs()
	   self:FindSceneAni()
	elseif self.mSkill.mSkillType == 2 then
		self:HandleBless()
	end
	self:HandleSelfState()
	if not con then
		self.mSkillCon:BeginDzShow()
	end
end

function SkillProcess:IsloopSkill()
	if self.mType == 3 then
		if FightSystem.mTouchPad.mIsAttackBtnDown then
			if self.mMaxCycleTime <= 0 then
				return false
			else
				return true
			end
		end
	elseif self.mType == 31 then
		if FightSystem.mTouchPad.mIsAttackBtnDown and FightSystem.mRoleManager.mFriendBulletCount and FightSystem.mRoleManager.mFriendBulletCount > 0 then
			return true
		end
	end
	return false
end



function SkillProcess:HandleBless()
	local list = self:FindFriend()
	table.insert(list, self.mRole)
	for k,_friend in pairs(list) do
		local skilllevel = self.mRole.mRoleData:SkillLevelById(self.mSkillID)
		CommonSkill.attachState(_friend, self.mDB, self.mRole ,skilllevel,self.mSkillID,0)
	end
end

-- 处理自身状态
function SkillProcess:HandleSelfState()
	local skilllevel = self.mRole.mRoleData:SkillLevelById(self.mSkillID)
	CommonSkill.attachSelfState(self.mRole, self.mDB,skilllevel, self.mSkillID,0)
end

function SkillProcess:FindVictim()
	local list = {}
	local _victimCount = self.mRoleManager:GetVicmCount(self.mRole)
	for i = 1, _victimCount do
		local _victim = self.mRoleManager:GetVicim(i, self.mRole , self.mDB)
		if _victim and self.mSkillCon:IsInSkillRange("role" ,self.mDB, _victim) then
			table.insert(list, _victim)
		end
	end

	--cclog("SkillProcess:FindVictim====== " .. #list)

	return list
end

function SkillProcess:FindFriend()
	local list = {}
	local _count = self.mRoleManager:GetFriendCount(self.mRole)
	for i = 1, _count do
		local _friend = self.mRoleManager:GetFriend(i, self.mRole)
		if _friend and self.mSkillCon:IsInSkillRange("role" ,self.mDB, _friend) then
			table.insert(list, _friend)
		end
	end

	return list
end

function SkillProcess:FindSceneAni()
	local _damge = CommonSkill.getDamageCount_SceneAni(self.mRole.mPropertyCon, self.mDB)
	local _sceneAniList = self.mRoleManager.mSceneAniList
	for i = 1, #_sceneAniList do
		local _ani = _sceneAniList[i]
		if _ani and _ani:canbeDamaged(self.mRole) and self.mSkillCon:IsInSkillRange("sceneAni", self.mDB, _ani) then
		   _ani:OnDamaged(_damge, self.mRole)
		   CommonSkill.hitSceneVictimDisplay(_ani, self.mProcessDisplayID, self.mRole)
		end
	end
end


function SkillProcess:CheckMp()
	local function xxx6()
		if self.mGetMp ~= 0 and (self.mRole.mGroup == "friend" or self.mRole.mGroup == "enemyplayer") then
			self.mRole.mSkillCon:AddMp(self.mGetMp + self.mRole.mRoleData:AddEnergyWeapSkillById(self.mSkillID))
		end
		if self.mGetMp ~= 0 and (FightSystem:GetModelByType(4) and self.mRole.mGroup == "monster" ) then
			self.mRole.mSkillCon:AddMp(self.mGetMp)
		end
	end
	xxx6()
end

-- 处理攻击方，处理区域受击者(总入口点)
function SkillProcess:HandleRangeVictims()
	local _hasVictim = false
	if self.mDamageType == 4 then 
		local function handleVictims()
			for k,v in pairs(self.mSkillCon.mGripCon.mVictims) do
				if not v.mFSM:IsDeading() and v.mBeatCon then
					self:HandleOneVictim(v)
					_hasVictim = true
				end
			end
		end
		handleVictims()
	else
		local function handleVictims()
			local list = self:FindVictim()
			self.mSkill.mFinalVictimCount = #list
			for k,_victim in pairs(list) do
				self:HandleOneVictim(_victim)
				_hasVictim = true
			end
		end
		handleVictims()
		--caculateFuncDuring("SkillProcess:HandleRangeVictims--handleVictims", handleVictims, true)
	end
	---- 至少有一个人受击，播一次受击声音
	local function beatSound()
		if self.mProcessDisplayID <= 0 then return end
		local _actionDB = DB_SkillDisplay.getDataById(self.mProcessDisplayID)
		local _HitSoundEffect = _actionDB.HitSoundEffect
		if _HitSoundEffect > 0 then
			CommonAnimation.PlayEffectId(_HitSoundEffect)
		end
	end
	if _hasVictim then
		-- local function xxx6()
		-- 	if self.mGetMp ~= 0 and (self.mRole.mGroup == "friend" or self.mRole.mGroup == "enemyplayer") then
		-- 		self.mRole.mSkillCon:AddMp(self.mGetMp)
		-- 	end
		-- 	if self.mGetMp ~= 0 and (FightSystem:GetModelByType(4) and self.mRole.mGroup == "monster" ) then
		-- 		self.mRole.mSkillCon:AddMp(self.mGetMp)
		-- 	end
		-- end
		-- 去掉有伤害加MP
		--xxx6()
	   caculateFuncDuring("SkillProcess:HandleRangeVictims--beatSound", beatSound)
	end
end

-- 过程段处理子物体被打
function SkillProcess:HandleRangeSubs()
	local list = {}
	local _victimCount = self.mRoleManager:GetVicmCount(self.mRole)
	for i = 1, _victimCount do
		local _victim = self.mRoleManager:GetVicimNoInVincible(i, self.mRole , self.mDB)

		if _victim then
			for k,v in pairs(_victim.mSkillCon.mSubObjectList) do
				if v.mCanBeAttack == 1 and v.isCheck then
					if self.mSkillCon:IsInSkillRange("pos" ,self.mDB, v:getPosition_pos()) then
						v:FinishSelf()
					end
				end
			end
		end	
	end
end


-- 处理抓投
function SkillProcess:HandleGrip()

	local _grip = self.mGripTag
	if _grip == 0 then return false end
	--
	if _grip == 1 then
	   if not self.mSkillCon.mGripCon:GripVictims(self.mDB) then
	   	self.IsNoneGripPro = true
	   return false end
	   self.mSkillCon.mGripCon:HandleGripedVictims(self.mGripDirection,self.mRole)
	elseif _grip == 11 then
	   	if self.mSkillCon.mGripCon:GripVictims(self.mDB) then
	       self.mSkillCon.mGripCon:HandleGripedVictims(self.mGripDirection,self.mRole)
	    end
	elseif _grip == 12 then
		if self.mSkillCon.mGripCon:GripVictimsAir(self.mDB) then
	       self.mSkillCon.mGripCon:HandleGripedVictimsAir(self.mGripDirection,self.mRole)
	    end
	elseif _grip == 2 then
		self.mSkillCon.mGripCon:HandleGripedVictims(self.mGripDirection,self.mRole)
		self.mSkillCon.mGripCon:HandleChangeGripTargetAct(self.mDB)
	elseif _grip == 3 then
		self.mSkillCon.mGripCon:ReleaseVictims(self.mDB)
	end

	return true
end

-- 处理一个受击者
function SkillProcess:HandleOneVictim(_victim)
	-- 处理伤害
	if not _victim.mBeatCon then return end
	local function xxx1()
		-- 加状态
		local skilllevel = self.mRole.mRoleData:SkillLevelById(self.mSkillID)
		CommonSkill.attachState(_victim, self.mDB, self.mRole ,skilllevel,self.mSkillID,0)
	end
	local function xxx2()
		-- 处理硬直
		if self.mInjuredStiff ~= 0 and _victim then
	   	   _victim.mBeatCon:BeatStiff(self.mInjuredStiff,self.mInjuredShake,self.mInjuredType,self.mRole) 
	   	end
	end
	
	local function xxx3()
		-- 处理受击显示
		CommonSkill.hitVictimDisplay(_victim, self.mProcessDisplayID, self.mRole)
	end
	caculateFuncDuring("SkillProcess:HandleOneVictim1", xxx1)
	caculateFuncDuring("SkillProcess:HandleOneVictim2", xxx2)
	caculateFuncDuring("SkillProcess:HandleOneVictim3", xxx3)

	local function xxx0()
		return self:HandleDamage(_victim)
	end
	local _hasDamager = caculateFuncDuring("SkillProcess:HandleOneVictim0", xxx0)
	--if not _hasDamager then return end

end

-- 不需要受击者的显示
function SkillProcess:HandleDisplay(_actionID,IsloopSkill,isolpvp)
	local function addCastAni(_root, _pos, _resID, _aniName)
		local _spine = CommonAnimation.playOnceSpineAni(_resID, _aniName, 1,nil,nil,_root)
		_spine:setPosition(_pos)
		_spine:setLocalZOrder(1000)
	end
	if _actionID <=0 then return end
	local _actionDB = DB_SkillDisplay.getDataById(_actionID)
	local _FullScreenStatic = _actionDB.FullScreenStatic
	local _ScreenShake = _actionDB.ScreenShake
	local _Path = _actionDB.Path
	local _EffectPath = _actionDB.EffectPath
	local _GroundGfxPath = _actionDB.GroundGfxPath
	local _GroundGfxFile = _actionDB.GroundGfxFile
	local _LightEffectPath = _actionDB.LightEffectPath
	local _ExtraGfxPath = _actionDB.ExtraGfxPath
	local _ExtraGfxFile = _actionDB.ExtraGfxFile
	local _PhantomEffect = _actionDB.PhantomEffect -- 残影


	local IscurView = true
	if self.mRole.mSceneIndex ~= 0 and self.mRole.mSceneIndex ~= FightSystem.mSceneManager.mArenaViewIndex then
		IscurView = false
	end
	-- 检查全屏静止
	local function fullscreen()
		-- 展示大招动画
		local function showCastAnimation()
			if _actionDB.CastAnimation[1] > 0 then
			   local _screenMiddle = getGoldFightPosition_Middle()
			   local _x = _screenMiddle.x
			   local _y = _screenMiddle.y
			   local _root = FightSystem.mTouchPad
			   addCastAni(_root, cc.p(_x + _actionDB.CastAnimation1Offset[1], _y + _actionDB.CastAnimation1Offset[2]), _actionDB.CastAnimation[1], "start")
			   addCastAni(_root, cc.p(_x + _actionDB.CastTextOffset[1], _y + _actionDB.CastTextOffset[2]), _actionDB.CastTextAnimation, "start")
			   addCastAni(_root, cc.p(_x + _actionDB.CastAnimation1Offset[1], _y + _actionDB.CastAnimation1Offset[2]), _actionDB.CastAnimation[2], "start")
			end
		end
		-- 检查静止帧
		if not isolpvp then
			if _FullScreenStatic[1] > 0 then
				local _during = math.ceil(_FullScreenStatic[1] / self.mTimeScale)
				local _blackLayer = CommonSkill.fullscreenStatic(self.mRole, _during ,showCastAnimation,_FullScreenStatic[2])
				--showCastAnimation()
			end
		end
	end
	-- 震动
	local function ScreenShake()
		if _ScreenShake[4] == 1 then
			local amplitude = _ScreenShake[2]
			if self.mRole.IsFaceLeft then
				amplitude = - amplitude
			end
			if _ScreenShake[1] == 1 then
				shakeNode(FightSystem.mSceneManager:GetSceneView(self.mRole.mSceneIndex),_ScreenShake[2],_ScreenShake[3],_ScreenShake[5])
			elseif _ScreenShake[1] == 2 then
				shakeNodeType1(FightSystem.mSceneManager:GetSceneView(self.mRole.mSceneIndex),_ScreenShake[2],_ScreenShake[3],_ScreenShake[5])
			elseif  _ScreenShake[1] == 3 then
				shakeNodeType2(FightSystem.mSceneManager:GetSceneView(self.mRole.mSceneIndex),amplitude,_ScreenShake[3],_ScreenShake[5])
			end
		end
	end
	-- 声音
	local function soundEffect()
		for k,_soundID in pairs(_actionDB.SoundEffect) do
			if _soundID > 0 then
				--doError(string.format("ProID=%d----Id=%d--list=%d--_soundID=%d",self.mProID,_actionDB.ID,#_actionDB.SoundEffect,_soundID))
				CommonAnimation.PlayEffectId(_soundID)
			end
		end
	end
	local function Display()
   		--播放动作
		if _Path ~= "" then
			self.mRole.mArmature:ActionNowWithSpeedScale(_Path, self.mTimeScale)
		else
			local timeScale = self.mTimeScale/self.mRole.mArmature:getWithSpeedScale()
			self.mRole.mArmature.mSpine:setTimeScale(timeScale)
		end

		if _EffectPath ~= "" then
			self.mRole.mArmature:ActionNowEffectSpeedScale(_EffectPath, self.mTimeScale)
		else
			if self.mRole.mArmature.mSpineSkillEffect then
				local timeScale = self.mTimeScale/self.mRole.mArmature:getWithSpeedScale()
				self.mRole.mArmature.mSpineSkillEffect:setTimeScale(timeScale)
			end
		end

		if _GroundGfxPath ~= "" then
			local _root = self.mRole.mArmature:getParent()
			local GroupSpine = CommonAnimation.createCacheSpine_commonByResID(_GroundGfxFile,_root)
			if self.mSkill.mGroupSpine then
				SpineDataCacheManager:collectFightSpineByAtlas(self.mSkill.mGroupSpine)
				self.mSkill.mGroupSpine = nil
			end
			self.mSkill.mGroupSpine = GroupSpine
			self.mSkill.mGroupSpine:setLocalZOrder(0)
			self.mSkill.mGroupSpine:setPosition(self.mRole.mShadow:getPosition_pos())
			self.mSkill.mGroupSpine:setAnimationWithSpeedScale(0, _GroundGfxPath, false, self.mRole.mPropertyCon.mAttRatePer)
			self.mSkill.mGroupSpine:registerSpineEventHandler(handler(self.mSkill, self.mSkill.onAnimationEventGroupEffect), 1)
			if self.mRole.mRoleData.mModelScale then
				if self.mRole.IsFaceLeft then
					self.mSkill.mGroupSpine:setScale(-self.mRole.mRoleData.mModelScale)
				else
					self.mSkill.mGroupSpine:setScale(-self.mRole.mRoleData.mModelScale)
				end
				self.mSkill.mGroupSpineScale = self.mRole.mRoleData.mModelScale
			end
		end

		--播放相关挂点
		if _ExtraGfxPath ~= "" and not IsloopSkill then
			local isloop = (self.mType == 3 or self.mType == 31)
			self.mRole.mArmature:setHangEffect(_ExtraGfxFile,_ExtraGfxPath,self.mTimeScale,isloop)
		end

		-- 自身特效
		if _victim and _LightEffectPath ~= 0 then
		   local _boneName = _actionDB.LightEffectBone
		   self:PinEffectOnBone(_LightEffectPath, _boneName, self.mRole.mArmature.mSpine)
		end

		-- 残影
		local _ghostInterval = _PhantomEffect[1] / 30
		local _ghostDuring = _PhantomEffect[2] / 30
		if _ghostInterval > 0 and _ghostDuring > 0 then
			cclog("generateGhost=======johny")
			local function generateGhost()
				local _role = self.mRole
				if _role == nil then
				   self:Finish()
				return end
				local _armature = _role.mArmature
				local _ghost = SpineGhost.new()
				_ghost:generate(_armature.mSpine, _ghostDuring)
				local _parentNode = _armature:getParent()
				_parentNode:addChild(_ghost)
				_ghost:setPosition(_armature:getPosition())
				if _role.IsFaceLeft then
				   _ghost:setFlippedX(true)
				end
			end
			local act0 = cc.DelayTime:create(_ghostInterval)
			local act1 = cc.CallFunc:create(generateGhost)
			local act2 = cc.Sequence:create(act0,act1)
			local forever = cc.RepeatForever:create(act2)
			forever:setTag(300)
			self.mRole.mArmature:runAction(forever)
			self.IsGhost = true
		end
   	end
	if IscurView then
		fullscreen()
		ScreenShake()
		soundEffect()
	end
	caculateFuncDuring("SkillProcess:HandleDisplay:Display", Display)
end

-- 给骨骼挂特效
function SkillProcess:PinEffectOnBone(_pathID, _boneName, _spine)
	CommonSkill.pinEffectOnBone(_pathID, _boneName, _spine, self.mRole)
end

-- 处理伤害
function SkillProcess:HandleDamage(_victim)

	local _damge = nil
	local _damgeTP = nil
	if FightSystem.mFightType == "olpvp" then
		_damge = 0
		if self.mRole.mGroup ~= "friend" then return end
		local con = nil
		if globaldata.olpvpType == 0 or globaldata.olpvpType == 3 then
			con = true
		else
			local index = globaldata:convertOlindex(globaldata.olHoldindex)
			if index == self.mRole.mPosIndex then
				con = true
			end
		end
		if con then
			local num = 0
			if globaldata.olHoldindex%2 == 0 then
				num = 1
			end
			local enemyindex = _victim.mPosIndex*2 - num
			local PerHurt = 1
			PerHurt = PerHurt + self.mRole.mRoleData:PerHurtWeapSkillById(self.mSkillID)
			FightSystem:GetFightManager():SendDamgeProcess(self.mSkillID,0,self.mProID,1,enemyindex,PerHurt)
		end
	else
		local function xxx1()
			return CommonSkill.getDamageCount(self.mRole.mPropertyCon, self.mDB, _victim.mPropertyCon,self.mSkillID)
		end
		_damge,_damgeTP = caculateFuncDuring("SkillProcess:HandleDamage1", xxx1)
	end
	if not _victim.mBeatCon then return end
	if _victim.mBeatCon:checkBlocked(self.mRole) then
		--[[ --注掉涨MP
		if _victim.mGroup == "friend" or _victim.mGroup == "enemyplayer" then
			_victim.mSkillCon:AddMp(2)
		end
		]]
		_damge = _damge*0.05
	end
	_damge = math.ceil(_damge)
	local function xxx2()
		_victim.mBeatCon:Beated(self.mRole, _damge, _damgeTP, self.mProID)
		_victim.mBeatCon:BeatFlash()
	end
	caculateFuncDuring("SkillProcess:HandleDamage2", xxx2)
	return true
end

-- 处理子物体
function SkillProcess:HandleSubObject()
	for i = 1,8 do
	    local subID = self.mDB[SubObjectID_Table[i]]
	    if subID > 0 then
	       self.mSkillCon:AddSubObject(subID, self.mSkill.mSkillID,self.mDB)
	    end
	end
end
