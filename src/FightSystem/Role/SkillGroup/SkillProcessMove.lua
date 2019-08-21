-- Func: 技能过程中的移动
-- Author: Johny

SkillProcessMove = class("SkillProcessMove")

function SkillProcessMove:ctor(_role, _db, _during)
	self.mRole = _role
	self.ProID = _db.ID
	local _type = _db.MoveType
	local _dis = _db.MinMoveDistance
	local _direction = _db.MoveDirection
	_dis = _dis * math.cos(math.rad(_direction))
	self.mDis = _dis
	if _type == 1 then
	   self.mV0 = _dis / _during
	else
	   self.mV0 = _dis / _during
	end
end

function SkillProcessMove:Tick(delta)
	if self.mRole:hasBoundBuffNow() then return end
	local _disX = self.mV0*FightSystem:getGameSpeedScale()
	if self.mDis > 1 or self.mDis < -1 then 
		self.mDis = self.mDis - _disX
		self.mRole:ForwardDis(_disX) 
	end
end

function SkillProcessMove:ArriveDis()
	if self.mRole:hasBoundBuffNow() then return end
	self.mRole:ForwardDis(self.mDis)
end
