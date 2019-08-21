-- Name: 	LotteryResultTen
-- Func：	十连抽结果
-- Author:	WangShengdong
-- Data:	14-12-17


local LotteryResultTenWindow = 
{
	mName 				=	"LotteryResultTenWindow",
	mRootNode			=	nil,
	mRootWidget			=	nil,
	mItemList 			=	{},	
	mCurLotteryType 	=	nil,
	mTopRoleInfoPanel	=	nil,	-- 顶部人物信息面板
}

function LotteryResultTenWindow:Release()

end

-- 显示物品
function LotteryResultTenWindow:showItem(data)

	local function xxx()
		for i = 1, 10 do
			self.mItemList[i] = TurnCardWidget.new(i, true,data[4][i],data[2][i],data[5][i])
			self.mRootWidget:getChildByName("Panel_"..i):addChild(self.mItemList[i])
			self.mItemList[i]:setPosition(cc.p(0, 0))
			self.mItemList[i]:setCardfront(false)
			self.mItemList[i]:setCanTouch(true)
			
			self.mItemList[i]:setItemIcon(data[1][i], data[2][i], data[3][i])

			self.mRootWidget:getChildByName("Button_Auto"):setVisible(true)
			self.mRootWidget:getChildByName("Button_Again"):setVisible(false)
			self.mRootWidget:getChildByName("Button_Close"):setVisible(false)

		end
	end
	local spine = CommonAnimation.playOnceSpineAni(442, "animation", 1, xxx, handler(self, self.onFrameEvent))
	self.mRootNode:addChild(spine, 100)
	spine:setPosition(cc.p(0, 0))

	local price = globaldata:getLotteryByTypeAndKey(self.mCurLotteryType, "tenthCostNum")
	self.mRootWidget:getChildByName("Label_Price"):setString(price)

	self.mRootWidget:getChildByName("Button_Auto"):setVisible(false)
	self.mRootWidget:getChildByName("Button_Again"):setVisible(false)
	self.mRootWidget:getChildByName("Button_Close"):setVisible(false)
end

-- 真是贱
function LotteryResultTenWindow:onFrameEvent(event)
	shakeNode(self.mRootNode, 2, 0.1)
end

-- 抽卡回包
function LotteryResultTenWindow:onExcuteLottery(msgPacket)
	for i = 1, 10 do
		self.mItemList[i] = TurnCardWidget.new(i)
		self.mRootWidget:getChildByName("Panel_"..i):removeAllChildren()
	end

	local lotteryType = msgPacket:GetInt()
	local leftTime = msgPacket:GetInt()

	local count = msgPacket:GetUShort()

	local result = {}
	result[1] = {}
	result[2] = {}
	result[3] = {}
	result[4] = {}
	result[5] = {}

	for i = 1, count do
		local heroOrItem = msgPacket:GetUChar()
		print("heroOrItem", heroOrItem)
		if 0 == heroOrItem then --新英雄
			result[1][i] = 10
			result[2][i], result[5][i] = globaldata:addHeroFromLottery(msgPacket)
			result[3][i] = -1
			result[4][i] = true
			print("新英雄id:", result[2][i])
		elseif 1 == heroOrItem then --旧英雄
			local heroId = msgPacket:GetInt()
			local heroName = msgPacket:GetString()
			print("heroId, heroName", heroId, heroName)
			result[1][i] = 10
			result[2][i] = heroId
			result[3][i] = -1
			result[4][i] = false
			result[5][i] = nil
		elseif 2 == heroOrItem then --物品
			local goodId = msgPacket:GetInt()
			local goodName = msgPacket:GetString()
			local goodNum = msgPacket:GetInt()
			print("goodId, goodName, goodNum", goodId, goodName, goodNum)
			result[1][i] = 0
			result[2][i] = goodId
			result[3][i] = goodNum
			result[4][i] = false
			result[5][i] = nil
		end	
	end
	self:showItem(result)
	GUISystem:hideLoading()
end

-- 再抽一次
function LotteryResultTenWindow:againLottery(widget)
	local price = globaldata:getLotteryByTypeAndKey(self.mCurLotteryType, "tenthCostNum")

	if 1 == self.mCurLotteryType then -- 金币
		if globaldata.money < price then
			MessageBox:showMessageBox1("金币不足~")
			return
		end
	elseif 2 == self.mCurLotteryType then -- 钻石
		if globaldata.diamond < price then
			MessageBox:showMessageBox1("钻石不足~")
			return
		end
	end

	GUISystem:playSound("lotterySound")

	widget:setVisible(false)
	local packet = NetSystem.mNetManager:GetSPacket()
    packet:SetType(PacketTyper._PTYPE_CS_REQUEST_EXCUTELOTTERY_)

    packet:PushUShort(self.mCurLotteryType)
    packet:PushUShort(10)
    packet:PushUShort(1)
	packet:Send()
	GUISystem:showLoading()

	self.mRootWidget:getChildByName("Image_Price"):setVisible(false)
	self.mRootWidget:getChildByName("Button_Auto"):setVisible(false)
end

-- 自动翻拍
function LotteryResultTenWindow:autoTurnCard(widget)
	widget:setVisible(false)
	for i = 1, 10 do
		if self.mItemList[i].mCardback:isVisible() then
			self.mItemList[i]:setTurnCard(true)
		end
	end
	self.mRootWidget:getChildByName("Image_Price"):setVisible(true)

	self.mRootWidget:getChildByName("Button_Auto"):setVisible(false)
	self.mRootWidget:getChildByName("Button_Again"):setVisible(true)
	self.mRootWidget:getChildByName("Button_Close"):setVisible(true)
end

function LotteryResultTenWindow:Load(event)
	cclog("=====LotteryResultTenWindow:Load=====begin")

	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_REQUEST_EXCUTELOTTERY_, handler(self,self.onExcuteLottery))

	self.mRootNode = cc.Node:create()
	GUISystem:GetRootNode():addChild(self.mRootNode)
	-----
	-- 初始化布局相关
	self:InitLayout()

	-- 显示物品
	self.mCurLotteryType = event.mData[1]
	self:showItem(event.mData[2])

	if 1 == self.mCurLotteryType then
		self.mRootWidget:getChildByName("Image_Price"):loadTexture("public_gold.png")
	elseif 2 == self.mCurLotteryType then
		self.mRootWidget:getChildByName("Image_Price"):loadTexture("public_diamond.png")
	end

	cclog("=====LotteryResultTenWindow:Load=====end")
end

function LotteryResultTenWindow:InitLayout()
	self.mRootWidget = GUIWidgetPool:createWidget("NewLotteryResult10")
	self.mRootNode:addChild(self.mRootWidget)

	local function closeWindow()
		GUISystem:playSound("homeBtnSound")
		EventSystem:PushEvent(Event.GUISYSTEM_HIDE_LOTTERYRESULTWINDOW10)
	end

	self.mTopRoleInfoPanel = TopRoleInfoPanel:new()
	local topInfoPanel = self.mTopRoleInfoPanel:init(self.mRootNode,ROLE_TITLE_TYPE.TITLE_LOTTERY, closeWindow)

	-- 自动翻拍
	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_Auto"), handler(self, self.autoTurnCard))
	-- 再抽一次
	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_Again"), handler(self, self.againLottery))
	self.mRootWidget:getChildByName("Button_Again"):setVisible(false)

	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_Close"), closeWindow)

	self.mRootWidget:getChildByName("Image_Price"):setVisible(false)


	self.mRootWidget:getChildByName("Button_Auto"):setVisible(false)
	self.mRootWidget:getChildByName("Button_Again"):setVisible(false)
	self.mRootWidget:getChildByName("Button_Close"):setVisible(false)

end

function LotteryResultTenWindow:Destroy()

	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_REQUEST_EXCUTELOTTERY_, handler(LotteryWindow,LotteryWindow.onExcuteLottery))

	self.mRootNode:removeFromParent(true)
	self.mRootNode = nil
	self.mRootWidget = nil

	self.mItemList 			=	{}
	self.mCurLotteryType 	=	nil

	self.mTopRoleInfoPanel:destroy()
	self.mTopRoleInfoPanel = nil
	-------
	CommonAnimation.clearAllTextures()
	cclog("=====LotteryResultTenWindow:Destroy=====")
end

function LotteryResultTenWindow:onEventHandler(event)
	if event.mAction == Event.WINDOW_SHOW then
		self:Load(event)
	elseif event.mAction == Event.WINDOW_HIDE then
		self:Destroy()
	end
end

return LotteryResultTenWindow