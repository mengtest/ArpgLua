-- Name: 	LevelRewardGuideTwo
-- Func：	等级奖励指引2
-- Author:	WangShengdong
-- Data:	16-6-28

local guideType = 12

local curStepCount = 0

LevelRewardGuideTwo = {}

LevelRewardGuideTwo.level = 9

LevelRewardGuideTwo.heroId = 2 -- 英雄ID

LevelRewardGuideTwo.itemId = 20278 -- 英雄碎片ID

-- 指引层
LevelRewardGuideTwo.guideLayer = nil

-- 处于指引过程中
LevelRewardGuideTwo.isInGuiding = false

-- 能否指引
function LevelRewardGuideTwo:canGuide()
	if not needUseGuide then
		return false
	end

	-- 英雄已经拥有不指引
	local heroObj = globaldata:findHeroById(self.heroId)
	if heroObj then
		return false
	end

	-- 物品已经具备不指引
	if globaldata:getItemOwnCount(self.itemId) > 10 then
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
function LevelRewardGuideTwo:isFinished()
	return 1 == GuideSystem:getFinishByGuideType(guideType)
end

-- 中断处理
function LevelRewardGuideTwo:recoverInterrupt()
	if globaldata.level < self.level then -- 小于5级不恢复
		return false
	end

	-- 英雄已经拥有不指引
	local heroObj = globaldata:findHeroById(self.heroId)
	if heroObj then
		GuideSystem:setFinishByGuideType(guideType, 1)
		return
	end

	-- 物品已经具备不指引
	if globaldata:getItemOwnCount(self.itemId) >= 10 then
		GuideSystem:setFinishByGuideType(guideType, 1)
		return
	end

	GuideSystem:setFinishByGuideType(guideType, 0)
	GuideSystem:setStepByGuideType(guideType, 1)
end

-- 中断处理
function LevelRewardGuideTwo:recoverInterrupt_PVE()
	if globaldata.level < self.level then -- 小于5级不恢复
		return false
	end

	-- 英雄已经拥有不指引
	local heroObj = globaldata:findHeroById(self.heroId)
	if heroObj then
		GuideSystem:setFinishByGuideType(guideType, 1)
		return
	end

	-- 物品已经具备不指引
	if globaldata:getItemOwnCount(self.itemId) >= 10 then
		GuideSystem:setFinishByGuideType(guideType, 1)
		return
	end

	GuideSystem:setFinishByGuideType(guideType, 0)
	GuideSystem:setStepByGuideType(guideType, 0)
end

-- 暂停
function LevelRewardGuideTwo:pause()
	-- 清理
	if self.guideLayer then
		self.guideLayer:removeFromParent(true)
		self.guideLayer = nil
	end
end

-- 设置完成
function LevelRewardGuideTwo:stop()
	
	if self:isFinished() then
		return false
	end

	if 2 ~= GuideSystem:getStepByGuideType(guideType) then -- 最后一步完成
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
		AnySDKManager:td_task_Complete("新手".."LevelRewardGuideTwo")
		self.isInGuiding = false

		if LotteryGuideOne:canGuide() then
			local window = GUISystem:GetWindowByName("HomeWindow")
			if window.mRootWidget then
				local guideBtn = window.mRootWidget:getChildByName("Image_Get")
				local size = guideBtn:getContentSize()
				local pos = guideBtn:getWorldPosition()
				pos.x = pos.x - size.width/2
				pos.y = pos.y - size.height/2
				local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
				LotteryGuideOne:step(1, touchRect)
			end
		end

		if HeroGuideTwo:canGuide() then
			local window = GUISystem:GetWindowByName("HomeWindow")
			if window.mRootWidget then
				local guideBtn = window.mRootWidget:getChildByName("Button_Hero")
				local size = guideBtn:getContentSize()
				local pos = guideBtn:getWorldPosition()
				pos.x = pos.x - size.width/2
				pos.y = pos.y - size.height/2
				local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
				HeroGuideTwo:step(1, touchRect)
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
function LevelRewardGuideTwo:step(stepCount, touchRect, callBackFunc, callBackFunc2)
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
    		self.guideLayer = self:create1Layer(touchRect)
    		
    	elseif 2 == stepCount then -- CG对白指引
    		self.guideLayer = self:create2Layer(touchRect)
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
function LevelRewardGuideTwo:create1Layer(touchRect)
	local layer = GuideSystem:createGuideLayer(touchRect)

	--local girl = GuideSystem:createGuideGirl("点击这里进入学员界面")
	--layer:addChild(girl)
	--girl:setPosition(CanvasToScreen(600, 150))

	GuideSystem:setStepByGuideType(guideType, 1)
	return layer
end

-- 第一步,进入英雄界面
function LevelRewardGuideTwo:create2Layer(touchRect)
	local layer = GuideSystem:createGuideLayer(touchRect)

	local girl = GuideSystem:createGuideGirl("点击领取新的等级奖励")
	layer:addChild(girl)
	girl:setPosition(CanvasToScreen(550, 200))

	GuideSystem:setStepByGuideType(guideType, 2)
	return layer
end


