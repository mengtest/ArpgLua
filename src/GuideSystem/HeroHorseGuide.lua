-- Name: 	HeroHorseGuide
-- Func：	时装坐骑指引
-- Author:	WangShengdong
-- Data:	16-7-9

local guideType = 32

local curStepCount = 0

HeroHorseGuide = {}

HeroHorseGuide.level = 21

-- 指引层
HeroHorseGuide.guideLayer = nil

-- 动画1
HeroHorseGuide.animNode1 = nil

-- 动画2
HeroHorseGuide.animNode2 = nil

-- 处于指引过程中
HeroHorseGuide.isInGuiding = false

-- 软指引
function HeroHorseGuide:doHomeGuide()
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
		window.mRootWidget:getChildByName("Image_Grow"):getChildByName("Panel_Open_Animation"):addChild(self.animNode1:getRootNode(), 100)
		self.animNode1:play("guide_circle", true)
	end
	-- 动画2
	if not self.animNode2 then
		self.animNode2 = AnimManager:createAnimNode(8049)
		window.mRootWidget:getChildByName("Image_MountsGuns"):getChildByName("Panel_Open_Animation"):addChild(self.animNode2:getRootNode(), 100)
		self.animNode2:play("guide_circle", true)
	end

	if true == window.mRootWidget:getChildByName("Panel_Grow"):isVisible() then
		self.animNode2:setVisible(true)
		self.animNode1:setVisible(false)
	else
		self.animNode2:setVisible(false)
		self.animNode1:setVisible(true)
	end

end

-- 软指引
function HeroHorseGuide:doHomeGuideDestroy()
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
function HeroHorseGuide:canGuide()
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
function HeroHorseGuide:isFinished()
	return 1 == GuideSystem:getFinishByGuideType(guideType)
end

-- 中断处理
function HeroHorseGuide:recoverInterrupt()
	if globaldata.level < self.level then
		return false
	end
	if not self:isFinished() then -- 没完成继续指引
		GuideSystem:setFinishByGuideType(guideType, 0)
		GuideSystem:setStepByGuideType(guideType, 0)
	end
end

-- 设置完成
function HeroHorseGuide:stop()
	local function doStop()
		-- 清理
		if self.guideLayer then
			self.guideLayer:removeFromParent(true)
			self.guideLayer = nil
		end
		-- 设置完成
		GuideSystem:setFinishByGuideType(guideType, 1)
		AnySDKManager:td_task_Complete("新手".."HeroHorseGuide")
		self.isInGuiding = false
		-- 软指引
		self:doHomeGuideDestroy()
	end
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_GUIDE_STEP_, doStop)

	-- 请求指引
    local function requestDoStop()
		self.isInGuiding = true
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
function HeroHorseGuide:step(stepCount, touchRect, callBackFunc, callBackFunc2)
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
    	self.isInGuiding = true
    	if 1 == stepCount then
    		AnySDKManager:td_task_begin("新手".."HeroHorseGuide")
    		
    		self.guideLayer = self:create1Layer(callBackFunc)
    	end

    	GUISystem:GetRootNode():addChild(self.guideLayer, GUISYS_ZORDER_GUIWINDOW)
    	GUISystem:hideLoading()
    end
    NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_GUIDE_STEP_, doGuide)

     -- 请求指引
    local function requestDoGuide()
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
function HeroHorseGuide:create1Layer(callBackFunc)
	local layer = GuideSystem:createGuideCGLayer(228, callBackFunc)
	GuideSystem:setStepByGuideType(guideType, 1)
	return layer
end
