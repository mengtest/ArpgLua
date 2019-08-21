-- Name: 	PurchaseWindow
-- Func：	购买窗口
-- Author:	WangShengdong
-- Data:	14-1-6

-- 支持长按
local longPressEnabled = true
local longPressTimeVal = 0.3

local PurchaseWindow = 
{
	mName				=	"PurchaseWindow",
	mRootNode 			= 	nil,
	mRootWidget 		= 	nil,

	mPurGoodsCount		=	1,
	mPurGoodsLabel		=	nil,
	mSchedulerHandler	=	nil,
	mPushDownTime		=	0,
	mReleaseUpTime		=	0,

	mGoodsType			=	nil,	-- 商品类型
	mGoodsIndex			=	nil,	-- 货架Id
	mGoodsId 			=	nil,	-- 商品Id
	mGoodsPrice			=	0,		-- 单价
	mTotalPrice			=	0,		-- 总价
	mShopType			=	nil,	-- 商店类型
	mGoodsMaxNum		=	0,		-- 最大购买数量
	mMoneyType			=	nil,	-- 使用货币类型


	mGoodsWidget 		=	nil,	-- 物品控件
}


function PurchaseWindow:Release()

end

function PurchaseWindow:Load(event)
	cclog("=====PurchaseWindow:Load=====begin")

	-- 已经显示则不显示
	if self.mRootNode then
		return
	end

	self.mRootNode = cc.Node:create()
	GUISystem:GetRootNode():addChild(self.mRootNode)

	self:InitLayout(event)

	cclog("=====PurchaseWindow:Load=====end")
end

function PurchaseWindow:InitLayout(event)
	self.mRootWidget =  GUIWidgetPool:createWidget("PurchaseWindow")
	self.mRootNode:addChild(self.mRootWidget)

	self.mPurGoodsLabel = self.mRootWidget:getChildByName("Label_Num")

	local function onButtonTouch(widget, eventType)
		
		if eventType == ccui.TouchEventType.began then
			self:onButtonPushDown(widget)
		elseif eventType == ccui.TouchEventType.ended then 
			self:onButtonReleaseUp(widget)
		elseif eventType == ccui.TouchEventType.canceled then
			self:onButtonCancled(widget)
		elseif eventType == ccui.TouchEventType.moved then
			
		end
		
	end

	self.mGoodsType = event.mData[1]

	-- if 0 == self.mGoodsType or 1 == self.mGoodsType or 2 == self.mGoodsType then -- 体力
	-- 	self.mMoneyType = 1
	-- 	self.mGoodsMaxNum = 100000
	-- 	self.mGoodsPrice = 10
	-- 	local goodsName = {"体力", "耐力", "点金"}
	-- 	-- 显示商品信息
	-- 	self.mRootWidget:getChildByName("Label_GoodsName"):setString(goodsName[self.mGoodsType + 1])
	-- else
		self.mGoodsIndex = event.mData[2]
		self.mGoodsId = event.mData[3]
		self.mMoneyType = event.mData[4]
		self.mGoodsPrice = event.mData[5]
		self.mShopType = event.mData[7]
		self.mGoodsMaxNum = event.mData[8]
		self.mGoodsWidget = event.mData[9]
		-- 显示商品信息
	--	self.mRootWidget:getChildByName("Label_GoodsName"):setString(event.mData[6])

	-- 	local containerWidget = self.mRootWidget:getChildByName("Panel_Goods")
	-- 	local oldContentSize = containerWidget:getContentSize()
	-- 	--local labelStr = string.format("请选择购买#50ff33%s#的数量", event.mData[6])

	-- local labelStr = string.format("<text>\
	-- 	<a type=\"text\" fontsize=\"25\" fontcolor=\"#FFFFFF\" text=\"请选择购买 \"></a>\
	-- 	<a type=\"text\" fontsize=\"25\" fontcolor=\"#50ff33\" text=\"%s\"></a>\
	-- 	<a type=\"text\" fontsize=\"25\" fontcolor=\"#FFFFFF\" text=\" 的数量\"></a>\
	-- </text>",event.mData[6])

	-- 	local function reSetPos(newWidth)
	-- 		local curPosX = (oldContentSize.width - tonumber(newWidth))/2
	-- 		containerWidget:setPositionX(curPosX)
	-- 	end
	-- 	richTextCreate(containerWidget, labelStr, false, reSetPos,true)

	-- 显示物品最大信息
	local function showItemBaseInfo()
		local itemData = nil
		if 8 == self.mGoodsType then
			itemData = DB_Diamond.getDataById(self.mGoodsId)
		elseif 0 == self.mGoodsType then
			itemData = DB_ItemConfig.getDataById(self.mGoodsId)
		elseif 1 == self.mGoodsType then
			itemData = DB_EquipmentConfig.getDataById(self.mGoodsId)
			self.mRootWidget:getChildByName("Label_Own"):setVisible(false)
		end

		-- 显示名字
		local itemNameId = itemData.Name
		local textData = DB_Text.getDataById(itemNameId)
		local itemName = textData[GAME_LANGUAGE]
		self.mRootWidget:getChildByName("Label_ItemName"):setString(itemName)
		-- 显示拥有数量
		local totalCount = globaldata:getItemOwnCount(self.mGoodsId)
		self.mRootWidget:getChildByName("Label_Own"):setString("当前拥有"..tostring(totalCount).."件")
		-- 描述
		local itemDescId = nil
		if 8 == self.mGoodsType then
			itemDescId = itemData.description
		elseif 0 == self.mGoodsType then
			itemDescId = itemData.Description
		elseif 1 == self.mGoodsType then
			itemDescId = itemData.EquipText
		end
		local DescText = getDictionaryText(itemDescId)
	--	self.mRootWidget:getChildByName("Label_Des"):setString(DescText)
		richTextCreate(self.mRootWidget:getChildByName("Panel_Desc"), DescText, true)
		-- 图标
		self.mRootWidget:getChildByName("Panel_ItemIcon"):addChild(createCommonWidget(self.mGoodsType, self.mGoodsId, 1, nil, true))
	end
	showItemBaseInfo()
		
	local function getNewMaxCount() -- 计算出新的最大购买量
		local curMoney = 0
		local curPrice = self.mGoodsPrice
		if 0 == self.mMoneyType then -- 金币
			curMoney = globaldata:getPlayerBaseData("money")
		elseif 1 == self.mMoneyType then -- 钻石
			curMoney = globaldata:getPlayerBaseData("diamond")
		elseif 2 == self.mMoneyType then -- 声望
			curMoney = globaldata:getPlayerBaseData("naili")
		elseif 3 == self.mMoneyType then -- 神秘
			curMoney = globaldata:getPlayerBaseData("shenmi")
		elseif 5 == self.mMoneyType then -- 帮会
			curMoney = globaldata:getPlayerBaseData("partyMoney")
		elseif 6 == self.mMoneyType then -- 天梯
			curMoney = globaldata:getPlayerBaseData("tiantiMoney")
		elseif 7 == self.mMoneyType then -- 游乐园
			curMoney = globaldata:getPlayerBaseData("towerMoney")
		end

		local newCount = math.floor(curMoney/curPrice)

		if self.mGoodsMaxNum > newCount then
			self.mGoodsMaxNum = newCount
		end

		if 0 == self.mGoodsMaxNum then
			self.mPurGoodsCount = 0
		end
	end
	getNewMaxCount()

	-- 缩放动作
	if self.mGoodsWidget then
		local moveWidget = self.mRootWidget:getChildByName("Image_bg1")
		local size = moveWidget:getContentSize()
		local curPos = cc.p(moveWidget:getPosition())
		local preNodePos = self.mGoodsWidget:getWorldPosition()
		local preSize = self.mGoodsWidget:getContentSize()
		preNodePos.x = preNodePos.x + preSize.width/2
		preNodePos.y = preNodePos.y + preSize.height/2

		local act0 = nil
		local tm = 0.15

		if preNodePos.x < curPos.x then -- 在左边
			if preNodePos.y < curPos.y then
			--	moveWidget:setAnchorPoint(cc.p(0, 0))
			--	act0 = cc.MoveTo:create(tm, cc.p(curPos.x - size.width/2, curPos.y - size.height/2))

			--	moveWidget:setPosition(cc.p(curPos.x - size.width/2, curPos.y - size.height/2))
			else
			--	moveWidget:setAnchorPoint(cc.p(0, 1))
			--	act0 = cc.MoveTo:create(tm, cc.p(curPos.x - size.width/2, curPos.y + size.height/2))

			--	moveWidget:setPosition(cc.p(curPos.x - size.width/2, curPos.y + size.height/2))
			end
		else -- 在右边
			if preNodePos.y < curPos.y then
			--	moveWidget:setAnchorPoint(cc.p(1, 0))
			--	act0 = cc.MoveTo:create(tm, cc.p(curPos.x + size.width/2, curPos.y - size.height/2))

			--	moveWidget:setPosition(cc.p(curPos.x + size.width/2, curPos.y - size.height/2))
			else
			--	moveWidget:setAnchorPoint(cc.p(1, 1))
			--	act0 = cc.MoveTo:create(tm, cc.p(curPos.x + size.width/2, curPos.y + size.height/2))

			--	moveWidget:setPosition(cc.p(curPos.x + size.width/2, curPos.y + size.height/2))
			end
		end

		moveWidget:setPosition(preNodePos)
		moveWidget:setScale(0.5)
		moveWidget:setOpacity(0)

		local act0 = cc.MoveTo:create(tm, curPos)
		local act1 = cc.ScaleTo:create(tm, 1)
		local act2 = cc.FadeIn:create(tm)

		moveWidget:runAction(cc.Spawn:create(act0, act1, act2))

	end
	-- 更换货币图片
	if 0 == self.mMoneyType then -- 金币
		self.mRootWidget:getChildByName("Image_Currency"):loadTexture("public_gold.png")
	elseif 1 == self.mMoneyType then -- 钻石
		self.mRootWidget:getChildByName("Image_Currency"):loadTexture("public_diamond.png")
	elseif 2 == self.mMoneyType then -- 声望
		self.mRootWidget:getChildByName("Image_Currency"):loadTexture("public_currency_arena.png")
	elseif 3 == self.mMoneyType then -- 神秘
		self.mRootWidget:getChildByName("Image_Currency"):loadTexture("public_coin.png")
	elseif 5 == self.mMoneyType then -- 帮会
		self.mRootWidget:getChildByName("Image_Currency"):loadTexture("public_currency_guild.png")
	elseif 6 == self.mMoneyType then -- 天梯
		self.mRootWidget:getChildByName("Image_Currency"):loadTexture("public_currency_tianti.png")
	elseif 7 == self.mMoneyType then -- 游乐园
		self.mRootWidget:getChildByName("Image_Currency"):loadTexture("public_currency_tower.png")
	end

	-- 清空总价格信息
	self.mRootWidget:getChildByName("Label_TotalPrice"):setString("0")
	self.mRootWidget:getChildByName("Button_AddOne"):addTouchEventListener(onButtonTouch)
	self.mRootWidget:getChildByName("Button_AddOne"):setTag(1)
--	self.mRootWidget:getChildByName("Button_AddTen"):addTouchEventListener(onButtonTouch)
--	self.mRootWidget:getChildByName("Button_AddTen"):setTag(10)
	self.mRootWidget:getChildByName("Button_AddMax"):addTouchEventListener(onButtonTouch)
	self.mRootWidget:getChildByName("Button_AddMax"):setTag(self.mGoodsMaxNum)
	self.mRootWidget:getChildByName("Button_SubOne"):addTouchEventListener(onButtonTouch)
	self.mRootWidget:getChildByName("Button_SubOne"):setTag(-1)
--	self.mRootWidget:getChildByName("Button_SubTen"):addTouchEventListener(onButtonTouch)
--	self.mRootWidget:getChildByName("Button_SubTen"):setTag(-10)

	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_Confirm"), handler(self, self.doConfirm))

	local function doCancel()
		EventSystem:PushEvent(Event.GUISYSTEM_HIDE_PURCHASEWINDOW)
	end
	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_Cancel"), doCancel)

	self:updateGoodsCount()
end

function PurchaseWindow:doConfirm()
	-- if 0 == self.mGoodsType or 1 == self.mGoodsType or 2 == self.mGoodsType then
	-- 	local packet = NetSystem.mNetManager:GetSPacket()
	--     packet:SetType(PacketTyper._PTYPE_CS_REQUEST_BUYCONSUME_)
	--     packet:PushChar(self.mGoodsType)
	--     packet:PushInt(self.mPurGoodsCount)
	--     packet:PushInt(self.mTotalPrice)
	--     packet:Send()
	-- else

		if 0 == self.mPurGoodsCount then
			MessageBox:showMessageBox1("亲购买数量不能是0啊~!")
			return
		end


		local packet = NetSystem.mNetManager:GetSPacket()
	    packet:SetType(PacketTyper._PTYPE_CS_REQUEST_BUY_)
	    packet:PushChar(self.mShopType)
	    packet:PushInt(self.mGoodsIndex)
	    packet:PushInt(self.mGoodsId)
	    packet:PushInt(self.mPurGoodsCount)
	    packet:PushInt(self.mTotalPrice)
	    packet:Send()  
	    GUISystem:showLoading()
	-- end

	EventSystem:PushEvent(Event.GUISYSTEM_HIDE_PURCHASEWINDOW)
end

function PurchaseWindow:onButtonPushDown(widget)

	if 1 == self.mGoodsType then
		MessageBox:showMessageBox1("时装类物品单次只能购买1个哦~")
		return
	end

	if longPressEnabled then
		local deltaNum = widget:getTag()
		local scheduler = cc.Director:getInstance():getScheduler()

		local function doChangeNum()
			if self.mPurGoodsCount + deltaNum <= self.mGoodsMaxNum then
				self.mPurGoodsCount = self.mPurGoodsCount + deltaNum
				if self.mPurGoodsCount <= 0 then
					self.mPurGoodsCount = 0
				end
			else
				self.mPurGoodsCount = self.mGoodsMaxNum
				MessageBox:showMessageBox1("已达到最大购买数量!")
			end
			self:updateGoodsCount()
		end
		self.mSchedulerHandler = scheduler:scheduleScriptFunc(doChangeNum, longPressTimeVal, false)
		self.mPushDownTime = os.clock()
	end
end

function PurchaseWindow:onButtonReleaseUp(widget)

	local function doDelta()
		local deltaNum = widget:getTag()
		if self.mPurGoodsCount + deltaNum <= self.mGoodsMaxNum then
			self.mPurGoodsCount = self.mPurGoodsCount + deltaNum
			if self.mPurGoodsCount <= 0 then
				self.mPurGoodsCount = 0
			end
		else
			self.mPurGoodsCount = self.mGoodsMaxNum
			MessageBox:showMessageBox1("已达到最大购买数量!")
		end
	end

	if longPressEnabled then
		local scheduler = cc.Director:getInstance():getScheduler()
		if self.mSchedulerHandler then
			scheduler:unscheduleScriptEntry(self.mSchedulerHandler)
			self.mSchedulerHandler = nil
		end

		self.mReleaseUpTime = os.clock()

		if self.mReleaseUpTime - self.mPushDownTime < longPressTimeVal then -- 单机一次的情况
			doDelta()
		end

	else
		doDelta()
	end
	self:updateGoodsCount()
end

function PurchaseWindow:onButtonCancled(widget)
	if longPressEnabled then
		local scheduler = cc.Director:getInstance():getScheduler()
		if self.mSchedulerHandler then
			scheduler:unscheduleScriptEntry(self.mSchedulerHandler)
			self.mSchedulerHandler = nil
		end
	end
end

function PurchaseWindow:updateGoodsCount()
	if self.mPurGoodsLabel then
		if self.mPurGoodsCount > 0 then
			self.mPurGoodsLabel:setString(tostring(self.mPurGoodsCount).."/"..tostring(self.mGoodsMaxNum))
			self.mTotalPrice = self.mPurGoodsCount*self.mGoodsPrice
			self.mRootWidget:getChildByName("Label_TotalPrice"):setString(tostring(self.mTotalPrice))

		elseif self.mPurGoodsCount <= 0 then
			if 0 == self.mGoodsMaxNum then
				self.mPurGoodsLabel:setString("0")
			else
			--	self.mPurGoodsLabel:setString("0/1")
				self.mPurGoodsLabel:setString(tostring(self.mPurGoodsCount).."/"..tostring(self.mGoodsMaxNum))
			end
			self.mRootWidget:getChildByName("Label_TotalPrice"):setString("0")
		end
		self.mRootWidget:getChildByName("Label_TotalNumber"):setString(tostring(self.mPurGoodsCount))
	end
end

function PurchaseWindow:Destroy()
	
	self.mRootNode:removeFromParent(true)
	self.mRootNode = nil
	self.mRootWidget = nil
	self.mPurGoodsCount		=	1
	self.mPurGoodsLabel		=	nil

	if self.mSchedulerHandler then
		scheduler:unscheduleScriptEntry(self.mSchedulerHandler)
		self.mSchedulerHandler = nil
	end
	
	self.mPushDownTime		=	0
	self.mReleaseUpTime		=	0

	self.mGoodsType			=	nil
	self.mGoodsIndex		=	nil
	self.mGoodsId 			=	nil
	self.mGoodsPrice		=	0
	self.mTotalPrice		=	10
	self.mShopType			=	nil
	self.mGoodsMaxNum		=	0

	CommonAnimation:clearAllTextures()
end

function PurchaseWindow:onEventHandler(event)
	if event.mAction == Event.WINDOW_SHOW then
		self:Load(event)
	elseif event.mAction == Event.WINDOW_HIDE then
		self:Destroy()
	end
end

return PurchaseWindow