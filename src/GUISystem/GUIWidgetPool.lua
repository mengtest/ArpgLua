-- Name: 	GUIWidgetPool.lua
-- Func：	负责点击进入游戏时，加载各种资源
-- Author:	WangShengdong
-- Data:	14-12-16


local jsonFiles = 
{
	-- "ActivitiesList.csb",
	-- "ActivitiesMain.csb",
	-- "Arena.csb",
	-- "Arena_AttackTeam.csb",
	-- "Arena_DefendTeam.csb",
	-- "Arena_Recard.csb",
	-- "ArenaPlayer.csb",
	-- "Bagpack.csb",
	-- "BattleResult_TurnCard.csb",
	-- "CGpicture.csb",
	-- "CGTalkText.csb",
	-- "ChatAudioElement.csb",
	-- "ChatBar.csb",
	-- "ChatElement1.csb",
	-- "ChatElement2.csb",
	-- "ChatElement3.csb",
	-- "Combo.csb",
	-- "CommonTips.csb",
	-- "DateEvent.csb",
	-- "DateHero.csb",
	-- "DateHeroLevel.csb",
	-- "DatePlayWindow.csb",
	-- "DateWindow.csb",
	-- "Equip_Main.csb",
	-- "Equip_Qianghua.csb",
	-- "Equip_Xiangqian.csb",
	-- "Fight.csb",
	-- "FightArena.csb",
	-- "FightArenaHead.csb",
	-- "FightHero.csb",
	-- "FightPause.csb",
	-- "FriendsMain.csb",
	-- "FriendsPlayer.csb",
	-- "FriendsPlayerWindow.csb",
	-- "FurnitBag.csb",
	-- "GoldenFinger.csb",
	-- "GoldenItem.csb",
	-- "HeroChangeWidget.csb",
	-- "HeroCheck.csb",
	-- "HeroEquipInfo.csb",
	-- "HeroEquipReplace.csb",
	"HeroIcon.csb",
	-- "HeroJinengBeidong.csb",
	-- "HeroJinengZhudong.csb",
	-- "HeroMain.csb",
	-- "HeroRelation.csb",
	-- "HeroShuxingLess.csb",
	-- "HeroShuxingMore.csb",
	-- "HeroWidget.csb",
	-- "HomeShop.csb",
--	"ItemWidget.csb",
	"ChatElement1.csb",
	"ChatElement2.csb",
	"ChatElement3.csb",
	"PlayerHead.csb"
	-- "KOF.csb",
	-- "LevelupWindow1.csb",
	-- "LevelupWindow2.csb",
	-- "Loading_1.csb",
	-- "LoginWindow_1.csb",
	-- "Lose.csb",
	-- "MailLetter.csb",
	-- "MailWindow.csb",
	-- "MessageBox_1.csb",
	-- "MessageBox_2.csb",
	-- "MessageBox_3.csb",
	-- "MessageBox_4.csb",
	-- "MessageBox_4_Item.csb",
	-- "MessageBox_5.csb",
	-- "MessageBox_6.csb",
	-- "MessageBox_7.csb",
	-- "Monsterblood.csb",
	-- "NewCreateRole.csb",
	-- "NewHeroChange.csb",
	-- "NewHeroSelect.csb",
	-- "NewHomeWindow.csb",
	-- "NewLottery.csb",
	-- "NewLotteryResult1.csb",
	-- "NewLotteryResult10.csb",
	-- "Niubility.csb",
	-- "Playeraccount.csb",
	-- "Playeraccount_lead.csb",
	-- "PlayerHead.csb",
	-- "PlayerInfo.csb",
	-- "PoseText.csb",
	-- "PurchaseWindow.csb",
	-- "PVE.csb",
	-- "PVE_SaodangContent.csb",
	-- "PVE_SaodangReward.csb",
	-- "PVE_Section.csb",
	-- "RankingList_Main.csb",
	-- "RankingList_Page1.csb",
	-- "RankingList_Page2.csb",
	-- "RankingList_Player.csb",
	-- "RoleInfoPanel.csb",
	-- "RoleInfoPanel2.csb",
	-- "SelectServer.csb",
	-- "ServerItem.csb",
	-- "ShopItem.csb",
	-- "ShopMain.csb",
	-- "Task.csb",
	-- "Task_Cell.csb",
	-- "Tower.csb",
	-- "Tower_SaodangContent.csb",
	-- "Tower_SaodangReward.csb",
	-- "Tower_SectionInfo.csb",
	-- "Win.csb",
	-- "Work.csb",
	-- "WorkerItem.csb",
	-- "WorkHeroData.csb",
	-- "WorkHeroList.csb",
	-- "WorkPlace.csb",
}


GUIWidgetPool = 
{
	mWidgets = {},	
}


local scheduler = nil
local mSchedulerHandler = nil

-- 操作表
local doLoadFuncTbl = 
{
	function()
		TextureSystem:LoadPublicTexture()
	end,
	function()
		DBSystem:init2_1()
	end,
	function()
		DBSystem:init2_2()
	end,
	function() 
		DBSystem:init2_3()
	end,
	function() 
		DBSystem:init2_4()
	end,
	function()
		DBSystem:init2_5()
	end,
	function() 
		DBSystem:init2_6()
	end,
	function() 
		GUISystem:init2()
	end,
	function()
		TextureSystem:init2()
	end,
	function() 
		require "GUISystem/PlayerFunctionController"
		PlayerFunctionController:init()
		PveEntryWindow_initData()
	end,
	function() 
		NoticeSystem:init()
	end,
	function() 
		FightSystem:init2()
	end,
}

function GUIWidgetPool:init()
	scheduler = cc.Director:getInstance():getScheduler()
	local i = 1
	local processCounter = 0
	local mLoadedPercent = 0
	-- 载入布局资源
	local function loadLayoutResource()
		local deltaPercent = math.floor((i - 1) / #jsonFiles * 30)
		if processCounter == deltaPercent then
			if i > #jsonFiles then -- 布局资源载入完毕，通知结束载入所有资源
				GUIEventManager:pushEvent("loadingResource", 100, string.format("正在载入布局资源...100%%"))
				-- 展现100%一段时间
				local function finishLoading()
					GUIEventManager:pushEvent("finishLoadingRes")
				end
				nextTick_frameCount(finishLoading, 0.5)
				scheduler:unscheduleScriptEntry(mSchedulerHandler)
				mSchedulerHandler = nil
				processCounter = 0
				i = 1
			return end
			local ret = string.sub(jsonFiles[i], 1, string.len(jsonFiles[i]) - string.len(".csb"))
			local _fullPath = string.format("res/layout/iphone5/%s", jsonFiles[i])
			cclog("loadLayoutResource=" .. _fullPath)
			self.mWidgets[ret] = ccs.GUIReader:getInstance():widgetFromBinaryFile(_fullPath)
			-- 驻留内存中
			self.mWidgets[ret]:retain()
			i = i + 1
		end
		GUIEventManager:pushEvent("loadingResource", mLoadedPercent, string.format("正在载入布局资源...%d%%", mLoadedPercent))
		processCounter = processCounter + 1
		mLoadedPercent = mLoadedPercent + 1
	end
	-- 加载与初始化主要资源
	local function loadAndInitMain()
		local deltaPercent = math.floor((i - 1) / #doLoadFuncTbl * 70)
		-- 加载资源
		if processCounter == mLoadedPercent + deltaPercent then
			if i <= #doLoadFuncTbl then
				doLoadFuncTbl[i]()
			else
				return
			end
			i = i + 1
		end
		-- 显示进度
		if i == #doLoadFuncTbl + 1 then
			scheduler:unscheduleScriptEntry(mSchedulerHandler)
			mSchedulerHandler = nextTick_eachSecond(loadLayoutResource, 0)
			mLoadedPercent = processCounter
			processCounter = 0
			i = 1
			return
		else
			-- 通知修改当前进度条
			local per = processCounter
			GUIEventManager:pushEvent("loadingResource", per, string.format("正在载入数据表...%d%%",per))
		end
		processCounter = processCounter + 1
	end
	--- 如果定时器已启动，先关闭
	if mSchedulerHandler then
	   scheduler:unscheduleScriptEntry(mSchedulerHandler)
	end
	--- 开启定时器，加载资源
	mSchedulerHandler = nextTick_eachSecond(loadAndInitMain, 0)
end

function GUIWidgetPool:destroy()
	for k, v in pairs(self.mWidgets) do
		v:release()
		v = nil
	end
	self.mWidgets = {}
end

function GUIWidgetPool:preLoadWidget(name, value)
	if value then 	-- 加载操作
		if self.mWidgets[name] then
			return
		end

		if "ItemWidget" == name then
			self.mWidgets[name] = ccui.Widget:create()
			local oldWidget = ccs.GUIReader:getInstance():widgetFromBinaryFile(string.format("res/layout/iphone5/%s.csb", name))
			self.mWidgets[name]:setContentSize(oldWidget:getContentSize())
			self.mWidgets[name]:setAnchorPoint(cc.p(0, 0))
			self.mWidgets[name]:setTouchEnabled(true)
			local children = oldWidget:getChildren()
			for i = 1, #children do
				self.mWidgets[name]:addChild(children[i]:clone())
			end

			-- 添加特效层
			local Panel_Animation = ccui.Widget:create()
			Panel_Animation:setName("Panel_Animation")
			self.mWidgets[name]:addChild(Panel_Animation, 35)
			Panel_Animation:setPosition(cc.p(40, 40))

			self.mWidgets[name]:retain()
			return
		end

		self.mWidgets[name] = ccs.GUIReader:getInstance():widgetFromBinaryFile(string.format("res/layout/iphone5/%s.csb", name))
		self.mWidgets[name]:retain()
	else			-- 卸载操作
		self:destroyWidget(name)
	end
end

function GUIWidgetPool:createWidget(name,filetype)
	-- 先从缓存池里找
	if self.mWidgets[name] then
		return self.mWidgets[name]:clone()
	end
	local rootWidget = nil
	if filetype then
		rootWidget = ccs.GUIReader:getInstance():widgetFromJsonFile(string.format("res/layout/iphone5/%s.json", name))
	else
		rootWidget = ccs.GUIReader:getInstance():widgetFromBinaryFile(string.format("res/layout/iphone5/%s.csb", name))
	end

	if rootWidget then
		return rootWidget
	end
	return nil
end

function GUIWidgetPool:destroyWidget(name)
	if self.mWidgets[name] then
		self.mWidgets[name]:release()
		self.mWidgets[name] = nil
	end
end