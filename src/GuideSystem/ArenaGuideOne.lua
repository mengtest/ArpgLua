-- Name: 	ArenaGuideOne
-- Func：	竞技场指引1
-- Author:	WangShengdong
-- Data:	16-6-28

local guideType = 14

local curStepCount = 0

ArenaGuideOne = {}

ArenaGuideOne.level = 10

-- 指引层
ArenaGuideOne.guideLayer = nil

-- 处于指引过程中
ArenaGuideOne.isInGuiding = false

-- 能否指引
function ArenaGuideOne:canGuide()
	if not needUseGuide then
		return false
	end

	if globaldata.level < self.level then
		return false
	end

	-- 完成不指引
	if self:isFinished() then
		return false
	end

	-- 前置指引必须完成
	if not HeroGuideTwo:isFinished() then
		return false
	end

	return true
end

-- 是否完成
function ArenaGuideOne:isFinished()
	return 1 == GuideSystem:getFinishByGuideType(guideType)
end

-- 中断处理
function ArenaGuideOne:recoverInterrupt()
	if globaldata.level < self.level then
		return false
	end
	if not self:isFinished() then -- 没完成继续指引
		GuideSystem:setFinishByGuideType(guideType, 0)
		GuideSystem:setStepByGuideType(guideType, 1)
	else
		GuideSystem:setFinishByGuideType(guideType, 1)
	end
end

-- 中断处理
function ArenaGuideOne:recoverInterrupt_PVE()
	if globaldata.level < self.level then
		return false
	end
	if not self:isFinished() then -- 没完成继续指引
		GuideSystem:setFinishByGuideType(guideType, 0)
		GuideSystem:setStepByGuideType(guideType, 0)
	else
		GuideSystem:setFinishByGuideType(guideType, 1)
	end
end

-- 设置完成
function ArenaGuideOne:stop()
	local function doStop()
		-- 清理
		if self.guideLayer then
			self.guideLayer:removeFromParent(true)
			self.guideLayer = nil
		end
		-- 设置完成
		GuideSystem:setFinishByGuideType(guideType, 1)
		AnySDKManager:td_task_Complete("新手".."ArenaGuideOne")
		self.isInGuiding = false
	end
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_GUIDE_STEP_, doStop)

	-- 请求指引
    local function requestDoStop()
    	local packet = NetSystem.mNetManager:GetSPacket()
    	packet:SetType(PacketTyper._PTYPE_CS_GUIDE_STEP_)
    	packet:PushChar(guideType)
    	packet:PushChar(curStepCount)
    	packet:PushChar(1)
    	packet:Send()
    end
    requestDoStop()
end

-- 指引操作
function ArenaGuideOne:step(stepCount, touchRect, callBackFunc, callBackFunc2)
	if curStepCount == stepCount then
		return
	end

	if not self:canGuide() then
		return
	end

	-- 已完成则不指引
	if 1 == GuideSystem:getFinishByGuideType(guideType) then
		return 
	end

	-- 不是指定步骤不指引
	if GuideSystem:getStepByGuideType(guideType) + 1 ~= stepCount then
		return 
	end

	-- 清理
	if self.guideLayer then
		self.guideLayer:removeFromParent(true)
		self.guideLayer = nil
	end

	curStepCount = stepCount

	-- 执行指引
    local function doGuide()
    	if 1 == stepCount then
    		AnySDKManager:td_task_begin("新手".."PveGuideOne")
    		self.guideLayer = self:create1Layer(touchRect)
    	elseif 2 == stepCount then -- CG对白指引
    		self.guideLayer = self:create2Layer(touchRect)
    	elseif 3 == stepCount then
    		self.guideLayer = self:create3Layer(touchRect)
    	elseif 4 == stepCount then
    		self.guideLayer = self:create4Layer(callBackFunc)
    	elseif 5 == stepCount then
    		self.guideLayer = self:create5Layer(touchRect)
    	elseif 6 == stepCount then
    		self.guideLayer = self:create6Layer()
    	elseif 7 == stepCount then
    		self.guideLayer = self:create7Layer(callBackFunc)
    	elseif 8 == stepCount then
    		self.guideLayer = self:create8Layer(touchRect)
    	elseif 9 == stepCount then
    		self.guideLayer = self:create9Layer(touchRect, callBackFunc2)
    	elseif 10 == stepCount then
    		self.guideLayer = self:create10Layer(touchRect, callBackFunc2)
    	elseif 11 == stepCount then
    		self.guideLayer = self:create11Layer(touchRect, callBackFunc2)
    	elseif 12 == stepCount then
    		self.guideLayer = self:create12Layer(touchRect, callBackFunc2)
    	end

    	GUISystem:GetRootNode():addChild(self.guideLayer, GUISYS_ZORDER_GUIWINDOW)
    	GUISystem:hideLoading()
    end
    NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_GUIDE_STEP_, doGuide)

     -- 请求指引
    local function requestDoGuide()
    	self.isInGuiding = true
    	local packet = NetSystem.mNetManager:GetSPacket()
    	packet:SetType(PacketTyper._PTYPE_CS_GUIDE_STEP_)
    	packet:PushChar(guideType)
    	packet:PushChar(stepCount)
    	packet:PushChar(0)
    	packet:Send()
    	GUISystem:showLoading()
    end
    requestDoGuide()
end

-- 第一步,进入英雄界面
function ArenaGuideOne:create1Layer(touchRect)
	local layer = GuideSystem:createGuideLayer(touchRect)

	--local girl = GuideSystem:createGuideGirl("点击这里进入学员界面")
	--layer:addChild(girl)
	--girl:setPosition(CanvasToScreen(600, 150))

	GuideSystem:setStepByGuideType(guideType, 1)
	return layer
end

-- 第一步,进入英雄界面
function ArenaGuideOne:create2Layer(touchRect)
	local layer = GuideSystem:createGuideLayer(touchRect)

	--local girl = GuideSystem:createGuideGirl("点击这里进入学员界面")
	--layer:addChild(girl)
	--girl:setPosition(CanvasToScreen(600, 150))

	GuideSystem:setStepByGuideType(guideType, 2)
	return layer
end

-- 第二步,CG对话
function ArenaGuideOne:create3Layer(touchRect)
	local layer = GuideSystem:createGuideLayer(touchRect)

	--local girl = GuideSystem:createGuideGirl("点击这里进入学员界面")
	--layer:addChild(girl)
	--girl:setPosition(CanvasToScreen(600, 150))

	GuideSystem:setStepByGuideType(guideType, 3)
	return layer
end

-- 第二步,进入技能标签
function ArenaGuideOne:create4Layer(callBackFunc)
	local layer = GuideSystem:createGuideCGLayer(218, callBackFunc)
	GuideSystem:setStepByGuideType(guideType, 4)
	return layer
end

-- 第二步,进入技能标签
function ArenaGuideOne:create5Layer(touchRect)
	local layer = GuideSystem:createGuideLayer(touchRect)

	local girl = GuideSystem:createGuideGirl("从这里进入设置防守阵容")
	layer:addChild(girl)
	girl:setPosition(CanvasToScreen(300, 350))

	GuideSystem:setStepByGuideType(guideType, 5)
	return layer
end

-- 第二步,进入技能标签
function ArenaGuideOne:create6Layer()
	local layer = cc.Layer:create()

	local girl = GuideSystem:createGuideGirl("请根据防守策略安排自己实力最强的学员上阵")
	layer:addChild(girl)
	girl:setPosition(CanvasToScreen(200, 50))

	GuideSystem:setStepByGuideType(guideType, 6)
	return layer
end

-- 第二步,进入技能标签
function ArenaGuideOne:create7Layer(callBackFunc)
	local layer = GuideSystem:createGuideCGLayer(219, callBackFunc)
	GuideSystem:setStepByGuideType(guideType, 7)
	return layer
end

-- 第二步,进入技能标签
function ArenaGuideOne:create8Layer(touchRect)
	local layer = GuideSystem:createGuideLayer(touchRect)

	local girl = GuideSystem:createGuideGirl("进行初次挑战，试试自己的身手吧")
	layer:addChild(girl)
	girl:setPosition(CanvasToScreen(500, 150))

	GuideSystem:setStepByGuideType(guideType, 8)
	return layer
end

-- 第二步,进入技能标签
function ArenaGuideOne:create9Layer(touchRect, callBackFunc2)
	local layer = GuideSystem:createShowLayer(touchRect, callBackFunc2)

	local girl = GuideSystem:createGuideGirl("这是敌方防守阵容的第一位学员，请注意他的职业")
	layer:addChild(girl)
	girl:setPosition(CanvasToScreen(150, 200))

	GuideSystem:setStepByGuideType(guideType, 9)
	return layer
end

-- 第二步,进入技能标签
function ArenaGuideOne:create10Layer(touchRect, callBackFunc2)
	local layer = GuideSystem:createShowLayer(touchRect, callBackFunc2)

	local girl = GuideSystem:createGuideGirl("这是敌方防守阵容的第二位学员，请注意他的职业")
	layer:addChild(girl)
	girl:setPosition(CanvasToScreen(350, 200))

	GuideSystem:setStepByGuideType(guideType, 10)
	return layer
end

-- 第二步,进入技能标签
function ArenaGuideOne:create11Layer(touchRect, callBackFunc2)
	local layer = GuideSystem:createShowLayer(touchRect, callBackFunc2)

	local girl = GuideSystem:createGuideGirl("这是敌方防守阵容的第三位学员，请注意他的职业")
	layer:addChild(girl)
	girl:setPosition(CanvasToScreen(550, 200))

	GuideSystem:setStepByGuideType(guideType, 11)
	return layer
end

-- 第二步,进入技能标签
function ArenaGuideOne:create12Layer(touchRect, callBackFunc2)
	local layer = GuideSystem:createShowLayer(touchRect, callBackFunc2, true)

	local girl = GuideSystem:createGuideGirl("根据敌方阵容的学员属性，选择自己的战队成员")
	layer:addChild(girl)
	girl:setPosition(CanvasToScreen(450, 100))

	GuideSystem:setStepByGuideType(guideType, 12)
	return layer
end
