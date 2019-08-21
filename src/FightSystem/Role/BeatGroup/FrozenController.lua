-- Name: 冰冻控制器
-- Author: Johny

FrozenController = class("FrozenController")


function FrozenController:ctor(_role)
	self.mRole = _role
	self.mDuring = 0
	self.mStopTick = false
	self.mICE = nil
end

function FrozenController:Destroy()
	if self.mShaderScheduleHandler then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.mShaderScheduleHandler)
		self.mShaderScheduleHandler = nil
	end
	SpineDataCacheManager:collectFightSpineByAtlas(self.mICE)
	self.mICE = nil
	self.mRole = nil
	self.mDuring = nil
	self.mStopTick = nil
end

function FrozenController:Tick(delta)
	if self.mStopTick then return end
	if self.mDuring > 0 then
	   self.mDuring = self.mDuring - 1
	   if self.mDuring == 0 then
	   	  self:finishFrozen()
	   end
	end
end

-- 冰冻开始
-- 1. 暂停骨骼动作
-- 2. 结束当前技能
-- 3. 添加冰冻特效
function FrozenController:Start(_dbSt, _dbSkillEff, _hiter)
	if self.mDuring > 0 then
		self.mDB = _dbSt
		self.mDuring = _dbSt.LastTime
		self.mRole.mArmature.mSpine:setStopTick(true)
		self.mRole.mArmature:pauseSkillEffect(true)
		self.mRole:pauseActionAndFinishCurSkill()
	else
		self.mDB = _dbSt
		--FightSystem:RegisterNotifaction("fireddamage", "FrozenController",handler(self, self.firedInFrozen))
		self.mDuring = _dbSt.LastTime
		self.mUnlockRate = _dbSkillEff.Data1
		self.mRole.mArmature.mSpine:setStopTick(true)
		self.mRole.mArmature:pauseSkillEffect(true)
		self.mRole:pauseActionAndFinishCurSkill()
		self:addFrozenEffect()
		if _dbSt.StateDisplayText ~= 0 then
			self.mRole.mFlowLabelCon:FlowBuffName( getDictionaryText(_dbSt.StateDisplayText))
		end
	end
end

-- 添加冰冻特效
function FrozenController:addFrozenEffect()
	local _effID = self.mDB.LightEffect1[1]
	local _dbRes = DB_ResourceList.getDataById(_effID)
	self.mICE = CommonAnimation.createCacheSpine_commonByResID(_effID, self.mRole.mArmature)
	self.mICE:registerSpineEventHandler(handler(self, self.onAnimationEvent), 1)
	local w = self.mRole.mArmature:getSize().width
	local h = self.mRole.mArmature:getSize().height
	self.mICE:setScaleX(w/310)
	self.mICE:setScaleY(h/350)
	self.mICE:setLocalZOrder(self.mDB.LightEffect1[2])
	self.mICE:setAnimation(0, "start", true)
	local _color1 = cc.vec4(0.09, 0.73, 0.89, 1.0)
	local _color2 = cc.vec4(0.09, 0.73, 0.89, 1.0)
	self.mShaderScheduleHandler = CommonAnimation.Spine_ColorChangeBetween2(self.mRole.mArmature.mSpine, _color1, _color2,nil,"FrozenController")
end

-- 冰冻死亡
function FrozenController:FrozenDead(_fun)
	self.mCallFun = _fun
	self.mStopTick = true
	self.mICE:setAnimation(0, "dead", false)
end

function FrozenController:onAnimationEvent(event)
	if event.type == 'end' then
		if event.animation == "dead" then
			if self.mICE then
				SpineDataCacheManager:collectFightSpineByAtlas(self.mICE)
				self.mICE = nil
			end
			if self.mCallFun then
				self.mCallFun()
				self.mCallFun = nil
			end
		end
	end
end

-- 受火系伤害
function FrozenController:firedInFrozen()
	self:finishFrozen()
end

-- 取消冰冻
function FrozenController:cancelFrozen()
	if not self.mRole then return end
	if self.mICE  then
		self.mRole.mArmature.mSpine:setStopTick(false)
		self.mRole.mArmature:pauseSkillEffect(false)
		self.mDuring = 0
		self.mRole.mFEM:ChangeToBeatEffect(0)
		if self.mShaderScheduleHandler then
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.mShaderScheduleHandler)
			self.mShaderScheduleHandler = nil
		end
		self.mRole.mBeatCon:cancelTrapBuffID(self.mDB.ID)
		SpineDataCacheManager:collectFightSpineByAtlas(self.mICE)
		self.mICE = nil
		ShaderManager:ResumeColor_spine(self.mRole.mArmature.mSpine)
	end
end

function FrozenController:finishFrozen()
	if not self.mRole then return end
	--FightSystem:UnRegisterNotification("fireddamage", "FrozenController")
	self.mRole.mArmature.mSpine:setStopTick(false)
	self.mRole.mArmature:pauseSkillEffect(false)
	self.mDuring = 0
	self.mRole.mFEM:ChangeToBeatEffect(0)
	self.mRole.mFSM:ChangeToStateWithCondition("becontroled" ,"idle")
	self.mRole.mBeatCon:cancelTrapBuffID(self.mDB.ID)
	SpineDataCacheManager:collectFightSpineByAtlas(self.mICE)
	self.mICE = nil
	if self.mShaderScheduleHandler then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.mShaderScheduleHandler)
		self.mShaderScheduleHandler = nil
	end
	ShaderManager:ResumeColor_spine(self.mRole.mArmature.mSpine)
end