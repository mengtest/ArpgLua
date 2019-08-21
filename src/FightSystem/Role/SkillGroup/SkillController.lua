-- Name: SkillController
-- Func: 角色技能控制器
-- Author: Johny

require "FightSystem/Role/SkillGroup/SkillObject"
require "FightSystem/Role/SubObject"
require "FightSystem/Role/SkillGroup/GripController"

SkillController = class("SkillController")
local _abs = math.abs

function SkillController:ctor(_role)
	self.mRole = _role
	self.mRoleData = _role.mRoleData
	self.mArmature = _role.mArmature
	self.mMp = 50
	self.mMpTickTime = 2
	self.mSkillStack = {}
	self.mCurSkill = nil
	self.mFinishSkillCallBackTable = {}
	self.mListCoolDown = {}
	self.mSubInstanceCounter = 0
	self.mSubObjectList = {}
	self.mGripCon = GripController.new(_role, self)
	--
	-- 光环链表
	self.SkillHaloList = {}
	-- 光环特效链表
	self.HaloEffectList = {}
	self.mIsHalo = false
	self.IsHaloEffect = false
	self:handlePassivedSkill()
	self.IsFirstHalo = true
	self.mDzShowTime = nil

end

function SkillController:Destroy()
	self.mRole = nil
	self.mSkillStack = nil
	self.mDzShowTime = nil
	if self.mCurSkill then
		self.mCurSkill:GroupEffectEnd()
		self.mCurSkill = nil
	end
	self.mFinishSkillCallBackTable = nil
	self.mListCoolDown = nil
	self.mSubInstanceCounter = nil
	self:cancelSkillRange()
	self:RemoveHaloEffect()
	self.HaloEffectList = nil
	self:RemoveAllSubObject()
	self.mSubObjectList = nil
	self.mGripCon = nil
	self.IsHaloEffect = nil
	self.mIsHalo = nil
	self.IsFirstHalo = nil
end

function SkillController:Tick(delta)
	-- 处理冷却
	self:TickCoolDown(delta)
	--self:TickAddMp(delta)
	if self.mCurSkill then
	   self.mCurSkill:Tick(delta)
	else
		self:PopSkillObject()
	end
	--
	for k,_sub in pairs(self.mSubObjectList) do
		_sub:Tick(delta)
	end

	--检查合体绑定
	self:tickCombineSkillBind()

	self.mGripCon:Tick()

	self:TickmSkillRange()
	self:TickHaloEffect()
	-- 技能被动光环
	self:TickSkillHalo(delta)
	-- 大招展示
	self:TickDazhao(delta)
end

-- Tick Mp
function SkillController:TickAddMp(delta)
	if self.mRole.mGroup == "friend" or self.mRole.mGroup == "enemyplayer" or (FightSystem:GetModelByType(4) and self.mRole.mGroup == "monster" ) then
		self.mMpTickTime = self.mMpTickTime - delta
		if self.mMpTickTime <= 0 then
			self.mMpTickTime = 2
			self:AddMp(2)
		end
	end
end

function SkillController:TickmSkillRange()
	if not self.mSkillRange then return end
	self:setPosSkillRange()
	if not (self.mRole.mFSM:IsRuning() or self.mRole.mFSM:IsIdle()) then
		self:cancelSkillRange()
	end
end

function SkillController:TickHaloEffect()
	if not self.IsHaloEffect then return end
	if self.IsFirstHalo then
 		self.IsFirstHalo = false
 		for k,halodata in pairs(self.SkillHaloList) do
			self:AddHaloEffect(halodata)
		end
	end
	for k,v in pairs(self.HaloEffectList) do
		v:setPosition(self.mRole.mShadow:getPosition_pos())
	end
end

function SkillController:TickSkillHalo(delta)
	if self.mIsHalo then
		for k,v in pairs(self.SkillHaloList) do

			if v.curIntervalTime >= v.HaloInterval then
				v.curIntervalTime = 0
				self:AddHaloState(v)
			else
				v.curIntervalTime = v.curIntervalTime + delta
			end
		end 
	end
end

function SkillController:TickDazhao(delta)
	if self.mDzShowTime and not self.mRole:IsControlByStaticFrameTime() then
		self.mDzShowTime = self.mDzShowTime - delta
		if self.mDzShowTime <= 0 then
			self.mDzShowTime = nil
			self.mRole:resumeAction()
		end
	end
end



function SkillController:BeginDzShow()
	self.mDzShowTime = 1.5
	self.mRole:pauseAction()
end

function SkillController:ShowHaloEffect()
	for k,v in pairs(self.HaloEffectList) do
		v:setVisible(true)
	end
end

function SkillController:HideHaloEffect()
	for k,v in pairs(self.HaloEffectList) do
		v:setVisible(false)
	end
end

function SkillController:AddHaloState(_halo)
	if _halo.HaloTarget == 0 then
		self:AddHaloStateFriend(_halo)
		self:AddHaloStateEnemy(_halo)
	elseif _halo.HaloTarget == 1 then
		self:AddHaloStateEnemy(_halo)
	elseif _halo.HaloTarget == 2 then
		self:AddHaloStateFriend(_halo)
	end
end

function SkillController:AddHaloStateFriend(_halo)
	local _victimCount = FightSystem.mRoleManager:GetFriendCount(self.mRole)
	for i = 1, _victimCount do
		local _victim = FightSystem.mRoleManager:GetFriend(i, self.mRole,true)
		if _victim and self:IsInSkillRangeByHalo(_halo ,_victim:getShadowPos()) then
			local _dbState = DB_SkillState.getDataById(_halo.HaloStateID)
			if _dbState then
				_victim.mBeatCon:BeatStateChange(_halo.Proc, _dbState, self.mRole)
			end
		end
	end
end

function SkillController:AddHaloStateEnemy(_halo)
	local _victimCount = FightSystem.mRoleManager:GetVicmCount(self.mRole)
	for i = 1, _victimCount do
		local _victim = FightSystem.mRoleManager:GetEnemy(i, self.mRole)
		if _victim and self:IsInSkillRangeByHalo(_halo ,_victim:getShadowPos()) then
			local _dbState = DB_SkillState.getDataById(_halo.HaloStateID)
			if _dbState then
				_victim.mBeatCon:BeatStateChange(_halo.Proc, _dbState, self.mRole)
			end
		end
	end
end

function SkillController:IsInSkillRangeByHalo(_halo,_pos)
	if _halo.HaloType == 1 then
		local _len = _halo.HaloRange[1]
		local _width = _halo.HaloRange[2]
		local _rect = cc.rect(self.mRole:getShadowPos().x - _len/2,self.mRole:getShadowPos().y - _width/2, _len, _width)
		if cc.rectContainsPoint(_rect, _pos) then
			return true
		end
	elseif _halo.HaloType == 2 then
		local _a = _halo.HaloRange[1]
		local _b = _halo.HaloRange[2]
		local _opos = _pos
		local rolepos = self.mRole:getShadowPos()
		if _opos.x*rolepos.x  >= 0 then
			_opos.x = rolepos.x  - _opos.x
		else
			_opos.x = _abs(rolepos.x)  + _abs(_opos.x)
		end

		if _opos.y*rolepos.y  >= 0 then
			_opos.y = rolepos.y  - _opos.y
		else
			_opos.y = _abs(rolepos.y)  + _abs(_opos.y)
		end
		if MathExt.IsPosInEllipse(_opos.x, _opos.y, _a, _b) then
			return true
		end
	end
	return false
end

function SkillController:setFlip(_flip)
	if not self.mSkillRange then return end
	local _x = nil
	if _flip == 1 then
		_x = _abs(self.mSkillRange:getScaleX())
	else
		_x = -_abs(self.mSkillRange:getScaleX())
	end
	self.mSkillRange:setScaleX(_x)
end

-- 添加Mp
function SkillController:AddMp(_value)
	self.mMp = self.mMp + _value
	if self.mMp > 100 then
		self.mMp = 100
	end
end

-- 加光环特效
function SkillController:AddHaloEffect(_halo)
	if _halo.HaloResID == 0 then return end
	local HaloSpine = CommonAnimation.createCacheSpine_commonByResID(_halo.HaloResID,self.mRole.mArmature:getParent())
	HaloSpine:setLocalZOrder(-2)
	HaloSpine:setAnimation(0,"start",true)
	table.insert(self.HaloEffectList,HaloSpine)
	HaloSpine:setScaleX(_halo.HaloRange[1]/500)
	HaloSpine:setScaleY(_halo.HaloRange[2]/500)
end


-- 检查被动技能
function SkillController:handlePassivedSkill()
	-- 仅友方有被动技能
	if self.mRole.mGroup == "friend" or self.mRole.mGroup == "enemyplayer" or self.mRole.mGroup == "monster" then
		local _key = "mRole_PassiveSkill"
		for i = 1,4 do
			local PassKey = string.format("mRole_PassiveSkill%d",i)
			local _pskill = self.mRoleData[PassKey]
			if not _pskill or _pskill == 0 then break end
			local _skill = DB_SkillEssence.getDataById(_pskill)
			if _skill.ProcessID1 == 0 or _skill.Type ~= 3 then break end
			local _proc = DB_SkillProcess.getDataById(_skill.ProcessID1)
			if _proc.HaloStateID ~= 0 then
				local halodata = {}
				halodata.HaloType = _proc.HaloType
				halodata.HaloRange = _proc.HaloRange
				halodata.HaloTarget = _proc.HaloTarget
				halodata.HaloStateID = _proc.HaloStateID
				halodata.HaloInterval = _proc.HaloInterval/30
				halodata.Proc = _proc
				halodata.curIntervalTime = 0
				halodata.HaloResID = _proc.HaloResID
				table.insert(self.SkillHaloList,halodata)
				self.mIsHalo = true
				if halodata.HaloResID ~= 0 then
					self.IsHaloEffect = true
				end
			end
			for j = 1,4 do
				local _kstate = TargetStateID_Table[j]
				local _stateid = _proc[_kstate]
				if _stateid == 0 then break end		
				local _state = DB_SkillState.getDataById(_stateid)
				for h = 1,4 do
					local _keff = EffectID_Table[h]
					local _effid = _state[_keff]
					if _effid == 0 then break end
					local _eff = DB_SkillEffect.getDataById(_effid)
					self.mRole.mBuffCon:addBuff(_state, _eff, self.mRole, _proc)
				end
			end
		end
	end
end

function SkillController:PushSkillObject(_skill)
	--cclog("插入技能======" .. _skill.mSkillID)
	table.insert(self.mSkillStack, _skill)
end

function SkillController:ExecuteSkillProcess()
	if self.mCurSkill then
		if self.mCurSkill.mCurPro then
			self.mCurSkill.mCurPro:HandleFirstTick()
		end
	end
end

function SkillController:onCustomCallBack(event)
	if self.mCurSkill and event.eventData then
		local num = tonumber(event.eventData.name)
		if type(num) == "number" then
			if self.mCurSkill.mCurPro and self.mCurSkill.mCurPro.mDB.EventIndex == num then
				if self.mCurSkill.mCurPro.mDB.Type == 3 then 
					if self.mCurSkill.mCurPro:IsloopSkill() then
						self.mRole.mArmature.mSpine:clearTracks()
						self.mCurSkill.mCurPro:HandleFirstTick(true)
						return false
					end 
				elseif self.mCurSkill.mCurPro.mDB.Type == 31 then
					if self.mCurSkill.mCurPro:IsloopSkill() then
						self.mRole.mArmature.mSpine:clearTracks()
						self.mCurSkill.mCurPro:HandleFirstTick(true)
						return false
					end 
				end
				self.mCurSkill:OnProcessFinish(self.mCurSkill.mCurPro)
				return true
			end
		end
	end
	return false
end

function SkillController:PopSkillObject()

	self.mCurSkill = table.remove(self.mSkillStack,1)

	if self.mCurSkill then
	   self:setCoolDown(self.mCurSkill.mSkillID)
	   if self.mRole.IsKeyRole then
	  	FightSystem.mTouchPad:GongjiChangeFace()
	   end
	   self:PlaySkillSyncOlPVP()
	   self.mCurSkill:StartRun()
	   self.mRole.mBeatCon.mBeatTiffCount = 0

	   if self.mRoleData.mRole_DodgeSkill and self.mCurSkill.mSkillID == self.mRoleData.mRole_DodgeSkill then
	   		self.mRole:setInvincible(true)
	   end
	   --cclog("开始执行技能====" .. self.mCurSkill.mSkillID)
	end
end

-- olpvp发技能
function SkillController:PlaySkillSyncOlPVP()
	if self.mRole.IsKeyRole and FightSystem.mFightType == "olpvp" then
		local randomNum = os.time()%100000
		math.randomseed(randomNum)
	   	FightSystem:GetFightManager():PlaySkill_SyncPVP(self.mRole,self.mCurSkill.mSkillID,randomNum)
	end
end

-- 当前技能是否可以移动
function SkillController:canCurSkillMove()
	if not self.mCurSkill then return false end

	return self.mCurSkill:CanMove()
end

function SkillController:IsSkillInStack(_skillID)
	for k,skill in pairs(self.mSkillStack) do
		if skill.mSkillID == _skillID then
		   return true
		end
	end

	return false
end

-- 外部通过此接口创建新skill
function SkillController:SetSkillByID(_skillID, _tp)
	--local con1 = #self.mSkillStack < 2
	local con2 = not self:IsSkillInStack(_skillID)
	local con3 = (self.mCurSkill and self.mCurSkill.mSkillID ~= _skillID) or not self.mCurSkill
	local con4 = false
	if FightConfig.__DEBUG_SKILL_COOLDOWN then
		con4 = FightConfig.__DEBUG_SKILL_COOLDOWN
	else
		con4 = not self:IsSkillInCoolDown(_skillID)
	end
	if  con2 and con3 and con4 then
		local _skill = SkillObject.new(_skillID, self, self.mRole, _tp)
		self:PushSkillObject(_skill)
		return true
	end

	cclog("加入技能失败")
	return false
end

-- 判断是否可以加入到技能池
function SkillController:isSetSkillByID(_skillID)
	--local con1 = #self.mSkillStack < 2
	local con2 = not self:IsSkillInStack(_skillID)
	local con3 = (self.mCurSkill and self.mCurSkill.mSkillID ~= _skillID) or not self.mCurSkill
	local con4 = false
	if FightConfig.__DEBUG_SKILL_COOLDOWN then
		con4 = FightConfig.__DEBUG_SKILL_COOLDOWN
	else
		con4 = not self:IsSkillInCoolDown(_skillID)
	end
	if  con2 and con3 and con4 then
		return true
	end

	return false
end

-- 结束当前技能
function SkillController:FinishCurSkill()
	if self.mCurSkill then
		if self.mRole.IsKeyRole and FightSystem.mFightType == "olpvp" then
			FightSystem:GetFightManager():CancelSkill_SyncPVP(self.mCurSkill.mSkillID)
		end
		self.mCurSkill:FinishSelfBeforeNextProcess()
		--cclog("SkillController:FinishCurSkill()==GGGGGGGGGGGGGGGGGGGGG=="..self.mCurSkill.mSkillID)
		self.mCurSkill = nil
	end
	self:ClearSkillStack()
end

-- 清空技能栈
function SkillController:ClearSkillStack()
	self.mSkillStack = {}
end



-------------------------------------技能范围----------------------------------------------
local SKILLRANGE_SIZE = cc.size(500,500)
function SkillController:showSkillRange(_skillID)
	self:cancelSkillRange()
	local _rolePos = self.mRole:getPosition_pos()
	local _dbSkill =  DB_SkillEssence.getDataById(_skillID)
	local _rangeType = _dbSkill.SelectEffect
	local _size = _dbSkill.SelectEffectSize
	local _offset = _dbSkill.SelectEffectOffset
	self.mshowSkillrangeType = _rangeType
	self.mshowSkillrangeoffset = _offset
	local _spine = nil
	if _rangeType == 0 then
		return false
	elseif _rangeType == 1 then
		-- 箭头
		_spine = CommonAnimation.createCacheSpine_commonByResID(150, self.mRole.mArmature:getParent())
		SKILLRANGE_SIZE.height = 50
	elseif _rangeType == 2 then
		-- 椭圆
		_spine = CommonAnimation.createCacheSpine_commonByResID(148, self.mRole.mArmature:getParent())
		SKILLRANGE_SIZE.height = 500
	elseif _rangeType == 3 then
		-- 目标点
		_spine = CommonAnimation.createCacheSpine_commonByResID(149, self.mRole.mArmature:getParent())
		SKILLRANGE_SIZE.height = 500
	end
	local _scaleX = _size[1]/SKILLRANGE_SIZE.width
	local _scaleY = _size[2]/SKILLRANGE_SIZE.height
	_spine:setScaleX(_scaleX)
	_spine:setScaleY(_scaleY)
	_spine:setLocalZOrder(-1)
	self.mSkillRange = _spine
	if self.mRole.IsFaceLeft then
		self.mSkillRange:setScaleX(-_scaleX)
	end

	if self.mRole.mGroup == "friend" or self.mRole.mGroup =="enemyplayer" or self.mRole.mGroup == "cgfriend" or self.mRole.mGroup == "summonfriend" then
		self.mSkillRange:setAnimation(0, "role", true)
	elseif self.mRole.mGroup == "monster" or self.mRole.mGroup == "summonmonster" then
		self.mSkillRange:setAnimation(0, "monster", true)
	end
	self:setPosSkillRange()
	return true
end

-- 设置技能框位置
function SkillController:setPosSkillRange()
	local _x = 0
	local _y = 0
	if self.mRole.IsFaceLeft then
		_x = -self.mshowSkillrangeoffset[1]
		_y = self.mshowSkillrangeoffset[2]
	else
		_x = self.mshowSkillrangeoffset[1]
		_y = self.mshowSkillrangeoffset[2]
	end
	self.mSkillRange:setPosition(self.mRole.mShadow:getPosition_pos().x+_x,self.mRole.mShadow:getPosition_pos().y+_y)
end
-- 显示投掷范围
function SkillController:showThrowSkillRange()
	return self:showSkillRange(self.mRole.mPickupCon:getThrowSkillID())
end

-- 取消技能范围
function SkillController:cancelSkillRange()
	if not self.mSkillRange then return end
	SpineDataCacheManager:collectFightSpineByAtlas(self.mSkillRange)
	self.mSkillRange = nil
end

-- 返回当前技能判定类型 和 长度
function SkillController:getInSkillRangeBySkillID(_skillID)
	local _dbEss =  DB_SkillEssence.getDataById(_skillID)
	for i = 1,32 do
		local _proID = _dbEss[ProcessID_Table[i]]
		if _proID == 0 then break end
		--
		local _pro = DB_SkillProcess.getDataById(_proID)
		if _pro.DamageLength ~= 0 and _pro.DamageWidth ~= 0 then
			return _pro
		end
	end
	return nil
end

-- 判断是否在技能范围内
-- type: role : pos 
-- isturnback 是否看转身
function SkillController:IsInSkillRangeBySkillID(_type, _skillID, _pos,isturnback,damagerange)
	local _dbEss =  DB_SkillEssence.getDataById(_skillID)
	for i = 1,32 do
		local _proID = _dbEss[ProcessID_Table[i]]
		if _proID == 0 then break end
		--
		local _pro = DB_SkillProcess.getDataById(_proID)
		if self:IsInSkillRange(_type, _pro, _pos, isturnback,damagerange) then
		   return true
		end
	end

	return false
end

-- type: sceneAni: role : pos
function SkillController:IsInSkillRange(_type, _dbProgress, _object, isturnback,damagerange)
	local _offset = _dbProgress.DamageRangeOffset
	local Length = _dbProgress.DamageLength
	local Width = _dbProgress.DamageWidth
	if damagerange then
		Length = damagerange[1]
		Width = damagerange[2]
	end
	if _dbProgress.DamageType == 1 then
	   return self:IsRoleInSkillRange_Type1(_type, Length, Width, _object, _offset, isturnback)
	elseif _dbProgress.DamageType == 2 then
		return self:IsRoleInSkillRange_Type2(_type, Length, Width, _object, _offset, isturnback)
	end
end


-- 立方体判断是否在技能范围
function SkillController:IsRoleInSkillRange_Type1(_type, _len, _width, _object, _offset, isturnback)
	local _x = self.mRole:getPositionX()
	local _y = self.mRole:getPositionY() - _width * 0.5
	-- 如果是0 直接跳过
	if _len == 0 or _width == 0 then
		return false
	end
	--备用矩形
	local turnback = isturnback
	local x1 = _x
	local x2 = _x
	local offsetx = _offset[1]
	if self.mRole.IsFaceLeft then
	   x1 = _x - _len
	   offsetx = - offsetx
	else
	   x2 = _x - _len
	end

	local _rect = cc.rect(x1 + offsetx, _y + _offset[2], _len, _width)
	local _rect1 = cc.rect(x2 - offsetx, _y + _offset[2], _len, _width)
	
	local _posVic = nil
	local isscenePiece = nil
	if _type == "sceneAni" then
		isscenePiece , _posVic = _object:CollisionPiece()
	elseif _type == "role" then
		_posVic = _object:getShadowPos()
	elseif _type == "pos" then
		_posVic = _object
	end

	-- 画出技能范围
	self.mArmature:DrawRect_SkillRange1(cc.p(0 + _offset[1], - _width * 0.5 + _offset[2]), cc.p(_len, _width))

	--
	if (isscenePiece and isscenePiece == 0) or not isscenePiece then
		if cc.rectContainsPoint(_rect, _posVic) then
			return true
		end
		if turnback then
			if cc.rectContainsPoint(_rect1, _posVic) then
				self.mRole:TurnReverse()
				return true
			end
		end
	else
		if cc.rectIntersectsRect(_rect, _posVic) then
			return true
		end
		if turnback then
			if cc.rectIntersectsRect(_rect1, _posVic) then
				self.mRole:TurnReverse()
				return true
			end
		end
	end
	return false
end

-- 椭圆判定
function SkillController:IsRoleInSkillRange_Type2(_type, _a, _b, _object, _offset, isturnback)
	-- 画出技能范围
	self.mArmature:DrawRect_SkillRange2(cc.p(_offset[1], _offset[2]), _a, _b)

	-- 如果是0 直接跳过
	if _a == 0 or _b == 0 then
		return false
	end
	local turnback = isturnback
	local _pos = nil
	local isscenePiece = nil
	local _posVic = nil
	if _type == "sceneAni" then
		_pos = _object:getPosition_pos()
		isscenePiece , _posVic = _object:CollisionPiece()
	elseif _type == "role" then
		_pos = _object:getShadowPos()
	elseif _type == "pos" then
		_pos = _object
	end
	-- 计算圆心
	local _opos = nil
	local _opos2 = nil
	if self.mRole.IsFaceLeft then
		_opos = cc.p(self.mRole:getPositionX() - _offset[1], self.mRole:getPositionY() + _offset[2])
		_opos2 = cc.p(self.mRole:getPositionX() + _offset[1], self.mRole:getPositionY() + _offset[2]) 
	else
	    _opos = cc.p(self.mRole:getPositionX() + _offset[1], self.mRole:getPositionY() + _offset[2]) 
	    _opos2 = cc.p(self.mRole:getPositionX() - _offset[1], self.mRole:getPositionY() + _offset[2])
	end
	if _offset[1] == 0 then
		turnback = false
	end

	if _opos.x*_pos.x  >= 0 then
		_opos.x = _pos.x  - _opos.x
	else
		_opos.x = _abs(_pos.x)  + _abs(_opos.x)
	end

	if _opos.y*_pos.y  >= 0 then
		_opos.y = _pos.y  - _opos.y
	else
		_opos.y = _abs(_pos.y)  + _abs(_opos.y)
	end

	if _opos2.x*_pos.x  >= 0 then
		_opos2.x = _pos.x  - _opos2.x
	else
		_opos2.x = _abs(_pos.x)  + _abs(_opos2.x)
	end

	if _opos2.y*_pos.y  >= 0 then
		_opos2.y = _pos.y  - _opos2.y
	else
		_opos2.y = _abs(_pos.y)  + _abs(_opos2.y)
	end
	--
	if not isscenePiece or (isscenePiece and isscenePiece == 0) then
		if MathExt.IsPosInEllipse(_opos.x, _opos.y, _a, _b) then
			return true
		end

		if turnback then
			if MathExt.IsPosInEllipse(_opos2.x, _opos2.y, _a, _b) then
				self.mRole:TurnReverse()
				return true
			end
		end
	else
		local _x = self.mRole:getPositionX()
		local _y = self.mRole:getPositionY() - _b
		local x1 = _x - _a
		local offsetx = _offset[1]
		if self.mRole.IsFaceLeft then
		   offsetx = - offsetx
		end
		local _rect = cc.rect(x1 + offsetx, _y + _offset[2], _a*2, _b*2)
		local _rect1 = cc.rect(x1 - offsetx, _y + _offset[2], _a*2, _b*2)

		if cc.rectIntersectsRect(_rect, _posVic) then
			return true
		end
		if turnback then
			if cc.rectIntersectsRect(_rect1, _posVic) then
				self.mRole:TurnReverse()
				return true
			end
		end
	end
	return false
end

--------------------------------------------------------------------------------------------


-- 设置技能结束回调handler
function SkillController:SetFinishSkillCallBackHandler(_key, _handler)
	self.mFinishSkillCallBackTable[_key] = _handler
end

-- 解注册回调
function SkillController:UnRegisterSkillCallBackHandler(_key)
	self.mFinishSkillCallBackTable[_key] = nil
end

-- 技能是否在冷却
function SkillController:IsSkillInCoolDown(_skillID)
	local _db = DB_SkillEssence.getDataById(_skillID)
	local _CostMp = _db.CostMp
	local _PowerUpTimes = _db.PowerUpTimes
	local _CoolDownID = _db.CoolDownID
	local _ret = true
	if self.mRole.mGroup == "friend" or self.mRole.mGroup == "enemyplayer" then
		if _CostMp ~= 0 and self.mMp < _CostMp then
			return _ret
		end
	end
	if FightSystem:GetModelByType(4) and self.mRole.mGroup == "monster" then
		if _CostMp ~= 0 and self.mMp < _CostMp then
			return _ret
		end
	end
	if _PowerUpTimes ~= 0 then
		local _coolTable = self.mListCoolDown[_CoolDownID]
		if _coolTable then
			return _coolTable[3] <= 0
		else
			return false
		end
	end
	local _coolTable = self.mListCoolDown[_CoolDownID]
	if _coolTable then
	   _ret = _coolTable[1] > 0
	else
		return false
	end
	return _ret
end

-- 合体技能是否在冷却
function SkillController:IsGroupSkillInCoolDown()
	local _ret = self:IsSkillInCoolDown(self.mRoleData.mGSID1)

	return _ret
end

-- 技能冷却时间
function SkillController:SkillInCoolDownTime(_skillID,_type)
	local _db = DB_SkillEssence.getDataById(_skillID)
	local _CostMp = _db.CostMp
	local _PowerUpTimes = _db.PowerUpTimes
	local _CoolDownID = _db.CoolDownID
	local _CoolDownTime = _db.CoolDownTime - self.mRole.mRoleData:CoolTimeWeapSkillById(_skillID)*30
	_CoolDownTime = _CoolDownTime / 30
	if self.mRole.mGroup == "monster" and not FightSystem:GetModelByType(4) then
		local _coolTable = self.mListCoolDown[_CoolDownID]
		if _coolTable then
		    return _coolTable[1], _coolTable[2]
		else
		    return 0
		end
	end
	if _CostMp ~= 0 then
		local _coolTable = self.mListCoolDown[_CoolDownID]
		local Table1 = nil
		local Table2 = nil
		if _coolTable then
			Table1 = _coolTable[1]
			Table2 = _coolTable[2]
		else
		    Table1 = 0
		end
		return _CostMp-self.mMp , _CostMp ,Table1 ,Table2
	elseif _PowerUpTimes ~= 0 then
		local _coolTable = self.mListCoolDown[_CoolDownID]
		if _coolTable then
			if _type then
				if _coolTable[3] > 0 then
					return 0
				else
					return _coolTable[1]
				end
			else
				return _coolTable[1], _coolTable[2],_coolTable[3],_coolTable[4]
			end
		else
		    return 0,_CoolDownTime,_db.PowerUpTimes,_db.PowerUpTimes
		end
	else
		local _coolTable = self.mListCoolDown[_db.CoolDownID]
		if _coolTable then
		    return _coolTable[1], _coolTable[2]
		else
		    return 0
		end
	end
end

-- 合体技能冷却时间
function SkillController:GroupSkillInCoolDownTime()
	return self:SkillInCoolDownTime(self.mRoleData.mGSID1)
end

-- 开始冷却
function SkillController:setCoolDown(_skillID)
	--cclog("设置技能冷却=====" .. _skillID)

	local _db = DB_SkillEssence.getDataById(_skillID)
	local _CostMp = _db.CostMp
	local _PowerUpTimes = _db.PowerUpTimes
	local _CoolDownID = _db.CoolDownID
	local _CoolDownTime = _db.CoolDownTime - self.mRole.mRoleData:CoolTimeWeapSkillById(_skillID)*30
	_CoolDownTime = _CoolDownTime/30


	if self.mRole.mGroup == "friend" or self.mRole.mGroup == "enemyplayer" then
		if _CostMp ~= 0 and self.mMp >= _CostMp then
			self.mMp = self.mMp - _CostMp
			--[[
			if _skillID == self.mRole.mRoleData.mGSID1 or _skillID == self.mRole.mRoleData.mGSID2 then
				if self.mRole.mGroup == "friend" and self.mRole.IsKeyRole then
					self.mMp = self.mMp - _CostMp
				end
			else
				self.mMp = self.mMp - _CostMp
			end
			]]
		end
	end

	if self.mRole.mGroup == "monster" and FightSystem:GetModelByType(4) then
		if _CostMp ~= 0 and self.mMp >= _CostMp then
			self.mMp = self.mMp - _CostMp
		end
	end

	if _PowerUpTimes ~= 0 then
		if self.mListCoolDown[_CoolDownID] then 
			self.mListCoolDown[_CoolDownID] = {self.mListCoolDown[_CoolDownID][1], _CoolDownTime ,self.mListCoolDown[_CoolDownID][3]-1,_PowerUpTimes}
		else
			self.mListCoolDown[_CoolDownID] = {_CoolDownTime, _CoolDownTime ,_PowerUpTimes - 1,_PowerUpTimes}
		end
	else
		self.mListCoolDown[_CoolDownID] = {_CoolDownTime, _CoolDownTime}
	end
end

-- 处理TIck冷却
function SkillController:TickCoolDown(delta)
	for k,v in pairs(self.mListCoolDown) do
		if v[3] then
			if v[3] < v[4] then
				if v[1] - delta <= 0 then
					self.mListCoolDown[k] = {v[2], v[2],v[3]+1,v[4]}
				else
					self.mListCoolDown[k] = {v[1] - delta, v[2],v[3],v[4]}
				end
			else
				self.mListCoolDown[k] = {v[2], v[2],v[4],v[4]}
			end
		else
			self.mListCoolDown[k] = {v[1] - delta, v[2]}
		end
	end
end

-- 人加入子物体
function SkillController:AddSubObject(_subID, _skillID, _procDB, _pos)
	self.mSubInstanceCounter = self.mSubInstanceCounter + 1
	local _sub = SubObject.new(_subID, self.mSubInstanceCounter, self.mRole, _skillID, _procDB, _pos)
	_sub:AddToRoot(FightSystem.mSceneManager:GetTiledLayer(self.mRole.mSceneIndex))
	_sub:BuildDelayLive()

	table.insert(self.mSubObjectList, _sub)
end

-- 子物体加入子物体
function SkillController:AddSubObjectBySub(_subID, _skillID, _procDB, _pos, _isLeft)
	self.mSubInstanceCounter = self.mSubInstanceCounter + 1
	local _sub = SubObject.new(_subID, self.mSubInstanceCounter, self.mRole, _skillID, _procDB, _pos ,_isLeft)
	_sub:AddToRoot(FightSystem.mSceneManager:GetTiledLayer(self.mRole.mSceneIndex))
	_sub:BuildDelayLive()

	table.insert(self.mSubObjectList, _sub)
end

function SkillController:RemoveSubObject(_instanceID)
	for k,sub in pairs(self.mSubObjectList) do
		if sub.mInstanceID == _instanceID then
		   sub:Destroy()
		   table.remove(self.mSubObjectList, k)
		return end
	end
end

function SkillController:RemoveHaloEffect()
	if not self.IsHaloEffect then return end
	for k,v in pairs(self.HaloEffectList) do
		SpineDataCacheManager:collectFightSpineByAtlas(v)
	end
	self.HaloEffectList = {}
end

function SkillController:RemoveAllSubObject()
	for k,sub in pairs(self.mSubObjectList) do
		sub:Destroy()
	end
	self.mSubObjectList = {}
end

-----------------------------合体技------------------------------------
-- 检查是否合体技
function SkillController:getGSFlag()
	return self.mRoleData.mGSFlag
end

-- 找出同伴相同的合体技, 附赠合体技的人
function SkillController:getCommonGSPartner()
	if self.mRole.mGroup == "monster" then return end
	local _gsflag = self:getGSFlag()
	if _gsflag == 0 then return end
	local _friendList = FightSystem.mRoleManager:GetFriendTable()
	for k,_role in pairs(_friendList) do
		if _role.mInstanceID ~= self.mRole.mInstanceID then 
		   local _gsflag2 = _role.mSkillCon:getGSFlag()
		   if _gsflag == _gsflag2 then

			  return _role
		   end
		end
	end

	return nil
end

-- 找出同伴相同的合体技, 附赠合体技的人
function SkillController:IsCommonGSPartner()
	if self.mRole.mGroup == "monster" then return end
	local _gsflag = self:getGSFlag()
	if _gsflag == 0 then return end
	if self.mRole.mRoleData.mGroupMainSubFlag ~= 1 then 
		return nil
	end
	local _friendList = FightSystem.mRoleManager:GetFriendTable()
	for k,_role in pairs(_friendList) do
		if _role.mInstanceID ~= self.mRole.mInstanceID then 
		   local _gsflag2 = _role.mSkillCon:getGSFlag()
		   if _gsflag == _gsflag2 then
			  return _role
		   end
		end
	end
	return nil
end

-- 释放合体技
function SkillController:playCombineSkill()
	local _partner = self:getCommonGSPartner()
	if not _partner then return end
	if _partner.mPropertyCon.mCurHP <= 0 or _partner.mFSM:IsDeading() then
		return
	end

	if _partner.mFSM:IsBeControlled() or _partner.mFSM:IsFallingDown() then
		return
	end

	if _partner.mFSM:IsBeGriped() then
		return
	end

	local _skillID = self.mRoleData.mGSID1
	if not self.mRole:PlaySkillByID(_skillID) then
		return
	end
	FightSystem.mTouchPad:setTouchEnabelCheckWeapon(false)
	FightSystem.mTouchPad:setCancelledTouchMove(true)
	self.isPlayCombineing = true
	self.isPlayCombineingStep1 = true
	-- 伙伴取消AI,回到待机
	self.mRole.mAI:setOpenAI(false)
	_partner.mAI:setOpenAI(false)
	if _partner.mFSM:IsAttacking() then
	   _partner.mSkillCon:FinishCurSkill()	  
	end
	self.mRole:setInvincible(true)
	_partner:setInvincible(true)
	_partner.mArmature:setNoReceiveAction(false)
	_partner.mFSM:ForceChangeToState("idle")	
	self:setGroupSkillPartner(_partner)
	_partner.mSkillCon:setGroupSkillPartner(self.mRole)
	self:playCombineSkill_1()
end

-- 合体技1阶段
function SkillController:playCombineSkill_1()
	local _partner = self:getGroupSkillPartner()
	local _nextPos = self.mRole:getPosition_pos()
	_nextPos.x = _nextPos.x + 100
	if self.mRole.IsFaceLeft then
		_nextPos.x = _nextPos.x - 200
	end
	local function finishskill1(_skillID)
		if _skillID ~= _partner.mRoleData.mGSID1 then return end
		_partner.mSkillCon:UnRegisterSkillCallBackHandler("SkillController")
		local function finishMove()
			self:playCombineSkill_2()
			FightSystem.mTouchPad:setCancelledTouchMove(false)
		end
		_partner:forceWalkingByPos(_nextPos, finishMove)
	end
	-- 全屏静止
	_partner:fullscreenStaticProtect()
	self.mBlackLayer = CommonSkill.fullscreenStaticForComSkill(self.mRole, 999)
	FightSystem.mTouchPad:disabled(true)
	--
	_partner:playCombineSkill1_sub()
	_partner.mSkillCon:SetFinishSkillCallBackHandler("SkillController",finishskill1)
end

-- 结束合体技能2
function SkillController:finishCombineSkill_2()
	local _partner = self:getGroupSkillPartner()
	--_partner.mShadow:stopTickZorder(false)
	if FightSystem.mTouchPad.mAutoTouchAttack then
		self.mRole.mAI:setOpenAI(true)
	end
	_partner.mAI:setOpenAI(true)
	self.mRole:setInvincible(false)
	_partner:setInvincible(false)
	self:setGroupSkillPartner(nil)
	_partner.mSkillCon:setGroupSkillPartner(nil)
	self.mIsPlayingGS = false
	self.isPlayCombineing = false
	FightSystem.mTouchPad:setTouchEnabelCheckWeapon(true)
end

-- 合体技2阶段
function SkillController:playCombineSkill_2()
	local _partner = self:getGroupSkillPartner()
	local function finishskill2(_skillID)
		if _skillID ~= _partner.mRoleData.mGSID2 then return end
		self:finishCombineSkill_2(_partner)
		_partner.mSkillCon:UnRegisterSkillCallBackHandler("SkillController")
	end
	-- 取消全屏静止
	FightSystem.mTouchPad:disabled(false)
	CommonSkill.cancelFullscreenStatic(self.mBlackLayer)
	_partner.mStaticFrameTime_Unlock = false
	-- 开始播放合体技
	self.mRole:PlaySkillByID(self.mRoleData.mGSID2)
	_partner:PlaySkillByID(_partner.mRoleData.mGSID2)
	_partner.mSkillCon:SetFinishSkillCallBackHandler("SkillController", finishskill2)

	local function finishskillBymain2(_skillID)
		if _skillID ~= self.mRole.mRoleData.mGSID2 then return end
		self.mRole.mArmature:setupToPose()
		self.mRole.mSkillCon:UnRegisterSkillCallBackHandler("SkillController")
	end
	self.mRole.mSkillCon:SetFinishSkillCallBackHandler("SkillController", finishskillBymain2)
	--_partner.mShadow:stopTickZorder(true)
	self.mIsPlayingGS = true
end


-- tick合体绑定
function SkillController:tickCombineSkillBind()
	if not self.mIsPlayingGS then return end
	local _partner = self:getGroupSkillPartner()
	local _posBind = self.mArmature.mSpine:getBonePosition("bind")
	local _posBind_p = _partner.mArmature.mSpine:getBonePosition("bind")
	local _posRole = self.mRole:getPosition_pos()
	local _nextPos = cc.p(_posRole.x, _posRole.y)
	-- 确保伙伴时刻面向自己
	if self.mRole.IsFaceLeft then
	   _partner:FaceRight()
	   _nextPos.x = _nextPos.x - (_posBind.x + _posBind_p.x)
	else
	   _partner:FaceLeft()
	   _nextPos.x = _nextPos.x + _posBind.x + _posBind_p.x
	end
	_partner:setPositionX(_nextPos.x,true)
	_partner:setPositionY(_nextPos.y)
	if self.mRole.mRoleData.mGSMainSub == 1 then
		_partner:setLocalZOrder(self.mRole:getLocalZOrder()-1)
	else
		self.mRole:setLocalZOrder(_partner:getLocalZOrder()-1)
	end
end

function SkillController:setGroupSkillPartner(_partner)
	self.mCombineSkillPartner = _partner
end

function SkillController:getGroupSkillPartner()
	return self.mCombineSkillPartner
end
---------------------------------------------------------------------------------------






--[[ 
	回调
]]
function SkillController:OnFinishSkill(_skill)
	self:OnForcedFinishSkill(_skill)
	if _skill.mType == "pickup_throw" then
	   self.mRole.mPickupCon:OnFinishThrowPickup()
	end
end

--[[
	强行结束技能回调
]]
function SkillController:OnForcedFinishSkill(_skill)
	if self.mCurSkill then
		self.mCurSkill:GroupEffectEnd()
		self.mCurSkill = nil
	end
	-- 解除闪烁无敌
	if self.mRole.Invincible and self.mRole.mRoleData.mRole_DodgeSkill and self.mRole.mRoleData.mRole_DodgeSkill == _skill.mSkillID then
		self.mRole:setInvincible(false)
	end

	-- 解除当前技能挂点
	self.mRole.mArmature:DestoryEffect()

	-- 如果抓投中，释放抓投
	self.mGripCon:ReleaseVictims()

	-------
	if _skill.mType == "pickup" then
	   self.mRole.mPickupCon:OnFinishPickup()
	end
	if _skill.mType == "pickup_hit" then
	   self.mRole.mPickupCon:decreaseUseCount(_skill.mFinalVictimCount)
	end
	if _skill.mType == "shoot_hit" then
		self.mRole.mGunCon:decreaseUseCount(1)
	end

	-- AI回调
	if self.mRole.mAI then
	   self.mRole.mAI:OnSkillFinish(_skill.mSkillID)
	end
	-- 注册的回调
	for k,v in pairs(self.mFinishSkillCallBackTable) do
		v(_skill.mSkillID)
	end
	--如果技能栈中无技能，切回待机
	if #self.mSkillStack == 0 then
	   self.mRole.mFSM:ChangeToStateWithCondition("attacking", "idle")
	end
end