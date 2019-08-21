-- Name: Event
-- Func: 事件单元
-- Author: Johny

--  使用说明
--	Type 为事件类型，用以标示接收的系统
--	SubType 为子类型，用以接收的系统来匹配处理的子模块
--	Action 为动作表，用以定义多个动作
--	Data 为数据表，用以定义多个数据

module("Event", package.seeall)


--
--Event Typer
--
EVENT_UNKNOWN = 0

-- WINDOW-- 1~1000
WINDOW_SHOW 		= 1
WINDOW_HIDE		 	= 2
WINDOW_ENABLE_DRAW 	= 3
WINDOW_DISABLE_DRAW = 4




-- SOUND --	5001~6000
tSOUND_BGM_PLAY = 5001
tSOUND_BGM_STOP = 5002
tSOUND_BGM_CHANGE = 5003
tSOUND_EFFECT_PLAY = 5004
tSOUND_EFFECT_STOP = 5005
tSOUND_EFFECTALL_STOP = 5006
tSOUND_EFFECT_PRELOAD = 5007
tSOUND_BGM_PRELOAD = 5008


-- LOGIC --	10001~20000
LOGIC_SOCKET_SUCCESS = 10001
LOGIC_SOCKET_FAIL = 10002
LOGIC_SOCKET_CLOSED = 10003
LOGIC_HTTP_FAIL = 10004





--
--Event Item
--


--[[
	function Event:ctor()
		self.mType = nil
		self.mSubType = nil
		self.mAction = nil
		self.mData = nil
	end
]]

--
-- WINDOW EVENT
--
GUISYSTEM_SHOW_ANDROIDLAUNCHWINDOW = { mType = "GUISYSTEM", mSubType = "AndroidLaunchWindow", mAction = WINDOW_SHOW, mData = nil}
GUISYSTEM_HIDE_ANDROIDLAUNCHWINDOW = { mType = "GUISYSTEM", mSubType = "AndroidLaunchWindow", mAction = WINDOW_HIDE, mData = nil}
--
GUISYSTEM_SHOW_FIGHTWINDOW = { mType = "GUISYSTEM", mSubType = "FightWindow", mAction = WINDOW_SHOW, mData = nil}
GUISYSTEM_HIDE_FIGHTWINDOW = { mType = "GUISYSTEM", mSubType = "FightWindow", mAction = WINDOW_HIDE, mData = nil}
--
GUISYSTEM_SHOW_HOMEWINDOW = { mType = "GUISYSTEM", mSubType = "HomeWindow", mAction = WINDOW_SHOW, mData = nil}
GUISYSTEM_HIDE_HOMEWINDOW = { mType = "GUISYSTEM", mSubType = "HomeWindow", mAction = WINDOW_HIDE, mData = nil}
GUISYSTEM_EABLEDRAW_HOMEWINDOW = { mType = "GUISYSTEM", mSubType = "HomeWindow", mAction = WINDOW_ENABLE_DRAW, mData = nil}
GUISYSTEM_DISABLEDRAW_HOMEWINDOW = { mType = "GUISYSTEM", mSubType = "HomeWindow", mAction = WINDOW_DISABLE_DRAW, mData = nil}
--
GUISYSTEM_SHOW_UNIONHALLWINDOW = { mType = "GUISYSTEM", mSubType = "UnionHallWindow", mAction = WINDOW_SHOW, mData = nil}
GUISYSTEM_HIDE_UNIONHALLWINDOW = { mType = "GUISYSTEM", mSubType = "UnionHallWindow", mAction = WINDOW_HIDE, mData = nil}
GUISYSTEM_ENABLEDRAW_UNIONHALLWINDOW = { mType = "GUISYSTEM", mSubType = "UnionHallWindow", mAction = WINDOW_ENABLE_DRAW, mData = nil}
GUISYSTEM_DISABLEDRAW_UNIONHALLWINDOW = { mType = "GUISYSTEM", mSubType = "UnionHallWindow", mAction = WINDOW_DISABLE_DRAW, mData = nil}
-----
GUISYSTEM_SHOW_LOADINGWINDOW = { mType = "GUISYSTEM", mSubType = "LoadingWindow", mAction = WINDOW_SHOW, mData = nil}
GUISYSTEM_HIDE_LOADINGWINDOW  = { mType = "GUISYSTEM", mSubType = "LoadingWindow", mAction = WINDOW_HIDE, mData = nil}

GUISYSTEM_SHOW_LOGINWINDOW = { mType = "GUISYSTEM", mSubType = "LoginWindow", mAction = WINDOW_SHOW, mData = nil}
GUISYSTEM_HIDE_LOGINWINDOW = { mType = "GUISYSTEM", mSubType = "LoginWindow", mAction = WINDOW_HIDE, mData = nil}

GUISYSTEM_SHOW_PVEENTRYWINDOW = { mType = "GUISYSTEM", mSubType = "PveEntryWindow", mAction = WINDOW_SHOW, mData = nil}
GUISYSTEM_HIDE_PVEENTRYWINDOW = { mType = "GUISYSTEM", mSubType = "PveEntryWindow", mAction = WINDOW_HIDE, mData = nil}
GUISYSTEM_EABLEDRAW_PVEENTRYWINDOW = { mType = "GUISYSTEM", mSubType = "PveEntryWindow", mAction = WINDOW_ENABLE_DRAW, mData = nil}
GUISYSTEM_DISABLEDRAW_PVEENTRYWINDOW = { mType = "GUISYSTEM", mSubType = "PveEntryWindow", mAction = WINDOW_DISABLE_DRAW, mData = nil}


GUISYSTEM_SHOW_SECTIONENTRYWINDOW = { mType = "GUISYSTEM", mSubType = "SectionEntryWindow", mAction = WINDOW_SHOW, mData = nil}
GUISYSTEM_HIDE_SECTIONENTRYWINDOW = { mType = "GUISYSTEM", mSubType = "SectionEntryWindow", mAction = WINDOW_HIDE, mData = nil}

GUISYSTEM_SHOW_BAGPACKWINDOW = { mType = "GUISYSTEM", mSubType = "BagpackWindow", mAction = WINDOW_SHOW, mData = nil}
GUISYSTEM_HIDE_BAGPACKWINDOW = { mType = "GUISYSTEM", mSubType = "BagpackWindow", mAction = WINDOW_HIDE, mData = nil}

GUISYSTEM_SHOW_SAODANGREWARDWINDOW = { mType = "GUISYSTEM", mSubType = "SaodangRewardWindow", mAction = WINDOW_SHOW, mData = nil}
GUISYSTEM_HIDE_SAODANGREWARDWINDOW = { mType = "GUISYSTEM", mSubType = "SaodangRewardWindow", mAction = WINDOW_HIDE, mData = nil}

GUISYSTEM_SHOW_BATTLERESULT_WIN  = { mType = "GUISYSTEM", mSubType = "BattleResult_WinWindow", mAction = WINDOW_SHOW, mData = nil}
GUISYSTEM_HIDE_BATTLERESULT_WIN = { mType = "GUISYSTEM", mSubType = "BattleResult_WinWindow", mAction = WINDOW_HIDE, mData = nil}

GUISYSTEM_SHOW_BATTLERESULT_LOSE  = { mType = "GUISYSTEM", mSubType = "BattleResult_LoseWindow", mAction = WINDOW_SHOW, mData = nil}
GUISYSTEM_HIDE_BATTLERESULT_LOSE = { mType = "GUISYSTEM", mSubType = "BattleResult_LoseWindow", mAction = WINDOW_HIDE, mData = nil}

GUISYSTEM_SHOW_ROLESELWINDOW = { mType = "GUISYSTEM", mSubType = "RoleselWindow", mAction = WINDOW_SHOW, mData = nil}
GUISYSTEM_HIDE_ROLESELWINDOW = { mType = "GUISYSTEM", mSubType = "RoleselWindow", mAction = WINDOW_HIDE, mData = nil}

GUISYSTEM_SHOW_SERVERSELWINDOW = { mType = "GUISYSTEM", mSubType = "ServerSelWindow", mAction = WINDOW_SHOW, mData = nil}
GUISYSTEM_HIDE_SERVERSELWINDOW = { mType = "GUISYSTEM", mSubType = "ServerSelWindow", mAction = WINDOW_HIDE, mData = nil}

GUISYSTEM_SHOW_HEROINFOWINDOW = { mType = "GUISYSTEM", mSubType = "HeroInfoWindow", mAction = WINDOW_SHOW, mData = nil}
GUISYSTEM_HIDE_HEROINFOWINDOW = { mType = "GUISYSTEM", mSubType = "HeroInfoWindow", mAction = WINDOW_HIDE, mData = nil}

GUISYSTEM_SHOW_LOTTERYWINDOW = { mType = "GUISYSTEM", mSubType = "LotteryWindow", mAction = WINDOW_SHOW, mData = nil}
GUISYSTEM_HIDE_LOTTERYWINDOW = { mType = "GUISYSTEM", mSubType = "LotteryWindow", mAction = WINDOW_HIDE, mData = nil}

GUISYSTEM_SHOW_LOTTERYRESULTWINDOW1 = { mType = "GUISYSTEM", mSubType = "LotteryResultOneWindow", mAction = WINDOW_SHOW, mData = nil}
GUISYSTEM_HIDE_LOTTERYRESULTWINDOW1 = { mType = "GUISYSTEM", mSubType = "LotteryResultOneWindow", mAction = WINDOW_HIDE, mData = nil}

GUISYSTEM_SHOW_LOTTERYRESULTWINDOW10 = { mType = "GUISYSTEM", mSubType = "LotteryResultTenWindow", mAction = WINDOW_SHOW, mData = nil}
GUISYSTEM_HIDE_LOTTERYRESULTWINDOW10 = { mType = "GUISYSTEM", mSubType = "LotteryResultTenWindow", mAction = WINDOW_HIDE, mData = nil}

GUISYSTEM_SHOW_SELECTROLEWINDOW = { mType = "GUISYSTEM", mSubType = "SelectRoleWindow", mAction = WINDOW_SHOW, mData = nil}
GUISYSTEM_HIDE_SELECTROLEWINDOW = { mType = "GUISYSTEM", mSubType = "SelectRoleWindow", mAction = WINDOW_HIDE, mData = nil}

GUISYSTEM_SHOW_EQUIPINFOWINDOW = { mType = "GUISYSTEM", mSubType = "EquipInfoWindow", mAction = WINDOW_SHOW, mData = nil}
GUISYSTEM_HIDE_EQUIPINFOWINDOW = { mType = "GUISYSTEM", mSubType = "EquipInfoWindow", mAction = WINDOW_HIDE, mData = nil}

GUISYSTEM_SHOW_EXCHANGEHEROWINDOW = { mType = "GUISYSTEM", mSubType = "ExchangeHeroWindow", mAction = WINDOW_SHOW, mData = nil}
GUISYSTEM_HIDE_EXCHANGEHEROWINDOW = { mType = "GUISYSTEM", mSubType = "ExchangeHeroWindow", mAction = WINDOW_HIDE, mData = nil}

GUISYSTEM_SHOW_PURCHASEWINDOW = { mType = "GUISYSTEM", mSubType = "PurchaseWindow", mAction = WINDOW_SHOW, mData = nil}
GUISYSTEM_HIDE_PURCHASEWINDOW = { mType = "GUISYSTEM", mSubType = "PurchaseWindow", mAction = WINDOW_HIDE, mData = nil}

GUISYSTEM_SHOW_SHOPWINDOW = { mType = "GUISYSTEM", mSubType = "ShopWindow", mAction = WINDOW_SHOW, mData = nil}
GUISYSTEM_HIDE_SHOPWINDOW = { mType = "GUISYSTEM", mSubType = "ShopWindow", mAction = WINDOW_HIDE, mData = nil}

GUISYSTEM_SHOW_ARENAWINDOW = { mType = "GUISYSTEM", mSubType = "ArenaWindow", mAction = WINDOW_SHOW, mData = nil}
GUISYSTEM_HIDE_ARENAWINDOW = { mType = "GUISYSTEM", mSubType = "ArenaWindow", mAction = WINDOW_HIDE, mData = nil}

GUISYSTEM_SHOW_FIGHTPAUSEWINDOW = { mType = "GUISYSTEM", mSubType = "FightPauseWindow", mAction = WINDOW_SHOW, mData = nil}
GUISYSTEM_HIDE_FIGHTPAUSEWINDOW = { mType = "GUISYSTEM", mSubType = "FightPauseWindow", mAction = WINDOW_HIDE, mData = nil}

GUISYSTEM_SHOW_WORKWINDOW = { mType = "GUISYSTEM", mSubType = "WorkWindow", mAction = WINDOW_SHOW, mData = nil}
GUISYSTEM_HIDE_WORKWINDOW  = { mType = "GUISYSTEM", mSubType = "WorkWindow", mAction = WINDOW_HIDE, mData = nil}

GUISYSTEM_SHOW_DATEWINDOW = { mType = "GUISYSTEM", mSubType = "DateWindow", mAction = WINDOW_SHOW, mData = nil}
GUISYSTEM_HIDE_DATEWINDOW  = { mType = "GUISYSTEM", mSubType = "DateWindow", mAction = WINDOW_HIDE, mData = nil}

GUISYSTEM_SHOW_DATESELECTWINDOW = { mType = "GUISYSTEM", mSubType = "DateSelectWindow", mAction = WINDOW_SHOW, mData = nil}
GUISYSTEM_HIDE_DATESELECTWINDOW  = { mType = "GUISYSTEM", mSubType = "DateSelectWindow", mAction = WINDOW_HIDE, mData = nil}

GUISYSTEM_SHOW_DATEPLAYWINDOW = { mType = "GUISYSTEM", mSubType = "DatePlayWindow", mAction = WINDOW_SHOW, mData = nil}
GUISYSTEM_HIDE_DATEPLAYWINDOW  = { mType = "GUISYSTEM", mSubType = "DatePlayWindow", mAction = WINDOW_HIDE, mData = nil}

GUISYSTEM_SHOW_DATEHEROWINDOW = { mType = "GUISYSTEM", mSubType = "DateHeroWindow", mAction = WINDOW_SHOW, mData = nil}
GUISYSTEM_HIDE_DATEHEROWINDOW  = { mType = "GUISYSTEM", mSubType = "DateHeroWindow", mAction = WINDOW_HIDE, mData = nil}

GUISYSTEM_SHOW_TOWERWINDOW = { mType = "GUISYSTEM", mSubType = "TowerWindow", mAction = WINDOW_SHOW, mData = nil}
GUISYSTEM_HIDE_TOWERWINDOW  = { mType = "GUISYSTEM", mSubType = "TowerWindow", mAction = WINDOW_HIDE, mData = nil}
GUISYSTEM_EABLEDRAW_TOWERWINDOW = { mType = "GUISYSTEM", mSubType = "TowerWindow", mAction = WINDOW_ENABLE_DRAW, mData = nil}
GUISYSTEM_DISABLEDRAW_TOWERWINDOW = { mType = "GUISYSTEM", mSubType = "TowerWindow", mAction = WINDOW_DISABLE_DRAW, mData = nil}

GUISYSTEM_SHOW_MAILWINDOW = { mType = "GUISYSTEM", mSubType = "MailWindow", mAction = WINDOW_SHOW, mData = nil}
GUISYSTEM_HIDE_MAILWINDOW  = { mType = "GUISYSTEM", mSubType = "MailWindow", mAction = WINDOW_HIDE, mData = nil}

GUISYSTEM_SHOW_ALLHEROWINDOW = { mType = "GUISYSTEM", mSubType = "AllHeroWindow", mAction = WINDOW_SHOW, mData = nil}
GUISYSTEM_HIDE_ALLHEROWINDOW  = { mType = "GUISYSTEM", mSubType = "AllHeroWindow", mAction = WINDOW_HIDE, mData = nil}

GUISYSTEM_SHOW_ACTIVITYWINDOW = { mType = "GUISYSTEM", mSubType = "ActivityWindow", mAction = WINDOW_SHOW, mData = nil}
GUISYSTEM_HIDE_ACTIVITYWINDOW = { mType = "GUISYSTEM", mSubType = "ActivityWindow", mAction = WINDOW_HIDE, mData = nil}

GUISYSTEM_SHOW_GOLDENWINDOW = { mType = "GUISYSTEM", mSubType = "GoldenFingerWindow", mAction = WINDOW_SHOW, mData = nil}
GUISYSTEM_HIDE_GOLDENWINDOW = { mType = "GUISYSTEM", mSubType = "GoldenFingerWindow", mAction = WINDOW_HIDE, mData = nil}

GUISYSTEM_SHOW_RANKINGWINDOW = { mType = "GUISYSTEM", mSubType = "RankingWindow", mAction = WINDOW_SHOW, mData = nil}
GUISYSTEM_HIDE_RANKINGWINDOW = { mType = "GUISYSTEM", mSubType = "RankingWindow", mAction = WINDOW_HIDE, mData = nil}

GUISYSTEM_SHOW_WORKPOSITIONWINDOW = { mType = "GUISYSTEM", mSubType = "WorkPositionWindow", mAction = WINDOW_SHOW, mData = nil}
GUISYSTEM_HIDE_WORKPOSITIONWINDOW = { mType = "GUISYSTEM", mSubType = "WorkPositionWindow", mAction = WINDOW_HIDE, mData = nil}

GUISYSTEM_SHOW_FRIENDWINDOW = { mType = "GUISYSTEM", mSubType = "FriendWindow", mAction = WINDOW_SHOW, mData = nil}
GUISYSTEM_HIDE_FRIENDWINDOW = { mType = "GUISYSTEM", mSubType = "FriendWindow", mAction = WINDOW_HIDE, mData = nil}

GUISYSTEM_SHOW_TASKWINDOW = { mType = "GUISYSTEM", mSubType = "TaskWindow", mAction = WINDOW_SHOW, mData = nil}
GUISYSTEM_HIDE_TASKWINDOW = { mType = "GUISYSTEM", mSubType = "TaskWindow", mAction = WINDOW_HIDE, mData = nil}

GUISYSTEM_SHOW_HEROCHANGEWINDOW = { mType = "GUISYSTEM", mSubType = "HeroChangeWindow", mAction = WINDOW_SHOW, mData = nil}
GUISYSTEM_HIDE_HEROCHANGEWINDOW = { mType = "GUISYSTEM", mSubType = "HeroChangeWindow", mAction = WINDOW_HIDE, mData = nil}

GUISYSTEM_SHOW_HOMESHOPWINDOW = { mType = "GUISYSTEM", mSubType = "HomeShopWindow", mAction = WINDOW_SHOW, mData = nil}
GUISYSTEM_HIDE_HOMESHOPWINDOW = { mType = "GUISYSTEM", mSubType = "HomeShopWindow", mAction = WINDOW_HIDE, mData = nil}

GUISYSTEM_SHOW_DAILYREWARDWINDOW = { mType = "GUISYSTEM", mSubType = "DailyRewardWindow", mAction = WINDOW_SHOW, mData = nil}
GUISYSTEM_HIDE_DAILYREWARDWINDOW = { mType = "GUISYSTEM", mSubType = "DailyRewardWindow", mAction = WINDOW_HIDE, mData = nil}

GUISYSTEM_SHOW_PLAYERSETTINGWINDOW = { mType = "GUISYSTEM", mSubType = "PlayerSettingWindow", mAction = WINDOW_SHOW, mData = nil}
GUISYSTEM_HIDE_PLAYERSETTINGWINDOW = { mType = "GUISYSTEM", mSubType = "PlayerSettingWindow", mAction = WINDOW_HIDE, mData = nil}

GUISYSTEM_SHOW_GAME2048WINDOW = { mType = "GUISYSTEM", mSubType = "Game2048Window", mAction = WINDOW_SHOW, mData = nil}
GUISYSTEM_HIDE_GAME2048WINDOW = { mType = "GUISYSTEM", mSubType = "Game2048Window", mAction = WINDOW_HIDE, mData = nil}

GUISYSTEM_SHOW_WEALTHWINDOW = { mType = "GUISYSTEM", mSubType = "WealthWindow", mAction = WINDOW_SHOW, mData = nil}
GUISYSTEM_HIDE_WEALTHWINDOW = { mType = "GUISYSTEM", mSubType = "WealthWindow", mAction = WINDOW_HIDE, mData = nil}
GUISYSTEM_EABLEDRAW_WEALTHWINDOW = { mType = "GUISYSTEM", mSubType = "WealthWindow", mAction = WINDOW_ENABLE_DRAW, mData = nil}
GUISYSTEM_DISABLEDRAW_WEALTHWINDOW = { mType = "GUISYSTEM", mSubType = "WealthWindow", mAction = WINDOW_DISABLE_DRAW, mData = nil}


GUISYSTEM_SHOW_FUCKWINDOW = { mType = "GUISYSTEM", mSubType = "FuckWindow", mAction = WINDOW_SHOW, mData = nil}
GUISYSTEM_HIDE_FUCKWINDOW = { mType = "GUISYSTEM", mSubType = "FuckWindow", mAction = WINDOW_HIDE, mData = nil}

GUISYSTEM_SHOW_LADDERWINDOW = { mType = "GUISYSTEM", mSubType = "LadderWindow", mAction = WINDOW_SHOW, mData = nil}
GUISYSTEM_HIDE_LADDERWINDOW = { mType = "GUISYSTEM", mSubType = "LadderWindow", mAction = WINDOW_HIDE, mData = nil}

GUISYSTEM_SHOW_LADDERLOADINGWINDOW = { mType = "GUISYSTEM", mSubType = "LadderLoadingWindow", mAction = WINDOW_SHOW, mData = nil}
GUISYSTEM_HIDE_LADDERLOADINGWINDOW = { mType = "GUISYSTEM", mSubType = "LadderLoadingWindow", mAction = WINDOW_HIDE, mData = nil}

GUISYSTEM_SHOW_CARDGAMEWINDOW = { mType = "GUISYSTEM", mSubType = "CardGameWindow", mAction = WINDOW_SHOW, mData = nil}
GUISYSTEM_HIDE_CARDGAMEWINDOW = { mType = "GUISYSTEM", mSubType = "CardGameWindow", mAction = WINDOW_HIDE, mData = nil}

GUISYSTEM_SHOW_LADDERRESULTWINDOW = { mType = "GUISYSTEM", mSubType = "LadderResultWindow", mAction = WINDOW_SHOW, mData = nil}
GUISYSTEM_HIDE_LADDERRESULTWINDOW  = { mType = "GUISYSTEM", mSubType = "LadderResultWindow", mAction = WINDOW_HIDE, mData = nil}

GUISYSTEM_SHOW_BASKETBALLWINDOW = { mType = "GUISYSTEM", mSubType = "BasketBallWindow", mAction = WINDOW_SHOW, mData = nil}
GUISYSTEM_HIDE_BASKETBALLWINDOW = { mType = "GUISYSTEM", mSubType = "BasketBallWindow", mAction = WINDOW_HIDE, mData = nil}

GUISYSTEM_SHOW_ROUNDGAMEWINDOW = { mType = "GUISYSTEM", mSubType = "RoundGameWindow", mAction = WINDOW_SHOW, mData = nil}
GUISYSTEM_HIDE_ROUNDGAMEWINDOW = { mType = "GUISYSTEM", mSubType = "RoundGameWindow", mAction = WINDOW_HIDE, mData = nil}

GUISYSTEM_SHOW_PARTYWINDOW = { mType = "GUISYSTEM", mSubType = "PartyWindow", mAction = WINDOW_SHOW, mData = nil}
GUISYSTEM_HIDE_PARTYWINDOW  = { mType = "GUISYSTEM", mSubType = "PartyWindow", mAction = WINDOW_HIDE, mData = nil}

GUISYSTEM_SHOW_IAPWINDOW = { mType = "GUISYSTEM", mSubType = "IAPWindow", mAction = WINDOW_SHOW, mData = nil}
GUISYSTEM_HIDE_IAPWINDOW  = { mType = "GUISYSTEM", mSubType = "IAPWindow", mAction = WINDOW_HIDE, mData = nil}

GUISYSTEM_SHOW_BLACKMARKETWINDOW = { mType = "GUISYSTEM", mSubType = "BlackMarketWindow", mAction = WINDOW_SHOW, mData = nil}
GUISYSTEM_HIDE_BLACKMARKETWINDOW  = { mType = "GUISYSTEM", mSubType = "BlackMarketWindow", mAction = WINDOW_HIDE, mData = nil}
GUISYSTEM_EABLEDRAW_BLACKMARKETWINDOW = { mType = "GUISYSTEM", mSubType = "BlackMarketWindow", mAction = WINDOW_ENABLE_DRAW, mData = nil}
GUISYSTEM_DISABLEDRAW_BLACKMARKETWINDOW = { mType = "GUISYSTEM", mSubType = "BlackMarketWindow", mAction = WINDOW_DISABLE_DRAW, mData = nil}

GUISYSTEM_SHOW_HEROGUESSWINDOW = { mType = "GUISYSTEM", mSubType = "HeroGuessWindow", mAction = WINDOW_SHOW, mData = nil}
GUISYSTEM_HIDE_HEROGUESSWINDOW  = { mType = "GUISYSTEM", mSubType = "HeroGuessWindow", mAction = WINDOW_HIDE, mData = nil}

GUISYSTEM_SHOW_TECHNOLOGYWINDOW = { mType = "GUISYSTEM", mSubType = "TechnologyWindow", mAction = WINDOW_SHOW, mData = nil}
GUISYSTEM_HIDE_TECHNOLOGYWINDOW  = { mType = "GUISYSTEM", mSubType = "TechnologyWindow", mAction = WINDOW_HIDE, mData = nil}

GUISYSTEM_SHOW_GANGWARSWINDOW = { mType = "GUISYSTEM", mSubType = "GangWarsWindow", mAction = WINDOW_SHOW, mData = nil}
GUISYSTEM_HIDE_GANGWARSWINDOW = { mType = "GUISYSTEM", mSubType = "GangWarsWindow", mAction = WINDOW_HIDE, mData = nil}
GUISYSTEM_EABLEDRAW_GANGWARSWINDOW = { mType = "GUISYSTEM", mSubType = "GangWarsWindow", mAction = WINDOW_ENABLE_DRAW, mData = nil}
GUISYSTEM_DISABLEDRAW_GANGWARSWINDOW = { mType = "GUISYSTEM", mSubType = "GangWarsWindow", mAction = WINDOW_DISABLE_DRAW, mData = nil}


GUISYSTEM_SHOW_PARTYJOINWINDOW = { mType = "GUISYSTEM", mSubType = "PartyJoinWindow", mAction = WINDOW_SHOW, mData = nil}
GUISYSTEM_HIDE_PARTYJOINWINDOW = { mType = "GUISYSTEM", mSubType = "PartyJoinWindow", mAction = WINDOW_HIDE, mData = nil}

GUISYSTEM_SHOW_PARTYMAINWINDOW = { mType = "GUISYSTEM", mSubType = "PartyMainWindow", mAction = WINDOW_SHOW, mData = nil}
GUISYSTEM_HIDE_PARTYMAINWINDOW = { mType = "GUISYSTEM", mSubType = "PartyMainWindow", mAction = WINDOW_HIDE, mData = nil}

GUISYSTEM_SHOW_PARTYBUILDWINDOW = { mType = "GUISYSTEM", mSubType = "PartyBuildWindow", mAction = WINDOW_SHOW, mData = nil}
GUISYSTEM_HIDE_PARTYBUILDWINDOW = { mType = "GUISYSTEM", mSubType = "PartyBuildWindow", mAction = WINDOW_HIDE, mData = nil}

GUISYSTEM_SHOW_PARTYSKILLWINDOW = { mType = "GUISYSTEM", mSubType = "PartySkillWindow", mAction = WINDOW_SHOW, mData = nil}
GUISYSTEM_HIDE_PARTYSKILLWINDOW = { mType = "GUISYSTEM", mSubType = "PartySkillWindow", mAction = WINDOW_HIDE, mData = nil}

GUISYSTEM_SHOW_PARTYHELLOWINDOW = { mType = "GUISYSTEM", mSubType = "PartyHelloWindow", mAction = WINDOW_SHOW, mData = nil}
GUISYSTEM_HIDE_PARTYHELLOWINDOW = { mType = "GUISYSTEM", mSubType = "PartyHelloWindow", mAction = WINDOW_HIDE, mData = nil}

GUISYSTEM_SHOW_POKERWINDOW = { mType = "GUISYSTEM", mSubType = "PokerWindow", mAction = WINDOW_SHOW, mData = nil}
GUISYSTEM_HIDE_POKERWINDOW = { mType = "GUISYSTEM", mSubType = "PokerWindow", mAction = WINDOW_HIDE, mData = nil}

GUISYSTEM_SHOW_CHANGEHEROICONWINDOW = { mType = "GUISYSTEM", mSubType = "ChangeHeroIconWindow", mAction = WINDOW_SHOW, mData = nil}
GUISYSTEM_HIDE_CHANGEHEROICONWINDOW = { mType = "GUISYSTEM", mSubType = "ChangeHeroIconWindow", mAction = WINDOW_HIDE, mData = nil}

GUISYSTEM_SHOW_WORLDBOSSWINDOW = { mType = "GUISYSTEM", mSubType = "WorldBossWindow", mAction = WINDOW_SHOW, mData = nil}
GUISYSTEM_HIDE_WORLDBOSSWINDOW = { mType = "GUISYSTEM", mSubType = "WorldBossWindow", mAction = WINDOW_HIDE, mData = nil}
GUISYSTEM_EABLEDRAW_WORLDBOSSWINDOW = { mType = "GUISYSTEM", mSubType = "WorldBossWindow", mAction = WINDOW_ENABLE_DRAW, mData = nil}
GUISYSTEM_DISABLEDRAW_WORLDBOSSWINDOW = { mType = "GUISYSTEM", mSubType = "WorldBossWindow", mAction = WINDOW_DISABLE_DRAW, mData = nil}

GUISYSTEM_SHOW_WORLDBOSSRESULTWINDOW = { mType = "GUISYSTEM", mSubType = "WorldBossResultWindow", mAction = WINDOW_SHOW, mData = nil}
GUISYSTEM_HIDE_WORLDBOSSRESULTWINDOW = { mType = "GUISYSTEM", mSubType = "WorldBossResultWindow", mAction = WINDOW_HIDE, mData = nil}

GUISYSTEM_SHOW_HEROBEAUTIFYWINDOW = { mType = "GUISYSTEM", mSubType = "HeroBeautifyWindow", mAction = WINDOW_SHOW, mData = nil}
GUISYSTEM_HIDE_HEROBEAUTIFYWINDOW = { mType = "GUISYSTEM", mSubType = "HeroBeautifyWindow", mAction = WINDOW_HIDE, mData = nil}

GUISYSTEM_SHOW_TOWEREXWINDOW = { mType = "GUISYSTEM", mSubType = "TowerExWindow", mAction = WINDOW_SHOW, mData = nil}
GUISYSTEM_HIDE_TOWEREXWINDOW = { mType = "GUISYSTEM", mSubType = "TowerExWindow", mAction = WINDOW_HIDE, mData = nil}
GUISYSTEM_EABLEDRAW_TOWEREXWINDOW = { mType = "GUISYSTEM", mSubType = "TowerExWindow", mAction = WINDOW_ENABLE_DRAW, mData = nil}
GUISYSTEM_DISABLEDRAW_TOWEREXWINDOW = { mType = "GUISYSTEM", mSubType = "TowerExWindow", mAction = WINDOW_DISABLE_DRAW, mData = nil}


GUISYSTEM_SHOW_HEROTITLEWINDOW = { mType = "GUISYSTEM", mSubType = "HeroTitleWindow", mAction = WINDOW_SHOW, mData = nil}
GUISYSTEM_HIDE_HEROTITLEWINDOW = { mType = "GUISYSTEM", mSubType = "HeroTitleWindow", mAction = WINDOW_HIDE, mData = nil}

GUISYSTEM_SHOW_HORSEANDGUNWINDOW = { mType = "GUISYSTEM", mSubType = "HorseAndGunWindow", mAction = WINDOW_SHOW, mData = nil}
GUISYSTEM_HIDE_HORSEANDGUNWINDOW = { mType = "GUISYSTEM", mSubType = "HorseAndGunWindow", mAction = WINDOW_HIDE, mData = nil}

GUISYSTEM_SHOW_HEROSKILLWINDOW = { mType = "GUISYSTEM", mSubType = "HeroSkillWindow", mAction = WINDOW_SHOW, mData = nil}
GUISYSTEM_HIDE_HEROSKILLWINDOW = { mType = "GUISYSTEM", mSubType = "HeroSkillWindow", mAction = WINDOW_HIDE, mData = nil}

GUISYSTEM_SHOW_BADGEWINDOW = { mType = "GUISYSTEM", mSubType = "BadgeWindow", mAction = WINDOW_SHOW, mData = nil}
GUISYSTEM_HIDE_BADGEWINDOW = { mType = "GUISYSTEM", mSubType = "BadgeWindow", mAction = WINDOW_HIDE, mData = nil}
--
--
-- SOUND EVENT
--
SOUNDSYS_BGM_PLAY = { mType = "SOUNDSYSTEM", mSubType = nil, mAction = tSOUND_BGM_PLAY, mData = nil}
SOUNDSYS_BGM_STOP = { mType = "SOUNDSYSTEM", mSubType = nil, mAction = tSOUND_BGM_STOP, mData = nil}
SOUNDSYS_BGM_CHANGE = { mType = "SOUNDSYSTEM", mSubType = nil, mAction = tSOUND_BGM_CHANGE, mData = nil}
SOUNDSYS_EFFECT_PLAY = { mType = "SOUNDSYSTEM", mSubType = nil, mAction = tSOUND_EFFECT_PLAY, mData = nil}
SOUNDSYS_EFFECT_STOP = { mType = "SOUNDSYSTEM", mSubType = nil, mAction = tSOUND_EFFECT_STOP, mData = nil}
SOUNDSYS_EFFECTALL_STOP = { mType = "SOUNDSYSTEM", mSubType = nil, mAction = tSOUND_EFFECTALL_STOP, mData = nil}
SOUNDSYS_EFFECT_PRELOAD = { mType = "SOUNDSYSTEM", mSubType = nil, mAction = tSOUND_EFFECT_PRELOAD, mData = nil}
SOUNDSYS_BGM_PRELOAD = { mType = "SOUNDSYSTEM", mSubType = nil, mAction = tSOUND_BGM_PRELOAD, mData = nil}


function release()
	cclog("Event:release1")
	_G["Event"] = nil
	package.loaded["Event"] = nil
	package.loaded["EventSystem/Event"] = nil
	cclog("Event:release2")
end