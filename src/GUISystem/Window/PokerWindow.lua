-- Name: 	PokerWindow.lua
-- Func：	扑克
-- Author:	WangShengdong
-- Data:	16-1-22

-----------------------------------------------一堆定义---------------------------------------------


local maxChallengeCnt = 3 -- 最大挑战次数

local totalSecond	=	40 -- 游戏总时间(秒)

local pointerMoveTm = 0.75 -- 指针运动时间(秒)

local cardType = {"hongtao", "heitao", "fangpian", "meihua"}

local deltaX = 50 -- 横向运动偏移

local trunTm = 0.4 -- 翻转时间

local winCount = 5 -- 胜利条件

-----------------------------------------------一堆定义---------------------------------------------

-- 扑克牌
local cardObject = {}

function cardObject:new()
	local o = 
	{
		mRootNode	=	nil, 	-- 根节点
		mType 		= 	nil,    -- 花色
		mValue		=	nil,    -- 值
	}
	o = newObject(o, cardObject)
	return o
end

-- 初始化
function cardObject:init(node, type, val)
	self.mRootNode = node
	self.mType = type
	self.mValue = val

	-- 显示
	self.mRootNode:setVisible(true)
end

-- 初始化2
function cardObject:init2(anotherObj)
	self:init(anotherObj.mRootNode, anotherObj.mType, anotherObj.mValue)
end

-- 销毁
function cardObject:destroy()
	-- 隐藏
	self.mRootNode:setVisible(false)
end

local PokerWindow = 
{
	mName					=	"PokerWindow",
	mRootNode				=	nil,
	mRootWidget				=	nil,
	mCardPool				=	{}, 	-- 牌池子
	mEnemyCardObj			=	nil,	-- 敌方牌对象
	mEnemyCardWidget		=	nil,	-- 敌方卡牌
	mEnemyCardIndex			=	nil,	-- 敌方牌索引
	mSelfCardObj			=	nil,	-- 己方牌对象
	mSelfCardWidget			=	nil,	-- 己方卡牌
	mSelfCardIndex			=	nil,	-- 己方牌索引
	mLeftChallengeCnt		=   maxChallengeCnt,	-- 剩余挑战次数
	mPointerWidget			=	nil,	-- 指针
	mTotalTryCount			=	nil,	-- 总次数
	mOkCount				=	nil,	-- 正确次数
	mLeftGameSecond			=	nil,	-- 剩余时间
	-----------------------------------------------
	mHeroId					=	nil,	
	mGameType				=	3 		-- 扑克

}

-- 开启定时器
function PokerWindow:openScheduler()
	local scheduler = cc.Director:getInstance():getScheduler()
	if self.mSchedulerEntry then
		scheduler:unscheduleScriptEntry(self.mSchedulerEntry)
		self.mSchedulerEntry = nil
	end
	self.mSchedulerEntry = scheduler:scheduleScriptFunc(handler(self, self.gameTick), 1, false)
end

-- 关闭定时器
function PokerWindow:stopScheduler()
	local scheduler = cc.Director:getInstance():getScheduler()
	if self.mSchedulerEntry then
		scheduler:unscheduleScriptEntry(self.mSchedulerEntry)
		self.mSchedulerEntry = nil
	end
end

-- 定时器
function PokerWindow:gameTick()
	self.mLeftGameSecond = self.mLeftGameSecond - 1
	if self.mLeftGameSecond > 0 then
		local tmStr =  timeFormat(self.mLeftGameSecond)
		self.mRootWidget:getChildByName("Label_LastTime"):setString(tmStr)
	else
		if self.mOkCount >= winCount then -- 胜利
			self:gameWin()
		else -- 失败
			self:gameLose()
		end
	end
end

-- 游戏胜利
function PokerWindow:gameWin()
	-- 关闭定时器
--	self:stopScheduler()
--	MessageBox:showMessageBox1("恭喜您，您赢了！")

	local function closeWindow()
		EventSystem:PushEvent(Event.GUISYSTEM_HIDE_POKERWINDOW)
	end
	Event.GUISYSTEM_SHOW_BATTLERESULT_WIN.mData = {"Poker",closeWindow}
	EventSystem:PushEvent(Event.GUISYSTEM_SHOW_BATTLERESULT_WIN)

	-- 开启输入
	GUISystem:enableUserInput()

	local function xxx()
		MessageBox:showMessageBox1("游戏已经结束~")
	end

	local btn = self.mRootWidget:getChildByName("Button_Low")
	registerWidgetReleaseUpEvent(btn, xxx)

	btn = self.mRootWidget:getChildByName("Button_High")
	registerWidgetReleaseUpEvent(btn, xxx)

	local function sendResultToServer()
		local packet = NetSystem.mNetManager:GetSPacket()
		packet:SetType(PacketTyper._PTYPE_CS_LITTLE_GAME_RESULT)
		packet:PushInt(self.mHeroId)
		packet:PushInt(self.mGameType)
		packet:PushChar(0)	-- 0:胜利 1:失败
		packet:Send()
	end
	sendResultToServer()

end

-- 游戏失败
function PokerWindow:gameLose()
	-- 关闭定时器
--	self:stopScheduler()
--	MessageBox:showMessageBox1("很遗憾，您输了！")

	local function closeWindow()
		EventSystem:PushEvent(Event.GUISYSTEM_HIDE_POKERWINDOW)
	end
	Event.GUISYSTEM_SHOW_BATTLERESULT_LOSE.mData = {"Poker",closeWindow}
	EventSystem:PushEvent(Event.GUISYSTEM_SHOW_BATTLERESULT_LOSE)

	-- 开启输入
	GUISystem:enableUserInput()

	-- local function xxx()
	-- 	MessageBox:showMessageBox1("游戏已经结束~")
	-- end

	-- local btn = self.mRootWidget:getChildByName("Button_Low")
	-- registerWidgetReleaseUpEvent(btn, xxx)

	-- btn = self.mRootWidget:getChildByName("Button_High")
	-- registerWidgetReleaseUpEvent(btn, xxx)

	local function sendResultToServer()
		local packet = NetSystem.mNetManager:GetSPacket()
		packet:SetType(PacketTyper._PTYPE_CS_LITTLE_GAME_RESULT)
		packet:PushInt(self.mHeroId)
		packet:PushInt(self.mGameType)
		packet:PushChar(1)	-- 0:胜利 1:失败
		packet:Send()
	end
	sendResultToServer()

end

function PokerWindow:Release()

end

function PokerWindow:Load(event)
	cclog("=====PokerWindow:Load=====begin")

	self.mRootNode = cc.Node:create()
	GUISystem:GetRootNode():addChild(self.mRootNode)

	self.mHeroId = event.mData

	self:InitLayout()

	-- 游戏开始
	self:gameStart()
   
	cclog("=====PokerWindow:Load=====end")
end

-- 游戏开始
function PokerWindow:gameStart()
	-- 清除
	if self.mEnemyCardWidget then
		self.mEnemyCardWidget:removeFromParent(true)
		self.mEnemyCardWidget = nil
	end

	-- 清除
	if self.mSelfCardWidget then
		self.mSelfCardWidget:removeFromParent(true)
		self.mSelfCardWidget = nil
	end		
	-- 初始化时间
	self.mLeftGameSecond = totalSecond
	-- 正确次数清零
	self.mOkCount = 0
	-- 总次数清零
	self.mTotalTryCount = 0
	-- 剩余挑战次数减1
	self.mLeftChallengeCnt = self.mLeftChallengeCnt - 1
	-- 初始化牌池
	self:initCardPool()
	-- 回合开始
	self:roundBegin()
end

-- 更新游戏状态
function PokerWindow:updateGameState()
	self.mRootWidget:getChildByName("Label_Score"):setString(self.mOkCount.."/"..winCount)
end

-- 回合开始
function PokerWindow:roundBegin()
	-- 回合数+1
	self.mTotalTryCount = self.mTotalTryCount + 1

--	self:openScheduler()

	if 0 == #self.mCardPool then
		-- 游戏失败
		self:gameLose()
		return
	end

	-- 随机一张敌方牌
	local function randomEnemyCard()

		

		self.mEnemyCardIndex = math.random(1, #self.mCardPool)
		self.mEnemyCardObj = cardObject:new()
		self.mEnemyCardObj:init2(self.mCardPool[self.mEnemyCardIndex])
		-- 取出操作
		table.remove(self.mCardPool, self.mEnemyCardIndex)

		-- 当前指针运动
		local pointerIndex = self.mEnemyCardObj.mValue
		local tarPos = cc.p(self.mRootWidget:getChildByName("Panel_Num_"..pointerIndex):getPosition())
		local act0 = cc.MoveTo:create(pointerMoveTm, tarPos)
		self.mPointerWidget:runAction(act0)

		-- 创建敌方卡牌
		self.mEnemyCardWidget = self:createOneCard(self.mEnemyCardObj)
		self.mEnemyCardWidget:getChildByName("Panel_Back"):setVisible(false)
		self.mEnemyCardWidget:getChildByName("Panel_Front"):setVisible(true)
		self.mRootWidget:getChildByName("Panel_Card_System"):addChild(self.mEnemyCardWidget)

		-- 运动进来
		self.mEnemyCardWidget:setOpacity(0)
		self.mEnemyCardWidget:setPositionX(deltaX + self.mEnemyCardWidget:getContentSize().width)
		
		act0 = cc.MoveTo:create(pointerMoveTm, cc.p(0, 0))
		local act1 = cc.FadeIn:create(pointerMoveTm)
		self.mEnemyCardWidget:runAction(cc.Spawn:create(act0, act1))
	end
	randomEnemyCard()
	
	-- 随机一张己方牌
	local function randomSelfCard()
		self.mSelfCardIndex = math.random(1, #self.mCardPool)
		self.mSelfCardObj = cardObject:new()
		self.mSelfCardObj:init2(self.mCardPool[self.mSelfCardIndex])
		-- 取出操作
	--	self.mCardPool[self.mSelfCardIndex ]:destroy()
		table.remove(self.mCardPool, self.mSelfCardIndex)

		-- 创建己方卡牌
		self.mSelfCardWidget = self:createOneCard(self.mSelfCardObj)
		self.mSelfCardWidget:getChildByName("Panel_Back"):setVisible(true)
		self.mSelfCardWidget:getChildByName("Panel_Front"):setVisible(false)
		self.mRootWidget:getChildByName("Panel_Card_Player"):addChild(self.mSelfCardWidget)

		-- 运动进来
		self.mSelfCardWidget:setOpacity(0)
		self.mSelfCardWidget:setPositionX(deltaX + self.mSelfCardWidget:getContentSize().width)

		local function onActEnd()
			-- 开启输入
			GUISystem:enableUserInput()

			MessageBox:showMessageBox1("请选择大小~")
		end
		
		act0 = cc.MoveTo:create(pointerMoveTm, cc.p(0, 0))
		local act1 = cc.FadeIn:create(pointerMoveTm)
		local act2 = cc.CallFunc:create(onActEnd)
		self.mSelfCardWidget:runAction(cc.Sequence:create(cc.Spawn:create(act0, act1), act2))

		-- 屏蔽输入
		GUISystem:disableUserInput()

	end
	randomSelfCard()

end

-- 创建卡牌
function PokerWindow:createOneCard(cardObj)
	local widget = GUIWidgetPool:createWidget("NewDate_GameCard_Cell")
	-- 数字
	widget:getChildByName("Label_Num_Top"):setString(cardObj.mValue)
	widget:getChildByName("Label_Num_Bottom"):setString(cardObj.mValue)

	if 1 == cardObj.mValue then
		widget:getChildByName("Label_Num_Top"):setString("A")
		widget:getChildByName("Label_Num_Bottom"):setString("A")
	end

	if "hongtao" == cardObj.mType or "fangpian" == cardObj.mType then
		widget:getChildByName("Label_Num_Top"):setColor(G_COLOR_C3B.RED)
		widget:getChildByName("Label_Num_Bottom"):setColor(G_COLOR_C3B.RED)
	elseif  "heitao" == cardObj.mType or "meihua" == cardObj.mType then
		widget:getChildByName("Label_Num_Top"):setColor(G_COLOR_C3B.BLACK )
		widget:getChildByName("Label_Num_Bottom"):setColor(G_COLOR_C3B.BLACK )
	end

	local pngInfoTbl = 
	{
		hongtao = "date_game_card_suit_heart.png",
		heitao  = "date_game_card_suit_spade.png",
		fangpian = "date_game_card_suit_diamond.png",
		meihua = "date_game_card_suit_club.png",
	}

	-- 图案
	local imgName = pngInfoTbl[cardObj.mType]
	widget:getChildByName("Image_Suit_Top"):loadTexture(imgName)
	widget:getChildByName("Image_Suit_Bottom"):loadTexture(imgName)
	-- 全部隐藏
	for i = 1, 10 do
		widget:getChildByName("Panel_Card_"..i):setVisible(false)
	end
	-- 单个显示
	local panelNode = widget:getChildByName("Panel_Card_"..cardObj.mValue)
	panelNode:setVisible(true)
	-- 换图
	for i = 1, cardObj.mValue do
		panelNode:getChildByName("Image_Num_"..i):loadTexture(imgName)
	end
	return widget
end

-- 初始化牌池
function PokerWindow:initCardPool()

	self.mCardPool = {}
	-- 红桃
	for i = 1, 10 do
		local newCard = cardObject:new()
		local rootNode = self.mRootWidget:getChildByName("Panel_Num_"..i):getChildByName("Label_Type_1")
		newCard:init(rootNode, "hongtao", i)
		table.insert(self.mCardPool, newCard)
	end

	-- 黑桃
	for i = 1, 10 do
		local newCard = cardObject:new()
		local rootNode = self.mRootWidget:getChildByName("Panel_Num_"..i):getChildByName("Label_Type_2")
		newCard:init(rootNode, "heitao", i)
		table.insert(self.mCardPool, newCard)
	end

	-- 方片
	for i = 1, 10 do
		local newCard = cardObject:new()
		local rootNode = self.mRootWidget:getChildByName("Panel_Num_"..i):getChildByName("Label_Type_3")
		newCard:init(rootNode, "fangpian", i)
		table.insert(self.mCardPool, newCard)
	end

	-- 梅花
	for i = 1, 10 do
		local newCard = cardObject:new()
		local rootNode = self.mRootWidget:getChildByName("Panel_Num_"..i):getChildByName("Label_Type_4")
		newCard:init(rootNode, "meihua", i)
		table.insert(self.mCardPool, newCard)
	end

end

function PokerWindow:InitLayout()

	self.mRootWidget = GUIWidgetPool:createWidget("NewDate_GameCard")
	self.mRootNode:addChild(self.mRootWidget, 2)

	local function closeWindow()
		EventSystem:PushEvent(Event.GUISYSTEM_HIDE_POKERWINDOW)
	end
	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_Back"), closeWindow)

	self.mPointerWidget = self.mRootWidget:getChildByName("Panel_Num_Cur")

	local btn = self.mRootWidget:getChildByName("Button_Low")
	btn:setTag(-1)
	registerWidgetReleaseUpEvent(btn, handler(self, self.onSelectedBtnClicked))

	btn = self.mRootWidget:getChildByName("Button_High")
	btn:setTag(1)
	registerWidgetReleaseUpEvent(btn, handler(self, self.onSelectedBtnClicked))

	local function doAdapter()
		-- Panel_Top左上角
		self.mRootWidget:getChildByName("Panel_TopLeft"):setPosition(cc.p(getGoldFightPosition_LU().x, getGoldFightPosition_LU().y - self.mRootWidget:getChildByName("Panel_TopLeft"):getContentSize().height))
	end
	doAdapter()
end

function PokerWindow:onSelectedBtnClicked(btn)
	local ret = -1 -- -1:输 0:平 1:赢

	if self.mSelfCardObj.mValue > self.mEnemyCardObj.mValue then
		if -1 == btn:getTag() then -- 猜小
			ret = -1
		elseif 1 == btn:getTag() then -- 猜大
			ret = 1
		end
	elseif self.mSelfCardObj.mValue == self.mEnemyCardObj.mValue then
		ret = 0
	elseif self.mSelfCardObj.mValue < self.mEnemyCardObj.mValue then
		if -1 == btn:getTag() then -- 猜小
			ret = 1
		elseif 1 == btn:getTag() then -- 猜大
			ret = -1
		end
	end

--	self:stopScheduler()

	-- 翻前面
	local function turnFront()
		local function xxx()
			self.mSelfCardWidget:getChildByName("Panel_Front"):setLocalZOrder(5)
			self.mSelfCardWidget:getChildByName("Panel_Front"):setVisible(true)
		end

		local act0 = cc.OrbitCamera:create(trunTm, 1, 0, 0, 180, 0, 0)
		local act1 = cc.DelayTime:create(trunTm/2)
		local act2 = cc.CallFunc:create(xxx)

		self.mSelfCardWidget:getChildByName("Panel_Front"):setScaleX(-1)
		self.mSelfCardWidget:getChildByName("Panel_Front"):runAction(cc.Spawn:create(act0, cc.Sequence:create(act1, act2)))
	end
	turnFront()

	-- 显示结果
	local function showResultFunc()
		if -1 == ret then
			MessageBox:showMessageBox1("您猜错了~")
			self.mOkCount = 0
		elseif 0 == ret then
			MessageBox:showMessageBox1("平局~")
		elseif 1 == ret then
			MessageBox:showMessageBox1("您猜对了~")
			self.mOkCount = self.mOkCount + 1
		end
		-- 显示战绩
		self:updateGameState()
		-- 移除己方卡
		self.mSelfCardObj:destroy()
		-- 移除敌方卡
		self.mEnemyCardObj:destroy()


		-- 下一回合
		local function nextRound()
			-- 判断是否胜利
			if self.mOkCount >= winCount then -- 胜利
				self:gameWin()
				return
			end

			-- 屏蔽
			GUISystem:enableUserInput()

			-- 清除
			self.mEnemyCardWidget:removeFromParent(true)
			self.mEnemyCardWidget = nil

			-- 清除
			self.mSelfCardWidget:removeFromParent(true)
			self.mSelfCardWidget = nil		

			-- 回合
			self:roundBegin()
		end

		-- 敌方淡出
		local act0 = cc.MoveBy:create(pointerMoveTm, cc.p(-deltaX - self.mEnemyCardWidget:getContentSize().width, 0))
		local act1 = cc.FadeOut:create(pointerMoveTm)
		self.mEnemyCardWidget:runAction(cc.Spawn:create(act0, act1))

		-- 己方淡出
		act0 = cc.MoveBy:create(pointerMoveTm, cc.p(-deltaX - self.mSelfCardWidget:getContentSize().width, 0))
		act1 = cc.FadeOut:create(pointerMoveTm)
		local act2 = cc.CallFunc:create(nextRound)
		self.mSelfCardWidget:runAction(cc.Sequence:create(cc.Spawn:create(act0, act1), act2))
	end

	-- 翻背面
	local function turnBack()
		local function xxx()
			self.mSelfCardWidget:getChildByName("Panel_Back"):setLocalZOrder(1)
			self.mSelfCardWidget:getChildByName("Panel_Back"):setVisible(false)
		end

		local act0 = cc.OrbitCamera:create(trunTm, 1, 0, 0, 180, 0, 0)
		local act1 = cc.DelayTime:create(trunTm/2)
		local act2 = cc.CallFunc:create(xxx)
		local act3 = cc.DelayTime:create(1) -- 翻牌1秒后判断结果
		local act4 = cc.CallFunc:create(showResultFunc)

		self.mSelfCardWidget:getChildByName("Panel_Back"):runAction(cc.Sequence:create(   cc.Spawn:create(act0, cc.Sequence:create(act1, act2))  , act3, act4))
	end
	turnBack()

	-- 屏蔽
	GUISystem:disableUserInput()
end

function PokerWindow:Destroy()
	-- 关闭定时器
--	self:stopScheduler()

	self.mRootNode:removeFromParent(true)
	self.mRootNode 		= 	nil
	self.mRootWidget 	= 	nil

	self.mCardPool				=	{}
	self.mEnemyCardObj			=	nil
	self.mEnemyCardWidget		=	nil
	self.mEnemyCardIndex		=	nil
	self.mSelfCardObj			=	nil
	self.mSelfCardWidget		=	nil
	self.mSelfCardIndex			=	nil
	self.mLeftChallengeCnt		=   maxChallengeCnt
	self.mPointerWidget			=	nil
	self.mTotalTryCount			=	nil
	self.mOkCount				=	nil
	self.mLeftGameSecond		=	nil
end

function PokerWindow:onEventHandler(event)
	if event.mAction == Event.WINDOW_SHOW then
		self:Load(event)
	elseif event.mAction == Event.WINDOW_HIDE then
		self:Destroy()
	end
end

return PokerWindow