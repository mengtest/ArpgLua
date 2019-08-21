-- Name: 	ArenaGuideTwo
-- Func：	竞技场指引2
-- Author:	WangShengdong
-- Data:	16-6-28

local guideType = 15

local curStepCount = 0

ArenaGuideTwo = {}

-- 指引层
ArenaGuideTwo.guideLayer = nil

-- 处于指引过程中
ArenaGuideTwo.isInGuiding = false

-- 能否指引
function ArenaGuideTwo:canGuide()
	if not needUseGuide then
		return false
	end

	-- 完成不指引
	if self:isFinished() then
		return false
	end

	-- 前置指引必须完成
	if not ArenaGuideOne:isFinished() then
		return false
	end

	return true
end

-- 是否完成
function ArenaGuideTwo:isFinished()
	return 1 == GuideSystem:getFinishByGuideType(guideType)
end

-- 中断处理
function ArenaGuideTwo:recoverInterrupt()
	if not self:isFinished() then -- 没完成继续指引
		GuideSystem:setFinishByGuideType(guideType, 0)
		GuideSystem:setStepByGuideType(guideType, 0)
	else
		GuideSystem:setFinishByGuideType(guideType, 1)
	end
end

-- 设置完成
function ArenaGuideTwo:stop()
	local function doStop()
		-- 清理
		if self.guideLayer then
			self.guideLayer:removeFromParent(true)
			self.guideLayer = nil
		end
		-- 设置完成
		GuideSystem:setFinishByGuideType(guideType, 1)
		AnySDKManager:td_task_Complete("新手".."ArenaGuideTwo")
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
function ArenaGuideTwo:step(stepCount, touchRect, callBackFunc, callBackFunc2)
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
    	elseif 2 == stepCount then
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
function ArenaGuideTwo:create1Layer(touchRect)
	local layer = GuideSystem:createGuideLayer(touchRect)

	local girl = GuideSystem:createGuideGirl("获得武道馆排名后，每小时都可在此领取排名奖励")
	layer:addChild(girl)
	girl:setPosition(CanvasToScreen(300, 300))

	GuideSystem:setStepByGuideType(guideType, 1)
	return layer
end

-- 第二步,进入技能标签
function ArenaGuideTwo:create2Layer(callBackFunc)
	local layer = GuideSystem:createGuideCGLayer(220, callBackFunc)
	GuideSystem:setStepByGuideType(guideType, 2)
	return layer
end

