-- Name: 	NiubilityWidget.lua
-- Func：	牛逼控件
-- Author:	WangShengdong
-- Data:	15-3-10

NiubilityWidget = {}

local delayTime = 0.15
local easeVal = 1.1

local showedType 	=	true 		-- 显示状态

-- 左面板
local PanelLeft = {}

function PanelLeft:new(rootNode, parent)
	local o = 
	{
		mRootNode 	= 	rootNode,
		mParent 	=	parent,
		mLabel		=	rootNode:getChildByName("Panel_Label"),
		mMainPanel	=	rootNode:getChildByName("Panel_Container"),
		mPosBegin	=	nil,
		mPosMiddle	=	nil,
		mPosEnd		=	nil,
	}
	o = newObject(o, PanelLeft)
	return o
end

function PanelLeft:init()
	self:setVisible(true)
	self:initPos()
	registerWidgetReleaseUpEvent(self.mRootNode:getChildByName("Panel_Touch"),handler(self, self.onTouch))
end

function PanelLeft:setVisible(visible)
	if visible then
		self:setOpacity(255)
	else
		self:setOpacity(120)
	end
	self.mMainPanel:setVisible(visible)
	self.mRootNode:setVisible(true)
end

function PanelLeft:setOpacity(opacity)
	local childArray = self.mRootNode:getChildren()

	for i = 1, #childArray do
		childArray[i]:setOpacity(opacity)
	end
	
	if 120 == opacity then
		self.mLabel:setOpacity(190)
	else
		self.mLabel:setOpacity(255)
	end
end

function PanelLeft:initPos()
	self.mPosBegin = cc.p(self.mRootNode:getPosition())
	self.mPosMiddle = cc.p(self.mPosBegin.x - 25, self.mPosBegin.y + 75)
	self.mPosEnd = cc.p(self.mPosBegin.x, self.mPosBegin.y + 25)
end

-- 到后面去
function PanelLeft:playAnim1()
	local function endAction()
	--	self.mLabel:setOpacity(190)
		-- self:setVisible(false)
		self.mMainPanel:setVisible(false)
		self.mRootNode:getChildByName("Image_Bg"):loadTexture("hero_board2_new.png")
	--	self.mRootNode:setLocalZOrder(10)
		self:setTouchEnabled(true)
	end

	local function reachMiddle()
		local act2 = cc.EaseIn:create(cc.MoveTo:create(delayTime, self.mPosEnd), easeVal)
	--	local act3 = cc.FadeTo:create(delayTime, 120)
		local act4 = cc.CallFunc:create(endAction)
		self.mRootNode:runAction(cc.Sequence:create(act2, act4))
		self.mRootNode:setLocalZOrder(5)
		self:setOpacity(120)
	end

	local act0 = cc.EaseIn:create(cc.MoveTo:create(delayTime, self.mPosMiddle), easeVal)
	local act1 = cc.CallFunc:create(reachMiddle)
	local act2 = cc.CallFunc:create(endAction)
	self:setTouchEnabled(false)
	self.mRootNode:runAction(cc.Sequence:create(act0, act1))
end

function PanelLeft:onTouch(widget)
	self.mParent:playAnim2()

	if HeroGuideOneEx:canGuide() then
		HeroGuideOneEx:stop()
	end

	-- if HeroGuideOne:canGuide() then
	-- 	local window = GUISystem:GetWindowByName("HeroInfoWindow")
	-- 	if window.mRootWidget then
	-- 		local guideBtn = window.mRootWidget:getChildByName("Image_HeroGroup")
	-- 		local size = guideBtn:getContentSize()
	-- 		local pos = guideBtn:getWorldPosition()
	-- 		pos.x = pos.x - size.width/2
	-- 		pos.y = pos.y - size.height/2
	-- 		local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
	-- 		HeroGuideOne:step(18, touchRect)
	-- 	end
	-- end
end

-- 到前面来
function PanelLeft:playAnim2()
	local function endAction()
		self.mMainPanel:setVisible(true)
		self:setTouchEnabled(false)
	end

	local function reachMiddle()
		local act2 = cc.EaseIn:create(cc.MoveTo:create(delayTime, self.mPosBegin), easeVal)
	--	local act3 = cc.FadeTo:create(1, 120)
		local act4 = cc.CallFunc:create(endAction)
		self.mRootNode:runAction(cc.Sequence:create(act2, act4))
		self.mRootNode:setLocalZOrder(10)
		self:setOpacity(255)
	end

	local act0 = cc.EaseIn:create(cc.MoveTo:create(delayTime, self.mPosMiddle), easeVal)
	local act1 = cc.CallFunc:create(reachMiddle)
	local act2 = cc.CallFunc:create(endAction)
	self:setTouchEnabled(false)
	self.mRootNode:runAction(cc.Sequence:create(act0, act1, act2))
	self.mRootNode:getChildByName("Image_Bg"):loadTexture("hero_board2.png")
end

function PanelLeft:setTouchEnabled(enabled)
	self.mRootNode:getChildByName("Panel_Touch"):setTouchEnabled(enabled)
end

function PanelLeft:setRedVisible(visible)
	self.mRootNode:getChildByName("Image_Notice_5016"):setVisible(visible)
end

-- 右面板
local PanelRight = {}

function PanelRight:new(rootNode, parent)
	local o = 
	{
		mRootNode 	= 	rootNode,
		mParent 	=	parent,
		mLabel		=	rootNode:getChildByName("Panel_Label"),
		mMainPanel	=	rootNode:getChildByName("Panel_Container"),
		mPosBegin	=	nil,
		mPosMiddle	=	nil,
		mPosEnd		=	nil,
	}
	o = newObject(o, PanelRight)
	return o
end

function PanelRight:init()
	self:setVisible(false)
	self:initPos()
	registerWidgetReleaseUpEvent(self.mRootNode:getChildByName("Panel_Touch"),handler(self, self.onTouch))
end

function PanelRight:onTouch(widget)
	self.mParent:playAnim1()
end

function PanelRight:initPos()
	self.mPosBegin = cc.p(self.mRootNode:getPosition())
	self.mPosMiddle = cc.p(self.mPosBegin.x + 25, self.mPosBegin.y - 75)
	self.mPosEnd = cc.p(self.mPosBegin.x, self.mPosBegin.y - 25)
end

-- 到前面来
function PanelRight:playAnim1()
	local function endAction()
		self.mMainPanel:setVisible(true)
		self:setTouchEnabled(false)

		showedType = false

		local function doHeroGuideOneEx_Step18()
			local window = GUISystem:GetWindowByName("HeroInfoWindow")
			if window.mRootWidget then
				local guideBtn = window.mShuxingWidget.mPanelLeft.mRootNode:getChildByName("Panel_Touch")
				local size = guideBtn:getContentSize()
				local pos = guideBtn:getWorldPosition()
				local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
				HeroGuideOneEx:step(19, touchRect)
			end
		end

		local function doHeroGuideOneEx_Step17()
			local guideBtn = self.mMainPanel
			local size = guideBtn:getContentSize()
			local pos = guideBtn:getWorldPosition()
			local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
			HeroGuideOneEx:step(18, touchRect, nil, doHeroGuideOneEx_Step18)
		end

		if HeroGuideOneEx:canGuide() then
			local guideBtn = self.mMainPanel
			local size = guideBtn:getContentSize()
			local pos = guideBtn:getWorldPosition()
			local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
			HeroGuideOneEx:step(17, touchRect, nil, doHeroGuideOneEx_Step17)
		end
	end

	local function reachMiddle()
		local act2 = cc.EaseIn:create(cc.MoveTo:create(delayTime, self.mPosEnd), easeVal)
	--	local act3 = cc.FadeTo:create(1, 120)
		local act4 = cc.CallFunc:create(endAction)
		self.mRootNode:runAction(cc.Sequence:create(act2, act4))
		self.mRootNode:setLocalZOrder(10)
		self:setOpacity(255)
		self.mMainPanel:setVisible(true)
	end

	local act0 = cc.EaseIn:create(cc.MoveTo:create(delayTime, self.mPosMiddle), easeVal)
	local act1 = cc.CallFunc:create(reachMiddle)
	local act2 = cc.CallFunc:create(endAction)
	self.mRootNode:runAction(cc.Sequence:create(act0, act1))
	self:setTouchEnabled(false)
	self.mRootNode:getChildByName("Image_Bg"):loadTexture("hero_board1.png")
end

-- 到后面去
function PanelRight:playAnim2()
	local function endAction()
		self.mMainPanel:setVisible(false)
		self.mRootNode:getChildByName("Image_Bg"):loadTexture("hero_board1_new.png")
		self:setTouchEnabled(true)

		showedType = true
	end

	local function reachMiddle()
		local act2 = cc.EaseIn:create(cc.MoveTo:create(delayTime, self.mPosBegin), easeVal)
	--	local act3 = cc.FadeTo:create(1, 120)
		local act4 = cc.CallFunc:create(endAction)
		self.mRootNode:runAction(cc.Sequence:create(act2, act4))
		self.mRootNode:setLocalZOrder(5)
		self:setOpacity(120)
		self.mMainPanel:setVisible(true)
	end

	local act0 = cc.EaseIn:create(cc.MoveTo:create(delayTime, self.mPosMiddle), easeVal)
	local act1 = cc.CallFunc:create(reachMiddle)
	local act2 = cc.CallFunc:create(endAction)
	self.mRootNode:runAction(cc.Sequence:create(act0, act1))
	self:setTouchEnabled(false)
	self.mRootNode:getChildByName("Image_Bg"):loadTexture("hero_board1.png")
end

function PanelRight:setVisible(visible)
	if visible then
		self:setOpacity(255)
	else
		self:setOpacity(120)
	end
	self.mMainPanel:setVisible(visible)
	self.mRootNode:setVisible(true)
end

function PanelRight:setOpacity(opacity)
	local childArray = self.mRootNode:getChildren()

	for i = 1, #childArray do
		childArray[i]:setOpacity(opacity)
	end

	if 120 == opacity then
		self.mLabel:setOpacity(190)
	else
		self.mLabel:setOpacity(255)
	end
end

function PanelRight:setTouchEnabled(enabled)
	self.mRootNode:getChildByName("Panel_Touch"):setTouchEnabled(enabled)
end

function PanelRight:setRedVisible(visible)
	self.mRootNode:getChildByName("Image_Notice_5017"):setVisible(visible)
end

function NiubilityWidget:new()
	local o = 
	{
		mParentNode			=	nil,
		mRootNode 			= 	nil,
		mPanelLeft			=	nil,	-- 左面板
		mPanelRight			=	nil,	-- 右面板
		mProcessTouchPanel 	=	nil, 	-- 滑动层
		mEnabled			=	true,	-- 是否可用
		mScrollEnabled		=	true, 	-- 是否允许滑动
		
	}
	o = newObject(o, NiubilityWidget)
	return o
end

function NiubilityWidget:setEnabled(enabled)
	if self.mEnabled and not enabled and not showedType then -- 从可切换到不可切换
		self:playAnim2()
	end
	self.mEnabled = enabled
end

function NiubilityWidget:init(parentNode, pos, leftContent, leftLabel, rightContent, rightLabel)
	self.mParentNode = parentNode
	self.mRootNode = GUIWidgetPool:createWidget("Niubility")

	showedType = true

	self.mParentNode:addChild(self.mRootNode, 1000)
	self.mRootNode:setPosition(pos)

	self.mPanelLeft = PanelLeft:new(self.mRootNode:getChildByName("Panel_Left"), self)
	self.mPanelLeft:setTouchEnabled(false)
	self.mPanelLeft.mMainPanel:addChild(leftContent)
	self.mPanelLeft.mLabel:addChild(leftLabel)
	self.mPanelRight = PanelRight:new(self.mRootNode:getChildByName("Panel_Right"), self)
	self.mPanelRight.mMainPanel:addChild(rightContent)
	self.mPanelRight.mLabel:addChild(rightLabel)

--	local function xxx()
		self:initTouchLayer()
--	end
--	nextTick(xxx)
end

function NiubilityWidget:initTouchLayer()
	-- self.mTouchLayer = self.mRootNode:getChildByName("Panel_Main")

	-- local function onTouchLayer(widget, eventType)
	-- 	local posBegan 	= 	nil
	-- 	local posEnd 	=	nil
	-- 	if eventType == ccui.TouchEventType.began then

 --    	elseif eventType == ccui.TouchEventType.moved then

 --    	elseif eventType == ccui.TouchEventType.ended then
 --    		posBegan = cc.p(widget:getTouchBeganPosition())
 --    		posEnd = cc.p(widget:getTouchEndPosition())
 --    		if posBegan.x > 500 then
 --    			return
 --    		end
 --    		local deltaX = posEnd.x - posBegan.x
 --    		if deltaX > 0 then
 --    			print("向右滑动")
 --    		elseif deltaX < 0 then
 --    			print("向左滑动")
 --    		end
 --    	elseif eventType == ccui.TouchEventType.canceled then

 --    	end
	-- end
	-- self.mTouchLayer:addTouchEventListener(onTouchLayer)

	local posBegan 	= 	nil
	local posEnd 	=	nil

	local contentSize = self.mRootNode:getChildByName("Panel_Main"):getContentSize()

	local function onTouchBegan(touch, event)
		posBegan = touch:getLocation()
		print("坐标", posBegan.x, posBegan.y)
		return true
	end

	local function onTouchMoved(touch, event)
		
	end

	local function onTouchEnded(touch, event)
		local worldPos = cc.p(self.mRootNode:getChildByName("Panel_Main"):getWorldPosition())
		local rect = cc.rect(worldPos.x, worldPos.y, contentSize.width, contentSize.height)
		if cc.rectContainsPoint(rect, posBegan) then
			
		else
			return
		end

		posEnd = touch:getLocation()
		local deltaX = math.abs(posEnd.x - posBegan.x)
		local deltaY = math.abs(posEnd.y - posBegan.y)
		if deltaX > deltaY and deltaX > 20 then
			self:scrollEvent()
		elseif deltaX < deltaY then
			
		end
	end

	local function onTouchCancelled(touch, event)
		
	end

--	cc.LayerGradient:create()
 --   layer3:setContentSize(cc.size(80, 80))

	self.mProcessTouchPanel = cc.Layer:create()

	local listener = cc.EventListenerTouchOneByOne:create()
	listener:setSwallowTouches(false)
	listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    listener:registerScriptHandler(onTouchCancelled,cc.Handler.EVENT_TOUCH_CANCELLED )
    local eventDispatcher = self.mProcessTouchPanel:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self.mProcessTouchPanel)
    self.mRootNode:addChild(self.mProcessTouchPanel, 1000)
    self.mProcessTouchPanel:setPosition(cc.p(0, 0))
end

function NiubilityWidget:scrollEvent()
	if not self.mEnabled then
		return
	end

	if not self.mScrollEnabled then
		return
	end

	if true == showedType then
		showedType = nil
		self:playAnim1()
	elseif false == showedType then
		showedType = nil
		self:playAnim2()
	end
end

function NiubilityWidget:show()
	self.mPanelLeft:init()
	self.mPanelRight:init()
end

function NiubilityWidget:playAnim1()
	if not self.mEnabled then
		return
	end

	print("playAnim1()")
	self.mPanelLeft:playAnim1()
	self.mPanelRight:playAnim1()
end

function NiubilityWidget:playAnim2()
	if not self.mEnabled then
		return
	end

	self.mPanelLeft:playAnim2()
	self.mPanelRight:playAnim2()
end

function NiubilityWidget:setScrollEnabled(enabled)
	self.mScrollEnabled = enabled
end





