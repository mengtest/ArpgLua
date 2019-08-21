-- Name: 	DateHeroWindow
-- Func：	活动查看英雄窗口
-- Author:	Wangsd
-- Data:	15-2-10

local schoolNums = 6

local HeroItem = {}

function HeroItem:new(rootWidget)
	local o = 
	{
		mRootWidget 			= 	rootWidget,
		mHeroWidget				= 	nil,
		mFromPos				=	nil,	-- 英雄上阵后，记录原始位置
		mHeroId     			=	nil,	-- 英雄动画Id
		mExist					=	true,	-- 玩家是否拥有
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

	-- 灰化
	-- if not globaldata:isHeroIdExist(heroId) then
	-- 	ShaderManager:Stone_spine(self.mHeroWidget)
	-- 	self.mExist = false
	-- end
	-- 图鉴
	local favorHero = globaldata:isHeroInBook(heroId)
	if favorHero then
		self.mRootWidget:getChildByName("Label_Hert"):setString(tostring(favorHero:getKeyValue("favorLevel")))
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

local DateHeroWindow = 
{
	mName 					= 	"DateHeroWindow",
	mRootNode 				= 	nil,
	mSchoolWiget			=	nil,
	mHeroWidget				=	nil,
	mSchools				=	{},		-- 存放SchoolItem的一维数组
	mListView_SchoolList	=	nil,
	mHeroWindow 			=	nil,    -- 英雄窗口
}

function DateHeroWindow:Release()

end

function DateHeroWindow:Load(event)
	cclog("=====DateHeroWindow:Load=====begin")

	self.mSchoolWiget = GUIWidgetPool:createWidget("DateRoleSchoolItem")
	self.mHeroWidget = GUIWidgetPool:createWidget("DateRoleHeroItem")

	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_REQUEST_FAVOR_HEROINFO_, handler(self, self.showHeroInfo))


	self.mRootNode = cc.Node:create()
	GUISystem:GetRootNode():addChild(self.mRootNode)
	self:InitLayout()

	cclog("=====DateHeroWindow:Load=====end")
end

function DateHeroWindow:InitLayout()

	self.mRootWidget = GUIWidgetPool:createWidget("ExchangeHeroWindow")
	self.mRootNode:addChild(self.mRootWidget)

	local function closeWindow()
		EventSystem:PushEvent(Event.GUISYSTEM_HIDE_DATEHEROWINDOW)
	end
	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_return"), closeWindow)

	self.mListView_SchoolList = self.mRootWidget:getChildByName("ListView_SchoolList")
	self.mListView_SchoolList:setScrollByAngle(true)

	self:initSchoolList()
end

-- 点击某个英雄
function DateHeroWindow:onTouchHeroList(widget, eventType)
	if eventType == ccui.TouchEventType.began then
		
	elseif eventType == ccui.TouchEventType.ended then
		local scrollViewPos = widget:getWorldPosition() --ScrollView世界坐标
		local touchScrollPos = cc.p(widget:getTouchEndPosition().x - scrollViewPos.x, widget:getTouchEndPosition().y - scrollViewPos.y) -- 触碰点世界坐标转换到位于ScrollView坐标
		local innerContainerPos = cc.p(widget:getInnerContainer():getPositionX(), widget:getInnerContainer():getPositionY()) 	-- innerContainer滑动到的Pos
		local touchContainerPos = cc.p(touchScrollPos.x - innerContainerPos.x, touchScrollPos.y)	-- 触摸点相对于innerContainer的Pos
		local schoolItem = self.mSchools[widget:getTag()]
		for i = 1, schoolItem:getHeroTotalCount() do
			local rect = schoolItem:getHeroByIndex(i):getBoundingBox()
			if cc.rectContainsPoint(rect, touchContainerPos) then
				local heroTargetId = schoolItem:getHeroByIndex(i):getHeroId()
				self:requestShowHeroInfo(heroTargetId)
			end
		end
	elseif eventType == ccui.TouchEventType.canceled or eventType == ccui.TouchEventType.moved then
		
	end
end

-- 查看某个英雄信息
function DateHeroWindow:requestShowHeroInfo(tarId)
	local packet = NetSystem.mNetManager:GetSPacket()
    packet:SetType(PacketTyper._PTYPE_CS_REQUEST_FAVOR_HEROINFO_)
    packet:PushInt(tarId)
    packet:Send()
end

function DateHeroWindow:showHeroInfo(msgPacket)

	self.mHeroWindow = GUIWidgetPool:createWidget("DateHeroLevel")
	self.mRootNode:addChild(self.mHeroWindow)
	registerWidgetReleaseUpEvent(self.mHeroWindow:getChildByName("Button_Close"), handler(self, self.hideHeroInfo))

	local heroId = msgPacket:GetInt()
	local favorLevel = msgPacket:GetInt()
	local favorValue = msgPacket:GetInt()
	-- 名字
	local heroData = DB_HeroConfig.getDataById(heroId)
	local heroNameId = heroData.Name
	local heroName = getDictionaryText(heroNameId)
	self.mHeroWindow:getChildByName("Label_59"):setString(heroName)
	-- 好感度
	self.mHeroWindow:getChildByName("Label_Explain"):setString("当前英雄好感度"..tostring(favorValue)..tostring(",").."阵容加成"..tostring(favorLevel).."级")
	-- 级别
	self.mHeroWindow:getChildByName("Label_Explain"):setString("当前英雄好感度"..tostring(favorValue)..tostring(",").."阵容加成"..tostring(favorLevel).."级")
	self.mHeroWindow:getChildByName("Image_LevelL"):getChildByName("Label_Level"):setString(tostring(favorLevel))
	self.mHeroWindow:getChildByName("Image_LevelR"):getChildByName("Label_Level"):setString(tostring(favorLevel+1))
	-- 奖励物品
	local count = msgPacket:GetUShort()
	for i = 1, count do
		local itemType = msgPacket:GetInt()
		local itemId = msgPacket:GetInt()
		local itemCount = msgPacket:GetInt()
		local container = self.mHeroWindow:getChildByName("Panel_Award"..tostring(i))
		local item = createCommonWidget(itemType, itemId, itemCount)
		container:addChild(item) 
	end
end

function DateHeroWindow:hideHeroInfo()
	self.mHeroWindow:removeFromParent(true)
end 


-- 初始化学校列表
function DateHeroWindow:initSchoolList()
	for i = 1, schoolNums do
		self.mSchools[i] = SchoolItem:new(self.mSchoolWiget:clone())
		self.mSchools[i]:setTag(i)
		self.mSchools[i]:addToListView(self.mListView_SchoolList)
		self.mSchools[i]:getScrollView():addTouchEventListener(handler(self, self.onTouchHeroList))
		local heros = DB_HeroConfig.getArrDataByField("College", i)
		for j = 1, #heros do
			if 1 == heros[j].Quality then
				local heroId = heros[j].ID
				local favorHero = globaldata:isHeroInBook(heroId)
				if favorHero then
		 			local heroItem = HeroItem:new(self.mHeroWidget:clone())
		 			heroItem:addHero(heroId)
		 			self.mSchools[i]:pushBackHeroItem(heroItem)
		 		end
			end
		end
	end
end

function DateHeroWindow:Destroy()
	self.mRootNode:removeFromParent(true)
	self.mRootNode = nil
	self.mRootWidget = nil
	
	CommonAnimation:clearAllTextures()
	cclog("=====DateHeroWindow:Destroy=====")
end

function DateHeroWindow:onEventHandler(event)
	if event.mAction == Event.WINDOW_SHOW then
		self:Load(event)
	elseif event.mAction == Event.WINDOW_HIDE then
		self:Destroy()
	end
end

return DateHeroWindow