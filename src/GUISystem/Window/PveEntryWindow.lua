-- Name: 	PveEntryWindow
-- Func：	章节选择
-- Author:	WangShengdong
-- Data:	14-11-12

local chapterLimitLevelTbl = {1, 1, 1, 1, 1, 1, 1, 1, 1, 1}

local chapterNums = 0	-- 章节数量
local left_margin = 40
local margin = 45
local delayTime = 0.1
local moveTime = 0.15
local deltaX = 7

local processTouchPanel = nil

-- 判断关卡是否完成
local function isChapterFinished(chapterId, chapterLevel)
	-- 判断本章最后一关是否通关
--	if globaldata:isChapterFinished(chapterId, 8, chapterLevel) then
	-- 判断章节是否开启
	if globaldata:isSectionOpened(chapterId, 1, chapterLevel) then
		return true
	else
		return false
	end
end

-- 从数据库中读取信息,GUIWidgetPool中调用
function PveEntryWindow_initData()
	local chapters = DB_MapUIConfigEasy.getArrDataByField("MapUI_SectionID", 0)	-- 取出所有章节
	chapterNums = #chapters
	chapters = {}
end

local PveEntryWindow = 
{
	mName 						= 	"PveEntryWindow",
	mRootNode					=	nil,
	mRootWidget					=	nil,
	mTopRoleInfoPanel			=	nil,	-- 顶部人物信息面板
	-----------------------------------------------------------
	mChapterWindow 				=	nil,	-- 章节窗口
	mSectionWindow 				=	nil, 	-- 关卡窗口
	mSectionWindow_Hard			=	nil,	-- 关卡窗口(精英)
	mSectionDetailWindow 		=	nil, 	-- 关卡详情窗口
	-----------------------------------------------------------
	mRewardPanel_Normal			=	nil,	-- 普通奖励面板
	mRewardPanel_Hard			=	nil,	-- 精英奖励面板
	-----------------------------------------------------------
	mChapterWidgetList 			=	{}, 	-- 章节控件
	mSectionWidgetList 			=	{}, 	-- 关卡控件
	mSectionWidgetList_Hard 	=	{}, 	-- 关卡控件(精英)
	-----------------------------------------------------------
	mLastClickedChapterWidget 	=	nil, 	-- 最后一次选择的章节控件
	mLastClickedSectionWidget 	=	nil, 	-- 最后一次选择的关卡控件
	mLastClickedLevelWidget 	=	nil, 	-- 最后一次选择的难度控件
	-----------------------------------------------------------
	mCurSectionObject			=	nil, 	-- 当前选中的关卡对象
	-----------------------------------------------------------
	mLevel 						=	1, 		-- 难度级别
	-----------------------------------------------------------
	mCurChallCount				=	nil,	-- 当前可以挑战的次数
	mSchedulerHandler			=	nil,	-- 定时器
	mRoleSelWindow				=	nil,	-- 选人界面
	-----------------------------------------------------------
	mRewardAnimList_Normal		=	{},		-- 奖励动画列表(普通)
	mRewardAnimList_Hard		=	{},		-- 奖励动画列表(精英)
	-----------------------------------------------------------
	mCurAnimNode				=	nil,	-- 特效节点
	mCurSectionAnimNode			=	nil,	-- 最新选中关的特效
	mIsMoveing					=	nil,	-- 正在滑动
	mEvent						=	nil,	
}


--------- 记录变量, 窗口关闭后依然记录--------------------
__IsEnterFighting__ = false        -- 本次打开pve副本窗口，是否进入战斗了

function PveEntryWindow:Release()

end

function PveEntryWindow:Load(event)
	cclog("=====PveEntryWindow:Load=====begin")
	self.mIsLoaded = true

	-- 播所属城镇bgm
	HallManager:playHallBGMAfterDestroyed()

	GuideSystem:recoverInterrupt_PVE()

	GUIEventManager:registerEvent("chapterInfoChanged", self, self.onChapterInfoChanged)
	GUIEventManager:registerEvent("itemInfoChanged", self, self.updateDetailInfo)
	GUIEventManager:registerEvent("starRewardGot", self, self.updateStarRewardInfo)

	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_REQUEST_SAODANG_, handler(self,self.onRequestDoSaodang))

	self.mRootNode = cc.Node:create()
	GUISystem:GetRootNode():addChild(self.mRootNode)

	local function preloadTexture()
		TextureSystem:loadPlist_pvesection()
	end
	preloadTexture()
--	self.mIsEnterFighting = false

	-- 初始化布局信息
	self:InitLayout()

	-- 初始化章节
	self:initChapters()

	-- 初始化关卡
	self:initSections()

--	print("当前章节:", globaldata.curChapterId[self.mLevel], "当前关卡:", globaldata.curSectionId[self.mLevel])

	self.mEvent = event

	-- 默认选择章节
	if event.mData then
		if event.mData[2] then
			local sectionInfo = nil
			if 1 == event.mData[1] then
				sectionInfo = DB_MapUIConfigEasy.getDataById(event.mData[2])
			elseif 2 == event.mData[1] then
				sectionInfo = DB_MapUIConfigNormal.getDataById(event.mData[2])
			end
			-- 选章节
			self:onClickedChapter(self.mChapterWidgetList[sectionInfo.MapUI_ChapterID],false)
			-- 选关卡
			if 1 == event.mData[1] then
				self:onClickedSection(self.mSectionWidgetList[sectionInfo.MapUI_SectionID])
			elseif 2 == event.mData[1] then
				self:onClickedSection(self.mSectionWidgetList_Hard[sectionInfo.MapUI_SectionID])
			end
		else
			self:onClickedChapter(self.mChapterWidgetList[globaldata.curChapterId[self.mLevel]],false)
		end
	else
		if globaldata.curChapterId[self.mLevel] >= 8 then
			self.mRootWidget:getChildByName("ScrollView_Chapter"):jumpToBottom()
		end
		self:onClickedChapter(self.mChapterWidgetList[globaldata.curChapterId[self.mLevel]],false)
	end
	
	-- 默认普通难度
	if event.mData then
		if event.mData[1] == 1 then
			self:onLevelSelected(self.mRootWidget:getChildByName("Image_Easy"),false)
		elseif event.mData[1] == 2 then
			self:onLevelSelected(self.mRootWidget:getChildByName("Image_Hard"),false)
		elseif event.mData[1] == 3 then
			self:onLevelSelected(self.mRootWidget:getChildByName("Image_Team"),false)
		end
	else
		if 1 == self.mLevel then
			self:onLevelSelected(self.mRootWidget:getChildByName("Image_Easy"),false)
		elseif 2 == self.mLevel then
			self:onLevelSelected(self.mRootWidget:getChildByName("Image_Hard"),false)
		elseif 3 == self.mLevel then
			self:onLevelSelected(self.mRootWidget:getChildByName("Image_Team"),false)
		end
	end

	-- 更新关卡信息
--	self:updateChapterInfoByLevel(self.mLevel)


	-- local myNode = cc.NodeGrid:create()
	-- myNode:setContentSize(cc.size(224, 154))
	-- local sprite = cc.Sprite:create("pve_section_04.jpg")
	-- myNode:addChild(sprite)
	-- self.mRootNode:addChild(myNode)

	-- myNode:setPosition(cc.p(200, 200))

	-- local flipx  = cc.FlipX3D:create(10)	
	-- myNode:runAction(flipx)

	-- if not self.mSchedulerHandler then
	-- 	local scheduler = cc.Director:getInstance():getScheduler()
	-- 	self.mSchedulerHandler = scheduler:scheduleScriptFunc(handler(self, self.onScrollViewEvent), 0, false)
	-- end
	PveNoticeInnerImpl:doUpdate()

	local function doPveGuideOne_Step2()
		local guideBtn = self.mSectionWidgetList[1]
		local size = guideBtn:getContentSize()
		local pos = guideBtn:getWorldPosition()
		pos.x = pos.x - size.width/2
		pos.y = pos.y - size.height/2
		local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
		PveGuideOne:step(3, touchRect)
	end
	PveGuideOne:step(2, nil, doPveGuideOne_Step2)

	local function doPveGuideTwo_Step2()
		local guideBtn = self.mSectionWidgetList[2]
		local size = guideBtn:getContentSize()
		local pos = guideBtn:getWorldPosition()
		pos.x = pos.x - size.width/2
		pos.y = pos.y - size.height/2
		local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
		PveGuideTwo:step(3, touchRect)
	end
	PveGuideTwo:step(2, nil, doPveGuideTwo_Step2)

	local function doPveGuideThree_Step2()
		local guideBtn = self.mSectionWidgetList[3]
		local size = guideBtn:getContentSize()
		local pos = guideBtn:getWorldPosition()
		pos.x = pos.x - size.width/2
		pos.y = pos.y - size.height/2
		local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
		PveGuideThree:step(3, touchRect)
	end
	PveGuideThree:step(2, nil, doPveGuideThree_Step2)

	if PveGuideFour:canGuide() then
		local guideBtn = self.mRootWidget:getChildByName("Panel_Rewards_8")
		local size = guideBtn:getContentSize()
		local pos = guideBtn:getWorldPosition()
		local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
		PveGuideFour:step(1, touchRect)
	end

	local function doPveGuideFive_Step2()
		local guideBtn = self.mSectionWidgetList[4]
		local size = guideBtn:getContentSize()
		local pos = guideBtn:getWorldPosition()
		pos.x = pos.x - size.width/2
		pos.y = pos.y - size.height/2
		local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
		PveGuideFive:step(3, touchRect)
	end
	PveGuideFive:step(2, nil, doPveGuideFive_Step2)

	local function doPveGuide1_5_Step2()
		local guideBtn = self.mSectionWidgetList[5]
		local size = guideBtn:getContentSize()
		local pos = guideBtn:getWorldPosition()
		pos.x = pos.x - size.width/2
		pos.y = pos.y - size.height/2
		local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
		PveGuide1_5:step(3, touchRect)
	end
	PveGuide1_5:step(2, nil, doPveGuide1_5_Step2)

	-- local function doPveGuide1_6_Step2()
	-- 	local guideBtn = self.mSectionWidgetList[6]
	-- 	local size = guideBtn:getContentSize()
	-- 	local pos = guideBtn:getWorldPosition()
	-- 	pos.x = pos.x - size.width/2
	-- 	pos.y = pos.y - size.height/2
	-- 	local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
	-- 	PveGuide1_6:step(3, touchRect)
	-- end
	-- PveGuide1_6:step(2, nil, doPveGuide1_6_Step2)
	if PveGuide1_6:canGuide() then
		local guideBtn = self.mSectionWidgetList[6]
		local size = guideBtn:getContentSize()
		local pos = guideBtn:getWorldPosition()
		local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
		PveGuide1_6:step(3, touchRect)
	end

	-- local function doPveGuide1_7_Step2()
	-- 	local guideBtn = self.mSectionWidgetList[7]
	-- 	local size = guideBtn:getContentSize()
	-- 	local pos = guideBtn:getWorldPosition()
	-- 	pos.x = pos.x - size.width/2
	-- 	pos.y = pos.y - size.height/2
	-- 	local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
	-- 	PveGuide1_7:step(3, touchRect)
	-- end
	-- PveGuide1_7:step(2, nil, doPveGuide1_7_Step2)
	if PveGuide1_7:canGuide() then
		local guideBtn = self.mSectionWidgetList[7]
		local size = guideBtn:getContentSize()
		local pos = guideBtn:getWorldPosition()
		local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
		PveGuide1_7:step(3, touchRect)
	end

	-- if SkillGuideOne:canGuide() then
	-- 	local guideBtn = self.mTopRoleInfoPanel.mTopWidget:getChildByName("Button_Back")
	-- 	local size = guideBtn:getContentSize()
	-- 	local pos = guideBtn:getWorldPosition()
	-- 	pos.x = pos.x - size.width/2
	-- 	pos.y = pos.y - size.height/2
	-- 	local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
	-- 	SkillGuideOne:step(1, touchRect)
	-- end

	if LevelRewardGuideOne:canGuide() then
		local guideBtn = self.mTopRoleInfoPanel.mTopWidget:getChildByName("Button_Back")
		local size = guideBtn:getContentSize()
		local pos = guideBtn:getWorldPosition()
		pos.x = pos.x - size.width/2
		pos.y = pos.y - size.height/2
		local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
		LevelRewardGuideOne:step(1, touchRect)
	end

	if LevelRewardGuideOnePointFive:canGuide() then
		local guideBtn = self.mTopRoleInfoPanel.mTopWidget:getChildByName("Button_Back")
		local size = guideBtn:getContentSize()
		local pos = guideBtn:getWorldPosition()
		pos.x = pos.x - size.width/2
		pos.y = pos.y - size.height/2
		local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
		LevelRewardGuideOnePointFive:step(1, touchRect)
	end

	local function doPveGuideSix_Step2()
	--	local guideBtn = self.mSectionWidgetList[globaldata.curSectionId[1]]
		local guideBtn = self.mSectionWidgetList[8]
		local size = guideBtn:getContentSize()
		local pos = guideBtn:getWorldPosition()
		pos.x = pos.x - size.width/2
		pos.y = pos.y - size.height/2
		local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
		PveGuideSix:step(3, touchRect)
	end
	PveGuideSix:step(2, nil, doPveGuideSix_Step2)

	if LevelRewardGuideTwo:canGuide() then
		local guideBtn = self.mTopRoleInfoPanel.mTopWidget:getChildByName("Button_Back")
		local size = guideBtn:getContentSize()
		local pos = guideBtn:getWorldPosition()
		pos.x = pos.x - size.width/2
		pos.y = pos.y - size.height/2
		local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
		LevelRewardGuideTwo:step(1, touchRect)
	end

	if ArenaGuideOne:canGuide() then
		local guideBtn = self.mTopRoleInfoPanel.mTopWidget:getChildByName("Button_Back")
		local size = guideBtn:getContentSize()
		local pos = guideBtn:getWorldPosition()
		pos.x = pos.x - size.width/2
		pos.y = pos.y - size.height/2
		local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
		ArenaGuideOne:step(1, touchRect)
	end

	if TaskGuideOne:canGuide() then
		local guideBtn = self.mTopRoleInfoPanel.mTopWidget:getChildByName("Button_Back")
		local size = guideBtn:getContentSize()
		local pos = guideBtn:getWorldPosition()
		pos.x = pos.x - size.width/2
		pos.y = pos.y - size.height/2
		local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
		TaskGuideOne:step(1, touchRect)
	end

	if TaskGuideZero:canGuide() then
		local guideBtn = self.mTopRoleInfoPanel.mTopWidget:getChildByName("Button_Back")
		local size = guideBtn:getContentSize()
		local pos = guideBtn:getWorldPosition()
		pos.x = pos.x - size.width/2
		pos.y = pos.y - size.height/2
		local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
		TaskGuideZero:step(1, touchRect)
	end

	-- if EquipGuideOne:canGuide() then
	-- 	local guideBtn = self.mTopRoleInfoPanel.mTopWidget:getChildByName("Button_Back")
	-- 	local size = guideBtn:getContentSize()
	-- 	local pos = guideBtn:getWorldPosition()
	-- 	pos.x = pos.x - size.width/2
	-- 	pos.y = pos.y - size.height/2
	-- 	local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
	-- 	EquipGuideOne:step(1, touchRect)
	-- end

	if HardPveGuideOne:canGuide() then
		local guideBtn = self.mRootWidget:getChildByName("Image_Hard")
		local size = guideBtn:getContentSize()
		local pos = guideBtn:getWorldPosition()
		pos.x = pos.x - size.width/2
		pos.y = pos.y - size.height/2
		local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
		HardPveGuideOne:step(1, touchRect)
	end

	if not globaldata:isSectionOpened(3, 1, 1) then
		self.mRootWidget:getChildByName("Image_Hard"):setVisible(false)
	else
		self.mRootWidget:getChildByName("Image_Hard"):setVisible(true)
	end

	cclog("=====PveEntryWindow:Load=====end")
end

-- 切换关卡
function PveEntryWindow:switchSection(direction)
	if self.mIsMoveing then
		return
	end

	local totalSectionCnt = 0
	local chapterList = globaldata:getChapterListByLevel(self.mLevel)
	if nil == chapterList[self.mLastClickedChapterWidget:getTag()] or 0 == #chapterList[self.mLastClickedChapterWidget:getTag()].mSectionList then
		return
	end
	totalSectionCnt = #chapterList[self.mLastClickedChapterWidget:getTag()].mSectionList

	local index = self.mLastClickedSectionWidget:getTag()
	local newIndex = index + direction
	if newIndex <= 0 or newIndex > totalSectionCnt then
		return
	end 

	local actWidget = self.mSectionDetailWindow:getChildByName("Panel_Main")
	local moveTime = 0.15
	local deltaX = 200
	local midPos = cc.p(actWidget:getPosition())
	local leftPos = cc.p(midPos.x - deltaX, midPos.y)
	local rightPos = cc.p(midPos.x + deltaX, midPos.y)

	if direction < 0 then -- 向左滑动
		local function leftAnim()
			local function onActEnd()
				if self.mSectionWidgetList[newIndex] then
					actWidget:setPosition(leftPos)
					self:onClickedSection(self.mSectionWidgetList[newIndex])
					local function onActEnd1()
						GUISystem:enableUserInput()
						self.mIsMoveing = false
					end
					
					local act0 = cc.MoveTo:create(moveTime, midPos)
					local act1 = cc.FadeIn:create(moveTime)
					local act2 = cc.Spawn:create(act0, act1)
					local act3 = cc.CallFunc:create(onActEnd1)
					actWidget:runAction(cc.Sequence:create(act2, act3))
				end
			end
			
			local act0 = cc.MoveTo:create(moveTime, rightPos)
			local act1 = cc.FadeOut:create(moveTime)
			local act2 = cc.Spawn:create(act0, act1)
			local act3 = cc.CallFunc:create(onActEnd)
			GUISystem:disableUserInput()
			self.mIsMoveing = true
			actWidget:runAction(cc.Sequence:create(act2, act3))
		end
		leftAnim()
	elseif direction > 0 then -- 向右滑动
		local function rightAnim()
			local function onActEnd()
				if self.mSectionWidgetList[newIndex] then
					actWidget:setPosition(rightPos)
					self:onClickedSection(self.mSectionWidgetList[newIndex])
					local function onActEnd1()
						GUISystem:enableUserInput()
						self.mIsMoveing = false
					end
					local act0 = cc.MoveTo:create(moveTime, midPos)
					local act1 = cc.FadeIn:create(moveTime)
					local act2 = cc.Spawn:create(act0, act1)
					local act3 = cc.CallFunc:create(onActEnd1)
					actWidget:runAction(cc.Sequence:create(act2, act3))
				end
			end
			
			local act0 = cc.MoveTo:create(moveTime, leftPos)
			local act1 = cc.FadeOut:create(moveTime)
			local act2 = cc.Spawn:create(act0, act1)
			local act3 = cc.CallFunc:create(onActEnd)
			GUISystem:disableUserInput()
			self.mIsMoveing = true
			actWidget:runAction(cc.Sequence:create(act2, act3))
		end
		rightAnim()
	end
end


-- 请求进入战斗
function PveEntryWindow:requestEnterBattle()
	local chapterList = globaldata:getChapterListByLevel(self.mLevel)
	local sectionList = chapterList[self.mLastClickedChapterWidget:getTag()]:getKeyValue("mSectionList")
	local sectionObj = sectionList[self.mLastClickedSectionWidget:getTag()]
	local leftCount = sectionObj:getKeyValue("mLeftChanllengeCount")
	-- 判断剩余挑战次数
	if 0 == leftCount then
		local packet = NetSystem.mNetManager:GetSPacket()
	    packet:SetType(PacketTyper._PTYPE_CS_RESET_SECTION_CHALL_TIME)
	    packet:PushChar(self.mLevel)
	    packet:PushInt(self.mLastClickedChapterWidget:getTag())
	    packet:PushInt(self.mLastClickedSectionWidget:getTag())
	    packet:Send()
	    GUISystem:showLoading()
	    return
	end
	self:showRoleSelWindow()
end

-- 显示选人界面
function PveEntryWindow:showRoleSelWindow()
	EventSystem:PushEvent(Event.GUISYSTEM_DISABLEDRAW_PVEENTRYWINDOW)
	self.mRoleSelWindow = GUIWidgetPool:createWidget("PVE_FightTeam")
	self.mRootNode:addChild(self.mRoleSelWindow, 1000)

	local function showHeroRelationShip()
		GUISystem:showHeroRelationShip()
	end
	registerWidgetReleaseUpEvent(self.mRoleSelWindow:getChildByName("Button_GroupCircle"), showHeroRelationShip)

	-- 背景适配
	local winSize = cc.Director:getInstance():getVisibleSize()
	local preSize = self.mRoleSelWindow:getChildByName("Image_WindowBg"):getContentSize()
	self.mRoleSelWindow:getChildByName("Image_WindowBg"):setContentSize(cc.size(winSize.width, preSize.height))

	-- 上阵英雄头像
	local battleHeroIconTbl = {}

	-- 所有英雄id
	local allHeroIdTbl = {}
	-- 所有英雄头像
	local allHeroIconTbl = {}

	-- 全部英雄
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

	-- 上阵英雄id
	local battleHeroIdTbl = {0, 0, 0}
	-- 复制
	if PveGuideSix:canGuide() then
		battleHeroIdTbl[1] = globaldata.battleHeroIdTbl[1] -- 只保留一个
	else
		for i = 1, 3 do
			if globaldata.battleHeroIdTbl[i] then
				battleHeroIdTbl[i] = globaldata.battleHeroIdTbl[i]
			end
		end
	end

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

	-- 进入战斗
	local function goToBattle()
		if getBattleHeroCount() < 1 then
			MessageBox:showMessageBox1("必须保证有一个英雄上阵")
			return
		end

		GUISystem:playSound("homeBtnSound")

		globaldata.clickedlevel = self.mLastClickedLevelWidget:getTag()
	--	globaldata.clickedlevel = self.mLevel
		globaldata.clickedchapter = self.mLastClickedChapterWidget:getTag()
		globaldata.clickedsection = self.mLastClickedSectionWidget:getTag()
		globaldata.battleHeroIdTbl = battleHeroIdTbl

--		if not globaldata:getTiligotoBattle() then return end
		-- loading
		globaldata:requestEnterBattle()

		if PveGuideOne:canGuide() then
			PveGuideOne:stop()
		end

		if PveGuideTwo:canGuide() then
			PveGuideTwo:stop()
		end

		if PveGuideThree:canGuide() then
			PveGuideThree:stop()
		end

		if PveGuideFive:canGuide() then
			PveGuideFive:stop()
		end

		if PveGuide1_5:canGuide() then
			PveGuide1_5:stop()
		end

		if PveGuide1_6:canGuide() then
			PveGuide1_6:stop()
		end

		if PveGuide1_7:canGuide() then
			PveGuide1_7:stop()
		end

		if PveGuideSix:canGuide() then
			PveGuideSix:stop()
		end
	end
	registerWidgetReleaseUpEvent(self.mRoleSelWindow:getChildByName("Button_Fight"), goToBattle)

	-- 显示英雄名字
	local function showBattleHeroName()
		local combat = 0 
		for i = 1, #battleHeroIdTbl do
			local lblWidget = self.mRoleSelWindow:getChildByName("Label_HeroName_"..tostring(i))
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

		self.mRoleSelWindow:getChildByName("Panel_TotalZhanli"):setVisible(true)
		self.mRoleSelWindow:getChildByName("Label_TotalZhanli"):setString(tostring(combat))
		self.mRoleSelWindow:getChildByName("Label_TotalZhanli"):setVisible(true)
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
				self.mRoleSelWindow:getChildByName("Panel_Hero_"..tostring(i)):addChild(animNode:getRootNode(), 100)
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

	-- 判断英雄是否在阵上
	local function isHeroInBattle(id)
		for i = 1, #battleHeroIdTbl do
			if id == battleHeroIdTbl[i] then
				return true
			end
		end
		return false
	end

--	local animNode = AnimManager:createAnimNode(8001)
--	self.mRoleSelWindow:addChild(animNode:getRootNode(), 100)
--	animNode:setPosition(cc.p(200, 200))
--	animNode:play("")


	-- 送英雄上阵
	local function sendHeroToBattle(widget)
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
					self.mRoleSelWindow:getChildByName("Panel_Hero_"..tostring(i)):addChild(battleHeroIconTbl[i])
					registerWidgetReleaseUpEvent(battleHeroIconTbl[i], sendHeroBack)
					-- 播放特效
					local animNode = AnimManager:createAnimNode(8001)
					self.mRoleSelWindow:getChildByName("Panel_Hero_"..tostring(i)):addChild(animNode:getRootNode(), 100)
					animNode:setPosition(cc.p(45, 32))
					animNode:play("fightteam_cell_chose1")
					-- 原来控件设置上阵
					widget:getChildByName("Image_HeroChosen"):setVisible(true)
					widget:getChildByName("Label_HeroName"):setColor(cc.c3b(255, 245, 84))
					showBattleHeroName()
					-- 播放特效
					animNode = AnimManager:createAnimNode(8001)
					widget:getChildByName("Panel_Animation"):addChild(animNode:getRootNode(), 100)
					animNode:play("fightteam_cell_chose2")

					if PveGuideSix:canGuide() then
						local guideBtn = self.mRoleSelWindow:getChildByName("Button_Fight")
						local size = guideBtn:getContentSize()
						local pos = guideBtn:getWorldPosition()
						pos.x = pos.x - size.width/2
						pos.y = pos.y - size.height/2
						local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
						PveGuideSix:step(6, touchRect)
					end

					return 
				end
			end
		else
			sendHeroBack(widget)
		end
	end

	local iconCnt = 0
	-- 载入所有英雄
	local function loadAllHero()
		-- for i = 1, maxHeroCount do -- 存在
		-- 	local heroData = DB_HeroConfig.getDataById(i)
		-- 	if globaldata:isHeroIdExist(i) then 
		-- 		table.insert(allHeroIdTbl, i)
		-- 	end
		-- end

		for i = 1, #allHeroIdTbl do
			local heroObj = globaldata:findHeroById(allHeroIdTbl[i])
			iconCnt = iconCnt + 1
			allHeroIconTbl[iconCnt] = GUIWidgetPool:createWidget("PVE_FightTeamCell")
			allHeroIconTbl[iconCnt]:getChildByName("Panel_HeroIcon"):addChild(createHeroIcon(heroObj.id, heroObj.level, heroObj.quality, heroObj.advanceLevel))
			allHeroIconTbl[iconCnt]:setTouchEnabled(true)
			allHeroIconTbl[iconCnt]:setTag(heroObj.id)
			self.mRoleSelWindow:getChildByName("ListView_heroList"):pushBackCustomItem(allHeroIconTbl[iconCnt])
			registerWidgetReleaseUpEvent(allHeroIconTbl[iconCnt], sendHeroToBattle)
			-- 名字
			local heroData = DB_HeroConfig.getDataById(heroObj.id)
			local heroNameId = heroData.Name
			allHeroIconTbl[iconCnt]:getChildByName("Label_HeroName"):setString(getDictionaryText(heroNameId))
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
						self.mRoleSelWindow:getChildByName("Panel_Hero_"..tostring(i)):addChild(battleHeroIconTbl[i])
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

	local function closeRoleSelWindow()
		EventSystem:PushEvent(Event.GUISYSTEM_EABLEDRAW_PVEENTRYWINDOW)
		self.mRoleSelWindow:removeFromParent(true)
		self.mRoleSelWindow = nil
	end
	registerWidgetReleaseUpEvent(self.mRoleSelWindow:getChildByName("Button_Cancel"), closeRoleSelWindow)

	if PveGuideOne:canGuide() then
		local guideBtn = self.mRoleSelWindow:getChildByName("Button_Fight")
		local size = guideBtn:getContentSize()
		local pos = guideBtn:getWorldPosition()
		pos.x = pos.x - size.width/2
		pos.y = pos.y - size.height/2
		local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
		PveGuideOne:step(5, touchRect)
	end

	if PveGuideTwo:canGuide() then
		local guideBtn = self.mRoleSelWindow:getChildByName("Button_Fight")
		local size = guideBtn:getContentSize()
		local pos = guideBtn:getWorldPosition()
		pos.x = pos.x - size.width/2
		pos.y = pos.y - size.height/2
		local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
		PveGuideTwo:step(5, touchRect)
	end

	if PveGuideThree:canGuide() then
		local guideBtn = self.mRoleSelWindow:getChildByName("Button_Fight")
		local size = guideBtn:getContentSize()
		local pos = guideBtn:getWorldPosition()
		pos.x = pos.x - size.width/2
		pos.y = pos.y - size.height/2
		local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
		PveGuideThree:step(5, touchRect)
	end

	if PveGuideFive:canGuide() then
		local guideBtn = self.mRoleSelWindow:getChildByName("Button_Fight")
		local size = guideBtn:getContentSize()
		local pos = guideBtn:getWorldPosition()
		pos.x = pos.x - size.width/2
		pos.y = pos.y - size.height/2
		local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
		PveGuideFive:step(5, touchRect)
	end

	if PveGuide1_5:canGuide() then
		local guideBtn = self.mRoleSelWindow:getChildByName("Button_Fight")
		local size = guideBtn:getContentSize()
		local pos = guideBtn:getWorldPosition()
		pos.x = pos.x - size.width/2
		pos.y = pos.y - size.height/2
		local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
		PveGuide1_5:step(5, touchRect)
	end

	if PveGuide1_6:canGuide() then
		local guideBtn = self.mRoleSelWindow:getChildByName("Button_Fight")
		local size = guideBtn:getContentSize()
		local pos = guideBtn:getWorldPosition()
		pos.x = pos.x - size.width/2
		pos.y = pos.y - size.height/2
		local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
		PveGuide1_6:step(5, touchRect)
	end

	if PveGuide1_7:canGuide() then
		local guideBtn = self.mRoleSelWindow:getChildByName("Button_Fight")
		local size = guideBtn:getContentSize()
		local pos = guideBtn:getWorldPosition()
		pos.x = pos.x - size.width/2
		pos.y = pos.y - size.height/2
		local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
		PveGuide1_7:step(5, touchRect)
	end

	if PveGuideSix:canGuide() then
		local function doRealGuide()
			local function getHeroIndex()
				for i = 1, #allHeroIconTbl do
					if battleHeroIdTbl[1] ~= allHeroIdTbl[i] then
						return i
					end
				end
			end
			local index = getHeroIndex()
			local guideBtn = allHeroIconTbl[index]
			local size = guideBtn:getContentSize()
			local pos = guideBtn:getWorldPosition()
			local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
			PveGuideSix:step(5, touchRect)
			GUISystem:enableUserInput()
		end
		GUISystem:disableUserInput()
		nextTick(doRealGuide)
	end
end

function PveEntryWindow:InitLayout()
	self.mRootWidget = GUIWidgetPool:createWidget("PVE")
	self.mRootNode:addChild(self.mRootWidget)

	local function closeWindow()
		GUISystem:playSound("homeBtnSound")
		if __IsEnterFighting__ then
			local function callFun()
				EventSystem:PushEvent(Event.GUISYSTEM_HIDE_PVEENTRYWINDOW)
				showLoadingWindow("HomeWindow")
		  		__IsEnterFighting__ = false
			end
		   FightSystem:sendChangeCity(false,callFun)
		else
			EventSystem:PushEvent(Event.GUISYSTEM_HIDE_PVEENTRYWINDOW)
		end
	end

	self.mTopRoleInfoPanel = TopRoleInfoPanel:new()
	self.mTopRoleInfoPanel:init(self.mRootNode,ROLE_TITLE_TYPE.TITLE_PVE, closeWindow)

	self.mChapterWindow = self.mRootWidget:getChildByName("Panel_Chapter")

	self.mSectionWindow = self.mRootWidget:getChildByName("Panel_Section")

	self.mSectionWindow_Hard = self.mRootWidget:getChildByName("Panel_Section_Hard")

	self.mRewardPanel_Normal = self.mRootWidget:getChildByName("Panel_MapRewards")

	self.mRewardPanel_Hard = self.mRootWidget:getChildByName("Panel_MapRewards_Hard")

	self.mSectionDetailWindow = nil

	-- self.mChapterScrollWidget = self.mRootWidget:getChildByName("ScrollView_Chapter")
	-- self.mSectionScrollWidget = self.mRootWidget:getChildByName("ScrollView_Section")
	-- self.mPanelSectionInfo = self.mRootWidget:getChildByName("Panel_SectionInfo")
	-- self.mPanelSectionInfo:setVisible(false)

	-- registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_CloseSection"), handler(self, self.hideSectionDetail))

	-- 简单
	self.mRootWidget:getChildByName("Image_Easy"):setTouchEnabled(true)
	registerWidgetPushDownEvent(self.mRootWidget:getChildByName("Image_Easy"), handler(self, self.onLevelSelected))
	self.mRootWidget:getChildByName("Image_Easy"):setTag(1)

	-- 困难
	self.mRootWidget:getChildByName("Image_Hard"):setTouchEnabled(true)
	registerWidgetPushDownEvent(self.mRootWidget:getChildByName("Image_Hard"), handler(self, self.onLevelSelected))
	self.mRootWidget:getChildByName("Image_Hard"):setTag(2)

	-- 团队
	self.mRootWidget:getChildByName("Image_Team"):setTouchEnabled(true)
	registerWidgetPushDownEvent(self.mRootWidget:getChildByName("Image_Team"), handler(self, self.onLevelSelected))

	self.mRootWidget:getChildByName("Image_Team"):setTag(3)

	
	local function doAdapter()
		self.mRootWidget:getChildByName("Panel_Chapter"):setPositionX(getGoldFightPosition_LU().x)
	end
	doAdapter()

end

-- 关闭关卡详情
function PveEntryWindow:hideSectionDetail(widget)
	self.mSectionOpened = false
	local deltaY = 30
	-- 关卡
	for i = 1, #self.mSectionWidgetList do
		local curPos = cc.p(self.mSectionWidgetList[i]:getPosition())
		local newPos = cc.p(curPos.x, 0)
		local newPos2 = cc.p(curPos.x - deltaX, 0)
		local act0 = nil
		if self.mLastClickedSectionWidget == self.mSectionWidgetList[i] then
			act0 = cc.MoveTo:create(moveTime, newPos2)
		else
			act0 = cc.MoveTo:create(moveTime, newPos)
		end
	--	self.mSectionWidgetList[i]:runAction(cc.EaseBackOut:create(act0))
		self.mSectionWidgetList[i]:runAction(act0)
		self.mSectionWidgetList[i]:getChildByName("Image_Unselected"):setVisible(false)
	end

	self.mChapterScrollWidget:setVisible(true)
	-- 章节
	for i = 1, #self.mChapterWidgetList do
		local curPos = cc.p(self.mChapterWidgetList[i]:getPosition())
		local newPos = cc.p(curPos.x, 0)
		local newPos2 = cc.p(curPos.x, deltaY)
		local act0 = nil
		if self.mLastClickedChapterWidget == self.mChapterWidgetList[i] then
			act0 = cc.MoveTo:create(moveTime, newPos2)
		else
			act0 = cc.MoveTo:create(moveTime, newPos)
		end
	--	self.mChapterWidgetList[i]:runAction(cc.EaseBackOut:create(act0))
		self.mChapterWidgetList[i]:runAction(act0)
	end

	self:setWidgetSelected(self.mLastClickedSectionWidget, false)
	self.mLastClickedSectionWidget:getChildByName("Image_Unselected"):setVisible(false)
	self.mLastClickedSectionWidget = nil
	self.mPanelSectionInfo:setVisible(false)
end

-- 选择难度
function PveEntryWindow:onLevelSelected(widget,bSound)

	local function doHardPveGuideOne_Stop()
		HardPveGuideOne:stop()
	end
	HardPveGuideOne:step(2, nil, doHardPveGuideOne_Stop)

	if bSound == nil then GUISystem:playSound("tabPageSound") end
	if widget == self.mLastClickedLevelWidget then
		return
	end

	local chapterList = globaldata:getChapterListByLevel(widget:getTag())
	if nil == chapterList or 0 == #chapterList or 0 == #(chapterList[1].mSectionList) then
		MessageBox:showMessageBox1("关卡还未开启~")
		return
	else
		local needChapterId = globaldata.curChapterId[widget:getTag()]
		local needSectionId = globaldata.curSectionId[widget:getTag()]

		self.mLevel = widget:getTag()

		if self.mEvent.mData then -- 默认选择章节
			if self.mEvent.mData[2] then
				local sectionInfo = nil
				if 1 == self.mEvent.mData[1] then
					sectionInfo = DB_MapUIConfigEasy.getDataById(self.mEvent.mData[2])
				elseif 2 == self.mEvent.mData[1] then
					sectionInfo = DB_MapUIConfigNormal.getDataById(self.mEvent.mData[2])
				end
				
				-- 选章节
				self:onClickedChapter(self.mChapterWidgetList[sectionInfo.MapUI_ChapterID],false)
				-- 选关卡
				self:onClickedSection(self.mSectionWidgetList[sectionInfo.MapUI_SectionID])
			else
				self:onClickedChapter(self.mChapterWidgetList[globaldata.curChapterId[self.mLevel]],false)
			end
		else -- 否则选最新关
			self:onClickedChapter(self.mChapterWidgetList[needChapterId],false, true)
		end

		-- 初始化关卡
		self:initSections()
	end

	local norTexture = {"pve_page_easy_1.png", "pve_page_hard_1.png", "pve_page_team_1.png"}
	local pusTexture = {"pve_page_easy_2.png", "pve_page_hard_2.png", "pve_page_team_2.png"}

	local function replaceTexture()
		if self.mLastClickedLevelWidget then
			self.mLastClickedLevelWidget:loadTexture(norTexture[self.mLastClickedLevelWidget:getTag()])
			self.mLastClickedLevelWidget = widget
		else
			self.mLastClickedLevelWidget = widget
		end
		widget:loadTexture(pusTexture[widget:getTag()])
	end
	-- 换菜单项图片
	replaceTexture()

	-- 更新关卡信息
	self:updateSections()

	local function addAnim()
		-- 播放特效
		animNode = AnimManager:createAnimNode(8014)
		widget:getChildByName("Panel_Animation"):addChild(animNode:getRootNode(), 100)
		if 1 == self.mLevel then
			animNode:play("pve_difficult_easy")
		elseif 2 == self.mLevel then
			animNode:play("pve_difficult_hard")
		elseif 3 == self.mLevel then
			animNode:play("pve_difficult_team")
		end
	end
	addAnim()

	-- 根据级别显示特定窗口
	if 1 == self.mLevel then
		self.mSectionWindow:setVisible(true)
		self.mSectionWindow_Hard:setVisible(false)
		self.mRewardPanel_Normal:setVisible(true)
		self.mRewardPanel_Hard:setVisible(false)
	elseif 2 == self.mLevel then
		self.mSectionWindow:setVisible(false)
		self.mSectionWindow_Hard:setVisible(true)
		self.mRewardPanel_Normal:setVisible(false)
		self.mRewardPanel_Hard:setVisible(true)
	end

	-- 更换颜色
	local function updateChapterWidget()
		for i = 1, 10 do
			if 1 == self.mLevel then
				self.mRootWidget:getChildByName("Image_Chapter_"..i):getChildByName("Image_Num"):loadTexture(string.format("pve_chapter_title_easy_%d.png", i))
			elseif 2 == self.mLevel then
				self.mRootWidget:getChildByName("Image_Chapter_"..i):getChildByName("Image_Num"):loadTexture(string.format("pve_chapter_title_hard_%d.png", i))
			end
		end
	end
	updateChapterWidget()

	-- 重设置滑动层大小
	local function reSetScrollViewWidgetContentSize()
		local function getOpenedChapterCnt()
			for i = 1, 10 do
				if not globaldata:isSectionOpened(i, 1, self.mLevel) then
					return i - 1
				end
			end
			return 10
		end

		local openedCnt = getOpenedChapterCnt()
		local scrollView = self.mRootWidget:getChildByName("ScrollView_Chapter")
		local preContentSize = scrollView:getInnerContainerSize()
		preContentSize.height = preContentSize.height*openedCnt/10
		scrollView:setInnerContainerSize(preContentSize)

		for i = 1, 10 do
			if i <= openedCnt then
				self.mRootWidget:getChildByName("Image_Chapter_"..i):setVisible(true)
			else
				self.mRootWidget:getChildByName("Image_Chapter_"..i):setVisible(false)
			end
		end
	end
	reSetScrollViewWidgetContentSize()	
end

-- 更新
function PveEntryWindow:updateDetailInfo()
	if self.mSectionDetailWindow then	
		-- 剩余挑战次数
		local chapterList = globaldata:getChapterListByLevel(self.mLevel)
		local sectionList = chapterList[self.mLastClickedChapterWidget:getTag()]:getKeyValue("mSectionList")
		local sectionObj = sectionList[self.mLastClickedSectionWidget:getTag()]
		local leftCount = sectionObj:getKeyValue("mLeftChanllengeCount")
		local totalCount = sectionObj:getKeyValue("mTotalChallengeCount")
		self.mSectionDetailWindow:getChildByName("Label_TimesNum"):setString(tostring(leftCount).."/"..tostring(totalCount))
	end
end

-- 显示关卡详情
function PveEntryWindow:showSectionDetail(tiliCost)
	if not self.mSectionDetailWindow then
		self.mSectionDetailWindow = GUIWidgetPool:createWidget("PVE_Section")
		self.mRootNode:addChild(self.mSectionDetailWindow, 100)
	end

	-- 显示级别
	if 1 == self.mLevel then
		self.mSectionDetailWindow:getChildByName("Label_Type"):setString("普通")
	elseif 2 == self.mLevel then
		self.mSectionDetailWindow:getChildByName("Label_Type"):setString("精英")
	elseif 3 == self.mLevel then
		self.mSectionDetailWindow:getChildByName("Label_Type"):setString("团队")
	end

	local function hideSectionDetail()
		GUISystem:playSound("homeBtnSound")
		self.mSectionDetailWindow:removeFromParent(true)
		self.mSectionDetailWindow = nil
	end

	registerWidgetReleaseUpEvent(self.mSectionDetailWindow:getChildByName("Button_Close"), hideSectionDetail)

	registerWidgetReleaseUpEvent(self.mSectionDetailWindow:getChildByName("Button_Chuangguan"), handler(self, self.requestEnterBattle))

	-- 关卡名字和章节名字
	local sections = nil
	if 1 == self.mLevel then
		sections = DB_MapUIConfigEasy.getArrDataByField("MapUI_ChapterID", self.mLastClickedChapterWidget:getTag())
	elseif 2 == self.mLevel then
		sections = DB_MapUIConfigNormal.getArrDataByField("MapUI_ChapterID", self.mLastClickedChapterWidget:getTag())
	end
	local function doFind()
		local chapterInfo = nil
		local sectionInfo = nil
		for i = 1, #sections do
			if 0 == sections[i].MapUI_SectionID then
				chapterInfo = sections[i]
			end
			if self.mLastClickedSectionWidget:getTag() == sections[i].MapUI_SectionID then
				sectionInfo = sections[i]
			end
		end
		return chapterInfo, sectionInfo
	end
	local chapterInfo, sectionInfo = doFind()
	-- 章节
	local chapterNameId = chapterInfo.MapUI_ChapterName
	local chapterNameData = DB_Text.getDataById(chapterNameId)
	local chapterName = chapterNameData[GAME_LANGUAGE]
	-- 关卡
	local sectionNameId = sectionInfo.MapUI_SectionName
	local sectionNameData = DB_Text.getDataById(sectionNameId)
	local sectionName = sectionNameData[GAME_LANGUAGE]

	self.mSectionDetailWindow:getChildByName("Label_ChapterAndSectionName_Stroke_157_2_70"):setString(chapterName.." ,"..sectionName)

	self.mSectionDetailWindow:getChildByName("Label_ChapterAndSectionNumber_Stroke_157_2_70"):setString(tostring(self.mLastClickedChapterWidget:getTag()).."-"..tostring(self.mLastClickedSectionWidget:getTag()))

	-- 更新扫荡券信息
	self:updateDetailInfo()

	-- 显示掉落信息
	local function showDropInfo()
		local levelDropMap = 
		{
			"MapUI_EasyDrop",
			"MapUI_NormalDrop",
			"MapUI_HardDrop",
		}

		for i = 1, 4 do
			local item = sectionInfo[levelDropMap[self.mLevel]..tostring(i)]
			self.mSectionDetailWindow:getChildByName("Panel_Drop"..tostring(i)):removeAllChildren()
			if -1 ~= item then
				local widget = createItemWidget(item)
				self.mSectionDetailWindow:getChildByName("Panel_Drop"..tostring(i)):addChild(widget)

				MessageBox:setTouchShowInfo(widget, 0, item)
			end
			
		end
	end
	showDropInfo()
	self.mCurSectionObject = sectionInfo

	-- 剩余挑战次数
	local chapterList = globaldata:getChapterListByLevel(self.mLevel)
	local sectionList = chapterList[self.mLastClickedChapterWidget:getTag()]:getKeyValue("mSectionList")
	local sectionObj = sectionList[self.mLastClickedSectionWidget:getTag()]
	local leftCount = sectionObj:getKeyValue("mLeftChanllengeCount")
	self.mCurChallCount = leftCount
	local totalCount = sectionObj:getKeyValue("mTotalChallengeCount")
	self.mSectionDetailWindow:getChildByName("Label_TimesNum"):setString(tostring(leftCount).."/"..tostring(totalCount))

	-- 体力消耗
	if 1 == self.mLevel then
		self.mSectionDetailWindow:getChildByName("Label_TiliCost"):setString("5")
	elseif 2 == self.mLevel then
		self.mSectionDetailWindow:getChildByName("Label_TiliCost"):setString("10")
	end

	-- 故事
	local storyTextId = sectionInfo.MapUI_SectionStory
	local storyTextData = DB_Text.getDataById(storyTextId)
	local storyText = storyTextData[GAME_LANGUAGE]
	self.mSectionDetailWindow:getChildByName("Label_Story"):setString(storyText)
        
	-- 关卡类型
	local modeTextId = sectionInfo.MapUI_Mode
	local modeTextData = DB_Text.getDataById(modeTextId)
	local modeText = modeTextData[GAME_LANGUAGE]
	self.mSectionDetailWindow:getChildByName("Label_SectionType"):setString(modeText)

	-- 关卡描述
	local boardId = getBoardIdByMapUI(self.mLastClickedChapterWidget:getTag(), self.mLastClickedSectionWidget:getTag(), self.mLevel)
	local boardData = DB_BoardsConfig.getDataById(boardId)
	for i = 1, 3 do
		local descTextId = boardData["Star"..i.."_Text"]
		local descTextData = DB_Text.getDataById(descTextId)
		local descText = descTextData[GAME_LANGUAGE]
		self.mSectionDetailWindow:getChildByName("Label_SectionDesc_"..i):setString(descText)
	end

	-- 星星
	local starCount =  sectionObj:getKeyValue("mCurStarCount")
	-- 显示星星
	for i = 1, 3 do
		self.mSectionDetailWindow:getChildByName("Panel_Stars"):getChildByName("Image_Star_"..i):loadTexture("public_star2.png")
	end
	for j = 1, starCount do
		self.mSectionDetailWindow:getChildByName("Panel_Stars"):getChildByName("Image_Star_"..j):loadTexture("public_star1.png")
	end

	-- 怪物
	for i = 1, 4 do
		self.mSectionDetailWindow:getChildByName("Panel_Enermy"..tostring(i)):removeAllChildren()
	end
	for i = 1, sectionInfo.MapUI_Monster_Number do
		local monsterId = sectionInfo["MapUI_MonsterID_"..tostring(i)]
		local iconWidget = createMonsterIcon(monsterId)
		self.mSectionDetailWindow:getChildByName("Panel_Enermy"..tostring(i)):addChild(iconWidget)
	end

	-- 扫荡
	local btn = self.mSectionDetailWindow:getChildByName("Button_Saodang1")
	btn:setTag(1)
	registerWidgetReleaseUpEvent(btn, handler(self, self.requestDoSaodang))

	-- 扫荡
	btn = self.mSectionDetailWindow:getChildByName("Button_Saodang10")
	btn:setTag(10)
	registerWidgetReleaseUpEvent(btn, handler(self, self.requestDoSaodang))

	if 1 == self.mLevel then -- 普通
		if leftCount >=10 then
			btn:getChildByName("Label_SaoDangMore_Stroke_7_43_95"):setString("通关10次")
		else
			btn:getChildByName("Label_SaoDangMore_Stroke_7_43_95"):setString("通关"..tostring(leftCount).."次")
		end
	elseif 2 == self.mLevel then -- 精英
		btn:getChildByName("Label_SaoDangMore_Stroke_7_43_95"):setString("通关"..tostring(leftCount).."次")
	end

	-- local btn = self.mSectionDetailWindow:getChildByName("Button_TurnPre")
	-- btn:setTag(-1)
	-- registerWidgetReleaseUpEvent(btn, handler(self, self.switchSection))

	-- btn = self.mSectionDetailWindow:getChildByName("Button_TurnNext")
	-- btn:setTag(1)
	-- registerWidgetReleaseUpEvent(btn, handler(self, self.switchSection))

	local posBegan 	= 	nil
	local posEnd 	=	nil

	local function onTouchBegan(touch, event)
		posBegan = touch:getLocation()
		return true
	end

	local function onTouchMoved(touch, event)
		
	end

	local function onTouchEnded(touch, event)
		posEnd = touch:getLocation()
		local deltaX = math.abs(posEnd.x - posBegan.x)
		local deltaY = math.abs(posEnd.y - posBegan.y)
		if deltaX > deltaY and deltaX > 20 then
			if posEnd.x > posBegan.x then
				self:switchSection(-1)
			else
				self:switchSection(1)
			end
		elseif deltaX < deltaY then
			
		end
	end

	local function onTouchCancelled(touch, event)
		
	end


	processTouchPanel = cc.Layer:create()
	local listener = cc.EventListenerTouchOneByOne:create()
	listener:setSwallowTouches(false)
	listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    listener:registerScriptHandler(onTouchCancelled,cc.Handler.EVENT_TOUCH_CANCELLED )
    local eventDispatcher = processTouchPanel:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, processTouchPanel)
    self.mSectionDetailWindow:addChild(processTouchPanel, 1000)
    processTouchPanel:setPosition(cc.p(0, 0))



	local leftAnimNode = AnimManager:createAnimNode(8031)
	local leftParentNode = self.mSectionDetailWindow:getChildByName("Panel_Arrow_Animation_Left")
	leftParentNode:removeAllChildren()
	leftParentNode:addChild(leftAnimNode:getRootNode(), 100)
	leftAnimNode:play("shop_arraw", true)

	local rightAnimNode = AnimManager:createAnimNode(8031)
	local rightParentNode = self.mSectionDetailWindow:getChildByName("Panel_Arrow_Animation_Right")
	rightParentNode:removeAllChildren()
	rightParentNode:addChild(rightAnimNode:getRootNode(), 100)
	rightAnimNode:play("shop_arraw", true)

	local function removeScrollFunc()
		if processTouchPanel then
			processTouchPanel:removeFromParent(true)
			processTouchPanel = nil
		end
	end


	if PveGuideOne:canGuide() then
		local guideBtn = self.mSectionDetailWindow:getChildByName("Button_Chuangguan")
		local size = guideBtn:getContentSize()
		local pos = guideBtn:getWorldPosition()
		pos.x = pos.x - size.width/2
		pos.y = pos.y - size.height/2
		local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
		PveGuideOne:step(4, touchRect)
		removeScrollFunc()
	end

	if PveGuideTwo:canGuide() then
		local guideBtn = self.mSectionDetailWindow:getChildByName("Button_Chuangguan")
		local size = guideBtn:getContentSize()
		local pos = guideBtn:getWorldPosition()
		pos.x = pos.x - size.width/2
		pos.y = pos.y - size.height/2
		local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
		PveGuideTwo:step(4, touchRect)
		removeScrollFunc()
	end

	if PveGuideThree:canGuide() then
		local guideBtn = self.mSectionDetailWindow:getChildByName("Button_Chuangguan")
		local size = guideBtn:getContentSize()
		local pos = guideBtn:getWorldPosition()
		pos.x = pos.x - size.width/2
		pos.y = pos.y - size.height/2
		local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
		PveGuideThree:step(4, touchRect)
		removeScrollFunc()
	end

	if PveGuideFive:canGuide() then
		local guideBtn = self.mSectionDetailWindow:getChildByName("Button_Chuangguan")
		local size = guideBtn:getContentSize()
		local pos = guideBtn:getWorldPosition()
		pos.x = pos.x - size.width/2
		pos.y = pos.y - size.height/2
		local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
		PveGuideFive:step(4, touchRect)
		removeScrollFunc()
	end

	if PveGuide1_5:canGuide() then
		local guideBtn = self.mSectionDetailWindow:getChildByName("Button_Chuangguan")
		local size = guideBtn:getContentSize()
		local pos = guideBtn:getWorldPosition()
		pos.x = pos.x - size.width/2
		pos.y = pos.y - size.height/2
		local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
		PveGuide1_5:step(4, touchRect)
		removeScrollFunc()
	end

	if PveGuide1_6:canGuide() then
		local guideBtn = self.mSectionDetailWindow:getChildByName("Button_Chuangguan")
		local size = guideBtn:getContentSize()
		local pos = guideBtn:getWorldPosition()
		pos.x = pos.x - size.width/2
		pos.y = pos.y - size.height/2
		local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
		PveGuide1_6:step(4, touchRect)
		removeScrollFunc()
	end

	if PveGuide1_7:canGuide() then
		local guideBtn = self.mSectionDetailWindow:getChildByName("Button_Chuangguan")
		local size = guideBtn:getContentSize()
		local pos = guideBtn:getWorldPosition()
		pos.x = pos.x - size.width/2
		pos.y = pos.y - size.height/2
		local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
		PveGuide1_7:step(4, touchRect)
		removeScrollFunc()
	end

	if PveGuideSix:canGuide() then
		local guideBtn = self.mSectionDetailWindow:getChildByName("Button_Chuangguan")
		local size = guideBtn:getContentSize()
		local pos = guideBtn:getWorldPosition()
		pos.x = pos.x - size.width/2
		pos.y = pos.y - size.height/2
		local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
		PveGuideSix:step(4, touchRect)
		removeScrollFunc()
	end

end

-- 点击关卡
function PveEntryWindow:onClickedSection(widget)

	-- 关卡名字和章节名字
	local sections = nil
	if 1 == self.mLevel then
		sections = DB_MapUIConfigEasy.getArrDataByField("MapUI_ChapterID", self.mLastClickedChapterWidget:getTag())
	elseif 2 == self.mLevel then
		sections = DB_MapUIConfigNormal.getArrDataByField("MapUI_ChapterID", self.mLastClickedChapterWidget:getTag())
	end
	local function doFind()
		local chapterInfo = nil
		local sectionInfo = nil
		for i = 1, #sections do
			if 0 == sections[i].MapUI_SectionID then
				chapterInfo = sections[i]
			end
			if widget:getTag() == sections[i].MapUI_SectionID then
				sectionInfo = sections[i]
			end
		end
		if not sectionInfo then
			G_ErrorReport("error in doFind(), widget:getTag() is "..widget:getTag())
		end
		return chapterInfo, sectionInfo
	end
	local chapterInfo, sectionInfo = doFind()
	local limitLevel = sectionInfo.MapUI_SectionLevelLimit
	if limitLevel > globaldata.level then
		MessageBox:showMessageBox1("挑战当前关卡需要等级:"..limitLevel)
		return
	end

	-- 精英关需要限制
	if 2 == self.mLevel then
		if not globaldata:isChapterFinished(self.mLastClickedChapterWidget:getTag(), 2*widget:getTag(), 1) then
			MessageBox:showMessageBox1("挑战当前关卡需要完成普通关卡:"..tostring(self.mLastClickedChapterWidget:getTag()).."-"..tostring(2*widget:getTag()))
			return
		end
	end

	local function onRequestGetSectionInfo(packet)
		-- 记录最后一次关卡
		self.mLastClickedSectionWidget = widget

		GUISystem:hideLoading()

		if not self.mLastClickedChapterWidget then
			return
		end

		-- 剩余挑战次数
		local chapterList = globaldata:getChapterListByLevel(self.mLevel)
		local sectionList = chapterList[self.mLastClickedChapterWidget:getTag()]:getKeyValue("mSectionList")
		local sectionObj = sectionList[self.mLastClickedSectionWidget:getTag()]

		sectionObj.mLeftChanllengeCount = packet:GetUShort()
		sectionObj.mTotalChallengeCount = packet:GetUShort()
		local tiliCostVal = packet:GetUShort()

		-- 显示关卡详情
		self:showSectionDetail(tiliCostVal)
		-- 更新左按钮
		if 1 == self.mLastClickedSectionWidget:getTag() then
			self.mSectionDetailWindow:getChildByName("Panel_Arrow_Animation_Left"):setVisible(false)
		else
			self.mSectionDetailWindow:getChildByName("Panel_Arrow_Animation_Left"):setVisible(true)
		end

		local chapterList = globaldata:getChapterListByLevel(self.mLevel)
		local sectionList = chapterList[self.mLastClickedChapterWidget:getTag()]:getKeyValue("mSectionList")

		-- 更新右按钮
		if #sectionList == self.mLastClickedSectionWidget:getTag() then
			self.mSectionDetailWindow:getChildByName("Panel_Arrow_Animation_Right"):setVisible(false)
		else
			self.mSectionDetailWindow:getChildByName("Panel_Arrow_Animation_Right"):setVisible(true)
		end
	end

	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_GET_SECTION_INFO_, onRequestGetSectionInfo)

	local function requestGetSectionInfo()
		local packet = NetSystem.mNetManager:GetSPacket()
	    packet:SetType(PacketTyper._PTYPE_CS_GET_SECTION_INFO_)
	    packet:PushChar(self.mLevel)
	    packet:PushInt(self.mLastClickedChapterWidget:getTag())
	    packet:PushInt(widget:getTag())
	    packet:Send()
	    GUISystem:showLoading()
	end
	requestGetSectionInfo()
end

-- 更新关卡信息
function PveEntryWindow:updateSectionInfoByLevel(level)
	local chapterList = globaldata:getChapterListByLevel(level)
	local sectionList = chapterList[self.mLastClickedChapterWidget:getTag()]:getKeyValue("mSectionList")

	local function setSectionOpen(widget, opened)
	--	widget:setVisible(opened)
		widget:setTouchEnabled(opened)
	end

	-- 锁住全部
	for i = 1, #self.mSectionWidgetList do
		setSectionOpen(self.mSectionWidgetList[i], false)
		-- 全部隐藏
		for j = 1, 3 do
			self.mSectionWidgetList[i]:getChildByName("Image_Star"..j):setVisible(false)
		end
	end
	-- 开启
	for i = 1, #sectionList do
		setSectionOpen(self.mSectionWidgetList[i], true)
		-- 星星
		local sectionObj = sectionList[i]
		local starCount =  sectionObj:getKeyValue("mCurStarCount")
		-- 显示星星
		for j = 1, starCount do
			self.mSectionWidgetList[i]:getChildByName("Image_Star"..j):setVisible(true)
		end
	end

	-- 未开启的黑白
	local openedCount = #sectionList
	for i = 1, #self.mSectionWidgetList do
		if i <= openedCount then

		else
	--		ShaderManager:DoUIWidgetDisabled(self.mSectionWidgetList[i]:getChildByName("Image_Bg"), true)
		end
	end
end

-- 创建关卡(普通)
function PveEntryWindow:updateSections_Normal()
	local sections = DB_MapUIConfigEasy.getArrDataByField("MapUI_ChapterID", self.mLastClickedChapterWidget:getTag())
	for i = 1, #sections do
		if 0 == sections[i].MapUI_SectionID then
			table.remove(sections, i)
			break
		end
	end
	local sectionNums = #sections

	local function sortFunc(section1, section2)
		return section1.ID < section2.ID
	end
	table.sort(sections, sortFunc)

	for i = 1, sectionNums do
		-- 显示名字
		local sectionImgId = sections[i].MapUI_ChapterIcon
		local sectionImgName = DB_ResourceList.getDataById(sectionImgId).Res_path1

		local sectionNameId = sections[i].MapUI_SectionName
		local sectionName = getDictionaryText(sectionNameId)

		if 0 ~= sectionNameId then
			if self.mSectionWidgetList[i] then
			--	self.mSectionWidgetList[i]:getChildByName("Image_Name"):loadTexture(sectionImgName, 0)
				self.mSectionWidgetList[i]:getChildByName("Label_Name"):setString(sectionName)
			end
		end	
	
		-- 底图
		local imgId = sections[i].MapUI_BackgroundImageID
		local imgName = DB_ResourceList.getDataById(imgId).Res_path1
		if self.mSectionWidgetList[i] then
			self.mSectionWidgetList[i]:getChildByName("Image_Section"):loadTexture(imgName, 1)
		end

		-- 颜色
		if 1 == self.mLevel then
			self.mSectionWidgetList[i]:getChildByName("Image_NameBg"):loadTexture("pve_sectionname_bg_easy.png")
		elseif 2 == self.mLevel then
			self.mSectionWidgetList[i]:getChildByName("Image_NameBg"):loadTexture("pve_sectionname_bg_hard.png")
		end
	end

	local chapterList = globaldata:getChapterListByLevel(self.mLevel)
	if chapterList[self.mLastClickedChapterWidget:getTag()] then -- 章节开启
		local sectionList = chapterList[self.mLastClickedChapterWidget:getTag()]:getKeyValue("mSectionList")
		-- 未开启的黑白
		local openedCount = #sectionList
		for i = 1, #self.mSectionWidgetList do
			if i <= openedCount then
--				ShaderManager:DoUIWidgetDisabled(self.mSectionWidgetList[i]:getChildByName("Image_Section"), false)
				self.mSectionWidgetList[i]:setVisible(true)
				self.mSectionWidgetList[i]:setTouchEnabled(true)
				-- self.mSectionWidgetList[i]:getChildByName("Image_Section"):setVisible(true)
				-- self.mSectionWidgetList[i]:getChildByName("Label_Name"):setVisible(true)
				-- self.mSectionWidgetList[i]:getChildByName("Label_Type"):setVisible(true)
				self.mSectionWidgetList[i]:getChildByName("Panel_Star"):setVisible(true)

				-- 星星
				local sectionObj = sectionList[i]
				local starCount =  sectionObj:getKeyValue("mCurStarCount")

				-- 显示星星
				for j = 1, 3 do
					self.mSectionWidgetList[i]:getChildByName("Image_Star_"..j):loadTexture("public_star2.png")
				end

				for j = 1, starCount do
					self.mSectionWidgetList[i]:getChildByName("Image_Star_"..j):loadTexture("public_star1.png")
				end
			else
--				ShaderManager:DoUIWidgetDisabled(self.mSectionWidgetList[i]:getChildByName("Image_Section"), true)
				self.mSectionWidgetList[i]:setVisible(false)
				self.mSectionWidgetList[i]:setTouchEnabled(false)
				-- self.mSectionWidgetList[i]:getChildByName("Image_Section"):setVisible(false)
				-- self.mSectionWidgetList[i]:getChildByName("Label_Name"):setVisible(false)
				-- self.mSectionWidgetList[i]:getChildByName("Label_Type"):setVisible(false)
				self.mSectionWidgetList[i]:getChildByName("Panel_Star"):setVisible(false)
			end
		end
	else -- 章节未开启
		for i = 1, #self.mSectionWidgetList do
--			ShaderManager:DoUIWidgetDisabled(self.mSectionWidgetList[i]:getChildByName("Image_Section"), true)
			self.mSectionWidgetList[i]:setTouchEnabled(false)
			-- self.mSectionWidgetList[i]:getChildByName("Image_Section"):setVisible(false)
			-- self.mSectionWidgetList[i]:getChildByName("Label_Name"):setVisible(false)
			-- self.mSectionWidgetList[i]:getChildByName("Label_Type"):setVisible(false)
			self.mSectionWidgetList[i]:getChildByName("Panel_Star"):setVisible(false)
		end
	end

	self:updateSectionLevelLimit()
end

-- 更新关卡等级限制
function PveEntryWindow:updateSectionLevelLimit()
	-- 关卡名字和章节名字
	local sections = nil
	local sectionCnt = nil
	if 1 == self.mLevel then
		sectionCnt = 8
		sections = DB_MapUIConfigEasy.getArrDataByField("MapUI_ChapterID", self.mLastClickedChapterWidget:getTag())
	elseif 2 == self.mLevel then
		sectionCnt = 4
		sections = DB_MapUIConfigNormal.getArrDataByField("MapUI_ChapterID", self.mLastClickedChapterWidget:getTag())
	end

	local function doFind(index)
		local chapterInfo = nil
		local sectionInfo = nil
		for i = 1, #sections do
			if 0 == sections[i].MapUI_SectionID then
				chapterInfo = sections[i]
			end
			if index == sections[i].MapUI_SectionID then
				sectionInfo = sections[i]
			end
		end
		return chapterInfo, sectionInfo
	end

	for i = 1, sectionCnt do
		local chapterInfo, sectionInfo = doFind(i)
		local limitLevel = sectionInfo.MapUI_SectionLevelLimit
		if 1 == self.mLevel then
			if limitLevel > globaldata.level then
				self.mSectionWidgetList[i]:getChildByName("Panel_LevelLimit"):setVisible(true)
				self.mSectionWidgetList[i]:getChildByName("Panel_LevelLimit"):getChildByName("Label_LevelLimit"):setString(tostring(limitLevel).."级开放")
				
			else
				self.mSectionWidgetList[i]:getChildByName("Panel_LevelLimit"):setVisible(false)
			end
		elseif 2 == self.mLevel then
			if not globaldata:isChapterFinished(self.mLastClickedChapterWidget:getTag(), 2*i, 1) then
				self.mSectionWidgetList_Hard[i]:getChildByName("Panel_LevelLimit_Hard"):setVisible(true)
				self.mSectionWidgetList_Hard[i]:getChildByName("Panel_LevelLimit_Hard"):getChildByName("Label_LevelLimit"):setString("完成普通"..tostring(self.mLastClickedChapterWidget:getTag()).."-"..tostring(2*i))
			else
				self.mSectionWidgetList_Hard[i]:getChildByName("Panel_LevelLimit_Hard"):setVisible(false)
			end
		end
	end
end

-- 创建关卡(精英)
function PveEntryWindow:updateSections_Hard()
	local sections = DB_MapUIConfigNormal.getArrDataByField("MapUI_ChapterID", self.mLastClickedChapterWidget:getTag())
	for i = 1, #sections do
		if 0 == sections[i].MapUI_SectionID then
			table.remove(sections, i)
			break
		end
	end
	local sectionNums = #sections

	local function sortFunc(section1, section2)
		return section1.ID < section2.ID
	end
	table.sort(sections, sortFunc)

	for i = 1, sectionNums do
		-- 显示名字
		local sectionImgId = sections[i].MapUI_ChapterIcon
		local sectionImgName = DB_ResourceList.getDataById(sectionImgId).Res_path1

		local sectionNameId = sections[i].MapUI_SectionName
		local sectionName = getDictionaryText(sectionNameId)

		if 0 ~= sectionNameId then
			if self.mSectionWidgetList_Hard[i] then
				self.mSectionWidgetList_Hard[i]:getChildByName("Label_Name"):setString(sectionName)
			end
		end	
	
		-- 底图
		local imgId = sections[i].MapUI_BackgroundImageID
		local heroData = DB_HeroConfig.getDataById(imgId)
		local heroImgId = heroData.PicID
		local imgName = DB_ResourceList.getDataById(heroImgId).Res_path1
		if self.mSectionWidgetList_Hard[i] then
			for j = 1, 24 do
				self.mSectionWidgetList_Hard[i]:getChildByName("Image_Section_hero_"..j):setVisible(false)
			end
			self.mSectionWidgetList_Hard[i]:getChildByName("Image_Section_hero_"..imgId):setVisible(true)
			self.mSectionWidgetList_Hard[i]:getChildByName("Image_Section_hero_"..imgId):loadTexture(imgName)
		end

		-- 颜色
		if 1 == self.mLevel then
			self.mSectionWidgetList_Hard[i]:getChildByName("Image_NameBg"):loadTexture("pve_sectionname_bg_easy.png")
		elseif 2 == self.mLevel then
			self.mSectionWidgetList_Hard[i]:getChildByName("Image_NameBg"):loadTexture("pve_sectionname_bg_hard.png")
		end
	end

	local chapterList = globaldata:getChapterListByLevel(self.mLevel)
	if chapterList[self.mLastClickedChapterWidget:getTag()] then -- 章节开启
		local sectionList = chapterList[self.mLastClickedChapterWidget:getTag()]:getKeyValue("mSectionList")
		-- 未开启的黑白
		local openedCount = #sectionList
		for i = 1, #self.mSectionWidgetList_Hard do
			if i <= openedCount then
				for j = 1, 24 do
--					ShaderManager:DoUIWidgetDisabled(self.mSectionWidgetList_Hard[i]:getChildByName("Image_Section_hero_"..j), false)
					self.mSectionWidgetList_Hard[i]:setVisible(true)
				end
				self.mSectionWidgetList_Hard[i]:setTouchEnabled(true)
				self.mSectionWidgetList_Hard[i]:getChildByName("Panel_Star"):setVisible(true)

				-- 星星
				local sectionObj = sectionList[i]
				local starCount =  sectionObj:getKeyValue("mCurStarCount")

				-- 显示星星
				for j = 1, 3 do
					self.mSectionWidgetList_Hard[i]:getChildByName("Image_Star_"..j):loadTexture("public_star2.png")
				end

				for j = 1, starCount do
					self.mSectionWidgetList_Hard[i]:getChildByName("Image_Star_"..j):loadTexture("public_star1.png")
				end
			else
				for j = 1, 24 do
--					ShaderManager:DoUIWidgetDisabled(self.mSectionWidgetList_Hard[i]:getChildByName("Image_Section_hero_"..j), true)
					self.mSectionWidgetList_Hard[i]:setVisible(false)
				end
				self.mSectionWidgetList_Hard[i]:setTouchEnabled(false)
				self.mSectionWidgetList_Hard[i]:getChildByName("Panel_Star"):setVisible(false)
			end
		end
	else -- 章节未开启
		for i = 1, #self.mSectionWidgetList_Hard do
--			ShaderManager:DoUIWidgetDisabled(self.mSectionWidgetList_Hard[i]:getChildByName("Image_Section"), true)
			self.mSectionWidgetList_Hard[i]:setTouchEnabled(false)
			self.mSectionWidgetList_Hard[i]:getChildByName("Panel_Star"):setVisible(false)
		end
	end

	self:updateSectionLevelLimit()
end

-- 创建关卡
function PveEntryWindow:updateSections()
	if 1 == self.mLevel then
		self:updateSections_Normal()
	elseif 2 == self.mLevel then
		self:updateSections_Hard()
	end
end

-- 更新奖励信息(普通)
function PveEntryWindow:updateStarRewardInfo_Normal()
	local chapterList = globaldata:getChapterListByLevel(self.mLevel)
	local chapterObj = chapterList[self.mLastClickedChapterWidget:getTag()]
	local starRewardInfo = chapterObj:getKeyValue("mStarReward")

	local function updateButton(index)
		local btn = nil  -- 层
		if 1 == index then
			btn = self.mRewardPanel_Normal:getChildByName("Panel_Rewards_8")
		elseif 2 == index then
			btn = self.mRewardPanel_Normal:getChildByName("Panel_Rewards_16")
		elseif 3 == index then
			btn = self.mRewardPanel_Normal:getChildByName("Panel_Rewards_24")
		end
		
		
		local needStarCount = starRewardInfo[index][1] -- 需要星星数
		local canGetReward = starRewardInfo[index][2] -- 是否已经获取奖励 0:没有,1：有

		if not self.mRewardAnimList_Normal[index] then
			self.mRewardAnimList_Normal[index] = AnimManager:createAnimNode(8004)
			btn:getChildByName("Panel_Rewards_Animation"):addChild(self.mRewardAnimList_Normal[index]:getRootNode(), 100)
		end

		if 0 == canGetReward then -- 不可领取
			self.mRewardAnimList_Normal[index]:play("pve_rewardsbox1", true)
		elseif 1 == canGetReward then -- 可领取
			self.mRewardAnimList_Normal[index]:play("pve_rewardsbox2", true)
		elseif 2 == canGetReward then -- 已经领取
			self.mRewardAnimList_Normal[index]:play("pve_rewardsbox5", true)
		end	

		-- 请求奖励
		local function requestReward(widget)
			local function requestGetInfo() -- 请求获取信息
				local packet = NetSystem.mNetManager:GetSPacket()
				packet:SetType(PacketTyper._PTYPE_CS_STARREWARD_INFO_)
				packet:PushChar(self.mLevel) 	-- 关卡级别
				packet:PushInt(chapterObj:getKeyValue("mChapterId")) -- 章节Id
				packet:PushChar(widget:getTag()) -- 第几个奖励
				packet:Send()
				
				globaldata.mLastGetRewardChapterId = chapterObj:getKeyValue("mChapterId")
				globaldata.mLastGetRewardIndex = widget:getTag()
			end
			
			if 1 == canGetReward then -- 可领取
				self.mRewardAnimList_Normal[index]:play("pve_rewardsbox3", false, requestGetInfo)
			elseif 0 == canGetReward then -- 不可领取
				requestGetInfo()
			elseif 2 == canGetReward then -- 已经领去
				requestGetInfo()
			end
			GUISystem:showLoading()

			if PveGuideFour:canGuide() then
				PveGuideFour:stop()
			end
		end
		btn:setTag(index)
		registerWidgetReleaseUpEvent(btn, requestReward)
	end
	-- 更新按钮信息
	for i = 1, 3 do
		updateButton(i)
	end

	-- 进度条
	local curStartCount = 0
	for i = 1, #chapterObj.mSectionList do
		curStartCount = chapterObj.mSectionList[i].mCurStarCount + curStartCount
	end
	local percent = curStartCount*100/24
	self.mRewardPanel_Normal:getChildByName("ProgressBar_MapRewards"):setPercent(percent)

	self.mRewardPanel_Normal:getChildByName("Label_Rewards_Num"):setString(tostring(curStartCount)..tostring("/24"))

	PveNoticeInnerImpl:doUpdate()
end

-- 更新奖励信息(精英)
function PveEntryWindow:updateStarRewardInfo_Hard()
	local chapterList = globaldata:getChapterListByLevel(self.mLevel)
	local chapterObj = chapterList[self.mLastClickedChapterWidget:getTag()]
	local starRewardInfo = chapterObj:getKeyValue("mStarReward")

	local function updateButton(index)
		local btn = nil  -- 层
		if 1 == index then
			btn = self.mRewardPanel_Hard:getChildByName("Panel_Rewards_4")
		elseif 2 == index then
			btn = self.mRewardPanel_Hard:getChildByName("Panel_Rewards_12")
		end
		
		
		local needStarCount = starRewardInfo[index][1] -- 需要星星数
		local canGetReward = starRewardInfo[index][2] -- 是否已经获取奖励 0:没有,1：有

		if not self.mRewardAnimList_Hard[index] then
			self.mRewardAnimList_Hard[index] = AnimManager:createAnimNode(8004)
			btn:getChildByName("Panel_Rewards_Animation"):addChild(self.mRewardAnimList_Hard[index]:getRootNode(), 100)
		end

		if 0 == canGetReward then -- 不可领取
			self.mRewardAnimList_Hard[index]:play("pve_rewardsbox1", true)
		elseif 1 == canGetReward then -- 可领取
			self.mRewardAnimList_Hard[index]:play("pve_rewardsbox2", true)
		elseif 2 == canGetReward then -- 已经领取
			self.mRewardAnimList_Hard[index]:play("pve_rewardsbox5", true)
		end	

		-- 请求奖励
		local function requestReward(widget)
			local function requestGetInfo() -- 请求获取信息
				local packet = NetSystem.mNetManager:GetSPacket()
				packet:SetType(PacketTyper._PTYPE_CS_STARREWARD_INFO_)
				packet:PushChar(self.mLevel) 	-- 关卡级别
				packet:PushInt(chapterObj:getKeyValue("mChapterId")) -- 章节Id
				packet:PushChar(widget:getTag()) -- 第几个奖励
				packet:Send()
				
				globaldata.mLastGetRewardChapterId = chapterObj:getKeyValue("mChapterId")
				globaldata.mLastGetRewardIndex = widget:getTag()
			end
			
			if 1 == canGetReward then -- 可领取
				GUISystem:showLoading()
				self.mRewardAnimList_Hard[index]:play("pve_rewardsbox3", false, requestGetInfo)
			elseif 0 == canGetReward then -- 不可领取
				requestGetInfo()
			end
		end
		btn:setTag(index)
		registerWidgetReleaseUpEvent(btn, requestReward)
	end
	-- 更新按钮信息
	for i = 1, 2 do
		updateButton(i)
	end

	-- 进度条
	local curStartCount = 0
	for i = 1, #chapterObj.mSectionList do
		curStartCount = chapterObj.mSectionList[i].mCurStarCount + curStartCount
	end
	local percent = curStartCount*100/12
	self.mRewardPanel_Hard:getChildByName("ProgressBar_MapRewards"):setPercent(percent)

	self.mRewardPanel_Hard:getChildByName("Label_Rewards_Num"):setString(tostring(curStartCount)..tostring("/12"))

	PveNoticeInnerImpl:doUpdate()
end

function PveEntryWindow:updateStarRewardInfo()
	if 1 == self.mLevel then
		self:updateStarRewardInfo_Normal()
	elseif 2 == self.mLevel then
		self:updateStarRewardInfo_Hard()
	end
end

function PveEntryWindow:setBonusWidgetVisible(visible)
	self.mRootWidget:getChildByName("Label_Star"):setVisible(visible)
	self.mRootWidget:getChildByName("Image_ProBg"):setVisible(visible)
end

-- 点击章节
function PveEntryWindow:onClickedChapter(widget,bSound, fromLevelbtn)
	if bSound == nil then GUISystem:playSound("tabPageSound") end
	if self.mLastClickedChapterWidget == widget and nil == fromLevelbtn then
		return 
	end

	local chapterList = globaldata:getChapterListByLevel(self.mLevel)
	if nil == chapterList[widget:getTag()] or 0 == #chapterList[widget:getTag()].mSectionList then
		MessageBox:showMessageBox1("关卡还未开启~")
		return
	end

	-- 关卡名字和章节名字
	local limitLevel = chapterLimitLevelTbl[widget:getTag()]
	if limitLevel > globaldata.level then
		MessageBox:showMessageBox1("挑战当前章节需要等级:"..limitLevel)
	end

	for i = 1, 10 do
		if 1 == self.mLevel then
			if isChapterFinished(i, self.mLevel) then
				self.mRootWidget:getChildByName("Image_Chapter_"..tostring(i)):loadTexture("pve_chapter_bg_easy_3.png")
			else
				self.mRootWidget:getChildByName("Image_Chapter_"..tostring(i)):loadTexture("pve_chapter_bg_easy_1.png")
			end
		elseif 2 == self.mLevel then
			if isChapterFinished(i, self.mLevel) then
				self.mRootWidget:getChildByName("Image_Chapter_"..tostring(i)):loadTexture("pve_chapter_bg_hard_3.png")
			else
				self.mRootWidget:getChildByName("Image_Chapter_"..tostring(i)):loadTexture("pve_chapter_bg_hard_1.png")
			end
		end
	end

	if self.mLastClickedChapterWidget then
		if 1 == self.mLevel then
			if isChapterFinished(self.mLastClickedChapterWidget:getTag(), self.mLevel) then
				self.mRootWidget:getChildByName("Image_Chapter_"..tostring(self.mLastClickedChapterWidget:getTag())):loadTexture("pve_chapter_bg_easy_3.png")
			else
				self.mRootWidget:getChildByName("Image_Chapter_"..tostring(self.mLastClickedChapterWidget:getTag())):loadTexture("pve_chapter_bg_easy_1.png")
			end
		elseif 2 == self.mLevel then
			if isChapterFinished(self.mLastClickedChapterWidget:getTag(), self.mLevel) then
				self.mRootWidget:getChildByName("Image_Chapter_"..tostring(self.mLastClickedChapterWidget:getTag())):loadTexture("pve_chapter_bg_hard_3.png")
			else
				self.mRootWidget:getChildByName("Image_Chapter_"..tostring(self.mLastClickedChapterWidget:getTag())):loadTexture("pve_chapter_bg_hard_1.png")
			end
		end 
	end
	self.mLastClickedChapterWidget = widget

	self.mCurAnimNode = AnimManager:createAnimNode(8012)
	self.mLastClickedChapterWidget:getChildByName("Panel_Animation"):addChild(self.mCurAnimNode:getRootNode(), 100)
	self.mCurAnimNode:play("pve_chapter_chosen", false)
	
	if 1 == self.mLevel then
		self.mLastClickedChapterWidget:loadTexture("pve_chapter_bg_easy_2.png")
	elseif 2 == self.mLevel then
		self.mLastClickedChapterWidget:loadTexture("pve_chapter_bg_hard_2.png")
	end 

	-- 更新关卡信息
	self:updateSections()

	-- 更新奖励信息
	self:updateStarRewardInfo()

	-- 控制特效是否显示
	if self.mCurSectionAnimNode then
		if self.mLastClickedChapterWidget:getTag() == globaldata.curChapterId[self.mLevel] then
			self.mCurSectionAnimNode:setVisible(true)
		else
			self.mCurSectionAnimNode:setVisible(false)
		end
	end

end

-- 设置选中状态
function PveEntryWindow:setWidgetSelected(widget, selected)
	widget:getChildByName("Image_Selected"):setVisible(selected)
	local blackImg = widget:getChildByName("Image_Unselected")
	if blackImg then
	blackImg:setVisible(not selected)
	end
end

-- 创建章节
function PveEntryWindow:initChapters()
	for i = 1, 10 do
		self.mChapterWidgetList[i] = self.mChapterWindow:getChildByName("Image_Chapter_"..tostring(i))
		self.mChapterWidgetList[i]:setTag(i)
		registerWidgetReleaseUpEvent(self.mChapterWidgetList[i], handler(self, self.onClickedChapter))
	end
end

function PveEntryWindow:setCurAnimNode()
	if self.mCurSectionAnimNode then
		self.mCurSectionAnimNode:destroy()
		self.mCurSectionAnimNode = nil
	end

	if 1 == self.mLevel then -- 普通
		if self.mLastClickedChapterWidget:getTag() == globaldata.curChapterId[self.mLevel] then
			local index = globaldata.curSectionId[self.mLevel]
			local function xxx()
		--		doError("easy_new")
				self.mCurSectionAnimNode:play("pve_section_"..tostring(index).."_new", true)
			end
			self.mCurSectionAnimNode = AnimManager:createAnimNode(8019)
			local parentNode = self.mSectionWidgetList[index]
			if parentNode then
		--		doError("easy_open")
				parentNode:getChildByName("Panel_Section_Animation"):addChild(self.mCurSectionAnimNode:getRootNode(), 100)
				self.mCurSectionAnimNode:play("pve_section_"..tostring(index).."_open", false, xxx)
			end
		end
	elseif 2 == self.mLevel then
		if self.mLastClickedChapterWidget:getTag() == globaldata.curChapterId[self.mLevel] then
			local index = globaldata.curSectionId[self.mLevel]
			local function xxx()
		--		doError("hard_new")
				self.mCurSectionAnimNode:play("pvehard_section_new", true)
			end
			self.mCurSectionAnimNode = AnimManager:createAnimNode(8043)
			local parentNode = self.mSectionWidgetList_Hard[index]
			if parentNode then
				parentNode:getChildByName("Panel_Section_Animation"):addChild(self.mCurSectionAnimNode:getRootNode(), 100)
		--		doError("hard_open")
				self.mCurSectionAnimNode:play("pvehard_section_open", false, xxx)
			end
		end	
	end
end

-- 创建关卡
function PveEntryWindow:initSections()
	for i = 1, 8 do
		self.mSectionWidgetList[i] = self.mSectionWindow:getChildByName("Panel_Section_"..tostring(i))
		self.mSectionWidgetList[i]:setTag(i)
		registerWidgetReleaseUpEvent(self.mSectionWidgetList[i], handler(self, self.onClickedSection))

		local function onActEnd()
			if 1 == self.mLevel then
				self:setCurAnimNode()
			end
		end

		self.mSectionWidgetList[i]:setAnchorPoint(cc.p(0.5, 0.5))
		self.mSectionWidgetList[i]:setOpacity(0)
		local act0 = cc.DelayTime:create(0.1*i)
		local act1 = cc.FadeIn:create(0.5)
		local act2 = cc.CallFunc:create(onActEnd)

		self.mSectionWidgetList[i]:stopAllActions()
		self.mSectionWidgetList[i]:setOpacity(0)

		if 8 ~= i then
			self.mSectionWidgetList[i]:runAction(cc.Sequence:create(act0, act1))
		else
			self.mSectionWidgetList[i]:runAction(cc.Sequence:create(act0, act1, act2))
		end
	end

	for i = 1, 4 do
		self.mSectionWidgetList_Hard[i] = self.mSectionWindow_Hard:getChildByName("Panel_Section_"..tostring(i))
		self.mSectionWidgetList_Hard[i]:setTag(i)
		registerWidgetReleaseUpEvent(self.mSectionWidgetList_Hard[i], handler(self, self.onClickedSection))

		local function onActEnd()
			if 2 == self.mLevel then
				self:setCurAnimNode()
			end
		end

		self.mSectionWidgetList_Hard[i]:setAnchorPoint(cc.p(0.5, 0.5))
		self.mSectionWidgetList_Hard[i]:setOpacity(0)
		local act0 = cc.DelayTime:create(0.1*i)
		local act1 = cc.FadeIn:create(0.5)
		local act2 = cc.CallFunc:create(onActEnd)

		self.mSectionWidgetList_Hard[i]:stopAllActions()
		self.mSectionWidgetList_Hard[i]:setOpacity(0)

		if 4 ~= i then
			self.mSectionWidgetList_Hard[i]:runAction(cc.Sequence:create(act0, act1))
		else
			self.mSectionWidgetList_Hard[i]:runAction(cc.Sequence:create(act0, act1, act2))
		end
	end
end

-- 更新关卡信息
function PveEntryWindow:updateChapterInfoByLevel(level)
	local chapterList = globaldata:getChapterListByLevel(level)

	local function setChapterOpen(widget, opened)
		if opened then
	--		widget:getChildByName("Image_Unselected"):loadTexture("pve_section_pus1.png")
		else
	--		widget:getChildByName("Image_Unselected"):loadTexture("pve_chapter_clock.png")
		end
		widget:getChildByName("Image_Lock"):setVisible(not opened)
		widget:getChildByName("Label_Name"):setVisible(opened)
		widget:setTouchEnabled(opened)
	end

	-- 锁住全部
	for i = 1, #self.mChapterWidgetList do
		setChapterOpen(self.mChapterWidgetList[i], false)
		-- 星星
		self.mChapterWidgetList[i]:getChildByName("Label_StarNum"):setString("0/0")
		-- 文字

	end
	-- 开启
	for i = 1, #chapterList do
		local curCount = chapterList[i]:getCurStarCount()
		local totalCount = chapterList[i]:getKeyValue("mTotalStarCount")
		setChapterOpen(self.mChapterWidgetList[i], true)
		-- 星星
		self.mChapterWidgetList[i]:getChildByName("Label_StarNum"):setString(tostring(curCount).."/"..tostring(totalCount))
	end
end

function PveEntryWindow:onChapterInfoChanged()
	if self.mSectionDetailWindow then
		-- 剩余挑战次数
		local chapterList = globaldata:getChapterListByLevel(self.mLevel)
		local sectionList = chapterList[self.mLastClickedChapterWidget:getTag()]:getKeyValue("mSectionList")
		local sectionObj = sectionList[self.mLastClickedSectionWidget:getTag()]
		local leftCount = sectionObj:getKeyValue("mLeftChanllengeCount")
		local totalCount = sectionObj:getKeyValue("mTotalChallengeCount")
		self.mSectionDetailWindow:getChildByName("Label_TimesNum"):setString(tostring(leftCount).."/"..tostring(totalCount))

		-- 刷新扫荡次数
		local btn = self.mSectionDetailWindow:getChildByName("Button_Saodang10")
		if 1 == self.mLevel then -- 普通
			if leftCount >=10 then
				btn:getChildByName("Label_SaoDangMore_Stroke_7_43_95"):setString("通关10次")
			else
				btn:getChildByName("Label_SaoDangMore_Stroke_7_43_95"):setString("通关"..tostring(leftCount).."次")
			end
		elseif 2 == self.mLevel then -- 精英
			btn:getChildByName("Label_SaoDangMore_Stroke_7_43_95"):setString("通关"..tostring(leftCount).."次")
		end

		self.mCurChallCount = leftCount
	end
end

-- 客户端请求扫荡
function PveEntryWindow:requestDoSaodang(widget)
	GUISystem:playSound("homeBtnSound")

	if globaldata.level < 13 then
		MessageBox:showMessageBox1("13级开放快速通关~")
		return 
	end

	local saodangCount = widget:getTag()
	-- local ticket = globaldata:getItemInfo(nil, 20015)
	-- local ticketCount = 0
	-- if ticket then
	-- 	ticketCount = ticket:getKeyValue("itemNum")
	-- end

	if 2 == self.mLevel and 10 == saodangCount then
		saodangCount = 3
	end

	if 3 == saodangCount or 10 == saodangCount then
		if self.mCurChallCount <= saodangCount then
			saodangCount = self.mCurChallCount
		end
	end

	-- 判断体力
	if globaldata.vatality  < self.mCurSectionObject.MapUI_PhysicalCost * saodangCount then
		local goodsType  = 0 -- 0:体力 1:耐力 2:点金
		local packet = NetSystem.mNetManager:GetSPacket()
	    packet:SetType(PacketTyper._PTYPE_CS_REQUEST_BUYCONSUME_)
	--    packet:PushChar(goodsType)
	--    packet:PushInt(1)
	    packet:Send()
	    GUISystem:showLoading()
		return
	end

	-- -- 判断扫荡次数
	-- if 0 == ticketCount then
	-- 	MessageBox:showMessageBox1("老妹儿，你的电影票好像不够哟~")
	-- 	return
	-- end

	local packet = NetSystem.mNetManager:GetSPacket()
	packet:SetType(PacketTyper._PTYPE_CS_REQUEST_SAODANG_)
	packet:PushChar(self.mLastClickedLevelWidget:getTag())
	packet:PushInt(self.mLastClickedChapterWidget:getTag())
	packet:PushInt(self.mLastClickedSectionWidget:getTag())
	packet:PushChar(saodangCount)
	packet:Send()
	GUISystem:showLoading()
end

-- 扫荡回包
function PveEntryWindow:onRequestDoSaodang(msgPacket)
	GUISystem:disableUserInput()
--	print("扫荡成功")
	local rewardWindow = GUIWidgetPool:createWidget("PVE_SaodangReward") 
	-- 普通奖励
	local rewardCount = msgPacket:GetChar()
	local rewardInfoTbl = {}
	for i = 1, rewardCount do
		rewardInfoTbl[i] = {}
		rewardInfoTbl[i].money = msgPacket:GetInt()
		rewardInfoTbl[i].exp = msgPacket:GetInt()
		rewardInfoTbl[i].itemNum = msgPacket:GetUShort()
		rewardInfoTbl[i].itemTbl = {}
		for j = 1, rewardInfoTbl[i].itemNum do
			rewardInfoTbl[i].itemTbl[j] = {}
			rewardInfoTbl[i].itemTbl[j].itemType = msgPacket:GetInt()
			rewardInfoTbl[i].itemTbl[j].itemId = msgPacket:GetInt()
			rewardInfoTbl[i].itemTbl[j].itemCount = msgPacket:GetInt()
		end
	end

	-- 额外奖励
	local extraCount = msgPacket:GetUShort()
	local extraReward = {}
	for i = 1, extraCount do
		extraReward[i] = {}
		extraReward[i].itemType = msgPacket:GetInt()
		extraReward[i].itemId = msgPacket:GetInt()
		extraReward[i].itemCount = msgPacket:GetInt()
	end

	local function closeWindow()
		GUISystem:playSound("homeBtnSound")
		rewardWindow:removeFromParent(true)
	end
	registerWidgetReleaseUpEvent(rewardWindow:getChildByName("Button_Close"), closeWindow)

	self.mRootNode:addChild(rewardWindow, 500)

	local outerSz = rewardWindow:getChildByName("Panel_Pos"):getContentSize()
	local panelWgt = rewardWindow:getChildByName("Panel_Reward")
	local panelSz = panelWgt:getContentSize()
	local rewardSz = GUIWidgetPool:createWidget("PVE_SaodangContent"):getContentSize()
	local addedRwardCnt = 0
	local moveTime = 0.05
	local text = {"一", "二", "三", "四", "五", "六", "七", "八", "九", "十", "十一"}
	local iconDelay = 0.2
	local bigScaleVal = 1.3 -- 图标放大倍数
	local interVal = 10 -- 奖励条竖向间隔

	-- 添加奖励
	local function addRewardWidget()	
		-- 修正大小
	--	panelWgt:setContentSize(cc.size(panelSz.width, rewardSz.height*(rewardCount+extraCount) + interVal*(rewardCount+extraCount-1) + 25))

		-- 重置Panel_Reward位置
		panelWgt:setPosition(cc.p(0, -panelSz.height + outerSz.height))

		-- 真实的添加奖励函数
		local function addRewardImpl()
			addedRwardCnt = addedRwardCnt + 1
			if addedRwardCnt > rewardCount + extraCount then -- 所有奖励已经全部添加完
			--	GUISystem:enableUserInput()
				return
			end

			-- 添加额外奖励
			local function addExtraWidget()
				-- 添加奖励控件
				local curPos = cc.p(25, panelSz.height - rewardSz.height*addedRwardCnt - interVal*(addedRwardCnt-1) + 25)
				local rewardWidget = GUIWidgetPool:createWidget("PVE_SaodangContent")
				panelWgt:addChild(rewardWidget)
				rewardWidget:setPosition(curPos)

				local function updateRewardInfo()
					rewardWidget:getChildByName("Panel_Reward"):setVisible(false)
					rewardWidget:getChildByName("Panel_LastReward"):setVisible(true)
				end
				updateRewardInfo()

				local function addIconWidget()
					local function onActEnd()
						-- 关闭按钮显示
						local actWidget = rewardWindow:getChildByName("Button_Close")
						actWidget:setVisible(true)
						local act0 = cc.Sequence:create(cc.ScaleTo:create(0.2, 1.1), cc.ScaleTo:create(0.05, 1.0)) -- 动作
						actWidget:runAction(act0)
						GUISystem:enableUserInput()
					end

					-- 添加icon
					for i = 1, extraCount do
						local itemType = extraReward[i].itemType
						local itemId = extraReward[i].itemId
						local itemCount = extraReward[i].itemCount
						local itemWidget = createCommonWidget(itemType, itemId, itemCount)

						local container = rewardWidget:getChildByName("Panel_LastReward"):getChildByName("Panel_Reward_"..tostring(i))
						container:addChild(itemWidget)
					--	container:setVisible(false)
					--	local scaleVal = container:getScale()
					--	local act0 = cc.DelayTime:create((i-1)*iconDelay) -- 延迟
					--	local act1 = cc.Show:create() -- 显示
					--	local act2 = cc.Sequence:create(cc.ScaleTo:create(0.2, scaleVal*bigScaleVal), cc.ScaleTo:create(0.05, scaleVal)) -- 动作
						local act3 = cc.CallFunc:create(onActEnd)
					--	container:runAction(cc.Sequence:create(act0, act1, act2, act3))
						container:runAction(act3)
					end
				end

				local actWidget = rewardWidget:getChildByName("Panel_InnerContainer")
				actWidget:setScale(0.8)
				local act0 = cc.Sequence:create(cc.ScaleTo:create(0.2, 1.1), cc.ScaleTo:create(0.05, 1.0))
				local act1 = cc.DelayTime:create(delayTime)
				local act2 = cc.CallFunc:create(addIconWidget)
				actWidget:runAction(cc.Sequence:create(act0, act1, act2))
			end

			-- 添加普通奖励
			local function addWidget()
				-- 添加奖励控件
				local curPos = cc.p(25, panelSz.height - rewardSz.height*addedRwardCnt - interVal*(addedRwardCnt-1) + 25)
				local rewardWidget = GUIWidgetPool:createWidget("PVE_SaodangContent")
				panelWgt:addChild(rewardWidget)
				rewardWidget:setPosition(curPos)

				local function addIconWidget()
					local money = rewardInfoTbl[addedRwardCnt].money
					local exp = rewardInfoTbl[addedRwardCnt].exp
					-- 金币
					local function addMoney()
						local container = rewardWidget:getChildByName("Panel_Reward_1")
						local iconWidget = createCommonWidget(2, nil, money)
						container:addChild(iconWidget)
					--	container:setVisible(false)
					--	local scaleVal = container:getScale()
					--	local act0 = cc.DelayTime:create(0*iconDelay) -- 延迟
					--	local act1 = cc.Show:create() -- 显示
					--	local act2 = cc.Sequence:create(cc.ScaleTo:create(0.2, scaleVal*bigScaleVal), cc.ScaleTo:create(0.05, scaleVal)) -- 动作
					--	container:runAction(cc.Sequence:create(act0, act1, act2))
					end
					addMoney()

					-- 经验
					local function addExp()
						local container = rewardWidget:getChildByName("Panel_Reward_2")
						local iconWidget = createCommonWidget(4, nil, exp)
						container:addChild(iconWidget)
					--	container:setVisible(false)
					--	local scaleVal = container:getScale()
					--	local act0 = cc.DelayTime:create(1*iconDelay) -- 延迟
					--	local act1 = cc.Show:create()
					--	local act2 = cc.Sequence:create(cc.ScaleTo:create(0.2, scaleVal*bigScaleVal), cc.ScaleTo:create(0.05, scaleVal))
					--	container:runAction(cc.Sequence:create(act0, act1, act2))
					end
					addExp()

					-- 奖励物品
					local itemNum = rewardInfoTbl[addedRwardCnt].itemNum
					if itemNum > 3 then
						itemNum = 3
					end
					for j = 1, itemNum do
						local itemType = rewardInfoTbl[addedRwardCnt].itemTbl[j].itemType
						local itemId = rewardInfoTbl[addedRwardCnt].itemTbl[j].itemId
						local itemCount = rewardInfoTbl[addedRwardCnt].itemTbl[j].itemCount
						local itemWidget = createCommonWidget(itemType, itemId, itemCount)
						print(itemType, itemId, itemCount)
						local lblWidget = itemWidget:getChildByName("Label_Count_Stroke")
						-- 数量
						if 1 ~= itemType then
							lblWidget:setVisible(true)
							lblWidget:setString(tostring(itemCount))
						else
							lblWidget:setVisible(false)
						end
						if j <= 3 then
							local function addItemWidget()
								local container = rewardWidget:getChildByName("Panel_Reward"):getChildByName("Panel_Reward_"..tostring(j+2))
								container:addChild(itemWidget)
							--	container:setVisible(false)
								local function nothing()
								end
								local scaleVal = container:getScale()
							--	local act0 = cc.DelayTime:create((j+1)*iconDelay) -- 延迟
							--	local act1 = cc.Show:create() -- 显示
							--	local act2 = cc.Sequence:create(cc.ScaleTo:create(0.2, scaleVal*bigScaleVal), cc.ScaleTo:create(0.05, scaleVal)) -- 动作
								local act3 = cc.CallFunc:create(addRewardImpl)
								if j ~= itemNum then
							--		container:runAction(cc.Sequence:create(act0, act1, act2))
								else
							--		container:runAction(cc.Sequence:create(act0, act1, act2, act3))
									container:runAction(act3)
								end
							end
							addItemWidget()
						end
					end
				end

				local function updateRewardInfo()
					rewardWidget:getChildByName("Panel_Reward"):setVisible(true)
					rewardWidget:getChildByName("Panel_LastReward"):setVisible(false)
					-- 名字
					local text = "第"..text[addedRwardCnt].."次"
					rewardWidget:getChildByName("Panel_Reward"):getChildByName("Label_Name"):setString(text)
				end
				updateRewardInfo()

				local actWidget = rewardWidget:getChildByName("Panel_InnerContainer")
				actWidget:setScale(0.8)
				local act0 = cc.Sequence:create(cc.ScaleTo:create(0.2, 1.1), cc.ScaleTo:create(0.05, 1.0))
				local act1 = cc.DelayTime:create(delayTime)
				local act2 = cc.CallFunc:create(addIconWidget)
				actWidget:runAction(cc.Sequence:create(act0, act1, act2))
			end

			if addedRwardCnt <= 2 then -- 不滑动
				if 2 == addedRwardCnt and 1 == rewardCount then -- 发现是单次扫荡
					addExtraWidget()
					return
				end
				addWidget()
			else -- 向上滑动
				-- 滑动结束回调
				local function onScrollEnd()

					if extraCount > 0 and addedRwardCnt == rewardCount + extraCount then -- 额外奖励
						addExtraWidget()
					else -- 普通奖励
						addWidget()
					end
				end
				-- 滑动
				local function doScroll()
				--	local act0 = cc.EaseOut:create(cc.MoveBy:create(moveTime, cc.p(0, rewardSz.height+interVal)), 3)
					local act0 = cc.MoveBy:create(moveTime, cc.p(0, rewardSz.height+interVal))
					local act1 = cc.CallFunc:create(onScrollEnd)
					panelWgt:runAction(cc.Sequence:create(act0, act1))
				end
				doScroll()
			end
		end
		addRewardImpl()
	end
	addRewardWidget()
	rewardWindow:getChildByName("Button_Close"):setVisible(false)

	GUISystem:hideLoading()
	-- 屏蔽用户输入
	-- 初始化滑动
	local function initSelfScrollFunc()
		local innerSz = rewardWindow:getChildByName("Panel_Reward"):getContentSize()
		local outerSz = rewardWindow:getChildByName("Panel_Pos"):getContentSize()

		-- 触摸初始位置
		local startTouchPos = nil
		-- 触摸滑动位置
		local moveTouchPos = nil

		-- 层初始Y坐标
		local startPanelPosY = nil
		local movePanelPosY = nil

		local function onTouch(widget, eventType)
	    	if eventType == ccui.TouchEventType.began then
	     		startPanelPosY = widget:getPositionY()
	     		startTouchPos = widget:getTouchBeganPosition()
	    	elseif eventType == ccui.TouchEventType.ended then
	    	elseif eventType == ccui.TouchEventType.moved then
	        	moveTouchPos = widget:getTouchMovePosition()
	        	movePanelPosY = widget:getPositionY()
	        	local deltaY = moveTouchPos.y - startTouchPos.y
	        	-- 更新位置
	        	movePanelPosY = startPanelPosY + deltaY
	        	widget:setPositionY(movePanelPosY)
	        	-- 修正坐标
	        --	if widget:getPositionY() >=0 then
	        --		widget:setPositionY(0)
	        	if widget:getPositionY() >= (rewardSz.height*(rewardCount+extraCount) + interVal*(rewardCount+extraCount-1) + 25) - innerSz.height  then
	        		widget:setPositionY((rewardSz.height*(rewardCount+extraCount) + interVal*(rewardCount+extraCount-1) + 25) - innerSz.height)
	        	elseif widget:getPositionY() <= outerSz.height - innerSz.height then
	        		widget:setPositionY(outerSz.height - innerSz.height)
	        	end
	    	elseif eventType == ccui.TouchEventType.canceled then
	        
	    	end
	    end
	    rewardWindow:getChildByName("Panel_Reward"):addTouchEventListener(onTouch)
	end
	if rewardCount + extraCount >= 3 then
		initSelfScrollFunc()
	end
end


function PveEntryWindow:onScrollViewEvent(sender, evenType)
	local widget = self.mRootWidget:getChildByName("ScrollView_Chapter")
	local contentSize = widget:getContentSize()
	local innerSize = widget:getInnerContainerSize()
	local innerWidget = widget:getInnerContainer()
	local innerPosY = innerWidget:getPositionY()

	self.mRootWidget:getChildByName("Image_Edge_1"):setVisible(false)
	self.mRootWidget:getChildByName("Image_Edge_2"):setVisible(false)

	if 0 == innerPosY then
		self.mRootWidget:getChildByName("Image_Edge_1"):setVisible(true)
	elseif contentSize.height - innerSize.height == innerPosY then
		self.mRootWidget:getChildByName("Image_Edge_2"):setVisible(true)
	else
		self.mRootWidget:getChildByName("Image_Edge_1"):setVisible(true)
		self.mRootWidget:getChildByName("Image_Edge_2"):setVisible(true)
	end
end

function PveEntryWindow:Destroy()
	-- 关闭定时器
	-- if self.mSchedulerHandler then
	-- 	local scheduler = cc.Director:getInstance():getScheduler()
	-- 	scheduler:unscheduleScriptEntry(self.mSchedulerHandler)
	-- 	self.mSchedulerHandler = nil
	-- end

	if not self.mIsLoaded then return end
	self.mIsLoaded = false
	GUIEventManager:unregister("chapterInfoChanged", self.onChapterInfoChanged)
	GUIEventManager:unregister("itemInfoChanged", self.updateDetailInfo)
	GUIEventManager:unregister("starRewardGot", self.updateStarRewardInfo)

	for i = 1, #self.mRewardAnimList_Normal do
		self.mRewardAnimList_Normal[i]:destroy()
		self.mRewardAnimList_Normal[i] = nil
	end

	for i = 1, #self.mRewardAnimList_Hard do
		self.mRewardAnimList_Hard[i]:destroy()
		self.mRewardAnimList_Hard[i] = nil
	end

	if self.mCurSectionAnimNode then
		self.mCurSectionAnimNode:destroy()
		self.mCurSectionAnimNode = nil
	end

	self.mEvent = nil

	processTouchPanel = nil

	self.mTopRoleInfoPanel:destroy()
	self.mTopRoleInfoPanel = nil

	self.mRootNode:removeFromParent(true)
	self.mRootNode = nil
	self.mRootWidget = nil

	self.mIsMoveing = nil
	
	self.mChapterScrollWidget =	nil
	self.mSectionScrollWidget =	nil
	self.mChapterWidgetList = {}
	self.mSectionWidgetList	= {}
	self.mPanelSectionInfo = nil
	-------------------------------------------------------
	self.mLastClickedChapterWidget = nil
	self.mLastClickedSectionWidget = nil
	self.mLastClickedLevelWidget = nil
	-------------------------------------------------------
	self.mSectionOpened = false
	-------------
	TextureSystem:unloadPlist_pvesection()
	CommonAnimation.clearAllTextures()
	cclog("=====PveEntryWindow:Destroy=====")
end

function PveEntryWindow:DisableDraw()
	if self.mRootWidget then
		self.mRootWidget:setVisible(false)
	end
end

function PveEntryWindow:EnableDraw()
	if self.mRootWidget then
		self.mRootWidget:setVisible(true)
	end
end


function PveEntryWindow:onEventHandler(event)
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

return PveEntryWindow

