-- Name: 	HardPveGuideOne
-- Func：	精英指引1
-- Author:	WangShengdong
-- Data:	16-6-29

local guideType = 22

local curStepCount = 0

HardPveGuideOne = {}

-- 指引层
HardPveGuideOne.guideLayer = nil

-- 处于指引过程中
HardPveGuideOne.isInGuiding = false

-- 能否指引
function HardPveGuideOne:canGuide()
	if not needUseGuide then
		return false
	end

	-- 完成不指引
	if self:isFinished() then
		return false
	end

	-- 2-8通关
	if not globaldata:isChapterFinished(2, 8, 1) then
		return false
	end

	return true
end

-- 是否完成
function HardPveGuideOne:isFinished()
	return 1 == GuideSystem:getFinishByGuideType(guideType)
end

-- 中断处理
function HardPveGuideOne:recoverInterrupt()
	if not self:isFinished() then -- 没做完继续指引
		GuideSystem:setFinishByGuideType(guideType, 0)
		GuideSystem:setStepByGuideType(guideType, 0)
	end
end

-- 中断处理
function HardPveGuideOne:recoverInterrupt_PVE()
	if not self:isFinished() then -- 没做完继续指引
		GuideSystem:setFinishByGuideType(guideType, 0)
		GuideSystem:setStepByGuideType(guideType, 0)
	end
end

-- 设置完成
function HardPveGuideOne:stop()
	local function doStop()
		-- 清理
		if self.guideLayer then
			self.guideLayer:removeFromParent(true)
			self.guideLayer = nil
		end
		-- 设置完成
		GuideSystem:setFinishByGuideType(guideType, 1)
		AnySDKManager:td_task_Complete("新手".."HardPveGuideOne")
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
function HardPveGuideOne:step(stepCount, touchRect, callBackFunc, callBackFunc2)
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
    		AnySDKManager:td_task_begin("新手".."HardPveGuideOne")
    		self.guideLayer = self:create1Layer(touchRect)
    	elseif 2 == stepCount then -- CG对白指引
    		self.guideLayer = self:create2Layer(callBackFunc)
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
function HardPveGuideOne:create1Layer(touchRect)
	local layer = GuideSystem:createGuideLayer(touchRect)

	local girl = GuideSystem:createGuideGirl("精英关卡开启，快来迎接新挑战")
	layer:addChild(girl)
	girl:setPosition(CanvasToScreen(300, 200))

	GuideSystem:setStepByGuideType(guideType, 1)
	return layer
end

-- 第一步,进入英雄界面
function HardPveGuideOne:create2Layer(callBackFunc)
	local layer = GuideSystem:createGuideCGLayer(222, callBackFunc)
	GuideSystem:setStepByGuideType(guideType, 2)
	return layer
end
