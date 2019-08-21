-- Name: 	HomeShopWindow
-- Func：	家具商城
-- Author:	WangShengdong
-- Data:	15-5-22

local HomeShopWindow = 
{
	mName				=	"HomeShopWindow",
	mRootNode			=	nil,
	mRootWidget			=	nil,
	mLastChooseOption	=	nil,
	mTopRoleInfoPanel	=	nil,
	mPanelShangcheng	=	nil,
}

function HomeShopWindow:Release()

end

function HomeShopWindow:Load(event)
	cclog("=====HomeShopWindow:Load=====begin")

	-- 检查版本
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_REQUEST_GOODSINFO_, handler(self,self.onRequestFreshShop))

	-- 购买成功
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_REQUEST_BUY_, handler(self,self.onRequestBuy))

	GUIEventManager:registerEvent("shopFreshed", self, self.requestFreshShop)
	GUIEventManager:registerEvent("roleBaseInfoChanged", self, self.onRoleBaseInfoChanged)

	self.mRootNode = cc.Node:create()
	GUISystem:GetRootNode():addChild(self.mRootNode)

	self:InitLayout()

	local index = event.mData
	if 1 == index then
		self:onSelectedOption(self.mRootWidget:getChildByName("Image_Shangcheng"))
	elseif 2 == index then
		self:onSelectedOption(self.mRootWidget:getChildByName("Image_Shenmi"))
	elseif 3 == index then
		self:onSelectedOption(self.mRootWidget:getChildByName("Image_Shengwang"))
	end

	cclog("=====HomeShopWindow:Load=====end")
end


function HomeShopWindow:sendFreshInfo(widget)
	local packet = NetSystem.mNetManager:GetSPacket()
	packet:SetType(PacketTyper._PTYPE_CS_REQUEST_FRESHSHOP_)
	packet:PushChar(self.mLastChooseOption:getTag())
	packet:Send()
	GUISystem:showLoading()
end

function HomeShopWindow:InitLayout()
	self.mRootWidget = GUIWidgetPool:createWidget("HomeShop")
	self.mRootNode:addChild(self.mRootWidget)

	local function closeWindow()
		EventSystem:PushEvent(Event.GUISYSTEM_HIDE_HOMESHOPWINDOW)
	end

	self.mTopRoleInfoPanel = TopRoleInfoPanel:new()
	local topInfoPanel = self.mTopRoleInfoPanel:init(self.mRootNode, ROLE_TITLE_TYPE.TITLE_SHOP,closeWindow)

	self.mPanelShangcheng	= self.mRootWidget:getChildByName("ListView_Shangcheng")
	self.mPanelShangcheng:setVisible(false)
	self.mPanelShenmi		= self.mRootWidget:getChildByName("ListView_Shenmi")
	self.mPanelShenmi:setVisible(false)
	self.mPanelShengwang	= self.mRootWidget:getChildByName("ListView_Shengwang")
	self.mPanelShengwang:setVisible(false)

	local function doAdapter()
	    local topInfoPanelSize = topInfoPanel:getContentSize()
	    local newHeight = getGoldFightPosition_LU().y - topInfoPanelSize.height - getGoldFightPosition_LD().y
	    local newPosY = newHeight/2 + getGoldFightPosition_LD().y - self.mRootWidget:getChildByName("Panel_Main"):getContentSize().height/2
	    self.mRootWidget:getChildByName("Panel_Main"):setVisible(false)
		local function doSomething()
			self.mRootWidget:getChildByName("Panel_Main"):setPositionY(newPosY)
			self.mRootWidget:getChildByName("Panel_Main"):setVisible(true)
		end
		nextTick(doSomething)
	end
	doAdapter()

	self.mRootWidget:getChildByName("Image_Shangcheng"):setTag(1)
	registerWidgetPushDownEvent(self.mRootWidget:getChildByName("Image_Shangcheng"), handler(self, self.onSelectedOption))
	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_Update"), handler(self, self.sendFreshInfo))

	self:setFreshEnabled(false)
end

local margin_top 	= 10	-- 顶边距
local margin_left 	= 5		-- 左边距
local margin_cell	= 13	-- 元素边距

function HomeShopWindow:addGoodsItem(listView, goodsList)
	print("商品数量", #goodsList)
	listView:removeAllChildren()
	listView:setVisible(true)
	local totalCount = #goodsList
	local columnCount = math.ceil(totalCount/2)
	local listContainerSize = listView:getInnerContainerSize()
	local listContentSize = listView:getContentSize()
	local itemContentSize = cc.size(270, 115)
	local newContentWidth = nil
	local function doResize()
		newContentWidth = columnCount * (itemContentSize.width + margin_cell)
		if totalCount <= 6 then
			listView:setInnerContainerSize(listContentSize)
		else
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
		print("商品Id", goodsObj:getKeyValue("goodsId"), "商品类型", goodsObj:getKeyValue("goodsType"))
		local goodsWidget = createGoodsWidget(4, goodsObj:getKeyValue("goodsType"), goodsObj:getKeyValue("goodsId"),
			goodsObj:getKeyValue("goodsCurrencyType"), goodsObj:getKeyValue("goodsPrice"), goodsObj:getKeyValue("goodsIndex"), goodsObj:getKeyValue("goodsMaxBuyCount"), goodsObj:getKeyValue("goodsMaxBuyLimitPerDay"))
		listView:addChild(goodsWidget)
		local posX = ((i-1)%columnCount)*(itemContentSize.width+margin_cell) + margin_left
		local posY = 0

		if i > columnCount then
			posY = 0
		elseif i <= columnCount then
			posY = margin_top + itemContentSize.height
		end
		
		goodsWidget:setPosition(cc.p(posX, posY))
	end
end

-- 响应购买成功
function HomeShopWindow:onRequestBuy(msgPacket)
	local success = msgPacket:GetChar()
	local shopType = msgPacket:GetChar()
	local unuseId = msgPacket:GetInt()
	local itemId = msgPacket:GetInt()
	local leftCount = msgPacket:GetInt()

	if 1 == shopType then
		local function updateInfo()
			for i = 1, #globaldata.ShopGoodsList do
				if itemId == globaldata.ShopGoodsList[i].goodsId then
				--	if 0 == leftCount then
				--		table.remove(globaldata.ShopGoodsList, i)
				--		break
				--	else
						print("刷新数据1", leftCount)
						globaldata.ShopGoodsList[i].goodsMaxBuyLimitPerDay = leftCount
				--	end
				end
			end
		end
		updateInfo()
		self:addGoodsItem(self.mPanelShangcheng, globaldata.ShopGoodsList)
	elseif 2 == shopType then
		local function updateInfo()
			for i = 1, #globaldata.ShenmiGoodsList do
				if itemId == globaldata.ShenmiGoodsList[i].goodsId then
			--		if 0 == leftCount then
			--			table.remove(globaldata.ShenmiGoodsList, i)
			--		else
						print("刷新数据2", leftCount)
						globaldata.ShenmiGoodsList[i].goodsMaxBuyLimitPerDay = leftCount
			--		end
				end
			end
		end
		updateInfo()
		self:addGoodsItem(self.mPanelShenmi, globaldata.ShenmiGoodsList)
	elseif 3 == shopType then
		local function updateInfo()
			for i = 1, #globaldata.ShengwangGoodsList do
				if itemId == globaldata.ShengwangGoodsList[i].goodsId then
		--			if 0 == leftCount then
		--				table.remove(globaldata.ShengwangGoodsList, i)
		--			else
						print("刷新数据3", leftCount)
						globaldata.ShengwangGoodsList[i].goodsMaxBuyLimitPerDay = leftCount
		--			end
				end
			end
		end
		updateInfo()
		self:addGoodsItem(self.mPanelShengwang, globaldata.ShengwangGoodsList)
	elseif 4 == shopType then
		local function updateInfo()
			for i = 1, #globaldata.FurnitGoodsList do
				if itemId == globaldata.FurnitGoodsList[i].goodsId then
		--			if 0 == leftCount then
		--				table.remove(globaldata.ShengwangGoodsList, i)
		--			else
						print("刷新数据4", leftCount)
						globaldata.FurnitGoodsList[i].goodsMaxBuyLimitPerDay = leftCount
		--			end
				end
			end
		end
		updateInfo()
		self:addGoodsItem(self.mPanelShangcheng, globaldata.FurnitGoodsList)
	end	
end

-- 设置刷新按钮是否响应
function HomeShopWindow:setFreshEnabled(enabled)
	self.mRootWidget:getChildByName("Button_Update"):setVisible(enabled)
	self.mRootWidget:getChildByName("Label_UpdateTime"):setVisible(enabled)
end

-- 响应刷新物品
function HomeShopWindow:onRequestFreshShop()
	if "Image_Shangcheng" == self.mLastChooseOption:getName() then
		self:setFreshEnabled(false)
		self:addGoodsItem(self.mPanelShangcheng, globaldata.FurnitGoodsList)
	end
end

-- 请求刷新商品
function HomeShopWindow:requestFreshShop(type)
	self:onRequestFreshShop()
	-- 剩余时间
	local leftTime = globaldata.ShopFreshTime[type]
	self.mRootWidget:getChildByName("Label_UpdateTime"):setString(leftTime)
end

function HomeShopWindow:onSelectedOption(widget)
	GUISystem:playSound("tabPageSound")
	if self.mLastChooseOption == widget then
		return 
	end

	local norTexture = {"shop_shangcheng_2.png", "shop_shenmi_2.png", "shop_shengwang_2.png"}
	local pusTexture = {"shop_shangcheng_1.png", "shop_shenmi_1.png", "shop_shengwang_1.png"}

	self.mRootWidget:getChildByName("Image_Shangcheng"):loadTexture(norTexture[1])

	local function replaceTexture()
		if self.mLastChooseOption then
			self.mLastChooseOption:loadTexture(norTexture[self.mLastChooseOption:getTag()])
			self.mLastChooseOption = widget
		else
			self.mLastChooseOption = widget
		end
		widget:loadTexture(pusTexture[self.mLastChooseOption:getTag()])
	end
	-- 换菜单项图片
	replaceTexture()

	self.mPanelShangcheng:setVisible(false)
	self.mPanelShenmi:setVisible(false)
	self.mPanelShengwang:setVisible(false)

	if "Image_Shangcheng" == widget:getName() then
		self.mPanelShangcheng:setVisible(true)
		self:requestFreshShop(4)
	end

	-- 更新货币
	self:updateCurCurrency(widget)
end

-- 更新当前货币
function HomeShopWindow:updateCurCurrency(widget)
	local imgWidget = self.mRootWidget:getChildByName("Image_CurCurrency")
	local lblWidget = self.mRootWidget:getChildByName("Label_CurCurrency")

	if 1 == widget:getTag() then
		imgWidget:loadTexture("public_gold.png")
		lblWidget:setString(tostring(globaldata:getPlayerBaseData("money")))
		self.mRootWidget:getChildByName("Image_TokenBg"):setVisible(false)
	elseif 2 == widget:getTag() then
		imgWidget:loadTexture("public_coin.png")
		lblWidget:setString(tostring(globaldata:getPlayerBaseData("shenmi")))
		self.mRootWidget:getChildByName("Image_TokenBg"):setVisible(true)
	elseif 3 == widget:getTag() then
		imgWidget:loadTexture("public_currency_arena.png")
		lblWidget:setString(tostring(globaldata:getPlayerBaseData("naili")))
		self.mRootWidget:getChildByName("Image_TokenBg"):setVisible(true)
	end
end

-- 响应玩家基础信息改变
function HomeShopWindow:onRoleBaseInfoChanged()
	self:updateCurCurrency(self.mLastChooseOption)
end

function HomeShopWindow:Destroy()
	self.mRootNode:removeFromParent(true)
	self.mRootNode 		= 	nil
	self.mRootWidget 	= 	nil
	self.mLastChooseOption	=	nil
	self.mPanelShangcheng	=	nil
	self.mPanelShenmi		=	nil
	self.mPanelShengwang		=	nil

	self.mTopRoleInfoPanel:destroy()
	self.mTopRoleInfoPanel = nil

	GUIEventManager:unregister("shopFreshed", self.requestFreshShop)
	GUIEventManager:unregister("roleBaseInfoChanged", self.onRoleBaseInfoChanged)

	
	CommonAnimation.clearAllTextures()
	cclog("=====HomeShopWindow:Destroy=====")
end

function HomeShopWindow:onEventHandler(event)
	if event.mAction == Event.WINDOW_SHOW then
		self:Load(event)
	elseif event.mAction == Event.WINDOW_HIDE then
		self:Destroy()
	end
end

return HomeShopWindow