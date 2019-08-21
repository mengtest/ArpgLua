-- Name: KnockStunedController
-- Author: Johny

KnockStunedController = class("KnockStunedController")


function KnockStunedController:ctor(_role)
	self.mRole = _role
	self.mDuring = 0
end

function KnockStunedController:Destroy()
	self.mRole = nil
	self.mDuring = 0
end

function KnockStunedController:Tick(delta)
	if self.mDuring > 0 then
	   self.mDuring = self.mDuring - 1
	   if self.mDuring == 0 then
	   	  self:finish()
	   end
	end
end

function KnockStunedController:Start(_dbSt, _dbSkillEff, _hiter)
	self.mDB = _dbSt
	if self.mDuring > _dbSt.LastTime then return end
	self.mDuring = _dbSt.LastTime
	self.mRole.mArmature:ActionNow("beStunned",true)
end

function KnockStunedController:finish()
	if not self.mRole.mFEM:IsBeatStstunned() then return end
	self.mRole.mFEM.mCurBeatEffect = "none"
	self.mRole.mFSM:ChangeToStateWithCondition("becontroled" ,"idle")
	self.mRole.mBeatCon:cancelTrapBuffID(self.mDB.ID)
end