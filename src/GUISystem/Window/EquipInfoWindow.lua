-- Name: 	EquipInfoWindow
-- Func：	强化装备
-- Author:	WangShengdong
-- Data:	14-12-18

-- 前一次的洗练属性位置
local preXilianPropPostionTbl = {}

local colorTable = {}
colorTable[1] =	cc.c4b(255, 168, 0, 204)	 	-- 橙
colorTable[2] =	cc.c4b(210, 0, 255, 178.5)	 	-- 紫
colorTable[3] =	cc.c4b(0, 96, 255, 178.5)		-- 蓝
colorTable[4] =	cc.c4b(9, 194, 0, 178.5)		-- 绿
colorTable[5] =	cc.c4b(255, 255, 255, 114.8)	-- 白

local clockedCount = 0

local index = 1

local curXilianCnt = 0 -- 当前可以进行洗练的项目条数

local function getColorByTypeAndVal(propType, propVal)
--	print("属性类型:", propType, "属性值:", propVal)
	local colorData = DB_Refresh.getDataById(propType)
	local function doSplit(str)
		local index = string.find(str, ',')
		local length = string.len(str, ',')
		return tonumber(string.sub(str, 1, index-1)), tonumber(string.sub(str, index+1, length))
	end

	local function findColor()
		for i = 1, 5 do
			local valRange = colorData["area"..tostring(i)]
			local leftVal, rightVal = doSplit(valRange)
			if propVal>=leftVal and propVal<=rightVal then
				return colorTable[i], i
			end
		end
	end

	return findColor()
end

local XilianItem = {}

function XilianItem:new(rootNode)
	local o = 
	{
		mRootNode 		= 	rootNode,
		mClockWidget	=	nil,			-- 锁
		mClocked		=	false,			-- 锁状态
		mPropType		=	nil,			-- 锁住的状态类型

		mSrcPropWidget	=	nil,			-- 原属性名称
		mSrcValueWidget	=	nil,			-- 原属性值
		mTarPropWidget	=	nil,			-- 新属性名称
		mTarValueWidget	=	nil,			-- 新属性值
		mPropColor 		=	nil,
	}
	o = newObject(o, XilianItem)
	return o
end

function XilianItem:init()
	self.mClockWidget = self.mRootNode:getChildByName("Image_Clock")
	self.mSrcPropWidget = self.mRootNode:getChildByName("Label_Scr")
	self.mTarPropWidget = self.mRootNode:getChildByName("Label_Tar")
	registerWidgetReleaseUpEvent(self.mClockWidget, handler(self, self.onClockClicked))
end

function XilianItem:getProp()
	return self.mPropType
end

function XilianItem:setProp(propType)
	self.mPropType = propType
end

function XilianItem:setString(propType, propVal, level)
	local color, i = getColorByTypeAndVal(propType, math.floor(propVal / level))
	self.mSrcPropWidget:setString(globaldata:getTypeString(propType).."+"..tostring(propVal))

	LabelManager:outline(self.mSrcPropWidget, color)

	self.mRootNode:getChildByName("Label_Max_Scr"):setString("max +"..tostring(globaldata:getTypeMax(propType) * level))
end

function XilianItem:getString()
	return self.mLabelWidget:getString()
end

function XilianItem:setTarString(propType, propVal, level)
	local color, i = getColorByTypeAndVal(propType, math.floor(propVal / level))
	self.mPropColor = i
	self.mTarPropWidget:setString(globaldata:getTypeString(propType).."+"..tostring(propVal))
	LabelManager:outline(self.mTarPropWidget, color)
	self.mRootNode:getChildByName("Label_Max_Tar"):setString("max +"..tostring(globaldata:getTypeMax(propType) * level))
end

function XilianItem:getClocked()
	return self.mClocked
end

function XilianItem:getColor()
	return self.mPropColor
end

function XilianItem:onClockClicked(widget)
	if self.mClocked then
		clockedCount = clockedCount - 1
		if clockedCount < 0 then
			return
		end
		self.mClockWidget:loadTexture("equip_xilian_lock1.png")
	else
		-- 判断是否会全锁住
		if clockedCount + 1 == curXilianCnt then
			MessageBox:showMessageBox1("不能全锁住的呀亲~~")
			return
		end
		
		clockedCount = clockedCount + 1
		self.mClockWidget:loadTexture("equip_xilian_lock2.png")
	end
	self.mClocked = not self.mClocked
	GUIEventManager:pushEvent("xilianPriceChanged")
end

function XilianItem:setClockedEnabled(enabled)
	self.mClocked = enabled
	if enabled then
		self.mClockWidget:loadTexture("equip_xilian_lock2.png")
	else
		self.mClockWidget:loadTexture("equip_xilian_lock1.png")
	end
end


EquipInfoWindow = 
{
	mName 				=	"EquipInfoWindow",
	mRootNode			=	nil,
	mRootWidget			=	nil,
	mTopRoleInfoPanel	=	nil,	-- 顶部人物信息面板
	---------------------------------------------------
	mHeroIconList				=	{},								-- 英雄头像列表
	mHeroIdTbl 					=	{},								-- 英雄Id数组
	mSchedulerEntry 			=	nil,							-- 定时器
	mScrollViewWidget			=	nil,							-- 滑动层
	mLastChooseOption			=	nil,							-- 最后选中的装备信息
	----------------------------------------------------
	mXiangqianWidgetList		=	{},								-- 容器
	mQianghuaWidgetList 		=	{},								-- 容器
	mXilianWidgetList			=	{},								-- 容器
	mXilianItemList 			=	{},	
	mDiamondComposeWindow		=	nil,							-- 宝石合成窗口
	--------------------------------------------------------------------
	mCallFuncAfterDestroy	=	nil,	
	mHeroIconListScrollingAnimNode	=	nil,	-- 滑动特效	
	mHeroIconListSelectedAnimNode	=	nil,	-- 选中特效					
}

function EquipInfoWindow:Release()

end

function EquipInfoWindow:Load(event)
	cclog("=====EquipInfoWindow:Load=====begin")
	if self.mRootNode then
		self.mRootNode:setVisible(true)
	return end


	preXilianPropPostionTbl = {}

	GUIEventManager:registerEvent("itemInfoChanged", self, self.freshStoneInfo)
	GUIEventManager:registerEvent("diamondXiangqianSuccess", self, self.onDiamondXiangqianSuccess)
	GUIEventManager:registerEvent("diamondPutoffSuccess", self, self.onDiamondPutoffSuccess)
	GUIEventManager:registerEvent("xilianPriceChanged", self, self.refreshXilianPrice)
	GUIEventManager:registerEvent("itemInfoChanged", self, self.refreshXilianPrice)

	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_EQUIP_XILIAN_, handler(self, self.onRequestDoEquipXilian))

	self.mRootNode = cc.Node:create()
	GUISystem:GetRootNode():addChild(self.mRootNode)

	---
	self:InitLayout()

	-- 创建洗练项
	self:createXilianItemList()

	-- 齿轮旋转
	self:initChilunRotation()

	-- 创建滑动控件
	self:createScrollViewWidget()

	-- 载入英雄
	self:loadAllHero()

	
	if event.mData then
		if 1 == event.mData[1] then
			self:onSelectedOption(self.mRootWidget:getChildByName("Button_Qianghua"))
		elseif 2 == event.mData[1] then
			self:onSelectedOption(self.mRootWidget:getChildByName("Button_Xiangqian"))
		elseif 3 == event.mData[1] then
			self:onSelectedOption(self.mRootWidget:getChildByName("Button_Xilian"))
		end
	else -- 默认选中强化
		self:onSelectedOption(self.mRootWidget:getChildByName("Button_Qianghua"))
	end

	-- 等级控制
	if globaldata.level < 10 then
		self.mRootWidget:getChildByName("Button_Xilian"):setVisible(false)
	end

	-- 等级控制
	if globaldata.level < 12 then
		self.mRootWidget:getChildByName("Button_Xiangqian"):setVisible(false)
	end

	-- 显示装备信息
	self:updateEquipInfo()

	local function doHeroGuideOne_Step5()
		local guideBtn = self.mQianghuaWidgetList[1]:getChildByName("Button_Qianghua")
		local size = guideBtn:getContentSize()
		local pos = guideBtn:getWorldPosition()
		pos.x = pos.x - size.width/2
		pos.y = pos.y - size.height/2
		local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
		EquipGuideOne:step(5, touchRect)
	end
	if EquipGuideOne:canGuide() then
		EquipGuideOne:step(4, nil, doHeroGuideOne_Step5)
	end

	cclog("=====EquipInfoWindow:Load=====end")
end


local bottomHeight = 288 -- 下边距
local topHeight = 288 -- 上边距
local marginCell = 10 -- 间隙
local cellHeight = 86 -- 格子大小

-- 创建洗练项
function EquipInfoWindow:createXilianItemList()
	self.mXilianItemList = {}
	for i = 1, 4 do
		self.mXilianItemList[i] = XilianItem:new(self.mPanelXilian:getChildByName("Panel_Prop"..tostring(i)))
		self.mXilianItemList[i]:init()
	end
end

-- 创建ScrollView
function EquipInfoWindow:createScrollViewWidget()
	self.mScrollViewWidget = ccui.ScrollView:create()
    self.mScrollViewWidget:setTouchEnabled(true)
    self.mScrollViewWidget:setContentSize(cc.size(159, 662))
  
    local function getHeroCount()
    	local cnt = 0
    	for i = 1, maxHeroCount do -- 存在
			if globaldata:isHeroIdExist(i) then 
				cnt = cnt + 1
			end
		end
		return cnt
    end
    local heroCount = getHeroCount()
    local innerHeight = bottomHeight + topHeight + heroCount*cellHeight + (heroCount-1)*marginCell
    self.mScrollViewWidget:setInnerContainerSize(cc.size(159, innerHeight))

 	self.mRootWidget:getChildByName("Panel_Left"):addChild(self.mScrollViewWidget, 100)
end

-- 载入英雄
function EquipInfoWindow:loadAllHero()
	if not self.mHeroIconListScrollingAnimNode then
		self.mHeroIconListScrollingAnimNode = AnimManager:createAnimNode(8068)
		self.mRootWidget:getChildByName("Panel_Middle_Chosen_Animation"):addChild(self.mHeroIconListScrollingAnimNode:getRootNode(), 100)
		self.mHeroIconListScrollingAnimNode:play("herolist_cur_3", true)
		self.mHeroIconListScrollingAnimNode:setVisible(false)
	end

	if not self.mHeroIconListSelectedAnimNode then
		self.mHeroIconListSelectedAnimNode = AnimManager:createAnimNode(8068)
		self.mRootWidget:getChildByName("Panel_Middle_Chosen_Animation"):addChild(self.mHeroIconListSelectedAnimNode:getRootNode(), 100)
		self.mHeroIconListSelectedAnimNode:setVisible(false)
	end

	-- 初始化定时器
	if not self.mSchedulerEntry then
		local scheduler = cc.Director:getInstance():getScheduler()
		self.mSchedulerEntry = scheduler:scheduleScriptFunc(handler(self, self.tick), 0, false)
	end
	-- 英雄ID表
	self.mHeroIdTbl = {}
	for i = 1, maxHeroCount do -- 存在
		if globaldata:isHeroIdExist(i) then 
			table.insert(self.mHeroIdTbl, i)
		end
	end

	-- 根据战力排序
	local function sortFunc(id1, id2)
		local heroObj1 = globaldata:findHeroById(id1)
		local heroObj2 = globaldata:findHeroById(id2)
		return heroObj1.combat > heroObj2.combat
	end
	table.sort(self.mHeroIdTbl, sortFunc)

	-- 刷新
	self:updateHeroIconTbl()

	local function onAutoScrollStartFunc()
		GUISystem:disableUserInput()
	end
	self.mScrollViewWidget:registerAutoScrollStartFunc(onAutoScrollStartFunc)

	local function onAutoScrollStopFunc()
		self.mXilianEquipWidget = nil
		self.mXiangqianEquipWidget = nil
		-- 修正ScrollView位置
    	self:fixScrollViewPos()
    end
	self.mScrollViewWidget:registerAutoScrollStopFunc(onAutoScrollStopFunc)

	local function onScrollViewEvent(sender, evenType)
		self.mXilianEquipWidget = nil
		self.mXiangqianEquipWidget = nil
		if evenType == ccui.ScrollviewEventType.scrolling then
			self.mHeroIconListScrollingAnimNode:setVisible(true)
			self.mHeroIconListSelectedAnimNode:setVisible(false)
		elseif evenType == ccui.ScrollviewEventType.scrollToBottom then  
			self.mCurSelectedHeroIndex = #self.mHeroIdTbl
			-- 显示英雄信息
			self:updateEquipInfo()
			GUISystem:enableUserInput()
			self.mHeroIconListScrollingAnimNode:setVisible(false)
			local function yyy()
				self.mHeroIconListSelectedAnimNode:play("herolist_cur_2", true)
			end
			self.mHeroIconListSelectedAnimNode:stop()
			self.mHeroIconListSelectedAnimNode:play("herolist_cur_1", false, yyy)
			self.mHeroIconListSelectedAnimNode:setVisible(true)
        elseif evenType ==  ccui.ScrollviewEventType.scrollToTop then
            self.mCurSelectedHeroIndex = 1

            -- 默认选中队长
			self:setLeaderSelected()

			-- 显示英雄信息
			self:updateEquipInfo()
			GUISystem:enableUserInput()
			self.mHeroIconListScrollingAnimNode:setVisible(false)
			local function yyy()
				self.mHeroIconListSelectedAnimNode:play("herolist_cur_2", true)
			end
			self.mHeroIconListSelectedAnimNode:stop()
			self.mHeroIconListSelectedAnimNode:play("herolist_cur_1", false, yyy)
			self.mHeroIconListSelectedAnimNode:setVisible(true)
        end
	end
	self.mScrollViewWidget:addEventListener(onScrollViewEvent)

	-- 修正ScrollView位置
	self:fixScrollViewPos()
	-- 更新头像透明度
	self:updateHeroIconOpacity()
end

-- 刷新
function EquipInfoWindow:updateHeroIconTbl()
	if not self.mRootWidget then
		return
	end
	local innerHeight = self.mScrollViewWidget:getInnerContainerSize().height
--	print("滑动列表总高度:", innerHeight)

	for i = 1, #self.mHeroIdTbl do
		local heroId = self.mHeroIdTbl[i]
		local heroObj = globaldata:findHeroById(heroId)
		
		self.mHeroIconList[i] = GUIWidgetPool:createWidget("Hero_ListCell")
	--	self.mRootWidget:getChildByName("ScrollView_HeroList"):getChildByName("Panel_Hero_"..tostring(i)):addChild(self.mHeroIconList[i])
		self.mScrollViewWidget:addChild(self.mHeroIconList[i])
		
		self.mHeroIconList[i]:setTag(i)
		registerWidgetReleaseUpEvent(self.mHeroIconList[i], handler(self, self.onHeroIconClicked))

		-- 职业
		local heroData = DB_HeroConfig.getDataById(heroId)
		self.mHeroIconList[i]:getChildByName("Image_Group"):loadTexture("hero_herolist_group"..heroData.HeroGroup..".png", 1)

		if 1 == heroData.QualityB then
				self.mHeroIconList[i]:getChildByName("Image_SuperHero"):loadTexture("hero_herolist_super_1.png", 1)
			--	local animNode = AnimManager:createAnimNode(8065)
			--	self.mHeroIconList[i]:getChildByName("Panel_SuperHero_Animation"):addChild(animNode:getRootNode(), 100)
			--	animNode:play("hero_list_superhero", true)
		else
			self.mHeroIconList[i]:getChildByName("Image_SuperHero"):loadTexture("hero_herolist_super_0.png", 1)
		end
		
		local curPos = cc.p(0, innerHeight - topHeight - (i-1)*marginCell - i*cellHeight)
		self.mHeroIconList[i]:setPosition(curPos)
--		print("英雄:", i, "位置:", curPos.x, curPos.y)
		-- 载入头像
		--	local imgId = heroData.IconID
		--	local imgName = DB_ResourceList.getDataById(imgId).Res_path1
		self.mHeroIconList[i]:getChildByName("Image_HeroList_HeroIcon"):loadTexture("hero_herolist_hero_"..heroId..".png", 1)

		if globaldata:findHeroById(heroId) then -- 如果存在
			print("英雄id:", heroId, "等级信息:", heroObj.level)
			local l1 = math.floor(heroObj.level/10)
			local l2 = math.fmod(heroObj.level, 10)
			if 0 == l1 then
				self.mHeroIconList[i]:getChildByName("Panel_HeroLevel_1"):setVisible(true)
				self.mHeroIconList[i]:getChildByName("Panel_HeroLevel_1"):getChildByName("Image_level"):loadTexture("hero_level_"..tostring(l2)..".png", 1)
			else 
				self.mHeroIconList[i]:getChildByName("Panel_HeroLevel_2"):setVisible(true)
				self.mHeroIconList[i]:getChildByName("Panel_HeroLevel_2"):getChildByName("Image_level_Left"):loadTexture("hero_level_"..tostring(l1)..".png", 1)
				self.mHeroIconList[i]:getChildByName("Panel_HeroLevel_2"):getChildByName("Image_level_Right"):loadTexture("hero_level_"..tostring(l2)..".png", 1)
			end

			--self.mHeroIconList[i]:getChildByName("Image_level_Right"):loadTexture("hero_level_"..tostring(l2)..".png")
		
			-- 星星
			local starLevel = heroObj.quality
			if 0 == starLevel then

			elseif starLevel >= 1 and starLevel <= 6 then
				for j = 1, starLevel do 
					local starWidget = self.mHeroIconList[i]:getChildByName("Panel_Star"):getChildByName("Image_Star_"..tostring(j))
					starWidget:loadTexture("hero_herolist_star1.png", 1)
					starWidget:setVisible(true)
				end
			elseif starLevel >= 7 and starLevel <= 12 then
				for j = 1, 6 do
					local starWidget = self.mHeroIconList[i]:getChildByName("Panel_Star"):getChildByName("Image_Star_"..tostring(j))
					starWidget:setVisible(true)
					starWidget:loadTexture("hero_herolist_star1.png", 1)
				end

				for j = 1, starLevel - 6 do
					local starWidget = self.mHeroIconList[i]:getChildByName("Panel_Star"):getChildByName("Image_Star_"..tostring(j))
					starWidget:setVisible(true)
					starWidget:loadTexture("hero_herolist_star2.png", 1)
				end
			end

			-- 品阶
			self.mHeroIconList[i]:getChildByName("Image_bg"):loadTexture(string.format("hero_herolist_cell_bg_%d.png", heroObj.advanceLevel), 1)

		else -- 如果不存在
			ShaderManager:blackwhiteFilter(self.mHeroIconList[i]:getChildByName("Image_HeroList_HeroIcon"):getVirtualRenderer())
		end
	end
end

-- -- 更新所测滑条
-- function EquipInfoWindow:updateHeroIconTbl()
-- 	local innerHeight = self.mScrollViewWidget:getInnerContainerSize().height
-- --	print("滑动列表总高度:", innerHeight)

-- 	for i = 1, #self.mHeroIdTbl do
-- 		local heroId = self.mHeroIdTbl[i]
-- --		print("英雄id:", i, heroId)

-- 		-- 载入头像
-- 		local heroData = DB_HeroConfig.getDataById(heroId)

-- 		if not self.mHeroIconList[i] then
-- 			self.mHeroIconList[i] = GUIWidgetPool:createWidget("Hero_ListCell")
-- 			self.mScrollViewWidget:addChild(self.mHeroIconList[i])

-- 			local curPos = cc.p(0, innerHeight - topHeight - (i-1)*marginCell - i*cellHeight)
-- 			self.mHeroIconList[i]:setPosition(curPos)
-- --			print("英雄:", i, "位置:", curPos.x, curPos.y)

-- 			self.mHeroIconList[i]:setTag(i)
-- 			registerWidgetReleaseUpEvent(self.mHeroIconList[i], handler(self, self.onHeroIconClicked))

-- 			-- 职业
-- 			self.mHeroIconList[i]:getChildByName("Image_Group"):loadTexture("heroicon_group"..heroData.HeroGroup..".png")
-- 		end

		
-- 		local imgId = heroData.IconID
-- 		local imgName = DB_ResourceList.getDataById(imgId).Res_path1
-- 		self.mHeroIconList[i]:getChildByName("Image_HeroList_HeroIcon"):loadTexture(imgName,1)
-- 		-- 级别

-- 		local heroObj = globaldata:findHeroById(heroId)
-- 		if heroObj then -- 如果存在
			
-- 			self.mHeroIconList[i]:getChildByName("Panel_HeroLevel_1"):setVisible(false)
-- 			self.mHeroIconList[i]:getChildByName("Panel_HeroLevel_2"):setVisible(false)
			
-- 			local l1 = math.floor(heroObj.level/10)
-- 			local l2 = math.fmod(heroObj.level, 10)
-- 			if 0 == l1 then
-- 				self.mHeroIconList[i]:getChildByName("Panel_HeroLevel_1"):setVisible(true)
-- 				self.mHeroIconList[i]:getChildByName("Panel_HeroLevel_1"):getChildByName("Image_level"):loadTexture("hero_level_"..tostring(l2)..".png")
-- 			else 
-- 				self.mHeroIconList[i]:getChildByName("Panel_HeroLevel_2"):setVisible(true)
-- 				self.mHeroIconList[i]:getChildByName("Panel_HeroLevel_2"):getChildByName("Image_level_Left"):loadTexture("hero_level_"..tostring(l1)..".png")
-- 				self.mHeroIconList[i]:getChildByName("Panel_HeroLevel_2"):getChildByName("Image_level_Right"):loadTexture("hero_level_"..tostring(l2)..".png")
-- 			end

-- 			ShaderManager:ResumeColor(self.mHeroIconList[i]:getChildByName("Image_HeroList_HeroIcon"):getVirtualRenderer())

-- 			-- 星星
-- 			local starLevel = heroObj.quality
-- 			if 0 == starLevel then

-- 			elseif starLevel >= 1 and starLevel <= 6 then
-- 				for j = 1, starLevel do 
-- 					local starWidget = self.mHeroIconList[i]:getChildByName("Panel_Star"):getChildByName("Image_Star_"..tostring(j))
-- 					starWidget:loadTexture("hero_herolist_star1.png", 1)
-- 					starWidget:setVisible(true)
-- 				end
-- 			elseif starLevel >= 7 and starLevel <= 12 then
-- 				for j = 1, 6 do
-- 					local starWidget = self.mHeroIconList[i]:getChildByName("Panel_Star"):getChildByName("Image_Star_"..tostring(j))
-- 					starWidget:setVisible(true)
-- 					starWidget:loadTexture("hero_herolist_star1.png", 1)
-- 				end

-- 				for j = 1, starLevel - 6 do
-- 					local starWidget = self.mHeroIconList[i]:getChildByName("Panel_Star"):getChildByName("Image_Star_"..tostring(j))
-- 					starWidget:setVisible(true)
-- 					starWidget:loadTexture("hero_herolist_star2.png", 1)
-- 				end
-- 			end

-- 			-- 品阶
-- 			self.mHeroIconList[i]:getChildByName("Image_bg"):loadTexture(string.format("hero_herolist_cell_bg_%d.png", heroObj.advanceLevel), 1)

-- 		else -- 如果不存在
-- 			ShaderManager:Disabled(self.mHeroIconList[i]:getChildByName("Image_HeroList_HeroIcon"):getVirtualRenderer())
-- 			self.mHeroIconList[i]:getChildByName("Panel_HeroLevel_1"):setVisible(false)
-- 			self.mHeroIconList[i]:getChildByName("Panel_HeroLevel_2"):setVisible(false)

-- 			-- 品阶
-- 			self.mHeroIconList[i]:getChildByName("Image_bg"):loadTexture("hero_herolist_cell_bg_0.png", 1)
-- 		end
-- 	end
-- end

-- 默认设置队长选中
function EquipInfoWindow:setLeaderSelected()
	
end

-- 响应头像点击
function EquipInfoWindow:onHeroIconClicked(widget)
	if 1 == #self.mHeroIdTbl then
		return
	end

	self.mCurSelectedHeroIndex = widget:getTag()
	local tm = 0.3
	-- 自动滑动
	local curHeight = self.mScrollViewWidget:getInnerContainerSize().height - self.mRootWidget:getChildByName("ScrollView_HeroList"):getContentSize().height
	local deltaY = self.mHeroIconList[1]:getPositionY() - self.mHeroIconList[self.mCurSelectedHeroIndex]:getPositionY()
	self.mScrollViewWidget:scrollToPercentVertical(100 - (curHeight-deltaY)/curHeight*100, tm, false)

	local function onScrollEnd()
		-- 更新英雄信息
		self:updateEquipInfo()
		GUISystem:enableUserInput()
		local function xxx()
			if self.mHeroIconListScrollingAnimNode then
				self.mHeroIconListScrollingAnimNode:setVisible(false)

				local function yyy()
					self.mHeroIconListSelectedAnimNode:play("herolist_cur_2", true)
				end
				self.mHeroIconListSelectedAnimNode:stop()
				self.mHeroIconListSelectedAnimNode:play("herolist_cur_1", false, yyy)
				self.mHeroIconListSelectedAnimNode:setVisible(true)
			end
		end
		nextTick(xxx)
	end
	self.mScrollViewWidget:stopAllActions()
	local act0 = cc.DelayTime:create(tm)
	local act1 = cc.CallFunc:create(onScrollEnd)
	self.mScrollViewWidget:runAction(cc.Sequence:create(act0, act1))
	GUISystem:disableUserInput()
end

-- 更新头像透明度
function EquipInfoWindow:updateHeroIconOpacity()
	local curPos = self.mRootWidget:getChildByName("Panel_Hero_Middle"):getWorldPosition()
	-- 十八个头像
	for i = 1, #self.mHeroIdTbl do
		local cellPos = self.mHeroIconList[i]:getWorldPosition()
		local distence = math.abs(cellPos.y - curPos.y)
		if distence <= 150 then
			self.mHeroIconList[i]:setOpacity(255)
		elseif distence > 150 and distence <= 275 then
			self.mHeroIconList[i]:setOpacity(255 - (distence-150)*155/125)
		elseif distence > 275 then
			self.mHeroIconList[i]:setOpacity(100)
		end
	end
	-- 六个地板
	for i = 1, 6 do
		local widget = self.mRootWidget:getChildByName("Panel_Empty_"..tostring(i))
		local cellPos = widget:getWorldPosition()
		local distence = math.abs(cellPos.y - curPos.y)
		if distence <= 150 then
			widget:setOpacity(255)
		elseif distence > 150 and distence <= 275 then
			widget:setOpacity(255 - (distence-150)*155/125)
		elseif distence > 275 then
			widget:setOpacity(100)
		end
	end
end

-- 修正ScrollView位置
function EquipInfoWindow:fixScrollViewPos()
	self.mCurSelectedHeroIndex = 1
	local nearestIcon = self.mHeroIconList[self.mCurSelectedHeroIndex]
	local tagWidget = self.mRootWidget:getChildByName("Panel_Hero_Middle")
	for i = 1, #self.mHeroIdTbl do
		local oldDis = math.abs(nearestIcon:getWorldPosition().y - tagWidget:getWorldPosition().y)
		local newDis = math.abs(self.mHeroIconList[i]:getWorldPosition().y - tagWidget:getWorldPosition().y)
		if newDis < oldDis then
			nearestIcon = self.mHeroIconList[i]
			self.mCurSelectedHeroIndex = i
		end
	end

	local function onActEnd()
		self.mXilianEquipWidget = nil
		self.mXiangqianEquipWidget = nil
		-- 显示英雄装备信息
		self:updateEquipInfo()
		local function xxx()
			-- 允许点击
			GUISystem:enableUserInput()
			if self.mHeroIconListScrollingAnimNode then
				self.mHeroIconListScrollingAnimNode:setVisible(false)
			end

			local function yyy()
				if self.mHeroIconListSelectedAnimNode then
					self.mHeroIconListSelectedAnimNode:play("herolist_cur_2", true)
				end
			end
			if self.mHeroIconListSelectedAnimNode then
				self.mHeroIconListSelectedAnimNode:stop()
				self.mHeroIconListSelectedAnimNode:play("herolist_cur_1", false, yyy)
				self.mHeroIconListSelectedAnimNode:setVisible(true)
			end
		end
		nextTick(xxx)
	end

	local moveTime = 0.2
	-- 自动滑动
	local curHeight = self.mScrollViewWidget:getInnerContainerSize().height - self.mScrollViewWidget:getContentSize().height
	local deltaY = self.mHeroIconList[1]:getPositionY() - self.mHeroIconList[self.mCurSelectedHeroIndex]:getPositionY()
	if #self.mHeroIdTbl > 1 then
		self.mScrollViewWidget:scrollToPercentVertical(100 - (curHeight-deltaY)/curHeight*100, moveTime, false)
	end
	
	local act0 = cc.DelayTime:create(moveTime)
	local act1 = cc.CallFunc:create(onActEnd)
	self.mRootWidget:runAction(cc.Sequence:create(act0, act1))
	-- 禁止点击
	GUISystem:disableUserInput()
end

-- 根据上阵英雄设置能否点击
function EquipInfoWindow:setHeroIconTouchEnabled()
	local menuList = self.mRootWidget:getChildByName("Panel_HeroMenuList")
	for i = 1, 5 do
		if globaldata:getHeroInfoByBattleIndex(i, "id") then
			menuList:getChildByName("Image_Hero"..tostring(i)):setTouchEnabled(true)
		else
			menuList:getChildByName("Image_Hero"..tostring(i)):getChildByName("Image_HeroLogo"):setVisible(false)
			menuList:getChildByName("Image_Hero"..tostring(i)):setTouchEnabled(false)
		end
	end
end

-- 初始化英雄头像
function EquipInfoWindow:initHeroIcon()
	for i = 1, 5 do
		local id = globaldata:getHeroInfoByBattleIndex(i, "id")
		if id then
			local heroData = DB_HeroConfig.getDataById(id)
			local imgId = heroData.IconID
			local imgName = DB_ResourceList.getDataById(imgId).Res_path1
			self.mRootWidget:getChildByName("Image_Hero"..tostring(i)):getChildByName("Image_HeroLogo"):loadTexture(imgName, 1)
		end
	end
end

function EquipInfoWindow:InitLayout(event)
	self.mRootWidget = GUIWidgetPool:createWidget("Equip_Main")
	self.mRootNode:addChild(self.mRootWidget)

	local function closeWindow()
		EventSystem:PushEvent(Event.GUISYSTEM_HIDE_EQUIPINFOWINDOW)
	end
	self.mTopRoleInfoPanel = TopRoleInfoPanel:new()
	local topInfoPanel = self.mTopRoleInfoPanel:init(self.mRootNode,ROLE_TITLE_TYPE.TITLE_EQUIP,closeWindow)

	self.mPanelQianghua = self.mRootWidget:getChildByName("Panel_Qianghua")
	self.mPanelXiangqian = self.mRootWidget:getChildByName("Panel_Xiangqian")
	self.mPanelXilian = self.mRootWidget:getChildByName("Panel_Xilian")

	self.mDiamondComposeWindow = GUIWidgetPool:createWidget("Bagpack_DiamondCom")
	self.mRootNode:addChild(self.mDiamondComposeWindow, 100)
	self.mDiamondComposeWindow:setVisible(false)

	registerWidgetPushDownEvent(self.mRootWidget:getChildByName("Button_Qianghua"), handler(self, self.onSelectedOption))
	registerWidgetPushDownEvent(self.mRootWidget:getChildByName("Button_Xiangqian"), handler(self, self.onSelectedOption))
	registerWidgetPushDownEvent(self.mRootWidget:getChildByName("Button_Xilian"), handler(self, self.onSelectedOption))
	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_DoXilian"), handler(self, self.requestDoEquipXilian))
	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_QuickXiangqian"), handler(self, self.doQuickXiangqian))

	-- 左面的菜单列表适配
	local function doAdapter()
		local leftPanel = self.mRootWidget:getChildByName("Panel_Left")
		leftPanel:setPositionX(getGoldFightPosition_LD().x)
	end
	doAdapter()

	-- 右面面板的适配
	local function doAdapter1()
		local deltaX = 100
		local rightPanel = self.mRootWidget:getChildByName("Panel_Main")
		local contentSize = rightPanel:getContentSize()
		rightPanel:setPositionX(getGoldFightPosition_RD().x - contentSize.width + deltaX)
		rightPanel:setOpacity(0)

		-- 居中操作
		local topInfoPanelSize = self.mTopRoleInfoPanel.mTopWidget:getContentSize()
	    local newHeight = getGoldFightPosition_LU().y - topInfoPanelSize.height - getGoldFightPosition_LD().y
	    local newPosY = newHeight/2 + getGoldFightPosition_LD().y - self.mRootWidget:getChildByName("Panel_Main"):getContentSize().height/2
	    self.mRootWidget:getChildByName("Panel_Main"):setAnchorPoint(cc.p(0, 0.5))
	    local panelSize = self.mRootWidget:getChildByName("Panel_Main"):getContentSize()
		self.mRootWidget:getChildByName("Panel_Main"):setPositionY(newPosY + panelSize.height/2)
	
		local function doFadeIn()
			local function onActEnd()
				GUISystem:enableUserInput()
			end

			local tm = 0.25
			local act0 = cc.FadeIn:create(tm)
			local act1 = cc.MoveBy:create(tm, cc.p(-deltaX, 0))
			local act2 = cc.CallFunc:create(onActEnd)
			rightPanel:runAction(cc.Sequence:create(cc.Spawn:create(act0, act1), act2))
			GUISystem:disableUserInput()
		end
		doFadeIn()
	end
	doAdapter1()

	-- 装备一键强化
	local function requestDoAutoStrengthen()
		local packet = NetSystem.mNetManager:GetSPacket()
		packet:SetType(PacketTyper._PTYPE_CS_REQUEST_EQUIP_AUTOSTRENGTHEN_)	
		packet:PushInt(self.mHeroIdTbl[self.mCurSelectedHeroIndex]) 			-- 英雄id
	    packet:Send()
	    GUISystem:showLoading()

	    globaldata.onEquipStrengthenSucessHandler = handler(self, self.onAutoStrengthen)
	end
	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_AutoQianghua"), requestDoAutoStrengthen)
end

-- 一键强化回包
function EquipInfoWindow:onAutoStrengthen(equipObj, oldPropTbl)
	local equipListView = self.mPanelQianghua:getChildByName("ListView_Qianghua")
	local rootWidget = equipListView:getChildByTag(equipObj.type)
	GUISystem:hideLoading()
	-- 刷新	
	EquipNoticeInnerImpl:doUpdate()

	local function doEquipGuideOne_Stop()
		EquipGuideOne:stop()
	end
	if EquipGuideOne:canGuide() then
		EquipGuideOne:step(7, nil, doEquipGuideOne_Stop)
	end
end

-- 选中选项
function EquipInfoWindow:onSelectedOption(widget)
	local normalTexture = {"equip_btn_qianghua2.png", "equip_btn_xiangqian2.png", "equip_btn_xilian2.png"}
	local pusTexture = {"equip_btn_qianghua1.png", "equip_btn_xiangqian1.png", "equip_btn_xilian1.png"}
	
	if widget == self.mLastChooseOption then
		return
	end

	local function replaceTexture()
		if self.mLastChooseOption then
			self.mLastChooseOption:loadTextureNormal(normalTexture[self.mLastChooseOption:getTag()])
			self.mLastChooseOption = widget
		else
			self.mLastChooseOption = widget
		end
		widget:loadTextureNormal(pusTexture[widget:getTag()])
	end
	-- 换菜单项图片
	replaceTexture()

	-- 隐藏所有窗口
	self.mPanelQianghua:setVisible(false)
	self.mPanelXiangqian:setVisible(false)
	self.mPanelXilian:setVisible(false)

	if "Button_Qianghua" == widget:getName() then
		self.mPanelQianghua:setVisible(true)
	elseif "Button_Xiangqian" == widget:getName() then
		self.mPanelXiangqian:setVisible(true)
	elseif "Button_Xilian" == widget:getName() then
		self.mPanelXilian:setVisible(true)

		local function doGonghuiGuideOne_Stop()
			EquipGuideTwo:stop()
		end
		if EquipGuideTwo:canGuide() then
			EquipGuideTwo:step(1, nil, doGonghuiGuideOne_Stop)
		end
	end
	self:updateEquipInfo()
end

-- 获取当前选中英雄的装备列表
function EquipInfoWindow:getCurSelectedHeroEquipList()
	local heroId = self.mHeroIdTbl[self.mCurSelectedHeroIndex]
	local heroObj   = globaldata:findHeroById(heroId)
	local function getEquipList()
		if heroObj then
			return heroObj.equipList
		else
			-- 装备对象(从globaldata复制过来的)
			local equipObject = {}
			function equipObject:new()
				local o = 
				{
					guid 				= "",				-- GUID
					id   				= 0,				-- 类型Id
					type				= 0,				-- 装备位类型
					level 				= 0,				-- 装备等级
					quality 			= 0,				-- 装备品质
					advanceLevel 		= 0, 				-- 进阶等级
					combat 				= 0, 				-- 装备战力
					diamondList 		= {0, 0, 0, 0, 0}, 	-- 宝石链表
					propCount 			= 0,				-- 基础属性数量
					propList 			= {},				-- 基础属性列表
					growPropCount		= 0,				-- 成长属性数量
					growPropList		= {},				-- 成长属性列表
					strengthGoodCount	= 0,				-- 强化所需材料
					strengthGoodList 	=	{}, 			-- 强化需要材料链表

				}
				o = newObject(o, equipObject)
				return o
			end

			function equipObject:getKeyValue(key)
				if self[key] then
					return self[key]
				end
				return nil
			end

			local equipList = {}
			local heroData = DB_HeroConfig.getDataById(heroId)
			for i = 1, 6 do
				local equipId = heroData["Equip"..tostring(i)]
				local newEquip = equipObject:new()
				newEquip.type = i
				newEquip.level = 1
				newEquip.guid = nil
				newEquip.id = equipId
				newEquip.quality = 1
				newEquip.advanceLevel = 1
				-- 没有宝石
				newEquip.diamondList = {}
				-- 没有属性
				newEquip.propCount = 0
				newEquip.propList = {}
				-- 没有成长属性
				newEquip.growPropCount = 0
				newEquip.growPropList = {}
				-- 强化物品数量
				newEquip.strengthGoodCount = 0
				newEquip.strengthGoodList = {}
				equipList[i] = newEquip
			end 
			return equipList
		end
	end
	return getEquipList()
end

-- 更新
function EquipInfoWindow:updateEquipInfo()
	if "Button_Qianghua" == self.mLastChooseOption:getName() then
		-- 显示强化信息
		self:updateEquipQianghuaInfo()
	elseif "Button_Xilian" == self.mLastChooseOption:getName() then
		-- 显示洗练信息
		self:updateEquipXilianInfo()
	elseif "Button_Xiangqian" == self.mLastChooseOption:getName() then
		-- 显示镶嵌信息
		self:updateEquipXiangqianInfo()
	end

	-- ICON主角标志
	for i = 1, #self.mHeroIdTbl do
		if globaldata.leaderHeroId == self.mHeroIdTbl[i] then -- 是主角
			self.mHeroIconList[i]:getChildByName("Image_LeaderMark"):setVisible(true)
		else -- 不是主角
			self.mHeroIconList[i]:getChildByName("Image_LeaderMark"):setVisible(false)
		end
	end

	-- 红点刷新
	EquipNoticeInnerImpl:doUpdate()
end

-- 刷新强化石
function EquipInfoWindow:freshStoneInfo()
	self.mPanelQianghua:getChildByName("Label_StoneNum"):setString(tostring(globaldata:getItemOwnCount(40007)))

	-- 显示强化信息
	local equipListView = self.mPanelQianghua:getChildByName("ListView_Qianghua")
--	equipListView:removeAllChildren()
--	self.mQianghuaWidgetList = {}

	-- 当前英雄id
	local heroId = self.mHeroIdTbl[self.mCurSelectedHeroIndex]
	-- 当前英雄装备
	local equipList = self:getCurSelectedHeroEquipList()

	if equipList then
		for i = 1, #equipList do
			if equipList[i]:getKeyValue("type") <= 6 then
				if not self.mQianghuaWidgetList[i] then -- 没有创建
					local widget = createEquipStrengthenWidget(heroId, equipList[i], false, handler(self, self.showEquipDetailInfo))
					equipListView:pushBackCustomItem(widget)
					self.mQianghuaWidgetList[i] = widget
				else -- 有就刷新
					createEquipStrengthenWidget(heroId, equipList[i], false, handler(self, self.showEquipDetailInfo), self.mQianghuaWidgetList[i])
				end
			end
		end
	end
	
	-- 显示强化石信息
	self.mPanelQianghua:getChildByName("Image_Stone"):loadTexture("item_equip_stone.png", 1)
	self.mPanelQianghua:getChildByName("Label_StoneNum"):setString(tostring(globaldata:getItemOwnCount(40007)))

	-- 刷新
	EquipNoticeInnerImpl:doUpdate()
end

-- 显示强化信息
function EquipInfoWindow:updateEquipQianghuaInfo()
	local equipListView = self.mPanelQianghua:getChildByName("ListView_Qianghua")
--	equipListView:removeAllItems()
--	self.mQianghuaWidgetList = {}

	-- 当前英雄id
	local heroId = self.mHeroIdTbl[self.mCurSelectedHeroIndex]
	-- 当前英雄装备
	local equipList = self:getCurSelectedHeroEquipList()

	if equipList then
		for i = 1, #equipList do
			if equipList[i]:getKeyValue("type") <= 6 then
				if not self.mQianghuaWidgetList[i] then -- 没有创建
					local widget = createEquipStrengthenWidget(heroId, equipList[i], false, handler(self, self.showEquipDetailInfo))
					equipListView:pushBackCustomItem(widget)
					self.mQianghuaWidgetList[i] = widget
				else -- 有就刷新
					createEquipStrengthenWidget(heroId, equipList[i], false, handler(self, self.showEquipDetailInfo), self.mQianghuaWidgetList[i])
				end
			end
		end
	end
	self.mXilianEquipWidget = nil
	self.mXiangqianEquipWidget = nil
	-- 显示强化石信息
	self.mPanelQianghua:getChildByName("Image_Stone"):loadTexture("item_equip_stone.png", 1)
	self.mPanelQianghua:getChildByName("Label_StoneNum"):setString(tostring(globaldata:getItemOwnCount(40007)))
end

-- 显示镶嵌信息
function EquipInfoWindow:updateEquipXiangqianInfo()
	local equipListView = self.mPanelXiangqian:getChildByName("ListView_Xiangqian")
--	equipListView:removeAllItems()
--	self.mXiangqianWidgetList = {}

	-- 当前英雄id
	local heroId = self.mHeroIdTbl[self.mCurSelectedHeroIndex]
	-- 当前英雄装备
	local equipList = self:getCurSelectedHeroEquipList()

	if equipList then
		for i = 1, #equipList do
			if equipList[i]:getKeyValue("type") <= 6 then
				if not self.mXiangqianWidgetList[i] then 
					local widget = createEquipXilianWidget(equipList[i], handler(self, self.showEquipDetailInfo))
					if widget then
						equipListView:pushBackCustomItem(widget)
						widget:setTouchEnabled(true)
						widget:setTag(i)
						registerWidgetPushDownEvent(widget, handler(self, self.onClickedXiangqianEquip))
						self.mXiangqianWidgetList[i] = widget
					end
				else
					createEquipXilianWidget(equipList[i], handler(self, self.showEquipDetailInfo), self.mXiangqianWidgetList[i])
				end

				if 1 == i then
					self:onClickedXiangqianEquip(self.mXiangqianWidgetList[i])
				else
					self.mXiangqianWidgetList[i]:setOpacity(190)
				end
			end
		end
	end
	self.mXilianEquipWidget = nil
end

-- 显示洗练信息
function EquipInfoWindow:updateEquipXilianInfo()
	local equipListView = self.mPanelXilian:getChildByName("ListView_Xilian")
--	equipListView:removeAllItems()

	-- 当前英雄id
	local heroId = self.mHeroIdTbl[self.mCurSelectedHeroIndex]
	-- 当前英雄装备
	local equipList = self:getCurSelectedHeroEquipList()

	if equipList then
		for i = 1, #equipList do
			if equipList[i]:getKeyValue("type") <= 6 then
				if not self.mXilianWidgetList[i] then
					local widget = createEquipXilianWidget(equipList[i], handler(self, self.showEquipDetailInfo))
					if widget then
						equipListView:pushBackCustomItem(widget)
						widget:setTouchEnabled(true)
						widget:setTag(i)
						registerWidgetPushDownEvent(widget, handler(self, self.onClickedXilianEquip))
						self.mXilianWidgetList[i] = widget
					end
				else
					createEquipXilianWidget(equipList[i], handler(self, self.showEquipDetailInfo), self.mXilianWidgetList[i])
				end

				if 1 == i then
					self:onClickedXilianEquip(self.mXilianWidgetList[i])
				else
					self.mXilianWidgetList[i]:setOpacity(190)
				end
			end
		end
	end
	self.mXiangqianEquipWidget = nil
	self:refreshXilianPrice() -- 价格
end

-- 请求洗练
function EquipInfoWindow:requestDoEquipXilian(widget)
	local equipObj = self:getCurSelectedHeroEquipList()[self.mXilianEquipWidget:getTag()]
	local growPropList = equipObj:getKeyValue("growPropList")
	local cnt = 0
	for k, v in pairs(growPropList) do
		cnt = cnt + 1
	end

	if cnt == 0 then
		MessageBox:showMessageBox1("没有可以洗练的属性~")
		return
	elseif cnt == self:getClockedCount() then
		MessageBox:showMessageBox1("老妹儿咱不能全锁住呀~")
		return
	end

	-- 判断橙色是否锁住
	local function isOrangeUnClocked()
		for i = 1, 4 do
			if not self.mXilianItemList[i]:getClocked() and 1 == self.mXilianItemList[i]:getColor() then
				return true
			end
		end
	end

	local function FuncOk()
		local index = self.mCurSelectedHeroIndex
		local packet = NetSystem.mNetManager:GetSPacket()
	    packet:SetType(PacketTyper._PTYPE_CS_EQUIP_XILIAN_)
		packet:PushInt(self.mHeroIdTbl[self.mCurSelectedHeroIndex])
		packet:PushChar(equipObj:getKeyValue("type"))
		packet:PushUShort(self:getClockedCount())

--		print("检测锁住的属性")
		for i = 1, 4 do
			if self.mXilianItemList[i]:getClocked() then
--				print("锁住的属性:", globaldata:getTypeString(self.mXilianItemList[i]:getProp()))
				packet:PushChar(self.mXilianItemList[i]:getProp())
			end
		end
	    packet:Send()
	    GUISystem:showLoading()
	end

	local function FuncCancel()

	end

	if isOrangeUnClocked() then
		MessageBox:showMessageBox2("此装备有橙色品质的属性没有锁住，确认洗练？", FuncOk, FuncCancel)
	else
		FuncOk()
	end

end

-- 一键镶嵌
function EquipInfoWindow:doQuickXiangqian(widget)
	-- 当前英雄装备
	if self.mXiangqianEquipWidget then
		local equipList = self:getCurSelectedHeroEquipList()
		local equipObj = equipList[self.mXiangqianEquipWidget:getTag()]
		local packet = NetSystem.mNetManager:GetSPacket()
	    packet:SetType(PacketTyper._PTYPE_CS_REQUEST_ONEKEY_XIANGQIAN_)
	    packet:PushInt(self.mHeroIdTbl[self.mCurSelectedHeroIndex])
	    packet:PushChar(equipObj:getKeyValue("type"))
		GUISystem:showLoading()
		packet:Send()
	end
end

-- 点击需要镶嵌的装备
function EquipInfoWindow:onClickedXiangqianEquip(widget)
	if self.mXiangqianEquipWidget == widget then
		return
	end

	if self.mXiangqianEquipWidget then
		self.mXiangqianEquipWidget:setOpacity(190)
	end
	self.mXiangqianEquipWidget = widget
	self.mXiangqianEquipWidget:setOpacity(255)

--	print("点击装备的序号", widget:getTag()) 

	local equipObj = self:getCurSelectedHeroEquipList()[widget:getTag()]
	local equipId = equipObj:getKeyValue("id")
	local equipInfo = DB_EquipmentConfig.getDataById(equipId)
	local iconId = equipInfo.IconID
	local ImgData = DB_ResourceList.getDataById(iconId)
	local imgName = ImgData.Res_path1
	-- 换图
	self.mPanelXiangqian:getChildByName("Image_CurXiangqianEquip"):loadTexture(imgName)
	-- 更新宝石信息
	self:updateDiamondInfo(equipObj)
	-- 显示文字
	self.mPanelXiangqian:getChildByName("Image_DiamondKind"):loadTexture(string.format("equip_diamond_%d.png", widget:getTag()))

	-- 一键镶嵌(6022)
	EquipNoticeInnerImpl:doUpdate_6022()
	-- 宝石孔(All)
	EquipNoticeInnerImpl:doUpdate_DiamondSlot()
end

local margin_top 	= 0		-- 顶边距
local margin_left 	= 5		-- 左边距
local margin_cell	= 8		-- 元素边距

-- 更新宝石信息
function EquipInfoWindow:updateDiamondInfo(equipObj, propTbl)
	local diamondList = equipObj:getKeyValue("diamondList")
	local needRotate = true
	for i = 1, #diamondList do
		
		if 0 == diamondList[i] then 	-- 没有宝石
			-- 加号显示
			local addWidget = self.mPanelXiangqian:getChildByName("Panel_Diamond_"..tostring(i)):getChildByName("Image_Add")
			addWidget:setTag(i)
			addWidget:setVisible(true)
			-- 宝石隐藏
			local diamondWidget = self.mPanelXiangqian:getChildByName("Image_Diamond"..tostring(i))
			diamondWidget:setVisible(false)

			local act0 = cc.FadeOut:create(0.6)
			local act1 = cc.FadeIn:create(0.6)
			addWidget:runAction(cc.RepeatForever:create(cc.Sequence:create(act0, act1)))
			addWidget:setTouchEnabled(true)
			registerWidgetPushDownEvent(addWidget, handler(self, self.openBag))
			needRotate = false
			-- 齿轮停止
			self.mPanelXiangqian:getChildByName("Panel_Diamond_"..tostring(i)):getChildByName("Image_DiamondChilun"):stopAllActions()
		else 							-- 有宝石
			-- 加号显示
			local addWidget = self.mPanelXiangqian:getChildByName("Panel_Diamond_"..tostring(i)):getChildByName("Image_Add")
			addWidget:setVisible(false)
			-- 宝石隐藏
			local diamondWidget = self.mPanelXiangqian:getChildByName("Image_Diamond"..tostring(i))
			diamondWidget:setVisible(true)

			diamondWidget:stopAllActions()
			local diamondData = DB_Diamond.getDataById(tonumber(diamondList[i]))
			local diamondIconId = diamondData.Icon
			local imgName = DB_ResourceList.getDataById(diamondIconId).Res_path1
			diamondWidget:loadTexture(imgName, 1)
			diamondWidget:setOpacity(255)
			diamondWidget:setTouchEnabled(true)
			registerWidgetPushDownEvent(diamondWidget, handler(self, self.showDiamondInfo))

			-- 齿轮转动
			local act0 = cc.RotateBy:create(15, 360)
			self.mPanelXiangqian:getChildByName("Panel_Diamond_"..tostring(i)):getChildByName("Image_DiamondChilun"):runAction(cc.RepeatForever:create(act0))
		end
	end

	-- 装备旋转
	if needRotate then
		local act0 = cc.RotateBy:create(15, -360)
		self.mPanelXiangqian:getChildByName("Image_EquipChilun"):runAction(act0)
	else
		self.mPanelXiangqian:getChildByName("Image_EquipChilun"):stopAllActions()
	end
end

-- 脱掉宝石成功回包
function EquipInfoWindow:onDiamondPutoffSuccess(equipObj, propTbl)
	-- 关闭背包
	self:closeInfo()
	-- 更新宝石信息
	self:updateDiamondInfo(equipObj, propTbl)
end

-- 显示宝石信息
function EquipInfoWindow:showDiamondInfo(widget)
	self.mDetailWidget = GUIWidgetPool:createWidget("HeroEquipInfo")
	self.mRootNode:addChild(self.mDetailWidget, 100)

	self.mDetailWidget:getChildByName("Label_Notice"):setVisible(false)

	self.mDetailWidget:getChildByName("Panel_ShizhuangBtn"):setVisible(false)
	self.mDetailWidget:getChildByName("Panel_DiamondBtn"):setVisible(true)
	self.mDetailWidget:getChildByName("Panel_EquipBtn"):setVisible(false)
	self.mDetailWidget:getChildByName("Panel_ShuXing"):setVisible(false)
	self.mDetailWidget:getChildByName("Panel_XiangQian"):setVisible(false)

	local infoWindow = self.mDetailWidget:getChildByName("Panel_EquipInfo")
	infoWindow:setVisible(true)
	local diamondWindow = self.mDetailWidget:getChildByName("Panel_EquipReplace")
	diamondWindow:getChildByName("ListView_EquipList"):setVisible(false)
	diamondWindow:getChildByName("ScrollView_Diamond"):setVisible(true)
	diamondWindow:setVisible(false)

	-- 显示
	self.mDetailWidget:getChildByName("Panel_DiamondsCom"):setVisible(true)

	-- 当前英雄id
	local heroId = self.mHeroIdTbl[self.mCurSelectedHeroIndex]
	-- 当前英雄装备
	local equipList = self:getCurSelectedHeroEquipList()
	local equipObj = equipList[self.mXiangqianEquipWidget:getTag()]
	local diamondList = equipObj:getKeyValue("diamondList")
	local diamondId = diamondList[widget:getTag()]
	local diamondData = DB_Diamond.getDataById(diamondId)
	local diamondNameId = diamondData.Name
	local name = getDictionaryText(diamondNameId)
	-- 名称
	self.mDetailWidget:getChildByName("Label_Name"):setString(name)

	-- 图标
--	local icon = widget:clone()
	local icon = createDiamondWidget(diamondId)
	icon:setTouchEnabled(false)
	icon:setScale(1)
	self.mDetailWidget:getChildByName("Panel_EquipIcon"):addChild(icon)

	-- 描述
	local itemDescId = diamondData.description
	local DescText = getDictionaryText(itemDescId)

--	self.mDetailWidget:getChildByName("Label_Des"):setString(DescText)
	richTextCreate(self.mDetailWidget:getChildByName("Panel_Des"), DescText, true)

	local function requestRemoveDiamond()
		local packet = NetSystem.mNetManager:GetSPacket()
	    packet:SetType(PacketTyper._PTYPE_CS_REQUEST_DIAMOND_PUTOFF_)
		packet:PushInt(self.mHeroIdTbl[self.mCurSelectedHeroIndex])
		packet:PushChar(equipObj:getKeyValue("type"))
		packet:PushInt(widget:getTag())
		GUISystem:showLoading()
		packet:Send()
	end

	local count = globaldata:getItemOwnCount(diamondId)
	if count >= 4 then
		count = 4
	end

	-- 显示合成信息
	local function showComposeInfo()
		
		local function createDiamondFunc(id)
			local itemWidget = createDiamondWidget(id, 0)
			itemWidget:getChildByName("Image_Quality"):setVisible(true)
			itemWidget:getChildByName("Label_Count_Stroke"):setString("")
			return itemWidget
		end

		-- 显示目标宝石
		local itemData = DB_Diamond.getDataById(diamondId)
		local targetId = itemData.NextID

		if -1 ~= targetId then 
			local diamondWidget = createDiamondFunc(targetId)
			self.mDetailWidget:getChildByName("Panel_Diamond_Mid"):removeAllChildren()
			self.mDetailWidget:getChildByName("Panel_Diamond_Mid"):addChild(diamondWidget)
		end

		-- 显示材料宝石
		for i = 1, count do
			local diamondWidget = createDiamondFunc(diamondId)
			self.mDetailWidget:getChildByName(string.format("Panel_Diamond_%d",i)):addChild(diamondWidget)
		end

		-- 显示自身
		local diamondWidget = createDiamondFunc(diamondId)
		self.mDetailWidget:getChildByName("Panel_Diamond_Self"):addChild(diamondWidget)

	end
	showComposeInfo()
		
	local moveTime	= 0.2
	local opened    = -1

	-- 请求宝石合成
	local function requestDoDiamondCompose()
		if count < 4 then
			MessageBox:showMessageBox1("宝石数量不够哦亲~~")
			return
		end
		local packet = NetSystem.mNetManager:GetSPacket()
	    packet:SetType(PacketTyper._PTYPE_CS_UPGRADE_DIAMOND_)
	    packet:PushInt(self.mHeroIdTbl[self.mCurSelectedHeroIndex])
		packet:PushChar(equipObj:getKeyValue("type"))
		packet:PushChar(widget:getTag())
		packet:Send()
		GUISystem:showLoading()
	end

	-- 显示合成窗口
	local function showComposeWindow()
		-- 显示目标宝石
		local itemData = DB_Diamond.getDataById(diamondId)
		local targetId = itemData.NextID
		if -1 == targetId then
			MessageBox:showMessageBox1("当前宝石已经是最高级,无法再进行合成操作哟~")
			return
		end

		self:closeInfo()
		self.mDiamondComposeWindow:setVisible(true)

		local function createDiamondFunc(id)
			local itemWidget = createDiamondWidget(id, 0)
			itemWidget:getChildByName("Image_Quality"):setVisible(true)
			itemWidget:getChildByName("Label_Count_Stroke"):setString("")
			return itemWidget
		end

		local diamondWidget = createDiamondFunc(targetId)
		self.mDiamondComposeWindow:getChildByName("Panel_Diamond_Mid"):removeAllChildren()
		self.mDiamondComposeWindow:getChildByName("Panel_Diamond_Mid"):addChild(diamondWidget)
		diamondWidget:getChildByName("Image_Quality_Bg"):setVisible(false)
		diamondWidget:getChildByName("Image_Quality"):setVisible(false)
		-- 更换品质图片
		local diamondData = DB_Diamond.getDataById(targetId)
		local quality = diamondData.Quality
		self.mDiamondComposeWindow:getChildByName("Image_Dianond_Mid_Bg"):loadTexture(string.format("backpack_diamond_quality_%d.png", quality))
			
		local function updateDiamondCnt()
			local totalCnt = globaldata:getItemOwnCount(diamondId)
			count = totalCnt
			if count >= 5 then
				count = 5
			end

			-- 清理
			for i = 1, 5 do
				self.mDiamondComposeWindow:getChildByName(string.format("Panel_Diamond_%d",i)):removeAllChildren()
			end

			-- 还原图
			for i = 1, 5 do
				self.mDiamondComposeWindow:getChildByName(string.format("Image_Dianond_%d_Bg",i)):loadTexture("backpack_diamond_com_itembg.png")
			end

			-- 显示材料宝石
			for i = 1, count do
				local diamondWidget = createDiamondFunc(diamondId)
				self.mDiamondComposeWindow:getChildByName(string.format("Panel_Diamond_%d",i)):addChild(diamondWidget)
				diamondWidget:getChildByName("Image_Quality_Bg"):setVisible(false)
				diamondWidget:getChildByName("Image_Quality"):setVisible(false)
				-- 更换品质图片
				local diamondData = DB_Diamond.getDataById(diamondId)
				local quality = diamondData.Quality
				self.mDiamondComposeWindow:getChildByName(string.format("Image_Dianond_%d_Bg",i)):loadTexture(string.format("backpack_diamond_quality_%d.png", quality))
			end

			-- 显示文字
			self.mDiamondComposeWindow:getChildByName("Label_Com_Most"):setString("合成"..tostring(math.floor(totalCnt/5)).."个")
			self.mDiamondComposeWindow:setVisible(true)
		end
		updateDiamondCnt()

		local function onRequestDoCompose(info)
			if self.mRootNode then
				if self.mItemDetailWindow then
					self.mItemDetailWindow:setVisible(false)
				end

				-- if self.mOnDiamondComFunc then
				-- 	GUIEventManager:unregister("itemInfoChanged", self.mOnDiamondComFunc)
				-- 	self.mOnDiamondComFunc = nil
				-- end
				
				-- 显示文字
				self.mDiamondComposeWindow:getChildByName("Label_Com_Most"):setString("合成"..tostring(math.floor(globaldata:getItemOwnCount(diamondId)/5)).."个")
			end

			local animNode = AnimManager:createAnimNode(8041)
			self.mDiamondComposeWindow:getChildByName("Panel_Animation_Top"):addChild(animNode:getRootNode(), 100)

			local function onAnimPlayEnd()
				-- 刷新出下一次的
				updateDiamondCnt()
				-- 销毁动画
				animNode:destroy()
			end

			local function onAnimPlayBegin(evtName)
				if "happen" == evtName then
					for i = 1, 5 do
					--	local childTbl = self.mDiamondComposeWindow:getChildByName(string.format("Panel_Diamond_%d",i)):getChildren()
					--	if childTbl[1] then
					--		childTbl[1]:setVisible(false)
					--	end
						self.mDiamondComposeWindow:getChildByName(string.format("Panel_Diamond_%d",i)):removeAllChildren()
					end
				end
			end

			animNode:play("bagpack_diamond_com_top", false, onAnimPlayEnd, onAnimPlayBegin)
		end

		if self.mOnDiamondComFunc then
			GUIEventManager:unregister("itemInfoChanged", self.mOnDiamondComFunc)
			self.mOnDiamondComFunc = nil
		end

		GUIEventManager:registerEvent("itemInfoChanged", nil, onRequestDoCompose)
		self.mOnDiamondComFunc = onRequestDoCompose

		local function requestDoCompose()
			local count = globaldata:getItemOwnCount(diamondId)
			if count < 5 then
				MessageBox:showMessageBox1("宝石数量不够哦亲~~")
				return
			end
			-- local packet = NetSystem.mNetManager:GetSPacket()
			-- packet:SetType(PacketTyper._PTYPE_CS_UPGRADE_DIAMOND_)
			-- packet:PushUShort(diamondId)
			-- packet:PushChar(widget:getTag())
			-- packet:Send()
			-- GUISystem:showLoading()
			local packet = NetSystem.mNetManager:GetSPacket()
		    packet:SetType(PacketTyper._PTYPE_CS_UPGRADE_DIAMOND_)
		    packet:PushInt(self.mHeroIdTbl[self.mCurSelectedHeroIndex])
			packet:PushChar(equipObj:getKeyValue("type"))
			packet:PushChar(widget:getTag())
			packet:Send()
			GUISystem:showLoading()
		end
		registerWidgetReleaseUpEvent(self.mDiamondComposeWindow:getChildByName("Button_Com_1"), requestDoCompose)
		self.mDiamondComposeWindow:getChildByName("Button_Com_1"):setTag(1)
		registerWidgetReleaseUpEvent(self.mDiamondComposeWindow:getChildByName("Button_Com_Most"), requestDoCompose)
		self.mDiamondComposeWindow:getChildByName("Button_Com_Most"):setTag(2)

		local function closeComposeWindow()

			if self.mOnDiamondComFunc then
				GUIEventManager:unregister("itemInfoChanged", self.mOnDiamondComFunc)
				self.mOnDiamondComFunc = nil
			end

			self.mDiamondComposeWindow:setVisible(false)
		end
		registerWidgetReleaseUpEvent(self.mDiamondComposeWindow:getChildByName("Button_Back"), closeComposeWindow)
	end
	registerWidgetReleaseUpEvent(self.mDetailWidget:getChildByName("Button_Hecheng"), showComposeWindow)


	local function requestExchangeDiamond()
		-- 装备列表窗口
	    local function act0End()
	   		opened = -1*opened
	   		infoWindow:getChildByName("Button_Exchange"):setTouchEnabled(true)
	    end


	    local function doAction0()
	   		diamondWindow:setVisible(true)
	   		local act0 = cc.MoveBy:create(moveTime, cc.p(opened*780, 0))
	   		local act1 = cc.CallFunc:create(act0End)
	   		diamondWindow:runAction(cc.Sequence:create(act0, act1))

	   		if -1 == opened then
	   			infoWindow:getChildByName("Button_Exchange"):loadTextureNormal("public_btn2.png")
	   			infoWindow:getChildByName("Button_Exchange"):loadTexturePressed("public_btn1.png")
	   		else
	   			infoWindow:getChildByName("Button_Exchange"):loadTextureNormal("public_btn1.png")
	   			infoWindow:getChildByName("Button_Exchange"):loadTexturePressed("public_btn2.png")
	   		end

	    end
	    doAction0()

	    -- 装备信息窗口
	    local function doAction1()
	   		local act0 = cc.MoveBy:create(moveTime, cc.p(opened*220, 0))
	   		infoWindow:runAction(act0)
	   		infoWindow:getChildByName("Button_Exchange"):setTouchEnabled(false)
	    end
	    doAction1()


		self:openBag(widget)
		infoWindow:setVisible(true)
	end

	local deltaX = 1000

	local function doAdapter()
		registerWidgetReleaseUpEvent(self.mDetailWidget:getChildByName("Panel_DiamondBtn"):getChildByName("Button_Exchange"), requestExchangeDiamond)
		registerWidgetReleaseUpEvent(self.mDetailWidget:getChildByName("Panel_DiamondBtn"):getChildByName("Button_Unload"), requestRemoveDiamond)
		registerWidgetReleaseUpEvent(self.mDetailWidget, handler(self, self.closeInfo))	
		local curPos = cc.p(diamondWindow:getPosition())
		local newPos = cc.p(curPos.x + deltaX, curPos.y)
		diamondWindow:setPosition(newPos)
	end
	nextTick(doAdapter)
end

-- 关闭宝石详情
function EquipInfoWindow:closeInfo(widget)
	if self.mDetailWidget then
		self.mDetailWidget:removeFromParent(true)
		self.mDetailWidget = nil
	end
end

-- 打开背包
function EquipInfoWindow:openBag(widget)

	if not self.mDetailWidget then
		self.mDetailWidget = GUIWidgetPool:createWidget("HeroEquipInfo")
		self.mRootNode:addChild(self.mDetailWidget, 100)
	end

	self.mDetailWidget:getChildByName("Label_Notice"):setVisible(false)

	-- 按钮
	self.mDetailWidget:getChildByName("Panel_DiamondBtn"):setVisible(true)
	self.mDetailWidget:getChildByName("Panel_EquipBtn"):setVisible(false)
	self.mDetailWidget:getChildByName("Panel_ShizhuangBtn"):setVisible(false)

	local infoWindow = self.mDetailWidget:getChildByName("Panel_EquipInfo")
	infoWindow:setVisible(false)
	local diamondWindow = self.mDetailWidget:getChildByName("Panel_EquipReplace")
	diamondWindow:getChildByName("ListView_EquipList"):setVisible(false)
	diamondWindow:getChildByName("ScrollView_Diamond"):setVisible(true)
	diamondWindow:setVisible(true)
	registerWidgetReleaseUpEvent(self.mDetailWidget, handler(self, self.closeBag))

	local equipObj = self:getCurSelectedHeroEquipList()[self.mXiangqianEquipWidget:getTag()]
	local equipId = equipObj:getKeyValue("id")
	local equipData = DB_EquipmentConfig.getDataById(equipId)
	local needType = equipData.Type
	local diamindList = globaldata.itemList[2]
	local newDiamondList = {}
	for i = 1, #diamindList do
		local diamondData = DB_Diamond.getDataById(diamindList[i]:getKeyValue("itemId"))
		local diamondType = diamondData.diamondType
		if needType == diamondType then
			table.insert(newDiamondList, i)
		end
	end

	local listView = self.mDetailWidget:getChildByName("ScrollView_Diamond")
	listView:removeAllChildren()
	local listContainerSize = listView:getInnerContainerSize()
	local listContentSize = listView:getContentSize()
	local itemContentSize = cc.size(90, 90)
	local newContentHeight = nil
	local function doResize()
		local needGridCount = #newDiamondList
		local columnNums = math.ceil(needGridCount/4)
		newContentHeight = columnNums*(itemContentSize.height+margin_cell)
		if newContentHeight > listContentSize.height then
			listView:setInnerContainerSize(cc.size(listContainerSize.width, newContentHeight))
		else
			listView:setInnerContainerSize(cc.size(listContainerSize.width, listContentSize.height))
		end
	end
	doResize()

	local function requestDoEquipXiangqian(diamond)
		
		local equipObj = self:getCurSelectedHeroEquipList()[self.mXiangqianEquipWidget:getTag()]

		local packet = NetSystem.mNetManager:GetSPacket()
	    packet:SetType(PacketTyper._PTYPE_CS_REQUEST_DIAMOND_XIANGQIAN_)
	    packet:PushInt(diamond:getTag()) -- 宝石id
	  	packet:PushInt(self.mHeroIdTbl[self.mCurSelectedHeroIndex]) -- 英雄id
	  	packet:PushChar(equipObj:getKeyValue("type"))
	    packet:PushInt(widget:getTag()) -- 孔号
	    packet:Send()
	    GUISystem:showLoading()
	end

	for i = 1, #newDiamondList do
		local diamindWidget = createDiamondWidget(diamindList[newDiamondList[i]]:getKeyValue("itemId"), diamindList[newDiamondList[i]]:getKeyValue("itemNum"))
	--	diamindWidget:getChildByName("Image_Quality"):setVisible(true)
	--	diamindWidget:getChildByName("Image_Quality"):loadTexture("icon_item_quality1.png", 1)
		listView:addChild(diamindWidget)
		registerWidgetReleaseUpEvent(diamindWidget, requestDoEquipXiangqian)
		local posX = ((i-1)%4)*(itemContentSize.width+margin_cell) + margin_left
		local posY = 0
		if newContentHeight > listContentSize.height then
			posY = listContentSize.height - math.ceil(i/4)*(itemContentSize.height+margin_cell) + newContentHeight - listContentSize.height
		else
			posY = listContentSize.height - math.ceil(i/4)*(itemContentSize.height+margin_cell)
		end
		diamindWidget:setPosition(cc.p(posX, posY))
	end

	if 0 == #newDiamondList then
		self.mDetailWidget:getChildByName("Label_Notice"):setVisible(true)
		self.mDetailWidget:getChildByName("Label_Notice"):setString("当前没有适合该装备的宝石")
	end
end

-- 关闭背包
function EquipInfoWindow:closeBag(widget)
	if self.mDetailWidget then
		self.mDetailWidget:removeFromParent(true)
		self.mDetailWidget = nil
	end
end

-- 点击需要洗练的装备
function EquipInfoWindow:onClickedXilianEquip(widget)
	if self.mXilianEquipWidget == widget then
		return
	end
	if self.mXilianEquipWidget then
	--	self.mXilianEquipWidget:removeBackGroundImage()
		self.mXilianEquipWidget:setOpacity(190)
	end
	self.mXilianEquipWidget = widget
	self.mXilianEquipWidget:setOpacity(255)
	-- widget:setBackGroundImage("xiangqian_dikuang4.png")

	local equipObj = self:getCurSelectedHeroEquipList()[widget:getTag()]
	local equipPropList = equipObj:getKeyValue("growPropList")
	-- 显示属性

	local propCnt = 0

	local idx = 0
--	print("显示属性:")

	for i = 1, 4 do -- 把所有的锁打开
		self.mXilianItemList[i]:setClockedEnabled(false)
	end

	curXilianCnt = 0
	for k, v in pairs(equipPropList) do

		idx = idx + 1
		self.mXilianItemList[idx]:setProp(k)
		self.mXilianItemList[idx]:setString(k, v, equipObj:getKeyValue("level"))
		self.mXilianItemList[idx]:setTarString(k, v, equipObj:getKeyValue("level"))
	--	print("显示类型(左边):", globaldata:getTypeString(k), "显示值:", v)
		curXilianCnt = curXilianCnt + 1

		preXilianPropPostionTbl[idx] = k
	end

	-- 显示文字
	for i = 1, 4 do
		if i <= idx then
			self.mPanelXilian:getChildByName(string.format("Label_Open_%d", i)):setVisible(false)
			self.mPanelXilian:getChildByName(string.format("Panel_Prop%d", i)):setVisible(true)
		else
			self.mPanelXilian:getChildByName(string.format("Label_Open_%d", i)):setVisible(true)
			self.mPanelXilian:getChildByName(string.format("Panel_Prop%d", i)):setVisible(false)
		end
	end
	
	clockedCount = 0

	self:refreshXilianPrice()
end

-- 初始化齿轮转动
function EquipInfoWindow:initChilunRotation()
	local act0 = cc.RotateBy:create(15, 360)
	self.mRootWidget:getChildByName("Image_BgChilun1"):runAction(cc.RepeatForever:create(act0))

	local act1 = cc.RotateBy:create(6, -360)
	self.mRootWidget:getChildByName("Image_BgChilun2"):runAction(cc.RepeatForever:create(act1))

	local act2 = cc.RotateBy:create(10, 360)
	self.mRootWidget:getChildByName("Image_BgChilun3"):runAction(cc.RepeatForever:create(act2))
end

function EquipInfoWindow:onEquipChanged()
	local listView = self.mPanelQianghua:getChildByName("ListView_Qianghua") 
	listView:removeAllItems()

	self.mQianghuaWidgetList = {}

	local heroId = self.mHeroIdTbl[self.mCurSelectedHeroIndex]

	local euipList = globaldata:getTotalEquipList()
	for i = 1, #euipList do
		local equipObj = euipList[i]
		if equipObj:getKeyValue("type") <= 6 then
			local widget = createEquipStrengthenWidget(heroId, equipObj, self.mForEquipOn, handler(self, self.showEquipDetailInfo), self.mPreCombat)
			listView:pushBackCustomItem(widget)
			self.mQianghuaWidgetList[i] = widget
		end
	end
	EventSystem:PushEvent(Event.GUISYSTEM_HIDE_EQUIPINFOWINDOW)
end

-- 响应请求洗练
function EquipInfoWindow:onRequestDoEquipXilian(msgPacket)
	GUISystem:hideLoading()
	if self.mRootNode then
		local guid = msgPacket:GetString()
		local id = msgPacket:GetInt()
		local equipObj = globaldata:getEquipByGuid(guid)

--		print("guid:", guid)

--		print("id:", id)

		local propMap = {
						{srcType=nil,tarType=nil,srcVal=nil,tarVal=nil,},
						{srcType=nil,tarType=nil,srcVal=nil,tarVal=nil,},
						{srcType=nil,tarType=nil,srcVal=nil,tarVal=nil,},
						{srcType=nil,tarType=nil,srcVal=nil,tarVal=nil,},
						}

		local propCount = msgPacket:GetUShort()
--		print("原属性数量:", propCount)
		for i = 1, propCount do
			propMap[i].srcType = msgPacket:GetChar()
			propMap[i].srcVal = msgPacket:GetInt()
--			print("原属性类型:", globaldata:getTypeString(propMap[i].srcType), "原属性值:", propMap[i].srcVal)
		end

		propCount = msgPacket:GetUShort()
--		print("新属性数量:", propCount)
		for i = 1, propCount do
			propMap[i].tarType = msgPacket:GetChar()
			propMap[i].tarVal = msgPacket:GetInt()
--			print("新属性类型:", globaldata:getTypeString(propMap[i].tarType), "新属性值:", propMap[i].tarVal)
		end

		-- 排序过后的属性
		local sortedPropMap = {}

		for i = 1, #preXilianPropPostionTbl do
			for j = 1, #propMap do
				if preXilianPropPostionTbl[i] == propMap[j].srcType then
					table.insert(sortedPropMap, propMap[j])
				end
			end			
		end

		-- 保存
		preXilianPropPostionTbl = {}
		for i = 1, #sortedPropMap do
			preXilianPropPostionTbl[i] = sortedPropMap[i].tarType
		end

		for i = 1, propCount do
			local xilianItem = self.mXilianItemList[i]
			if xilianItem then
				xilianItem:setProp(sortedPropMap[i].tarType)
				xilianItem:setString(sortedPropMap[i].srcType, sortedPropMap[i].srcVal, equipObj:getKeyValue("level"))
				xilianItem:setTarString(sortedPropMap[i].tarType, sortedPropMap[i].tarVal, equipObj:getKeyValue("level"))
			end
		end
		-- 旧的属性列表
		local oldPropTbl = {}
		-- 备份旧的成长属性列表
		for k, v in pairs(equipObj.growPropList) do
			oldPropTbl[k] = v
		end

		equipObj.growPropList = {}
		equipObj.growPropCount = propCount
		for i = 1, propCount do
			local newType = sortedPropMap[i].tarType
			local newVal = sortedPropMap[i].tarVal
			equipObj.growPropList[newType] = newVal
		end
		-- 新的属性列表
		local newPropTbl = {}
		-- 备份旧的成长属性列表
		for k, v in pairs(equipObj.growPropList) do
			newPropTbl[k] = v
		end

		for k, v in pairs(newPropTbl) do
			if oldPropTbl[k] then
				newPropTbl[k] = v - oldPropTbl[k]
			end
		end
	end


	-- 洗练页签
	EquipNoticeInnerImpl:doUpdate_6030()

	-- 洗练装备
	EquipNoticeInnerImpl:doUpdate_6031()
end

-- 获取洗练锁住的数量
function EquipInfoWindow:getClockedCount()
	local count = 0
	for i = 1, 4 do
		if self.mXilianItemList[i]:getClocked() then
			count = count + 1
		end
	end
	return count
end

-- 取出某属性的XilianItem
function EquipInfoWindow:getItemByProp(propType)
	for i = 1, 4 do
		if propType == self.mXilianItemList[i]:getProp() then
			return self.mXilianItemList[i]
		end
	end
end

-- 刷新洗练价格
function EquipInfoWindow:refreshXilianPrice()
	local count = self:getClockedCount()
	local price = globaldata:getXilianPrice(count)			-- 需要宝石数量
	local ticketCnt = globaldata:getItemOwnCount(20401)		-- 拥有洗练券数量

	-- 显示钻石部分
	self.mRootWidget:getChildByName("Panel_LockCost"):getChildByName("Label_LockCost"):setString(price)

	local labelWidget = self.mRootWidget:getChildByName("Panel_XilianCost"):getChildByName("Label_XilianCost")
	-- 显示锤子部分
	if ticketCnt > 0 then
		self.mRootWidget:getChildByName("Panel_XilianCost"):getChildByName("Label_XilianCost"):setString(1)
		self.mRootWidget:getChildByName("Panel_XilianCost"):getChildByName("Image_XilianCost"):loadTexture("public_currency_xilian.png")
		labelWidget:setColor(cc.c3b(162,255,169))
	else
		labelWidget:setString(20000)
		self.mRootWidget:getChildByName("Panel_XilianCost"):getChildByName("Image_XilianCost"):loadTexture("public_gold.png")
		if globaldata.money >= 20000 then
			labelWidget:setColor(cc.c3b(162,255,169))
		else
			labelWidget:setColor(cc.c3b(255,162,162))
		end
	end

--[[
	-- 先隐藏两个层
	local panelOne = self.mRootWidget:getChildByName("Panel_One")
	panelOne:setVisible(false)

	local panelTwo = self.mRootWidget:getChildByName("Panel_Two")
	panelTwo:setVisible(false)

	if ticketCnt > 0 then -- 判断钻石和券的关系
		if ticketCnt*20 >= price then -- 宝石券够
			panelOne:setVisible(true)
			panelOne:getChildByName("Label_Currency_Stroke"):setString(price/20) -- 显示券的数量
			panelOne:getChildByName("Image_Currency"):loadTexture("public_currency_xilian.png")
		else
			panelTwo:setVisible(true)
			panelTwo:getChildByName("Label_Currency_Stroke"):setString(ticketCnt) -- 显示券
			panelTwo:getChildByName("Image_Currency"):loadTexture("public_currency_xilian.png")
			panelTwo:getChildByName("Image_Currency"):setVisible(true)
			panelTwo:getChildByName("Label_Diamond_Stroke"):setString(price - ticketCnt*20)  -- 显示剩余需要钻石
			panelTwo:getChildByName("Image_Diamond"):loadTexture("public_diamond.png")
			panelTwo:getChildByName("Image_Diamond"):setVisible(true)
		end
	elseif ticketCnt == 0 then -- 只有钻石
		panelOne:setVisible(true)
		panelOne:getChildByName("Label_Currency_Stroke"):setString(price)
		panelOne:getChildByName("Image_Currency"):loadTexture("public_diamond.png")
	end
]]

end

-- 窗口更新
function EquipInfoWindow:tick()
	-- 更新头像透明度
	self:updateHeroIconOpacity()
end

-- 镶嵌成功回包
function EquipInfoWindow:onDiamondXiangqianSuccess(equipObj, propTbl)
	-- 关闭背包
	self:closeBag()
	-- 关闭详情
	self:closeInfo()
	-- 更新宝石信息
	self:updateDiamondInfo(equipObj, propTbl)
end

-- 脱掉宝石成功回包
function EquipInfoWindow:onDiamondPutoffSuccess(equipObj, propTbl)
	-- 关闭背包
	self:closeInfo()
	-- 更新宝石信息
	self:updateDiamondInfo(equipObj, propTbl)
end

function EquipInfoWindow:destroyRootNode()
	cclog("=====HeroInfoWindow:destroyRootNode=====")
	if not self.mRootNode then return end


	preXilianPropPostionTbl = {}

	if self.mSchedulerEntry then
		local scheduler = cc.Director:getInstance():getScheduler()
		scheduler:unscheduleScriptEntry(self.mSchedulerEntry)
		self.mSchedulerEntry = nil
	end

	if self.mHeroIconListScrollingAnimNode then
		self.mHeroIconListScrollingAnimNode:destroy()
		self.mHeroIconListScrollingAnimNode = nil
	end
	
	if self.mHeroIconListSelectedAnimNode then
		self.mHeroIconListSelectedAnimNode:destroy()
		self.mHeroIconListSelectedAnimNode = nil
	end

	GUIEventManager:unregister("itemInfoChanged", self.freshStoneInfo)
	GUIEventManager:unregister("diamondXiangqianSuccess", self.onDiamondXiangqianSuccess)
	GUIEventManager:unregister("diamondPutoffSuccess", self.onDiamondPutoffSuccess)
	GUIEventManager:unregister("xilianPriceChanged", self.refreshXilianPrice)
	GUIEventManager:unregister("itemInfoChanged", self.refreshXilianPrice)

	self.mTopRoleInfoPanel:destroy()
	self.mTopRoleInfoPanel = nil

	self.mRootNode:removeFromParent(true)
	self.mRootNode 					= 	nil
	self.mRootWidget 				= 	nil
	self.mDiamondComposeWindow 		= 	nil

	--------------------------------------
	self.mXiangqianEquipWidget		=	nil
	self.mXilianEquipWidget 		=	nil
	--------------------------------------

	self.mXiangqianWidgetList		=	{}								-- 容器
	self.mQianghuaWidgetList 		=	{}								-- 容器
	self.mXilianWidgetList 			=	{}								-- 容器
	self.mXilianItemList			=	{}								

	--------------------------------------
	self.mLastChooseHeroWidget		=	nil
	self.mCurSelectedHeroIndex		=	nil
	self.mLastChooseOption 			=	nil
	---------------------------------------------------
	self.mPanelQianghua				=	nil
	self.mPanelXiangqian			=	nil
	self.mPanelXilian				=	nil
	---------------------------------------------------
	self.mForEquipOn				=	nil
	self.mNeedPutonEquipHeroIndex	=	nil
	---------------------------------------------------
	self.mEquipType					=	nil
end

function EquipInfoWindow:Destroy()
	cclog("=====EquipInfoWindow:Destroy=====")
	self.mRootNode:setVisible(false)
	CommonAnimation.clearAllTextures()
end

function EquipInfoWindow:onEventHandler(event, func)
	if event.mAction == Event.WINDOW_SHOW then
		GUIWidgetPool:preLoadWidget("Equip_Qianghua", true)
		GUIWidgetPool:preLoadWidget("Equip_Xiangqian", true)
		GUIWidgetPool:preLoadWidget("Hero_ListCell", true)
		self:Load(event)
		---------停止画主城镇界面
		EventSystem:PushEvent(Event.GUISYSTEM_DISABLEDRAW_HOMEWINDOW)
		---------
		NoticeSystem:doSingleUpdate(self.mName)
		self.mCallFuncAfterDestroy = func
		EquipGuideTwo:doEquipGuide()
	elseif event.mAction == Event.WINDOW_HIDE then
		EquipGuideTwo:doEquipDestroy()
		GUIWidgetPool:preLoadWidget("Equip_Qianghua", false)
		GUIWidgetPool:preLoadWidget("Equip_Xiangqian", false)
		GUIWidgetPool:preLoadWidget("Hero_ListCell", false)
		self:Destroy()
		---------开启画主城镇界面
		EventSystem:PushEvent(Event.GUISYSTEM_EABLEDRAW_HOMEWINDOW)
		---------
		-- 红点刷新
		HomeNoticeInnerImpl:doUpdate()
		if self.mCallFuncAfterDestroy then
			self.mCallFuncAfterDestroy()
			self.mCallFuncAfterDestroy = nil
		end
	end
end

function EquipInfoWindow:showEquipDetailInfo(widget)

--	print("选中的装备", widget:getTag())

	local detailWidget = GUIWidgetPool:createWidget("HeroEquipInfo")
	self.mRootNode:addChild(detailWidget, 100)

	local infoWindow = detailWidget:getChildByName("Panel_EquipInfo")
	infoWindow:setVisible(true)

	-- 按钮
	detailWidget:getChildByName("Panel_DiamondBtn"):setVisible(false)
	detailWidget:getChildByName("Panel_EquipBtn"):setVisible(true)
	detailWidget:getChildByName("Panel_ShizhuangBtn"):setVisible(false)
	detailWidget:getChildByName("Panel_DiamondsCom"):setVisible(false)

	-- 关闭窗口
	local function closeEquipInfo()
		detailWidget:removeFromParent(true)
	end
	registerWidgetReleaseUpEvent(detailWidget, closeEquipInfo)

	detailWidget:getChildByName("Button_Unload"):setVisible(false)

	detailWidget:getChildByName("Button_Strengthen"):setVisible(false)

	detailWidget:getChildByName("Button_Exchange"):setVisible(false)

	-- 显示装备信息
	local function updateEquipInfo()
		local equipList = self:getCurSelectedHeroEquipList()

		local equipId = widget:getTag()
		local equipInfo = DB_EquipmentConfig.getDataById(equipId)
		local descId = equipInfo.EquipText

		local function findEquipById(equipId)
			for i = 1, #equipList do
--				print("链表中的装备", equipList[i]:getKeyValue("id"))
				if equipId == equipList[i]:getKeyValue("id") then
					return equipList[i]
				end
			end
		end
		local equipObject = findEquipById(equipId)

		-- 显示名称
		local equipInfo = DB_EquipmentConfig.getDataById(equipObject:getKeyValue("id"))
		local equipNameId = equipInfo.Name
		local equipName = getDictionaryText(equipNameId)
		detailWidget:getChildByName("Label_Name"):setString(string.format("%s Lv.%d", equipName, equipObject:getKeyValue("level")))

		-- 装备图标
		local equipWidget = widget:clone()
		equipWidget:setTouchEnabled(false)
		detailWidget:getChildByName("Panel_EquipIcon"):addChild(equipWidget)
		equipWidget:setScale(1)
		equipWidget:setOpacity(255)

		-- 描述
	--	detailWidget:getChildByName("Label_Des"):setString(getDictionaryText(descId))
		richTextCreate(detailWidget:getChildByName("Panel_Des"), getDictionaryText(descId),true)

		-- 初始属性
		local propList = equipObject:getKeyValue("propList")
		local cnt = 1
		for k, v in pairs(propList) do
			detailWidget:getChildByName(string.format("Label_Init_%d", cnt)):setString(string.format("初始%s +%d", globaldata:getTypeString(k), v))
			cnt = cnt + 1
		end

		-- 成长属性
		local growPropList = equipObject:getKeyValue("growPropList")
		cnt = 1
		for k, v in pairs(growPropList) do
			detailWidget:getChildByName(string.format("Label_Add_%d", cnt)):setString(string.format("成长%s +%d", globaldata:getTypeString(k), v))
			cnt = cnt + 1
		end

		-- 等级加成
		local function updateEquipLevelProp()
			local parentNode = detailWidget:getChildByName("ScrollView_Equip"):getChildByName("Panel_Level")
			--颜色变化
			for lv = 10, 100, 10 do
				if lv <= equipObject.level then
					parentNode:getChildByName("Label_Level_"..lv):setColor(cc.c3b(96, 194, 249))
				else
					parentNode:getChildByName("Label_Level_"..lv):setColor(cc.c3b(175, 175, 175))
				end
			end
			-- 属性加成
			for i = 1, 10 do
				local lvType = equipInfo["AttributeType"..i]
				local lvValue = equipInfo["AttributeValue"..i]
				parentNode:getChildByName("Label_Level_"..tostring(i*10)):setString(tostring(i*10).."级:"..globaldata:getTypeString(lvType).."+"..tostring(lvValue))
			end
		end
		updateEquipLevelProp()

		-- 成长属性显示
		if 1 == cnt then
--			detailWidget:getChildByName("Panel_Add"):setVisible(false)
		else
			for i = 1, 4 do
				if i <= cnt-1 then
					detailWidget:getChildByName(string.format("Label_Add_%d", i)):setVisible(true)
				else
--					detailWidget:getChildByName(string.format("Label_Add_%d", i)):setVisible(false)
				end
			end
		end
--[[
		-- 宝石
		local diamondCnt = 0
		local diamondId = nil
		local diamondList = equipObject:getKeyValue("diamondList")
		for i = 1, #diamondList do
			if 0 ~= diamondList[i] then
				local wgt = createDiamondWidget(diamondList[i])
				detailWidget:getChildByName(string.format("Image_Diamond_Bg_%d", i)):getChildByName("Panel_Diamond"):addChild(wgt)
				diamondCnt = diamondCnt + 1
				diamondId = diamondList[i]
			end
		end

		-- 宝石属性加成
		if diamondCnt > 0 then
			for j = 1, 3 do
				detailWidget:getChildByName("Label_Effect_"..j):setVisible(false)
			end

			local propTbl = {}

			for i = 1, #diamondList do
			if 0 ~= diamondList[i] then
				local diamondId = diamondList[i]
				local diamondData = DB_Diamond.getDataById(diamondId) 
				local propCnt = diamondData.Count
				for j = 1, propCnt do
					local propType = diamondData["Type"..j]
			 		local propValue = diamondData["value"..j]
			 		if not propTbl[propType] then
			 			propTbl[propType] = 0
			 		end
			 		propTbl[propType] = propTbl[propType] + propValue
				end
			end

			local idx = 0
			for k, v in pairs(propTbl) do
				idx = idx + 1
				detailWidget:getChildByName("Label_Effect_"..idx):setString(string.format("%s + %d", globaldata:getTypeString(k), v))
				detailWidget:getChildByName("Label_Effect_"..idx):setVisible(true)
			end
		end
		else
			for j = 1, 3 do
				detailWidget:getChildByName("Label_Effect_"..j):setVisible(false)
			end
		end
]]
	end
	updateEquipInfo()
	-- 隐藏
	detailWidget:getChildByName("Panel_DiamondsCom"):setVisible(false)
end

return EquipInfoWindow