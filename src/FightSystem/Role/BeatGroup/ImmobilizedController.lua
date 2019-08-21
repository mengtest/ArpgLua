-- Name: 定身控制器
-- Author: tuanzhang

ImmobilizedController = class("ImmobilizedController")


function ImmobilizedController:ctor(_role)
	self.mRole = _role
	self.mDuring = 0
	self.mStopTick = false
end

function ImmobilizedController:Destroy()
	self.mRole = nil
	self.mDuring = nil
	self.mStopTick = nil
end

function ImmobilizedController:Tick(delta)
	if self.mStopTick then return end
	if self.mDuring > 0 then
	   self.mDuring = self.mDuring - 1
	   if self.mDuring == 0 then
	   	  self:finishImmobilized()
	   end
	end
end

-- 冰冻开始
-- 1. 暂停骨骼动作
-- 2. 结束当前技能
-- 3. 添加冰冻特效
function ImmobilizedController:Start(_dbSt, _dbSkillEff, _hiter)
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
		self:addImmobilizedEffect()
		if _dbSt.StateDisplayText ~= 0 then
			self.mRole.mFlowLabelCon:FlowBuffName( getDictionaryText(_dbSt.StateDisplayText))
		end
	end
end

-- 添加定身特效
function ImmobilizedController:addImmobilizedEffect()
	local _effID = self.mDB.LightEffect1[1]
	if _effID == 0 then
		return
	end
	local _dbRes = DB_ResourceList.getDataById(_effID)
	self.mICE = CommonAnimation.createCacheSpine_commonByResID(_effID, self.mRole.mArmature)
	self.mICE:setLocalZOrder(self.mDB.LightEffect1[2])
	self.mICE:setAnimation(0, "start", true)
end

-- 取消定身
function ImmobilizedController:cancelImmobilized()
	if not self.mRole then return end
	self.mRole.mArmature.mSpine:setStopTick(false)
	self.mRole.mArmature:pauseSkillEffect(false)
	self.mDuring = 0
	self.mRole.mFEM:ChangeToBeatEffect(0)
	self.mRole.mBeatCon:cancelTrapBuffID(self.mDB.ID)
	SpineDataCacheManager:collectFightSpineByAtlas(self.mICE)
	self.mICE = nil
end

function ImmobilizedController:finishImmobilized()
	if not self.mRole then return end
	self.mRole.mArmature.mSpine:setStopTick(false)
	self.mRole.mArmature:pauseSkillEffect(false)
	self.mDuring = 0
	self.mRole.mFEM:ChangeToBeatEffect(0)
	self.mRole.mFSM:ChangeToStateWithCondition("becontroled" ,"idle")
	self.mRole.mBeatCon:cancelTrapBuffID(self.mDB.ID)
	SpineDataCacheManager:collectFightSpineByAtlas(self.mICE)
	self.mICE = nil
end