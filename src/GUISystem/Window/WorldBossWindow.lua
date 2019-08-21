-- Name: 	WorldBossWindow
-- Func：	世界boss界面
-- Author:	tuanzhang
-- Data:	16-03-16

--==========================================================recordTv begin ==================================================================
BossTableView = {}

function BossTableView:new(owner,listType)
	local o = 
	{
		mOwner			  = owner,
		mRootNode 	      =	nil,
		mType 		      =	listType,
		mTableView	      =	nil,
	}
	o = newObject(o, BossTableView)
	return o
end

function BossTableView:Destroy()
	self.mRootNode:removeFromParent(true)
	self.mRootNode     = nil
	self.mTableView    = nil
	self.mOwner        = nil
end

function BossTableView:myModel()
	return self.mOwner.mModel
end

function BossTableView:init(rootNode)
	self.mRootNode = rootNode
	-- 初始化数据源
	self:initTableView()
end

function BossTableView:initTableView()
	self.mTableView = TableViewEx:new()

	local widget = GUIWidgetPool:createWidget("WorldBoss_RankingCell")

	self.mTableView:setCellSize(widget:getContentSize())
	self.mTableView:setCellCount(#self:myModel().mRanklist)

	self.mTableView:registerTableCellAtIndexFunc(handler(self, self.tableCellAtIndex))
	self.mTableView:registerTableCellTouchedFunc(handler(self, self.tableCellTouched))

	self.mTableView:init(self.mRootNode:getContentSize(), cc.p(0,0), 1)
	self.mRootNode:addChild(self.mTableView:getRootNode())
end

function BossTableView:tableCellAtIndex(table, index)
	local cell = table:dequeueCell()
	local applyItem = nil

	if nil == cell then
		cell = cc.TableViewCell:new()
		applyItem = GUIWidgetPool:createWidget("WorldBoss_RankingCell")
		
		applyItem:setTouchSwallowed(false)
		applyItem:setTag(1)
		cell:addChild(applyItem)
	else
		applyItem = cell:getChildByTag(1)
	end

	if #self:myModel().mRanklist ~= 0 then
		self:setCellLayOut(applyItem,index)
	end
	
	return cell
end

function BossTableView:setCellLayOut(widget,index)
	index = index + 1
	local deque = self:myModel().mRanklist[index]
	
	--widget:getChildByName("Label_Time"):setString(deque[index + 1][1])
	--widget:getChildByName("Label_PlayerName"):setString(deque[index + 1][2])
	--widget:getChildByName("Label_Event"):setString(deque[index + 1][3])
	widget:getChildByName("Image_Ranking"):setVisible(false)
	widget:getChildByName("Label_Ranking_Stroke"):setVisible(false)

	for i=1,2 do
		widget:getChildByName(string.format("Panel_Reward_%d",i)):removeAllChildren()
	end
	for i=1,deque.rewardsNum do
		local itemdata = deque.Rewards[i]
		local item = createCommonWidget(itemdata.itemType,itemdata.itemId,itemdata.itemNum)
		widget:getChildByName(string.format("Panel_Reward_%d",i)):addChild(item)
	end
	widget:getChildByName("Label_TotalZhanli_Stroke_163_55_8"):setString(tostring(deque.fightPower))
	widget:getChildByName("Label_Damage"):setString(string.format("伤害量%d",deque.damage))
	widget:getChildByName("Label_PlayerName"):setString(deque.name)

	local playerHead = GUIWidgetPool:createWidget("PlayerHead")
	playerHead:getChildByName("Panel_7"):setTouchEnabled(false) 
	playerHead:getChildByName("Image_PlayerHead_Bg"):loadTexture(FindFrameIconbyId(deque.frameId))
	playerHead:getChildByName("Image_PlayerHead"):loadTexture(FindFrameIconbyId(deque.iconId))
	playerHead:getChildByName("Label_Level"):setString(tostring(deque.level))
	widget:getChildByName("Panel_PlayerInfo"):removeAllChildren()
	widget:getChildByName("Panel_PlayerInfo"):addChild(playerHead)

	if deque.rank < 4  then
		widget:getChildByName("Image_Ranking"):setVisible(true)
		widget:getChildByName("Image_Ranking"):loadTexture(string.format("rankinglist_no%d.png",deque.rank))
	else
		widget:getChildByName("Label_Ranking_Stroke"):setVisible(true)
		widget:getChildByName("Label_Ranking_Stroke"):setString(tostring(deque.rank))
	end
end

function BossTableView:tableCellTouched(table,cell)
	print("RecordTableView cell touched at index: " .. cell:getIdx())
	local index = cell:getIdx() + 1
	local deque = self:myModel().mRanklist[index]
	local playerid = deque.playerId
	if playerid == globaldata.playerId then return end
	local packet = NetSystem.mNetManager:GetSPacket()
	packet:SetType(PacketTyper._PTYPE_CS_REQUEST_PLAYER_INFO_)
	packet:PushString(playerid)
	packet:Send()
	globaldata.requestType = "worldplayerinfo"
	GUISystem:showLoading()
end

function BossTableView:UpdateTableView(cellCnt) --move table to cur cell after reload
	self.mTableView:setCellCount(cellCnt)

	--local curOffset = self.mTableView.mInnerContainer:getContentOffset()
	--local curHeight = self.mTableView.mInnerContainer:getContentSize().height
	self.mTableView:reloadData()
	--self.mTableView.mInnerContainer:setContentOffset(cc.p(0,self.mTableView.mInnerContainer:getViewSize().height - self.mTableView.mInnerContainer:getContentSize().height))
	--local height = self.mTableView.mInnerContainer:getContentSize().height
	--curOffset.y = curOffset.y + (curHeight - height)
	--self.mTableView.mInnerContainer:setContentOffset(curOffset)
end

-- 世界信息
local WBInstance = nil

WorldBossModel = class("WorldBossModel")

function WorldBossModel:ctor()
	self.mName          = "WorldBossModel"
	self.mOwner         = nil
	self.mheroGroup     = nil
	self.mleftTime 		= nil
	self.mMyBossRank	= nil
	self.mMyRewardsCount= nil
	self.mMyRewards		= {}
	self.mMaxDamage 	= nil
	self.mLeftChallengeCount = nil
	self.mMaxChallengeCount = nil
	self.mRanklist		= {}
	self.mRankTotal     = nil
	self.mEnterFun		= nil
	self:registerNetEvent()

end

function WorldBossModel:getInstance()
	if WBInstance == nil then  
        WBInstance = WorldBossModel.new()
    end  
    return WBInstance
end

function WorldBossModel:destroyInstance()
	if WBInstance then
		WBInstance:deinit()
    	WBInstance = nil
    end
end

function WorldBossModel:deinit()
    self.mOwner         = nil
	self.mheroGroup     = nil
	self.mleftTime 		= nil
	self.mMyBossRank	= nil
	self.mMyRewardsCount= nil
	self.mMyRewards		= {}
	self.mMaxDamage 	= nil
	self.mLeftChallengeCount = nil
	self.mMaxChallengeCount = nil
	self.mRanklist		= {}
	self.mRankTotal     = nil
	self.mEnterFun		= nil
	self:unRegisterNetEvent()
end

function WorldBossModel:setOwner(owner)
	self.mOwner = owner
end

function WorldBossModel:registerNetEvent()
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_BOSS_REQUEST_BACK_, handler(self, self.onBossEnterInfoResponse))
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_BOSSRANK_REQUEST_BACK_, handler(self, self.onBossRankInfoResponse))
end

function WorldBossModel:unRegisterNetEvent()
	NetSystem.mNetManager:UnregisterPacketHandler(PacketTyper._PTYPE_SC_BOSS_REQUEST_BACK_)
	NetSystem.mNetManager:UnregisterPacketHandler(PacketTyper._PTYPE_SC_BOSSRANK_REQUEST_BACK_)
end

function WorldBossModel:onBossEnterInfoResponse(msgPacket)
	GUISystem:hideLoading()
	if self.mEnterFun then
		self.mEnterFun()
		self.mEnterFun = nil
	end
	self.mheroGroup     = msgPacket:GetInt()
	self.mleftTime 		= msgPacket:GetInt()
	self.mMyBossRank	= msgPacket:GetInt()
	self.mMyRewardsCount= msgPacket:GetUShort()
	for i=1,self.mMyRewardsCount do
		local item = {}
		item.itemType = msgPacket:GetInt()
		item.itemId =  msgPacket:GetInt()
		item.itemNum = msgPacket:GetInt()
		self.mMyRewards[i] = item
	end

	self.mMaxDamage 	= msgPacket:GetInt()
	self.mLeftChallengeCount = msgPacket:GetInt()
	self.mMaxChallengeCount = msgPacket:GetInt()
	if self.mOwner and self.mOwner.mRootNode then
		self.mOwner:UpdateLayout()
	else
		EventSystem:PushEvent(Event.GUISYSTEM_SHOW_WORLDBOSSWINDOW)	
	end

end

function WorldBossModel:onBossRankInfoResponse(msgPacket)
	GUISystem:hideLoading()
	self.mRanklist = {}
	self.mRankTotal = msgPacket:GetUShort()
	for i=1,self.mRankTotal do
		local palyerinfo = {}
		palyerinfo.rank = msgPacket:GetInt()
		palyerinfo.playerId = msgPacket:GetString()
		palyerinfo.name = msgPacket:GetString()
		palyerinfo.frameId = msgPacket:GetInt()
		palyerinfo.iconId = msgPacket:GetInt()
		palyerinfo.level = msgPacket:GetInt()
		palyerinfo.fightPower = msgPacket:GetInt()
		palyerinfo.damage = msgPacket:GetInt()
		palyerinfo.rewardsNum = msgPacket:GetUShort()
		palyerinfo.Rewards = {}
		for j=1,palyerinfo.rewardsNum do
			local item = {}
			item.itemType = msgPacket:GetInt()
			item.itemId =  msgPacket:GetInt()
			item.itemNum = msgPacket:GetInt()
			palyerinfo.Rewards[j] = item
		end
		self.mRanklist[i] = palyerinfo
	end
	self.mOwner:ShowRanklist()
end

function WorldBossModel:onBossEnterRequst()
	local packet = NetSystem.mNetManager:GetSPacket()
    packet:SetType(PacketTyper._PTYPE_CS_BOSS_REQUEST_)
    packet:Send()
    GUISystem:showLoading()
end

function WorldBossModel:onBossRankListRequst()
	local packet = NetSystem.mNetManager:GetSPacket()
    packet:SetType(PacketTyper._PTYPE_CS_BOSSRANK_REQUEST_)
    packet:Send()
    GUISystem:showLoading()
end

-- 请求挑战boss
function WorldBossModel:onBossFightRequst(heros)
	local packet = NetSystem.mNetManager:GetSPacket()
    packet:SetType(PacketTyper._PTYPE_CS_BOSSFIGHT_REQUEST_)
    packet:PushUShort(#heros) 
    for i=1,#heros do
		packet:PushInt(heros[i])
	end
    packet:Send()
    GUISystem:showLoading()
end


local WorldBossWindow = 
{
	mName					=	"WorldBossWindow",
	mRootNode				=	nil,
	mRootWidget				=	nil,
	----------------------------------------	
}

function WorldBossWindow:Release()

end

function WorldBossWindow:Load()
	cclog("=====WorldBossWindow:Load=====begin")

	self.mRootNode = cc.Node:create()
	GUISystem:GetRootNode():addChild(self.mRootNode)
	self:InitModelData()
	------

	self:InitLayout()

	local function doWorldBossGuideOne_Stop()
		WorldBossGuideOne:stop()
	end
	WorldBossGuideOne:step(1, nil, doWorldBossGuideOne_Stop)
	
	cclog("=====WorldBossWindow:Load=====end")
end

function WorldBossWindow:InitModelData()
	self.mModel = WorldBossModel:getInstance()
	self.mModel:setOwner(self)
end

function WorldBossWindow:InitLayout()

	self.mRootWidget = GUIWidgetPool:createWidget("WorldBoss")
	self.mRootNode:addChild(self.mRootWidget)
	self.mMainWidget = self.mRootWidget:getChildByName("Panel_Window")
	self.mPanelSection = self.mRootWidget:getChildByName("Panel_Section")
	self.mPanelBottom = self.mRootWidget:getChildByName("Panel_Bottom")
	self.mPanelBossPic = self.mRootWidget:getChildByName("Panel_BossPic")
	self.mTimeLabel = self.mPanelBottom:getChildByName("Label_LastTime")
	
	self.mPanelBottom:getChildByName("Label_MyRanking"):setString(string.format("%d名",self.mModel.mMyBossRank))
	self.mPanelBottom:getChildByName("Label_Damage"):setString(tostring(self.mModel.mMaxDamage))
	self.mPanelBottom:getChildByName("Label_LastTimes"):setString(string.format("剩余次数 %d/%d",self.mModel.mLeftChallengeCount,self.mModel.mMaxChallengeCount))

	for i=1,self.mModel.mMyRewardsCount do
		local item = self.mModel.mMyRewards[i]
		local widget = createCommonWidget(item.itemType,item.itemId,item.itemNum)
		self.mPanelBottom:getChildByName(string.format("Panel_Reward_%d",i)):addChild(widget)
	end

	local function closeWindow()
		if __IsEnterFightWindow__ then
			local function callFun()
				EventSystem:PushEvent(Event.GUISYSTEM_HIDE_WORLDBOSSWINDOW)
				showLoadingWindow("HomeWindow")
				__IsEnterFightWindow__ = false
			end
		    FightSystem:sendChangeCity(false,callFun)
			
		else
			EventSystem:PushEvent(Event.GUISYSTEM_HIDE_WORLDBOSSWINDOW)
		end	
	end
	self.mTopRoleInfoPanel = TopRoleInfoPanel:new()
	local topInfoPanel = self.mTopRoleInfoPanel:init(self.mRootNode,ROLE_TITLE_TYPE.TITLE_WORLDBOSS,closeWindow)
	local function doAdapter()
	    local topInfoPanelSize = topInfoPanel:getContentSize()
	    local newHeight = getGoldFightPosition_LU().y - topInfoPanelSize.height - getGoldFightPosition_LD().y
	    local newPosY = newHeight/2 + getGoldFightPosition_LD().y - self.mMainWidget:getContentSize().height/2
		self.mMainWidget:setPositionY(newPosY)
		self.mMainWidget:setVisible(true)

	end
	doAdapter()
	self:ChangeBossinfo(self.mModel.mheroGroup)

	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_RankingList"), handler(self,self.onRank))
	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_Rule"), handler(self,self.onRule))
	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_Fight"), handler(self,self.ongoFight))
	self.mTimeScheduler = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self, self.UpdateTimeLine), 1, false)
	self.mLeftTime = self.mModel.mleftTime
	self.mTimeLabel:setString(timeFormat(self.mLeftTime))
end

function WorldBossWindow:UpdateLayout()
	self.misWaitUpdate = nil
	self.mLeftTime = self.mModel.mleftTime
	self.mTimeLabel:setString(timeFormat(self.mLeftTime))
	self.mPanelBottom:getChildByName("Label_MyRanking"):setString(string.format("%d名",self.mModel.mMyBossRank))
	self.mPanelBottom:getChildByName("Label_Damage"):setString(tostring(self.mModel.mMaxDamage))
	self.mPanelBottom:getChildByName("Label_LastTimes"):setString(string.format("剩余次数 %d/%d",self.mModel.mLeftChallengeCount,self.mModel.mMaxChallengeCount))
	for i=1,self.mModel.mMyRewardsCount do
		local item = self.mModel.mMyRewards[i]
		local widget = createCommonWidget(item.itemType,item.itemId,item.itemNum)
		self.mPanelBottom:getChildByName(string.format("Panel_Reward_%d",i)):addChild(widget)
	end
	self:ChangeBossinfo(self.mModel.mheroGroup)
end

function WorldBossWindow:UpdateTimeLine()
	if self.misWaitUpdate then return end
	self.mTimeLabel:setString(timeFormat(self.mLeftTime))
	self.mLeftTime = self.mLeftTime - 1
	if self.mLeftTime < 0 then
		self.mLeftTime = 0
		self.misWaitUpdate = true
		GUISystem:showLoading()
		WorldBossModel:getInstance():onBossEnterRequst()
	end
end

function WorldBossWindow:doBossFightRequest(_heros)
	self.mModel:onBossFightRequst(_heros)
end

function WorldBossWindow:ongoFight()
	if self.mModel.mLeftChallengeCount == 0 then
		local packet = NetSystem.mNetManager:GetSPacket()
	    packet:SetType(PacketTyper._PTYPE_CS_BOSSFIGHT_BUY_)
	    packet:Send()
	    GUISystem:showLoading()
		return
	end
	ShowRoleSelWindow(self,function(heros) self:doBossFightRequest(heros) end,{0,0,0},SELECTHERO.SHOWSELF)
end

function WorldBossWindow:onRule()
	self.mNodeRule = GUIWidgetPool:createWidget("WorldBoss_Rule")
	local textData = DB_Text.getDataById(1731)
	local textStr  = textData.Text_CN
	richTextCreate(self.mNodeRule:getChildByName("Panel_Text"),textStr,true,nil,false)
	self.mRootNode:addChild(self.mNodeRule,101)
	local function closeRank()
		self.mNodeRule:removeFromParent()
	end
	registerWidgetReleaseUpEvent(self.mNodeRule:getChildByName("Button_Close"), closeRank)
end

function WorldBossWindow:onRank()
	self.mModel:onBossRankListRequst()
end

function WorldBossWindow:ShowRanklist()
	self.mNodeRank = GUIWidgetPool:createWidget("WorldBoss_RankingList")
	self.mRootNode:addChild(self.mNodeRank,101)

	self.mBossTableView = BossTableView:new(self,0)
	self.mBossTableView:init(self.mNodeRank:getChildByName("Panel_List"))

	local function closeRank()
		self.mNodeRank:removeFromParent()
	end
	registerWidgetReleaseUpEvent(self.mNodeRank:getChildByName("Button_Close"), closeRank)
end

function WorldBossWindow:onReceivePlayInfo(data)
	if not self.mRootNode then return end
	if self.mPlayerInfo then
		self.mPlayerInfo:removeFromParent()
		self.mPlayerInfo = nil
	end
	self.mPlayerInfo = CheckPlayerInfo.new(data)
	self.mRootNode:addChild(self.mPlayerInfo,110)
	registerWidgetReleaseUpEvent(self.mPlayerInfo.mRootWidget:getChildByName("Panel_20"), handler(self, self.PlayerInfoTouch))
end

function WorldBossWindow:PlayerInfoTouch()
	if self.mPlayerInfo then
		self.mPlayerInfo:removeFromParent()
		self.mPlayerInfo = nil
	end
end

function WorldBossWindow:ChangeBossinfo(index)
	local IconID = 219
	if index == 2 then
		IconID = 211
	elseif index == 3 then
		IconID = 228
	end
	local _resDB = DB_ResourceList.getDataById(IconID)
	for i=1,3 do
		local panel = self.mPanelSection:getChildByName(string.format("Panel_Boss_%d",i))
		ShaderManager:DoUIWidgetDisabled(panel:getChildByName("Image_Boss_Pic"), false)
		if index == i then
			panel:getChildByName("Image_Bg"):loadTexture("worldboss_boss_bg_1.png")
			self.mPanelBottom:getChildByName("Image_BossName"):loadTexture(string.format("worldboss_boss_name_%d.png",index))
			self.mRootWidget:getChildByName("Image_SceneBg"):loadTexture(string.format("worldboss_bg_%d.png",index))
			self.mPanelBossPic:getChildByName(string.format("Image_BossPic_%d",i)):setVisible(true)
			self.mPanelBossPic:getChildByName(string.format("Image_BossPic_%d",i)):loadTexture(_resDB.Res_path1)
		else
			ShaderManager:DoUIWidgetDisabled(panel:getChildByName("Image_Boss_Pic"), true)
			panel:getChildByName("Image_Bg"):loadTexture("worldboss_boss_bg_2.png")
			self.mPanelBossPic:getChildByName(string.format("Image_BossPic_%d",i)):setVisible(false)
		end
	end
end

function WorldBossWindow:Destroy()
	self.misWaitUpdate = nil
	if self.mTimeScheduler then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.mTimeScheduler)
		self.mTimeScheduler = nil
	end
	self.mTopRoleInfoPanel:destroy()
	self.mTopRoleInfoPanel = nil

	if self.TempTeamCell then
		self.TempTeamCell:release()
		self.TempTeamCell = nil
	end

	self.mRootNode:removeFromParent(true)
	self.mRootNode = nil
	self.mRootWidget = nil
	self.mModel:destroyInstance()
	self.mModel = nil

	------------
	CommonAnimation.clearAllTextures()
end

function WorldBossWindow:DisableDraw()
	if self.mRootWidget then
		self.mRootWidget:setVisible(false)
	end
end

function WorldBossWindow:EnableDraw()
	if self.mRootWidget then
		self.mRootWidget:setVisible(true)
	end
end

function WorldBossWindow:onEventHandler(event)
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
	elseif event.mAction == Event.WINDOW_ENABLE_DRAW then
		self:EnableDraw()
	elseif event.mAction == Event.WINDOW_DISABLE_DRAW then
		self:DisableDraw()
	end
end

return WorldBossWindow