-- Name: KnockBackController
-- Author: Johny

KnockBackController = class("KnockBackController")

local _beBlowUpEnd2_ = "beBlowUpEnd2"
local _beBlowUpStand2_ = "beBlowUpStand2"
function KnockBackController:ctor(_role)
	self.mRole = _role
	self.mFEM = self.mRole.mFEM
	self.mHiter = nil
	self.mDuring = 0
	self.mDis = 0
end

function KnockBackController:Destroy()
	self.mRole = nil
	self.mHiter = nil
	self.mDuring = 0
	self.mDis = 0
end


function KnockBackController:Tick(delta)
	if self.mRole:IsControlByStaticFrameTime() then return end
	if self.IsBlowUpEnd2 then
		if self.mHoutuiDis and self.mHoutuiDis == 0 then return end
		if self.mHoutuiDis > 0  then
			if self.mV <= 0 then return end
		else
			if self.mV >= 0 then return end
		end
		local Vt = MathExt.GetV1InUniformDeceleration(self.mV, self.mA, 1)
		local dis = (self.mV+Vt)/2
		self:KnockBack(dis)
	end

	if self.mDuring > 0 then
		if self.mExcuteMethod == 11 then
			local Vt = MathExt.GetV1InUniformDeceleration(self.mV, self.mA, 1)
			local dis = (self.mV+Vt)/2
			self:KnockBack(dis)
			self.mV = Vt
		   self.mDuring = self.mDuring - 1
		   if self.mDuring == 0 then
		   	  self:finish()
		   end
		else
			local _x = self.mRole:getPositionX()
			self:KnockBack(self.mAverageDis*FightSystem:getGameSpeedScale())
			if _x == self.mRole:getPositionX() then
				self.mDuring = 0
				self.IsBlowUpEnd2 = true
				self.mRole.mArmature:ActionNow(_beBlowUpEnd2_)
				return
			end

			self.mDuring = self.mDuring - 1
			if self.mDuring == 0 then
				self.IsBlowUpEnd2 = true
				self.mRole.mArmature:ActionNow(_beBlowUpEnd2_)
		   	end
		end
	end
end

function KnockBackController:Start(_dbSt, _dbSkillEff, _hiter)
	self.mDB = _dbSt
	self.mDuring = _dbSt.LastTime
	self.mExcuteMethod = _dbSkillEff.ExcuteMethod
	self.mDis = _dbSkillEff.Data1
	self.mAverageDis = self.mDis/self.mDuring
	self.mDaodiTime = _dbSkillEff.Data2
	self.mHoutuiDis = _dbSkillEff.Data3
	self.mHiter = _hiter
	if self.mExcuteMethod == 11 then
		self.mV, self.mA = MathExt.GetAandV0InUniformDeceleration_0(self.mDis, self.mDuring)
		self.mRole.mArmature:ActionNowWithSpeedScale("injured2",10/self.mDuring)
	else
		self.mV, self.mA = MathExt.GetAandV0InUniformDeceleration_0(self.mHoutuiDis, 13)
		self.mRole.mArmature:ActionNowWithSpeedScale("beKnockBack",6/self.mDuring)
	end
	

	self.mRole.mArmature:RegisterActionEnd("KnockBackController",handler(self, self.OnActionEvent))
end

function KnockBackController:OnActionEvent(_action)
	if _action == _beBlowUpEnd2_ then
		self.IsBlowUpEnd2 = false
		self:finish()
	elseif _action == _beBlowUpStand2_ then
		if not self.mRole.mPropertyCon:IsHpEmpty() then
			self.mRole.mFSM:ForceChangeToState("idle")
		end
	end
end

function KnockBackController:KnockBack(_dis)
	self.mRole:BackDis(_dis)
end

function KnockBackController:cancelKnockBack()
	self.mDuring = 0
	self.mDis = 0
	self.mHiter = nil
	self.IsBlowUpEnd2 = nil
end

function KnockBackController:finish()
	if not self.mRole.mFEM:IsBeatStBack() then return end
	if self.mDaodiTime > 0 then
		self.mRole.mFEM:ChangeToBeatEffect(0)
		if self.mRole.mPropertyCon:IsHpEmpty() then
			self.mRole.mFSM:ForceChangeToState("dead")
		else
			self.mRole.mFSM:ForceChangeToState("falldown")
		end
		self.mRole.mBeatCon.mFalldownCon:Start("",_beBlowUpStand2_,self.mDaodiTime,nil,self.mDB.ID)
	else
		self.mRole.mFEM.mCurBeatEffect = "none"
		self.mRole.mFSM:ChangeToStateWithCondition("becontroled" ,"idle")
		self.mRole.mBeatCon:cancelTrapBuffID(self.mDB.ID)
	end
end