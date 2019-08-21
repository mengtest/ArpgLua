-- Name: 	GoldenFingerWindow
-- Func：	点金手
-- Author:	WangShengdong
-- Data:	15-4-7

local moveTime = 0.3

local rewardSz = nil

local retCount = nil

local GoldenFingerWindow = 
{
	mName				=	"GoldenFingerWindow",
	mRootNode			=	nil,
	mRootWidget			=	nil,
	mMainWindow 		=	nil,	-- 主窗口
	mInfoWindow 		=	nil,	-- 信息窗口
	mShowed 			=	false,	

	-------------------------------------------
	mLeftBuyCount 		=	0, 	-- 剩余购买次数
	mTotalBuyCount 		=	0,	-- 总的购买次数
	mPrice 				=	0,	-- 价格
	mReward				=	0, 	-- 回报
	mMaxCountPer        =   0,  -- 单次最大点金次数
}

function GoldenFingerWindow:Release()

end

function GoldenFingerWindow:Load(event)
	cclog("=====GoldenFingerWindow:Load=====begin")

	-- 已经显示则不显示
	if self.mRootNode then
		return
	end

	-- 点金回包
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_GOLDENFINGER_EXECUTE_, handler(self,self.onRequestBuyGold))

	self.mShowed = false

	self.mLeftBuyCount = event.mData.canBuyCount
	self.mTotalBuyCount = event.mData.totalBuyCount
	self.mMaxCountPer = event.mData.maxCountPerRequest
	self.mPrice = event.mData.price
	self.mReward = event.mData.reward

	self.mRootNode = cc.Node:create()
	GUISystem:GetRootNode():addChild(self.mRootNode)

	self:InitLayout()

	-- 刷新数据
	self:updateGoldenInfo()

	cclog("=====GoldenFingerWindow:Load=====end")
end

function GoldenFingerWindow:InitLayout()
	self.mRootWidget = GUIWidgetPool:createWidget("GoldenFinger")
	self.mRootNode:addChild(self.mRootWidget)

	-- 主窗口
	self.mMainWindow = self.mRootWidget:getChildByName("Panel_Main")
	self.mMainWindow:setVisible(true)

	-- 信息窗口
	self.mInfoWindow = self.mRootWidget:getChildByName("Panel_EX")
	self.mInfoWindow:setVisible(false)

	-- 请求点金
	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_Use"), handler(self, self.requestBuyGold))
	self.mRootWidget:getChildByName("Button_Use"):setTag(1)
	-- 请求点金10次
	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_Use10"), handler(self, self.requestBuyGold))
	self.mRootWidget:getChildByName("Button_Use10"):setTag(self.mMaxCountPer)
	-- 标签
	self.mRootWidget:getChildByName("Button_Use10"):getChildByName("Label_9"):setString("使用"..tostring(self.mMaxCountPer).."次")

	-- 初始化滑动功能 
	self:initSelfScrollFunc()

	local function closeWindow()
		EventSystem:PushEvent(Event.GUISYSTEM_HIDE_GOLDENWINDOW)
	end
	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_Close"), closeWindow)
end

-- 更新点金信息
function GoldenFingerWindow:updateGoldenInfo()
	-- 次数
	local str = "(今日可购买"..tostring(self.mLeftBuyCount).."/"..tostring(self.mTotalBuyCount).."次)"
	self.mRootWidget:getChildByName("Label_Times"):setString(str)
	-- 价格
	self.mRootWidget:getChildByName("Label_NewPrice"):setString(tostring(self.mPrice))
	if 0 == self.mPrice then
		self.mRootWidget:getChildByName("Label_NewPrice"):setString("免费")
	end
	-- 回报
	self.mRootWidget:getChildByName("Label_NewReward"):setString(tostring(self.mReward))
end

-- 初始化滑动
function GoldenFingerWindow:initSelfScrollFunc()
	local innerSz = self.mRootWidget:getChildByName("Panel_GoldItem"):getContentSize()
	local outerSz = self.mRootWidget:getChildByName("Panel_Pos"):getContentSize()


	-- 触摸初始位置
	local startTouchPos = nil
	-- 触摸滑动位置
	local moveTouchPos = nil

	-- 层初始Y坐标
	local startPanelPosY = nil
	local movePanelPosY = nil

	local function onTouch(widget, eventType)
    	if eventType == ccui.TouchEventType.began then
     		startPanelPosY = widget:getPositionY()
     		startTouchPos = widget:getTouchBeganPosition()
    	elseif eventType == ccui.TouchEventType.ended then
        
    	elseif eventType == ccui.TouchEventType.moved then
        	moveTouchPos = widget:getTouchMovePosition()
        	movePanelPosY = widget:getPositionY()
        	local deltaY = moveTouchPos.y - startTouchPos.y
        	-- 更新位置
        	movePanelPosY = startPanelPosY + deltaY
        	widget:setPositionY(movePanelPosY)
        	-- 修正坐标
        --	if widget:getPositionY() >=0 then
        --		widget:setPositionY(0)
        	if widget:getPositionY() >= (rewardSz.height*retCount + interVal*(retCount-1) + 25) - innerSz.height  then
	        		widget:setPositionY((rewardSz.height*(retCount) + interVal*(retCount-1) + 25) - innerSz.height)
        	elseif widget:getPositionY() <= outerSz.height - innerSz.height then
        		widget:setPositionY(outerSz.height - innerSz.height)
        	end
    	elseif eventType == ccui.TouchEventType.canceled then
        
    	end
    end
    self.mRootWidget:getChildByName("Panel_GoldItem"):addTouchEventListener(onTouch)
end

-- 点金回包
function GoldenFingerWindow:onRequestBuyGold(msgPacket)
	GUISystem:disableUserInput()
	retCount = msgPacket:GetChar() 	-- 点金成功的次数
	local goldRetInfo = {}
	for i = 1, retCount do
		goldRetInfo[i] = {}
		goldRetInfo[i].price = msgPacket:GetInt()
		goldRetInfo[i].reward = msgPacket:GetInt()
		goldRetInfo[i].crit = msgPacket:GetChar()
	end

	self.mMaxCountPer = msgPacket:GetUShort()
	self.mRootWidget:getChildByName("Button_Use10"):setTag(self.mMaxCountPer)
	-- 标签
	self.mRootWidget:getChildByName("Button_Use10"):getChildByName("Label_9"):setString("使用"..tostring(self.mMaxCountPer).."次")

	self.mPrice = msgPacket:GetInt()
	self.mReward = msgPacket:GetInt()

	print("金钱", self.mPrice, "回报", self.mReward)

	local function addGoldWidget() -- 添加奖励控件
		-- 重置Panel_Reward位置
		local outerSz = self.mRootWidget:getChildByName("Panel_Pos"):getContentSize()
		local panelWgt = self.mRootWidget:getChildByName("Panel_GoldItem")
		local panelSz = panelWgt:getContentSize()
		panelWgt:setPosition(cc.p(0, -panelSz.height + outerSz.height))
		panelWgt:removeAllChildren()

		-- 获取PVE_SaodangContent大小
		rewardSz = GUIWidgetPool:createWidget("GoldenItem"):getContentSize()
		local addedRwardCnt = 0
		local moveTime = 0.25
		local bigScaleVal = 1.15 -- 图标放大倍数

		-- 修正大小
	--	panelWgt:setContentSize(cc.size(panelSz.width, rewardSz.height*(retCount)))

		panelWgt:setContentSize(cc.size(panelSz.width, 300))

		-- 真实的添加点金结果函数
		local function addGoldWidgetImpl()
			addedRwardCnt = addedRwardCnt + 1
			if addedRwardCnt > retCount then -- 所有奖励已经全部添加完
				-- 允许用户输入
				GUISystem:enableUserInput()
				return
			end

			local function addWidget()
				-- 添加奖励控件
				local curPos = cc.p(25, panelSz.height - rewardSz.height*addedRwardCnt + 25)
				local rewardWidget = GUIWidgetPool:createWidget("GoldenItem")
				panelWgt:addChild(rewardWidget)
				rewardWidget:setPosition(curPos)
				-- 更新奖励信息
				local function updateRewardInfo()
					rewardWidget:getChildByName("Label_Price"):setString(tostring(goldRetInfo[addedRwardCnt].price))
					rewardWidget:getChildByName("Label_Reward"):setString(tostring(goldRetInfo[addedRwardCnt].reward))
					if goldRetInfo[addedRwardCnt].crit > 0 then
						rewardWidget:getChildByName("Label_Crit"):setString(tostring(goldRetInfo[addedRwardCnt].crit).."倍暴击")
					elseif goldRetInfo[addedRwardCnt].crit == 0 then
						rewardWidget:getChildByName("Label_Crit"):setVisible(false)
					end
					print("点金次数:", addedRwardCnt, "钻石消耗:", goldRetInfo[addedRwardCnt].price, "金币获得:", goldRetInfo[addedRwardCnt].reward, "暴击", goldRetInfo[addedRwardCnt].crit)
				end
				updateRewardInfo()

				local scaleVal = rewardWidget:getScale()
				local act0 = cc.Sequence:create(cc.ScaleTo:create(0.2, scaleVal*bigScaleVal), cc.ScaleTo:create(0.05, scaleVal)) -- 动作
				local act1 = cc.CallFunc:create(addGoldWidgetImpl) -- 回调
				rewardWidget:getChildByName("Panel_Inner"):runAction(cc.Sequence:create(act0, act1))

			end

			if addedRwardCnt <=3 then -- 不滑动
				addWidget()
			else -- 滑动
				-- 滑动结束回调
				local function onScrollEnd()
					addWidget()
				end
				-- 滑动
				local function doScroll()
					local act0 = cc.MoveBy:create(moveTime, cc.p(0, rewardSz.height))
					local act1 = cc.CallFunc:create(onScrollEnd)
					panelWgt:runAction(cc.Sequence:create(act0, act1))
				end
				doScroll()
			end
		end
		addGoldWidgetImpl()
		
	end

	if self.mShowed then
		addGoldWidget()
	else
		local function doAction1()
			local contentSize = self.mMainWindow:getContentSize()
			local curPos = cc.p(self.mMainWindow:getPosition())
			local newPos = cc.p(curPos.x, curPos.y + contentSize.height/2)
			local act0 = cc.MoveTo:create(moveTime, newPos)
			self.mMainWindow:runAction(act0)
		end
		local function doAction2()
			local contentSize = self.mInfoWindow:getContentSize()
			local curPos = cc.p(self.mInfoWindow:getPosition())
			local newPos = cc.p(curPos.x, curPos.y - contentSize.height/2)
			local act0 = cc.MoveTo:create(moveTime, newPos)
			local act1 = cc.CallFunc:create(addGoldWidget)
			self.mInfoWindow:runAction(cc.Sequence:create(act0, act1))
			self.mInfoWindow:setVisible(true)
		end
		doAction1()
		doAction2()
		self.mShowed = true
	end

	-- 更新
	self.mLeftBuyCount = self.mLeftBuyCount - retCount
	self:updateGoldenInfo()
	GUISystem:hideLoading()
end

-- 请求点金
function GoldenFingerWindow:requestBuyGold(widget)
	local packet = NetSystem.mNetManager:GetSPacket()
	packet:SetType(PacketTyper._PTYPE_CS_GOLDENFINGER_EXECUTE_)
	packet:PushChar(widget:getTag())
	packet:Send()
	GUISystem:showLoading()
end

function GoldenFingerWindow:Destroy()
	self.mRootNode:removeFromParent(true)
	self.mRootNode 		= 	nil
	self.mRootWidget 	= 	nil

	self.mShowed = false

	CommonAnimation:clearAllTextures()
	cclog("=====GoldenFingerWindow:Destroy=====")
end

function GoldenFingerWindow:onEventHandler(event)
	if event.mAction == Event.WINDOW_SHOW then
		self:Load(event)
	elseif event.mAction == Event.WINDOW_HIDE then
		self:Destroy()
	end
end

return GoldenFingerWindow
