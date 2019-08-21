-- Name: 	ArenaWindow
-- Func：	武道馆
-- Author:	WangShengdong
-- Data:	14-1-20

-- local textSource = 
-- {
-- 	{
-- 		"text" 	= "哈哈哈",
-- 		"color" = cc.c3b(255, 255, 255),
-- 	},

-- }

local function getCompareResult(val1, val2)
	if val1 == val2 then
		return false, false
	end
	if 1 == val1 then
		if 2 == val2 then
			return "public_arrow2.png", "public_arrow3.png"
		elseif 3 == val2 then
			return "public_arrow3.png", "public_arrow2.png"
		end
	elseif 2 == val1 then 
		if 1 == val2 then
			return "public_arrow3.png", "public_arrow2.png"
		elseif 3 == val2 then
			return "public_arrow2.png", "public_arrow3.png"
		end
	elseif 3 == val1 then
		if 1 == val2 then
			return "public_arrow2.png", "public_arrow3.png"
		elseif 2 == val2 then
			return "public_arrow3.png", "public_arrow2.png"
		end
	end
end

__IsEnterFightWindow__  =  false

-- 秒转时间
local function secondToHour(seconds)
	if not seconds or seconds <= 0 then
	return "领 奖"
	end
	local hour = math.floor(seconds / 3600)
	seconds = math.mod(seconds, 3600)
	local min = math.floor(seconds / 60)
	seconds = math.mod(seconds, 60)
	local sec = seconds
	return string.format("%02d:%02d", min, sec).." 后领奖"
end

local ArenaWindow = 
{ 
	mName				=	"ArenaWindow",
	mIsLoaded 		    =   false,
	mRootNode 			= 	nil,
	mRootWidget 		= 	nil,
	mTopRoleInfoPanel	=	nil,
	mArenaInfo 			=	nil,
	-------------------------------------
	mPlayerInfoWindow 	=	nil,  	-- 玩家信息窗口
	mLogWindow 			=	nil,  	-- 战报窗口
	mLastChooseWidget 	= 	nil,
	mFormationSetWindow = 	nil,    -- 防守阵容调整窗口
	mAttackSetWindow 	=	nil,    -- 进攻阵容调整窗口
	mHeroAnimList		=	{},	    -- Spine列表
	mRuleWindow			=	nil,    -- 规则窗口
	mRewardSecondsLeft	=	nil,    -- 领奖剩余秒数
	mSchedulerHandler 	=	nil,	-- 定时器
}

local arenaPlayerWidget = nil

function ArenaWindow:Release()

end

function ArenaWindow:Load(event)
	cclog("=====ArenaWindow:Load=====begin")

	-- 播所属城镇bgm
	HallManager:playHallBGMAfterDestroyed()

	arenaPlayerWidget = GUIWidgetPool:createWidget("ArenaPlayer")
	arenaPlayerWidget:retain()
	----
	self.mIsLoaded = true
	self.mCanRefresh = true --可以刷新挑战者
	GUIEventManager:registerEvent("arenaChallCountChanged", self, self.onArenaChallCountChanged)
	GUIEventManager:registerEvent("roleBaseInfoChanged", self, self.onNailiInfoChanged)

	-- 请求竞技场数据
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_REQUEST_ARENA_, handler(self,self.onRequestDoArenaFresh))
	-- 请求竞技场战报
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_REQUEST_ARENALOG_, handler(self,self.onRequestArenaLog))
	-- 请求竞技场奖励
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_ARENA_REWARD_INFO, handler(self,self.onRequestArenaReward))

	self.mRootNode = cc.Node:create()
	GUISystem:GetRootNode():addChild(self.mRootNode)

	self.mArenaInfo = event.mData

	self:InitLayout(event)

	self:initArenaData()

	self:showCombat()

	self:initTick()
	self:tick()

	local function doArenaGuideOne_Step5()
		local guideBtn = self.mRootWidget:getChildByName("Button_DefensiveTeam")
		local size = guideBtn:getContentSize()
		local pos = guideBtn:getWorldPosition()
		pos.x = pos.x - size.width/2
		pos.y = pos.y - size.height/2
		local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
		ArenaGuideOne:step(5, touchRect)
	end
	ArenaGuideOne:step(4, nil, doArenaGuideOne_Step5)

	if ArenaGuideTwo:canGuide() then
		local guideBtn = self.mRootWidget:getChildByName("Button_Reward")
		local size = guideBtn:getContentSize()
		local pos = guideBtn:getWorldPosition()
		pos.x = pos.x - size.width/2
		pos.y = pos.y - size.height/2
		local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
		ArenaGuideTwo:step(1, touchRect)
	end

	cclog("=====ArenaWindow:Load=====end")
end

function ArenaWindow:onNailiInfoChanged()
	-- 积分
	self.mRootWidget:getChildByName("Label_TokenNum"):setString(globaldata.naili)
end

-- 初始化定时器
function ArenaWindow:initTick()
	if not self.mSchedulerHandler then
		local scheduler = cc.Director:getInstance():getScheduler()
		self.mSchedulerHandler = scheduler:scheduleScriptFunc(handler(self, self.tick), 1, false)
	end
end

-- 刷新
function ArenaWindow:tick()
	self.mArenaInfo.rewardSecondsLeft = self.mArenaInfo.rewardSecondsLeft - 1
	if self.mArenaInfo.rewardSecondsLeft <= 0 then
		self.mArenaInfo.rewardSecondsLeft = 0
	end
	self.mRootWidget:getChildByName("Label_LastTime_Stroke_204_66_34"):setString(secondToHour(self.mArenaInfo.rewardSecondsLeft))
end

-- 销毁定时器
function ArenaWindow:destroyTick()
	if self.mSchedulerHandler then
		local scheduler = cc.Director:getInstance():getScheduler()
		scheduler:unscheduleScriptEntry(self.mSchedulerHandler)
		self.mSchedulerHandler = nil
	end
end

function ArenaWindow:onArenaChallCountChanged(count)
	self.mArenaInfo.leftTimes = count
	-- 挑战次数
	self.mRootWidget:getChildByName("Label_Times"):setString(tostring(self.mArenaInfo.leftTimes).."/"..tostring(self.mArenaInfo.maxTimes))
	if count <= 0 then
		self:setBuyCountEnabled(true)
	else
		self:setBuyCountEnabled(false)
	end
end

-- 请求购买次数
function ArenaWindow:requestBuyCount()
	GUISystem:playSound("homeBtnSound")
	local packet = NetSystem.mNetManager:GetSPacket()
	packet:SetType(PacketTyper._PTYPE_CS_ARENA_BUY_COUNT_)
	packet:Send()
	GUISystem:showLoading()
end

-- 设置购买按钮是否可用
function ArenaWindow:setBuyCountEnabled(enabled)
	self.mRootWidget:getChildByName("Button_BuyCount"):setVisible(enabled)
end

function ArenaWindow:initArenaData()
	-- 自身队伍
	-- for i = 1, 5 do
	-- 	local heroId = globaldata:getHeroInfoByBattleIndex(i, "id")
	-- 	if heroId then
	-- 		local heroWidget = createHeroIcon(heroId, globaldata:getHeroInfoByBattleIndex(i, "level"), globaldata:getHeroInfoByBattleIndex(i, "quality"), 
	-- 			globaldata:getHeroInfoByBattleIndex(i, "advanceLevel"))
			
	-- 		self.mRootWidget:getChildByName("Panel_HeroBg_"..i):addChild(heroWidget)
	-- 	end
	-- end

	self:UpdateBattleTeamPanel()
	-- 排名
	self.mRootWidget:getChildByName("BitmapLabel_MyRanking"):setString(tostring(self.mArenaInfo.rank))
	-- 战斗力

--	self.mRootWidget:getChildByName("Label_capValue"):setString(tostring(self.mArenaInfo.fightPower))
	-- 积分增长率
	self.mRootWidget:getChildByName("Label_Shengwang_Grow"):setString(tostring(self.mArenaInfo.score))
	-- 积分
	self.mRootWidget:getChildByName("Label_TokenNum"):setString(tostring(self.mArenaInfo.totalScore))
	-- 挑战次数
	self.mRootWidget:getChildByName("Label_Times"):setString(tostring(self.mArenaInfo.leftTimes).."/"..tostring(self.mArenaInfo.maxTimes))
	
	if self.mArenaInfo.leftTimes <= 0 then
		self:setBuyCountEnabled(true)
	else
		self:setBuyCountEnabled(false)
	end

	local function xxx()
		if self.mRootNode then
			-- 可挑战玩家
			for i = 1, self.mArenaInfo.playerCount do
				local heroWidget = self:createCanAttackPlayer(self.mArenaInfo.canAttackPlayer[i])
				heroWidget:setTag(i)
				registerWidgetReleaseUpEvent(heroWidget, handler(self, self.setHeroSelected))
				self.mRootWidget:getChildByName("Panel_Player_"..tostring(i)):removeAllChildren()
				self.mRootWidget:getChildByName("Panel_Player_"..tostring(i)):addChild(heroWidget)	
			end
		end
	end
	SpineDataCacheManager:applyForAddSpineDataCache(xxx)
end

-- 进入商店
function ArenaWindow:gotoShop(widget)
	GUISystem:playSound("homeBtnSound")
	local function onRequestEnterShop(msgPacket)
		globaldata:updateGoodsInfoFromServerPacket(msgPacket)
		Event.GUISYSTEM_SHOW_SHOPWINDOW.mData = 3
		EventSystem:PushEvent(Event.GUISYSTEM_SHOW_SHOPWINDOW)
		GUISystem:hideLoading()
	end

	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_REQUEST_GOODSINFO_, onRequestEnterShop)

	local function requestEnterShop()
		local packet = NetSystem.mNetManager:GetSPacket()
		packet:SetType(PacketTyper._PTYPE_CS_REQUEST_GOODSINFO_)
		packet:PushChar(3)
		packet:Send()
		GUISystem:showLoading()
	end
	requestEnterShop()
end

-- 创建可以挑战的英雄
function ArenaWindow:createCanAttackPlayer(playerInfo)
	local widget = arenaPlayerWidget:clone()
	-- 名字
	widget:getChildByName("Label_PlayerName_Stroke"):setString(playerInfo.playerName)
	-- 排名
	widget:getChildByName("Label_Ranking_Stroke_129_20_0"):setString(tostring(playerInfo.playerRank).."名")
	-- 战力
	widget:getChildByName("Label_Zhanli"):setString(tostring(playerInfo.playerZhanli))
	-- 英雄
	local function xxx()
		local heroAnim = SpineDataCacheManager:getSimpleSpineByHeroID(playerInfo.hero[1].heroId, widget:getChildByName("Panel_Captain"))
		heroAnim:setSkeletonRenderType(cc.RENDER_TYPE_HERO)
		widget:getChildByName("Panel_Captain"):setScale(1)

		-- 设置缩放
		local heroData = DB_HeroConfig.getDataById(playerInfo.hero[1].heroId)
		heroAnim:setScale(heroData.UIResouceZoom)
		heroAnim:setAnimation(0, "stand", true)

		table.insert(self.mHeroAnimList, heroAnim)
	end
	xxx()

	registerWidgetReleaseUpEvent(widget:getChildByName("Button_Fight"), handler(self, self.OnChallenge))
	widget:getChildByName("Button_Fight"):setTag(playerInfo.playerRank)
	self.mCanGoChallenge = false
	local function CanChallenge()
		self.mCanGoChallenge = true
		GUISystem:enableUserInput()
	end 
	nextTick(CanChallenge)
	GUISystem:disableUserInput()

	return widget
end

-- 显示规则窗口
function ArenaWindow:showRuleWindow()
	self.mRuleWindow = GUIWidgetPool:createWidget("Arena_Rule")
	self.mRootNode:addChild(self.mRuleWindow, 1000)

	local function closeWindow()
		self.mRuleWindow:removeFromParent(true)
		self.mRuleWindow = nil
	end
	registerWidgetReleaseUpEvent(self.mRuleWindow:getChildByName("Button_Close"), closeWindow)
	registerWidgetReleaseUpEvent(self.mRuleWindow, closeWindow)


	local textData = DB_Text.getDataById(1701)
	local textStr  = textData.Text_CN
	richTextCreate(self.mRuleWindow:getChildByName("Panel_Text"), textStr, true, nil, false)
end

function ArenaWindow:OnChallenge(widget)
	GUISystem:playSound("homeBtnSound")
	-- 判断剩余挑战次数
	if not self.mCanGoChallenge then return end
		if self.mArenaInfo.leftTimes <= 0 then
		--	MessageBox:showMessageBox1("挑战次数已经用尽~")
			self:requestBuyCount()
		return
	end
	self:showAttackSetWindow(widget:getTag())
end

function ArenaWindow:InitLayout(event)
	self.mRootWidget =  GUIWidgetPool:createWidget("Arena")
	self.mRootNode:addChild(self.mRootWidget)

	local function closeWindow()
		GUISystem:playSound("homeBtnSound")
		if __IsEnterFightWindow__ then
			local function callFun()
				EventSystem:PushEvent(Event.GUISYSTEM_HIDE_ARENAWINDOW)
				showLoadingWindow("HomeWindow")
				__IsEnterFightWindow__ = false
			end
		    FightSystem:sendChangeCity(false,callFun)
		else
			EventSystem:PushEvent(Event.GUISYSTEM_HIDE_ARENAWINDOW)
		end
	end

	self.mTopRoleInfoPanel = TopRoleInfoPanel:new()
	local topInfoPanel = self.mTopRoleInfoPanel:init(self.mRootNode,ROLE_TITLE_TYPE.TITLE_ARENA,closeWindow)

	-- 玩家信息窗口
	self.mPlayerInfoWindow = self.mRootWidget:getChildByName("Panel_PlayerWindow")
	self.mPlayerInfoWindow:setVisible(false)
	registerWidgetReleaseUpEvent(self.mPlayerInfoWindow, handler(self, self.hidePlayerInfo))

	-- 战报窗口
	self.mLogWindow = self.mRootWidget:getChildByName("Panel_Record")
	self.mLogWindow:setVisible(false)
	registerWidgetReleaseUpEvent(self.mLogWindow:getChildByName("Button_Close"), handler(self, self.hideLogWindow))
	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_Record"), handler(self, self.requestArenaLog))

	-- 显示规则窗口
	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_Rule"), handler(self, self.showRuleWindow))

	-- 刷新
	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_Update"), handler(self, self.requestDoArenaFresh))
	-- 购买
	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_BuyCount"), handler(self, self.requestBuyCount))
	-- 商店
	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_Shop"), handler(self, self.gotoShop))
	-- 防守阵容
	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_DefensiveTeam"), handler(self, self.showFormationSetWindow))
	-- 领取奖励
	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_Reward"), handler(self, self.requestGetArenaReward))

	
	--排行榜
	local function showRank()
		GUISystem:playSound("homeBtnSound")	
		GUISystem:goTo("rankinglist",{RANKTYPE.MAIN.ORGANIZE,RANKTYPE.MINOR.ARENA})
	end

	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_RankingList"), handler(self, showRank))

	-- 适配
	local function doAdapter()
		-- Panel_TopLeft 贴屏幕左边
		self.mRootWidget:getChildByName("Panel_TopLeft"):setPositionX(getGoldFightPosition_LD().x)

		-- Panel_Top 的上边顶着返回按钮那个大长条的下边
		self.mRootWidget:getChildByName("Panel_Top"):setPositionY(getGoldFightPosition_LU().y - self.mTopRoleInfoPanel.mTopWidget:getContentSize().height - self.mRootWidget:getChildByName("Panel_Top"):getContentSize().height)

		-- Panel_Bottom 的下边贴着屏幕下边缘
		self.mRootWidget:getChildByName("Panel_Bottom"):setPositionY(getGoldFightPosition_LD().y)

		-- Panel_TopRight距离屏幕右边的距离为(屏幕宽度-960)/2
		local dis = (cc.Director:getInstance():getVisibleSize().width-960)/2
		self.mRootWidget:getChildByName("Panel_TopRight"):setPositionX(getGoldFightPosition_RD().x - self.mRootWidget:getChildByName("Panel_TopRight"):getContentSize().width - dis)

	end
	doAdapter()

end

-- 领取竞技场奖励
function ArenaWindow:requestGetArenaReward()
	local packet = NetSystem.mNetManager:GetSPacket()
	packet:SetType(PacketTyper._PTYPE_CS_ARENA_REWARD_INFO)
	packet:Send()
	GUISystem:showLoading()
end

function ArenaWindow:onRequestArenaReward(msgPacket)

	local function doArenaGuideTwo_Stop()
		ArenaGuideTwo:stop()
	end
	ArenaGuideTwo:step(2, nil, doArenaGuideTwo_Stop)

	local honorCnt = msgPacket:GetInt()
	local rewardCnt = msgPacket:GetUShort()
	local rewardTbl = {}
	for i = 1, rewardCnt do
		rewardTbl[i] = {}
		rewardTbl[i].time = msgPacket:GetString()
		rewardTbl[i].rank = msgPacket:GetInt()
		rewardTbl[i].honor = msgPacket:GetInt()
	end

	local window = GUIWidgetPool:createWidget("Arena_Reward")
	self.mRootNode:addChild(window, 100)

	window:getChildByName("Label_TotalReward"):setString(honorCnt)

	-- 关闭窗口
	local function delWindow()
		if window then
			window:removeFromParent(true)
			window = nil
		end
	end

	-- 响应领奖
	local function onGet(msgPacket)
		delWindow()
	end
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_ARENA_REWARD_GET, onGet)

	-- 请求领奖
	local function requestGet()
		local packet = NetSystem.mNetManager:GetSPacket()
		packet:SetType(PacketTyper._PTYPE_CS_ARENA_REWARD_GET)
		packet:Send()
	end

	registerWidgetReleaseUpEvent(window:getChildByName("Button_Get"), requestGet)
	registerWidgetReleaseUpEvent(window, delWindow)

	local listWidget = window:getChildByName("ListView_Reward")

	for i = 1, rewardCnt do
		local cellWidget = GUIWidgetPool:createWidget("Arena_RewardCell")
		cellWidget:getChildByName("Label_Time"):setString(rewardTbl[i].time)
		cellWidget:getChildByName("Label_Ranking"):setString("排名 "..rewardTbl[i].rank)
		cellWidget:getChildByName("Label_Reward"):setString(rewardTbl[i].honor)
		listWidget:pushBackCustomItem(cellWidget)
	end
	GUISystem:hideLoading()

	if 0 == rewardCnt then
		window:getChildByName("Label_NoReward"):setVisible(true)
	end
end

-- 显示规则窗口
function ArenaWindow:RuleWindow()
	self.mRuleWindow = GUIWidgetPool:createWidget("Arena_Rule")
	self.mRootNode:addChild(self.mRuleWindow, 1000)

	local function closeWindow()
		self.mRuleWindow:removeFromParent(true)
		self.mRuleWindow = nil
	end
	registerWidgetReleaseUpEvent(self.mRuleWindow:getChildByName("Button_Close"), closeWindow)
	registerWidgetReleaseUpEvent(self.mRuleWindow, closeWindow)


	local textData = DB_Text.getDataById(1701)
	local textStr  = textData.Text_CN
	richTextCreate(self.mRuleWindow:getChildByName("Panel_Text"), textStr, true, nil, false)
end

function ArenaWindow:UpdateBattleTeamPanel()
	-- 删除原来的
	for i = 1, 3 do
		self.mRootWidget:getChildByName("Panel_HeroBg_"..tostring(i)):removeAllChildren()
	end
	-- 添加新的
	for i = 1, #globaldata.defendHeroList do
		local heroId = globaldata.defendHeroList[i]
		local heroObj = globaldata:findHeroById(heroId)
		if heroObj then
			local heroIcon = createHeroIcon(heroObj.id, heroObj.level, heroObj.quality, heroObj.advanceLevel)
			self.mRootWidget:getChildByName("Panel_HeroBg_"..tostring(i)):addChild(heroIcon)
		end
	end
end

local baseZorder = 10
local topZorder = 100

-- 显示防守阵容战力
function ArenaWindow:showCombat()
	local combat = 0
	for i = 1, #globaldata.defendHeroList do
		if 0 ~= globaldata.defendHeroList[i] then
			local heroObj = globaldata:findHeroById(globaldata.defendHeroList[i])
			combat = combat + heroObj.combat
		end
	end
	self.mRootWidget:getChildByName("Label_DefensiveZhanli_Stroke_167_58_1"):setString(tostring(combat))
end

-- 显示阵容调整窗口
function ArenaWindow:showFormationSetWindow()
	GUISystem:playSound("homeBtnSound")
	if not self.mFormationSetWindow then
		self.mFormationSetWindow = GUIWidgetPool:createWidget("PVE_FightTeam")
	end
	self.mRootNode:addChild(self.mFormationSetWindow, 100)

	local function showHeroRelationShip()
		GUISystem:showHeroRelationShip()
	end
	registerWidgetReleaseUpEvent(self.mFormationSetWindow:getChildByName("Button_GroupCircle"), showHeroRelationShip)

	-- 背景适配
	local winSize = cc.Director:getInstance():getVisibleSize()
	local preSize = self.mFormationSetWindow:getChildByName("Image_WindowBg"):getContentSize()
	self.mFormationSetWindow:getChildByName("Image_WindowBg"):setContentSize(cc.size(winSize.width, preSize.height))
	-- 显示战力
	self.mFormationSetWindow:getChildByName("Panel_TotalZhanli"):setVisible(true)
	-- 上阵英雄id
	local battleHeroIdTbl = {0, 0, 0}
	-- 上阵英雄头像
	local battleHeroIconTbl = {}

	-- 所有英雄id
	local allHeroIdTbl = {}
	-- 所有英雄头像
	local allHeroIconTbl = {}

	local function closeWindow()
		self.mFormationSetWindow:removeFromParent(true)
		self.mFormationSetWindow = nil
		GUISystem:hideLoading()
		globaldata.defendHeroList = {}
		for i = 1, #battleHeroIdTbl do
			globaldata.defendHeroList[i] = battleHeroIdTbl[i]
		end
		self:UpdateBattleTeamPanel()
		self:showCombat()

		local function doArenaGuideOne_Step7()
			local guideBtn = self.mRootWidget:getChildByName("Panel_Player_4"):getChildByName("Button_Fight")
			local size = guideBtn:getContentSize()
			local pos = guideBtn:getWorldPosition()
			pos.x = pos.x - size.width/2
			pos.y = pos.y - size.height/2
			local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
			ArenaGuideOne:step(8, touchRect)
		end
		if ArenaGuideOne:canGuide() then
			ArenaGuideOne:step(7, nil, doArenaGuideOne_Step7)
		end

	end
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_DEFEND_SET_, closeWindow)

	-- 复制
	for i = 1, 3 do
		if globaldata.defendHeroList[i] then
			battleHeroIdTbl[i] = globaldata.defendHeroList[i]
		end
	end

	-- 竞技场指引
	if ArenaGuideOne:canGuide() then
		battleHeroIdTbl = {0, 0, 0} -- 如果需要指引,先强制调整阵容
		self.mFormationSetWindow:getChildByName("Button_Cancel"):setVisible(false)
		ArenaGuideOne:step(6)
	end

	-- 显示英雄名字
	local function showBattleHeroName()
		local combat = 0 
		for i = 1, #battleHeroIdTbl do
			local lblWidget = self.mFormationSetWindow:getChildByName("Label_HeroName_"..tostring(i))
			if 0 == battleHeroIdTbl[i] then -- 没有英雄
				lblWidget:setVisible(false)
			else -- 有英雄 
				lblWidget:setVisible(true)
				-- 名字
				local heroData = DB_HeroConfig.getDataById(battleHeroIdTbl[i])
				local heroNameId = heroData.Name
				lblWidget:setString(getDictionaryText(heroNameId))
				-- 战力
				local heroObj = globaldata:findHeroById(battleHeroIdTbl[i])
				combat = combat + heroObj.combat
			end
		end
		self.mFormationSetWindow:getChildByName("Label_TotalZhanli"):setString(combat)
	end

	-- 关闭界面
	local function closeWindowNoPacket()
		self.mFormationSetWindow:removeFromParent(true)
		self.mFormationSetWindow = nil
	end
	registerWidgetReleaseUpEvent(self.mFormationSetWindow:getChildByName("Button_Cancel"), closeWindowNoPacket)

	local function requestSetFormation()
		for i = 1, #battleHeroIdTbl do
    		if 0 == battleHeroIdTbl[i] then
    			MessageBox:showMessageBox1("亲防守阵容中有空余位置~")
    			return
    		end
    	end 

		GUISystem:playSound("homeBtnSound")
		local packet = NetSystem.mNetManager:GetSPacket()
    	packet:SetType(PacketTyper._PTYPE_CS_DEFEND_SET_)
    	packet:PushUShort(#battleHeroIdTbl)
    	for i = 1, #battleHeroIdTbl do
    		packet:PushInt(battleHeroIdTbl[i])
    	end
    	packet:Send()
    	GUISystem:showLoading()
	end
	registerWidgetReleaseUpEvent(self.mFormationSetWindow:getChildByName("Button_Fight"), requestSetFormation)

	-- 获取阵容上英雄的数量
	local function getBattleHeroCount()
		local cnt = 0
		for i = 1, #battleHeroIdTbl do
			if 0 ~= battleHeroIdTbl[i] then
				cnt = cnt + 1
			end
		end
		return cnt
	end

	-- 让英雄下阵
	local function sendHeroBack(widget)
		-- 去掉阵上英雄
		local heroId = widget:getTag()
		-- 去掉阵上id和控件
		for i = 1, #battleHeroIdTbl do
			if battleHeroIdTbl[i] == heroId then
				battleHeroIdTbl[i] = 0
				battleHeroIconTbl[i]:removeFromParent(true)
				battleHeroIconTbl[i] = nil
				-- 播放特效
				local animNode = AnimManager:createAnimNode(8001)
				self.mFormationSetWindow:getChildByName("Panel_Hero"..tostring(i).."_Bg"):getChildByName("Panel_Hero_"..i):addChild(animNode:getRootNode(), 100)
				animNode:setPosition(cc.p(45, 32))
				animNode:play("fightteam_cell_chose2")
			end
		end
		for i = 1, #allHeroIdTbl do
			if allHeroIdTbl[i] == heroId then
				allHeroIconTbl[i]:getChildByName("Image_HeroChosen"):setVisible(false)
				allHeroIconTbl[i]:getChildByName("Label_HeroName"):setColor(G_COLOR_C3B.WHITE)
				-- 播放特效
				animNode = AnimManager:createAnimNode(8001)
				allHeroIconTbl[i]:getChildByName("Panel_Animation"):addChild(animNode:getRootNode(), 100)
				animNode:play("fightteam_cell_chose2")
			end
		end
		showBattleHeroName()
	end

	-- 送英雄上阵
	local function sendHeroToBattle(widget)
		-- 判断英雄是否在阵上
		local function isHeroInBattle(id)
			for i = 1, #battleHeroIdTbl do
				if id == battleHeroIdTbl[i] then
					return true
				end
			end
			return false
		end
		
		local heroId = widget:getTag()
		if not isHeroInBattle(heroId) then 

			if getBattleHeroCount() >=3 then
			--	MessageBox:showMessageBox1("上阵英雄已经满足三人~")
				return
			end

			for i = 1, #battleHeroIdTbl do
				if 0 == battleHeroIdTbl[i] then -- 此处是空位
					-- 记住id
					battleHeroIdTbl[i] = heroId
					-- 创建控件
					local heroObj = globaldata:findHeroById(heroId)
					battleHeroIconTbl[i] = createHeroIcon(heroObj.id, heroObj.level, heroObj.quality, heroObj.advanceLevel)
					battleHeroIconTbl[i]:setTouchEnabled(true)
					self.mFormationSetWindow:getChildByName("Panel_Hero"..tostring(i).."_Bg"):getChildByName("Panel_Hero_"..i):addChild(battleHeroIconTbl[i])
					registerWidgetReleaseUpEvent(battleHeroIconTbl[i], sendHeroBack)
					-- 播放特效
					local animNode = AnimManager:createAnimNode(8001)
					self.mFormationSetWindow:getChildByName("Panel_Hero"..tostring(i).."_Bg"):getChildByName("Panel_Hero_"..i):addChild(animNode:getRootNode(), 100)
					animNode:setPosition(cc.p(45, 32))
					animNode:play("fightteam_cell_chose1")
					-- 原来空间设置上阵
					widget:getChildByName("Image_HeroChosen"):setVisible(true)
					widget:getChildByName("Label_HeroName"):setColor(cc.c3b(255, 245, 84))
					showBattleHeroName()
					-- 播放特效
					animNode = AnimManager:createAnimNode(8001)
					widget:getChildByName("Panel_Animation"):addChild(animNode:getRootNode(), 100)
					animNode:play("fightteam_cell_chose2")
					return 
				end
			end
		else
			sendHeroBack(widget)
		end
	end

	local function loadAllHero()
		for i = 1, 24 do -- 存在
			if globaldata:isHeroIdExist(i) then 
				table.insert(allHeroIdTbl, i)
			end
		end
		-- 根据战力排序
		local function sortFunc(id1, id2)
			local heroObj1 = globaldata:findHeroById(id1)
			local heroObj2 = globaldata:findHeroById(id2)
			return heroObj1.combat > heroObj2.combat
		end
		table.sort(allHeroIdTbl, sortFunc)

		-- 创建英雄头像
		for i = 1, #allHeroIdTbl do
			local heroObj = globaldata:findHeroById(allHeroIdTbl[i])
			allHeroIconTbl[i] = GUIWidgetPool:createWidget("PVE_FightTeamCell")
			allHeroIconTbl[i]:getChildByName("Panel_HeroIcon"):addChild(createHeroIcon(heroObj.id, heroObj.level, heroObj.quality, heroObj.advanceLevel))
			allHeroIconTbl[i]:setTouchEnabled(true)
			allHeroIconTbl[i]:setTag(heroObj.id)
			self.mFormationSetWindow:getChildByName("ListView_heroList"):pushBackCustomItem(allHeroIconTbl[i])
			registerWidgetReleaseUpEvent(allHeroIconTbl[i], sendHeroToBattle)
			-- 名字
			local heroData = DB_HeroConfig.getDataById(heroObj.id)
			local heroNameId = heroData.Name
			allHeroIconTbl[i]:getChildByName("Label_HeroName"):setString(getDictionaryText(heroNameId))
		end
		showBattleHeroName()
	end
	loadAllHero()

	-- 默认上阵
	local function xxx()
		for i = 1, #battleHeroIdTbl do
			local heroId = battleHeroIdTbl[i]
			if 0 ~= heroId then
				for j = 1, #allHeroIdTbl do
					if heroId == allHeroIdTbl[j] then
						-- 创建控件
						local heroObj = globaldata:findHeroById(heroId)
						battleHeroIconTbl[i] = createHeroIcon(heroObj.id, heroObj.level, heroObj.quality, heroObj.advanceLevel)
						battleHeroIconTbl[i]:setTouchEnabled(true)
						self.mFormationSetWindow:getChildByName("Panel_Hero"..tostring(i).."_Bg"):getChildByName("Panel_Hero_"..i):addChild(battleHeroIconTbl[i])
						registerWidgetReleaseUpEvent(battleHeroIconTbl[i], sendHeroBack)
						-- 原来控件设置上阵
						allHeroIconTbl[j]:getChildByName("Image_HeroChosen"):setVisible(true)
						allHeroIconTbl[j]:getChildByName("Label_HeroName"):setColor(cc.c3b(255, 245, 84))
					end
				end
			end
		end
	end
	xxx()
end

-- 显示战前阵容调整窗口
function ArenaWindow:showAttackSetWindow(tag)
	if not self.mAttackSetWindow then
		self.mAttackSetWindow = GUIWidgetPool:createWidget("Arena_AttackTeam")
	end
	self.mRootNode:addChild(self.mAttackSetWindow, 100)


	local function showCompareResult(index, friendHeroId, enemyHeroId)

		if not friendHeroId then
			self.mAttackSetWindow:getChildByName("Panel_Self_Cell_"..index):getChildByName("Image_Myhero_Arrow_"..index):setVisible(false)
			self.mAttackSetWindow:getChildByName("Panel_Enemy_Cell_"..index):getChildByName("Image_Enemy_Arrow_"..index):setVisible(false)
			return
		end

		local friendGroup 	= nil 	-- 己方
		local enemyGroup 	= nil   -- 敌方

		local heroData = DB_HeroConfig.getDataById(friendHeroId)
		friendGroup = heroData.HeroGroup
		
		heroData = DB_HeroConfig.getDataById(enemyHeroId)
		enemyGroup = heroData.HeroGroup

		-- 显示对比结果
		local result1, result2 = getCompareResult(friendGroup, enemyGroup)
		if not result1 then -- 平手,隐藏
			self.mAttackSetWindow:getChildByName("Panel_Self_Cell_"..index):getChildByName("Image_Myhero_Arrow_"..index):setVisible(false)
			self.mAttackSetWindow:getChildByName("Panel_Enemy_Cell_"..index):getChildByName("Image_Enemy_Arrow_"..index):setVisible(false)
		else
			self.mAttackSetWindow:getChildByName("Panel_Self_Cell_"..index):getChildByName("Image_Myhero_Arrow_"..index):setVisible(true)
			self.mAttackSetWindow:getChildByName("Panel_Self_Cell_"..index):getChildByName("Image_Myhero_Arrow_"..index):loadTexture(result1)
			self.mAttackSetWindow:getChildByName("Panel_Enemy_Cell_"..index):getChildByName("Image_Enemy_Arrow_"..index):setVisible(true)
			self.mAttackSetWindow:getChildByName("Panel_Enemy_Cell_"..index):getChildByName("Image_Enemy_Arrow_"..index):loadTexture(result2)
		end
	end

	-- 背景适配
	local winSize = cc.Director:getInstance():getVisibleSize()

	-- 背景适配
	local winSize = cc.Director:getInstance():getVisibleSize()
	local preSize = self.mAttackSetWindow:getChildByName("Image_WindowBg"):getContentSize()
	self.mAttackSetWindow:getChildByName("Image_WindowBg"):setContentSize(cc.size(winSize.width, preSize.height))

	local function closeWindow()
		GUISystem:playSound("homeBtnSound")
		self.mAttackSetWindow:removeFromParent(true)
		self.mAttackSetWindow = nil
	end
	registerWidgetReleaseUpEvent(self.mAttackSetWindow:getChildByName("Button_Close"), closeWindow)

	local function showHeroRelationShip()
		GUISystem:showHeroRelationShip()
	end
	registerWidgetReleaseUpEvent(self.mAttackSetWindow:getChildByName("Button_GroupCircle"), showHeroRelationShip)

	-- 上阵英雄id
	local battleHeroIdTbl = {0, 0, 0}
	-- 上阵英雄头像
	local battleHeroIconTbl = {}

	-- 所有英雄id
	local allHeroIdTbl = {}
	-- 所有英雄头像
	local allHeroIconTbl = {}

	-- 复制
	for i = 1, 3 do
		if globaldata.attackHeroList[i] then
			battleHeroIdTbl[i] = globaldata.attackHeroList[i]
		end
	end

	-- 竞技场指引
	if ArenaGuideOne:canGuide() then
		battleHeroIdTbl = {0, 0, 0} -- 如果需要指引,先强制调整阵容

		local function doArenaGuideOne_Stop()
			ArenaGuideOne:stop()
		end
		
		local function doArenaGuideOne_Step12()
			local guideBtn = self.mAttackSetWindow:getChildByName("Button_Fight")
			local size = guideBtn:getContentSize()
			local pos = guideBtn:getWorldPosition()
			pos.x = pos.x - size.width/2
			pos.y = pos.y - size.height/2
			local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
			ArenaGuideOne:step(12, touchRect, nil, doArenaGuideOne_Stop)
		end

		local function doArenaGuideOne_Step11()
			local guideBtn = self.mAttackSetWindow:getChildByName("Image_Enemy_3")
			local size = guideBtn:getContentSize()
			local pos = guideBtn:getWorldPosition()
			pos.x = pos.x - size.width/2
			pos.y = pos.y - size.height/2
			local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
			ArenaGuideOne:step(11, touchRect, nil, doArenaGuideOne_Step12)
		end

		local function doArenaGuideOne_Step10()
			local guideBtn = self.mAttackSetWindow:getChildByName("Image_Enemy_2")
			local size = guideBtn:getContentSize()
			local pos = guideBtn:getWorldPosition()
			pos.x = pos.x - size.width/2
			pos.y = pos.y - size.height/2
			local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
			ArenaGuideOne:step(10, touchRect, nil, doArenaGuideOne_Step11)
		end

		if ArenaGuideOne:canGuide() then
			local guideBtn = self.mAttackSetWindow:getChildByName("Image_Enemy_1")
			local size = guideBtn:getContentSize()
			local pos = guideBtn:getWorldPosition()
			pos.x = pos.x - size.width/2
			pos.y = pos.y - size.height/2
			local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
			ArenaGuideOne:step(9, touchRect, nil, doArenaGuideOne_Step10)
		end

	end

	-- 显示敌方英雄
	local function showEnemyHero()
		for k, v in pairs(self.mArenaInfo.canAttackPlayer) do
			if tag == v.playerRank then
				for i = 1, v.heroCount do
					local heroIcon = createHeroIcon(v.hero[i].heroId, v.hero[i].level, v.hero[i].quality, v.hero[i].advanceLevel)
					self.mAttackSetWindow:getChildByName("Panel_Enemy_"..tostring(i)):addChild(heroIcon)
					local heroData = DB_HeroConfig.getDataById(v.hero[i].heroId)
					local heroNameId = heroData.Name
					self.mAttackSetWindow:getChildByName("Label_EnemyName_"..tostring(i)):setString(getDictionaryText(heroNameId))
				end
			end
		end
	end
	showEnemyHero()

	-- 挑战请求
	local function requestAttack()
		GUISystem:playSound("homeBtnSound")

		for i = 1, #battleHeroIdTbl do
			if 0 == battleHeroIdTbl[i] then
				MessageBox:showMessageBox1("亲进攻阵容中有空余位置~")
    			return
			end
		end

		for k, v in pairs(self.mArenaInfo.canAttackPlayer) do
			if tag == v.playerRank then
				local function ChallengePlayer()
					local packet = NetSystem.mNetManager:GetSPacket()
					packet:SetType(PacketTyper._PTYPE_CS_REQUEST_CHALLENGE_PLAYER_)
					globaldata.playerid_str = v.playerId
					globaldata.playerrank = v.playerRank
					packet:PushString(v.playerId)
					packet:PushInt(v.playerRank)
					packet:PushUShort(#battleHeroIdTbl)
					for i = 1, #battleHeroIdTbl do
						packet:PushInt(battleHeroIdTbl[i])
					end
					packet:Send()
				end
				ChallengePlayer()
				GUISystem:showLoading()
				return
			end
		end
	end
	registerWidgetReleaseUpEvent(self.mAttackSetWindow:getChildByName("Button_Fight"), requestAttack)

	local function closeWindow()
		self.mFormationSetWindow:removeFromParent(true)
		self.mFormationSetWindow = nil
		GUISystem:hideLoading()
		globaldata.attackHeroList = {}
		for i = 1, #battleHeroIdTbl do
			globaldata.attackHeroList[i] = battleHeroIdTbl[i]
		end
	end
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_DEFEND_SET_, closeWindow)

	-- 获取阵容上英雄的数量
	local function getBattleHeroCount()
		local cnt = 0
		for i = 1, #battleHeroIdTbl do
			if 0 ~= battleHeroIdTbl[i] then
				cnt = cnt + 1
			end
		end
		return cnt
	end

	-- 显示英雄名字
	local function showBattleHeroName()
		local combat = 0 
		for i = 1, #battleHeroIdTbl do
			local lblWidget = self.mAttackSetWindow:getChildByName("Label_HeroName_"..tostring(i))
			if 0 == battleHeroIdTbl[i] then -- 没有英雄
				lblWidget:setVisible(false)
			else -- 有英雄
				lblWidget:setVisible(true)
				-- 名字
				local heroData = DB_HeroConfig.getDataById(battleHeroIdTbl[i])
				local heroNameId = heroData.Name
				lblWidget:setString(getDictionaryText(heroNameId))
				-- 战力
				local heroObj = globaldata:findHeroById(battleHeroIdTbl[i])
				combat = combat + heroObj.combat
			end
		end
		self.mAttackSetWindow:getChildByName("Label_DefensiveZhanli_Stroke_167_58_1"):setString("战力 "..tostring(combat))
	end

	-- 让英雄下阵
	local function sendHeroBack(widget)
		-- 去掉阵上英雄
		local heroId = widget:getTag()
		-- 去掉阵上id和控件
		for i = 1, #battleHeroIdTbl do
			if battleHeroIdTbl[i] == heroId then
				battleHeroIdTbl[i] = 0
				battleHeroIconTbl[i]:removeFromParent(true)
				battleHeroIconTbl[i] = nil
				-- 播放特效
				local animNode = AnimManager:createAnimNode(8001)
				self.mAttackSetWindow:getChildByName("Panel_MyHero_"..tostring(i)):addChild(animNode:getRootNode(), 100)
				animNode:setPosition(cc.p(45, 32))
				animNode:play("fightteam_cell_chose2")

				showCompareResult(i, nil)
			end
		end
		for i = 1, #allHeroIdTbl do
			if allHeroIdTbl[i] == heroId then
				allHeroIconTbl[i]:getChildByName("Image_HeroChosen"):setVisible(false)
				allHeroIconTbl[i]:getChildByName("Label_HeroName"):setColor(G_COLOR_C3B.WHITE)
				-- 播放特效
				animNode = AnimManager:createAnimNode(8001)
				allHeroIconTbl[i]:getChildByName("Panel_Animation"):addChild(animNode:getRootNode(), 100)
				animNode:play("fightteam_cell_chose2")
			end
		end
		showBattleHeroName()
	end

	-- 送英雄上阵
	local function sendHeroToBattle(widget)
		-- 判断英雄是否在阵上
		local function isHeroInBattle(id)
			for i = 1, #battleHeroIdTbl do
				if id == battleHeroIdTbl[i] then
					return true
				end
			end
			return false
		end
		
		local heroId = widget:getTag()
		if not isHeroInBattle(heroId) then 

			if getBattleHeroCount() >=3 then
			--	MessageBox:showMessageBox1("上阵英雄已经满足三人~")
				return
			end

			for i = 1, #battleHeroIdTbl do
				if 0 == battleHeroIdTbl[i] then -- 此处是空位
					-- 记住id
					battleHeroIdTbl[i] = heroId
					-- 创建控件
					local heroObj = globaldata:findHeroById(heroId)
					battleHeroIconTbl[i] = createHeroIcon(heroObj.id, heroObj.level, heroObj.quality, heroObj.advanceLevel)
					battleHeroIconTbl[i]:setTouchEnabled(true)
					self.mAttackSetWindow:getChildByName("Panel_MyHero_"..tostring(i)):addChild(battleHeroIconTbl[i])
					registerWidgetReleaseUpEvent(battleHeroIconTbl[i], sendHeroBack)
					-- 播放特效
					local animNode = AnimManager:createAnimNode(8001)
					self.mAttackSetWindow:getChildByName("Panel_MyHero_"..tostring(i)):addChild(animNode:getRootNode(), 100)
					animNode:setPosition(cc.p(45, 32))
					animNode:play("fightteam_cell_chose1")
					-- 原来空间设置上阵
					widget:getChildByName("Image_HeroChosen"):setVisible(true)
					widget:getChildByName("Label_HeroName"):setColor(cc.c3b(255, 245, 84))
					showBattleHeroName()
					-- 播放特效
					animNode = AnimManager:createAnimNode(8001)
					widget:getChildByName("Panel_Animation"):addChild(animNode:getRootNode(), 100)
					animNode:play("fightteam_cell_chose2")

					-- 显示比对结果
					local enemyHeroId = nil
					for k, v in pairs(self.mArenaInfo.canAttackPlayer) do
						if tag == v.playerRank then
							enemyHeroId = v.hero[i].heroId
							break
						end
					end
					showCompareResult(i, heroId, enemyHeroId)

					return 
				end
			end
		else
			sendHeroBack(widget)
		end
	end

	local function loadAllHero()
		for i = 1, 24 do -- 存在
			if globaldata:isHeroIdExist(i) then 
				table.insert(allHeroIdTbl, i)
			end
		end
		-- 根据战力排序
		local function sortFunc(id1, id2)
			local heroObj1 = globaldata:findHeroById(id1)
			local heroObj2 = globaldata:findHeroById(id2)
			return heroObj1.combat > heroObj2.combat
		end
		table.sort(allHeroIdTbl, sortFunc)

		-- 创建英雄头像
		for i = 1, #allHeroIdTbl do
			local heroObj = globaldata:findHeroById(allHeroIdTbl[i])
			allHeroIconTbl[i] = GUIWidgetPool:createWidget("PVE_FightTeamCell")
			allHeroIconTbl[i]:getChildByName("Panel_HeroIcon"):addChild(createHeroIcon(heroObj.id, heroObj.level, heroObj.quality, heroObj.advanceLevel))
			allHeroIconTbl[i]:setTouchEnabled(true)
			allHeroIconTbl[i]:setTag(heroObj.id)
			self.mAttackSetWindow:getChildByName("ListView_HeroList"):pushBackCustomItem(allHeroIconTbl[i])
			registerWidgetReleaseUpEvent(allHeroIconTbl[i], sendHeroToBattle)
			-- 名字
			local heroData = DB_HeroConfig.getDataById(heroObj.id)
			local heroNameId = heroData.Name
			allHeroIconTbl[i]:getChildByName("Label_HeroName"):setString(getDictionaryText(heroNameId))
		end
		showBattleHeroName()
	end
	loadAllHero()

	-- 默认上阵
	local function xxx()
		for i = 1, #battleHeroIdTbl do
			local heroId = battleHeroIdTbl[i]
			if 0 ~= heroId then
				for j = 1, #allHeroIdTbl do
					if heroId == allHeroIdTbl[j] then
						-- 创建控件
						local heroObj = globaldata:findHeroById(heroId)
						battleHeroIconTbl[i] = createHeroIcon(heroObj.id, heroObj.level, heroObj.quality, heroObj.advanceLevel)
						battleHeroIconTbl[i]:setTouchEnabled(true)
						self.mAttackSetWindow:getChildByName("Panel_MyHero_"..tostring(i)):addChild(battleHeroIconTbl[i])
						registerWidgetReleaseUpEvent(battleHeroIconTbl[i], sendHeroBack)
						-- 原来控件设置上阵
						allHeroIconTbl[j]:getChildByName("Image_HeroChosen"):setVisible(true)
						allHeroIconTbl[j]:getChildByName("Label_HeroName"):setColor(cc.c3b(255, 245, 84))

						-- 显示比对结果
						local enemyHeroId = nil
						for k, v in pairs(self.mArenaInfo.canAttackPlayer) do
							if tag == v.playerRank then
								enemyHeroId = v.hero[i].heroId
								break
							end
						end
						showCompareResult(i, heroId, enemyHeroId)

					end
				end
			end
		end
	end
	xxx()	
end

function ArenaWindow:setHeroSelected(widget)
	if self.mLastChooseWidget == widget then
		return
	end
	-- 换菜单项图片
	local function replaceTexture()
		if self.mLastChooseWidget then
			self.mLastChooseWidget:getChildByName("Image_Bg1"):loadTexture("arena_player_bg1.png")
			self.mLastChooseWidget = widget
		else
			self.mLastChooseWidget = widget
		end
		widget:getChildByName("Image_Bg1"):loadTexture("arena_player_bg_chosen.png")
	end
	replaceTexture()

	self:showPlayerInfo(widget:getTag())
end

function ArenaWindow:showPlayerInfo(index)
	-- 删除控件
	for i = 1, 5 do
		local panelHero = self.mPlayerInfoWindow:getChildByName("Panel_Hero"..i)
		if  panelHero then
			panelHero:removeAllChildren()
		end
	end
	local playerInfo = self.mArenaInfo.canAttackPlayer[index]

	-- 添加控件
	local playerInfoWidget = GUIWidgetPool:createWidget("PlayerInfo")
	playerInfoWidget:getChildByName("Image_PlayerHead"):loadTexture(FindFrameIconbyId(playerInfo.playerIconId))
	playerInfoWidget:getChildByName("Image_PlayerHead_Bg"):loadTexture(FindFrameIconbyId(playerInfo.playerFrameId))
	self.mPlayerInfoWindow:getChildByName("Panel_PlayInfo"):removeAllChildren()
	self.mPlayerInfoWindow:getChildByName("Panel_PlayInfo"):addChild(playerInfoWidget)

	-- 帮会名字
	if "" == playerInfo.playerGonghuiName then
		self.mPlayerInfoWindow:getChildByName("Label_Banghui"):setString("未加入公会")
	else
		self.mPlayerInfoWindow:getChildByName("Label_Banghui"):setString(playerInfo.playerGonghuiName)
	end

	-- 英雄
	for i = 1, playerInfo.heroCount do
		local heroWidget = createHeroIcon(playerInfo.hero[i].heroId, playerInfo.hero[i].level, playerInfo.hero[i].quality, playerInfo.hero[i].advanceLevel)
		self.mPlayerInfoWindow:getChildByName("Panel_Hero"..i):addChild(heroWidget)
	end
	-- 排名
	self.mPlayerInfoWindow:getChildByName("Label_Ranking"):setString(tostring(playerInfo.playerRank))
	-- 名字
	self.mPlayerInfoWindow:getChildByName("Label_Name"):setString(tostring(playerInfo.playerName))
	-- 战力
	self.mPlayerInfoWindow:getChildByName("Label_Zhanli"):setString(tostring(playerInfo.playerZhanli))
	-- 声望
	self.mPlayerInfoWindow:getChildByName("Label_Shengwang_Grow"):setString(tostring(playerInfo.playerScore))
	-- 级别
	self.mPlayerInfoWindow:getChildByName("Label_Level"):setString(tostring(playerInfo.playerLevel))

	self.mPlayerInfoWindow:setVisible(true)
end

-- 显示战报窗口
function ArenaWindow:showLogWindow()

	-- 删除控件
	local listWidget = self.mLogWindow:getChildByName("ListView_Record")
	listWidget:removeAllItems()

	for i = 1, self.mArenaInfo.logCount do
		local logWidget = GUIWidgetPool:createWidget("Arena_Recard")
		local logInfo = self.mArenaInfo.log[i]
		-- 胜败
		if 0 == logInfo.win then -- 胜
			logWidget:getChildByName("Image_Result"):loadTexture("arena_record_win.png")
		elseif 1 == logInfo.win then  -- 败
			logInfo.rankChange = -logInfo.rankChange
			logWidget:getChildByName("Image_Result"):loadTexture("arena_record_lose.png")
		end

		-- 排名变化
		if logInfo.rankChange > 0 then
			logWidget:getChildByName("Image_Arrow"):loadTexture("public_arrow2.png")
			logWidget:getChildByName("Image_Arrow"):setVisible(true)
			logWidget:getChildByName("Label_RankingChange"):setString(tostring(logInfo.rankChange))
		elseif logInfo.rankChange == 0 then
			logWidget:getChildByName("Image_Arrow"):setVisible(false)
			logWidget:getChildByName("Label_RankingChange"):setVisible(false)
		elseif logInfo.rankChange < 0 then
			logWidget:getChildByName("Image_Arrow"):loadTexture("public_arrow3.png")
			logWidget:getChildByName("Image_Arrow"):setVisible(true)
			logWidget:getChildByName("Label_RankingChange"):setString(tostring(logInfo.rankChange))
		end
		-- 时间
		logWidget:getChildByName("Label_WhichDay"):setString(logInfo.time)

		if self.mArenaInfo.log[i].attackPlayerName == globaldata.name then -- 对手是防守方
			-- 级别
			local playerHead = GUIWidgetPool:createWidget("PlayerHead")
		--	print("级别", logInfo.level)
			playerHead:getChildByName("Label_Level"):setString(tostring(logInfo.defendPlayerLevel))
			logWidget:getChildByName("Panel_Player"):addChild(playerHead)
			-- 头像
			playerHead:getChildByName("Image_PlayerHead"):loadTexture(FindFrameIconbyId(logInfo.defendPlayerIconId))
			-- 边框
			playerHead:getChildByName("Image_PlayerHead_Bg"):loadTexture(FindFrameIconbyId(logInfo.defendPlayerFrameId))
		else -- 对手是进攻方
			-- 级别
			local playerHead = GUIWidgetPool:createWidget("PlayerHead")
		--	print("级别", logInfo.level)
			playerHead:getChildByName("Label_Level"):setString(tostring(logInfo.attackPlayerLevel))
			logWidget:getChildByName("Panel_Player"):addChild(playerHead)
			-- 头像
			playerHead:getChildByName("Image_PlayerHead"):loadTexture(FindFrameIconbyId(logInfo.defendPlayerIconId))
			-- 边框
			playerHead:getChildByName("Image_PlayerHead_Bg"):loadTexture(FindFrameIconbyId(logInfo.defendPlayerFrameId))
		end

		-- 文字
		if 0 == logInfo.win then -- 胜
			if self.mArenaInfo.log[i].attackPlayerName == globaldata.name then -- 对手是防守方
				local label = richTextCreate(logWidget:getChildByName("Panel_SomeWords"), string.format("#000000您挑战了##0023d7%s##000000, 将他打翻在地#", logInfo.defendPlayerName), true)
				label:setFontSize(18)
			else -- 对手是进攻方
				local label = richTextCreate(logWidget:getChildByName("Panel_SomeWords"), string.format("#0023d7%s##000000挑战了您, 被您打翻在地#", logInfo.attackPlayerName), true)
				label:setFontSize(18)
			end
		elseif 1 == logInfo.win then  -- 败
			if self.mArenaInfo.log[i].attackPlayerName == globaldata.name then -- 对手是防守方
				local label = richTextCreate(logWidget:getChildByName("Panel_SomeWords"), string.format("#000000您挑战了##0023d7%s##000000, 被他打翻在地#", logInfo.defendPlayerName), true)
				label:setFontSize(18)
			else -- 对手是进攻方
				local label = richTextCreate(logWidget:getChildByName("Panel_SomeWords"), string.format("#0023d7%s##000000挑战了您, 将您打翻在地#", logInfo.attackPlayerName), true)
				label:setFontSize(18)
			end
		end

--[[
		-- 谁挑战谁
		if logInfo.attackPlayerName == globaldata.name then
			logInfo.attackPlayerName = "您"
		elseif logInfo.defendPlayerName == globaldata.name then
			logInfo.defendPlayerName = "您"
		end

		local strText = nil
		-- 赢还是输
		if 0 == logInfo.win then -- 赢 
			strText = string.format("#000000%s挑战了##0023d7%s##000000#", logInfo.attackPlayerName, logInfo.defendPlayerName)
		--	local label = richTextCreate(logWidget:getChildByName("Panel_SomeWords"), , true)
		--	label:setFontSize(18)
		elseif 1 == logInfo.win then -- 输
			strText = string.format("#000000%s挑战了##0023d7%s##000000#", logInfo.attackPlayerName, logInfo.defendPlayerName)
		--	local label = richTextCreate(logWidget:getChildByName("Panel_SomeWords"), , true)
		--	label:setFontSize(18)
		end

		-- 连接
		if logInfo.attackPlayerName == globaldata.name then
			strText = strText..""
		elseif logInfo.defendPlayerName == globaldata.name then
			logInfo.defendPlayerName = "您"
		end
]]
		listWidget:pushBackCustomItem(logWidget)
	end

	self.mLogWindow:setVisible(true)
end

-- 隐藏战报窗口
function ArenaWindow:hideLogWindow()

	GUISystem:playSound("homeBtnSound")
	self.mLogWindow:setVisible(false)
end


function ArenaWindow:hidePlayerInfo()
	self.mLastChooseWidget:getChildByName("Image_Bg1"):loadTexture("arena_player_bg1.png")
	self.mLastChooseWidget = nil
	self.mPlayerInfoWindow:setVisible(false)
end

-- 请求刷新
function ArenaWindow:requestDoArenaFresh()
	local function enableRefresh()
		self.mCanRefresh = true
	end
	if self.mCanRefresh then
		GUISystem:playSound("homeBtnSound")
		local packet = NetSystem.mNetManager:GetSPacket()
		packet:SetType(PacketTyper._PTYPE_CS_REQUEST_ARENA_)
		packet:Send()
		GUISystem:showLoading()
		self.mCanRefresh = false
		nextTick_frameCount(enableRefresh, 1)
	else
		MessageBox:showMessageBox1("亲，请不要频繁刷新啊~")
	end
end

-- 响应刷新请求
function ArenaWindow:onRequestDoArenaFresh(msgPacket)
	self.mArenaInfo.playerCount = msgPacket:GetUShort()
	-- 可挑战的
	self.mArenaInfo.canAttackPlayer = {}
	for i = 1, self.mArenaInfo.playerCount do
		local player = {}
		player.playerId = msgPacket:GetString()
		player.playerName = msgPacket:GetString()
		player.playerGonghuiName = msgPacket:GetString()
		player.playerIconId = msgPacket:GetInt()
		player.playerFrameId = msgPacket:GetInt()
		player.playerLevel = msgPacket:GetInt()
		player.playerRank = msgPacket:GetInt()
		player.playerScore = msgPacket:GetInt()
		player.playerZhanli = msgPacket:GetInt()
		player.heroCount = msgPacket:GetUShort()
		player.hero = {}
		for j = 1, player.heroCount do
			player.hero[j] = {}
			player.hero[j].heroId = msgPacket:GetInt() 
			player.hero[j].advanceLevel = msgPacket:GetChar()
			player.hero[j].quality = msgPacket:GetChar()
			player.hero[j].level = msgPacket:GetInt()
		end
		self.mArenaInfo.canAttackPlayer[i] = player
	end

	-- 先删除上一次的Spine
	for i = 1, #self.mHeroAnimList do
		SpineDataCacheManager:collectFightSpineByAtlas(self.mHeroAnimList[i])
	end
	self.mHeroAnimList = {}

	-- 可挑战玩家
	for i = 1, self.mArenaInfo.playerCount do
		local heroWidget = self:createCanAttackPlayer(self.mArenaInfo.canAttackPlayer[i])
		heroWidget:setTag(i)
		registerWidgetReleaseUpEvent(heroWidget, handler(self, self.setHeroSelected))
		self.mRootWidget:getChildByName("Panel_Player_"..tostring(i)):removeAllChildren()
		self.mRootWidget:getChildByName("Panel_Player_"..tostring(i)):addChild(heroWidget)	
	end


	GUISystem:hideLoading()
end

-- 请求战报
function ArenaWindow:requestArenaLog()
	GUISystem:playSound("homeBtnSound")
	local packet = NetSystem.mNetManager:GetSPacket()
	packet:SetType(PacketTyper._PTYPE_CS_REQUEST_ARENALOG_)
	packet:Send()
	GUISystem:showLoading()
end

-- 响应战报请求
function ArenaWindow:onRequestArenaLog(msgPacket)
	-- 战报
	self.mArenaInfo.logCount = msgPacket:GetUShort()
	self.mArenaInfo.log = {}

	for i = 1, self.mArenaInfo.logCount do
		self.mArenaInfo.log[i] = {}
		self.mArenaInfo.log[i].attackPlayerName  	= msgPacket:GetString()
		self.mArenaInfo.log[i].attackPlayerIconId 	= msgPacket:GetInt()
		self.mArenaInfo.log[i].attackPlayerLevel 	= msgPacket:GetInt()
		self.mArenaInfo.log[i].win = msgPacket:GetChar()
		self.mArenaInfo.log[i].rankChange = msgPacket:GetInt()
		self.mArenaInfo.log[i].defendPlayerName = msgPacket:GetString()
		self.mArenaInfo.log[i].defendPlayerFrameId = msgPacket:GetInt()
		self.mArenaInfo.log[i].defendPlayerIconId = msgPacket:GetInt()
		self.mArenaInfo.log[i].defendPlayerLevel = msgPacket:GetInt()
		self.mArenaInfo.log[i].time = msgPacket:GetString()
	end

	-- 显示战报窗口
	self:showLogWindow()
	GUISystem:hideLoading()
end


function ArenaWindow:Destroy()
	if not self.mIsLoaded then return end
	-- 清理Spine
	for i = 1, #self.mHeroAnimList do
		SpineDataCacheManager:collectFightSpineByAtlas(self.mHeroAnimList[i])
	end
	self.mHeroAnimList = {}

	self.mTopRoleInfoPanel:destroy()
	self.mTopRoleInfoPanel = nil

	self:destroyTick()

	self.mIsLoaded = false
	arenaPlayerWidget:release()
	arenaPlayerWidget = nil
	self.mRootNode:removeFromParent(true)
	self.mRootNode = nil
	self.mRootWidget = nil
	
	self.mArenaInfo = nil
	self.mPlayerInfoWindow = nil
	self.mLogWindow = nil
	self.mLastChooseWidget = nil
	self.mFormationSetWindow = nil
	self.mAttackSetWindow =	nil

	GUIEventManager:unregister("arenaChallCountChanged", self.onArenaChallCountChanged)
	GUIEventManager:unregister("roleBaseInfoChanged", self.onNailiInfoChanged)
end

function ArenaWindow:onEventHandler(event)
	if event.mAction == Event.WINDOW_SHOW then
		GUIWidgetPool:preLoadWidget("Arena_RewardCell", true)
		self:Load(event)
		---------停止画主城镇界面
		EventSystem:PushEvent(Event.GUISYSTEM_DISABLEDRAW_HOMEWINDOW)
		-- 红点刷新
		NoticeSystem:doSingleUpdate(self.mName)
	elseif event.mAction == Event.WINDOW_HIDE then
		GUIWidgetPool:preLoadWidget("Arena_RewardCell", false)
		self:Destroy()
		---------开启画主城镇界面
		EventSystem:PushEvent(Event.GUISYSTEM_EABLEDRAW_HOMEWINDOW)
		---------
	end
end

return ArenaWindow