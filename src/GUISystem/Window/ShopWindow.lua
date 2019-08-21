-- Name: 	ShopWindow
-- Func：	商城
-- Author:	WangShengdong
-- Data:	15-1-8

local ShopWindow = 
{
	mName				=	"ShopWindow",
	mRootNode			=	nil,
	mRootWidget			=	nil,
	mLastChooseOption	=	nil,
	mTopRoleInfoPanel	=	nil,
	mPanelShangcheng	=	nil,
	mSchedulerHandler	=	nil,	-- 定时器
	-------------------------------------------
	mShopType			=	nil,	-- 商店类型
}

function ShopWindow:Release()

end

function ShopWindow:Load(event)
	cclog("=====ShopWindow:Load=====begin")

	-- 检查版本
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_REQUEST_GOODSINFO_, handler(self,self.onRequestFreshShop))

	-- 购买成功
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_REQUEST_BUY_, handler(self,self.onRequestBuy))

	GUIEventManager:registerEvent("shopFreshed", self, self.requestFreshShop)
	GUIEventManager:registerEvent("roleBaseInfoChanged", self, self.onRoleBaseInfoChanged)

	self.mRootNode = cc.Node:create()
	GUISystem:GetRootNode():addChild(self.mRootNode)

	self.mShopType = event.mData -- 商店类型

	self:InitLayout()

	if 1 == self.mShopType then -- 普通商店
		self.mRootWidget:getChildByName("Image_title"):loadTexture("shop_title_cityshop.png")
		self.mRootWidget:getChildByName("Image_Title_Hero"):loadTexture("shop_hero_city.png")
	elseif 2 == self.mShopType then -- 神秘商店
	--	self.mRootWidget:getChildByName("Image_title"):loadTexture("shop_shenmi_1.png")
	elseif 3 == self.mShopType then -- 竞技场商店
		self.mRootWidget:getChildByName("Image_title"):loadTexture("shop_title_arenashop.png")
		self.mRootWidget:getChildByName("Image_Title_Hero"):loadTexture("shop_hero_arena.png")
	elseif 4 == self.mShopType then -- 宝石商店
	--	self.mRootWidget:getChildByName("Image_title"):loadTexture("shop_baoshi_1.png")
	elseif 5 == self.mShopType then -- 帮会商店
		self.mRootWidget:getChildByName("Image_title"):loadTexture("shop_title_guildshop.png")
		self.mRootWidget:getChildByName("Image_Title_Hero"):loadTexture("shop_hero_guild.png")
	elseif 8 == self.mShopType then -- 天梯商店
		self.mRootWidget:getChildByName("Image_title"):loadTexture("shop_title_tiantishop.png")
		self.mRootWidget:getChildByName("Image_Title_Hero"):loadTexture("shop_hero_tianti.png")
	end
	-- 刷新商品
	self:onSelectedOption()

	cclog("=====ShopWindow:Load=====end")
end

function ShopWindow:sendFreshInfo(widget)
	GUISystem:playSound("homeBtnSound")
	local packet = NetSystem.mNetManager:GetSPacket()
	packet:SetType(PacketTyper._PTYPE_CS_REQUEST_FRESHSHOP_)
	packet:PushChar(self.mShopType)
	packet:Send()
	GUISystem:showLoading()
end

function ShopWindow:InitLayout()
	self.mRootWidget = GUIWidgetPool:createWidget("ShopMain")
	self.mRootNode:addChild(self.mRootWidget)

	local function closeWindow()
		GUISystem:playSound("homeBtnSound")
		EventSystem:PushEvent(Event.GUISYSTEM_HIDE_SHOPWINDOW)
	end

	self.mTopRoleInfoPanel = TopRoleInfoPanel:new()
	local topInfoPanel = nil

	if 3 == self.mShopType then -- 武道馆商城
		topInfoPanel = self.mTopRoleInfoPanel:init(self.mRootNode,ROLE_TITLE_TYPE.TITLE_ARENA_SHOP, closeWindow)
	elseif 5 == self.mShopType then -- 帮会
		topInfoPanel = self.mTopRoleInfoPanel:init(self.mRootNode,ROLE_TITLE_TYPE.TITLE_PARTY_SHOP, closeWindow)
	elseif 8 == self.mShopType then -- 制霸之战商城
		topInfoPanel = self.mTopRoleInfoPanel:init(self.mRootNode,ROLE_TITLE_TYPE.TITLE_TIANTI_SHOP, closeWindow)
	else
		topInfoPanel = self.mTopRoleInfoPanel:init(self.mRootNode,ROLE_TITLE_TYPE.TITLE_SHOP, closeWindow)
	end

	self.mPanelShangcheng	= self.mRootWidget:getChildByName("ListView_Shangcheng")
--	self.mPanelShangcheng:setBounceEnabled(true)
	self.mPanelShangcheng:setVisible(false)


	local function doAdapter()
	    local topInfoPanelSize = topInfoPanel:getContentSize()
	    local newHeight = getGoldFightPosition_LU().y - topInfoPanelSize.height - getGoldFightPosition_LD().y
	    local newPosY = newHeight/2 + getGoldFightPosition_LD().y - self.mRootWidget:getChildByName("Panel_Main"):getContentSize().height/2
	    self.mRootWidget:getChildByName("Panel_Main"):setAnchorPoint(cc.p(0.5, 0.5))
	    local panelSize = self.mRootWidget:getChildByName("Panel_Main"):getContentSize()
	    local curPosX = self.mRootWidget:getChildByName("Panel_Main"):getPositionX()
	    self.mRootWidget:getChildByName("Panel_Main"):setPositionX(curPosX + panelSize.width/2)
		self.mRootWidget:getChildByName("Panel_Main"):setPositionY(newPosY + panelSize.height/2)

		self.mRootWidget:getChildByName("Panel_Main"):setOpacity(0)

		-- 做由小变大效果
		self.mRootWidget:getChildByName("Panel_Main"):setScale(0.5)
		local act0 = cc.ScaleTo:create(0.15, 1)
		local act1 = cc.FadeIn:create(0.15)
	--	local act1 = cc.EaseElasticOut:create(act0)
		self.mRootWidget:getChildByName("Panel_Main"):runAction(cc.Spawn:create(act0, act1))

	end
	doAdapter()

	-- 普通商城显示页签
	if 1 == self.mShopType or 7 == self.mShopType or 10 == self.mShopType then
		self.mRootWidget:getChildByName("Panel_CityShop_Pages"):setVisible(true)
		self.mRootWidget:getChildByName("Image_TokenBg"):setVisible(false)
	else
		self.mRootWidget:getChildByName("Panel_CityShop_Pages"):setVisible(false)
	end

	local function onPageBtnClicked(widget)
		if self.mLastChooseOption == widget then
			return
		end
	--	if self.mLastChooseOption then
	--		self.mLastChooseOption:loadTexture("shop_page_1.png")
	--	end
		self.mLastChooseOption = widget 
	--	self.mLastChooseOption:loadTexture("shop_page_2.png")

		-- 修改商店类型
		self.mShopType = widget:getTag()

		-- 全部还原
		self.mRootWidget:getChildByName("Image_Page_1"):loadTexture("shop_page1_2.png")
		self.mRootWidget:getChildByName("Image_Page_2"):loadTexture("shop_page2_2.png")
		self.mRootWidget:getChildByName("Image_Page_3"):loadTexture("shop_page3_2.png")

		-- 更换新的
		if "Image_Page_1" == self.mLastChooseOption:getName() then
			self.mLastChooseOption:loadTexture("shop_page1_1.png")
		elseif "Image_Page_2" == self.mLastChooseOption:getName() then
			self.mLastChooseOption:loadTexture("shop_page2_1.png")
		elseif "Image_Page_3" == self.mLastChooseOption:getName() then
			self.mLastChooseOption:loadTexture("shop_page3_1.png")
		end

		local function onRequestEnterShop(msgPacket)
			globaldata:updateGoodsInfoFromServerPacket(msgPacket)
			-- 刷新
			self:onSelectedOption()
		end

		NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_REQUEST_GOODSINFO_, onRequestEnterShop)

		local function requestEnterShop()
			local packet = NetSystem.mNetManager:GetSPacket()
	    	packet:SetType(PacketTyper._PTYPE_CS_REQUEST_GOODSINFO_)
	    	packet:PushChar(self.mShopType)
	    	packet:Send()
	    	GUISystem:showLoading()
		end
		requestEnterShop()
	end

	local btn = self.mRootWidget:getChildByName("Image_Page_1")
	btn:setTag(7)
	btn:setTouchEnabled(true)
	registerWidgetPushDownEvent(btn, onPageBtnClicked)
	btn = self.mRootWidget:getChildByName("Image_Page_2")
	btn:setTag(1)
	btn:setTouchEnabled(true)
	registerWidgetPushDownEvent(btn, onPageBtnClicked)
	btn = self.mRootWidget:getChildByName("Image_Page_3")
	btn:setTag(10)
	btn:setTouchEnabled(true)
	btn:setVisible(false)
	registerWidgetPushDownEvent(btn, onPageBtnClicked)

	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_Update"), handler(self, self.sendFreshInfo))

	local function setPageBtnSelectec()
		if 1 == self.mShopType then
			self.mLastChooseOption = self.mRootWidget:getChildByName("Image_Page_2")
			self.mLastChooseOption:loadTexture("shop_page2_1.png")
		elseif 7 == self.mShopType then
			self.mLastChooseOption = self.mRootWidget:getChildByName("Image_Page_1")
			self.mLastChooseOption:loadTexture("shop_page1_1.png")
		elseif 10 == self.mShopType then
			self.mLastChooseOption = self.mRootWidget:getChildByName("Image_Page_3")
			self.mLastChooseOption:loadTexture("shop_page3_1.png")
		end
	end

	-- 普通商城显示页签
	if 1 == self.mShopType or 7 == self.mShopType or 10 == self.mShopType then
		setPageBtnSelectec()
	end

	self:setFreshEnabled(false)
end

local margin_top 	= 0	-- 顶边距
local margin_left 	= 0		-- 左边距
local margin_cell	= 0	-- 元素边距

function ShopWindow:addGoodsItem(listView, goodsList)
	-- 隐藏
	local childrenTbl = listView:getChildren()
	for i = 1, #childrenTbl do
		childrenTbl[i]:setVisible(false)
	end

	local smallPosX = 0
	local bigPosX = 0

	listView:setVisible(true)
	local totalCount = #goodsList
	local columnCount = math.ceil(totalCount/2)
	local listContainerSize = listView:getInnerContainerSize()
	local listContentSize = listView:getContentSize()
	local itemContentSize = cc.size(305, 177)
	local newContentWidth = nil
	local function doResize()
		newContentWidth = columnCount * (itemContentSize.width + margin_cell)
		if totalCount <= 6 then
	--		listView:setPositionX(smallPosX)
			listView:setInnerContainerSize(listContentSize)
		else
	--		listView:setPositionX(bigPosX)
			if newContentWidth > listContentSize.width then
				listView:setInnerContainerSize(cc.size(newContentWidth, listContentSize.height))
			else
				listView:setInnerContainerSize(cc.size(listContainerSize.width, listContentSize.height))
			end
		end
	end
	doResize()
	for i = 1, #goodsList do
		local goodsObj = goodsList[i]
		local srcWidget = listView:getChildByTag(i)

		local goodsWidget = createGoodsWidget(self.mShopType, goodsObj:getKeyValue("goodsType"), goodsObj:getKeyValue("goodsId"),
			goodsObj:getKeyValue("goodsCurrencyType"), goodsObj:getKeyValue("goodsPrice"), goodsObj:getKeyValue("goodsIndex"), goodsObj:getKeyValue("goodsMaxBuyCount"), goodsObj:getKeyValue("goodsMaxBuyLimitPerDay"), srcWidget)
		listView:addChild(goodsWidget)
		local posX = ((i-1)%columnCount)*(itemContentSize.width+margin_cell) + margin_left
		local posY = 0

		if i > columnCount then
			posY = 0
		elseif i <= columnCount then
			posY = margin_top + itemContentSize.height
		end
		
		if totalCount <= 6 then
			goodsWidget:setPosition(cc.p(posX + smallPosX, posY))
		else
			goodsWidget:setPosition(cc.p(posX + bigPosX, posY))
		end

		goodsWidget:setTag(i)
		goodsWidget:setVisible(true)
	end
end

-- 响应购买成功
function ShopWindow:onRequestBuy(msgPacket)
	local success = msgPacket:GetChar()
	local shopType = msgPacket:GetChar()
	local unuseId = msgPacket:GetInt()
	local itemId = msgPacket:GetInt()
	local leftCount = msgPacket:GetInt()

	
	local function updateInfo()
		for i = 1, #globaldata.ShopGoodsList[shopType] do
			if itemId == globaldata.ShopGoodsList[shopType][i].goodsId then
				globaldata.ShopGoodsList[shopType][i].goodsMaxBuyLimitPerDay = leftCount
			end
		end
	end
	updateInfo()
	self:addGoodsItem(self.mPanelShangcheng, globaldata.ShopGoodsList[shopType])
end

-- 设置刷新按钮是否响应
function ShopWindow:setFreshEnabled(enabled)
	self.mRootWidget:getChildByName("Button_Update"):setVisible(enabled)
	self.mRootWidget:getChildByName("Label_UpdateTime"):setVisible(enabled)
end

-- 响应刷新物品
function ShopWindow:onRequestFreshShop()
	if 1 == self.mShopType then
		self:setFreshEnabled(false)
	elseif 2 == self.mShopType then
		self:setFreshEnabled(true)
	elseif 3 == self.mShopType then
		self:setFreshEnabled(true)
	elseif 4 == self.mShopType then
		self:setFreshEnabled(false)
	elseif 5 == self.mShopType then
		self:setFreshEnabled(true)
	elseif 8 == self.mShopType then
		self:setFreshEnabled(true)
	end
	-- 添加商品
	self:addGoodsItem(self.mPanelShangcheng, globaldata.ShopGoodsList[self.mShopType])
end

-- 请求刷新商品
function ShopWindow:requestFreshShop(type)
	self:onRequestFreshShop()
	-- 剩余时间
	local leftTime = globaldata.ShopFreshTime[type]
	self.mRootWidget:getChildByName("Label_UpdateTime"):setString(leftTime)
end

function ShopWindow:onSelectedOption(widget, bSound)
	-- 刷新商品
	self:requestFreshShop(self.mShopType)
	-- 更新货币
	self:updateCurCurrency(widget)
end

-- 更新当前货币
function ShopWindow:updateCurCurrency(widget)
	local imgWidget = self.mRootWidget:getChildByName("Image_CurCurrency")
	local lblWidget = self.mRootWidget:getChildByName("Label_CurCurrency")

	if 1 == self.mShopType then
		imgWidget:loadTexture("public_gold.png")
		lblWidget:setString(tostring(globaldata:getPlayerBaseData("money")))
		self.mRootWidget:getChildByName("Image_TokenBg"):setVisible(false)
	elseif 2 == self.mShopType then
		imgWidget:loadTexture("public_currency_tower.png")
		lblWidget:setString(tostring(globaldata:getPlayerBaseData("towerMoney")))
		self.mRootWidget:getChildByName("Image_TokenBg"):setVisible(true)
	elseif 3 == self.mShopType then
		imgWidget:loadTexture("public_currency_arena.png")
		lblWidget:setString(tostring(globaldata:getPlayerBaseData("naili")))
		self.mRootWidget:getChildByName("Image_TokenBg"):setVisible(true)
	elseif 4 == self.mShopType then
		imgWidget:loadTexture("public_diamond.png")
		lblWidget:setString(tostring(globaldata:getPlayerBaseData("diamond")))
		self.mRootWidget:getChildByName("Image_TokenBg"):setVisible(false)
	elseif 5 == self.mShopType then
		imgWidget:loadTexture("public_currency_guild.png")
		lblWidget:setString(tostring(globaldata:getPlayerBaseData("partyMoney")))
		self.mRootWidget:getChildByName("Image_TokenBg"):setVisible(true)
	elseif 8 == self.mShopType then
		imgWidget:loadTexture("public_currency_tianti.png")
		lblWidget:setString(tostring(globaldata:getPlayerBaseData("tiantiMoney")))
		self.mRootWidget:getChildByName("Image_TokenBg"):setVisible(true)
	end
end

-- 响应玩家基础信息改变
function ShopWindow:onRoleBaseInfoChanged()
	self:updateCurCurrency(self.mLastChooseOption)
end

function ShopWindow:Destroy()

	self.mTopRoleInfoPanel:destroy()
	self.mTopRoleInfoPanel = nil

	self.mRootNode:removeFromParent(true)
	self.mRootNode 		= 	nil
	self.mRootWidget 	= 	nil
	self.mLastChooseOption	=	nil
	self.mPanelShangcheng	=	nil

	GUIEventManager:unregister("shopFreshed", self.requestFreshShop)
	GUIEventManager:unregister("roleBaseInfoChanged", self.onRoleBaseInfoChanged)

	
	CommonAnimation.clearAllTextures()
	cclog("=====ShopWindow:Destroy=====")
end

function ShopWindow:onEventHandler(event)
	if event.mAction == Event.WINDOW_SHOW then
		if GUISystem:canShow(self.mName) then
			GUIWidgetPool:preLoadWidget("ShopItem", true)
			self:Load(event)
			---------停止画主城镇界面
			EventSystem:PushEvent(Event.GUISYSTEM_DISABLEDRAW_HOMEWINDOW)
			---------停止画帮派界面
			EventSystem:PushEvent(Event.GUISYSTEM_DISABLEDRAW_UNIONHALLWINDOW)
			---------
		end
	elseif event.mAction == Event.WINDOW_HIDE then
		GUIWidgetPool:preLoadWidget("ShopItem", false)
		self:Destroy()
		---------开启画主城镇界面
		EventSystem:PushEvent(Event.GUISYSTEM_EABLEDRAW_HOMEWINDOW)
		---------开启画帮派界面
		EventSystem:PushEvent(Event.GUISYSTEM_ENABLEDRAW_UNIONHALLWINDOW)
		---------
	end
end

return ShopWindow