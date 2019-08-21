-- Func: 召唤控制器
-- Author: Johny

SummonController = class("SummonController")


function SummonController:ctor(_role)
	self.mRole = _role
	self.mSummons = {}
end

function SummonController:Destroy()
	self.mRole = nil
	for k,summon in pairs(self.mSummons) do
		summon:RemoveSelfOlPvpSummon()
	end
	self.mSummons = nil
end

function SummonController:Tick()
	self:tickDuring()
end

function SummonController:addSummon(_id, _offPos, _during)
	local _pos = cc.p(self.mRole:getPositionX() + _offPos[1], self.mRole:getPositionY() + _offPos[2])
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
	local _summon = FightSystem.mRoleManager:LoadSummon(_id, _pos, self.mRole.mGroup,self.mRole.mSceneIndex)
	_summon:copyProperty(self.mRole.mPropertyCon)
	_summon.mHost = self.mRole
	_summon.mDuring = _during
	table.insert(self.mSummons, _summon)
end

function SummonController:tickDuring()
	for k,summon in pairs(self.mSummons) do
		summon.mDuring = summon.mDuring - 1
		if summon.mDuring == 0 then
		   summon:RemoveSelfSummon()
		   table.remove(self.mSummons, k)
		end
	end
end
