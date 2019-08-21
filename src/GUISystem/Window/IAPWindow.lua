-- Name: 	IAPWindow
-- Func：	内购
-- Author:	WangShengdong
-- Data:	15-10-19

local IAPWindow = 
{
	mName					=	"IAPWindow",
	mRootNode				=	nil,
	mRootWidget				=	nil,
	mTopRoleInfoPanel		=	nil,
	------------------------------------
	mGoodsWindow			=	nil,	-- 商品窗口
	mInfoWindow				=	nil,	-- 信息窗口
	------------------------------------
	mCurSelectedVipLevel	=	nil,	-- 当前选择的VIP等级
	mLeftBtn				=	nil,	-- 左按钮
	mRightBtn 				=	nil,	-- 右按钮
}

function IAPWindow:Release()

end

function IAPWindow:Load(event)
	cclog("=====IAPWindow:Load=====begin")

	self.mRootNode = cc.Node:create()
	GUISystem:GetRootNode():addChild(self.mRootNode)

	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_BUY_VIP_GIFT, handler(self, self.onRequestBuyGift))

	GUIEventManager:registerEvent("roleBaseInfoChanged", self, self.onRoleBaseChange)

	self:InitLayout()

	self:updateVipInfo()
	-- 初始化VIP特权
	self:initVipInfoWindow()
	-- 更新VIP特权
	self:updateVipInfoWindow()

	cclog("=====IAPWindow:Load=====end")
end

-- 更新玩家基础信息
function IAPWindow:onRoleBaseChange()
	-- 更新VIP基础信息
	self:updateVipInfo()
	-- 更新VIP特权
	self:updateVipInfoWindow()
end

-- 请求购买礼包
function IAPWindow:requestBuyGift()
	local packet = NetSystem.mNetManager:GetSPacket()
	packet:SetType(PacketTyper._PTYPE_CS_BUY_VIP_GIFT)
	packet:PushInt(self.mCurSelectedVipLevel)
	packet:Send()
	GUISystem:showLoading()
end

-- 购买礼包回包
function IAPWindow:onRequestBuyGift(msgPacket)
	local vipLevel = msgPacket:GetInt()
	local rewardCount = msgPacket:GetUShort()
	local itemList = {}
	for i = 1, rewardCount do
		local itemType = msgPacket:GetInt()
		local itemId = msgPacket:GetInt()
		local itemCount = msgPacket:GetInt()
		itemList[i] = {itemType, itemId, itemCount}
	end
	MessageBox:showMessageBox_ItemAlreadyGot(itemList)
	GUISystem:hideLoading()
end

function IAPWindow:InitLayout()

	self.mRootWidget = GUIWidgetPool:createWidget("Deposit_Main")
	self.mRootNode:addChild(self.mRootWidget)

	local function closeWindow()
		GUISystem:playSound("homeBtnSound")
		EventSystem:PushEvent(Event.GUISYSTEM_HIDE_IAPWINDOW)
	end
	self.mTopRoleInfoPanel = TopRoleInfoPanel:new()
	local topInfoPanel = self.mTopRoleInfoPanel:init(self.mRootNode,ROLE_TITLE_TYPE.TITLE_DEPOSIT ,closeWindow)

	-- 适配
	local function doAdapter()
	--	local topPanelSize = self.mTopRoleInfoPanel.mTopWidget:getContentSize()
	--	local mainPanelSize = self.mRootWidget:getChildByName("Panel_Main"):getContentSize()
	--	self.mRootWidget:getChildByName("Panel_Main"):setPositionY(getGoldFightPosition_LU().y - topPanelSize.height - mainPanelSize.height )

		-- 动效
		local function doAnim()
			local widget = self.mRootWidget:getChildByName("Panel_Main")
			widget:setAnchorPoint(cc.p(0.5, 0.5))
			widget:setScale(0)
			widget:setOpacity(0)

			-- 修正修复锚点以后的位置
			local curPos = cc.p(widget:getPosition())
			widget:setPositionY(widget:getContentSize().height/2 + curPos.y)
			widget:setPositionX(widget:getContentSize().width/2 + curPos.x)

			local act0 = cc.ScaleTo:create(0.15, 1)
			local act1 = cc.FadeIn:create(0.15)
			self.mRootWidget:getChildByName("Panel_Main"):runAction(cc.Spawn:create(act0, act1))
		end
		doAnim()
	end
	doAdapter()

	-- 商品窗口
	self.mGoodsWindow = self.mRootWidget:getChildByName("ScrollView_Options")
	self.mGoodsWindow:setVisible(true)
	-- 信息窗口
	self.mInfoWindow = self.mRootWidget:getChildByName("Panel_VIP_Privilege")
	self.mInfoWindow:setVisible(false)
	-- 响应
	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_VIP_Change"), handler(self, self.changeWindow))

	self.mLeftBtn = self.mRootWidget:getChildByName("Panel_TurnPre"):getChildByName("Button_Turn")
	self.mLeftBtn:setTag(-1)
	registerWidgetReleaseUpEvent(self.mLeftBtn, handler(self, self.onVipLevelSelected))

	self.mRightBtn = self.mRootWidget:getChildByName("Panel_TurnNext"):getChildByName("Button_Turn")
	self.mRightBtn:setTag(1)
	registerWidgetReleaseUpEvent(self.mRightBtn, handler(self, self.onVipLevelSelected))

	-- 购买礼包
	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_Buy"), handler(self, self.requestBuyGift))

end

-- 选择VIP特权
function IAPWindow:onVipLevelSelected(widget)
	if -1 == widget:getTag() then
		self.mCurSelectedVipLevel = self.mCurSelectedVipLevel - 1
		if self.mCurSelectedVipLevel <= 0 then
			self.mCurSelectedVipLevel = 1
		end
	elseif 1 == widget:getTag() then
		self.mCurSelectedVipLevel = self.mCurSelectedVipLevel + 1
		if self.mCurSelectedVipLevel >= 16 then
			self.mCurSelectedVipLevel = 16
		end
	end
	self:updateVipInfoWindow()
end

-- 初始化VIP特权
function IAPWindow:initVipInfoWindow()
	if 0 == globaldata.vipLevel then
		self.mCurSelectedVipLevel = 1
	else
		self.mCurSelectedVipLevel = globaldata.vipLevel
	end
end

-- 更新VIP特权
function IAPWindow:updateVipInfoWindow()
	if 1 == self.mCurSelectedVipLevel then
		self.mRootWidget:getChildByName("Panel_TurnPre"):setVisible(false)
		self.mRootWidget:getChildByName("Panel_TurnNext"):setVisible(true)
	elseif 16 == self.mCurSelectedVipLevel then
		self.mRootWidget:getChildByName("Panel_TurnPre"):setVisible(true)
		self.mRootWidget:getChildByName("Panel_TurnNext"):setVisible(false)
	else
		self.mRootWidget:getChildByName("Panel_TurnPre"):setVisible(true)
		self.mRootWidget:getChildByName("Panel_TurnNext"):setVisible(true)
	end

	-- 信息
	local lessTextId = 1750
	local textData = DB_Text.getDataById(lessTextId + self.mCurSelectedVipLevel)
	local textStr  = textData.Text_CN
	local panelWidget = self.mRootWidget:getChildByName("ScrollView_VIP_Privilege"):getChildByName("Panel_VIP_Privilege")
	panelWidget:removeAllChildren()
	richTextCreate(panelWidget, textStr, true, nil, false)
	print(textStr)
	-- 序号
	self.mRootWidget:getChildByName("Image_Title"):getChildByName("Label_VIP_Stroke_0_67_191"):setString("VIP "..tostring(self.mCurSelectedVipLevel))

	-- 序号
	self.mRootWidget:getChildByName("Panel_TurnPre"):getChildByName("Label_VIP_Stroke_0_67_191"):setString("VIP "..tostring(self.mCurSelectedVipLevel - 1))

	-- 序号
	self.mRootWidget:getChildByName("Panel_TurnNext"):getChildByName("Label_VIP_Stroke_0_67_191"):setString("VIP "..tostring(self.mCurSelectedVipLevel + 1))

	-- 礼包
	local giftInfo = DB_VipBag.getDataById(self.mCurSelectedVipLevel)

	-- 原价
	self.mRootWidget:getChildByName("Image_PrePrice"):getChildByName("Label_PrePrice"):setString(giftInfo.originalPrice)

	-- 现价
	self.mRootWidget:getChildByName("Image_CurPrice"):getChildByName("Label_PrePrice"):setString(giftInfo.discountPrice)

	-- 物品
	for i = 1, 6 do
		self.mRootWidget:getChildByName("Panel_VIP_Package"):getChildByName("Panel_Item_"..tostring(i)):removeAllChildren()
	end
	for i = 1, giftInfo.rewardCount do
		local itemInfoStr = giftInfo["Item"..tostring(i)]
		local infoTbl = extern_string_split_(itemInfoStr, ",")
		local itemWidget = createCommonWidget(tonumber(infoTbl[1]), tonumber(infoTbl[2]), tonumber(infoTbl[3]))
		self.mRootWidget:getChildByName("Panel_VIP_Package"):getChildByName("Panel_Item_"..tostring(i)):addChild(itemWidget)

		if 0 == tonumber(infoTbl[1]) then
			local itemData = DB_ItemConfig.getDataById(tonumber(infoTbl[2]))
			if 1 == itemData.Type then -- 英雄碎片
				local animNode = AnimManager:createAnimNode(8013)
				itemWidget:getChildByName("Panel_Animation"):addChild(animNode:getRootNode())
				animNode:play("item_special", true)
			end
		end
	end

	-- 按钮
	local btn = self.mRootWidget:getChildByName("Button_Buy")
	if 0 == globaldata.vipGiftList[self.mCurSelectedVipLevel] then -- 可购买
		ShaderManager:DoUIWidgetDisabled(btn, false)
		btn:setTouchEnabled(true)
	elseif 1 == globaldata.vipGiftList[self.mCurSelectedVipLevel] then -- 不可购买
		ShaderManager:DoUIWidgetDisabled(btn, true)
		btn:setTouchEnabled(false)
	end
end

-- 切换窗口
function IAPWindow:changeWindow(widget)
	local textWidget = widget:getChildByName("Label_VIP_Change_Stroke_255_84_0")
	if "VIP 特权" == textWidget:getString() then
		self.mGoodsWindow:setVisible(false)
		self.mInfoWindow:setVisible(true)
		textWidget:setString("充值")
	elseif "充值" == textWidget:getString() then
		self.mGoodsWindow:setVisible(true)
		self.mInfoWindow:setVisible(false)
		textWidget:setString("VIP 特权")
	end
end

-- 更新VIP信息
function IAPWindow:updateVipInfo()
	-- VIP等级
	self.mRootWidget:getChildByName("BitmapLabel_108"):setString(tostring(globaldata.vipLevel))
	-- 下一等级需要冲的钻石数
	self.mRootWidget:getChildByName("Label_NeedDiamond"):setString(tostring(globaldata.nextVipNeedDiamondCount))
	-- 下一个VIP等级
	self.mRootWidget:getChildByName("Label_NextVIP"):setString("VIP."..tostring(globaldata.nextVipLevel))
	-- 进度条
--	self.mRootWidget:getChildByName("ProgressBar_Deposit"):setPercent(globaldata.diamondAlreadyGet*100/globaldata.nextVipNeedDiamondCount)
	self.mRootWidget:getChildByName("ProgressBar_Deposit"):setPercent(globaldata.vipPercent)
end

function IAPWindow:onEventHandler(event)
	if event.mAction == Event.WINDOW_SHOW then
		self:Load(event)
	elseif event.mAction == Event.WINDOW_HIDE then
		self:Destroy()
	end
end

function IAPWindow:Destroy()

	self.mTopRoleInfoPanel:destroy()
	self.mTopRoleInfoPanel = nil
	
	self.mRootNode:removeFromParent(true)
	self.mRootNode 		= 	nil
	self.mRootWidget 	= 	nil

	GUIEventManager:unregister("roleBaseInfoChanged", self.onRoleBaseChange)

	cclog("=====IAPWindow:Destroy=====")
end

return IAPWindow