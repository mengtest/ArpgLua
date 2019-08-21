-- Name: 	DailyRewardWindow
-- Func：	福利
-- Author:	lichuan
-- Data:	15-7-15

INVALID_VALUE = 9999

DailyRewardModel = class("DailyRewardModel")

local rewardObject = {}

function rewardObject:new()
	local o = 
	{
		mMagicNum   =   nil, 
		mAlreadyGet	=	nil,	-- 是否已经领去 0:已经签到 1:未签到
		mVipLevel	=   nil,
		mItemType	=	nil,
		mItemId		=	nil,	
		mItemNum	=	nil,
	}
	o = newObject(o, rewardObject)
	return o
end

local MEALSTATE = {MEAL_NOTREADY = 1,MEAL_READY = 2,MEAL_EATED = 3,MEAL_TIMEOUT = 4}

local DRInstance = nil

function DailyRewardModel:ctor(owner)
	self.mName 		        = "DailyRewardModel"
	self.mOwner			    = nil
	self.mLoginRewardArr    = {}

	self.mSignInIndex		= nil 
	self.mClickIndex	    = nil 

	self.mCurMonth 			= nil
	self.mCurDayCount		= nil
	self.mRewardInfoList 	= {}
	self.mLvRewardStates    = {}
	self.mLoginCnt          = nil

	self:registerNetEvent()
end

function DailyRewardModel:deinit()
	self.mName 		     = nil
	self.mOwner			 = nil
	self.mLoginRewardArr = nil
	self.mClickIndex     = nil
	self.mSignInIndex    = nil
	self.mCurMonth 		 = nil
	self.mCurDayCount	 = nil
	self.mLoginCnt       = nil
	self.mRewardInfoList = {}
	self.mLvRewardStates = {}
	self:unRegisterNetEvent()
end

function DailyRewardModel:getInstance()
	if DRInstance == nil then  
        DRInstance = DailyRewardModel.new()
    end  
    return DRInstance
end

function DailyRewardModel:destroyInstance()
	if DRInstance then
		DRInstance:deinit()
    	DRInstance = nil
    end
end

function DailyRewardModel:registerNetEvent()
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_DAILYREWARD_INFO_, handler(self, self.onDailyRewardResponse))
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_DAILYREWARD_GET_,  handler(self, self.onGetRewardResponse))
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_LOGIN_INFO_RESPONSE_, handler(self, self.onLoginInfoResponse))
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_GET_LOGIN_REWARD_RESPONSE_, handler(self, self.onGetLoginRewardResponse))
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_EAT_MEAL_RESPONSE_, handler(self, self.onEatMealResponse))
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_LEVEL_REWARD_STATE_RESPONSE_, handler(self, self.onLoadLevelRewardStateResponse))
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_GET_LEVEL_REWARD_RESPONSE_, handler(self, self.onGetLevelRewardResponse))
end

function DailyRewardModel:unRegisterNetEvent()
	NetSystem.mNetManager:UnregisterPacketHandler(PacketTyper._PTYPE_SC_DAILYREWARD_INFO_)
	NetSystem.mNetManager:UnregisterPacketHandler(PacketTyper._PTYPE_SC_DAILYREWARD_GET_)
	NetSystem.mNetManager:UnregisterPacketHandler(PacketTyper._PTYPE_SC_LOGIN_INFO_RESPONSE_)
	NetSystem.mNetManager:UnregisterPacketHandler(PacketTyper._PTYPE_SC_GET_LOGIN_REWARD_RESPONSE_)
	NetSystem.mNetManager:UnregisterPacketHandler(PacketTyper._PTYPE_SC_EAT_MEAL_RESPONSE_)
	NetSystem.mNetManager:UnregisterPacketHandler(PacketTyper._PTYPE_SC_LEVEL_REWARD_STATE_RESPONSE_)
	NetSystem.mNetManager:UnregisterPacketHandler(PacketTyper._PTYPE_SC_GET_LEVEL_REWARD_RESPONSE_)
end

function DailyRewardModel:setOwner(owner)
	self.mOwner = owner
end

function DailyRewardModel:doLoadDailyRewardInfo()
	if #self.mRewardInfoList ~= 0 then return end
	local packet = NetSystem.mNetManager:GetSPacket()
	packet:SetType(PacketTyper._PTYPE_CS_DAILYREWARD_INFO_)
	packet:Send()
	GUISystem:showLoading()
end

function DailyRewardModel:onDailyRewardResponse(msgPacket)
	self.mCurMonth    = msgPacket:GetUShort()
	self.mCurDayCount = msgPacket:GetUShort()
	self.mTotalGotCnt = msgPacket:GetChar()
	self.mRewardInfoList = {}
	for i = 1, self.mCurDayCount do
		self.mRewardInfoList[i]             = rewardObject:new()
		self.mRewardInfoList[i].mMagicNum   = msgPacket:GetInt()
		self.mRewardInfoList[i].mAlreadyGet = msgPacket:GetChar()
		self.mRewardInfoList[i].mVipLevel	= msgPacket:GetUShort()
		self.mRewardInfoList[i].mItemType   = msgPacket:GetInt()
		self.mRewardInfoList[i].mItemId     = msgPacket:GetInt()
		self.mRewardInfoList[i].mItemNum    = msgPacket:GetInt()
	end

	if self.mOwner ~= nil then 
		self.mOwner:UpdateDailyReward()
	end

	GUISystem:hideLoading()
end

function DailyRewardModel:doGetRewardRequest(index)
	self.mSignInIndex = index
	local packet = NetSystem.mNetManager:GetSPacket()
	packet:SetType(PacketTyper._PTYPE_CS_DAILYREWARD_GET_)
	packet:PushInt(index)
	packet:Send()
	GUISystem:showLoading()
end

function DailyRewardModel:onGetRewardResponse(msgPacket)
	local ret = msgPacket:GetChar()
	if 0 == ret then
		local dayCnt = msgPacket:GetUShort()
		self.mRewardInfoList[dayCnt].mAlreadyGet = 0
		self.mRewardInfoList[dayCnt].mMagicNum   = msgPacket:GetInt()
		self.mTotalGotCnt = msgPacket:GetChar()
		self.mGetCnt      = msgPacket:GetInt()

		if self.mOwner and self.mOwner.mlstClickItem then
			self.mOwner.mlstClickItem:setTouchEnabled(true)
		end

	end
	GUISystem:hideLoading()

	if self.mOwner ~= nil then
		self.mOwner:NotifySignIn(self.mSignInIndex,self.mGetCnt)
	end
end

function DailyRewardModel:doLoadLoginInfoRequest()
	if #self.mLoginRewardArr ~= 0 then return end
	local packet = NetSystem.mNetManager:GetSPacket()
    packet:SetType(PacketTyper._PTYPE_CS_LOGIN_INFO_REQUEST_)
    packet:Send()
    GUISystem:showLoading()
end

function DailyRewardModel:onLoginInfoResponse(msgPacket)
	self.mLoginCnt     = msgPacket:GetUShort()
	local rewardDayCnt = msgPacket:GetUShort()

	self.mLoginRewardArr = {}
	for i=1,rewardDayCnt do
		self.mLoginRewardArr[i] = {}
		self.mLoginRewardArr[i].getStaus = msgPacket:GetChar()
		
		-- if self.mLoginRewardArr[i].getStaus == 2 then 
		-- 	self.mLoginCnt = self.mLoginCnt + 1
		-- end

		local rewardCnt = msgPacket:GetUShort()
		self.mLoginRewardArr[i].rewardInfoArr = {}
		for j=1,rewardCnt do
			self.mLoginRewardArr[i].rewardInfoArr[j] = {}
			self.mLoginRewardArr[i].rewardInfoArr[j][1] =  msgPacket:GetInt()
			self.mLoginRewardArr[i].rewardInfoArr[j][2] =  msgPacket:GetInt()
			self.mLoginRewardArr[i].rewardInfoArr[j][3] =  msgPacket:GetInt()
		end
	end

	GUISystem:hideLoading()
	if self.mOwner ~= nil then
		self.mOwner:UpdateLoginRewardLayout()
	end
end

function DailyRewardModel:doGetLoginRewardRequest(panelIndex)
	self.mClickIndex = panelIndex
	local packet = NetSystem.mNetManager:GetSPacket()
    packet:SetType(PacketTyper._PTYPE_CS_GET_LOGIN_REWARD_REQUEST_)
    packet:PushInt(panelIndex)
    packet:Send()
    GUISystem:showLoading()
end

function DailyRewardModel:onGetLoginRewardResponse(msgPacket)
	GUISystem:hideLoading()
	local ret = msgPacket:GetChar()
	if ret == 0 then
		if self.mOwner ~= nil then
			self.mOwner:NotifyGetReward(self.mClickIndex)
		end
	else

	end
end

function DailyRewardModel:doEatMealRequest(idx)
	self.mEatIdx = idx
	local packet = NetSystem.mNetManager:GetSPacket()
    packet:SetType(PacketTyper._PTYPE_CS_EAT_MEAL_REQUEST_)
    packet:PushChar(idx)
    packet:Send()
    GUISystem:showLoading()
end

function DailyRewardModel:onEatMealResponse(msgPacket)
	local ret = msgPacket:GetChar()
	if ret == 0 then
		local x = msgPacket:GetInt()
		MessageBox:showMessageBox1(string.format("体力+%d",x))
		local mealPanel  = self.mOwner.mWinArr[4]:getChildByName(string.format("Panel_Meal_%d",self.mEatIdx))
		local stateLabel = mealPanel:getChildByName("Label_State")
		local eatBtn     = mealPanel:getChildByName("Button_Get")
		stateLabel:setVisible(true)
		stateLabel:setString("已享用")
		eatBtn:setVisible(false)
		globaldata.mealStateArr[self.mEatIdx] = MEALSTATE.MEAL_EATED
	else
		MessageBox:showMessageBox1("没吃着！")
	end
	GUISystem:hideLoading()
end

function DailyRewardModel:doLoadLevelRewardStateRequest()
	if not empty(self.mLvRewardStates) then return end
	local packet = NetSystem.mNetManager:GetSPacket()
    packet:SetType(PacketTyper._PTYPE_CS_LEVEL_REWARD_STATE_REQUEST_)
    packet:Send()
    GUISystem:showLoading()
end

function DailyRewardModel:onLoadLevelRewardStateResponse(msgPacket)
	local cnt = msgPacket:GetUShort()

	for i=1,cnt do
		self.mLvRewardStates[i] = msgPacket:GetChar()
	end

	GUISystem:hideLoading()

	if self.mOwner then
		self.mOwner:InitLevelRewardPanel(self.mLvRewardStates)
	end
end

function DailyRewardModel:doGetLevelRewardRequest(cell)
	self.mLstCell = cell
	local packet = NetSystem.mNetManager:GetSPacket()
    packet:SetType(PacketTyper._PTYPE_CS_GET_LEVEL_REWARD_REQUEST_)
    packet:PushInt(cell:getChildByName("Button_Get"):getTag())
    packet:Send()
    GUISystem:showLoading()
end

function DailyRewardModel:onGetLevelRewardResponse(msgPacket)
	local ret = msgPacket:GetChar()

	GUISystem:hideLoading()
	if ret == SUCCESS then
		local idx = self.mLstCell:getChildByName("Button_Get"):getTag()
		local data = DB_LevelRewards.getDataById(idx)
		local itemlist = {}

		for i=1,4 do
			local rewards = data[string.format("Reward%d",i)]
			table.insert(itemlist,rewards)
		end

		self.mLvRewardStates[idx] = REWARDSTATE.HAVERECEIVED
		self.mLstCell:getChildByName("Button_Get"):setVisible(false)
		self.mLstCell:getChildByName("Image_Got"):setVisible(true)

		MessageBox:showMessageBox_ItemAlreadyGot(itemlist)
	else
		MessageBox:showMessageBox1("没领到！")
	end
end

function DailyRewardModel:getFirstIndex()
	local idx = 0
	for i=1,#self.mLvRewardStates do
		if self.mLvRewardStates[i] == REWARDSTATE.CANRECEIVE then
			idx = i
			break 
		end
	end

	return idx
end

--=============================================================================== window begin ===============================================================================

local DailyRewardWindow = 
{
	mName 				        = 	"DailyRewardWindow",
	mRootNode			        = 	nil,
	mRootWidget 		        = 	nil,
	mTopRoleInfoPanel	        = 	nil,
	mLastClickedOptionWidget 	= 	nil,	-- 最后一次选中的选项

	mModel				        = 	nil,
	---------------------------------------------------------
	mVipGiftWidgetList 			=	{},

	mAnimArr                    =   {},
	mVipListView				=   nil,

	mWinArr						=   {},
}

function DailyRewardWindow:Release()

end

function DailyRewardWindow:Load()
	cclog("=====DailyRewardWindow:Load=====begin")

	self.mRootNode = cc.Node:create()
	GUISystem:GetRootNode():addChild(self.mRootNode)

	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_BUY_VIP_GIFT, handler(self, self.onRequestBuyGift))

	self.mModel = DailyRewardModel:getInstance()
	self.mModel:setOwner(self)
	---
	self:InitLayout()

	-- 更新VIP礼包
	--GUIEventManager:registerEvent("roleBaseInfoChanged", self, self.updateVipGiftInfo)
	cclog("=====DailyRewardWindow:Load=====end")
end

-- 购买礼包回包
function DailyRewardWindow:onRequestBuyGift(msgPacket)
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

function DailyRewardWindow:InitLayout()	
	local a = os.clock()

	if not GUIWidgetPool.mWidgets["WelfareMain"] then
		GUIWidgetPool.mWidgets["WelfareMain"]= ccs.GUIReader:getInstance():widgetFromBinaryFile("res/layout/iphone5/WelfareMain.csb")
		GUIWidgetPool.mWidgets["WelfareMain"]:retain()		
	end
		
	self.mRootWidget = GUIWidgetPool.mWidgets["WelfareMain"]	
	self.mRootNode:addChild(self.mRootWidget)
	--load bg
	local bg = self.mRootWidget:getChildByName("Image_WindowBg")
	bg:loadTexture("res/image/new/public_bg_all2.jpg")

	local function closeWindow()
		EventSystem:PushEvent(Event.GUISYSTEM_HIDE_DAILYREWARDWINDOW)
	end

	if self.mTopRoleInfoPanel == nil then
		cclog("DailyRewardWindow mTopRoleInfoPanel init")
		self.mTopRoleInfoPanel = TopRoleInfoPanel:new()
		self.mTopRoleInfoPanel:init(self.mRootNode,ROLE_TITLE_TYPE.TITLE_WELFARE,closeWindow)
	end

	for i = 1, 5 do
		local btn = self.mRootWidget:getChildByName(string.format("Panel_Daily%d",i))
		btn:setTag(i)
		registerWidgetReleaseUpEvent(btn, handler(self,self.OnClickRewardTab))
	end

	local topSize = self.mTopRoleInfoPanel.mTopWidget:getContentSize()
	local y = getGoldFightPosition_Middle().y - topSize.height / 2
	local x = getGoldFightPosition_Middle().x

	self.mRootWidget:getChildByName("Panel_Main"):setAnchorPoint(0.5,0.5)
 	self.mRootWidget:getChildByName("Panel_Main"):setPosition(cc.p(x,y))
	
	local sv = self.mRootWidget:getChildByName("ScrollView_Dailyrewards")
	sv:setBounceEnabled(true)
	sv:setVisible(false)

	self.mRootWidget:getChildByName("Label_MonthTimes"):setVisible(false)

	self:UIAnimation()

	self.mWinArr[1] = self.mRootWidget:getChildByName("Panel_Schedule")
	self.mWinArr[2] = self.mRootWidget:getChildByName("Panel_dailyrewards")
	self.mWinArr[3] = self.mRootWidget:getChildByName("Panel_VIP_Package")
	self.mWinArr[4] = self.mRootWidget:getChildByName("Panel_Meal")
	self.mWinArr[5] = self.mRootWidget:getChildByName("Panel_LevelRewards")

	self:OnClickRewardTab(self.mRootWidget:getChildByName("Panel_Daily1"),false)
	local b = os.clock()
	cclog(string.format("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa%0.4f",b - a))
end

function DailyRewardWindow:UpdateMealPanel()
	local state = globaldata.mealStateArr

	local stateString = {"未开饭","可享用","已享用","已超时"}

	for i=1,3 do
		local mealPanel  = self.mWinArr[4]:getChildByName(string.format("Panel_Meal_%d",i))
		local stateLabel = mealPanel:getChildByName("Label_State")
		local btnEat     = mealPanel:getChildByName("Button_Get")

		btnEat:setTag(i)

		registerWidgetReleaseUpEvent(btnEat,function() self.mModel:doEatMealRequest(btnEat:getTag()) end)

		if state[i] == MEALSTATE.MEAL_READY then
			stateLabel:setVisible(false)
			btnEat:setVisible(true)
		else
			stateLabel:setVisible(true)
			btnEat:setVisible(false)
			stateLabel:setString(stateString[state[i]])
		end	
	end
end

function DailyRewardWindow:UIAnimation()

	local deltaX = 50
	local function PageAnimation()
		-- 初始化位置
		for i = 1, 5 do
			local btn      = self.mRootWidget:getChildByName(string.format("Panel_Daily%d", i))
			local curPosX  = btn:getPositionX()
			btn:setPositionX(curPosX - deltaX)
			btn:setOpacity(0)
			btn:setVisible(true)
		end	
		-- 依次做运动
		for i = 1, 5 do
			local btn      = self.mRootWidget:getChildByName(string.format("Panel_Daily%d", i))
			local curPos   = cc.p(btn:getPosition())
			local newPos   = cc.p(curPos.x + deltaX, curPos.y)
			local act0     = cc.DelayTime:create(i*0.15)
			local act1     = cc.MoveTo:create(0.1, newPos)
			local act2     = cc.FadeIn:create(0.1)
			local act3     = cc.Spawn:create(act1, act2)
			btn:runAction(cc.Sequence:create(act0, act3))
		end	
	end
	PageAnimation()

	local contentPanel = self.mRootWidget:getChildByName("Panel_Window")
	local panelPos   = cc.p(contentPanel:getPosition()) 
	local panelSize  = contentPanel:getContentSize() 

	local function runBegin()
		contentPanel:setPositionX(getGoldFightPosition_RD().x - panelSize.width / 2)
		contentPanel:setOpacity(0)
	end

	local actBegin = cc.CallFunc:create(runBegin)
	local actMove  = cc.MoveTo:create(0.2, panelPos)
	local actFade  = cc.FadeIn:create(0.2)
	local actSpawn = cc.Spawn:create(actMove,actFade)

	contentPanel:runAction(cc.Sequence:create(actBegin,actSpawn))
end

function DailyRewardWindow:onScrollViewEvent(sender, evenType)
	local widget = nil 
	local edgeUp = nil 
	local edgeDown = nil

	if self.mLastClickedOptionWidget:getTag() == 1 then 
		widget = self.mRootWidget:getChildByName("ScrollView_Rewards")
		edgeUp = self.mRootWidget:getChildByName("Panel_Schedule"):getChildByName("Image_Edge_1")
		edgeDown = self.mRootWidget:getChildByName("Panel_Schedule"):getChildByName("Image_Edge_2")
	else
		widget = self.mRootWidget:getChildByName("ScrollView_Dailyrewards")
		edgeUp = self.mRootWidget:getChildByName("Panel_dailyrewards"):getChildByName("Image_Edge_1")
		edgeDown = self.mRootWidget:getChildByName("Panel_dailyrewards"):getChildByName("Image_Edge_2")
	end
	
	local contentSize = widget:getContentSize()
	local innerSize   = widget:getInnerContainerSize()
	local innerWidget = widget:getInnerContainer()
	local innerPosY   = innerWidget:getPositionY()


	edgeUp:setVisible(false)
	edgeDown:setVisible(false)

	if 0 == innerPosY then
		edgeUp:setVisible(true)
	elseif contentSize.height - innerSize.height == innerPosY then
		edgeDown:setVisible(true)
	else
		edgeDown:setVisible(true)
		edgeUp:setVisible(true)
	end
end

function DailyRewardWindow:OnClickRewardTab(widget, bSound)
	if bSound == nil then GUISystem:playSound("tabPageSound") end
	
	if self.mLastClickedOptionWidget == widget then return end

	local tag = widget:getTag()

	for i=1,#self.mWinArr do
		self.mWinArr[i]:setVisible(i == tag)
	end

	if 1 == tag then
		self.mModel:doLoadDailyRewardInfo()
	elseif 2 == tag then
		self.mModel:doLoadLoginInfoRequest()
	elseif 3 == tag then
		self:updateVipGiftInfo()
	elseif 4 == tag then
		self:UpdateMealPanel()
	elseif 5 == tag then
		self.mModel:doLoadLevelRewardStateRequest()
	end

	local norTexture = "welfare_page_bg1.png"
	local pusTexture = "welfare_page_bg2.png"

	for i = 1, 5 do
		local btn = self.mRootWidget:getChildByName(string.format("Panel_Daily%d",i))
		btn:getChildByName("Image_Bg"):loadTexture(norTexture,1)
		btn:getChildByName("Label_Name"):setColor(cc.c3b(90, 204, 255))
	end

	widget:getChildByName("Image_Bg"):loadTexture(pusTexture,1)
	widget:getChildByName("Label_Name"):setColor(cc.c3b(255, 255, 255))

	self.mLastClickedOptionWidget = widget

	local function addAnim()
		-- 播放特效
		local animNode = AnimManager:createAnimNode(8016)
		table.insert(self.mAnimArr,animNode) 
		widget:getChildByName("Panel_Welfare_Animation"):addChild(animNode:getRootNode(), 100)
		animNode:play("welfare_page_chose")
	end
	addAnim()
end

function DailyRewardWindow:InitLevelRewardPanel(states)
	local len = #DB_LevelRewards.LevelRewards
	local LRpanel = self.mRootWidget:getChildByName("Panel_LevelRewards")
	self.mLRlst = LRpanel:getChildByName("ListView_LevelRewards")
	self.mLRlst:removeAllItems()

	local cellSize = nil

	for i=1,len do
		local cell = GUIWidgetPool:createWidget("Welfare_LevelRewards_Cell")
		local data = DB_LevelRewards.getDataById(i)

		cellSize = cell:getContentSize()

		cell:getChildByName("Label_Level_Stroke"):setString(string.format("%d级",data.level))

		for i=1,4 do
			local rewards = data[string.format("Reward%d",i)]
			local item = createCommonWidget(rewards[1], rewards[2], rewards[3])
			cell:getChildByName(string.format("Panel_Item_%d",i)):addChild(item)
		end

		if globaldata.level < data.level then
			cell:getChildByName("Label_cannot_Stroke"):setVisible(true)
			cell:getChildByName("Image_Level_Bg"):loadTexture("welfare_levelrewards_bar_bg1.png",1)
			cell:getChildByName("Image_Bg"):loadTexture("welfare_dailyrewards_bar_bg1.png",1)
		else
			cell:getChildByName("Label_cannot_Stroke"):setVisible(false)

			if states[i] == REWARDSTATE.CANRECEIVE then
				cell:getChildByName("Button_Get"):setVisible(true)
				cell:getChildByName("Button_Get"):setTag(i)

				registerWidgetReleaseUpEvent(cell:getChildByName("Button_Get"),function() self.mModel:doGetLevelRewardRequest(cell) end)
			else
				cell:getChildByName("Image_Got"):setVisible(true)
			end

			cell:getChildByName("Image_Bg"):loadTexture("welfare_dailyrewards_bar_bg2.png",1)
			cell:getChildByName("Image_Level_Bg"):loadTexture("welfare_levelrewards_bar_bg2.png",1)
		end

		self.mLRlst:pushBackCustomItem(cell)
	end

	local idx    = self.mModel:getFirstIndex()
	local width  = cellSize.width
	local height = cellSize.height * len + (len - 1) * 5

	self.mLRlst:setInnerContainerSize(cc.size(width,height))
	self.mLRlst:jumpToPercentVertical(idx == len and 100 or (cellSize.height + 5) * (idx - 1) / height * 100)
end

-- 更新vip礼包信息
function DailyRewardWindow:updateVipGiftInfo()
	self.mVipListView = self.mRootWidget:getChildByName("ListView_VIP_Package")
	if #self.mVipGiftWidgetList == 0 then -- 没有就创建
		for i = 1, 16 do
			self.mVipGiftWidgetList[i] = GUIWidgetPool:createWidget("Welfare_VIP_Package_Cell")
			self.mVipListView:pushBackCustomItem(self.mVipGiftWidgetList[i])

			local giftInfo = DB_VipBag.getDataById(i)
			-- 物品
			for j = 1, giftInfo.rewardCount do
				local itemInfoStr = giftInfo["Item"..tostring(j)]
				local infoTbl = extern_string_split_(itemInfoStr, ",")
				local itemWidget = createCommonWidget(tonumber(infoTbl[1]), tonumber(infoTbl[2]), tonumber(infoTbl[3]))
				self.mVipGiftWidgetList[i]:getChildByName("Panel_Reward_"..tostring(j)):addChild(itemWidget)
			
				if 0 == tonumber(infoTbl[1]) then
					local itemData = DB_ItemConfig.getDataById(tonumber(infoTbl[2]))
					if 1 == itemData.Type then -- 英雄碎片
						local animNode = AnimManager:createAnimNode(8013)
						table.insert(self.mAnimArr,animNode) 
						itemWidget:getChildByName("Panel_Animation"):addChild(animNode:getRootNode())
						animNode:play("item_special", true)
					end
				end
			end

			-- 原价
			self.mVipGiftWidgetList[i]:getChildByName("Image_PrePrice"):getChildByName("Label_PrePrice"):setString(giftInfo.originalPrice)

			-- 现价
			self.mVipGiftWidgetList[i]:getChildByName("Image_CurPrice"):getChildByName("Label_PrePrice"):setString(giftInfo.discountPrice)

			-- 购买
			local btnWidget = self.mVipGiftWidgetList[i]:getChildByName("Button_Buy")
			btnWidget:setTag(i)
			local function requestBuyGift(widget)
				local packet = NetSystem.mNetManager:GetSPacket()
				packet:SetType(PacketTyper._PTYPE_CS_BUY_VIP_GIFT)
				packet:PushInt(widget:getTag())
				packet:Send()
				GUISystem:showLoading()
			end
			registerWidgetReleaseUpEvent(btnWidget, requestBuyGift)
		end
	end

	for i = 1, 16 do
		local giftInfo = DB_VipBag.getDataById(i)
		local widget = self.mVipGiftWidgetList[i]
		local labelParentWidget = widget:getChildByName("Image_VIP")
		local labelWidget = widget:getChildByName("Label_VIP_155_0_0")
		local btnWidget   = widget:getChildByName("Button_Buy")
		if i <= globaldata.vipLevel then -- 达到
			labelParentWidget:setVisible(false)
			if 0 == globaldata.vipGiftList[i] then -- 可购买
				btnWidget:setVisible(true)
				widget:getChildByName("Image_Got"):setVisible(false)
			elseif 1 == globaldata.vipGiftList[i] then -- 不可购买
				btnWidget:setVisible(false)
				widget:getChildByName("Image_Got"):setVisible(true)
			end
			
		else -- 没达到
			labelParentWidget:setVisible(true)
			labelWidget:setString("Vip"..tostring(i).."可购买")
			btnWidget:setVisible(false)
		end
	end
end

function DailyRewardWindow:UpdateDailyReward()
	for i = 1, self.mModel.mCurDayCount do
		local rewardWidget = self:createRewardWidget(i)
		self.mRootWidget:getChildByName(string.format( "Panel_Day_%d",i)):addChild(rewardWidget)
	end

	self.mRootWidget:getChildByName("Label_MonthTimes"):setVisible(true)
	self.mRootWidget:getChildByName("Label_MonthTimes"):setString(string.format("本月已经签到%d次",self.mModel.mTotalGotCnt))

	-- 当前月份
	self.mRootWidget:getChildByName("Image_Title"):loadTexture(string.format("welfare_schedule_title_%d.png",self.mModel.mCurMonth),1)
end

function DailyRewardWindow:createRewardWidget(index)
	local widget = GUIWidgetPool:createWidget("Welfare_Schedule_Widget")
	local obj = self.mModel.mRewardInfoList[index]
	-- 显示物品
	local item = createCommonWidget(obj.mItemType, obj.mItemId, obj.mItemNum)
	widget:getChildByName("Panel_Item"):addChild(item)
	
	-- 是否已经领去
	if 0 == obj.mAlreadyGet then -- 已经领取
		widget:getChildByName("Image_Gotten"):setVisible(true)
		widget:getChildByName("Image_VIP_Double"):setVisible(false)
		widget:setTouchEnabled(false)

		item:setTouchEnabled(true)
		if obj.mMagicNum == 1 and obj.mVipLevel ~= INVALID_VALUE then
			widget:getChildByName("Image_Again"):setVisible(true)
			widget:getChildByName("Image_Again"):loadTexture(string.format("welfare_schedule_again_vip_%d.png",obj.mVipLevel),1)
		else
			widget:getChildByName("Image_Again"):setVisible(false)
		end
	elseif 1 == obj.mAlreadyGet then -- 不能领取
		widget:getChildByName("Image_Gotten"):setVisible(false)
		widget:setTouchEnabled(false)

		if obj.mVipLevel ~= INVALID_VALUE then 
			widget:getChildByName("Image_VIP_Double"):setVisible(true)
			widget:getChildByName("Image_VIP"):loadTexture(string.format("welfare_schedule_vip_%d.png",obj.mVipLevel),1) 
		end

		item:setTouchEnabled(true)

	elseif 2 == obj.mAlreadyGet then -- 可领取
		widget:getChildByName("Image_Gotten"):setVisible(false)
		widget:getChildByName("Image_Bg"):loadTexture("welfare_schedule_item_bg2.png",1)
		widget:setTouchEnabled(true)

		local anim = AnimManager:createAnimNode(8028)
		if anim then
			widget:getChildByName("Panel_Animation"):addChild(anim:getRootNode(), 100)
			anim:play("welfare_schedule_today", true)
		end

		if obj.mVipLevel ~= INVALID_VALUE then 
			widget:getChildByName("Image_VIP_Double"):setVisible(true)
			widget:getChildByName("Image_VIP"):loadTexture(string.format("welfare_schedule_vip_%d.png",obj.mVipLevel),1) 
		end

		item:setTouchEnabled(false)
				
		registerWidgetReleaseUpEvent(widget,
		function()
			self.mlstClickItem = widget
		 	GUISystem:playSound("homeBtnSound") 
		 	if anim then anim:stop() anim:destroy() anim = nil end
		 	self.mModel:doGetRewardRequest(index)  
		 end)
	end



	return widget
end

function DailyRewardWindow:NotifySignIn(index,getCnt)

	local itemlist = {self.mModel.mRewardInfoList[index].mItemType,self.mModel.mRewardInfoList[index].mItemId,getCnt,self.mModel.mRewardInfoList[index].mVipLevel}

	MessageBox:showMessageBox4(itemlist,true)

	local widget = self.mRootWidget:getChildByName(string.format("Panel_Day_%d",index))
	widget:getChildByName("Image_Gotten"):setVisible(true)
	widget:setTouchEnabled(false)
	widget:getChildren()[1]:setTouchEnabled(false)
	widget:getChildByName("Panel_Item"):getChildren()[1]:setTouchEnabled(true)
	widget:getChildByName("Image_Bg"):loadTexture("welfare_schedule_item_bg1.png",1)
	widget:getChildByName("Image_VIP_Double"):setVisible(false)

	local obj = self.mModel.mRewardInfoList[index]

	if obj.mMagicNum == 1 then
		if obj.mVipLevel ~= INVALID_VALUE then
			widget:getChildByName("Image_Again"):setVisible(true)
			widget:getChildByName("Image_Again"):loadTexture(string.format("welfare_schedule_again_vip_%d.png",obj.mVipLevel),1)
		end
	else
		widget:getChildByName("Image_Again"):setVisible(false)
	end

	self.mRootWidget:getChildByName("Label_MonthTimes"):setString(string.format("本月已经签到%d次",self.mModel.mTotalGotCnt))
end

function DailyRewardWindow:UpdateLoginRewardLayout()
	for i=1,7 do
		local panel = self.mRootWidget:getChildByName(string.format("Panel_Day%d",i))
		local getStaus = self.mModel.mLoginRewardArr[i].getStaus

		panel:getChildByName("Button_Get"):setTag(i)

		if 0 == getStaus then 	 --已经领取
			panel:getChildByName("Image_Got"):setVisible(true) 
		elseif 1 == getStaus then --不可领取
			panel:getChildByName("Button_Get"):setVisible(false)
			panel:getChildByName("Image_Day_Bg1"):setVisible(true)
		elseif 2 == getStaus then --可领取
			panel:getChildByName("Button_Get"):setVisible(true)
			panel:getChildByName("Image_Got"):setVisible(false)
			panel:getChildByName("Image_Day_Bg1"):setVisible(false)
			registerWidgetReleaseUpEvent(panel:getChildByName("Button_Get"),function(widget) self.mModel:doGetLoginRewardRequest(widget:getTag()) end)
		end

		panel:getChildByName("Image_Bg"):loadTexture(self.mModel.mLoginCnt == i and "welfare_dailyrewards_bar_bg2.png" or "welfare_dailyrewards_bar_bg1.png",1)

		for j=1,#self.mModel.mLoginRewardArr[i].rewardInfoArr do
			local rewardPanel = panel:getChildByName(string.format("Panel_Reward_%d",j))
			local rewardInfo  = self.mModel.mLoginRewardArr[i].rewardInfoArr[j]
			local srcWidget   = rewardPanel:getChildren()[1]
			local widget      = createCommonWidget(rewardInfo[1],rewardInfo[2],rewardInfo[3],srcWidget)
			widget:setTouchSwallowed(false)
			widget:setTouchEnabled(true)
			rewardPanel:addChild(widget)
		end
	end

	self.mRootWidget:getChildByName("ScrollView_Dailyrewards"):setVisible(true)
	self.mRootWidget:getChildByName("Image_Today_Day"):loadTexture(string.format("welfare_dailyrewards_day_%d.png",self.mModel.mLoginCnt),1)
end

function DailyRewardWindow:NotifyGetReward(panelIndex)
	local itemlist = self.mModel.mLoginRewardArr[panelIndex].rewardInfoArr

	MessageBox:showMessageBox_ItemAlreadyGot(itemlist)
	local panel = self.mRootWidget:getChildByName(string.format("Panel_Day%d",panelIndex))
	panel:getChildByName("Button_Get"):setVisible(false)
	panel:getChildByName("Image_Got"):setVisible(true) 
	panel:getChildByName("Image_Bg"):loadTexture("welfare_dailyrewards_bar_bg1.png",1)
	--self.mRootWidget:getChildByName("Image_Today_Day"):loadTexture(string.format("welfare_dailyrewards_day_%d.png",self.mModel.mLoginCnt))
end

function DailyRewardWindow:Destroy()
	for i=1,#self.mAnimArr do
		if self.mAnimArr[i] ~= nil then
			self.mAnimArr[i]:destroy()
			self.mAnimArr[i] = nil
		end
	end

	for i=1,31 do
		self.mRootWidget:getChildByName(string.format( "Panel_Day_%d",i)):removeAllChildren()
	end

	for i=1,7 do
		local panel = self.mRootWidget:getChildByName(string.format("Panel_Day%d",i))		
		for j=1,4 do
			local rewardPanel = panel:getChildByName(string.format("Panel_Reward_%d",j))
			rewardPanel:removeAllChildren()
		end
	end

	if self.mVipListView ~= nil then
		self.mVipListView:removeAllItems()
		self.mVipListView = nil
	end

	if self.mLRlst ~= nil then
		self.mLRlst:removeAllItems()
		self.mLRlst = nil
	end


	if self.mTopRoleInfoPanel ~= nil then
		self.mTopRoleInfoPanel:destroy()
		self.mTopRoleInfoPanel = nil
	end

	self.mLastClickedOptionWidget = nil
	self.mVipGiftWidgetList = {}
	self.mWinArr			= {}

	GUIEventManager:unregister("roleBaseInfoChanged", self.updateVipGiftInfo)

	self.mRootWidget = nil

	if self.mRootNode ~= nil then
		self.mRootNode:removeFromParent(true)
		self.mRootNode 		   = nil
	end

	self.mModel:destroyInstance()
	CommonAnimation.clearAllTextures()
end

function DailyRewardWindow:onEventHandler(event)
	if event.mAction == Event.WINDOW_SHOW then
		GUIWidgetPool:preLoadWidget("Welfare_Schedule_Widget", true)
		GUIWidgetPool:preLoadWidget("Welfare_VIP_Package_Cell", true)
		self:Load()
		---------停止画主城镇界面
		EventSystem:PushEvent(Event.GUISYSTEM_DISABLEDRAW_HOMEWINDOW)
		---------
		NoticeSystem:doSingleUpdate(self.mName)
	elseif event.mAction == Event.WINDOW_HIDE then
		GUIWidgetPool:preLoadWidget("Welfare_Schedule_Widget", false)
		GUIWidgetPool:preLoadWidget("Welfare_VIP_Package_Cell", false)
		self:Destroy()
		---------开启画主城镇界面
		EventSystem:PushEvent(Event.GUISYSTEM_EABLEDRAW_HOMEWINDOW)
		---------
	end
end

return DailyRewardWindow