

MonsterObject = class("MonsterObject")

function MonsterObject:ctor()
	self.ID = nil
	self.Type = nil
	self.DelayTime = nil
	self.PositionX = nil
	self.PositionY = nil
	self.tickTime = 0
end

function MonsterObject:BornByTriggerid(_Triggerid)
	if self.DelayTime[1] == 2 then
		if self.DelayTime[2] == _Triggerid then
			return true
		end
	end
	return false
end

function MonsterObject:TickBorn(delta)
	--return false
	self.tickTime = self.tickTime + delta
	if self.DelayTime[1] == 1 then
		if self.DelayTime[2] <= self.tickTime then
			return true
		end	
	end
	return false
end


function MonsterObject:PrestrainBorn()
	--return false
	if self.DelayTime[1] == 1 then
		if self.DelayTime[2] == -1 then
			return true
		end	
	end
	return false
end





