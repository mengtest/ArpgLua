-- Name: 	HeroGuessWindow.lua
-- Func：	篮球
-- Author:	WangShengdong
-- Data:	16-1-15

local totalSecond	=	40 -- 游戏总时间(秒)

local perRoundSecond	= 8 -- 每回合时间(秒)

local winCount = 5 -- 总共需要猜对的次数

local function timeFormat(seconds)
	local min = math.floor(seconds / 60)
	seconds = math.mod(seconds, 60)
	local sec = seconds
	return string.format("%02d:%02d", min, sec)
end

local state = {"playing", "win", "lose"}

local HeroGuessWindow = 
{
	mName					=	"HeroGuessWindow",
	mRootNode				=	nil,
	mRootWidget				=	nil,
	------------------------------------------
	mAllHeroIdTbl			=	{},   				-- 所有英雄ID表
	mAllHeroIconList 		=	{},					-- 所有英雄icon
	mCurSelectedHeroWidget	=	nil,				-- 当前点击的英雄头像
	------------------------------------------
	mSchedulerEntry			=	nil,				-- 定时器
	mLeftGameSecond			=	nil,				-- 剩余秒数
	mTotalTryCount			=	nil,				-- 猜测总次数
	mOkCount				=	nil,				-- 猜对次数
	mTotalRoundCount		=	nil,				-- 当前回合数
	------------------------------------------
	mQuestionHeroId			=	nil,				-- 问题英雄ID
	mMaskImgWidget			=	nil,				-- 遮挡图片
	mGameState				=	nil,				-- 游戏状态
	mPlayerSelected			=	true,				-- 玩家有选择操作
	-----------------------------------------------------------------
	mHeroId					=	nil,	
	mGameType				=	2 		-- 猜人
}

function HeroGuessWindow:Release()

end

function HeroGuessWindow:Load(event)
	cclog("=====HeroGuessWindow:Load=====begin")

	self.mRootNode = cc.Node:create()
	GUISystem:GetRootNode():addChild(self.mRootNode)

	self.mHeroId = event.mData

	self:InitLayout()

	self:initAllHeroIdTbl()

	self:initAllHeroIcon()

	-- 开始游戏
	self:gameStart()
   
	cclog("=====HeroGuessWindow:Load=====end")
end

-- 初始化所有英雄id
function HeroGuessWindow:initAllHeroIdTbl()
	for i = 1, maxHeroCount do -- 存在
		local heroData = DB_HeroConfig.getDataById(i)
		if 1 == heroData.Open then 
			table.insert(self.mAllHeroIdTbl, i)
		end
	end
end

-- 初始化所有英雄icon
function HeroGuessWindow:initAllHeroIcon()
	for i = 1, #self.mAllHeroIdTbl do
		local heroId = self.mAllHeroIdTbl[i]
		local heroData = DB_HeroConfig.getDataById(heroId)
		local heroImgId = heroData.IconID
		local heroImgName = DB_ResourceList.getDataById(heroImgId).Res_path1
		self.mAllHeroIconList[i] = self.mRootWidget:getChildByName("Panel_Hero_"..tostring(i))
		self.mAllHeroIconList[i]:getChildByName("Image_HeroIcon"):loadTexture(heroImgName,1)
		self.mAllHeroIconList[i]:setTag(heroId)
		registerWidgetReleaseUpEvent(self.mAllHeroIconList[i], handler(self, self.onHeroIconClicked))
	end
end

-- 开启定时器
function HeroGuessWindow:openScheduler()
	local scheduler = cc.Director:getInstance():getScheduler()
	if self.mSchedulerEntry then
		scheduler:unscheduleScriptEntry(self.mSchedulerEntry)
		self.mSchedulerEntry = nil
	end
	self.mSchedulerEntry = scheduler:scheduleScriptFunc(handler(self, self.gameTick), 1, false)
end

-- 关闭定时器
function HeroGuessWindow:stopScheduler()
	local scheduler = cc.Director:getInstance():getScheduler()
	if self.mSchedulerEntry then
		scheduler:unscheduleScriptEntry(self.mSchedulerEntry)
		self.mSchedulerEntry = nil
	end
end

-- 开始游戏
function HeroGuessWindow:gameStart()
	-- 初始化时间
	self.mLeftGameSecond = totalSecond

	-- 开启输入
	for i = 1, #self.mAllHeroIconList do
		self.mAllHeroIconList[i]:setTouchEnabled(true)
	end

	-- 初始化猜测总次数
	self.mTotalTryCount = 0

	-- 初始化猜测对的次数
	self.mOkCount = 0

	-- 初始化当前回合
	self.mTotalRoundCount = 0

	-- 初始化游戏状态
	self.mGameState = "playing"

	-- 玩家选择状态
	self.mPlayerSelected = true

	-- 回合开始
	self:roundBegin()
end

-- 回合开始
function HeroGuessWindow:roundBegin()
	-- 判断游戏状态
	if "playing" ~= self.mGameState then
		return
	end

	if self.mPlayerSelected then -- 玩家有选择操作
		
	else -- 玩家没有选择操作
		self.mTotalTryCount = self.mTotalTryCount + 1
	end
	self.mPlayerSelected = false

	-- 开启定时器
	self:openScheduler()
	-- 开启输入
	GUISystem:enableUserInput()
	-- 删除前一个选中
	if self.mCurSelectedHeroWidget then
		self.mCurSelectedHeroWidget:getChildByName("Image_Chose"):setVisible(false)
		self.mCurSelectedHeroWidget = nil
	end
	-- 回合计数
	self.mTotalRoundCount = self.mTotalRoundCount + 1
	-- 随机一个英雄
	self.mQuestionHeroId = self.mAllHeroIdTbl[math.random(1, 18)]

	MessageBox:showMessageBox1("第"..self.mTotalRoundCount.."幅图~")

	-- 载入大图
	local heroData = DB_HeroConfig.getDataById(self.mQuestionHeroId)
	local heroImgId = heroData.PicID
	local heroImgName = DB_ResourceList.getDataById(heroImgId).Res_path1
	self.mRootWidget:getChildByName("Panel_Left"):getChildByName("Image_HeroPic"):loadTexture(heroImgName)

	-- 添加遮挡图片
	if self.mMaskImgWidget then
		self.mMaskImgWidget:removeFromParent()
		self.mMaskImgWidget = nil
	end
	local imgWidget = cc.Sprite:create("date_game_guess_cover.png")
	self.mMaskImgWidget = cc.ProgressTimer:create(imgWidget)
	self.mMaskImgWidget:setType(cc.PROGRESS_TIMER_TYPE_BAR)
	self.mMaskImgWidget:setMidpoint(cc.p(1, 0))
	self.mMaskImgWidget:setAnchorPoint(cc.p(0, 0))
	self.mMaskImgWidget:setBarChangeRate(cc.p(0, 1))
	self.mMaskImgWidget:setPosition(0, 0)
	self.mMaskImgWidget:setPercentage(50)
	self.mRootWidget:getChildByName("Panel_Left"):getChildByName("Panel_HeroPic"):addChild(self.mMaskImgWidget, 100)

	-- 图片全部展开
	local function onActEnd()
		self:roundBegin()
	end

	local act0 = cc.ProgressFromTo:create(perRoundSecond, 100, 0)
	local act1 = cc.CallFunc:create(onActEnd)
	self.mMaskImgWidget:runAction(cc.Sequence:create(act0, act1))

	-- 更新游戏状态 
	self:updateGameState()

end

-- 定时器
function HeroGuessWindow:gameTick()
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
function HeroGuessWindow:gameWin()
	-- 关闭定时器
	self:stopScheduler()
--	MessageBox:showMessageBox1("恭喜您，您赢了！")

	local function closeWindow()
		EventSystem:PushEvent(Event.GUISYSTEM_HIDE_HEROGUESSWINDOW)
	end
	Event.GUISYSTEM_SHOW_BATTLERESULT_WIN.mData = {"HeroGuess",closeWindow}
	EventSystem:PushEvent(Event.GUISYSTEM_SHOW_BATTLERESULT_WIN)


	self.mGameState = "win"

	-- 屏蔽输入
	for i = 1, #self.mAllHeroIconList do
		self.mAllHeroIconList[i]:setTouchEnabled(false)
	end

	-- 全部图片显示
	if self.mMaskImgWidget then
		self.mMaskImgWidget:setPercentage(0)
		self.mMaskImgWidget:stopAllActions()
	end

	-- 开启输入
	GUISystem:enableUserInput()

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
function HeroGuessWindow:gameLose()
	-- 关闭定时器
	self:stopScheduler()
--	MessageBox:showMessageBox1("很遗憾，您输了！")

	local function closeWindow()
		EventSystem:PushEvent(Event.GUISYSTEM_HIDE_HEROGUESSWINDOW)
	end
	Event.GUISYSTEM_SHOW_BATTLERESULT_LOSE.mData = {"HeroGuess",closeWindow}
	EventSystem:PushEvent(Event.GUISYSTEM_SHOW_BATTLERESULT_LOSE)

	self.mGameState = "lose"

	-- 屏蔽输入
	for i = 1, #self.mAllHeroIconList do
		self.mAllHeroIconList[i]:setTouchEnabled(false)
	end

	-- 全部图片显示
	if self.mMaskImgWidget then
		self.mMaskImgWidget:setPercentage(0)
		self.mMaskImgWidget:stopAllActions()
	end

	-- 开启输入
	GUISystem:enableUserInput()

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

-- 响应英雄头像点击
function HeroGuessWindow:onHeroIconClicked(widget)
	if widget == self.mCurSelectedHeroWidget then
		return
	end
	self.mCurSelectedHeroWidget = widget

	self.mCurSelectedHeroWidget:getChildByName("Image_Chose"):setVisible(true)

	-- 计数
	self.mTotalTryCount = self.mTotalTryCount + 1
	self.mPlayerSelected = true

	local result = false

	-- 对比
	if widget:getTag() == self.mQuestionHeroId then
		-- 计数
		self.mOkCount = self.mOkCount + 1
		result = true
	else
		result = false
	end

	-- 全部图片显示
	if self.mMaskImgWidget then
		self.mMaskImgWidget:setPercentage(0)
		self.mMaskImgWidget:stopAllActions()
	end
	-- 屏蔽输入
	GUISystem:disableUserInput()

	-- 下一回合
	local function nextRound()
		self.mRootWidget:getChildByName("Image_Result"):setVisible(false)

		-- 判断是否胜利
		if self.mOkCount >= winCount then -- 胜利
			self:gameWin()
			return
		end

		-- 回合开始
		self:roundBegin()
	end

	-- 显示结果
	local function showResult()
		self.mRootWidget:getChildByName("Image_Result"):setVisible(true)
		if result then -- 正确
			self.mRootWidget:getChildByName("Image_Result"):loadTexture("date_game_guess_logo_right.png")
			MessageBox:showMessageBox1("恭喜你答对了！")
		else -- 错误
			self.mRootWidget:getChildByName("Image_Result"):loadTexture("date_game_guess_logo_wrong.png")
			MessageBox:showMessageBox1("没有猜对，加油哦！")
		end
		-- 更新游戏状态 
		self:updateGameState()
	end

	local act0 = cc.DelayTime:create(1)
	local act1 = cc.CallFunc:create(showResult)
	local act2 = cc.DelayTime:create(2)
	local act3 = cc.CallFunc:create(nextRound)
	self.mMaskImgWidget:runAction(cc.Sequence:create(act0, act1, act2, act3))

	-- 关闭定时器
--	self:stopScheduler()
end

-- 更新游戏状态
function HeroGuessWindow:updateGameState()
	-- 显示正确率
	self.mRootWidget:getChildByName("Label_Right_Num"):setString(self.mOkCount.."/"..self.mTotalTryCount)
	-- 显示完成度
	self.mRootWidget:getChildByName("Label_Win_Num"):setString((self.mOkCount).."/"..winCount)
end

function HeroGuessWindow:InitLayout()

	self.mRootWidget = GUIWidgetPool:createWidget("NewDate_GameHeroGuess")
	self.mRootNode:addChild(self.mRootWidget, 2)

	local function closeWindow()
		EventSystem:PushEvent(Event.GUISYSTEM_HIDE_HEROGUESSWINDOW)
	end
	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_Back"), closeWindow)

	local function doAdapter()
		-- Panel_Top左上角
		self.mRootWidget:getChildByName("Panel_TopLeft"):setPosition(cc.p(getGoldFightPosition_LU().x, getGoldFightPosition_LU().y - self.mRootWidget:getChildByName("Panel_TopLeft"):getContentSize().height))

		-- 向下窜50后居中
		local topInfoPanelHeight = 50
	    local newHeight = getGoldFightPosition_LU().y - topInfoPanelHeight - getGoldFightPosition_LD().y
	    local newPosY = newHeight/2 + getGoldFightPosition_LD().y - self.mRootWidget:getChildByName("Panel_Main"):getContentSize().height/2
	    self.mRootWidget:getChildByName("Panel_Main"):setAnchorPoint(cc.p(0.5, 0.5))
	    local panelSize = self.mRootWidget:getChildByName("Panel_Main"):getContentSize()
	    local curPosX = self.mRootWidget:getChildByName("Panel_Main"):getPositionX()
	    self.mRootWidget:getChildByName("Panel_Main"):setPositionX(curPosX + panelSize.width/2)
		self.mRootWidget:getChildByName("Panel_Main"):setPositionY(newPosY + panelSize.height/2)
	end
	doAdapter()
 
	self.mRootWidget:getChildByName("Label_LastTime"):setString(timeFormat(totalSecond))
end

function HeroGuessWindow:Destroy()

	self.mAllHeroIdTbl			=	{}  				-- 所有英雄ID表
	self.mAllHeroIconList 		=	{}					-- 所有英雄icon
	self.mCurSelectedHeroWidget	=	nil					-- 当前点击的英雄头像
	self.mMaskImgWidget			=   nil

	if self.mSchedulerEntry then
		local scheduler = cc.Director:getInstance():getScheduler()
		scheduler:unscheduleScriptEntry(self.mSchedulerEntry)
		self.mSchedulerEntry = nil
	end

	self.mRootNode:removeFromParent(true)
	self.mRootNode 		= 	nil
	self.mRootWidget 	= 	nil

end

function HeroGuessWindow:onEventHandler(event)
	if event.mAction == Event.WINDOW_SHOW then
		self:Load(event)
	elseif event.mAction == Event.WINDOW_HIDE then
		self:Destroy()
	end
end

return HeroGuessWindow