-- Name: 	LadderWindow
-- Func：	制霸之战
-- Author:	lichuan
-- Data:	15-8-28

local BATTLE_SINGLE_TAG = 2304
local BATTLE_MULTI_TAG  = 2323

local SLIDE_FADEIN      = 1
local SLIDE_FADEOUT     = 0

local WIN_FORWARD	    = 1
local WIN_BACKWARD      = 0
local WIN_EXIT	        = 2

local LMInstance = nil	

LadderModel = class("LadderModel")

function LadderModel:ctor()
	self.mName          = "LadderModel"
	self.mOwner         = nil
	self.mWinData       = nil

	self.mBattleType          = nil  --useless
	self.mSingleWinCnt        = 0 
	self.mSingleFailCnt	      = 0
	self.mSingleOpenBeginTime = 0
	self.mSingleOpenEndTime	  = 0
	self.mSingleCloseSec	  = 0
	self.mSingleLeftCnt		  = 0
	self.mSingleTotalCnt	  = 0
	self.mSingleScore		  = 0
	self.mSingleRank          = 0
	self.mSingleSettleStr     = ""

	self.mBattleHeroIds 	  = {0,0,0}

	self.mBattleType1		  = nil  --useless	
	self.mMultiWinCnt         = 0 
	self.mMultiFailCnt	      = 0
	self.mMultiOpenBeginTime  = 0
	self.mMultiOpenEndTime	  = 0
	self.mMultiCloseSec	      = 0
	self.mMultiLeftCnt		  = 0
	self.mMultiTotalCnt	      = 0
	self.mMultiScore		  = 0
	self.mMultiRank           = 0
	self.mMultiSettleStr	  = ""

	self.mIsSearching		  = false

	self.mBattleHeroId       = 0

	-- 数据结构
	-- 结构体： level = {LadderAwardData,LadderAwardData,LadderAwardData}
	self.mAwardDataMap        = {}

	self.mRewardArr			  = {{},{},{}}

	for i=1,2 do
		for j=1,17 do
			self.mRewardArr[i][18 - j] = {}
			local data = ((i == 1 and DB_pvprewards1v1.getDataById(j)) or DB_pvprewards3v3.getDataById(j))

			for k=1,3 do
				self.mRewardArr[i][18 - j][k] = {}
				self.mRewardArr[i][18 - j][k][1] = data[string.format("Reward%d",k)][1]
				self.mRewardArr[i][18 - j][k][2] = data[string.format("Reward%d",k)][2]
				self.mRewardArr[i][18 - j][k][3] = data[string.format("Reward%d",k)][3]
			end
			self.mRewardArr[i][18 - j][4] = data.Name
			self.mRewardArr[i][18 - j][5] = data.Minscore
			self.mRewardArr[i][18 - j][6] = data.Maxscore
		end
	end

	for i=1,100 do
		local data = DB_rankrewards3v3.getDataById(i)
		self.mRewardArr[3][i] = {}
		for j=1,3 do
			self.mRewardArr[3][i][j] = {}
			self.mRewardArr[3][i][j][1] = data[string.format("Reward%d",j)][1]
			self.mRewardArr[3][i][j][2] = data[string.format("Reward%d",j)][2]
			self.mRewardArr[3][i][j][3] = data[string.format("Reward%d",j)][3]
		end
	end



	self:registerNetEvent()
end

function LadderModel:deinit()
	self.mName  			  = nil
	self.mOwner 			  = nil
	self.mWinData             = nil
	self.mBattleType          = nil  --useless
	self.mSingleWinCnt        = 0 
	self.mSingleFailCnt	      = 0
	self.mSingleOpenBeginTime = 0
	self.mSingleOpenEndTime	  = 0
	self.mSingleCloseSec	  = 0
	self.mSingleLeftCnt		  = 0
	self.mSingleTotalCnt	  = 0
	self.mSingleScore		  = 0
	self.mSingleRank          = 0
	self.mSingleSettleStr     = nil

	self.mBattleHeroIds 	  = {0,0,0}

	self.mBattleType1		  = nil  --useless	
	self.mMultiWinCnt         = 0 
	self.mMultiFailCnt	      = 0
	self.mMultiOpenBeginTime  = 0
	self.mMultiOpenEndTime	  = 0
	self.mMultiCloseSec	      = 0
	self.mMultiLeftCnt		  = 0
	self.mMultiTotalCnt	      = 0
	self.mMultiScore		  = 0
	self.mMultiRank           = 0
	self.mMultiSettleStr	  = nil

	self.mBattleHeroId       = 0

	self:unRegisterNetEvent()
end

function LadderModel:getInstance()
	if LMInstance == nil then  
        LMInstance = LadderModel.new()
    end  
    return LMInstance
end

function LadderModel:destroyInstance()
	if LMInstance then
		LMInstance:deinit()
    	LMInstance = nil
    end
end

function LadderModel:registerNetEvent()
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_REQUEST_LADDER_INFO_, handler(self, self.onLadderInfoResponse))
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_REQUEST_LADDER_AWARDINFO_, handler(self, self.onLoadMedalInfoResponse))
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_BUY_LADDERINFO_RESPONSE_, handler(self, self.onLoadLadderCntPriceResponse))
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_BUY_LADDERCNT_RESPONSE_, handler(self, self.onBuyLadderCntResponse))
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_ENTER_LADDER_RESPONSE_, handler(self, self.onEnterLadderResponse))
end

function LadderModel:unRegisterNetEvent()
	NetSystem.mNetManager:UnregisterPacketHandler(PacketTyper._PTYPE_SC_REQUEST_LADDER_INFO_)
	NetSystem.mNetManager:UnregisterPacketHandler(PacketTyper._PTYPE_SC_REQUEST_LADDER_AWARDINFO_)
	NetSystem.mNetManager:UnregisterPacketHandler(PacketTyper._PTYPE_SC_BUY_LADDERINFO_RESPONSE_)
	NetSystem.mNetManager:UnregisterPacketHandler(PacketTyper._PTYPE_SC_BUY_LADDERCNT_RESPONSE_)
	NetSystem.mNetManager:UnregisterPacketHandler(PacketTyper._PTYPE_SC_ENTER_LADDER_RESPONSE_)
end

function LadderModel:setOwner(owner)
	self.mOwner = owner
end

function LadderModel:doLoadLadderInfoRequest()
	local packet = NetSystem.mNetManager:GetSPacket()
    packet:SetType(PacketTyper._PTYPE_CS_REQUEST_LADDER_INFO_)
    packet:Send()
    GUISystem:showLoading()
end

function LadderModel:onLadderInfoResponse(msgPacket)
	self.mBattleType          = msgPacket:GetChar()
	self.mSingleWinCnt        = msgPacket:GetInt() 
	self.mSingleFailCnt	      = msgPacket:GetInt() 
	self.mSingleOpenBeginTime = msgPacket:GetChar()
	self.mSingleOpenEndTime	  = msgPacket:GetChar()
	self.mSingleCloseSec	  = msgPacket:GetInt() 
	self.mSingleLeftCnt		  = msgPacket:GetChar()

	self.mSingleTotalCnt	  = msgPacket:GetChar()
	self.mSingleScore		  = msgPacket:GetInt()
	self.mSingleRank		  = msgPacket:GetInt()  
	self.mSingleSettleStr     = msgPacket:GetString() 
	self.mBattleHeroCnt       = msgPacket:GetUShort()
	
	for i=1,self.mBattleHeroCnt do
		self.mBattleHeroIds[i] = msgPacket:GetInt() 
	end

	self.mBattleType1		  = msgPacket:GetChar()	
	self.mMultiWinCnt         = msgPacket:GetInt()  
	self.mMultiFailCnt	      = msgPacket:GetInt() 
	self.mMultiOpenBeginTime  = msgPacket:GetChar()
	self.mMultiOpenEndTime	  = msgPacket:GetChar()
	self.mMultiCloseSec	      = msgPacket:GetInt() 
	self.mMultiLeftCnt		  = msgPacket:GetChar()

	self.mMultiTotalCnt	      = msgPacket:GetChar()
	self.mMultiScore		  = msgPacket:GetInt()
	self.mMultiRank   		  = msgPacket:GetInt()  
	self.mMultiSettleStr	  = msgPacket:GetString()

	local heroCnt             = msgPacket:GetUShort()
	local heroIds = {0,0,0}
	for i=1,heroCnt do
		heroIds[i]            = msgPacket:GetInt()
		if heroIds[i] ~= 0 then
			self.mBattleHeroId        = heroIds[i]
		end
	end

	GUISystem:hideLoading()

	Event.GUISYSTEM_SHOW_LADDERWINDOW.mData = self.mWinData	

	if self.mWinData ~= nil and self.mWinData[2] ~= nil then     --for offline exit
		self.mWinData[2]()
	end

	EventSystem:PushEvent(Event.GUISYSTEM_SHOW_LADDERWINDOW) 
end

function LadderModel:doSearchBattleRequest(battleType)
 	if battleType == BATTLE_SINGLE_TAG then
 		globaldata:requestOLpvp1v1(self.mOwner.mBattleHeroIds[1],self.mOwner.mBattleHeroIds[2],self.mOwner.mBattleHeroIds[3])
 	else
 		if self.mMultiLeftCnt <= 0 then MessageBox:showMessageBox1("剩余匹配次数不足") return end
 		globaldata:requestOLpvp3v3(self.mOwner.mBattleHeroId)
 	end
 	self.mIsSearching		 = true
 end 

 function LadderModel:doCancleSearchRequest()
 	self.mIsSearching		 = false
 	globaldata:cancelOLpvp()
 end

-- 请求段位奖励信息
function LadderModel:doLoadMedalInfoRequest()
	--if self.mAwardDataMap.rewardInfo ~= nil then self.mOwner:ShowDailyReward(self.mAwardDataMap) return end
	local packet = NetSystem.mNetManager:GetSPacket()
    packet:SetType(PacketTyper._PTYPE_CS_REQUEST_LADDER_AWARDINFO_)
    packet:Send()
    GUISystem:showLoading()
end

-- 段位奖励信息回复
function LadderModel:onLoadMedalInfoResponse(msgPacket)
	self.mAwardDataMap.fightCnt = msgPacket:GetInt()
	self.mAwardDataMap.winCnt   = msgPacket:GetInt()
	local rewardCnt             = msgPacket:GetUShort()

	if rewardCnt > 3 then rewardCnt = 3 end

	self.mAwardDataMap.rewardInfo = {}

	for i=1,rewardCnt do
		self.mAwardDataMap.rewardInfo[i] = {}
		self.mAwardDataMap.rewardInfo[i].canGet =  msgPacket:GetChar()
		self.mAwardDataMap.rewardInfo[i].rewards = {}

		local rewardsNum = msgPacket:GetUShort()
		for j =1,rewardsNum do
			local item       = {}
			item.mRewardType = msgPacket:GetInt()
			item.mItemId     = msgPacket:GetInt()
			item.mItemCnt    = msgPacket:GetInt()
			table.insert(self.mAwardDataMap.rewardInfo[i].rewards,item)
		end
	end

	self.mOwner:ShowDailyReward(self.mAwardDataMap)
	GUISystem:hideLoading()
end

function LadderModel:doGetRewardRequest(type)
	local packet = NetSystem.mNetManager:GetSPacket()
    packet:SetType(PacketTyper._PTYPE_CS_GETREWARD_REQUEST_)
    packet:PushChar(type)
    packet:Send()
end

function LadderModel:doLoadLadderCntPriceRequest()
	local packet = NetSystem.mNetManager:GetSPacket()
    packet:SetType(PacketTyper._PTYPE_CS_BUY_LADDERINFO_REQUEST_)
    packet:Send()
    GUISystem:showLoading()
end

function LadderModel:onLoadLadderCntPriceResponse(msgPacket)
	local price = msgPacket:GetInt()
	local count = msgPacket:GetInt()

	GUISystem:hideLoading()
	MessageBox:showMessageBoxConsume(price,count)
end

function LadderModel:onBuyLadderCntResponse(msgPacket)
	local leftCnt = msgPacket:GetInt()

	self.mMultiLeftCnt = leftCnt

	local totalCnt = msgPacket:GetInt()
	self.mOwner.mDetailPanel:getChildByName("Label_LastTimes"):setString(string.format("%d/%d",leftCnt,totalCnt))

	local bshow = nil if leftCnt > 0 then bshow = false else bshow = true end
	local buyBtn = self.mOwner.mDetailPanel:getChildByName("Button_MoreTimes")
	buyBtn:setVisible(bshow)
end

function LadderModel:doEnterLadderRequest(widget)
	self.mLastSel = widget

	local typ = ((widget:getTag() == BATTLE_SINGLE_TAG and 0) or 1)

	local packet = NetSystem.mNetManager:GetSPacket()
    packet:SetType(PacketTyper._PTYPE_CS_ENTER_LADDER_REQUEST_)
    packet:PushChar(typ)
    packet:Send()
    GUISystem:showLoading()	
end

function LadderModel:onEnterLadderResponse(msgPacket)
	GUISystem:hideLoading()
	local ret = msgPacket:GetChar()

	if ret == SUCCESS then
		self.mOwner:OnSelectBattle(self.mLastSel)
	else
		MessageBox:showMessageBox1("未到开放时间，无法进入！")
	end

end

--==========================================================TV  begin ==================================================================

RewardTableView = {}

function RewardTableView:new(owner,listType)
	local o = 
	{
		mOwner			  = owner,
		mRootNode 	      =	nil,
		mType 		      =	listType,
		mTableView	      =	nil,
		mSourceType      =  nil,
	}
	o = newObject(o, RewardTableView)
	return o
end

function RewardTableView:Destroy()
	self.mRootNode:removeFromParent(true)
	self.mRootNode     = nil
	self.mTableView    = nil
	self.mOwner        = nil
	self.mSourceType   = nil
end

function RewardTableView:SetSourceType(typ)
	self.mSourceType   = typ

	self:UpdateTableView(#self.mOwner.mModel.mRewardArr[self.mSourceType])
end

function RewardTableView:myModel()
	return self.mOwner.mModel
end

function RewardTableView:init(rootNode)
	self.mRootNode = rootNode
	-- 初始化数据源
	--self:myModel():doLoadDataRequest(PacketTyper._PTYPE_CS_REQUEST_FRIEND_LIST_,nil)
	self:initTableView()
end

function RewardTableView:initTableView()
	self.mTableView = TableViewEx:new()

	local widget = GUIWidgetPool:createWidget("Tianti_RewardCell")

	self.mTableView:setCellSize(widget:getContentSize())
	self.mTableView:setCellCount(8)

	self.mTableView:registerTableCellAtIndexFunc(handler(self, self.tableCellAtIndex))
	self.mTableView:registerTableCellTouchedFunc(handler(self, self.tableCellTouched))

	self.mTableView:init(self.mRootNode:getContentSize(), cc.p(0,0), 1)
	self.mRootNode:addChild(self.mTableView:getRootNode())
end

function RewardTableView:tableCellAtIndex(table, index)
	local cell = table:dequeueCell()
	local rewardItem = nil

	if nil == cell then
		cell = cc.TableViewCell:new()
		rewardItem = GUIWidgetPool:createWidget("Tianti_RewardCell")
		rewardItem:getChildByName("Panel_Reward"):setTouchEnabled(false)
		rewardItem:setTouchSwallowed(false)
		rewardItem:setTag(1)
		cell:addChild(rewardItem)
	else
		rewardItem = cell:getChildByTag(1)
	end

	--if #self:myModel().mMsgdeque ~= 0 then
		self:setCellLayOut(rewardItem,index)
	--end
	
	return cell
end

function RewardTableView:setCellLayOut(widget,index)
	local rewardArr = self.mOwner.mModel.mRewardArr[self.mSourceType][index + 1]

	if self.mSourceType == 3 then
		widget:getChildByName("Label_Ranking_Stroke"):setString(tostring(index + 1))
		widget:getChildByName("Panel_Badge"):setVisible(false)
		widget:getChildByName("Panel_Ranking"):setVisible(true)
	else
		local desData = DB_Text.getDataById(rewardArr[4])
		local descStr = desData.Text_CN
		widget:getChildByName("Label_Badge_Stroke"):setString(descStr)
		if index == 0 then
			widget:getChildByName("Label_Integral"):setString(string.format("%d分以上",rewardArr[5]))
		else
			widget:getChildByName("Label_Integral"):setString(string.format("%d分-%d 分",rewardArr[5],rewardArr[6]))
		end
		setMedalLayout(rewardArr[5],widget:getChildByName("Panel_Badge"),self.mSourceType - 1)
		widget:getChildByName("Panel_Badge"):setVisible(true)
		widget:getChildByName("Panel_Ranking"):setVisible(false)
	end

	for i=1,3 do
		local panelReward = widget:getChildByName(string.format("Panel_Reward_%d",i)):getChildByName("Panel_Reward")
		panelReward:removeAllChildren()
		panelReward:setVisible(true)
		panelReward:setTouchSwallowed(false)

		if rewardArr[i][3] ~= 0 then
			local rewardWidget = createCommonWidget(rewardArr[i][1],rewardArr[i][2],rewardArr[i][3])
			visibleOnlyImg(rewardWidget)
			rewardWidget:setTouchSwallowed(false)
			widget:getChildByName(string.format("Panel_Reward_%d",i)):getChildByName("Label_Num"):setString(tostring(rewardArr[i][3]))
			panelReward:addChild(rewardWidget)
		else
			widget:getChildByName(string.format("Panel_Reward_%d",i)):getChildByName("Label_Num"):setVisible(false)
		end
	end
end

function RewardTableView:tableCellTouched(table,cell)
	print("RewardTableView cell touched at index: " .. cell:getIdx())

end

function RewardTableView:UpdateTableView(cellCnt) --move table to cur cell after reload
	if self.mTableView == nil then return end 
	self.mTableView:setCellCount(cellCnt)

	--local curOffset = self.mTableView.mInnerContainer:getContentOffset()
	--local curHeight = self.mTableView.mInnerContainer:getContentSize().height
	self.mTableView:reloadData()
	--self.mTableView.mInnerContainer:setContentOffset(cc.p(0,self.mTableView.mInnerContainer:getViewSize().height - self.mTableView.mInnerContainer:getContentSize().height))
	--local height = self.mTableView.mInnerContainer:getContentSize().height
	--curOffset.y = curOffset.y + (curHeight - height)
	--self.mTableView.mInnerContainer:setContentOffset(curOffset)
end

--==========================================================window  begin ==================================================================

local LadderWindow = 
{
	mName                = "LadderWindow",
	mRootNode            = nil,
	mRootWidget          = nil,
	mTopRoleInfoPanel    = nil,
	mModel               = nil,
	mSelectPanel         = nil,
	mDetailPanel         = nil,

	mExistHeroIcons 	 = {},

	mBattleHeroIcons     = {},
	mBattleHeroIcon      = nil,

	mBattleHeroIds       = {0,0,0},
	mBattleHeroId 		 = 0, 

	mBattleType          = nil,
	mTipSchedulerHandler = nil,

	mTotalCombat         = 0,
	mCountDownScheduler  = nil,

	mData                = nil,
	------------------------------------
	mAnimNode1			=	nil,
	mAnimNode2			=	nil,

	mCancelType         = nil,
}

function LadderWindow:Load(event)
	cclog("=====LadderWindow:Load=====begin")

	-- 播所属城镇bgm
	HallManager:playHallBGMAfterDestroyed()

	self.mData  = event.mData

	self.mRootNode = cc.Node:create()
	GUISystem:GetRootNode():addChild(self.mRootNode)

	self.mModel = LadderModel:getInstance()
	self.mModel:setOwner(self)

	self:InitLayout(event)

	local function doTiantiGuideOne_Step2()
		local guideBtn = self.mRootWidget:getChildByName("Panel_1V1"):getChildByName("Button_Enter")
		local size = guideBtn:getContentSize()
		local pos = guideBtn:getWorldPosition()
		pos.x = pos.x - size.width/2
		pos.y = pos.y - size.height/2
		local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
		TiantiGuideOne:step(2, touchRect)
	end
	TiantiGuideOne:step(1, nil, doTiantiGuideOne_Step2)

	cclog("=====LadderWindow:Load=====end")
end

function LadderWindow:InitLayout(event)
	if self.mRootWidget == nil then
		self.mRootWidget = GUIWidgetPool:createWidget("Tianti_Main")
		self.mRootNode:addChild(self.mRootWidget)
	end

	if self.mTopRoleInfoPanel == nil then
		cclog("LadderWindow mTopRoleInfoPanel init")
		self.mTopRoleInfoPanel = TopRoleInfoPanel:new()
		self.mTopRoleInfoPanel:init(self.mRootNode, ROLE_TITLE_TYPE.TITLE_LADDER,
		function()
			GUISystem:playSound("homeBtnSound")		
			self:SelectPanelAnimation(SLIDE_FADEOUT,WIN_EXIT)	
		end)
	end

	self.mSelectPanel = self.mRootWidget:getChildByName("Panel_Main")
	self.mDetailPanel = self.mRootWidget:getChildByName("Panel_VS")

	local topSize = self.mTopRoleInfoPanel.mTopWidget:getContentSize()
	local y = getGoldFightPosition_Middle().y - topSize.height / 2
	local x = getGoldFightPosition_Middle().x

	self.mSelectPanel:setAnchorPoint(0.5,0.5)
	self.mSelectPanel:setPosition(cc.p(x,y))
	self.mDetailPanel:setAnchorPoint(0.5,0.5)
	self.mDetailPanel:setPosition(cc.p(x,y))

	self.mSelectPanel:setVisible(true)
	self.mDetailPanel:setVisible(false)

	GUISystem:disableUserInput()
	self:SelectPanelAnimation(SLIDE_FADEIN,WIN_FORWARD)

	registerWidgetReleaseUpEvent(self.mSelectPanel:getChildByName("Panel_1V1"):getChildByName("Button_Enter"),
		function(widget) self.mModel:doEnterLadderRequest(widget) end)
	registerWidgetReleaseUpEvent(self.mSelectPanel:getChildByName("Panel_3V3"):getChildByName("Button_Enter"),
		function(widget) self.mModel:doEnterLadderRequest(widget) end)

	if not self.mTipSchedulerHandler then
		self.mTipSchedulerHandler = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self, self.UpdateTimeLine), 1, false)
	end

	if self.mModel.mSingleLeftCnt < 0 then self.mModel.mSingleLeftCnt = 0 end
	self.mSelectPanel:getChildByName("Panel_1V1"):getChildByName("Label_CombatGains"):
	setString(string.format("%d 胜  %d 负",self.mModel.mSingleWinCnt,self.mModel.mSingleFailCnt))
	--self.mSelectPanel:getChildByName("Panel_1V1"):getChildByName("Label_LastTimes"):
	--setString(string.format("剩余次数：%d/%d",self.mModel.mSingleLeftCnt,self.mModel.mSingleTotalCnt))
	self.mSelectPanel:getChildByName("Panel_1V1"):getChildByName("Label_OpenTime"):
	setString(string.format("今日  %d:00 ~ %d:00 开放",self.mModel.mSingleOpenBeginTime,self.mModel.mSingleOpenEndTime))	

	if self.mModel.mMultiLeftCnt < 0 then self.mModel.mMultiLeftCnt = 0 end
	self.mSelectPanel:getChildByName("Panel_3V3"):getChildByName("Label_CombatGains"):
	setString(string.format("%d 胜  %d 负",self.mModel.mMultiWinCnt,self.mModel.mMultiFailCnt))
	self.mSelectPanel:getChildByName("Panel_3V3"):getChildByName("Label_LastTimes"):
	setString(string.format("剩余次数：%d/%d",self.mModel.mMultiLeftCnt,self.mModel.mMultiTotalCnt))
	self.mSelectPanel:getChildByName("Panel_3V3"):getChildByName("Label_OpenTime"):
	setString(string.format("今日  %d:00 ~ %d:00 开放",self.mModel.mMultiOpenBeginTime,self.mModel.mMultiOpenEndTime))

	self.mBattleHeroIds = self.mModel.mBattleHeroIds
	self.mBattleHeroId  = self.mModel.mBattleHeroId

	self:initAnimation()
end

-- 添加特效
function LadderWindow:initAnimation()
	self.mAnimNode1 = AnimManager:createAnimNode(8007)
	self.mRootWidget:getChildByName("Panel_1V1"):getChildByName("Panel_Card_Animation"):addChild(self.mAnimNode1:getRootNode(), 100)
	self.mAnimNode1:play("tianti_1v1_card", true)

	self.mAnimNode2 = AnimManager:createAnimNode(8008)
	self.mRootWidget:getChildByName("Panel_3V3"):getChildByName("Panel_Card_Animation"):addChild(self.mAnimNode2:getRootNode(), 100)
	self.mAnimNode2:play("tianti_3v3_card", true)
end

-- 删除特效
function LadderWindow:destroyAnimation()
	if self.mAnimNode1 ~= nil then
		self.mAnimNode1:destroy()
		self.mAnimNode1 = nil
	end

	if self.mAnimNode2 ~= nil then
		self.mAnimNode2:destroy()
		self.mAnimNode2 = nil
	end

end

function LadderWindow:InitHeroIcon()
	if #self.mExistHeroIcons == 0 then
		local allHeroIdTbl = {}

		for k, v in pairs(globaldata.heroTeam) do
			table.insert(allHeroIdTbl, v.id)
		end
		-- 根据战力排序
		local function sortFunc(id1, id2)
			local heroObj1 = globaldata:findHeroById(id1)
			local heroObj2 = globaldata:findHeroById(id2)
			return heroObj1.combat > heroObj2.combat
		end
		table.sort(allHeroIdTbl, sortFunc)

		for i=1,#allHeroIdTbl do		
			local heroObj  = globaldata:findHeroById(allHeroIdTbl[i])
			local heroIcon = createHeroIcon(heroObj.id, heroObj.level, heroObj.quality, heroObj.advanceLevel)

			heroIcon:setTouchEnabled(true)
			heroIcon:setTag(allHeroIdTbl[i])
			self.mDetailPanel:getChildByName("ListView_HeroList"):pushBackCustomItem(heroIcon)
			registerWidgetReleaseUpEvent(heroIcon, handler(self,self.OnSelectHero))

			table.insert(self.mExistHeroIcons,heroIcon)			
		end
	end

	if #self.mBattleHeroIcons == 0 then
		local panel1V1 = self.mDetailPanel:getChildByName("Panel_VS_Window"):getChildByName("Panel_1V1")

		for i=1,#self.mBattleHeroIds do
			if self.mBattleHeroIds[i] ~= 0 then 
				local heroObj = globaldata:findHeroById(self.mBattleHeroIds[i])
				self.mBattleHeroIcons[i] = createHeroIcon(heroObj.id, heroObj.level, heroObj.quality, heroObj.advanceLevel)
				self.mBattleHeroIcons[i]:setTouchEnabled(true)
				self.mBattleHeroIcons[i]:setTag(self.mBattleHeroIds[i])
				registerWidgetReleaseUpEvent(self.mBattleHeroIcons[i], handler(self,self.OnDisSelectHero))

				local panelHero = panel1V1:getChildByName("Panel_Hero_"..tostring(i))
				panelHero:getChildByName("Panel_HeroIcon"):addChild(self.mBattleHeroIcons[i])
				panelHero:getChildByName("Label_Zhanli"):setString(tostring(heroObj.combat))

				self.mTotalCombat = self.mTotalCombat + heroObj.combat
			end
		end
		panel1V1:getChildByName("Label_Totle_Zhanli_Stroke"):setString(string.format("总战力 %d",self.mTotalCombat))
	end

	if self.mBattleHeroIcon == nil then
		if self.mBattleHeroId ~= 0 then
			local heroObj = globaldata:findHeroById(self.mBattleHeroId)
			self.mBattleHeroIcon = createHeroIcon(heroObj.id, heroObj.level, heroObj.quality, heroObj.advanceLevel)
			self.mBattleHeroIcon:setTouchEnabled(true)
			self.mBattleHeroIcon:setTag(self.mBattleHeroId)
			registerWidgetReleaseUpEvent(self.mBattleHeroIcon, handler(self,self.OnDisSelectHero))

			local panelHero = self.mDetailPanel:getChildByName("Panel_VS_Window"):getChildByName("Panel_3V3"):getChildByName("Panel_Player")
			panelHero:getChildByName("Panel_HeroIcon"):addChild(self.mBattleHeroIcon)
			panelHero:getChildByName("Label_Zhanli"):setString(tostring(heroObj.combat))
		end
	end	

	for i=1,#self.mExistHeroIcons do
		if self.mExistHeroIcons[i] ~= nil then
			if self:isHeroInBattle(self.mExistHeroIcons[i]:getTag()) then
				self.mExistHeroIcons[i]:getChildByName("Image_HeroChosen"):setVisible(true)
			else
				self.mExistHeroIcons[i]:getChildByName("Image_HeroChosen"):setVisible(false)
			end
		end
	end
end

-- 获取阵容上英雄的数量
function LadderWindow:getBattleHeroCount()
	if self.mBattleType == BATTLE_SINGLE_TAG then
		local cnt = 0
		for i = 1, #self.mBattleHeroIds do
			if 0 ~= self.mBattleHeroIds[i] then
				cnt = cnt + 1
			end
		end
		return cnt
	else
		if self.mBattleHeroId == 0 then return 0 else return 1 end
	end
end

function LadderWindow:isHeroInBattle(id)
	if self.mBattleType == BATTLE_SINGLE_TAG then
		for i = 1, #self.mBattleHeroIds do
			if id == self.mBattleHeroIds[i] then
				return true
			end
		end
		return false
	else
		if self.mBattleHeroId == id then return true else return false end
	end
end

function LadderWindow:OnSelectHero(widget)
	if self.mModel.mIsSearching == true then return end
	local heroId = widget:getTag()

	local iconContainer = nil
	if self.mBattleType == BATTLE_SINGLE_TAG then
		iconContainer = self.mDetailPanel:getChildByName("Panel_VS_Window"):getChildByName("Panel_1V1")	
	else
		iconContainer = self.mDetailPanel:getChildByName("Panel_VS_Window"):getChildByName("Panel_3V3")
	end

	if not self:isHeroInBattle(heroId) then
		if self.mBattleType == BATTLE_SINGLE_TAG then

			if self:getBattleHeroCount() >= 3 then
				--MessageBox:showMessageBox1("上阵英雄已经满足三人~")
				return
			end

			for i = 1, #self.mBattleHeroIds do
				if 0 == self.mBattleHeroIds[i] then -- 此处是空位
					-- 记住id
					self.mBattleHeroIds[i] = heroId
					-- 创建控件
					local heroObj = globaldata:findHeroById(heroId)
					self.mBattleHeroIcons[i] = createHeroIcon(heroObj.id, heroObj.level, heroObj.quality, heroObj.advanceLevel)
					self.mBattleHeroIcons[i]:setTouchEnabled(true)
					self.mBattleHeroIcons[i]:setTag(heroId)

					iconContainer:getChildByName("Panel_Hero_"..tostring(i)):getChildByName("Panel_HeroIcon"):addChild(self.mBattleHeroIcons[i])
					iconContainer:getChildByName("Panel_Hero_"..tostring(i)):getChildByName("Label_Zhanli"):setString(tostring(heroObj.combat))
					-- 播放特效
					local animNode = AnimManager:createAnimNode(8001)
					iconContainer:getChildByName("Panel_Hero_"..tostring(i)):addChild(animNode:getRootNode(), 100)
					animNode:setPosition(cc.p(45, 32))
					animNode:play("fightteam_cell_chose1")

					widget:getChildByName("Image_HeroChosen"):setVisible(true)
					registerWidgetReleaseUpEvent(self.mBattleHeroIcons[i], handler(self,self.OnDisSelectHero))

					-- 播放特效
					animNode = AnimManager:createAnimNode(8001)
					widget:getChildByName("Panel_Animation"):addChild(animNode:getRootNode(), 100)
					animNode:play("fightteam_cell_chose2")

					self.mTotalCombat = self.mTotalCombat + heroObj.combat
					local panel1V1 = self.mDetailPanel:getChildByName("Panel_VS_Window"):getChildByName("Panel_1V1")
					panel1V1:getChildByName("Label_Totle_Zhanli_Stroke"):setString(string.format("总战力 %d",self.mTotalCombat))

					return 
				end
			end
		else
			if self:getBattleHeroCount() >= 1 then
				--MessageBox:showMessageBox1("上阵英雄已经满足三人~")
				return
			end

			self.mBattleHeroId = heroId

			local heroObj = globaldata:findHeroById(heroId)
			self.mBattleHeroIcon = createHeroIcon(heroObj.id, heroObj.level, heroObj.quality, heroObj.advanceLevel)
			self.mBattleHeroIcon:setTouchEnabled(true)
			self.mBattleHeroIcon:setTag(heroId)

			local animNode = AnimManager:createAnimNode(8001)
			iconContainer:getChildByName("Panel_Player"):addChild(animNode:getRootNode(), 100)
			animNode:setPosition(cc.p(45, 32))
			animNode:play("fightteam_cell_chose1")

			iconContainer:getChildByName("Panel_Player"):getChildByName("Panel_HeroIcon"):addChild(self.mBattleHeroIcon)
			iconContainer:getChildByName("Panel_Player"):getChildByName("Label_Zhanli"):setString(tostring(heroObj.combat))	
			widget:getChildByName("Image_HeroChosen"):setVisible(true)

			-- 播放特效
			animNode = AnimManager:createAnimNode(8001)
			widget:getChildByName("Panel_Animation"):addChild(animNode:getRootNode(), 100)
			animNode:play("fightteam_cell_chose2")
			registerWidgetReleaseUpEvent(self.mBattleHeroIcon, handler(self,self.OnDisSelectHero))
		end
	else
		self:OnDisSelectHero(widget)
	end	
end

function LadderWindow:OnDisSelectHero(widget)
	if self.mModel.mIsSearching == true then return end
	-- 去掉阵上英雄
	local heroId = widget:getTag()
	local iconContainer = nil
	
	if self.mBattleType == BATTLE_SINGLE_TAG then
		iconContainer = self.mDetailPanel:getChildByName("Panel_VS_Window"):getChildByName("Panel_1V1")
		
		-- 去掉阵上id和控件
		for i = 1, #self.mBattleHeroIds do
			if self.mBattleHeroIds[i] == heroId then
				self.mBattleHeroIds[i] = 0

				self.mBattleHeroIcons[i]:removeFromParent(true)
				self.mBattleHeroIcons[i] = nil

				iconContainer:getChildByName(string.format("Panel_Hero_%d",i)):getChildByName("Label_Zhanli"):setString("0")
				-- 播放特效
				local animNode = AnimManager:createAnimNode(8001)
				iconContainer:getChildByName("Panel_Hero_"..tostring(i)):addChild(animNode:getRootNode(), 100)
				animNode:setPosition(cc.p(45, 32))
				animNode:play("fightteam_cell_chose2")
			end
		end

		local heroObj = globaldata:findHeroById(heroId)
		self.mTotalCombat = self.mTotalCombat - heroObj.combat
		iconContainer:getChildByName("Label_Totle_Zhanli_Stroke"):setString(string.format("总战力 %d",self.mTotalCombat))
	else
		iconContainer = self.mDetailPanel:getChildByName("Panel_VS_Window"):getChildByName("Panel_3V3")
		self.mBattleHeroId = 0
		if self.mBattleHeroIcon ~= nil then
			self.mBattleHeroIcon:removeFromParent(true)
			self.mBattleHeroIcon = nil
			local animNode = AnimManager:createAnimNode(8001)
			iconContainer:getChildByName("Panel_Player"):addChild(animNode:getRootNode(), 100)
			animNode:setPosition(cc.p(45, 32))
			animNode:play("fightteam_cell_chose2")
		end
	end

	for i = 1, #self.mExistHeroIcons do
		if self.mExistHeroIcons[i]:getTag() == heroId then
			self.mExistHeroIcons[i]:getChildByName("Image_HeroChosen"):setVisible(false)
			-- 播放特效
			animNode = AnimManager:createAnimNode(8001)
			self.mExistHeroIcons[i]:getChildByName("Panel_Animation"):addChild(animNode:getRootNode(), 100)
			animNode:play("fightteam_cell_chose2")
			break 
		end
	end
end

function LadderWindow:UpdateTimeLine()
	if self.mModel == nil then return end

	local function secondToHour(seconds)
		local hour = math.floor(seconds / 3600)
		seconds = math.mod(seconds, 3600)
		local min = math.floor(seconds / 60)
		seconds = math.mod(seconds, 60)
		local sec = seconds
		return string.format("%02d:%02d:%02d",hour,min,sec)
	end

	if self.mModel.mSingleCloseSec ~= nil then 
		self.mModel.mSingleCloseSec = self.mModel.mSingleCloseSec - 1
		self.mModel.mMultiCloseSec  = self.mModel.mMultiCloseSec - 1

		if self.mModel.mSingleCloseSec < 0 then self.mModel.mSingleCloseSec = 0 end
		if self.mModel.mMultiCloseSec < 0 then self.mModel.mMultiCloseSec = 0 end
	
		if self.mSelectPanel ~= nil then
			self.mSelectPanel:getChildByName("Panel_1V1"):getChildByName("Label_SettlementTime"):
			setString(string.format("距离结算  %s",secondToHour(self.mModel.mSingleCloseSec)))
			self.mSelectPanel:getChildByName("Panel_3V3"):getChildByName("Label_SettlementTime"):
			setString(string.format("距离结算  %s",secondToHour(self.mModel.mMultiCloseSec)))
		end
	end
end

function LadderWindow:SelectPanelAnimation(inORout,direction)  --inORout 1 in 0 out direction 1 forward 0 backward 2 exit
	local singlePanel     = self.mSelectPanel:getChildByName("Panel_1V1")
	local multiPanel      = self.mSelectPanel:getChildByName("Panel_3V3")

	local singlePanelPos  = cc.p(singlePanel:getPosition())
	local singlePanelSize = singlePanel:getContentSize()

	local multiPanelPos   = cc.p(multiPanel:getPosition())
	local multiPanelSize  = multiPanel:getContentSize()

	local function SlideFadeIn()
		local singleBtn = self.mSelectPanel:getChildByName("Panel_1V1"):getChildByName("Button_Enter")
		local multiBtn  = self.mSelectPanel:getChildByName("Panel_3V3"):getChildByName("Button_Enter")

		singlePanel:setOpacity(0)
		multiPanel:setOpacity(0)

		local function runBeginSingle()
			GUISystem:disableUserInput()
			singleBtn:setTouchEnabled(false)
			multiBtn:setTouchEnabled(false)	
			singlePanel:setPositionX(VisibleRect:left().x - singlePanelSize.width)			
		end

		local function runBeginMulti()
			multiPanel:setPositionX(VisibleRect:right().x)
		end

		local function runEndSingle()
			singlePanel:setPosition(singlePanelPos)	
			singleBtn:setTouchEnabled(true)
			GUISystem:enableUserInput()
		end

		local function runEndMulti()
			multiPanel:setPosition(multiPanelPos)
			multiBtn:setTouchEnabled(true)		
			GUISystem:enableUserInput()
		end

		local actBeginSingle = cc.CallFunc:create(runBeginSingle)
		local actBeginMulti	 = cc.CallFunc:create(runBeginMulti)
		local actMoveSingle  = cc.MoveTo:create(0.2, singlePanelPos)
		local actMoveMulti   = cc.MoveTo:create(0.2, multiPanelPos)
		local actFadeSingle  = cc.FadeIn:create(0.2)
		local actFadeMulti   = cc.FadeIn:create(0.2)
		local actSpawnSingle = cc.Spawn:create(actMoveSingle,actFadeSingle)
		local actSpawnMulti  = cc.Spawn:create(actMoveMulti,actFadeMulti)

		local actEndSingle   = cc.CallFunc:create(runEndSingle)
		local actEndMulti    = cc.CallFunc:create(runEndMulti)

		singlePanel:runAction(cc.Sequence:create(actBeginSingle,actSpawnSingle,actEndSingle))
		multiPanel:runAction(cc.Sequence:create(actBeginMulti,actSpawnMulti,actEndMulti))
	end

	local function SlideFadeOut()
		local function runEndSingle()	
			singlePanel:setPosition(singlePanelPos)
			GUISystem:enableUserInput()
		end

		local function runEndMulti()
			multiPanel:setPosition(multiPanelPos)
			if direction == WIN_FORWARD then 
				self.mSelectPanel:setVisible(false)
				self.mDetailPanel:setVisible(true)
				self:DetailPanelAnimation(SLIDE_FADEIN)
			elseif direction == WIN_EXIT then
				globaldata:cancelOLpvp()

				local function CallFunc()
					showLoadingWindow("HomeWindow") 
					EventSystem:PushEvent(Event.GUISYSTEM_HIDE_LADDERWINDOW)
				end

				if self.mData ~= nil and self.mData[1] ~= nil then
					FightSystem:sendChangeCity(false,CallFunc)	
				else
					EventSystem:PushEvent(Event.GUISYSTEM_HIDE_LADDERWINDOW)
				end
			end
			GUISystem:enableUserInput()
		end

		local actBeginSingle = cc.CallFunc:create(function() GUISystem:disableUserInput() end)
		local actBeginMulti	 = cc.CallFunc:create(function() end)
		local actMoveSingle  = cc.MoveTo:create(0.2, cc.p(VisibleRect:left().x - singlePanelSize.width,singlePanelPos.y))
		local actMoveMulti   = cc.MoveTo:create(0.2, cc.p(VisibleRect:right().x,multiPanelPos.y))
		local actFadeSingle  = cc.FadeOut:create(0.2)
		local actFadeMulti   = cc.FadeOut:create(0.2)
		local actSpawnSingle = cc.Spawn:create(actMoveSingle,actFadeSingle)
		local actSpawnMulti  = cc.Spawn:create(actMoveMulti,actFadeMulti)
		local actEndSingle   = cc.CallFunc:create(runEndSingle)
		local actEndMulti	 = cc.CallFunc:create(runEndMulti)

		singlePanel:runAction(cc.Sequence:create(actBeginSingle,actSpawnSingle,actEndSingle))
		multiPanel:runAction(cc.Sequence:create(actBeginMulti,actSpawnMulti,actEndMulti))
	end

	if inORout == SLIDE_FADEIN then SlideFadeIn() else SlideFadeOut() end
end

local detailOrignPosY = nil

function LadderWindow:DetailPanelAnimation(inORout)
	local panelPos   = cc.p(self.mDetailPanel:getPosition())
	detailOrignPosY = panelPos.y 
	local panelSize  = self.mDetailPanel:getContentSize() 

	local actFade    = nil

	if inORout == SLIDE_FADEOUT then 
		panelPos.y = panelPos.y + panelSize.height / 2
		actFade = cc.FadeOut:create(0.2)
	else
		actFade = cc.FadeIn:create(0.2)
	end

	local function runBegin()
		GUISystem:disableUserInput()	

		if inORout == SLIDE_FADEIN then 
			self.mDetailPanel:setPositionY(panelPos.y + panelSize.height / 2)
			self.mDetailPanel:setOpacity(0)
		end
	end

	local function runFinish()
		if inORout == SLIDE_FADEOUT then 	
			self.mDetailPanel:setPositionY(detailOrignPosY)
			self.mDetailPanel:setVisible(false)

			self.mModel:doCancleSearchRequest()
			self.mDetailPanel:getChildByName("Label_Seach_Stroke_162_81_2"):setString("匹配")
			self:SelectPanelAnimation(SLIDE_FADEIN,WIN_BACKWARD)
		else
			self:InitHeroIcon()
		end

		GUISystem:enableUserInput()
	end

	local actBegin = cc.CallFunc:create(runBegin)
	local actMove  = cc.MoveTo:create(0.2, panelPos)
	local actSpawn = cc.Spawn:create(actMove,actFade)
	local actEnd   = cc.CallFunc:create(runFinish)

	self.mDetailPanel:runAction(cc.Sequence:create(actBegin,actSpawn,actEnd))

end

local animNode = nil

function LadderWindow:OnSelectBattle(widget)
	GUISystem:disableUserInput()
	self.mBattleType = widget:getTag()
	local winCnt     = 0
	local failCnt    = 0
	local leftCnt    = 0
	local totalCnt   = 0
	local settleStr  = ""
	local score      = 0
	local rank       = 0
	local info3Str   = nil
	local typ        = nil
	local btnDR = self.mDetailPanel:getChildByName("Image_DailyRewards")

	if self.mBattleType == BATTLE_SINGLE_TAG then
		winCnt     = self.mModel.mSingleWinCnt
		failCnt    = self.mModel.mSingleFailCnt
		settleStr  = self.mModel.mSingleSettleStr
		leftCnt    = self.mModel.mSingleLeftCnt
		totalCnt   = self.mModel.mSingleTotalCnt
		score  	   = self.mModel.mSingleScore
		rank       = self.mModel.mSingleRank
		typ        = 0
		info3Str   = "新赛季积分将重新计算"

		self.mDetailPanel:getChildByName("Panel_VS_Window"):getChildByName("Panel_1V1"):setVisible(true)
		self.mDetailPanel:getChildByName("Panel_VS_Window"):getChildByName("Panel_3V3"):setVisible(false)
		self.mDetailPanel:getChildByName("Panel_VS"):getChildByName("Image_who"):loadTexture("tianti_vs_1v1.png")
		btnDR:setVisible(true) 
	else
		winCnt     = self.mModel.mMultiWinCnt
		failCnt    = self.mModel.mMultiFailCnt
		settleStr  = self.mModel.mMultiSettleStr
		leftCnt    = self.mModel.mMultiLeftCnt
		totalCnt   = self.mModel.mMultiTotalCnt
		score      = self.mModel.mMultiScore
		rank       = self.mModel.mMultiRank
		typ        = 1

		info3Str   = "排名前100的玩家可获得额外奖励" 

		self.mDetailPanel:getChildByName("Panel_VS_Window"):getChildByName("Panel_1V1"):setVisible(false)
		self.mDetailPanel:getChildByName("Panel_VS_Window"):getChildByName("Panel_3V3"):setVisible(true)
		self.mDetailPanel:getChildByName("Panel_VS"):getChildByName("Image_who"):loadTexture("tianti_vs_3v3.png")

		btnDR:setVisible(false)
	end

	if leftCnt < 0 then leftCnt = 0 end

	local medalPanel = self.mDetailPanel:getChildByName("Panel_Badge")
	medalPanel:getChildByName("Label_Integral"):setString(string.format("积分：%d",score))
	medalPanel:getChildByName("Label_Ranking"):setString(string.format("排名：%d",rank))
	setMedalLayout(score,medalPanel,typ)

	self.mDetailPanel:getChildByName("Panel_Info_1"):getChildByName("Label_Info"):setString(settleStr)
	self.mDetailPanel:getChildByName("Panel_Info_2"):getChildByName("Label_Info"):setString(info3Str)
	self.mDetailPanel:getChildByName("Label_WinLose"):setString(string.format("%d胜 %d负",winCnt,failCnt))	 
	self.mDetailPanel:getChildByName("Label_LastTimes"):setString(string.format("%d/%d",leftCnt,totalCnt))

	local bshow = nil if leftCnt > 0 then bshow = false else bshow = true end
	local buyBtn = self.mDetailPanel:getChildByName("Button_MoreTimes")
	buyBtn:setVisible(bshow)
	registerWidgetReleaseUpEvent(buyBtn,function() self.mModel:doLoadLadderCntPriceRequest() end)

	self.mDetailPanel:getChildByName("Label_Seach_Stroke_162_81_2"):setString("匹配")

	self:SelectPanelAnimation(SLIDE_FADEOUT,WIN_FORWARD)

	self.mDetailPanel:getChildByName("Image_Countdown"):setVisible(false)

	self.mTopRoleInfoPanel:resetExitBtnCallFunc(function()  
		GUISystem:playSound("homeBtnSound")
		self.mSelectPanel:setVisible(true) 
		self:DetailPanelAnimation(SLIDE_FADEOUT)			
		self.mTopRoleInfoPanel:resetExitBtnCallFunc(function()
			GUISystem:playSound("homeBtnSound")
			self:SelectPanelAnimation(SLIDE_FADEOUT,WIN_EXIT)
		end) 
	end)

	registerWidgetReleaseUpEvent(self.mDetailPanel:getChildByName("Button_RankingList"),
	function() 
		local typeInfo = nil 
		if self.mBattleType == BATTLE_SINGLE_TAG then
			typeInfo = RANKTYPE.MINOR.LADDER1V1
		else
			typeInfo = RANKTYPE.MINOR.LADDER3V3
		end
		GUISystem:goTo("rankinglist",{RANKTYPE.MAIN.ORGANIZE,typeInfo}) 
	end)	
	registerWidgetReleaseUpEvent(self.mDetailPanel:getChildByName("Button_Shop"), function() GUISystem:goTo("shangcheng", 8) end) 
	registerWidgetReleaseUpEvent(self.mDetailPanel:getChildByName("Button_Rule"), function() self:ShowRulePanel() end) 
	registerWidgetReleaseUpEvent(self.mDetailPanel:getChildByName("Button_DailyRewards"),function() self.mModel:doLoadMedalInfoRequest() end)
	registerWidgetReleaseUpEvent(self.mDetailPanel:getChildByName("Button_Rewards"),function() self:ShowScoreReward() end)
	--registerWidgetReleaseUpEvent(medalPanel,function() self.mModel:doLoadMedalInfoRequest() end)
	registerWidgetReleaseUpEvent(self.mDetailPanel:getChildByName("Button_Seach"),
	function()
		if self.mDetailPanel:getChildByName("Label_Seach_Stroke_162_81_2"):getString() == "匹配" then

			if self.mBattleType == BATTLE_SINGLE_TAG then  
				if self:getBattleHeroCount() < 3 then MessageBox:showMessageBox1("出战英雄数量不足！") return end
			else
				if self:getBattleHeroCount() < 1 then MessageBox:showMessageBox1("请选择出战英雄！") return end
			end

			self.mDetailPanel:getChildByName("Label_Seach_Stroke_162_81_2"):setString("取消")

			if animNode == nil then
				animNode = AnimManager:createAnimNode(8003)
				self.mDetailPanel:getChildByName("Image_Middle_VS"):getChildByName("Panel_Animation"):addChild(animNode:getRootNode(), 100)
			end
			animNode:play("tianti_vs_search1",true)

			self.mCancelType = nil	

			self.mModel:doSearchBattleRequest(self.mBattleType)

			self.mDetailPanel:getChildByName("Button_Seach"):setTouchEnabled(false)
			ShaderManager:DoUIWidgetDisabled(self.mDetailPanel:getChildByName("Button_Seach"),true)

			nextTick_frameCount(function()
				if self.mDetailPanel then
					self.mDetailPanel:getChildByName("Button_Seach"):setTouchEnabled(true) 
					ShaderManager:DoUIWidgetDisabled(self.mDetailPanel:getChildByName("Button_Seach"),false)
				end
			end,config.LadderCancelTimeGap)

		else
			self.mModel:doCancleSearchRequest()
		end
	end)

	local function doTiantiGuideOne_Stop()
		TiantiGuideOne:stop()
	end

	local function doTiantiGuideOne_Step5()
		local guideBtn = self.mRootWidget:getChildByName("Image_DailyRewards")
		local size = guideBtn:getContentSize()
		local pos = guideBtn:getWorldPosition()
		pos.x = pos.x - size.width/2
		pos.y = pos.y - size.height/2
		local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
		TiantiGuideOne:step(5, touchRect, nil, doTiantiGuideOne_Stop)
	end

	local function doTiantiGuideOne_Step4()
		local guideBtn = self.mRootWidget:getChildByName("Image_Rewards")
		local size = guideBtn:getContentSize()
		local pos = guideBtn:getWorldPosition()
		pos.x = pos.x - size.width/2
		pos.y = pos.y - size.height/2
		local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
		TiantiGuideOne:step(4, touchRect, nil, doTiantiGuideOne_Step5)
	end
	TiantiGuideOne:step(3, nil, doTiantiGuideOne_Step4)

end

function LadderWindow:ShowDailyReward(awardMap)
	local DRPanel = GUIWidgetPool:createWidget("Tianti_AccrueRewards")
	self.mRootNode:addChild(DRPanel,1000)

	DRPanel:getChildByName("Label_JoinTimes"):setString(tostring(awardMap.fightCnt))
	DRPanel:getChildByName("Label_WinTimes"):setString(tostring(awardMap.winCnt))

	for i=1,#awardMap.rewardInfo do
	 	local awardPanel = DRPanel:getChildByName(string.format("Panel_Reward_%d",i))

	 	local cnt = #awardMap.rewardInfo[i].rewards
	 	if cnt > 2 then cnt = 2 end

	 	for j=1,cnt do
	 		local itemPanel = awardPanel:getChildByName(string.format("Panel_Item_%d",j))
	 		local itemInfo = awardMap.rewardInfo[i].rewards[j]
	 		itemPanel:removeAllChildren()
	 		itemPanel:addChild(createCommonWidget(itemInfo.mRewardType,itemInfo.mItemId,itemInfo.mItemCnt))
	 	end

	 	local btn = awardPanel:getChildByName("Button_Get")

	 	if awardMap.rewardInfo[i].canGet == REWARDSTATE.CANRECEIVE then 
	 		btn:setTouchEnabled(true)
	 		ShaderManager:DoUIWidgetDisabled(btn,false)
	 	elseif awardMap.rewardInfo[i].canGet == REWARDSTATE.HAVERECEIVED then
	 		btn:getChildByName("Label_Get"):setString("已领取")
	 		btn:setTouchEnabled(false)
	 		ShaderManager:DoUIWidgetDisabled(btn,true)
	 	else
	 		btn:setTouchEnabled(false)
	 		ShaderManager:DoUIWidgetDisabled(btn,true)
	 	end
	 	btn:setTag(i)
	 	registerWidgetReleaseUpEvent(btn,function(widget)
	 		self.mModel:doGetRewardRequest(widget:getTag())
	 		widget:getChildByName("Label_Get"):setString("已领取") 
	 		widget:setTouchEnabled(false)
	 		ShaderManager:DoUIWidgetDisabled(btn,true) 
	 	end)	 	
	end

	local function closeWindow()
		DRPanel:removeFromParent()  
		DRPanel = nil
	end

	registerWidgetReleaseUpEvent(DRPanel,closeWindow)
end

function LadderWindow:ShowScoreReward()
	local SRPanel = GUIWidgetPool:createWidget("Tianti_BadgeRewards")
	self.mRootNode:addChild(SRPanel,1000)

	SRPanel:getChildByName("Panel_Window"):setTouchEnabled(true)

	local function closeWindow()
		SRPanel:removeFromParent()  
		SRPanel = nil
	end

	SRPanel:getChildByName("Panel_List"):setTouchEnabled(false)

	self.mSRTV = RewardTableView:new(self, 0)

	if self.mBattleType == BATTLE_SINGLE_TAG then
		self.mSRTV:SetSourceType(1)
	else
		self.mSRTV:SetSourceType(2)
	end

	self.mSRTV:init(SRPanel:getChildByName("Panel_List"))

	local page1 = SRPanel:getChildByName("Image_Page_1")
	local page2 = SRPanel:getChildByName("Image_Page_2")
	local bshow = false if self.mBattleType == BATTLE_MULTI_TAG then bshow = true end
	page2:setVisible(bshow)

	local lastPage = nil

	local function OnPressPage(widget)
		if lastPage and lastPage == widget then return end

		local tag = nil 
		if widget == page1 then
			page1:loadTexture("tianti_rewards_page1_1.png")
			page2:loadTexture("tianti_rewards_page2_2.png")
			tag = 1
			if self.mBattleType == BATTLE_SINGLE_TAG then
				self.mSRTV:SetSourceType(1)
			else
				self.mSRTV:SetSourceType(2)
			end
		else
			page1:loadTexture("tianti_rewards_page1_2.png")
			page2:loadTexture("tianti_rewards_page2_1.png")
			tag = 2
			self.mSRTV:SetSourceType(3)
		end

		lastPage = widget
	end

	registerWidgetReleaseUpEvent(page1,OnPressPage)
	registerWidgetReleaseUpEvent(page2,OnPressPage)
	OnPressPage(page1)

	registerWidgetReleaseUpEvent(SRPanel:getChildByName("Button_Close"),closeWindow) 
	registerWidgetReleaseUpEvent(SRPanel,closeWindow)
end

function LadderWindow:ShowRulePanel()
	local rulePanel = GUIWidgetPool:createWidget("Tianti_Rule")

	self.mRootNode:addChild(rulePanel,1000)
	
	registerWidgetReleaseUpEvent(rulePanel:getChildByName("Button_Close"),function() rulePanel:removeFromParent()  rulePanel = nil end) 
	registerWidgetReleaseUpEvent(rulePanel,function() rulePanel:removeFromParent()  rulePanel = nil end)

	local textId = nil
	if self.mBattleType == BATTLE_SINGLE_TAG then
		textId = 1711
	else
		textId = 1712
	end

	local textData = DB_Text.getDataById(textId)
	local textStr  = textData.Text_CN
	richTextCreate(rulePanel:getChildByName("Panel_Text"),textStr,true,nil,false)
end

local time = 5

function LadderWindow:NotifySearchSuccess()
	GUISystem:disableUserInput()
	local function UpdateCountDown()
		if self.mCancelType then return end	
		if time == 1 then
			GUISystem:HideAllWindow()
			EventSystem:PushEvent(Event.GUISYSTEM_HIDE_LADDERWINDOW)
			showPVPLoadingWindow("FightWindow")
			cclog("HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH==========")	
		else
			time = time - 1
			self.mDetailPanel:getChildByName("Image_Countdown"):loadTexture(string.format("tianti_vs_countdown_%d.png",time))
		end
	end

	self.mCountDownScheduler = cc.Director:getInstance():getScheduler():scheduleScriptFunc(UpdateCountDown, 1, false)

	self.mDetailPanel:getChildByName("Image_Countdown"):setVisible(true)
	self.mDetailPanel:getChildByName("Image_Countdown"):loadTexture("tianti_vs_countdown_5.png")
	self.mDetailPanel:getChildByName("Image_VS"):setVisible(false)
	ShaderManager:DoUIWidgetDisabled(self.mDetailPanel:getChildByName("Button_Seach"),false)
	self.mDetailPanel:getChildByName("Label_Seach_Stroke_162_81_2"):setString("匹配成功")


	local function xxx()
		if animNode ~= nil then
			animNode:play("tianti_vs_search3",true)
		end
	end

	if animNode ~= nil then
		animNode:play("tianti_vs_search2",false, xxx)
	end
end

function LadderWindow:NotifyCancelSearch(cancelType)
	if self.mDetailPanel == nil then return end

	self.mCancelType = cancelType

	GUISystem:enableUserInput()
	time = 5

	if self.mCountDownScheduler ~= nil then 
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.mCountDownScheduler)
		self.mCountDownScheduler = nil
	end


	if animNode ~= nil then
		animNode:destroy()
		animNode = nil
	end

	self.mDetailPanel:getChildByName("Image_Countdown"):setVisible(false)
	self.mDetailPanel:getChildByName("Image_VS"):setVisible(true)
	self.mDetailPanel:getChildByName("Label_Seach_Stroke_162_81_2"):setString("匹配")
end

function LadderWindow:Destroy()
	if self.mTopRoleInfoPanel ~= nil then
		self.mTopRoleInfoPanel:destroy()
		self.mTopRoleInfoPanel = nil
	end

	self:destroyAnimation()
	self.mModel:destroyInstance()

	if self.mDetailPanel ~= nil then
		self.mDetailPanel:getChildByName("ListView_HeroList"):removeAllItems()
		self.mDetailPanel      = nil
	end

	for i=1,#self.mExistHeroIcons do
		if self.mExistHeroIcons[i] ~= nil then
			--self.mExistHeroIcons[i]:removeFromParent(true)
			self.mExistHeroIcons[i] = nil
		end
	end
	self.mExistHeroIcons  = {}

	self.mSelectPanel  	   = nil

	for i=1,#self.mBattleHeroIcons do
		if self.mBattleHeroIcons[i] ~= nil then
			self.mBattleHeroIcons[i]:removeFromParent(true)
			self.mBattleHeroIcons[i] = nil
		end
	end
	self.mBattleHeroIcons  = {}

	if self.mBattleHeroIcon ~= nil then
		self.mBattleHeroIcon:removeFromParent(true)
		self.mBattleHeroIcon = nil
	end

	self.mBattleHeroIds    = {0,0,0}
	self.mBattleHeroId     = 0

	self.mTotalCombat      = 0

	if self.mTipSchedulerHandler ~= nil then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.mTipSchedulerHandler)
		self.mTipSchedulerHandler = nil
	end

	if self.mCountDownScheduler ~= nil then 
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.mCountDownScheduler)
		self.mCountDownScheduler = nil
	end

	time = 5

	if animNode ~= nil then
		animNode:destroy()
		animNode = nil
	end

	self.mRootWidget = nil

	if self.mRootNode then
		self.mRootNode:removeFromParent(true)
		self.mRootNode = nil
	end

	CommonAnimation.clearAllTextures()
end

function LadderWindow:onEventHandler(event)
	if event.mAction == Event.WINDOW_SHOW then
		self:Load(event)
		---------停止画主城镇界面
		EventSystem:PushEvent(Event.GUISYSTEM_DISABLEDRAW_HOMEWINDOW)
		---------
		NoticeSystem:doSingleUpdate(self.mName)
	elseif event.mAction == Event.WINDOW_HIDE then
		self:Destroy()
		---------开启画主城镇界面
		EventSystem:PushEvent(Event.GUISYSTEM_EABLEDRAW_HOMEWINDOW)
		---------
	end
end

return LadderWindow