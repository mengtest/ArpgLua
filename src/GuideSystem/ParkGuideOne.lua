-- Name: 	ParkGuideOne
-- Func：	游乐园指引1
-- Author:	WangShengdong
-- Data:	16-6-30

local guideType = 24

local curStepCount = 0

ParkGuideOne = {}

ParkGuideOne.level = 26

-- 指引层
ParkGuideOne.guideLayer = nil

-- 动画1
ParkGuideOne.animNode1 = nil

-- 动画2
ParkGuideOne.animNode2 = nil

-- 处于指引过程中
ParkGuideOne.isInGuiding = false

-- 软指引
function ParkGuideOne:doHomeGuide()
	-- 完成不指引
	if self:isFinished() then
		return
	end
	-- 窗口不存在不指引
	local window = GUISystem:GetWindowByName("HomeWindow")
	if not window.mRootWidget then
		return
	end
	-- 能否指引
	if not self:canGuide() then
		return
	end
	-- 动画1
	if not self.animNode1 then
		self.animNode1 = AnimManager:createAnimNode(8049)
		window.mRootWidget:getChildByName("Image_PVE"):getChildByName("Panel_Open_Animation"):addChild(self.animNode1:getRootNode(), 100)
		self.animNode1:play("guide_circle", true)
	end
	-- 动画2
	if not self.animNode2 then
		self.animNode2 = AnimManager:createAnimNode(8049)
		window.mRootWidget:getChildByName("Image_Tower"):getChildByName("Panel_Open_Animation"):addChild(self.animNode2:getRootNode(), 100)
		self.animNode2:play("guide_circle", true)
	end

	if true == window.mRootWidget:getChildByName("Panel_PVE"):isVisible() then
		self.animNode2:setVisible(true)
		self.animNode1:setVisible(false)
	else
		self.animNode2:setVisible(false)
		self.animNode1:setVisible(true)
	end

end

-- 软指引
function ParkGuideOne:doHomeGuideDestroy()
	if self.animNode1 then
		self.animNode1:destroy()
		self.animNode1 = nil
	end

	if self.animNode2 then
		self.animNode2:destroy()
		self.animNode2 = nil
	end
end

-- 能否指引
function ParkGuideOne:canGuide()
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

	return true
end

-- 是否完成
function ParkGuideOne:isFinished()
	return 1 == GuideSystem:getFinishByGuideType(guideType)
end

-- 中断处理
function ParkGuideOne:recoverInterrupt()
	if globaldata.level < self.level then
		return false
	end
	if not self:isFinished() then -- 没完成继续指引
		GuideSystem:setFinishByGuideType(guideType, 0)
		GuideSystem:setStepByGuideType(guideType, 0)
	end
end

-- 设置完成
function ParkGuideOne:stop()
	local function doStop()
		-- 清理
		if self.guideLayer then
			self.guideLayer:removeFromParent(true)
			self.guideLayer = nil
		end
		-- 设置完成
		GuideSystem:setFinishByGuideType(guideType, 1)
		AnySDKManager:td_task_Complete("新手".."ParkGuideOne")
		self.isInGuiding = false
		-- 软指引
		self:doHomeGuideDestroy()
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
function ParkGuideOne:step(stepCount, touchRect, callBackFunc, callBackFunc2)
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
    		AnySDKManager:td_task_begin("新手".."ParkGuideOne")
    		self.guideLayer = self:create1Layer(callBackFunc)
    	elseif 2 == stepCount then
    		self.guideLayer = self:create2Layer(touchRect, callBackFunc2)
    	elseif 3 == stepCount then
    		self.guideLayer = self:create3Layer(touchRect, callBackFunc2)
    	elseif 4 == stepCount then
    		self.guideLayer = self:create4Layer(touchRect, callBackFunc2)
    	elseif 5 == stepCount then
    		self.guideLayer = self:create5Layer(callBackFunc)
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
function ParkGuideOne:create1Layer(callBackFunc)
	local layer = GuideSystem:createGuideCGLayer(230, callBackFunc)
	GuideSystem:setStepByGuideType(guideType, 1)
	return layer
end

-- 第一步,进入英雄界面
function ParkGuideOne:create2Layer(touchRect, callBackFunc2)
	local layer = GuideSystem:createShowLayer(touchRect, callBackFunc2)

	local girl = GuideSystem:createGuideGirl("点击对手头像图标，可进入关卡战斗")
	layer:addChild(girl)
	girl:setPosition(CanvasToScreen(100, 150))

	GuideSystem:setStepByGuideType(guideType, 2)
	return layer
end

-- 第二步,进入技能标签
function ParkGuideOne:create3Layer(touchRect, callBackFunc2)
	local layer = GuideSystem:createShowLayer(touchRect, callBackFunc2)

	local girl = GuideSystem:createGuideGirl("顺利通过一关后，可领取本关奖励")
	layer:addChild(girl)
	girl:setPosition(CanvasToScreen(150, 50))

	GuideSystem:setStepByGuideType(guideType, 3)
	return layer
end

-- 第二步,进入技能标签
function ParkGuideOne:create4Layer(touchRect, callBackFunc2)
	local layer = GuideSystem:createShowLayer(touchRect, callBackFunc2)

	local girl = GuideSystem:createGuideGirl("当所有学员死亡后，点击重置，可开启新一轮")
	layer:addChild(girl)
	girl:setPosition(CanvasToScreen(500, 150))

	GuideSystem:setStepByGuideType(guideType, 4)
	return layer
end

-- 第一步,进入英雄界面
function ParkGuideOne:create5Layer(callBackFunc)
	local layer = GuideSystem:createGuideCGLayer(231, callBackFunc)
	GuideSystem:setStepByGuideType(guideType, 5)
	return layer
end
