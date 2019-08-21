-- Name: 	RoundGameWindow.lua
-- Func：	回合制
-- Author:	WangShengdong
-- Data:	15-9-21

local maxHpValue = 15 		-- 最大血量值
local maxMpValue = 4 		-- 最大怒气值
local perRoundTime	=	5	-- 每回合最大秒数
local perSkillTime	=	5 	-- 大招流程最大秒数

local pugong_AnimName 		= 	"skill2"
local xuqi_AnimName			=	"bindStand2"
local gedang_AnimName		=	"blockStart"
local dazhao_AnimName		=	"skill1"
local shoushang_AnimName	=	"injured1"

local heroObject = {}

function heroObject:new(heroId)
	local o = 
	{
		mRootNode	=	nil,	-- 跟节点
		mHeroId		=	heroId,	-- 英雄Id
		mHeroAnim	=	nil,	-- 英雄Spine
		mHpValue	=	maxHpValue,		-- 血量值
		mMpValue	=	0,		-- 怒气值
		mSkillList  = 	{},		-- 技能池
		mHpState	=	nil,	-- true:加血 false:减血
		mMpState 	=	nil,	-- true:加蓝 false:减蓝
	}
	o = newObject(o, heroObject)
	return o
end

-- 加载Spine
function heroObject:loadSpine(parentNode, scaleValue)
	self.mHeroAnim = SpineDataCacheManager:getFullSpineByHeroID(self.mHeroId, parentNode)
	self.mHeroAnim:setScaleX(scaleValue)
	self.mHeroAnim:registerSpineEventHandler(handler(self, self.onSpineCallBack), 1)
	self.mHeroAnim:setAnimation(0, "stand", true)
end

-- 回调
function heroObject:onSpineCallBack(event)
	-- cclog(string.format("[spine] %d end: %s", 
 --                          event.trackIndex,
 --                          event.animation))
	
	if gedang_AnimName == event.animation then
		local function onAnimEnd()
			self.mHeroAnim:setAnimation(0, "blockEnd", false)
		end
		nextTick_frameCount(onAnimEnd, 3)
	else
		self.mHeroAnim:setAnimation(0, "stand2", true)
	end
end

-- 销毁
function heroObject:destroy()
	SpineDataCacheManager:collectFightSpineByAtlas(self.mHeroAnim)
end

-- 随机技能
function heroObject:randomSkillList()
	self.mSkillList = {}
	for i = 1, 6 do
		self.mSkillList[i] = math.random(1, 3)
	end
end

-- 设置技能
function heroObject:setSkillList(skillPos, skillType)
	self.mSkillList[skillPos] = skillType
end

-- 血变化
function heroObject:setNewHp(delta)
	self.mHpValue = self.mHpValue + delta
	if delta >= 0 then
		self.mHpState = true
	else
		self.mHpState = false
	end
end

-- 蓝变化
function heroObject:setNewMp(delta)
	self.mMpValue = self.mMpValue + delta
	if delta >= 0 then
		self.mMpState = true
	else
		self.mMpState = false
	end
end

-- 检测扣血
function heroObject:checkHpChange()
	if not self.mHpState then
		self:playAnimation(0, "beStunned", false)
	end
end

-- 播放动作
function heroObject:playAnimation(parm1, parm2, parm3)
	self.mHeroAnim:setToSetupPose()
	self.mHeroAnim:setAnimation(parm1, parm2, parm3)
	if "attack1" == parm2 then -- 如果是攻击，就不播放受伤动作
		self.mHpState = true
	end
end


local RoundGameWindow = 
{
	mName				=	"RoundGameWindow",
	mRootNode			=	nil,
	mRootWidget			=	nil,
	mSelfHero			=	nil,	-- 自身英雄对象
	mEnemyHero			=	nil,	-- 敌方英雄对象
	mRoundCount			=	nil,	-- 当前回合数
	mEnemySkillWidget	=	nil,	-- 敌方技能
	mSelfSkillWidget	=	nil,	-- 友方技能
	mCircleAnimNode		=	nil,	-- 光圈特效
	mCurSkillIndex		=	nil,	-- 当前设置的技能序列
	mCurBattleIndex		=	nil,	-- 对战中的技能序列
	---------------------------------------------------
	mSelfProBarWidget	=	nil,	-- 己方血条控件
	mEnemyProBarWidget	=	nil,	-- 敌方血条控件
	---------------------------------------------------
	mTimerSchedulerEntry 	= 	nil, 	-- 定时器
	mLeftSecond				=	nil,	-- 剩余秒数
	---------------------------------------------------
	mLeftSkillLabel			=	nil,	-- 左技能提示标签
	mRightSkillLabel 		=	nil,	-- 右技能提示标签
}

function RoundGameWindow:Release()

end

function RoundGameWindow:Load(event)
	cclog("=====RoundGameWindow:Load=====begin")

	ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("res/animation/CircleBlink.ExportJson")

	-- TextureSystem:loadPlist_iconherokof()

	self.mRootNode = cc.Node:create()
	GUISystem:GetRootNode():addChild(self.mRootNode)

	FightSystem.mShowSceneManager:LoadSceneView(1, self.mRootNode, 2)

	self:InitLayout()

	-- 游戏开始
	self:gameStart(event)	

	cclog("=====RoundGameWindow:Load=====end")
end

-- 游戏开始
function RoundGameWindow:gameStart(event)
	-- 初始化两方队伍
	self:initTwoTeam(event.mData)

	-- 显示血量怒气
	self:updateHeroData()

	-- 回合数置为0
	self.mRoundCount = 0

	-- 回合开始
	self:roundBegin()

	-- 开启定时器
	local scheduler = cc.Director:getInstance():getScheduler()
	self.mTimerSchedulerEntry = scheduler:scheduleScriptFunc(handler(self, self.timerTick), 1, false)
	self.mLeftSecond = 180
end

-- 清理技能标签
function RoundGameWindow:cleanSkillLabelWidget()
	-- 删除技能
	if self.mLeftSkillLabel then
		self.mLeftSkillLabel:removeFromParent(true)
		self.mLeftSkillLabel = nil
	end
	-- 删除技能
	if self.mRightSkillLabel then
		self.mRightSkillLabel:removeFromParent(true)
		self.mRightSkillLabel = nil
	end
end

-- 添加技能标签
function RoundGameWindow:addSkillLabelWidget(skillDirection, skillType)
	local _resDB = DB_ResourceList.getDataById(1206)

	if "left" == skillDirection then
	self.mRightSkillLabel = CommonAnimation.createSpine_common(_resDB.Res_path2, _resDB.Res_path1)
	self.mRootWidget:getChildByName("Panel_Left"):getChildByName("Panel_Skill_Spine"):addChild(self.mRightSkillLabel)
	self.mRightSkillLabel:setAnimation(0, skillType, false)
	elseif "right" == skillDirection then
		self.mRightSkillLabel = CommonAnimation.createSpine_common(_resDB.Res_path2, _resDB.Res_path1)
		self.mRootWidget:getChildByName("Panel_Right"):getChildByName("Panel_Skill_Spine"):addChild(self.mRightSkillLabel)
		self.mRightSkillLabel:setAnimation(0, skillType, false)
	end
end

-- 游戏结束
function RoundGameWindow:gameOver()
	local scheduler = cc.Director:getInstance():getScheduler()
	scheduler:unscheduleScriptEntry(self.mTimerSchedulerEntry)
	self.mTimerSchedulerEntry 	= 	nil 	-- 定时器
end

-- 定时器
function RoundGameWindow:timerTick()
	self.mLeftSecond = self.mLeftSecond - 1
	if self.mLeftSecond <=0 then
		self.mLeftSecond =0
	end
	self.mRootWidget:getChildByName("Label_RemainingTime"):setString(string.format("%03d", self.mLeftSecond))
end

-- 回合开始
function RoundGameWindow:roundBegin()
	self.mRoundCount = self.mRoundCount + 1

	-- 清理
	if self.mSelfSkillWidget then
		self.mSelfSkillWidget:removeFromParent(true)
		self.mSelfSkillWidget = nil
	end

	-- 清理
	if self.mEnemySkillWidget then
		self.mEnemySkillWidget:removeFromParent(true)
		self.mEnemySkillWidget = nil
	end

	-- 随机敌方技能
	self:randomEnemySkillList()
end

-- 选择己方技能
function RoundGameWindow:selectSelfSkillList()
	-- 显示
	self.mRootWidget:getChildByName("Panel_Skill_Bottom"):setVisible(true)

	-- 创建
	if not self.mSelfSkillWidget then
		self.mSelfSkillWidget = GUIWidgetPool:createWidget("NewDate_GameRoundSkillList")
		-- 控制标签是否显示
		self.mSelfSkillWidget:getChildByName("Image_Notice_Enemy"):setVisible(false)
		self.mSelfSkillWidget:getChildByName("Image_Notice_Self"):setVisible(true)

		local curPos = self.mRootWidget:getChildByName("Panel_SkillList_Middle"):getWorldPosition()
		self.mRootWidget:addChild(self.mSelfSkillWidget, 100)
		self.mSelfSkillWidget:setPosition(curPos)

		-- 创建技能控件
		for i = 1, 6 do
			local skillCellWgt = GUIWidgetPool:createWidget("NewDate_GameRoundSkillCell")
			self.mSelfSkillWidget:getChildByName("Panel_Skill_"..tostring(i)):addChild(skillCellWgt)
			skillCellWgt:getChildByName("Image_Bg"):setLocalZOrder(1)
			skillCellWgt:getChildByName("Image_Bg"):setVisible(true)
			skillCellWgt:getChildByName("Image_Skill"):setLocalZOrder(5)
			skillCellWgt:getChildByName("Image_Skill"):setVisible(false)
			skillCellWgt:setTag(1990)
		end
	end

	-- 创建动画
	local function addCircleAnim()
		if self.mCircleAnimNode then
			self.mCircleAnimNode:removeFromParent(true)
			self.mCircleAnimNode = nil
		end
		if not self.mCircleAnimNode then -- 创建动画
			local containerWidget = self.mSelfSkillWidget:getChildByName("Panel_Skill_"..tostring(self.mCurSkillIndex))
			self.mCircleAnimNode = cc.Sprite:create("date_round_skillchosen_bg.png")
			local sz = containerWidget:getContentSize()
			containerWidget:addChild(self.mCircleAnimNode)
			self.mCircleAnimNode:setPosition(cc.p(sz.width/2, sz.height/2))
		end
	end
	addCircleAnim()

	-- 选中技能
	local function setSkillSelected(widget)
		self.mSelfHero:setSkillList(self.mCurSkillIndex, widget:getTag())

		-- 显示技能
		local skillWidget = self.mSelfSkillWidget:getChildByName("Panel_Skill_"..tostring(self.mCurSkillIndex)):getChildByTag(1990)
		if 1 == widget:getTag() then
			skillWidget:getChildByName("Image_Skill"):loadTexture("date_round_skill_hold.png")
		elseif 2 == widget:getTag() then
			skillWidget:getChildByName("Image_Skill"):loadTexture("date_round_skill_block.png")
		elseif 3 == widget:getTag() then
			skillWidget:getChildByName("Image_Skill"):loadTexture("date_round_skill_attack.png")
		end
		skillWidget:getChildByName("Image_Skill"):setVisible(true)

		self.mCurSkillIndex = self.mCurSkillIndex + 1

		if 7 ~= self.mCurSkillIndex then
			-- 添加下一个技能
			self:selectSelfSkillList()
		else
			-- 隐藏
			self.mRootWidget:getChildByName("Panel_Skill_Bottom"):setVisible(false)

			-- 删除动画
			if self.mCircleAnimNode then
				self.mCircleAnimNode:removeFromParent(true)
				self.mCircleAnimNode = nil
			end
			-- 做运动
			local tarPos = self.mRootWidget:getChildByName("Panel_SkillList_TopLeft"):getWorldPosition()
			local act1 = cc.MoveTo:create(0.5, tarPos)
			local act2 = cc.ScaleTo:create(0.5, 0.5)
			local function onActEnd()
				-- 计算结果
				self:showBattleResult()
			end
			local act3 = cc.CallFunc:create(onActEnd)
			self.mSelfSkillWidget:runAction(cc.Sequence:create(act0, cc.Spawn:create(act1, act2), act3))
			-- 控制标签是否显示
			self.mSelfSkillWidget:getChildByName("Image_Notice_Enemy"):setVisible(false)
			self.mSelfSkillWidget:getChildByName("Image_Notice_Self"):setVisible(false)
		end
	end

	-- 添加技能响应
	local function addButtonFunc()
		local btn = nil

		btn = self.mRootWidget:getChildByName("Button_Skill_Hold")
		btn:setTag(1)
		registerWidgetReleaseUpEvent(btn, setSkillSelected)

		btn = self.mRootWidget:getChildByName("Button_Skill_Block")
		btn:setTag(2)
		registerWidgetReleaseUpEvent(btn, setSkillSelected)

		btn = self.mRootWidget:getChildByName("Button_Skill_Attack")
		btn:setTag(3)
		registerWidgetReleaseUpEvent(btn, setSkillSelected)
	end
	addButtonFunc()
end

-- 显示战斗实时结果
function RoundGameWindow:showBattleResult()
	-- 应该设置的技能置为1
	self.mCurSkillIndex = 1
	-- 从第一个技能开始比对
	self.mCurBattleIndex = 1

	local function exePreFunc() -- 回合开始前

		local actManager = cc.Director:getInstance():getActionManager()

		local function afterSkillFunc() -- 释放完大招后
			if self.mRootNode then -- 如果窗口还存在
				actManager:resumeTarget(self.mRootWidget) -- 恢复
				-- 更新显示英雄数据
				self:updateHeroData()
			end
		end

		if self:checkSkill() then -- 触发大招
			
			actManager:pauseTarget(self.mRootWidget) -- 暂停

			-- 动画逻辑
			if 4 == self.mSelfHero.mMpValue and 4 == self.mEnemyHero.mMpValue then
				self.mSelfHero:playAnimation(0, dazhao_AnimName, false)
				self.mEnemyHero:playAnimation(0, dazhao_AnimName, false)
			elseif 4 == self.mSelfHero.mMpValue then
				self.mSelfHero:playAnimation(0, dazhao_AnimName, false)
				-- 延迟两秒播放受伤
				local function doInjure()
					if self.mRootNode then -- 如果窗口还存在
						self.mEnemyHero:playAnimation(0, shoushang_AnimName, true)
					end
				end
				nextTick_frameCount(doInjure, 3)
			elseif 4 == self.mEnemyHero.mMpValue then
				-- 延迟两秒播放受伤
				local function doInjure()
					if self.mRootNode then -- 如果窗口还存在
						self.mSelfHero:playAnimation(0, shoushang_AnimName, true)
					end
				end
				nextTick_frameCount(doInjure, 3)
				self.mEnemyHero:playAnimation(0, dazhao_AnimName, false)
			end

			-- 释放大招
			if 4 == self.mSelfHero.mMpValue then
				-- 怒气清零
				self.mSelfHero.mMpValue = 0
				-- 敌方扣血
				self.mEnemyHero.mHpValue = self.mEnemyHero.mHpValue - 4
				print("己方释放大招!")
			end

			if 4 == self.mEnemyHero.mMpValue then
				-- 怒气清零
				self.mEnemyHero.mMpValue = 0
				-- 敌方扣血
				self.mSelfHero.mHpValue = self.mSelfHero.mHpValue - 4
				print("敌方释放大招!")
			end
			nextTick_frameCount(afterSkillFunc, perSkillTime)
			return 
		end

		self.mEnemyHero:playAnimation(0, "stand2", true)
		self.mSelfHero:playAnimation(0, "stand2", true)
	end

	local act0 = cc.CallFunc:create(exePreFunc)

	local act1 = cc.DelayTime:create(1)

	
	local function exeFunc() -- 执行函数
		-- 计算结果
		self:doRealBattle()
		-- 更新显示英雄数据
		self:updateHeroData()
		-- 加1
		self.mCurBattleIndex = self.mCurBattleIndex + 1
	end
	local act3 = cc.CallFunc:create(exeFunc)

	local act4 = cc.DelayTime:create(perRoundTime)

	local function onRoundEnd()
		self:roundBegin()
	end
	self.mRootWidget:runAction(cc.Sequence:create(cc.Repeat:create(cc.Sequence:create(act0, act1, act2, act3, act4), 6), cc.CallFunc:create(onRoundEnd)))
end

-- 检测大招
function RoundGameWindow:checkSkill()
	if 4 == self.mSelfHero.mMpValue or 4 == self.mEnemyHero.mMpValue then
		return true
	else
		return false
	end
end

-- 计算战斗结果
function RoundGameWindow:doRealBattle()
		-- 清除上一次的技能标签
		self:cleanSkillLabelWidget()

		-- 当前技能高亮
		self.mEnemySkillWidget:getChildByName("Panel_Skill_"..tostring(self.mCurBattleIndex)):getChildByTag(1990):getChildByName("Image_Bg"):loadTexture("date_round_skillchosen_bg.png")
		self.mSelfSkillWidget:getChildByName("Panel_Skill_"..tostring(self.mCurBattleIndex)):getChildByTag(1990):getChildByName("Image_Bg"):loadTexture("date_round_skillchosen_bg.png")

		-- 前一次的灰掉
		if self.mCurBattleIndex > 1 then
			self.mEnemySkillWidget:getChildByName("Panel_Skill_"..tostring(self.mCurBattleIndex-1)):getChildByTag(1990):getChildByName("Image_Bg"):loadTexture("date_round_skill_bg.png")
			self.mSelfSkillWidget:getChildByName("Panel_Skill_"..tostring(self.mCurBattleIndex-1)):getChildByTag(1990):getChildByName("Image_Bg"):loadTexture("date_round_skill_bg.png")
		end

		local selfSkill = self.mSelfHero.mSkillList[self.mCurBattleIndex]
		local enemySkill = self.mEnemyHero.mSkillList[self.mCurBattleIndex]
		local result = DB_DateRound.getDataById(selfSkill)

		-- 状态改变逻辑
		if 1 == enemySkill then
			self.mSelfHero:setNewHp(result.Enemy_Skill1_SelfBlood)
			self.mSelfHero:setNewMp(result.Enemy_Skill1_SelfEnergy)
			self.mEnemyHero:setNewHp(result.Enemy_Skill1_EnemyBlood)
			self.mEnemyHero:setNewMp(result.Enemy_Skill1_EnemyEnergy)
		elseif 2 == enemySkill then
			self.mSelfHero:setNewHp(result.Enemy_Skill2_SelfBlood)
			self.mSelfHero:setNewMp(result.Enemy_Skill2_SelfEnergy)
			self.mEnemyHero:setNewHp(result.Enemy_Skill2_EnemyBlood)
			self.mEnemyHero:setNewMp(result.Enemy_Skill2_EnemyEnergy)
		elseif 3 == enemySkill then
			self.mSelfHero:setNewHp(result.Enemy_Skill3_SelfBlood)
			self.mSelfHero:setNewMp(result.Enemy_Skill3_SelfEnergy)
			self.mEnemyHero:setNewHp(result.Enemy_Skill3_EnemyBlood)
			self.mEnemyHero:setNewMp(result.Enemy_Skill3_EnemyEnergy)
		end

		print("======================================================================")
		print("本回合序列:", self.mCurBattleIndex)
		print("本回合己方技能:", selfSkill)
		print("本回合敌方技能:", enemySkill)
	--	print("己方血量变化:", result.Enemy_Skill1_SelfBlood)
		print("己方剩余血量:", self.mSelfHero.mHpValue)
	--	print("己方怒气变化:", result.Enemy_Skill1_SelfEnergy)
	--	print("敌方血量变化:", result.Enemy_Skill1_EnemyBlood)
		print("敌方剩余血量:", self.mEnemyHero.mHpValue)
	--	print("敌方怒气变化:", result.Enemy_Skill1_EnemyEnergy)
		print("======================================================================")

		-- 判断己方血量
		if self.mSelfHero.mHpValue > maxHpValue then
			self.mSelfHero.mHpValue = maxHpValue
		elseif self.mSelfHero.mHpValue <= 0 then
			doError("you lose!")
		end

		-- 判断敌方血量
		if self.mEnemyHero.mHpValue > maxHpValue then
			self.mEnemyHero.mHpValue = maxHpValue
		elseif self.mEnemyHero.mHpValue <= 0 then
			doError("you win!")
		end

		-- 判断己方怒气
		if self.mSelfHero.mMpValue > maxMpValue then
			self.mSelfHero.mHpValue = maxMpValue
		elseif self.mSelfHero.mHpValue <= 0 then
			self.mSelfHero.mHpValue = 0
		end

		-- 判断敌方怒气
		if self.mEnemyHero.mMpValue > maxMpValue then
			self.mEnemyHero.mMpValue = maxMpValue
		elseif self.mEnemyHero.mMpValue <= 0 then
			self.mEnemyHero.mMpValue = 0
		end

		-- 播放人物动作
		if 1 == selfSkill then
			self.mSelfHero:playAnimation(0, xuqi_AnimName, false)
			self:addSkillLabelWidget("left", "hold1")
		elseif 2 == selfSkill then
			self.mSelfHero:playAnimation(0, gedang_AnimName, false)
			self:addSkillLabelWidget("left", "block1")
		elseif 3 == selfSkill then
			self.mSelfHero:playAnimation(0, pugong_AnimName, false)
			self:addSkillLabelWidget("left", "attack1")
		end

		-- 播放人物动作
		if 1 == enemySkill then
			self.mEnemyHero:playAnimation(0, xuqi_AnimName, false)
			self:addSkillLabelWidget("right", "hold2")
		elseif 2 == enemySkill then
			self.mEnemyHero:playAnimation(0, gedang_AnimName, false)
			self:addSkillLabelWidget("right", "block2")
		elseif 3 == enemySkill then
			self.mEnemyHero:playAnimation(0, pugong_AnimName, false)
			self:addSkillLabelWidget("right", "attack2")
		end

		-- 一秒钟以后检测掉血
		local function checkHpChange()
			self.mSelfHero:checkHpChange()
			self.mEnemyHero:checkHpChange()
		end
		local act0 = cc.DelayTime:create(1)
		local act1 = cc.CallFunc:create(checkHpChange)
		self.mEnemySkillWidget:runAction(cc.Sequence:create(act0, act1))
end

function RoundGameWindow:randomEnemySkillList()
	-- 随机敌方技能
	self.mEnemyHero:randomSkillList()

	-- 隐藏
	self.mRootWidget:getChildByName("Panel_Skill_Bottom"):setVisible(false)

	-- 创建技能控件
	self.mEnemySkillWidget = GUIWidgetPool:createWidget("NewDate_GameRoundSkillList")

	-- 设置标签是否显示
	self.mEnemySkillWidget:getChildByName("Image_Notice_Enemy"):setVisible(true)
	self.mEnemySkillWidget:getChildByName("Image_Notice_Self"):setVisible(false)

	for i = 1, #self.mEnemyHero.mSkillList do
		local skillCellWgt = GUIWidgetPool:createWidget("NewDate_GameRoundSkillCell")
		self.mEnemySkillWidget:getChildByName("Panel_Skill_"..tostring(i)):addChild(skillCellWgt)
		if 1 == self.mEnemyHero.mSkillList[i] then
			skillCellWgt:getChildByName("Image_Skill"):loadTexture("date_round_skill_hold.png")
		elseif 2 == self.mEnemyHero.mSkillList[i] then
			skillCellWgt:getChildByName("Image_Skill"):loadTexture("date_round_skill_block.png")
		elseif 3 == self.mEnemyHero.mSkillList[i] then
			skillCellWgt:getChildByName("Image_Skill"):loadTexture("date_round_skill_attack.png")
		end
		skillCellWgt:getChildByName("Image_Bg"):setLocalZOrder(5)
		skillCellWgt:getChildByName("Image_Skill"):setLocalZOrder(1)
		skillCellWgt:setTag(1990)
	end
	local curPos = self.mRootWidget:getChildByName("Panel_SkillList_Middle"):getWorldPosition()
	self.mRootWidget:addChild(self.mEnemySkillWidget, 100)
	self.mEnemySkillWidget:setPosition(curPos)


	local pos0 = nil
	local pos1 = nil
	local function onTouchSkillPanel(widget, eventType)
		if eventType == ccui.TouchEventType.began then
			pos0 = widget:getTouchBeganPosition()
	    elseif eventType == ccui.TouchEventType.ended then
	    	pos1 = widget:getTouchEndPosition()
	    	if pos1.x > pos0.x then
	    		self.mEnemySkillWidget:setTouchEnabled(false)
	    		self:random3SkillForShow()
	    	end
	    elseif eventType == ccui.TouchEventType.moved then
	       
	    elseif eventType == ccui.TouchEventType.canceled then
	        
	    end
	end
	self.mEnemySkillWidget:setTouchEnabled(true)
	self.mEnemySkillWidget:addTouchEventListener(onTouchSkillPanel)

end

-- 随机出三张敌方技能牌显示
function RoundGameWindow:random3SkillForShow()

	local retValTbl = {1, 3, 4}
	-- math.randomseed(os.time())

	-- local function isInRetTbl(val)
	-- 	-- 在这里
	-- 	for i = 1, #retValTbl do
	-- 		if val == retValTbl[i] then
	-- 			return true
	-- 		end
	-- 	end
	-- 	-- 不在这里,插入
	-- 	table.insert(retValTbl, val)
	-- 	return false
	-- end

	-- for cnt = 1, 3 do
	-- 	local retVal = math.random(1, 6)
	-- 	while isInRetTbl(retVal)
	-- 	do
	-- 	   retVal = math.random(1, 6)
	-- 	   isInRetTbl(retVal)
	-- 	end
	-- end

	for i = 1, #retValTbl do
		local skillCellWgt = self.mEnemySkillWidget:getChildByName("Panel_Skill_"..tostring(retValTbl[i])):getChildByTag(1990)
		self:turnSkillWidget(skillCellWgt)
	end

	-- 做运动
	local act0 = cc.DelayTime:create(2)
	local tarPos = self.mRootWidget:getChildByName("Panel_SkillList_TopRight"):getWorldPosition()
	local act1 = cc.MoveTo:create(0.5, tarPos)
	local act2 = cc.ScaleTo:create(0.5, 0.5)
	local function onActEnd()
		self.mCurSkillIndex = 1
		self:selectSelfSkillList()
	end
	local act3 = cc.CallFunc:create(onActEnd)
	self.mEnemySkillWidget:runAction(cc.Sequence:create(act0, cc.Spawn:create(act1, act2), act3))
	self.mEnemySkillWidget:getChildByName("Image_Notice_Enemy"):setVisible(false)
	self.mEnemySkillWidget:getChildByName("Image_Notice_Self"):setVisible(false)

end

-- 翻转
function RoundGameWindow:turnSkillWidget(widget)
	local tm = 1
	-- 翻前面
	local function turnFront()
		local function xxx()
			widget:getChildByName("Image_Skill"):setLocalZOrder(5)
		end

		local act0 = cc.OrbitCamera:create(tm, 1, 0, 0, 180, 0, 0)
		local act1 = cc.DelayTime:create(tm/2)
		local act2 = cc.CallFunc:create(xxx)

		widget:getChildByName("Image_Skill"):runAction(cc.Spawn:create(act0, cc.Sequence:create(act1, act2)))
	end
	turnFront()

	-- 翻背面
	local function turnBack()
		local function xxx()
			widget:getChildByName("Image_Bg"):setLocalZOrder(1)
		end

		local act0 = cc.OrbitCamera:create(tm, 1, 0, 0, 180, 0, 0)
		local act1 = cc.DelayTime:create(tm/2)
		local act2 = cc.CallFunc:create(xxx)

		widget:getChildByName("Image_Bg"):runAction(cc.Spawn:create(act0, cc.Sequence:create(act1, act2)))
	end
	turnBack()
end

-- 刷新英雄数据
function RoundGameWindow:updateHeroData()
	-- 友方的
	for i = 1, 4 do
		if i > self.mSelfHero.mMpValue then
			self.mRootWidget:getChildByName("Panel_Left"):getChildByName("Image_Bean_"..tostring(i)):setVisible(false)
		else
			self.mRootWidget:getChildByName("Panel_Left"):getChildByName("Image_Bean_"..tostring(i)):setVisible(true)
		end
	end

	-- 敌方的
	for i = 1, 4 do
		if i > self.mEnemyHero.mMpValue then
			self.mRootWidget:getChildByName("Panel_Right"):getChildByName("Image_Bean_"..tostring(i)):setVisible(false)
		else
			self.mRootWidget:getChildByName("Panel_Right"):getChildByName("Image_Bean_"..tostring(i)):setVisible(true)
		end
	end

	-- 友方的
	self.mSelfProBarWidget:setPercentage(self.mSelfHero.mHpValue / maxHpValue * 100)
	self.mSelfProBarWidget:setColor(getBloodColor(self.mSelfHero.mHpValue / maxHpValue * 100))

	-- 敌方的
	self.mEnemyProBarWidget:setPercentage(self.mEnemyHero.mHpValue / maxHpValue * 100)
	self.mEnemyProBarWidget:setColor(getBloodColor(self.mEnemyHero.mHpValue / maxHpValue * 100))
end

-- 初始化两方队伍头像
function RoundGameWindow:initTwoTeam(enemyHeroId)
	-- 友方
	self.mSelfHero = heroObject:new(globaldata:getHeroInfoByBattleIndex(1, "id"))
	-- 敌方
	self.mEnemyHero = heroObject:new(enemyHeroId)

	-- 加载友方动画
	self.mSelfHero:loadSpine(self.mRootWidget:getChildByName("Panel_HeroSelf"), 1)

	-- 加载敌方动画
	self.mEnemyHero:loadSpine(self.mRootWidget:getChildByName("Panel_HeroEnemy"), 1)

	-- 加载友方头像
	local heroData = DB_HeroConfig.getDataById(globaldata:getHeroInfoByBattleIndex(1, "id"))
	local iconId = heroData.IconID
	local imgName = DB_ResourceList.getDataById(iconId).Res_path1
	self.mRootWidget:getChildByName("Panel_Left"):getChildByName("Image_HeroIcon"):loadTexture(imgName, 1)

	-- 加载敌方头像
	heroData = DB_HeroConfig.getDataById(enemyHeroId)
	iconId = heroData.IconID
	imgName = DB_ResourceList.getDataById(iconId).Res_path1
	self.mRootWidget:getChildByName("Panel_Right"):getChildByName("Image_HeroIcon"):loadTexture(imgName, 1)
end

function RoundGameWindow:InitLayout()

	self.mRootWidget = GUIWidgetPool:createWidget("NewDate_GameRound")
	self.mRootNode:addChild(self.mRootWidget, 2)

	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_Pause"),function()
		Event.GUISYSTEM_SHOW_FIGHTPAUSEWINDOW.mData = WINDOW_FROM.ROUND  
		EventSystem:PushEvent(Event.GUISYSTEM_SHOW_FIGHTPAUSEWINDOW)
	end)

	local function doAdapter()

		-- Panel_Top贴顶
		self.mRootWidget:getChildByName("Panel_Top"):setPositionY(getGoldFightPosition_LU().y - self.mRootWidget:getChildByName("Panel_Top"):getContentSize().height)

		-- Panel_Left贴左
		self.mRootWidget:getChildByName("Panel_Left"):setPositionX(getGoldFightPosition_LU().x)

		-- Panel_Left贴右
		self.mRootWidget:getChildByName("Panel_Right"):setPositionX(getGoldFightPosition_RU().x - self.mRootWidget:getChildByName("Panel_Right"):getContentSize().width)

		-- Panel_Bottom贴低
		self.mRootWidget:getChildByName("Panel_Bottom"):setPositionY(getGoldFightPosition_LD().y)

		-- 进度条
		local function doReScale()
			local leftPos = self.mRootWidget:getChildByName("Panel_Left"):getChildByName("Image_Blood_Bg"):getWorldPosition()
			local midPos = self.mRootWidget:getChildByName("Panel_Pos_Middle"):getWorldPosition()
			local goldDis = midPos.x - leftPos.x

			local srcDis = self.mRootWidget:getChildByName("Panel_Left"):getChildByName("Image_Blood_Bg"):getContentSize().width
			local tarScaleVal = goldDis / srcDis
			-- 左边缩放
			self.mRootWidget:getChildByName("Panel_Left"):getChildByName("Image_Blood_Bg"):setScale(tarScaleVal)

			-- 右边缩放
			self.mRootWidget:getChildByName("Panel_Right"):getChildByName("Image_Blood_Bg"):setScale(tarScaleVal)
		end
		doReScale()
	end
	doAdapter()

	-- 创建己方血条
	local function createSelfProBar()
		local xuetiao = cc.Sprite:create()
		xuetiao:setProperty("Frame", "fight_kof_blood.png")
		local xiedu = 0.029
		self.mSelfProBarWidget = cc.ProgressTimer:create(xuetiao)
		self.mSelfProBarWidget:setType(2)
		self.mSelfProBarWidget:setSlopbarParam(3, xiedu)
		self.mSelfProBarWidget:setMidpoint(cc.p(0,1))
		self.mSelfProBarWidget:setAnchorPoint(cc.p(0.5,0.5))
    	self.mSelfProBarWidget:setBarChangeRate(cc.p(1, 0))
    	self.mRootWidget:getChildByName("Panel_Left"):getChildByName("Image_Blood_Bg"):addChild(self.mSelfProBarWidget)
    	local sz = self.mRootWidget:getChildByName("Panel_Left"):getChildByName("Image_Blood_Bg"):getContentSize()
    	self.mSelfProBarWidget:setPercentage(100)
    	self.mSelfProBarWidget:setColor(getBloodColor(100))

    	self.mSelfProBarWidget:setPosition(cc.p(sz.width/2, sz.height/2))
	end
	createSelfProBar()

	-- 创建敌方血条
	local function createSelfProBar()
		local xuetiao = cc.Sprite:create()
		xuetiao:setProperty("Frame", "fight_kof_blood.png")
		local xiedu = 0.029
		self.mEnemyProBarWidget = cc.ProgressTimer:create(xuetiao)
		self.mEnemyProBarWidget:setType(2)
		self.mEnemyProBarWidget:setSlopbarParam(3, xiedu)
		self.mEnemyProBarWidget:setMidpoint(cc.p(0,1))
		self.mEnemyProBarWidget:setAnchorPoint(cc.p(0.5,0.5))
    	self.mEnemyProBarWidget:setBarChangeRate(cc.p(1, 0))
    	self.mRootWidget:getChildByName("Panel_Right"):getChildByName("Image_Blood_Bg"):addChild(self.mEnemyProBarWidget)
    	local sz = self.mRootWidget:getChildByName("Panel_Right"):getChildByName("Image_Blood_Bg"):getContentSize()
    	self.mEnemyProBarWidget:setPercentage(100)
    	self.mEnemyProBarWidget:setColor(getBloodColor(100))
    	self.mEnemyProBarWidget:setPosition(cc.p(sz.width/2, sz.height/2))
    	self.mEnemyProBarWidget:setScaleX(-1)
	end
	createSelfProBar()
end

function RoundGameWindow:Destroy()

	ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo("res/animation/CircleBlink.ExportJson")

	self.mSelfHero:destroy()

	self.mEnemyHero:destroy()

	-- TextureSystem:unloadPlist_iconherokof()

	FightSystem.mShowSceneManager:UnloadSceneView()

	if self.mTimerSchedulerEntry then
		local scheduler = cc.Director:getInstance():getScheduler()
		scheduler:unscheduleScriptEntry(self.mTimerSchedulerEntry)
		self.mTimerSchedulerEntry 	= 	nil 	-- 定时器
	end

	self.mLeftSecond			=	nil	-- 剩余秒数

	self.mRootNode:removeFromParent(true)
	self.mRootNode 				= 	nil
	self.mRootWidget 			= 	nil
	self.mRoundCount			=	nil
	self.mEnemySkillWidget		=	nil
	self.mSelfSkillWidget		=	nil
	self.mCircleAnimNode		=	nil
	self.mCurSkillIndex			=	nil
	self.mCurBattleIndex		=	nil
	self.mSelfProBarWidget		=	nil
	self.mEnemyProBarWidget		=	nil
	self.mLeftSkillLabel		=	nil
	self.mRightSkillLabel 		=	nil

end

function RoundGameWindow:onEventHandler(event)
	if event.mAction == Event.WINDOW_SHOW then
		self:Load(event)
	elseif event.mAction == Event.WINDOW_HIDE then
		self:Destroy()
	end
end

return RoundGameWindow