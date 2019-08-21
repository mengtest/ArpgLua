-- Name: 	LevelRewardGuideZero
-- Func：	等级奖励指引0
-- Author:	WangShengdong
-- Data:	16-7-7

local guideType = 26

local curStepCount = 0

LevelRewardGuideZero = {}

LevelRewardGuideZero.level = 4

-- 指引层
LevelRewardGuideZero.guideLayer = nil

-- 处于指引过程中
LevelRewardGuideZero.isInGuiding = false

-- 能否指引
function LevelRewardGuideZero:canGuide()
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

	return true
end

-- 是否完成
function LevelRewardGuideZero:isFinished()
	return 1 == GuideSystem:getFinishByGuideType(guideType)
end

-- 中断处理
function LevelRewardGuideZero:recoverInterrupt()
	if globaldata.level < self.level then -- 小于5级不恢复
		return false
	end
	if not self:isFinished() then -- 没完成就继续指引
		GuideSystem:setFinishByGuideType(guideType, 0)
		GuideSystem:setStepByGuideType(guideType, 2)
	else
		GuideSystem:setFinishByGuideType(guideType, 1)
	end
end

-- 中断处理
function LevelRewardGuideZero:recoverInterrupt_PVE()
	if globaldata.level < self.level then -- 小于5级不恢复
		return false
	end
	if not self:isFinished() then -- 没完成就继续指引
		GuideSystem:setFinishByGuideType(guideType, 0)
		GuideSystem:setStepByGuideType(guideType, 2)
	else
		GuideSystem:setFinishByGuideType(guideType, 1)
	end
end

-- 暂停
function LevelRewardGuideZero:pause()
	-- 清理
	if self.guideLayer then
		self.guideLayer:removeFromParent(true)
		self.guideLayer = nil
	end
end

-- 设置完成
function LevelRewardGuideZero:stop()
	
	if self:isFinished() then
		return false
	end

	if 3 ~= GuideSystem:getStepByGuideType(guideType) then -- 最后一步完成
		return
	end

	local function doStop()
		-- 清理
		if self.guideLayer then
			self.guideLayer:removeFromParent(true)
			self.guideLayer = nil
		end
		-- 设置完成
		GuideSystem:setFinishByGuideType(guideType, 1)
		AnySDKManager:td_task_Complete("新手".."LevelRewardGuideZero")
		self.isInGuiding = false

		-- if LotteryGuideOne:canGuide() then
		-- 	local window = GUISystem:GetWindowByName("HomeWindow")
		-- 	if window.mRootWidget then
		-- 		local guideBtn = window.mRootWidget:getChildByName("Image_Get")
		-- 		local size = guideBtn:getContentSize()
		-- 		local pos = guideBtn:getWorldPosition()
		-- 		pos.x = pos.x - size.width/2
		-- 		pos.y = pos.y - size.height/2
		-- 		local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
		-- 		LotteryGuideOne:step(1, touchRect)
		-- 	end
		-- end

		if SkillGuideOne:canGuide() then
			local window = GUISystem:GetWindowByName("HomeWindow")
			if window.mRootWidget then
				local guideBtn = window.mRootWidget:getChildByName("Image_Hero")
				local size = guideBtn:getContentSize()
				local pos = guideBtn:getWorldPosition()
				pos.x = pos.x - size.width/2
				pos.y = pos.y - size.height/2
				local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
				SkillGuideOne:step(2, touchRect)
			end
		end

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
function LevelRewardGuideZero:step(stepCount, touchRect, callBackFunc, callBackFunc2)
	if curStepCount == stepCount then
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
    		AnySDKManager:td_task_begin("新手".."HomeGuideOne")
    		
    		self.guideLayer = self:create1Layer(callBackFunc)
    	elseif 2 == stepCount then -- CG对白指引
    		self.guideLayer = self:create2Layer(touchRect)
    	elseif 3 == stepCount then -- CG对白指引
    		self.guideLayer = self:create3Layer(touchRect)
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
function LevelRewardGuideZero:create1Layer(callBackFunc)
	local layer = GuideSystem:createGuideCGLayer(206, callBackFunc)
	GuideSystem:setStepByGuideType(guideType, 1)
	return layer
end

-- 第一步,进入英雄界面
function LevelRewardGuideZero:create2Layer(touchRect)
	local layer = GuideSystem:createGuideLayer(touchRect)

	--local girl = GuideSystem:createGuideGirl("现在，需要去进行一下实力的提升")
	--layer:addChild(girl)
	--girl:setPosition(CanvasToScreen(600, 200))

	GuideSystem:setStepByGuideType(guideType, 2)
	return layer
end

-- 第一步,进入英雄界面
function LevelRewardGuideZero:create3Layer(touchRect)
	local layer = GuideSystem:createGuideLayer(touchRect)

	--local girl = GuideSystem:createGuideGirl("现在，需要去进行一下实力的提升")
	--layer:addChild(girl)
	--girl:setPosition(CanvasToScreen(500, 350))

	GuideSystem:setStepByGuideType(guideType, 3)
	return layer
end


