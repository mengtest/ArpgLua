-- Func: 抓投控制器
-- Author: Johny

GripController = class("GripController")

function GripController:ctor(_role, _skillCon)
	self.mRole = _role
	self.mSkillCon = _skillCon
	self.mVictims = {}
end

function GripController:Destroy()
	self.mRole = nil
	self.mSkillCon = nil
	self.mVictims = nil
end

function GripController:Tick()
end

-- 抓投这帮人
function GripController:GripVictims(_dbprogress)
	local _list = self:FindVictim(_dbprogress)
	for k,victim in pairs(_list) do
		table.insert(self.mVictims, victim)
		if _dbprogress.GripTargetAct[1] ~= "" then
			victim.mBeatCon.mBeatGripedCon:OnGriped(self.mRole, _dbprogress.GripTargetAct)
		end	
	end

	return #self.mVictims ~= 0
end

-- 腾空抓人
function GripController:GripVictimsAir(_dbprogress)
	local _list = self:FindVictim(_dbprogress)
	for k,victim in pairs(_list) do
		table.insert(self.mVictims, victim)
		victim.mShadow:stopTickMoveY(true)
		if _dbprogress.GripTargetAct[1] ~= "" then
			victim.mBeatCon.mBeatGripedCon:OnGripedAir(self.mRole, _dbprogress.GripTargetAct)
		end	
	end

	return #self.mVictims ~= 0
end

function GripController:HandleChangeGripTargetAct(_dbprogress)
	for k,victim in pairs(self.mVictims) do
		if victim.mBeatCon then
			victim.mBeatCon.mBeatGripedCon:OnGripTargetAct(_dbprogress)
		end
	end
end

function GripController:HandleGripedVictims(_rotate ,_hiter)
	for k,victim in pairs(self.mVictims) do
		if victim.mBeatCon then
			victim.mBeatCon.mBeatGripedCon:OnRotated(_rotate,_hiter)
		end
	end
end

function GripController:HandleGripedVictimsAir(_rotate ,_hiter)
	for k,victim in pairs(self.mVictims) do
		if victim.mBeatCon then
			victim.mBeatCon.mBeatGripedCon:OnRiseed(_hiter)
		end
	end
end

function GripController:FindVictim(_dbprogress)
	local list = {}
	local _victimCount = FightSystem.mRoleManager:GetVicmCount(self.mRole)
	local GripNum = 0
	for i = 1, _victimCount do
		local _victim = FightSystem.mRoleManager:GetVicim(i, self.mRole)
		if _victim and not _victim:hasNoControlBuffNow() and _victim:canbeGriped() and self.mSkillCon:IsInSkillRange("role" , _dbprogress, _victim) then
			table.insert(list, _victim)
			GripNum = GripNum + 1
			if _dbprogress.GripNum == GripNum then
			break end
		end
	end

	return list
end

-- 释放抓投者
function GripController:ReleaseVictims(_dbprogress)
	if not _dbprogress then  
		-- 通常为打断抓投
		for k,victim in pairs(self.mVictims) do
			if victim.mBeatCon then
				victim.mBeatCon.mBeatGripedCon:OnGripReleased()
			end
		end
	else
		-- 正常结束
		local _needReverse = _dbprogress.GripOverTurnRound
		for k,victim in pairs(self.mVictims) do
			if victim.mFSM:IsBeGriped() then
				if victim.mBeatCon then
					victim.mBeatCon.mBeatGripedCon:OnGripReleased(_needReverse)
				end
			end
		end
	end
	self.mVictims = {}
end