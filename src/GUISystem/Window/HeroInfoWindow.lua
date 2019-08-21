-- Name: 	HeroInfoWindow
-- Func：	战队界面
-- Author:	WangShengdong
-- Data:	14-12-8

local longPressTimeVal = 0.15 -- 长摁间隔

local dantengVavlue = true

HeroInfoWindow = 
{
	mName 				=	"HeroInfoWindow",
	mRootNode			=	nil,
	mRootWidget			=	nil,
	mTopRoleInfoPanel	=	nil,	-- 顶部人物信息面板
	--------------------------------------------------
	mSchedulerEntry 	=	nil,	-- 定时器
	mHeroIconList		=	{},
	--------------------------------------------------
	mCurSelectedHeroIndex	=	1,
	mPreSelectedHeroIndex 	=	nil,
	mHeroAnimPanel			=	nil,	-- 存放英雄动画的层
	mPrePicShowed 			=	false,	-- 前景原画是否显示
	mLastShowPanel 			=	nil,	-- 上次显示的窗口
	mPeiyangPanel			=	nil,
	mEquipPanel				=	nil,
	mSkillPanel				=	nil,
	mPropPanel				=	nil,
	mDestinyPanel			=	nil,
	mLastChooseWidget		=	nil,	-- 最后一次点击的标签选项
	mHeroIdTbl 				=	{},		-- 英雄Id数组
	mExpProgressTimerWidget	=	nil,	-- 经验条
	mExpItemWidgetList		=	{},		-- 经验药列表
	mCurSelectedHeroPeiyangBtn	=	nil,	-- 当前选中的培养按钮
	mSchedulerHandler 		=	nil,	-- 定时器
	mPushDownTime			=	0,
	mReleaseUpTime			=	0,
	mRequestLvUpEnabled		=	true,
	mHeroLvUpInfo			=	{heroId = nil, itemId = 0, itemCnt = 0},
	---------------------------------------------------------------------
	mShowWindowFuncHandler  =   nil,
	mSkillSelectedAnimNode	=	nil,
	mBtnAnimNodeList		=	{},
	--------------------------------------------------------------------
	mCallFuncAfterDestroy	=	nil,
	mHeroQualityBAnimNode	=	nil,	-- 英雄特效
	mHeroIconListScrollingAnimNode	=	nil,	-- 滑动特效
	mHeroIconListSelectedAnimNode	=	nil,	-- 选中特效
	mData 					=	nil,	
}

function HeroInfoWindow:Load(event)
	cclog("=====HeroInfoWindow:Load=====begin")
	if self.mRootNode then
		self.mRootNode:setVisible(true)
	return end

	dantengVavlue = false

	self.mCurSelectedHeroIndex = 2

	-- self.mRootNode = cc.Node:create()
	-- GUISystem:GetRootNode():addChild(self.mRootNode)

	GUIEventManager:registerEvent("equipChanged", self, self.onEquipChanged)
	GUIEventManager:registerEvent("itemInfoChanged", self, self.onItemInfoChanged)
--	GUIEventManager:registerEvent("autoSkillUpdate", self, self.onSkillAutoUpdate)
	GUIEventManager:registerEvent("heroAddSync", self, self.onHeroAddFunc)
	GUIEventManager:registerEvent("heroInfoSync", self, self.updateHeroCombat)


	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_REQUEST_JINJIEINFO_, handler(self, self.onRequestJinjieInfo))
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_REQUEST_DOPEIYANG_, handler(self, self.onRequestDoPeiyang))
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_REQUEST_DOJINHUA_, handler(self, self.onRequestDoJinhua))
	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_REQUEST_DOJINJIE_, handler(self, self.onRequrestDoJinjie))

	-- 预加载大图
	local function preloadTexture()
		TextureSystem:loadPlist_iconskill()
	end
	preloadTexture()


	--初始化界面
	self:InitLayout()
	self.mRootNode:setVisible(true)

	-- 符文旋转
	self:initFuwenRotate()

	-- 创建滑动控件
	self:createScrollViewWidget()

	-- 载入英雄
	self:loadAllHero()

	-- 灰化大图
	self:doPicGray()

	-- 显示英雄信息
	self:updateHeroInfo()

	local defaultShow = nil

	self.mData = event.mData

	if event.mData and event.mData[3] then
		self.mCurSelectedHeroPeiyangBtn = self.mPeiyangPanel:getChildByName("Image_Page_Stars")
	end

	self.mPeiyangPanel:getChildByName("Image_Page_Stars")

	if event.mData then
		if event.mData[2] then
			defaultShow = event.mData[2]
		end
	else
		defaultShow = 1
	end

	-- 默认显示人物信息
	if defaultShow == 1 then
		self:showHeroInfo(self.mRootWidget:getChildByName("Image_Peiyang"))
	elseif defaultShow == 2 then
		self:showHeroInfo(self.mRootWidget:getChildByName("Image_Zhuangbei"))
	elseif defaultShow == 3 then 
		self:showHeroInfo(self.mRootWidget:getChildByName("Image_Jineng"))
	elseif defaultShow == 4 then 
		self:showHeroInfo(self.mRootWidget:getChildByName("Image_Shuxing"))
	elseif defaultShow == 5 then 
		self:showHeroInfo(self.mRootWidget:getChildByName("Image_DangAn"))
	end

	if not self.mSchedulerEntry then
		local scheduler = cc.Director:getInstance():getScheduler()
		self.mSchedulerEntry = scheduler:scheduleScriptFunc(handler(self, self.tick), 0, false)
	end

	-- 初始化主角控件
	self:initLeaderWidget()

	cclog("=====HeroInfoWindow:Load=====end")
end

function HeroInfoWindow:InitLayout()
	self.mRootNode = cc.Node:create()
	GUISystem:GetRootNode():addChild(self.mRootNode)
	self.mRootWidget = GUIWidgetPool:createWidget("HeroList")
	self.mRootNode:addChild(self.mRootWidget)
	self.mRootNode:setVisible(false)

	local function closeWindow()	
		EventSystem:PushEvent(Event.GUISYSTEM_HIDE_HEROINFOWINDOW)

		if PveGuideSix:canGuide() then
			local window = GUISystem:GetWindowByName("HomeWindow")
			if window.mRootWidget then
				local guideBtn = window.mRootWidget:getChildByName("Button_Adventure")
				local size = guideBtn:getContentSize()
				local pos = guideBtn:getWorldPosition()
				pos.x = pos.x - size.width/2
				pos.y = pos.y - size.height/2
				local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
				PveGuideSix:step(1, touchRect)
			end
		end
	end

	self.mTopRoleInfoPanel = TopRoleInfoPanel:new()
	local topInfoPanel = self.mTopRoleInfoPanel:init(self.mRootNode,ROLE_TITLE_TYPE.TITLE_HERO, closeWindow)

	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Panel_HeroPic"),handler(self, self.showHeroPic))
	self.mRootWidget:getChildByName("Image_PreHeroPic"):setOpacity(0)

	self.mPeiyangPanel = self.mRootWidget:getChildByName("Panel_PeiYang")
	self.mEquipPanel = self.mRootWidget:getChildByName("Panel_ZhuangBei")
	self.mSkillPanel = self.mRootWidget:getChildByName("Panel_JiNeng")
	self.mPropPanel = self.mRootWidget:getChildByName("Panel_ShuXing")
	self.mDestinyPanel = self.mRootWidget:getChildByName("Panel_DangAn")
	self.mHeroAnimPanel = self.mRootWidget:getChildByName("Panel_HeroAnim")

	-- 点击属性页
	local function onPageBtnTouched(widget)
		self:showHeroInfo(widget)
		GUISystem:playSound("tabPageSound")
	end

	local btn0 = nil
	local pagWidget = self.mRootWidget:getChildByName("Panel_Pag")

	btn0 = pagWidget:getChildByName("Image_Peiyang")
	btn0:setTag(5)
	registerWidgetPushDownEvent(btn0, onPageBtnTouched)

	self.mBtnAnimNodeList[5] = AnimManager:createAnimNode(8032)
--	btn0:getChildByName("Panel_Animation"):removeAllChildren()
	btn0:getChildByName("Panel_Animation"):addChild(self.mBtnAnimNodeList[5]:getRootNode(), 100)
	self.mBtnAnimNodeList[5]:play("hero_page_chosen_2", true)

	btn0 = pagWidget:getChildByName("Image_Shuxing")
	btn0:setTag(3)
	registerWidgetPushDownEvent(btn0, onPageBtnTouched)

	self.mBtnAnimNodeList[3] = AnimManager:createAnimNode(8032)
--	btn0:getChildByName("Panel_Animation"):removeAllChildren()
	btn0:getChildByName("Panel_Animation"):addChild(self.mBtnAnimNodeList[3]:getRootNode(), 100)
	self.mBtnAnimNodeList[3]:play("hero_page_chosen_2", true)

	btn0 = pagWidget:getChildByName("Image_Jineng")
	btn0:setTag(2)
	registerWidgetPushDownEvent(btn0, onPageBtnTouched)

	self.mBtnAnimNodeList[2] = AnimManager:createAnimNode(8032)
--	btn0:getChildByName("Panel_Animation"):removeAllChildren()
	btn0:getChildByName("Panel_Animation"):addChild(self.mBtnAnimNodeList[2]:getRootNode(), 100)
	self.mBtnAnimNodeList[2]:play("hero_page_chosen_2", true)

	btn0 = pagWidget:getChildByName("Image_DangAn")
	btn0:setTag(1)
	registerWidgetPushDownEvent(btn0, onPageBtnTouched)

	self.mBtnAnimNodeList[1] = AnimManager:createAnimNode(8032)
--	btn0:getChildByName("Panel_Animation"):removeAllChildren()
	btn0:getChildByName("Panel_Animation"):addChild(self.mBtnAnimNodeList[1]:getRootNode(), 100)
	self.mBtnAnimNodeList[1]:play("hero_page_chosen_2", true)

	-- 左面滑动条适配
	local function doAdapter1()
		local leftPanel = self.mRootWidget:getChildByName("Panel_Left")
		leftPanel:setPositionX(getGoldFightPosition_LD().x)
	end
	doAdapter1()

	-- 右面的属性面板适配
	local function doAdapter2()
		local propPanel = self.mRootWidget:getChildByName("Panel_HeroInfo")
		propPanel:setPositionX(getGoldFightPosition_RD().x - propPanel:getContentSize().width)
		-- 添加自定义控件
		self:initCustomWidget()
	end
	doAdapter2()

	-- 底部的菜单列表适配
	local function doAdapter3()
		local menuList = self.mRootWidget:getChildByName("Panel_Pag")
		menuList:setPosition(getGoldFightPosition_RD().x - menuList:getContentSize().width, getGoldPosition().y)
	end
	doAdapter3()

	-- 显示升级界面
--	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_Shengji"), handler(self, self.showLevelupPanel))
	-- 隐藏升级界面
--	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_SJBack"), handler(self, self.hideLevelupPanel))
	-- 进化请求
	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_DoJinhua"),handler(self, self.requestDoJinhua))
	-- 进阶请求
	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_DoJinjie"),handler(self, self.requrestDoJinjie))

	-- 换图
--	for i = 1, 4 do
--		self.mPeiyangPanel:getChildByName("Image_Medicine_"..tostring(i)):getChildByName("Image_Medicine"):loadTexture("item_yao"..tostring(i)..".png", 1)
--	end
--	self.mPeiyangPanel:getChildByName("Image_JinjieDaoju"):loadTexture("item_jinjie.png", 1)

	local function showHeroRelationShip()
		GUISystem:showHeroRelationShip()
	end
	
	self.mRootWidget:getChildByName("Image_HeroGroup"):setTouchEnabled(true)
	registerWidgetPushDownEvent(self.mRootWidget:getChildByName("Image_HeroGroup"), showHeroRelationShip)
	
end

-- 响应请求进阶信息
function HeroInfoWindow:onRequestJinjieInfo(msgPacket)
	GUISystem:hideLoading()
	if self.mRootWidget then
		local guid = msgPacket:GetString()
		local id = msgPacket:GetInt()
		local name = msgPacket:GetString()
		local curAdvanceLv = msgPacket:GetInt()
		local curCombat = msgPacket:GetInt()
		local reachMax = msgPacket:GetChar()
		if 0 == reachMax then	
			-- 隐藏
			self.mRootWidget:getChildByName("Button_DoJinjie"):setVisible(false)
			self.mRootWidget:getChildByName("Image_NextJinjieLv"):setVisible(false)
			self.mRootWidget:getChildByName("Image_CurJinjieLv"):setVisible(false)
			self.mRootWidget:getChildByName("Image_Arrow"):setVisible(false)
			self.mRootWidget:getChildByName("Image_MaxJinjie"):setVisible(true)
			self.mRootWidget:getChildByName("Panel_JinjieCost"):setVisible(false)
			return
		end
		local nextAdvanceLv = msgPacket:GetInt()
		local nextCombat = msgPacket:GetInt()
		local costCount = msgPacket:GetUShort() -- 花费类型数量

		-- 显示
		self.mRootWidget:getChildByName("Button_DoJinjie"):setVisible(true)
		self.mRootWidget:getChildByName("Image_NextJinjieLv"):setVisible(true)
		self.mRootWidget:getChildByName("Image_CurJinjieLv"):setVisible(true)
		self.mRootWidget:getChildByName("Image_Arrow"):setVisible(true)
		self.mRootWidget:getChildByName("Image_MaxJinjie"):setVisible(false)
		self.mRootWidget:getChildByName("Panel_JinjieCost"):setVisible(true)

		local consumeItem = {}

		for i = 1, costCount do
			local costType = msgPacket:GetInt()
			local costId = msgPacket:GetInt()
			local costNum = msgPacket:GetInt()
			consumeItem[i] = {costType, costId, costNum}
		end

		-- 材料一
		self.mRootWidget:getChildByName("Label_DiamondNum"):setString(consumeItem[1][3])
		-- 材料二
		self.mRootWidget:getChildByName("Label_JinjieDaojuNum"):setString(consumeItem[2][3])

		local function doUpdate()
			local heroId = self.mHeroIdTbl[self.mCurSelectedHeroIndex]
			local heroObj = globaldata:findHeroById(heroId)
			local jinjie = heroObj.advanceLevel
			self.mRootWidget:getChildByName("Image_CurJinjieLv"):loadTexture("heroselect_qualitynum_"..tostring(jinjie)..".png")
			if maxHeroJinjieLevel == jinjie then
				self.mRootWidget:getChildByName("Button_DoJinjie"):setVisible(false)
				self.mRootWidget:getChildByName("Image_NextJinjieLv"):setVisible(false)
				self.mRootWidget:getChildByName("Image_CurJinjieLv"):setVisible(false)
				self.mRootWidget:getChildByName("Image_Arrow"):setVisible(false)
				self.mRootWidget:getChildByName("Image_MaxJinjie"):setVisible(true)
				self.mRootWidget:getChildByName("Panel_JinjieCost"):setVisible(false)
			else
				self.mRootWidget:getChildByName("Button_DoJinjie"):setVisible(true)
				self.mRootWidget:getChildByName("Image_NextJinjieLv"):setVisible(true)
				self.mRootWidget:getChildByName("Image_CurJinjieLv"):setVisible(true)
				self.mRootWidget:getChildByName("Image_Arrow"):setVisible(true)
				self.mRootWidget:getChildByName("Image_MaxJinjie"):setVisible(false)
				self.mRootWidget:getChildByName("Panel_JinjieCost"):setVisible(true)
				self.mRootWidget:getChildByName("Image_NextJinjieLv"):loadTexture("heroselect_qualitynum_"..tostring(jinjie+1)..".png")
			end
		end
		doUpdate()	
	end
end

-- 请求执行进阶
function HeroInfoWindow:requrestDoJinjie(widget)
	GUISystem:playSound("homeBtnSound")

	local heroId = self.mHeroIdTbl[self.mCurSelectedHeroIndex]
	local heroObj = globaldata:findHeroById(heroId)

	local guid = heroObj.guid
	local id = heroObj.id

	local packet = NetSystem.mNetManager:GetSPacket()
    packet:SetType(PacketTyper._PTYPE_CS_REQUEST_DOJINJIE_)
    packet:PushString(guid)
    packet:PushInt(id)
    packet:Send()
    GUISystem:showLoading()
end

-- 响应请求执行进阶
function HeroInfoWindow:onRequrestDoJinjie(msgPacket)
	local heroId = self.mHeroIdTbl[self.mCurSelectedHeroIndex]
	local heroObj = globaldata:findHeroById(heroId)

	local preHeroInfo = 
	{
		id 			= 	heroObj.id,
		level 		= 	heroObj.level,
		starLevel 	=	heroObj.quality,
		colorLevel 	= 	heroObj.advanceLevel,
		combat 		=	heroObj.combat,
	}

	GUISystem:hideLoading()
	globaldata:updateOneHeroInfo(msgPacket)
	self:updateHeroInfo()

	local newHeroInfo = 
	{
		id 			= 	heroObj.id,
		level 		= 	heroObj.level,
		starLevel 	=	heroObj.quality,
		colorLevel 	= 	heroObj.advanceLevel,
		combat 		=	heroObj.combat,
	}

	self:showGrowUpResultWindow(preHeroInfo, newHeroInfo, "shengpin")

	GUIEventManager:pushEvent("combatChanged")
end

-- 请求进化
function HeroInfoWindow:requestDoJinhua(widget)
	GUISystem:playSound("homeBtnSound")

	local heroId = self.mHeroIdTbl[self.mCurSelectedHeroIndex]
	local heroObj = globaldata:findHeroById(heroId)
	local guid = heroObj.guid
	local id = heroObj.id

	local packet = NetSystem.mNetManager:GetSPacket()
    packet:SetType(PacketTyper._PTYPE_CS_REQUEST_DOJINHUA_)
    packet:PushString(guid)
    packet:PushInt(id)
    packet:Send()
    GUISystem:showLoading()
end

-- 响应请求进化
function HeroInfoWindow:onRequestDoJinhua(msgPacket)
	GUISystem:hideLoading()

	local heroId = self.mHeroIdTbl[self.mCurSelectedHeroIndex]
	local heroObj = globaldata:findHeroById(heroId)

	local function doUpdate()
		local needChipCount	= heroObj.chipCount -- 需要的碎片数量
		local curChipCount = self.mLastLeftChipCount - needChipCount
		if curChipCount <=0 then
			curChipCount = 0
		end
		self.mLastLeftChipCount = curChipCount

		local preHeroInfo = 
		{
			id 			= 	heroObj.id,
			level 		= 	heroObj.level,
			starLevel 	=	heroObj.quality,
			colorLevel 	= 	heroObj.advanceLevel,
			combat 		=	heroObj.combat,
		}

		-- 更新新的需要碎片的数量
		globaldata:updateOneHeroInfo(msgPacket)
		needChipCount	= heroObj.chipCount -- 需要的碎片数量
		-- 显示数量(显示扣除后的)
		self.mRootWidget:getChildByName("Label_ChipNum"):setString(tostring(curChipCount).."/"..tostring(needChipCount))
		-- 星星
		local color = heroObj.quality
		for i = 1, 6 do
			self.mRootWidget:getChildByName("Image_JinjieStar"..tostring(i)):loadTexture("public_hero_starbg_big.png")
		end
	--	for i = 1, color do
	--		self.mRootWidget:getChildByName("Image_JinjieStar"..tostring(i)):loadTexture("public_star1.png")
	--	end

		if 0 == color then

		elseif color >= 1 and color <= 6 then
			for i = 1, color do
				self.mRootWidget:getChildByName("Image_JinjieStar"..tostring(i)):loadTexture("public_hero_star1_big.png")
			end
		elseif color >= 7 and color <= 12 then
			for i = 1, 6 do
				self.mRootWidget:getChildByName("Image_JinjieStar"..tostring(i)):loadTexture("public_hero_star1_big.png")
			end
			for i = 1, color - 6 do
				self.mRootWidget:getChildByName("Image_JinjieStar"..tostring(i)):loadTexture("public_hero_star2_big.png")
			end
		end

		if color == 12 then
			self.mRootWidget:getChildByName("Label_ChipNum"):setString("已进化至顶级")
			self.mRootWidget:getChildByName("Label_ChipNum"):setColor(cc.c3b(255, 255, 255))
		end

		local newHeroInfo = 
		{
			id 			= 	heroObj.id,
			level 		= 	heroObj.level,
			starLevel 	=	heroObj.quality,
			colorLevel 	= 	heroObj.advanceLevel,
			combat 		=	heroObj.combat,
		}

		self:updateHeroInfo()
		self:showGrowUpResultWindow(preHeroInfo, newHeroInfo, "shengxing")

		GUIEventManager:pushEvent("updateJinHua")
	end
	doUpdate()
end

-- 显示升星&升品
function HeroInfoWindow:showGrowUpResultWindow(preHeroInfo, newHeroInfo, upType)
	local window = GUIWidgetPool:createWidget("Hero_Grow")

	-- 刷新左侧头像
	self:updateHeroIconTbl()

	if "shengxing" == upType then
		CommonAnimation.PlayEffectId(5006)
	elseif "shengpin" == upType then
		CommonAnimation.PlayEffectId(5007)
	end

	-- 背景适配
	local winSize = cc.Director:getInstance():getVisibleSize()
	local imgSize = window:getChildByName("Image_Bg"):getContentSize()
	imgSize.width = winSize.width
	window:getChildByName("Image_Bg"):setContentSize(imgSize)

	local colorTbl = {}
	colorTbl[0] = cc.c3b(255,255,255)
	colorTbl[1] = cc.c3b(0,255,48)
	colorTbl[2] = cc.c3b(0,255,48)
	colorTbl[3] = cc.c3b(26,193,255)
	colorTbl[4] = cc.c3b(26,193,255)
	colorTbl[5] = cc.c3b(188,59,255)
	colorTbl[6] = cc.c3b(188,59,255)
	colorTbl[7] = cc.c3b(255,170,59)

	-- 旧信息
	window:getChildByName("Label_Zhanli_Pre"):setString(preHeroInfo.combat)
	local preIcon = createHeroIcon(preHeroInfo.id, preHeroInfo.level, preHeroInfo.starLevel, preHeroInfo.colorLevel)
	window:getChildByName("Panel_HeroIcon_Pre"):addChild(preIcon)
	-- 姓名&进阶
	local heroData 		= DB_HeroConfig.getDataById(preHeroInfo.id)
	local heroNameId 	= heroData.Name
	local lblWidget 	= window:getChildByName("Panel_HeroIcon_Pre"):getChildByName("Label_HeroName&Quality_Stroke")
	lblWidget:setString(getDictionaryText(heroNameId).."+"..tostring(preHeroInfo.colorLevel))
	lblWidget:setColor(colorTbl[preHeroInfo.colorLevel])


	-- 新信息
	window:getChildByName("Label_Zhanli_Cur"):setString(newHeroInfo.combat)
	local newIcon = createHeroIcon(newHeroInfo.id, newHeroInfo.level, newHeroInfo.starLevel, newHeroInfo.colorLevel)
	window:getChildByName("Panel_HeroIcon_Cur"):addChild(newIcon)
	-- 姓名&进阶
	heroData 	= DB_HeroConfig.getDataById(newHeroInfo.id)
	heroNameId 	= heroData.Name
	lblWidget 	= window:getChildByName("Panel_HeroIcon_Cur"):getChildByName("Label_HeroName&Quality_Stroke")
	lblWidget:setString(getDictionaryText(heroNameId).."+"..tostring(newHeroInfo.colorLevel))
	lblWidget:setColor(colorTbl[newHeroInfo.colorLevel])

	-- 更新成长信息
	local function updateGrowInfo()
		-- 生命
		local oldValue = math.pow(heroData.QualityAddHP/10, preHeroInfo.starLevel-1)*heroData.LevelAddHP
		oldValue = math.floor(oldValue)
		local newValue = math.pow(heroData.QualityAddHP/10, newHeroInfo.starLevel-1)*heroData.LevelAddHP
		newValue = math.floor(newValue)
		window:getChildByName("Panel_Property_1"):getChildByName("Label_Property_Pre"):setString(oldValue)
		window:getChildByName("Panel_Property_1"):getChildByName("Label_Property_Cur"):setString(newValue)

		-- 格斗
		oldValue = math.pow(heroData.QualityAddPhyAttack/10, preHeroInfo.starLevel-1)*heroData.LevelAddPhyAttack
		oldValue = string.format("%.2f", oldValue)
		newValue = math.pow(heroData.QualityAddPhyAttack/10, newHeroInfo.starLevel-1)*heroData.LevelAddPhyAttack
		newValue = string.format("%.2f", newValue)
		window:getChildByName("Panel_Property_2"):getChildByName("Label_Property_Pre"):setString(oldValue)
		window:getChildByName("Panel_Property_2"):getChildByName("Label_Property_Cur"):setString(newValue)

		-- 功夫
		oldValue = math.pow(heroData.QualityAddHit/10, preHeroInfo.starLevel-1)*heroData.LevelAddHit
		oldValue = string.format("%.2f", oldValue)
		newValue = math.pow(heroData.QualityAddHit/10, newHeroInfo.starLevel-1)*heroData.LevelAddHit
		newValue = string.format("%.2f", newValue)
		window:getChildByName("Panel_Property_3"):getChildByName("Label_Property_Pre"):setString(oldValue)
		window:getChildByName("Panel_Property_3"):getChildByName("Label_Property_Cur"):setString(newValue)

		-- 柔术
		oldValue = math.pow(heroData.QualityAddDodge/10, preHeroInfo.starLevel-1)*heroData.LevelAddDodge
		oldValue = string.format("%.2f", oldValue)
		newValue = math.pow(heroData.QualityAddDodge/10, newHeroInfo.starLevel-1)*heroData.LevelAddDodge
		newValue = string.format("%.2f", newValue)
		window:getChildByName("Panel_Property_4"):getChildByName("Label_Property_Pre"):setString(oldValue)
		window:getChildByName("Panel_Property_4"):getChildByName("Label_Property_Cur"):setString(newValue)
	end
	updateGrowInfo()

	-- 更新职业信息
	local function updateGroupInfo()
		-- 旧的
		window:getChildByName("Panel_HeroIcon_Pre"):getChildByName("Image_Group"):loadTexture("hero_group"..heroData.HeroGroup..".png")
		window:getChildByName("Panel_HeroIcon_Pre"):getChildByName("Image_Group_Quliaty"):loadTexture("hero_group"..heroData.HeroGroup.."_"..preHeroInfo.colorLevel..".png")
		-- 新的
		window:getChildByName("Panel_HeroIcon_Cur"):getChildByName("Image_Group"):loadTexture("hero_group"..heroData.HeroGroup..".png")
		window:getChildByName("Panel_HeroIcon_Cur"):getChildByName("Image_Group_Quliaty"):loadTexture("hero_group"..heroData.HeroGroup.."_"..newHeroInfo.colorLevel..".png")
	end
	updateGroupInfo()

	local function closeWindow()
		window:removeFromParent(true)
		window = nil
	end
	registerWidgetReleaseUpEvent(window:getChildByName("Button_Close"), closeWindow)

	self.mRootNode:addChild(window, 100)

	local animName = 
	{
		shengxing 	= {"hero_up_star_1", "hero_up_star_2"},
		shengpin 	= {"hero_up_quality_1", "hero_up_quality_2"},
	}

	local function addAnim()
		local animNode = AnimManager:createAnimNode(8038)

		local function xxx()
			animNode:play(animName[upType][2], true)

			window:getChildByName("Panel_HeroInfo"):setVisible(true)

			local function func1()
				window:getChildByName("Panel_ZhanliInfo"):setVisible(true)
			end

			local function func2()
				if "shengxing" == upType then
					window:getChildByName("Panel_Grow_Star"):setVisible(true)
				elseif "shengpin" == upType then
					window:getChildByName("Panel_Grow_Quality"):setVisible(true)
				end
			end

			local function func3()
				window:getChildByName("Button_Close"):setVisible(true)
			end

			local act0 = cc.DelayTime:create(1)
			local act1 = cc.CallFunc:create(func1)
			local act2 = cc.DelayTime:create(1)
			local act3 = cc.CallFunc:create(func2)
			local act4 = cc.DelayTime:create(1)
			local act5 = cc.CallFunc:create(func3)
			window:runAction(cc.Sequence:create(act0, act1, act2, act3, act4, act5))
		end
		
		window:getChildByName("Panel_Title_Animation"):addChild(animNode:getRootNode(), 100)
		animNode:play(animName[upType][1], false, xxx)
	end
--	addAnim()

	local function addAnim2()
			local animNode = AnimManager:createAnimNode(8038)

			local function xxx()
				animNode:play(animName[upType][2], true)

				local actWidget = nil

				actWidget = window:getChildByName("Panel_HeroInfo")
				actWidget:setOpacity(0)
				actWidget:setVisible(true)
				actWidget:runAction(cc.FadeIn:create(0.1))

				actWidget = window:getChildByName("Panel_ZhanliInfo")
				actWidget:setOpacity(0)
				actWidget:setVisible(true)
				actWidget:runAction(cc.FadeIn:create(0.2))

				if "shengxing" == upType then
					actWidget = window:getChildByName("Panel_Grow_Star")
				elseif "shengpin" == upType then
					actWidget = window:getChildByName("Panel_Grow_Quality")
				end
				actWidget:setOpacity(0)
				actWidget:setVisible(true)
				actWidget:runAction(cc.FadeIn:create(0.3))

				actWidget = window:getChildByName("Button_Close")
				actWidget:setVisible(true)
				actWidget:setOpacity(0)
				actWidget:runAction(cc.FadeIn:create(0.4))
			end
			
			window:getChildByName("Panel_Title_Animation"):addChild(animNode:getRootNode(), 100)
			animNode:play(animName[upType][1], false, xxx)
		end
	addAnim2()
end

-- 响应请求进阶信息
function HeroInfoWindow:onRequestJinjieInfo(msgPacket)
	GUISystem:hideLoading()
	if self.mRootWidget then
		local guid = msgPacket:GetString()
		local id = msgPacket:GetInt()
		local name = msgPacket:GetString()
		local curAdvanceLv = msgPacket:GetInt()
		local curCombat = msgPacket:GetInt()
		local reachMax = msgPacket:GetChar()
		if 0 == reachMax then	
			-- 隐藏
			self.mRootWidget:getChildByName("Button_DoJinjie"):setVisible(false)
			self.mRootWidget:getChildByName("Image_NextJinjieLv"):setVisible(false)
			self.mRootWidget:getChildByName("Image_CurJinjieLv"):setVisible(false)
			self.mRootWidget:getChildByName("Image_Arrow"):setVisible(false)
			self.mRootWidget:getChildByName("Image_MaxJinjie"):setVisible(true)
			self.mRootWidget:getChildByName("Panel_JinjieCost"):setVisible(false)
			return
		end
		local nextAdvanceLv = msgPacket:GetInt()
		local nextCombat = msgPacket:GetInt()
		local costCount = msgPacket:GetUShort() -- 花费类型数量

		-- 显示
		self.mRootWidget:getChildByName("Button_DoJinjie"):setVisible(true)
		self.mRootWidget:getChildByName("Image_NextJinjieLv"):setVisible(true)
		self.mRootWidget:getChildByName("Image_CurJinjieLv"):setVisible(true)
		self.mRootWidget:getChildByName("Image_Arrow"):setVisible(true)
		self.mRootWidget:getChildByName("Image_MaxJinjie"):setVisible(false)
		self.mRootWidget:getChildByName("Panel_JinjieCost"):setVisible(true)

		local function updateJinjieInfo()
			self.mJinjiePanel:getChildByName("Label_JinjieCurCombat"):setString("战力"..tostring(curCombat))
			self.mJinjiePanel:getChildByName("Label_JinjieNextCombat"):setString("战力"..tostring(nextCombat))
			self.mJinjiePanel:getChildByName("Label_JinjieCurLv"):setString("+"..tostring(curAdvanceLv))
			self.mJinjiePanel:getChildByName("Label_JinjieNextLv"):setString("+"..tostring(nextAdvanceLv))
			self.mJinjiePanel:getChildByName("Label_JinjieCurName"):setString(name)
			self.mJinjiePanel:getChildByName("Label_JinjieNextName"):setString(name)
		end

		local consumeItem = {}

		for i = 1, costCount do
			local costType = msgPacket:GetInt()
			local costId = msgPacket:GetInt()
			local costNum = msgPacket:GetInt()
			consumeItem[i] = {costType, costId, costNum}
		end
		
		-- 先全部隐藏
		for i = 1, 3 do
			self.mPeiyangPanel:getChildByName("Label_Item"..tostring(i).."_Num"):setVisible(false)
			self.mPeiyangPanel:getChildByName("Panel_Item"..tostring(i)):removeAllChildren()
		end

		-- 显示金币
		for i = 1, #consumeItem do
			if 2 == consumeItem[i].costType then
				self.mPeiyangPanel:getChildByName("Label_CurrencyNum"):setString(tonumber(consumeItem.costNum))
			end
		end

		-- 显示物品
		local index = 1
		for i = 1, #consumeItem do
			if 2 ~= consumeItem.costType then
				local itemWidget = createCommonWidget(consumeItem.costType, consumeItem.costId)
				self.mPeiyangPanel:getChildByName("Panel_Item"..tostring(index)):addChild(itemWidget)
				self.mPeiyangPanel:getChildByName("Label_Item"..tostring(index).."_Num"):setVisible(true)
				self.mPeiyangPanel:getChildByName("Label_Item"..tostring(index).."_Num"):setString(consumeItem.costNum)
				index = index + 1
			end
		end
		

		local function doUpdate()
			local index = self.mCurSelectedHeroIndex
			local jinjie = globaldata:getHeroInfoByBattleIndex(index, "advanceLevel")
			self.mRootWidget:getChildByName("Image_CurJinjieLv"):loadTexture("heroselect_qualitynum_"..tostring(jinjie)..".png")
			if maxHeroJinjieLevel == jinjie then
				self.mRootWidget:getChildByName("Button_DoJinjie"):setVisible(false)
				self.mRootWidget:getChildByName("Image_NextJinjieLv"):setVisible(false)
				self.mRootWidget:getChildByName("Image_CurJinjieLv"):setVisible(false)
				self.mRootWidget:getChildByName("Image_Arrow"):setVisible(false)
				self.mRootWidget:getChildByName("Image_MaxJinjie"):setVisible(true)
				self.mRootWidget:getChildByName("Panel_JinjieCost"):setVisible(false)
			else
				self.mRootWidget:getChildByName("Button_DoJinjie"):setVisible(true)
				self.mRootWidget:getChildByName("Image_NextJinjieLv"):setVisible(true)
				self.mRootWidget:getChildByName("Image_CurJinjieLv"):setVisible(true)
				self.mRootWidget:getChildByName("Image_Arrow"):setVisible(true)
				self.mRootWidget:getChildByName("Image_MaxJinjie"):setVisible(false)
				self.mRootWidget:getChildByName("Panel_JinjieCost"):setVisible(true)
				self.mRootWidget:getChildByName("Image_NextJinjieLv"):loadTexture("heroselect_qualitynum_"..tostring(jinjie+1)..".png")
			end
		end
		doUpdate()	
	end
end

-- 显示升级界面
function HeroInfoWindow:showLevelupPanel(widget)
	GUISystem:playSound("homeBtnSound")
	self.mPeiyangPanel:getChildByName("Panel_Content2"):setVisible(true)
	self.mPeiyangPanel:getChildByName("Panel_Content1"):setVisible(false)

	-- 显示能加经验的物品
	self:onItemInfoChanged()
end

-- 背包物品变化响应
function HeroInfoWindow:onItemInfoChanged()
	local itemId = {20011, 20012, 20013, 20014}
	for i = 1, 4 do
		local itemObj = globaldata:getItemInfo(nil, itemId[i])
		local itemCount = 0
		if itemObj then
			itemCount = itemObj:getKeyValue("itemNum")
		end
		local lblWidget = self.mExpItemWidgetList[i]:getChildByName("Label_Count_Stroke")
		if lblWidget then
			lblWidget:setString(globaldata:getItemOwnCount(itemId[i]))
		end
	end

	-- 英雄碎片
	self:updateHeroInfo()

	-- 刷新红点
	HeroNoticeInnerImpl:doUpdate()
end

-- 请求英雄升级(内部)
function HeroInfoWindow:requestDoInnerPeiyang(widget)

	if dantengVavlue then
		return
	end

	self.mRequestLvUpEnabled = false
	local itemId = widget:getTag()

	local itemCnt = globaldata:getItemOwnCount(itemId)
	if itemCnt <= 0 then
		MessageBox:showMessageBox1("该物品不足~")
		return
	end

	local heroId = self.mHeroIdTbl[self.mCurSelectedHeroIndex]
	local heroObj = globaldata:findHeroById(heroId)

	if 1 == heroObj.maxExp - heroObj.exp and heroObj.level == globaldata.level then
		MessageBox:showMessageBox1("英雄等级已经达到上限~")
		return
	end

	-- 显示添加经验数量
	local itemData = DB_ItemConfig.getDataById(itemId)
	local itemExp = tonumber(itemData.para1)

	-- 原来的属性
	local preLevel  = heroObj.level
	local preExp    = heroObj.exp
	local preMaxExp = heroObj.maxExp
		
	-- 循环加经验升级	
	while true
	do
		if heroObj.level == globaldata.level and 1 == heroObj.maxExp - heroObj.exp and itemExp >= 0 then
			MessageBox:showMessageBox1("英雄等级已经达到上限~")
			break
		end

		if itemExp >= heroObj.maxExp - heroObj.exp then -- 足够升到下一级
			heroObj.level = heroObj.level + 1 -- 升一级

			-- 越界情况
			if heroObj.level > globaldata.level then
				heroObj.level = globaldata.level
				itemExp = 0
				local expData = DB_HeroEXP.getDataById(heroObj.level)
				heroObj.maxExp = expData.EXP
				heroObj.exp = heroObj.maxExp - 1
				MessageBox:showMessageBox1("英雄等级已经达到上限~")
				break
			end

			itemExp = itemExp + heroObj.exp - heroObj.maxExp -- 扣除升一级的经验
			local expData = DB_HeroEXP.getDataById(heroObj.level)
			heroObj.exp = 0
			heroObj.maxExp = expData.EXP
		else -- 不足够升到下一级
			heroObj.level = heroObj.level -- 不升级
			heroObj.maxExp = heroObj.maxExp
			heroObj.exp = heroObj.exp + itemExp -- 加上经验
			itemExp = 0
			break
		end
	end

	-- 新的属性
	local newLevel  = heroObj.level
	local newExp    = heroObj.exp
	local newMaxExp = heroObj.maxExp

	self.mHeroLvUpInfo.heroId =	heroId
	self.mHeroLvUpInfo.itemId = itemId
	self.mHeroLvUpInfo.itemCnt = self.mHeroLvUpInfo.itemCnt + 1
	globaldata:setItemOwnCount(itemId, itemCnt - 1)

	-- 更新物品显示数量
	widget:getChildByName("Label_Count_Stroke"):setString(tostring(itemCnt - 1))

	-- 添加特效
	local animNode = AnimManager:createAnimNode(8027)
	widget:getChildByName("Panel_Animation"):addChild(animNode:getRootNode(), 100)
	animNode:play("hero_expfood_touch", false)


--	print("英雄id:", heroId)
--	print("旧级别:", preLevel, "旧经验:", preExp, "旧最大经验:", preMaxExp)
--	print("新级别:", newLevel, "新经验:", newExp, "新最大经验:", newMaxExp)

	self:onRequestDoInnerPeiyang(heroId, preLevel, preExp, preMaxExp, newLevel, newExp, newMaxExp)
end

-- 响应英雄升级(内部)
function HeroInfoWindow:onRequestDoInnerPeiyang(heroId, preLevel, preExp, preMaxExp, newLevel, newExp, newMaxExp)
	self.mRequestLvUpEnabled = true

	-- 级别
	self.mRootWidget:getChildByName("Label_LevelVal_Stroke"):setString("Lv. "..tostring(newLevel))
	-- 经验
	self.mRootWidget:getChildByName("Label_ExpVal"):setString(tostring(newExp)..tostring("/")..tostring(newMaxExp))

	if newLevel  > preLevel then
		local animNode = AnimManager:createAnimNode(8026)
		self.mPeiyangPanel:getChildByName("Panel_PrograssAnimation"):addChild(animNode:getRootNode(), 100)
		animNode:play("hero_levelprograss_update", false)
	end

--	print("升级前级别:", preLevel, "升级前经验:", preExp)
--	print("升级后级别:", newLevel, "升级后经验:", newExp)

	for i = 1, #self.mHeroIdTbl do
		-- 更新头像显示信息
		if heroId == self.mHeroIdTbl[i] then
			self.mHeroIconList[i]:getChildByName("Panel_HeroLevel_1"):setVisible(false)
			self.mHeroIconList[i]:getChildByName("Panel_HeroLevel_2"):setVisible(false)
			local l1 = math.floor(newLevel/10)
			local l2 = math.fmod(newLevel, 10)
			if 0 == l1 then
				self.mHeroIconList[i]:getChildByName("Panel_HeroLevel_1"):setVisible(true)
				self.mHeroIconList[i]:getChildByName("Panel_HeroLevel_1"):getChildByName("Image_level"):loadTexture("hero_level_"..tostring(l2)..".png", 1)
			else 
				self.mHeroIconList[i]:getChildByName("Panel_HeroLevel_2"):setVisible(true)
				self.mHeroIconList[i]:getChildByName("Panel_HeroLevel_2"):getChildByName("Image_level_Left"):loadTexture("hero_level_"..tostring(l1)..".png", 1)
				self.mHeroIconList[i]:getChildByName("Panel_HeroLevel_2"):getChildByName("Image_level_Right"):loadTexture("hero_level_"..tostring(l2)..".png", 1)
			end
		end
	end

	-- 更新经验条
	local function updateExpProBar()
		if self.mExpProgressTimerWidget then
			-- 之前的百分比
			self.mExpProgressTimerWidget:setPercentage(preExp/preMaxExp*100)
			self.mExpProgressTimerWidget:stopAllActions()

			local function updateLevelLabel()

				local animNode = AnimManager:createAnimNode(8026)
				self.mPeiyangPanel:getChildByName("Panel_PrograssAnimation"):addChild(animNode:getRootNode(), 100)
				animNode:play("hero_levelprograss_update", false)

				preLevel = preLevel + 1
				contentWidget = self.mPeiyangPanel:getChildByName("Label_LevelVal_Stroke"):setString("Lv. "..tostring(preLevel))
			end

			local deltaLevel = newLevel - preLevel 
			local valRangeTbl = {}
			if 0 == deltaLevel then 	-- 未升级
				-- 一段
				valRangeTbl[1] = {}
				valRangeTbl[1].beginVal = preExp/preMaxExp*100
				valRangeTbl[1].endVal   = newExp/newMaxExp*100
			elseif 1 == deltaLevel then -- 升一级
				-- 一段
				valRangeTbl[1] = {}
				valRangeTbl[1].beginVal = preExp/preMaxExp*100
				valRangeTbl[1].endVal   = 100
				-- 二段
				valRangeTbl[2] = {}
				valRangeTbl[2].beginVal = 0
				valRangeTbl[2].endVal   = newExp/newMaxExp*100
			else -- 升两级或两级以上
				-- 一段
				valRangeTbl[1] = {}
				valRangeTbl[1].beginVal = preExp/preMaxExp*100
				valRangeTbl[1].endVal   = 100
				-- 中段
				for i = 2, deltaLevel+1 do
					valRangeTbl[i] = {}
					valRangeTbl[i].beginVal = 0
					valRangeTbl[i].endVal   = 100
				end
				-- 末段
				valRangeTbl[deltaLevel+1] = {}
				valRangeTbl[deltaLevel+1].beginVal = 0
				valRangeTbl[deltaLevel+1].endVal   = newExp/newMaxExp*100
			end
		
			local speedVal = 200 -- 一秒走出200的百分比

			if 0 == deltaLevel then -- 没有级别变化
			--	local act0 = cc.ProgressFromTo:create(math.abs(valRangeTbl[1].endVal-valRangeTbl[1].beginVal)/speedVal, valRangeTbl[1].beginVal, valRangeTbl[1].endVal)
				local act0 = cc.ProgressFromTo:create(longPressTimeVal, valRangeTbl[1].beginVal, valRangeTbl[1].endVal)
				self.mExpProgressTimerWidget:runAction(act0)
			else -- 有级别变化
				local actionList = {}
				for i = 1, #valRangeTbl do
				--	local act0 = cc.ProgressFromTo:create(math.abs(valRangeTbl[i].endVal-valRangeTbl[i].beginVal)/speedVal, valRangeTbl[i].beginVal, valRangeTbl[i].endVal)
					local act0 = cc.ProgressFromTo:create(longPressTimeVal, valRangeTbl[i].beginVal, valRangeTbl[i].endVal)
					local act1 = cc.CallFunc:create(updateLevelLabel)
					if i ~= #valRangeTbl then
						actionList[i] = cc.Sequence:create(act0, act1)
					else
						actionList[i] = cc.Sequence:create(act0)
					end
				end
				self.mExpProgressTimerWidget:runAction(cc.Sequence:create(actionList))
			end
		end
	end
	updateExpProBar()
end

-- 请求执行培养
function HeroInfoWindow:requestDoPeiyang()
	
	local heroId = self.mHeroIdTbl[self.mCurSelectedHeroIndex]
	local heroObj = globaldata:findHeroById(heroId)

	if self.mHeroLvUpInfo.itemCnt > 0 then
		local packet = NetSystem.mNetManager:GetSPacket()
		packet:SetType(PacketTyper._PTYPE_CS_REQUEST_DOPEIYANG_)
		packet:PushInt(heroId)
		packet:PushInt(self.mHeroLvUpInfo.itemId)
		packet:PushInt(self.mHeroLvUpInfo.itemCnt)
		packet:PushInt(heroObj.level)
		packet:PushInt(heroObj.exp)
		packet:Send()
		GUISystem:showLoading()
	end
end

-- 响应培养
function HeroInfoWindow:onRequestDoPeiyang(msgPacket)
	local ret = msgPacket:GetChar()
	if 0 == ret then
		GUISystem:hideLoading()
	elseif 1 == ret then
		
	end

	self.mHeroLvUpInfo = {heroId = nil, itemId = 0, itemCnt = 0}
	-- 刷新界面
	self:updateHeroInfo()

	-- 刷新另外两个界面
	GUISystem:GetWindowByName("EquipInfoWindow"):updateHeroIconTbl()
	GUISystem:GetWindowByName("HeroSkillWindow"):updateHeroIconTbl()

	local heroObj = globaldata:findHeroById(HeroGuideOneEx.heroId)
	if heroObj and heroObj.level >= HeroGuideOneEx.level and HeroGuideOneEx:canGuide() then
		local guideBtn = self.mRootWidget:getChildByName("Image_Leader")
		local size = guideBtn:getContentSize()
		local pos = guideBtn:getWorldPosition()
		pos.x = pos.x - size.width/2
		pos.y = pos.y - size.height/2
		local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
		HeroGuideOneEx:step(5, touchRect)
	end
end

-- 隐藏升级界面
function HeroInfoWindow:hideLevelupPanel(widget)
	GUISystem:playSound("homeBtnSound")
	self.mPeiyangPanel:getChildByName("Panel_Content2"):setVisible(false)
	self.mPeiyangPanel:getChildByName("Panel_Content1"):setVisible(true)
end

-- 初始化符文转动
function HeroInfoWindow:initFuwenRotate()
	-- 符文运动
	local fazhen = self.mRootWidget:getChildByName("Image_Bg_Fazhen")
	local act0 = cc.RotateBy:create(30, 360)
	fazhen:runAction(cc.RepeatForever:create(act0))
end

-- 创建雷达图
function HeroInfoWindow:createRadarGraph()
	local leftProp = GUIWidgetPool:createWidget("HeroShuxingLess")

	local function initRadar()
		self.mRadarWidget = RadarWidget:new()
		self.mRadarWidget:init(leftProp)
	end
	initRadar()
	-- 底图隐藏
	leftProp:getChildByName("Image_Pentagon"):setVisible(false)

	return leftProp
end

-- 初始化自定义控件
function HeroInfoWindow:initCustomWidget()
	-- 属性窗口
	local leftProp = self:createRadarGraph()
	local leftLabel = cc.Sprite:create("hero_shuxing_title2.png")
	-- 初始化属性
	self.mPropWidget = GUIWidgetPool:createWidget("HeroShuxingMore")
	local rightLabel = cc.Sprite:create("hero_shuxing_title1.png")
	self.mShuxingWidget = NiubilityWidget:new()
	self.mShuxingWidget:init(self.mPropPanel, cc.p(0, 0), leftProp, leftLabel, self.mPropWidget, rightLabel)
	self.mShuxingWidget:show()

	local function showPropDetail()
		local window = GUIWidgetPool:createWidget("Hero_ShuxingDesc")
		self.mRootNode:addChild(window, 100)
		local function closeWindow()
			window:removeFromParent(true)
			window = nil
		end
		registerWidgetReleaseUpEvent(window, closeWindow)
	end
	registerWidgetReleaseUpEvent(self.mPropWidget:getChildByName("Button_PropertyDesc"), showPropDetail)

	-- 技能窗口
--	self.mLeftSkill = GUIWidgetPool:createWidget("HeroJinengZhudong")
--	leftLabel = cc.Sprite:create("hero_jineng_title2.png")
--	self.mRightSkill = GUIWidgetPool:createWidget("HeroJinengBeidong")
--	rightLabel = cc.Sprite:create("hero_jineng_title1.png")
--	self.mJinengWidget = NiubilityWidget:new()
--	self.mJinengWidget:init(self.mSkillPanel, cc.p(0, 0), self.mLeftSkill, leftLabel, self.mRightSkill, rightLabel)
--	self.mJinengWidget:show()

	-- 为技能等级表面（4处）
--	LabelManager:outline(self.mLeftSkill:getChildByName("Panel_Attack_1"):getChildByName("Label_Level"), G_COLOR_C4B.BLACK)
--	LabelManager:outline(self.mLeftSkill:getChildByName("Panel_Skill_1"):getChildByName("Label_Level"), G_COLOR_C4B.BLACK)
--	LabelManager:outline(self.mLeftSkill:getChildByName("Panel_Skill_2"):getChildByName("Label_Level"), G_COLOR_C4B.BLACK)
--	LabelManager:outline(self.mLeftSkill:getChildByName("Panel_Skill_3"):getChildByName("Label_Level"), G_COLOR_C4B.BLACK)

	self.mRightSkill = self.mRootWidget:getChildByName("Panel_JiNeng")
end

-- 窗口更新
function HeroInfoWindow:tick()
	-- 更新头像透明度
	self:updateHeroIconOpacity()
end

-- 更新头像透明度
function HeroInfoWindow:updateHeroIconOpacity()
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

local bottomHeight = 288 -- 下边距
local topHeight = 288 -- 上边距
local marginCell = 10 -- 间隙
local cellHeight = 86 -- 格子大小

-- 创建ScrollView
function HeroInfoWindow:createScrollViewWidget()
	self.mScrollViewWidget = ccui.ScrollView:create()
    self.mScrollViewWidget:setTouchEnabled(true)
    self.mScrollViewWidget:setContentSize(cc.size(159, 662))

    self.mRootWidget:getChildByName("ScrollView_HeroList"):setVisible(false)
  
    local function getHeroCount()
    	local cnt = 0
    	for i = 1, maxHeroCount do -- 存在
			local heroData = DB_HeroConfig.getDataById(i)
			if 1 == heroData.Open then 
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

function HeroInfoWindow:onHeroAddFunc()
	-- 显示英雄信息
	self:updateHeroInfo()
	-- 更新左侧滑条
	self:updateHeroIconTbl()
	-- 暂停
	HeroGuideTwo:pause()
end

-- 载入英雄
function HeroInfoWindow:loadAllHero()

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

	-- 英雄ID表
	self.mHeroIdTbl = {}
	for i = 1, maxHeroCount do -- 存在
		local heroData = DB_HeroConfig.getDataById(i)
		if globaldata:isHeroIdExist(i) and 1 == heroData.Open then 
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


	local function insertHeroUnGet() -- 添加为拥有的英雄
		local tempHeroIdTbl = {}

		for i = 1, maxHeroCount do -- 不存在
			local heroData = DB_HeroConfig.getDataById(i)
			if not globaldata:isHeroIdExist(i) and 1 == heroData.Open then 
				table.insert(tempHeroIdTbl, i)
			end
		end

		local function isHeroIdCanGet(heroId) -- 判断英雄是否能合成
			-- 碎片信息
			local heroData = DB_HeroConfig.getDataById(heroId)
			local fragmentId     = heroData.Fragment

			local function getFragmentCnt(fragmentId)
				local itemList = globaldata:getItemList()
				if not itemList[1] then
					return 0
				end
				for k, v in pairs(itemList[1]) do
					if fragmentId == v:getKeyValue("itemId") then
						return v:getKeyValue("itemNum")
					end
				end
				return 0
			end
			local fragmentCnt = getFragmentCnt(fragmentId)
			local needCnt	  = 10

			local function getFragmentInfo(heroId)
				local chipInfo = globaldata.heroChipsInfo
				for i=1,#chipInfo do
					if heroId == chipInfo[i].heroId then 
						return chipInfo[i].chipCnt
					end
				end
				return 10
			end
			needCnt       = getFragmentInfo(heroId)

			return fragmentCnt >= needCnt 
		end

		-- -- 根据是否能合成排序
		-- local function sortFunc2(id1, id2)
		-- --	if isHeroIdCanGet(id1) then
		-- --		return true
		-- --	elseif isHeroIdCanGet(id2) then
		-- --		return false
		-- --	else
		-- --		return false
		-- --	end
		-- 	if isHeroIdCanGet(id1) and isHeroIdCanGet(id2) then -- 都能合成
		-- 		return true
		-- 	elseif isHeroIdCanGet(id1) and not  isHeroIdCanGet(id2) then-- 前一个合成
		-- 		return true
		-- 	elseif not isHeroIdCanGet(id1) and isHeroIdCanGet(id2) then-- 前一个合成
		-- 		return false
		-- 	elseif not isHeroIdCanGet(id1) and not isHeroIdCanGet(id2) then-- 都不能合成
		-- 		return false	
		-- 	end
		-- end
		-- table.sort(tempHeroIdTbl, sortFunc2)

		local function doSortForHeroCanGet() --能合成的排在前面
			local tempHeroIdTbl2 = {}
			for i = 1, #tempHeroIdTbl do
				if isHeroIdCanGet(tempHeroIdTbl[i]) then -- 能合成
					table.insert(tempHeroIdTbl2, tempHeroIdTbl[i])
				end
			end
			for i = 1, #tempHeroIdTbl do 
				if not isHeroIdCanGet(tempHeroIdTbl[i]) then -- 不能合成
					table.insert(tempHeroIdTbl2, tempHeroIdTbl[i])
				end
			end
			tempHeroIdTbl = tempHeroIdTbl2

			for i = 1, #tempHeroIdTbl do
				table.insert(self.mHeroIdTbl, tempHeroIdTbl2[i])
			end

		end
		doSortForHeroCanGet()
	end
	insertHeroUnGet()

	-- 更新所测滑条
	self:updateHeroIconTbl()
	
	local function onAutoScrollStartFunc()
		GUISystem:disableUserInput()
	end
	self.mScrollViewWidget:registerAutoScrollStartFunc(onAutoScrollStartFunc)

	local function onAutoScrollStopFunc()
		-- 修正ScrollView位置
    	self:fixScrollViewPos()
    end
	self.mScrollViewWidget:registerAutoScrollStopFunc(onAutoScrollStopFunc)


	local function onScrollViewEvent(sender, evenType)
		if evenType == ccui.ScrollviewEventType.scrolling then
			self.mHeroIconListScrollingAnimNode:setVisible(true)
			self.mHeroIconListSelectedAnimNode:setVisible(false)
		elseif evenType == ccui.ScrollviewEventType.scrollToBottom then 
			self.mCurSelectedHeroIndex = #self.mHeroIdTbl
			-- 显示英雄信息
			self:updateHeroInfo()
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
			self:updateHeroInfo()
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

-- 更新所测滑条
function HeroInfoWindow:updateHeroIconTbl()
	local innerHeight = self.mScrollViewWidget:getInnerContainerSize().height
--	print("滑动列表总高度:", innerHeight)

	for i = 1, #self.mHeroIdTbl do
		local heroId = self.mHeroIdTbl[i]
--		print("英雄id:", i, heroId)

		-- 载入头像
		local heroData = DB_HeroConfig.getDataById(heroId)

		if not self.mHeroIconList[i] then
			self.mHeroIconList[i] = GUIWidgetPool:createWidget("Hero_ListCell")
			self.mScrollViewWidget:addChild(self.mHeroIconList[i])

			local curPos = cc.p(0, innerHeight - topHeight - (i-1)*marginCell - i*cellHeight)
			self.mHeroIconList[i]:setPosition(curPos)
--			print("英雄:", i, "位置:", curPos.x, curPos.y)

			self.mHeroIconList[i]:setTag(i)
			registerWidgetReleaseUpEvent(self.mHeroIconList[i], handler(self, self.onHeroIconClicked))

			-- 职业
			self.mHeroIconList[i]:getChildByName("Image_Group"):loadTexture("hero_herolist_group"..heroData.HeroGroup..".png", 1)

			if 1 == heroData.QualityB then
				self.mHeroIconList[i]:getChildByName("Image_SuperHero"):loadTexture("hero_herolist_super_1.png", 1)
			--	local animNode = AnimManager:createAnimNode(8065)
			--	self.mHeroIconList[i]:getChildByName("Panel_SuperHero_Animation"):addChild(animNode:getRootNode(), 100)
			--	animNode:play("hero_list_superhero", true)
			else
				self.mHeroIconList[i]:getChildByName("Image_SuperHero"):loadTexture("hero_herolist_super_0.png", 1)
			end
		end

	--	local imgId = heroData.IconID
	--	local imgName = DB_ResourceList.getDataById(imgId).Res_path1
		self.mHeroIconList[i]:getChildByName("Image_HeroList_HeroIcon"):loadTexture("hero_herolist_hero_"..heroId..".png", 1)
		
		-- 级别

		local heroObj = globaldata:findHeroById(heroId)
		if heroObj then -- 如果存在
			print("英雄id:", heroId, "等级信息:", heroObj.level)
			self.mHeroIconList[i]:getChildByName("Panel_HeroLevel_1"):setVisible(false)
			self.mHeroIconList[i]:getChildByName("Panel_HeroLevel_2"):setVisible(false)
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
		
			ShaderManager:ResumeColor(self.mHeroIconList[i]:getChildByName("Image_HeroList_HeroIcon"):getVirtualRenderer())

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
			ShaderManager:Disabled(self.mHeroIconList[i]:getChildByName("Image_HeroList_HeroIcon"):getVirtualRenderer())
			self.mHeroIconList[i]:getChildByName("Panel_HeroLevel_1"):setVisible(false)
			self.mHeroIconList[i]:getChildByName("Panel_HeroLevel_2"):setVisible(false)

			-- 品阶
			self.mHeroIconList[i]:getChildByName("Image_bg"):loadTexture("hero_herolist_cell_bg_0.png", 1)
		end
	end
end

-- 响应头像点击
function HeroInfoWindow:onHeroIconClicked(widget)
	self.mCurSelectedHeroIndex = widget:getTag()
	local tm = 0.3
	-- 自动滑动
	local curHeight = self.mScrollViewWidget:getInnerContainerSize().height - self.mRootWidget:getChildByName("ScrollView_HeroList"):getContentSize().height
	local deltaY = self.mHeroIconList[1]:getPositionY() - self.mHeroIconList[self.mCurSelectedHeroIndex]:getPositionY()
	self.mScrollViewWidget:scrollToPercentVertical(100 - (curHeight-deltaY)/curHeight*100, tm, false)

	local function onScrollEnd()
		-- 更新英雄信息
		self:updateHeroInfo()
		GUISystem:enableUserInput()

		-- if HeroGuideOne:canGuide() then
		-- 	local guideBtn = self.mRootWidget:getChildByName("Panel_Sushi_1")
		-- 	local size = guideBtn:getContentSize()
		-- 	local pos = guideBtn:getWorldPosition()
		-- 	local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
		-- 	HeroGuideOne:step(5, touchRect)
		-- end

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

-- 初始化主角控件
function HeroInfoWindow:initLeaderWidget()
	local function doSetLeader()

		local function onRequestDoSetLeader(msgPacket)
			globaldata.leaderHeroId = msgPacket:GetInt()
			self:updateLeaderInfo()
			-- 通知大厅换英雄
			FightSystem.mHallManager:OnTeamMemberChanged()
			GUISystem:hideLoading()

			-- local function doHeroGuideOne_Step8()
			-- 	local guideBtn = self.mRootWidget:getChildByName("Image_Jineng")
			-- 	local size = guideBtn:getContentSize()
			-- 	local pos = guideBtn:getWorldPosition()
			-- 	pos.x = pos.x - size.width/2
			-- 	pos.y = pos.y - size.height/2
			-- 	local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
			-- 	HeroGuideOne:step(8, touchRect)
			-- end

			local function doHeroGuideOneEx_Step7()
				local guideBtn = self.mRootWidget:getChildByName("Image_HeroGroup")
				local size = guideBtn:getContentSize()
				local pos = guideBtn:getWorldPosition()
				pos.x = pos.x - size.width/2
				pos.y = pos.y - size.height/2
				local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
				HeroGuideOneEx:step(7, touchRect)
			end

			if HeroGuideOneEx:canGuide() then
				local guideBtn = self.mHeroIconList[2]:getChildByName("Image_LeaderMark")
				local size = guideBtn:getContentSize()
				local pos = guideBtn:getWorldPosition()
				local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
				HeroGuideOneEx:step(6, touchRect, nil, doHeroGuideOneEx_Step7)
			end

		end
		NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_RESET_LEADER_, onRequestDoSetLeader)

		local function requestDoSetLeader()
			local heroId = self.mHeroIdTbl[self.mCurSelectedHeroIndex]
			local heroObj = globaldata:findHeroById(heroId)
			if heroObj then
				local packet = NetSystem.mNetManager:GetSPacket()
				packet:SetType(PacketTyper._PTYPE_CS_RESET_LEADER_)
				packet:PushInt(heroId)
				packet:Send()
				GUISystem:showLoading()
			end
		end
		requestDoSetLeader()
	end
	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Image_Leader"), doSetLeader)
end

-- 显示主角信息
function HeroInfoWindow:updateLeaderInfo()
	local heroId = self.mHeroIdTbl[self.mCurSelectedHeroIndex]
	if heroId == globaldata.leaderHeroId then -- 是主角
		self.mRootWidget:getChildByName("Image_IfLeader"):setVisible(true)
		self.mRootWidget:getChildByName("Image_Leader"):setTouchEnabled(false)
	else
		self.mRootWidget:getChildByName("Image_IfLeader"):setVisible(false)
		self.mRootWidget:getChildByName("Image_Leader"):setTouchEnabled(true)
	end
	-- ICON主角标志
	for i = 1, #self.mHeroIdTbl do
		if globaldata.leaderHeroId == self.mHeroIdTbl[i] then -- 是主角
			self.mHeroIconList[i]:getChildByName("Image_LeaderMark"):setVisible(true)
		else -- 不是主角
			self.mHeroIconList[i]:getChildByName("Image_LeaderMark"):setVisible(false)
		end
	end
end

-- 显示头像选中
function HeroInfoWindow:updateIconSelectedInfo()
	-- for i = 1, #self.mHeroIdTbl do
	-- 	if i == self.mCurSelectedHeroIndex then -- 选中的
	-- 		self.mHeroIconList[i]:getChildByName("Image_bg"):loadTexture("hero_herolistchosen_bg.png")
	-- 	else -- 未选中的
	-- 		self.mHeroIconList[i]:getChildByName("Image_bg"):loadTexture("hero_herolist_cell_bg_0.png")
	-- 	end
	-- end

	local heroId = self.mHeroIdTbl[self.mCurSelectedHeroIndex]
	local heroObj = globaldata:findHeroById(heroId)
	if heroObj then
		self.mRootWidget:getChildByName("Panel_HeroZhanli"):setVisible(true)
		self.mRootWidget:getChildByName("Image_Leader"):setVisible(true)
	else
		self.mRootWidget:getChildByName("Panel_HeroZhanli"):setVisible(false)
		self.mRootWidget:getChildByName("Image_Leader"):setVisible(false)
	end
end

-- 显示英雄信息
function HeroInfoWindow:updateHeroInfo(needSendPacket)
	
	-- 显示主角信息
	self:updateLeaderInfo()

	-- 显示英雄动画
	self:updateHeroAnim()

	-- 显示英雄姓名
	self:updateHeroName()

	-- 显示头像选中
	self:updateIconSelectedInfo()

	if 1 == self.mCurSelecetdHeroInfo then -- 档案
		self:updateHeroDestiny()
	elseif 2 == self.mCurSelecetdHeroInfo then -- 技能
		self:updateHeroSkill()
	elseif 3 == self.mCurSelecetdHeroInfo then -- 属性
		self:updateHeroProp()
	elseif 4 == self.mCurSelecetdHeroInfo then -- 装备
		self:updateEquipInfo()
	elseif 5 == self.mCurSelecetdHeroInfo then -- 培养
		self:updatePeiyangInfo()
	end

--	if not needSendPacket then
--		self:requestJinjieInfo()
--	end
	
	-- 红点刷新
	HeroNoticeInnerImpl:doUpdate()	

	-- 显示英雄战力
	self:updateHeroCombat()

	-- 更新左侧滑条
	self:updateHeroIconTbl()
end

-- 请求进阶信息
function HeroInfoWindow:requestJinjieInfo(widget)
	-- local index = self.mCurSelectedHeroIndex
	-- local guid = globaldata:getHeroInfoByBattleIndex(index, "guid")
	-- local id = globaldata:getHeroInfoByBattleIndex(index, "id")

	-- local packet = NetSystem.mNetManager:GetSPacket()
 --    packet:SetType(PacketTyper._PTYPE_CS_REQUEST_JINJIEINFO_)
 --    packet:PushString(guid)
 --    packet:PushInt(id)
 --    packet:Send()
 --    GUISystem:showLoading()

 	local heroId    = self.mHeroIdTbl[self.mCurSelectedHeroIndex]
	local heroObj   = globaldata:findHeroById(heroId)


	if heroObj then

	 	local reachMax = heroObj.isMaxAdvancedLv
	 	if 0 == reachMax then
	 		-- 隐藏
			self.mRootWidget:getChildByName("Button_DoJinjie"):setVisible(false)
			-- self.mRootWidget:getChildByName("Image_NextJinjieLv"):setVisible(false)
			-- self.mRootWidget:getChildByName("Image_CurJinjieLv"):setVisible(false)
			-- self.mRootWidget:getChildByName("Image_Arrow"):setVisible(false)
			-- self.mRootWidget:getChildByName("Image_MaxJinjie"):setVisible(true)
			-- self.mRootWidget:getChildByName("Panel_JinjieCost"):setVisible(false)
			return
	 	end

	 	local function doUpdate()
			local index = self.mCurSelectedHeroIndex
			local jinjie = heroObj.advanceLevel
			self.mRootWidget:getChildByName("Image_CurJinjieLv"):loadTexture("heroselect_qualitynum_"..tostring(jinjie)..".png")
			if maxHeroJinjieLevel == jinjie then
				self.mRootWidget:getChildByName("Button_DoJinjie"):setVisible(false)
				-- self.mRootWidget:getChildByName("Image_NextJinjieLv"):setVisible(false)
				-- self.mRootWidget:getChildByName("Image_CurJinjieLv"):setVisible(false)
				-- self.mRootWidget:getChildByName("Image_Arrow"):setVisible(false)
				-- self.mRootWidget:getChildByName("Image_MaxJinjie"):setVisible(true)
				-- self.mRootWidget:getChildByName("Panel_JinjieCost"):setVisible(false)
				self.mPeiyangPanel:getChildByName("Panel_Quality"):setVisible(false)
				self.mPeiyangPanel:getChildByName("Label_TopQuality"):setVisible(true)
			else
				self.mRootWidget:getChildByName("Button_DoJinjie"):setVisible(true)
				-- self.mRootWidget:getChildByName("Image_NextJinjieLv"):setVisible(true)
				-- self.mRootWidget:getChildByName("Image_CurJinjieLv"):setVisible(true)
				-- self.mRootWidget:getChildByName("Image_Arrow"):setVisible(true)
				-- self.mRootWidget:getChildByName("Image_MaxJinjie"):setVisible(false)
				-- self.mRootWidget:getChildByName("Panel_JinjieCost"):setVisible(true)
				-- self.mRootWidget:getChildByName("Image_NextJinjieLv"):loadTexture("heroselect_qualitynum_"..tostring(jinjie+1)..".png")
				self.mPeiyangPanel:getChildByName("Label_TopQuality"):setVisible(false)
			end
		end
	--	doUpdate()	

		local consumeItem = {}
		local temp = heroObj.advancedCostList

		for i = 1, #temp do
			local costType = temp[i].itemType
			local costId = temp[i].itemId
			local costNum = temp[i].itemNum
			consumeItem[i] = {costType, costId, costNum}
		end

		-- 显示金币
		for i = 1, #consumeItem do
			if 2 == consumeItem[i].costType then
				self.mRootWidget:getChildByName("Label_CurrencyNum"):setString(consumeItem[i].costNum)
			end
		end
	end

end

-- 显示培养信息
function HeroInfoWindow:updatePeiyangInfo()
	local heroId    = self.mHeroIdTbl[self.mCurSelectedHeroIndex]
	local heroObj   = globaldata:findHeroById(heroId)

	local curJinjieLv = nil
	if heroObj then
		curJinjieLv = heroObj.advanceLevel
	end

	local colorTbl = {}
	colorTbl[0] = cc.c3b(255,255,255)
	colorTbl[1] = cc.c3b(0,255,48)
	colorTbl[2] = cc.c3b(0,255,48)
	colorTbl[3] = cc.c3b(26,193,255)
	colorTbl[4] = cc.c3b(26,193,255)
	colorTbl[5] = cc.c3b(188,59,255)
	colorTbl[6] = cc.c3b(188,59,255)
	colorTbl[7] = cc.c3b(255,170,59)
	

	local function showWindow(widget)
	--	if self.mCurSelectedHeroPeiyangBtn == widget then
	--		return
	--	end

		self.mPeiyangPanel:getChildByName("Panel_Quality"):setVisible(false)
		self.mPeiyangPanel:getChildByName("Panel_Stars"):setVisible(false)
		self.mPeiyangPanel:getChildByName("Panel_Level"):setVisible(false)

		local function replaceTexture()
			self.mPeiyangPanel:getChildByName("Image_Page_Quality"):loadTexture("hero_peiyang_page_bg1.png")
			self.mPeiyangPanel:getChildByName("Image_Page_Stars"):loadTexture("hero_peiyang_page_bg1.png")
			self.mPeiyangPanel:getChildByName("Image_Page_Level"):loadTexture("hero_peiyang_page_bg1.png")
			
			self.mCurSelectedHeroPeiyangBtn = widget
			self.mCurSelectedHeroPeiyangBtn:loadTexture("hero_peiyang_page_bg2.png")
		end
		replaceTexture()

		if 1 == self.mCurSelectedHeroPeiyangBtn:getTag() then
			self.mPeiyangPanel:getChildByName("Panel_Quality"):setVisible(true)
			if 7 == curJinjieLv then
				self.mPeiyangPanel:getChildByName("Panel_Quality"):setVisible(false)
				self.mPeiyangPanel:getChildByName("Label_TopQuality"):setVisible(true)
			else
				if heroObj then
					self.mPeiyangPanel:getChildByName("Label_TopQuality"):setVisible(false)
					-- 显示物品
					local index = 1
					for i = 1, 3 do
						self.mPeiyangPanel:getChildByName("Panel_Item_"..tostring(i)):setVisible(false)
					end
					for i = 1, #heroObj.advancedCostList do
						if 2 ~= heroObj.advancedCostList[i].itemType then
							local itemWidget = createCommonWidget(heroObj.advancedCostList[i].itemType, heroObj.advancedCostList[i].itemId, nil, nil, true)
							self.mPeiyangPanel:getChildByName("Panel_Item_"..tostring(index)):setVisible(true)
							self.mPeiyangPanel:getChildByName("Panel_Item_"..tostring(index)):addChild(itemWidget)
							self.mPeiyangPanel:getChildByName("Panel_Item_"..tostring(index)):getChildByName("Label_Number"):setVisible(true)
							local val1 = globaldata:getItemOwnCount(heroObj.advancedCostList[i].itemId)
							local val2 = heroObj.advancedCostList[i].itemNum
							local labelWidget = self.mPeiyangPanel:getChildByName("Panel_Item_"..tostring(index)):getChildByName("Label_Number")
							local btnAdd = self.mPeiyangPanel:getChildByName("Panel_Item_"..tostring(index)):getChildByName("Image_Add")
							if val1 >= val2 then -- 足够
								labelWidget:setColor(cc.c3b(162,255,169))
								btnAdd:setVisible(false)
								-- 足够显示信息
								MessageBox:setTouchShowInfo(itemWidget, heroObj.advancedCostList[i].itemType, heroObj.advancedCostList[i].itemId)
							else
								labelWidget:setColor(cc.c3b(255,162,162))
								btnAdd:setVisible(true)
								-- 不足显示跳转
								MessageBox:showHowToGetMessage(itemWidget, heroObj.advancedCostList[i].itemType, heroObj.advancedCostList[i].itemId)
							end
							labelWidget:setString(val1.."/"..val2)
							index = index + 1
						else
							self.mPeiyangPanel:getChildByName("Panel_Quality"):getChildByName("Label_Cost"):setString(heroObj.advancedCostList[i].itemNum)
						end
					end
				end
			end
		elseif 2 == self.mCurSelectedHeroPeiyangBtn:getTag() then
			self.mPeiyangPanel:getChildByName("Panel_Stars"):setVisible(true)
			self.mPeiyangPanel:getChildByName("Label_TopQuality"):setVisible(false)
		elseif 3 == self.mCurSelectedHeroPeiyangBtn:getTag() then
			self.mPeiyangPanel:getChildByName("Panel_Level"):setVisible(true)
			self.mPeiyangPanel:getChildByName("Label_TopQuality"):setVisible(false)
		end
	end

	if self.mCurSelectedHeroPeiyangBtn then
		showWindow(self.mCurSelectedHeroPeiyangBtn)
	end

	self.mShowWindowFuncHandler = showWindow

	local expItem = {20011, 20012, 20013, 20014}
	if 0 == #self.mExpItemWidgetList then
		for i = 1, #expItem do
			self.mExpItemWidgetList[i] = createItemWidget(expItem[i], globaldata:getItemOwnCount(expItem[i]))
			self.mPeiyangPanel:getChildByName("Panel_Sushi_"..tostring(i)):addChild(self.mExpItemWidgetList[i])
			-- 显示添加经验数量
			local itemData = DB_ItemConfig.getDataById(expItem[i])
			local expNum = itemData.para1
			self.mPeiyangPanel:getChildByName("Panel_Sushi_"..tostring(i)):getChildByName("Label_EXP_Number"):setString("EXP +"..expNum)

			self.mExpItemWidgetList[i]:setTag(expItem[i])

			local function onButtonTouch(widget, eventType)
				if eventType == ccui.TouchEventType.began then

					local function tick()
						if self.mRequestLvUpEnabled then
							self:requestDoInnerPeiyang(widget)
						end
					end

					local scheduler = cc.Director:getInstance():getScheduler()
					self.mSchedulerHandler = scheduler:scheduleScriptFunc(tick, longPressTimeVal, false)
					self.mPushDownTime = os.clock()
					-- 清除一下信息
					self.mHeroLvUpInfo			=	{heroId = nil, itemId = 0, itemCnt = 0}

				elseif eventType == ccui.TouchEventType.ended then 
					if self.mSchedulerHandler then
						local scheduler = cc.Director:getInstance():getScheduler()
						scheduler:unscheduleScriptEntry(self.mSchedulerHandler)
						self.mSchedulerHandler = nil
						self.mRequestLvUpEnabled = true
					end
					self.mReleaseUpTime = os.clock()

					if self.mReleaseUpTime - self.mPushDownTime < longPressTimeVal then -- 单机一次的情况
						self:requestDoInnerPeiyang(widget)
					end
					self:requestDoPeiyang()
				elseif eventType == ccui.TouchEventType.canceled then
					if self.mSchedulerHandler then
						local scheduler = cc.Director:getInstance():getScheduler()
						scheduler:unscheduleScriptEntry(self.mSchedulerHandler)
						self.mSchedulerHandler = nil
						self.mRequestLvUpEnabled = true
					end
					self:requestDoPeiyang()
				elseif eventType == ccui.TouchEventType.moved then
					
				end
			end

			self.mExpItemWidgetList[i]:addTouchEventListener(onButtonTouch)
		end
	end

	self.mPeiyangPanel:getChildByName("ProgressBar_Peiyang"):setVisible(false)

	-- 升品功能开启
	if globaldata.level < 9 then
		ShaderManager:DoUIWidgetDisabled(self.mPeiyangPanel:getChildByName("Image_Page_Quality"), true)
	else
		ShaderManager:DoUIWidgetDisabled(self.mPeiyangPanel:getChildByName("Image_Page_Quality"), false)
	end

	local function onBtnClicked(widget)
		if 1 == widget:getTag() then
			if globaldata.level < 9 then
				MessageBox:showMessageBox1("该功能9级开放")
				return 
			end
		end
		showWindow(widget)
	end

	local btn = nil
	btn = self.mPeiyangPanel:getChildByName("Image_Page_Quality")
	btn:setTag(1)
	registerWidgetPushDownEvent(btn, onBtnClicked)

	btn = self.mPeiyangPanel:getChildByName("Image_Page_Stars")
	btn:setTag(2)
	registerWidgetPushDownEvent(btn, onBtnClicked)

	btn = self.mPeiyangPanel:getChildByName("Image_Page_Level")
	btn:setTag(3)
	registerWidgetPushDownEvent(btn, onBtnClicked)

	-- 默认显示品质
	if self.mCurSelectedHeroPeiyangBtn then
		showWindow(self.mCurSelectedHeroPeiyangBtn)
	else
		showWindow(self.mPeiyangPanel:getChildByName("Image_Page_Level"))
	end

	if heroObj then
		self.mPeiyangPanel:getChildByName("Panel_Bottom"):setVisible(true)
		self.mPeiyangPanel:getChildByName("Panel_Top"):setVisible(true)
		self.mPeiyangPanel:getChildByName("Panel_Pages"):setVisible(true)
		self.mPeiyangPanel:getChildByName("Panel_Unget"):setVisible(false)

		-- 经验
		local exp = heroObj.exp
		local maxExp = heroObj.maxExp
		local level = heroObj.level
		self.mRootWidget:getChildByName("Label_ExpVal"):setString(tostring(exp)..tostring("/")..tostring(maxExp))
		
		self.mPeiyangPanel:getChildByName("Label_LevelVal_Stroke"):setString("Lv. "..tostring(level))
		self.mPeiyangPanel:getChildByName("Label_ExpVal"):setString(tostring(exp)..tostring("/")..tostring(maxExp))

		-- 级别
		local curLevel = heroObj.level
		self.mRootWidget:getChildByName("Label_LevelVal_Stroke"):setString("Lv. "..tostring(curLevel))
		-- 经验
		local curExp = heroObj.exp
		local curMaxExp = heroObj.maxExp
		self.mRootWidget:getChildByName("Label_ExpVal"):setString(tostring(curExp)..tostring("/")..tostring(curMaxExp))

		-- 经验百分比
		local expPercent = exp * 100 / maxExp
	--	self.mRootWidget:getChildByName("ProgressBar_Peiyang"):setPercent(expPercent)

		-- 经验条
		local imgWidget = cc.Sprite:create("public_prograss3.png")
		if self.mExpProgressTimerWidget then
			self.mExpProgressTimerWidget:removeFromParent(true)
			self.mExpProgressTimerWidget = nil
		end

		self.mExpProgressTimerWidget = cc.ProgressTimer:create(imgWidget)
		self.mExpProgressTimerWidget:setType(1)
		self.mExpProgressTimerWidget:setMidpoint(cc.p(0,1))
		self.mExpProgressTimerWidget:setAnchorPoint(cc.p(0.5,0.5))
    	self.mExpProgressTimerWidget:setBarChangeRate(cc.p(1, 0))
    	self.mExpProgressTimerWidget:setPosition(0,0)
    	self.mExpProgressTimerWidget:setPercentage(expPercent)
    	self.mPeiyangPanel:getChildByName("Image_PrograssBg"):addChild(self.mExpProgressTimerWidget)
    	local curPos = cc.p(self.mPeiyangPanel:getChildByName("ProgressBar_Peiyang"):getPosition())
		self.mExpProgressTimerWidget:setPosition(curPos)

    	-- 姓名&进阶
		local heroData 		= DB_HeroConfig.getDataById(heroId)
		local heroNameId 	= heroData.Name
		self.mPeiyangPanel:getChildByName("Label_Hero_Name&Quality_Stroke"):setString(getDictionaryText(heroNameId).."+"..tostring(curJinjieLv))

		-- 进化
		local color = heroObj.quality
		for i = 1, 6 do
			self.mRootWidget:getChildByName("Image_JinjieStar"..tostring(i)):loadTexture("public_hero_starbg_big.png")
		end
		-- for i = 1, color do
		-- 	self.mRootWidget:getChildByName("Image_JinjieStar"..tostring(i)):loadTexture("public_star1.png")
		-- end

		if 0 == color then

		elseif color >= 1 and color <= 6 then
			for i = 1, color do
				self.mRootWidget:getChildByName("Image_JinjieStar"..tostring(i)):loadTexture("public_hero_star1_big.png")
			end
		elseif color >= 7 and color <= 12 then
			for i = 1, 6 do
				self.mRootWidget:getChildByName("Image_JinjieStar"..tostring(i)):loadTexture("public_hero_star1_big.png")
			end
			for i = 1, color - 6 do
				self.mRootWidget:getChildByName("Image_JinjieStar"..tostring(i)):loadTexture("public_hero_star2_big.png")
			end
		end

		self.mPeiyangPanel:getChildByName("Label_Hero_Name&Quality_Stroke"):setColor(colorTbl[heroObj.advanceLevel])
		-- 进化信息
		local chipId = heroObj.chipId	-- 需要的碎片Id
		local needChipCount	= heroObj.chipCount -- 需要的碎片数量
		local function findCurChipCount()
			local itemList = globaldata:getItemList()
			if not itemList[1] then
				return 0
			end
			for k, v in pairs(itemList[1]) do
				if chipId == v:getKeyValue("itemId") then
					return v:getKeyValue("itemNum")
				end
			end
			return 0
		end
		local curChipCount = findCurChipCount()
		self.mLastLeftChipCount = curChipCount

		-- 显示数量
		self.mRootWidget:getChildByName("Label_ChipNum"):setString(tostring(curChipCount).."/"..tostring(needChipCount))
		-- 显示进度条
	--	local progressWidget = self.mRootWidget:getChildByName("ProgressBar_jinhua")
		if needChipCount <= curChipCount then
			self.mPeiyangPanel:getChildByName("Label_ChipNum"):setColor(cc.c3b(162,255,169))
	--		progressWidget:setPercent(100)
		else
			self.mPeiyangPanel:getChildByName("Label_ChipNum"):setColor(cc.c3b(255,162,162))
	--		progressWidget:setPercent(curChipCount*100/needChipCount)

			-- 不够跳转
		end
		MessageBox:showHowToGetMessage(self.mPeiyangPanel:getChildByName("Button_HeroPiece"), 0, chipId)

		if needChipCount <= curChipCount then -- 足够
			registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_DoJinhua"),handler(self, self.requestDoJinhua))
		else -- 不足够
			MessageBox:showHowToGetMessage(self.mPeiyangPanel:getChildByName("Button_DoJinhua"), 0, chipId)
		end


		if color == 12 then
			self.mPeiyangPanel:getChildByName("Label_ChipNum"):setString("已最高星级")
			self.mPeiyangPanel:getChildByName("Label_ChipNum"):setColor(cc.c3b(255, 255, 255))
		end

	else
		self.mPeiyangPanel:getChildByName("Panel_Bottom"):setVisible(false)
		self.mPeiyangPanel:getChildByName("Panel_Top"):setVisible(false)
		self.mPeiyangPanel:getChildByName("Panel_Pages"):setVisible(false)
		self.mPeiyangPanel:getChildByName("Panel_Unget"):setVisible(true)

		-- 姓名&进阶
		local heroData 		= DB_HeroConfig.getDataById(heroId)
		local heroNameId 	= heroData.Name
		local lblWidget 	= self.mPeiyangPanel:getChildByName("Label_Hero_Name&Quality_Stroke")
		lblWidget:setString(getDictionaryText(heroNameId).." +0")
		lblWidget:setColor(colorTbl[0])

		-- 星星
		for i = 1, 6 do
			self.mRootWidget:getChildByName("Image_JinjieStar"..tostring(i)):loadTexture("public_hero_starbg_big.png")
		end

		-- 碎片信息
		local heroData = DB_HeroConfig.getDataById(heroId)
		local fragmentId     = heroData.Fragment

		-- 不足显示跳转
		MessageBox:showHowToGetMessage(self.mPeiyangPanel:getChildByName("Button_GetMorePiece"), 0, heroData.Fragment)

		local function getFragmentCnt(fragmentId)
			local itemList = globaldata:getItemList()
			if not itemList[1] then
				return 0
			end
			for k, v in pairs(itemList[1]) do
				if fragmentId == v:getKeyValue("itemId") then
					return v:getKeyValue("itemNum")
				end
			end
			return 0
		end
		local fragmentCnt = getFragmentCnt(fragmentId)
		local needCnt	  = 10

		local function getFragmentInfo(heroId)
			local chipInfo = globaldata.heroChipsInfo
			for i=1,#chipInfo do
				if heroId == chipInfo[i].heroId then 
					return chipInfo[i].chipCnt
				end
			end
			return 10
		end
		needCnt       = getFragmentInfo(self.mHeroIdTbl[self.mCurSelectedHeroIndex])

		local function doGetHeroRequest()
			local packet = NetSystem.mNetManager:GetSPacket()
			packet:SetType(PacketTyper._PTYPE_CS_REQUEST_USEITEM_)
			packet:PushInt(fragmentId)
			packet:PushInt(1)
			packet:Send()
		end

		-- 更新碎片信息
		local function updateFragInfo()
			local lblWidget = self.mRootWidget:getChildByName("Label_Piece")
			lblWidget:setString(tostring(fragmentCnt).."/"..tostring(needCnt))
			if fragmentCnt >= needCnt then
				lblWidget:setColor(cc.c3b(162,255,169))
			else 
				lblWidget:setColor(cc.c3b(255,162,162))
			end
		end
		updateFragInfo()

		local bShowGetBtn = false
		if fragmentCnt >= needCnt then bShowGetBtn = true end
		self.mRootWidget:getChildByName("Button_Get"):setVisible(bShowGetBtn)
		registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_Get"), doGetHeroRequest)
	end

end

function HeroInfoWindow:showHeroInfo(widget)
	local moveTime	=	0.25
	local startPos 	= 	cc.p(570, 0)
	local endPos	=	cc.p(0, 0)

	if self.mLastChooseWidget == widget then
		return
	end

	-- 换菜单项图片
	local function replaceTexture()
		if self.mLastChooseWidget then
		--	self.mLastChooseWidget:getChildByName("Image_Circle"):loadTexture("hero_btn_bg1.png")	
			-- 停止
		--	self.mLastChooseWidget:getChildByName("Image_Circle"):stopAllActions()

			self.mBtnAnimNodeList[self.mLastChooseWidget:getTag()]:play("hero_page_chosen_2", true)

			self.mLastChooseWidget = widget
		else
			self.mLastChooseWidget = widget
		end
	--	widget:getChildByName("Image_Circle"):loadTexture("hero_btn_bg2.png")

		self.mBtnAnimNodeList[self.mLastChooseWidget:getTag()]:play("hero_page_chosen_1", true)
		local function runAction()
			local act0 = cc.RotateBy:create(5, 360)
	--		widget:getChildByName("Image_Circle"):runAction(cc.RepeatForever:create(act0))
		end
		runAction()
	end
	replaceTexture()

	local function hideLastWindow()
		GUISystem:disableUserInput_MsgBox()
		local function showInfoWindow()
			if "Image_Peiyang" == widget:getName() then
				self.mLastShowPanel = self.mPeiyangPanel
			elseif "Image_Zhuangbei" == widget:getName() then
				self.mLastShowPanel = self.mEquipPanel
			elseif "Image_Shuxing" == widget:getName() then
				self.mLastShowPanel = self.mPropPanel
			elseif "Image_Jineng" == widget:getName() then
				self.mLastShowPanel = self.mSkillPanel
			elseif "Image_DangAn" == widget:getName() then
				self.mLastShowPanel = self.mDestinyPanel
			end

			local function endAction()
				GUISystem:enableUserInput_MsgBox()

				if HeroGuideOneEx:canGuide() then
					local guideBtn = self.mRootWidget:getChildByName("Panel_Sushi_1")
					local size = guideBtn:getContentSize()
					local pos = guideBtn:getWorldPosition()
					local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
					HeroGuideOneEx:step(4, touchRect)
				end

				local function doHeroGuideOne_Step14()
					local guideBtn = self.mShuxingWidget.mPanelLeft.mRootNode:getChildByName("Image_Pentagon")
					local size = guideBtn:getContentSize()
					local pos = guideBtn:getWorldPosition()
					pos.x = pos.x - size.width/2
					pos.y = pos.y - size.height/2
					local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
					HeroGuideOneEx:step(16, touchRect)
				end

				if HeroGuideOneEx:canGuide() then
					local guideBtn = self.mShuxingWidget.mPanelLeft.mRootNode:getChildByName("Image_Pentagon")
					local size = guideBtn:getContentSize()
					local pos = guideBtn:getWorldPosition()
					pos.x = pos.x - size.width/2
					pos.y = pos.y - size.height/2
					local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
					HeroGuideOneEx:step(15, touchRect, nil, doHeroGuideOne_Step14)
				end

				local function doHeroGuideOne_Step12()
					local guideBtn = self.mRootWidget:getChildByName("Image_Shuxing")
					local size = guideBtn:getContentSize()
					local pos = guideBtn:getWorldPosition()
					pos.x = pos.x - size.width/2
					pos.y = pos.y - size.height/2
					local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
					HeroGuideOneEx:step(14, touchRect)
				end

				local function doHeroGuideOneEx_Step12()
					HeroGuideOneEx:step(13, nil, doHeroGuideOne_Step12)
				end

				local function doHeroGuideOneEx_Step11()
					local guideBtn = self.mRootWidget:getChildByName("Panel_Talent_2")
					local size = guideBtn:getContentSize()
					local pos = guideBtn:getWorldPosition()
					local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
					HeroGuideOneEx:step(12, touchRect, nil, doHeroGuideOneEx_Step12)
				end

				if HeroGuideOneEx:canGuide() then
					local guideBtn = self.mRootWidget:getChildByName("Panel_Talent_1")
					local size = guideBtn:getContentSize()
					local pos = guideBtn:getWorldPosition()
					local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
					HeroGuideOneEx:step(11, touchRect, nil, doHeroGuideOneEx_Step11)
				end

				if HeroGuideTwo:canGuide() then
					local guideBtn = self.mRootWidget:getChildByName("Button_Get")
					local size = guideBtn:getContentSize()
					local pos = guideBtn:getWorldPosition()
					pos.x = pos.x - size.width/2
					pos.y = pos.y - size.height/2
					local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
					HeroGuideTwo:step(3, touchRect)
				end

				if HeroGuideTwo:canGuide() then
					local guideBtn = self.mRootWidget:getChildByName("ListView_Destiny"):getItem(0)
					if guideBtn then
						local size = guideBtn:getContentSize()
						local pos = guideBtn:getWorldPosition()
						local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
						HeroGuideTwo:step(6, touchRect)
					end
				end

			end
			-- 减速进
			local act0 = cc.EaseOut:create(cc.MoveTo:create(moveTime, endPos), 3)
			local act1 = cc.CallFunc:create(endAction)
			self.mLastShowPanel:runAction(cc.Sequence:create(act0, act1))	
		end

		if self.mLastShowPanel then
			-- 加速出
			local act0 = cc.EaseIn:create(cc.MoveTo:create(moveTime, startPos), 3)
			local act1 = cc.CallFunc:create(showInfoWindow)
			self.mLastShowPanel:runAction(cc.Sequence:create(act0, act1))
		else
			showInfoWindow()
		end
	end
	hideLastWindow()

	self.mCurSelecetdHeroInfo = widget:getTag()
	self:updateHeroInfo()
end

-- 刷新天赋点限制
function HeroInfoWindow:updateTalentIconLimit()
	-- 读表
	local heroId    = self.mHeroIdTbl[self.mCurSelectedHeroIndex]
	local heroObj   = globaldata:findHeroById(heroId)
	local heroData 	= DB_HeroConfig.getDataById(heroId)

	local talentCnt = 11

	if not heroObj then
		-- 先所有置灰
		for i = 1, talentCnt do 
			local btnWidget = self.mRightSkill:getChildByName("Panel_Talent_"..i):getChildByName("Button_UpGrade")
			ShaderManager:DoUIWidgetDisabled(btnWidget, true) 
			btnWidget:setTouchEnabled(false)
			-- 底图置灰
			local imgWidget = self.mRightSkill:getChildByName("Panel_Talent_"..i):getChildByName("Button_UpGrade")
			imgWidget:loadTextureNormal("hero_talent_lock.png")
		end
		return
	end

	local talentPool = 
	{
		{1, 2},
		{3, 4},
		{5, 6},
		{7, 8},
		{9, 10, 11},
	}

	-- 获取同层
	local function getTheSameFloorTalent(index)
		for i = 1, #talentPool do
			for j = 1, #talentPool[i] do
				if index == talentPool[i][j] then
					return talentPool[i]
				end
			end
		end
	end

	-- 获得对应位置的加点
	local function getTalentValue(index)
		local lblWidget = self.mRightSkill:getChildByName("Panel_Talent_"..index):getChildByName("Label_Level")
		local lblText = lblWidget:getString()
		return tonumber(string.sub(lblText, 1, 1))
	end

	for i = 1, talentCnt do
		print("位置:", i, "值:", getTalentValue(i))
	end

	-- 判断是否应该置灰
	local function isTalentLimit(index)
		if getTalentValue(index) > 0 then -- 已经加点
			print("index:", index , "亮1")
			return false
		end

		local sameFloorTbl = getTheSameFloorTalent(index)
	--	print("获得:", index, "同层信息")
	--	for i = 1, #sameFloorTbl do
	--		print(sameFloorTbl[i])
	--	end
		for i = 1, #sameFloorTbl do
			if index ~= sameFloorTbl[i] then -- 不是自己
				if getTalentValue(sameFloorTbl[i]) > 0 then -- 同层其它位置加点
					print("index:", index , "灰2")
					return true
				end
			end
		end

		print("index:", index , "亮3")
		return false
	end

	for i = 1, talentCnt do
		local btnWidget = self.mRightSkill:getChildByName("Panel_Talent_"..i):getChildByName("Button_UpGrade")
		if isTalentLimit(i) then -- 需要置灰
			ShaderManager:DoUIWidgetDisabled(btnWidget, true) 
			btnWidget:setTouchEnabled(false)
		else
			ShaderManager:DoUIWidgetDisabled(btnWidget, false) 
			btnWidget:setTouchEnabled(true)
		end
	end
end

-- 显示英雄技能
function HeroInfoWindow:updateHeroSkill()
	-- 读表
	local heroId    =  self.mHeroIdTbl[self.mCurSelectedHeroIndex]
	local heroObj   = globaldata:findHeroById(heroId)
	local heroData 	= DB_HeroConfig.getDataById(heroId)
	local talentCnt = 11
	-- 天赋点部分
	local function updateTalentIcon()
		local talentData = DB_Talent.getDataById(heroId)
		for i = 1, talentCnt do
			local talentType = talentData["Talent_"..i]
			-- 图片
			local panelNode = self.mRightSkill:getChildByName("Panel_Talent_"..i)
			panelNode:getChildByName("Image_Item"):loadTexture("hero_property_"..talentType..".png")
			-- 按钮
		--	panelNode:getChildByName("Button_UpGrade"):setTouchEnabled(false)
			-- 数字
			local talentLimit = talentData["Talent_"..i.."_Limit"] -- 属性限制
			panelNode:getChildByName("Label_Level"):setString("0/"..talentLimit)
			-- 底图
			panelNode:getChildByName("Image_Bg"):loadTexture("hero_skill_beidong_cell_bg_1.png")
			-- 属性清零
			panelNode:getChildByName("Label_Property"):setString("+0%")
		end
	end
	updateTalentIcon()

	if heroObj then
		local talentData = DB_Talent.getDataById(heroId)

		local function updateHeroTalentInfo(paramHeroObj)
			-- 剩余天赋点
			self.mRightSkill:getChildByName("Label_Talent"):setString(paramHeroObj.talentPointCount)
			-- 天赋
			for i = 1, #paramHeroObj.talentOwnList do -- i是层
				for j = 1, talentCnt do
					if paramHeroObj.talentOwnList[i].talentType == talentData["Talent_"..j] and i == talentData["Talent_"..j.."_Layer"] then
						local panelNode = self.mRightSkill:getChildByName("Panel_Talent_"..j) -- 控件
						panelNode:getChildByName("Label_Level"):setString(paramHeroObj.talentOwnList[i].talentLevel.."/"..paramHeroObj.talentOwnList[i].talentLevelMax)
						-- 底图
						panelNode:getChildByName("Image_Bg"):loadTexture("hero_skill_beidong_cell_bg_2.png")
						-- 属性
						local addPropVal = paramHeroObj.talentOwnList[i].talentLevel*talentData["Talent_"..j.."_Value"]/10
						panelNode:getChildByName("Label_Property"):setString("+"..tostring(addPropVal).."%")
						break
					end
				end
			end

			-- 根据层数设置灰色(全部置灰)
			for i = 3, 11 do
				-- 底图置灰
				local imgWidget = self.mRightSkill:getChildByName("Panel_Talent_"..i):getChildByName("Button_UpGrade")
				imgWidget:loadTextureNormal("hero_talent_lock.png")
			end
			-- 根据层数设置灰色(开启恢复)
			local talentPool = 
			{
				{1, 2},
				{3, 4},
				{5, 6},
				{7, 8},
				{9, 10, 11},
			}

			local max = #paramHeroObj.talentOwnList
			if max > 0 then
				if paramHeroObj.talentOwnList[max].talentLevelMax == paramHeroObj.talentOwnList[max].talentLevel then -- 满级
					max = max + 1
				end
				if max > 5 then
					max = 5
				end
				for i = 1, max do
					-- 底图恢复
					for j = 1, #talentPool[i] do
						local imgWidget = self.mRightSkill:getChildByName("Panel_Talent_"..talentPool[i][j]):getChildByName("Button_UpGrade")
						imgWidget:loadTextureNormal("public_add2.png")
					end
				end
			else
				-- 底图恢复
				for j = 1, #talentPool[1] do
					local imgWidget = self.mRightSkill:getChildByName("Panel_Talent_"..talentPool[1][j]):getChildByName("Button_UpGrade")
					imgWidget:loadTextureNormal("public_add2.png")
				end
			end

			self:updateTalentIconLimit()

			-- 刷新
			HeroNoticeInnerImpl:doUpdate()
		end
		-- 刷新界面
		updateHeroTalentInfo(heroObj)

		for i = 1, talentCnt do
			local talentType = talentData["Talent_"..i] -- 属性类型
			local talentFloor = talentData["Talent_"..i.."_Layer"] -- 属性层数
			local talentLimit = talentData["Talent_"..i.."_Limit"] -- 属性限制
			local panelNode = self.mRightSkill:getChildByName("Panel_Talent_"..i) -- 控件

			-- 请求设置天赋点
			local function requestSetTalent()
				if heroObj.talentPointCount <= 0 then -- 没有天赋点
					MessageBox:showMessageBox1("无法进行加点操作,请检查是否有足够的剩余天赋点或者上层天赋尚未点满~")
					return
				end

				local function OnRequestSetTalent(msgPacket)
					local msgHeroId = msgPacket:GetInt()
					local newHeroObj = globaldata:findHeroById(msgHeroId)
					newHeroObj.talentPointCount = msgPacket:GetInt()
					newHeroObj.talentOwnCount = msgPacket:GetUShort()
					newHeroObj.talentOwnList = {}
					for i = 1, newHeroObj.talentOwnCount do
						newHeroObj.talentOwnList[i] = {}
						newHeroObj.talentOwnList[i].talentType = msgPacket:GetChar()
						newHeroObj.talentOwnList[i].talentLevel = msgPacket:GetChar()
						newHeroObj.talentOwnList[i].talentLevelMax = msgPacket:GetChar()
					end
					-- 重新刷新界面
					updateHeroTalentInfo(newHeroObj)
					GUISystem:hideLoading()
				end
				NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_HERO_TALENT_SET, OnRequestSetTalent)

				local packet = NetSystem.mNetManager:GetSPacket()
			    packet:SetType(PacketTyper._PTYPE_CS_HERO_TALENT_SET)
			    packet:PushInt(heroId)
			    packet:PushChar(talentFloor)
			   	packet:PushChar(talentType)
			    packet:Send()
			    GUISystem:showLoading()
			end
			-- 按钮
		--	panelNode:getChildByName("Button_UpGrade"):setTouchEnabled(true)
			registerWidgetReleaseUpEvent(panelNode:getChildByName("Button_UpGrade"), requestSetTalent)

			-- 请求重置天赋点
			local function requestResetTalent()

				local heroId = self.mHeroIdTbl[self.mCurSelectedHeroIndex]
				if not globaldata:findHeroById(heroId) then
					MessageBox:showMessageBox1("未拥有该英雄,无法进行此操作~")
					return
				end

				local function OnRequestSetTalent(msgPacket)
					local msgHeroId = msgPacket:GetInt()
					local newHeroObj = globaldata:findHeroById(msgHeroId)
					newHeroObj.talentPointCount = msgPacket:GetInt()
					newHeroObj.talentOwnCount = msgPacket:GetUShort()
					newHeroObj.talentOwnList = {}
					for i = 1, newHeroObj.talentOwnCount do
						newHeroObj.talentOwnList[i] = {}
						newHeroObj.talentOwnList[i].talentType = msgPacket:GetChar()
						newHeroObj.talentOwnList[i].talentLevel = msgPacket:GetChar()
						newHeroObj.talentOwnList[i].talentLevelMax = msgPacket:GetChar()
					end
					-- 重置一下界面
					updateTalentIcon()
					-- 重新刷新界面
					updateHeroTalentInfo(newHeroObj)
					GUISystem:hideLoading()
				end
				NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_HERO_TALENT_SET, OnRequestSetTalent)

				local packet = NetSystem.mNetManager:GetSPacket()
			    packet:SetType(PacketTyper._PTYPE_CS_HERO_TALENT_RESET)
			    packet:PushInt(heroId)
			    packet:Send()
			    GUISystem:showLoading()
			end
			registerWidgetReleaseUpEvent(self.mRightSkill:getChildByName("Button_Reset"), requestResetTalent)
		end
	else
		for i = 1, talentCnt do 
			-- 底图置灰
			local imgWidget = self.mRightSkill:getChildByName("Panel_Talent_"..i):getChildByName("Button_UpGrade")
			imgWidget:loadTextureNormal("hero_talent_lock.png")
		end
	end
end

-- 自动升级技能
function HeroInfoWindow:onSkillAutoUpdate(index, skillLvUp, skillSelected)
	if skillLvUp or skillSelected then
		self:updateHeroSkill()
	end

	-- 刷红点
	HeroNoticeInnerImpl:doUpdate()

	-- 显示特效
	local heroId    = self.mHeroIdTbl[self.mCurSelectedHeroIndex]
	local heroObj   = globaldata:findHeroById(heroId)
	local skillList = heroObj.skillList
	local skillObj  = skillList[index]

	if not skillObj then
		return
	end

	if skillLvUp then -- 技能升级
		if 1 == skillObj.mSkillType then -- 普通
			-- 特效
			local animNode = AnimManager:createAnimNode(8006)
			self.mLeftSkill:getChildByName(string.format("Panel_Attack_%d", skillObj.mSkillIndex)):getChildByName("Panel_SkillAnimation"):addChild(animNode:getRootNode(), 100)
			animNode:play("herolist_skill_update", false)
		elseif 2 == skillObj.mSkillType then -- 主动
			-- 特效
			local animNode = AnimManager:createAnimNode(8006)
			self.mLeftSkill:getChildByName(string.format("Panel_Skill_%d", skillObj.mSkillIndex)):getChildByName("Panel_SkillAnimation"):addChild(animNode:getRootNode(), 100)
			animNode:play("herolist_skill_update", false)
		end
	end
end

-- 显示英雄缘分
function HeroInfoWindow:updateHeroDestiny()
	-- 读表
	local heroId = self.mHeroIdTbl[self.mCurSelectedHeroIndex]
	local heroData = DB_HeroConfig.getDataById(heroId)
	-- 学校名
	local schoolId = heroData.College
	local schoolData = DB_SchoolConfig.getDataById(schoolId)
	local schoolNameId = schoolData.Name
	local schoolName = getDictionaryText(schoolNameId)
	self.mRootWidget:getChildByName("Label_SchoolName_Stroke"):setString(schoolName)
	-- -- 班级
	-- local classId = heroData.Class
	-- local className = getDictionaryText(classId)
	-- self.mRootWidget:getChildByName("Label_ClassName"):setString(className)

	-- 格言
	local sloganId = heroData.Slogan
	local sloganName = getDictionaryText(sloganId)
	self.mRootWidget:getChildByName("Label_Introduction"):setString(sloganName)

	local function createDestinyWidget(heroId, fateType, fateValue, activeType, fateName)
		local widget = GUIWidgetPool:createWidget("HeroRelation")
		local idTbl = extern_string_split_(heroId, ",")

		-- 缘分名字
		widget:getChildByName("Label_Title_Stroke"):setString(getDictionaryText(fateName))

		-- 名字
		local heroName = ""
		if 1 == #idTbl then
			-- 英雄1
			local heroData1 = DB_HeroConfig.getDataById(tonumber(idTbl[1]))
			local heroNameId1 = heroData1.Name
			widget:getChildByName("Image_HeroBg1"):getChildByName("Label_Name_Stroke"):setString(getDictionaryText(heroNameId1))

		elseif 2 == #idTbl then
			-- 英雄1
			local heroData1 = DB_HeroConfig.getDataById(tonumber(idTbl[1]))
			local heroNameId1 = heroData1.Name
			widget:getChildByName("Image_HeroBg1"):getChildByName("Label_Name_Stroke"):setString(getDictionaryText(heroNameId1))
			-- 英雄2
			local heroData2 = DB_HeroConfig.getDataById(tonumber(idTbl[2]))
			local heroNameId2 = heroData2.Name
			widget:getChildByName("Image_HeroBg2"):getChildByName("Label_Name_Stroke"):setString(getDictionaryText(heroNameId2))
		end

		local allIsInTeam = true -- 一同上阵了

		-- 头像
		for i = 1, 2 do
			if idTbl[i] then -- 开放
				local heroId = tonumber(idTbl[i])
				local heroData = DB_HeroConfig.getDataById(heroId)

				if 1 == heroData.Open then -- 开放
				--	local imgId = heroData.IconID
				--	local imgName = DB_ResourceList.getDataById(imgId).Res_path1
					widget:getChildByName("Image_HeroBg"..tostring(i)):getChildByName("Image_HeroLogo"):loadTexture("hero_herolist_hero_"..heroId..".png", 1)

					if 1 == heroData.QualityB then
					--	local animNode = AnimManager:createAnimNode(8065)
					--	widget:getChildByName("Image_HeroBg"..tostring(i)):getChildByName("Panel_Animation_SuperHero"):addChild(animNode:getRootNode(), 100)
					--	animNode:play("hero_list_superhero", true)
					end

					-- 如果此id没有在队伍中,灰化
					local function doGray()
					--	for i = 1, 5 do
						if globaldata:findHeroById(heroId) and 1 == heroData.Open then
						--	if heroId == globaldata:getHeroInfoByBattleIndex(i, "id") then
								return true
						--	end
						end
					--	end
						return false
					end
					if not doGray() then
						allIsInTeam = false
						ShaderManager:decreaseSaturationTo( widget:getChildByName("Image_HeroBg"..tostring(i)):getChildByName("Image_HeroLogo"):getVirtualRenderer(), 0.2)	
					else
						widget:getChildByName("Image_HeroBg"..i):getChildByName("Label_Name_Stroke"):setColor(cc.c3b(255,238,46))
					end
				elseif 0 == heroData.Open then -- 未开放
					allIsInTeam = false
					widget:getChildByName("Image_HeroBg"..i):getChildByName("Image_HeroLogo"):setVisible(false)
					widget:getChildByName("Image_HeroBg"..i):getChildByName("Label_Name_Stroke"):setVisible(false)
					widget:getChildByName("Image_HeroBg"..i):getChildByName("Image_None"):setVisible(true)
				end
			else
				widget:getChildByName("Image_HeroBg"..tostring(i)):setVisible(false)
			end
		end

		if not globaldata:findHeroById(self.mHeroIdTbl[self.mCurSelectedHeroIndex]) then
			allIsInTeam = false
		end

		local typeTable = {}
		typeTable[0] = "生命"
		typeTable[1] = "格斗" 
		typeTable[2] = "破甲" 
		typeTable[3] = "护甲" 
		typeTable[4] = "功夫" 
		typeTable[5] = "柔术" 
		typeTable[6] = "暴击" 
		typeTable[7] = "韧性" 
		typeTable[8] = "攻速"

		-- 加成
		if 1 == activeType then
		--	widget:getChildByName("Label_Addition"):setString("纳入组织 "..typeTable[fateType].." +"..tostring(fateValue).."%")
			widget:getChildByName("Label_Addition"):setString(typeTable[fateType].." +"..tostring(fateValue).."%")
		elseif 2 == activeType then
			widget:getChildByName("Label_Addition"):setString("一同上阵激活合体技")
		end

		if allIsInTeam then
			widget:getChildByName("Label_Addition"):setColor(cc.c3b(255,239,56))
			-- 如果激活了,就添加特效
			local animNode = AnimManager:createAnimNode(8023)
			widget:getChildByName("Panel_Relation_Animation"):addChild(animNode:getRootNode(), 100)
			animNode:play("hero_relation", true)

			local lvVal = 0

			if 1 == #idTbl then
				
				-- local newHeroObj = globaldata:findHeroById(self.mHeroIdTbl[self.mCurSelectedHeroIndex])
				-- if newHeroObj then
				-- 	lvVal = newHeroObj.advanceLevel + newHeroObj.quality
				-- 	print("主英雄advanceLevel:", newHeroObj.advanceLevel, "主英雄quality:", newHeroObj.quality)
				-- end

				newHeroObj = globaldata:findHeroById(tonumber(idTbl[1]))
				if newHeroObj then
					local heroData1 = DB_HeroConfig.getDataById(tonumber(idTbl[1]))
					lvVal = lvVal + newHeroObj.advanceLevel + newHeroObj.quality + heroData1.QualityB*2
					print("1英雄advanceLevel:", newHeroObj.advanceLevel, "1英雄quality:", newHeroObj.quality)

				end

				-- 缘分加成
				widget:getChildByName("Label_Addition"):setString(typeTable[fateType].." +"..(fateValue*lvVal).."%")
	
			elseif 2 == #idTbl then

				-- local newHeroObj = globaldata:findHeroById(self.mHeroIdTbl[self.mCurSelectedHeroIndex])
				-- if newHeroObj then
				-- 	lvVal = newHeroObj.advanceLevel + newHeroObj.quality
				-- 	print("主英雄advanceLevel:", newHeroObj.advanceLevel, "主英雄quality:", newHeroObj.quality)
				-- end

				newHeroObj = globaldata:findHeroById(tonumber(idTbl[1]))
				if newHeroObj then
					local heroData1 = DB_HeroConfig.getDataById(tonumber(idTbl[1]))
					lvVal = lvVal + newHeroObj.advanceLevel + newHeroObj.quality + heroData1.QualityB*2
					print("1英雄advanceLevel:", newHeroObj.advanceLevel, "1英雄quality:", newHeroObj.quality)
				end

				newHeroObj = globaldata:findHeroById(tonumber(idTbl[2]))
				if newHeroObj then
					local heroData2 = DB_HeroConfig.getDataById(tonumber(idTbl[2]))
					lvVal = lvVal + newHeroObj.advanceLevel + newHeroObj.quality + heroData2.QualityB*2
					print("2英雄advanceLevel:", newHeroObj.advanceLevel, "2英雄quality:", newHeroObj.quality)
				end
				lvVal = lvVal - 1

				-- 缘分加成
				widget:getChildByName("Label_Addition"):setString(typeTable[fateType].." +"..(fateValue*lvVal+fateValue).."%")



			end

			-- 缘分名字
			widget:getChildByName("Label_Title_Stroke"):setString(getDictionaryText(fateName).." Lv."..lvVal)

			local function showRelationShipMsgBox()
				-- 指引部分
				local function doHomeGuideTwo_Stop()
					HeroGuideTwo:stop()
				end
				HeroGuideTwo:step(7, nil, doHomeGuideTwo_Stop)

				local msgWnd = GUIWidgetPool:createWidget("Hero_RelationDesc")
				self.mRootNode:addChild(msgWnd, 100)

				-- 缘分名字
				msgWnd:getChildByName("Label_RelationName"):setString(getDictionaryText(fateName).." Lv."..tostring(lvVal))

			--[[
				if 1 == #idTbl then
					-- 缘分加成
					msgWnd:getChildByName("Label_Addition"):setString(typeTable[fateType].." +"..fateValue*lvVal.."%")
				elseif 2 == #idTbl then
					-- 缘分加成
					msgWnd:getChildByName("Label_Addition"):setString(typeTable[fateType].." +"..(fateValue*lvVal+fateValue)*lvVal.."%")
				end
			]]
				-- 缘分加成
				msgWnd:getChildByName("Label_Addition"):setString(widget:getChildByName("Label_Addition"):getString())

				-- 下一属性
				msgWnd:getChildByName("Label_Addition_NextLevel"):setString(typeTable[fateType].." +"..tostring((#idTbl+lvVal)*fateValue).."%")

				-- 适配
				if 2 == #idTbl then
					local preSize = msgWnd:getChildByName("Panel_Main"):getContentSize()
					preSize.height = preSize.height + 75
					msgWnd:getChildByName("Panel_Main"):setContentSize(preSize)
					msgWnd:getChildByName("Image_Bg"):setContentSize(preSize)
				end

				local function updateStarInfo(parentNode, starLevel)
					if 0 == starLevel then

					elseif starLevel >= 1 and starLevel <= 6 then
						for i = 1, starLevel do
							local starWidget = parentNode:getChildByName("Image_Star_"..tostring(i))
							starWidget:loadTexture("public_hero_star1_small.png")
							starWidget:setVisible(true)
						end
					elseif starLevel >= 7 and starLevel <= 12 then
						for i = 1, 6 do
							local starWidget = parentNode:getChildByName("Image_Star_"..tostring(i))
							starWidget:setVisible(true)
							starWidget:loadTexture("public_hero_star1_small.png")
						end

						for i = 1, starLevel - 6 do
							local starWidget = parentNode:getChildByName("Image_Star_"..tostring(i))
							starWidget:setVisible(true)
							starWidget:loadTexture("public_hero_star2_small.png")
						end
					end
				end

				-- -- 学员信息1
				-- local heroId = self.mHeroIdTbl[self.mCurSelectedHeroIndex]
				-- local heroData = DB_HeroConfig.getDataById(heroId)
				-- local heroName = heroData.Name
				-- local parentNode = msgWnd:getChildByName("Panel_Hero_1")
				-- parentNode:getChildByName("Label_HeroName"):setString(getDictionaryText(heroName))
				-- local newHeroObj = globaldata:findHeroById(heroId)
				-- if newHeroObj then
				-- 	parentNode:getChildByName("Label_Quality"):setString("+"..newHeroObj.advanceLevel)
				-- 	updateStarInfo(parentNode, newHeroObj.quality)
				-- end

				-- 学员信息2
				if idTbl[1] then
					heroData = DB_HeroConfig.getDataById(tonumber(idTbl[1]))
					heroName = heroData.Name
					parentNode = msgWnd:getChildByName("Panel_Hero_1")
					parentNode:getChildByName("Label_HeroName"):setString(getDictionaryText(heroName))
					newHeroObj = globaldata:findHeroById(tonumber(idTbl[1]))
					if newHeroObj then
						parentNode:getChildByName("Label_Quality"):setString("+"..newHeroObj.advanceLevel)
						updateStarInfo(parentNode, newHeroObj.quality)

						-- 星星
						updateStarInfo(parentNode, newHeroObj.quality)

						-- 星星等级
						parentNode:getChildByName("Panel_Star"):getChildByName("Label_Star_Level"):setString("等级+"..tostring(newHeroObj.quality))

						-- 星星加成值
						parentNode:getChildByName("Panel_Star"):getChildByName("Label_Star_Addition"):setString("属性+"..tostring(fateValue*newHeroObj.quality).."%")

						-- 品质
						parentNode:getChildByName("Panel_Quality"):getChildByName("Label_Quality"):setString("+"..tostring(newHeroObj.advanceLevel))

						-- 品质等级
						parentNode:getChildByName("Panel_Quality"):getChildByName("Label_Quality_Level"):setString("等级+"..tostring(newHeroObj.advanceLevel))

						-- 品质加成值
						parentNode:getChildByName("Panel_Quality"):getChildByName("Label_Quality_Addition"):setString("属性+"..tostring(fateValue*newHeroObj.advanceLevel).."%")

						-- 头像	
						local heroIcon = createHeroIcon(newHeroObj.id, newHeroObj.level, newHeroObj.quality, newHeroObj.advanceLevel)		
						parentNode:getChildByName("Panel_HeroIcon"):addChild(heroIcon)

						-- 超级学员
						if 1 == heroData.QualityB then
							parentNode:getChildByName("Panel_SuperHero"):setVisible(true)
							parentNode:getChildByName("Panel_SuperHero"):getChildByName("Label_SuperHero_Level"):setString("等级+2")
							-- 超级学员加成值
							parentNode:getChildByName("Panel_SuperHero"):getChildByName("Label_SuperHero_Addition"):setString("属性+"..tostring(fateValue*2).."%")
						end
						
					end	
				end

				-- 学员信息3
				if idTbl[2] then
					heroData = DB_HeroConfig.getDataById(tonumber(idTbl[2]))
					heroName = heroData.Name
					parentNode = msgWnd:getChildByName("Panel_Hero_2")
					parentNode:setVisible(true)
					parentNode:getChildByName("Label_HeroName"):setString(getDictionaryText(heroName))
					newHeroObj = globaldata:findHeroById(tonumber(idTbl[2]))
					if newHeroObj then
						parentNode:getChildByName("Label_Quality"):setString("+"..newHeroObj.advanceLevel)
						updateStarInfo(parentNode, newHeroObj.quality)

						-- 星星
						updateStarInfo(parentNode, newHeroObj.quality)

						-- 星星等级
						parentNode:getChildByName("Panel_Star"):getChildByName("Label_Star_Level"):setString("等级+"..tostring(newHeroObj.quality-1))

						-- 星星加成值
						parentNode:getChildByName("Panel_Star"):getChildByName("Label_Star_Addition"):setString("属性+"..tostring(fateValue*newHeroObj.quality).."%")

						-- 品质
						parentNode:getChildByName("Panel_Quality"):getChildByName("Label_Quality"):setString("+"..tostring(newHeroObj.advanceLevel))

						-- 品质等级
						parentNode:getChildByName("Panel_Quality"):getChildByName("Label_Quality_Level"):setString("等级+"..tostring(newHeroObj.advanceLevel))

						-- 品质加成值
						parentNode:getChildByName("Panel_Quality"):getChildByName("Label_Quality_Addition"):setString("属性+"..tostring(fateValue*newHeroObj.advanceLevel).."%")

						-- 头像	
						local heroIcon = createHeroIcon(newHeroObj.id, newHeroObj.level, newHeroObj.quality, newHeroObj.advanceLevel)		
						parentNode:getChildByName("Panel_HeroIcon"):addChild(heroIcon)

						-- 超级学员
						if 1 == heroData.QualityB then
							parentNode:getChildByName("Panel_SuperHero"):setVisible(true)
							parentNode:getChildByName("Panel_SuperHero"):getChildByName("Label_SuperHero_Level"):setString("等级+2")
							-- 超级学员加成值
							parentNode:getChildByName("Panel_SuperHero"):getChildByName("Label_SuperHero_Addition"):setString("属性+"..tostring(fateValue*2).."%")
						end
					end
				end

				local function delWindow()
					msgWnd:removeFromParent(true)
					msgWnd = nil
				end
				registerWidgetReleaseUpEvent(msgWnd, delWindow)
			end
			registerWidgetPushDownEvent(widget, showRelationShipMsgBox)


		else
			widget:getChildByName("Label_Addition"):setColor(cc.c3b(184,184,184))
		end

		return widget
	end
	local listWidget = self.mDestinyPanel:getChildByName("ListView_Destiny")
 	listWidget:removeAllItems()

-- 	print("当前英雄Id:", heroId)

	-- 缘分一
	local id1 = heroData.FateObj1
	local fateType1 = heroData.FateType1
	local fateValue1 = heroData.FateValue1
	local activeType1 = heroData.FateActiveType1
	local fateName1 = heroData.FateName1
--	print("类型", fateType1)
	local widget1 = createDestinyWidget(id1, fateType1, fateValue1, activeType1, fateName1)
	listWidget:pushBackCustomItem(widget1)

--	print("英雄id1:", id1)

	-- 缘分二
	local id2 = heroData.FateObj2
	local fateType2 = heroData.FateType2
	local fateValue2 = heroData.FateValue2
	local activeType2 = heroData.FateActiveType2
	local fateName2 = heroData.FateName2
--	print("类型", fateType2)
	local widget2 = createDestinyWidget(id2, fateType2, fateValue2, activeType2, fateName2)
	listWidget:pushBackCustomItem(widget2)

--	print("英雄id2:", id2)

	-- 缘分三
	local id3 = heroData.FateObj3
	local fateType3 = heroData.FateType3
	local fateValue3 = heroData.FateValue3
	local activeType3 = heroData.FateActiveType3
	local fateName3 = heroData.FateName3
--	print("类型", fateType3)
	local widget3 = createDestinyWidget(id3, fateType3, fateValue3, activeType3, fateName3)
	listWidget:pushBackCustomItem(widget3)

--	print("英雄id3:", id3)

	-- 缘分四
	local id4 = heroData.FateObj4
	local fateType4 = heroData.FateType4
	local fateValue4 = heroData.FateValue4
	local activeType4 = heroData.FateActiveType4
	local fateName4 = heroData.FateName4
--	print("类型", fateType4)
	local widget4 = createDestinyWidget(id4, fateType4, fateValue4, activeType4, fateName4)
	listWidget:pushBackCustomItem(widget4)

--	print("英雄id4:", id4)
end

-- 显示英雄姓名
function HeroInfoWindow:updateHeroName()
	local heroId    	= self.mHeroIdTbl[self.mCurSelectedHeroIndex]
	local heroData 		= DB_HeroConfig.getDataById(heroId)
	local heroNameId 	= heroData.Name
	local lblWidget 	= self.mRootWidget:getChildByName("Label_HeroName_Stroke_19_48_176")
	lblWidget:setString(getDictionaryText(heroNameId))
end

function HeroInfoWindow:updateRadar()
	local heroId = self.mHeroIdTbl[self.mCurSelectedHeroIndex]
	local heroData = DB_HeroConfig.getDataById(heroId)

	local val = 
	{
		(heroData.LevelAddArmor+heroData.LevelAddTenacity-61)/24,  -- 防御

		1, 																							-- 输出

		(heroData.LevelAddHP+36)/2178, 	 							-- 生存

		(heroData.LevelAddCrit-22)/22, 									-- 爆发

		(heroData.LevelAddArmorPene-22)/22, 						-- 敏捷
	}

	if 1 == heroData.HeroGroup then
		val[2] = ((heroData.LevelAddPhyAttack)*0.7+(heroData.LevelAddHit)*0.3+(heroData.LevelAddDodge)*0.3+3)/132
	elseif 2 == heroData.HeroGroup then
		val[2] = ((heroData.LevelAddPhyAttack)*0.3+(heroData.LevelAddHit)*0.7+(heroData.LevelAddDodge)*0.3+3)/132
	elseif 3 == heroData.HeroGroup then
		val[2] = ((heroData.LevelAddPhyAttack)*0.3+(heroData.LevelAddHit)*0.3+(heroData.LevelAddDodge)*0.7+3)/132
	end
	
	
--	local val = {1, 1, 1, 1, 1}

--	print("英雄雷达图:", "防御:", val[1], "输出:", val[2], "生存:", val[3], "爆发:", val[4], "敏捷:", val[5])

	self.mRadarWidget:drawShape(val)
end

-- 显示英雄属性
function HeroInfoWindow:updateHeroProp()
	self:updateRadar()

	local heroId    = self.mHeroIdTbl[self.mCurSelectedHeroIndex]
	local heroObj   = globaldata:findHeroById(heroId)
	local heroData 	= DB_HeroConfig.getDataById(heroId)

	-- logo
	for i = 1, 3 do
		self.mRootWidget:getChildByName("Button_Logo_"..i):setVisible(false)
	end

	local msgBtn = self.mRootWidget:getChildByName("Button_Logo_"..heroData.HeroGroup)
	msgBtn:setVisible(true)

	local function onMsg()
		if 1 == heroData.HeroGroup then
			MessageBox:showMessageBox1("格斗家的伤害能力主要取决于格斗属性")
		elseif 2 == heroData.HeroGroup then
			MessageBox:showMessageBox1("功夫家的伤害能力主要取决于功夫属性")
		elseif 3 == heroData.HeroGroup then
			MessageBox:showMessageBox1("柔术家的伤害能力主要取决于柔术属性")
		end
	end
	registerWidgetReleaseUpEvent(msgBtn, onMsg)

	-- 颜色
	for i = 1, 3 do
		self.mRootWidget:getChildByName("Label_Name_"..i):setColor(cc.c3b(255, 255, 255))
	end
	self.mRootWidget:getChildByName("Label_Name_"..heroData.HeroGroup):setColor(cc.c3b(255, 232, 73))


	if heroObj then
		self.mShuxingWidget:setEnabled(true)
		local propList = heroObj.propList
		local propListEx = heroObj.propListEx
		-- 生命
		self.mRootWidget:getChildByName("Label_LifeVal"):setString(tostring(propList[0]))
		local labelEx = self.mRootWidget:getChildByName("Label_LifeGrowth")
		if propListEx[0] > 0 then
			labelEx:setString("+"..tostring(propListEx[0]))
			labelEx:setVisible(true)
		else
			labelEx:setVisible(false)
		end

		-- 物攻
		self.mRootWidget:getChildByName("Label_DamageVal"):setString(tostring(propList[1]))
		local labelEx = self.mRootWidget:getChildByName("Label_DamageGrowth")
		if propListEx[1] > 0 then
			labelEx:setString("+"..tostring(propListEx[1]))
			labelEx:setVisible(true)
		else
			labelEx:setVisible(false)
		end

		-- 破甲
		self.mRootWidget:getChildByName("Label_PojiaVal"):setString(tostring(propList[2]))
		local labelEx = self.mRootWidget:getChildByName("Label_PojiaGrowth")
		if propListEx[2] > 0 then
			labelEx:setString("+"..tostring(propListEx[2]))
			labelEx:setVisible(true)
		else
			labelEx:setVisible(false)
		end

		-- 护甲
		self.mRootWidget:getChildByName("Label_HujiaVal"):setString(tostring(propList[3]))
		local labelEx = self.mRootWidget:getChildByName("Label_HujiaGrowth")
		if propListEx[3] > 0 then
			labelEx:setString("+"..tostring(propListEx[3]))
			labelEx:setVisible(true)
		else
			labelEx:setVisible(false)
		end

		-- 命中
		self.mRootWidget:getChildByName("Label_MingzhongVal"):setString(tostring(propList[4]))
		local labelEx = self.mRootWidget:getChildByName("Label_MingzhongGrowth")
		if propListEx[4] > 0 then
			labelEx:setString("+"..tostring(propListEx[4]))
			labelEx:setVisible(true)
		else
			labelEx:setVisible(false)
		end

		-- 闪避
		self.mRootWidget:getChildByName("Label_ShanbiVal"):setString(tostring(propList[5]))
		local labelEx = self.mRootWidget:getChildByName("Label_ShanbiGrowth")
		if propListEx[5] > 0 then
			labelEx:setString("+"..tostring(propListEx[5]))
			labelEx:setVisible(true)
		else
			labelEx:setVisible(false)
		end

		-- 暴击
		self.mRootWidget:getChildByName("Label_BaojiVal"):setString(tostring(propList[6]))
		local labelEx = self.mRootWidget:getChildByName("Label_BaojiGrowth")
		if propListEx[6] > 0 then
			labelEx:setString("+"..tostring(propListEx[6]))
			labelEx:setVisible(true)
		else
			labelEx:setVisible(false)
		end

		-- 韧性
		self.mRootWidget:getChildByName("Label_RenxingVal"):setString(tostring(propList[7]))
		local labelEx = self.mRootWidget:getChildByName("Label_RenxingGrowth")
		if propListEx[7] > 0 then
			labelEx:setString("+"..tostring(propListEx[7]))
			labelEx:setVisible(true)
		else
			labelEx:setVisible(false)
		end

		-- 攻击速度
		self.mRootWidget:getChildByName("Label_GongjiSpeedVal"):setString(tostring(propList[8]))
		local labelEx = self.mRootWidget:getChildByName("Label_GongjiSpeedGrowth")
		if propListEx[8] > 0 then
			labelEx:setString("+"..tostring(propListEx[8]))
			labelEx:setVisible(true)
		else
			labelEx:setVisible(false)
		end

		-- 移动速度
		self.mRootWidget:getChildByName("Label_YidongSpeedVal"):setString(tostring(propList[9]))
		local labelEx = self.mRootWidget:getChildByName("Label_YidongSpeedGrowth")
		if propListEx[9] > 0 then
			labelEx:setString("+"..tostring(propListEx[9]))
			labelEx:setVisible(true)
		else
			labelEx:setVisible(false)
		end

		-- 跳跃力
		self.mRootWidget:getChildByName("Label_JumpVal"):setString(tostring(propList[10]))
		local labelEx = self.mRootWidget:getChildByName("Label_JumpGrowth")
		if propListEx[10] > 0 then
			labelEx:setString("+"..tostring(propListEx[10]))
			labelEx:setVisible(true)
		else
			labelEx:setVisible(false)
		end

		-- 成长属性
		local growPropList = heroObj.growPropList
		for k, v in pairs(growPropList) do
			self.mRootWidget:getChildByName("ProgressBar_Prop"..tostring(k)):setPercent(v)
		end
	else
		self.mShuxingWidget:setEnabled(false)
		-- propList        = {}
		-- growPropList    = {}
	
		-- propList[0]     = heroData.InitHP
		-- propList[1]     = heroData.InitPhyAttack
		-- propList[2]     = heroData.InitArmorPene
		-- propList[3]     = heroData.InitArmor
		-- propList[4]     = heroData.InitHit
		-- propList[5]     = heroData.InitDodge
		-- propList[6]     = heroData.InitCrit
		-- propList[7]     = heroData.InitTenacity
		-- propList[8]     = heroData.InitAttackSpeed
		-- propList[9]     = heroData.InitMoveSpeed
		-- propList[10]    = heroData.InitJumpHeight

		-- growPropList[0] = heroData.LevelAddHP / 1400 * 100
		-- growPropList[1] = heroData.LevelAddPhyAttack
		-- growPropList[2] = heroData.LevelAddArmorPene
		-- growPropList[3] = heroData.LevelAddArmor
		-- growPropList[4] = heroData.LevelAddHit
		-- growPropList[5] = heroData.LevelAddDodge
		-- growPropList[6] = heroData.LevelAddCrit
		-- growPropList[7] = heroData.LevelAddTenacity

		-- -- 生命
		-- self.mRootWidget:getChildByName("Label_LifeVal"):setString(tostring(propList[0]))
		-- -- 物攻
		-- self.mRootWidget:getChildByName("Label_DamageVal"):setString(tostring(propList[1]))
		-- -- 破甲
		-- self.mRootWidget:getChildByName("Label_PojiaVal"):setString(tostring(propList[2]))
		-- -- 护甲
		-- self.mRootWidget:getChildByName("Label_HujiaVal"):setString(tostring(propList[3]))
		-- -- 命中
		-- self.mRootWidget:getChildByName("Label_MingzhongVal"):setString(tostring(propList[4]))
		-- -- 闪避
		-- self.mRootWidget:getChildByName("Label_ShanbiVal"):setString(tostring(propList[5]))
		-- -- 暴击
		-- self.mRootWidget:getChildByName("Label_BaojiVal"):setString(tostring(propList[6]))
		-- -- 韧性
		-- self.mRootWidget:getChildByName("Label_RenxingVal"):setString(tostring(propList[7]))
		-- -- 攻击速度
		-- self.mRootWidget:getChildByName("Label_GongjiSpeedVal"):setString(tostring(propList[8]))
		-- -- 移动速度
		-- self.mRootWidget:getChildByName("Label_YidongSpeedVal"):setString(tostring(propList[9]))
		-- -- 跳跃力
		-- self.mRootWidget:getChildByName("Label_JumpVal"):setString(tostring(propList[10]))
		-- -- 成长属性
		-- for k, v in pairs(growPropList) do
		-- 	self.mRootWidget:getChildByName("ProgressBar_Prop"..tostring(k)):setPercent(v)
		-- end		
	end
end

-- 装备调整
function HeroInfoWindow:onEquipChanged()
	-- 清除装备
	for i = 1, 9 do
		self.mRootWidget:getChildByName("Panel_Equip"..tostring(i)):removeAllChildren()
	end

	-- 添加装备
	local heroId = self.mHeroIdTbl[self.mCurSelectedHeroIndex]
	local heroObj   = globaldata:findHeroById(heroId)
	if heroObj then
		local equipList = heroObj.equipList
		for k, v in pairs(equipList) do
			local equipWidget = createEquipWidget(v:getKeyValue("id"), v:getKeyValue("quality"))
			self.mRootWidget:getChildByName("Panel_Equip"..tostring(v:getKeyValue("type"))):addChild(equipWidget)
		end
	end
	GUISystem:hideLoading()
	self:hideEquipInfo()
	self:onUpdateHerofacade()
	self:dyeHeroAnim(self.mHeroAnimNode,heroId)
end

function HeroInfoWindow:hideEquipInfo()
	if self.mEquipDetailWindow then
		self.mEquipDetailWindow:removeFromParent(true)
		self.mEquipDetailWindow = false
	end
end

-- 显示英雄战力
function HeroInfoWindow:updateHeroCombat()
	local heroId    = self.mHeroIdTbl[self.mCurSelectedHeroIndex]
	local heroObj   = globaldata:findHeroById(heroId)
	if heroObj then
		local combat = heroObj:getKeyValue("combat")
		self.mRootWidget:getChildByName("Label_HeroZhanli"):setString(tostring(combat))
--		print("英雄:", index, "战斗力:", combat)
	else
		self.mRootWidget:getChildByName("Label_HeroZhanli"):setString(tostring("无"))
--		print("英雄:", index, "战斗力:", combat)
	end
end

-- 显示装备信息
function HeroInfoWindow:updateEquipInfo()
	-- 清除装备
	for i = 1, 9 do
		self.mRootWidget:getChildByName("Panel_Equip"..tostring(i)):removeAllChildren()
	end
	-- 添加装备
	local heroId = self.mHeroIdTbl[self.mCurSelectedHeroIndex]
	local heroObj   = globaldata:findHeroById(heroId)
	if heroObj then
		local equipList = heroObj.equipList
		for k, v in pairs(equipList) do
			local equipWidget = createEquipWidget(v:getKeyValue("id"), v:getKeyValue("quality"))
			self.mRootWidget:getChildByName("Panel_Equip"..tostring(v:getKeyValue("type"))):addChild(equipWidget)
		end

		for j = 7, 9 do
			self.mRootWidget:getChildByName("Panel_Equip"..j):setTouchEnabled(true)
		end
	else
		local heroData = DB_HeroConfig.getDataById(heroId)
		for i = 1, 6 do
			local equipId = heroData["Equip"..tostring(i)]
			local equipWidget = createEquipWidget(equipId, 1)
			self.mRootWidget:getChildByName("Panel_Equip"..tostring(i)):addChild(equipWidget)
		end

		for j = 7, 9 do
			self.mRootWidget:getChildByName("Panel_Equip"..j):setTouchEnabled(false)
		end
	end
end


-- 人物换装更新
function HeroInfoWindow:onUpdateHerofacade()
	if self.mHeroAnimNode then
		SpineDataCacheManager:collectFightSpineByAtlas(self.mHeroAnimNode)
		local heroId = self.mHeroIdTbl[self.mCurSelectedHeroIndex]
		local weapon = globaldata:getHeroInfoByBattleIndex(heroId, "weapon")
		if weapon then
			local heorid = heroId
			local _db = DB_HeroConfig.getDataById(heorid)
			local _resID = _db.SimpleResouceID
			local _resScale = _db.SimpleResouceZoom
			if _resID <= 0 then
			   _resID = _db.ResouceID
			   _resScale = _db.ResouceZoom
			end
			local _resDB = DB_ResourceList.getDataById(_resID)
			local dress = globaldata:getHeroInfoByBattleIndex(heroId, "dress")
			if dress then
				local _atlas = _resDB.Res_path1
				local _atlas1 = string.format("%d.",dress.FashionDressIndex)
				_atlas = string.gsub(_atlas,"%.",_atlas1)
				self.mHeroAnimNode = SpineDataCacheManager:getFightSpineByAtlasWeapon(_resDB.Res_path2,_atlas,weapon.ID,_db.UIResouceZoom,self.mHeroAnimPanel)
			else
				self.mHeroAnimNode = SpineDataCacheManager:getFightSpineByAtlasWeapon(_resDB.Res_path2,_resDB.Res_path1,weapon.ID,_db.UIResouceZoom,self.mHeroAnimPanel)
			end
			self.mHeroAnimNode:setScale(_db.UIResouceZoom)
			self.mHeroAnimNode:setAnimation(0,"bindStand3",true)
		else
			local heorid = heroId
			local _db = DB_HeroConfig.getDataById(heorid)
			local _resID = _db.SimpleResouceID
			local _resScale = _db.SimpleResouceZoom
			if _resID <= 0 then
			   _resID = _db.ResouceID
			   _resScale = _db.ResouceZoom
			end
			local _resDB = DB_ResourceList.getDataById(_resID)
			local dress = globaldata:getHeroInfoByBattleIndex(heroId, "dress")
			if dress then
				local _atlas = _resDB.Res_path1
				local _atlas1 = string.format("%d.",dress.FashionDressIndex)
				_atlas = string.gsub(_atlas,"%.",_atlas1)
				self.mHeroAnimNode = SpineDataCacheManager:getFightSpineByatlas(_resDB.Res_path2,_atlas,_db.UIResouceZoom,self.mHeroAnimPanel)
			else
				self.mHeroAnimNode = SpineDataCacheManager:getFightSpineByatlas(_resDB.Res_path2,_resDB.Res_path1,_db.UIResouceZoom,self.mHeroAnimPanel)
			end
			self.mHeroAnimNode:setSkeletonRenderType(cc.RENDER_TYPE_HERO)
			self.mHeroAnimNode:setScale(_db.UIResouceZoom)
			--
			self.mHeroAnimNode:setAnimation(0,"stand",true)
		end

		if self.mPrePicShowed then
			self.mHeroAnimPanel:setOpacity(0)
		else
			self.mHeroAnimPanel:setOpacity(255)
		end
	end
end

-- 染色英雄
function HeroInfoWindow:dyeHeroAnim(_spine,_heriId)
	for i=1,4 do
		local data = globaldata:getHeroInfoByBattleIndex(_heriId, "changecolor",i)
		ShaderManager:changeColorspineByData(_spine,data,_heriId)
	end
end

-- 显示英雄动画
function HeroInfoWindow:updateHeroAnim()
	if self.mCurSelectedHeroIndex == self.mPreSelectedHeroIndex then
		return
	end
	self.mPreSelectedHeroIndex = self.mCurSelectedHeroIndex
	
	if self.mHeroAnimNode then
		SpineDataCacheManager:collectFightSpineByAtlas(self.mHeroAnimNode)
		self.mHeroAnimNode = nil
	end
	local heroId = self.mHeroIdTbl[self.mCurSelectedHeroIndex]
	self.mHeroAnimNode = SpineDataCacheManager:getSimpleSpineByHeroID(heroId,self.mHeroAnimPanel)	
	self:onUpdateHerofacade()
	-- 显示原画大图
	local heroData = DB_HeroConfig.getDataById(heroId)
	local imgId = heroData.PicID
	local imgName = DB_ResourceList.getDataById(imgId).Res_path1
	self.mRootWidget:getChildByName("Image_HeroPic"):loadTexture(imgName)
	self.mRootWidget:getChildByName("Image_PreHeroPic"):loadTexture(imgName)

	self.mHeroAnimNode:setScale(heroData.UIResouceZoom)
	local path = string.format("hero_group%d.png", heroData.HeroGroup)
	self.mRootWidget:getChildByName("Image_HeroGroup"):loadTexture(path)

	self:dyeHeroAnim(self.mHeroAnimNode,heroId)

	local advanceLevel = nil
	if globaldata:findHeroById(heroId) then
		advanceLevel = globaldata:findHeroById(heroId).advanceLevel
	else
		advanceLevel = 0
	end

	path = string.format("hero_group%d_%d.png", heroData.HeroGroup, advanceLevel)
	self.mRootWidget:getChildByName("Image_Group_Quality"):loadTexture(path)

	if not self.mHeroQualityBAnimNode then
	--	self.mHeroQualityBAnimNode = AnimManager:createAnimNode(8064)
	--	self.mRootWidget:getChildByName("Panel_SmallHero"):getChildByName("Panel_SuperHero_Animation"):addChild(self.mHeroQualityBAnimNode:getRootNode(), 100)
	--	self.mHeroQualityBAnimNode:play("hero_halo_superhero", true)
	end

	if 1 == heroData.QualityB then
	--	self.mHeroQualityBAnimNode:setVisible(true)
		self.mRootWidget:getChildByName("Panel_HeroName"):getChildByName("Image_SuperHero"):loadTexture("hero_super_1.png")
	else
	--	self.mHeroQualityBAnimNode:setVisible(false)
		self.mRootWidget:getChildByName("Panel_HeroName"):getChildByName("Image_SuperHero"):loadTexture("hero_super_0.png")
	end

	if self.mPrePicShowed then
		self.mHeroAnimPanel:setOpacity(0)
	else
		self.mHeroAnimPanel:setOpacity(255)
	end
end

-- 灰化大图
function HeroInfoWindow:doPicGray()
	self.mRootWidget:getChildByName("Image_HeroPic"):setOpacity(30)
	ShaderManager:blackwhiteFilter(self.mRootWidget:getChildByName("Image_HeroPic"):getVirtualRenderer())
end

-- 英雄动画和大图之间的切换
function HeroInfoWindow:showHeroPic(widget)
	local moveTime	= 0.5

	if self.mPrePicShowed then
		local function actEnd()
			self.mPrePicShowed = not self.mPrePicShowed
			widget:setTouchEnabled(true)
		end

		-- 前景淡出
		local act0 = cc.FadeOut:create(moveTime)
		local act1 = cc.CallFunc:create(actEnd)
		self.mRootWidget:getChildByName("Image_PreHeroPic"):runAction(cc.Sequence:create(act0, act1))
		-- 后景淡入
		local act2 = cc.FadeIn:create(moveTime)
		self.mRootWidget:getChildByName("Panel_HeroAnim"):runAction(act2)
		-- 光圈可见
		local act3 = cc.FadeIn:create(moveTime)
		self.mRootWidget:getChildByName("Panel_HeroPic"):getChildByName("Image_HeroStop"):runAction(act3)
	else
		local function actEnd()
			self.mPrePicShowed = not self.mPrePicShowed
			widget:setTouchEnabled(true)
		end
		-- 前景淡入
		local act0 = cc.FadeIn:create(moveTime)
		local act1 = cc.CallFunc:create(actEnd)
		self.mRootWidget:getChildByName("Image_PreHeroPic"):runAction(cc.Sequence:create(act0, act1))
		-- 后景淡出
		local act2 = cc.FadeOut:create(moveTime)
		self.mRootWidget:getChildByName("Panel_HeroAnim"):runAction(act2)
		-- 光圈隐藏
		local act3 = cc.FadeOut:create(moveTime)
		self.mRootWidget:getChildByName("Panel_HeroPic"):getChildByName("Image_HeroStop"):runAction(act3)
	end
	widget:setTouchEnabled(false)
end

-- 修正ScrollView位置
function HeroInfoWindow:fixScrollViewPos()
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
		-- 显示英雄信息
		self:updateHeroInfo()

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
	local curHeight = self.mScrollViewWidget:getInnerContainerSize().height - self.mRootWidget:getChildByName("ScrollView_HeroList"):getContentSize().height
	local deltaY = self.mHeroIconList[1]:getPositionY() - self.mHeroIconList[self.mCurSelectedHeroIndex]:getPositionY()
	self.mScrollViewWidget:scrollToPercentVertical(100 - (curHeight-deltaY)/curHeight*100, moveTime, false)
	
	local act0 = cc.DelayTime:create(moveTime)
	local act1 = cc.CallFunc:create(onActEnd)
	self.mRootWidget:runAction(cc.Sequence:create(act0, act1))
	-- 禁止点击
	GUISystem:disableUserInput()
end

-- 默认设置队长选中
function HeroInfoWindow:setLeaderSelected()
	-- 在有指引情况下默认滑到英雄
	if HeroGuideTwo:canGuide() then
		for i = 1, #self.mHeroIdTbl do
			if self.mHeroIdTbl[i] == HeroGuideTwo.heroId then
				self.mCurSelectedHeroIndex = i
				break
			end
		end
		local function doScroll()
			-- 自动滑动
			local curHeight = self.mScrollViewWidget:getInnerContainerSize().height - self.mRootWidget:getChildByName("ScrollView_HeroList"):getContentSize().height
			local deltaY = self.mHeroIconList[1]:getPositionY() - self.mHeroIconList[self.mCurSelectedHeroIndex]:getPositionY()
			self.mScrollViewWidget:scrollToPercentVertical(100 - (curHeight-deltaY)/curHeight*100, 0, false)	
			-- 允许点击
			GUISystem:enableUserInput()
		end
		nextTick(doScroll)
		-- 屏蔽点击
		GUISystem:disableUserInput()
	end

	if HeroGuideOneEx:canGuide() then
		for i = 1, #self.mHeroIdTbl do
			if self.mHeroIdTbl[i] == HeroGuideOneEx.heroId then
				self.mCurSelectedHeroIndex = i
				break
			end
		end
		local function doScroll()
			-- 自动滑动
			local curHeight = self.mScrollViewWidget:getInnerContainerSize().height - self.mRootWidget:getChildByName("ScrollView_HeroList"):getContentSize().height
			local deltaY = self.mHeroIconList[1]:getPositionY() - self.mHeroIconList[self.mCurSelectedHeroIndex]:getPositionY()
			self.mScrollViewWidget:scrollToPercentVertical(100 - (curHeight-deltaY)/curHeight*100, 0, false)	
			-- 允许点击
			GUISystem:enableUserInput()
		end
		nextTick(doScroll)
		-- 屏蔽点击
		GUISystem:disableUserInput()
	end


	-- 默认滑动到初始英雄
	if self.mData and self.mData[1] then
		for i = 1, #self.mHeroIdTbl do
			if self.mHeroIdTbl[i] == self.mData[1] then
				self.mCurSelectedHeroIndex = i
				break
			end
		end
		if 1 == self.mCurSelectedHeroIndex then
			return
		end
		local function doScroll()
			-- 自动滑动
			local curHeight = self.mScrollViewWidget:getInnerContainerSize().height - self.mRootWidget:getChildByName("ScrollView_HeroList"):getContentSize().height
			local deltaY = self.mHeroIconList[1]:getPositionY() - self.mHeroIconList[self.mCurSelectedHeroIndex]:getPositionY()
			self.mScrollViewWidget:scrollToPercentVertical(100 - (curHeight-deltaY)/curHeight*100, 0, false)	
			-- 允许点击
			GUISystem:enableUserInput()
		end
		nextTick(doScroll)
		-- 屏蔽点击
		GUISystem:disableUserInput()
		self.mData[1] = nil
	end
end

function HeroInfoWindow:destroyRootNode()
	cclog("=====HeroInfoWindow:destroyRootNode=====")
	if not self.mRootNode then return end
	ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo("res/animation/JM_Xuanzhong.ExportJson")
	GUIEventManager:unregister("itemInfoChanged", self.onItemInfoChanged)
	GUIEventManager:unregister("equipChanged", self.onEquipChanged)
--	GUIEventManager:unregister("autoSkillUpdate", self.onSkillAutoUpdate)
	GUIEventManager:unregister("heroAddSync", self.onHeroAddFunc)
	GUIEventManager:unregister("heroInfoSync", self.updateHeroCombat)

	dantengVavlue = true
	
	if self.mSchedulerEntry then
		local scheduler = cc.Director:getInstance():getScheduler()
		scheduler:unscheduleScriptEntry(self.mSchedulerEntry)
		self.mSchedulerEntry = nil
	end

	if self.mHeroAnimNode then -- 删除动画节点
		SpineDataCacheManager:collectFightSpineByAtlas(self.mHeroAnimNode)
		self.mHeroAnimNode = nil
	end

	if self.mHeroQualityBAnimNode then
		self.mHeroQualityBAnimNode:destroy()
		self.mHeroQualityBAnimNode = nil
	end

	if self.mHeroIconListScrollingAnimNode then
		self.mHeroIconListScrollingAnimNode:destroy()
		self.mHeroIconListScrollingAnimNode = nil
	end

	if self.mHeroIconListSelectedAnimNode then
		self.mHeroIconListSelectedAnimNode:destroy()
		self.mHeroIconListSelectedAnimNode = nil
	end

	self.mData = nil

	self.mSkillSelectedAnimNode = nil
	
	self.mExpProgressTimerWidget = nil	-- 经验条

	self.mTopRoleInfoPanel:destroy()
	self.mTopRoleInfoPanel = nil

	self.mCurSelectedHeroPeiyangBtn = nil

	self.mRootNode:removeFromParent(true)
	self.mRootNode = nil
	self.mRootWidget = nil

	self.mCurSelectedHeroIndex = 1
	self.mPreSelectedHeroIndex = nil

	self.mRequestLvUpEnabled		=	true

	self.mSchedulerHandler 		=	nil
	self.mPushDownTime			=	0
	self.mReleaseUpTime			=	0

	self.mHeroIconList = {}

	self.mHeroLvUpInfo			=	{heroId = nil, itemId = 0, itemCnt = 0}

	self.mPrePicShowed = false

	self.mExpItemWidgetList		=	{}

	self.mLastChooseWidget 	= 	nil
	self.mLastShowPanel 	=	nil
	-----
	TextureSystem:unloadPlist_iconskill()
end

function HeroInfoWindow:Destroy()
	cclog("=====HeroInfoWindow:Destroy=====")
	self.mRootNode:setVisible(false)
	CommonAnimation.clearAllTextures()
end

function HeroInfoWindow:onEventHandler(event, func)
	if event.mAction == Event.WINDOW_SHOW then
		GUIWidgetPool:preLoadWidget("Hero_ListCell", true)
		GUIWidgetPool:preLoadWidget("HeroRelation", true)
		GUIWidgetPool:preLoadWidget("HeroEquipReplace", true)
		self:Load(event)
		---------停止画主城镇界面
		EventSystem:PushEvent(Event.GUISYSTEM_DISABLEDRAW_HOMEWINDOW)
		---------
		NoticeSystem:doSingleUpdate(self.mName)
		self.mCallFuncAfterDestroy = func
	elseif event.mAction == Event.WINDOW_HIDE then
		GUIWidgetPool:preLoadWidget("Hero_ListCell", false)
		GUIWidgetPool:preLoadWidget("HeroRelation", false)
		GUIWidgetPool:preLoadWidget("HeroEquipReplace", false)
	--	GUISystem:playSound(name)
		self:Destroy()
		---------开启画主城镇界面
		EventSystem:PushEvent(Event.GUISYSTEM_EABLEDRAW_HOMEWINDOW)
		---------
		-- 主城红点刷新
		HomeNoticeInnerImpl:doUpdate()
		if self.mCallFuncAfterDestroy then
			self.mCallFuncAfterDestroy()
			self.mCallFuncAfterDestroy = nil
		end
	end
end

return HeroInfoWindow