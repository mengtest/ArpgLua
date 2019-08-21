-- Name: 	CardGameWindow
-- Func：	卡牌
-- Author:	WangShengdong
-- Data:	15-9-9

-- 随机数种子
math.randomseed(os.time())

-- 运动时间
local moveTime = 0.5

local rotateVal = -30

-- 进入无敌状态需要的怒气值
local wudiStateValue = 15

-- 卡牌高度
local cardHeight = 181

-- 卡牌旋转角度
local preRotateVal = nil

-- 卡牌层级
local cardZOrderTbl = {1, 2, 3 ,4 ,5}

-- 根据概率随机
local function randomNumByWeight(weightTbl)
	
	local totalWeight = 0 -- 总权值
	for i = 1, #weightTbl do
		totalWeight = totalWeight + weightTbl[i]
	end
	local result = math.random(1, totalWeight)
	local newWeightVal = 0
	for i = 1, #weightTbl do
		newWeightVal = newWeightVal + weightTbl[i]
		if result <= newWeightVal then
			return i
		end
	end
end

-- 随机一张英雄的牌
local function randomOneCardByHeroId(heroId)
	-- local heroData = DB_DateHero.getDataById(heroId)
	-- local weightTbl = {}
	-- -- 第一张
	-- weightTbl[1] = heroData.Card_kill_Probability

	-- -- 第二张
	-- weightTbl[2] = heroData.Card_Ignore_Probability

	-- -- 第三张
	-- weightTbl[3] = heroData.Card_Angry_Probability

	-- -- 第四张
	-- weightTbl[4] = heroData.Card_Appease_Probability

	-- -- 剩余24张英雄
	-- for i = 1, 24 do
	-- 	weightTbl[4 + i] = heroData["Card_Hero"..tostring(i).."_Probability"]
	-- end
	-- return randomNumByWeight(weightTbl)
	local weightTbl = {}
	for i = 1, 76 do
		local heroData = DB_DateCard.getDataById(i)
		if heroData then
			weightTbl[i] = heroData.Weight
		end
	end

	local ret = randomNumByWeight(weightTbl)
	return ret
end

local CardGameWindow = 
{
	mName				=	"CardGameWindow",
	mRootNode			=	nil,
	mRootWidget			=	nil,

	----------------------------------------
	mSelfHeroId 		=	nil,
	mEnemyHeroId 		=	nil,
	----------------------------------------
	mSelfHeroAnim		=	nil,
	mEnemyHeroAnim 		=	nil,
	----------------------------------------
	mSelfCardTeam				=	{0, 0, 0, 0, 0},	-- 己方阵容
	mSelfCardWidgetList			=	{}, 				-- 己方卡片数组
	mSelfCurBattleCardIndex		=	nil,				-- 己方当前战斗成员
	mSelfCurScaledCardIndex		=	nil,				-- 己方当前放大的成员
	mSelfHpValue 				=	0, 					-- 己方血量
	mSelfMpValue				=	0,  				-- 己方怒气
	mEnemyCardTeam 				=	{0, 0, 0, 0, 0},    -- 敌方阵容
	mEnemyCardWidgetList		=	{},	 				-- 敌方卡片数组		
	mEnemyCurBattleCardIndex	=	nil,				-- 敌方当前战斗成员
	mEnemyHpValue				=	0,					-- 敌方血量
	mEnemyMpValue				=	0,					-- 敌方怒气	
	----------------------------------------
	mSelfWudiState 				=	false, 				-- 己方无敌状态
	mSelfWudiCount				=	0,
	mEnemyWudiState 			=	false, 				-- 敌方无敌状态
	mEnemyWudiCount				=	0,
	----------------------------------------
	mCurRoundIndex		=	0,				-- 当前回合数
	----------------------------------------
	mGameState 			=	"needSendCard",			-- 当前游戏阶段
	mCurRoundTitle		=	nil,					-- 当前回合主题 1:音乐 2:美术 3:体育
	----------------------------------------
	mRealScaledCardWidget	=	nil,				-- 临时的放大后的卡牌
}

local titleTbl = {"音乐", "美术", "体育"}

-- 状态
local stateTbl = {
					"needSendCard", -- 等待己方送牌状态
					"movingCard",	-- 拖动卡牌阶段
					"fighting", 	-- 战斗阶段
					"checkingCard",	-- 查看牌阶段
					
				 }

function CardGameWindow:Release()

end

function CardGameWindow:setGameState(stateVal)
	self.mGameState = stateVal
end

function CardGameWindow:getGameState()
	return self.mGameState
end

function CardGameWindow:onTouchScreen(widget, eventType)
	if eventType == ccui.TouchEventType.began then
		-- 判断是否到送牌阶段
		if "needSendCard" ~= self:getGameState() then
			return
		end
		local touchPos = widget:getTouchBeganPosition()
        self:checkCardClicked(touchPos)
    elseif eventType == ccui.TouchEventType.ended then
    		-- 判断是否到拖动卡片阶段
		if "checkingCard" ~= self:getGameState() then
			return
		end
		local touchPos = widget:getTouchEndPosition()
		self:placeBattleCard(touchPos)
    elseif eventType == ccui.TouchEventType.moved then
       	-- 判断是否在检查卡牌阶段
		if "checkingCard" ~= self:getGameState() then
			return
		end
		local touchPos = widget:getTouchMovePosition()
		self:checkCardMoved(touchPos)
    elseif eventType == ccui.TouchEventType.canceled then
        
    end
end



-- 放置卡片
function CardGameWindow:placeBattleCard(checkPos)
	for i = 1, 5 do
		local checkWidget = self.mRootWidget:getChildByName("Panel_Bottom"):getChildByName("Panel_Cardpool_1"):getChildByName("Panel_Card_"..tostring(i))
		local worldPos = checkWidget:getWorldPosition()
		local rect = checkWidget:getBoundingBox()
		rect.x = worldPos.x
		rect.y = worldPos.y + cardHeight -- 修正矩形位置
		rect.height = rect.height - cardHeight -- 修正矩形高度
		if cc.rectContainsPoint(rect, checkPos) then
			local cardWidget = self.mSelfCardWidgetList[self.mSelfCurBattleCardIndex]

			local function actEnd0()
				-- 落地
				self:resetSelfCardPos()
			end

			local function actEnd1()
			 	-- 敌方出牌
			 	self:sendOneCardToBattle()
			-- 	GUISystem:enableUserInput()
			end
			local act0 = cc.Sequence:create(cc.ScaleTo:create(moveTime/2, 1.3), cc.ScaleTo:create(moveTime/2, 1))                              
			local act1 = cc.MoveTo:create(moveTime, cc.p(self.mRootWidget:getChildByName("Panel_Card_Self"):getWorldPosition()))
			local act2 = cc.CallFunc:create(actEnd0)
			local act3 = cc.DelayTime:create(1)
			local act4 = cc.CallFunc:create(actEnd1)
			local act5 = cc.EaseInOut:create(cc.Spawn:create(act0, act1), 1.35) 
			cardWidget:runAction(cc.Sequence:create(act5, act2, act3, act4))
			GUISystem:disableUserInput()


			local function rotateAction()
				local act0 = cc.RotateTo:create(moveTime, 0)
				cardWidget:getChildByName("Panel_Middle"):runAction(act0)
			end
			rotateAction()

			local function smallAction() -- 本次放大
				local actWidget = cardWidget:getChildByName("Panel_Middle")
				actWidget:setScale(1.0)
				actWidget:setPositionY(0)
				cardWidget:setLocalZOrder(1990)
			end
			smallAction()

			-- 清除
			self:cleanScaledCardWidget()
			return
		end
	end
	
	local function smallAction()
		for i = 1, 5 do
			-- 置回原大小
			local cardWidget = self.mSelfCardWidgetList[i]
			local actWidget = cardWidget:getChildByName("Panel_Middle")
			actWidget:setScale(1.0)
			actWidget:setPositionY(0)
			actWidget:setRotation(preRotateVal)
			cardWidget:setLocalZOrder(cardZOrderTbl[i])
		end
		self.mSelfCurBattleCardIndex = nil
		self.mSelfCurScaledCardIndex = nil
		self:setGameState("needSendCard")
	end
	smallAction()

	-- 清除
	self:cleanScaledCardWidget()
end

-- 重置其他卡牌位置(敌军)
function CardGameWindow:resetEnemyCardPos()
	-- 调换 self.mEnemyCardTeam
	local newEnemyCardTeam = {0, 0, 0, 0, 0}

	print("原来的CardTeam:")
	for i = 1, 5 do
		print(i, self.mEnemyCardTeam[i])
	end

	local cnt = 0 
	for i = 1, 5 do
		if i ~= self.mEnemyCurBattleCardIndex then
			cnt = cnt + 1
			newEnemyCardTeam[cnt] = self.mEnemyCardTeam[i]
		end
	end
	-- 选中的挪到最后
	newEnemyCardTeam[5] = self.mEnemyCardTeam[self.mEnemyCurBattleCardIndex]
	self.mEnemyCardTeam = newEnemyCardTeam

	print("挪动后的CardTeam:")
	for i = 1, 5 do
		print(i, self.mEnemyCardTeam[i])
	end

	-- 调换 self.mEnemyCardWidgetList
	local newEnemyCardWidgetList = {}
	cnt = 0
	for i = 1, 5 do
		if i ~= self.mEnemyCurBattleCardIndex then
			cnt = cnt + 1
			newEnemyCardWidgetList[cnt] = self.mEnemyCardWidgetList[i]
		end
	end
	-- 选中的挪到最后
	newEnemyCardWidgetList[5] = self.mEnemyCardWidgetList[self.mEnemyCurBattleCardIndex]
	self.mEnemyCardWidgetList = newEnemyCardWidgetList

	-- 调换 self.mEnemyCurBattleCardIndex
	self.mEnemyCurBattleCardIndex = 5

	local moveTime = 0.5
	-- 重新设置位置
	for i = 1, 4 do
		local tarPos = self.mRootWidget:getChildByName("Panel_Top"):getChildByName("Panel_Cardpool_2"):getChildByName("Panel_Card_"..tostring(i)):getWorldPosition()
		local act0 = cc.MoveTo:create(moveTime, tarPos)
		self.mEnemyCardWidgetList[i]:runAction(act0)
	end
end

-- 重置其他卡牌位置(友军)
function CardGameWindow:resetSelfCardPos()
	-- 调换 self.mSelfCardTeam
	local newSelfCardTeam = {0, 0, 0, 0, 0}

	local cnt = 0 
	for i = 1, 5 do
		if i ~= self.mSelfCurBattleCardIndex then
			cnt = cnt + 1
			newSelfCardTeam[cnt] = self.mSelfCardTeam[i]
		end
	end
	-- 选中的挪到最后
	newSelfCardTeam[5] = self.mSelfCardTeam[self.mSelfCurBattleCardIndex]
	self.mSelfCardTeam = newSelfCardTeam

	-- 调换 self.mSelfCardWidgetList
	local newSelfCardWidgetList = {}
	cnt = 0
	for i = 1, 5 do
		if i ~= self.mSelfCurBattleCardIndex then
			cnt = cnt + 1
			newSelfCardWidgetList[cnt] = self.mSelfCardWidgetList[i]
		end
	end
	-- 选中的挪到最后
	newSelfCardWidgetList[5] = self.mSelfCardWidgetList[self.mSelfCurBattleCardIndex]
	self.mSelfCardWidgetList = newSelfCardWidgetList

	-- 调换 self.mSelfCurBattleCardIndex
	self.mSelfCurBattleCardIndex = 5

	local moveTime = 0.5
	-- 重新设置位置
	for i = 1, 4 do
		local tarPos = self.mRootWidget:getChildByName("Panel_Bottom"):getChildByName("Panel_Cardpool_2"):getChildByName("Panel_Card_"..tostring(i)):getWorldPosition()
		local act0 = cc.MoveTo:create(moveTime, tarPos)
		self.mSelfCardWidgetList[i]:runAction(act0)
	end
end

-- 检测卡牌被点击
function CardGameWindow:checkCardClicked(checkPos)
	for i = 1, 5 do
		local checkWidget = self.mRootWidget:getChildByName("Panel_Bottom"):getChildByName("Panel_Cardpool_1"):getChildByName("Panel_Card_"..tostring(i))
		local worldPos = checkWidget:getWorldPosition()
		local rect = checkWidget:getBoundingBox()
		rect.x = worldPos.x
		rect.y = worldPos.y
		rect.height = cardHeight -- 修正矩形高度
		if cc.rectContainsPoint(rect, checkPos) then
			self.mSelfCurBattleCardIndex = i
			self:setGameState("checkingCard")
			-- 选中卡牌放大
			self:showCardDetail()
			return
		end
	end
	self.mSelfCurBattleCardIndex = nil
	-- 前一次的缩小
	self:showCardDetail()
end

-- 检测卡牌滑动
function CardGameWindow:checkCardMoved(checkPos)
	for i = 1, 5 do
		local checkWidget = self.mRootWidget:getChildByName("Panel_Bottom"):getChildByName("Panel_Cardpool_1"):getChildByName("Panel_Card_"..tostring(i))
		local worldPos = checkWidget:getWorldPosition()
		local rect = checkWidget:getBoundingBox()
		rect.x = worldPos.x
		rect.y = worldPos.y
		if cc.rectContainsPoint(rect, checkPos) then
			self.mSelfCurBattleCardIndex = i
			self:setGameState("checkingCard")
			-- 选中卡牌放大
			self:showCardDetail()
			return
		end
	end
	self.mSelfCurBattleCardIndex = nil
	-- 前一次的缩小
	self:showCardDetail()
end

-- 清除放大卡牌
function CardGameWindow:cleanScaledCardWidget()
	if self.mRealScaledCardWidget then
		self.mRealScaledCardWidget:removeFromParent(true)
		self.mRealScaledCardWidget = nil
	end
end

-- 卡牌放大
function CardGameWindow:showCardDetail()
	if self.mSelfCurScaledCardIndex == self.mSelfCurBattleCardIndex then -- 相同返回
		return 
	end
	if self.mSelfCurScaledCardIndex then -- 前一次的缩小
		local cardWidget = self.mSelfCardWidgetList[self.mSelfCurScaledCardIndex]
		local actWidget = cardWidget:getChildByName("Panel_Middle")
	--	actWidget:setScale(1.0)
		actWidget:setPositionY(0)
		cardWidget:setLocalZOrder(cardZOrderTbl[self.mSelfCurScaledCardIndex])
		actWidget:getChildByName("Panel_Middle"):setRotation(preRotateVal)
		-- 清除
		self:cleanScaledCardWidget()
	end
	self.mSelfCurScaledCardIndex = self.mSelfCurBattleCardIndex -- 记录当前的
	if self.mSelfCurBattleCardIndex then
		local function bigAction() -- 本次放大
			local cardWidget = self.mSelfCardWidgetList[self.mSelfCurScaledCardIndex]
			local actWidget = cardWidget:getChildByName("Panel_Middle")
		--	actWidget:setScale(1.2)
			actWidget:setPositionY(40)
			cardWidget:setLocalZOrder(1990)
			if not preRotateVal then
				preRotateVal = actWidget:getChildByName("Panel_Middle"):getRotation()
			end
			actWidget:getChildByName("Panel_Middle"):setRotation(0)
			local parentSize = cardWidget:getContentSize()
			-- 创建放大后的卡牌
			self.mRealScaledCardWidget = cardWidget:clone()
			self.mRealScaledCardWidget:setScale(2)
			cardWidget:addChild(self.mRealScaledCardWidget, 1990)
			self.mRealScaledCardWidget:setPosition(cc.p(-parentSize.width/2, -20))
		end
		bigAction()
	end
end

-- 移动卡片
function CardGameWindow:moveSelectedCard(movingPos)
	local cardWidget = self.mSelfCardWidgetList[self.mSelfCurBattleCardIndex]
	cardWidget:setLocalZOrder(2000)
	local contentSize = cardWidget:getContentSize()
	local tarPos = cc.p(movingPos.x - contentSize.width/2, movingPos.y - contentSize.height/2)
	cardWidget:setPosition(tarPos)
end

-- 判断结果
function CardGameWindow:doCompute()
	-- 敌方
	local enemyCardIndex = self.mEnemyCardTeam[self.mEnemyCurBattleCardIndex]
	print("敌方Card Index:", enemyCardIndex)
	-- 己方
	local selfCardIndex = self.mSelfCardTeam[self.mSelfCurBattleCardIndex]
	print("己方Card Index:", selfCardIndex)

	print("当前回合主题:", titleTbl[self.mCurRoundTitle])

	if enemyCardIndex > 4 and selfCardIndex > 4 then -- 如果是两张英雄牌
		print("双方均是属性牌")
		-- 己方
		local selfPropVal = nil
		local selfCardData = DB_DateCard.getDataById(selfCardIndex)
		-- if 1 == self.mCurRoundTitle then
		-- 	selfPropVal = selfCardData.Music
		-- elseif 2 == self.mCurRoundTitle then
		-- 	selfPropVal = selfCardData.Paint
		-- elseif 3 == self.mCurRoundTitle then
		-- 	selfPropVal = selfCardData.Sport
		-- end
		selfPropVal = selfCardData.Weight
		-- 敌方
		local enemyPropVal = nil
		local enemyCardData = DB_DateCard.getDataById(enemyCardIndex)
		-- if 1 == self.mCurRoundTitle then
		-- 	enemyPropVal = enemyCardData.Music
		-- elseif 2 == self.mCurRoundTitle then
		-- 	enemyPropVal = enemyCardData.Paint
		-- elseif 3 == self.mCurRoundTitle then
		-- 	enemyPropVal = enemyCardData.Sport
		-- end
		enemyPropVal = enemyCardData.Weight

		-- 检测无敌状态
		if self.mSelfWudiState then
			selfPropVal = 100
			print("己方进入无敌状态")
		end

		-- 检测无敌状态
		if self.mEnemyWudiState then
			enemyPropVal = 100
			print("敌方进入无敌状态")
		end

		print("己方对应属性值:", selfPropVal)
		print("对方对应属性值:", enemyPropVal)

		-- 结果
		if (enemyCardIndex == self.mCurRoundTitle and selfCardIndex == self.mCurRoundTitle) or (enemyCardIndex ~= self.mCurRoundTitle and selfCardIndex ~= self.mCurRoundTitle) then
			local resultData = DB_DateCardPK.getDataById(5)
			if selfPropVal > enemyPropVal then -- 对方属性小
				print("己方血量:", resultData.Smaller_SelfBlood)
				self.mSelfHpValue = self.mSelfHpValue + tonumber(resultData.Smaller_SelfBlood)

				print("己方怒气:", resultData.Smaller_SelfAnger)
				self.mSelfMpValue = self.mSelfMpValue + tonumber(resultData.Smaller_SelfAnger)

				print("对方血量:", resultData.Smaller_EnemyBlood)
				self.mEnemyHpValue = self.mEnemyHpValue + tonumber(resultData.Smaller_EnemyBlood)

				print("对方怒气:", resultData.Smaller_EnemyAnger)
				self.mEnemyMpValue = self.mEnemyMpValue + tonumber(resultData.Smaller_EnemyAnger)
			elseif selfPropVal == enemyPropVal then -- 双方属性相等
				print("己方血量:", resultData.Equal_SelfBlood)
				self.mSelfHpValue = self.mSelfHpValue + tonumber(resultData.Equal_SelfBlood)

				print("己方怒气:", resultData.Equal_SelfAnger)
				self.mSelfMpValue = self.mSelfMpValue + tonumber(resultData.Equal_SelfAnger)

				print("对方血量:", resultData.Equal_EnemyBlood)
				self.mEnemyHpValue = self.mEnemyHpValue + tonumber(resultData.Equal_EnemyBlood)

				print("对方怒气:", resultData.Equal_EnemyAnger)
				self.mEnemyMpValue = self.mEnemyMpValue + tonumber(resultData.Equal_EnemyAnger)
			else -- 对方属性大
				print("己方血量:", resultData.Bigger_SelfBlood)
				self.mSelfHpValue = self.mSelfHpValue + tonumber(resultData.Bigger_SelfBlood)

				print("己方怒气:", resultData.Bigger_SelfAnger)
				self.mSelfMpValue = self.mSelfMpValue + tonumber(resultData.Bigger_SelfAnger)

				print("对方血量:", resultData.Bigger_EnemyBlood)
				self.mEnemyHpValue = self.mEnemyHpValue + tonumber(resultData.Bigger_EnemyBlood)

				print("对方怒气:", resultData.Bigger_EnemyAnger)
				self.mEnemyMpValue = self.mEnemyMpValue + tonumber(resultData.Bigger_EnemyAnger)
			end
		else
			if selfCardIndex == self.mCurRoundTitle then -- 自己大
				print("己方血量:", resultData.Smaller_SelfBlood)
				self.mSelfHpValue = self.mSelfHpValue + tonumber(resultData.Smaller_SelfBlood)

				print("己方怒气:", resultData.Smaller_SelfAnger)
				self.mSelfMpValue = self.mSelfMpValue + tonumber(resultData.Smaller_SelfAnger)

				print("对方血量:", resultData.Smaller_EnemyBlood)
				self.mEnemyHpValue = self.mEnemyHpValue + tonumber(resultData.Smaller_EnemyBlood)

				print("对方怒气:", resultData.Smaller_EnemyAnger)
				self.mEnemyMpValue = self.mEnemyMpValue + tonumber(resultData.Smaller_EnemyAnger)
			else -- 对面大
				print("己方血量:", resultData.Bigger_SelfBlood)
				self.mSelfHpValue = self.mSelfHpValue + tonumber(resultData.Bigger_SelfBlood)

				print("己方怒气:", resultData.Bigger_SelfAnger)
				self.mSelfMpValue = self.mSelfMpValue + tonumber(resultData.Bigger_SelfAnger)

				print("对方血量:", resultData.Bigger_EnemyBlood)
				self.mEnemyHpValue = self.mEnemyHpValue + tonumber(resultData.Bigger_EnemyBlood)

				print("对方怒气:", resultData.Bigger_EnemyAnger)
				self.mEnemyMpValue = self.mEnemyMpValue + tonumber(resultData.Bigger_EnemyAnger)
			end
		end
	elseif enemyCardIndex > 4 and selfCardIndex <=4 then -- 己方技能牌,敌方属性牌
		print("己方技能牌,敌方属性牌")
		-- 结果
		local resultData = DB_DateCardPK.getDataById(selfCardIndex)
		print("己方血量:", resultData.Bigger_SelfBlood)
		self.mSelfHpValue = self.mSelfHpValue + tonumber(resultData.Bigger_SelfBlood)

		print("己方怒气:", resultData.Bigger_SelfAnger)
		self.mSelfMpValue = self.mSelfMpValue + tonumber(resultData.Bigger_SelfAnger)

		print("对方血量:", resultData.Bigger_EnemyBlood)
		self.mEnemyHpValue = self.mEnemyHpValue + tonumber(resultData.Bigger_EnemyBlood)

		print("对方怒气:", resultData.Bigger_EnemyAnger)
		self.mEnemyMpValue = self.mEnemyMpValue + tonumber(resultData.Bigger_EnemyAnger)
	elseif enemyCardIndex <= 4 and selfCardIndex > 4 then -- 己方属性牌,敌方技能牌
		print("己方属性牌,敌方技能牌")
		-- 结果
		local resultData = DB_DateCardPK.getDataById(5)
		if 1 == enemyCardIndex then -- 对方必杀
			print("己方血量:", resultData.Kill_SelfBlood)
			self.mSelfHpValue = self.mSelfHpValue + tonumber(resultData.Kill_SelfBlood)

			print("己方怒气:", resultData.Kill_SelfAnger)
			self.mSelfMpValue = self.mSelfMpValue + tonumber(resultData.Kill_SelfAnger)

			print("对方血量:", resultData.Kill_EnemyBlood)
			self.mEnemyHpValue = self.mEnemyHpValue + tonumber(resultData.Kill_EnemyBlood)

			print("对方怒气:", resultData.Kill_EnemyAnger)
			self.mEnemyMpValue = self.mEnemyMpValue + tonumber(resultData.Kill_EnemyAnger)
		elseif 2 == enemyCardIndex then -- 对方无视
			print("己方血量:", resultData.Ignore_SelfBlood)
			self.mSelfHpValue = self.mSelfHpValue + tonumber(resultData.Ignore_SelfBlood)

			print("己方怒气:", resultData.Ignore_SelfAnger)
			self.mSelfMpValue = self.mSelfMpValue + tonumber(resultData.Ignore_SelfAnger)

			print("对方血量:", resultData.Ignore_EnemyBlood)
			self.mEnemyHpValue = self.mEnemyHpValue + tonumber(resultData.Ignore_EnemyBlood)

			print("对方怒气:", resultData.Ignore_EnemyAnger)
			self.mEnemyMpValue = self.mEnemyMpValue + tonumber(resultData.Ignore_EnemyAnger)
		elseif 3 == enemyCardIndex then -- 对方暴怒
			print("己方血量:", resultData.Angry_SelfBlood)
			self.mSelfHpValue = self.mSelfHpValue + tonumber(resultData.Angry_SelfBlood)

			print("己方怒气:", resultData.Angry_SelfAnger)
			self.mSelfMpValue = self.mSelfMpValue + tonumber(resultData.Angry_SelfBlood)

			print("对方血量:", resultData.Angry_EnemyBlood)
			self.mEnemyHpValue = self.mEnemyHpValue + tonumber(resultData.Angry_EnemyBlood)

			print("对方怒气:", resultData.Angry_EnemyAnger)
			self.mEnemyMpValue = self.mEnemyMpValue + tonumber(resultData.Angry_EnemyAnger)

		elseif 4 == enemyCardIndex then -- 对方安抚
			print("己方血量:", resultData.Appease_SelfBlood)
			self.mSelfHpValue = self.mSelfHpValue + tonumber(resultData.Appease_SelfBlood)

			print("己方怒气:", resultData.Appease_SelfAnger)
			self.mSelfMpValue = self.mSelfMpValue + tonumber(resultData.Appease_SelfAnger)

			print("对方血量:", resultData.Appease_EnemyBlood)
			self.mEnemyHpValue = self.mEnemyHpValue + tonumber(resultData.Appease_EnemyBlood)

			print("对方怒气:", resultData.Appease_EnemyAnger)
			self.mEnemyMpValue = self.mEnemyMpValue + tonumber(resultData.Appease_EnemyAnger)
		end
	elseif enemyCardIndex <= 4 and selfCardIndex <= 4 then -- 双方都是技能牌
		print("双方都是技能牌")
		-- 结果
		local resultData = DB_DateCardPK.getDataById(selfCardIndex)
		if 1 == enemyCardIndex then -- 对方必杀
			print("己方血量:", resultData.Kill_SelfBlood)
			self.mSelfHpValue = self.mSelfHpValue + tonumber(resultData.Kill_SelfBlood)

			print("己方怒气:", resultData.Kill_SelfAnger)
			self.mSelfMpValue = self.mSelfMpValue + tonumber(resultData.Kill_SelfAnger)

			print("对方血量:", resultData.Kill_EnemyBlood)
			self.mEnemyHpValue = self.mEnemyHpValue + tonumber(resultData.Kill_EnemyBlood)

			print("对方怒气:", resultData.Kill_EnemyAnger)
			self.mEnemyMpValue = self.mEnemyMpValue + tonumber(resultData.Kill_EnemyAnger)
		elseif 2 == enemyCardIndex then -- 对方无视
			print("己方血量:", resultData.Ignore_SelfBlood)
			self.mSelfHpValue = self.mSelfHpValue + tonumber(resultData.Ignore_SelfBlood)

			print("己方怒气:", resultData.Ignore_SelfAnger)
			self.mSelfMpValue = self.mSelfMpValue + tonumber(resultData.Ignore_SelfAnger)

			print("对方血量:", resultData.Ignore_EnemyBlood)
			self.mEnemyHpValue = self.mEnemyHpValue + tonumber(resultData.Ignore_EnemyBlood)

			print("对方怒气:", resultData.Ignore_EnemyAnger)
			self.mEnemyMpValue = self.mEnemyMpValue + tonumber(resultData.Ignore_EnemyAnger)
		elseif 3 == enemyCardIndex then -- 对方暴怒
			print("己方血量:", resultData.Angry_SelfBlood)
			self.mSelfHpValue = self.mSelfHpValue + tonumber(resultData.Angry_SelfBlood)

			print("己方怒气:", resultData.Angry_SelfAnger)
			self.mSelfMpValue = self.mSelfMpValue + tonumber(resultData.Angry_SelfBlood)

			print("对方血量:", resultData.Angry_EnemyBlood)
			self.mEnemyHpValue = self.mEnemyHpValue + tonumber(resultData.Angry_EnemyBlood)

			print("对方怒气:", resultData.Angry_EnemyAnger)
			self.mEnemyMpValue = self.mEnemyMpValue + tonumber(resultData.Angry_EnemyAnger)

		elseif 4 == enemyCardIndex then -- 对方安抚
			print("己方血量:", resultData.Appease_SelfBlood)
			self.mSelfHpValue = self.mSelfHpValue + tonumber(resultData.Appease_SelfBlood)

			print("己方怒气:", resultData.Appease_SelfAnger)
			self.mSelfMpValue = self.mSelfMpValue + tonumber(resultData.Appease_SelfAnger)

			print("对方血量:", resultData.Appease_EnemyBlood)
			self.mEnemyHpValue = self.mEnemyHpValue + tonumber(resultData.Appease_EnemyBlood)

			print("对方怒气:", resultData.Appease_EnemyAnger)
			self.mEnemyMpValue = self.mEnemyMpValue + tonumber(resultData.Appease_EnemyAnger)
		end
	end

	-- 显示血量怒气
	self:showHpAndMp()

	if self.mSelfHpValue < 0 then
		doError("you lose!")
	elseif self.mEnemyHpValue < 0 then -- 比赛结束
		doError("you win!")
	else -- 下一回合

	--	local function actEnd()
			self:roundBegin()
	--	end

	--	local act0 = cc.DelayTime:create(2)
	--	local act1 = cc.CallFunc:create(actEnd)

	--	self.mRootWidget:runAction(cc.Sequence:create(act0, act1))
		
	end
end

function CardGameWindow:Load(event)
	cclog("=====CardGameWindow:Load=====begin")

	self.mRootNode = cc.Node:create()
	GUISystem:GetRootNode():addChild(self.mRootNode)

	self.mEnemyHeroId = event.mData
	self.mSelfHeroId = globaldata:getHeroInfoByBattleIndex(1, "id")

	self:InitLayout()

--	self:showHeroAnims()

	-- 游戏开始
	self:gameStart()

	cclog("=====CardGameWindow:Load=====end")
end

function CardGameWindow:showHeroAnims()
	-- 敌人
--	self.mEnemyHeroAnim = FightSystem.mRoleManager:CreateSpine(self.mEnemyHeroId)
--	self.mRootWidget:getChildByName("Panel_EnemyInfo"):getChildByName("Panel_HeroHead"):addChild(self.mEnemyHeroAnim)
--	self.mEnemyHeroAnim:setAnimation(0, "stand", true)

--	self.mEnemyHeroAnim = SpineDataCacheManager:getSimpleSpineByHeroID(self.mEnemyHeroId, self.mRootWidget:getChildByName("Panel_EnemyInfo"):getChildByName("Panel_HeroHead"))
--	self.mEnemyHeroAnim:setAnimation(0, "stand", true)

	-- 自己
--	self.mSelfHeroAnim = FightSystem.mRoleManager:CreateSpine(globaldata:getHeroInfoByBattleIndex(1, "id"))
--	self.mRootWidget:getChildByName("Panel_CaptainInfo"):getChildByName("Panel_HeroHead"):addChild(self.mSelfHeroAnim)
--	self.mSelfHeroAnim:setAnimation(0, "stand", true)

--	self.mSelfHeroAnim = SpineDataCacheManager:getSimpleSpineByHeroID(globaldata:getHeroInfoByBattleIndex(1, "id"), self.mRootWidget:getChildByName("Panel_CaptainInfo"):getChildByName("Panel_HeroHead"))
--	self.mSelfHeroAnim:setAnimation(0, "stand", true)
end

-- 游戏开始
function CardGameWindow:gameStart()
	-- 清除牌
	self.mSelfCardTeam		=	{0, 0, 0, 0, 0}	    -- 己方阵容
	self.mEnemyCardTeam 	=	{0, 0, 0, 0, 0}   	-- 敌方阵容

	-- 己方血量怒气
	self.mSelfHpValue = 25
	self.mSelfMpValue = 0

	-- 敌方血量怒气
	self.mEnemyHpValue = 25
	self.mEnemyMpValue = 0

	-- 无敌状态
	self.mSelfWudiState 				=	false				-- 己方无敌状态
	self.mSelfWudiCount				=	0
	self.mEnemyWudiState 			=	false				-- 敌方无敌状态
	self.mEnemyWudiCount				=	0

	-- 回合开始
	self:roundBegin()
end

-- 刷新血量怒气显示
function CardGameWindow:showHpAndMp()
	-- 己方血量
	if self.mSelfHpValue >= 25 then
		self.mSelfHpValue = 25
	elseif self.mSelfHpValue <= 0 then
		self.mSelfHpValue = 0
	end
	self.mRootWidget:getChildByName("Panel_Bottom"):getChildByName("Label_BloodCount"):setString(tostring(self.mSelfHpValue))
	-- 己方怒气
	if self.mSelfMpValue >= 25 then
		self.mSelfMpValue = 25
	elseif self.mSelfMpValue <= 0 then
		self.mSelfMpValue = 0
	end
	self.mRootWidget:getChildByName("Panel_Bottom"):getChildByName("Label_AngerCount"):setString(tostring(self.mSelfMpValue))
	-- 敌方血量
	if self.mEnemyHpValue >= 25 then
		self.mEnemyHpValue = 25
	elseif self.mEnemyHpValue <= 0 then
		self.mEnemyHpValue = 0
	end
	self.mRootWidget:getChildByName("Panel_Top"):getChildByName("Label_BloodCount"):setString(tostring(self.mEnemyHpValue))
	-- 敌方怒气
	if self.mEnemyMpValue >= 25 then
		self.mEnemyMpValue = 25
	elseif self.mEnemyMpValue <= 0 then
		self.mEnemyMpValue = 0
	end
	self.mRootWidget:getChildByName("Panel_Top"):getChildByName("Label_AngerCount"):setString(tostring(self.mEnemyMpValue))

	-- 检测无敌状态
	if wudiStateValue == self.mEnemyMpValue then
		self.mEnemyMpValue = 0
		self.mEnemyWudiState = true
		self.mEnemyWudiCount = 3
	end

	-- 检测无敌状态
	if wudiStateValue == self.mSelfMpValue then
		self.mSelfMpValue = 0
		self.mSelfWudiState = true
		self.mSelfWudiCount = 3
	end

end

-- 清理Spine
function CardGameWindow:cleanSpineCache()

	SpineDataCacheManager:collectFightSpineByAtlas(self.mEnemyHeroAnim)

	SpineDataCacheManager:collectFightSpineByAtlas(self.mSelfHeroAnim)

	for i = 1, #self.mSelfCardWidgetList do
		local preSpine = self.mSelfCardWidgetList[i]:getChildByName("Panel_InnerHero"):getChildren()
		if #preSpine > 0 then
			SpineDataCacheManager:collectFightSpineByAtlas(preSpine[1])
		end
	end

	for i = 1, #self.mEnemyCardWidgetList do
		local preSpine = self.mEnemyCardWidgetList[i]:getChildByName("Panel_InnerHero"):getChildren()
		if #preSpine > 0 then
			SpineDataCacheManager:collectFightSpineByAtlas(preSpine[1])
		end
	end
end

-- 清理战场
function CardGameWindow:cleanPreRound()
	-- 敌方
	if self.mEnemyCurBattleCardIndex then

		-- 回收Spine
	--	local preSpine = self.mEnemyCardWidgetList[self.mEnemyCurBattleCardIndex]:getChildByName("Panel_InnerHero"):getChildren()
	--	if #preSpine > 0 then
	--		SpineDataCacheManager:collectFightSpineByAtlas(preSpine[1])
	--	end

		self.mEnemyCardWidgetList[self.mEnemyCurBattleCardIndex]:removeFromParent(true)
		self.mEnemyCardWidgetList[self.mEnemyCurBattleCardIndex] = nil
		self.mEnemyCardTeam[self.mEnemyCurBattleCardIndex] = 0
		self.mEnemyCurBattleCardIndex = nil
	end

	-- 敌方无敌状态
	if self.mEnemyWudiCount > 0 then
		self.mEnemyWudiCount = self.mEnemyWudiCount - 1
	else
		self.mEnemyWudiState = false
	end

	-- 己方
	if self.mSelfCurBattleCardIndex then

		-- 回收Spine
		-- local preSpine = self.mSelfCardWidgetList[self.mSelfCurBattleCardIndex]:getChildByName("Panel_InnerHero"):getChildren()
		-- if #preSpine > 0 then
		-- 	SpineDataCacheManager:collectFightSpineByAtlas(preSpine[1])
		-- end

		self.mSelfCardWidgetList[self.mSelfCurBattleCardIndex]:removeFromParent(true)
		self.mSelfCardWidgetList[self.mSelfCurBattleCardIndex] = nil
		self.mSelfCardTeam[self.mSelfCurBattleCardIndex] = 0
		self.mSelfCurBattleCardIndex = nil
	end

	-- 己方无敌状态
	if self.mSelfWudiCount > 0 then
		self.mSelfWudiCount = self.mSelfWudiCount - 1
	else
		self.mSelfWudiState = false
	end
end

-- 回合开始
function CardGameWindow:roundBegin()
	-- 允许点击
	GUISystem:enableUserInput()
	-- 清理
	self:cleanPreRound()

	-- 回合计数
	self.mCurRoundIndex = self.mCurRoundIndex + 1

--	doError("round: "..tostring(self.mCurRoundIndex).." begin!")

	-- 显示血量怒气
	self:showHpAndMp()

	-- 随机主题
	self:randomRoundTitle()

	-- 随机己方的卡片
	self:randomSelfTeam()

	-- 随机敌方的卡片
	self:randomEnemyTeam()

--	-- 敌方出牌
--	self:sendOneCardToBattle()

	-- 玩家出牌阶段
	self:setGameState("needSendCard")
	MessageBox:showMessageBox1("请出牌~")
end

-- 随机主题
function CardGameWindow:randomRoundTitle()
	self.mCurRoundTitle = math.random(1, 3)
	self.mRootWidget:getChildByName("Image_Music"):loadTexture("date_card_icon_music1.png")
	self.mRootWidget:getChildByName("Image_Sport"):loadTexture("date_card_icon_sport1.png")
	self.mRootWidget:getChildByName("Image_Painting"):loadTexture("date_card_icon_painting1.png")
	if 1 == self.mCurRoundTitle then
		self.mRootWidget:getChildByName("Image_Music"):loadTexture("date_card_icon_music2.png")
	elseif 2 == self.mCurRoundTitle then
		self.mRootWidget:getChildByName("Image_Sport"):loadTexture("date_card_icon_sport2.png")
	elseif 3 == self.mCurRoundTitle then
		self.mRootWidget:getChildByName("Image_Painting"):loadTexture("date_card_icon_painting2.png")
	end
end

-- 创建一个卡片控件
function CardGameWindow:createOneCardWidget(index, isEnemy)
	local cardWidget = GUIWidgetPool:createWidget("NewDate_GameCard_Cell")

	print("index:", index)
	local cardData = DB_DateCard.getDataById(index)
	
	if cardData.Date_CardType <= 4 then -- 技能牌
		cardWidget:getChildByName("Image_Skill"):setVisible(true)
		cardWidget:getChildByName("Panel_Hero"):setVisible(false)
		local iconId = cardData.Date_CardIconID
		local imgName = DB_ResourceList.getDataById(iconId).Res_path1
		cardWidget:getChildByName("Image_Skill"):loadTexture(imgName)
	else -- 英雄 
		cardWidget:getChildByName("Image_Skill"):setVisible(false)
		cardWidget:getChildByName("Panel_Hero"):setVisible(true)
		-- 读取属性图
		if 5 == cardData.Date_CardType then
			cardWidget:getChildByName("Panel_Hero"):getChildByName("Image_Bg"):loadTexture("date_card_hero_music.png")
		elseif 6 == cardData.Date_CardType then
			cardWidget:getChildByName("Panel_Hero"):getChildByName("Image_Bg"):loadTexture("date_card_hero_sport.png")
		elseif 7 == cardData.Date_CardType then
			cardWidget:getChildByName("Panel_Hero"):getChildByName("Image_Bg"):loadTexture("date_card_hero_painting.png")
		end

	-- 载入头像
	local imgId = cardData.Date_CardIconID
	local imgName = DB_ResourceList.getDataById(imgId).Res_path1
	cardWidget:getChildByName("Image_HeroPic"):loadTexture(imgName,1)

	-- 旋转
	--cardWidget:getChildByName("Panel_Middle"):setRotation(-24)

	--	local anim = FightSystem.mRoleManager:CreateSpine(index - 4)
	--	anim:setAnimation(0, "stand", true)
	--	cardWidget:getChildByName("Panel_InnerHero"):addChild(anim)

	--	local anim = SpineDataCacheManager:getSimpleSpineByHeroID(index - 4, cardWidget:getChildByName("Panel_InnerHero"))
	--	anim:setAnimation(0, "stand", true)

	--	cardWidget:getChildByName("Label_Music_Stroke"):setString(cardData.Mus!c)
	--	cardWidget:getChildByName("Label_Sport_Stroke"):setString(cardData.Sport)
	--	cardWidget:getChildByName("Label_Painting_Stroke"):setString(cardData.Paint)
	end

	-- 显示数值
	cardWidget:getChildByName("Label_Figure"):setString(tostring(cardData.Figure))

	if isEnemy then -- 敌方
	--	if index <= 4 then -- 技能牌暴露正面
	--		cardWidget:getChildByName("Image_Back"):setVisible(false)
	--		cardWidget:getChildByName("Panel_Front"):setVisible(true)
	--	else -- 属性牌暴露背面
			cardWidget:getChildByName("Image_Back"):setVisible(true)
			cardWidget:getChildByName("Panel_Front"):setVisible(false)
	--	end
	else -- 自己
		cardWidget:getChildByName("Image_Back"):setVisible(false)
		cardWidget:getChildByName("Panel_Front"):setVisible(true)
	end

	-- 载入卡背
	if cardData.Date_CardType <= 4 then
		cardWidget:getChildByName("Image_Back"):loadTexture("date_card_cardback_skill.png")
	elseif cardData.Date_CardType == 5 then
		cardWidget:getChildByName("Image_Back"):loadTexture("date_card_cardback_music.png")
	elseif cardData.Date_CardType == 6 then
		cardWidget:getChildByName("Image_Back"):loadTexture("date_card_cardback_sport.png")
	elseif cardData.Date_CardType == 7 then
		cardWidget:getChildByName("Image_Back"):loadTexture("date_card_cardback_painting.png")
	end


	return cardWidget
end

-- 随机己方的卡片
function CardGameWindow:randomSelfTeam()
	local function getCardCount()
		local cnt = 0 
		for i = 1, #self.mSelfCardTeam do
			if 0 ~= self.mSelfCardTeam[i] then
				cnt = cnt + 1
			end
		end
		return cnt
	end

	if 0 == getCardCount() then -- 第一次
		for i = 1, #self.mSelfCardTeam do
			if 0 == self.mSelfCardTeam[i] then -- 此位置没有卡片,随机一张
				self.mSelfCardTeam[i] = randomOneCardByHeroId(self.mSelfHeroId)
				local containerWidget = self.mRootWidget:getChildByName("Panel_Bottom"):getChildByName("Panel_Cardpool_1"):getChildByName("Panel_Card_"..tostring(i))
				local pos = containerWidget:getWorldPosition()
				self.mSelfCardWidgetList[i] = self:createOneCardWidget(self.mSelfCardTeam[i], false)
				self.mRootWidget:getChildByName("Panel_CardStay"):addChild(self.mSelfCardWidgetList[i], cardZOrderTbl[i])
				self.mSelfCardWidgetList[i]:setPosition(pos)
			end
		end
	elseif 4 == getCardCount() then 
		for i = 1, 5 do -- 前四个向左移动
			if i ~= 5 then
				local cardWidget = self.mSelfCardWidgetList[i]
				local tarPos = self.mRootWidget:getChildByName("Panel_Bottom"):getChildByName("Panel_Cardpool_1"):getChildByName("Panel_Card_"..tostring(i)):getWorldPosition()
				local act0 = cc.MoveTo:create(0.5, tarPos)
				cardWidget:runAction(act0)
			else
				self.mSelfCardTeam[i] = randomOneCardByHeroId(self.mSelfHeroId)
				local containerWidget = self.mRootWidget:getChildByName("Panel_Bottom"):getChildByName("Panel_Cardpool_1"):getChildByName("Panel_Card_5_Initial")
				local pos = containerWidget:getWorldPosition()
				self.mSelfCardWidgetList[i] = self:createOneCardWidget(self.mSelfCardTeam[i], false)
				self.mRootWidget:getChildByName("Panel_CardStay"):addChild(self.mSelfCardWidgetList[i], cardZOrderTbl[i])
				self.mSelfCardWidgetList[i]:setPosition(pos)

				local tarPos = self.mRootWidget:getChildByName("Panel_Bottom"):getChildByName("Panel_Cardpool_1"):getChildByName("Panel_Card_5"):getWorldPosition()
				local act0 = cc.MoveTo:create(0.5, tarPos)
				self.mSelfCardWidgetList[i]:runAction(act0)
			end
		end 
	end
end

-- 敌方卡牌随机一张上阵
function CardGameWindow:sendOneCardToBattle()
	-- 统计技能牌数量
	local function getSkillCardCount()
		local Cnt = 0
		local Tbl = {}
		for i = 1, #self.mEnemyCardTeam do
			if 0 ~= self.mEnemyCardTeam[i] and self.mEnemyCardTeam[i] <=4 then
				Cnt = Cnt + 1
				table.insert(Tbl, i)
			end
		end
		return Cnt, Tbl
	end
	-- -- 获取对应属性最高的两张牌的Index
	-- local function getTwoPropValueMax(propType)
	-- 	local Tbl = {}
	-- 	for i = 1, #self.mEnemyCardTeam do
	-- 		if 0 ~= self.mEnemyCardTeam[i] then
	-- 			table.insert(Tbl, i)
	-- 		end
	-- 	end
	-- 	local function doSort(key1, key2)
	-- 		local data1 = DB_DateCard.getDataById(self.mEnemyCardTeam[key1])
	-- 		local data2 = DB_DateCard.getDataById(self.mEnemyCardTeam[key2])
	-- 		if 1 == propType then
	-- 			return data1.Music > data2.Music
	-- 		elseif 2 == propType then
	-- 			return data1.Paint > data2.Paint
	-- 		elseif 3 == propType then
	-- 			return data1.Sport > data2.Sport
	-- 		end
	-- 	end
	-- 	table.sort(Tbl, doSort)
		
	-- 	return Tbl[1], Tbl[2]
	-- end

	-- 如果有与回合主题一致的属性牌，出figure最大的那张；如果没有，出figure最大的那张
	local function getSpecialFigure(propType)
		local sameTypeTbl = {}
		for i = 1, #self.mEnemyCardTeam do
			local cardData = DB_DateCard.getDataById(self.mEnemyCardTeam[i])
			if propType == cardData.Date_CardType then
				table.insert(sameTypeTbl, i)
			end
		end
		-- 排序函数
		local function sortFunc(key1, key2)
			local data1 = DB_DateCard.getDataById(self.mEnemyCardTeam[key1])
	 		local data2 = DB_DateCard.getDataById(self.mEnemyCardTeam[key2])
	 		return data1.Figure > data2.Figure
		end
		if #sameTypeTbl > 0 then -- 如果有相同属性的牌
			table.sort(sameTypeTbl, sortFunc)
			return sameTypeTbl[1]
		else -- 如果没有相同属性的牌
			local allTypeTbl = {}
			for i = 1, #self.mEnemyCardTeam do
			local cardData = DB_DateCard.getDataById(self.mEnemyCardTeam[i])
				if cardData.Date_CardType > 4 then
					table.insert(allTypeTbl, i)
				end
			end
			table.sort(allTypeTbl, sortFunc)
			return allTypeTbl[1]
		end
	end

	local retCnt, retTbl = getSkillCardCount()
	if 5 == retCnt or 4 == retCnt then -- 随机出一张技能牌
		print("第一种情况")
		local randomNum = math.random(1, #retTbl)
		self.mEnemyCurBattleCardIndex = retTbl[randomNum]
	elseif 1 <= retCnt and 3 >= retCnt then
		print("第二种情况")
		local ret = math.random(1, 5)
		if ret <= retCnt then -- 本局出技能牌
			local randomNum = math.random(1, #retTbl)
			self.mEnemyCurBattleCardIndex = retTbl[randomNum]
		else -- 本局出英雄牌
		--	self.mEnemyCurBattleCardIndex = getTwoPropValueMax(self.mCurRoundTitle)
			self.mEnemyCurBattleCardIndex =	getSpecialFigure(self.mCurRoundTitle)
		end
	elseif 0 == retCnt then -- 50%出属性最高的, 50%出属性第二高的
		-- print("第三种情况")
		-- local index1, index2 = getTwoPropValueMax(self.mCurRoundTitle)
		-- local ret = math.random(1, 2)
		-- if 1 == ret then
		-- 	self.mEnemyCurBattleCardIndex = index1
		-- else
		-- 	self.mEnemyCurBattleCardIndex = index2
		-- end
		self.mEnemyCurBattleCardIndex =	getSpecialFigure(self.mCurRoundTitle)
	end
	print("敌方出牌Index:",  self.mEnemyCardTeam[self.mEnemyCurBattleCardIndex])

	local cardWidget = self.mEnemyCardWidgetList[self.mEnemyCurBattleCardIndex]
	cardWidget:setLocalZOrder(1000)

	local function actEnd2()
		-- 判断结果
		self:doCompute()
--		GUISystem:enableUserInput()
	end

	local function actEnd0()
		-- 落地
		shakeNode(self.mRootNode)
		-- 重置敌军位置
		self:resetEnemyCardPos()
	end

	local function actEnd1()
		-- 翻牌
	--	self.mEnemyCardWidgetList[self.mEnemyCurBattleCardIndex]:getChildByName("Image_Back"):setVisible(false)
	--	self.mEnemyCardWidgetList[self.mEnemyCurBattleCardIndex]:getChildByName("Panel_Front"):setVisible(true)
		local cardWidget = self.mEnemyCardWidgetList[self.mEnemyCurBattleCardIndex]
		local tm = 1
		-- 翻前面
		local function turnFront()
			local function xxx()
				cardWidget:getChildByName("Panel_Front"):setLocalZOrder(5)
				cardWidget:getChildByName("Panel_Front"):setVisible(true)
			end

			local act0 = cc.OrbitCamera:create(tm, 1, 0, 0, 180, 0, 0)
			local act1 = cc.DelayTime:create(tm/2)
			local act2 = cc.CallFunc:create(xxx)

			cardWidget:getChildByName("Panel_Front"):setScaleX(-1)
			cardWidget:getChildByName("Panel_Front"):runAction(cc.Spawn:create(act0, cc.Sequence:create(act1, act2)))
		end
		turnFront()

		-- 翻背面
		local function turnBack()
			local function xxx()
				cardWidget:getChildByName("Image_Back"):setLocalZOrder(1)
				cardWidget:getChildByName("Image_Back"):setVisible(false)
			end

			local act0 = cc.OrbitCamera:create(tm, 1, 0, 0, 180, 0, 0)
			local act1 = cc.DelayTime:create(tm/2)
			local act2 = cc.CallFunc:create(xxx)
			local act3 = cc.DelayTime:create(3) -- 翻牌三秒后判断结果
			local act4 = cc.CallFunc:create(actEnd2)

			cardWidget:getChildByName("Image_Back"):runAction(   cc.Sequence:create(   cc.Spawn:create(act0, cc.Sequence:create(act1, act2))  , act3, act4)  )
		end
		turnBack()
	end

	local act0 = cc.Sequence:create(cc.ScaleTo:create(moveTime/2, 1.3), cc.ScaleTo:create(moveTime/2, 1))                              
	local act1 = cc.MoveTo:create(moveTime, cc.p(self.mRootWidget:getChildByName("Panel_Card_Enemy"):getWorldPosition()))
	local act2 = cc.CallFunc:create(actEnd0)
	local act3 = cc.DelayTime:create(3) -- 卡牌落地三秒后翻牌
	local act4 = cc.CallFunc:create(actEnd1)
--	local act5 = cc.DelayTime:create(3) -- 翻牌一秒后判断结果
--	local act6 = cc.CallFunc:create(actEnd2)
	local act7 = cc.EaseInOut:create(cc.Spawn:create(act0, act1), 1.35) 
	cardWidget:runAction(cc.Sequence:create(act7, act2, act3, act4))
--	GUISystem:disableUserInput()

	local function rotateAction()
		local act0 = cc.RotateTo:create(moveTime, 0)
		cardWidget:getChildByName("Panel_Middle"):runAction(act0)
	end
	rotateAction()
end

-- 随机敌方的卡片
function CardGameWindow:randomEnemyTeam()
	local function getCardCount()
		local cnt = 0 
		for i = 1, #self.mEnemyCardTeam do
			if 0 ~= self.mEnemyCardTeam[i] then
				cnt = cnt + 1
			end
		end
		return cnt
	end

	if 0 == getCardCount() then -- 第一次
		for i = 1, #self.mEnemyCardTeam do
			if 0 == self.mEnemyCardTeam[i] then -- 此位置没有卡片,随机一张
				self.mEnemyCardTeam[i] = randomOneCardByHeroId(self.mSelfHeroId)
				local containerWidget = self.mRootWidget:getChildByName("Panel_Top"):getChildByName("Panel_Cardpool_1"):getChildByName("Panel_Card_"..tostring(i))
				local pos = containerWidget:getWorldPosition()
				self.mEnemyCardWidgetList[i] = self:createOneCardWidget(self.mEnemyCardTeam[i], true)
				self.mRootWidget:getChildByName("Panel_CardStay"):addChild(self.mEnemyCardWidgetList[i], cardZOrderTbl[i])
				self.mEnemyCardWidgetList[i]:setPosition(pos)
			end
		end
	elseif 4 == getCardCount() then 
		for i = 1, 5 do -- 前四个向左移动
			if i ~= 5 then
				local cardWidget = self.mEnemyCardWidgetList[i]
				local tarPos = self.mRootWidget:getChildByName("Panel_Top"):getChildByName("Panel_Cardpool_1"):getChildByName("Panel_Card_"..tostring(i)):getWorldPosition()
				local act0 = cc.MoveTo:create(0.5, tarPos)
				cardWidget:runAction(act0)
			else
				self.mEnemyCardTeam[i] = randomOneCardByHeroId(self.mSelfHeroId)
				local containerWidget = self.mRootWidget:getChildByName("Panel_Top"):getChildByName("Panel_Cardpool_1"):getChildByName("Panel_Card_5_Initial")
				local pos = containerWidget:getWorldPosition()
				self.mEnemyCardWidgetList[i] = self:createOneCardWidget(self.mEnemyCardTeam[i], true)
				self.mRootWidget:getChildByName("Panel_CardStay"):addChild(self.mEnemyCardWidgetList[i], cardZOrderTbl[i])
				self.mEnemyCardWidgetList[i]:setPosition(pos)

				local tarPos = self.mRootWidget:getChildByName("Panel_Top"):getChildByName("Panel_Cardpool_1"):getChildByName("Panel_Card_5"):getWorldPosition()
				local act0 = cc.MoveTo:create(0.5, tarPos)
				self.mEnemyCardWidgetList[i]:runAction(act0)
			end
		end 
	end
end

function CardGameWindow:InitLayout()

	self.mRootWidget = GUIWidgetPool:createWidget("NewDate_GameCard")
	self.mRootNode:addChild(self.mRootWidget)

	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_Pause"),function()
		Event.GUISYSTEM_SHOW_FIGHTPAUSEWINDOW.mData = WINDOW_FROM.CARDGAME  
		EventSystem:PushEvent(Event.GUISYSTEM_SHOW_FIGHTPAUSEWINDOW)
	end)

	-- Panel_Top适配
	self.mRootWidget:getChildByName("Panel_Top"):setPositionY(getGoldFightPosition_LU().y - self.mRootWidget:getChildByName("Panel_Top"):getContentSize().height)

	-- Panel_Pause适配
	self.mRootWidget:getChildByName("Panel_Pause"):setPositionX(getGoldFightPosition_LU().x)
	self.mRootWidget:getChildByName("Panel_Pause"):setPositionY(getGoldFightPosition_LU().y - self.mRootWidget:getChildByName("Panel_Pause"):getContentSize().height)

	-- Panel_EnemyInfo适配
--	self.mRootWidget:getChildByName("Panel_EnemyInfo"):setPositionX(getGoldFightPosition_RU().x - self.mRootWidget:getChildByName("Panel_EnemyInfo"):getContentSize().width)

	-- Panel_CaptainInfo适配
--	self.mRootWidget:getChildByName("Panel_CaptainInfo"):setPositionX(getGoldFightPosition_LU().x)

	-- Panel_Title适配
--	self.mRootWidget:getChildByName("Panel_Title"):setPositionX(getGoldFightPosition_RU().x - self.mRootWidget:getChildByName("Panel_Title"):getContentSize().width)

	-- Panel_Icons适配
--	self.mRootWidget:getChildByName("Panel_Icons"):setPositionX(getGoldFightPosition_LU().x)

	-- Panel_Bottom适配
	self.mRootWidget:getChildByName("Panel_Bottom"):setPositionY(getGoldFightPosition_LD().y)
	self.mRootWidget:getChildByName("Panel_Bottom"):setTouchEnabled(false)

	self.mRootWidget:getChildByName("Panel_CardStay"):addTouchEventListener(handler(self, self.onTouchScreen))

	-- Panel_Icons贴左侧
	self.mRootWidget:getChildByName("Panel_Icons"):setPositionX(getGoldFightPosition_LU().x)

	-- Panel_Title贴右侧
--	self.mRootWidget:getChildByName("Panel_Title"):setPositionX(getGoldFightPosition_RU().x - self.mRootWidget:getChildByName("Panel_Title"):getContentSize().width)

end

function CardGameWindow:Destroy()
	-- 清理Spine
--	self:cleanSpineCache()

	self.mRootNode:removeFromParent(true)
	self.mRootNode 		= 	nil
	self.mRootWidget 	= 	nil

	self.mEnemyHeroId   = 	nil

	self.mSelfHeroId 		=	nil
	self.mEnemyHeroId 		=	nil

	self.mSelfHeroAnim		=	nil
	self.mEnemyHeroAnim 		=	nil

	self.mSelfCardTeam				=	{0, 0, 0, 0, 0}
	self.mSelfCardWidgetList			=	{}
	self.mSelfCurBattleCardIndex		=	nil
	self.mSelfHpValue 				=	0
	self.mSelfMpValue				=	0
	self.mEnemyCardTeam 				=	{0, 0, 0, 0, 0}
	self.mEnemyCardWidgetList		=	{}
	self.mEnemyCurBattleCardIndex	=	nil
	self.mEnemyHpValue				=	0
	self.mEnemyMpValue				=	0

	self.mCurRoundIndex		=	0

	self.mGameState 			=	"needSendCard"
	self.mCurRoundTitle		=	nil

	-- 无敌状态
	self.mSelfWudiState 				=	false				-- 己方无敌状态
	self.mSelfWudiCount				=	0
	self.mEnemyWudiState 			=	false				-- 敌方无敌状态
	self.mEnemyWudiCount				=	0

	cclog("=====CardGameWindow:Destroy=====")
end

function CardGameWindow:onEventHandler(event)
	if event.mAction == Event.WINDOW_SHOW then
		self:Load(event)
	elseif event.mAction == Event.WINDOW_HIDE then
		self:Destroy()
	end
end

return CardGameWindow