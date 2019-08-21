-- Name: 	PveGuide1_6
-- Func：	副本指引1-6
-- Author:	WangShengdong
-- Data:	16-7-8

local guideType = 28

local curStepCount = 0

PveGuide1_6 = {}

PveGuide1_6.level = 6

-- 指引层
PveGuide1_6.guideLayer = nil

-- 处于指引过程中
PveGuide1_6.isInGuiding = false

-- 能否指引
function PveGuide1_6:canGuide()
	if not needUseGuide then
		return false
	end

	-- 完成不指引
	if self:isFinished() then
		return false
	end

	-- 等级必须足够
	if globaldata.level < self.level then
		return false
	end

	-- 前置指引必须完成
	if not EquipGuideOne:isFinished() then
		return false
	end

	return true
end

-- 是否完成
function PveGuide1_6:isFinished()
	return 1 == GuideSystem:getFinishByGuideType(guideType)
end

-- 中断处理
function PveGuide1_6:recoverInterrupt()
	-- 等级必须足够
	if globaldata.level < self.level then
		return false
	end

	-- 前置指引必须完成
	if not EquipGuideOne:isFinished() then
		return false
	end

	if globaldata:isSectionOpened(1, 6, 1) then
		if not globaldata:isChapterFinished(1, 6, 1) then -- 第三关没通关继续指引
			GuideSystem:setFinishByGuideType(guideType, 0)
			GuideSystem:setStepByGuideType(guideType, 2)
		else
			GuideSystem:setFinishByGuideType(guideType, 1)
		end
	end
end

-- 中断处理
function PveGuide1_6:recoverInterrupt_PVE()
	-- 等级必须足够
	if globaldata.level < self.level then
		return false
	end

	-- 前置指引必须完成
	if not EquipGuideOne:isFinished() then
		return false
	end
	
	if globaldata:isSectionOpened(1, 6, 1) then
		if not globaldata:isChapterFinished(1, 6, 1) then -- 第三关没通关继续指引
			GuideSystem:setFinishByGuideType(guideType, 0)
			GuideSystem:setStepByGuideType(guideType, 2)
		else
			GuideSystem:setFinishByGuideType(guideType, 1)
		end
	end
end

-- 设置完成
function PveGuide1_6:stop()
	local function doStop()
		-- 清理
		if self.guideLayer then
			self.guideLayer:removeFromParent(true)
			self.guideLayer = nil
		end
		-- 设置完成
		GuideSystem:setFinishByGuideType(guideType, 1)
		AnySDKManager:td_task_Complete("新手".."PveGuide1_6")
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
function PveGuide1_6:step(stepCount, touchRect, callBackFunc, callBackFunc2)
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
    		AnySDKManager:td_task_begin("新手".."PveGuide1_6")
    		self.guideLayer = self:create1Layer(touchRect)
    		
    	elseif 2 == stepCount then -- CG对白指引
    		self.guideLayer = self:create2Layer(callBackFunc)
    	elseif 3 == stepCount then
    		self.guideLayer = self:create3Layer(touchRect)
    	elseif 4 == stepCount then
    		self.guideLayer = self:create4Layer(touchRect)
    	elseif 5 == stepCount then
    		self.guideLayer = self:create5Layer(touchRect)
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
function PveGuide1_6:create1Layer(touchRect)
	local layer = GuideSystem:createGuideLayer(touchRect)

	--local girl = GuideSystem:createGuideGirl("点击这里进入学员界面")
	--layer:addChild(girl)
	--girl:setPosition(CanvasToScreen(600, 150))

	GuideSystem:setStepByGuideType(guideType, 1)
	return layer
end

-- 第一步,进入英雄界面
function PveGuide1_6:create2Layer(callBackFunc)
	local layer = GuideSystem:createGuideCGLayer(206, callBackFunc)
	GuideSystem:setStepByGuideType(guideType, 2)
	return layer
end

-- 第二步,CG对话
function PveGuide1_6:create3Layer(touchRect)
	local layer = GuideSystem:createGuideLayer(touchRect)

	--local girl = GuideSystem:createGuideGirl("点击这里进入学员界面")
	--layer:addChild(girl)
	--girl:setPosition(CanvasToScreen(600, 150))

	GuideSystem:setStepByGuideType(guideType, 3)
	return layer
end

-- 第二步,进入技能标签
function PveGuide1_6:create4Layer(touchRect, callBackFunc2)
	local layer = GuideSystem:createGuideLayer(touchRect)

	--local girl = GuideSystem:createGuideGirl("点击这里进入学员界面")
	--layer:addChild(girl)
	--girl:setPosition(CanvasToScreen(600, 150))

	GuideSystem:setStepByGuideType(guideType, 4)
	return layer
end

-- 第二步,进入技能标签
function PveGuide1_6:create5Layer(touchRect)
	local layer = GuideSystem:createGuideLayer(touchRect)

	--local girl = GuideSystem:createGuideGirl("进行初次挑战，试试自己的身手吧")
	--layer:addChild(girl)
	--girl:setPosition(CanvasToScreen(550, 150))

	GuideSystem:setStepByGuideType(guideType, 5)
	return layer
end
