-- Name: 	LotteryWindow
-- Func：	英雄招募
-- Author:	lvyunlong
-- Data:	14-12-9

local moveTime = 0.3
local deltaX = 1000

LotteryWindow = 
{
	mName 				=	"LotteryWindow",
	mRootNode			=	nil,
	mRootWidget			=	nil,

	---------------------------------------
	mPanelBtnList 		=	nil,
	mBtnRight 			=	nil,
	mBtnLeft 			=	nil,
	---------------------------------------
	mType1LeftSeconds 	=	nil, 			-- 类型一免费剩余时间
	mTimeWidget1 		=	nil,			-- 计时器1
	mTimeWidget1_2 		=	nil,			-- 计时器
	mType2LeftSeconds 	=	nil, 			-- 类型二免费剩余时间
	mTimeWidget2 		=	nil,			-- 计时器2
	mTimeWidget2_2 		=	nil,			-- 计时器
	---------------------------------------
	mCurLotteryType 	=	nil,			-- 当前抽卡类型
	mTopRoleInfoPanel	=	nil,			-- 顶部人物信息面板
}
-- gacha.xlsx
GachaItemDataTable = {20278,
20280,
20281,
20282,
20283,
20284,
20286,
20287,
20288,
20289,
20290,
20291,
20293,
20295,
20297,
20298,
20299,
20300,
}

-- hero表
HeroDataTable = {2,4,5,6,7,8,10,11,12,13,14,15,17,19,21,22,23,24}

ItemCountTable = {1,5,9,13}

function LotteryWindow:Release()

end

function LotteryWindow:Load()
	cclog("=====LotteryWindow:Load=====begin")

	self.mRootNode = cc.Node:create()
	GUISystem:GetRootNode():addChild(self.mRootNode)

	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_REQUEST_EXCUTELOTTERY_, handler(self,self.onExcuteLottery))
	-- 初始化布局相关
	self:InitLayout()

	-- 刷新抽卡信息
	self:updateLotteryInfo()

	cclog("=====LotteryWindow:Load=====end")
end

function LotteryWindow:InitLayout()
	self.mRootWidget = GUIWidgetPool:createWidget("Lottery_Main")
	self.mRootWidgetResult = GUIWidgetPool:createWidget("Lottery_Result")

	self.mRootNode:addChild(self.mRootWidget)
	self.mRootNode:addChild(self.mRootWidgetResult,101)

	--self.mPanelBtnList = self.mRootWidget:getChildByName("Panel_BtnList")
	self.mRootWidget:getChildByName("Panel_Main")


	local function closeWindow()
		-- 抽卡完成
		if LotteryGuideOne:canGuide() then
			LotteryGuideOne:stop()
			return
		end
		GUISystem:playSound("homeBtnSound")
		EventSystem:PushEvent(Event.GUISYSTEM_HIDE_LOTTERYWINDOW)
	end

	self.mTimeWidget1 = self.mRootWidget:getChildByName("Label_LastFreeTime_1")

	self.mFreeTime = self.mTimeWidget1:getChildByName("Label_17")

	self.mLabelCost1 = self.mRootWidget:getChildByName("Label_Cost_1")
	self.mLabelCostFree = self.mRootWidget:getChildByName("Label_Cost_Free")
	

	-- 创建摇杆
	self.mOneLottery = self.mRootWidget:getChildByName("Panel_Touch_YaoGan_Lan")
	self.mTenLottery = self.mRootWidget:getChildByName("Panel_Touch_YaoGan_Hong")
	self.mZhuanpan = self.mRootWidget:getChildByName("Panel_Spine_ZhuanPan")
	self.mZhuanpanDeng = self.mRootWidget:getChildByName("Panel_Spine_ZhuanPanDeng")

	self.mOneLotteryPos = self.mRootWidget:getChildByName("Panel_Spine_YaoGan_Lan")
	self.mTenLotteryPos = self.mRootWidget:getChildByName("Panel_Spine_YaoGan_Hong")

	self.mOneLotteryBtn = self.mRootWidget:getChildByName("Button_Get_1")
	self.mOneLotteryBtn:setTag(1)
	self.mTenLotteryBtn = self.mRootWidget:getChildByName("Button_Get_10")
	self.mTenLotteryBtn:setTag(10)
	-- 花费

	self.mOneLottery:setTag(1)
	registerWidgetReleaseUpEvent(self.mOneLottery, handler(self, self.requestDoLottery))
	registerWidgetReleaseUpEvent(self.mOneLotteryBtn, handler(self, self.requestDoLottery))
	-- 钻石十连抽
	self.mTenLottery:setTag(10)
	registerWidgetReleaseUpEvent(self.mTenLottery, handler(self, self.requestDoLottery))
	registerWidgetReleaseUpEvent(self.mTenLotteryBtn, handler(self, self.requestDoLottery))

	self.mCurLotteryType = 2

	self.mZhuanpanCount = 0
	self.mZhuanpaniconList = {}

	self.mSpeedzhuanpan = 3
	self.mSpeedyaogan = 2
	self.mSpeedzhuanpanLast = 0.5

	self.mSpineLan = CommonAnimation.createCacheSpine_commonByResID(878,self.mOneLotteryPos)
	--self.mSpineLan:setAnimation(0,"start",true)
	self.mSpineLan:registerSpineEventHandler(handler(self, self.onAnimationEvent_Lan), 1)

	self.mSpineHong = CommonAnimation.createCacheSpine_commonByResID(877,self.mTenLotteryPos)
	self.mSpineHong:registerSpineEventHandler(handler(self, self.onAnimationEvent_Hong), 1)
	--self.mSpineHong:setAnimation(0,"start",true)

	self.mSpineZhuanpan = CommonAnimation.createCacheSpine_commonByResID(879,self.mZhuanpan)
	self.mSpineZhuanpan:registerSpineEventHandler(handler(self, self.onAnimationEvent_Zhuanpan), 1)
	self.mSpineZhuanpan:registerSpineEventHandler(handler(self, self.onAnimationEvent_Zhuanpan), 3)
	self.mSpineZhuanpan:setAnimation(0,"stand",false)
	--[[
	self.mSpineZhuanpanDeng = CommonAnimation.createCacheSpine_commonByResID(880,self.mZhuanpanDeng)
	self.mSpineZhuanpanDeng:registerSpineEventHandler(handler(self, self.onAnimationEvent_Deng), 1)
	self.mSpineZhuanpanDeng:setAnimation(0,"stand",true)
	]]

	self.mSpineZhuanpanDeng = AnimManager:createAnimNode(8054)
	self.mZhuanpanDeng:addChild(self.mSpineZhuanpanDeng:getRootNode(), 100)
	self.mSpineZhuanpanDeng:play("lottery_main_1",true)
	-- 创建转盘物品

	for i=1,5 do
		local _gripPos = self.mSpineZhuanpan:getBonePosition(string.format("banzi%d",i))
		local imgWidget = ccui.ImageView:create()
		local num = math.random(1,18)
		local _data = DB_HeroConfig.getDataById(HeroDataTable[num])
		local _iconid = _data.IconBigID 
		local srcpath = DB_ResourceList.getDataById(_iconid).Res_path1
		local widget = GUIWidgetPool:createWidget("ItemWidget")
		widget:getChildByName("Image_Quality"):setVisible(true)
		widget:getChildByName("Image_Quality"):loadTexture("icon_item_quality1.png",1)
		widget:getChildByName("Image_Quality_Bg"):setVisible(true)
		widget:getChildByName("Image_Quality_Bg"):loadTexture("icon_item_quality_bg1.png",1)
		widget:getChildByName("Image_HeroIcon"):setVisible(true)   
		widget:getChildByName("Image_HeroIcon"):getChildByName("Image_HeroIcon"):loadTexture(srcpath,1)
		imgWidget:loadTexture("icon_item_quality1.png",1)
		imgWidget:setAnchorPoint(0.5,0.5)
		imgWidget:addChild(widget)
		self.mZhuanpan:addChild(imgWidget,i)
		if _gripPos then
			imgWidget:setPosition(_gripPos)
		end

		self.mZhuanpaniconList[i] = imgWidget
	end
	

	for i=1,5 do
		local index = math.random(1,#GachaItemDataTable)
		local count = math.random(1,4)
		self:ChangeImage(self.mZhuanpaniconList[i],0,GachaItemDataTable[index],ItemCountTable[count])

		-- local num = math.random(1,3)
		-- if num == 1 then
		-- 	-- 这是英雄
		-- 	local num1 = math.random(1,18)
		-- 	local heroid = HeroDataTable[num1]
		-- 	self:ChangeImage(self.mZhuanpaniconList[i],10,heroid)
		-- else
		-- 	-- 这是物品
		-- 	local index = math.random(1,#GachaItemDataTable)
		-- 	local count = math.random(1,5)
		-- 	self:ChangeImage(self.mZhuanpaniconList[i],0,GachaItemDataTable[index],count)
		-- end
	end

	-- 1抽
	self.mOneItemPanel = self.mRootWidgetResult:getChildByName("Panel_Result_1")
	registerWidgetReleaseUpEvent(self.mOneItemPanel:getChildByName("Button_Close"), handler(self, self.closeOneLottery))
	self.mOneItemPanel:getChildByName("Button_Again"):setTag(1)
	registerWidgetReleaseUpEvent(self.mOneItemPanel:getChildByName("Button_Again"), handler(self, self.requestDoLotteryAgain))
	-- 10抽
	self.mTenItemPanel = self.mRootWidgetResult:getChildByName("Panel_Result_10")
	registerWidgetReleaseUpEvent(self.mTenItemPanel:getChildByName("Button_Close"), handler(self, self.closeTenLottery))
	self.mTenItemPanel:getChildByName("Button_Again"):setTag(10)
	registerWidgetReleaseUpEvent(self.mTenItemPanel:getChildByName("Button_Again"), handler(self, self.requestDoLotteryAgain))

	self.mTopRoleInfoPanel = TopRoleInfoPanel:new()
	local topInfoPanel = self.mTopRoleInfoPanel:init(self.mRootNode,ROLE_TITLE_TYPE.TITLE_LOTTERY, closeWindow)




	local function doAdapter()
	    local topInfoPanelSize = topInfoPanel:getContentSize()
	    local newHeight = getGoldFightPosition_LU().y - topInfoPanelSize.height - getGoldFightPosition_LD().y
	    local newPosY = newHeight/2 + getGoldFightPosition_LD().y - self.mRootWidget:getChildByName("Panel_Main"):getContentSize().height/2
		--self.mRootWidget:getChildByName("Panel_Main"):setPositionY(newPosY)

		self.mRootWidget:getChildByName("Panel_Main"):setAnchorPoint(cc.p(0.5, 0.5))

		local panelSize = self.mRootWidget:getChildByName("Panel_Main"):getContentSize()
	    local curPosX = self.mRootWidget:getChildByName("Panel_Main"):getPositionX()
	    self.mRootWidget:getChildByName("Panel_Main"):setPositionX(curPosX + panelSize.width/2)
		self.mRootWidget:getChildByName("Panel_Main"):setPositionY(getGoldFightPosition_LD().y + panelSize.height/2)
		self.mRootWidget:getChildByName("Panel_Main"):setOpacity(0)

		-- 做由小变大效果
		local function onActEnd()
			GUISystem:enableUserInput()
		end

		if LotteryGuideOne:canGuide() then
			local guideBtn = self.mRootWidget:getChildByName("Button_Get_1")
			local size = guideBtn:getContentSize()
			local pos = guideBtn:getWorldPosition()
			pos.x = pos.x - size.width/2
			pos.y = pos.y - size.height/2
			local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
			LotteryGuideOne:step(2, touchRect)
		end

		self.mRootWidget:getChildByName("Panel_Main"):setScale(0.5)
		local act0 = cc.ScaleTo:create(0.15, 1)
		local act1 = cc.FadeIn:create(0.15)
		local act2 = cc.CallFunc:create(onActEnd)
		self.mRootWidget:getChildByName("Panel_Main"):runAction(cc.Spawn:create(act0, act1, act2))
		GUISystem:disableUserInput()
	end

	doAdapter()
	-- 价格
	self:freshPrice()

	--[[

	-- 查看钻石抽卡
	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_HighCheck"), handler(self, self.checkHighLottery))
	-- 查看金币抽卡
	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_LowCheck"), handler(self, self.checkLowLottery))
	-- 金币抽返回
	self.mBtnLeft = self.mRootWidget:getChildByName("Button_Left")
	registerWidgetReleaseUpEvent(self.mBtnLeft, handler(self, self.returnFromLeft))
	self.mBtnLeft:setVisible(false)
	-- 钻石抽返回
	self.mBtnRight = self.mRootWidget:getChildByName("Button_Right")
	registerWidgetReleaseUpEvent(self.mBtnRight, handler(self, self.returnFromRight))
	self.mBtnRight:setVisible(false)

	-- 计时器
	self.mTimeWidget1 = self.mRootWidget:getChildByName("Panel_LowCheck"):getChildByName("Label_LeftTime")
	self.mTimeWidget1_2 = self.mRootWidget:getChildByName("Panel_LowLottery1"):getChildByName("Label_LeftTime")
	self.mTimeWidget2 = self.mRootWidget:getChildByName("Panel_HighCheck"):getChildByName("Label_LeftTime")
	self.mTimeWidget2_2 = self.mRootWidget:getChildByName("Panel_HighLottery1"):getChildByName("Label_LeftTime")

	-- 钻石单抽
	self.mRootWidget:getChildByName("Button_HighLottery1"):setTag(1)
	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_HighLottery1"), handler(self, self.requestDoLottery))

	-- 钻石十连抽
	self.mRootWidget:getChildByName("Button_HighLottery2"):setTag(10)
	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_HighLottery2"), handler(self, self.requestDoLottery))

	-- 金币单抽
	self.mRootWidget:getChildByName("Button_LowLottery1"):setTag(1)
	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_LowLottery1"), handler(self, self.requestDoLottery))

	-- 金币十连抽
	self.mRootWidget:getChildByName("Button_LowLottery2"):setTag(10)
	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_LowLottery2"), handler(self, self.requestDoLottery))

	-- 价格
	self:freshPrice()

	]]
end

function LotteryWindow:onAnimationEvent_Lan(event)
	if event.type == 'end' then
		local function Finish(Aniself)
			Aniself:play("lottery_main_1",true)
		end
		self.mSpineZhuanpan:setAnimationWithSpeedScale(0,"start",false,1.5)
		self.mSpineZhuanpanDeng:play("lottery_main_2",false,Finish)
		--self.mSpineZhuanpanDeng:setAnimationWithSpeedScale(0, "start", false,self.mSpeedzhuanpan)
	elseif event.type == 'event' then
	
	end
end

function LotteryWindow:onAnimationEvent_Hong(event)
	if event.type == 'end' then
		local function Finish(Aniself)
			Aniself:play("lottery_main_1",true)
		end
		self.mSpineZhuanpan:setAnimationWithSpeedScale(0,"start",false,1.5)
		self.mSpineZhuanpanDeng:play("lottery_main_2",false,Finish)
		--self.mSpineZhuanpanDeng:setAnimationWithSpeedScale(0, "start", false,self.mSpeedzhuanpan)
	elseif event.type == 'event' then
	
	end
end

function LotteryWindow:onAnimationEvent_Zhuanpan(event)
	if event.type == 'end' and event.animation == "start" then

		self.mZhuanpanCount = self.mZhuanpanCount + 1

		-- elseif self.mZhuanpanCount == 7 then
		-- 	GUISystem:enableUserInput()
		-- 	self:GetLotterItems()
		-- 	self.mZhuanpanCount = 0

		if self.mZhuanpanCount == 3 then
			self.mSpineZhuanpan:setAnimationWithSpeedScale(0, "end", false, 1)
		else
			self.mSpineZhuanpan:setAnimationWithSpeedScale(0, "start", false,1.5)
		end
	elseif event.type == 'end' and event.animation == "end" then
		GUISystem:enableUserInput()
		self:GetLotterItems()
		self.mZhuanpanCount = 0
	elseif event.type == 'event' then
		local num = tonumber(event.eventData.name)
		if num == 5 then
			self:ChangeImage(self.mZhuanpaniconList[2], self.mResult[1][1], self.mResult[2][1],self.mResult[3][1])
		else
			local Zhuanindex = num
			-- if num == 1 then
			-- 	Zhuanindex = 4
			-- elseif num == 2 then
			-- 	Zhuanindex = 3
			-- elseif num == 3 then
			-- 	Zhuanindex = 2
			-- elseif num == 4 then
			-- 	Zhuanindex = 1
			-- end
			local index = math.random(1,#GachaItemDataTable)
			local count = math.random(1,4)
			self:ChangeImage(self.mZhuanpaniconList[Zhuanindex],0,GachaItemDataTable[index],ItemCountTable[count])
			-- local randomnum = math.random(1,3)
			-- if randomnum == 1 then
			-- 	-- 这是英雄
			-- 	local num1 = math.random(1,18)
			-- 	local heroid = HeroDataTable[num1]
			-- 	self:ChangeImage(self.mZhuanpaniconList[Zhuanindex],10,heroid)
			-- else
			-- 	-- 这是物品
			-- 	local index = math.random(1,#GachaItemDataTable)
			-- 	local count = math.random(1,5)
			-- 	self:ChangeImage(self.mZhuanpaniconList[Zhuanindex],0,GachaItemDataTable[index],count)
			-- end
		end
	end
end

function LotteryWindow:ChangeImage(_panel , itemtype,id,num)
	if itemtype == 0 or itemtype == 11 then
		local widget = createCommonWidget(0,id,num)
		_panel:removeAllChildren()
		_panel:addChild(widget)
	elseif itemtype == 10 then
		_panel:removeAllChildren()
		local herodata = DB_HeroConfig.getDataById(id)
		local _iconid = herodata.IconBigID 
		local srcpath = DB_ResourceList.getDataById(_iconid).Res_path1
		local widget = GUIWidgetPool:createWidget("ItemWidget")
		widget:getChildByName("Image_Quality"):setVisible(true)
		widget:getChildByName("Image_Quality"):loadTexture("icon_item_quality1.png",1)
		widget:getChildByName("Image_Quality_Bg"):setVisible(true)
		widget:getChildByName("Image_Quality_Bg"):loadTexture("icon_item_quality_bg1.png",1)
		widget:getChildByName("Image_HeroIcon"):setVisible(true)   
		widget:getChildByName("Image_HeroIcon"):getChildByName("Image_HeroIcon"):loadTexture(srcpath,1)
		widget:setTag(10000)
		widget:getChildByName("Image_SuperHero"):setVisible(true)
		if 1 == herodata.QualityB then
			widget:getChildByName("Image_SuperHero"):loadTexture("icon_hero_super_1.png",1)
		else
			widget:getChildByName("Image_SuperHero"):loadTexture("icon_hero_super_0.png",1)
		end

		

		_panel:addChild(widget)
	end
end

function LotteryWindow:onAnimationEvent_Deng(event)
	if event.type == 'end' then
		
	elseif event.type == 'event' then
	
	end
end

function LotteryWindow:closeOneLottery()
	self.mOneItemPanel:setVisible(false)

	local function doLotteryGuideOne()
		local window = GUISystem:GetWindowByName("LotteryWindow")
		if window.mRootWidget then
			local guideBtn = window.mTopRoleInfoPanel.mTopWidget:getChildByName("Button_Back")
			local size = guideBtn:getContentSize()
			local pos = guideBtn:getWorldPosition()
			pos.x = pos.x - size.width/2
			pos.y = pos.y - size.height/2
			local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
			LotteryGuideOne:step(3, touchRect)
		end
	end
	doLotteryGuideOne()
end

function LotteryWindow:closeTenLottery()
	self.mTenItemPanel:setVisible(false)
end

function LotteryWindow:freshPrice()
	local type2price1 = globaldata:getLotteryByTypeAndKey(2, "onceCostNum")
	local type2price10 = globaldata:getLotteryByTypeAndKey(2, "tenthCostNum")

		-- 钻石
	self.mRootWidget:getChildByName("Label_Cost_1"):setString(tostring(type2price1))
	self.mRootWidget:getChildByName("Label_Cost_10"):setString(tostring(type2price10))

	--[[
	local type1price1 = globaldata:getLotteryByTypeAndKey(1, "onceCostNum")
	local type1price10 = globaldata:getLotteryByTypeAndKey(1, "tenthCostNum")
	local type2price1 = globaldata:getLotteryByTypeAndKey(2, "onceCostNum")
	local type2price10 = globaldata:getLotteryByTypeAndKey(2, "tenthCostNum")
	local secret1 = globaldata:getLotteryByTypeAndKey(2, "onceSecretAdd")
	local secret10 = globaldata:getLotteryByTypeAndKey(2, "tenthSecretAdd")

	-- 金币
	self.mRootWidget:getChildByName("Panel_Left"):getChildByName("Panel_LowLottery1"):getChildByName("Label_Price"):setString(tostring(type1price1))
	self.mRootWidget:getChildByName("Panel_Left"):getChildByName("Panel_LowLottery2"):getChildByName("Label_Price"):setString(tostring(type1price10))

	-- 钻石
	self.mRootWidget:getChildByName("Panel_Right"):getChildByName("Panel_HighLottery1"):getChildByName("Label_Price"):setString(tostring(type2price1))
	self.mRootWidget:getChildByName("Panel_Right"):getChildByName("Panel_HighLottery2"):getChildByName("Label_Price"):setString(tostring(type2price10))

	-- 神秘币
	self.mRootWidget:getChildByName("Panel_Right"):getChildByName("Panel_HighLottery1"):getChildByName("Label_23_0"):setString(tostring(secret1))
	self.mRootWidget:getChildByName("Panel_Right"):getChildByName("Panel_HighLottery2"):getChildByName("Label_23"):setString(tostring(secret10))

	-- 金币
	self.mRootWidget:getChildByName("Panel_LowCheck"):getChildByName("Label_Price"):setString(tostring(type1price1))
	-- 钻石
	self.mRootWidget:getChildByName("Panel_HighCheck"):getChildByName("Label_Price"):setString(tostring(type2price1))
	]]
end

-- 查看钻石抽
function LotteryWindow:checkHighLottery()
	GUISystem:playSound("lotteryScrollBtnSound")
	local curPos = cc.p(self.mPanelBtnList:getPosition())
	local newPos = cc.p(curPos.x - deltaX, curPos.y)

	local function actEnd()
		self.mBtnRight:setVisible(true)

		self.mRootWidget:getChildByName("Button_HighCheck"):setTouchEnabled(true)
		self.mRootWidget:getChildByName("Button_LowCheck"):setTouchEnabled(true)
	end

	local act0 = cc.MoveTo:create(moveTime, newPos)
	local act1 = cc.CallFunc:create(actEnd)
	self.mPanelBtnList:runAction(cc.Sequence:create(act0, act1))

	self.mRootWidget:getChildByName("Button_HighCheck"):setTouchEnabled(false)
	self.mRootWidget:getChildByName("Button_LowCheck"):setTouchEnabled(false)

	self.mCurLotteryType = 2
end

-- 钻石抽返回
function LotteryWindow:returnFromRight(widget)
	GUISystem:playSound("lotteryScrollBtnSound")
	local curPos = cc.p(self.mPanelBtnList:getPosition())
	local newPos = cc.p(curPos.x + deltaX, curPos.y)
	local act0 = cc.MoveTo:create(moveTime, newPos)
	self.mPanelBtnList:runAction(act0)
	widget:setVisible(false)
end

-- 查看金币抽
function LotteryWindow:checkLowLottery()
	GUISystem:playSound("lotteryScrollBtnSound")
	local curPos = cc.p(self.mPanelBtnList:getPosition())
	local newPos = cc.p(curPos.x + deltaX, curPos.y)

	local function actEnd()
		self.mBtnLeft:setVisible(true)

		self.mRootWidget:getChildByName("Button_HighCheck"):setTouchEnabled(true)
		self.mRootWidget:getChildByName("Button_LowCheck"):setTouchEnabled(true)
	end

	local act0 = cc.MoveTo:create(moveTime, newPos)
	local act1 = cc.CallFunc:create(actEnd)
	self.mPanelBtnList:runAction(cc.Sequence:create(act0, act1))

	self.mRootWidget:getChildByName("Button_HighCheck"):setTouchEnabled(false)
	self.mRootWidget:getChildByName("Button_LowCheck"):setTouchEnabled(false)

	self.mCurLotteryType = 1
end

-- 金币抽返回
function LotteryWindow:returnFromLeft(widget)
	GUISystem:playSound("lotteryScrollBtnSound")
	local curPos = cc.p(self.mPanelBtnList:getPosition())
	local newPos = cc.p(curPos.x - deltaX, curPos.y)
	local act0 = cc.MoveTo:create(moveTime, newPos)
	self.mPanelBtnList:runAction(act0)
	widget:setVisible(false)
end

-- 更新抽卡信息
function LotteryWindow:updateLotteryInfo()
	--self.mType1LeftSeconds = globaldata:getLotteryByTypeAndKey(1, "leftTime")
	self.mType2LeftSeconds = globaldata:getLotteryByTypeAndKey(2, "leftTime")
	self.mTimeWidget1:setString(secondToHour(self.mType2LeftSeconds))
	if self.mType2LeftSeconds <= 0 then
		self.mFreeTime:setVisible(false)
		self.mTimeWidget1:setVisible(false)
		self.mLabelCost1:setVisible(false)
		self.mLabelCostFree:setVisible(true)

	else
		self.mFreeTime:setVisible(true)
		self.mTimeWidget1:setVisible(true)
		self.mLabelCost1:setVisible(true)
		self.mLabelCostFree:setVisible(false)
	end
	-- if self.mType2LeftSeconds > 0 then
	-- 	self.mType2LeftSeconds = self.mType2LeftSeconds - 1
	-- 	self.mTimeWidget2:setString(secondToHour(self.mType2LeftSeconds))
	-- end
	self:startTick()
end

function LotteryWindow:startTick()
	self.mTickSeconds = 0
	local scheduler = cc.Director:getInstance():getScheduler()
	if not self.mSchedulerEntry then
		self.mSchedulerEntry = scheduler:scheduleScriptFunc(handler(self, self.doTick), 0.03, false)
	end
end

function LotteryWindow:stopTick()
	self.mTickSeconds = nil
	local scheduler = cc.Director:getInstance():getScheduler()
	if self.mSchedulerEntry then
		scheduler:unscheduleScriptEntry(self.mSchedulerEntry)
		self.mSchedulerEntry = nil
	end
end

function LotteryWindow:doTick(time)
	if self.mType2LeftSeconds > 0 then
		self.mTickSeconds = self.mTickSeconds + time
		if self.mTickSeconds >= 1 then
			self.mTickSeconds = self.mTickSeconds - 1
			self.mType2LeftSeconds = self.mType2LeftSeconds - 1
			self.mTimeWidget1:setString(secondToHour(self.mType2LeftSeconds))
		end
		if self.mType2LeftSeconds <= 0 then
			self.mFreeTime:setVisible(false)
			self.mTimeWidget1:setVisible(false)
			self.mLabelCost1:setVisible(false)
			self.mLabelCostFree:setVisible(true)
		else
			self.mFreeTime:setVisible(true)
			self.mTimeWidget1:setVisible(true)
			self.mLabelCost1:setVisible(true)
			self.mLabelCostFree:setVisible(false)
		end
	end
	self:TickIconPos()
end

function LotteryWindow:TickIconPos()
	for i=1,5 do
		local _gripPos = self.mSpineZhuanpan:getBonePosition(string.format("banzi%d",i))
		if _gripPos then
			self.mZhuanpaniconList[i]:setPosition(_gripPos)
		end
	end
end

-- 请求抽卡
local _LOTTERY_INTERVAL_   =  2
local _CanLottery_   =  true
function LotteryWindow:requestDoLottery(widget)
	if not _CanLottery_ then return end
	GUISystem:playSound("lotterySound")
	local packet = NetSystem.mNetManager:GetSPacket()
    packet:SetType(PacketTyper._PTYPE_CS_REQUEST_EXCUTELOTTERY_)

    packet:PushUShort(self.mCurLotteryType)
    packet:PushUShort(widget:getTag())
    packet:PushUShort(1)
	packet:Send()
	GUISystem:showLoading()

	_CanLottery_ = false
	local function setLottery()
		_CanLottery_ = true
	end
	nextTick_frameCount(setLottery, _LOTTERY_INTERVAL_)

	-- 指引暂停
	LotteryGuideOne:pause()
end

-- 再次抽卡
function LotteryWindow:requestDoLotteryAgain(widget)
	self.mOneItemPanel:setVisible(false)
	self.mTenItemPanel:setVisible(false)
	GUISystem:playSound("lotterySound")
	local packet = NetSystem.mNetManager:GetSPacket()
    packet:SetType(PacketTyper._PTYPE_CS_REQUEST_EXCUTELOTTERY_)

    packet:PushUShort(self.mCurLotteryType)
    packet:PushUShort(widget:getTag())
    packet:PushUShort(1)
	packet:Send()
	self.IsAgain = true
	GUISystem:showLoading()
end

-- 抽卡回包
function LotteryWindow:onExcuteLottery(msgPacket)
	local lotteryType = msgPacket:GetInt()
	local leftTime = msgPacket:GetInt()
	self.mType2LeftSeconds = leftTime
	self.mTimeWidget1:setString(secondToHour(self.mType2LeftSeconds))
	if self.mType2LeftSeconds <= 0 then
		self.mFreeTime:setVisible(false)
		self.mTimeWidget1:setVisible(false)
		self.mLabelCost1:setVisible(false)
		self.mLabelCostFree:setVisible(true)
	else
		self.mFreeTime:setVisible(true)
		self.mTimeWidget1:setVisible(true)
		self.mLabelCost1:setVisible(true)
		self.mLabelCostFree:setVisible(false)
	end
	local count = msgPacket:GetUShort()

	self.mResult = {}
	self.mResult[1] = {}
	self.mResult[2] = {}
	self.mResult[3] = {}
	self.mResult[4] = {}
	self.mResult[5] = {}

	self.mTypeCall = count

	print("count", count)
	for i = 1, count do
		local heroOrItem = msgPacket:GetUChar()
		print("heroOrItem", heroOrItem)
		if 0 == heroOrItem then --新英雄
			self.mResult[1][i] = 10
			self.mResult[2][i], self.mResult[5][i] = globaldata:addHeroFromLottery(msgPacket)
			self.mResult[3][i] = -1
			self.mResult[4][i] = true
		elseif 1 == heroOrItem then --旧英雄
			local heroId = msgPacket:GetInt()
			local heroName = msgPacket:GetString()
			print("heroId, heroName", heroId, heroName)
			self.mResult[1][i] = 10
			self.mResult[2][i] = heroId
			self.mResult[3][i] = -1
			self.mResult[4][i] = false
			self.mResult[5][i] = nil
		elseif 2 == heroOrItem then --物品
			local goodId = msgPacket:GetInt()
			local goodName = msgPacket:GetString()
			local goodNum = msgPacket:GetInt()
			print("goodId, goodName, goodNum", goodId, goodName, goodNum)
			self.mResult[1][i] = 0
			self.mResult[2][i] = goodId
			self.mResult[3][i] = goodNum
			self.mResult[4][i] = false
			self.mResult[5][i] = nil
		elseif 3 == heroOrItem then
			local goodId = msgPacket:GetInt()
			local goodName = msgPacket:GetString()
			local goodNum = msgPacket:GetInt()
			local heroId = msgPacket:GetInt()
			self.mResult[1][i] = 11
			self.mResult[2][i] = goodId
			self.mResult[3][i] = goodNum
			self.mResult[4][i] = heroId
			self.mResult[5][i] = msgPacket:GetInt()
		end	
	end
	if self.IsAgain then
		self.IsAgain = false
		self:GetLotterItems()
		GUISystem:hideLoading()
	else
		if 1 == count then
			self.mSpineLan:setAnimationWithSpeedScale(0,"start",false,self.mSpeedyaogan)
		elseif 10 == count then
			self.mSpineHong:setAnimationWithSpeedScale(0,"start",false,self.mSpeedyaogan)
		end
		GUISystem:hideLoading()
		GUISystem:disableUserInput()
	end
end

function LotteryWindow:GetLotterItems()
	self.mSpineZhuanpanDeng:play("lottery_main_1",true)
	--self.mSpineZhuanpanDeng:setAnimation(0,"stand",true)
	if self.mTypeCall == 1 then
		self:ShowLotterOne(self.mResult)
		self.mOneItemPanel:setVisible(true)
	else
		self:ShowLotterTen(self.mResult)
		self.mTenItemPanel:setVisible(true)
	end
end

function LotteryWindow:ShowLotterOne(result)
	self.mOneItemPanel:getChildByName("Button_Close"):setVisible(false)
	self.mOneItemPanel:getChildByName("Button_Again"):setVisible(false)

	local function showBtn( ... )
		self.mOneItemPanel:getChildByName("Button_Close"):setVisible(true)
		if not LotteryGuideOne:canGuide() then
			self.mOneItemPanel:getChildByName("Button_Again"):setVisible(true)
		end
	end
	local function LastShow( ... )
		local itemtype = result[1][1]
	
		if itemtype == 10 then
			local id = result[2][1]
			local num = result[3][1]
			CommonAnimation.PlayEffectId(5008)
			local newheropanel = createNewHeroPanelByID(id,self.mRootNode,showBtn)
		elseif itemtype == 11 then
			local id = result[4][1]
			local num = result[3][1]

			local _infoDB = DB_HeroConfig.getDataById(id)
			local ItemID = _infoDB.Fragment
			local itemdata = DB_ItemConfig.getDataById(ItemID)

			if itemdata.Quality == 5 or num >= 20 then
				CommonAnimation.PlayEffectId(5008)
				local newheropanel = createNewHeroPanelByID(id,self.mRootNode,showBtn,num)
			else
				self.mOneItemPanel:getChildByName("Button_Close"):setVisible(true)
				if not LotteryGuideOne:canGuide() then
					self.mOneItemPanel:getChildByName("Button_Again"):setVisible(true)
				end
			end
		else
			self.mOneItemPanel:getChildByName("Button_Close"):setVisible(true)
			if not LotteryGuideOne:canGuide() then
				self.mOneItemPanel:getChildByName("Button_Again"):setVisible(true)
			end
		end
	end
	local pos1 = self.mOneItemPanel:getChildByName("Panel_Item_1")
	pos1:removeChildByTag(10000)
	pos1:getChildByName("Label_Name_Stroke"):setVisible(false)
	local function showOnepanel()
		local itemtype = result[1][1]
		local id = result[2][1]
		local num = result[3][1]
		local widget = nil
		if itemtype == 0 or itemtype == 11 then
			widget = createCommonWidget(0,id,num)
			pos1:addChild(widget)
			widget:setTag(10000)
			local itemData   = DB_ItemConfig.getDataById(id)
			local itemNameId = itemData.Name
			local textData   = DB_Text.getDataById(itemNameId)
			nameStr = textData[GAME_LANGUAGE]
			pos1:getChildByName("Label_Name_Stroke"):setString(nameStr)
			pos1:getChildByName("Label_Name_Stroke"):setVisible(true)
		elseif itemtype == 10 then
			local herodata = DB_HeroConfig.getDataById(id)
			local _iconid = herodata.IconBigID 
			local srcpath = DB_ResourceList.getDataById(_iconid).Res_path1
			widget = GUIWidgetPool:createWidget("ItemWidget")
			widget:getChildByName("Image_Quality"):setVisible(true)
			widget:getChildByName("Image_Quality"):loadTexture("icon_item_quality1.png",1)
			widget:getChildByName("Image_Quality_Bg"):setVisible(true)
			widget:getChildByName("Image_Quality_Bg"):loadTexture("icon_item_quality_bg1.png",1)
			widget:getChildByName("Image_HeroIcon"):setVisible(true)   
			widget:getChildByName("Image_HeroIcon"):getChildByName("Image_HeroIcon"):loadTexture(srcpath,1)
			pos1:addChild(widget)
			widget:setTag(10000)
			pos1:getChildByName("Label_Name_Stroke"):setString(getDictionaryText(herodata.Name))
			pos1:getChildByName("Label_Name_Stroke"):setVisible(true)

			widget:getChildByName("Image_SuperHero"):setVisible(true)
			if 1 == herodata.QualityB then
				widget:getChildByName("Image_SuperHero"):loadTexture("icon_hero_super_1.png",1)
			else
				widget:getChildByName("Image_SuperHero"):loadTexture("icon_hero_super_0.png",1)
			end
		end
		pos1:setOpacity(0)
		local act1 = cc.FadeIn:create(0.25)
		local act2 = cc.CallFunc:create(LastShow)
		pos1:runAction(cc.Sequence:create(act1, act2))
	end

	local function playStarFinish(selfAni)
		selfAni:play("lottery_common_2",true)
	end
	local function Finish(evt)
		if evt == "1" then
			showOnepanel()
		end
	end
	if self.star then
		self.star:destroy()
		self.star = nil
	end
	self.star = AnimManager:createAnimNode(8045)
	self.mOneItemPanel:getChildByName("Panel_CommonAnimation"):addChild(self.star:getRootNode(), 100)
	self.star:play("lottery_common_1",false,playStarFinish,Finish)
end

function LotteryWindow:ShowFunItem(widget)
	self.mShowLotterCount = self.mShowLotterCount + 1
	if self.mShowLotterCount == 10 then
		self.mTenItemPanel:getChildByName("Button_Close"):setVisible(true)
		self.mTenItemPanel:getChildByName("Button_Again"):setVisible(true)
	end
	local index = widget:getTag()
	local itemtype = self.mResult[1][index]
	local id = self.mResult[2][index]
	local num = self.mResult[3][index]
	if itemtype == 10 then
		for i=index+1,10 do
			local pos1 = self.mTenItemPanel:getChildByName(string.format("Panel_Item_%d",i))
			pos1:stopAllActions()
		end
		CommonAnimation.PlayEffectId(5008)
		local newheropanel = createNewHeroPanelByID(id,self.mRootNode,handler(self,self.CloseNewPanel))
	elseif itemtype == 11 then
		local _infoDB = DB_HeroConfig.getDataById(self.mResult[4][index])
		local ItemID = _infoDB.Fragment
		local itemdata = DB_ItemConfig.getDataById(ItemID)
		if itemdata.Quality == 5 or num >= 20 then
			for i=index+1,10 do
				local pos1 = self.mTenItemPanel:getChildByName(string.format("Panel_Item_%d",i))
				pos1:stopAllActions()
			end
			CommonAnimation.PlayEffectId(5008)
			local newheropanel = createNewHeroPanelByID(self.mResult[4][index],self.mRootNode,handler(self,self.CloseNewPanel),self.mResult[3][index])
		end
	end
end

function LotteryWindow:CloseNewPanel()
	for i=self.mShowLotterCount+1,10 do
		local pos1 = self.mTenItemPanel:getChildByName(string.format("Panel_Item_%d",i))
		pos1:setOpacity(0)
		local act0 = cc.DelayTime:create(0.2*(i-self.mShowLotterCount-1))
		local ShowFun = cc.CallFunc:create(handler(self,self.ShowFunItem))
		local act1 = cc.FadeIn:create(0.25)
		pos1:runAction(cc.Sequence:create(act0,ShowFun, act1))
	end
end

function LotteryWindow:ShowLotterTen(result)
	self.mTenItemPanel:getChildByName("Button_Close"):setVisible(false)
	self.mTenItemPanel:getChildByName("Button_Again"):setVisible(false)
	self.mShowLotterCount = 0
	local function LastShow( ... )
		self.mTenItemPanel:getChildByName("Button_Close"):setVisible(true)
		self.mTenItemPanel:getChildByName("Button_Again"):setVisible(true)
	end
	for i=1,10 do
		local pos1 = self.mTenItemPanel:getChildByName(string.format("Panel_Item_%d",i))
		pos1:removeChildByTag(10000)
		pos1:getChildByName("Label_Name_Stroke"):setVisible(false)
		pos1:setTag(i)
	end

	local function showTenpanel( ... )
		for i=1,10 do
			local itemtype = result[1][i]
			local id = result[2][i]
			local num = result[3][i]
			local pos1 = self.mTenItemPanel:getChildByName(string.format("Panel_Item_%d",i))
			local widget = nil
			if itemtype == 0 or itemtype == 11 then
				widget = createCommonWidget(0,id,num)
				pos1:addChild(widget)
				widget:setTag(10000)
				local itemData   = DB_ItemConfig.getDataById(id)
				local itemNameId = itemData.Name
				local textData   = DB_Text.getDataById(itemNameId)
				nameStr = textData[GAME_LANGUAGE]
				pos1:getChildByName("Label_Name_Stroke"):setString(nameStr)
				pos1:getChildByName("Label_Name_Stroke"):setVisible(true)
			elseif itemtype == 10 then
				local herodata = DB_HeroConfig.getDataById(id)
				local _iconid = herodata.IconBigID 
				local srcpath = DB_ResourceList.getDataById(_iconid).Res_path1
				widget = GUIWidgetPool:createWidget("ItemWidget")
				widget:getChildByName("Image_Quality"):setVisible(true)
				widget:getChildByName("Image_Quality"):loadTexture("icon_item_quality1.png",1)
				widget:getChildByName("Image_Quality_Bg"):setVisible(true)
				widget:getChildByName("Image_Quality_Bg"):loadTexture("icon_item_quality_bg1.png",1)
				widget:getChildByName("Image_HeroIcon"):setVisible(true)   
				widget:getChildByName("Image_HeroIcon"):getChildByName("Image_HeroIcon"):loadTexture(srcpath,1)
				pos1:addChild(widget)
				widget:setTag(10000)
				pos1:getChildByName("Label_Name_Stroke"):setString(getDictionaryText(herodata.Name))
				pos1:getChildByName("Label_Name_Stroke"):setVisible(true)
				widget:getChildByName("Image_SuperHero"):setVisible(true)
				if 1 == herodata.QualityB then
					widget:getChildByName("Image_SuperHero"):loadTexture("icon_hero_super_1.png",1)
				else
					widget:getChildByName("Image_SuperHero"):loadTexture("icon_hero_super_0.png",1)
				end
			end
			pos1:setOpacity(0)
			local act0 = cc.DelayTime:create(0.2*(i-1))
			local ShowFun = cc.CallFunc:create(handler(self,self.ShowFunItem))
			local act1 = cc.FadeIn:create(0.25)
			pos1:runAction(cc.Sequence:create(act0,ShowFun, act1))
		end
	end

	local function playStarFinish(selfAni)
		selfAni:play("lottery_common_2",true)
	end
	local function Finish(evt)
		if evt == "1" then
			showTenpanel()
		end
	end
	if self.star then
		self.star:destroy()
		self.star = nil
	end
	self.star = AnimManager:createAnimNode(8045)
	self.mTenItemPanel:getChildByName("Panel_CommonAnimation"):addChild(self.star:getRootNode(), 100)
	self.star:play("lottery_common_1",false,playStarFinish,Finish)
end

function LotteryWindow:Destroy()
	NetSystem.mNetManager:UnregisterPacketHandler(PacketTyper._PTYPE_SC_REQUEST_EXCUTELOTTERY_)

	self.mTopRoleInfoPanel:destroy()
	self.mTopRoleInfoPanel = nil
	if self.star then
		self.star:destroy()
		self.star = nil
	end
	self.IsAgain = nil
	self:stopTick()
	SpineDataCacheManager:collectFightSpineByAtlas(self.mSpineLan)
	self.mSpineLan = nil
	SpineDataCacheManager:collectFightSpineByAtlas(self.mSpineHong)
	self.mSpineHong = nil
	SpineDataCacheManager:collectFightSpineByAtlas(self.mSpineZhuanpan)
	self.mSpineZhuanpan = nil
	-- SpineDataCacheManager:collectFightSpineByAtlas(self.mSpineZhuanpanDeng)
	-- self.mSpineZhuanpanDeng = nil
	self.mRootNode:removeFromParent(true)
	self.mRootNode = nil
	self.mRootWidget = nil
	self.mType2LeftSeconds = 0
	self.mTimeWidget2 =	nil	
	self.mType3LeftSeconds = 0
	self.mTimeWidget3 =	nil
	self.mSchedulerEntry = nil
	----------
	CommonAnimation.clearAllTextures()
	cclog("=====LotteryWindow:Destroy=====")
end

function LotteryWindow:onEventHandler(event)
	if event.mAction == Event.WINDOW_SHOW then
		if GUISystem:canShow(self.mName) then
			self:Load(event)
			---------停止画主城镇界面
			EventSystem:PushEvent(Event.GUISYSTEM_DISABLEDRAW_HOMEWINDOW)
			---------
		end
	elseif event.mAction == Event.WINDOW_HIDE then
		self:Destroy()
		---------开启画主城镇界面
		EventSystem:PushEvent(Event.GUISYSTEM_EABLEDRAW_HOMEWINDOW)
		---------
	end
end

return LotteryWindow