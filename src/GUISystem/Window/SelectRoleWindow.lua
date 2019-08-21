-- Name: 	SelectRoleWindow
-- Func：	战前选人界面
-- Author:	WangShengdong
-- Data:	14-12-9

local schoolNums = 6
local heroNums = 10
local delayMoveTime = 0.15 		-- 从点击英雄到松手出发挪动最长时间
local delayTime = 0.3 			-- 从点击英雄到响应滑动所需时间

--[[
	"BrowseHero"		-- 浏览英雄
	"ChooseHero"		-- 选中英雄
	"ChooseBattleHero"	-- 选中已经上阵英雄
]]

local user_state = 
{
	mState 						= 	"BrowseHero",
	mPos 						= 	nil,
	mAnim						=	nil,
	mRow 						=	nil,
	mColumn						=	nil,
	mLastClickBattleHeroIndex 	= 	nil,
}

local HeroItem = {}

function HeroItem:new(rootWidget)
	local o = 
	{
		mRootWidget = 	rootWidget,
		mHeroWidget = 	nil,
		mFromPos	=	nil,	-- 英雄上阵后，记录原始位置
		mHeroId     =	nil,	-- 英雄动画Id
		mExist		=	true,	-- 玩家是否拥有
	}
	o = newObject(o, HeroItem)
	return o
end

function HeroItem:getRootWidget()
	return self.mRootWidget
end

function HeroItem:isHeroAnimVisible()
	return self.mHeroWidget:isVisible()
end

-- 设置英雄是否可见
function HeroItem:setHeroAnimVisible(val)
	self.mHeroWidget:setVisible(val)
end

function HeroItem:getContentSize()
	return self.mRootWidget:getContentSize()
end

-- 是否存在英雄动画
function HeroItem:isHeroExist()
	return self.mHeroWidget
end

function HeroItem:addHero(heroId)
	self.mHeroId = heroId
	self.mHeroWidget = FightSystem.mRoleManager:CreateSpine(heroId)
	self.mRootWidget:addChild(self.mHeroWidget)
	self.mHeroWidget:setScale(0.7)
	self.mHeroWidget:setPosition(cc.p(60, 5))

	if not globaldata:isHeroIdExist(heroId) then
		ShaderManager:Stone_spine(self.mHeroWidget)
		self.mExist = false
	end
end

function HeroItem:isExist()
	return self.mExist
end

function HeroItem:getHeroId()
	return self.mHeroId
end

function HeroItem:removeHero()
	self.mHeroWidget:removeFromParent(true)
	self.mHeroWidget = nil
end

function HeroItem:setPosition(pos)
	self.mRootWidget:setPosition(pos)
end

function HeroItem:getBoundingBox()
	return self.mRootWidget:getBoundingBox()
end

function HeroItem:getContentSize()
	return self.mRootWidget:getContentSize()
end

function HeroItem:getWorldPosition()
	return self.mRootWidget:getWorldPosition()
end

function HeroItem:removeFromPos()
	self.mFromPos = nil
end

function HeroItem:setFromPos(posX, posY)
	self.mFromPos = cc.p(posX, posY)
end

function HeroItem:getFromPos()
	return self.mFromPos
end


local SchoolItem = {}

function SchoolItem:new(rootWidget)
	local o = 
	{
		mRootWidget = 	rootWidget,
		mHeros		=	{},		-- 存放HeroItem的维数组
		mHeroCount	=	0,
	}
	o = newObject(o, SchoolItem)
	-- 设置剪切
	o.mRootWidget:getChildByName("ScrollView_Hero"):setClippingEnabled(true)
	return o
end

-- 获得英雄
function SchoolItem:getHeroByIndex(index)
	return self.mHeros[index]
end

-- 获得内部英雄数量
function SchoolItem:getHeroTotalCount()
	return self.mHeroCount
end

-- 添加英雄
function SchoolItem:pushBackHeroItem(heroItem)
	local hero_margin = 30 -- 人物横向间距30
	self.mHeroCount = self.mHeroCount + 1
	self.mHeros[self.mHeroCount] = heroItem
	self:getScrollView():addChild(heroItem:getRootWidget())
	local contentSize = heroItem:getContentSize()
	heroItem:setPosition(cc.p((self.mHeroCount-1)*(hero_margin+contentSize.width), 0))

	-- 调整innerContentSize
	local oldContentSize = self:getScrollView():getInnerContainerSize()
	local itemContentSize = heroItem:getContentSize()
	local newContentWidth = itemContentSize.width*self.mHeroCount + hero_margin*(self.mHeroCount-1)
	self:getScrollView():setInnerContainerSize(cc.size(newContentWidth, oldContentSize.height))
end

-- 设置Tag
function SchoolItem:setTag(tag)
	self.mRootWidget:getChildByName("ScrollView_Hero"):setTag(tag)
end

-- 把自己添加到ListView
function SchoolItem:addToListView(listView)
	listView:pushBackCustomItem(self.mRootWidget)
end

-- 获得内部ScrollView
function SchoolItem:getScrollView()
	return self.mRootWidget:getChildByName("ScrollView_Hero")
end

-- 设置是否允许滑动
function SchoolItem:setScrollEnabled(val)
	self.mRootWidget:getChildByName("ScrollView_Hero"):setEnabled(val)
	self.mRootWidget:getChildByName("ScrollView_Hero"):setTouchEnabled(val)
end


local SelectRoleWindow = 
{
	mName 					=	"SelectRoleWindow",
	mRootNode				=	nil,
	mRootWidget				=	nil,
	mSectionId				=	nil,	-- 关卡Id
	mPveLevel				=	nil,	-- 难度级别
	mListView_SchoolList	=	nil,	-- 中间的大ListView
	mProcessTouchPanel		=	nil,	-- 响应触摸层
	mSchedulerHandler		=	nil,	-- 计时器(待上阵列表)
	mTickCount				=	0,		-- 计时(点击待上阵列表)
	mSchedulerHandler2		=	nil,	-- 计时器(上阵列表)
	mTickCount2				=	0,		-- 计时(点击上阵列表)
	mHeroWidget				=	nil,	
	mSchools				=	{},		-- 存放SchoolItem的一维数组
	mSchoolWiget			=	nil,
	mBattleHeros 			=	{},		-- 底部存放5个上阵英雄的数组
}

function SelectRoleWindow:Release()

end

function SelectRoleWindow:Load(event)
	cclog("=====SelectRoleWindow:Load=====begin")

	ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("Hero.ExportJson")

--	self.mSectionId = event.mData[1]
--	self.mPveLevel = event.mData[2]

	self.mSchoolWiget = GUIWidgetPool:createWidget("SelectRoleSchoolItem")
	self.mHeroWidget = GUIWidgetPool:createWidget("SelectRoleHeroItem")

	self.mRootNode = cc.Node:create()
	GUISystem:GetRootNode():addChild(self.mRootNode)
	self:InitLayout()

	cclog("=====SelectRoleWindow:Load=====end")
end

-- 服务器回包响应
function SelectRoleWindow:onGoToBattle(msgPacket)
	globaldata:updateBattleFormation(msgPacket)

	local _data = {}
	_data.mType = "fuben"
	_data.mHard = self.mSectionId --sectionInfo[1].MapUI_BoardConfigID
	_data.mPveLevel = self.mPveLevel
	Event.GUISYSTEM_SHOW_FIGHTWINDOW.mData = _data
	EventSystem:PushEvent(Event.GUISYSTEM_HIDE_PVEENTRYWINDOW)
	EventSystem:PushEvent(Event.GUISYSTEM_HIDE_SELECTROLEWINDOW)
	EventSystem:PushEvent(Event.GUISYSTEM_SHOW_FIGHTWINDOW)
end



-- 前往战斗
function SelectRoleWindow:goToBattle()
	--[[  -- 不用的界面 150824

	local function requestEnterBattle()
		local packet = NetSystem.mNetManager:GetSPacket()
		packet:SetType(PacketTyper._PTYPE_CS_REQUEST_GOTOBATTLE_)
		local hardType = 0
		if "normal" == self.mPveLevel then
			hardType = 1
		end
		packet:PushChar(hardType)
		print("难度级别", self.mPveLevel)
		print("副本Id", self.mSectionId)
		local chapterInfo = DB_MapUIConfig.getArrDataByField(DB_MapUIConfig, "MapUI_BoardConfigID", self.mSectionId)
		packet:PushInt(chapterInfo[1].MapUI_ChapterID)
		packet:PushInt(chapterInfo[1].MapUI_SectionID)
		print("章节Id", chapterInfo[1].MapUI_ChapterID)
		print("副本Id", chapterInfo[1].MapUI_SectionID)
		local count = 0
		for i = 1, 5 do
			if self.mBattleHeros[i]:isHeroExist() then
				count = count + 1
			end
		end
		print("上阵英雄数量", count)
		packet:PushUShort(count)
		for i = 1, 5 do
			if self.mBattleHeros[i]:isHeroExist() then
				local heroId = self.mBattleHeros[i]:getHeroId()
				local heroObj = globaldata:findHeroById(heroId)
				local heroGuid = heroObj:getKeyValue("guid")
				packet:PushChar(i)
				packet:PushString(heroGuid)
				packet:PushInt(heroId)
			end
		end
		packet:Send()
	end
	requestEnterBattle()
	]]
end

-- 初始化战斗阵型
function SelectRoleWindow:initBattleFormation()
	for i = 1, #self.mSchools do
		local heroCount = self.mSchools[i]:getHeroTotalCount()
		for j = 1, heroCount do
			local heroItem = self.mSchools[i]:getHeroByIndex(j)
			local heroId = heroItem:getHeroId()
			local battleHeroCount = globaldata:getBattleHeroCount()
			for m = 1, battleHeroCount do
				local id = globaldata:getHeroInfoByBattleIndex(m, "id")
				if heroId == id then
					-- 英雄上阵
					self.mBattleHeros[m]:addHero(id)
					self.mBattleHeros[m]:setFromPos(i, j)
					-- 原处英雄隐藏
					self.mSchools[i]:getHeroByIndex(j):setHeroAnimVisible(false)
				end

			end
		end
	end
end

function SelectRoleWindow:InitLayout()
	self.mRootWidget = GUIWidgetPool:createWidget("SelectRoleWindow")
	self.mRootNode:addChild(self.mRootWidget)

	local function closeWindow()
		EventSystem:PushEvent(Event.GUISYSTEM_HIDE_SELECTROLEWINDOW)
	end
	local btnClose = self.mRootWidget:getChildByName("Button_return")
	registerWidgetReleaseUpEvent(btnClose, closeWindow)
	local btlStart = self.mRootWidget:getChildByName("Button_start")
	registerWidgetReleaseUpEvent(btlStart, handler(self, self.goToBattle))

	local function onTouchBegan(touch, event)
		return true
	end

	local function onTouchMoved(touch, event)
		if "ChooseHero" == user_state.mState or "ChooseBattleHero" == user_state.mState then
			local location = touch:getLocation()
			user_state.mAnim:setPosition(location)
		end
	end

	local function onTouchEnded(touch, event)
		local location = touch:getLocation()
		if "ChooseHero" == user_state.mState then
			self:setScrollEnabled(true)
			user_state.mAnim:removeFromParent(true)
			user_state.mAnim = nil
			local visibleVal = true
			
			for i = 1, 5 do
				local rect = self.mBattleHeros[i]:getBoundingBox()
				local worldPos = self.mBattleHeros[i]:getWorldPosition()
				rect.x = worldPos.x
				rect.y = worldPos.y 

				if cc.rectContainsPoint(rect, location) then 
					if not self.mBattleHeros[i]:isHeroExist() then  -- 放置处没有英雄，直接放置
						-- 添加英雄
						self.mBattleHeros[i]:addHero(self.mSchools[user_state.mRow]:getHeroByIndex(user_state.mColumn):getHeroId())
						visibleVal = false
					else 											-- 放置处有英雄，交换
						-- 把上阵英雄放回原处
						self:sendBattleHeroBack(self.mBattleHeros[i])
						-- 把拖动的英雄上阵
						self.mBattleHeros[i]:addHero(self.mSchools[user_state.mRow]:getHeroByIndex(user_state.mColumn):getHeroId())
						visibleVal = false
					end
					self.mBattleHeros[i]:setFromPos(user_state.mRow, user_state.mColumn)
					break
				end
			end
			
			self.mSchools[user_state.mRow]:getHeroByIndex(user_state.mColumn):setHeroAnimVisible(visibleVal)
			user_state.mState = "BrowseHero"
		elseif "ChooseBattleHero" == user_state.mState then
			user_state.mAnim:removeFromParent(true)
			user_state.mAnim = nil
			local visibleVal = true
			for i = 1, 5 do
				local rect = self.mBattleHeros[i]:getBoundingBox()
				local worldPos = self.mBattleHeros[i]:getWorldPosition()
				rect.x = worldPos.x
				rect.y = worldPos.y 
				if cc.rectContainsPoint(rect, location) and user_state.mLastClickBattleHeroIndex ~= i then 
					if not self.mBattleHeros[i]:isHeroExist() then  -- 放置处没有英雄，直接放置
						-- 删除原处英雄
						self.mBattleHeros[user_state.mLastClickBattleHeroIndex]:removeHero()
						-- 获取原处英雄FromPos并清空
						local pos1 = self.mBattleHeros[user_state.mLastClickBattleHeroIndex]:getFromPos()
						self.mBattleHeros[user_state.mLastClickBattleHeroIndex]:removeFromPos()
						-- 添加英雄
						self.mBattleHeros[i]:addHero(self.mBattleHeros[user_state.mLastClickBattleHeroIndex]:getHeroId())
						self.mBattleHeros[i]:setFromPos(cc.p(pos1.x, pos1.y))
						
						visibleVal = false
					else 											-- 放置处有英雄，交换	
						self:exchangeTwoHero(i, user_state.mLastClickBattleHeroIndex)
						visibleVal = false
					end
					break
				end
			end
			if visibleVal then
				self.mBattleHeros[user_state.mLastClickBattleHeroIndex]:setHeroAnimVisible(visibleVal)
			end
			user_state.mLastClickBattleHeroIndex = nil
			user_state.mState = "BrowseHero"
		end
	end

	local function onTouchCancelled(touch, event)
		
	end

	self.mProcessTouchPanel = cc.Layer:create()
	local listener = cc.EventListenerTouchOneByOne:create()
	listener:setSwallowTouches(false)
	listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    listener:registerScriptHandler(onTouchCancelled,cc.Handler.EVENT_TOUCH_CANCELLED )
    local eventDispatcher = self.mProcessTouchPanel:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self.mProcessTouchPanel)
    self.mRootNode:addChild(self.mProcessTouchPanel, 100)
	self.mListView_SchoolList = self.mRootWidget:getChildByName("ListView_SchoolList")
	self.mListView_SchoolList:setScrollByAngle(true)

	-- -- 底部5个上阵英雄

	for i = 1, 5 do
		self.mBattleHeros[i] = HeroItem:new(self.mRootWidget:getChildByName("Panel_hero"..tostring(i)))
		self.mBattleHeros[i]:getRootWidget():addTouchEventListener(handler(self, self.onTouchBattleHero))
		self.mBattleHeros[i]:getRootWidget():setTag(i)
		-- -- 根据阵容上阵
		-- local heroId = globaldata:getHeroInfoByBattleIndex(i, "id")
		-- if heroId then
		-- 	self.mBattleHeros[i]:addHero(heroId)
		-- end
	end

	self:initSchoolList()

	self:initBattleFormation()

	user_state.mState = "BrowseHero"
end

function SelectRoleWindow:exchangeTwoHero(index1, index2)
	local id1 = self.mBattleHeros[index1]:getHeroId()
	local pos1 = self.mBattleHeros[index1]:getFromPos()
	local id2 = self.mBattleHeros[index2]:getHeroId()
	local pos2 = self.mBattleHeros[index2]:getFromPos()
	-- 交换动画
	self.mBattleHeros[index1]:removeHero()
	self.mBattleHeros[index2]:removeHero()
	self.mBattleHeros[index1]:addHero(id2)
	self.mBattleHeros[index2]:addHero(id1)
	-- 交换原始位置信息
	self.mBattleHeros[index1]:setFromPos(pos2.x, pos2.y)
	self.mBattleHeros[index2]:setFromPos(pos1.x, pos1.y)
end

-- 触摸上阵英雄列表
function SelectRoleWindow:onTouchBattleHero(widget, eventType)
	-- 获取选中索引
	local index = widget:getTag()

	if eventType == ccui.TouchEventType.began then
		if self.mBattleHeros[index]:isHeroExist() then
			self:startTick2(widget)
		end
	elseif eventType == ccui.TouchEventType.ended then 
		self:checkTick2(widget)
		self:endTick2()
	elseif eventType == ccui.TouchEventType.canceled or eventType == ccui.TouchEventType.moved then
		self:endTick2()
	end
end

function SelectRoleWindow:setScrollEnabled(val)
	for i = 1, #self.mSchools do
		self.mSchools[i]:setScrollEnabled(val)
	end
	self.mListView_SchoolList:setEnabled(val)
	self.mListView_SchoolList:setTouchEnabled(val)
end

-- 创建随鼠标滑动的英雄
function SelectRoleWindow:createHeroAnim(type)
	-- 添加英雄
	user_state.mAnim = FightSystem.mRoleManager:CreateSpine(type)
	self.mProcessTouchPanel:addChild(user_state.mAnim)
	user_state.mAnim:setScale(0.7)
	user_state.mAnim:setPosition(user_state.mPos)
end

-- 点中某个英雄后开始计时(待上阵)
function SelectRoleWindow:startTick(widget, row, column)
	self.mTickCount = 0
	local scheduler = cc.Director:getInstance():getScheduler()
	local fpsVal = 30

	user_state.mRow = row
	user_state.mColumn = column

	local function doSomthing()
		self.mTickCount = self.mTickCount + 1
		local sec = self.mTickCount / 30
		if sec >= delayTime then
			self:setScrollEnabled(false)
			user_state.mState = "ChooseHero"
			user_state.mPos = widget:getTouchBeganPosition()
			self:createHeroAnim(self.mSchools[user_state.mRow]:getHeroByIndex(user_state.mColumn):getHeroId())
			-- 隐藏英雄
			self.mSchools[row]:getHeroByIndex(column):setHeroAnimVisible(false)
			-- 结束计时
			self:endTick()
		end
	end

	self.mSchedulerHandler = scheduler:scheduleScriptFunc(doSomthing, 0, false)
end

-- 点中某个英雄后开始计时(已上阵)
function SelectRoleWindow:startTick2(widget)
	self.mTickCount2 = 0
	local scheduler = cc.Director:getInstance():getScheduler()
	local fpsVal = 30

	local function doSomthing()
		self.mTickCount2 = self.mTickCount2 + 1
		local sec = self.mTickCount2 / 30
		if sec >= delayTime then
			user_state.mState = "ChooseBattleHero"
			user_state.mPos = widget:getTouchBeganPosition()
			-- 移除(上阵的都是直接移除，待上阵的做隐藏)
			local index = widget:getTag()
			user_state.mLastClickBattleHeroIndex = index
			self.mBattleHeros[index]:setHeroAnimVisible(false)
			self:createHeroAnim(self.mBattleHeros[index]:getHeroId())
			-- 结束计时
			self:endTick2()
		end
	end

	self.mSchedulerHandler2 = scheduler:scheduleScriptFunc(doSomthing, 0, false)
end

-- 关闭计时器(待上阵列表)
function SelectRoleWindow:endTick()
	self.mTickCount = 0
	local scheduler = cc.Director:getInstance():getScheduler()
	if self.mSchedulerHandler then
		scheduler:unscheduleScriptEntry(self.mSchedulerHandler)
		self.mSchedulerHandler = nil
	end
end

-- 关闭计时器(已上阵列表)
function SelectRoleWindow:endTick2()
	self.mTickCount2 = 0
	local scheduler = cc.Director:getInstance():getScheduler()
	if self.mSchedulerHandler2 then
		scheduler:unscheduleScriptEntry(self.mSchedulerHandler2)
		self.mSchedulerHandler2 = nil
	end
end 

-- 检测点击挪动英雄
function SelectRoleWindow:checkTick()
	local sec = self.mTickCount / 30
	local result = true

	if sec > 0 and  sec < delayMoveTime then	
		for i = 1, 5 do
			-- 5个空选位置有地方
			if not self.mBattleHeros[i]:isHeroExist() then
				-- 添加英雄
				self.mBattleHeros[i]:addHero(self.mSchools[user_state.mRow]:getHeroByIndex(user_state.mColumn):getHeroId())
				self.mBattleHeros[i]:setFromPos(user_state.mRow, user_state.mColumn)
				self.mSchools[user_state.mRow]:getHeroByIndex(user_state.mColumn):setHeroAnimVisible(visibleVal)
				result = false
				break
			end
		end
	end

	if result then
		print("该位置没有英雄或上阵人数已经满员")
	end
end

-- 检测点击挪动英雄
function SelectRoleWindow:checkTick2(widget)
	local sec = self.mTickCount2 / 30
	local result = true
	if sec > 0 and  sec < delayMoveTime then
		-- 获取选中索引
		local index = widget:getTag()
		self:sendBattleHeroBack(self.mBattleHeros[index])
	end
end

-- 把已经上阵英雄放置回原位
function SelectRoleWindow:sendBattleHeroBack(battleHero)
	-- 上阵英雄消失
	battleHero:removeHero()
	-- 原处英雄显示
	local fromPos = battleHero:getFromPos()
	self.mSchools[fromPos.x]:getHeroByIndex(fromPos.y):setHeroAnimVisible(true)
end

function SelectRoleWindow:onTouchHeroList(widget, eventType)
	if eventType == ccui.TouchEventType.began then
		local scrollViewPos = widget:getWorldPosition() --ScrollView世界坐标
		local touchScrollPos = cc.p(widget:getTouchBeganPosition().x - scrollViewPos.x, widget:getTouchBeganPosition().y - scrollViewPos.y) -- 触碰点世界坐标转换到位于ScrollView坐标
		local innerContainerPos = cc.p(widget:getInnerContainer():getPositionX(), widget:getInnerContainer():getPositionY()) 	-- innerContainer滑动到的Pos
		local touchContainerPos = cc.p(touchScrollPos.x - innerContainerPos.x, touchScrollPos.y)	-- 触摸点相对于innerContainer的Pos

		local schoolItem = self.mSchools[widget:getTag()]
		for i = 1, schoolItem:getHeroTotalCount() do
			local rect = schoolItem:getHeroByIndex(i):getBoundingBox()
			if cc.rectContainsPoint(rect, touchContainerPos) then
				if 	schoolItem:getHeroByIndex(i):isHeroAnimVisible() and schoolItem:getHeroByIndex(i):isExist() then
					self:startTick(widget, widget:getTag(), i)
				end
			end
		end
	elseif eventType == ccui.TouchEventType.ended then 
		self:checkTick()
		self:endTick()
	elseif eventType == ccui.TouchEventType.canceled or eventType == ccui.TouchEventType.moved then
		self:endTick()
	end
end

-- 初始化学校列表
function SelectRoleWindow:initSchoolList()
	for i = 1, schoolNums do
		self.mSchools[i] = SchoolItem:new(self.mSchoolWiget:clone())
		self.mSchools[i]:setTag(i)
		self.mSchools[i]:addToListView(self.mListView_SchoolList)
		self.mSchools[i]:getScrollView():addTouchEventListener(handler(self, self.onTouchHeroList))
		
		local heros = DB_HeroConfig.getArrDataByField("College", i)
		print("nums", #heros)
		for j = 1, #heros do
			if 1 == heros[j].Quality then
				local heroId = heros[j].ID
		 		local heroItem = HeroItem:new(self.mHeroWidget:clone())
		 		heroItem:addHero(heroId)
		 		self.mSchools[i]:pushBackHeroItem(heroItem)
			end
		end
	end
end

function SelectRoleWindow:Destroy()
	self.mRootNode:removeFromParent(true)
	self.mRootNode = nil
	self.mRootWidget = nil
	self.mSectionId = nil
	self.mListView_SchoolList = nil
	self.mTickCount = 0
	self.mSchedulerHandler = nil
	self.mTickCount2 = 0
	self.mSchedulerHandler2 = nil
	self.mProcessTouchPanel	= nil
	self.mHeroWidget = nil
	self.mSchools = {}	
	self.mSchoolWiget =	nil
	self.mBattleHeros = {}	

	ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo("Hero.ExportJson")
	
	CommonAnimation:clearAllTextures()
	cclog("=====SelectRoleWindow:Destroy=====")
end

function SelectRoleWindow:onEventHandler(event)
	if event.mAction == Event.WINDOW_SHOW then
		self:Load(event)
	elseif event.mAction == Event.WINDOW_HIDE then
		self:Destroy()
	end
end

return SelectRoleWindow



