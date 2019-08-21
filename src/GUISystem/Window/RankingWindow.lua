-- Name: 	RankingModel
-- Func：	排行榜模型
-- Author:	lichuan
-- Data:	15-6-2

RankerInfo = {}
function RankerInfo:new()
	local o = 
	{
		mPlayerIdStr 			= nil,	-- 玩家ID
		mPlayerNameStr			= nil,	-- 玩家名字
		mPlayerFrameId          = nil,	-- 玩家头像边框
		mPlayerIconId           = nil, 	-- 玩家头像
		mPartyId                = 0,    -- 帮派ID
 		mPartyLv                = 0,	-- 帮派Lv
		mPartyName				= "",	-- 帮会名字
		mPlayerLevel			= 0,	-- 玩家等级
		mRankValue				= 0,    -- 排行值
		mMainHeroId             = 0,    -- 主英雄ID 
		mMainHeroLv             = 0,    -- 主英雄Lv 
		mMainHeroQa				= 0,    -- 主英雄品质
		mMainHeroAdLv			= 0,    -- 主英雄advanceLv
		mHeroArr				= {},	-- 英雄
		mIsFriend               = 0,    -- 1 是  0 不是
		mPartyIconId            = 1,
	}
	o = newObject(o, RankerInfo)
	return o
end

function RankerInfo:getKeyValue(key)
	if self[key] then
		return self[key]
	end
	return nil
end

bigItemInfo = 
{
	-- 组织
	{
		mName = "组织排名",
		mContent = {"全员总战力", "武道馆名次", "制霸之战1v1","制霸之战3v3",}--"魅力值",
	},
	-- 英雄
	{
		mName = "英雄排名",
		mContent = {"战力排行",}
	},
	-- 公会
	{
		mName = "公会排名",
		mContent = {"建设度",}
	},

}

local RMInstance = nil

RankingModel = class("RankingModel")

function RankingModel:ctor(owner)
	self.mName 		     = "RankingModel"
	self.mOwner			 = owner
	self.mCheckPlayerId	 = nil
	self.mDataSource 	 = nil
	self.mRankLength     = nil 
	self.mSelfRank       = nil
	self.mSelfHeroCnt 	 = nil
	self.mSelfTotalStar  = nil
	self.mSelfFightPower = nil
	self.mReload = false

	self:registerNetEvent()
end

function RankingModel:deinit()
	self.mName 		    = nil
	self.mOwner			= nil
	self.mCheckPlayerId	= nil
	self.mDataSource 	 = {}
	self.mRankLength     = nil 
	self.mSelfRank       = nil
	self.mSelfHeroCnt 	 = nil
	self.mSelfTotalStar  = nil
	self.mSelfFightPower = nil
	self.mReload = false
	
	self:unRegisterNetEvent()
end

function RankingModel:getInstance()
	if RMInstance == nil then  
        RMInstance = RankingModel.new()
    end  
    return RMInstance
end

function RankingModel:destroyInstance()
	if RMInstance then
		RMInstance:deinit()
    	RMInstance = nil
    end
end

function RankingModel:registerNetEvent()
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_RANKING_LIST, handler(self, self.onRequestRankList))
end

function RankingModel:unRegisterNetEvent()
	NetSystem.mNetManager:UnregisterPacketHandler(PacketTyper._PTYPE_SC_RANKING_LIST)
end

function RankingModel:setOwner(owner)
	self.mOwner = owner
end

-- 初始化数据源
function RankingModel:loadDataSource(curIdx)
	local length = ((self.mOwner.mMainRank ~= RANKTYPE.MAIN.PARTY and #self.mDataSource - 1 ) or #self.mDataSource)
	if length <= 0 then length = 0 end
	self.mReload = ((curIdx == 0 and true) or false)

	local packet = NetSystem.mNetManager:GetSPacket()
    packet:SetType(PacketTyper._PTYPE_CS_RANKING_LIST)
    packet:PushChar(self.mOwner.mMainRank)
    packet:PushChar(self.mOwner.mMinorRank)
    packet:PushInt(length)
    packet:Send()

	GUISystem:showLoading()
end

function RankingModel:loadFirstTime()
	local mainRank    = self.mWinData[1]
	local minorRank   = self.mWinData[2]

	-- if mainRank ~= RANKTYPE.MAIN.PARTY then
	-- 	local invalidInfo = RankerInfo:new()
	-- 	invalidInfo.mRankValue = -1 
	-- 	globaldata.rankArr[mainRank][minorRank][1] = invalidInfo
	-- end

	local packet = NetSystem.mNetManager:GetSPacket()
	packet:SetType(PacketTyper._PTYPE_CS_RANKING_LIST)
	packet:PushChar(mainRank)
	packet:PushChar(minorRank)
	packet:PushInt(0)
	packet:Send()
	self.mReload = true
    GUISystem:showLoading()
end

function RankingModel:reload()
	local mainRank   = self.mOwner.mMainRank
	local minorRank  = self.mOwner.mMinorRank
	self.mDataSource = globaldata.rankArr[mainRank][minorRank]
	self.mRankLength = globaldata.rankLength[mainRank][minorRank] 
	self.mSelfRank   = globaldata.selfRank[mainRank][minorRank]


	--GUISystem:showLoading() 
	--nextTick_frameCount(function() GUISystem:hideLoading() end, 0.3)
	-- -1 client init value  0 for server

	if self.mRankLength == -1 or self.mRankLength == 0 then 
		self:loadDataSource(0)
	end
end

local lastMainRank  = 0
local lastMinorRank = 0

function RankingModel:onRequestRankList(msgPacket)
	self.mMainRank   = msgPacket:GetChar()
	self.mMinorRank  = msgPacket:GetChar()
	self.mRankLength = msgPacket:GetInt()	
	self.mSelfRank   = msgPacket:GetInt()
	self.mSelfValue  = msgPacket:GetInt()

	globaldata.rankLength[self.mMainRank][self.mMinorRank] = self.mRankLength
	globaldata.selfRank[self.mMainRank][self.mMinorRank] = self.mSelfRank

	cclog(string.format("mainRank is %d, minorRank is %d rank totalLength is %d,selfRank is %d",self.mMainRank,self.mMinorRank ,self.mRankLength,self.mSelfRank))

	if lastMainRank ~= self.mMainRank or lastMinorRank ~= self.mMinorRank then
		self.mDataSource = globaldata.rankArr[self.mMainRank][self.mMinorRank]
		lastMainRank     = self.mMainRank
		lastMinorRank    = self.mMinorRank
	end

	if self.mMainRank ~= RANKTYPE.MAIN.PARTY and self.mSelfRank ~= 0 then
		local invalidInfo = RankerInfo:new()
		invalidInfo.mRankValue = -1 
		globaldata.rankArr[self.mMainRank][self.mMinorRank][1] = invalidInfo
	end

	local rankCnt    = msgPacket:GetUShort()
	if self.mMainRank == RANKTYPE.MAIN.ORGANIZE then
		for j = 1, rankCnt do
			local rankerInfo = RankerInfo:new()
			rankerInfo.mIsFriend             = msgPacket:GetChar()
			local rank                       = msgPacket:GetInt()			
			rankerInfo.mPlayerIdStr          = msgPacket:GetString()
			rankerInfo.mPlayerNameStr        = msgPacket:GetString()
			rankerInfo.mPlayerFrameId        = msgPacket:GetInt()	
			rankerInfo.mPlayerIconId         = msgPacket:GetInt()			
			rankerInfo.mPartyName            = msgPacket:GetString()
			rankerInfo.mPlayerLevel 		 = msgPacket:GetInt()
			rankerInfo.mRankValue			 = msgPacket:GetInt()

			local heroCnt                    = msgPacket:GetUShort()
			for i=1,heroCnt do
				local id                     = msgPacket:GetInt()
				local lv                     = msgPacket:GetInt()
				local qa                     = msgPacket:GetChar()
				local adlv                   = msgPacket:GetChar()
				local heroInfo = {id,lv,qa,adlv}
				table.insert(rankerInfo.mHeroArr,heroInfo)  
			end

			print(string.format("%s,%s,%d,%d",rankerInfo.mPlayerIdStr,rankerInfo.mPlayerNameStr,rankerInfo.mPlayerFrameId,rankerInfo.mPlayerIconId))
			table.insert(globaldata.rankArr[self.mMainRank][self.mMinorRank],rankerInfo)		
		end
	elseif self.mMainRank == RANKTYPE.MAIN.HERO then
		for j = 1, rankCnt do
			local rankerInfo = RankerInfo:new()
			local rank                       = msgPacket:GetInt()
			rankerInfo.mPlayerIdStr          = msgPacket:GetString()
			rankerInfo.mPlayerNameStr        = msgPacket:GetString()
			rankerInfo.mPlayerFrameId        = msgPacket:GetInt()	
			rankerInfo.mPlayerIconId         = msgPacket:GetInt()
			rankerInfo.mPartyName            = msgPacket:GetString()
			rankerInfo.mPlayerLevel 		 = msgPacket:GetInt()
			rankerInfo.mMainHeroId			 = msgPacket:GetInt()
			rankerInfo.mMainHeroLv			 = msgPacket:GetInt()
			rankerInfo.mMainHeroQa			 = msgPacket:GetChar()
			rankerInfo.mMainHeroAdLv	     = msgPacket:GetChar()
			rankerInfo.mRankValue			 = msgPacket:GetInt()

			print(string.format("%s,%s,%d,%d",rankerInfo.mPlayerIdStr,rankerInfo.mPlayerNameStr,rankerInfo.mPlayerFrameId,rankerInfo.mPlayerIconId))
			table.insert(globaldata.rankArr[self.mMainRank][self.mMinorRank],rankerInfo)
		end
	elseif self.mMainRank == RANKTYPE.MAIN.PARTY then
		for j = 1, rankCnt do
			local rankerInfo = RankerInfo:new()
			local rank                       = msgPacket:GetInt()
			rankerInfo.mPartyId              = msgPacket:GetString()
			rankerInfo.mPartyName            = msgPacket:GetString()
			rankerInfo.mPartyIconId			 = msgPacket:GetInt()
			rankerInfo.mPartyLv 		     = msgPacket:GetInt()
			rankerInfo.mRankValue			 = msgPacket:GetInt()
			table.insert(globaldata.rankArr[self.mMainRank][self.mMinorRank],rankerInfo)
		end
	end


	self.mDataSource = globaldata.rankArr[self.mMainRank][self.mMinorRank]	
	
	if self.mOwner and self.mOwner.mRankListView then
		self.mOwner.mRankListView:UpdateTableView()
	else
		Event.GUISYSTEM_SHOW_RANKINGWINDOW.mData = self.mWinData
		EventSystem:PushEvent(Event.GUISYSTEM_SHOW_RANKINGWINDOW)
	end

	self.mOwner:setSelfPanelLayout()

	nextTick_frameCount(function() GUISystem:hideLoading() end, 0.5) 
end

function RankingModel:doLoadPlayerInfoRequest(index)
	if #self.mDataSource == 0 then return end
	if self.mOwner.mMainRank == RANKTYPE.MAIN.HERO or self.mOwner.mMainRank == RANKTYPE.MAIN.PARTY then return end
	if self.mDataSource[index].mPlayerIdStr == nil then return end

    if self.mDataSource[index].mPlayerIdStr ~= globaldata.playerId then
    	self.mCheckPlayerId   = self.mDataSource[index].mPlayerIdStr
    	self.mCheckPlayerName = self.mDataSource[index].mPlayerNameStr
		local packet = NetSystem.mNetManager:GetSPacket()
		packet:SetType(PacketTyper._PTYPE_CS_REQUEST_PLAYER_INFO_)
		packet:PushString(self.mDataSource[index].mPlayerIdStr)
		packet:Send()
		globaldata.requestType = "RankingWindow"
		GUISystem:showLoading()
    end

end

function RankingModel:doAddFriendRequest()
	if self.mCheckPlayerId == nil then return end

	local packet = NetSystem.mNetManager:GetSPacket()
    packet:SetType(PacketTyper._PTYPE_CS_REQUEST_ADD_FRIEND_)
    packet:PushString(self.mCheckPlayerId)
    packet:Send()
end

function RankingModel:doDelFriendRequest()
	if self.mCheckPlayerId == nil then return end

	local packet = NetSystem.mNetManager:GetSPacket()
    packet:SetType(PacketTyper._PTYPE_CS_DELETE_FRIEND_)
    packet:PushString(self.mCheckPlayerId)
    packet:Send()
end

function RankingModel:doChatRequest()
	if self.mCheckPlayerId == nil then return end
	GUISystem:requestTalkToSomebody(self.mCheckPlayerId,self.mCheckPlayerName)
	EventSystem:PushEvent(Event.GUISYSTEM_HIDE_RANKINGWINDOW)
end

function RankingModel:doPKRequest()
	if self.mCheckPlayerId == nil then return end	
	PKHelper:DoPKInvite(self.mCheckPlayerId,self.mCheckPlayerName)
end

--==================================================================tv begin========================================================================
-- 英雄列表对象
local RankingItemList = {}

function RankingItemList:new(owner, listType)
	local o = 
	{
		mOwner 			=	owner,
		mRootNode 		=	nil,
		mType 			=	listType,
		mTableView		=	nil,
		mLastCellIndex  = 	-1,
		mLastClickCell  =   nil,
	}
	o = newObject(o, RankingItemList)
	return o
end

function RankingItemList:Destroy()
	self.mOwner 			= nil
	self.mRootNode:removeFromParent(true)
	self.mRootNode 		    = nil
	self.mTableView 	    = nil
	self.mLastCellIndex     = -1
	self.mLastClickCell     = nil
end

function RankingItemList:init(rootNode)
	self.mRootNode = rootNode
	self:initTableView()
end

function RankingItemList:initTableView()
	self.mTableView = TableViewEx:new()
	self.mTableView:setCellSize(GUIWidgetPool:createWidget("RankingList_Player"):getContentSize())
	self.mTableView:setCellCount(10)

	self.mTableView:registerTableCellAtIndexFunc(handler(self, self.tableCellAtIndex))
	self.mTableView:registerTableCellTouchedFunc(handler(self, self.tableCellTouched))
	--self.mTableView:registerScrollViewDidScrollFunc(handler(self, self.scrollViewDidScroll))

	self.mTableView:init(self.mRootNode:getContentSize(), cc.p(0,0), 1)
	self.mRootNode:addChild(self.mTableView:getRootNode())

	self.mTableView:setBounceable(true)
end

function RankingItemList:tableCellAtIndex(table, index)
	local length   = (self.mOwner.mModel.mMainRank ~= RANKTYPE.MAIN.PARTY and #self:myModel().mDataSource - 1 ) or #self:myModel().mDataSource
	local totalLen = globaldata.rankLength[self.mOwner.mMainRank][self.mOwner.mMinorRank]
	local rankInfo = self:myModel().mDataSource[length - 1]

	if index + 1 > length and index + 1 < totalLen then
		if rankInfo ~= nil then
			self:myModel():loadDataSource(length)
		end
	end  

	local cell = table:dequeueCell()
	local playerItem = nil
	if nil == cell then
		cell = cc.TableViewCell:new()
		playerItem = GUIWidgetPool:createWidget("RankingList_Player")
		playerItem:setTouchSwallowed(false)
		playerItem:setTag(1)
		cell:addChild(playerItem)
	else
		playerItem = cell:getChildByTag(1)
	end

	self:setCellLayOut(playerItem,index)
	
	return cell
end

function RankingItemList:setCellLayOut(widget,index)
	if #self:myModel().mDataSource == 0 then return end

	widget:setOpacity(0)
	widget:runAction(cc.FadeIn:create(0.2))

	local selfRank = ((self:myModel().mSelfRank == nil and globaldata.selfRank[self.mOwner.mMainRank][self.mOwner.mMinorRank]) or self:myModel().mSelfRank)
	local rankInfo = self:myModel().mDataSource[index + 1]

	if rankInfo == nil or rankInfo.mRankValue == -1 then 
		widget:setVisible(false)
		return 
	else
		widget:setVisible(true)
	end

	local rankPanel  = nil

	if self.mOwner.mMainRank ~= RANKTYPE.MAIN.PARTY then
		if index == selfRank and selfRank ~= 0 then
			rankPanel = widget:getChildByName("Panel_Self")	
			widget:getChildByName("Panel_Others"):setVisible(false)
		else
			rankPanel = widget:getChildByName("Panel_Others")
			widget:getChildByName("Panel_Self"):setVisible(false)	
		end
		rankPanel:setVisible(true)
	else
		rankPanel = widget:getChildByName("Panel_Others")
		rankPanel:setVisible(true)
		widget:getChildByName("Panel_Self"):setVisible(false)
	end

	if self.mOwner.mMainRank ~= RANKTYPE.MAIN.PARTY and self:myModel().mSelfRank ~= 0 then
		if index < 4 and index > 0 then	
			rankPanel:getChildByName("Image_Ranking"):setVisible(true)
			rankPanel:getChildByName("Image_Ranking"):loadTexture(string.format("rankinglist_no%d.png",index))
			rankPanel:getChildByName("BitmapLabel_Ranking"):setVisible(false)
		else
			rankPanel:getChildByName("Image_Ranking"):setVisible(false)
			rankPanel:getChildByName("BitmapLabel_Ranking"):setVisible(true)
			rankPanel:getChildByName("BitmapLabel_Ranking"):setString(tostring(index))
		end
	else
		if index < 3 then	
			rankPanel:getChildByName("Image_Ranking"):setVisible(true)
			rankPanel:getChildByName("Image_Ranking"):loadTexture(string.format("rankinglist_no%d.png",index + 1))
			rankPanel:getChildByName("BitmapLabel_Ranking"):setVisible(false)
		else
			rankPanel:getChildByName("Image_Ranking"):setVisible(false)
			rankPanel:getChildByName("BitmapLabel_Ranking"):setVisible(true)
			rankPanel:getChildByName("BitmapLabel_Ranking"):setString(tostring(index + 1))
		end
	end

	local mainRank       = self.mOwner.mMainRank
	local minorRank      = self.mOwner.mMinorRank

	local playerPanel    = rankPanel:getChildByName("Panel_Player")
	local partyPanel     = rankPanel:getChildByName("Panel_Guild")
	local allPowerPanel  = playerPanel:getChildByName("Panel_TotalZhanli")
	local arenaPanel     = playerPanel:getChildByName("Panel_Arena")
	local ladderPanel    = playerPanel:getChildByName("Panel_Tianti")
	local charmPanel     = playerPanel:getChildByName("Panel_Favor")
	local heroPowerPanel = playerPanel:getChildByName("Panel_HeroZhanli")
	local panelArr       = {allPowerPanel,arenaPanel,ladderPanel,ladderPanel,charmPanel,heroPowerPanel}

	local function selectPanelVisible(index,panelArr)
		for i=1,#panelArr do			  
			if index == i then
				panelArr[i]:setVisible(true)
			else
				if i ~= 4 then
					panelArr[i]:setVisible(false)
				end
			end	 
		end
	end

	local playerHead = GUIWidgetPool:createWidget("PlayerHead")
	playerHead:setTag(1)
	playerHead:getChildByName("Panel_7"):setTouchEnabled(false)
	playerHead:getChildByName("Image_PlayerHead_Bg"):loadTexture(FindFrameIconbyId(rankInfo.mPlayerFrameId))
	playerHead:getChildByName("Image_PlayerHead"):loadTexture(FindFrameIconbyId(rankInfo.mPlayerIconId))

	rankPanel:getChildByName("Panel_PlayerInfo"):removeAllChildren()
	rankPanel:getChildByName("Panel_PlayerInfo"):addChild(playerHead)
	

	playerHead:getChildByName("Label_Level"):setString(tostring(rankInfo.mPlayerLevel))

	if rankInfo.mPartyName == "" then rankInfo.mPartyName = "未加入帮派" end
	panelArr[minorRank]:getChildByName("Label_PlayerName"):setString(rankInfo.mPlayerNameStr)
	panelArr[minorRank]:getChildByName("Label_GuildName"):setString(rankInfo.mPartyName)

	if mainRank == RANKTYPE.MAIN.ORGANIZE then
		playerPanel:setVisible(true)
		partyPanel:setVisible(false)

		selectPanelVisible(minorRank,panelArr)

		if minorRank == RANKTYPE.MINOR.ALLFIGHTPOWER then
			panelArr[minorRank]:getChildByName("Label_TotalZhanli"):setString(string.format("所有学员总战力：%d",rankInfo.mRankValue))			
		elseif minorRank == RANKTYPE.MINOR.ARENA then
		elseif minorRank == RANKTYPE.MINOR.LADDER1V1 or minorRank == RANKTYPE.MINOR.LADDER3V3 then
			local typ = (minorRank == RANKTYPE.MINOR.LADDER1V1 and 0) or 1
			setMedalLayout(rankInfo.mRankValue,panelArr[minorRank],typ)
		elseif minorRank == RANKTYPE.MINOR.CHARM then --deprecated
			--panelArr[minorRank]:getChildByName("Label_Favor"):setString(string.format("学员好感度：%d",rankInfo.mRankValue))		
		end		
	elseif mainRank == RANKTYPE.MAIN.HERO then 	
		playerPanel:setVisible(true)
		partyPanel:setVisible(false)

		selectPanelVisible(6,panelArr)

		panelArr[6]:getChildByName("Label_heroZhanli"):setString(string.format("%d",rankInfo.mRankValue))
		if rankInfo.mPartyName == "" then rankInfo.mPartyName = "未加入帮派" end
		panelArr[6]:getChildByName("Label_PlayerName"):setString(rankInfo.mPlayerNameStr)
		panelArr[6]:getChildByName("Label_GuildName"):setString(rankInfo.mPartyName)

		local srcIcon = panelArr[6]:getChildByName("Panel_HeroIcon"):getChildByTag(9527)
		
		if srcIcon then
			local something = srcIcon:getChildByName("Panel_SuperHero_Animation") 
			if something then something:setVisible(false) end
		end

		if rankInfo.mRankValue ~= -1 then 
			local heroIcon = createHeroIcon(rankInfo.mMainHeroId,rankInfo.mMainHeroLv,rankInfo.mMainHeroQa,rankInfo.mMainHeroAdLv,srcIcon)
			heroIcon:setTag(9527)
			if srcIcon == nil then 
				panelArr[6]:getChildByName("Panel_HeroIcon"):addChild(heroIcon)
			end
		end
	elseif mainRank == RANKTYPE.MAIN.PARTY then
		playerPanel:setVisible(false)	
		partyPanel:setVisible(true)
		partyPanel:getChildByName("Panel_GuildBuild"):setVisible(true)
		partyPanel:getChildByName("Label_GuildBuild"):setString(rankInfo.mRankValue)
		partyPanel:getChildByName("Label_GuildLevel"):setString(string.format("< %d >",rankInfo.mPartyLv))
		partyPanel:getChildByName("Label_GuildName"):setString(rankInfo.mPartyName)

		local resId = DB_GuildIcon.getDataById(rankInfo.mPartyIconId).ResourceListID
		local resData = DB_ResourceList.getDataById(resId)
		partyPanel:getChildByName("Image_GuildIcon"):loadTexture(resData.Res_path1)
	end 

	self.mLastCellIndex = index
end

function RankingItemList:tableCellTouched(table,cell)
	print("RankingItemList cell touched at index: " .. cell:getIdx())
	if self.mOwner.mMainRank ~= RANKTYPE.MAIN.PARTY then 
		--self.mOwner:ShowPlayerInfo(cell:getIdx() + 1)
		self.mOwner.mModel:doLoadPlayerInfoRequest(cell:getIdx() + 1)
    end
	self.mLastClickCell = cell
end

function RankingItemList:UpdateTableView()
	local rankTotalLength = globaldata.rankLength[self.mOwner.mMainRank][self.mOwner.mMinorRank]
	local curOffset = self.mTableView.mInnerContainer:getContentOffset()
	local curHeight = self.mTableView.mInnerContainer:getContentSize().height

	if self.mOwner.mMainRank ~= RANKTYPE.MAIN.PARTY and self:myModel().mSelfRank ~= 0 then
		rankTotalLength = rankTotalLength + 1
	end

	self.mTableView:setCellCount(rankTotalLength)
	self.mTableView:reloadData()

	if self.mOwner.mModel.mReload ~= true then
		self.mTableView.mInnerContainer:setContentOffset(cc.p(0,self.mTableView.mInnerContainer:getViewSize().height - self.mTableView.mInnerContainer:getContentSize().height))
		local height = self.mTableView.mInnerContainer:getContentSize().height
		curOffset.y = curOffset.y + (curHeight - height)
		self.mTableView.mInnerContainer:setContentOffset(curOffset)
	end
end

function RankingItemList:setBounceable(bounce)
	self.mTableView:setBounceable(bounce)
end

function RankingItemList:myModel()
	return self.mOwner.mModel
end

--==================================================================window begin========================================================================
-- Name: 	RankingWindow
-- Func：	排行榜
-- Author:	lichuan
-- Data:	15-5-4
local moveTime 			=	0.1
local totalLength 		=	0 		-- 关卡滑动总长度

local RankingWindow = 
{
	mName						=	"RankingWindow",
	mRootNode 					= 	nil,
	mRootWidget 				= 	nil,

	mBigItemList				=	{},
	mSmallItemList 				=	{},

	mLastClickIndex 			=	nil,	-- 最后一次点击大选项的序号
	mLastClickedSmallWidget 	=	nil, 	-- 最后一次点击的小选项控件

	mRankListView				= 	nil,
	mSelfPanel					=   nil,
	mSmallCurSel				=   nil,
	mModel						=   nil,

	mMainRank				    =   1,
	mMinorRank                  =   1,

	mLadderScore 				=  {},
}

function RankingWindow:Release()

end

function RankingWindow:Load(event)
	cclog("=====RankingWindow:Load=====begin")

	self.mMainRank    = event.mData[1]
	self.mMinorRank   = event.mData[2]
	self.mSmallCurSel = self.mMinorRank

	self.mModel = RankingModel:getInstance()
	self.mModel:setOwner(self)

	self:InitLayout(event)

	cclog("=====RankingWindow:Load=====end")
end

function RankingWindow:InitLayout(event)
	self.mRootNode = cc.Node:create()
	GUISystem:GetRootNode():addChild(self.mRootNode)
	
	self.mRootWidget =  GUIWidgetPool:createWidget("RankingList_Main")
	self.mRootNode:addChild(self.mRootWidget)

	if self.mTopRoleInfoPanel == nil then
		cclog("RankingWindow mTopRoleInfoPanel init")
		self.mTopRoleInfoPanel = TopRoleInfoPanel:new()
		self.mTopRoleInfoPanel:init(self.mRootNode,ROLE_TITLE_TYPE.TITLE_RANK,
		function() 
			GUISystem:playSound("homeBtnSound") 
			EventSystem:PushEvent(Event.GUISYSTEM_HIDE_RANKINGWINDOW)
			globaldata:clearRankData() 
		end)
	end
	
	self.mTopRoleInfoPanel.mTopWidget:getChildByName("Button_Back"):setTouchEnabled(false)
	
	self.mSelfPanel = GUIWidgetPool:createWidget("RankingList_Player")
	self.mRootWidget:getChildByName("Panel_Self"):addChild(self.mSelfPanel,200)
	self.mSelfPanel:setVisible(false)

	local listPanel = self.mRootWidget:getChildByName("Panel_RankingList")
	local pagePanel = self.mRootWidget:getChildByName("Panel_Page")
	listPanel:setVisible(true)
	pagePanel:setVisible(true)

	self.mRankListView = RankingItemList:new(self, 0)
	self.mRankListView:init(self.mRootWidget:getChildByName("Panel_Main"):getChildByName("Panel_RankingList"):getChildByName("ListView_RankingList"))

	self:initBigItem()
end

function RankingWindow:setSelfPanelLayout()
	self.mSelfPanel:setVisible(true)
	self.mSelfPanel:getChildByName("Panel_Others"):setVisible(false)

	local selfRank =  self.mModel.mSelfRank
	if selfRank == nil then selfRank = globaldata.selfRank[self.mMainRank][self.mMinorRank] end

	local ownerPanel = self.mSelfPanel:getChildByName("Panel_Self")
	ownerPanel:setVisible(true)

	if selfRank <= 0 then
		ownerPanel:setVisible(false)
		self.mSelfPanel:setTouchSwallowed(false)
	else
		self.mSelfPanel:setTouchSwallowed(true)
	end

	if selfRank < 3 and selfRank > 0 then 
		ownerPanel:getChildByName("Image_Ranking"):setVisible(true)
		ownerPanel:getChildByName("Image_Ranking"):loadTexture(string.format("rankinglist_no%d.png",selfRank))
		ownerPanel:getChildByName("BitmapLabel_Ranking"):setVisible(false)			
	end

	if selfRank >= 3 then 
		ownerPanel:getChildByName("Image_Ranking"):setVisible(false)
		ownerPanel:getChildByName("BitmapLabel_Ranking"):setVisible(true)
		ownerPanel:getChildByName("BitmapLabel_Ranking"):setString(tostring(selfRank))
	end

	local playerPanelo    = ownerPanel:getChildByName("Panel_Player")
	local partyPanelo     = ownerPanel:getChildByName("Panel_Guild")
	local allPowerPanelo  = playerPanelo:getChildByName("Panel_TotalZhanli")
	local arenaPanelo     = playerPanelo:getChildByName("Panel_Arena")
	local ladderPanelo    = playerPanelo:getChildByName("Panel_Tianti")
	local charmPanelo     = playerPanelo:getChildByName("Panel_Favor")
	local heroPowerPanelo = playerPanelo:getChildByName("Panel_HeroZhanli")
	local panelArro       = {allPowerPanelo,arenaPanelo,ladderPanelo,ladderPanelo,charmPanelo,heroPowerPanelo}

	local function selectPanelVisible(index)
		for i=1,#panelArro do			  
			if index == i then
				panelArro[i]:setVisible(true)
			else
				if i ~= 4 then
					panelArro[i]:setVisible(false)
				end
			end	 
		end
	end

	local playerHead = GUIWidgetPool:createWidget("PlayerHead")
	playerHead:getChildByName("Label_Level"):setString(tostring(globaldata.level))
	playerHead:getChildByName("Image_PlayerHead_Bg"):loadTexture(FindFrameIconbyId(globaldata.playerFrame))
	playerHead:getChildByName("Image_PlayerHead"):loadTexture(FindFrameIconbyId(globaldata.playerIcon))

	ownerPanel:getChildByName("Panel_PlayerInfo"):removeAllChildren()
	ownerPanel:getChildByName("Panel_PlayerInfo"):addChild(playerHead)

	panelArro[self.mMinorRank]:getChildByName("Label_PlayerName"):setString(globaldata.name)
	panelArro[self.mMinorRank]:getChildByName("Label_GuildName"):setString((globaldata.partyName == "" and "未加入帮派") or globaldata.partyName)

	if self.mMainRank == RANKTYPE.MAIN.ORGANIZE then
		playerPanelo:setVisible(true)
		partyPanelo:setVisible(false)

		selectPanelVisible(self.mMinorRank)

		if self.mMinorRank == RANKTYPE.MINOR.ALLFIGHTPOWER then
			panelArro[self.mMinorRank]:getChildByName("Label_TotalZhanli"):setString(string.format("所有学员总战力：%d",globaldata.playerCombat))				
		elseif self.mMinorRank == RANKTYPE.MINOR.ARENA then
		elseif self.mMinorRank == RANKTYPE.MINOR.LADDER1V1 or self.mMinorRank == RANKTYPE.MINOR.LADDER3V3 then
			local typ = (self.mMinorRank == RANKTYPE.MINOR.LADDER1V1 and 0) or 1
			self.mLadderScore[typ] = ((self.mLadderScore[typ] == nil and self.mModel.mSelfValue) or self.mLadderScore[typ])
			setMedalLayout(self.mLadderScore[typ],panelArro[self.mMinorRank],typ)
		elseif self.mMinorRank == RANKTYPE.MINOR.CHARM then --deprecated
			--panelArro[self.mMinorRank]:getChildByName("Label_Favor"):setString(string.format("学员好感度：%d",9527))			
		end		
	elseif self.mMainRank == RANKTYPE.MAIN.HERO then 	
		playerPanelo:setVisible(true)
		partyPanelo:setVisible(false)

		selectPanelVisible(6)
		
		local maxCombatId = 0
		local maxCombat   = 0

		for k, v in pairs(globaldata.heroTeam) do
			local heroObj = globaldata:findHeroById(v.id) 
			if heroObj.combat > maxCombat then
				maxCombatId = heroObj.id
				maxCombat = heroObj.combat
			end
		end

		local heroObj = globaldata:findHeroById(maxCombatId) 
		local heroIcon = createHeroIcon(heroObj.id,heroObj.level,heroObj.quality,heroObj.advanceLevel)

		panelArro[6]:getChildByName("Panel_HeroIcon"):addChild(heroIcon)
		panelArro[6]:getChildByName("Label_heroZhanli"):setString(tostring(maxCombat))
		panelArro[6]:getChildByName("Label_PlayerName"):setString(globaldata.name)
		panelArro[6]:getChildByName("Label_GuildName"):setString((globaldata.partyName == "" and "未加入帮派") or globaldata.partyName)
	elseif self.mMainRank == RANKTYPE.MAIN.PARTY then
		ownerPanel:setVisible(false)  --工会不显示自己的条
	end 
end

local margin_top = 20

-- 初始化大选项
function RankingWindow:initBigItem()
	local scrollWidget = self.mRootWidget:getChildByName("ScrollView_Page")

	local listContentSize = scrollWidget:getContentSize()
	local itemContentSize = GUIWidgetPool:createWidget("RankingList_Page1"):getContentSize()
	
	for i = 1, #bigItemInfo do
		self.mBigItemList[i] = GUIWidgetPool:createWidget("RankingList_Page1")
		self.mBigItemList[i]:getChildByName("Label_Name"):setString(bigItemInfo[i].mName)
		self.mBigItemList[i]:setTag(i)
		scrollWidget:addChild(self.mBigItemList[i], 10)
		self.mBigItemList[i]:setPosition(cc.p(0, 0 - (i-1)*itemContentSize.height + listContentSize.height - margin_top))
		registerWidgetReleaseUpEvent(self.mBigItemList[i], handler(self, self.onBigItemPushDown))
	end

	self:onBigItemPushDown(self.mBigItemList[self.mMainRank])
end

-- 大选项响应点击
function RankingWindow:onBigItemPushDown(widget)
	GUISystem:playSound("tabPageSound")
	--if widget:getTag() ~= 1 then return end 
	-- 清理
	self:cleanSmallItems()

	if self.mLastClickIndex and self.mLastClickIndex == widget:getTag() then
		-- 换图
		self.mBigItemList[self.mLastClickIndex]:getChildByName("Image_Bg"):loadTexture("rankinglist_page1_1.png")
		self.mLastClickIndex = nil
		return
	end
	-- 换图
	if self.mLastClickIndex then
		self.mBigItemList[self.mLastClickIndex]:getChildByName("Image_Bg"):loadTexture("rankinglist_page1_1.png")
	end
	self.mLastClickIndex = widget:getTag()
	-- 换图
	self.mBigItemList[self.mLastClickIndex]:getChildByName("Image_Bg"):loadTexture("rankinglist_page1_2.png")

	self.mMainRank   = widget:getTag()
 	
	-- 向下滑动BigItem
	local function doBigItemScroll()
		local index = widget:getTag() + 1
		for i = index, #bigItemInfo do
			local act0 = cc.MoveBy:create(moveTime, cc.p(0, -totalLength))
			self.mBigItemList[i]:runAction(act0)
		end

		self.mTopRoleInfoPanel.mTopWidget:getChildByName("Button_Back"):setTouchEnabled(true)
	end

	self:initSmallItem(widget)
	doBigItemScroll()    
end

-- 初始化小选项
function RankingWindow:initSmallItem(bigItem)
	local scrollWidget = self.mRootWidget:getChildByName("ScrollView_Page")

	local itemContentSize = GUIWidgetPool:createWidget("RankingList_Page2"):getContentSize()

	totalLength = itemContentSize.height * #bigItemInfo[self.mLastClickIndex].mContent

	for i = 1, #bigItemInfo[self.mLastClickIndex].mContent do
		self.mSmallItemList[i] = GUIWidgetPool:createWidget("RankingList_Page2")
		self.mSmallItemList[i]:getChildByName("Label_Name"):setString(bigItemInfo[self.mLastClickIndex].mContent[i])
		self.mSmallItemList[i]:setTag(i)
		scrollWidget:addChild(self.mSmallItemList[i], 5)
		self.mSmallItemList[i]:setPosition(cc.p(bigItem:getPosition()))
		registerWidgetPushDownEvent(self.mSmallItemList[i], handler(self, self.onSmallItemPushDown))
		local act0 = cc.MoveBy:create(moveTime, cc.p(0, -i*itemContentSize.height))
		self.mSmallItemList[i]:runAction(act0)
	end

 	if self.mMainRank == RANKTYPE.MAIN.HERO or self.mMainRank == RANKTYPE.MAIN.PARTY then 
		self.mMinorRank = 1
 	end

	self:onSmallItemPushDown(self.mSmallItemList[self.mMinorRank])
end

-- 响应小选项点击
function RankingWindow:onSmallItemPushDown(widget)
	GUISystem:playSound("tabPageSound")
	if self.mLastClickedSmallWidget == widget then return end
	-- 换图片

	if self.mLastClickedSmallWidget then
		self.mLastClickedSmallWidget:getChildByName("Image_Bg"):loadTexture("rankinglist_page2_1.png")
		self.mLastClickedSmallWidget:getChildByName("Label_Name"):getVirtualRenderer():setTextColor(G_COLOR_C4B.WHITE)	
		self.mLastClickedSmallWidget = widget
	else
		self.mLastClickedSmallWidget = widget
	end
	widget:getChildByName("Image_Bg"):loadTexture("rankinglist_page2_2.png")
	widget:getChildByName("Label_Name"):getVirtualRenderer():setTextColor(cc.c4b(0,255,186,255))

	self.mSmallCurSel = widget:getTag()
	self.mMinorRank   = widget:getTag()

	self.mModel.mDataSource = globaldata.rankArr[self.mMainRank][self.mMinorRank]
	self.mModel.mSelfRank   = globaldata.selfRank[self.mMainRank][self.mMinorRank]
	
	local sourceLength = ((self.mMainRank ~= RANKTYPE.MAIN.PARTY and #self.mModel.mDataSource - 1) or #self.mModel.mDataSource)

	if sourceLength > 0 and self.mRankListView then
		self.mRankListView:UpdateTableView()
		self:setSelfPanelLayout()
	else
		self.mModel:reload()
	end
end
	
-- 清理小选项
function RankingWindow:cleanSmallItems()
	local nums = table.getn(self.mSmallItemList)
	if nums == 0 then return end

	for i = 1, nums do 
		self.mSmallItemList[i]:removeFromParent(true)
	end

	self.mSmallItemList = {}
	self.mLastClickedSmallWidget = nil

	for i = self.mLastClickIndex+1, #bigItemInfo do
		local posX = self.mBigItemList[i]:getPositionX()
		local posY = self.mBigItemList[i]:getPositionY()
		posY = posY + totalLength
		self.mBigItemList[i]:setPosition(cc.p(posX, posY))
	end
end

function RankingWindow:onReceivePlayInfo() --ShowPlayerInfo(index)
	local widget =  GUIWidgetPool:createWidget("FriendsPlayerWindow")
	local playerInfoWidget = GUIWidgetPool:createWidget("PlayerInfo")
	--local rankInfo   = self.mModel.mDataSource[index]
	--if rankInfo == nil then return end
	widget:getChildByName("Panel_PlayInfo"):addChild(playerInfoWidget)
    self.mRootWidget:addChild(widget)

    widget:getChildByName("Label_Banghui"):setString(globaldata.cityPlayer.banghuiName)

    registerWidgetReleaseUpEvent(widget:getChildByName("Button_Add"), function() GUISystem:playSound("homeBtnSound") self.mModel:doAddFriendRequest() end)
    registerWidgetReleaseUpEvent(widget:getChildByName("Button_Delete"), function() GUISystem:playSound("homeBtnSound") self.mModel:doDelFriendRequest() end)
    registerWidgetReleaseUpEvent(widget:getChildByName("Button_Chat"), function() GUISystem:playSound("homeBtnSound") self.mModel:doChatRequest() end)
    registerWidgetReleaseUpEvent(widget:getChildByName("Button_Fight"),function() GUISystem:playSound("homeBtnSound") self.mModel:doPKRequest() end)

    --ShaderManager:DoUIWidgetDisabled(widget:getChildByName("Button_Visit"), true)
    --widget:getChildByName("Button_Visit"):setEnabled(false)

    local function setDlgLayOut()
    	if globaldata.cityPlayer.isfriend == 0 then
		    widget:getChildByName("Button_Add"):setVisible(false)
		    widget:getChildByName("Button_Delete"):setVisible(true)
		else
		    widget:getChildByName("Button_Add"):setVisible(true)
		    widget:getChildByName("Button_Delete"):setVisible(false)
		end
		playerInfoWidget:getChildByName("Image_PlayerHead_Bg"):loadTexture(FindFrameIconbyId(globaldata.cityPlayer.playerFrame))
   		playerInfoWidget:getChildByName("Image_PlayerHead"):loadTexture(FindFrameIconbyId(globaldata.cityPlayer.playerIcon))
    	playerInfoWidget:getChildByName("Label_Level"):setString(tostring(globaldata.cityPlayer.playerLevel))
    	playerInfoWidget:getChildByName("Label_Name"):setString(globaldata.cityPlayer.playerName)
    	playerInfoWidget:getChildByName("Label_Zhanli"):setString(tostring(globaldata.cityPlayer.playerZhanli))

		for i = 1, globaldata.cityPlayer.heroCount do
		  local heroWidget = createHeroIcon(globaldata.cityPlayer.hero[i].heroId, globaldata.cityPlayer.hero[i].level, globaldata.cityPlayer.hero[i].quality, globaldata.cityPlayer.hero[i].advanceLevel)
		  widget:getChildByName("Panel_Hero"..i):addChild(heroWidget)
		end
		-- 排名
		self.mRootWidget:getChildByName("Label_Ranking"):setString(tostring(globaldata.cityPlayer.playerRank))
    end
    setDlgLayOut()
    -- 关闭窗口
	registerWidgetReleaseUpEvent(widget,function() widget:removeFromParent(true);widget = nil end)
end

function RankingWindow:Destroy()
	if self.mRankListView ~= nil then
		self.mRankListView:Destroy()
		self.mRankListView     = nil
	end

	if self.mTopRoleInfoPanel ~= nil then
		self.mTopRoleInfoPanel:destroy()
		self.mTopRoleInfoPanel = nil
	end

	if self.mRootNode ~= nil then
		self.mRootNode:removeFromParent(true)
		self.mRootNode         = nil
	end
	self.mRootWidget       = nil

	self.mModel:destroyInstance()

	self.mBigItemList	   = {}
	self.mSmallItemList    = {}
	self.mLastClickIndex   = nil
	self.mLastClickedSmallWidget = nil
	self.mSmallCurSel	   = nil
	self.mLadderScore 	   =  {}
	
	CommonAnimation.clearAllTextures()
end

function RankingWindow:onEventHandler(event)
	if event.mAction == Event.WINDOW_SHOW then
		GUIWidgetPool:preLoadWidget("RankingList_Player", true)
		GUIWidgetPool:preLoadWidget("RankingList_Page1", true)
		GUIWidgetPool:preLoadWidget("RankingList_Page2", true)
		GUIWidgetPool:preLoadWidget("PlayerHead", true)
		self:Load(event)
		---------停止画主城镇界面
		EventSystem:PushEvent(Event.GUISYSTEM_DISABLEDRAW_HOMEWINDOW)
		---------
	elseif event.mAction == Event.WINDOW_HIDE then
		GUIWidgetPool:preLoadWidget("RankingList_Player", false)
		GUIWidgetPool:preLoadWidget("RankingList_Page1", false)
		GUIWidgetPool:preLoadWidget("RankingList_Page2", false)
		GUIWidgetPool:preLoadWidget("PlayerHead", false)
		self:Destroy()
		---------开启画主城镇界面
		EventSystem:PushEvent(Event.GUISYSTEM_EABLEDRAW_HOMEWINDOW)
		---------
	end
end

return RankingWindow