-- Name: 	Shabi
-- Func: 	傻逼
-- Author: 	xxx
-- Data:	16-5-30

local perValue = 300

Shabi = 
{	
	mLeftSeconds_One 	= 0, 	-- 恢复下一点体力所需秒数
	mLeftSeconds_Total 	= 0, 	-- 恢复满体力所需秒数
	mTickHandler 		= nil,	-- 定时器
}	

-- 初始化
function Shabi:init()
	if globaldata.vatality >= globaldata.maxVatality then
		self:stopTick()
	else
		self:openTick()
	end
end

-- 更新
function Shabi:tick()
	self.mLeftSeconds_One = self.mLeftSeconds_One - 1
	self.mLeftSeconds_Total = self.mLeftSeconds_Total - 1
	if self.mLeftSeconds_One <= 0 then
		self.mLeftSeconds_One = 0
	end
	if self.mLeftSeconds_Total <= 0 then
		self.mLeftSeconds_Total = 0
	end
	if 0 == self.mLeftSeconds_One and 0 == self.mLeftSeconds_Total then
		self:stopTick()
	end

--	print("剩余1点时间:", self.mLeftSeconds_One)	

--	print("剩余max点时间:", self.mLeftSeconds_Total)	

	GUIEventManager:pushEvent("shabi", self.mLeftSeconds_One, self.mLeftSeconds_Total)
end

-- 刷新
function Shabi:update()
	if 1 == globaldata:getPlayerBaseData("vatality") - globaldata:getPlayerPreBaseData("vatality") then
		-- 先关闭定时器
		self:stopTick()
		-- 再开启定时器
		self:openTick()
	end
end

-- 开启定时器
function Shabi:openTick()
	if not self.mTickHandler then
		local scheduler = cc.Director:getInstance():getScheduler()
		self.mTickHandler = scheduler:scheduleScriptFunc(handler(self, self.tick), 1, false)

		local deltaTili = globaldata.maxVatality - globaldata.vatality
		if deltaTili > 0 then
			self.mLeftSeconds_One = perValue
			self.mLeftSeconds_Total = perValue*deltaTili
		else
			self.mLeftSeconds_One = 0
			self.mLeftSeconds_Total = 0
		end
	end
end

-- 关闭定时器
function Shabi:stopTick()
	if self.mTickHandler then
		local scheduler = cc.Director:getInstance():getScheduler()
		scheduler:unscheduleScriptEntry(self.mTickHandler)
		self.mTickHandler = nil
		self.mLeftSeconds_One = 0
		self.mLeftSeconds_Total = 0
	end
end 
	
-- 销毁
function Shabi:destroy()

end