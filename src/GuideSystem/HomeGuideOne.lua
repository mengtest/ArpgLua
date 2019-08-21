-- Name: 	HomeGuideOne
-- Func：	主城指引1
-- Author:	WangShengdong
-- Data:	16-6-25

local guideType = 1

local curStepCount = 0

HomeGuideOne = {}

-- 指引层
HomeGuideOne.guideLayer = nil

-- 处于指引过程中
HomeGuideOne.isInGuiding = false

-- 能否指引
function HomeGuideOne:canGuide()
	if not needUseGuide then
		return false
	end

	-- 完成不指引
	if self:isFinished() then
		return false
	end

	return true
end

-- 是否完成
function HomeGuideOne:isFinished()
	return 1 == GuideSystem:getFinishByGuideType(guideType)
end

-- 中断处理
function HomeGuideOne:recoverInterrupt()
	if 0 == globaldata.mytitleId and not globaldata:isChapterFinished(1, 1, 1) then -- 没有称号并且第一关没通关继续指引
		GuideSystem:setFinishByGuideType(guideType, 0)
		GuideSystem:setStepByGuideType(guideType, 0)
	else
		GuideSystem:setFinishByGuideType(guideType, 1)
	end
end

-- 设置完成
function HomeGuideOne:stop()
	local function doStop()
		-- 清理
		if self.guideLayer then
			self.guideLayer:removeFromParent(true)
			self.guideLayer = nil
		end
		-- 设置完成
		GuideSystem:setFinishByGuideType(guideType, 1)
		AnySDKManager:td_task_Complete("新手".."HomeGuideOne")
		self.isInGuiding = false

		if PveGuideOne:canGuide() then
			local window = GUISystem:GetWindowByName("HomeWindow")
			if window.mRootWidget then
				local guideBtn = window.mRootWidget:getChildByName("Button_Adventure")
				local size = guideBtn:getContentSize()
				local pos = guideBtn:getWorldPosition()
				pos.x = pos.x - size.width/2
				pos.y = pos.y - size.height/2
				local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
				PveGuideOne:step(1, touchRect)
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
function HomeGuideOne:step(stepCount, touchRect, callBackFunc, callBackFunc2)
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
    	elseif 3 == stepCount then
    		self.guideLayer = self:create3Layer(touchRect)
    	elseif 4 == stepCount then
    		self.guideLayer = self:create4Layer(touchRect, callBackFunc2)
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
function HomeGuideOne:create1Layer(callBackFunc)
	local layer = GuideSystem:createGuideCGLayer(201, callBackFunc)
	GuideSystem:setStepByGuideType(guideType, 1)
	return layer
end

-- 第一步,进入英雄界面
function HomeGuideOne:create2Layer(touchRect)
	local layer = GuideSystem:createGuideLayer(touchRect)

	--local girl = GuideSystem:createGuideGirl("点击这里进入学员界面")
	--layer:addChild(girl)
	--girl:setPosition(CanvasToScreen(600, 150))

	GuideSystem:setStepByGuideType(guideType, 2)
	return layer
end

-- 第二步,CG对话
function HomeGuideOne:create3Layer(touchRect)
	local layer = GuideSystem:createGuideLayer(touchRect)

	local girl = GuideSystem:createGuideGirl("先来这里领取新生证吧")
	layer:addChild(girl)
	girl:setPosition(CanvasToScreen(500, 200))

	GuideSystem:setStepByGuideType(guideType, 3)
	return layer
end

-- 第二步,进入技能标签
function HomeGuideOne:create4Layer(touchRect, callBackFunc2)
	local layer = GuideSystem:createShowLayer(touchRect, callBackFunc2)

	local girl = GuideSystem:createGuideGirl("只要进入乌鸦学校，就会成为这里炙手可热的小鲜肉")
	layer:addChild(girl)
	girl:setPosition(CanvasToScreen(150, 300))

	GuideSystem:setStepByGuideType(guideType, 4)
	return layer
end

-- 第二步,进入技能标签
function HomeGuideOne:create5Layer(touchRect)
	local layer = GuideSystem:createGuideLayer(touchRect)

	local girl = GuideSystem:createGuideGirl("点击这里，可以使所选择的称号#16ff04在主城的角色头顶上显示#")
	layer:addChild(girl)
	girl:setPosition(CanvasToScreen(300, 50))

	GuideSystem:setStepByGuideType(guideType, 5)
	return layer
end

-- 第二步,CG对话
function HomeGuideOne:create6Layer(touchRect)
	local layer = GuideSystem:createGuideLayer(touchRect)

	--local girl = GuideSystem:createGuideGirl("进行初次挑战，试试自己的身手吧")
	--layer:addChild(girl)
	--girl:setPosition(CanvasToScreen(700, 100))

	GuideSystem:setStepByGuideType(guideType, 6)
	return layer
end

-- 第二步,进入技能标签
function HomeGuideOne:create7Layer(callBackFunc)
	local layer = GuideSystem:createGuideCGLayer(202, callBackFunc)
	GuideSystem:setStepByGuideType(guideType, 7)
	return layer
end


