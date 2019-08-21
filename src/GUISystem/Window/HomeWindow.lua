-- Name: 	HomeWindow
-- Func：	主城界面
-- Author:	WangShengdong
-- Data:	14-12-15

-------------------局部变量-------------------------
local __OPEN_BLACK_MARKET__  = true
----------------------------------------------------

local function setNodeToMidPoint(parentNode)
	local curSize = parentNode:getContentSize()
	local curPos = cc.p(parentNode:getPosition())
	parentNode:setAnchorPoint(cc.p(0.5, 0.5))
	curPos.x = curPos.x + curSize.width/2
	curPos.y = curPos.y + curSize.height/2
	parentNode:setPosition(cc.p(curPos))
end

--主城底层图标位置，自右向左
local outerBtnPos = 
{
	cc.p(490, 60),
	cc.p(400, 60),
	cc.p(310, 60),
	cc.p(220, 60),
	cc.p(130, 60),
	cc.p(40, 60),
}

--主城底层图标开放等级，自右向左
local outerBtnList = 
{
	{"Image_PVP", 10},
	{"Image_PVE", 17},
	{"Image_Hero", 1},
	{"Image_Grow", 1},
	{"Image_Bagpack", 1},
	{"Image_Banghui", 15},
}

	----------------------------
	----------------------------
	
--学员二级菜单开放等级
local panel_hero_btn_list = 
{
	{"Image_HeroList", 1},
	{"Image_Skill", 4},
	{"Image_Equip", 6},
	{"Image_ColorChange", 1},
}

--学员二级菜单位置-奇数
local panel_hero_btn_pos_odd = 
{
	cc.p(180, 45),
	cc.p(90, 45),
	cc.p(270, 45),
}

--学员二级菜单位置-偶数
local panel_hero_btn_pos_even = 
{
	cc.p(225, 45),
	cc.p(135, 45),
	cc.p(315, 45),
	cc.p(45, 45),
}

	----------------------------
	----------------------------
	
--成长二级菜单开放等级
local panel_grow_btn_list = 
{
	{"Image_PlayerTitle", 1},
	{"Image_MountsGuns", 21},
	{"Image_Badge", 33},
	{"Image_Technology", 39},
}

--成长二级菜单位置-奇数
local panel_grow_btn_pos_odd = 
{
	cc.p(180, 45),
	cc.p(90, 45),
	cc.p(270, 45),
}

--成长二级菜单位置-偶数
local panel_grow_btn_pos_even = 
{
	cc.p(225, 45),
	cc.p(135, 45),
	cc.p(315, 45),
	cc.p(45, 45),
}

	----------------------------
	----------------------------
	
--竞技二级菜单开放等级
local panel_pvp_btn_list = 
{
	{"Image_Arena", 10},
	{"Image_Tianti", 30},
}

--竞技二级菜单位置-奇数
local panel_pvp_btn_pos_odd = 
{
	cc.p(90, 45),
}

--竞技二级菜单位置-偶数
local panel_pvp_btn_pos_even = 
{
	cc.p(45, 45),
	cc.p(135, 45),
}

	----------------------------
	----------------------------
	
--挑战二级菜单开放等级
local panel_pve_btn_list = 
{
	{"Image_WealthMountain", 17},
	{"Image_DayDayUp", 20},
	{"Image_WorldBoss", 22},
	{"Image_Tower", 26},
	{"Image_BlackMarket", 36},
}

--挑战二级菜单位置-奇数
local panel_pve_btn_pos_odd = 
{
	cc.p(225, 45),
	cc.p(135, 45),
	cc.p(315, 45),
	cc.p(405, 45),
	cc.p(45, 45),
}

--挑战二级菜单位置-偶数
local panel_pve_btn_pos_even = 
{
	cc.p(270, 45),
	cc.p(180, 45),
	cc.p(360, 45),
	cc.p(90, 45),
}

	----------------------------
	----------------------------
	
HomeWindow = 
{
	mName 				= "HomeWindow",
	mIsLoaded 		    =   false,
	mRootNode			=	nil,	
	mRootWidget 		= 	nil,
	mBottomChatPanel	=	nil,
	mMenuOpen			=	nil,
	mScrollWidget		=	nil,
	mStartPos			=	nil,
	mEndPos				=	nil,
	----------------------------
	panelTopMenuList 		=	nil,	-- 顶部按钮
	panelBottomMenuList 	= 	nil, 	-- 底部按钮
	panelTopLeftMenuList 	=	nil, 	-- 左部按钮
	----------------------------
	mBuildMode				=	nil, 	-- 建造模式
	mBuildBagOpened 		=	nil, 	-- 建造背包开启
	-- mBuildPanel 			=	nil, 	-- 建造层
	-- mBuildBagPanel			=	nil, 	-- 建造背包层
	mBroadCastTipsDq		=   nil,		-- 广播提示
	mTipSchedulerHandler    =   nil,	-- 检查广播定时器
	-------------------------------------------------
	mAnimNode1				=	nil,
	mAnimNode2				=	nil,
	mAnimNode3				=	nil,
	mCircleNode_fuben       =   nil,    -- 冒险大光圈
	mPageBtnAnimNode		=	nil,	-- 标签页按钮特效
}

-- 更新按钮布局
function HomeWindow:updateHomeBtnLayout()
	if self.mRootWidget then
		local openedCnt = 1
		for i = 1, #outerBtnList do
			if outerBtnList[i][2] <= globaldata.level then -- 显示
				self.mRootWidget:getChildByName(outerBtnList[i][1]):setVisible(true)
				self.mRootWidget:getChildByName(outerBtnList[i][1]):setPosition(outerBtnPos[openedCnt])
				openedCnt = openedCnt + 1
			else -- 不显示
				self.mRootWidget:getChildByName(outerBtnList[i][1]):setVisible(false)
			end
		end
	end
end

function HomeWindow:addPageBtnAnim(parentNode)
	self:removePageBtnAnim()

	local function xxx()
		self.mPageBtnAnimNode:play("hero_skillchosen_2", true)
	end
	self.mPageBtnAnimNode = AnimManager:createAnimNode(8030)
	parentNode:addChild(self.mPageBtnAnimNode:getRootNode(), 100)
	self.mPageBtnAnimNode:play("hero_skillchosen_1", false, xxx)
end

function HomeWindow:removePageBtnAnim()
	if self.mPageBtnAnimNode then
		self.mPageBtnAnimNode:destroy()
		self.mPageBtnAnimNode = nil
	end
end

function HomeWindow:Release()
end


function HomeWindow:Load()
	if self.mIsLoaded then 
	   self:EnableDraw()
	return end
	cclog("=====HomeWindow:Load=====begin")
	self.mIsLoaded = true
	if not self.mRootNode then
		self.mRootNode = cc.Node:create()
		GUISystem:GetRootNode():addChild(self.mRootNode)
		-- 载入UI
		self:InitLayout(self.mRootNode, 3)
		--
		TextureSystem:loadPlist_HomeScene()
	else
		self.mRootNode:setVisible(true)
	end
	--注册通知
	GUIEventManager:registerEvent("roleBaseInfoChanged", self, self.updateRoleBaseData)
	GUIEventManager:registerEvent("playerLevelup", self, self.updateFuncOpen)
	GUIEventManager:registerEvent("noticeSendOut", self, self.showNoticeInfo)
	GUIEventManager:registerEvent("itemInfoChanged", self, self.onItemInfoChanged)

	NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_BROADCAST_TIPS_, handler(self, self.onBroadCastResponse))
	--
	-- 载入城镇和人
	FightSystem:LoadCityHall(self.mRootNode, 1)

	self:updateRoleBaseData()

	self:doHomeGuide()

	-- 刷新下一级别功能开放
	self:updateNextFuncOpenByLevel()

	-- 刷新级别控制
	self:updateHomeBtnLayout()

	GUIWidgetPool:preLoadWidget("ItemWidget", true)

	local function doHomeGuide_Step2()
		local guideBtn = self.mRootWidget:getChildByName("Image_Grow")
		local size = guideBtn:getContentSize()
		local pos = guideBtn:getWorldPosition()
		pos.x = pos.x - size.width/2
		pos.y = pos.y - size.height/2
		local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
		HomeGuideOne:step(2, touchRect)
	end
	HomeGuideOne:step(1, nil, doHomeGuide_Step2)

	if PveGuideOne:canGuide() then
		local window = GUISystem:GetWindowByName("HomeWindow")
		if window.mRootWidget then
			local guideBtn = window.mRootWidget:getChildByName("Button_Adventure")
			local size = guideBtn:getContentSize()
			local pos = guideBtn:getWorldPosition()
			pos.x = pos.x - size.width/2
			pos.y = pos.y - size.height/2
			local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
			PveGuideOne:step(1, touchRect)
		end
	end

	if PveGuideTwo:canGuide() then
		local window = GUISystem:GetWindowByName("HomeWindow")
		if window.mRootWidget then
			local guideBtn = window.mRootWidget:getChildByName("Button_Adventure")
			local size = guideBtn:getContentSize()
			local pos = guideBtn:getWorldPosition()
			pos.x = pos.x - size.width/2
			pos.y = pos.y - size.height/2
			local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
			PveGuideTwo:step(1, touchRect)
		end
	end

	if PveGuideThree:canGuide() then
		local window = GUISystem:GetWindowByName("HomeWindow")
		if window.mRootWidget then
			local guideBtn = window.mRootWidget:getChildByName("Button_Adventure")
			local size = guideBtn:getContentSize()
			local pos = guideBtn:getWorldPosition()
			pos.x = pos.x - size.width/2
			pos.y = pos.y - size.height/2
			local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
			PveGuideThree:step(1, touchRect)
		end
	end

	-- if PveGuideFive:canGuide() then
	-- 	local window = GUISystem:GetWindowByName("HomeWindow")
	-- 	if window.mRootWidget then
	-- 		local guideBtn = window.mRootWidget:getChildByName("Button_Adventure")
	-- 		local size = guideBtn:getContentSize()
	-- 		local pos = guideBtn:getWorldPosition()
	-- 		pos.x = pos.x - size.width/2
	-- 		pos.y = pos.y - size.height/2
	-- 		local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
	-- 		PveGuideFive:step(1, touchRect)
	-- 	end
	-- end

	if PveGuide1_5:canGuide() then
		local window = GUISystem:GetWindowByName("HomeWindow")
		if window.mRootWidget then
			local guideBtn = window.mRootWidget:getChildByName("Button_Adventure")
			local size = guideBtn:getContentSize()
			local pos = guideBtn:getWorldPosition()
			pos.x = pos.x - size.width/2
			pos.y = pos.y - size.height/2
			local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
			PveGuide1_5:step(1, touchRect)
		end
	end

	-- if PveGuide1_6:canGuide() then
	-- 	local window = GUISystem:GetWindowByName("HomeWindow")
	-- 	if window.mRootWidget then
	-- 		local guideBtn = window.mRootWidget:getChildByName("Button_Adventure")
	-- 		local size = guideBtn:getContentSize()
	-- 		local pos = guideBtn:getWorldPosition()
	-- 		pos.x = pos.x - size.width/2
	-- 		pos.y = pos.y - size.height/2
	-- 		local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
	-- 		PveGuide1_6:step(1, touchRect)
	-- 	end
	-- end

	-- if PveGuide1_7:canGuide() then
	-- 	local window = GUISystem:GetWindowByName("HomeWindow")
	-- 	if window.mRootWidget then
	-- 		local guideBtn = window.mRootWidget:getChildByName("Button_Adventure")
	-- 		local size = guideBtn:getContentSize()
	-- 		local pos = guideBtn:getWorldPosition()
	-- 		pos.x = pos.x - size.width/2
	-- 		pos.y = pos.y - size.height/2
	-- 		local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
	-- 		PveGuide1_7:step(1, touchRect)
	-- 	end
	-- end

	if SkillGuideOne:canGuide() then
		local window = GUISystem:GetWindowByName("HomeWindow")
		if window.mRootWidget then
			local guideBtn = window.mRootWidget:getChildByName("Image_Hero")
			local size = guideBtn:getContentSize()
			local pos = guideBtn:getWorldPosition()
			pos.x = pos.x - size.width/2
			pos.y = pos.y - size.height/2
			local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
			SkillGuideOne:step(2, touchRect)
		end
	end

	if LevelRewardGuideZero:canGuide() then
		local guideBtn = self.mRootWidget:getChildByName("Button_HomeLevelReward")
		local size = guideBtn:getContentSize()
		local pos = guideBtn:getWorldPosition()
		pos.x = pos.x - size.width/2
		pos.y = pos.y - size.height/2
		local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
		LevelRewardGuideZero:step(3, touchRect)
	end

	if LevelRewardGuideOne:canGuide() then
		local guideBtn = self.mRootWidget:getChildByName("Button_HomeLevelReward")
		local size = guideBtn:getContentSize()
		local pos = guideBtn:getWorldPosition()
		pos.x = pos.x - size.width/2
		pos.y = pos.y - size.height/2
		local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
		LevelRewardGuideOne:step(2, touchRect)
	end

	if LevelRewardGuideOnePointFive:canGuide() then
		local guideBtn = self.mRootWidget:getChildByName("Button_HomeLevelReward")
		local size = guideBtn:getContentSize()
		local pos = guideBtn:getWorldPosition()
		pos.x = pos.x - size.width/2
		pos.y = pos.y - size.height/2
		local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
		LevelRewardGuideOnePointFive:step(2, touchRect)
	end

	if LotteryGuideOne:canGuide() then
		local guideBtn = self.mRootWidget:getChildByName("Image_Get")
		local size = guideBtn:getContentSize()
		local pos = guideBtn:getWorldPosition()
		pos.x = pos.x - size.width/2
		pos.y = pos.y - size.height/2
		local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
		LotteryGuideOne:step(1, touchRect)
	end

	local function doHeroGuideOneEx_Step2()
		local guideBtn = self.mRootWidget:getChildByName("Button_Hero")
		local size = guideBtn:getContentSize()
		local pos = guideBtn:getWorldPosition()
		pos.x = pos.x - size.width/2
		pos.y = pos.y - size.height/2
		local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
		HeroGuideOneEx:step(2, touchRect)
	end
	HeroGuideOneEx:step(1, nil, doHeroGuideOneEx_Step2)

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

	if LevelRewardGuideTwo:canGuide() then
		local guideBtn = self.mRootWidget:getChildByName("Button_HomeLevelReward")
		local size = guideBtn:getContentSize()
		local pos = guideBtn:getWorldPosition()
		pos.x = pos.x - size.width/2
		pos.y = pos.y - size.height/2
		local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
		LevelRewardGuideTwo:step(2, touchRect)
	end

	if HeroGuideTwo:canGuide() then
		local guideBtn = self.mRootWidget:getChildByName("Button_Hero")
		local size = guideBtn:getContentSize()
		local pos = guideBtn:getWorldPosition()
		pos.x = pos.x - size.width/2
		pos.y = pos.y - size.height/2
		local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
		HeroGuideTwo:step(1, touchRect)
	end

	if ArenaGuideOne:canGuide() then
		local guideBtn = self.mRootWidget:getChildByName("Button_PVP")
		local size = guideBtn:getContentSize()
		local pos = guideBtn:getWorldPosition()
		pos.x = pos.x - size.width/2
		pos.y = pos.y - size.height/2
		local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
		ArenaGuideOne:step(2, touchRect)
	end

	if TaskGuideOne:canGuide() then
		local guideBtn = self.mRootWidget:getChildByName("Button_Task")
		local size = guideBtn:getContentSize()
		local pos = guideBtn:getWorldPosition()
		pos.x = pos.x - size.width/2
		pos.y = pos.y - size.height/2
		local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
		TaskGuideOne:step(2, touchRect)
	end

	if TaskGuideZero:canGuide() then
		local guideBtn = self.mRootWidget:getChildByName("Button_Task")
		local size = guideBtn:getContentSize()
		local pos = guideBtn:getWorldPosition()
		pos.x = pos.x - size.width/2
		pos.y = pos.y - size.height/2
		local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
		TaskGuideZero:step(2, touchRect)
	end

	if EquipGuideOne:canGuide() then
		local guideBtn = self.mRootWidget:getChildByName("Image_Hero")
		local size = guideBtn:getContentSize()
		local pos = guideBtn:getWorldPosition()
		pos.x = pos.x - size.width/2
		pos.y = pos.y - size.height/2
		local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
		EquipGuideOne:step(2, touchRect)
	end

	cclog("=====HomeWindow:Load=====end")

	self.mBroadCastTipsDq = deque.new()
end

-- 各种软指引
function HomeWindow:doHomeGuide()
	FuckTimeGuideOne:doHomeGuide()

	GonghuiGuideOne:doHomeGuide()

	DayDayUpGuideOne:doHomeGuide()

	EquipGuideTwo:doHomeGuide()

	WorldBossGuideOne:doHomeGuide()

	ParkGuideOne:doHomeGuide()

	TiantiGuideOne:doHomeGuide()

	HeroHorseGuide:doHomeGuide()

	HeroWeaponGuide:doHomeGuide()

	BadgeGuideOne:doHomeGuide()

	BlackMarketGuide:doHomeGuide()

	TechnologyGuideOne:doHomeGuide()

	-- 显示特效
	self:showPveCircleNode()
end

-- 各种软指引
function HomeWindow:doHomeGuideDestroy()
	FuckTimeGuideOne:doHomeGuideDestroy()

	GonghuiGuideOne:doHomeGuideDestroy()

	DayDayUpGuideOne:doHomeGuideDestroy()

	EquipGuideTwo:doHomeGuideDestroy()

	WorldBossGuideOne:doHomeGuideDestroy()

	ParkGuideOne:doHomeGuideDestroy()

	TiantiGuideOne:doHomeGuideDestroy()

	HeroHorseGuide:doHomeGuideDestroy()

	HeroWeaponGuide:doHomeGuideDestroy()

	BadgeGuideOne:doHomeGuideDestroy()

	BlackMarketGuide:doHomeGuideDestroy()

	TechnologyGuideOne:doHomeGuideDestroy()
end

function HomeWindow:onItemInfoChanged()
	-- 主城红点刷新
--	HomeNoticeInnerImpl:doUpdate()
end

-- 设置建造模式
function HomeWindow:setBuildMode(widget)
	if self.mBuildMode then
--		self.mBuildPanel1:setVisible(true)
--		self.mBuildPanel2:setVisible(false)
		self.panelTopMenuList:setVisible(true)
		self.panelBottomMenuList:setVisible(true)
		self.panelTopLeftMenuList:setVisible(true)
--		widget:getChildByName("Label_Text"):setString("建造")
		-- if GUISystem.mFurnitManager then
		-- 	GUISystem.mFurnitManager:setEditMode(false)
		-- 	-- 关闭移除模式
		-- 	self.mRootWidget:getChildByName("Button_Sell"):setTitleText("移除")
		-- 	self.mDelMode = false
		-- end
		GUISystem.mFurnitManager:removeMovingFurnit()
	else
--		self.mBuildPanel1:setVisible(true)
--		self.mBuildPanel2:setVisible(true)
		self.panelTopMenuList:setVisible(false)
		self.panelBottomMenuList:setVisible(false)
		self.panelTopLeftMenuList:setVisible(false)
--		widget:getChildByName("Label_Text"):setString("返回")

		-- if GUISystem.mFurnitManager then
		-- 	GUISystem.mFurnitManager:setEditMode(true)
		-- end
	end
	-- 变量
	-- self.mBuildMode = not self.mBuildMode
	-- 建造背包按钮隐藏
	-- self.mBuildBagPanel:setVisible(self.mBuildMode)
end

function HomeWindow:getBuildMode()
	return self.mBuildMode
end

-- 打开建造背包
function HomeWindow:openBuildBag(widget)
	-- local moveTime	= 0.2
	-- local moveLength = 150

	-- if self.mBuildBagOpened then -- 已经打开
	-- 	local act0 = cc.MoveBy:create(moveTime, cc.p(moveLength, 0))
	-- 	self.mBuildBagPanel:runAction(act0)
	-- else -- 未打开
	-- 	GUISystem.mFurnitManager:getDataFromGlobal()
	-- 	GUISystem.mFurnitManager:reloadData()
	-- 	local act0 = cc.MoveBy:create(moveTime, cc.p(-moveLength, 0))
	-- 	self.mBuildBagPanel:runAction(act0)
	-- end
	-- -- 建造按钮隐藏
	-- self.mRootWidget:getChildByName("Button_Build"):setVisible(self.mBuildBagOpened)
	-- -- 变量
	-- self.mBuildBagOpened = not self.mBuildBagOpened
end

function HomeWindow:updateRoleBaseData()
	print("HomeWindow:updateRoleBaseData()")
	self.mRootWidget:getChildByName("Label_PlayerName"):setString(tostring(globaldata:getPlayerBaseData("name")))
	self.mRootWidget:getChildByName("Label_Level_42_85_208"):setString("LV "..tostring(globaldata:getPlayerBaseData("level")))
	local levelVal = globaldata:getPlayerBaseData("vipLevel")
--	self.mRootWidget:getChildByName("Image_VIP_Bg"):loadTexture(string.format("home_vip_bg_%d.png",getVipLevelBg(_lv)))
--	self.mRootWidget:getChildByName("Image_VIP"):getChildByName("Image_VIP"):loadTexture(string.format("home_vip_%02d.png",_lv))
	
	self.mRootWidget:getChildByName("Label_VIP_Stroke"):setString(levelVal)
	if 15 == levelVal or 16 == levelVal then
		self.mRootWidget:getChildByName("Label_VIP_Stroke"):setColor(cc.c3b(255, 242, 67))
	end

	if levelVal >= 0 and levelVal <= 5 then
		self.mRootWidget:getChildByName("Image_VIP_Bg"):loadTexture("home_vip_bg_1.png", 1)
	elseif levelVal >= 6 and levelVal <= 10 then
		self.mRootWidget:getChildByName("Image_VIP_Bg"):loadTexture("home_vip_bg_2.png", 1)
	elseif levelVal >= 11 and levelVal <= 14 then
		self.mRootWidget:getChildByName("Image_VIP_Bg"):loadTexture("home_vip_bg_3.png", 1)
	elseif levelVal >= 15 and levelVal <= 16 then
		self.mRootWidget:getChildByName("Image_VIP_Bg"):loadTexture("home_vip_bg_4.png", 1)
	end

	self.mRootWidget:getChildByName("Label_Tili"):setString(tostring(globaldata:getPlayerBaseData("vatality")).."/"..tostring(globaldata:getPlayerBaseData("maxVatality")))
--	self.mRootWidget:getChildByName("Label_Naili"):setString(tostring(globaldata:getPlayerBaseData("naili")).."/"..tostring(globaldata:getPlayerBaseData("maxNaili")))
	-- 战力
	self.mRootWidget:getChildByName("Label_TotalZhanli"):setString(tostring(globaldata:getTeamCombat()))
	
	-- 钻石改变
	local preDiamond = globaldata:getPlayerPreBaseData("diamond")
	local curDiamond = globaldata:getPlayerBaseData("diamond")
	widgetDoGradualAction(self.mRootWidget:getChildByName("Label_Diamond"), preDiamond, curDiamond)
	-- 金币改变
	local preGold = globaldata:getPlayerPreBaseData("money")
	local curGold = globaldata:getPlayerBaseData("money")
	widgetDoGradualAction(self.mRootWidget:getChildByName("Label_Gold"), preGold, curGold)
end

function HomeWindow:openMenu(widget)
	local moveTime	= 0.2
	widget:setTouchEnabled(false)
	if not self.mMenuOpen then
	local function actEnd()
			self.mMenuOpen = true
			widget:loadTextureNormal("home_open2.png")
			widget:setTouchEnabled(true)
		end
		local function doOpen()
			local act0 = cc.EaseIn:create(cc.MoveTo:create(moveTime, self.mEndPos), 3)
			local act1 = cc.CallFunc:create(actEnd)
			self.mScrollWidget:runAction(cc.Sequence:create(act0, act1))
		end
		doOpen()
	else
		local function actEnd()
			self.mMenuOpen = false
			widget:loadTextureNormal("home_open.png")
			widget:setTouchEnabled(true)
		end
		local function doClosed()
			local act0 = cc.EaseOut:create(cc.MoveTo:create(moveTime, self.mStartPos), 3)
			local act1 = cc.CallFunc:create(actEnd)
			self.mScrollWidget:runAction(cc.Sequence:create(act0, act1))
		end
		doClosed()
	end
end

function HomeWindow:InitLayout(_root, _zorder)	
    self.mRootWidget = GUIWidgetPool:createWidget("NewHomeWindow")

    _root:addChild(self.mRootWidget, _zorder)


    self.panelTopMenuList = self.mRootWidget:getChildByName("Panel_TopMenuList")
    self.panelTopMenuList:setVisible(false)

    self.panelBottomMenuList = self.mRootWidget:getChildByName("Panel_BottomMenuList")
    self.panelBottomMenuList:setVisible(false)

    self.panelTopLeftMenuList = self.mRootWidget:getChildByName("Panel_TopLeftMenulist")
    self.panelTopLeftMenuList:setVisible(false)

    -- -- 建造层
    -- self.mBuildPanel = self.mRootWidget:getChildByName("Panel_Build")
    -- self.mBuildPanel:setVisible(false)

    -- -- 建造背包层
    -- self.mBuildBagPanel = self.mRootWidget:getChildByName("Panel_BuildBag")
    -- self.mBuildBagPanel:setVisible(false)

    self.mBuildMode = false

    self.mBuildBagOpened = false

    local function doAdapter()
    	local contentSize = self.panelTopMenuList:getContentSize()
    	self.panelTopMenuList:setPosition(getGoldFightPosition_RU().x - contentSize.width, getGoldFightPosition_RU().y - contentSize.height)
    	self.panelTopMenuList:setVisible(true)

    	contentSize = self.panelTopLeftMenuList:getContentSize()
    	self.panelTopLeftMenuList:setPosition(getGoldFightPosition_LU().x, getGoldFightPosition_LU().y - contentSize.height)
    	self.panelTopLeftMenuList:setVisible(true)

    	contentSize = self.panelBottomMenuList:getContentSize()
    	self.panelBottomMenuList:setPosition(getGoldFightPosition_RD().x - contentSize.width, getGoldFightPosition_RD().y)
    	self.panelBottomMenuList:setVisible(true)

    	-- -- 建造层
    	-- contentSize = self.mBuildPanel:getContentSize()
    	-- self.mBuildPanel:setPositionX(getGoldFightPosition_RD().x - contentSize.width)

    	-- 广播
    	local noticePanel = self.mRootWidget:getChildByName("Panel_TopNotice")
    	local size = noticePanel:getContentSize()
    	noticePanel:setPosition(getGoldFightPosition_Middle().x - size.width / 2,getGoldFightPosition_LU().y - self.panelTopLeftMenuList:getContentSize().height - 45)
    end
   doAdapter()
    
   	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Panel_StoryTask"), handler(self, self.OnTaskMainEvent))
   	self:upDateTaskMain()

    registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_Tili"), handler(self, self.PurchaseEvent))
    self.mRootWidget:getChildByName("Button_Tili"):setTag(0)

    -- 体力信息
	local function showTiliInfo(widget)
		MessageBox:showMessageBox_TiliInfo(widget)
	end
	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Panel_Tili"), showTiliInfo)

--    registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_Gold"), handler(self, self.PurchaseEvent))
--    self.mRootWidget:getChildByName("Button_Gold"):setTag(2)

	-- 建筑按钮
	-- registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_Build"), handler(self, self.setBuildMode))

	-- 建造背包
	-- registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_Bag"), handler(self, self.openBuildBag))

	-- 点金请求
	local function doGoldenFinger()
		GUISystem:goTo("goldenfinger")
	end
	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_Gold"), doGoldenFinger)

	self.mBottomChatPanel = BottomChatPanel:new()
	self.mBottomChatPanel:init(_root)

	-- 抽屉
	-- self.mRootWidget:getChildByName("Button_Open"):setTouchEnabled(true)
	-- registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_Open"), handler(self, self.openMenu))
	-- self.mMenuOpen = false
	-- self.mScrollWidget = self.mRootWidget:getChildByName("Image_Scroll")
	-- self.mStartPos = cc.p(self.mScrollWidget:getPosition())
	-- local contentSize = self.mScrollWidget:getContentSize()
	-- self.mEndPos = cc.p(self.mStartPos.x - contentSize.width, self.mStartPos.y)

	-- 内购
	local function openIAP()
		FightSystem.mTouchPad:setCancelledTouch()
		GUISystem:playSound("homeBtnSound")
		GUISystem:goTo("iap")
	end
	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_Diamond"), openIAP)
	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_Deposit"), openIAP)

	-- 背包
	local function openBag()
		FightSystem.mTouchPad:setCancelledTouch()
		GUISystem:playSound("homeBtnSound")
		GUISystem:goTo("bagpack")
	end
	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_Bagpack"), openBag)

	-- 装备
	local function openEquip()
		FightSystem.mTouchPad:setCancelledTouch()
		GUISystem:playSound("homeBtnSound")
		GUISystem:goTo("equip",1)
	end
	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_Equip"), openEquip)

	-- 英雄
	-- local function openHero()
	-- 	FightSystem.mTouchPad:setCancelledTouch()
	-- 	GUISystem:playSound("homeBtnSound")
	-- 	GUISystem:goTo("allhero")
	-- end
	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_HeroList"), openHero)

	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Panel_PlayerInfo"), handler(self, self.OnEventPlayerInfo))

	-- PVP
	local function openArena()
		FightSystem.mTouchPad:setCancelledTouch()
		GUISystem:playSound("homeBtnSound")
		GUISystem:goTo("arena")
	end
	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_Arena"), openArena)

	-- 招募
	local function openLottery()
		FightSystem.mTouchPad:setCancelledTouch()
		GUISystem:playSound("homeBtnSound")
		GUISystem:goTo("lottery")
	end
	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_Get"), openLottery)

	-- 商城
	local function openShop()
		FightSystem.mTouchPad:setCancelledTouch()
		GUISystem:playSound("homeBtnSound")
		GUISystem:goTo("shangcheng", 7)
	end
	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_Shop"), openShop)

	-- 活动
--	local function openActivity()
--		FightSystem.mTouchPad:setCancelledTouch()
--		GUISystem:playSound("homeBtnSound")
--		GUISystem:goTo("activity",nil)
--	end
--	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_Activity"), openActivity)

	-- PVE
	local function openPVE()
		FightSystem.mTouchPad:setCancelledTouch()
		GUISystem:playSound("homeBtnSound")
		GUISystem:goTo("pve")
		-- TextureSystem:logTextureCacheInfo()
	end
	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_Adventure"), openPVE)

	-- 邮件
	local function openMail()
		FightSystem.mTouchPad:setCancelledTouch()
		GUISystem:playSound("homeBtnSound")
		GUISystem:goTo("mail")
	end
	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_Mail"), openMail)

	-- 所有英雄
	local function openAllHero()
		FightSystem.mTouchPad:setCancelledTouch()
		GUISystem:playSound("homeBtnSound")
		GUISystem:goTo("hero",1)
	end
--	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_Team"), openAllHero)
	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_HeroList"), openAllHero)

	-- 任务
	local function openTask()
		FightSystem.mTouchPad:setCancelledTouch()
		GUISystem:playSound("homeBtnSound")
		GUISystem:goTo("task")
	end
	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_Task"), openTask)

	-- 技能
	local function openSkill()
		GUISystem:playSound("homeBtnSound")
		GUISystem:goTo("skill")
	end
	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_Skill"), openSkill)

	-- 排行榜
	local function openRankingList()
		FightSystem.mTouchPad:setCancelledTouch()
		GUISystem:playSound("homeBtnSound")
		GUISystem:goTo("rankinglist",{RANKTYPE.MAIN.ORGANIZE,RANKTYPE.MINOR.ALLFIGHTPOWER})
	end
	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_RankingList"), openRankingList)

	-- 每日奖励
	local function openDailyReward()
		FightSystem.mTouchPad:setCancelledTouch()
		GUISystem:playSound("homeBtnSound")
		GUISystem:goTo("dailyreward")
	end
	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_Bonus"), openDailyReward)

	-- 约会
	-- local function openYuehui()
	-- 	FightSystem.mTouchPad:setCancelledTouch()
	-- 	GUISystem:playSound("homeBtnSound")
	-- 	GUISystem:goTo("yuehui")
	-- end
	-- self.mRootWidget:getChildByName("Button_Date"):setTouchEnabled(true)
	-- registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_Date"), openYuehui)

  	--好友
	local function openFriend()
		FightSystem.mTouchPad:setCancelledTouch()
		GUISystem:playSound("homeBtnSound")
		GUISystem:goTo("friend")
	end

	--黑市
	local function openBlackMarket()
		if __OPEN_BLACK_MARKET__ then
			GUISystem:goTo("blackmarket")
		end
	end

	-- 徽章
	local function openBadge()
		GUISystem:goTo("badge")
	end
	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_Badge"), openBadge)

	--世界boss
	local function openWorldBoss( ... )
		GUISystem:goTo("worldboss")
	end

	-- 英雄美化
	local function openHeroBeautify()
		GUISystem:goTo("herobeautify")
	end
	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_ColorChange"), openHeroBeautify)

	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_Social"), openFriend)
	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_Tower"),function() GUISystem:goTo("tower")end)
	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_WealthMountain"),function() GUISystem:goTo("wealth") end)
	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_Tianti"),function() GUISystem:goTo("ladder") end)
	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_Banghui"),function() GUISystem:goTo("partyEntry") end)

	self.mLvAnim = AnimManager:createAnimNode(8070)
	local btn    = self.mRootWidget:getChildByName("Button_HomeLevelReward")
	btn:getChildByName("Panel_Animation"):removeAllChildren()
	btn:getChildByName("Panel_Animation"):addChild(self.mLvAnim:getRootNode(), 1000)
	self:UpdateLevelReward(globaldata.curLvRewardInfo)

	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_BlackMarket"), openBlackMarket)
	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_WorldBoss"), openWorldBoss)

	--self.mRootWidget:getChildByName("Button_Technology"):setTouchEnabled(false)
	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_Technology"),
		function() 
			GUISystem:goTo("technology") 
			end )
	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_DayDayUp"),function() GUISystem:goTo("towerex") end )

	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_MountsGuns"),function() GUISystem:goTo("horsegun") end )
	
	registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_PlayerTitle"),function() GUISystem:goTo("herotitle") end )
	  -- if FightConfig.__DEBUG_ONLINEPVP_ then
	  -- 	local btn = self.mRootWidget:getChildByName("CheckBox_5")
	  -- 	btn:setVisible(true)
	  -- 	btn:addEventListener(selectedEvent)

	  -- 	local btn = self.mRootWidget:getChildByName("CheckBox_5_0")
	  -- 	btn:setVisible(true)
	  -- 	btn:addEventListener(selectedEvent1)
	  -- end

	-- 控制功能开启
	self:updateFuncOpen()

	self.mTipSchedulerHandler = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self, self.UpDateTopNotice),config.NoticeTimerGap, false)

	-- 红点
	self:showNoticeInfo()

	-- 添加特效
	self.mAnimNode1 = AnimManager:createAnimNode(8009) -- 体力
	self.mRootWidget:getChildByName("Panel_Tili"):getChildByName("Panel_Animation"):addChild(self.mAnimNode1:getRootNode(), 100)
	self.mAnimNode1:play("roleinfo_tili", true)

	self.mAnimNode2 = AnimManager:createAnimNode(8010) -- 钻石
	self.mRootWidget:getChildByName("Panel_Diamond"):getChildByName("Panel_Animation"):addChild(self.mAnimNode2:getRootNode(), 100)
	self.mAnimNode2:play("roleinfo_diamond", true)

	self.mAnimNode3 = AnimManager:createAnimNode(8011) -- 金币
	self.mRootWidget:getChildByName("Panel_Gold"):getChildByName("Panel_Animation"):addChild(self.mAnimNode3:getRootNode(), 100)
	self.mAnimNode3:play("roleinfo_gold", true)

	-- 添加特效
	local function addAnim()
		local animNode = AnimManager:createAnimNode(8021)
		self.mRootWidget:getChildByName("Panel_Deposit_Animation"):addChild(animNode:getRootNode(), 100)
		animNode:play("home_deposit", true)

		animNode = AnimManager:createAnimNode(8020)
		self.mRootWidget:getChildByName("Panel_PlayerInfo_Animation"):addChild(animNode:getRootNode(), 100)
		animNode:play("home_playerinfo", true)
	end
	addAnim()
	local function changeHeroIcon()
		local data = DB_PlayerIcon.getDataById(globaldata.playerIcon)
		local Icon = DB_ResourceList.getDataById(data.ResourceListID).Res_path1
		self.mRootWidget:getChildByName("Panel_PlayerInfo"):getChildByName("Image_PlayerHead"):loadTexture(Icon)
	end
	changeHeroIcon()

	local function showPanelLogic()
		local function showPvp()
			local vivible = self.mRootWidget:getChildByName("Panel_PVP"):isVisible() 
			self.mRootWidget:getChildByName("Panel_PVP"):setVisible(not vivible)
			self.mRootWidget:getChildByName("Panel_PVE"):setVisible( false)
			self.mRootWidget:getChildByName("Panel_Hero"):setVisible( false)
			self.mRootWidget:getChildByName("Panel_Grow"):setVisible( false)
			-- 添加动画
			if not vivible then
				self:addPageBtnAnim(self.mRootWidget:getChildByName("Image_PVP"):getChildByName("Panel_Open_Animation"))
				-- 按钮显示逻辑
				self:btnListShowLogic(self.mRootWidget:getChildByName("Panel_PVP"), panel_pvp_btn_list, panel_pvp_btn_pos_even, panel_pvp_btn_pos_odd, self.mRootWidget:getChildByName("Image_PVP"))
			else
				self:removePageBtnAnim()
			end

			-- 软指引
			self:doHomeGuide()
		end
		registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_PVP"), showPvp)

		local function showPve()
			local vivible = self.mRootWidget:getChildByName("Panel_PVE"):isVisible() 
			self.mRootWidget:getChildByName("Panel_PVP"):setVisible( false)
			self.mRootWidget:getChildByName("Panel_PVE"):setVisible(not vivible)
			self.mRootWidget:getChildByName("Panel_Hero"):setVisible( false)
			self.mRootWidget:getChildByName("Panel_Grow"):setVisible( false)
			-- 添加动画
			if not vivible then
				self:addPageBtnAnim(self.mRootWidget:getChildByName("Image_PVE"):getChildByName("Panel_Open_Animation"))
				-- 按钮显示逻辑
				self:btnListShowLogic(self.mRootWidget:getChildByName("Panel_PVE"), panel_pve_btn_list, panel_pve_btn_pos_even, panel_pve_btn_pos_odd, self.mRootWidget:getChildByName("Image_PVE"))
			else
				self:removePageBtnAnim()
			end
			-- 软指引
			self:doHomeGuide()
		end
		registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_PVE"), showPve)

		local function showHero()
			local vivible = self.mRootWidget:getChildByName("Panel_Hero"):isVisible() 
			self.mRootWidget:getChildByName("Panel_PVP"):setVisible( false)
			self.mRootWidget:getChildByName("Panel_PVE"):setVisible( false)
			self.mRootWidget:getChildByName("Panel_Hero"):setVisible(not vivible)
			self.mRootWidget:getChildByName("Panel_Grow"):setVisible( false)
			-- 添加动画
			if not vivible then
				self:addPageBtnAnim(self.mRootWidget:getChildByName("Image_Hero"):getChildByName("Panel_Open_Animation"))
				-- 按钮显示逻辑
				self:btnListShowLogic(self.mRootWidget:getChildByName("Panel_Hero"), panel_hero_btn_list, panel_hero_btn_pos_even, panel_hero_btn_pos_odd, self.mRootWidget:getChildByName("Image_Hero"))
			else
				self:removePageBtnAnim()
			end
			-- 软指引
			self:doHomeGuide()
		end
		registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_Hero"), showHero)

		local function showGrow()
			local vivible = self.mRootWidget:getChildByName("Panel_Grow"):isVisible() 
			self.mRootWidget:getChildByName("Panel_PVP"):setVisible( false)
			self.mRootWidget:getChildByName("Panel_PVE"):setVisible( false)
			self.mRootWidget:getChildByName("Panel_Hero"):setVisible( false)
			self.mRootWidget:getChildByName("Panel_Grow"):setVisible(not vivible)
			-- 添加动画
			if not vivible then
				self:addPageBtnAnim(self.mRootWidget:getChildByName("Image_Grow"):getChildByName("Panel_Open_Animation"))
				-- 按钮显示逻辑
				self:btnListShowLogic(self.mRootWidget:getChildByName("Panel_Grow"), panel_grow_btn_list, panel_grow_btn_pos_even, panel_grow_btn_pos_odd, self.mRootWidget:getChildByName("Image_Grow"))
			else
				self:removePageBtnAnim()
			end

			-- 软指引
			self:doHomeGuide()
		end
		registerWidgetReleaseUpEvent(self.mRootWidget:getChildByName("Button_Grow"), showGrow)
	end
	showPanelLogic()
end

function HomeWindow:upDateTaskMain()
	FightSystem.mTaskMainManager:UpDateTask(self.mRootWidget:getChildByName("Panel_StoryTask"))
end

function HomeWindow:updateFuncOpen()
	-- for k, v in pairs(globaldata.btnMap) do
	-- 	if v then
	-- 		local funcName = k
	-- 		local btnName = v

	-- 		if GUISystem:getFuncOpen(funcName) then
	-- 			self.mRootWidget:getChildByName(btnName):setVisible(true)
	-- 		else
	-- 			self.mRootWidget:getChildByName(btnName):setVisible(false)
	-- 		end
	-- 	end
	-- end
end

function HomeWindow:OnEventPlayerInfo(widget)
	Event.GUISYSTEM_SHOW_PLAYERSETTINGWINDOW.mData = widget
	EventSystem:PushEvent(Event.GUISYSTEM_SHOW_PLAYERSETTINGWINDOW)
end

function HomeWindow:onBroadCastResponse(msgPacket)
	local broadCastTipInfo    = {}
	broadCastTipInfo.priority = msgPacket:GetChar()
	broadCastTipInfo.showText = msgPacket:GetString()
	if broadCastTipInfo.priority == 1  then 
		 deque.pushFront(self.mBroadCastTipsDq,broadCastTipInfo) 
    else 
    	deque.pushBack(self.mBroadCastTipsDq,broadCastTipInfo)
    end
	print(broadCastTipInfo.priority,broadCastTipInfo.showText)
end

local val = false

function HomeWindow:UpDateTopNotice()
	if self.mRootNode == nil or deque.empty(self.mBroadCastTipsDq) or val then return end

	local noticePanel = self.mRootWidget:getChildByName("Panel_TopNotice")	
	local textLabel	  = self.mRootWidget:getChildByName("Panel_Text")

	if noticePanel == nil or textLabel == nil then return end

	local panelPos	  = cc.p(noticePanel:getPosition())
	local panelSize   = noticePanel:getContentSize()

	local textPos	  = cc.p(textLabel:getPosition())
	local textSize	  = textLabel:getContentSize()

	local tip        = deque.popFront(self.mBroadCastTipsDq)
	local richText   = richTextCreate(textLabel,tip.showText,false)
	local richHeight = richText:getTextHeight()
	local richWidth  = richText:getTextWidth()

	local function runBegin()
		noticePanel:setVisible(true)
		textLabel:setVisible(true) 
		noticePanel:runAction(cc.FadeIn:create(1))		
		val = true
	end

	local actBegin = cc.CallFunc:create(runBegin)
	local actMove  =  cc.MoveTo:create((richWidth / config.NoticeWidthFactor + 1) * config.NoticeTimeFactor, cc.p(-richWidth,0))

	local function runFinish()
	   	noticePanel:runAction(cc.FadeOut:create(1))
	   	textLabel:setVisible(false) 
	   	textLabel:setPosition(textPos)
	   	val = false
	end

	local actEnd = cc.CallFunc:create(runFinish)

	textLabel:runAction(cc.Sequence:create(actBegin,actMove,actEnd))

end

function HomeWindow:UpdateLevelReward(curLvRewardInfo)
	local btn        = self.mRootWidget:getChildByName("Button_HomeLevelReward")
	if curLvRewardInfo.idx <= 0 then btn:setVisible(false) return end
	local label      = btn:getChildByName("Label_Level_Stroke")
	local rewardInfo = DB_NewLevelRewards.getDataById(curLvRewardInfo.idx)
	local level      = rewardInfo.level
	local reward     = rewardInfo.rewards
	local widget     = createCommonWidget(reward[1],reward[2],reward[3])

	btn:setTouchEnabled(true) 
	if curLvRewardInfo.state == REWARDSTATE.CANNOTRECEIVE then
		label:setString(string.format("%d级领取",level))
		self.mLvAnim:play("badge_badge_lock", true)
		registerWidgetReleaseUpEvent(btn,function()  end)
	elseif curLvRewardInfo.state == REWARDSTATE.CANRECEIVE then
		label:setString("领取奖励")
		self.mLvAnim:play("badge_badge_open", true)
		registerWidgetReleaseUpEvent(btn,
		function()
			btn:setTouchEnabled(false) 
			self.mLvAnim:play("badge_badge_opening",false,
			function()
				btn:setTouchEnabled(true) 
				globaldata:doGetLevelRewardExRequest() 
			end) 
		end)
	end

	widget:getChildByName("Label_Count_Stroke"):setVisible(false)
	widget:setTouchEnabled(false)
	btn:getChildByName("Panel_ItemIcon"):removeAllChildren()
	btn:getChildByName("Panel_ItemIcon"):setVisible(true)
	btn:getChildByName("Panel_ItemIcon"):addChild(widget)
end

function HomeWindow:OnTaskMainEvent(widget)
	FightSystem.mTaskMainManager:OnTaskEvent()
end

function HomeWindow:PurchaseEvent(widget)
--	Event.GUISYSTEM_SHOW_PURCHASEWINDOW.mData = {widget:getTag()}
--	EventSystem:PushEvent(Event.GUISYSTEM_SHOW_PURCHASEWINDOW)

	local goodsType  = widget:getTag() -- 0:体力 1:耐力 2:点金
	local packet = NetSystem.mNetManager:GetSPacket()
    packet:SetType(PacketTyper._PTYPE_CS_REQUEST_BUYCONSUME_)
--    packet:PushChar(goodsType)
  --  packet:PushInt(1)
    packet:Send()
    GUISystem:showLoading()
end

function HomeWindow:showNoticeInfo()
	-- -- 福利
	-- if 0 == globaldata.noticeList[1] then
	-- 	self.mRootWidget:getChildByName("Image_Bonus"):getChildByName("Image_Notice"):setVisible(true)
	-- else
	-- 	self.mRootWidget:getChildByName("Image_Bonus"):getChildByName("Image_Notice"):setVisible(false)
	-- end

	-- -- 任务
	-- if 0 == globaldata.noticeList[2] then
	-- 	self.mRootWidget:getChildByName("Image_Task"):getChildByName("Image_Notice"):setVisible(true)
	-- else
	-- 	self.mRootWidget:getChildByName("Image_Task"):getChildByName("Image_Notice"):setVisible(false)
	-- end

	-- -- 招募
	-- if 0 == globaldata.noticeList[3] then
	-- 	self.mRootWidget:getChildByName("Image_Get"):getChildByName("Image_Notice"):setVisible(true)
	-- else
	-- 	self.mRootWidget:getChildByName("Image_Get"):getChildByName("Image_Notice"):setVisible(false)
	-- end

	-- -- 检测装备通知
	-- local function checkEquipNotice()
	-- 	local heroCount = globaldata:getBattleHeroCount()
	-- 	for i = 1, heroCount do
	-- 		local heroLevel = globaldata:getHeroInfoByBattleIndex(i, "level")
	-- 		local equipList = globaldata:getHeroInfoByBattleIndex(i, "equipList")
	-- 		for i = 1, #equipList do
	-- 			local equipObj = equipList[i]
	-- 			if equipObj.level < heroLevel then
	-- 				return 0
	-- 			end
	-- 		end
	-- 	end
	-- 	return 1
	-- end
	-- globaldata.noticeList[4] = checkEquipNotice()

	-- -- 装备
	-- if 0 == globaldata.noticeList[5] then
	-- 	self.mRootWidget:getChildByName("Image_Equip"):getChildByName("Image_Notice"):setVisible(true)
	-- else
	-- 	self.mRootWidget:getChildByName("Image_Equip"):getChildByName("Image_Notice"):setVisible(false)
	-- end

	-- -- 英雄
	-- if 0 == globaldata.noticeList[6] then
	-- 	self.mRootWidget:getChildByName("Image_Hero"):getChildByName("Image_Notice"):setVisible(true)
	-- else
	-- 	self.mRootWidget:getChildByName("Image_Hero"):getChildByName("Image_Notice"):setVisible(false)
	-- end

	-- -- 抽屉菜单
	-- if 0 == globaldata.noticeList[8] then
	-- 	self.mRootWidget:getChildByName("Button_Open"):getChildByName("Image_Notice"):setVisible(true)
	-- else
	-- 	self.mRootWidget:getChildByName("Button_Open"):getChildByName("Image_Notice"):setVisible(false)
	-- end

	-- -- 邮箱
	-- if 0 == globaldata.noticeList[9] then
	-- 	self.mRootWidget:getChildByName("Button_Mail"):getChildByName("Image_Notice"):setVisible(true)
	-- else
	-- 	self.mRootWidget:getChildByName("Button_Mail"):getChildByName("Image_Notice"):setVisible(false)
	-- end

	-- -- 邮箱
	-- if 0 == globaldata.noticeList[10] then
	-- 	self.mRootWidget:getChildByName("Button_Social"):getChildByName("Image_Notice"):setVisible(true)
	-- else
	-- 	self.mRootWidget:getChildByName("Button_Social"):getChildByName("Image_Notice"):setVisible(false)
	-- end

	-- -- 检测

end

function HomeWindow:showPveCircleNode()
	if self.mRootWidget then
		local function isSectionLevelLimit(sectionLevel, chapterId, sectionId)
			local sections = nil
			if 1 == sectionLevel then
				sections = DB_MapUIConfigEasy.getArrDataByField("MapUI_ChapterID", chapterId)
			elseif 2 == sectionLevel then
				sections = DB_MapUIConfigNormal.getArrDataByField("MapUI_ChapterID", chapterId)
			end
			local function doFind()
				local chapterInfo = nil
				local sectionInfo = nil
				for i = 1, #sections do
					if sectionId == sections[i].MapUI_SectionID then
						sectionInfo = sections[i]
					end
				end
				
				return sectionInfo
			end
			local sectionInfo = doFind()
			local limitLevel = sectionInfo.MapUI_SectionLevelLimit
			if limitLevel > globaldata.level then
				return false
			end
			return true
		end

		local boolVal = false
		for i = 1, 1 do
			if globaldata.curChapterId[i] and globaldata.curSectionId[i] and not globaldata:isChapterFinished(globaldata.curChapterId[i], globaldata.curSectionId[i], i) then
				if isSectionLevelLimit(i, globaldata.curChapterId[i], globaldata.curSectionId[i]) then
					boolVal = true
				end
			end
		end

		if not self.mCircleNode_fuben then
			self.mCircleNode_fuben = AnimManager:createAnimNode(8075)
			local parentNode = self.mRootWidget:getChildByName("Panel_GuideAnimation")
		    parentNode:addChild(self.mCircleNode_fuben:getRootNode(), 100)
		    self.mCircleNode_fuben:play("home_adventure_new", true)
		end
		if boolVal then
			self.mCircleNode_fuben:setVisible(true)
		else
			self.mCircleNode_fuben:setVisible(false)
		end
	end
end

-- @销毁主城镇场景
-- #进入所有战斗前  #退回登录界面前
function HomeWindow:destroyRootNode()
	if not self.mRootNode then return end
	local function destroySubWindowRootNode()
		HeroInfoWindow:destroyRootNode()
		EquipInfoWindow:destroyRootNode()
		HeroSkillWindow:destroyRootNode()
	end
	destroySubWindowRootNode()
	-- 销毁
	self:doHomeGuideDestroy()
	self.mBottomChatPanel:destroy()
	self.mBottomChatPanel = nil
	self.mRootWidget:removeFromParent(true)
	self.mRootWidget = nil
	self.mRootNode:removeFromParent(true)
	self.mRootNode = nil
	----
	TextureSystem:unloadPlist_HomeScene()
	CommonAnimation:clearAllTexturesAndSpineData()
end

function HomeWindow:Destroy()
	if not self.mIsLoaded then return end
	self.mIsLoaded = false
	------------
	GUIEventManager:unregister("roleBaseInfoChanged", self.updateRoleBaseData)
	GUIEventManager:unregister("playerLevelup", self.updateFuncOpen)
	GUIEventManager:unregister("noticeSendOut", self.showNoticeInfo)
	GUIEventManager:unregister("itemInfoChanged", self.onItemInfoChanged)
	FightSystem:UnloadCityHall()

	if self.mTipSchedulerHandler ~= nil then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.mTipSchedulerHandler)
		self.mTipSchedulerHandler = nil
	end

	self:doHomeGuideDestroy()

	NetSystem.mNetManager:UnregisterPacketHandler(PacketTyper._PTYPE_SC_BROADCAST_TIPS_)
	self.mBroadCastTipsDq = nil
	self.mAnimNode1:destroy()
	self.mAnimNode2:destroy()
	self.mAnimNode3:destroy()
	if self.mCircleNode_fuben then
		self.mCircleNode_fuben:destroy()
		self.mCircleNode_fuben = nil
	end
	self.mHeroPanelList = {}
	val = false

	self.mRootWidget:getChildByName("Panel_PVP"):setVisible(false)
	self.mRootWidget:getChildByName("Panel_PVE"):setVisible(false)
	self.mRootWidget:getChildByName("Panel_Hero"):setVisible(false)
	self.mRootWidget:getChildByName("Panel_Grow"):setVisible(false)
	self:removePageBtnAnim()

	-- 暂不销毁root节点和聊天窗
	self.mRootNode:setVisible(false)
	SpineDataCacheManager:destroyFightSpineList()
	CommonAnimation.clearAllTextures()
end

function HomeWindow:DisableDraw()
	if self.mRootNode then
		self.mRootNode:setVisible(false)
	end
end

function HomeWindow:EnableDraw()
	if self.mRootNode then
		self.mRootNode:setVisible(true)
	end
end

function HomeWindow:onEventHandler(event)
	if event.mAction == Event.WINDOW_SHOW then
		self:Load()
		-- 主城红点刷新
		HomeNoticeInnerImpl:doUpdate()
		-- 红点刷新
		NoticeSystem:doSingleUpdate(self.mName)
		-- 功能控制开启
		PlayerFunctionController:update()
	elseif event.mAction == Event.WINDOW_HIDE then
		self:Destroy()
	elseif event.mAction == Event.WINDOW_ENABLE_DRAW then
		self:EnableDraw()
	elseif event.mAction == Event.WINDOW_DISABLE_DRAW then
		self:DisableDraw()
	end
end

-- 刷新下一级别开放功能
function HomeWindow:updateNextFuncOpenByLevel()
	if self.mRootNode then
		local funcData = DB_PlayerLevelFunction.getDataById(globaldata.level)
		local funcWidget = self.mRootWidget:getChildByName("Panel_Function_Open_Soon")
		if funcData then -- 如果有功能
			funcWidget:setVisible(true)
			-- 图标
			local imgId = funcData.IconID
			local imgName = DB_ResourceList.getDataById(imgId).Res_path1
			funcWidget:getChildByName("Image_Function_Icon"):loadTexture(imgName, 1)

			-- 名字
			local nameId = funcData.NameID
			funcWidget:getChildByName("Label_Function_Name"):setString(getDictionaryText(nameId))

			-- 几级开放
			funcWidget:getChildByName("Label_Function_OpenLevel"):setString(funcData.OpenLevel.."级开放")

			-- 显示详细信息
			local function showDetailInfo()
				local window = GUIWidgetPool:createWidget("NewHome_FunctionLock")
				self.mRootNode:addChild(window, 1000)

				-- 关闭
				local function delWindow()
					window:removeFromParent(true)
					window = nil
				end
				
				window:getChildByName("Panel_Main"):setOpacity(0)

				local act0 = cc.FadeIn:create(0.03)
				local act1 = cc.DelayTime:create(2)
				local act2 = cc.FadeOut:create(0.03)
				local act3 = cc.CallFunc:create(delWindow)
				window:runAction(cc.Sequence:create(act0, act1, act2, act3))

				-- 图标
				window:getChildByName("Image_Icon"):loadTexture(imgName, 1)

				-- 名字
				window:getChildByName("Label_Name"):setString(getDictionaryText(nameId))

				-- 描述
				window:getChildByName("Label_Desc"):setString(getDictionaryText(funcData.FunctionDescID))

				-- 扯蛋
				richTextCreate(window:getChildByName("Panel_FunctionLock"), string.format("#00ff00%d级#开放，快来加入大家吧", funcData.OpenLevel), true)

			end
			registerWidgetReleaseUpEvent(funcWidget, showDetailInfo)

		else -- 如果没有功能
			funcWidget:setVisible(false)
		end
	end
end

function HomeWindow:btnListShowLogic(actNode, btnList, posListEven, posListOdd, posWidget, delta)
	local imgNode = actNode:getChildByName("Image_Bg")
	-- 更改锚点
	if 0.5 == actNode:getAnchorPoint().x and 0.5 == actNode:getAnchorPoint().y then

	else
		setNodeToMidPoint(actNode)
	end

	if delta then
		actNode:setPositionX(posWidget:getPositionX() + delta)
	else
		actNode:setPositionX(posWidget:getPositionX())
	end
	
	imgNode:setScaleX(0.1)

	local new_btn_list = {}
	for i = 1, #btnList do
		if btnList[i][2] <= globaldata.level then -- 功能开放
			table.insert(new_btn_list, btnList[i])
		end
	end

	local function actBegin()
		for i = 1, #btnList do
			self.mRootWidget:getChildByName(btnList[i][1]):setOpacity(0)
		end
	end
	actBegin()

	local function actEnd()
		GUISystem:enableUserInput()
		for i = 1, #new_btn_list do
			self.mRootWidget:getChildByName(new_btn_list[i][1]):runAction(cc.FadeIn:create(0.1))
			if 0 == math.fmod(#new_btn_list, 2) then -- 偶数
				self.mRootWidget:getChildByName(new_btn_list[i][1]):setPosition(posListEven[i])
			else
				self.mRootWidget:getChildByName(new_btn_list[i][1]):setPosition(posListOdd[i])
			end
		end

		if ArenaGuideOne:canGuide() then
			local guideBtn = self.mRootWidget:getChildByName("Button_Arena")
			local size = guideBtn:getContentSize()
			local pos = guideBtn:getWorldPosition()
			pos.x = pos.x - size.width/2
			pos.y = pos.y - size.height/2
			local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
			ArenaGuideOne:step(3, touchRect)
		end

		if SkillGuideOne:canGuide() then
			local guideBtn = self.mRootWidget:getChildByName("Image_Skill")
			local size = guideBtn:getContentSize()
			local pos = guideBtn:getWorldPosition()
			pos.x = pos.x - size.width/2
			pos.y = pos.y - size.height/2
			local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
			SkillGuideOne:step(3, touchRect)
		end

		if HeroGuideOneEx:canGuide() then
			local guideBtn = self.mRootWidget:getChildByName("Button_HeroList")
			local size = guideBtn:getContentSize()
			local pos = guideBtn:getWorldPosition()
			pos.x = pos.x - size.width/2
			pos.y = pos.y - size.height/2
			local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
			HeroGuideOneEx:step(3, touchRect)
		end

		if HeroGuideTwo:canGuide() then
			local guideBtn = self.mRootWidget:getChildByName("Button_HeroList")
			local size = guideBtn:getContentSize()
			local pos = guideBtn:getWorldPosition()
			pos.x = pos.x - size.width/2
			pos.y = pos.y - size.height/2
			local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
			HeroGuideTwo:step(2, touchRect)
		end

		if EquipGuideOne:canGuide() then
			local guideBtn = self.mRootWidget:getChildByName("Button_Equip")
			local size = guideBtn:getContentSize()
			local pos = guideBtn:getWorldPosition()
			pos.x = pos.x - size.width/2
			pos.y = pos.y - size.height/2
			local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
			EquipGuideOne:step(3, touchRect)
		end

		if HomeGuideOne:canGuide() then
			local guideBtn = self.mRootWidget:getChildByName("Image_PlayerTitle")
			local size = guideBtn:getContentSize()
			local pos = guideBtn:getWorldPosition()
			pos.x = pos.x - size.width/2
			pos.y = pos.y - size.height/2
			local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
			HomeGuideOne:step(3, touchRect)
		end

	end
	local act0 = cc.ScaleTo:create(0.1, 1*#new_btn_list/#btnList, 1)
	local act1 = cc.CallFunc:create(actEnd)
	imgNode:runAction(cc.Sequence:create(act0, act1))
	GUISystem:disableUserInput()
end

function HomeWindow:cleanBtnInfo()
	if self.mRootWidget then
		self.mRootWidget:getChildByName("Panel_PVP"):setVisible(false)
		self.mRootWidget:getChildByName("Panel_PVE"):setVisible( false)
		self.mRootWidget:getChildByName("Panel_Hero"):setVisible( false)
		self.mRootWidget:getChildByName("Panel_Grow"):setVisible( false)
		self:removePageBtnAnim()
	end
end

return HomeWindow