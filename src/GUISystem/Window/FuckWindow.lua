-- Name: 	FuckWindow
-- Func：	约会
-- Author:	WangShengdong
-- Data:	15-1-8

math.randomseed(os.time())

local moveTime 	= 	0.35
local moveDis 	=	500

local FuckWindow = 
{
	mName				=	"FuckWindow",
	mRootNode			=	nil,
	mRootWidget			=	nil,
	mTopRoleInfoPanel	=	nil,

	---------------------------
	mCurHeroId			=	nil,
	mCurHeroAnim 		=	nil,
	---------------------------

	mHeroWindow			=	nil,
	---------------------------
	mFuckInfo			=	nil,	-- 约会信息
	---------------------------
	mAskHeroId			=	nil,	-- 请求提问的英雄ID
	mQuestionId			=	nil,	-- 问题ID
	---------------------------
	mGiftWidgetList		=	{}, 	-- 礼物

	mHeroWidgetList 	= 	{},
	mCurClickedSchoolWidget = nil,

	mNoticeAnimNode		=	nil,	-- 特效节点
}

function FuckWindow:Release()

end

function FuckWindow:flyMenu(dir, func)
	local 	actWidget 	= nil
	local  	curPos 		= nil

	if "left" == dir then
		local function onActEnd()
			GUISystem:enableUserInput()
			if func then
				func()
			end
		end

		for i = 1, 4 do
			if 4 ~= i then
				actWidget = self.mRootWidget:getChildByName("Button_Event_"..tostring(i))
			elseif 4 == i then
				actWidget = self.mRootWidget:getChildByName("Button_Present")
			end
			curPos = cc.p(actWidget:getPosition())
			local act0 = cc.DelayTime:create(i*0.15)
			local act1 = cc.EaseOut:create(cc.MoveTo:create(moveTime/2, curPos), 2.5)
			local act2 = cc.CallFunc:create(onActEnd)
			actWidget:setPositionX(curPos.x + moveDis)
			if 4 ~= i then
				actWidget:runAction(cc.Sequence:create(act0, act1))
			elseif 4 == i then
				actWidget:runAction(cc.Sequence:create(act0, act1, act2))
			end
			actWidget:setVisible(true)
		end
	elseif "right" == dir then
		local function onActEnd()
			GUISystem:enableUserInput()
			if func then
				func()
			end
			for i = 1, 4 do
				if 4 ~= i then
					actWidget = self.mRootWidget:getChildByName("Button_Event_"..tostring(i))
				elseif 4 == i then
					actWidget = self.mRootWidget:getChildByName("Button_Present")
				end
				curPos = cc.p(actWidget:getPosition())
				actWidget:setPositionX(curPos.x - moveDis)
				actWidget:setVisible(true)
			end
		end

		for i = 1, 4 do
			if 4 ~= i then
				actWidget = self.mRootWidget:getChildByName("Button_Event_"..tostring(i))
			elseif 4 == i then
				actWidget = self.mRootWidget:getChildByName("Button_Present")
			end
			curPos = cc.p(actWidget:getPosition())
			local act0 = cc.DelayTime:create(i*0.15)
			local act1 = cc.EaseIn:create(cc.MoveTo:create(moveTime/2, cc.p(curPos.x + moveDis, curPos.y)), 2.5)
			local act2 = cc.CallFunc:create(onActEnd)
			if 4 ~= i then
				actWidget:runAction(cc.Sequence:create(act0, act1))
			elseif 4 == i then
				actWidget:runAction(cc.Sequence:create(act0, act1, act2))
			end
			actWidget:setVisible(true)
		end
	end
	GUISystem:disableUserInput()
end

function FuckWindow:onMsgBox(msgPacket)
	local rootWidget = GUIWidgetPool:createWidget("NewDate_TipsFriendshipChange")
	local msgWidget = rootWidget:getChildByName("Panel_Main")
	msgWidget:setOpacity(0)

	-- 清理
	local function doCleanup()
		rootWidget:removeFromParent(true)
	end

	-- 做动作
	local function doAction()
		local act0 = cc.MoveBy:create(0.2, cc.p(0, 100))
		local act1 = cc.FadeIn:create(0.2)
		local act2 = cc.DelayTime:create(2)
		local act3 = cc.MoveBy:create(0.2, cc.p(0, 200))
		local act4 = cc.FadeOut:create(0.2)
		local act5 = cc.CallFunc:create(doCleanup)
		msgWidget:runAction(cc.Sequence:create( cc.Spawn:create(act0, act1), act2, cc.Spawn:create(act3, act4), act5 ))	
	end 
	doAction()

	local heroId 		= msgPacket:GetInt() -- 英雄ID
	local addFuckExp 	= msgPacket:GetInt() -- 增加的好感度
	local curFuckExp 	= msgPacket:GetInt() -- 当前的好感度
	local playerChange 	= msgPacket:GetInt() -- 玩家是否升级
	local curFuckLevel  = nil
	if 0 == playerChange then
		curFuckLevel = msgPacket:GetInt() -- 玩家约会级别
	end

	local addHeroFuckExp 	= msgPacket:GetInt() -- 增加的英雄好感度
	local curHeroFuckExp 	= msgPacket:GetInt() -- 当前的英雄好感度
	local heroChange 		= msgPacket:GetInt() 	 -- 英雄是否升级
	local curHeroFuckLevel  = nil
	if 0 == heroChange then
		curHeroFuckLevel = msgPacket:GetInt() -- 英雄约会级别
	end

	-- 头像
	local heroData 	= DB_HeroConfig.getDataById(heroId)
	local imgId 	= heroData.IconID
	local imgName 	= DB_ResourceList.getDataById(imgId).Res_path1
	local heroName  = heroData.Name
	msgWidget:getChildByName("Image_HeroIcon"):loadTexture(imgName, 1)

	if 0 == playerChange then
		richTextCreateWithFont(msgWidget:getChildByName("Panel_PlayerFriendship"), string.format("#fff841组织魅力# #45ff41+%d#，等级提升至 #fff841%s#", addFuckExp, curFuckLevel), true,22)
	elseif 1 == playerChange then
		richTextCreateWithFont(msgWidget:getChildByName("Panel_PlayerFriendship"), string.format("#fff841组织魅力# #45ff41+%d#", addFuckExp), true,22)
	end

	if 0 == heroChange then
		richTextCreateWithFont(msgWidget:getChildByName("Panel_HeroFriendship"), string.format("学员 #51fdff%s# 好感度 #45ff41+%d#，等级提升至 #fff841%s#", getDictionaryText(heroName), addHeroFuckExp, curHeroFuckLevel), true,25)
	elseif 1 == heroChange then
		richTextCreateWithFont(msgWidget:getChildByName("Panel_HeroFriendship"), string.format("学员 #51fdff%s# 好感度 #45ff41+%d#", getDictionaryText(heroName), addHeroFuckExp), true,22)
	end

	GUISystem.RootNode:addChild(rootWidget, GUISYS_ZORDER_MESSAGEBOXWINDOW)
end

function FuckWindow:Load(event)
	cclog("=====FuckWindow:Load=====begin")

	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_CS_FUCK_INFO_SYNC, handler(self, self.onFuckInfoChanged))

	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_LITTLE_GAME_RESULT, handler(self, self.onLittleGameResult))

	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_MSGBOX_INFO_, handler(self, self.onMsgBox))

	self.mFuckInfo = event.mData

	self.mRootNode = cc.Node:create()
	GUISystem:GetRootNode():addChild(self.mRootNode)

	GUIEventManager:registerEvent("itemInfoChanged", self, self.onItemInfoChanged)

	self:InitLayout()

	-- 默认显示全部
	self:onSchoolSelected(self.mRootWidget:getChildByName("Image_All"))

	-- 显示对话泡泡
	self:showHeroTalkBuble()

	-- 显示约会信息
	self:showFuckInfoFromServer()

	-- 特效
	self.mNoticeAnimNode = AnimManager:createAnimNode(8022)
	self.mRootWidget:getChildByName("Panel_Bottom"):getChildByName("Panel_Hello"):getChildByName("Panel_ArrowAnimation"):addChild(self.mNoticeAnimNode:getRootNode(), 100)

	cclog("=====FuckWindow:Load=====end")
end

-- 显示约会信息
function FuckWindow:showFuckInfoFromServer()

	-- 玩家好感度等级
	self.mRootWidget:getChildByName("Label_PlayerFavor_Level_Stroke"):setString(tostring(self.mFuckInfo.level))

	-- 玩家好感度经验条
	self.mRootWidget:getChildByName("ProgressBar_PlayFavor"):setPercent(self.mFuckInfo.exp*100/self.mFuckInfo.maxExp)

	-- 剩余送礼物次数
	self.mRootWidget:getChildByName("Label_LastTimes_Stroke_163_55_8"):setString("剩余 "..tostring(self.mFuckInfo.mLeftGiftCount).."/"..tostring(self.mFuckInfo.mTotalGiftCount))
end

-- 同步小游戏信息
function FuckWindow:onLittleGameResult(msgPacket)
	local heroId = msgPacket:GetInt()
	for i = 1, #self.mFuckInfo.heroList do
		if heroId == self.mFuckInfo.heroList[i].heroId then
			local gameType = msgPacket:GetInt()
			self.mFuckInfo.heroList[i].gameState[gameType] = msgPacket:GetInt()
			break
		end
	end

	self.mFuckInfo.game1CurCnt = msgPacket:GetInt()
	self.mFuckInfo.game1TotalCnt = msgPacket:GetInt()

	self.mFuckInfo.game2CurCnt = msgPacket:GetInt()
	self.mFuckInfo.game2TotalCnt = msgPacket:GetInt()

	self.mFuckInfo.game3CurCnt = msgPacket:GetInt()
	self.mFuckInfo.game3TotalCnt = msgPacket:GetInt()

	-- 显示小游戏次数
	self.mRootWidget:getChildByName("Button_Event_1"):getChildByName("Label_Num"):setString(self.mFuckInfo.game1CurCnt.."/"..self.mFuckInfo.game1TotalCnt)

	self.mRootWidget:getChildByName("Button_Event_2"):getChildByName("Label_Num"):setString(self.mFuckInfo.game2CurCnt.."/"..self.mFuckInfo.game2TotalCnt)

	self.mRootWidget:getChildByName("Button_Event_3"):getChildByName("Label_Num"):setString(self.mFuckInfo.game3CurCnt.."/"..self.mFuckInfo.game3TotalCnt)
end

-- 同步约会信息
function FuckWindow:onFuckInfoChanged(msgPacket)
	self.mFuckInfo.mLeftGiftCount = msgPacket:GetInt()
	self.mFuckInfo.mTotalGiftCount = msgPacket:GetInt()
	self.mFuckInfo.level = msgPacket:GetInt() 	-- 玩家好感度等级
	local preFuckInfoExp = self.mFuckInfo.exp
	self.mFuckInfo.exp = msgPacket:GetInt() 	-- 玩家好感度经验值
	self.mFuckInfo.maxExp = msgPacket:GetInt() 	-- 玩家好感度最大经验值 

	-- 全局
	self:showFuckInfoFromServer()

	local heroId = msgPacket:GetInt()
	for i = 1, #self.mFuckInfo.heroList do
		if heroId == self.mFuckInfo.heroList[i].heroId then
			local oldLevel =  msgPacket:GetInt()
			self.mFuckInfo.heroList[i].fuckLevel = msgPacket:GetInt()	-- 约会等级(新)

			if self.mFuckInfo.heroList[i].fuckLevel > oldLevel then
				self.mFuckInfo.heroList[i].rewardCount = msgPacket:GetUShort() -- 奖励数量
				self.mFuckInfo.heroList[i].rewardList = {}
				for m = 1, self.mFuckInfo.heroList[i].rewardCount do
					self.mFuckInfo.heroList[i].rewardList[m] = {}
					self.mFuckInfo.heroList[i].rewardList[m].itemType = msgPacket:GetInt()
					self.mFuckInfo.heroList[i].rewardList[m].itemId = msgPacket:GetInt()
					self.mFuckInfo.heroList[i].rewardList[m].itemCount = msgPacket:GetInt()
				end
			end

			-- 显示奖励
			self:showReward()

			self.mFuckInfo.heroList[i].fuckExp = msgPacket:GetInt() 	-- 约会经验值
			self.mFuckInfo.heroList[i].fuckMaxExp = msgPacket:GetInt() 	-- 约会最大经验值

			-- 刷新界面
			if self.mCurHeroId == heroId then
				local parentNode = self.mRootWidget:getChildByName("Panel_Bottom"):getChildByName("Panel_Inner_HeroInfo")
				-- 等级
				parentNode:getChildByName("Label_HeroFriendLevel_Stroke"):setString(tostring(self.mFuckInfo.heroList[i].fuckLevel))
				-- 进度
				parentNode:getChildByName("ProgressBar_HeroFriendShip"):setPercent(self.mFuckInfo.heroList[i].fuckExp*100/self.mFuckInfo.heroList[i].fuckMaxExp)
				-- doError("1111")
				-- print("约会同步数据英雄id:", heroId, "级别:", self.mFuckInfo.heroList[i].fuckLevel, "百分比:", self.mFuckInfo.heroList[i].fuckExp*100/self.mFuckInfo.heroList[i].fuckMaxExp)
				-- doError("2222")
			end
			
			-- 刷新界面
			for j = 1, #self.mHeroWidgetList do
				if heroId == self.mHeroWidgetList[j]:getTag() then
					local lv = self.mFuckInfo.heroList[i].fuckLevel
					-- 等级
					self.mHeroWidgetList[j]:getChildByName("Label_Level"):setString(lv)
					-- 进度
					self.mHeroWidgetList[j]:getChildByName("ProgressBar_Level"):setPercent(self.mFuckInfo.heroList[i].fuckExp*100/self.mFuckInfo.heroList[i].fuckMaxExp)
					-- doError("3333")
					-- print("约会同步数据英雄id:", heroId, "级别:", self.mFuckInfo.heroList[i].fuckLevel, "百分比:", self.mFuckInfo.heroList[i].fuckExp*100/self.mFuckInfo.heroList[i].fuckMaxExp)
					-- doError("4444")
				end
			end

		end
	end

	local isChange  = msgPacket:GetInt()
	
	if 0 == isChange then -- 有变化
		self.mFuckInfo.heroCount = msgPacket:GetInt()
		self.mFuckInfo.heroList = {}

		for i = 1, self.mFuckInfo.heroCount do
			self.mFuckInfo.heroList[i] = {}
			self.mFuckInfo.heroList[i].heroId = msgPacket:GetInt() -- 英雄id

			self.mFuckInfo.heroList[i].gameState = {}
			local gameCnt = msgPacket:GetInt()
			for j = 1, gameCnt do
				self.mFuckInfo.heroList[i].gameState[j] = msgPacket:GetInt()
			end

			self.mFuckInfo.heroList[i].fuckLevel = msgPacket:GetInt() -- 约会等级
			self.mFuckInfo.heroList[i].fuckExp = msgPacket:GetInt() -- 约会经验值
			self.mFuckInfo.heroList[i].fuckMaxExp = msgPacket:GetInt() -- 约会最大经验值
			self.mFuckInfo.heroList[i].rewardCount = msgPacket:GetUShort() -- 奖励数量
			self.mFuckInfo.heroList[i].rewardList = {}
			for j = 1, self.mFuckInfo.heroList[i].rewardCount do
				self.mFuckInfo.heroList[i].rewardList[j] = {}
				self.mFuckInfo.heroList[i].rewardList[j].itemType = msgPacket:GetInt()
				self.mFuckInfo.heroList[i].rewardList[j].itemId = msgPacket:GetInt()
				self.mFuckInfo.heroList[i].rewardList[j].itemCount = msgPacket:GetInt()
			end
		end
		-- 显示英雄
		self:initHeroList(self.mCurClickedSchoolWidget:getTag())
	end

	self.mFuckInfo.bubleCount = msgPacket:GetInt() -- 泡泡数量
	self.mFuckInfo.bubleList = {}
	for i = 1, self.mFuckInfo.bubleCount do
		self.mFuckInfo.bubleList[i] = {}
		self.mFuckInfo.bubleList[i].heroId = msgPacket:GetInt() -- 泡泡的英雄ID
		self.mFuckInfo.bubleList[i].moodIndex = 1
	end

	-- 显示泡泡
	self:showHeroTalkBuble()
end

-- 显示对话泡泡
function FuckWindow:showHeroTalkBuble()

	local randomPosTbl = 
	{
		-- 一个点
		{
			cc.p(313,143),
		},
		-- 两个点
		{
			cc.p(125,245),
			cc.p(313,143),
		},
		-- 三个点
		{
			cc.p(125,245),
			cc.p(313,143),
			cc.p(9,90),
		},
		-- 四个点
		{
			cc.p(125,245),
			cc.p(313,143),
			cc.p(9,90),
			cc.p(60,11),
		},
		-- 五个点
		{
			cc.p(125,245),
			cc.p(313,143),
			cc.p(9,90),
			cc.p(60,11),
			cc.p(323,290),
		},
		-- 六个点
		{
			cc.p(125,245),
			cc.p(313,143),
			cc.p(9,90),
			cc.p(60,11),
			cc.p(323,290),
			cc.p(53,168),
		},
		-- 七个点
		{
			cc.p(125,245),
			cc.p(313,143),
			cc.p(9,90),
			cc.p(60,11),
			cc.p(323,290),
			cc.p(53,168),
			cc.p(9,303),
		},
		-- 八个点
		{
			cc.p(125,245),
			cc.p(313,143),
			cc.p(9,90),
			cc.p(60,11),
			cc.p(323,290),
			cc.p(53,168),
			cc.p(9,303),
			cc.p(301,21),
		},
	}

	self.mRootWidget:getChildByName("Panel_HelloEventArea"):removeAllChildren()

	for i = 1, #self.mFuckInfo.bubleList do
		-- 创建泡泡控件
		local bubleWidget = self:createBubleWidget(self.mFuckInfo.bubleList[i].heroId)
		-- 添加
		self.mRootWidget:getChildByName("Panel_HelloEventArea"):addChild(bubleWidget)
		-- 位置
		bubleWidget:setPosition(randomPosTbl[self.mFuckInfo.bubleCount][i])
		bubleWidget:setLocalZOrder(770 - randomPosTbl[self.mFuckInfo.bubleCount][i].y)

		bubleWidget:setScale(0)
		local act0 = cc.DelayTime:create(0.3*i)
	--	local act1 = cc.EaseElasticOut:create( cc.EaseOut:create(cc.ScaleTo:create(0.5, 1), 3))
		local act1 = cc.EaseOut:create(cc.Sequence:create(cc.ScaleTo:create(0.2, 1.15), cc.ScaleTo:create(0.05, 1.0)), 3)
		bubleWidget:runAction(cc.Sequence:create(act0, act1))

	end

end

-- 创建对话泡泡
function FuckWindow:createBubleWidget(heroId)
	local widget = GUIWidgetPool:createWidget("NewDate_Hello_Cell")
	local heroData = DB_DateHero.getDataById(heroId)
	local heroBaseData = DB_HeroConfig.getDataById(heroId)

	-- 英雄姓名
	local nameId = heroBaseData.Name
	local textName = getDictionaryText(nameId)
	widget:getChildByName("Label_HeroName"):setString(textName)

	-- 泡泡英雄发言
	local function gerHeroMoodIndex()
		for i = 1, #self.mFuckInfo.bubleList do
			if heroId == self.mFuckInfo.bubleList[i].heroId then
				return self.mFuckInfo.bubleList[i].moodIndex
			end
		end
	end
	local textId = heroData["ChatBubble_HeroSpeak_"..gerHeroMoodIndex()]
	local textShow = getDictionaryText(textId)
	widget:getChildByName("Label_HeroWords"):setString(textShow)

	-- 英雄头像
	local imgId = heroBaseData.IconID
	local imgName = DB_ResourceList.getDataById(imgId).Res_path1
	widget:getChildByName("Image_HeroIcon"):loadTexture(imgName,1)

	widget:getChildByName("Button_Bg"):setTag(heroId)

	registerWidgetReleaseUpEvent(widget:getChildByName("Button_Bg"), handler(self, self.showBubleWindow))

	return widget
end

-- 选择答案
function FuckWindow:sendAnswer(widget)
	
	-- 回答回包
	local function onSendAnswer(msgPacket)
		local ret = msgPacket:GetChar()
		local success = msgPacket:GetChar()

		local quesData = DB_DateHero.getDataById(self.mAskHeroId)
		local retTextId = nil

		if 0 == ret then -- 正确
			retTextId = quesData.Chat_Hero2_Right
		else -- 失败
			retTextId = quesData.Chat_Hero2_wrong
		end

		local retText = getDictionaryText(retTextId)
		self.mRootWidget:getChildByName("Panel_PlayerAnswer"):setVisible(false)
		self.mRootWidget:getChildByName("Panel_Bottom"):getChildByName("Panel_Hello"):getChildByName("Label_HeroWords"):setString(retText)

		GUISystem:hideLoading()

		-- for i = 1, #self.mFuckInfo.bubleList do 
		-- 	if self.mAskHeroId == self.mFuckInfo.bubleList[i].heroId then
		-- 		table.remove(self.mFuckInfo.bubleList, i)
		-- 	end
		-- end

		-- 允许退出
		self.mRootWidget:getChildByName("Panel_Hello"):setTouchEnabled(true)

		-- 显示泡泡
		self:showHeroTalkBuble()

		-- 显示特效
		self.mNoticeAnimNode:setVisible(true)
	end

	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_SEND_FUCK_ANSWER_, onSendAnswer)

	local packet = NetSystem.mNetManager:GetSPacket()
	packet:SetType(PacketTyper._PTYPE_CS_SEND_FUCK_ANSWER_)
	packet:PushInt(self.mAskHeroId)
	-- 泡泡英雄发言
	local function gerHeroMoodIndex()
		for i = 1, #self.mFuckInfo.bubleList do
			if self.mAskHeroId == self.mFuckInfo.bubleList[i].heroId then
				return self.mFuckInfo.bubleList[i].moodIndex
			end
		end
	end
	packet:PushInt(gerHeroMoodIndex())
	packet:PushInt(widget:getTag())
	packet:Send()
	GUISystem:showLoading()
end

-- 显示泡泡窗口
function FuckWindow:showBubleWindow(widget)

	self.mAskHeroId = widget:getTag()

	-- 请求进入泡泡窗口响应
	local function onRequestEnterBubleWindow(msgPacket)
		-- 显示问题		
		local function showQuestion()
			-- 获取问题ID
		--	self.mQuestionId = msgPacket:GetInt()

			local quesData = DB_DateHero.getDataById(self.mAskHeroId)
		--	local quesTextId = quesData["Chat_Hero1_"..tostring(self.mQuestionId)]
			local quesTextId = quesData.Chat_Hero
			local quesText = getDictionaryText(quesTextId)
			self.mRootWidget:getChildByName("Panel_Bottom"):getChildByName("Panel_Hello"):getChildByName("Label_HeroWords"):setString(quesText)
		end
		showQuestion()

		-- 显示答案
		local function showAnswer()
			local quesData = DB_DateHero.getDataById(self.mAskHeroId)
			for i = 1, 3 do
				local answerTextId = quesData["Chat_Player_"..tostring(i)]
				local answerText = getDictionaryText(answerTextId)
				self.mRootWidget:getChildByName("Button_Answer_"..tostring(i)):getChildByName("Label_Answer"):setString(answerText)
			end
		end
		showAnswer()

		-- 关闭主界面
		self:hideMainWindow()
		-- 显示英雄窗口
		self:showHeroWindow()
		-- 显示泡泡
		self.mRootWidget:getChildByName("Panel_Present"):setVisible(false)
		self.mRootWidget:getChildByName("Panel_Event"):setVisible(false)
		self.mRootWidget:getChildByName("Panel_Hello"):setVisible(true)
		self.mHeroWindow:getChildByName("Panel_NextLevelRewards"):setVisible(false)

		-- 重置回退按钮
		local function xxx()
			-- 隐藏答案控件
			self.mHeroWindow:getChildByName("Panel_PlayerAnswer"):setVisible(false)

			self.mHeroWindow:getChildByName("Panel_NextLevelRewards"):setVisible(false)
			-- 显示主界面
			self:showMainWindow()
			-- 关闭英雄窗口
			self:closeHeroWindow()
			-- 重置回退按钮
			self:resetExitBtnCallFunc(handler(self, self.closeWindow))
		end
		self:resetExitBtnCallFunc(xxx)

		-- 隐藏答案控件
		self.mHeroWindow:getChildByName("Panel_PlayerAnswer"):setVisible(false)
		local function flyInAnswer(widget)
			self.mHeroWindow:getChildByName("Panel_PlayerAnswer"):setVisible(true)
			local actWidget = self.mHeroWindow:getChildByName("Panel_PlayerAnswer")

			local function actEnd()
				self.mRootWidget:getChildByName("Panel_Hello"):setTouchEnabled(false)
				-- 隐藏特效
				self.mNoticeAnimNode:setVisible(false)
			end

			for i = 1, 3 do
				local answerWidget = actWidget:getChildByName("Button_Answer_"..tostring(i))
				local curPos = cc.p(answerWidget:getPosition())
				answerWidget:setPosition(cc.p(curPos.x + 500, curPos.y))
				local act0 = cc.DelayTime:create(i*0.1)
				local act1 = cc.MoveTo:create(moveTime, curPos)
				local act2 = cc.CallFunc:create(actEnd)
				if i ~= 3 then
					answerWidget:runAction(cc.Sequence:create(act0, act1))
				else
					answerWidget:runAction(cc.Sequence:create(act0, act1, act2))
				end
			end
			-- 重置回退按钮
			registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Panel_Hello"), xxx)
			self.mRootWidget:getChildByName("Panel_Hello"):setTouchEnabled(false)
		end
		registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Panel_Hello"), flyInAnswer)

		if self.mCurHeroAnim then
			-- self.mCurHeroAnim:removeFromParent(true)
			SpineDataCacheManager:collectFightSpineByAtlas(self.mCurHeroAnim)
			self.mCurHeroAnim = nil
		end
	--	self.mCurHeroAnim = FightSystem.mRoleManager:CreateSpine(widget:getTag())
	--	self.mRootWidget:getChildByName("Panel_HeroSpine"):addChild(self.mCurHeroAnim)
	--	self.mCurHeroAnim:setAnimation(0, "stand", true)

		self.mCurHeroAnim = SpineDataCacheManager:getSimpleSpineByHeroID(widget:getTag(), self.mRootWidget:getChildByName("Panel_HeroSpine"))
		self.mCurHeroAnim:setAnimation(0, "stand", true)
		self.mCurHeroAnim:setScale(1.8)

		-- 名字
		local heroData = DB_HeroConfig.getDataById(widget:getTag())
		local heroNameId = heroData.Name
		local heroName   = getDictionaryText(heroNameId)
		self.mRootWidget:getChildByName("Panel_Bottom"):getChildByName("Panel_Inner_HeroInfo"):getChildByName("Label_HeroName"):setString(heroName)

		-- 基本信息
		for i = 1, #self.mFuckInfo.heroList do
			if widget:getTag() == self.mFuckInfo.heroList[i].heroId then
				local parentNode = self.mRootWidget:getChildByName("Panel_Bottom"):getChildByName("Panel_Inner_HeroInfo")
				-- 等级
				parentNode:getChildByName("Label_HeroFriendLevel_Stroke"):setString(self.mFuckInfo.heroList[i].fuckLevel)
				-- 进度
				parentNode:getChildByName("ProgressBar_HeroFriendShip"):setPercent(self.mFuckInfo.heroList[i].fuckExp*100/self.mFuckInfo.heroList[i].fuckMaxExp)
			end
		end

		-- 界面特效
		local function doAnimation()
			-- 左面进
			local curPos = cc.p(self.mCurHeroAnim:getPosition())
			self.mCurHeroAnim:setPositionX(-150)
			local act0 = cc.EaseOut:create(cc.MoveTo:create(moveTime, curPos), 2.5)
			self.mCurHeroAnim:runAction(act0)

			-- 下面进
			local widget = self.mRootWidget:getChildByName("Panel_Bottom")
			curPos = cc.p(widget:getPosition())
			widget:setPositionY(curPos.y - 100)
			act0 = cc.EaseOut:create(cc.MoveTo:create(moveTime, curPos), 2.5)
			widget:runAction(act0)
		end
		doAnimation()

		GUISystem:hideLoading()

		self.mRootWidget:getChildByName("Panel_Hello"):setTouchEnabled(true)

		-- 显示
		self.mNoticeAnimNode:setVisible(true)
		self.mNoticeAnimNode:play("cg_arrow_next", true)
	end

	onRequestEnterBubleWindow()

--	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_REQUEST_FUCK_ASK_, onRequestEnterBubleWindow)

	-- 请求进入泡泡窗口
	local function requestEnterBubleWindow()
		local packet = NetSystem.mNetManager:GetSPacket()
    	packet:SetType(PacketTyper._PTYPE_CS_REQUEST_FUCK_ASK_)
    	packet:PushInt(widget:getTag())
    	packet:Send()
    	GUISystem:showLoading()
    	self.mAskHeroId = widget:getTag()
	end
--	requestEnterBubleWindow()
--	GUISystem:showLoading()
end

-- 创建英雄头像
function FuckWindow:createHeroItem(objId,favorLv,favorExp,favorMaxExp)
	local widget    = GUIWidgetPool:createWidget("NewDateHero")

	-- 名字
	local heroData = DB_HeroConfig.getDataById(objId)

	local heroNameId = heroData.Name
	local heroName   = getDictionaryText(heroNameId)
	widget:getChildByName("Label_HeroName"):setString(heroName)

	-- 头像
	local iconWidget = createHeroIcon(objId, 0, 0, nil, nil)
	iconWidget:getChildByName("Image_Quality"):setVisible(true)
	iconWidget:getChildByName("Image_Quality"):loadTexture("icon_hero_quality0.png", 1)

	widget:getChildByName("Panel_HeroPic"):addChild(iconWidget)

	-- 等级
	widget:getChildByName("Label_Level"):setString(tostring(favorLv))
	LabelManager:outline(widget:getChildByName("Label_Level"), G_COLOR_C4B.BLACK)

	-- 进度
	widget:getChildByName("ProgressBar_Level"):setPercent(favorExp / favorMaxExp * 100 )

	-- tag
	widget:setTag(objId)
	
	return widget
end

function FuckWindow:closeWindow()
	GUISystem:playSound("homeBtnSound")
	-- local function callFun()
		PKHelper:ShowPKInvite()
		EventSystem:PushEvent(Event.GUISYSTEM_HIDE_FUCKWINDOW)
	-- 	showLoadingWindow("HomeWindow")
	-- end
	-- FightSystem:sendChangeCity(false,callFun)
end

function FuckWindow:InitLayout()
	self.mRootWidget = GUIWidgetPool:createWidget("NewDate")
	self.mRootNode:addChild(self.mRootWidget)

	PKHelper:HidePKInvite()

	self.mTopRoleInfoPanel = TopRoleInfoPanel:new()
	local topInfoPanel = self.mTopRoleInfoPanel:init(self.mRootNode,ROLE_TITLE_TYPE.TITLE_DATE,handler(self, self.closeWindow))
	self.mTopRoleInfoPanel.mTopWidget:getChildByName("Panel_BtnList"):setVisible(false)

	-- 适配
	local function doAdapter()
		-- Panel_HeroList 靠屏幕最左边
		self.mRootWidget:getChildByName("Panel_HeroList"):setPositionX(getGoldFightPosition_LD().x)

		-- Panel_SchoolPages
		self.mRootWidget:getChildByName("Panel_SchoolPages"):setPositionY(getGoldFightPosition_LD().y)

		self.mRootWidget:getChildByName("Panel_SchoolPages"):setPositionX(getGoldFightPosition_RD().x - self.mRootWidget:getChildByName("Panel_SchoolPages"):getContentSize().width)

		-- Panel_Bottom 靠屏幕下底边
		self.mRootWidget:getChildByName("Panel_Bottom"):setPositionY(getGoldFightPosition_LD().y)

		-- Panel_Hero
	--	self.mRootWidget:getChildByName("Panel_Hero"):setPositionY(getGoldFightPosition_LD().y + self.mRootWidget:getChildByName("Panel_Hero"):getContentSize().height)

		self.mRootWidget:getChildByName("Panel_Hero"):setPositionX(getGoldFightPosition_LD().x)

		-- Panel_Halo
	--	self.mRootWidget:getChildByName("Panel_Halo"):setPositionY(getGoldFightPosition_LD().y + self.mRootWidget:getChildByName("Panel_Halo"):getContentSize().height)

--		self.mRootWidget:getChildByName("Panel_Halo"):setPositionX(getGoldFightPosition_LD().x)

		-- Panel_HeroInfo
		self.mRootWidget:getChildByName("Panel_HeroInfo"):setPositionY(getGoldFightPosition_LD().y)

		-- Button_MyLevel 与屏幕右边保持距离50，高度不变
		self.mRootWidget:getChildByName("Image_MyLevel"):setPositionX(getGoldFightPosition_RD().x - 50)

		-- Button_MyLevel 与屏幕右边保持距离50，高度不变
		self.mRootWidget:getChildByName("Image_MyLevel"):setPositionX(getGoldFightPosition_RD().x - 50)

		local function onMyLevelBtnClicked(widget, eventType)
			if eventType == ccui.TouchEventType.began then
		    	widget:setScale(0.9)
		    elseif eventType == ccui.TouchEventType.ended then
		        widget:setScale(1)
		    elseif eventType == ccui.TouchEventType.moved then
		        widget:setScale(0.9)
		    elseif eventType == ccui.TouchEventType.canceled then
		        widget:setScale(1)
		    end
		end
		self.mRootWidget:getChildByName("Image_MyLevel"):addTouchEventListener(onMyLevelBtnClicked)
		-- Button_AllHero 与屏幕右边保持距离50，高度不变
--		self.mRootWidget:getChildByName("Button_AllHero"):setPositionX(getGoldFightPosition_RD().x - 50)

		-- Panel_Present 贴右屏幕
		self.mRootWidget:getChildByName("Panel_Present"):setPositionX(getGoldFightPosition_RD().x - self.mRootWidget:getChildByName("Panel_Present"):getContentSize().width)

		-- Panel_Present 贴下屏幕
		self.mRootWidget:getChildByName("Panel_Present"):setPositionY(getGoldFightPosition_RD().y)

		-- Panel_Hello 贴右屏幕
		self.mRootWidget:getChildByName("Panel_Hello"):setPositionX(getGoldFightPosition_RD().x - self.mRootWidget:getChildByName("Panel_Hello"):getContentSize().width)

		-- Panel_Event 贴右屏幕
		self.mRootWidget:getChildByName("Panel_Event"):setPositionX(getGoldFightPosition_RD().x - self.mRootWidget:getChildByName("Panel_Event"):getContentSize().width)

		-- Panel_Event 贴下屏幕
		self.mRootWidget:getChildByName("Panel_Event"):setPositionY(getGoldFightPosition_RD().y)

		-- Panel_Btn_AllHero靠右边缘
--		self.mRootWidget:getChildByName("Panel_Btn_AllHero"):setPositionX(getGoldFightPosition_RD().x - self.mRootWidget:getChildByName("Panel_Btn_AllHero"):getContentSize().width)

		-- Panel_Btn_MyLevel靠右边缘
		self.mRootWidget:getChildByName("Panel_Btn_MyLevel"):setPositionX(getGoldFightPosition_RD().x - self.mRootWidget:getChildByName("Panel_Btn_MyLevel"):getContentSize().width)

		-- Panel_Btn_MyLevel靠上边缘
		self.mRootWidget:getChildByName("Panel_Btn_MyLevel"):setPositionY(getGoldFightPosition_RU().y - self.mRootWidget:getChildByName("Panel_Btn_MyLevel"):getContentSize().height)

		-- Panel_Btn_AllHero靠下边缘
--		self.mRootWidget:getChildByName("Panel_Btn_AllHero"):setPositionY(getGoldFightPosition_RD().y + self.mRootWidget:getChildByName("Panel_OperationArea"):getContentSize().height)

		-- Panel_Inner_HeroInfo靠左边
		self.mRootWidget:getChildByName("Panel_Inner_HeroInfo"):setPositionX(getGoldFightPosition_LD().x)

		-- Panel_NextLevelRewards靠右边
		self.mRootWidget:getChildByName("Panel_NextLevelRewards"):setPositionX(getGoldFightPosition_RD().x - self.mRootWidget:getChildByName("Panel_NextLevelRewards"):getContentSize().width)

		-- Panel_Inner_Present靠右边
		self.mRootWidget:getChildByName("Panel_Inner_Present"):setPositionX(getGoldFightPosition_RD().x - self.mRootWidget:getChildByName("Panel_Inner_Present"):getContentSize().width)

		local function doAnimation()
			-- Panel_HeroList动画
			local actWidget = self.mRootWidget:getChildByName("Panel_HeroList")
			local curPos = cc.p(actWidget:getPosition())
			actWidget:setPositionX(curPos.x - 150)
			local act0 = cc.EaseOut:create(cc.MoveTo:create(moveTime, curPos), 2.5)
			actWidget:runAction(act0)

			-- Panel_Btn_MyLevel动画
			actWidget = self.mRootWidget:getChildByName("Panel_Btn_MyLevel")
			curPos = cc.p(actWidget:getPosition())
			actWidget:setPositionX(curPos.x + 150)
			local act0 = cc.EaseOut:create(cc.MoveTo:create(moveTime, curPos), 2.5)
			actWidget:runAction(act0)

			-- Panel_SchoolPages动画
		--	actWidget = self.mRootWidget:getChildByName("Panel_SchoolPages")
		--	curPos = cc.p(actWidget:getPosition())
		--	actWidget:setPositionX(curPos.x + 150)
		--	local act0 = cc.EaseOut:create(cc.MoveTo:create(moveTime, curPos), 2.5)
		--	actWidget:runAction(act0)
		end
		doAnimation()

	end
	doAdapter()

	-- 显示主界面
	self:showMainWindow()

	-- 关闭英雄界面
	self.mRootWidget:getChildByName("Panel_Hero"):setVisible(false)

	-- for i = 1, 3 do
	-- 	local widget = self.mRootWidget:getChildByName("Panel_Touch_Shool_"..tostring(i))
	-- 	widget:setTag(i)
	-- 	registerWidgetReleaseUpEvent(widget, handler(self, self.onSchoolSelected))
	-- end

	local function setBtnFunc()
		local btnWidget = nil
		-- 全部
		
		btnWidget = self.mRootWidget:getChildByName("Image_All")
		btnWidget:setTag(0)
		registerWidgetReleaseUpEvent(btnWidget, handler(self, self.onSchoolSelected))

		btnWidget = self.mRootWidget:getChildByName("Image_LingLan")
		btnWidget:setTag(1)
		registerWidgetReleaseUpEvent(btnWidget, handler(self, self.onSchoolSelected))

		btnWidget = self.mRootWidget:getChildByName("Image_ReXue")
		btnWidget:setTag(2)
		registerWidgetReleaseUpEvent(btnWidget, handler(self, self.onSchoolSelected))

		btnWidget = self.mRootWidget:getChildByName("Image_FengXian")
		btnWidget:setTag(3)
		registerWidgetReleaseUpEvent(btnWidget, handler(self, self.onSchoolSelected))

		for i = 1, 3 do
			btnWidget = self.mRootWidget:getChildByName("Button_Answer_"..tostring(i))
			btnWidget:setTag(i)
			registerWidgetReleaseUpEvent(btnWidget, handler(self, self.sendAnswer))
		end
	end
	setBtnFunc()

	self.mHeroWindow = self.mRootWidget:getChildByName("Panel_Hero")

	-- 初始化英雄列表
--	self:initHeroList()

	-- 送礼
	local function giftBtnFunc()
		self:flyMenu("right", handler(self, self.showGiftWindow))
	end
	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_Present"), giftBtnFunc)

	-- 打招呼
--	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_Hello"), handler(self, self.showHelloWindow))

	-- 小游戏
--	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_Event"), handler(self, self.showGameWindow))

	-- 小游戏按钮
	for i = 1, 3 do
		local btn = self.mRootWidget:getChildByName("Button_Event_"..tostring(i))
		btn:setTag(i)
	--	btn:setTouchEnabled(true)
		registerWidgetReleaseUpEvent(btn, handler(self, self.onGameBtnClicked))
	end

end

-- 小游戏
function FuckWindow:onGameBtnClicked(widget)
	local gameType = widget:getTag()

	if 1 == gameType then
		if self.mFuckInfo.game1CurCnt <= 0 then
			MessageBox:showMessageBox1("次数已经为0~")
			return
		end
	elseif 2 == gameType then
		if self.mFuckInfo.game2CurCnt <= 0 then
			MessageBox:showMessageBox1("次数已经为0~")
			return
		end
	elseif 3 == gameType then
		if self.mFuckInfo.game3CurCnt <= 0 then
			MessageBox:showMessageBox1("次数已经为0~")
			return
		end
	end


	for i = 1, #self.mFuckInfo.heroList do
		if self.mCurHeroId == self.mFuckInfo.heroList[i].heroId then
			if 2 == self.mFuckInfo.heroList[i].gameState[gameType] then
				MessageBox:showMessageBox1("该英雄已经无法再玩这个小游戏~")
				return
			end
		end
	end

	if 1 == gameType then 			-- 2048
		Event.GUISYSTEM_SHOW_GAME2048WINDOW.mData = self.mCurHeroId
		EventSystem:PushEvent(Event.GUISYSTEM_SHOW_GAME2048WINDOW)
	elseif 2 == gameType then 		-- 猜人
		Event.GUISYSTEM_SHOW_HEROGUESSWINDOW.mData = self.mCurHeroId
		EventSystem:PushEvent(Event.GUISYSTEM_SHOW_HEROGUESSWINDOW)
	elseif 3 == gameType then 		-- 扑克
		Event.GUISYSTEM_SHOW_POKERWINDOW.mData = self.mCurHeroId
		EventSystem:PushEvent(Event.GUISYSTEM_SHOW_POKERWINDOW)
	end
end

-- 初始化英雄列表
function FuckWindow:initHeroList(schoolType)
	local listViewWidget = self.mRootWidget:getChildByName("Panel_Main"):getChildByName("ListView_HeroList")
	-- 设置竖向滑动
	listViewWidget:setDirection(ccui.ScrollViewDir.vertical)
	listViewWidget:removeAllChildren()

	self.mHeroWidgetList = {}

	for i = 1, self.mFuckInfo.heroCount do
		local heroData = DB_HeroConfig.getDataById(self.mFuckInfo.heroList[i].heroId)
		if 0 == schoolType then 
			self.mHeroWidgetList[i] = self:createHeroItem(self.mFuckInfo.heroList[i].heroId, self.mFuckInfo.heroList[i].fuckLevel
				, self.mFuckInfo.heroList[i].fuckExp, self.mFuckInfo.heroList[i].fuckMaxExp)
			-- 响应点击
			registerWidgetReleaseUpEvent(self.mHeroWidgetList[i], handler(self, self.onHeroWidgetClicked))
	 		listViewWidget:pushBackCustomItem(self.mHeroWidgetList[i])
		elseif schoolType == heroData.HeroGroup then
			self.mHeroWidgetList[i] = self:createHeroItem(self.mFuckInfo.heroList[i].heroId, self.mFuckInfo.heroList[i].fuckLevel
				, self.mFuckInfo.heroList[i].fuckExp, self.mFuckInfo.heroList[i].fuckMaxExp)
			-- 响应点击
			registerWidgetReleaseUpEvent(self.mHeroWidgetList[i], handler(self, self.onHeroWidgetClicked))
	 		listViewWidget:pushBackCustomItem(self.mHeroWidgetList[i])
		end
	end
end

-- 刷新物品
function FuckWindow:onItemInfoChanged()
	if 0 ~= #self.mGiftWidgetList then
		for i = 1, 10 do
			local giftData = DB_DateGift.getDataById(i)
			local itemId = giftData.Event_Gift_ItemID

			-- 剩余
			local leftCnt = globaldata:getItemOwnCount(itemId)
			self.mGiftWidgetList[i]:getChildByName("Label_Num"):setString("剩余"..tostring(leftCnt).."件")
			if leftCnt > 0 then
				self.mGiftWidgetList[i]:getChildByName("Panel_Give"):setVisible(true)
				self.mGiftWidgetList[i]:getChildByName("Panel_Buy"):setVisible(false)
			else
				self.mGiftWidgetList[i]:getChildByName("Panel_Give"):setVisible(false)
				self.mGiftWidgetList[i]:getChildByName("Panel_Buy"):setVisible(true)
			end
		end
	end
end

-- 送礼
function FuckWindow:showGiftWindow(widget)
	self.mHeroWindow:getChildByName("Panel_Event"):setVisible(false)

	self.mHeroWindow:getChildByName("Panel_Inner_Present"):setVisible(true)

	local giftWindow = self.mHeroWindow:getChildByName("Panel_Present")
	giftWindow:setVisible(true)

	local curPos = cc.p(giftWindow:getPosition())
	giftWindow:setPositionX(curPos.x + moveDis)

	local function onActEnd()
		GUISystem:enableUserInput()
	end

	local act0 = cc.EaseOut:create(cc.MoveTo:create(moveTime, curPos), 2.5)
	local act1 = cc.CallFunc:create(onActEnd)
	giftWindow:runAction(cc.Sequence:create(act0, act1))
	GUISystem:disableUserInput()

	self.mHeroWindow:getChildByName("Panel_Bottom"):getChildByName("Panel_NextLevelRewards"):setVisible(false)

	local function xxx()
		-- 界面飞出,按钮飞进
		local function onActEnd()
			self.mHeroWindow:getChildByName("Panel_NextLevelRewards"):setVisible(true)
			self.mHeroWindow:getChildByName("Panel_Inner_Present"):setVisible(false)
			self.mHeroWindow:getChildByName("Panel_Present"):setVisible(false)
			self.mHeroWindow:getChildByName("Panel_Present"):setPositionX(curPos.x)
			GUISystem:enableUserInput()
			self.mHeroWindow:getChildByName("Panel_Event"):setVisible(true)
			self:flyMenu("left")
		end
		local act0 = cc.EaseIn:create(cc.MoveTo:create(moveTime, cc.p(curPos.x + moveDis, curPos.y)), 2.5)
		local act1 = cc.CallFunc:create(onActEnd)
		giftWindow:runAction(cc.Sequence:create(act0, act1))
		GUISystem:disableUserInput()

		

		local function yyy()
			-- 显示主界面
			self:showMainWindow()
			-- 关闭英雄窗口
			self:closeHeroWindow()
			-- 重置回退按钮
			self:resetExitBtnCallFunc(handler(self, self.closeWindow))
		end
		self:resetExitBtnCallFunc(yyy)
	end
	self:resetExitBtnCallFunc(xxx)

	if 0 == #self.mGiftWidgetList then
		-- 创建礼物
		local listViewWidget = giftWindow:getChildByName("ListView_GiftList")
		listViewWidget:setDirection(ccui.ScrollViewDir.vertical)
		listViewWidget:removeAllChildren()
		for i = 1, 10 do
			self.mGiftWidgetList[i] = GUIWidgetPool:createWidget("NewDate_Gift")
			listViewWidget:pushBackCustomItem(self.mGiftWidgetList[i])

			local giftData = DB_DateGift.getDataById(i)
			local itemId = giftData.Event_Gift_ItemID

			-- 名称
			local itemData = DB_ItemConfig.getDataById(itemId)
			local itemNameId = itemData.Name
			self.mGiftWidgetList[i]:getChildByName("Label_Name"):setString(getDictionaryText(itemNameId))

			-- 剩余
			local leftCnt = globaldata:getItemOwnCount(itemId)
			self.mGiftWidgetList[i]:getChildByName("Label_Num"):setString("剩余"..tostring(leftCnt).."件")
			if leftCnt > 0 then
				self.mGiftWidgetList[i]:getChildByName("Panel_Give"):setVisible(true)
				self.mGiftWidgetList[i]:getChildByName("Panel_Buy"):setVisible(false)
			else
				self.mGiftWidgetList[i]:getChildByName("Panel_Give"):setVisible(false)
				self.mGiftWidgetList[i]:getChildByName("Panel_Buy"):setVisible(true)
			end

			-- 购买价格
			local price = giftData.Event_Gift_BuyPrice
			self.mGiftWidgetList[i]:getChildByName("Label_Price"):setString(tostring(price))

			-- 好感度
			local value = giftData["Event_Gift_Hero"..tostring(self.mCurHeroId)]
			self.mGiftWidgetList[i]:getChildByName("Label_FriendAdvance"):setString("好感度 +"..tostring(value))

			-- 图标
			local iconWidget = createItemWidget(itemId, 0)
			iconWidget:getChildByName("Label_Count_Stroke"):setVisible(false)
			self.mGiftWidgetList[i]:getChildByName("Panel_Item"):addChild(iconWidget)

			-- 响应
			local btn = self.mGiftWidgetList[i]:getChildByName("Button_Buy")
			btn:setTag(i)
			registerWidgetReleaseUpEvent(btn , handler(self , self.onGiftWidgetClicked))
		end
	end

	-- 送礼对话
	local heroId = self.mCurHeroId
	local heroData = DB_DateHero.getDataById(heroId)
	local giftTextId = heroData.Gift_text
	self.mRootWidget:getChildByName("Panel_Inner_Present"):getChildByName("Label_PresentWords"):setString(getDictionaryText(giftTextId))
end

-- 点击礼物
function FuckWindow:onGiftWidgetClicked(btn)
	local giftId = btn:getTag()

	local giftData = DB_DateGift.getDataById(giftId)
	local itemId = giftData.Event_Gift_ItemID

	-- 剩余
	local leftCnt = globaldata:getItemOwnCount(itemId)

	-- 购买价格
	local price = giftData.Event_Gift_BuyPrice

	-- 名称
	local itemData = DB_ItemConfig.getDataById(itemId)
	local itemNameId = itemData.Name
	local itemName = getDictionaryText(itemNameId)

	if leftCnt > 0 then -- 赠送

		for i = 1, #self.mFuckInfo.heroList do
			if self.mCurHeroId == self.mFuckInfo.heroList[i].heroId then
				if 20 == self.mFuckInfo.heroList[i].fuckLevel then
					MessageBox:showMessageBox1("当前英雄好感度等级已满~")
					return
				end
			end
		end


		local packet = NetSystem.mNetManager:GetSPacket()
		packet:SetType(PacketTyper._PTYPE_CS_USE_GIFT)
		packet:PushInt(self.mCurHeroId)
		packet:PushInt(itemId)
		packet:PushInt(1)
		packet:Send()
		GUISystem:showLoading()
	else -- 购买
		Event.GUISYSTEM_SHOW_PURCHASEWINDOW.mData = 
		{
		0, 			-- 商品类型
		0, 			-- 货架ID
		itemId,     -- 商品ID
		1,          -- 货币类型
		price,      -- 价格
		itemName,   -- 名称
		9,          -- 商店ID
		100         -- 最大购买数量
		}
		EventSystem:PushEvent(Event.GUISYSTEM_SHOW_PURCHASEWINDOW)
	end
end

-- 打招呼
function FuckWindow:showHelloWindow(widget)
	self.mRootWidget:getChildByName("Panel_Hello"):setVisible(true)

	self:resetExitBtnCallFunc(handler(self, self.showMenu))
end

-- 小游戏
function FuckWindow:showGameWindow(widget)
	self.mRootWidget:getChildByName("Panel_Event"):setVisible(true)

	self:resetExitBtnCallFunc(handler(self, self.showMenu))
end

-- 重新设置返回函数
function FuckWindow:resetExitBtnCallFunc(func)
	self.mTopRoleInfoPanel:resetExitBtnCallFunc(func)
end

-- 显示菜单
function FuckWindow:showMenu()
	-- 关闭三个界面
	self.mRootWidget:getChildByName("Panel_Event"):setVisible(false)

	self.mRootWidget:getChildByName("Panel_Hello"):setVisible(false)

	local function xxx()
		-- 显示主界面
		self:showMainWindow()
		-- 关闭英雄窗口
		self:closeHeroWindow()
		-- 重置回退按钮
		self:resetExitBtnCallFunc(handler(self, self.closeWindow))
	end
	self:resetExitBtnCallFunc(xxx)
end

-- 点击英雄
function FuckWindow:onHeroWidgetClicked(widget)
	self.mRootWidget:getChildByName("Panel_Hero"):getChildByName("Panel_Event"):setVisible(true)
	-- 替换Spine
	local heroId = widget:getTag()
	self.mCurHeroId = heroId
	if self.mCurHeroAnim then
		-- self.mCurHeroAnim:removeFromParent(true)
		SpineDataCacheManager:collectFightSpineByAtlas(self.mCurHeroAnim)
		self.mCurHeroAnim = nil
	end
--	self.mCurHeroAnim = FightSystem.mRoleManager:CreateSpine(heroId)
--	self.mRootWidget:getChildByName("Panel_HeroSpine"):addChild(self.mCurHeroAnim)

	self.mCurHeroAnim = SpineDataCacheManager:getSimpleSpineByHeroID(heroId, self.mRootWidget:getChildByName("Panel_HeroSpine"))
	self.mCurHeroAnim:setAnimation(0, "stand", true)
	self.mCurHeroAnim:setScale(1.8)

	-- 显示姓名
	local heroData  = DB_HeroConfig.getDataById(heroId)
	
	local heroNameId = heroData.Name
	local heroName   = getDictionaryText(heroNameId)
	self.mHeroWindow:getChildByName("Label_HeroName"):setString(heroName)

	-- 基本信息
	for i = 1, #self.mFuckInfo.heroList do
		if widget:getTag() == self.mFuckInfo.heroList[i].heroId then
			local parentNode = self.mRootWidget:getChildByName("Panel_Bottom"):getChildByName("Panel_Inner_HeroInfo")
			-- 等级
			parentNode:getChildByName("Label_HeroFriendLevel_Stroke"):setString(self.mFuckInfo.heroList[i].fuckLevel)
			-- 进度
			parentNode:getChildByName("ProgressBar_HeroFriendShip"):setPercent(self.mFuckInfo.heroList[i].fuckExp*100/self.mFuckInfo.heroList[i].fuckMaxExp)
		end
	end

	-- 显示小游戏次数
	self.mRootWidget:getChildByName("Button_Event_1"):getChildByName("Label_Num"):setString(self.mFuckInfo.game1CurCnt.."/"..self.mFuckInfo.game1TotalCnt)

	self.mRootWidget:getChildByName("Button_Event_2"):getChildByName("Label_Num"):setString(self.mFuckInfo.game2CurCnt.."/"..self.mFuckInfo.game2TotalCnt)

	self.mRootWidget:getChildByName("Button_Event_3"):getChildByName("Label_Num"):setString(self.mFuckInfo.game3CurCnt.."/"..self.mFuckInfo.game3TotalCnt)


	-- 界面特效
	local function doAnimation()
		-- 左面进
		local curPos = cc.p(self.mCurHeroAnim:getPosition())
		self.mCurHeroAnim:setPositionX(-150)
		local act0 = cc.EaseOut:create(cc.MoveTo:create(moveTime, curPos), 2.5)
		self.mCurHeroAnim:runAction(act0)

		-- 下面进
		local widget = self.mRootWidget:getChildByName("Panel_Bottom")
		curPos = cc.p(widget:getPosition())
		widget:setPositionY(curPos.y - 100)
		act0 = cc.EaseOut:create(cc.MoveTo:create(moveTime, curPos), 2.5)
		widget:runAction(act0)

		-- 按钮飞入
		self:flyMenu("left")

	end
	doAnimation()

	-- 关闭主界面
	self:hideMainWindow()
	-- 显示英雄窗口
	self:showHeroWindow()
	-- 重置回退按钮
	local function xxx()
		-- 关闭英雄窗口
		self:closeHeroWindow()
	end
	self:resetExitBtnCallFunc(xxx)
end

-- 点击学校
function FuckWindow:onSchoolSelected(widget)
	if widget == self.mCurClickedSchoolWidget then
		return
	end
	local actTime = 0.5

	if self.mCurClickedSchoolWidget and 0 ~= self.mCurClickedSchoolWidget:getTag() then
		-- 前一次的淡出
		if self.mCurClickedSchoolWidget then
			local act0 = cc.FadeOut:create(actTime)
			self.mRootWidget:getChildByName("Panel_Area_"..tostring(self.mCurClickedSchoolWidget:getTag())):runAction(act0)
		end
	end

	-- 停止旋转
	if self.mCurClickedSchoolWidget then
		self.mCurClickedSchoolWidget:getChildByName("Image_Halo"):stopAllActions()
	end

	-- 记住当前的
	self.mCurClickedSchoolWidget = widget
	local function onActEnd()
		GUISystem:enableUserInput()
	end
	if 0 ~= widget:getTag() then
		-- 当前的淡入
		local act0 = cc.FadeIn:create(actTime)
		local act1 = cc.CallFunc:create(onActEnd)
		local actWidget = self.mRootWidget:getChildByName("Panel_Area_"..tostring(widget:getTag()))
		actWidget:setVisible(true)
		actWidget:setOpacity(0)
		actWidget:runAction(cc.Sequence:create(act0, act1))
		GUISystem:disableUserInput()
	end

	-- 开始旋转
	local function doRotate()
		local act0 = cc.RotateBy:create(5, 360)
		self.mCurClickedSchoolWidget:getChildByName("Image_Halo"):runAction(cc.RepeatForever:create(act0))
	end
	doRotate()

	-- 显示英雄
	self:initHeroList(widget:getTag())
end

-- 显示主界面
function FuckWindow:showMainWindow()
	self.mRootWidget:getChildByName("Panel_Main"):setVisible(true)
end

-- 关闭主界面
function FuckWindow:hideMainWindow()
	self.mRootWidget:getChildByName("Panel_Main"):setVisible(false)
end

-- 显示英雄窗口
function FuckWindow:showHeroWindow()
	self.mRootWidget:getChildByName("Panel_Hero"):setVisible(true)

	self.mHeroWindow:getChildByName("Panel_PlayerAnswer"):setVisible(false)
	self.mHeroWindow:getChildByName("Panel_Present"):setVisible(false)
	self.mHeroWindow:getChildByName("Panel_HeroInfo"):setVisible(true)
	self.mHeroWindow:getChildByName("Panel_Bottom"):setVisible(true)
	self.mRootWidget:getChildByName("Panel_Bottom"):getChildByName("Panel_Hello"):setVisible(false)
	self.mRootWidget:getChildByName("Panel_Bottom"):getChildByName("Panel_Inner_Present"):setVisible(false)

	self.mRootWidget:getChildByName("Panel_NextLevelRewards"):setVisible(true)

	-- 显示奖励
	self:showReward()
end

-- 显示奖励
function FuckWindow:showReward()
	-- 显示奖励
	for i = 1, 4 do
		self.mRootWidget:getChildByName("Panel_NextLevelRewards"):getChildByName("Panel_Reward_"..tostring(i)):removeAllChildren()
	end

	for i = 1, #self.mFuckInfo.heroList do
		if self.mCurHeroId == self.mFuckInfo.heroList[i].heroId then
			for j = 1, #self.mFuckInfo.heroList[i].rewardList do
				local itemWidget = createCommonWidget(self.mFuckInfo.heroList[i].rewardList[j].itemType, self.mFuckInfo.heroList[i].rewardList[j].itemId, self.mFuckInfo.heroList[i].rewardList[j].itemCount)
				self.mRootWidget:getChildByName("Panel_NextLevelRewards"):getChildByName("Panel_Reward_"..tostring(j)):addChild(itemWidget)
			end
		end
	end
end

-- 关闭英雄窗口
function FuckWindow:closeHeroWindow()

	-- 界面特效
	local function doAnimation()
		-- 左面出
		local curPos0 = cc.p(self.mCurHeroAnim:getPosition())
	--	self.mCurHeroAnim:setPositionX(-150)
		local tarPos = cc.p(curPos0.x - 300, curPos0.y)
		local act0 = cc.EaseOut:create(cc.MoveTo:create(moveTime, tarPos), 2.5)
		self.mCurHeroAnim:runAction(act0)

		-- 下面出
		local widget = self.mRootWidget:getChildByName("Panel_Bottom")
		local curPos1 = cc.p(widget:getPosition())
	--	widget:setPositionY(curPos.y - 100)
		tarPos = cc.p(curPos1.x, curPos1.y - 300)
		act0 = cc.EaseOut:create(cc.MoveTo:create(moveTime, tarPos), 2.5)
		widget:runAction(act0)


		local function xxx()
			-- 显示主界面
			self:showMainWindow()
			-- 重置回退按钮
			self:resetExitBtnCallFunc(handler(self, self.closeWindow))
			self.mCurHeroAnim:setPosition(curPos0)
			widget:setPosition(curPos1)
			self.mRootWidget:getChildByName("Panel_Hero"):setVisible(false)
		end

		-- 按钮飞入
		self:flyMenu("right", xxx)

	end
	doAnimation()
end

function FuckWindow:Destroy()

	GUIEventManager:unregister("itemInfoChanged", self.onItemInfoChanged)

	self.mTopRoleInfoPanel:destroy()
	self.mTopRoleInfoPanel = nil
	---
	if self.mCurHeroAnim then
		SpineDataCacheManager:collectFightSpineByAtlas(self.mCurHeroAnim)
		self.mCurHeroAnim 	=	nil
	end
	---
	self.mRootNode:removeFromParent(true)
	self.mRootNode 		= 	nil
	self.mRootWidget 	= 	nil
	self.mCurHeroId = nil

	self.mGiftWidgetList = {}

	self.mHeroWidgetList = {}

	self.mCurClickedSchoolWidget = nil
	----
	CommonAnimation.clearAllTextures()
	cclog("=====ShopWindow:Destroy=====")
end

function FuckWindow:onEventHandler(event)
	if event.mAction == Event.WINDOW_SHOW then
		GUIWidgetPool:preLoadWidget("NewDate_Hello_Cell", true)
		GUIWidgetPool:preLoadWidget("NewDateHero", true)
		GUIWidgetPool:preLoadWidget("NewDate_Gift", true)
		self:Load(event)
		---------停止画主城镇界面
		EventSystem:PushEvent(Event.GUISYSTEM_DISABLEDRAW_HOMEWINDOW)
		---------
	elseif event.mAction == Event.WINDOW_HIDE then
		GUIWidgetPool:preLoadWidget("NewDate_Hello_Cell", false)
		GUIWidgetPool:preLoadWidget("NewDateHero", false)
		GUIWidgetPool:preLoadWidget("NewDate_Gift", false)
		self:Destroy()
		---------开启画主城镇界面
		EventSystem:PushEvent(Event.GUISYSTEM_EABLEDRAW_HOMEWINDOW)
		---------
	end
end

return FuckWindow
