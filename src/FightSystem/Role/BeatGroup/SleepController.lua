-- Name: 昏睡控制器
-- Author: Johny

SleepController = class("SleepController")


function SleepController:ctor(_role)
	self.mRole = _role
	self.mDuring = 0
end

function SleepController:Destroy()
	self.mRole = nil
	self.mDuring = nil
end

function SleepController:Tick(delta)
	if self.mDuring > 0 then
	   self.mDuring = self.mDuring - 1
	   if self.mDuring == 0 then
	   	  self:finishSleep()
	   end
	end
end

function SleepController:Start(_dbSt, _dbSkillEff, _hiter)
	self.mDB = _dbSt
	self.mDuring = _dbSt.LastTime
	self.mUnlockRate = _dbSkillEff.Data1
	self.mRole.mArmature:ActionNow("beBlowUpEnd")
	FightSystem:RegisterNotifaction("roledamaged", "SleepController", handler(self, self.damagedInSleep))
end

-- 昏睡中受伤害
function SleepController:damagedInSleep()
	local _tmpRate = self.mUnlockRate * 100
	local _random = math.random(1, 100)
	if _random <= _tmpRate then
	   self:finishSleep()
	end
end

function SleepController:finishSleep()
	FightSystem:UnRegisterNotification("roledamaged", "SleepController")
	self.mDuring = 0
	local _tb = {self.mDB}
	self.mRole.mFEM:ChangeToBeatEffect(0, _tb)
	self.mRole.mFSM:ChangeToStateWithCondition("becontroled" ,"idle")
	self.mRole.mBeatCon:cancelTrapBuffID(self.mDB.ID)
end