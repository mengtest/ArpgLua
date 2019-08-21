-- Name: GUISystem
-- Func: GUI系统
-- Author: Johny


require "GUISystem/ColorTable"
require "GUISystem/Widget/NiubilityWidget"
require "GUISystem/Widget/TurnCardWidget"
require "GUISystem/Widget/HeroExpWidget"
require "GUISystem/Widget/HeroleadExpWidget"
require "GUISystem/Widget/CommonWidgetCreater"
require "GUISystem/Widget/CommonAnimation"
require "GUISystem/Window/MessageBox"
require "GUISystem/Widget/TableViewEx"
require "GUISystem/Widget/PageViewEx"
require "GUISystem/Widget/FurnitObject"
require "GUISystem/LabelManager"
require "GUISystem/Widget/PublicShowRole"
require "GUISystem/VideoManager"





-----------------------------------Window层级------------------------------------------
GUISYS_ZORDER_GUIWINDOW        =    1000
GUISYS_ZORDER_PKNOTICE         =    1500
GUISYS_ZORDER_LOADINGWINDOW    =    2000
GUISYS_ZORDER_MESSAGEBOXWINDOW =    2001
---------------------------------------------------------------------------------------



GUISystem = {}
GUISystem.mType = "GUISYSTEM"
GUISystem.RootNode = nil
GUISystem.Windows = {}
-- GUISystem.mTipsWidget = nil
GUISystem.maskLayer = nil	-- 屏蔽用户输入层
GUISystem.mHomeNextwindow = nil

GUISystem.mLoadingLayer = nil 	-- Loading层

GUISystem.mFurnitManager	=	nil	-- 家具管理器

GUISystem.mCombatChangeWidget		=	nil -- 战力变化控件
GUISystem.mCombatChangeScheduler	=	nil -- 战力变化定时器
GUISystem.mCombatAnimNode			=	nil -- 战力变化特效

local function _createScene()
	local director = cc.Director:getInstance()
	local rootNode = cc.Scene:create()

	if director:getRunningScene() ~= nil then
		director:replaceScene(rootNode)
	else
		director:runWithScene(rootNode)
	end

	GUISystem.RootNode = rootNode
end
--------------------------------------------------------------

function GUISystem:Init()
    cclog("=====GUISystem:Init=====1")
    ------
    self.mShowedWindows = {}
    _createScene()
	-- 载入第一批window，游戏启动时
	self:RegisterWindow(require("GUISystem/Window/AndroidLaunchWindow"))
	self:RegisterWindow(require("GUISystem/Window/LoadingWindow"))
	self:RegisterWindow(require("GUISystem/Window/LoginWindow"))
	self:RegisterWindow(require("GUISystem/Window/ServerSelWindow"))
	self:RegisterWindow(require("GUISystem/Window/HomeWindow"))
	---
	require "GUISystem/PKHelper"
	require "GUISystem/AnimManager"

	cclog("=====GUISystem:Init=====2")
end

-- 第二批载入，在GUIWidgePool中载入
function GUISystem:init2()
	--
	self:RegisterWindow(require("GUISystem/Window/FightWindow"))
	self:RegisterWindow(require("GUISystem/Window/UnionHallWindow"))
	self:RegisterWindow(require("GUISystem/Window/PveEntryWindow"))
	self:RegisterWindow(require("GUISystem/Window/SectionEntryWindow"))
	self:RegisterWindow(require("GUISystem/Window/BagpackWindow"))
	self:RegisterWindow(require("GUISystem/Window/SaodangRewardWindow"))
	self:RegisterWindow(require("GUISystem/Window/BattleResult_WinWindow"))
	self:RegisterWindow(require("GUISystem/Window/BattleResult_LoseWindow"))
	self:RegisterWindow(require("GUISystem/Window/RoleselWindow"))
	self:RegisterWindow(require("GUISystem/Window/HeroInfoWindow"))
	self:RegisterWindow(require("GUISystem/Window/LotteryWindow"))
	self:RegisterWindow(require("GUISystem/Window/LotteryResultTen"))
	self:RegisterWindow(require("GUISystem/Window/LotteryResultOne"))
	self:RegisterWindow(require("GUISystem/Window/SelectRoleWindow"))
	self:RegisterWindow(require("GUISystem/Window/EquipInfoWindow"))
	self:RegisterWindow(require("GUISystem/Window/ExchangeHeroWindow"))
	self:RegisterWindow(require("GUISystem/Window/PurchaseWindow"))
	self:RegisterWindow(require("GUISystem/Window/ShopWindow"))
	self:RegisterWindow(require("GUISystem/Window/ArenaWindow"))
	self:RegisterWindow(require("GUISystem/Window/FightPauseWindow"))
	self:RegisterWindow(require("GUISystem/Window/TowerWindow"))
	self:RegisterWindow(require("GUISystem/Window/MailWindow"))
	--self:RegisterWindow(require("GUISystem/Window/WorkWindow"))
	--self:RegisterWindow(require("GUISystem/Window/DateWindow"))
	--self:RegisterWindow(require("GUISystem/Window/DateSelectWindow"))
	--self:RegisterWindow(require("GUISystem/Window/DatePlayWindow"))
	--self:RegisterWindow(require("GUISystem/Window/DateHeroWindow"))
	--self:RegisterWindow(require("GUISystem/Window/AllHeroWindow"))
	--self:RegisterWindow(require("GUISystem/Window/ActivityWindow"))
	--self:RegisterWindow(require("GUISystem/Window/WorkPositionWindow"))
	--self:RegisterWindow(require("GUISystem/Window/PartyWindow"))
	self:RegisterWindow(require("GUISystem/Window/GoldenFingerWindow"))
	self:RegisterWindow(require("GUISystem/Window/RankingWindow"))
	self:RegisterWindow(require("GUISystem/Window/FriendWindow"))
	self:RegisterWindow(require("GUISystem/Window/TaskWindow"))
	self:RegisterWindow(require("GUISystem/Window/HeroChangeWindow"))
	self:RegisterWindow(require("GUISystem/Window/HomeShopWindow"))
	self:RegisterWindow(require("GUISystem/Window/DailyRewardWindow"))
	self:RegisterWindow(require("GUISystem/Window/PlayerSettingWindow"))
	--self:RegisterWindow(require("GUISystem/Window/Game2048Window"))
	self:RegisterWindow(require("GUISystem/Window/WealthWindow"))
	self:RegisterWindow(require("GUISystem/Window/FuckWindow"))
	self:RegisterWindow(require("GUISystem/Window/LadderWindow"))
	self:RegisterWindow(require("GUISystem/Window/LadderLoadingWindow"))
	self:RegisterWindow(require("GUISystem/Window/CardGameWindow"))
	self:RegisterWindow(require("GUISystem/Window/LadderResultWindow"))
	self:RegisterWindow(require("GUISystem/Window/BasketBallWindow"))
	self:RegisterWindow(require("GUISystem/Window/RoundGameWindow"))	
	self:RegisterWindow(require("GUISystem/Window/IAPWindow"))
	self:RegisterWindow(require("GUISystem/Window/BlackMarketWindow"))
	self:RegisterWindow(require("GUISystem/Window/HeroGuessWindow"))
	self:RegisterWindow(require("GUISystem/Window/TechnologyWindow"))
	self:RegisterWindow(require("GUISystem/Window/GangWarsWindow"))
	self:RegisterWindow(require("GUISystem/Window/PokerWindow"))
	self:RegisterWindow(require("GUISystem/Window/PartyJoinWindow"))
	self:RegisterWindow(require("GUISystem/Window/PartyMainWindow"))
	self:RegisterWindow(require("GUISystem/Window/PartyBuildWindow"))
	self:RegisterWindow(require("GUISystem/Window/PartySkillWindow"))
	self:RegisterWindow(require("GUISystem/Window/PartyHelloWindow"))
	self:RegisterWindow(require("GUISystem/Window/ChangeHeroIconWindow"))
	self:RegisterWindow(require("GUISystem/Window/WorldBossWindow"))
	self:RegisterWindow(require("GUISystem/Window/WorldBossResultWindow"))
	self:RegisterWindow(require("GUISystem/Window/HeroBeautifyWindow"))
	self:RegisterWindow(require("GUISystem/Window/TowerExWindow"))
	self:RegisterWindow(require("GUISystem/Window/HeroTitleWindow"))
	self:RegisterWindow(require("GUISystem/Window/HorseAndGunWindow"))
	self:RegisterWindow(require("GUISystem/Window/HeroSkillWindow"))
	self:RegisterWindow(require("GUISystem/Window/BadgeWindow"))
end

-- 禁止多点触摸
function GUISystem:setMultiTouchDisabled()
	local director = cc.Director:getInstance()
	-- 点击
	local function onTouchBegan()
		cclog("GUISystem:setMultiTouchDisabled()===Began")
		-- GUISystem:disableUserInput()
	end
	director:registerAllUIWidgetTouchBeganCallFunc(onTouchBegan)

	-- 取消
	local function onTouchCancelled()
		cclog("GUISystem:setMultiTouchDisabled()===Canceled")
		-- GUISystem:enableUserInput()
	end
	director:registerAllUIWidgetTouchCancelledCallFunc(onTouchCancelled)

	-- 结束
	local function onTouchEnded()
		cclog("GUISystem:setMultiTouchDisabled()===Ended")
		-- GUISystem:enableUserInput()sh
	end
	director:registerAllUIWidgetTouchEndedCallFunc(onTouchEnded)
end

-- 允许许多点触摸
function GUISystem:setMultiTouchEnabled()
	local director = cc.Director:getInstance()
	director:registerAllUIWidgetTouchBeganCallFunc(nil)
	director:registerAllUIWidgetTouchCancelledCallFunc(nil)
	director:registerAllUIWidgetTouchEndedCallFunc(nil)
end

local _userInputCounter  = 0
function GUISystem:Tick()
	-- 检测每过60帧强制开启用户输入，防止界面卡住不能操作
	if _userInputCounter == 60 then
	   _userInputCounter = 0
	   self:enableUserInput2()
	end
	_userInputCounter = _userInputCounter + 1
end

function GUISystem:Release()
--	self.mTipsWidget:destroy()
	GUIWidgetPool:destroy()
	--
	for k,v in ipairs(self.Windows) do
		v:Release()
	end

	_G["GUISystem"] = nil
 	package.loaded["GUISystem"] = nil
 	package.loaded["GUISystem/GUISystem"] = nil
end


function GUISystem:GetRootNode()
	return self.RootNode
end

function GUISystem:RegisterWindow(window)
	self.Windows[window.mName] = window
end

function GUISystem:GetWindowByName(_name)
	return self.Windows[_name]
end

-- 查看一个窗口是否显示
function GUISystem:IsWindowShowed(_name)
	for k,_winName in pairs(self.mShowedWindows) do
		if _winName == _name then
		   return true
		end
	end

	return false
end

-- 隐藏所有窗口
function GUISystem:HideAllWindow()
	for k,_name in pairs(self.mShowedWindows) do
		if _name ~= "HomeWindow" then
			local _window = self:GetWindowByName(_name)
			_window:Destroy()
		end
	end
	GUISystem:hideLoading()
	GUISystem:hideLoadingForPvp()
	GUISystem:enableUserInput()
	GUISystem:CanCelCountDownlayout()
	GUISystem:CanCelFightBeginlayout()
	local _window = self:GetWindowByName("HomeWindow")
	_window:Destroy()
	self.mShowedWindows = {}
end

-- 返回登录界面
function GUISystem:BackToLoginWindow()
	self.misLoginingBySDK = false
	self:doCleanup()
	self:doPlayerCombatChangeDestroy()
	globaldata:resetAllData()
	GuideSystem:reloadGuideAllLuaFile()
	if FightSystem.mTaskMainManager then
		FightSystem.mTaskMainManager:Destroy()
	end
	self:HideAllWindow()
	HomeWindow:destroyRootNode()
	self:GetRootNode():removeAllChildren()
	BottomChatPanel:clearAllChatDataList()
	---
	EventSystem:PushEvent(Event.GUISYSTEM_SHOW_LOGINWINDOW)
end

------------------------回调--------------------------------
--@接收事件
function GUISystem:onEventHandler(event, func)
	local window = self.Windows[event.mSubType]
	if window ~= nil then
		local _canpushEvent = true --是否可以传该事件
		if event.mAction == Event.WINDOW_HIDE then
		    _canpushEvent = self:onAnyWindowDestroyed(window.mName)
		elseif event.mAction == Event.WINDOW_SHOW then
			_canpushEvent = self:onAnyWindowShowed(window.mName)
		end
		if _canpushEvent then
			window:onEventHandler(event, func)
		end
		event.mData = nil
	else
		cclog("======GUISystem:onEventHandler===ERROR: The Window is not Existed. Window Type is: " .. event.mSubType)
	end
end

--	@系统间对话的函数
--  return：true：该window加载过  false：该window未加载过
function GUISystem:onAnyWindowDestroyed(_windowName)
	for i = 1, #self.mShowedWindows do
		if self.mShowedWindows[i] == _windowName then
		   table.remove(self.mShowedWindows, i)
		return true end
	end

	return false
end

--  @有window需要显示
--  return：true：该window未加载过  false：该window已加载过
function GUISystem:onAnyWindowShowed(_windowName)
	for i = 1, #self.mShowedWindows do
		if self.mShowedWindows[i] == _windowName then
		return false end
	end
	-----
	table.insert(self.mShowedWindows, _windowName)
	return true
end

----------------------------------------------------------------------------------------------
-- 获取功能是否开启
function GUISystem:getFuncOpen(funcName)
	return globaldata.funcMap[funcName]
end

-- 设置功能是否开启
function GUISystem:setFuncOpen(funcName, opended)
	globaldata.funcMap[funcName] = opended
end

GUISystem.handlerMap = 
{
	-- 约会
	yuehui 		= function()
					local function onRequestEnterFuckWindow(msgPacket) -- 进入约会回包
						local fuckInfo = {}

						fuckInfo.level = msgPacket:GetInt() -- 玩家好感度等级
						fuckInfo.exp = msgPacket:GetInt() -- 玩家好感度经验值
						fuckInfo.maxExp = msgPacket:GetInt() -- 玩家好感度最大经验值
						fuckInfo.heroCount = msgPacket:GetInt() -- 开放英雄数量
						fuckInfo.heroList = {} -- 英雄列表

						for i = 1, fuckInfo.heroCount do
							fuckInfo.heroList[i] = {}
							fuckInfo.heroList[i].heroId = msgPacket:GetInt() -- 英雄id

							fuckInfo.heroList[i].gameState = {}
							local gameCnt = msgPacket:GetInt()
							for j = 1, gameCnt do
								fuckInfo.heroList[i].gameState[j] = msgPacket:GetInt()
							end

							fuckInfo.heroList[i].fuckLevel = msgPacket:GetInt() -- 约会等级
							fuckInfo.heroList[i].fuckExp = msgPacket:GetInt() -- 约会经验值
							fuckInfo.heroList[i].fuckMaxExp = msgPacket:GetInt() -- 约会最大经验值
							fuckInfo.heroList[i].rewardCount = msgPacket:GetUShort() -- 奖励数量
							fuckInfo.heroList[i].rewardList = {}
							for j = 1, fuckInfo.heroList[i].rewardCount do
								fuckInfo.heroList[i].rewardList[j] = {}
								fuckInfo.heroList[i].rewardList[j].itemType = msgPacket:GetInt()
								fuckInfo.heroList[i].rewardList[j].itemId = msgPacket:GetInt()
								fuckInfo.heroList[i].rewardList[j].itemCount = msgPacket:GetInt()
							end
						end

						fuckInfo.mLeftGiftCount = msgPacket:GetInt()
						fuckInfo.mTotalGiftCount = msgPacket:GetInt()

						fuckInfo.game1CurCnt = msgPacket:GetInt()
						fuckInfo.game1TotalCnt = msgPacket:GetInt()

						fuckInfo.game2CurCnt = msgPacket:GetInt()
						fuckInfo.game2TotalCnt = msgPacket:GetInt()

						fuckInfo.game3CurCnt = msgPacket:GetInt()
						fuckInfo.game3TotalCnt = msgPacket:GetInt()

						fuckInfo.bubleCount = msgPacket:GetInt() -- 泡泡数量
						fuckInfo.bubleList = {}
						for i = 1, fuckInfo.bubleCount do
							fuckInfo.bubleList[i] = {}
							fuckInfo.bubleList[i].heroId = msgPacket:GetInt() -- 泡泡的英雄ID
							fuckInfo.bubleList[i].moodIndex = msgPacket:GetInt()
							
						end					
						Event.GUISYSTEM_SHOW_FUCKWINDOW.mData = fuckInfo -- 约会信息
						-- EventSystem:PushEvent(Event.GUISYSTEM_HIDE_HOMEWINDOW)
						EventSystem:PushEvent(Event.GUISYSTEM_SHOW_FUCKWINDOW)
						GUISystem:hideLoading()
					end
					NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_REQUEST_FUCK_INFO_, onRequestEnterFuckWindow)

					local function requestEnterFuckWindow() -- 请求进入约会
						local packet = NetSystem.mNetManager:GetSPacket()
				    	packet:SetType(PacketTyper._PTYPE_CS_REQUEST_FUCK_INFO_)
				    	packet:Send()
				    	GUISystem:showLoading()
					end
					requestEnterFuckWindow()
				end,
	-- PVE
	pve  		= function(sectionType, id)
					-- 默认为空
					Event.GUISYSTEM_SHOW_PVEENTRYWINDOW.mData = nil
					-- 有参数再判断
					if sectionType and id then
						-- 副本信息
						local sectionInfo = nil
						if 1 == sectionType then
							sectionInfo = DB_MapUIConfigEasy.getDataById(id)
						elseif 2 == sectionType then
							sectionInfo = DB_MapUIConfigNormal.getDataById(id)
						end
						-- 选章节
						local chapterIndex = sectionInfo.MapUI_ChapterID
						-- 选关卡
						local sectionIndex = sectionInfo.MapUI_SectionID
						

						if globaldata:isSectionOpened(chapterIndex, sectionIndex, sectionType) then
							Event.GUISYSTEM_SHOW_PVEENTRYWINDOW.mData = {}
							Event.GUISYSTEM_SHOW_PVEENTRYWINDOW.mData[1] = sectionType    --简单、困难、团队
							Event.GUISYSTEM_SHOW_PVEENTRYWINDOW.mData[2] = id      		  --副本ID
						end
						if not globaldata:isSectionOpened(chapterIndex, sectionIndex, sectionType) then
							MessageBox:showMessageBox1("当前关卡未开启")
							return
						end
					end

					if sectionType and not id then
						Event.GUISYSTEM_SHOW_PVEENTRYWINDOW.mData = {}
						Event.GUISYSTEM_SHOW_PVEENTRYWINDOW.mData[1] = sectionType    --简单、困难、团队

						if 2 == sectionType then
						--	local sectionInfo = DB_MapUIConfig.getDataById(3)
						--	if not globaldata:isSectionOpened(sectionInfo.MapUI_ChapterID, sectionInfo.MapUI_SectionID, sectionType) then
							if not globaldata:isSectionOpened(1, 1, 2) then
							--	print("关卡属性:", sectionInfo.MapUI_ChapterID, sectionInfo.MapUI_SectionID, sectionType)
								MessageBox:showMessageBox1("当前关卡未开启")
								return
							end
						end
					end

					EventSystem:PushEvent(Event.GUISYSTEM_SHOW_PVEENTRYWINDOW)
				end,	
	-- 商城
	shangcheng  = function(type)	
					local function onRequestEnterShop(msgPacket)
						globaldata:updateGoodsInfoFromServerPacket(msgPacket)
						Event.GUISYSTEM_SHOW_SHOPWINDOW.mData = type
						EventSystem:PushEvent(Event.GUISYSTEM_SHOW_SHOPWINDOW)
						GUISystem:hideLoading()
					end

					NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_REQUEST_GOODSINFO_, onRequestEnterShop)

					local function requestEnterShop()
						local packet = NetSystem.mNetManager:GetSPacket()
				    	packet:SetType(PacketTyper._PTYPE_CS_REQUEST_GOODSINFO_)
				    	packet:PushChar(type)
				    	packet:Send()
				    	GUISystem:showLoading()
					end
					requestEnterShop()
				end,	
	-- 打工
	dagong 		= function()
					EventSystem:PushEvent(Event.GUISYSTEM_SHOW_WORKWINDOW)
				end,
	-- 装备
	equip 		= function(typ)
					Event.GUISYSTEM_SHOW_EQUIPINFOWINDOW.mData = {}
					Event.GUISYSTEM_SHOW_EQUIPINFOWINDOW.mData[1] = typ
					EventSystem:PushEvent(Event.GUISYSTEM_SHOW_EQUIPINFOWINDOW)
				end, 
	-- 竞技场
	arena 		= function(func)
					-- 打开竞技场主界面
					local function onRequestEnterArena(msgPacket)
						local arenaInfo = {}
						arenaInfo.rank = msgPacket:GetInt()
						arenaInfo.fightPower = msgPacket:GetInt()
						arenaInfo.score = msgPacket:GetInt()
						arenaInfo.totalScore = msgPacket:GetInt()
						arenaInfo.leftTimes = msgPacket:GetInt()
						arenaInfo.maxTimes = msgPacket:GetInt()
						arenaInfo.rewardSecondsLeft	= msgPacket:GetInt()
						
						-- 接收进攻阵容信息
						globaldata:updateAttackFormationInfoFromServer(msgPacket)

						-- 接收防守阵容信息
						globaldata:updateDefendFormationInfoFromServer(msgPacket)

						-- 可挑战的
						arenaInfo.playerCount = msgPacket:GetUShort()
						arenaInfo.canAttackPlayer = {}
						for i = 1, arenaInfo.playerCount do
							local player = {}
							player.playerId = msgPacket:GetString()
							player.playerName = msgPacket:GetString()
							player.playerGonghuiName = msgPacket:GetString()
							player.playerIconId = msgPacket:GetInt()
							player.playerFrameId = msgPacket:GetInt()
							player.playerLevel = msgPacket:GetInt()
							player.playerRank = msgPacket:GetInt()
							player.playerScore = msgPacket:GetInt()
							player.playerZhanli = msgPacket:GetInt()
							player.heroCount = msgPacket:GetUShort()
							player.hero = {}

							for j = 1, player.heroCount do
								player.hero[j] = {}
								player.hero[j].heroId = msgPacket:GetInt() 
								player.hero[j].advanceLevel = msgPacket:GetChar()
								player.hero[j].quality = msgPacket:GetChar()
								player.hero[j].level = msgPacket:GetInt() 
							end
							arenaInfo.canAttackPlayer[i] = player
						end

						if func then
							func()
						end
						Event.GUISYSTEM_SHOW_ARENAWINDOW.mData = arenaInfo
						EventSystem:PushEvent(Event.GUISYSTEM_SHOW_ARENAWINDOW)
						GUISystem:hideLoading()
					end

					NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_REQUEST_ENTER_ARENA_, onRequestEnterArena)

					local function requestEnterArena()
						local packet = NetSystem.mNetManager:GetSPacket()
			    		packet:SetType(PacketTyper._PTYPE_CS_REQUEST_ENTER_ARENA_)
			    		packet:Send()
			    		GUISystem:showLoading()
					end

					if globaldata:getHeroTotalCount() >= 3 then
						requestEnterArena()
					else
						MessageBox:showMessageBox1("拥有英雄不足三个,无法进入竞技场~")
					end
				end,
	-- 背包
	bagpack 	= function()
					EventSystem:PushEvent(Event.GUISYSTEM_SHOW_BAGPACKWINDOW)
				end,
	-- 英雄
	hero 		= function(type)
					Event.GUISYSTEM_SHOW_HEROINFOWINDOW.mData    = {}
					Event.GUISYSTEM_SHOW_HEROINFOWINDOW.mData[1] = nil   	--当前选择英雄索引
					Event.GUISYSTEM_SHOW_HEROINFOWINDOW.mData[2] = type
       				EventSystem:PushEvent(Event.GUISYSTEM_SHOW_HEROINFOWINDOW)
				end,
	-- 抽卡
	lottery 	= function()
					local function onRequestEnterLottery(msgPacket)
						globaldata:updateLotteryInfoFromServerPacket(msgPacket)
						EventSystem:PushEvent(Event.GUISYSTEM_SHOW_LOTTERYWINDOW)
						GUISystem:hideLoading()
					end

					-- 抽卡请求
					NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_REQUEST_ENTERLOTTERY_, onRequestEnterLottery)

					local function requestEnterLottery()
						local packet = NetSystem.mNetManager:GetSPacket()
				    	packet:SetType(PacketTyper._PTYPE_CS_REQUEST_ENTERLOTTERY_)
				    	packet:Send()
				    	GUISystem:showLoading()
					end
					requestEnterLottery()
				end,
	-- 邮件
	mail 		= function()
					EventSystem:PushEvent(Event.GUISYSTEM_SHOW_MAILWINDOW)
				end,
	-- 所有英雄
	allhero 	= function()
					EventSystem:PushEvent(Event.GUISYSTEM_SHOW_ALLHEROWINDOW)
				end,
	-- 活动
	activity 	= function(result)
					if result then
						Event.GUISYSTEM_SHOW_ACTIVITYWINDOW.mData = result
					end
					EventSystem:PushEvent(Event.GUISYSTEM_SHOW_ACTIVITYWINDOW)
				end,
	-- 点金
	goldenfinger = function()
					-- 请求点金信息回包
					local function onRequestEnterGoldenFinger(msgPacket)
						local info = {}
						info.canBuyCount = msgPacket:GetUShort()
						info.totalBuyCount = msgPacket:GetUShort()
						info.maxCountPerRequest = msgPacket:GetUShort() -- 单次最大点金次数
						info.price = msgPacket:GetInt()
						info.reward = msgPacket:GetInt()
						print("剩余次数", info.canBuyCount)
						print("总的次数", info.totalBuyCount)
						print("价格", info.price)
						print("回报", info.reward)
						Event.GUISYSTEM_SHOW_GOLDENWINDOW.mData = info
						EventSystem:PushEvent(Event.GUISYSTEM_SHOW_GOLDENWINDOW)
						GUISystem:hideLoading()
					end
					NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_GOLDENFINGER_INFO_, onRequestEnterGoldenFinger)
					-- 请求点金信息
					local function requestEnterGoldenFinger()
						local packet = NetSystem.mNetManager:GetSPacket()
				    	packet:SetType(PacketTyper._PTYPE_CS_GOLDENFINGER_INFO_)
				    	packet:Send()
				    	GUISystem:showLoading()
					end
					requestEnterGoldenFinger()
				end,
	-- 排行榜
	rankinglist	= function(typ)
					RankingModel:getInstance().mWinData = typ --type[1] MAIN  type[2] MINOR
					RankingModel:getInstance():loadFirstTime()
				end,

	--好友
	friend = function()
				EventSystem:PushEvent(Event.GUISYSTEM_SHOW_FRIENDWINDOW)
			end,

	--闯关
	tower = function(result)
				TowerModel:getInstance().mWinData = result
				TowerModel:getInstance():doChallengeInfoRequest()
			end,
	--爬塔
	towerex = function(data)
			TowerExModel:getInstance().mWinData = data
			TowerExModel:getInstance():doLoadTowerExInfoRequest()
	end,

	-- 任务
	task = function()
				TaskModel:getInstance():doLoadTaskRequest()
			end,
	-- 道具商城
	homeshop  = function()

					local function onRequestEnterShop(msgPacket)
						globaldata:updateFurnitShopInfoFromServer(msgPacket)
						Event.GUISYSTEM_SHOW_HOMESHOPWINDOW.mData = 1
						EventSystem:PushEvent(Event.GUISYSTEM_SHOW_HOMESHOPWINDOW)
						GUISystem:hideLoading()
					end

					NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_FURNITURE_SHOP_, onRequestEnterShop)

					local function requestEnterShop()
						local packet = NetSystem.mNetManager:GetSPacket()
				    	packet:SetType(PacketTyper._PTYPE_CS_FURNITURE_SHOP_)
				    	packet:Send()
				    	GUISystem:showLoading()
					end
					requestEnterShop()

				end,
	-- 每日奖励
	dailyreward 	=	function()
						EventSystem:PushEvent(Event.GUISYSTEM_SHOW_DAILYREWARDWINDOW)
					end,
	-- 内购
	iap 			=	function()
						EventSystem:PushEvent(Event.GUISYSTEM_SHOW_IAPWINDOW)
					end,
	--财富之山
	wealth          = function(data)	--data[1] battle result data[2] callback
						WealthModel:getInstance().mWinData = data
						WealthModel:getInstance():doLoadWealthInfoRequest() 
					end,
	--天梯
	ladder          = function(battleResult)
						LadderModel:getInstance().mWinData = battleResult
						LadderModel:getInstance():doLoadLadderInfoRequest()
					end,
	--帮派
	partyEntry 		= function()
						if globaldata.partyId ~= "" then
							UnionSubManager:enterUnionHall()
						else
							EventSystem:PushEvent(Event.GUISYSTEM_SHOW_PARTYJOINWINDOW) 
						end
					end,
	--帮派主界面
	partyMain 		= function()
						EventSystem:PushEvent(Event.GUISYSTEM_SHOW_PARTYMAINWINDOW) 
					end,

	--帮派建设界面
	partyBuild 		= function()
						PartyBuildModel:getInstance():doLoadBuildInfoRequest() 
					end,

	--帮派技能界面
	partySkill 		= function()
						PartySkillModel:getInstance():doLoadPartySkillInfoRequest()
					end,

	--帮派问好界面
	partyHello 		= function()
						PartyHelloModel:getInstance():doLoadSeniorsRequest()
					end,										

	--黑市
	blackmarket     = function(data) --data[1] battle result data[2] callback
						BlackMarketModel:getInstance().mWinData = data
						BlackMarketModel:getInstance():doLoadMarketInfoRequest()
					end,

	--科技
	technology     = function(data,fun2)
						TechnologyModel:getInstance().mEndFunc =  data
						TechnologyModel:getInstance().mEndFunc2 = fun2
						TechnologyModel:getInstance():doLoadArtiFactInfoRequest()
					end,

	banghuihall  = function()

					local function onRequestBanghuiHall(msgPacket)
						globaldata:onRequestBanghuiHallData(msgPacket)
						EventSystem:PushEvent(Event.GUISYSTEM_SHOW_GANGWARSWINDOW)
						GUISystem:hideLoading()
					end

					NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_LOAD_BANGHUIHALL_RESPONSE, onRequestBanghuiHall)

					local function requestBanghuiHall()
						local packet = NetSystem.mNetManager:GetSPacket()
				    	packet:SetType(PacketTyper._PTYPE_CS_LOAD_BANGHUIHALL_REQUEST)
				    	packet:Send()
				    	GUISystem:showLoading()
					end
					requestBanghuiHall()

				end,
	--世界boss
	worldboss     = function(data)
						WorldBossModel:getInstance():onBossEnterRequst()
						WorldBossModel:getInstance().mEnterFun = data
					end,
	herobeautify  = function()
						EventSystem:PushEvent(Event.GUISYSTEM_SHOW_HEROBEAUTIFYWINDOW)
					end,
	herotitle     = function(data)
						HeroTitleModel:getInstance():onTitleEnterRequst()
						HeroTitleModel:getInstance().mEnterFun = data
					end,

					--坐骑和时装
	horsegun 		= function(param)
						local function onRequestEnterHorseGunWnd(msgPacket)
							local fashionEquipList = {}
							fashionEquipList.defaultParam = param
							local equipCnt = msgPacket:GetUShort()
							for i = 1, equipCnt do
								fashionEquipList[i] = {}
								fashionEquipList[i].mId   		= msgPacket:GetInt()
								fashionEquipList[i].mType 		= msgPacket:GetChar()
								fashionEquipList[i].mPower 		= msgPacket:GetInt()	-- 时装战力
								fashionEquipList[i].mLevel  	= msgPacket:GetInt()
								-- 时装升级部分
								fashionEquipList[i].equipUpdateItemCnt	=	msgPacket:GetInt()
								fashionEquipList[i].equipUpdateMoneyCnt	=	msgPacket:GetInt()
								fashionEquipList[i].equipAdvanceLevel	=	msgPacket:GetInt()
								fashionEquipList[i].equipCurSkillPoint	=	msgPacket:GetInt()
								fashionEquipList[i].equipMaxSkillPoint	=	msgPacket:GetInt()
								-- 时装基础属性
								fashionEquipList[i].propPercent			=	msgPacket:GetInt()
								fashionEquipList[i].initPropCnt 		=	msgPacket:GetUShort()
								fashionEquipList[i].initPropList		=	{}
								for j = 1, fashionEquipList[i].initPropCnt do
									fashionEquipList[i].initPropList[j] = {}
									fashionEquipList[i].initPropList[j].propType 	= 	msgPacket:GetChar()
									fashionEquipList[i].initPropList[j].propValue	=	msgPacket:GetInt()
								end
								-- 时装技能部分
								fashionEquipList[i].mSkillCnt  	= msgPacket:GetUShort()
								fashionEquipList[i].mSkillList 	= {}
								for j = 1, fashionEquipList[i].mSkillCnt do
									fashionEquipList[i].mSkillList[j]				= {}
									fashionEquipList[i].mSkillList[j].mSkillId				=	msgPacket:GetInt()		-- 时装技能ID
									fashionEquipList[i].mSkillList[j].mSkillBigLevel		=	msgPacket:GetInt()		-- 时装技能大等级
									fashionEquipList[i].mSkillList[j].mSkillSmallLevel		=	msgPacket:GetInt()		-- 时装技能小等级
									fashionEquipList[i].mSkillList[j].mSkillSmallLevelCnt	=	msgPacket:GetInt()		-- 时装技能小等级数量
									fashionEquipList[i].mSkillList[j].mSkillUpdateItemCnt	=	msgPacket:GetInt()		-- 时装技能升级需要物品数量
								end
							end
							Event.GUISYSTEM_SHOW_HORSEANDGUNWINDOW.mData    = fashionEquipList
							EventSystem:PushEvent(Event.GUISYSTEM_SHOW_HORSEANDGUNWINDOW)
							GUISystem:hideLoading()
						end

						NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_FASHION_EQUIP_INFO, onRequestEnterHorseGunWnd)

						local function requestEnterHorseGunWnd()
							local packet = NetSystem.mNetManager:GetSPacket()
					    	packet:SetType(PacketTyper._PTYPE_CS_FASHION_EQUIP_INFO)
					    	packet:Send()
					    	GUISystem:showLoading()
						end
						requestEnterHorseGunWnd()
					end,

					-- 英雄技能界面
	skill 		  = function()
						EventSystem:PushEvent(Event.GUISYSTEM_SHOW_HEROSKILLWINDOW)
					end,
	badge 		  = function(func,func2)
						local function onRequestEnterBadgeWindow(msgPacket)
							local badgeInfo = {}
							badgeInfo.starCnt 		= 	msgPacket:GetInt() 		-- 星星数量
							badgeInfo.curBadgeIndex	=	msgPacket:GetUShort()	-- 当前徽章数
							badgeInfo.diamondCnt	=	msgPacket:GetUShort()	-- 宝石数
							badgeInfo.diamondList	=	{}
							for i = 1, badgeInfo.diamondCnt do
								local diamondPos = msgPacket:GetInt()	-- 宝石位置
								local diamondId	 = msgPacket:GetInt()	-- 宝石ID
								badgeInfo.diamondList[diamondPos] = diamondId
							end
							badgeInfo.propCnt 		=	msgPacket:GetUShort()	-- 属性数量
							badgeInfo.propList 		=	{}
							for i = 1, badgeInfo.propCnt do
								badgeInfo.propList[i] = {}
								badgeInfo.propList[i].propType	=	msgPacket:GetChar()		-- 属性类型
								badgeInfo.propList[i].propValue	=	msgPacket:GetInt()		-- 属性值
							end
							Event.GUISYSTEM_SHOW_BADGEWINDOW.mData    = badgeInfo
							if func2 then
								func2()
							end
							EventSystem:PushEvent(Event.GUISYSTEM_SHOW_BADGEWINDOW, func)
							GUISystem:hideLoading()
						end

						NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_BADGE_INFO, onRequestEnterBadgeWindow)

						local function requestEnterBadgeWindow()
							local packet = NetSystem.mNetManager:GetSPacket()
					    	packet:SetType(PacketTyper._PTYPE_CS_BADGE_INFO)
					    	packet:Send()
					    	GUISystem:showLoading()
						end
						requestEnterBadgeWindow()
					end,

}


-- 各个UI入口
function GUISystem:goTo(name, ...)
	if self.handlerMap[name] then
		self.handlerMap[name](...)
		-- 关闭按钮弹出框
		GUISystem:GetWindowByName("HomeWindow"):cleanBtnInfo()
	end
end

-- 玩家升级
function GUISystem:onPlayerLevelup(Levelold,Level,maxUpdateVityold,maxUpdateVity,maxEquipold,maxEquip)
	-- 各种弱指引
	GUISystem:GetWindowByName("HomeWindow"):doHomeGuide()
	-- 按钮刷新
	GUISystem:GetWindowByName("HomeWindow"):updateHomeBtnLayout()

	CommonAnimation.PlayEffectId(5005)
	local widget = GUIWidgetPool:createWidget("LevelupWindow1")
	local function doCleanup()
		widget:removeFromParent(true)
		if globaldata.levelupbackwindow == "fuben" then
			if globaldata.PvpType == "wealth" then
				EventSystem:PushEvent(Event.GUISYSTEM_HIDE_FIGHTWINDOW)
				GUISystem:goTo("wealth",{"success",nil})
				globaldata.PvpType = "none"
			else
				EventSystem:PushEvent(Event.GUISYSTEM_HIDE_FIGHTWINDOW)	
				Event.GUISYSTEM_SHOW_PVEENTRYWINDOW.mData = {}
				Event.GUISYSTEM_SHOW_PVEENTRYWINDOW.mData[1] = globaldata.clickedlevel
				EventSystem:PushEvent(Event.GUISYSTEM_SHOW_PVEENTRYWINDOW)
			end
		end
		-- 刷一下主城界面
		GUISystem:GetWindowByName("HomeWindow"):doHomeGuide()

	end
	local function ShowMain()
		local Playdata = DB_PlayerEXP.getArrDataByField("Player_Level",Level)
		if #Playdata ~= 0 then
			local panelMain = widget:getChildByName("Panel_Main_NewFunction")
			panelMain:setVisible(true)
			panelMain:getChildByName("Panel_Level"):setOpacity(0)
			panelMain:getChildByName("Panel_Tili"):setOpacity(0)
			panelMain:getChildByName("Panel_Equip"):setOpacity(0)
			panelMain:getChildByName("Panel_Level"):getChildByName("Label_Pre"):setString(tostring(Levelold))
			panelMain:getChildByName("Panel_Level"):getChildByName("Label_Cur"):setString(tostring(Level))
			panelMain:getChildByName("Panel_Tili"):getChildByName("Label_Pre"):setString(tostring(maxUpdateVityold))
			panelMain:getChildByName("Panel_Tili"):getChildByName("Label_Cur"):setString(tostring(maxUpdateVity))
			panelMain:getChildByName("Panel_Equip"):getChildByName("Label_Pre"):setString(tostring(maxEquipold))
			panelMain:getChildByName("Panel_Equip"):getChildByName("Label_Cur"):setString(tostring(maxEquip))
			panelMain:getChildByName("Panel_NewFunction"):setOpacity(0)
			panelMain:getChildByName("Panel_NewFunction"):getChildByName("Image_FunctionIcon"):loadTexture(Playdata[1].Player_Icon,1)
			panelMain:getChildByName("Panel_NewFunction"):getChildByName("Label_FunctionName"):setString(getDictionaryText(Playdata[1].Function_Name))

			local act = cc.FadeIn:create(0.1)
			panelMain:getChildByName("Panel_Level"):runAction(act)

			local act1 = cc.FadeIn:create(0.2)
			panelMain:getChildByName("Panel_Tili"):runAction(act1)

			local act2 = cc.FadeIn:create(0.3)
			panelMain:getChildByName("Panel_Equip"):runAction(act2)
			local  function ShowOk()
				panelMain:getChildByName("Button_OK"):setVisible(true)
				registerWidgetReleaseUpEvent(panelMain:getChildByName("Button_OK"), doCleanup)
			end
			local act3 = cc.FadeIn:create(0.4)
			local _ac4 = cc.CallFunc:create(ShowOk)
			panelMain:getChildByName("Panel_NewFunction"):runAction(cc.Sequence:create(act3,_ac4))

		else
			
			local panelMain = widget:getChildByName("Panel_Main")
			panelMain:setVisible(true)
			panelMain:getChildByName("Panel_Level"):setOpacity(0)
			panelMain:getChildByName("Panel_Tili"):setOpacity(0)
			panelMain:getChildByName("Panel_Equip"):setOpacity(0)

			panelMain:getChildByName("Panel_Level"):getChildByName("Label_Pre"):setString(tostring(Levelold))
			panelMain:getChildByName("Panel_Level"):getChildByName("Label_Cur"):setString(tostring(Level))
			panelMain:getChildByName("Panel_Tili"):getChildByName("Label_Pre"):setString(tostring(maxUpdateVityold))
			panelMain:getChildByName("Panel_Tili"):getChildByName("Label_Cur"):setString(tostring(maxUpdateVity))
			panelMain:getChildByName("Panel_Equip"):getChildByName("Label_Pre"):setString(tostring(maxEquipold))
			panelMain:getChildByName("Panel_Equip"):getChildByName("Label_Cur"):setString(tostring(maxEquip))
			local act = cc.FadeIn:create(0.1)
			panelMain:getChildByName("Panel_Level"):runAction(act)
			local act1 = cc.FadeIn:create(0.2)
			panelMain:getChildByName("Panel_Tili"):runAction(act1)
			local act2 = cc.FadeIn:create(0.3)
			local  function ShowOk()
				panelMain:getChildByName("Button_OK"):setVisible(true)
				registerWidgetReleaseUpEvent(panelMain:getChildByName("Button_OK"), doCleanup)
			end
			local _ac4 = cc.CallFunc:create(ShowOk)
		
			panelMain:getChildByName("Panel_Equip"):runAction(cc.Sequence:create(act2,_ac4))
		end
	end
	self.RootNode:addChild(widget, 500)

	local function playStarFinish(selfAni)
		selfAni:play("player_update_2",true)
		ShowMain()
	end
	local star = AnimManager:createAnimNode(8048)
	widget:getChildByName("Panel_Animation"):addChild(star:getRootNode(), 100)
	star:play("player_update_1",false,playStarFinish)

	--[[
	local Halo = widget:getChildByName("Image_Halo")
	local function  setPY()
		panelMain:setPositionY(panelMain:getPositionY() - 1000)
	end
	nextTick(setPY)
	
	local weigettable = {}

	local function Step2()
		local act1 = cc.RotateBy:create(5, 360)
		local act2 = cc.RepeatForever:create(act1)
		Halo:runAction(act2)
	end

	local function runFinish()
		Halo:setVisible(true)
		Halo:setScale(0)
		local act1 = cc.ScaleTo:create(0.25, 1.0, 1.0)
		local act2 = cc.CallFunc:create(Step2)
		Halo:runAction(cc.Sequence:create(act1,act2))
	end 

	local function Step1()
		panelMain:setVisible(true)
		local pos = cc.p(panelMain:getPositionX(),panelMain:getPositionY()+1000)
		local act1 = cc.MoveTo:create(0.5, pos)
		local act2 = cc.CallFunc:create(runFinish)
		panelMain:runAction(cc.Sequence:create(act1,act2))
	end

	local bg = widget:getChildByName("Image_Bg")
	bg:setScaleY(0)
	local pic_actionTo = cc.ScaleTo:create(0.2, 1.0, 1.0)
	local act2 = cc.CallFunc:create(Step1)
	bg:runAction(cc.Sequence:create(pic_actionTo,act2))

	]]

	-- 主城功能下一级提示
	GUISystem:GetWindowByName("HomeWindow"):updateNextFuncOpenByLevel()

	-- 功能控制开启
	PlayerFunctionController:update()
end


-- 显示Loading
-- @_hasNoDeadLine 是否没有时间限制
function GUISystem:showLoading(_hasNoDeadLine)
	if not self.mLoadingLayer then
		self.mLoadingLayer = ccui.Layout:create()
	--    self.mLoadingLayer:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
	--   self.mLoadingLayer:setBackGroundColor(G_COLOR_C3B.BLACK)
	    self.mLoadingLayer:setContentSize(cc.size(1140, 770))
	--    self.mLoadingLayer:setOpacity(20)
	    self.mLoadingLayer:setTouchEnabled(true)

	    -- 添加载入动画
		-- ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("res/animation/JM_Loading.ExportJson")
	 --    local anim = ccs.Armature:create("JM_Loading")
		-- anim:getAnimation():play("Animation1", -1, 1)
		-- anim:setPosition(cc.p(1140/2, 770/2))
	 --    self.mLoadingLayer:addChild(anim)

	 	local _resDB = DB_ResourceList.getDataById(4401)
		local _spine = CommonAnimation.createSpine_common(_resDB.Res_path2, _resDB.Res_path1)
		self.mLoadingLayer:addChild(_spine)
		_spine:setPosition(cc.p(1140/2, 770/2))
		_spine:setAnimationWithSpeedScale(0, "act"..math.random(1, 3), true, 1)

	    -- 等待服务器回包超时,自行断开socket连接
	    if not _hasNoDeadLine then
		    local function onNetDelay()
		    	self:hideLoading()
		    	NetManager:ForceDisconnectGameServer()
		    end
		    local act0 = cc.DelayTime:create(NetSystem.mBackDuring)
		    local act1 = cc.CallFunc:create(onNetDelay)
		    self.mLoadingLayer:runAction(cc.Sequence:create(act0, act1))
		end

	    self:GetRootNode():addChild(self.mLoadingLayer, 100)
	end
end

-- 关闭Loading
function GUISystem:hideLoading()
	if self.mLoadingLayer then
		self.mLoadingLayer:stopAllActions()
		self.mLoadingLayer:removeFromParent(true)
		self.mLoadingLayer = nil
	end
end

-- 显示Loading
function GUISystem:showLoadingForPvp()
	if not self.mLoadingLayerPvp then
		self.mLoadingLayerPvp = ccui.Layout:create()
	--    self.mLoadingLayer:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
	--   self.mLoadingLayer:setBackGroundColor(G_COLOR_C3B.BLACK)
	    self.mLoadingLayerPvp:setContentSize(cc.size(1140, 770))
	--    self.mLoadingLayer:setOpacity(20)
	    self.mLoadingLayerPvp:setTouchEnabled(true)

	    -- 添加载入动画
		ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("res/animation/JM_Loading.ExportJson")
	    local anim = ccs.Armature:create("JM_Loading")
		anim:getAnimation():play("Animation1", -1, 1)
		anim:setPosition(cc.p(1140/2, 770/2))
	    self.mLoadingLayerPvp:addChild(anim)
	    -- 等待服务器回包超时,自行断开socket连接
	    local function onNetDelay()
	    	self:hideLoadingForPvp()
	    	NetSystem.mNetManager2:ForceDisconnectSubServer()
	    end
	    local act0 = cc.DelayTime:create(NetSystem.mBackDuring)
	    local act1 = cc.CallFunc:create(onNetDelay)
	    self.mLoadingLayerPvp:runAction(cc.Sequence:create(act0, act1))

	    self:GetRootNode():addChild(self.mLoadingLayerPvp, 100)
	end
end

-- 关闭Loading
function GUISystem:hideLoadingForPvp()
	if self.mLoadingLayerPvp then
		self.mLoadingLayerPvp:stopAllActions()
		self.mLoadingLayerPvp:removeFromParent(true)
		self.mLoadingLayerPvp = nil
	end
end

-- 屏蔽用户输入
function GUISystem:disableUserInput()
	if not self.mLoadingLayer1 then
	--	doError("disableUserInput")
		self.mLoadingLayer1 = ccui.Layout:create()
	--    self.mLoadingLayer:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
	--   self.mLoadingLayer:setBackGroundColor(G_COLOR_C3B.BLACK)
	    self.mLoadingLayer1:setContentSize(cc.size(1140, 770))
	--    self.mLoadingLayer:setOpacity(20)
	    self.mLoadingLayer1:setTouchEnabled(true)
	    self:GetRootNode():addChild(self.mLoadingLayer1, 100)
	end	
end

-- 允许用户输入
function GUISystem:enableUserInput()
	if self.mLoadingLayer1 then
	--	doError("enableUserInput")
		self.mLoadingLayer1:removeFromParent(true)
		self.mLoadingLayer1 = nil
	end
end

-- 屏蔽用户输入
function GUISystem:disableUserInput_MsgBox()
	if not self.mLoadingLayer_MsgBox then
	--	doError("disableUserInput")
		self.mLoadingLayer_MsgBox = ccui.Layout:create()
	--    self.mLoadingLayer:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
	--   self.mLoadingLayer:setBackGroundColor(G_COLOR_C3B.BLACK)
	    self.mLoadingLayer_MsgBox:setContentSize(cc.size(1140, 770))
	--    self.mLoadingLayer:setOpacity(20)
	    self.mLoadingLayer_MsgBox:setTouchEnabled(true)
	    self:GetRootNode():addChild(self.mLoadingLayer_MsgBox, 100)
	end	
end

-- 允许用户输入
function GUISystem:enableUserInput_MsgBox()
	if self.mLoadingLayer_MsgBox then
	--	doError("enableUserInput")
		self.mLoadingLayer_MsgBox:removeFromParent(true)
		self.mLoadingLayer_MsgBox = nil
	end
end

--[[
-- 加强版本的屏蔽功能 by wangsd 2016-4-16
GUISystem.mLoadingLayerList = {}

-- 加强版本的屏蔽用户输入
function GUISystem:disableUserInput()
	local curIndex = #self.mLoadingLayerList
	self.mLoadingLayerList[curIndex+1] = ccui.Layout:create()
	self.mLoadingLayerList[curIndex+1]:setContentSize(cc.size(1140, 770))
	self.mLoadingLayerList[curIndex+1]:setTouchEnabled(true)
	self:GetRootNode():addChild(self.mLoadingLayerList[curIndex+1], 100)
end

-- 加强版本的允许用户输入
function GUISystem:enableUserInput()
	local curIndex = #self.mLoadingLayerList
	if curIndex > 0 then
		self.mLoadingLayerList[curIndex]:removeFromParent(true)
		table.remove(self.mLoadingLayerList, curIndex)
	end
end
]]

-- 用于防止玩家多点输入
function GUISystem:disableUserInput2()
	if not self.mLoadingLayer2 then
		self.mLoadingLayer2 = ccui.Layout:create()
	    self.mLoadingLayer2:setContentSize(cc.size(1140, 770))
	    self.mLoadingLayer2:setTouchEnabled(true)
	    self:GetRootNode():addChild(self.mLoadingLayer2, 100)
	end	
end

-- 用于防止玩家多点输入
function GUISystem:enableUserInput2()
	if self.mLoadingLayer2 then
		self.mLoadingLayer2:removeFromParent(true)
		self.mLoadingLayer2 = nil
	end
end

-- 倒数3秒
function GUISystem:CountDownlayout(_waitTime ,_callFinishfun)
	--[[
	if not self.mCountDownlayout then
		GUISystem:disableUserInput()

		local layer = cc.LayerColor:create(G_COLOR_C4B.BLACK, 10, 10)
		self.mCountDownlayout = cc.LayerColor:create(G_COLOR_C4B.BLACK, 1140, 770)
	--  self.mLoadingLayer:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
		self.mCountDownlayout:setColor(G_COLOR_C3B.BLACK)
	    self.mCountDownlayout:setContentSize(cc.size(1140, 770))
	 	self.mCountDownlayout:setOpacity(200)
	    self.mCountDownlayout:setTouchEnabled(true)
	    
	    self:GetRootNode():addChild(self.mCountDownlayout, 100)

    	local path = "res/fonts/font_fight_yellow.fnt"
   	 	local _lb1 = CocosCacheManager:getLabelBMFont(path)
    	_lb1:setAnchorPoint(0.5,0.5)
	    self.mCountDownlayout:addChild(_lb1)
	    _lb1:setPosition(getGoldFightPosition_Middle())
	     _lb1:setScale(2)
	    _lb1:setString("3")
		
		local function ShowLayer()
			self.mCountDownlayout:setVisible(true)
		end	

	    local function CountAction2()
	   		_lb1:setString("2")
	   	end

	   	local function CountAction1()
	   		_lb1:setString("1")
	   	end

	   	local function CountAction0()
	   		_lb1:setString("GO!")
	   	end

	   	local function CountActionFinish()
	   		GUISystem:CanCelCountDownlayout()
	   		GUISystem:enableUserInput()
	   		FightSystem.mTouchPad:setCancelledTouchMove(false)
	   		if _callFinishfun then
	   			_callFinishfun()
	   		end
	   	end

	   	local act1 = cc.DelayTime:create(1)
	   	local act2 = cc.CallFunc:create(CountAction2)
	   	local act3 = cc.DelayTime:create(1)
	   	local act4 = cc.CallFunc:create(CountAction1)
	   	-- local act5 = cc.DelayTime:create(1)
	   	-- local act6 = cc.CallFunc:create(CountAction0)
	   	local act7 = cc.DelayTime:create(0.5)
	   	local act8 = cc.CallFunc:create(CountActionFinish)
	  	if _waitTime then
	  		local act0 = cc.DelayTime:create(_waitTime)
	  		local fun2 = cc.CallFunc:create(ShowLayer)
	  		self.mCountDownlayout:setVisible(false)
	   		_lb1:runAction(cc.Sequence:create(act0,fun2,act1,act2,act3,act4,act7,act8))
	   	else
	   		_lb1:runAction(cc.Sequence:create(act1,act2,act3,act4,act7,act8))
	   	end
	end	
	]]
end

-- 取消倒数
function GUISystem:CanCelCountDownlayout()
	if self.mCountDownlayout then
		self.mCountDownlayout:removeFromParent(true)
		self.mCountDownlayout = nil
	end	
end

-- 加黑屏一年后
function GUISystem:BlackShowPvelayout(callfun)
	if not self.mBlackShowPvelayout then
		self.mBlackShowPvelayout = cc.LayerColor:create(G_COLOR_C4B.BLACK, 1140, 770)
		self.mBlackShowPvelayout:setColor(G_COLOR_C3B.BLACK)
	    self.mBlackShowPvelayout:setContentSize(cc.size(1140, 770))
	 	self.mBlackShowPvelayout:setOpacity(50)
	    self.mBlackShowPvelayout:setTouchEnabled(true)
	    
	    self:GetRootNode():addChild(self.mBlackShowPvelayout, 100)

	    local function Call1()
	    	local _lb = ccui.Text:create()
		    _lb:setFontName("res/fonts/font_3.ttf")
		    _lb:setFontSize(40)
		    -- LabelManager:outline(_lb,cc.c4b(0, 0, 0, 255))
		    _lb:setColor(G_COLOR_C3B.WHITE)
		    _lb:setLocalZOrder(2)
		    _lb:setOpacity(1)
		    _lb:setString("一年以后...")
		    _lb:setPosition(getGoldFightPosition_Middle())
		    local function Call2()
		    	if callfun then
		    		callfun()
		    	end
		    end
		    local _action = cc.FadeIn:create(1)
			local _callback = cc.CallFunc:create(Call2)
			local _seq = cc.Sequence:create(_action, _callback)
			_lb:runAction(_seq)
	    	self.mBlackShowPvelayout:addChild(_lb)
	    end

	    local _action = cc.FadeIn:create(2)
		local _callback = cc.CallFunc:create(Call1)
		local _seq = cc.Sequence:create(_action, _callback)
		self.mBlackShowPvelayout:runAction(_seq)
	end	
end

-- 取消加黑屏一年后
function GUISystem:CanCelBlackShowPvelayout()
	if self.mBlackShowPvelayout then
		self.mBlackShowPvelayout:removeAllChildren()
		local function Call1()
	    	self.mBlackShowPvelayout:removeFromParent(true)
			self.mBlackShowPvelayout = nil
	    end
	    local _action = cc.FadeOut:create(2)
		local _callback = cc.CallFunc:create(Call1)
		local _seq = cc.Sequence:create(_action, _callback)
		self.mBlackShowPvelayout:runAction(_seq)
	end	
end

-- 战斗开始层
function GUISystem:FightBeginlayout(_callFinishfun)
	if not self.mFightBeginlayout then
		self.mFightBeginlayout = ccui.Layout:create()
	    self.mFightBeginlayout:setContentSize(cc.size(1140, 770))
	 	self.mFightBeginlayout:setAnchorPoint(cc.p(0,0))
	    self.mFightBeginlayout:setTouchEnabled(true)
	    self:GetRootNode():addChild(self.mFightBeginlayout, 100)
		local function RoundBegin( selfAni )
		   selfAni:destroy()
		    if _callFinishfun then
		      _callFinishfun()
		      _callFinishfun = nil
		    end
		   self:CanCelFightBeginlayout()
		end
		local Beginfight = AnimManager:createAnimNode(8052)
		self.mFightBeginlayout:addChild(Beginfight:getRootNode(), 100)
		Beginfight:getRootNode():setPosition(getGoldFightPosition_Middle())
		Beginfight:play("fight_begin",false,RoundBegin)
	end	
end

-- 取消战斗开始层
function GUISystem:CanCelFightBeginlayout()
	if self.mFightBeginlayout then
		self.mFightBeginlayout:removeFromParent(true)
		self.mFightBeginlayout = nil
	end	
end

-- 设置PVP之后黑屏
function GUISystem:PVPBlacklayout(_fun)

	if self.mPvpBlacklayout1 then
		self.mPvpBlacklayout1:removeFromParent()
		self.mPvpBlacklayout1 = nil
	end
	
	self.mPvpBlacklayout1 = ccui.Layout:create()
	self.mPvpBlacklayout1:setBackGroundColor(G_COLOR_C3B.BLACK)
    self.mPvpBlacklayout1:setContentSize(cc.size(1140, 770))
 	self.mPvpBlacklayout1:setOpacity(255)
 	self.mPvpBlacklayout1:setAnchorPoint(cc.p(0,0))
 	self.mPvpBlacklayout1:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
    self:GetRootNode():addChild(self.mPvpBlacklayout1, 100)
    self.mPvpBlacklayout1:setPosition(getGoldFightPosition_LU())
	
    if self.mPvpBlacklayout2 then
		self.mPvpBlacklayout2:removeFromParent()
		self.mPvpBlacklayout2 = nil
	end
	self.mPvpBlacklayout2 = ccui.Layout:create()
	self.mPvpBlacklayout2:setBackGroundColor(G_COLOR_C3B.BLACK)
    self.mPvpBlacklayout2:setContentSize(cc.size(1140, 770))
 	self.mPvpBlacklayout2:setOpacity(255)
 	self.mPvpBlacklayout2:setAnchorPoint(cc.p(0,1))

 	self.mPvpBlacklayout2:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)

    self:GetRootNode():addChild(self.mPvpBlacklayout2, 100)
    self.mPvpBlacklayout2:setPosition(cc.p(getGoldFightPosition_LD()))

    local endCount = 0
	local function moveEnd()
		endCount = endCount + 1
		if endCount == 2 then
			if _fun then
				_fun()
			end
		end
	end
	
	local actDelay = cc.DelayTime:create(2)
	local actMove  = cc.MoveTo:create(0.5,cc.p(getGoldFightPosition_LU().x,getGoldFightPosition_Middle().y))
	local actEnd   = cc.CallFunc:create(moveEnd)
	self.mPvpBlacklayout1:runAction(cc.Sequence:create(actDelay,actMove,actEnd))
	
	local actDelay1 = cc.DelayTime:create(2)
	local actMove1  = cc.MoveTo:create(0.5,cc.p(getGoldFightPosition_LU().x,getGoldFightPosition_Middle().y))
	local actEnd1   = cc.CallFunc:create(moveEnd)
	self.mPvpBlacklayout2:runAction(cc.Sequence:create(actDelay1,actMove1,actEnd1))
end

function GUISystem:PVPBlacklayoutLeave()
	if self.mPvpBlacklayout1 then
		local function moveEnd1()
			self.mPvpBlacklayout1:removeFromParent()
			self.mPvpBlacklayout1 = nil
		end
		local actDelay = cc.DelayTime:create(0.1)
		local actMove  = cc.MoveTo:create(0.2,getGoldFightPosition_LU())
		local actEnd   = cc.CallFunc:create(moveEnd1)
		self.mPvpBlacklayout1:runAction(cc.Sequence:create(actDelay,actMove,actEnd))
	end

	if self.mPvpBlacklayout2 then
		local function moveEnd2()
			self.mPvpBlacklayout2:removeFromParent()
			self.mPvpBlacklayout2 = nil
		end
		local actDelay = cc.DelayTime:create(0.1)
		local actMove  = cc.MoveTo:create(0.5,getGoldFightPosition_LD())
		local actEnd   = cc.CallFunc:create(moveEnd2)
		self.mPvpBlacklayout2:runAction(cc.Sequence:create(actDelay,actMove,actEnd))
	end
end

-- 窗口是否能显示
function GUISystem:canShow(wndName)
	-- local windows = 
	-- {
	-- 	"HeroInfoWindow",
	-- 	"EquipInfoWindow",
	-- 	"BagpackWindow",
	-- 	"AllHeroWindow",
	-- 	"PveEntryWindow",
	-- 	"ArenaWindow",
	-- 	"ActivityWindow",
	-- 	"LotteryWindow",
	-- 	"ShopWindow",
	-- 	"TaskWindow",
	-- }

	-- for i = 1, #windows do
	-- 	if wndName ~= windows[i] then
	-- 		if nil ~= self:GetWindowByName(windows[i]).mRootNode then
	-- 			return false
	-- 		end
	-- 	end
	-- end
	return true
end

-- 播放声音
function GUISystem:playSound(name)
	if "closeSound" == name then 						-- 关闭声音
		CommonAnimation.PlayEffectId(2001)
	elseif "homeBtnSound" == name then 					-- 主城界面按钮
		CommonAnimation.PlayEffectId(2006)
	elseif "lotterySound" == name then 					-- 召唤
		CommonAnimation.PlayEffectId(2003)
	elseif "heroLotterySound" == name then 				-- 召唤出英雄
		CommonAnimation.PlayEffectId(2004)
	elseif "goldenFingerSound" == name then 			-- 点金
		CommonAnimation.PlayEffectId(2005)
	elseif "tabPageSound" == name then 					-- 标签页声音
		CommonAnimation.PlayEffectId(2002)
	elseif "lotteryScrollBtnSound" == name then 		-- 召唤窗口内滑动按钮
		CommonAnimation.PlayEffectId(2007)
	end
end

-- 请求跟某人私聊
function GUISystem:requestTalkToSomebody(playerId, playerName)
	print("请求私聊:", "id:", playerId, "name:", playerName)
	if GUISystem:GetWindowByName("HomeWindow").mBottomChatPanel then
		GUISystem:GetWindowByName("HomeWindow").mBottomChatPanel:talkToSomebody(playerId, playerName)
	end
end


local deltaTm = 30 -- 总变化时间为5秒
local lblWidget  = nil

-- 销毁
function GUISystem:doPlayerCombatChangeDestroy()
	-- 删除前一次的定时器
	if self.mCombatChangeScheduler then
		local scheduler = cc.Director:getInstance():getScheduler()
		scheduler:unscheduleScriptEntry(self.mCombatChangeScheduler)
		self.mCombatChangeScheduler = nil
	end
end

-- 显示战力变化
function GUISystem:showPlayerCombatChange(oldValue, newValue)
	
	if not self.mCombatChangeWidget then
		self.mCombatChangeWidget = GUIWidgetPool:createWidget("NewHome_ZhanliChange")
		GUISystem.RootNode:addChild(self.mCombatChangeWidget, 5000)

		local function doAdapter()
			local mainWidget = self.mCombatChangeWidget:getChildByName("Panel_Main")
			mainWidget:setPositionY(getGoldFightPosition_LU().y - mainWidget:getContentSize().height)
		end
		doAdapter()

		local function addAnimNode()
			GUISystem.mCombatAnimNode = AnimManager:createAnimNode(8042)
			self.mCombatChangeWidget:getChildByName("Panel_Animation"):addChild(GUISystem.mCombatAnimNode:getRootNode(), 100)
		end
		addAnimNode()
	end

	lblWidget = self.mCombatChangeWidget:getChildByName("Label_Zhanli_Stroke_211_0_0")

	local function playAnimFuncUp()
		local function onAnimEnd()
			GUISystem.mCombatAnimNode:play("zhanli_change_up_2", true)
		end
		GUISystem.mCombatAnimNode:play("zhanli_change_up_1", false, onAnimEnd)
	end

	local function playAnimFuncDown()
		local function onAnimEnd()
			GUISystem.mCombatAnimNode:play("zhanli_change_down_2", true)
		end
		GUISystem.mCombatAnimNode:play("zhanli_change_down_1", false, onAnimEnd)
	end

	if newValue > oldValue then -- 提升
		playAnimFuncUp()
	else
		playAnimFuncDown()
	end
	
	-- 停止前一次的
	self.mCombatChangeWidget:setVisible(true)
	self.mCombatChangeWidget:setOpacity(255)
	self.mCombatChangeWidget:stopAllActions()

	local function stopTick()
		-- 删除前一次的定时器
		if self.mCombatChangeScheduler then
			local scheduler = cc.Director:getInstance():getScheduler()
			scheduler:unscheduleScriptEntry(self.mCombatChangeScheduler)
			self.mCombatChangeScheduler = nil
		end
	end
	stopTick()

	local deltaValue = (newValue - oldValue)/deltaTm -- 算出变化率
	if deltaValue > 0 then
		deltaValue = math.ceil(deltaValue)
	else
		deltaValue = math.floor(deltaValue)
	end

	print("oldValue:", oldValue, "newValue:", newValue, "deltaValue:", deltaValue)

	lblWidget:setString(oldValue)

	local function startFunc()
		
	end

	local curValue = oldValue

	if newValue >= oldValue then
		local function deltaFunc()
			local function tick()
				curValue = curValue + deltaValue
				if curValue >= newValue then
					lblWidget:setString(newValue)
					stopTick()
					self.mCombatChangeWidget:stopAllActions()
					local function overFunc()
						self.mCombatChangeWidget:setVisible(false)
						self.mCombatChangeWidget:getChildByName("Image_Zhanli_Bg"):setVisible(false)
						lblWidget:setVisible(false)
					end
					local act0 = cc.DelayTime:create(1)
					local act1 = cc.FadeOut:create(0.5)
					local act2 = cc.CallFunc:create(overFunc)
					self.mCombatChangeWidget:runAction(cc.Sequence:create(act0, act1, act2))
				else
					lblWidget:setString(curValue)
				end
				
			end

			-- 创建定时器
			if not self.mCombatChangeScheduler then
				local scheduler = cc.Director:getInstance():getScheduler()
				self.mCombatChangeScheduler = scheduler:scheduleScriptFunc(tick, 0, false)
			end
			-- 一秒钟以后显示
			self.mCombatChangeWidget:getChildByName("Image_Zhanli_Bg"):setVisible(true)
			lblWidget:setVisible(true)
		end

		-- 开始做运动
		local act0 = cc.CallFunc:create(startFunc)
		local act1 = cc.DelayTime:create(1)
		local act2 = cc.CallFunc:create(deltaFunc)
		self.mCombatChangeWidget:runAction(cc.Sequence:create(act0, act1, act2))
	else
		local function deltaFunc()
			local function tick()
				curValue = curValue + deltaValue
				if curValue <= newValue then
					lblWidget:setString(newValue)
					stopTick()
					self.mCombatChangeWidget:stopAllActions()
					local function overFunc()
						self.mCombatChangeWidget:setVisible(false)
						self.mCombatChangeWidget:getChildByName("Image_Zhanli_Bg"):setVisible(false)
						lblWidget:setVisible(false)
					end
					local act0 = cc.DelayTime:create(1)
					local act1 = cc.FadeOut:create(0.5)
					local act2 = cc.CallFunc:create(overFunc)
					self.mCombatChangeWidget:runAction(cc.Sequence:create(act0, act1, act2))
				else
					lblWidget:setString(curValue)
				end
				
			end

			-- 创建定时器
			if not self.mCombatChangeScheduler then
				local scheduler = cc.Director:getInstance():getScheduler()
				self.mCombatChangeScheduler = scheduler:scheduleScriptFunc(tick, 0, false)
			end
			-- 一秒钟以后显示
			self.mCombatChangeWidget:getChildByName("Image_Zhanli_Bg"):setVisible(true)
			lblWidget:setVisible(true)
		end

		-- 开始做运动
		local act0 = cc.CallFunc:create(startFunc)
		local act1 = cc.DelayTime:create(1)
		local act2 = cc.CallFunc:create(deltaFunc)
		self.mCombatChangeWidget:runAction(cc.Sequence:create(act0, act1, act2))
	end
end

-- 显示英雄克制关系
function GUISystem:showHeroRelationShip()
	local rootWidget = GUIWidgetPool:createWidget("Hero_GroupCircle")

	-- 清理
	local function doCleanup()
		rootWidget:removeFromParent(true)

		local window = GUISystem:GetWindowByName("HeroInfoWindow")
		if window.mRootWidget then
			local guideBtn = window.mRootWidget:getChildByName("Image_Jineng")
			local size = guideBtn:getContentSize()
			local pos = guideBtn:getWorldPosition()
			pos.x = pos.x - size.width/2
			pos.y = pos.y - size.height/2
			local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
			HeroGuideOneEx:step(10, touchRect)
		end
	end

	registerWidgetPushDownEvent(rootWidget, doCleanup)

	GUISystem.RootNode:addChild(rootWidget, GUISYS_ZORDER_GUIWINDOW)

--	local function doHeroGuideOne_Stop()
--		HeroGuideOne:stop()
--	end

--	if HeroGuideOne:canGuide() then
--		HeroGuideOne:step(19, nil, doHeroGuideOne_Stop)
--	end

	local function doHeroGuideOneEx_Step9()
		local window = GUISystem:GetWindowByName("HeroInfoWindow")
		if window.mRootWidget then
			local guideBtn = window.mRootWidget:getChildByName("Panel_HeroInfo")
			local size = guideBtn:getContentSize()
			local pos = guideBtn:getWorldPosition()
			pos.x = pos.x - size.width/2
			pos.y = pos.y - size.height/2
			local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
			HeroGuideOneEx:step(9, touchRect)
		end
	end
	HeroGuideOneEx:step(8, nil, doHeroGuideOneEx_Step9)

end

-- 清理所有东西
function GUISystem:doCleanup()
	if self.mCombatChangeWidget then
		self.mCombatChangeWidget:removeFromParent(true)
		self.mCombatChangeWidget = nil
	end
end