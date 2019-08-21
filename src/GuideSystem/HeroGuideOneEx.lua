-- Name: 	HeroGuideOneEx
-- Func：	英雄指引1
-- Author:	WangShengdong
-- Data:	16-6-27

local guideType = 10

local curStepCount = 0

HeroGuideOneEx = {}

-- 英雄ID
HeroGuideOneEx.heroId = 6

HeroGuideOneEx.level = 7

-- 指引层
HeroGuideOneEx.guideLayer = nil

-- 处于指引过程中
HeroGuideOneEx.isInGuiding = false

-- 能否指引
function HeroGuideOneEx:canGuide()
	if not needUseGuide then
		return false
	end

	-- 完成不指引
	if self:isFinished() then
		return false
	end

	-- 前置指引必须完成
	if not LotteryGuideOne:isFinished() then
		return false
	end

	return true
end

-- 是否完成
function HeroGuideOneEx:isFinished()
	return 1 == GuideSystem:getFinishByGuideType(guideType)
end

-- 中断处理
function HeroGuideOneEx:recoverInterrupt()
	-- 前置指引必须完成
	if not LotteryGuideOne:isFinished() then
		return false
	end
	local heroObj = globaldata:findHeroById(HeroGuideOneEx.heroId)
	if not heroObj then
		return
	end
	if heroObj.level < self.level then -- 英雄不到5级
		GuideSystem:setFinishByGuideType(guideType, 0)
		GuideSystem:setStepByGuideType(guideType, 0)
	else
		GuideSystem:setFinishByGuideType(guideType, 1)
	end
end

-- 中断处理
function HeroGuideOneEx:recoverInterrupt_PVE()
	if not globaldata:isChapterFinished(1, 1, 1) then -- 第一关没通关继续指引
		GuideSystem:setFinishByGuideType(guideType, 0)
		GuideSystem:setStepByGuideType(guideType, 1)
	else
		GuideSystem:setFinishByGuideType(guideType, 1)
	end
end

-- 暂停
function HeroGuideOneEx:pause()
	-- 清理
	if self.guideLayer then
		self.guideLayer:removeFromParent(true)
		self.guideLayer = nil
	end
end

-- 设置完成
function HeroGuideOneEx:stop()
	local function doStop()
		-- 清理
		if self.guideLayer then
			self.guideLayer:removeFromParent(true)
			self.guideLayer = nil
		end
		-- 设置完成
		GuideSystem:setFinishByGuideType(guideType, 1)
		AnySDKManager:td_task_Complete("新手".."PveGuideOne")
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
function HeroGuideOneEx:step(stepCount, touchRect, callBackFunc, callBackFunc2)
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
    		AnySDKManager:td_task_begin("新手".."HeroGuideOneEx")
    		
    		self.guideLayer = self:create1Layer(callBackFunc)
    	elseif 2 == stepCount then -- CG对白指引
    		self.guideLayer = self:create2Layer(touchRect)
    	elseif 3 == stepCount then
    		self.guideLayer = self:create3Layer(touchRect)
    	elseif 4 == stepCount then
    		self.guideLayer = self:create4Layer(touchRect)
    	elseif 5 == stepCount then
    		self.guideLayer = self:create5Layer(touchRect)
    	elseif 6 == stepCount then
    		self.guideLayer = self:create6Layer(touchRect, callBackFunc2)
    	elseif 7 == stepCount then
    		self.guideLayer = self:create7Layer(touchRect)
    	elseif 8 == stepCount then
    		self.guideLayer = self:create8Layer(callBackFunc)
    	elseif 9 == stepCount then
    		self.guideLayer = self:create9Layer(touchRect)
    	elseif 10 == stepCount then
    		self.guideLayer = self:create10Layer(touchRect)
    	elseif 11 == stepCount then
    		self.guideLayer = self:create11Layer(touchRect, callBackFunc2)
    	elseif 12 == stepCount then
    		self.guideLayer = self:create12Layer(touchRect, callBackFunc2)
    	elseif 13 == stepCount then
    		self.guideLayer = self:create13Layer(callBackFunc)
    	elseif 14 == stepCount then
    		self.guideLayer = self:create14Layer(touchRect)
    	elseif 15 == stepCount then
    		self.guideLayer = self:create15Layer(touchRect, callBackFunc2)
    	elseif 16 == stepCount then
    		self.guideLayer = self:create16Layer(touchRect)
    	elseif 17 == stepCount then
    		self.guideLayer = self:create17Layer(touchRect, callBackFunc2)
    	elseif 18 == stepCount then
    		self.guideLayer = self:create18Layer(touchRect, callBackFunc2)
    	elseif 19 == stepCount then
    		self.guideLayer = self:create19Layer(touchRect)
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
function HeroGuideOneEx:create1Layer(callBackFunc)
	local layer = GuideSystem:createGuideCGLayer(211, callBackFunc)
	GuideSystem:setStepByGuideType(guideType, 1)
	return layer
end

-- 第一步,进入英雄界面
function HeroGuideOneEx:create2Layer(touchRect)
	local layer = GuideSystem:createGuideLayer(touchRect)

	--local girl = GuideSystem:createGuideGirl("点击这里进入学员界面")
	--layer:addChild(girl)
	--girl:setPosition(CanvasToScreen(600, 150))

	GuideSystem:setStepByGuideType(guideType, 2)
	return layer
end

-- 第二步,CG对话
function HeroGuideOneEx:create3Layer(touchRect)
	local layer = GuideSystem:createGuideLayer(touchRect)

	local girl = GuideSystem:createGuideGirl("每当获得新学员，要先对其进行培养")
	layer:addChild(girl)
	girl:setPosition(CanvasToScreen(400, 200))

	GuideSystem:setStepByGuideType(guideType, 3)
	return layer
end

-- 第二步,进入技能标签
function HeroGuideOneEx:create4Layer(touchRect)
	local layer = GuideSystem:createGuideLayer(touchRect)

	local girl = GuideSystem:createGuideGirl("使用#16ff04经验寿司#，提升学员经验到#16ff047级#")
	layer:addChild(girl)
	girl:setPosition(CanvasToScreen(500, 200))

	GuideSystem:setStepByGuideType(guideType, 4)
	return layer
end

-- 第二步,进入技能标签
function HeroGuideOneEx:create5Layer(touchRect)
	local layer = GuideSystem:createGuideLayer(touchRect)

	local girl = GuideSystem:createGuideGirl("将所选学员勾选为#16ff04队长#后，他的形象会代表战队出现在主城")
	layer:addChild(girl)
	girl:setPosition(CanvasToScreen(320, 100))

	GuideSystem:setStepByGuideType(guideType, 5)
	return layer
end

-- 第二步,进入技能标签
function HeroGuideOneEx:create6Layer(touchRect, callBackFunc2)
	local layer = GuideSystem:createShowLayer(touchRect, callBackFunc2)

	local girl = GuideSystem:createGuideGirl("被选作队长的学员，在这里有#16ff04特殊标示#")
	layer:addChild(girl)
	girl:setPosition(CanvasToScreen(200, 250))

	GuideSystem:setStepByGuideType(guideType, 6)
	return layer
end

-- 第二步,进入技能标签
function HeroGuideOneEx:create7Layer(touchRect)
	local layer = GuideSystem:createGuideLayer(touchRect)

	local girl = GuideSystem:createGuideGirl("此外，学员还有分为#16ff04不同职业#")
	layer:addChild(girl)
	girl:setPosition(CanvasToScreen(450, 100))

	GuideSystem:setStepByGuideType(guideType, 7)
	return layer
end

-- 第一步,进入英雄界面
function HeroGuideOneEx:create8Layer(callBackFunc)
	local layer = GuideSystem:createGuideCGLayer(213, callBackFunc)
	GuideSystem:setStepByGuideType(guideType, 8)
	return layer
end

-- 第一步,进入英雄界面
function HeroGuideOneEx:create9Layer(touchRect)
	local layer = GuideSystem:createGuideLayer(touchRect)

	local girl = GuideSystem:createGuideGirl("点击空白处关闭窗口")
	layer:addChild(girl)
	girl:setPosition(CanvasToScreen(720, 30))

	GuideSystem:setStepByGuideType(guideType, 9)
	return layer
end

-- 第一步,进入英雄界面
function HeroGuideOneEx:create10Layer(touchRect)
	local layer = GuideSystem:createGuideLayer(touchRect)

	--local girl = GuideSystem:createGuideGirl("点击空白处关闭窗口")
	--layer:addChild(girl)
	--girl:setPosition(CanvasToScreen(600, 150))

	GuideSystem:setStepByGuideType(guideType, 10)
	return layer
end

-- 第二步,进入技能标签
function HeroGuideOneEx:create11Layer(touchRect, callBackFunc2)
	local layer = GuideSystem:createOriginalShowLayer(touchRect, callBackFunc2)

	local girl = GuideSystem:createGuideGirl("学员的天赋点由#16ff04顶部第一排#开启，每#16ff04点满一排#可#16ff04开启下一排#")
	layer:addChild(girl)
	girl:setPosition(CanvasToScreen(400, 380))

	GuideSystem:setStepByGuideType(guideType, 11)
	return layer
end



-- 第二步,进入技能标签
function HeroGuideOneEx:create12Layer(touchRect, callBackFunc2)
	local layer = GuideSystem:createOriginalShowLayer(touchRect, callBackFunc2)

	local girl = GuideSystem:createGuideGirl("每一排只能选择#16ff04一个属性#进行升级，#16ff04不能全选#哦")
	layer:addChild(girl)
	girl:setPosition(CanvasToScreen(550, 380))

	GuideSystem:setStepByGuideType(guideType, 12)
	return layer
end


-- 第一步,进入英雄界面
function HeroGuideOneEx:create13Layer(callBackFunc)
	local layer = GuideSystem:createGuideCGLayer(212, callBackFunc)
	GuideSystem:setStepByGuideType(guideType, 13)
	return layer
end



-- 第二步,进入技能标签
function HeroGuideOneEx:create14Layer(touchRect)
	local layer = GuideSystem:createGuideLayer(touchRect)

	--local girl = GuideSystem:createGuideGirl("进行初次挑战，试试自己的身手吧")
	--layer:addChild(girl)
	--girl:setPosition(CanvasToScreen(550, 150))

	GuideSystem:setStepByGuideType(guideType, 14)
	return layer
end

-- 第二步,进入技能标签
function HeroGuideOneEx:create15Layer(touchRect, callBackFunc2)
	local layer = GuideSystem:createShowLayer(touchRect, callBackFunc2, true)

	local girl = GuideSystem:createGuideGirl("#16ff04五维图#代表学员的#16ff04属性偏向#，比例越大，能力越强")
	layer:addChild(girl)
	girl:setPosition(CanvasToScreen(550, 100))

	GuideSystem:setStepByGuideType(guideType, 15)
	return layer
end



-- 第二步,进入技能标签
function HeroGuideOneEx:create16Layer(touchRect)
	local layer = GuideSystem:createGuideLayer(touchRect, "guide_hand_slide_left")

	local girl = GuideSystem:createGuideGirl("向左滑动，可切换至详细属性面板")
	layer:addChild(girl)
	girl:setPosition(CanvasToScreen(550, 130))

	GuideSystem:setStepByGuideType(guideType, 16)
	return layer
end


-- 第二步,进入技能标签
function HeroGuideOneEx:create17Layer(touchRect, callBackFunc2)
	local layer = GuideSystem:createShowLayer(touchRect, callBackFunc2, true)

	local girl = GuideSystem:createGuideGirl("#16ff04属性成长#是属性随学员等级、星级、品级增长而提升的幅度")
	layer:addChild(girl)
	girl:setPosition(CanvasToScreen(450, 200))

	GuideSystem:setStepByGuideType(guideType, 17)
	return layer
end


-- 第二步,进入技能标签
function HeroGuideOneEx:create18Layer(touchRect, callBackFunc2)
	local layer = GuideSystem:createShowLayer(touchRect, callBackFunc2, true)

	local girl = GuideSystem:createGuideGirl("#16ff04详细属性#是当前学员的属性数值，详细效果可点击查看#16ff04属性描述#")
	layer:addChild(girl)
	girl:setPosition(CanvasToScreen(450, 50))

	GuideSystem:setStepByGuideType(guideType, 18)
	return layer
end

-- 第一步,进入英雄界面
function HeroGuideOneEx:create19Layer(touchRect)
	local layer = GuideSystem:createGuideLayer(touchRect)

	local girl = GuideSystem:createGuideGirl("#16ff04点击#下层窗口的#16ff04边缘#也可进行界面切换")
	layer:addChild(girl)
	girl:setPosition(CanvasToScreen(350, 400))

	GuideSystem:setStepByGuideType(guideType, 19)
	return layer
end