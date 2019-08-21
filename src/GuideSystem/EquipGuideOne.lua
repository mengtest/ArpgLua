-- Name: 	EquipGuideOne
-- Func：	装备指引1
-- Author:	WangShengdong
-- Data:	16-6-29

local guideType = 17

local curStepCount = 0

EquipGuideOne = {}

EquipGuideOne.level = 6

-- 指引层
EquipGuideOne.guideLayer = nil

-- 处于指引过程中
EquipGuideOne.isInGuiding = false

-- 能否指引
function EquipGuideOne:canGuide()
	if not needUseGuide then
		return false
	end

	-- 完成不指引
	if self:isFinished() then
		return false
	end

	if globaldata.level < self.level then
		return false
	end

	if not LevelRewardGuideOne:isFinished() then
		return false
	end

	return true
end

-- 是否完成
function EquipGuideOne:isFinished()
	return 1 == GuideSystem:getFinishByGuideType(guideType)
end

-- 中断处理
function EquipGuideOne:recoverInterrupt()
	if globaldata.level < self.level then
		return false
	end
	if not LevelRewardGuideOne:isFinished() then
		return false
	end
	if GuideSystem:getStepByGuideType(guideType) > 3 then -- 第一关没通关继续指引
		GuideSystem:setFinishByGuideType(guideType, 1)
	else
		GuideSystem:setFinishByGuideType(guideType, 0)
		GuideSystem:setStepByGuideType(guideType, 1)
	end
end

-- 中断处理
function EquipGuideOne:recoverInterrupt_PVE()
	-- if globaldata.level < self.level then
	-- 	return false
	-- end
	-- if GuideSystem:getStepByGuideType(guideType) > 3 then -- 第一关没通关继续指引
	-- 	GuideSystem:setFinishByGuideType(guideType, 1)
	-- else
	-- 	GuideSystem:setFinishByGuideType(guideType, 0)
	-- 	GuideSystem:setStepByGuideType(guideType, 0)
	-- end
end

-- 设置完成
function EquipGuideOne:stop()
	local function doStop()
		-- 清理
		if self.guideLayer then
			self.guideLayer:removeFromParent(true)
			self.guideLayer = nil
		end
		-- 设置完成
		GuideSystem:setFinishByGuideType(guideType, 1)
		AnySDKManager:td_task_Complete("新手".."EquipGuideOne")
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
function EquipGuideOne:step(stepCount, touchRect, callBackFunc, callBackFunc2)
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
    	-- 清理
		if self.guideLayer then
			self.guideLayer:removeFromParent(true)
			self.guideLayer = nil
		end
    	
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
    		self.guideLayer = self:create6Layer(touchRect)
    	elseif 7 == stepCount then
    		self.guideLayer = self:create7Layer(callBackFunc)
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
function EquipGuideOne:create1Layer(touchRect)
	local layer = GuideSystem:createGuideLayer(touchRect)

	--local girl = GuideSystem:createGuideGirl("点击这里进入学员界面")
	--layer:addChild(girl)
	--girl:setPosition(CanvasToScreen(600, 150))

	GuideSystem:setStepByGuideType(guideType, 1)
	return layer
end

-- 第一步,进入英雄界面
function EquipGuideOne:create2Layer(touchRect)
	local layer = GuideSystem:createGuideLayer(touchRect)

	--local girl = GuideSystem:createGuideGirl("点击这里进入学员界面")
	--layer:addChild(girl)
	--girl:setPosition(CanvasToScreen(600, 150))

	GuideSystem:setStepByGuideType(guideType, 2)
	return layer
end

-- 第二步,CG对话
function EquipGuideOne:create3Layer(touchRect)
	local layer = GuideSystem:createGuideLayer(touchRect)

	--local girl = GuideSystem:createGuideGirl("点击这里进入学员界面")
	--layer:addChild(girl)
	--girl:setPosition(CanvasToScreen(600, 150))

	GuideSystem:setStepByGuideType(guideType, 3)
	return layer
end

-- 第二步,进入技能标签
function EquipGuideOne:create4Layer(callBackFunc)
	local layer = GuideSystem:createGuideCGLayer(209, callBackFunc)
	GuideSystem:setStepByGuideType(guideType, 4)
	return layer
end

-- 第二步,进入技能标签
function EquipGuideOne:create5Layer(touchRect)
	local layer = GuideSystem:createGuideLayer(touchRect)

	local girl = GuideSystem:createGuideGirl("点击一次#16ff04强化#，可将装备#16ff04提升1级#")
	layer:addChild(girl)
	girl:setPosition(CanvasToScreen(550, 300))

	GuideSystem:setStepByGuideType(guideType, 5)
	return layer
end

-- 第二步,进入技能标签
function EquipGuideOne:create6Layer(touchRect)
	local layer = GuideSystem:createGuideLayer(touchRect)

	local girl = GuideSystem:createGuideGirl("使用#16ff04一键强化#，可轻松强化所有装备")
	layer:addChild(girl)
	girl:setPosition(CanvasToScreen(450, 50))

	GuideSystem:setStepByGuideType(guideType, 6)
	return layer
end

-- 第二步,进入技能标签
function EquipGuideOne:create7Layer(callBackFunc)
	local layer = GuideSystem:createGuideCGLayer(210, callBackFunc)
	GuideSystem:setStepByGuideType(guideType, 7)
	return layer
end
