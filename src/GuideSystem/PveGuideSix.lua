-- Name: 	PveGuideSix
-- Func：	副本指引6
-- Author:	WangShengdong
-- Data:	16-6-28

local guideType = 11

local curStepCount = 0

PveGuideSix = {}

-- 指引层
PveGuideSix.guideLayer = nil

-- 处于指引过程中
PveGuideSix.isInGuiding = false

-- 能否指引
function PveGuideSix:canGuide()
	if not needUseGuide then
		return false
	end

	-- 完成不指引
	if self:isFinished() then
		return false
	end

	-- 前置指引必须完成
	if not HeroGuideOneEx:isFinished() then
		return false
	end

	return true
end

-- 是否完成
function PveGuideSix:isFinished()
	return 1 == GuideSystem:getFinishByGuideType(guideType)
end

-- 中断处理
function PveGuideSix:recoverInterrupt()
	-- 前置指引必须完成
	if not HeroGuideOneEx:isFinished() then
		return false
	end
	if not self:isFinished() then -- 没完成就继续指引
		GuideSystem:setFinishByGuideType(guideType, 0)
		GuideSystem:setStepByGuideType(guideType, 0)
	else
		GuideSystem:setFinishByGuideType(guideType, 1)
	end
end

-- 中断处理
function PveGuideSix:recoverInterrupt_PVE()
	-- 前置指引必须完成
	if not HeroGuideOneEx:isFinished() then
		return false
	end
	if not self:isFinished() then -- 没完成就继续指引
		GuideSystem:setFinishByGuideType(guideType, 0)
		GuideSystem:setStepByGuideType(guideType, 1)
	else
		GuideSystem:setFinishByGuideType(guideType, 1)
	end
end

-- 设置完成
function PveGuideSix:stop()
	local function doStop()
		-- 清理
		if self.guideLayer then
			self.guideLayer:removeFromParent(true)
			self.guideLayer = nil
		end
		-- 设置完成
		GuideSystem:setFinishByGuideType(guideType, 1)
		AnySDKManager:td_task_Complete("新手".."PveGuideSix")
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
function PveGuideSix:step(stepCount, touchRect, callBackFunc, callBackFunc2)
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
    		self.guideLayer = self:create2Layer(callBackFunc)
    	elseif 3 == stepCount then
    		self.guideLayer = self:create3Layer(touchRect)
    	elseif 4 == stepCount then
    		self.guideLayer = self:create4Layer(touchRect)
    	elseif 5 == stepCount then
    		self.guideLayer = self:create5Layer(touchRect)
    	elseif 6 == stepCount then
    		self.guideLayer = self:create6Layer(touchRect)
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
function PveGuideSix:create1Layer(touchRect)
	local layer = GuideSystem:createGuideLayer(touchRect)

	--local girl = GuideSystem:createGuideGirl("点击这里进入学员界面")
	--layer:addChild(girl)
	--girl:setPosition(CanvasToScreen(600, 150))

	GuideSystem:setStepByGuideType(guideType, 1)
	return layer
end

-- 第一步,进入英雄界面
function PveGuideSix:create2Layer(callBackFunc)
	local layer = GuideSystem:createGuideCGLayer(214, callBackFunc)
	GuideSystem:setStepByGuideType(guideType, 2)
	return layer
end

-- 第二步,CG对话
function PveGuideSix:create3Layer(touchRect)
	local layer = GuideSystem:createGuideLayer(touchRect)

	--local girl = GuideSystem:createGuideGirl("点击这里进入学员界面")
	--layer:addChild(girl)
	--girl:setPosition(CanvasToScreen(600, 150))

	GuideSystem:setStepByGuideType(guideType, 3)
	return layer
end

-- 第二步,进入技能标签
function PveGuideSix:create4Layer(touchRect, callBackFunc2)
	local layer = GuideSystem:createGuideLayer(touchRect)

	--local girl = GuideSystem:createGuideGirl("点击这里进入学员界面")
	--layer:addChild(girl)
	--girl:setPosition(CanvasToScreen(600, 150))

	GuideSystem:setStepByGuideType(guideType, 4)
	return layer
end

-- 第二步,进入技能标签
function PveGuideSix:create5Layer(touchRect)
	local layer = GuideSystem:createGuideLayer(touchRect)

	local girl = GuideSystem:createGuideGirl("#16ff04点击学员#可以将他加入上阵队伍中")
	layer:addChild(girl)
	girl:setPosition(CanvasToScreen(200, 50))

	GuideSystem:setStepByGuideType(guideType, 5)
	return layer
end

-- 第二步,进入技能标签
function PveGuideSix:create6Layer(touchRect)
	local layer = GuideSystem:createGuideLayer(touchRect)

	--local girl = GuideSystem:createGuideGirl("进行初次挑战，试试自己的身手吧")
	--layer:addChild(girl)
	--girl:setPosition(CanvasToScreen(550, 150))

	GuideSystem:setStepByGuideType(guideType, 6)
	return layer
end
