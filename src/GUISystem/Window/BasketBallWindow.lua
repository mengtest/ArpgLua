-- Name: 	BasketBallWindow.lua
-- Func：	篮球
-- Author:	WangShengdong
-- Data:	15-9-21

local const_GoalCount = 6 -- 进球数

local const_CoolDownCount = 3 -- CD时间

local const_LeftSecondCount = 180

local const_ScaleValue = 1

local BasketBallWindow = 
{
	mName				=	"BasketBallWindow",
	mRootNode			=	nil,
	mRootWidget			=	nil,

	-----------------------------------------
	mBasketWidget		=	nil, 	-- 篮筐
	mBasketWidgetFront  =	nil,
	mPlayerHeroId 		=	nil, 	-- 队员ID
	mPlayerAnim 		=	nil, 	-- 英雄动画
	mSchedulerEntry 	= 	nil,	-- 定时器
	mMovingDir 			=	nil, 	-- 移动方向
	-----------------------------------------
	mResultSchedulerEntry 	=	nil,	-- 结果检测定时器
	mBallWidget 		=	nil,	-- 篮球控件
	-----------------------------------------
	mSpineSchedulerEntry 			=	nil,
	mSpineBall 			=	nil, 	-- 篮球Spine
	mSpineBasket		=	nil,	-- 篮网Spine
	mResultBall 		=	nil, 	-- 投篮结果动画
	-----------------------------------------
	mJudgeSchedulerEntry	=	nil,	-- 裁判计时器
	mLeftSecondCount		=	nil,	-- 剩余秒数
	mGoalCount				=	0,		-- 进球数
	mCdSecondCount			=	0,		-- CD
}

function BasketBallWindow:Release()

end

function BasketBallWindow:Load(event)
	cclog("=====BasketBallWindow:Load=====begin")

	self.mRootNode = cc.Node:create()
	GUISystem:GetRootNode():addChild(self.mRootNode)

	self.mPlayerHeroId = event.mData

	FightSystem.mShowSceneManager:LoadSceneView(1, self.mRootNode, 13)

	self:InitLayout()

	self:initTouchPad()

	-- 游戏开始
	self:gameStart()
      
	cclog("=====BasketBallWindow:Load=====end")
end

function BasketBallWindow:InitLayout()

	self.mRootWidget = GUIWidgetPool:createWidget("NewDate_GameBasketball")
	self.mRootNode:addChild(self.mRootWidget, 2)

	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_Pause"),function()
		Event.GUISYSTEM_SHOW_FIGHTPAUSEWINDOW.mData = WINDOW_FROM.BASKETBALL  
		EventSystem:PushEvent(Event.GUISYSTEM_SHOW_FIGHTPAUSEWINDOW)
	end)

	local function doAdapter()
		-- Panel_BottomLeft左下角
		self.mRootWidget:getChildByName("Panel_BottomLeft"):setPosition(getGoldFightPosition_LD())

		-- Panel_Shoot右下角
		self.mRootWidget:getChildByName("Panel_Shoot"):setPosition(cc.p(getGoldFightPosition_RD().x - self.mRootWidget:getChildByName("Panel_Shoot"):getContentSize().width, getGoldFightPosition_RD().y))

		-- Panel_Top左上角
		self.mRootWidget:getChildByName("Panel_Top"):setPosition(cc.p(getGoldFightPosition_LU().x, getGoldFightPosition_LU().y - self.mRootWidget:getChildByName("Panel_Top"):getContentSize().height))

		-- Panel_TopLeft左边
		self.mRootWidget:getChildByName("Panel_TopLeft"):setPositionX(getGoldFightPosition_LU().x)

		-- Panel_TopRight右边
		self.mRootWidget:getChildByName("Panel_TopRight"):setPositionX(getGoldFightPosition_RU().x - self.mRootWidget:getChildByName("Panel_TopRight"):getContentSize().width)

	end
	doAdapter()

	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_Direction"), handler(self, self.doShoot))

	-- 初始化篮筐
	self:initBasket()
end

-- spineTick
function BasketBallWindow:doSpineTick()
	local ballPos = self.mPlayerAnim:getBonePosition("daoju2")
	self.mSpineBall:setPosition(cc.p(ballPos.x, ballPos.y + 15))
end

-- 初始化篮筐
function BasketBallWindow:initBasket()
	self.mBasketWidget = GUIWidgetPool:createWidget("NewDate_GameBasketBall_BackBoard")
	self.mBasketWidget:setAnchorPoint(cc.p(0.5, 0.5))
	self.mRootWidget:getChildByName("Panel_BackboardArea"):addChild(self.mBasketWidget)

	self.mBasketWidgetFront = GUIWidgetPool:createWidget("NewDate_GameBasketBall_BackBoard")
	self.mBasketWidgetFront:setAnchorPoint(cc.p(0.5, 0.5))
	self.mRootWidget:getChildByName("Panel_BasketArea"):addChild(self.mBasketWidgetFront)
	self.mBasketWidgetFront:getChildByName("Image_BackBoard"):setVisible(false)


	self.mSpineBasket = CommonAnimation.createCacheSpine_commonByResID(1205, self.mBasketWidgetFront:getChildByName("Panel_Basket"))
	self.mSpineBasket:setAnimation(0, "stand", true)
end

local moveTime = 4
function BasketBallWindow:gameStart()

	-- 移动篮筐
	local function doBasketMove()
		self.mBasketWidget:setPosition(cc.p(0, 0))
		local tarPos = cc.p(0, self.mRootWidget:getChildByName("Panel_BackboardArea"):getContentSize().height)
		local act0 = cc.MoveTo:create(moveTime, tarPos)
		local act1 = cc.MoveTo:create(moveTime, cc.p(0, 0))
		self.mBasketWidget:runAction(cc.RepeatForever:create(cc.Sequence:create(act0, act1)))


		self.mBasketWidgetFront:setPosition(cc.p(0, 0))
		local tarPos = cc.p(0, self.mRootWidget:getChildByName("Panel_BackboardArea"):getContentSize().height)
		local act0 = cc.MoveTo:create(moveTime, tarPos)
		local act1 = cc.MoveTo:create(moveTime, cc.p(0, 0))
		self.mBasketWidgetFront:runAction(cc.RepeatForever:create(cc.Sequence:create(act0, act1)))
	end
	doBasketMove()

	-- 初始化队员
	local function initPlayer()
		self.mPlayerAnim = SpineDataCacheManager:getFullSpineByHeroID(self.mPlayerHeroId, self.mRootWidget:getChildByName("Panel_HeroWalkArea"))
		self.mPlayerAnim:setAnimation(0, "bindStand2", true)
		self.mPlayerAnim:registerSpineEventHandler(handler(self, self.onSpineCallBack), 1)
		self.mPlayerAnim:registerSpineEventHandler(handler(self, self.onSpineFrameCallBack), 3)
		self.mPlayerAnim:setScale(const_ScaleValue)

		if not self.mSpineSchedulerEntry then
			local scheduler = cc.Director:getInstance():getScheduler()
			self.mSpineSchedulerEntry = scheduler:scheduleScriptFunc(handler(self, self.doSpineTick), 0, false)
		end

		self.mSpineBall = GUIWidgetPool:createWidget("NewDate_GameBasketBall_Ball")	
		self.mPlayerAnim:addChild(self.mSpineBall, 1000)

	end
	initPlayer()

	-- 初始化定时器
	local function initScheduler()
		if not self.mJudgeSchedulerEntry then
			local scheduler = cc.Director:getInstance():getScheduler()
			self.mJudgeSchedulerEntry = scheduler:scheduleScriptFunc(handler(self, self.doJudgeTick), 1, false)
		end
		-- 重置时间
		self.mLeftSecondCount = const_LeftSecondCount
		-- 重置分数
		self.mGoalCount = 0
	end
	initScheduler()



end

function BasketBallWindow:timeFormat(seconds)
  local min = math.floor(seconds / 60)
  seconds = math.mod(seconds, 60)
  local sec = seconds
  return string.format("%02d:%02d", min, sec)
end

function BasketBallWindow:doJudgeTick()
	self.mLeftSecondCount = self.mLeftSecondCount - 1
	if self.mLeftSecondCount < 0 then
		MessageBox:showMessageBox3("失败", handler(self, self.closeWindow))
		self:endGame()
	end
	-- 显示时间
	local timeStr = self:timeFormat(self.mLeftSecondCount)
	self.mRootWidget:getChildByName("Label_LastTime"):setString(timeStr)
	-- 显示分数
	local scoreStr = string.format("%d/%d", self.mGoalCount*5, const_GoalCount*5)
	self.mRootWidget:getChildByName("Panel_TopRight"):getChildByName("Label_LastTime"):setString(scoreStr)
	-- 进度条
	self.mRootWidget:getChildByName("ProgressBar_Score"):setPercent(self.mGoalCount*100/const_GoalCount)
	-- CD
	if self.mCdSecondCount > 0 then
		self.mCdSecondCount = self.mCdSecondCount - 1
		self.mRootWidget:getChildByName("Label_CD"):setString(tostring(self.mCdSecondCount))
	end
	if self.mCdSecondCount <= 0 then
		self:stopCoolDown()
	end
end

function BasketBallWindow:addScore()
	self.mGoalCount = self.mGoalCount + 1
	if self.mGoalCount >= const_GoalCount then
		MessageBox:showMessageBox3("胜利", handler(self, self.closeWindow))
		self:endGame()
	end
	-- 显示分数
	local scoreStr = string.format("%d/%d", self.mGoalCount*5, const_GoalCount*5)
	self.mRootWidget:getChildByName("Panel_TopRight"):getChildByName("Label_LastTime"):setString(scoreStr)
	-- 进度条
	self.mRootWidget:getChildByName("ProgressBar_Score"):setPercent(self.mGoalCount*100/const_GoalCount)
end

function BasketBallWindow:endGame()
	if self.mJudgeSchedulerEntry then
		local scheduler = cc.Director:getInstance():getScheduler()
		scheduler:unscheduleScriptEntry(self.mJudgeSchedulerEntry)
		self.mJudgeSchedulerEntry = nil

		-- 重置时间
		self.mLeftSecondCount = const_LeftSecondCount
		-- 重置分数
		self.mGoalCount = 0

	end
end

function BasketBallWindow:onSpineCallBack(event)
	if event.type == "end" and event.animation == "bindAttack2" then
		self.mPlayerAnim:setAnimation(0, "bindStand2", true)
--		self.mSpineBall:setVisible(true)
	end
end

function BasketBallWindow:closeWindow()
	EventSystem:PushEvent(Event.GUISYSTEM_HIDE_BASKETBALLWINDOW)
end

-- SpineCallBack
function BasketBallWindow:onSpineFrameCallBack(event)
	if 1 == tonumber(event.eventData.name) then
		self:doRealShoot()
--		self.mSpineBall:setVisible(false)
	end
end

-- 发射真实的球
function BasketBallWindow:doRealShoot()
	local startPos = self.mRootWidget:getChildByName("Panel_HeroWalkArea"):getWorldPosition()
	local animPos = cc.p(self.mPlayerAnim:getPosition())
	
	startPos.x = startPos.x + animPos.x -- 水平人的位移
	startPos.y = startPos.y + 50 -- 人的高度

	local endPos = cc.p(startPos.x + 600, startPos.y)
	local contronlBtn1 = cc.p(startPos.x + 50, startPos.y + 300)
	local contronlBtn2 = cc.p(endPos.x - 50, endPos.y + 300)

	self.mBallWidget = GUIWidgetPool:createWidget("NewDate_GameBasketBall_Ball")
	self.mRootWidget:getChildByName("Panel_BallWay"):addChild(self.mBallWidget)
	self.mBallWidget:setPosition(startPos)

	local function onActEnd()
		self.mBallWidget:removeFromParent(true)
		self:stopResultTick()
	end

	local bezier = {contronlBtn1, contronlBtn2, endPos}
	local act0 = cc.EaseInOut:create(cc.BezierTo:create(1.3, bezier), 0.65)
	local act1 = cc.CallFunc:create(onActEnd)

	self.mBallWidget:runAction(cc.Sequence:create(act0, act1))
	
	self:startCoolDown()

	-- 球旋转
	local act2 = cc.RepeatForever:create(cc.RotateBy:create(1, -360))
	self.mBallWidget:getChildByName("Image_Ball"):runAction(act2)

	if not self.mResultSchedulerEntry then
		local scheduler = cc.Director:getInstance():getScheduler()
		self.mResultSchedulerEntry = scheduler:scheduleScriptFunc(handler(self, self.resultTick), 0, false)
	end
end

-- 开始CD
function BasketBallWindow:startCoolDown()
	self.mCdSecondCount = const_CoolDownCount
	self.mRootWidget:getChildByName("Button_Direction"):setTouchEnabled(false)
	self.mRootWidget:getChildByName("Label_CD"):setVisible(true)
	self.mSpineBall:setVisible(false)
end

-- 结束计时
function BasketBallWindow:stopCoolDown()
	self.mCdSecondCount = 0
	self.mRootWidget:getChildByName("Button_Direction"):setTouchEnabled(true)
	self.mRootWidget:getChildByName("Label_CD"):setVisible(false)
	self.mSpineBall:setVisible(true)
end

-- 发射
function BasketBallWindow:doShoot()
	self.mPlayerAnim:setAnimation(0, "bindAttack2", false)
	self.mRootWidget:getChildByName("Button_Direction"):setTouchEnabled(false)
end

-- 结果检测
function BasketBallWindow:resultTick()
	local ballPos = self.mBallWidget:getWorldPosition()
	local ballSize = self.mBallWidget:getContentSize()
	local ballRect = cc.rect(ballPos.x - ballSize.width/2, ballPos.y - ballSize.height/2, ballSize.width, ballSize.height)

	for i = 1, 5 do -- 5个区域检测
		local basketWidget = self.mBasketWidget:getChildByName("Panel_Contact_"..tostring(i))
		local basketPos = basketWidget:getWorldPosition()
		local basketSize = basketWidget:getContentSize()
		local basketRect = cc.rect(basketPos.x, basketPos.y, basketSize.width, basketSize.height)

		print("ballRect:", ballRect.x, ballRect.y, ballRect.width, ballRect.height)

		print("basketRect:", basketRect.x, basketRect.y, basketRect.width, basketRect.height)

		if cc.rectIntersectsRect(ballRect, basketRect ) then
			if 1 == i then -- 红色
				self.mResultBall = CommonAnimation.createCacheSpine_commonByResID(1200, self.mRootWidget:getChildByName("Panel_BallWay"))
			elseif 2 == i then -- 黄色
				self.mResultBall = CommonAnimation.createCacheSpine_commonByResID(1201, self.mRootWidget:getChildByName("Panel_BallWay"))
				-- 得分
				self:addScore()
			elseif 3 == i then -- 绿色
				self.mResultBall = CommonAnimation.createCacheSpine_commonByResID(1202, self.mRootWidget:getChildByName("Panel_BallWay"))
			elseif 4 == i then -- 蓝色
				self.mResultBall = CommonAnimation.createCacheSpine_commonByResID(1203, self.mRootWidget:getChildByName("Panel_BallWay"))
			elseif 5 == i then -- 紫色
				self.mResultBall = CommonAnimation.createCacheSpine_commonByResID(1204, self.mRootWidget:getChildByName("Panel_BallWay"))
			end

			-- 设置位置
			self.mResultBall:setPosition(ballPos)

			local function onAnimEvent(event)
				if event.type == "end" then
					self.mResultBall:removeFromParent(true)
					self.mResultBall = nil
				end
			end

			-- 播放动画
			self.mResultBall:registerSpineEventHandler(onAnimEvent, 1)
			self.mResultBall:setAnimation(0, "shoot", false)

			-- 篮筐动
			self.mSpineBasket:setAnimation(0, "basket", false)

			-- 删除球
			self.mBallWidget:stopAllActions()
			self.mBallWidget:removeFromParent(true)
			self.mBallWidget = nil

			self:stopResultTick()

			return
		end
	end
end

-- 停止结果检测
function BasketBallWindow:stopResultTick()
	if self.mResultSchedulerEntry then
		local scheduler = cc.Director:getInstance():getScheduler()
		scheduler:unscheduleScriptEntry(self.mResultSchedulerEntry)
		self.mResultSchedulerEntry = nil
	end
end

-- 初始化触控板
function BasketBallWindow:initTouchPad()
	local function onTouch(widget, eventType)

		local bornPos = widget:getWorldPosition()
		local midPosX = bornPos.x

		if eventType == ccui.TouchEventType.began then
        	local touchPos = widget:getTouchBeganPosition()
        	if touchPos.x < midPosX then
        		self:toDirection("left")
        		widget:loadTexture("date_ball_direction_left.png")
        	elseif touchPos.x > midPosX then
        		self:toDirection("right")
        		widget:loadTexture("date_ball_direction_right.png")
        	end
        	print("touchPos.x:", touchPos.x)
     	elseif eventType == ccui.TouchEventType.ended then
        	self:toDirection("null")
        	widget:loadTexture("date_ball_direction_btn.png")
      	elseif eventType == ccui.TouchEventType.moved then
        	local touchPos = widget:getTouchMovePosition()
        	if touchPos.x < midPosX then
        		self:toDirection("left")
        		widget:loadTexture("date_ball_direction_left.png")
        	elseif touchPos.x > midPosX then
        		self:toDirection("right")
        		widget:loadTexture("date_ball_direction_right.png")
        	end
        	print("touchPos.x:", touchPos.x)
      	elseif eventType == ccui.TouchEventType.canceled then
        	self:toDirection("null")
        	widget:loadTexture("date_ball_direction_btn.png")
      	end
	end
	self.mRootWidget:getChildByName("Image_Direction"):addTouchEventListener(onTouch)
end


local speed = 9
function BasketBallWindow:animMovingTick()
	local contentSize = self.mRootWidget:getChildByName("Panel_HeroWalkArea"):getContentSize()
	local curPosX = self.mPlayerAnim:getPositionX()

	if "left" == self.mMovingDir then -- 向左移动 
		if curPosX > 0 then
			local newX = curPosX - speed
			if newX <= 0 then
				newX = 0
			end
			self.mPlayerAnim:setPositionX(newX)
			if "bindRun2" ~= self.mPlayerAnim:getCurrentAniName() then
				self.mPlayerAnim:setAnimation(0, "bindRun2", true)
			end
			self.mPlayerAnim:setScaleX(-const_ScaleValue)
		end
	elseif "right" == self.mMovingDir then -- 向右移动 
		if curPosX < contentSize.width then
			local newX = curPosX + speed
			if newX >= contentSize.width then
				newX = contentSize.width
			end
			self.mPlayerAnim:setPositionX(newX)
			if "bindRun2" ~= self.mPlayerAnim:getCurrentAniName() then
				self.mPlayerAnim:setAnimation(0, "bindRun2", true)
			end
			self.mPlayerAnim:setScaleX(const_ScaleValue)
		end
	end
end

function BasketBallWindow:toDirection(dir)
	if not self.mSchedulerEntry then
		local scheduler = cc.Director:getInstance():getScheduler()
		self.mSchedulerEntry = scheduler:scheduleScriptFunc(handler(self, self.animMovingTick), 0, false)
	end

	if "left" == dir then
		self.mMovingDir = "left"
	elseif "right" == dir then
		self.mMovingDir = "right"
	elseif "null" == dir then
		if self.mSchedulerEntry then
			local scheduler = cc.Director:getInstance():getScheduler()
			scheduler:unscheduleScriptEntry(self.mSchedulerEntry)
			self.mSchedulerEntry = nil
			if "bindStand2" ~= self.mPlayerAnim:getCurrentAniName() then
				self.mPlayerAnim:setAnimation(0, "bindStand2", true)
				self.mPlayerAnim:setScaleX(const_ScaleValue)
			end
		end
	end
end

function BasketBallWindow:Destroy()

	-- 先删除球
	self.mSpineBall:removeFromParent(true)
	self.mSpineBall = nil
	
	FightSystem.mShowSceneManager:UnloadSceneView()

	SpineDataCacheManager:collectFightSpineByAtlas(self.mPlayerAnim)

	local scheduler = cc.Director:getInstance():getScheduler()

	if self.mSchedulerEntry then
		scheduler:unscheduleScriptEntry(self.mSchedulerEntry)
		self.mSchedulerEntry = nil
	end

	if self.mResultSchedulerEntry then
		scheduler:unscheduleScriptEntry(self.mResultSchedulerEntry)
		self.mResultSchedulerEntry = nil
	end

	if self.mSpineSchedulerEntry then
		scheduler:unscheduleScriptEntry(self.mSpineSchedulerEntry)
		self.mSpineSchedulerEntry = nil
	end

	if self.mJudgeSchedulerEntry then
		scheduler:unscheduleScriptEntry(self.mJudgeSchedulerEntry)
		self.mJudgeSchedulerEntry = nil
	end


	self.mRootNode:removeFromParent(true)
	self.mRootNode 		= 	nil
	self.mRootWidget 	= 	nil

end

function BasketBallWindow:onEventHandler(event)
	if event.mAction == Event.WINDOW_SHOW then
		self:Load(event)
	elseif event.mAction == Event.WINDOW_HIDE then
		self:Destroy()
	end
end

return BasketBallWindow
