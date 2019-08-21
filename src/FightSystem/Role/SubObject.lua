-- Func: 子物体
-- Author: Johny

SubObject = class("SubObject", function()
   return cc.Node:create()
end)

function SubObject:ctor(_id, _instanceID, _role, _skillID, _procDB, _pos, _isleft)
	self.mInstanceID = _instanceID
	self.mSkillID = _skillID
	self.mRole = _role
	self.mPropertyCon = {}
	self.mPropertyCon.mAttRatePer = self.mRole.mPropertyCon.mAttRatePer
	self.mHarm = self.mRole.mPropertyCon.mHarm
	self.mRoleMaxHp = self.mRole.mPropertyCon.mMaxHP
	self.mPosIndex = self.mRole.mPosIndex
	self.mGroup = self.mRole.mGroup
	self.mCurPosRoleX = self.mRole:getPositionX()
	self.mStaticFrameDuring = 0
	if _pos then
		self.mCurPosRoleY = _pos.y
	else
		self.mCurPosRoleY = self.mRole:getPositionY()
	end
	self.mRoleManager = FightSystem.mRoleManager
	self.mDB = DB_SkillSubObject.getDataById(_id)
	if self.mDB.ProcessDisplayID ~= 0 then
		self.mDBDisPlay = DB_SkillDisplay.getDataById(self.mDB.ProcessDisplayID)
	end
	self.mDBProcess = _procDB
	self.mValidType = self.mDB.ValidType
	if self.mDBDisPlay then
		self.mSoundList = self.mDBDisPlay.SoundEffect
		self.mDBStaticFrameTime = self.mDBDisPlay.StaticFrameTime
		self.mTargetStaticFrameTime = self.mDBDisPlay.TargetStaticFrameTime
	end
	self.mObjectType = self.mDB.SubObjectType  -- 子物体
	self.mType = self.mDB.SubObjectProcessType 
	self.mCanBeAttack = self.mDB.SubObjectCanBeAttack
	self.mMaxHp = self.mDB.SubObjectMaxHp
	self.mCurHp = self.mMaxHp
	self.mInjuredStiff = self.mDB.InjuredStiff
	self.mInjuredShake = self.mDB.InjuredShake
	self.mInjuredType = self.mDB.TargetInjuredAct
	self.mBuildAngle = self.mDB.BuildAngle
	self.mBuildDistance = self.mDB.BuildDistance
	self.mFlyDirection = self.mDB.FlyDirection
	self.mValidCycleConst = self.mDB.ValidCycle -- 生效周期
	self.mValidMaxTimes= self.mDB.ValidMaxTimes
	self.mValidDelayConst = self.mDB.ValidDelay
	self.mMaxLifeTime = self.mDB.MaxLifeTime
	self.mStartSpeed = self.mDB.StartSpeed
	self.mMaxDistance = self.mDB.MaxDistance
	self.mDamageRangeOffset = self.mDB.DamageRangeOffset
	self.mDamageType = self.mDB.DamageType
	self.mIsFlip = self.mDB.IsFlip
	self.mInjuredDirection = self.mDB.InjuredDirection
	self.mBuildDelay = self.mDB.BuildDelay
	--self.mLastPosx = nil

	if _isleft  then
		if _isleft == "left" then
			self:FaceLeft()
		else
			self:FaceRight()
		end
	else
		self:TurnFlag(_role.IsFaceLeft)
	end

	self.mParentSubPos = _pos
	--
	if _pos then
		self:Borned(_pos)
	else
		self:Borned(_role:getPosition_pos())
	end
	
	self:initSpine()
	self:initValidCount()
end

function SubObject:Destroy()
	self.mIsLiving = nil
	self.mRole = nil
	self.mRoleManager = nil
	self.mDB = nil
	self.mDBDisPlay = nil
	self.mSoundList = nil
	self.mType = nil
	self.mDuring = nil
	self.mValidCount = nil
	self.mValidCycle = nil
	self.mValidDelay = nil
	self.isCheck = nil
	self.mInstanceID = nil
	self.mStaticFrameDuring = 0
	SpineDataCacheManager:collectFightSpineByAtlas(self.mGroupSpine)
	self.mGroupSpine = nil
	SpineDataCacheManager:collectFightSpineByAtlas(self.mSpine)
	self.mSpine = nil
	self:removeFromParent()
end

function SubObject:Tick(delta)
	if not self.mIsLiving then return end
	if self:IsControlByStaticFrameTime() then
	   self.mStaticFrameDuring = self.mStaticFrameDuring - 1
	   if self.mStaticFrameDuring == 0 then
	   	  self:resume()
	   	  self:pauseAction(false)
	   end
	   return
	end

	self:TickZOrder()
	self:TickCheckCollide(delta)
end

-- 是否是静止影响
function SubObject:IsControlByStaticFrameTime()
	local con2 = self.mStaticFrameDuring > 0
	return con2
end

function SubObject:TickZOrder()
	local _curY = self:getPositionY()
	if not self.mIsTickStopZOrder then
		self:setLocalZOrder(1440 - _curY)
	end
	if self.mGroupSpine then
		self.mGroupSpine:setPositionX(self:getPositionX())
		self.mGroupSpine:setPositionY(self:getPositionY())
		self.mGroupSpine:setLocalZOrder(-1440-_curY)
	end
	--self:ChangeScaleByPosY(_curY)
end

function SubObject:ChangeScaleByPosY(_y)
    local _scale = self:getTiledmapScaleByPosY(_y)

	if self.mSpine then
		self.mSpine:setScale(_scale*self.mSpineScale)	
	end
	if self.mGroupSpine then
		self.mGroupSpine:setScale(_scale*self.mGroupSpineScale)
	end
end

function SubObject:getTiledmapScaleByPosY(_y)
	if self.mTiledScaleY then
		return (self.mTiledMapMiny - _y)*self.mTiledScaleY + 1
	end
	return 1
end

-- 检测碰撞对手
function SubObject:TickCheckCollide(delta)
	if not self.isCheck then return end
	if not self:CheckValidDelay(delta) then return end
	-- -- 射线碰撞
	-- if not self.mLastPosx then
	-- 	self.mLastPosx = self:getPositionX()
	-- 	self.mLastPosx1 = self.mLastPosx
	-- else
	-- 	self.mLastPosx1 = self.mLastPosx
	-- 	self.mLastPosx = self:getPositionX()
	-- end
	if self.mObjectType == 3 then
		self:TickCheckTeam()	
	else
		self:TickCheckSceneAni()
		self:TickCheckVictim()
	end

end

function SubObject:TickCheckTeam()
	if not self.isCheck then return end
	local _hited = nil
	local isvictim = nil
	local _victim = nil
	local _victimCount = FightSystem.mRoleManager:GetFriendCount(self.mRole)
	for i = 1, _victimCount do
		_victim = FightSystem.mRoleManager:GetAllFriend(i, self.mRole, true)
		if _victim and _victim.mFSM:CanBeSelected() and  self:IsVictimInRange(_victim:getShadowPos()) then
			local ishitone = self:BlessFriend(_victim)
			if not _hited and ishitone then _hited = true end
			if not self.isCheck then return end
			if not self.mIsLiving then return end
			isvictim = true
			if self.mDamageType == 1 or self.mDamageType == 2 or self.mDamageType == 3 then
				break
			end	
		end
	end
	if isvictim then
		-- 检查震屏
		if _hited and self.mValidType == 1 then
		   self:FinishSelf()
		return end
	end
end

function SubObject:TickCheckVictim()
	if not self.isCheck then return end
	local _hited = nil
	local isvictim = nil
	local _victim = nil
	local _victimCount = FightSystem.mRoleManager:GetVicmCount(self.mRole)
	for i = 1, _victimCount do
		_victim = FightSystem.mRoleManager:GetVicim(i, self.mRole, self.mDB)
		if _victim and _victim.mFSM:CanBeSelected() and  self:IsVictimInRange(_victim:getShadowPos()) then
			local ishitone = self:HitVictim(_victim)
			if not _hited and ishitone then _hited = true end
			if not self.isCheck then return end
			if not self.mIsLiving then return end
			isvictim = true
			if self.mDamageType == 1 or self.mDamageType == 2 or self.mDamageType == 3 then
				break
			end	
		end
	end
	if isvictim then
		-- 检查震屏
		self:HitCheckShake()
		if _hited and self.mValidType == 1 then
		   self:FinishSelf()
		return end
	end
end

function SubObject:TickCheckSub()
	if not self.isCheck then return end
	local _victim = nil
	local _victimCount = FightSystem.mRoleManager:GetVicmCount(self.mRole)
	for i = 1, _victimCount do
		_victim = FightSystem.mRoleManager:GetVicimNoInVincible(i, self.mRole, self.mDB)
		if _victim then
			for k,v in pairs(_victim.mSkillCon.mSubObjectList) do
				if (v.mCanBeAttack == 1 and v.isCheck)  then
					if self:IsVictimInRange(v:getPosition_pos()) then
						local _hited = self:HitSub(v)
						v:FinishSelf()
						if not self.isCheck then return end
						if not self.mIsLiving then return end
						if _hited and self.mValidType == 1 then
						    self:FinishSelf()
							return 
						end
					end	
				elseif self.mCanBeAttack == 1 then
					if self:IsVictimInRange(v:getPosition_pos()) then
						local _hited = self:HitSub(v)
						if v.mValidType == 1 then
							v:FinishSelf()
						end
						if not self.isCheck then return end
						if not self.mIsLiving then return end
						if _hited and self.mValidType == 1 then
						    self:FinishSelf()
							return 
						end
					end	
				end
			end
		end
	end
end

function SubObject:HitCheckShake()
	-- 检查震屏
	if not self.mDBDisPlay then return end
	if self.mDBDisPlay.ScreenShake[1] ~= 0 and self.mDBDisPlay.ScreenShake[4] ~= 1 then
		local amplitude = self.mDBDisPlay.ScreenShake[2]
		if self.IsFaceLeft then
			amplitude = - amplitude
		end
		if self.mDBDisPlay.ScreenShake[1] == 1 then
			shakeNode(FightSystem.mSceneManager:GetSceneView(self.mRole.mSceneIndex),self.mDBDisPlay.ScreenShake[2],self.mDBDisPlay.ScreenShake[3],self.mDBDisPlay.ScreenShake[5])
		elseif self.mDBDisPlay.ScreenShake[1] == 2 then
			shakeNodeType1(FightSystem.mSceneManager:GetSceneView(self.mRole.mSceneIndex),self.mDBDisPlay.ScreenShake[2],self.mDBDisPlay.ScreenShake[3],self.mDBDisPlay.ScreenShake[5])
		elseif  self.mDBDisPlay.ScreenShake[1] == 3 then
			shakeNodeType2(FightSystem.mSceneManager:GetSceneView(self.mRole.mSceneIndex),amplitude,self.mDBDisPlay.ScreenShake[3],self.mDBDisPlay.ScreenShake[5])
		end
	end
end

function SubObject:PlayCheckShake()
	-- 检查震屏
	if not self.mDBDisPlay then return end
	if self.mDBDisPlay.ScreenShake[1] ~= 0 and self.mDBDisPlay.ScreenShake[4] == 1 then
		local amplitude = self.mDBDisPlay.ScreenShake[2]
		if self.IsFaceLeft then
			amplitude = - amplitude
		end
		if self.mDBDisPlay.ScreenShake[1] == 1 then
			shakeNode(FightSystem.mSceneManager:GetSceneView(self.mRole.mSceneIndex),self.mDBDisPlay.ScreenShake[2],self.mDBDisPlay.ScreenShake[3],self.mDBDisPlay.ScreenShake[5])
		elseif self.mDBDisPlay.ScreenShake[1] == 2 then
			shakeNodeType1(FightSystem.mSceneManager:GetSceneView(self.mRole.mSceneIndex),self.mDBDisPlay.ScreenShake[2],self.mDBDisPlay.ScreenShake[3],self.mDBDisPlay.ScreenShake[5])
		elseif  self.mDBDisPlay.ScreenShake[1] == 3 then
			shakeNodeType2(FightSystem.mSceneManager:GetSceneView(self.mRole.mSceneIndex),amplitude,self.mDBDisPlay.ScreenShake[3],self.mDBDisPlay.ScreenShake[5])
		end
	end
end

function SubObject:TickCheckSceneAni()
	if not self.isCheck then return end
	local _sceneAniList = FightSystem.mRoleManager.mSceneAniList
	local _damage = CommonSkill.getDamageCount_SceneAni(self.mRole.mPropertyCon, self.mDB)
	for i = 1, #_sceneAniList do
		local _ani = _sceneAniList[i]
		if _ani and _ani:canbeDamaged(self.mRole) and self:IsVictimInRange(_ani:getPosition_pos()) then
		   self:HitSceneVictimDisplay(_ani)
		   _ani:OnDamaged(_damage, self.mRole)
		   self:HitCheckShake()
		   if self.mDB and self.mValidType == 1 then
			  self:FinishSelf()
		   return end
		end
	end
end

function SubObject:AddToRoot(_root)
	_root:addChild(self)
	self:AddGround(_root)
	if _root.mTiledMapMiny and _root.mTiledMapMaxy then
		self.mTiledMapMiny = _root.mTiledMapMiny
		self.mTiledMapMaxy = _root.mTiledMapMaxy
		self.mTiledScaleY = 0.1 / math.floor(self.mTiledMapMaxy - self.mTiledMapMiny)
		--self:ChangeScaleByPosY(self:getPositionY())
	end
end

--添加地面子物体
function SubObject:AddGround(_root)
	if not self.mDBDisPlay then return end
	if self.mDBDisPlay.GroundGfxPath ~= "" then
		local _resDB = DB_ResourceList.getDataById(self.mDBDisPlay.GroundGfxFile)
		self.mGroupSpine = SpineDataCacheManager:getFightSpineByatlas(_resDB.Res_path2, _resDB.Res_path1,nil,_root)
		self.mGroupSpineScale = 1
		self.mGroupSpine:setVisible(false)
	end
end

function SubObject:getPosition_pos()
	return cc.p(self:getPosition())
end

function SubObject:TurnFlag(_isleft)
	if _isleft then
		self:FaceLeft()
	else
		self:FaceRight()
	end
end

-- 面向左边
function SubObject:FaceLeft()
	if self.mIsFlip == 1 then
		self:setScaleX(-1)
	end
	self.IsFaceLeft = true
end

-- 面向右边
function SubObject:FaceRight()
	if self.mIsFlip == 1 then
		self:setScaleX(1)
	end
	self.IsFaceLeft = false
end

function SubObject:getRotation(_deg)
	if not self.IsFaceLeft then 
	   _deg = - _deg
	end

	return _deg
end

function SubObject:getMoveDeg(_deg)
	if self.IsFaceLeft then
	   if _deg >= 0 and _deg <= 180 then
	   	  _deg = 180 - _deg
	   else
	   	  _deg = - (180 + _deg)
	   end
	end

	return _deg
end

function SubObject:Borned(_centerPos)
	local _deg = self:getMoveDeg(self.mBuildAngle)
	local _nextpos = cc.p(_centerPos.x + self.mBuildDistance, _centerPos.y)
	local _pos = cc.pRotateByAngle(_nextpos, _centerPos, math.rad(_deg))
	-- 如果用枪，找到bind骨骼位置
	if self.mRole.mPickupCon.mBind and self.mRole.mPickupCon.mBind.mBindType == 3 then
		local _bindPos = self.mRole.mArmature.mSpine:getBonePosition("bind")
		if self.IsFaceLeft then
 		   _bindPos.x = - _bindPos.x
		end
		_pos.x = _bindPos.x + _pos.x
		_pos.y = _bindPos.y + _pos.y
	end
	self:setPositionX(_pos.x)
	self:setPositionY(_pos.y)

	--cclog("ROLEXXXXX===" .. _centerPos.x .. "===YYY===" .._centerPos.y)
	--cclog("ID=======" .. self.mDB.ID .. "==XXXX==" .._pos.x .. "==YYYY==" .._pos.y)
	self:Rotated()
end

-- 角度旋转
function SubObject:Rotated()
	local _deg = self:getRotation(self.mFlyDirection)
	self:setRotation(_deg)
end

function SubObject:initSpine()
	if not self.mDBDisPlay then return end
	if self.mDBDisPlay.SubObjectModel ~= 0 then
		local _resDB = DB_ResourceList.getDataById(self.mDBDisPlay.SubObjectModel)
		self.mSpine = SpineDataCacheManager:getFightSpineByatlas(_resDB.Res_path2, _resDB.Res_path1, nil, self)
		self.mSpineScale = 1
		self.mSpine:registerSpineEventHandler(handler(self, self.onAnimationEvent),0)
		self.mSpine:registerSpineEventHandler(handler(self, self.onAnimationEvent),1)
		self.mSpine:registerSpineEventHandler(handler(self, self.onAnimationEvent),2)
		self.mSpine:registerSpineEventHandler(handler(self, self.onAnimationEvent),3)

	end

end

function SubObject:onAnimationEvent(event)
	
	if event.type == 'start' then
		-- doError("start===" .. self.mInstanceID)
	elseif event.type == 'end' then
		-- doError("end===" .. self.mInstanceID)
		self:onAnimationEnd(event)
	elseif event.type == 'complete' then	
	elseif event.type == 'event' and event.eventData then
		if event.eventData.name == "offset" then
			local num = tonumber(event.eventData.intValue)
			if type(num) == "number" then
				self.mIsTickStopZOrder = true
				local _curY = self:getPositionY()
				self:setLocalZOrder(1440 - _curY + num)
			end
		elseif event.eventData.name == "sound" then
			local intEffectId = event.eventData.intValue
	    	if intEffectId and intEffectId > 0 then
	    		CommonAnimation.PlayEffectId(intEffectId)
	    	end
		end
	end
end

function SubObject:onAnimationEnd( event )
	if event.animation == "start" then
		self:startMove()
	elseif event.animation == "end" then
		self.mRole.mSkillCon:RemoveSubObject(self.mInstanceID)

	end
	
end

function SubObject:initValidCount()
	if self.mValidType == 1 then
		self.mValidCount = 1
	else
		self.mValidCount = self.mValidMaxTimes -- 攻击上线
		self.mValidCycle = self.mValidCycleConst/30 -- 
	end
	--
	if self.mValidDelayConst > 0 then
	   self.mValidDelay = self.mValidDelayConst /30
	else
	   self.mValidDelay = 0
	end
end

-- 子物体出生
function SubObject:startBorn()
	self.mIsLiving = true  -- 用于标识该对象是否活着
	self.isCheck = true
	if self.mSpine then
		self.mSpine:setAnimation(0, "start", false)
	else
		self:startMove()
	end
	self:playVoiceSound(1)
end

function SubObject:BuildDelayLive()
	if self.mBuildDelay ~= 0 then
		local DelayTime = cc.DelayTime:create(self.mBuildDelay/30)
        local fun = cc.CallFunc:create(handler(self,self.startBorn))
        self:runAction(cc.Sequence:create(DelayTime,fun))
	else
		self:startBorn()
	end
end

function SubObject:startMove()
	--播放动作
	if self.mGroupSpine then
		self.mGroupSpine:setVisible(true)
		self.mGroupSpine:setAnimation(0, self.mDBDisPlay.GroundGfxPath, true)	
	end
	if self.mSpine then
		-- doError("fly===" .. self.mInstanceID)
		if self.mDBDisPlay.Path ~= "" then
			self.mSpine:setAnimation(0, self.mDBDisPlay.Path, true)
		else
			self.mSpine:setAnimation(0, "fly", true)
		end
	end
	
	local function xx(_openALIndex)
		self.mLoopEffectOpenALIndex = _openALIndex
	end
	self:playVoiceSound(2, xx)
	--
	-- 需要移动的子物体
	self.mDuring = self.mMaxLifeTime
	local _during = 0
	if self.mStartSpeed == 0 then
		_during = 0
	else
		_during = math.ceil(self.mMaxDistance / self.mStartSpeed)
	end
	--
	local function finishMove()
		self:FinishSelf()
	end
	--
	local _deg = self:getMoveDeg(self.mFlyDirection)
	local _oldPos = self:getPosition_pos()
	local _nextX = _oldPos.x + self.mStartSpeed * _during
	local _nextY = _oldPos.y
	--
	if _deg ~= 0 then
		local _nextPos = cc.pRotateByAngle(cc.p(_nextX, _nextY), _oldPos, math.rad(_deg))
		--_nextPos.x = self:filtPosX(_nextPos.x)
		local _ac = cc.MoveTo:create(_during/30, _nextPos)
		local _ac1 = cc.DelayTime:create(self.mDuring/30)
		local _ac2 = cc.CallFunc:create(finishMove)
		local _ac4 = cc.Sequence:create(_ac1, _ac2)
		self:runAction(cc.Spawn:create(_ac,_ac4))
	else
		--_nextX = self:filtPosX(_nextX)
		local _ac = cc.MoveTo:create(_during/30, cc.p(_nextX, _nextY))
		local _ac1 = cc.DelayTime:create(self.mDuring/30)
		local _ac2 = cc.CallFunc:create(finishMove)
		local _ac4 = cc.Sequence:create(_ac1, _ac2)
		self:runAction(cc.Spawn:create(_ac,_ac4))
	end
end

function SubObject:filtPosX(_posX)
	if FightSystem.mFightType == "fuben" then
		local _minX = FightSystem.mFubenManager:GetLeftLineX()
		local _maxX = FightSystem.mFubenManager:GetRightLineX()
		if _posX < _minX then
		   _posX = _minX
		end
		if _posX > _maxX then
		   _posX = _maxX
		end
	elseif FightSystem.mFightType == "arena" then
		local _minX =  0
		local _maxX = FightSystem.mSceneManager:GetTiledLayer(self.mRole.mSceneIndex).mWidth
		if _posX < _minX then
		   _posX = _minX
		end
		if _posX > _maxX then
		   _posX = _maxX
		end
	elseif FightSystem.mFightType == "olpvp" then
		local _minX =  0
		local _maxX = FightSystem.mSceneManager:GetTiledLayer(self.mRole.mSceneIndex).mWidth
		if _posX < _minX then
		   _posX = _minX
		end
		if _posX > _maxX then
		   _posX = _maxX
		end
	end
	--
	return _posX
end

-- 结束
function SubObject:FinishSelf()
	self:stopAllActions()
	self.isCheck = false
	if self.mLoopEffectOpenALIndex then 
		CommonAnimation.StopEffectId(self.mLoopEffectOpenALIndex) 
	end
	self:playVoiceSound(3)
	if self.mGroupSpine then
		SpineDataCacheManager:collectFightSpineByAtlas(self.mGroupSpine)
		self.mGroupSpine = nil
	end
	if self.mSpine then
		self:PlayCheckShake()
		self.mSpine:setAnimation(0, "end", false)
		for i=1,4 do
			if self.mDB[ChildSubobject_Table[i]] == 0 then break end
			local subId = self.mDB[ChildSubobject_Table[i]]
			local flag = "left"
			if not self.IsFaceLeft then
				flag = "right"
			end
			self.mRole.mSkillCon:AddSubObjectBySub(subId, self.mSkillID,self.mDBProcess,cc.p(self:getPositionX(),self:getPositionY()),flag)
		end
	else
		self.mRole.mSkillCon:RemoveSubObject(self.mInstanceID)
	end
end

function SubObject:CheckValidDelay(delta)
	-- 检查生效延时
	if self.mValidDelay > 0 then
	   self.mValidDelay = self.mValidDelay - delta
	   return false
	end
	-- 检查生效周期
	if self.mValidType == 2 then
	   self.mValidCycle = self.mValidCycle - delta
	   if self.mValidCycle <= 0 then
	   	  self.mValidCycle = self.mValidCycleConst/30
	   	  self:PlayCheckShake()
	   else
	   	  return false
	   end
	end

	return true
end


function SubObject:IsVictimInRange(_posVic)
	local _ret = false
	local _offset = self.mDamageRangeOffset
	local _tp = self.mDamageType
	if _tp == 1 or _tp == 11 then
	   _ret = self:IsVictimInRange_FRect(_posVic,_offset)
	elseif _tp == 2 or _tp == 21 then
	   _ret = self:IsVictimInRange_Circle(_posVic,_offset)
	elseif _tp == 3 or _tp == 31 then
	   _ret = self:IsVictimInRange_SRect(_posVic,_offset)
	end

	return _ret
end

-- 前方
function SubObject:IsVictimInRange_FRect(_posVic,_offset)
	local _len = self.mDB.DamageLength
	local _width = self.mDB.DamageWidth
	local _x = self:getPositionX()

	local offsetx  = _offset[1]
	local offsety  = _offset[2]
	local _y = self.mCurPosRoleY - _width * 0.5
	local dawX = 0
	if self.IsFaceLeft then
	   _x = _x - _len
	   offsetx = -offsetx
	else
		dawX = -_len* 0.5
	end
	-- 画出技能范围
	self:DrawRect_SkillRange1(cc.p(dawX+offsetx, - _width * 0.5+offsety), cc.p(_len, _width))
	local _rect = cc.rect(_x+offsetx , _y+offsety, _len, _width)
	if cc.rectContainsPoint(_rect, _posVic) then
		--doError(string.format("1===XXX==".._rect.x .. "==YYY==" .. _rect.y))
		return true
	end
	return false
end

function SubObject:IsVictimInRange_Circle(_posVic,_offset)
	local _a = self.mDB.DamageLength
	local _b = self.mDB.DamageWidth
	if _a == 0 or _b == 0 then
		return false
	end

	local offX = _offset[1]
	local offY = _offset[2]

	local _orX = self:getPositionX()
	local _orY = self:getPositionY()

	local _opos = nil
	--不能用绝对值
	if self.IsFaceLeft then
		_opos = cc.p(self:getPositionX() - offX, self:getPositionY() + offY)
	else
	    _opos = cc.p(self:getPositionX() + offX, self:getPositionY() + offY) 
	end

	if _opos.x*_posVic.x  >= 0 then
		_opos.x = _posVic.x  - _opos.x
	else
		_opos.x = math.abs(_posVic.x)  + math.abs(_opos.x)
	end

	if _opos.y*_posVic.y  >= 0 then
		_opos.y = _posVic.y  - _opos.y
	else
		_opos.y = math.abs(_posVic.y)  + math.abs(_opos.y)
	end
	-- 画出技能范围
	self:DrawRect_SkillRange2(cc.p(_offset[1], _offset[2]), _a, _b)

	if MathExt.IsPosInEllipse(_opos.x, _opos.y, _a, _b) then
		--doError(string.format("2===XXX==".._opos.x .. "==YYY==" .. _opos.y))
		return true
	end

	return false
end

-- 自身周围
function SubObject:IsVictimInRange_SRect(_posVic,_offset)
	local _len = self.mDB.DamageLength
	local _width = self.mDB.DamageWidth
	local _x = self:getPositionX()
	-- if _x ~= self.mLastPosx1 then
	-- 	if _len < math.abs(self.mLastPosx1 - _x) then
	-- 		_len = math.abs(self.mLastPosx1 - _x)
	-- 	end
	-- 	if self.IsFaceLeft then
	-- 		_x = _x - _len/2
	-- 	else
	-- 		_x = self.mLastPosx1 + _len/2
	-- 	end
	-- else
	-- 	_x = _x - _len/2
	-- end
	local offsetx  = _offset[1]
	local offsety  = _offset[2]
	local _y = self.mCurPosRoleY - _width * 0.5
	local dawX = 0
	_x = _x - _len/2
	if self.IsFaceLeft then
	   offsetx = -offsetx
	else
		dawX = -_len* 0.5
	end
	-- 画出技能范围
	self:DrawRect_SkillRange1(cc.p(dawX+offsetx, - _width * 0.5+offsety), cc.p(_len, _width))

	local _rect = cc.rect(_x+offsetx , _y+offsety, _len, _width)
	if cc.rectContainsPoint(_rect, _posVic) then
		return true
	end
	return false
end

function SubObject:CheckValidCount()
	self.mValidCount = self.mValidCount - 1
	if self.mValidType == 2 and self.mValidCount == 0 then
	   self:FinishSelf()
	end
end

-- 祝福
function SubObject:BlessFriend(_victim)
	if self.mType == 1 then
		self:HandleBeatState(_victim)
		self:CheckValidCount()
		return false
	end
	self:HandleBeatState(_victim)
	--检查有效次数
	self:CheckValidCount()
	return true
end

-- 击中受害者
function SubObject:HitVictim(_victim)
	self:getSubFlagbyvictim(_victim)
	if self.mType == 1 then
		self:HandleBeatState(_victim)
		self:HandleDisplay(_victim)
		self:CheckValidCount()
		return true
	end
	
	self:HandleBeatState(_victim)
	self:HandleBeatStiff(_victim)
	self:HandleDisplay(_victim)

	self:HandleDamage(_victim)
	--检查有效次数
	self:CheckValidCount()
	return true
end

-- 击中子物体
function SubObject:HitSub(_sub)
	if self.mType == 1 then
		return false
	end
	self:CheckValidCount()
	return true
end

-- 处理受击状态
function SubObject:HandleBeatState(_victim)
	local _str1 = "TargetStateID"
	for i = 1, 4 do
		local key = string.format("TargetStateID%d",i)
		local _stateID = self.mDB[key]
		if _stateID == 0 then break end
		--
		local _dbState = DB_SkillState.getDataById(_stateID)
		local skilllevel = self.mRole.mRoleData:SkillLevelById(self.mSkillID)
		_victim.mBeatCon:BeatStateChange(self.mDBProcess, _dbState, self ,skilllevel, self.mSkillID, 1,self.mRole)
	end
end

-- 子物体面向
function SubObject:getSubFlagbyvictim(_victim)
	if self.mInjuredDirection == 1 then
		if _victim:getPosition_pos().x > self:getPositionX() then
			self.IsFaceLeft = false
		else
			self.IsFaceLeft = true
		end
	end
end


function SubObject:HitSceneVictimDisplay(_victim)
	if not self.mDBDisPlay then return end
	local _actionDB = self.mDBDisPlay
	-- 受击声音
	if _actionDB.HitSoundEffect > 0 then
		CommonAnimation.PlayEffectId(_actionDB.HitSoundEffect)
	end

	-- 受击特效
	if _victim and type(_actionDB.HitEffect) == "table" then
		-- local face = nil
		-- if _hiter:getPosition_pos().x > _victim:getPosition_pos().x then
		-- 	if _victim.mIsFaceLeft then
		-- 		face = true		
		-- 	end
		-- else
		-- 	if not _victim.mIsFaceLeft then
		-- 		face = true		
		-- 	end
		-- end
	   self:PinEffectOnBone(_actionDB.HitEffect, _actionDB.HitEffectBone, _victim.mSpine)
	end
end

-- 执行该过程展示部分
function SubObject:HandleDisplay(_victim)
	if not self.mDBDisPlay then return end
	local _actionDB = self.mDBDisPlay

	-- 受击音效
	if _actionDB.HitSoundEffect > 0 then
		CommonAnimation.PlayEffectId(_actionDB.HitSoundEffect)
	end

	if self.mDBStaticFrameTime > 0 then
		self.mStaticFrameDuring = self.mDBStaticFrameTime
		self:pause()
		self:pauseAction(true)
	end

	-- 检查静止帧
	if self.mTargetStaticFrameTime > 0 then
		_victim:enableStaticFrame(self.mTargetStaticFrameTime,2)
	end

	-- 攻击特效
	local _HitEffect = _actionDB.HitEffect
	if type(_HitEffect) == "table" and _actionDB.HitEffectBone ~= "" then
	   local _boneName = _actionDB.HitEffectBone
	   -- local face = nil
	   -- if self:getPositionX() > _victim:getPosition_pos().x then
	   -- 		face = true
	   -- end
   		if _HitEffect[3] == 0 then
			self:PinEffectOnBone(_HitEffect, _boneName, _victim.mArmature.mSpine,face)
		elseif _victim.mFSM:IsBeGriped() then
			self:PinEffectOnBone(_HitEffect, _boneName, _victim.mArmature.mSpine,face)
		end
	end
end

-- 给骨骼挂特效
function SubObject:PinEffectOnBone(_pathID, _boneName, _spine)
	local _bonePos = _spine:getBonePosition(_boneName)
	local anim = self.mRole.mEffectCon:GetEffectByResID(_pathID,_spine)
	anim:setPosition(_bonePos)
end

-- 处理硬直
function SubObject:HandleBeatStiff(_victim)
	if self.mInjuredStiff ~= 0 and _victim then
	   _victim.mBeatCon:BeatStiff(self.mInjuredStiff,self.mInjuredShake,self.mInjuredType,self) 
	end
end

-- 处理伤害
function SubObject:HandleDamage(_victim)
	
	local _damage = nil
	local _damageTP = nil
	if FightSystem.mFightType == "olpvp" then
		_damage = 0
		if self.mRole.mGroup == "friend" then
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
				FightSystem:GetFightManager():SendDamgeProcess(self.mSkillID,1,self.mDB.ID,1,enemyindex,PerHurt)
			end
		end
	else
		_damage, _damageTP = CommonSkill.getDamageCount(self.mRole.mPropertyCon, self.mDB, _victim.mPropertyCon,self.mSkillID)
	end
	_victim.mBeatCon:Beated_SubObject( self, self.mRole, _damage, _damageTP,self.mDB,self.mDBDisPlay)
	if FightSystem:IsWithinStaticFrameTime() then
	   _victim.mBeatCon:BeatFlash()
	end
	return true
end

-- 处理伤害
function SubObject:HandleDamageSub(_sub)
	
end

function SubObject:DrawRect_SkillRange1(_point1, _point2)
    if not FightConfig.__DEBUG_SKILLRANGE then return end
    --if self.mDebug_range then return end
    --
    local _debug = quickCreate9ImageView("debug_rectangle.png", _point2.x, _point2.y)
    _debug:setAnchorPoint(cc.p(0, 0))
    if self.IsFaceLeft then
       _point1.x = _point1.x - _point2.x
    end
    _debug:setPosition(_point1)
    self:addChild(_debug)
    --
    self:DelayHideDebug(_debug)
end

function SubObject:DrawRect_SkillRange2(_posCenter, _a, _b)
     if not FightConfig.__DEBUG_SKILLRANGE then return end
     --if self.mDebug_range then return end
     --
    local _debug = quickCreate9ImageView("debug_circular.png", _a * 2, _b* 2)
    _debug:setPosition(_posCenter)
    self:addChild(_debug)
    --
    self:DelayHideDebug(_debug)
end

function SubObject:DelayHideDebug(_debug)
    local function ActionCallBack( sender )
          cclog("销毁技能debug框")
          sender:removeFromParent();
          self.mDebug_range = nil
    end
    local _ac1 = cc.FadeOut:create(1)
    local _ac2 = cc.CallFunc:create(ActionCallBack)
    local _seq = cc.Sequence:create({_ac1, _ac2})
    _debug:runAction(_seq)
    self.mDebug_range = _debug
end


-- 音效
-- 1. 出生
-- 2. 循环
-- 3. 消失
function SubObject:playVoiceSound(_voiceNum, _func)
	if not self.mSoundList then return end
	local _soundID = self.mSoundList[_voiceNum]
	if _soundID <= 0 then return end
	CommonAnimation.PlayEffectId(_soundID, _func)
end

--[[
   暂停动作
]]
function SubObject:pauseAction(_bb)
	if self.mSpine then
		self.mSpine:setStopTick(_bb)
	end
end