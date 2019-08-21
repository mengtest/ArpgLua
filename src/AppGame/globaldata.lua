-- Name: 	globaldata.lua
-- Func：	全局数据, 管理收发游戏中主要的数据
-- Author:	WangShengdong
-- Data:	14-12-20

require "AppGame/Common"
require "GUISystem/Shabi"

-- 是否需要新手指引
needUseGuide = false

globaldata = {}

globaldata.mSkillAnimTag = false -- 添加一个标志位,胜东 2016-2-2

globaldata.gameperformance = false
-- 还原数据
-- 希望在退出登录被还原的数据写到这里
function globaldata:resetAllData()
	cclog("globaldata:resetAllData")
	self:clearRankData()
	self.mealStateArr 				= {1,1,1}
	self.curLvRewardInfo.idx        = 1
    self.curLvRewardInfo.state      = 0
   	self.showguanqialayer 			= false
end

function globaldata:clearRankData()
	globaldata.selfRank             = {{-1,-1,-1,-1},{-1},{-1},}
	globaldata.rankLength			= {{-1,-1,-1,-1},{-1},{-1},}
	globaldata.rankArr 				= { 
									{{},{},{},{},},
									{{},},
									{{},},
								   } 
end

-------------------------------------------------type-begin------------------------------------------
-- 英雄进阶消耗物品对象
local heroAdvancedCost ={}
function heroAdvancedCost:new()
	local o =
	{
		itemType = 0,  -- 物品类型  0:物品 1:装备 2:金钱 3:钻石 4:经验 5:体力 6:耐力
		itemId   = 0,  -- 物品Id 当物品类型为 2,3,4,5,6时为0
		itemNum  = 0,  -- 物品数量
	}
	o = newObject(o, heroAdvancedCost)
	return o
end

-- 英雄专属武器
heroWeaponObject = {}
function heroWeaponObject:new()
	local o = 
	{
		mId 		=	0,	-- ID
		mLevel 		=	0,	-- 等级
		mMoney		=	0,	-- 升级所需金钱
		mItemCnt 	=	0,  -- 升级所需物品数量
	}
	o = newObject(o, heroWeaponObject)
	return o
end

-- 英雄对象
local heroObject = {}
function heroObject:new()
	local o = 
	{
		guid 		 	= 	"",			-- GUID
		index		 	=	0,			-- 阵容中位置
		combat			=	0,			-- 战斗力
		id		 	 	=	0,			-- 类型Id
		name 			=	"",			-- 英雄名字
		level 		 	=	0,			-- 等级
		exp 		 	=	0,			-- 经验
		maxExp 		 	=	0,			-- 最大经验
		advanceLevel 	=	0,			-- 英雄进阶等级
		quality			=	0,			-- 当前品质
		chipId			=	0,			-- 对应的碎片Id
		chipCount		=	0,			-- 需要的碎片数量
		isMaxAdvancedLv =   0,			-- 是否达到最大进阶等级 0:是，1：不是
		nextAdvancedLv  =   0,			-- 下一进阶等级
		advancedCostList    =   {},		-- 进阶消耗物品列表
		growPropCount	=	0,			-- 英雄成长属性数量
		growPropList	=	{},			-- 英雄成长属性列表
		propCount 		=	0,			-- 英雄属性数量
		propList 		=	{},			-- 英雄属性列表
		propListEx		=	{},			-- 英雄属性增强
		equipCount		=	0,			-- 英雄装备数量
		equipList 		=	{},			-- 装备链表
		skillCount		=	0,			-- 技能数量
		skillList 		=	{}, 		-- 技能链表
		changeColorCount=	0,
		changeColorList =	{}, 		-- 染色链表
		talentPointCount	=	nil,	-- 剩余天赋点数
		talentOwnCount	=	nil,		-- 已经拥有的天赋
		talentOwnList	=	{},			-- 已经拥有的天赋链表
		weapon 			=	nil,		-- 专属武器
	}
	o = newObject(o, heroObject)
	return o
end

function heroObject:getKeyValue(key)
	if self[key] then
		return self[key]
	end
	return nil
end

-- 技能对象
skillObject = {}
function skillObject:new()
	local o = 
	{
		mSkillId		=	nil,	-- 技能ID
		mSkillType		=	nil,	-- 技能类型
		mSkillIndex 	= 	nil,	-- 技能序号
		mSkillSelected	=	nil, 	-- 技能选择  0:选中 1:没选中
		mSkillLevel		=	nil,	-- 技能等级
		mPrice			=	nil,	-- 价格
	}
	o = newObject(o, skillObject)
	return o
end

function skillObject:getKeyValue(key)
	if self[key] then
		return self[key]
	end
	return nil
end

-- 阵位对象
local posObject = {}
function posObject:new()
	local o = 
	{
		guid 			= 	0,			-- 该位置的英雄guid
	}
	o = newObject(o, posObject)
	return o
end

function posObject:getKeyValue(key)
	if self[key] then
		return self[key]
	end
	return nil
end

local strengthGoodObject = {}
function strengthGoodObject:new()
	local o = 
	{
		mType 	=	nil,
		mId 	=	nil,
		mCount 	=	nil,
	}
	o = newObject(o, strengthGoodObject)
	return o
end

function strengthGoodObject:getKeyValue(key)
	if self[key] then
		return self[key]
	end
	return nil
end

-- 装备对象
local equipObject = {}
function equipObject:new()
	local o = 
	{
		guid 				= "",				-- GUID
		id   				= 0,				-- 类型Id
		type				= 0,				-- 装备位类型
		level 				= 0,				-- 装备等级
		quality 			= 0,				-- 装备品质
		qualityAddValue		= 0,				-- 装备品质附加值
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

-- 抽卡对象
local lotteryObject = {}
function lotteryObject:new()
	local o = 
	{
		id 					= 	0,	-- 类型Id
		freeNum 			= 	-1,	-- 今日剩余免费次数
		freeMaxNum			=	-1,	-- 每日最大免费次数
		leftTime			=	0,	-- 距离下次免费时间(秒)
		onceCostType		=	0,	-- 一连抽花费物品类型
		onceCostId			=	0,	-- 一连抽花费物品Id
		onceCostNum			=	0,	-- 一连抽花费物品数量
		onceSecretAdd	=	0, 	-- 一连丑赠送神秘币
		tenthCostType		=	0,	-- 十连抽花费物品类型
		tenthCostId			=	0,	-- 十连抽花费物品Id
		tenthCostNum		=	0,	-- 十连抽花费物品数量
		tenthSecretAdd	=	0, 	-- 一连丑赠送神秘币
	}
	o = newObject(o, lotteryObject)
	return o
end

-- 物品对象
local itemObject = {}
function itemObject:new()
	local o = 
	{
		itemId 		= 	nil,	-- 物品Id
		itemType 	= 	nil,	-- 物品类型
		itemNum		= 	0,		-- 物品数量
	}
	o = newObject(o, itemObject)
	return o
end

function itemObject:getKeyValue(key)
	if self[key] then
		return self[key]
	end
	return nil
end

-- 商品对象
local goodsObject = {}
function goodsObject:new()
	local o = 
	{
		goodsIndex				=	nil,	-- 货架顺序
		goodsType				=	nil,	-- 1:装备 2:物品
		goodsId 				=	nil,	-- 商品Id
		goodsCurrencyType		=	nil,	-- 消耗货币类型		0:金钱 1:钻石 2:物品
		goodsPrice				=	nil,	-- 价格
		goodsConditionType		=	nil,	-- 限制条件类型		0:无 1:玩家等级 2:VIP等级
		goodsConditionParam 	=	nil,	-- 条件参数
		goodsMaxBuyLimitPerDay	=	nil,	-- 每日最大购买数量
		goodsMaxBuyCount		=	nil,	-- 每次购买的最大数量
	}
	o = newObject(o, goodsObject)
	return o
end

function goodsObject:getKeyValue(key)
	if self[key] then
		return self[key]
	end
	return nil
end

-- 阵容对象
local battleObject = {}
function battleObject:new()
	local o = 
	{
		index 		=	nil,
		guid 		= 	nil,
		id 	 		= 	nil,
		skillList   =   {},
		propCount 	= 	0,
		propList 	=	{},
	}
	o = newObject(o, battleObject)
	return o
end

function battleObject:getKeyValue(key)
	if self[key] then
		return self[key]
	end
	return nil
end

-- 打工对象
local workerObject = {}
function workerObject:new()
	local o = 
	{
		mWorkType 		= nil,	-- 1:音乐	2:美术	3:体育
		mWorkHeroGuid	= nil,	-- 打工者Guid
		mWorkHeroId 	= nil,  -- 打工者Id
		mLeftTime 		= 0,	-- 剩余打工时间
		mItemType		= nil,  -- 奖励物品类型
		mItemId 		= nil,	-- 奖励物品Id
		mItemCount 		= 0,	-- 获得奖励数量
		mTotleCount     = 0,	-- 奖励总数量
		mSchedulerEntry	= nil,	-- 定时器
		mWidget	= nil,
	}
	o = newObject(o, workerObject)
	return o
end

function workerObject:init()
	if not self.mSchedulerEntry then
		local scheduler = cc.Director:getInstance():getScheduler()
		self.mSchedulerEntry = scheduler:scheduleScriptFunc(handler(self, self.tick), 1, false)
	end
end

function workerObject:setWidget(widget)
	self.mWidget = widget
	local timeVal = secondToHour(self.mLeftTime)
	self.mWidget:getChildByName("Label_Time") :setString(string.format("剩余 %s",timeVal))
	--if self.mLeftTime == 0 then
	--	self.mWidget:getChildByName("Button_Leave"):setVisible(true)
	--	self.mWidget:getChildByName("Label_22"):setString("领取")
	--end
end

function workerObject:cleanWidget()
	self.mWidget = nil
end

function workerObject:tick()
	if self.mLeftTime > 0 then
		self.mLeftTime = self.mLeftTime - 1
		local timeVal = secondToHour(self.mLeftTime)
		if self.mWidget then
			self.mWidget:getChildByName("Label_Time") :setString(string.format("剩余 %s",timeVal))
		end
	else
		if self.mWidget then
			self.mWidget:getChildByName("Button_Leave"):setVisible(true)
			self.mWidget:getChildByName("Label_22"):setString("领取")
			--self.mWidget:getChildByName("Button_Get"):setVisible(true)
		end
		self:destroy()
	end
end

function workerObject:destroy()
	if self.mSchedulerEntry then
		local scheduler = cc.Director:getInstance():getScheduler()
		scheduler:unscheduleScriptEntry(self.mSchedulerEntry)
		self.mSchedulerEntry = nil
	end
end

function workerObject:getKeyValue(key)
	if self[key] then
		return self[key]
	end
	return nil
end

-- 好感度英雄
local favorHero = {}
function favorHero:new()
	local o = 
	{
		heroId 			= nil,
		favorLevel 		= 0,
		favorValue 		= 0,
		favorMaxValue 	= 0, 
	}
	o = newObject(o, favorHero)
	return o
end

function favorHero:getKeyValue(key)
	if self[key] then
		return self[key]
	end
	return nil
end

-- 章节对象
local chapterObject = {}
function chapterObject:new()
	local o = 
	{
		mChapterId		=	nil,	-- 章节Id
		mSectionList	=	{},		-- 关卡列表
		mCurStarCount	=	0,		-- 当前星星数
		mTotalStarCount	=	24,		-- 总的星星数
		mType 			=	0,		-- 关卡类型
		mStarReward		=	{}, 	-- 星星奖励状态  		-- 0:不可领取 1:可领取 2:已经领取
	}
	o = newObject(o, chapterObject)
	return o
end

function chapterObject:getKeyValue(key)
	if self[key] then
		return self[key]
	end
	return nil
end

function chapterObject:getCurStarCount()
	local count = 0
	for i = 1, #self.mSectionList do
		count = count + self.mSectionList[i]:getKeyValue("mCurStarCount")
	end
	return count
end

-- 关卡对象
local sectionObject = {}
function sectionObject:new()
	local o = 
	{
		mSectionId 				=	nil, 	-- 关卡Id
		mCurStarCount 			=	0, 		-- 获得星星数
		mLeftChanllengeCount	=	0, 		-- 剩余挑战次数
		mTotalChallengeCount 	=	0, 		-- 总的挑战次数
	}
	o = newObject(o, sectionObject)
	return o
end

function sectionObject:getKeyValue(key)
	if self[key] then
		return self[key]
	end
	return nil
end

-- 家具对象
furnitObject = {}
function furnitObject:new()
	local o = 
	{
		mGuid 	= 	nil, 	-- GUID
		mId 	= 	nil,	-- ID
		mPosX 	=	nil, 	-- X坐标
		mPosY 	=	nil,	-- Y坐标
	}
	o = newObject(o, furnitObject)
	return o
end

globaldata.GangData = {}
-- 帮会排名对象
local BanghuirankObject = {}
function BanghuirankObject:new()
	local o = 
	{
		mBanghuiName = 	nil, 	-- 帮会名
		mScore 	= 	nil,	-- 积分
	}
	o = newObject(o, BanghuirankObject)
	return o
end

-- 帮会房间对象
local BanghuiTeamObject = {}
function BanghuiTeamObject:new()
	local o = 
	{
		mBanghuiRoomId = 	nil, 	-- 帮会名
		mBanghuiTeamCount 	= 	nil,	-- 积分
		mBanghuiList = {},
	}
	o = newObject(o, BanghuiTeamObject)
	return o
end

-- 房间一个位置的信息
local BanghuiPlayerInfo = {}
function BanghuiPlayerInfo:new()
	local o = 
	{
		mPlayerId = 	nil, 	-- 帮会名
		mPlayerName 	= 	nil,	-- 积分
		mFightHeroId = nil,
		mFightHeroLevel = nil,
		mFightHeroquality = nil,
		mFightHeroadvanceLv = nil,
		mIsLeader = nil,
		mIsReady = nil,
	}
	o = newObject(o, BanghuiPlayerInfo)
	return o
end


-------------------------------------------------type-end------------------------------------------

-------------------------------------------------data-begin------------------------------------------

-- 好友切磋开关
globaldata.friendPlayerPK = false
-- 玩家主角英雄ID
globaldata.leaderHeroId	= nil
-- 玩家总战力
globaldata.playerCombat = 0
-- 玩家ID
globaldata.playerId = ""
-- 玩家名称
globaldata.name = ""
-- 玩家当前等级
globaldata.level = 0
-- 玩家当前经验值
globaldata.exp = 0
-- 玩家最大经验值
globaldata.maxExp = 0
-- 玩家体力
globaldata.vatality = 0
-- 最大体力
globaldata.maxVatality = 0
-- 耐力
globaldata.naili = 0
-- 神秘币
globaldata.shenmi = 0
-- 金钱
globaldata.money = 0
-- 钻石
globaldata.diamond = 0
-- 帮会贡献度
globaldata.partyMoney = 0
-- 天梯货币
globaldata.tiantiMoney = 0
-- 游乐园货币
globaldata.towerMoney =	0
-- VIP等级
globaldata.vipLevel = 0
-- 帮会id
globaldata.partyId = ""
-- 帮会名字
globaldata.partyName = ""
-- 已经冲的钻石数
globaldata.diamondAlreadyGet = 0
-- 下一个VIP等级
globaldata.nextVipLevel = 0
-- 下一等级需要冲的钻石数
globaldata.nextVipNeedDiamondCount = 0
-- VIP经验百分比
globaldata.vipPercent = 0
-- VIP礼包
globaldata.vipGiftList = {}
-- 保存修改之前的数据
globaldata.preBaseData = {}
-- 上阵英雄数量
globaldata.battleCount = 0
-- 上阵英雄
globaldata.battleTeam = {}
-- 拥有英雄总数量
globaldata.heroCount = 0
-- 所有英雄
globaldata.heroTeam = {}
-- 抽卡总类型数
globaldata.lotteryCount = 0
-- 抽卡类型数组
globaldata.lotteryList = {}
-- 物品链表
globaldata.itemList = 
{
	{},
	{},
	{},
	{},
	{},
	{},
}
-- 商城刷新时间
globaldata.ShopFreshTime = {}
-- 商城商品列表
globaldata.ShopGoodsList = {}
-- 声望商店商品列表
globaldata.ShengwangGoodsList = {}
-- 神秘商店商品列表
globaldata.ShenmiGoodsList = {}
-- 家具商店商品列表
globaldata.FurnitGoodsList = {}
-- 宝石商店商品列表
globaldata.DiamondGoodsList = {}
-- 帮会商店商品列表
globaldata.PartyGoodsList = {}
-- 天梯商店商品列表
globaldata.TiantiGoodsList = {}
-- 未穿着装备列表
globaldata.equipList = {}
-- Q&A类型
globaldata.QAType = nil
-- Q&A参数个数
globaldata.QAParamNum = 0
-- Q&A回答参数
globaldata.QAParamList = {}
-- 洗练价格
globaldata.xilianPriceList = {}
-- 强化价格
globaldata.qianghuaPriceList = {}
-- 阵容列表
globaldata.battleFormation = {}
-- 阵容英雄数量
globaldata.battleFormationCount = 0
-- 怪物数量
globaldata.monsterCount = 0
-- 怪物列表
globaldata.monsterList = {}

-- 音乐
globaldata.workers = {}
globaldata.workers[1] = {}
globaldata.workers[2] = {}
globaldata.workers[3] = {}

-- 英雄图鉴
globaldata.heroBook = {}

-- 城镇大厅数据
globaldata.cityhalldata = 
{
    cityid = 0,
    subserver = 0,
    posx = 0,
    posy = 0,
    direction = 0,
    opcount = 0,
}

globaldata.btnMap = 
{
	-- chuangguan 	= 	nil,				-- 闯关
	yuehui		=	nil, 				-- 约会
	pve 		=	"Button_Adventure", 		-- PVE
	shangcheng 	=	"Button_Shop",  	-- 商城
	dagong 		=	"Button_Activity", 	-- 打工
	equip 		=	"Button_Equip", 	-- 装备
	arena 		=	"Button_Arena", 		-- 竞技场
	bagpack 	=	"Button_Bagpack", 	-- 背包
	hero 		=	"Button_HeroList", 		-- 英雄
	lottery 	=	"Button_Get", 		-- 抽卡
	mail 		=	"Button_Mail", 		-- 邮件
}

globaldata.funcMap = 
{
	-- chuangguan 	= 	true,	-- 闯关
	yuehui		=	true, 	-- 约会
	pve 		=	true, 	-- PVE
	shangcheng 	=	true,   -- 商城
	dagong 		=	true, 	-- 打工
	equip 		=	true, 	-- 装备
	arena 		=	true, 	-- 竞技场
	bagpack 	=	true, 	-- 背包
	hero 		=	true, 	-- 英雄
	lottery 	=	true, 	-- 抽卡
	mail 		=	true, 	-- 邮件
}

-- 当前正在进行的章节Id
globaldata.curChapterId		    = {}

-- 当前正在进行的关卡Id
globaldata.curSectionId 	    = {}

globaldata.chapterList          = {}

-- 未放置家具
globaldata.furnitListOutHouse 	= {}

-- 已放置家具
globaldata.furnitListInHouse 	= {}

-- 防守阵容
globaldata.defendHeroList       = {}

-- 进攻阵容
globaldata.attackHeroList 		= {}

-- 同步的任务
globaldata.syncTaskInfo         = nil

--财富山结算
globaldata.wealthType 			= 0		-- 1,2,3 mapid
globaldata.wealthBattleHeros      = {}
globaldata.towerBattleHeros       = {}
globaldata.towerExBattleHeros     = {}

globaldata.curLvRewardInfo        = {idx = 1,state = 0}

--rank cache
globaldata.selfRank             = {{-1,-1,-1,-1},{-1},{-1},}
globaldata.rankLength			= {{-1,-1,-1,-1},{-1},{-1},}
globaldata.rankArr 				= { 
									{{},{},{},{},},
									{{},},
									{{},},
								   } 

globaldata.mealStateArr          = {1,1,1} -- MEAL_NOTREADY = 1,MEAL_READY = 2,MEAL_EATED = 3,MEAL_TIMEOUT = 4

--黑市
globaldata.blackMarketBattleHeros = {}
globaldata.bmTaskid               = nil
globaldata.bmTaskIdx              = nil
globaldata.bmPlayerid             = nil
-- 时装
globaldata.fashionEquipCnt = nil
globaldata.fashionEquipList = {}
-------------------------------------------------data-end------------------------------------------
-------------------------------------------------func-begin------------------------------------------

-- 更新防守阵容信息
function globaldata:updateDefendFormationInfoFromServer(msgPacket)
	self.defendHeroList = {}

	local count = msgPacket:GetUShort()
	for i = 1, count do
	--	local posIndex = msgPacket:GetChar()
	--	local heroIndex = msgPacket:GetChar()
		self.defendHeroList[i] = msgPacket:GetInt()
	end
end

-- 更新进攻阵容信息
function globaldata:updateAttackFormationInfoFromServer(msgPacket)
	self.attackHeroList = {}

	local count = msgPacket:GetUShort()
	for i = 1, count do
	--	local posIndex = msgPacket:GetChar()
	--	local heroIndex = msgPacket:GetChar()
	--	self.attackHeroList[posIndex] = heroIndex
		self.attackHeroList[i] = msgPacket:GetInt()
	end
end

-- 判断指定位置是否在防守阵容中
function globaldata:isIndexInDefendFormation(index)
	for i = 1, #self.defendHeroList do
		if index == self.defendHeroList[i] then
			return true
		end
	end
	return false
end

-- 判断指定位置是否在进攻阵容中
function globaldata:isIndexInAttackFormation(index)
	for i = 1, #self.attackHeroList do
		if index == self.attackHeroList[i] then
			return true
		end
	end
	return false
end

-- 更新家具信息
function globaldata:updateFurnitInfoFromServer(msgPacket)
	-- 未放置的
	local outCount = msgPacket:GetUShort()
	for i = 1, outCount do
		local newFurnit = furnitObject:new()
		newFurnit.mGuid = msgPacket:GetString()
		newFurnit.mId = msgPacket:GetInt()
		table.insert(self.furnitListOutHouse, newFurnit)
	end

	-- 已放置的
	local inCount = msgPacket:GetUShort()
	for i = 1, inCount do
		local newFurnit = furnitObject:new()
		newFurnit.mGuid = msgPacket:GetString()
		newFurnit.mId = msgPacket:GetInt()
		newFurnit.mPosX = msgPacket:GetUShort()
		newFurnit.mPosY = msgPacket:GetUShort()
		table.insert(self.furnitListInHouse, newFurnit)
	end
end

-- 判断关卡是否打过
function globaldata:isSectionVisited(level, chapter, section)
	if not self:isSectionOpened(chapter, section, level) then
		return false
	end

	if self.chapterList[level][chapter].mSectionList[section] then
		if self.chapterList[level][chapter].mSectionList[section]:getKeyValue("mCurStarCount") > 0 then
			return true
		else
			return false
		end
	else
		return false
	end
end

-- 根据难度获取章节链表
function globaldata:getChapterListByLevel(level)
	return self.chapterList[level]
end

-- 更新关卡信息
function globaldata:updateChapterInfoFromServerPacket(packet)
	local chapterTypeCount = packet:GetChar()
	for i = 1, chapterTypeCount do
		local chapterType = packet:GetChar()
		self.chapterList[chapterType] = {}
		self.curChapterId[chapterType] = packet:GetInt()
		self.curSectionId[chapterType] = packet:GetInt()
		local chapterCount = packet:GetUShort()
		for j = 1, chapterCount do
			local newChapter = chapterObject:new()
			newChapter.mChapterId = packet:GetInt()
			newChapter.mTotalStarCount = packet:GetInt()
			-- 星星奖励
			local starRewardCount = packet:GetUShort()
			for i = 1, starRewardCount do
				local needStarCount = packet:GetInt()
				local canGetReward = packet:GetChar()
				newChapter.mStarReward[i] = {needStarCount, canGetReward}
			end
			-- 关卡数量
			local sectionCount = packet:GetUShort()
			for m = 1, sectionCount do
				local newSection = sectionObject:new()
				newSection.mSectionId = packet:GetInt()
				newSection.mCurStarCount = packet:GetChar()
				newSection.mLeftChanllengeCount = packet:GetUShort()
				newSection.mTotalChallengeCount = packet:GetUShort()
				newChapter.mSectionList[m] = newSection
			end
			self.chapterList[chapterType][j] = newChapter
		end
	end
end

-- 确保关卡是否开启
function globaldata:isChapterOpened(chapterId, chapterLevel)
	if not self.chapterList[chapterLevel][chapterId] then
		return false
	end
	return true
end

-- 确保关卡是否开启
function globaldata:isSectionOpened(chapterId, sectionId, chapterLevel)
	if self.chapterList[chapterLevel][chapterId] then
		local sectionList = self.chapterList[chapterLevel][chapterId].mSectionList
		for i = 1, #sectionList do
			if sectionId == sectionList[i].mSectionId then
				return true
			end
		end
		return false
	end
	return false
end

-- 关卡是否完成
function globaldata:isChapterFinished(chapterId, sectionId, chapterLevel)
	if self.chapterList[chapterLevel][chapterId] then
		local sectionList = self.chapterList[chapterLevel][chapterId].mSectionList
		for i = 1, #sectionList do
			if sectionId == sectionList[i].mSectionId then
				if sectionList[i].mCurStarCount > 0 then
					return true
				else
					return false
				end
			end
		end
		return false
	end

	return false
end

-- 获取团队战力
function globaldata:getTeamCombat()
	-- local combat = 0
	-- for i = 1, 5 do
	-- 	local val = globaldata:getHeroInfoByBattleIndex(i, "combat")
	-- 	if val then
	-- 		combat = combat + val
	-- 	end	
	-- end
	-- return combat
	return self.playerCombat
end

-- 更新财富之山玩家阵容信息
function globaldata:updateBattleFormationWealth(msgPacket)
	-- 玩家数据
	globaldata.fubenstar = 3
	self.battleFormation = {}
	globaldata.battleFormationCount = 0

	globaldata.boardIDforWealth = msgPacket:GetInt()
	globaldata.Wealthhard = msgPacket:GetChar()

	self.battleFormationCount = msgPacket:GetUShort()
	for i = 1, self.battleFormationCount do
		local newBattleObj = battleObject:new()
		newBattleObj.index = msgPacket:GetInt() -- 索引 
		newBattleObj.guid = msgPacket:GetString() -- 
		newBattleObj.id = msgPacket:GetInt() -- HeroID
		newBattleObj.advanceLevel = msgPacket:GetChar()
		newBattleObj.quality = msgPacket:GetChar()
		newBattleObj.level = msgPacket:GetInt()

		local function parseSkill()
			  newBattleObj.skillList["SkillWeaponLevel"] = msgPacket:GetInt()

			  local WeaponSkillLevel = newBattleObj.skillList["SkillWeaponLevel"]
			  local Old_Replace_New_skillTable = {}
			  local New_Replace_Old_skillTable = {}

			local HeroWeaponData = DB_HeroWeapon.getDataById(newBattleObj.id)
			for i=1,WeaponSkillLevel do
				local wkId = HeroWeaponData[string.format("Skill%d",i)]
				local WkData = DB_Weapon_Skill.getDataById(wkId)
				if WkData.Type == 4 then
					Old_Replace_New_skillTable[WkData["Param1"]] = WkData["Param2"]
					New_Replace_Old_skillTable[WkData["Param2"]] = WkData["Param1"]
				end
			end

			local function ChangeNewWeapSkillById( _oldskillId )
				if Old_Replace_New_skillTable[_oldskillId] then
					return Old_Replace_New_skillTable[_oldskillId]
				end
				return _oldskillId
			end

			  newBattleObj.skillList["Role_NormalSkill1"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_NormalSkill1_Level"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_NormalSkill2"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_NormalSkill3"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_NormalSkill4"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_SpecialSkill1"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_SpecialSkillActivate1"] = msgPacket:GetChar()
			  newBattleObj.skillList["Role_SpecialSkillActivate1_Level"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_SpecialSkill2"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_SpecialSkillActivate2"] = msgPacket:GetChar()
			  newBattleObj.skillList["Role_SpecialSkillActivate2_Level"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_SpecialSkill3"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_SpecialSkillActivate3"] = msgPacket:GetChar()
			  newBattleObj.skillList["Role_SpecialSkillActivate3_Level"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_SpecialSkill4"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_SpecialSkillActivate4"] = msgPacket:GetChar()
			  newBattleObj.skillList["Role_SpecialSkillActivate4_Level"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_PassiveSkill1"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_PassiveSkill2"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_PassiveSkill3"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_PassiveSkill4"] = msgPacket:GetInt()			  			  			  
			  newBattleObj.skillList["Role_GroupSkill1"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_GroupSkill2"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_GroupMainSubFlag"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_GroupSkillFlag"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_DodgeSkill"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_Change_NormalSkill1"] = ChangeNewWeapSkillById(newBattleObj.skillList["Role_NormalSkill1"])
			  newBattleObj.skillList["Role_Change_NormalSkill2"] = ChangeNewWeapSkillById(newBattleObj.skillList["Role_NormalSkill2"])
			  newBattleObj.skillList["Role_Change_NormalSkill3"] = ChangeNewWeapSkillById(newBattleObj.skillList["Role_NormalSkill3"])
			  newBattleObj.skillList["Role_Change_NormalSkill4"] = ChangeNewWeapSkillById(newBattleObj.skillList["Role_NormalSkill4"])
			  newBattleObj.skillList["Role_Change_SpecialSkill1"] = ChangeNewWeapSkillById(newBattleObj.skillList["Role_SpecialSkill1"])
			  newBattleObj.skillList["Role_Change_SpecialSkill2"] = ChangeNewWeapSkillById(newBattleObj.skillList["Role_SpecialSkill2"])
			  newBattleObj.skillList["Role_Change_SpecialSkill3"] = ChangeNewWeapSkillById(newBattleObj.skillList["Role_SpecialSkill3"])
			  newBattleObj.skillList["Role_Change_SpecialSkill4"] = ChangeNewWeapSkillById(newBattleObj.skillList["Role_SpecialSkill4"])
		end
		local function parseProp()
			newBattleObj.propCount = msgPacket:GetUShort()
			for j = 1, newBattleObj.propCount do
				local k = msgPacket:GetChar()
				local v = msgPacket:GetInt()
				newBattleObj.propList[k] = v
			end
		end
		parseSkill()
		parseProp()
		self.battleFormation[newBattleObj.index] = newBattleObj
	end
end

-- 更新爬塔玩家阵容信息
function globaldata:updateBattleFormationTower(msgPacket)
	-- 玩家数据
	globaldata.fubenstar = 3
	self.battleFormation = {}
	globaldata.battleFormationCount = 0

	globaldata.boardIDforTower = msgPacket:GetInt()
	globaldata.Towerhard = msgPacket:GetChar()

	self.battleFormationCount = msgPacket:GetUShort()
	for i = 1, self.battleFormationCount do
		local newBattleObj = battleObject:new()
		newBattleObj.index = msgPacket:GetInt() -- 索引 
		newBattleObj.guid = msgPacket:GetString() -- 
		newBattleObj.id = msgPacket:GetInt() -- HeroID
		newBattleObj.advanceLevel = msgPacket:GetChar()
		newBattleObj.quality = msgPacket:GetChar()
		newBattleObj.level = msgPacket:GetInt()

		local function parseSkill()
			  newBattleObj.skillList["SkillWeaponLevel"] = msgPacket:GetInt()

			  local WeaponSkillLevel = newBattleObj.skillList["SkillWeaponLevel"]
			  local Old_Replace_New_skillTable = {}
			  local New_Replace_Old_skillTable = {}

			local HeroWeaponData = DB_HeroWeapon.getDataById(newBattleObj.id)
			for i=1,WeaponSkillLevel do
				local wkId = HeroWeaponData[string.format("Skill%d",i)]
				local WkData = DB_Weapon_Skill.getDataById(wkId)
				if WkData.Type == 4 then
					Old_Replace_New_skillTable[WkData["Param1"]] = WkData["Param2"]
					New_Replace_Old_skillTable[WkData["Param2"]] = WkData["Param1"]
				end
			end

			local function ChangeNewWeapSkillById( _oldskillId )
				if Old_Replace_New_skillTable[_oldskillId] then
					return Old_Replace_New_skillTable[_oldskillId]
				end
				return _oldskillId
			end

			  newBattleObj.skillList["Role_NormalSkill1"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_NormalSkill1_Level"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_NormalSkill2"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_NormalSkill3"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_NormalSkill4"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_SpecialSkill1"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_SpecialSkillActivate1"] = msgPacket:GetChar()
			  newBattleObj.skillList["Role_SpecialSkillActivate1_Level"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_SpecialSkill2"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_SpecialSkillActivate2"] = msgPacket:GetChar()
			  newBattleObj.skillList["Role_SpecialSkillActivate2_Level"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_SpecialSkill3"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_SpecialSkillActivate3"] = msgPacket:GetChar()
			  newBattleObj.skillList["Role_SpecialSkillActivate3_Level"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_SpecialSkill4"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_SpecialSkillActivate4"] = msgPacket:GetChar()
			  newBattleObj.skillList["Role_SpecialSkillActivate4_Level"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_PassiveSkill1"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_PassiveSkill2"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_PassiveSkill3"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_PassiveSkill4"] = msgPacket:GetInt()			  			  			  
			  newBattleObj.skillList["Role_GroupSkill1"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_GroupSkill2"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_GroupMainSubFlag"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_GroupSkillFlag"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_DodgeSkill"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_Change_NormalSkill1"] = ChangeNewWeapSkillById(newBattleObj.skillList["Role_NormalSkill1"])
			  newBattleObj.skillList["Role_Change_NormalSkill2"] = ChangeNewWeapSkillById(newBattleObj.skillList["Role_NormalSkill2"])
			  newBattleObj.skillList["Role_Change_NormalSkill3"] = ChangeNewWeapSkillById(newBattleObj.skillList["Role_NormalSkill3"])
			  newBattleObj.skillList["Role_Change_NormalSkill4"] = ChangeNewWeapSkillById(newBattleObj.skillList["Role_NormalSkill4"])
			  newBattleObj.skillList["Role_Change_SpecialSkill1"] = ChangeNewWeapSkillById(newBattleObj.skillList["Role_SpecialSkill1"])
			  newBattleObj.skillList["Role_Change_SpecialSkill2"] = ChangeNewWeapSkillById(newBattleObj.skillList["Role_SpecialSkill2"])
			  newBattleObj.skillList["Role_Change_SpecialSkill3"] = ChangeNewWeapSkillById(newBattleObj.skillList["Role_SpecialSkill3"])
			  newBattleObj.skillList["Role_Change_SpecialSkill4"] = ChangeNewWeapSkillById(newBattleObj.skillList["Role_SpecialSkill4"])
		end
		local function parseProp()
			newBattleObj.propCount = msgPacket:GetUShort()
			for j = 1, newBattleObj.propCount do
				local k = msgPacket:GetChar()
				local v = msgPacket:GetInt()
				newBattleObj.propList[k] = v
			end
		end
		parseSkill()
		parseProp()
		self.battleFormation[newBattleObj.index] = newBattleObj
	end
end

-- 更新副本玩家阵容信息
function globaldata:updateBattleFormation(msgPacket,flag)
	-- 玩家数据
	globaldata.fubenstar = 3
	self.battleFormation = {}
	globaldata.battleFormationCount = 0

	if not flag then
		globaldata.mapType = msgPacket:GetChar()
		globaldata.mapId = msgPacket:GetInt()
		globaldata.stageId = msgPacket:GetInt()
	end
	self.battleFormationCount = msgPacket:GetUShort()
	for i = 1, self.battleFormationCount do
		local newBattleObj = battleObject:new()
		newBattleObj.index = msgPacket:GetInt() -- 索引 
		newBattleObj.guid = msgPacket:GetString() -- 
		newBattleObj.id = msgPacket:GetInt() -- HeroID
		newBattleObj.advanceLevel = msgPacket:GetChar()
		newBattleObj.quality = msgPacket:GetChar()
		newBattleObj.level = msgPacket:GetInt()
		if self.PvpType == "brave" then
			newBattleObj.braveCurHp = msgPacket:GetInt()
		end
		local function parseSkill()
			  newBattleObj.skillList["SkillWeaponLevel"] = msgPacket:GetInt()

			  local WeaponSkillLevel = newBattleObj.skillList["SkillWeaponLevel"]
			  local Old_Replace_New_skillTable = {}
			  local New_Replace_Old_skillTable = {}

			local HeroWeaponData = DB_HeroWeapon.getDataById(newBattleObj.id)
			for i=1,WeaponSkillLevel do
				local wkId = HeroWeaponData[string.format("Skill%d",i)]
				local WkData = DB_Weapon_Skill.getDataById(wkId)
				if WkData.Type == 4 then
					Old_Replace_New_skillTable[WkData["Param1"]] = WkData["Param2"]
					New_Replace_Old_skillTable[WkData["Param2"]] = WkData["Param1"]
				end
			end

			local function ChangeNewWeapSkillById( _oldskillId )
				if Old_Replace_New_skillTable[_oldskillId] then
					return Old_Replace_New_skillTable[_oldskillId]
				end
				return _oldskillId
			end

			  newBattleObj.skillList["Role_NormalSkill1"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_NormalSkill1_Level"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_NormalSkill2"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_NormalSkill3"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_NormalSkill4"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_SpecialSkill1"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_SpecialSkillActivate1"] = msgPacket:GetChar()
			  newBattleObj.skillList["Role_SpecialSkillActivate1_Level"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_SpecialSkill2"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_SpecialSkillActivate2"] = msgPacket:GetChar()
			  newBattleObj.skillList["Role_SpecialSkillActivate2_Level"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_SpecialSkill3"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_SpecialSkillActivate3"] = msgPacket:GetChar()
			  newBattleObj.skillList["Role_SpecialSkillActivate3_Level"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_SpecialSkill4"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_SpecialSkillActivate4"] = msgPacket:GetChar()
			  newBattleObj.skillList["Role_SpecialSkillActivate4_Level"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_PassiveSkill1"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_PassiveSkill2"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_PassiveSkill3"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_PassiveSkill4"] = msgPacket:GetInt()			  			  			  
			  newBattleObj.skillList["Role_GroupSkill1"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_GroupSkill2"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_GroupMainSubFlag"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_GroupSkillFlag"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_DodgeSkill"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_Change_NormalSkill1"] = ChangeNewWeapSkillById(newBattleObj.skillList["Role_NormalSkill1"])
			  newBattleObj.skillList["Role_Change_NormalSkill2"] = ChangeNewWeapSkillById(newBattleObj.skillList["Role_NormalSkill2"])
			  newBattleObj.skillList["Role_Change_NormalSkill3"] = ChangeNewWeapSkillById(newBattleObj.skillList["Role_NormalSkill3"])
			  newBattleObj.skillList["Role_Change_NormalSkill4"] = ChangeNewWeapSkillById(newBattleObj.skillList["Role_NormalSkill4"])
			  newBattleObj.skillList["Role_Change_SpecialSkill1"] = ChangeNewWeapSkillById(newBattleObj.skillList["Role_SpecialSkill1"])
			  newBattleObj.skillList["Role_Change_SpecialSkill2"] = ChangeNewWeapSkillById(newBattleObj.skillList["Role_SpecialSkill2"])
			  newBattleObj.skillList["Role_Change_SpecialSkill3"] = ChangeNewWeapSkillById(newBattleObj.skillList["Role_SpecialSkill3"])
			  newBattleObj.skillList["Role_Change_SpecialSkill4"] = ChangeNewWeapSkillById(newBattleObj.skillList["Role_SpecialSkill4"])
		end
		local function parseProp()
			newBattleObj.propCount = msgPacket:GetUShort()
			for j = 1, newBattleObj.propCount do
				local k = msgPacket:GetChar()
				local v = msgPacket:GetInt()
				newBattleObj.propList[k] = v
			end
		end
		parseSkill()
		parseProp()
		self.battleFormation[newBattleObj.index] = newBattleObj
	end

	-- local function sortFunc(obj1, obj2)
	-- 	if obj1.index < obj2.index then
	-- 		return true
	-- 	else
	-- 		return false
	-- 	end
	-- end
	-- table.sort(self.battleFormation, sortFunc)

end

-- 更新副本掉落
function globaldata:updateMonsterDropItem(msgPacket)
	self.monsterdropkinds = msgPacket:GetUShort()
	self.monsterdroplist = {}
	self.FubenconstRewardList = {}
	-- for i=1,self.fubenbalancedata.constRewardNum do
	-- 	local constRewarditem = {}
	-- 	constRewarditem.itemType = packet:GetInt()
	-- 	constRewarditem.itemId = packet:GetInt()
	-- 	constRewarditem.itemNum = packet:GetInt()
	-- 	self.fubenbalancedata.constRewardList[i] = constRewarditem
	-- end

	for i=1,self.monsterdropkinds do
		local monsterDropInfo = {}
		monsterDropInfo.monsterId = msgPacket:GetInt()

		monsterDropInfo.monsterCount = msgPacket:GetUShort()


		monsterDropInfo.monsterInfo = {}
		for i=1,monsterDropInfo.monsterCount do
			local monster = {}
			monster.goodsNum = msgPacket:GetUShort()
			monster.goodslist = {}
			for i=1,monster.goodsNum do

				local item = {}
				item.itemType = msgPacket:GetInt()
				item.itemId = msgPacket:GetInt()
				item.itemNum = msgPacket:GetInt()

				for i=1,3 do
					if self.FubenconstRewardList[i] then
						if self.FubenconstRewardList[i].itemType == item.itemType and self.FubenconstRewardList[i].itemId == item.itemId then
							if self.FubenconstRewardList[i].itemType == 1 then
								local index = #self.FubenconstRewardList
								if index < 3 then
									table.insert(self.FubenconstRewardList,item)
								end
							else
								if item.itemType == 2 then
									-- cclog("MONEY ==" .. i)
								end
								self.FubenconstRewardList[i].itemNum =self.FubenconstRewardList[i].itemNum + item.itemNum
							end
							break
						end
					else
						if item.itemType == 2 then
							-- cclog("MONEY ==" .. i)
						end
						table.insert(self.FubenconstRewardList,item)
						break
					end
				end

				-- cclog("Drop itemType===" .. item.itemType)
				-- cclog("Drop itemId===" .. item.itemId)
				-- cclog("Drop itemNum===" .. item.itemNum)
				table.insert(monster.goodslist,item)
			end
			table.insert(monsterDropInfo.monsterInfo,monster)
		end
		table.insert(self.monsterdroplist,monsterDropInfo)
	end

	self.FubenconstRewardNum = #self.FubenconstRewardList
end

--blcakmarket battle request for restart
function globaldata:doBlackMarketBattleRequest(index,taskId,playerId,heros)
	for i=1,#heros do
		globaldata.blackMarketBattleHeros[i] = heros[i]
	end

	globaldata.bmTaskid  = taskId
	globaldata.bmTaskIdx = index
	globaldata.bmPlayerid = playerId
	local packet = NetSystem.mNetManager:GetSPacket()
	packet:SetType(PacketTyper._PTYPE_CS_BEGIN_ROB_REQUEST)
	packet:PushChar(globaldata.bmTaskIdx)
	packet:PushInt(globaldata.bmTaskid)
	packet:PushString(globaldata.bmPlayerid)
	packet:PushUShort(#heros) 
	for i=1,#heros do
		packet:PushInt(heros[i])
	end
	packet:Send()
	GUISystem:showLoading()

	return 0
end


--walth mountian battle request  for restart
function globaldata:doWealthBattleRequest(heros)
	for i=1,#heros do
		globaldata.wealthBattleHeros[i] = heros[i]
	end
	
	local packet = NetSystem.mNetManager:GetSPacket()
	packet:SetType(PacketTyper._PTYPE_CS_REQUEST_WEALTH_BATTLE_)
	packet:PushChar(globaldata.wealthType)
	packet:PushChar(globaldata.clickedlevel)
	packet:PushUShort(#heros) 
	for i=1,#heros do
		packet:PushInt(heros[i])
	end
	packet:Send()
	GUISystem:showLoading()

	return 0
end

--towerex  battle request  for restart
function globaldata:doTowerExBattleRequest(heros)
	for i=1,#heros do
		globaldata.towerExBattleHeros[i] = heros[i]
	end
	
	local packet = NetSystem.mNetManager:GetSPacket()
    packet:SetType(PacketTyper._PTYPE_CS_TOWER_EX_CHALLENGE_REQUEST)
    packet:PushUShort(#heros) 
	for i=1,#heros do
		packet:PushInt(heros[i])
	end
    packet:Send()
	GUISystem:showLoading()
end

-- 进入副本请求
function globaldata:requestEnterBattle(_isagainfight)
	globaldata.fightagain = _isagainfight
	globaldata.PvpType        = "fuben"
	local packet = NetSystem.mNetManager:GetSPacket()
	packet:SetType(PacketTyper._PTYPE_CS_REQUEST_GOTOBATTLE_)
	packet:PushChar(globaldata.clickedlevel)
	packet:PushInt(globaldata.clickedchapter)
	packet:PushInt(globaldata.clickedsection)
	-- cclog("章节Id=="..globaldata.clickedchapter)
	-- cclog("关卡Id=="..globaldata.clickedsection)

	packet:PushUShort(#globaldata.battleHeroIdTbl)
	for i = 1, #globaldata.battleHeroIdTbl do
		packet:PushInt(globaldata.battleHeroIdTbl[i])
	end

	packet:Send()
	GUISystem:showLoading()
end

--更新敌方阵容信息
function globaldata:updateEnemyInfoFormation(msgPacket)
	-- 玩家数据
	self.enemyFormation = {}
	self.enemyFormationCount = 0

	self.enemyFormationCount = msgPacket:GetUShort()
	for i = 1, self.enemyFormationCount do
		local newBattleObj = battleObject:new()
		newBattleObj.index = msgPacket:GetInt()
		newBattleObj.guid = msgPacket:GetString()
		newBattleObj.id = msgPacket:GetInt()
		newBattleObj.advanceLevel = msgPacket:GetChar()
		newBattleObj.quality = msgPacket:GetChar()
		newBattleObj.level = msgPacket:GetInt()
		if self.PvpType == "brave" then
			newBattleObj.braveCurHp = msgPacket:GetInt()
		end

		local function parseSkill()
			  newBattleObj.skillList["SkillWeaponLevel"] = msgPacket:GetInt()

			  local WeaponSkillLevel = newBattleObj.skillList["SkillWeaponLevel"]
			  local Old_Replace_New_skillTable = {}
			  local New_Replace_Old_skillTable = {}

			local HeroWeaponData = DB_HeroWeapon.getDataById(newBattleObj.id)
			for i=1,WeaponSkillLevel do
				local wkId = HeroWeaponData[string.format("Skill%d",i)]
				local WkData = DB_Weapon_Skill.getDataById(wkId)
				if WkData.Type == 4 then
					Old_Replace_New_skillTable[WkData["Param1"]] = WkData["Param2"]
					New_Replace_Old_skillTable[WkData["Param2"]] = WkData["Param1"]
				end
			end

			local function ChangeNewWeapSkillById( _oldskillId )
				if Old_Replace_New_skillTable[_oldskillId] then
					return Old_Replace_New_skillTable[_oldskillId]
				end
				return _oldskillId
			end

			  newBattleObj.skillList["Role_NormalSkill1"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_NormalSkill1_Level"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_NormalSkill2"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_NormalSkill3"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_NormalSkill4"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_SpecialSkill1"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_SpecialSkillActivate1"] = msgPacket:GetChar()
			  newBattleObj.skillList["Role_SpecialSkillActivate1_Level"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_SpecialSkill2"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_SpecialSkillActivate2"] = msgPacket:GetChar()
			  newBattleObj.skillList["Role_SpecialSkillActivate2_Level"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_SpecialSkill3"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_SpecialSkillActivate3"] = msgPacket:GetChar()
			  newBattleObj.skillList["Role_SpecialSkillActivate3_Level"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_SpecialSkill4"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_SpecialSkillActivate4"] = msgPacket:GetChar()
			  newBattleObj.skillList["Role_SpecialSkillActivate4_Level"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_PassiveSkill1"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_PassiveSkill2"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_PassiveSkill3"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_PassiveSkill4"] = msgPacket:GetInt()			  			  			  
			  newBattleObj.skillList["Role_GroupSkill1"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_GroupSkill2"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_GroupMainSubFlag"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_GroupSkillFlag"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_DodgeSkill"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_Change_NormalSkill1"] = ChangeNewWeapSkillById(newBattleObj.skillList["Role_NormalSkill1"])
			  newBattleObj.skillList["Role_Change_NormalSkill2"] = ChangeNewWeapSkillById(newBattleObj.skillList["Role_NormalSkill2"])
			  newBattleObj.skillList["Role_Change_NormalSkill3"] = ChangeNewWeapSkillById(newBattleObj.skillList["Role_NormalSkill3"])
			  newBattleObj.skillList["Role_Change_NormalSkill4"] = ChangeNewWeapSkillById(newBattleObj.skillList["Role_NormalSkill4"])
			  newBattleObj.skillList["Role_Change_SpecialSkill1"] = ChangeNewWeapSkillById(newBattleObj.skillList["Role_SpecialSkill1"])
			  newBattleObj.skillList["Role_Change_SpecialSkill2"] = ChangeNewWeapSkillById(newBattleObj.skillList["Role_SpecialSkill2"])
			  newBattleObj.skillList["Role_Change_SpecialSkill3"] = ChangeNewWeapSkillById(newBattleObj.skillList["Role_SpecialSkill3"])
			  newBattleObj.skillList["Role_Change_SpecialSkill4"] = ChangeNewWeapSkillById(newBattleObj.skillList["Role_SpecialSkill4"])
		end
		local function parseProp()
			newBattleObj.propCount = msgPacket:GetUShort()
			for j = 1, newBattleObj.propCount do
				local k = msgPacket:GetChar()
				local v = msgPacket:GetInt()
				newBattleObj.propList[k] = v
			end
		end
		local function changecolorFun()
			newBattleObj.changeColorCount = msgPacket:GetUShort()
			newBattleObj.changecolor = {}
			for i=1,newBattleObj.changeColorCount do
				local Colordata = {}
				Colordata.partType = msgPacket:GetChar()
				Colordata.colorType = msgPacket:GetChar()
				if Colordata.colorType > 0 then
					Colordata.colorArrCount = msgPacket:GetUShort()
					Colordata.colorArr = {}
					cclog("updateEnemyInfoFormation===colorArrCount=="..Colordata.colorArrCount .. "===colorType=="..Colordata.colorType)
					for i=1,Colordata.colorArrCount do
						Colordata.colorArr[i] = msgPacket:GetUShort()
					end
				end
				newBattleObj.changecolor[i] = Colordata
			end
		end
		parseSkill()
		parseProp()
		if self.PvpType == "boss" or self.PvpType == "brave" then
		else
			changecolorFun()
		end
		self.enemyFormation[newBattleObj.index] = newBattleObj
	end

	-- local function sortFunc(obj1, obj2)
	-- 	if obj1.index < obj2.index then
	-- 		return true
	-- 	else
	-- 		return false
	-- 	end
	-- end
	-- table.sort(self.battleFormation, sortFunc)
end



-- OLPVP 更新友方人物战斗信息
function globaldata:updateFriendFightInfo_OLPvp(msgPacket)
	-- 玩家数据
	globaldata.fubenstar = 3
	self.battleFormation = {}
	globaldata.battleFormationCount = 0

	self.battleFormationCount = msgPacket:GetUShort()
	for i = 1, self.battleFormationCount do
		local newBattleObj = battleObject:new()
		newBattleObj.playerName = msgPacket:GetString()
		local tempindex = msgPacket:GetInt()
		if self.olpvpType == 0 or self.olpvpType == 3 then
			self.olHoldindex = tempindex%2
		end
		newBattleObj.index = self:convertOlindex(tempindex)
		newBattleObj.guid = msgPacket:GetString()
		newBattleObj.id = msgPacket:GetInt()
		newBattleObj.advanceLevel = msgPacket:GetChar()
		newBattleObj.quality = msgPacket:GetChar()
		newBattleObj.level = msgPacket:GetInt()
		local function parseSkill()
			  newBattleObj.skillList["SkillWeaponLevel"] = msgPacket:GetInt()

			  local WeaponSkillLevel = newBattleObj.skillList["SkillWeaponLevel"]
			  local Old_Replace_New_skillTable = {}
			  local New_Replace_Old_skillTable = {}

			local HeroWeaponData = DB_HeroWeapon.getDataById(newBattleObj.id)
			for i=1,WeaponSkillLevel do
				local wkId = HeroWeaponData[string.format("Skill%d",i)]
				local WkData = DB_Weapon_Skill.getDataById(wkId)
				if WkData.Type == 4 then
					Old_Replace_New_skillTable[WkData["Param1"]] = WkData["Param2"]
					New_Replace_Old_skillTable[WkData["Param2"]] = WkData["Param1"]
				end
			end

			local function ChangeNewWeapSkillById( _oldskillId )
				if Old_Replace_New_skillTable[_oldskillId] then
					return Old_Replace_New_skillTable[_oldskillId]
				end
				return _oldskillId
			end

			  newBattleObj.skillList["Role_NormalSkill1"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_NormalSkill1_Level"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_NormalSkill2"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_NormalSkill3"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_NormalSkill4"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_SpecialSkill1"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_SpecialSkillActivate1"] = msgPacket:GetChar()
			  newBattleObj.skillList["Role_SpecialSkillActivate1_Level"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_SpecialSkill2"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_SpecialSkillActivate2"] = msgPacket:GetChar()
			  newBattleObj.skillList["Role_SpecialSkillActivate2_Level"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_SpecialSkill3"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_SpecialSkillActivate3"] = msgPacket:GetChar()
			  newBattleObj.skillList["Role_SpecialSkillActivate3_Level"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_SpecialSkill4"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_SpecialSkillActivate4"] = msgPacket:GetChar()
			  newBattleObj.skillList["Role_SpecialSkillActivate4_Level"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_PassiveSkill1"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_PassiveSkill2"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_PassiveSkill3"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_PassiveSkill4"] = msgPacket:GetInt()			  			  			  
			  newBattleObj.skillList["Role_GroupSkill1"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_GroupSkill2"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_GroupMainSubFlag"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_GroupSkillFlag"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_DodgeSkill"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_Change_NormalSkill1"] = ChangeNewWeapSkillById(newBattleObj.skillList["Role_NormalSkill1"])
			  newBattleObj.skillList["Role_Change_NormalSkill2"] = ChangeNewWeapSkillById(newBattleObj.skillList["Role_NormalSkill2"])
			  newBattleObj.skillList["Role_Change_NormalSkill3"] = ChangeNewWeapSkillById(newBattleObj.skillList["Role_NormalSkill3"])
			  newBattleObj.skillList["Role_Change_NormalSkill4"] = ChangeNewWeapSkillById(newBattleObj.skillList["Role_NormalSkill4"])
			  newBattleObj.skillList["Role_Change_SpecialSkill1"] = ChangeNewWeapSkillById(newBattleObj.skillList["Role_SpecialSkill1"])
			  newBattleObj.skillList["Role_Change_SpecialSkill2"] = ChangeNewWeapSkillById(newBattleObj.skillList["Role_SpecialSkill2"])
			  newBattleObj.skillList["Role_Change_SpecialSkill3"] = ChangeNewWeapSkillById(newBattleObj.skillList["Role_SpecialSkill3"])
			  newBattleObj.skillList["Role_Change_SpecialSkill4"] = ChangeNewWeapSkillById(newBattleObj.skillList["Role_SpecialSkill4"])
		end
		local function parseProp()
			newBattleObj.propCount = msgPacket:GetUShort()
			for j = 1, newBattleObj.propCount do
				local k = msgPacket:GetChar()
				local v = msgPacket:GetInt()
				newBattleObj.propList[k] = v
			end
			newBattleObj.mMaxHp = newBattleObj.propList[0]
			debugLog("FFFFFFFFFFF===="..i.."======"..newBattleObj.mMaxHp)
		end
		local function changecolorFun()
			newBattleObj.changeColorCount = msgPacket:GetUShort()
			newBattleObj.changecolor = {}
			for i=1,newBattleObj.changeColorCount do
				local Colordata = {}
				Colordata.partType = msgPacket:GetChar()
				Colordata.colorType = msgPacket:GetChar()
				if Colordata.colorType > 0 then
					Colordata.colorArrCount = msgPacket:GetUShort()
					Colordata.colorArr = {}
					for i=1,Colordata.colorArrCount do
						Colordata.colorArr[i] = msgPacket:GetUShort()
					end
				end
				newBattleObj.changecolor[i] = Colordata
			end
		end
		parseSkill()
		parseProp()
		changecolorFun()

		self.battleFormation[newBattleObj.index] = newBattleObj
	end
end


-- OLPVP 更新敌方人物战斗信息
function globaldata:updateEnemyFightInfo_OLPvp(msgPacket)
	-- 玩家数据
	self.enemyFormation = {}
	self.enemyFormationCount = 0

	self.enemyFormationCount = msgPacket:GetUShort()
	for i = 1, self.enemyFormationCount do
		local newBattleObj = battleObject:new()
		newBattleObj.playerName = msgPacket:GetString()
		local tempindex = msgPacket:GetInt()
		newBattleObj.index = self:convertOlindex(tempindex)
		--doError("self.olHoldindex=="..self.olHoldindex .. "==newBattleObj.index==Enemy" ..tempindex )
		newBattleObj.guid = msgPacket:GetString()
		newBattleObj.id = msgPacket:GetInt()
		newBattleObj.advanceLevel = msgPacket:GetChar()
		newBattleObj.quality = msgPacket:GetChar()
		newBattleObj.level = msgPacket:GetInt()


		local function parseSkill()
			   newBattleObj.skillList["SkillWeaponLevel"] = msgPacket:GetInt()

			  local WeaponSkillLevel = newBattleObj.skillList["SkillWeaponLevel"]
			  local Old_Replace_New_skillTable = {}
			  local New_Replace_Old_skillTable = {}

			local HeroWeaponData = DB_HeroWeapon.getDataById(newBattleObj.id)
			for i=1,WeaponSkillLevel do
				local wkId = HeroWeaponData[string.format("Skill%d",i)]
				local WkData = DB_Weapon_Skill.getDataById(wkId)
				if WkData.Type == 4 then
					Old_Replace_New_skillTable[WkData["Param1"]] = WkData["Param2"]
					New_Replace_Old_skillTable[WkData["Param2"]] = WkData["Param1"]
				end
			end

			local function ChangeNewWeapSkillById( _oldskillId )
				if Old_Replace_New_skillTable[_oldskillId] then
					return Old_Replace_New_skillTable[_oldskillId]
				end
				return _oldskillId
			end

			  newBattleObj.skillList["Role_NormalSkill1"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_NormalSkill1_Level"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_NormalSkill2"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_NormalSkill3"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_NormalSkill4"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_SpecialSkill1"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_SpecialSkillActivate1"] = msgPacket:GetChar()
			  newBattleObj.skillList["Role_SpecialSkillActivate1_Level"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_SpecialSkill2"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_SpecialSkillActivate2"] = msgPacket:GetChar()
			  newBattleObj.skillList["Role_SpecialSkillActivate2_Level"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_SpecialSkill3"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_SpecialSkillActivate3"] = msgPacket:GetChar()
			  newBattleObj.skillList["Role_SpecialSkillActivate3_Level"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_SpecialSkill4"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_SpecialSkillActivate4"] = msgPacket:GetChar()
			  newBattleObj.skillList["Role_SpecialSkillActivate4_Level"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_PassiveSkill1"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_PassiveSkill2"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_PassiveSkill3"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_PassiveSkill4"] = msgPacket:GetInt()			  			  			  
			  newBattleObj.skillList["Role_GroupSkill1"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_GroupSkill2"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_GroupMainSubFlag"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_GroupSkillFlag"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_DodgeSkill"] = msgPacket:GetInt()
			  newBattleObj.skillList["Role_Change_NormalSkill1"] = ChangeNewWeapSkillById(newBattleObj.skillList["Role_NormalSkill1"])
			  newBattleObj.skillList["Role_Change_NormalSkill2"] = ChangeNewWeapSkillById(newBattleObj.skillList["Role_NormalSkill2"])
			  newBattleObj.skillList["Role_Change_NormalSkill3"] = ChangeNewWeapSkillById(newBattleObj.skillList["Role_NormalSkill3"])
			  newBattleObj.skillList["Role_Change_NormalSkill4"] = ChangeNewWeapSkillById(newBattleObj.skillList["Role_NormalSkill4"])
			  newBattleObj.skillList["Role_Change_SpecialSkill1"] = ChangeNewWeapSkillById(newBattleObj.skillList["Role_SpecialSkill1"])
			  newBattleObj.skillList["Role_Change_SpecialSkill2"] = ChangeNewWeapSkillById(newBattleObj.skillList["Role_SpecialSkill2"])
			  newBattleObj.skillList["Role_Change_SpecialSkill3"] = ChangeNewWeapSkillById(newBattleObj.skillList["Role_SpecialSkill3"])
			  newBattleObj.skillList["Role_Change_SpecialSkill4"] = ChangeNewWeapSkillById(newBattleObj.skillList["Role_SpecialSkill4"])
		end
		local function parseProp()
			newBattleObj.propCount = msgPacket:GetUShort()
			for j = 1, newBattleObj.propCount do
				local k = msgPacket:GetChar()
				local v = msgPacket:GetInt()
				newBattleObj.propList[k] = v
			end
			newBattleObj.mMaxHp = newBattleObj.propList[0]
			debugLog("EEEEEEE===="..i.."======"..newBattleObj.mMaxHp)
		end
		local function changecolorFun()
			newBattleObj.changeColorCount = msgPacket:GetUShort()
			newBattleObj.changecolor = {}
			for i=1,newBattleObj.changeColorCount do
				local Colordata = {}
				Colordata.partType = msgPacket:GetChar()
				Colordata.colorType = msgPacket:GetChar()
				if Colordata.colorType > 0 then
					Colordata.colorArrCount = msgPacket:GetUShort()
					Colordata.colorArr = {}
					for i=1,Colordata.colorArrCount do
						Colordata.colorArr[i] = msgPacket:GetUShort()
					end
				end
				newBattleObj.changecolor[i] = Colordata
			end
		end
		parseSkill()
		parseProp()
		changecolorFun()
		self.enemyFormation[newBattleObj.index] = newBattleObj
	end
end

-- 得到战斗类型是1的 index转换 
function globaldata:convertOlindex(_index)
	local team = "friend"
	if self.olHoldindex%2 ~= _index%2 then
		team = "enemy"
	end
	if _index == 1 then
		return 1 , team
	elseif _index == 2 then
		return 1 , team
	elseif _index == 3 then
		return 2 , team
	elseif _index == 4 then
		return 2 , team
	elseif _index == 5 then
		return 3 , team
	elseif _index == 6 then
		return 3 , team
	end
end

--2803返回 双方战斗数据, PVP
function globaldata:updateBattlePvpInfo(msgPacket)
	__IsEnterFightWindow__ = true
	AnySDKManager:td_task_begin("pk")
	self.PvpType = "arena"
	globaldata.fightresultkey = msgPacket:GetInt()
	self.pvpmapType = msgPacket:GetChar()
	self.pvpmapId =  msgPacket:GetInt()
	self.pvpmapNameId =  msgPacket:GetInt()
	self.pvpmaxTime =  msgPacket:GetInt()
	self.pvpfriendTeamCount  = msgPacket:GetUShort()
	self.pvpFriendPosList = {}
	for i=1,self.pvpfriendTeamCount do
		local x = msgPacket:GetUShort()/100
		local y = msgPacket:GetUShort()/100
		local pos = cc.p(x,y)
		table.insert(self.pvpFriendPosList,pos)
	end
	self.pvpEnemyTeamCount  = msgPacket:GetUShort()
	self.pvpEnemyPosList = {}
	for i=1,self.pvpEnemyTeamCount do
		local x = msgPacket:GetUShort()/100
		local y = msgPacket:GetUShort()/100
		local pos = cc.p(x,y)
		table.insert(self.pvpEnemyPosList,pos)
	end
	self.pvpmucicId = msgPacket:GetUShort()
	

	self:updateBattleFormation(msgPacket,true)
	globaldata.ArenaEnemyName = msgPacket:GetString()
	self:updateEnemyInfoFormation(msgPacket)
	GUISystem:hideLoading()
	---------
	__IsEnterFightingPVP__ = true
	GUISystem:HideAllWindow()
	HomeWindow:destroyRootNode()
	showLoadingWindow("FightWindow")
	globaldata.mFriendPvpDamage = {}
	globaldata.mEnemyPvpDamage = {}
	PvpArenaManager:OnPreEnterPVP(self.pvpmapId)
end

-- 获取进入PVP敌人英雄的数量
function globaldata:getBattleEnemyFormationCount()
	return self.enemyFormationCount
end

-- 获取进入战斗英雄的数量 --return 1 上一个英雄
function globaldata:getBattleFormationCount()
	return self.battleFormationCount
end

-- 根据Index获取指定英雄的信息Key
function globaldata:getBattleFormationInfoByIndexAndKey(index, key)
	if self.battleFormation[index] then
		local battleObj = self.battleFormation[index]
		if battleObj[key] then
			return battleObj[key]
		else
			return nil
		end
	else
		return nil
	end
	return nil
end

-- 根据Index获取指定英雄的信息
function globaldata:getBattleFormationInfoByIndex(index)
	if self.battleFormation[index] then
		return self.battleFormation[index]
	end
	return nil
end

-- 根据Index获取指定敌方英雄的信息Key
function globaldata:getBattleEnemyFormationInfoByIndexAndKey(index, key)
	if self.enemyFormation[index] then
		local battleObj = self.enemyFormation[index]
		if battleObj[key] then
			return battleObj[key]
		else
			return nil
		end
	else
		return nil
	end
	return nil
end

-- 根据Index获取指定敌方英雄的信息
function globaldata:getBattleEnemyFormationInfoByIndex(index)
	if self.enemyFormation[index] then
		return self.enemyFormation[index]
	end
	return nil
end

-- 获取进入战斗怪物的数量
function globaldata:getMonsterCount()
	return self.monsterCount
end

-- 根据Index获取指定怪物的信息
function globaldata:getMonsterInfoByIndexAndKey(_monsterID, key)
	for i = 1,self.monsterCount do
		local _monster = self.monsterList[i]
		if _monster.id == _monsterID then
		   	if _monster[key] then
			   return _monster[key]
			else
				doError("key not exist!")
			end
		end
	end
	doError("_monsterID not exist!")
	return nil
end

-- 1003解包
-- 初始化数据(玩家登录成功时，收到大部分数据存于内存,后期通过同步更新)
function globaldata:initFromServerPacket(packet)
	-- 玩家信息
	local boolVal = packet:GetInt()
	-- 默认为不开启，debug版不受服务器控制
	needUseGuide = false
	if GAME_MODE ~= ENUM_GAMEMODE.debug then
		if 0 == boolVal then
			needUseGuide = true -- 开启
		elseif 1 == boolVal then
			needUseGuide = false -- 不开启
		end
	end

	self:setPlayerBaseData("playerId", packet:GetString())
	self:setPlayerBaseData("name", packet:GetString())
	self:setPlayerBaseData("level", packet:GetInt())
	self:setPlayerBaseData("exp", packet:GetInt())
	self:setPlayerBaseData("maxExp", packet:GetInt())
	self:setPlayerBaseData("vatality", packet:GetInt())
	self:setPlayerBaseData("maxVatality", packet:GetInt())
	self:setPlayerBaseData("naili", packet:GetInt())
	self:setPlayerBaseData("shenmi", packet:GetInt())
	self:setPlayerBaseData("money", packet:GetInt())
	self:setPlayerBaseData("diamond", packet:GetInt())
	self:setPlayerBaseData("partyMoney", packet:GetInt())
	self:setPlayerBaseData("tiantiMoney", packet:GetInt())
	self:setPlayerBaseData("towerMoney", packet:GetInt())
	self:setPlayerBaseData("vipLevel", packet:GetInt())

	-- 主城镇数据
	self:updateCityHallData(packet)
---------------------------准备数据--------------------------------------
	-- 初始化前一次数据
	globaldata:finishGradualEffect()
	-- 更新洗练价格
	self:updateXilianPriceFronServerPacket(packet)
	-- 更新强化价格
--	self:updateQianghuaPriceFronServerPacket(packet)
	-- 英雄队伍信息
	self:initHeroTeam(packet)
	-- 玩家总战力
	self.playerCombat = packet:GetInt()
	-- 上阵队伍信息
--	self:updateBattleTeam(packet)
	-- 更新物品信息
	self:updateItemInfoFromServerPacket(packet)
	-- 更新家具信息
	self:updateFurnitInfoFromServer(packet)
	-- 更新装备信息
	self:updateEquipInfoFromServerPacket(packet)
	-- 更新关卡信息
	self:updateChapterInfoFromServerPacket(packet)
    -- 更新碎片信息
    self:updateHeroChipsFromServerPacket(packet)
    -- 玩家信息
--    self:setPlayerBaseData("diamondAlreadyGet", packet:GetInt())
--    self:setPlayerBaseData("nextVipLevel", packet:GetInt())
--    self:setPlayerBaseData("nextVipNeedDiamondCount", packet:GetInt())
    globaldata.leaderHeroId = packet:GetInt()
    globaldata.registerHeroId = packet:GetInt()
    -- PVE阵容信息
    local cnt = packet:GetUShort()
    globaldata.battleHeroIdTbl = {}
    for i = 1, cnt do
   	    globaldata.battleHeroIdTbl[i] = packet:GetInt()
    end

    -- pk切磋
    local pkCnt = packet:GetUShort()
    if pkCnt > 3 then pkCnt = 3 end

    globaldata.pkBattleHeroIdTbl = {0,0,0}
    for i = 1, pkCnt do
   	    globaldata.pkBattleHeroIdTbl[i] = packet:GetInt() 
    end

    -- 帮会id 
    self:setPlayerBaseData("partyId", packet:GetString())
    -- 帮会名字
    self:setPlayerBaseData("partyName", packet:GetString())
    --帮会头像ID
    self.partyIconId = packet:GetInt()

    -- 英雄头像和边框
    self:playerFrameandIcon(packet)
    globaldata.mytitleId = packet:GetInt()
    -- 好友PK开关
 	globaldata.friendPlayerPK = packet:GetInt()
 	-- 初始化指引系统
    GuideSystem:init(packet)

    self:onSuccessServerForOlpvp()

    -- 体力倒计时
    Shabi:init()

    -- 时装
    globaldata.fashionEquipCnt = packet:GetUShort()
    for i = 1, globaldata.fashionEquipCnt do
    	globaldata.fashionEquipList[packet:GetChar()] = {packet:GetInt(), packet:GetChar()}
    end

    globaldata.curLvRewardInfo.idx        = packet:GetInt()
    globaldata.curLvRewardInfo.state      = packet:GetInt()
end

    -- 如果在olPVP战斗或者在olPVPloading重连之后做处理
function globaldata:onSuccessServerForOlpvp()
	if GUISystem.Windows["LadderWindow"].mRootNode or (GUISystem.Windows["FightWindow"].mRootNode and FightSystem.mFightType == "olpvp") then
		if globaldata.olpvpType == 2 then
			local function xxx()
		        local function callFun()
		          GUISystem:HideAllWindow()
		          HomeWindow:destroyRootNode()
		          showLoadingWindow("HomeWindow")
		        end
		        FightSystem:sendChangeCity(5,callFun)
		    end
		    xxx()
		else
			local function CallFun( ... )
				GUISystem:HideAllWindow()
				HomeWindow:destroyRootNode()
				FightSystem.mFightType = "none"
			end
			GUISystem:goTo("ladder",{BATTLE_RESULT.EXCEPTION,CallFun})
		end
	end
end

-- 英雄头像和边框
function globaldata:playerFrameandIcon(packet)
	self.playerFrame = packet:GetInt()
	self.playerIcon = packet:GetInt()
end

-- 更新英雄碎片信息
function globaldata:updateHeroChipsFromServerPacket(packet)
	self.heroChipsInfo = {}
	local count = packet:GetUShort()
	for i = 1, count do
		self.heroChipsInfo[i] = {}
		self.heroChipsInfo[i].heroId = packet:GetInt()
		self.heroChipsInfo[i].chipCnt = packet:GetUShort()
	end
end

-- 更新洗练价格信息
function globaldata:updateXilianPriceFronServerPacket(packet)
	local count = packet:GetChar()
	for i = 1, count do
		local clockCount = packet:GetChar()
		local price = packet:GetInt()
		self.xilianPriceList[clockCount] = price
	end
end

-- 更新强化价格信息
function globaldata:updateQianghuaPriceFronServerPacket(packet)
	local count = packet:GetUShort()
	for i = 1, count do
		local equipLevel = packet:GetUShort()
		local price = packet:GetInt()
		self.qianghuaPriceList[equipLevel] = price
	end
end

-- 获取洗练价格
function globaldata:getXilianPrice(clockCount)
	local price = self.xilianPriceList[clockCount]
	return price
end

-- 获取强化价格
function globaldata:getQianghuaPrice(equipLevel)
	local price = self.qianghuaPriceList[equipLevel]
	return price
end

-- 更新装备信息
function globaldata:updateEquipInfoFromServerPacket(packet)
	self.equipList = {}
	local equipCount = packet:GetUShort()
	for i = 1, equipCount do
		local newEquip = equipObject:new()
		newEquip.type = packet:GetInt()
		newEquip.level = packet:GetInt()
		newEquip.guid = packet:GetString()
		newEquip.id = packet:GetInt()
		newEquip.quality = packet:GetInt()
		newEquip.qualityAddValue = packet:GetInt()
		newEquip.advanceLevel = packet:GetInt()
--		newEquip.combat = packet:GetInt()
		newEquip.diamondList = {0, 0, 0, 0, 0}
		local diamondCount = packet:GetUShort()
		for i = 1, diamondCount do
			local index = packet:GetChar()
			local value = packet:GetInt()
			newEquip.diamondList[index] = value
		end

		newEquip.propCount = packet:GetUShort()
		for m = 1, newEquip.propCount do
			local propType = packet:GetChar()
			local propVal = packet:GetInt()
			newEquip.propList[propType] = propVal
		end
		newEquip.growPropCount = packet:GetUShort()
		for m = 1, newEquip.growPropCount do
			local propType = packet:GetChar()
			local propVal = packet:GetInt()
			newEquip.growPropList[propType] = propVal
		end
		-- 材料
		newEquip.strengthGoodCount = packet:GetUShort()
		for i = 1, newEquip.strengthGoodCount do
			newEquip.strengthGoodList[i] = strengthGoodObject:new()
			newEquip.strengthGoodList[i].mType = packet:GetInt()
			newEquip.strengthGoodList[i].mId = packet:GetInt()
			newEquip.strengthGoodList[i].mCount = packet:GetInt()
		end
		self.equipList[i] = newEquip
	end
end

-- 更新物品信息
function globaldata:updateItemInfoFromServerPacket(packet)
	self.itemList = {
						{},
						{},
						{},
						{},
						{},
						{},
						{},
					}
	local typeCount = packet:GetUShort()
	for i = 1, typeCount do
		local newItem = itemObject:new()
		newItem.itemId = packet:GetInt()
		newItem.itemType = packet:GetInt()
		newItem.itemNum = packet:GetInt()
		if not self.itemList[newItem.itemType] then
			self.itemList[newItem.itemType] = {}
		end
		table.insert(self.itemList[newItem.itemType], newItem)
	end 
end

-- 商城刷新
function globaldata:onRequestFreshShop(packet)
	local shopType = packet:GetChar()
	self.ShopFreshTime[shopType] = packet:GetString()
	local function createGoodsObj(packet)
		local newGoods = goodsObject:new()
		newGoods.goodsIndex = packet:GetInt()	
		newGoods.goodsType = packet:GetChar()		
		print("物品类型:", newGoods.goodsType)
		newGoods.goodsId = packet:GetInt()				
		newGoods.goodsCurrencyType = packet:GetChar()	
		newGoods.goodsPrice = packet:GetInt()		
		newGoods.goodsConditionType = packet:GetChar()
		newGoods.goodsConditionParam = packet:GetInt() 	
		newGoods.goodsMaxBuyLimitPerDay = packet:GetInt()
		newGoods.goodsMaxBuyCount = packet:GetInt()
		return newGoods
	end

	self.ShopGoodsList[shopType] = {}

	local goodsNum = packet:GetUShort()
	print("商店类型", shopType, "商品数量", goodsNum)
	for i = 1, goodsNum do
		table.insert(self.ShopGoodsList[shopType], createGoodsObj(packet))
	end

	GUIEventManager:pushEvent("shopFreshed", shopType)
	GUISystem:hideLoading()
end

-- 财富之山战斗回包2729,进入副本
function globaldata:onRequestEnterBattleWealth(packet)
	self.PvpType = "wealth"

	if globaldata.wealthType == WEALTHTYPE.MONEY then
		AnySDKManager:td_task_begin("fk-gold")
	elseif globaldata.wealthType == WEALTHTYPE.SUSHI then
		AnySDKManager:td_task_begin("fk-exp")
	elseif globaldata.wealthType == WEALTHTYPE.STONE then
		AnySDKManager:td_task_begin("fk-stone")
	end
	globaldata.fightresultkey = packet:GetInt()
	globaldata:updateBattleFormationWealth(packet)
	globaldata:updateMonsterDropItem(packet)
	----
	
	GUISystem:hideLoading()

	if globaldata.fightagain then
		globaldata.fightagain = false
		FightSystem:reloadFightWindow()
	else
		-- __IsEnterFighting__ = true
		GUISystem:HideAllWindow()
		HomeWindow:destroyRootNode()
		showLoadingWindow("FightWindow")
	end
	FubenManager:OnPreEnterPveWealth(globaldata.clickedchapter, globaldata.clickedsection, globaldata.clickedlevel)
end

-- 爬塔战斗回包8507,进入副本
function globaldata:onRequestEnterBattleTower(packet)
	self.PvpType = "tower"
	AnySDKManager:td_task_begin("sx")
	globaldata.fightresultkey = packet:GetInt()
	globaldata:updateBattleFormationTower(packet)
	globaldata:updateMonsterDropItem(packet)
	----
	
	GUISystem:hideLoading()

	if globaldata.fightagain then
		globaldata.fightagain = false
		FightSystem:reloadFightWindow()
	else
		-- __IsEnterFighting__ = true
		GUISystem:HideAllWindow()
		HomeWindow:destroyRootNode()
		showLoadingWindow("FightWindow")
	end
	FubenManager:OnPreEnterPveTower()
end

-- 战斗进入展示关卡
function globaldata:onEnterShowGuanqiaBattle()
	self.PvpType = "fuben"
	globaldata:updateBattleShowGuanqia()
	globaldata:updateBattleShowGuanqiaEnemy()
	GUISystem:hideLoading()
	GUISystem:HideAllWindow()
	HomeWindow:destroyRootNode()
	showLoadingWindow("FightWindow")
	FubenManager:OnEnterShowPve()
end

function globaldata:updateBattleShowGuanqia()
	globaldata.fubenstar = 3
	self.battleFormation = {}
	globaldata.battleFormationCount = 0

	globaldata.boardIDforShowGq = 3001
	globaldata.ShowGqhard = 1

	self.battleFormationCount = 3
	for i = 1, self.battleFormationCount do
		local ShowGuanqiaHeroList = {24,2,7}
		local newBattleObj = battleObject:new()
		newBattleObj.index = i -- 索引 
		newBattleObj.guid = "" -- 
		newBattleObj.id = ShowGuanqiaHeroList[i]
		newBattleObj.advanceLevel = 1
		newBattleObj.quality = 1
		newBattleObj.level = 1
		local _infoDB = DB_HeroConfig.getDataById(newBattleObj.id)
		local function parseSkill()
			  newBattleObj.skillList["SkillWeaponLevel"] = 0
			  newBattleObj.skillList["Role_NormalSkill1"] = _infoDB.Role_NormalSkill1
			  newBattleObj.skillList["Role_NormalSkill1_Level"] = 1
			  newBattleObj.skillList["Role_NormalSkill2"] = _infoDB.Role_NormalSkill2
			  newBattleObj.skillList["Role_NormalSkill3"] = _infoDB.Role_NormalSkill3
			  newBattleObj.skillList["Role_NormalSkill4"] = _infoDB.Role_NormalSkill4
			  newBattleObj.skillList["Role_SpecialSkill1"] = _infoDB.Role_SpecialSkill1
			  newBattleObj.skillList["Role_SpecialSkillActivate1"] = 1
			  newBattleObj.skillList["Role_SpecialSkillActivate1_Level"] = 1
			  newBattleObj.skillList["Role_SpecialSkill2"] = _infoDB.Role_SpecialSkill2
			  newBattleObj.skillList["Role_SpecialSkillActivate2"] = 1
			  newBattleObj.skillList["Role_SpecialSkillActivate2_Level"] = 1
			  newBattleObj.skillList["Role_SpecialSkill3"] = _infoDB.Role_SpecialSkill3
			  newBattleObj.skillList["Role_SpecialSkillActivate3"] = 1
			  newBattleObj.skillList["Role_SpecialSkillActivate3_Level"] = 1
			  newBattleObj.skillList["Role_SpecialSkill4"] = _infoDB.Role_SpecialSkill4
			  newBattleObj.skillList["Role_SpecialSkillActivate4"] = 1
			  newBattleObj.skillList["Role_SpecialSkillActivate4_Level"] = 1
			  newBattleObj.skillList["Role_PassiveSkill1"] = _infoDB.Role_PassiveSkill1
			  newBattleObj.skillList["Role_PassiveSkill2"] = _infoDB.Role_PassiveSkill2
			  newBattleObj.skillList["Role_PassiveSkill3"] = _infoDB.Role_PassiveSkill3
			  newBattleObj.skillList["Role_PassiveSkill4"] = _infoDB.Role_PassiveSkill4		
			  newBattleObj.skillList["Role_GroupSkill1"] = _infoDB.Role_GroupSkill1
			  newBattleObj.skillList["Role_GroupSkill2"] = _infoDB.Role_GroupSkill1
			  newBattleObj.skillList["Role_GroupMainSubFlag"] = _infoDB.Role_GroupMainSubFlag
			  newBattleObj.skillList["Role_GroupSkillFlag"] = _infoDB.Role_GroupSkillFlag
			  newBattleObj.skillList["Role_DodgeSkill"] = _infoDB.Role_DodgeSkill
		end
		local function parseProp()
			newBattleObj.propList[0] = _infoDB.InitHP
			newBattleObj.propList[1] = _infoDB.InitPhyAttack
			newBattleObj.propList[2] = _infoDB.InitArmorPene
			newBattleObj.propList[3] = _infoDB.InitArmor
			newBattleObj.propList[4] = _infoDB.InitHit
			newBattleObj.propList[5] = _infoDB.InitDodge
			newBattleObj.propList[6] = _infoDB.InitCrit
			newBattleObj.propList[7] = _infoDB.InitTenacity
			newBattleObj.propList[8] = _infoDB.InitAttackSpeed
			newBattleObj.propList[9] = _infoDB.InitMoveSpeed
			newBattleObj.propList[10] = _infoDB.InitJumpHeight
		end
		parseSkill()
		parseProp()
		self.battleFormation[newBattleObj.index] = newBattleObj
	end

end

function globaldata:updateBattleShowGuanqiaEnemy()

	self.enemyFormation = {}
	self.enemyFormationCount = 3
	for i = 1, self.enemyFormationCount do
		local ShowGuanqiaHeroList = {17,15,14}
		local newBattleObj = battleObject:new()
		newBattleObj.index = i -- 索引 
		newBattleObj.guid = "" -- 
		newBattleObj.id = ShowGuanqiaHeroList[i]
		newBattleObj.advanceLevel = 1
		newBattleObj.quality = 1
		newBattleObj.level = 1
		local _infoDB = DB_HeroConfig.getDataById(newBattleObj.id)
		local function parseSkill()
			  newBattleObj.skillList["SkillWeaponLevel"] = 0
			  newBattleObj.skillList["Role_NormalSkill1"] = _infoDB.Role_NormalSkill1
			  newBattleObj.skillList["Role_NormalSkill1_Level"] = 1
			  newBattleObj.skillList["Role_NormalSkill2"] = _infoDB.Role_NormalSkill2
			  newBattleObj.skillList["Role_NormalSkill3"] = _infoDB.Role_NormalSkill3
			  newBattleObj.skillList["Role_NormalSkill4"] = _infoDB.Role_NormalSkill4
			  newBattleObj.skillList["Role_SpecialSkill1"] = _infoDB.Role_SpecialSkill1
			  newBattleObj.skillList["Role_SpecialSkillActivate1"] = 1
			  newBattleObj.skillList["Role_SpecialSkillActivate1_Level"] = 1
			  newBattleObj.skillList["Role_SpecialSkill2"] = _infoDB.Role_SpecialSkill2
			  newBattleObj.skillList["Role_SpecialSkillActivate2"] = 1
			  newBattleObj.skillList["Role_SpecialSkillActivate2_Level"] = 1
			  newBattleObj.skillList["Role_SpecialSkill3"] = _infoDB.Role_SpecialSkill3
			  newBattleObj.skillList["Role_SpecialSkillActivate3"] = 1
			  newBattleObj.skillList["Role_SpecialSkillActivate3_Level"] = 1
			  newBattleObj.skillList["Role_SpecialSkill4"] = _infoDB.Role_SpecialSkill4
			  newBattleObj.skillList["Role_SpecialSkillActivate4"] = 1
			  newBattleObj.skillList["Role_SpecialSkillActivate4_Level"] = 1
			  newBattleObj.skillList["Role_PassiveSkill1"] = _infoDB.Role_PassiveSkill1
			  newBattleObj.skillList["Role_PassiveSkill2"] = _infoDB.Role_PassiveSkill2
			  newBattleObj.skillList["Role_PassiveSkill3"] = _infoDB.Role_PassiveSkill3
			  newBattleObj.skillList["Role_PassiveSkill4"] = _infoDB.Role_PassiveSkill4		
			  newBattleObj.skillList["Role_GroupSkill1"] = _infoDB.Role_GroupSkill1
			  newBattleObj.skillList["Role_GroupSkill2"] = _infoDB.Role_GroupSkill1
			  newBattleObj.skillList["Role_GroupMainSubFlag"] = _infoDB.Role_GroupMainSubFlag
			  newBattleObj.skillList["Role_GroupSkillFlag"] = _infoDB.Role_GroupSkillFlag
			  newBattleObj.skillList["Role_DodgeSkill"] = _infoDB.Role_DodgeSkill
		end
		local function parseProp()
			newBattleObj.propList[0] = _infoDB.InitHP
			newBattleObj.propList[1] = _infoDB.InitPhyAttack
			newBattleObj.propList[2] = _infoDB.InitArmorPene
			newBattleObj.propList[3] = _infoDB.InitArmor
			newBattleObj.propList[4] = _infoDB.InitHit
			newBattleObj.propList[5] = _infoDB.InitDodge
			newBattleObj.propList[6] = _infoDB.InitCrit
			newBattleObj.propList[7] = _infoDB.InitTenacity
			newBattleObj.propList[8] = _infoDB.InitAttackSpeed
			newBattleObj.propList[9] = _infoDB.InitMoveSpeed
			newBattleObj.propList[10] = _infoDB.InitJumpHeight
		end
		parseSkill()
		parseProp()
		self.enemyFormation[newBattleObj.index] = newBattleObj
	end

end

-- 战斗回包3021,进入副本
function globaldata:onRequestEnterBattle(packet)
	self.PvpType = "fuben"
	globaldata.fightresultkey = packet:GetInt()
	globaldata:updateBattleFormation(packet)
	globaldata:updateMonsterDropItem(packet)
	----
	
	GUISystem:hideLoading()

	if globaldata.fightagain then
		globaldata.fightagain = false
		FightSystem:reloadFightWindow()
	else
		__IsEnterFighting__ = true
		GUISystem:HideAllWindow()
		HomeWindow:destroyRootNode()
		if not globaldata.showguanqialayer then
			showLoadingWindow("FightWindow")
		end
	end
	FubenManager:OnPreEnterPve(globaldata.clickedchapter, globaldata.clickedsection, globaldata.clickedlevel)
end

-- 更新家具商品信息
function globaldata:updateFurnitShopInfoFromServer(packet)

	local goodsType = packet:GetChar()
	self.ShopFreshTime[goodsType] = packet:GetString()
	local function createGoodsObj(packet)
		local newGoods = goodsObject:new()
		newGoods.goodsIndex = packet:GetInt()	
		newGoods.goodsType = packet:GetChar()		
		newGoods.goodsId = packet:GetInt()				
		newGoods.goodsCurrencyType = packet:GetChar()	
		newGoods.goodsPrice = packet:GetInt()		
		newGoods.goodsConditionType = packet:GetChar()
		newGoods.goodsConditionParam = packet:GetInt() 	
		newGoods.goodsMaxBuyLimitPerDay = packet:GetInt()
		newGoods.goodsMaxBuyCount = packet:GetInt()
		return newGoods
	end

	self.FurnitGoodsList = {}
	local goodsNum = packet:GetUShort()
	for i = 1, goodsNum do
		table.insert(self.FurnitGoodsList, createGoodsObj(packet))
	end
end

-- 更新商品信息
function globaldata:updateGoodsInfoFromServerPacket(packet)
	local shopCount = packet:GetUShort()
	for i = 1, shopCount do
		local shopType = packet:GetChar()
		self.ShopFreshTime[shopType] = packet:GetString()
		local function createGoodsObj(packet)
			local newGoods = goodsObject:new()
			newGoods.goodsIndex = packet:GetInt()	
			newGoods.goodsType = packet:GetChar()		
			newGoods.goodsId = packet:GetInt()
			newGoods.goodsCurrencyType = packet:GetChar()	
			newGoods.goodsPrice = packet:GetInt()		
			newGoods.goodsConditionType = packet:GetChar()
			newGoods.goodsConditionParam = packet:GetInt()
			newGoods.goodsMaxBuyLimitPerDay = packet:GetInt()
			newGoods.goodsMaxBuyCount = packet:GetInt()

			return newGoods
		end

		self.ShopGoodsList[shopType] = {}

		local goodsNum = packet:GetUShort()
		print("商店类型", shopType, "商品数量", goodsNum)
		for i = 1, goodsNum do
			table.insert(self.ShopGoodsList[shopType], createGoodsObj(packet))
		end

		GUIEventManager:pushEvent("shopFreshed", shopType)
		GUISystem:hideLoading()
	end

	--[[

	商店类型:
	1:	大厅商城 	-- 宝箱页签
	2:	神秘商店
	3:	武道馆商店
	4:	家具商店 	-- 暂时没用
	5:	公会商店
	7:	大厅商城 	-- 宝石页签
	8:	制霸之战商店
	9:	礼物购买商店
	10: 大厅商城 	-- 时装页签 			

	]]--
	
end

-- 单独更新某个英雄的信息
-- 通常为英雄升星时调用（该英雄技能初始化包含所有该有的技能）
function globaldata:updateOneHeroInfo(msgPacket)
	
	local guid = msgPacket:GetString()
	local index = msgPacket:GetInt()
	local id = msgPacket:GetInt()
	local newHero = self:findHeroById(id)
	newHero.guid = guid
	newHero.index = index
	newHero.id = id
	newHero.name = msgPacket:GetString()
	newHero.level = msgPacket:GetInt()
	newHero.exp = msgPacket:GetInt()
	newHero.maxExp = msgPacket:GetInt()
	newHero.advanceLevel = msgPacket:GetInt()
	newHero.quality = msgPacket:GetInt()
	newHero.combat = msgPacket:GetInt()
	newHero.chipId = msgPacket:GetInt()
	newHero.chipCount = msgPacket:GetInt()

	-- 进阶信息
	newHero.isMaxAdvancedLv = msgPacket:GetChar()
	if newHero.isMaxAdvancedLv ~= 0 then
	   newHero.nextAdvancedLv = msgPacket:GetInt()
	   newHero.advancedCostList = {}
	   local _costCount = msgPacket:GetUShort()
	   for i = 1, _costCount do
	   	   local _advancedCost = heroAdvancedCost:new()
	   	   _advancedCost.itemType = msgPacket:GetInt()
	   	   _advancedCost.itemId = msgPacket:GetInt()
	   	   _advancedCost.itemNum = msgPacket:GetInt()
	   	   table.insert(newHero.advancedCostList, _advancedCost)
	   end
	end

	-- 取出该英雄的属性信息
	newHero.propCount = msgPacket:GetUShort()
	newHero.propList = {}
	newHero.propListEx = {}
	for m = 1, newHero.propCount do
		local propType = msgPacket:GetChar()
		local val = msgPacket:GetInt()
		newHero.propList[propType] = val
		newHero.propListEx[propType] = msgPacket:GetInt()
	end

	-- 取出该英雄的成长属性信息
	newHero.growPropCount = msgPacket:GetUShort()
	newHero.growPropList = {}
	for k = 1, newHero.growPropCount do
		local propType = msgPacket:GetChar()
		local percent = msgPacket:GetInt()
		newHero.growPropList[propType] = percent
	end
	-- 取出该英雄的装备信息
	newHero.equipCount = msgPacket:GetUShort()
	newHero.equipList = {}
	for j = 1, newHero.equipCount do
		local newEquip = equipObject:new()
		newEquip.type = msgPacket:GetInt()
		newEquip.level = msgPacket:GetInt()
		newEquip.guid = msgPacket:GetString()
		newEquip.id = msgPacket:GetInt()
		newEquip.quality = msgPacket:GetInt()
		newEquip.qualityAddValue = msgPacket:GetInt()
		newEquip.advanceLevel = msgPacket:GetInt()
		local diamondCount = msgPacket:GetUShort()
		for i = 1, diamondCount do
			local index = msgPacket:GetChar()
			local value = msgPacket:GetInt()
			newEquip.diamondList[index] = value
		end

		newEquip.propCount = msgPacket:GetUShort()
		for m = 1, newEquip.propCount do
			local propType = msgPacket:GetChar()
			local propVal = msgPacket:GetInt()
			newEquip.propList[propType] = propVal
		end

		newEquip.growPropCount = msgPacket:GetUShort()
		for m = 1, newEquip.growPropCount do
			local propType = msgPacket:GetChar()
			local propVal = msgPacket:GetInt()
			newEquip.growPropList[propType] = propVal
		end

		newEquip.strengthGoodCount = msgPacket:GetUShort()
		for i = 1, newEquip.strengthGoodCount do
			newEquip.strengthGoodList[i] = strengthGoodObject:new()
			newEquip.strengthGoodList[i].mType = msgPacket:GetInt()
			newEquip.strengthGoodList[i].mId = msgPacket:GetInt()
			newEquip.strengthGoodList[i].mCount = msgPacket:GetInt()
		end

		newHero.equipList[j] = newEquip
	end
	-- 取出该英雄的技能信息
	newHero.skillCount = msgPacket:GetUShort()
	newHero.skillList = {}
	cclog("updateheroskill================================" .. newHero.skillCount)
	for i = 1, newHero.skillCount do
		newHero.skillList[i] = skillObject:new()
		newHero.skillList[i].mSkillId = msgPacket:GetInt()
		newHero.skillList[i].mSkillType = msgPacket:GetChar()
		newHero.skillList[i].mSkillIndex = msgPacket:GetChar()
		newHero.skillList[i].mSkillSelected = msgPacket:GetChar()
		newHero.skillList[i].mSkillLevel = msgPacket:GetInt()
		newHero.skillList[i].mPrice = msgPacket:GetInt()
		cclog("skill==tp:" .. newHero.skillList[i].mSkillType .."=idx:" .. newHero.skillList[i].mSkillIndex .. "=lv:" .. newHero.skillList[i].mSkillLevel)
	end
	newHero.changeColorCount = msgPacket:GetUShort()
	for i=1,newHero.changeColorCount do
		local Colordata = {}
		Colordata.partType = msgPacket:GetChar()
		Colordata.colorType = msgPacket:GetChar()
		if Colordata.colorType > 0 then
			Colordata.colorArrCount = msgPacket:GetUShort()
			Colordata.colorArr = {}
			for i=1,Colordata.colorArrCount do
				Colordata.colorArr[i] = msgPacket:GetUShort()
			end
		end
		newHero.changeColorList[i] = Colordata
	end

	newHero.talentPointCount = msgPacket:GetInt()
	newHero.talentOwnCount = msgPacket:GetUShort()
	newHero.talentOwnList = {}
	for i = 1, newHero.talentOwnCount do
		newHero.talentOwnList[i] = {}
		newHero.talentOwnList[i].talentType = msgPacket:GetChar()
		newHero.talentOwnList[i].talentLevel = msgPacket:GetChar()
		newHero.talentOwnList[i].talentLevelMax = msgPacket:GetChar()
	end

	local weaponId = msgPacket:GetInt()
	if weaponId > 0 then
		newHero.weapon 				= 	heroWeaponObject:new()
		newHero.weapon.mId 			=	weaponId
		newHero.weapon.mLevel 		=	msgPacket:GetInt()
		newHero.weapon.mMoney		=	msgPacket:GetInt()
		newHero.weapon.mItemCnt 	=	msgPacket:GetInt()
	end

	cclog("================================")
end

-- 获取物品链表
function globaldata:getItemList()
	return self.itemList
end

-- 增加物品
function globaldata:addItem(itemType, itemId, itemNum)
	if not self.itemList[itemType] then
		self.itemList[itemType] = {}
	end
	local newItem = itemObject:new()
	newItem.itemId = itemId
	newItem.itemType = itemType
	newItem.itemNum = itemNum
	table.insert(self.itemList[newItem.itemType], newItem)
end

-- 获取物品信息
function globaldata:getItemInfo(itemType, itemId)
	if itemType and self.itemList[itemType] then
		for k, v in pairs(self.itemList[itemType]) do
			if itemId == v.itemId then
				return v
			end
		end
	else
		for k, v in pairs(self.itemList) do
			for m, n in pairs(v) do
				if itemId == n.itemId then
					return n
				end
			end
		end
	end
	return nil
end

-- 获取物品数量
function globaldata:getItemOwnCount(itemId)
	local itemObj = self:getItemInfo(nil, itemId)
	if itemObj then
		return itemObj.itemNum
	end

	return 0
end

-- 设置物品数量
function globaldata:setItemOwnCount(itemId, itemCnt)
	local itemObj = self:getItemInfo(nil, itemId)
	if itemObj then
		itemObj.itemNum = itemCnt
	end
end

-- 删除物品
function globaldata:removeItem(itemType, itemId)
	if itemType then
		for i = 1, #self.itemList[itemType] do
			if itemId == self.itemList[itemType][i].itemId then
				table.remove(self.itemList[itemType], i)
				return
			end
		end
	else
		for k, v in pairs(self.itemList) do
			for i = 1, #v[i] do
				if itemId == v[i].itemId then
					table.remove(v, i)
				end
			end
		end
	end
end

-- 更新抽卡信息
function globaldata:updateLotteryInfoFromServerPacket(packet)
	self.lotteryCount = packet:GetUShort()

	for i = 1, self.lotteryCount do
		local newLottery = lotteryObject:new()
		newLottery.id = packet:GetInt()
		newLottery.freeNum = packet:GetInt()
		newLottery.freeMaxNum = packet:GetInt()
		newLottery.leftTime = packet:GetInt()
		newLottery.onceCostType = packet:GetInt()
		newLottery.onceCostId = packet:GetInt()
		newLottery.onceCostNum = packet:GetInt()
		newLottery.onceSecretAdd = packet:GetInt()
		newLottery.tenthCostType = packet:GetInt()
		newLottery.tenthCostId = packet:GetInt()
		newLottery.tenthCostNum = packet:GetInt()
		newLottery.tenthSecretAdd = packet:GetInt()
		self.lotteryList[i] = newLottery
	end
end

-- 获取抽卡信息
function globaldata:getLotteryByTypeAndKey(lotteryType, key)
	for i = 1, #self.lotteryList do
		if lotteryType == self.lotteryList[i].id then
			return self.lotteryList[i][key]
		end
	end
end

-- 抽卡是否免费
function globaldata:isLotteryFree(lotteryType)
	for i = 1, #self.lotteryList do
		if lotteryType == self.lotteryList[i].id then
			if self.lotteryList[i].freeNum > 0 then
				return true
			end
		end
	end
	return false
end


-- 更新玩家基础数据
function globaldata:setPlayerBaseData(key, val)
	if globaldata[key] then
		globaldata[key] = val
		print("值:", val)
	end
end

-- 更新玩家前一次基础数据
function globaldata:setPlayerPreBaseData(key, val)
	globaldata.preBaseData[key] = val	
end

-- 获取玩家前一次基础数据
function globaldata:getPlayerPreBaseData(key)
	return globaldata.preBaseData[key]
end

-- 获取玩家基础数据
function globaldata:getPlayerBaseData(key)
	if globaldata[key] then
		return globaldata[key]
	end
	doError(string.format("playerBaseData %s dosen't exist!",tostring(key)))
	return nil
end

-- 初始化英雄数据
function globaldata:initHeroTeam(packet)
	-- 初始化前，先将队伍列表置空
	globaldata.heroTeam = {}
	----
	globaldata.heroCount = packet:GetUShort()
	for i = 1, globaldata.heroCount do
		local newHero = heroObject:new()
		newHero.guid = packet:GetString()
		newHero.index = packet:GetInt() -- 0:没有 1:有
		newHero.id = packet:GetInt()
		newHero.name = packet:GetString()
		newHero.level = packet:GetInt()
		newHero.exp = packet:GetInt()
		newHero.maxExp = packet:GetInt()
		newHero.advanceLevel = packet:GetInt()
		newHero.quality = packet:GetInt()
		newHero.combat = packet:GetInt()
		newHero.chipId = packet:GetInt()
		newHero.chipCount = packet:GetInt()
		-- 进阶信息
		newHero.isMaxAdvancedLv = packet:GetChar()
		if newHero.isMaxAdvancedLv ~= 0 then
		   newHero.nextAdvancedLv = packet:GetInt()
		   newHero.advancedCostList = {}
		   local _costCount = packet:GetUShort()
		   for i = 1, _costCount do
		   	   local _advancedCost = heroAdvancedCost:new()
		   	   _advancedCost.itemType = packet:GetInt()
		   	   _advancedCost.itemId = packet:GetInt()
		   	   _advancedCost.itemNum = packet:GetInt()
		   	   table.insert(newHero.advancedCostList, _advancedCost)
		   end
		end
		-- 取出该英雄的属性信息
		newHero.propList = {}
		newHero.propListEx = {}
		newHero.propCount = packet:GetUShort()
		for m = 1, newHero.propCount do
			local propType = packet:GetChar()
			local val = packet:GetInt()
			newHero.propList[propType] = val
			newHero.propListEx[propType] = packet:GetInt()
		end
		-- 取出该英雄的成长属性信息
		newHero.growPropLis = {}
		newHero.growPropCount = packet:GetUShort()
		for k = 1, newHero.growPropCount do
			local propType = packet:GetChar()
			local percent = packet:GetInt()
			newHero.growPropList[propType] = percent
		end
		globaldata.heroTeam[newHero.guid] = newHero
		-- 取出该英雄的装备信息
		newHero.equipCount = packet:GetUShort()
		for j = 1, newHero.equipCount do
			local newEquip = equipObject:new()
			newEquip.type = packet:GetInt()
			newEquip.level = packet:GetInt()
			newEquip.guid = packet:GetString()
			newEquip.id = packet:GetInt()
			newEquip.quality = packet:GetInt()
			newEquip.qualityAddValue = packet:GetInt()
			newEquip.advanceLevel = packet:GetInt()
			local diamondCount = packet:GetUShort()
			print("宝石数量", diamondCount)
			newEquip.diamondList = {0, 0, 0, 0, 0}
			for i = 1, diamondCount do
				local index = packet:GetChar()
				local value = packet:GetInt()
				print("宝石位置:", index, "宝石值:", value)
				newEquip.diamondList[index] = value
			end

			newEquip.propCount = packet:GetUShort()
			for m = 1, newEquip.propCount do
				local propType = packet:GetChar()
				local propVal = packet:GetInt()
				newEquip.propList[propType] = propVal
			end

			newEquip.growPropCount = packet:GetUShort()
			for m = 1, newEquip.growPropCount do
				local propType = packet:GetChar()
				local propVal = packet:GetInt()
				newEquip.growPropList[propType] = propVal
			end

			newEquip.strengthGoodCount = packet:GetUShort()
			newEquip.strengthGoodList = {}
			for i = 1, newEquip.strengthGoodCount do
				newEquip.strengthGoodList[i] = strengthGoodObject:new()
				newEquip.strengthGoodList[i].mType = packet:GetInt()
				newEquip.strengthGoodList[i].mId = packet:GetInt()
				newEquip.strengthGoodList[i].mCount = packet:GetInt()
				
				print(i, newEquip.strengthGoodList[i].mType, newEquip.strengthGoodList[i].mId, newEquip.strengthGoodList[i].mCount)
			end

			newHero.equipList[j] = newEquip
		end

		-- 取出该英雄的技能信息
		newHero.skillCount = packet:GetUShort()
		for i = 1, newHero.skillCount do
			newHero.skillList[i] = skillObject:new()
			newHero.skillList[i].mSkillId = packet:GetInt()
			newHero.skillList[i].mSkillType = packet:GetChar()
			newHero.skillList[i].mSkillIndex = packet:GetChar()
			newHero.skillList[i].mSkillSelected = packet:GetChar()
			newHero.skillList[i].mSkillLevel = packet:GetInt()
			newHero.skillList[i].mPrice = packet:GetInt()
		end
		newHero.changeColorCount = packet:GetUShort()
		for i=1,newHero.changeColorCount do
			local Colordata = {}
			Colordata.partType = packet:GetChar()
			Colordata.colorType = packet:GetChar()
			if Colordata.colorType > 0 then
				Colordata.colorArrCount = packet:GetUShort()
				Colordata.colorArr = {}
				for i=1,Colordata.colorArrCount do
					Colordata.colorArr[i] = packet:GetUShort()
				end
			end
			newHero.changeColorList[i] = Colordata
		end

		newHero.talentPointCount = packet:GetInt()
		newHero.talentOwnCount = packet:GetUShort()
		newHero.talentOwnList = {}
		for i = 1, newHero.talentOwnCount do
			newHero.talentOwnList[i] = {}
			newHero.talentOwnList[i].talentType = packet:GetChar()
			newHero.talentOwnList[i].talentLevel = packet:GetChar()
			newHero.talentOwnList[i].talentLevelMax = packet:GetChar()
		end

		local weaponId = packet:GetInt()
		if weaponId > 0 then
			newHero.weapon 				= 	heroWeaponObject:new()
			newHero.weapon.mId 			=	weaponId
			newHero.weapon.mLevel 		=	packet:GetInt()
			newHero.weapon.mMoney		=	packet:GetInt()
			newHero.weapon.mItemCnt 	=	packet:GetInt()
		end

		-- 排序
		local function sortFunc(skillObj1, skillObj2)
			if skillObj1.mSkillType < skillObj2.mSkillType then
				return true
			elseif skillObj1.mSkillType == skillObj2.mSkillType then
				return skillObj1.mSkillIndex < skillObj2.mSkillIndex
			elseif skillObj1.mSkillType > skillObj2.mSkillType then
				return false
			end
		end
		table.sort(newHero.skillList, sortFunc)
--[[
		doError("111")
		for i = 1, #newHero.skillList do
			print("技能id:", newHero.skillList[i].mSkillId, 
				"技能大类型:", newHero.skillList[i].mSkillType,
				"技能小类型:", newHero.skillList[i].mSkillIndex)
		end
		doError("222")
]]
	end
end

-- 添加英雄(抽卡)
function globaldata:addHeroFromLottery(packet)
	local newHero = heroObject:new()
	newHero.guid = packet:GetString()
	newHero.index = packet:GetInt()
	newHero.id = packet:GetInt()
	newHero.name = packet:GetString()
	newHero.level = packet:GetInt()
	newHero.exp = packet:GetInt()
	newHero.maxExp = packet:GetInt()
	newHero.advanceLevel = packet:GetInt()
	newHero.quality = packet:GetInt()
	newHero.combat = packet:GetInt()
	newHero.chipId = packet:GetInt()
	newHero.chipCount = packet:GetInt()

	-- 进阶信息
	newHero.isMaxAdvancedLv = packet:GetChar()
	if newHero.isMaxAdvancedLv ~= 0 then
	   newHero.nextAdvancedLv = packet:GetInt()
	   newHero.advancedCostList = {}
	   local _costCount = packet:GetUShort()
	   for i = 1, _costCount do
	   	   local _advancedCost = heroAdvancedCost:new()
	   	   _advancedCost.itemType = packet:GetInt()
	   	   _advancedCost.itemId = packet:GetInt()
	   	   _advancedCost.itemNum = packet:GetInt()
	   	   table.insert(newHero.advancedCostList, _advancedCost)
	   end
	end

	-- 取出该英雄的属性信息
	newHero.propCount = packet:GetUShort()
	newHero.propList = {}
	newHero.propListEx = {}
	for m = 1, newHero.propCount do
		local propType = packet:GetChar()
		local val = packet:GetInt()
		newHero.propList[propType] = val
		newHero.propListEx[propType] = packet:GetInt()
	end
	
	-- 取出该英雄的成长属性信息
	newHero.growPropCount = packet:GetUShort()
	for k = 1, newHero.growPropCount do
		local propType = packet:GetChar()
		local percent = packet:GetInt()
		newHero.growPropList[propType] = percent
	end
	globaldata.heroTeam[newHero.guid] = newHero

	-- 取出该英雄的装备信息
	newHero.equipCount = packet:GetUShort()
	for j = 1, newHero.equipCount do
		local newEquip = equipObject:new()
		newEquip.type = packet:GetInt()
		newEquip.level = packet:GetInt()
		newEquip.guid = packet:GetString()
		newEquip.id = packet:GetInt()
		newEquip.quality = packet:GetInt()
		newEquip.qualityAddValue = packet:GetInt()
		newEquip.advanceLevel = packet:GetInt()
		local diamondCount = packet:GetUShort()
		for i = 1, diamondCount do
			local index = packet:GetChar()
			local value = packet:GetInt()
			newEquip.diamondList[index] = value
		end

		newEquip.propCount = packet:GetUShort()
		for m = 1, newEquip.propCount do
			local propType = packet:GetChar()
			local propVal = packet:GetInt()
			newEquip.propList[propType] = propVal
		end
		newEquip.growPropCount = packet:GetUShort()
		for m = 1, newEquip.growPropCount do
			local propType = packet:GetChar()
			local propVal = packet:GetInt()
			newEquip.growPropList[propType] = propVal
		end

		newEquip.strengthGoodCount = packet:GetUShort()
		for i = 1, newEquip.strengthGoodCount do
			newEquip.strengthGoodList[i] = strengthGoodObject:new()
			newEquip.strengthGoodList[i].mType = packet:GetInt()
			newEquip.strengthGoodList[i].mId = packet:GetInt()
			newEquip.strengthGoodList[i].mCount = packet:GetInt()
		end


		newHero.equipList[j] = newEquip
	end

	-- 取出该英雄的技能信息
	-- 技能类型: 1:普通 2:主动 3:被动 4:合体
	newHero.skillCount = packet:GetUShort()
	for i = 1, newHero.skillCount do
		newHero.skillList[i] = skillObject:new()
		newHero.skillList[i].mSkillId = packet:GetInt()
		newHero.skillList[i].mSkillType = packet:GetChar()
		newHero.skillList[i].mSkillIndex = packet:GetChar()
		newHero.skillList[i].mSkillSelected = packet:GetChar()
		newHero.skillList[i].mSkillLevel = packet:GetInt()
		newHero.skillList[i].mPrice = packet:GetInt()
	end

	newHero.changeColorCount = packet:GetUShort()
	for i=1,newHero.changeColorCount do
		local Colordata = {}
		Colordata.partType = packet:GetChar()
		Colordata.colorType = packet:GetChar()
		if Colordata.colorType > 0 then
			Colordata.colorArrCount = packet:GetUShort()
			Colordata.colorArr = {}
			for i=1,Colordata.colorArrCount do
				Colordata.colorArr[i] = packet:GetUShort()
			end
		end
		newHero.changeColorList[i] = Colordata
	end

	newHero.talentPointCount = packet:GetInt()
	newHero.talentOwnCount = packet:GetUShort()
	newHero.talentOwnList = {}
	for i = 1, newHero.talentOwnCount do
		newHero.talentOwnList[i] = {}
		newHero.talentOwnList[i].talentType = packet:GetChar()
		newHero.talentOwnList[i].talentLevel = packet:GetChar()
		newHero.talentOwnList[i].talentLevelMax = packet:GetChar()
	end

	local weaponId = packet:GetInt()
	if weaponId > 0 then
		newHero.weapon 				= 	heroWeaponObject:new()
		newHero.weapon.mId 			=	weaponId
		newHero.weapon.mLevel 		=	packet:GetInt()
		newHero.weapon.mMoney		=	packet:GetInt()
		newHero.weapon.mItemCnt 	=	packet:GetInt()
	end

	return newHero.id, newHero.quality
end

-- 更新上阵英雄数据
function globaldata:updateBattleTeam(packet)
	globaldata.battleCount = packet:GetUShort()

	for i = 1, globaldata.battleCount do
		local guid = packet:GetString()
		local battleHero = globaldata.heroTeam[guid]
	 	battleHero.index = packet:GetInt()
	 	battleHero.combat = packet:GetInt()

	 	local newPostion = posObject:new()
	 	newPostion.guid = guid
		-- 取出该英雄的属性信息
		battleHero.propCount = packet:GetUShort()
		for m = 1, battleHero.propCount do
			local propType = packet:GetChar()
			local val = packet:GetInt()
			battleHero.propList[propType] = val
		end

		globaldata.battleTeam[battleHero.index] = newPostion
	end
end

-- 获取上阵队伍英雄数量
function globaldata:getBattleHeroCount()
	self.battleCount = 0 
	for k, v in pairs(self.battleTeam) do
		self.battleCount = self.battleCount + 1
	end
	return self.battleCount
end

-- 阵位上是否有人
function globaldata:isBattleIndexExist(index)
	if self.battleTeam[index] then
		return true
	end
	return false
end


-- 根据Index获取上阵队伍指定英雄指定信息
function globaldata:getHeroInfoByBattleIndex(index, key, part)
	local heroObj = nil
	if index == 1 then
		heroObj = globaldata:findHeroById(globaldata.leaderHeroId)
	else
		heroObj = globaldata:findHeroById(index)
	end
	if not heroObj then return end
	
	if "horse" == key then

		local equipList = heroObj.equipList
		for i = 1, #equipList do
			if equipList[i].type == 9 then
				local _itemID = equipList[i].id
				local _horseID = DB_EquipmentConfig.getDataById(_itemID).FashionHorseID
				return _horseID
			end
		end
		return nil
	elseif "weapon" == key then
		local equipList = heroObj.equipList
		for i = 1, #equipList do
			if equipList[i].type == 7 then
				local _itemID = equipList[i].id
				return DB_EquipmentConfig.getDataById(_itemID)
			end
		end
		return nil
	elseif "dress" == key then
		local equipList = heroObj.equipList
		for i = 1, #equipList do
			local _itemID = equipList[i].id
			local Equip = DB_EquipmentConfig.getDataById(_itemID)
			if heroObj.id == Equip.RoleLimit then
				return Equip
			end
		end
		return nil
	elseif "changecolor" == key then
		if part then
			return heroObj.changeColorList[part]
		else
			return heroObj.changeColorList
		end
	end
	if heroObj then
		return heroObj[key]
	end
	return nil

	--[[

	if "horse" == key then
		local posObj = self.battleTeam[index]
		if posObj then
			local guid = self.battleTeam[index].guid
			if guid then
				local equipList = self:getHeroInfoByGUID(guid, "equipList")
				for i = 1, #equipList do
					if equipList[i].type == 9 then
						local _itemID = equipList[i].id
						local _horseID = DB_EquipmentConfig.getDataById(_itemID).FashionHorseID
						return _horseID
					end
				end
			end
			return nil
		else
			return nil
		end
		return
	elseif "weapon" == key then
		local posObj = self.battleTeam[index]
		if posObj then
			local guid = self.battleTeam[index].guid
			if guid then
				local equipList = self:getHeroInfoByGUID(guid, "equipList")
				for i = 1, #equipList do
					if equipList[i].type == 7 then
						local _itemID = equipList[i].id
						return DB_EquipmentConfig.getDataById(_itemID)
					end
				end
			end
			return nil
		else
			return nil
		end
	elseif "dress" == key then
		local posObj = self.battleTeam[index]
		if posObj then
			local posObj = self.battleTeam[index]
			if posObj then
				local guid = self.battleTeam[index].guid
				if guid then
					local equipList = self:getHeroInfoByGUID(guid, "equipList")
					for i = 1, #equipList do
						local _itemID = equipList[i].id
						local Equip = DB_EquipmentConfig.getDataById(_itemID)
						if self:getHeroInfoByGUID(posObj.guid, "id") == Equip.RoleLimit then
							return Equip
						end
					end
					return nil
				end
			end
		else
			return nil
		end
	end
	if self.battleTeam[index] then
		local guid = self.battleTeam[index].guid
		if guid then
			return self:getHeroInfoByGUID(guid, key)
		end
	end
	return nil
	]]
end

-- 根据Guid获取上阵队伍指定英雄指定信息
function globaldata:getHeroInfoByBattleGuid(guid, key)
	local index = nil
	for k,v in pairs(self.battleTeam) do
		if v.guid == guid then
			index = k
			break
		end
	end
	if not index then return nil end

	if "horse" == key then
		local posObj = self.battleTeam[index]
		if posObj then
			local guid = self.battleTeam[index].guid
			if guid then
				local equipList = self:getHeroInfoByGUID(guid, "equipList")
				for i = 1, #equipList do
					if equipList[i].type == 9 then
						local _itemID = equipList[i].id
						local _horseID = DB_EquipmentConfig.getDataById(_itemID).FashionHorseID
						return _horseID
					end
				end
			end
			return nil
		else
			return nil
		end
		return
	elseif "weapon" == key then
		local posObj = self.battleTeam[index]
		if posObj then
			local guid = self.battleTeam[index].guid
			if guid then
				local equipList = self:getHeroInfoByGUID(guid, "equipList")
				for i = 1, #equipList do
					if equipList[i].type == 7 then
						local _itemID = equipList[i].id
						return DB_EquipmentConfig.getDataById(_itemID)
					end
				end
			end
			return nil
		else
			return nil
		end
	elseif "dress" == key then
		local posObj = self.battleTeam[index]
		if posObj then
			local posObj = self.battleTeam[index]
			if posObj then
				local guid = self.battleTeam[index].guid
				if guid then
					local equipList = self:getHeroInfoByGUID(guid, "equipList")
					for i = 1, #equipList do
						local _itemID = equipList[i].id
						local Equip = DB_EquipmentConfig.getDataById(_itemID)
						if self:getHeroInfoByGUID(posObj.guid, "id") == Equip.RoleLimit then
							return Equip
						end
					end
					return nil
				end
			end
		else
			return nil
		end
	end
	if self.battleTeam[index] then
		local guid = self.battleTeam[index].guid
		if guid then
			return self:getHeroInfoByGUID(guid, key)
		end
	end
	return nil

	
end

-- 英雄是否拥有
function globaldata:isHeroIdExist(heroId)
	for k, v in pairs(globaldata.heroTeam) do
		if heroId == v.id then
			return true
		end
	end
	return false
end

-- 英雄是否在阵上
function globaldata:isHeroIdInBattle(id)
	for i = 1, 5 do
		if id == self:getHeroInfoByBattleIndex(i,"id") then
			return true
		end
	end
	return false
end

-- 根据id查找英雄
function globaldata:findHeroById(heroId)
	for k, v in pairs(globaldata.heroTeam) do
		if heroId == v.id then
			return v
		end
	end
--	doError(string.format("id:%s dosen't exist!",tostring(id)))
	return nil
end

-- 获取英雄总数量
function globaldata:getHeroTotalCount()
	local cnt = 0 
	for k, v in pairs(globaldata.heroTeam) do
		cnt = cnt + 1
	end
	return cnt
end

-- 获取指定guid的装备
function globaldata:getEquipByGuid(equipGuid)
	for k, v in pairs(globaldata.heroTeam) do
		local equipList = v:getKeyValue("equipList") 
		for j = 1, #equipList do
			if equipGuid == equipList[j].guid then
				equipObj = equipList[j]
				return equipObj
			end
		end
	end
	return nil
end

-- 获取总的英雄列表
function globaldata:getTotalHeroTeam()
	return self.heroTeam
end

-- 获得所有未穿着的装备
function globaldata:getTotalEquipList()
	return self.equipList
end

-- 获取指定装备位装备链表
function globaldata:getEquipListByIndex(index)
	if index < 6 and self.battleTeam[index] then
		local guid = self.battleTeam[index].guid
		if guid then
			local equipList = self:getHeroInfoByGUID(guid, "equipList")
			return equipList
		end
	elseif 6 == index then
		return self.equipList
	end
	return nil
end

-- 指定位置装备是否存在
function globaldata:isEquipExist(index1, index2)
	local equipList = self:getEquipListByIndex(index1)
	if not equipList then
		return false
	end
	for k, v in pairs(equipList) do
		if v.type == index2 then
			return true
		end
	end
	return false
end

-- 指定英雄的装备是否存在
function globaldata:isHeroEquipExist(heroId, equipType)
	local heroObj = globaldata:findHeroById(heroId)
	if heroObj then
		local equipList = heroObj.equipList
		for i = 1, #equipList do
			if equipType == equipList[i].type then
				return equipList[i]
			end
		end
	end
	return false
end

-- 根据GUID获取上阵队伍指定英雄指定信息
function globaldata:getHeroInfoByGUID(guid, key)
	local obj = self.heroTeam[guid]
	-- 取key对应的value
	if obj then
		return obj[key]
	else
		doError(string.format("guid: %s dosen't exist!",tostring(guid)))
		return nil
	end
end

-- 获取抽卡信息
function globaldata:getLotteryInfo(id, key)
	local obj = globaldata.lotteryList[id]
	if obj then
		if obj[key] then
			return obj[key]
		end
	end
	return nil
end

-- 设置QA参数 
function globaldata:setQAParam(param)
	self.QAParamList = param
end

-- 1303 接收服务器返回新场景进入数据
function globaldata:onCityHallNewSceneEnter(packet)
	-- 主城镇数据
	self:updateCityHallData(packet)
	-- 通知进入城镇
	GUISystem:hideLoading()
	if globaldata.CityCallFun then
		globaldata.CityCallFun()
		globaldata.CityCallFun = nil
	end
	FightSystem.mFightType = "none"
	local _cityid = globaldata:getCityHallData("cityid")
	FightSystem.mHallManager:OnPreEnterCity(_cityid)
end

-- 副本计算返回 3023
function globaldata:onFubenBalance(packet)
	self.isFubenBalance = true
	self.fubenbalancedata = {}
	self.fubenbalancedata.result = packet:GetChar()
	if self.fubenbalancedata.result == 1 then
		
	else
		self.fubenbalancedata.prePlayerLevel = packet:GetInt()
		self.fubenbalancedata.prePlayerExp = packet:GetInt()
		self.fubenbalancedata.prePlayerMaxExp = packet:GetInt()
		self.fubenbalancedata.addPlayerExp = packet:GetInt()
		self.fubenbalancedata.isLevelup = packet:GetChar()

		self.fubenbalancedata.curPlayerLevel = packet:GetInt()
		self.fubenbalancedata.curPlayerExp = packet:GetInt()
		self.fubenbalancedata.curPlayerMaxExp = packet:GetInt()

		self.fubenbalancedata.heroCount = packet:GetUShort()

		self.fubenbalancedata.heroinfoList = {}
		for i=1,self.fubenbalancedata.heroCount do
			local heroinfo = {}
			heroinfo.heroid = packet:GetInt()
			heroinfo.heropreLevel = packet:GetInt()
			heroinfo.heropreExp = packet:GetInt()
			heroinfo.heropreMaxExp = packet:GetInt()
			heroinfo.heroaddheroExp = packet:GetInt()
			heroinfo.heroisLevelup = packet:GetChar()
			heroinfo.herocurLevel = packet:GetInt()
			heroinfo.herocurExp = packet:GetInt()
			heroinfo.herocurMaxExp = packet:GetInt()

			self.fubenbalancedata.heroinfoList[i] = heroinfo
		end

		self.fubenbalancedata.money = packet:GetInt()
		self.fubenbalancedata.rewardnumcount = packet:GetUShort()
		self.fubenbalancedata.rewarditemlist = {}

		for i=1,self.fubenbalancedata.rewardnumcount do
			local item = {}
			item.type = packet:GetInt()
			item.id =  packet:GetInt()
			item.num = packet:GetInt()
			item.isget = packet:GetChar()
			self.fubenbalancedata.rewarditemlist[i] = item
		end
	end
	FightSystem.mFubenManager:BackFubenResult(self.fubenbalancedata.result)
end



function globaldata:onPvpArenaResultBack(packet)
	self.isFubenBalance = true
	self.ArenaWin = packet:GetChar()
	self.ArenaReward = packet:GetChar()
	if self.ArenaReward == 1 then
		self.oldHighRank = packet:GetInt()
		self.newHighRank = packet:GetInt()
		globaldata.FubenconstRewardNum = packet:GetUShort()
		globaldata.FubenconstRewardList = {}
		for i=1,globaldata.FubenconstRewardNum do
			local item = {}
			item.itemType = packet:GetInt()
			item.itemId =  packet:GetInt()
			item.itemNum = packet:GetInt()
			globaldata.FubenconstRewardList[i] = item
		end
	end
	FightSystem:GetFightManager():BackPvpArenaResult()
end

function globaldata:onBossResultBack(packet)
	self.isFubenBalance = true
	FightSystem:GetFightManager():BackBossResult()
end


-- 掠夺计算返回 8015
function globaldata:onFubenPlunderBalance(packet)
	local count = packet:GetUShort()
	globaldata.FubenconstRewardNum = count
	globaldata.FubenconstRewardList = {}
	for i=1,count do
		local item = {}
		item.itemType = packet:GetInt()
		item.itemId =  packet:GetInt()
		item.itemNum = packet:GetInt()
		globaldata.FubenconstRewardList[i] = item
	end
	GUISystem:hideLoading()
	FightSystem.mFubenManager:BackFubenResult()
end

-- 爬塔结算返回 8509
function globaldata:onFubenPaTaBalance(packet)
	local win = packet:GetChar()
	if win == 0 then
		local count = packet:GetUShort()
		globaldata.FubenconstRewardNum = count
		globaldata.FubenconstRewardList = {}
		for i=1,count do
			local item = {}
			item.itemType = packet:GetInt()
			item.itemId =  packet:GetInt()
			item.itemNum = packet:GetInt()
			globaldata.FubenconstRewardList[i] = item
		end
		GUISystem:hideLoading()
		FightSystem.mFubenManager:BackFubenResult()
	end
end

-- @更新城镇大厅数据,收到主城镇信息，统一走这
function globaldata:updateCityHallData(packet)
	self.cityhalldata.cityid = packet:GetInt()
	self.cityhalldata.posx = packet:GetUShort()
	self.cityhalldata.posy = packet:GetUShort()
	self.cityhalldata.direction = packet:GetChar()
	if self.cityhalldata.cityid <= 0 then
		G_ErrorReport(string.format("globaldata:updateCityHallData,cityid is invalid,cityid: %d", _cityid))
	end 
end

-- 设置城镇大厅数据
function globaldata:setCityHallData(_key, _value)
	self.cityhalldata[_key] = _value
end

-- 获取城镇大厅数据
function globaldata:getCityHallData(_key)
	return self.cityhalldata[_key]
end

-- 看体力是否少于5点
function globaldata:getTiligotoBattle()
	if self:getPlayerBaseData("vatality") < 5 then
		MessageBox:showMessageBox1("挑战体力不足")
		return false
	end
	local chapterList = globaldata:getChapterListByLevel(globaldata.clickedlevel)
	local sectionList = chapterList[globaldata.clickedchapter]:getKeyValue("mSectionList")
	local sectionObj = sectionList[globaldata.clickedsection]
	local leftCount = sectionObj:getKeyValue("mLeftChanllengeCount")
	if leftCount <= 0 then
		MessageBox:showMessageBox1("挑战次数不足")
		return false
	end
	return true
end

-------------------------------------------------func-end------------------------------------------

function globaldata:syncInfoFromServer(msgPacket)
	GUISystem:hideLoading()
	local syncTypeCount = msgPacket:GetUShort()
	for i = 1, syncTypeCount do
		local syncType = msgPacket:GetUShort()
		if 1 == syncType then -- 等级
			self:setPlayerPreBaseData("level", self:getPlayerBaseData("level"))
			self:setPlayerBaseData("level", msgPacket:GetInt())
			GUIEventManager:pushEvent("roleBaseInfoChanged")
			-- 主城红点刷新
			HomeNoticeInnerImpl:doUpdate()
			-- 战队界面
			HeroNoticeInnerImpl:doUpdate()
		elseif 2 == syncType then -- 经验
			self:setPlayerPreBaseData("exp", self:getPlayerBaseData("exp"))
			self:setPlayerBaseData("exp", msgPacket:GetInt())
			GUIEventManager:pushEvent("roleBaseInfoChanged")
			-- 主城红点刷新
			HomeNoticeInnerImpl:doUpdate()
			-- 战队界面
			HeroNoticeInnerImpl:doUpdate()
		elseif 3 == syncType then -- 最大经验
			self:setPlayerPreBaseData("maxExp", self:getPlayerBaseData("maxExp"))
			self:setPlayerBaseData("maxExp", msgPacket:GetInt())
			GUIEventManager:pushEvent("roleBaseInfoChanged")
			-- 主城红点刷新
			HomeNoticeInnerImpl:doUpdate()
			-- 战队界面
			HeroNoticeInnerImpl:doUpdate()
		elseif 4 == syncType then -- 体力值
			self:setPlayerPreBaseData("vatality", self:getPlayerBaseData("vatality"))
			self:setPlayerBaseData("vatality", msgPacket:GetInt())
			GUIEventManager:pushEvent("roleBaseInfoChanged")
			-- 主城红点刷新
			HomeNoticeInnerImpl:doUpdate()
			-- 战队界面
			HeroNoticeInnerImpl:doUpdate()
			-- 傻逼
			Shabi:update()
		elseif 5 == syncType then -- 耐力值
			self:setPlayerPreBaseData("naili", self:getPlayerBaseData("naili"))
			self:setPlayerBaseData("naili", msgPacket:GetInt())
			GUIEventManager:pushEvent("roleBaseInfoChanged")
			-- 主城红点刷新
			HomeNoticeInnerImpl:doUpdate()
			-- 战队界面
			HeroNoticeInnerImpl:doUpdate()
		elseif 6 == syncType then -- 金钱
			self:setPlayerPreBaseData("money", self:getPlayerBaseData("money"))
			self:setPlayerBaseData("money", msgPacket:GetInt())
			GUIEventManager:pushEvent("roleBaseInfoChanged")
			-- 主城红点刷新
			HomeNoticeInnerImpl:doUpdate()
			-- 战队界面
			HeroNoticeInnerImpl:doUpdate()
		elseif 7 == syncType then -- 钻石
			self:setPlayerPreBaseData("diamond", self:getPlayerBaseData("diamond"))
			self:setPlayerBaseData("diamond", msgPacket:GetInt())
			GUIEventManager:pushEvent("roleBaseInfoChanged")
			-- 主城红点刷新
			HomeNoticeInnerImpl:doUpdate()
			-- 战队界面
			HeroNoticeInnerImpl:doUpdate()
		elseif 8 == syncType then -- 背包
			local recvId = msgPacket:GetInt()
			local recvType = msgPacket:GetInt()
			local recvNum = msgPacket:GetInt()
			local itemObj = globaldata:getItemInfo(recvType, recvId)

			if itemObj then
				if 0 == recvNum then
					print("直接删除", recvType, recvId)
					self:removeItem(recvType, recvId)
				else
					print("当前:", itemObj.itemNum, "使用后", recvNum)
					itemObj.itemNum = recvNum
				end
			else
				globaldata:addItem(recvType, recvId, recvNum)
			end
			GUIEventManager:pushEvent("itemInfoChanged", {itemIndex = recvIndex, itemId = recvId, itemType = recvType, itemNum = recvNum})
			-- 主城红点刷新
			HomeNoticeInnerImpl:doUpdate()
			-- 战队界面
			HeroNoticeInnerImpl:doUpdate()
		elseif 9 == syncType then -- VIP相关信息
			-- VIP等级
			self:setPlayerBaseData("vipLevel", msgPacket:GetInt())
			-- 已经冲的钻石数
			self:setPlayerBaseData("diamondAlreadyGet", msgPacket:GetInt())
			-- 下一个VIP等级
			self:setPlayerBaseData("nextVipLevel", msgPacket:GetInt())
			-- 下一等级需要冲的钻石数
			self:setPlayerBaseData("nextVipNeedDiamondCount", msgPacket:GetInt())
			-- 百分比
			self:setPlayerBaseData("vipPercent", msgPacket:GetInt())
			-- 礼包
			local giftCnt = msgPacket:GetUShort()
			for i = 1, giftCnt do
				globaldata.vipGiftList[i] = msgPacket:GetChar()
				print("领取信息:", i, globaldata.vipGiftList[i])
			end

			GUIEventManager:pushEvent("roleBaseInfoChanged")
		elseif 10 == syncType then
			local heroId = msgPacket:GetInt()
			local change = msgPacket:GetChar()
			local newEquip = equipObject:new()
			newEquip.type = msgPacket:GetInt()
			newEquip.level = msgPacket:GetInt()
			newEquip.guid = msgPacket:GetString()
			newEquip.id = msgPacket:GetInt()
			newEquip.quality = msgPacket:GetInt()
			newEquip.qualityAddValue = msgPacket:GetInt()
	--		doError(newEquip.qualityAddValue)
			newEquip.advanceLevel = msgPacket:GetInt()
			newEquip.propCount = msgPacket:GetUShort()
			for m = 1, newEquip.propCount do
				local propType = msgPacket:GetChar()
				local propVal = msgPacket:GetInt()
				newEquip.propList[propType] = propVal
			end
			newEquip.growPropCount = msgPacket:GetUShort()
			for m = 1, newEquip.growPropCount do
				local propType = msgPacket:GetChar()
				local propVal = msgPacket:GetInt()
				newEquip.growPropList[propType] = propVal
			end
			newEquip.diamondList = {0, 0, 0, 0, 0}
			local holeCount = msgPacket:GetUShort()
			for i = 1, holeCount do
				local index = msgPacket:GetChar()
				local id = msgPacket:GetInt()
				newEquip.diamondList[index] = id
			end

			newEquip.strengthGoodCount = msgPacket:GetUShort()
			for i = 1, newEquip.strengthGoodCount do
				newEquip.strengthGoodList[i] = strengthGoodObject:new()
				newEquip.strengthGoodList[i].mType = msgPacket:GetInt()
				newEquip.strengthGoodList[i].mId = msgPacket:GetInt()
				newEquip.strengthGoodList[i].mCount = msgPacket:GetInt()
			end

			print("同步装备信息:", "heroId:", heroId, "change:", change)

			if 1 == change then	-- 穿
				-- 添加到身上
				local heroObj = globaldata:findHeroById(heroId)
				if heroObj then
					local heroEquipList = heroObj.equipList
					if heroEquipList then
						table.insert(heroEquipList, newEquip)
					end
				end
				-- 从背包中移除
				for i = 1, #self.equipList do
					if newEquip.guid == self.equipList[i].guid then
						table.remove(self.equipList, i)
						break
					end
				end
			elseif 0 == change then	-- 脱
				-- 从身上拿掉
				local heroObj = globaldata:findHeroById(heroId)
				if heroObj then
					local heroEquipList = heroObj.equipList
					if heroEquipList then
						for i = 1, #heroEquipList do
							if newEquip.guid == heroEquipList[i].guid then
								table.remove(heroEquipList, i)
								break
							end
						end
					end
				end
				-- 放到背包中
				table.insert(self.equipList, newEquip)
			end
			if heroId == self:getHeroInfoByBattleIndex(1, "id") then
				GUIEventManager:pushEvent("equipChanged", true,change)
			else
				GUIEventManager:pushEvent("equipChanged", false,change)
			end
		elseif 11 == syncType then -- 同步战力
			local heroGuid = msgPacket:GetString()
			local heroObject = globaldata.heroTeam[heroGuid]
			heroObject.index = msgPacket:GetInt()
			heroObject.combat = msgPacket:GetInt()
			-- 取出该英雄的属性信息
			heroObject.propCount = msgPacket:GetUShort()
			heroObject.propList = {}
			for m = 1, heroObject.propCount do
				local propType = msgPacket:GetChar()
				local val = msgPacket:GetInt()
				heroObject.propList[propType] = val
			end
			GUIEventManager:pushEvent("combatChanged")
		elseif 12 == syncType then -- 同步总战力
			local oldCombat = self:getTeamCombat()
			local newCombat = msgPacket:GetInt()
			local deltaValue = newCombat - oldCombat
			self.playerCombat = newCombat
			GUIEventManager:pushEvent("roleBaseInfoChanged")

			if oldCombat ~= newCombat then
				GUISystem:showPlayerCombatChange(oldCombat, newCombat)
			end
		elseif 13 == syncType then -- 同步章节
			local chapterType = msgPacket:GetChar()
			local chapterId = msgPacket:GetInt()
			local sectionId = msgPacket:GetInt()
			local sectionStarCount = msgPacket:GetChar()
			local leftChallengeCount = msgPacket:GetUShort()
			local totalChallengeCount = msgPacket:GetUShort()
			if not self.chapterList[chapterType][chapterId] then
				self.chapterList[chapterType][chapterId] = chapterObject:new()
			end

			self.chapterList[chapterType][chapterId].mChapterId = chapterId

			self.chapterList[chapterType][chapterId].mType = chapterType

			-- 星星奖励
			self.chapterList[chapterType][chapterId].starRewardCount = msgPacket:GetUShort()
			for i = 1, self.chapterList[chapterType][chapterId].starRewardCount do
				local needStarCount = msgPacket:GetInt()
				local canGetReward = msgPacket:GetChar()
				self.chapterList[chapterType][chapterId].mStarReward[i] = {needStarCount, canGetReward}
			end
			local newSection = sectionObject:new()
			newSection.mSectionId = sectionId
			newSection.mLeftChanllengeCount = leftChallengeCount
			newSection.mTotalChallengeCount = totalChallengeCount
			newSection.mCurStarCount = sectionStarCount
			self.chapterList[chapterType][chapterId].mSectionList[sectionId] = newSection
			GUIEventManager:pushEvent("chapterInfoChanged")
		elseif 14 == syncType then -- 同步竞技场剩余挑战次数
			local leftCount = msgPacket:GetChar()
			GUIEventManager:pushEvent("arenaChallCountChanged", leftCount)
		elseif 15 == syncType then -- 同步神秘币
			self:setPlayerPreBaseData("shenmi", self:getPlayerBaseData("shenmi"))
			self:setPlayerBaseData("shenmi", msgPacket:GetInt())
			GUIEventManager:pushEvent("roleBaseInfoChanged")
		elseif 16 == syncType then -- 同步最大经验
			self:setPlayerPreBaseData("maxVatality", self:getPlayerBaseData("maxVatality"))
			self:setPlayerBaseData("maxVatality", msgPacket:GetInt())
			GUIEventManager:pushEvent("roleBaseInfoChanged")
		elseif 17 == syncType then -- 家具同步
			local newFurnit = furnitObject:new()
			newFurnit.mGuid = msgPacket:GetString()
			newFurnit.mId = msgPacket:GetInt()
			table.insert(self.furnitListOutHouse, newFurnit)
		elseif 18 == syncType then  --任务同步
			local taskInfo = {}
		    taskInfo.mTaskType     		    = msgPacket:GetChar()
			taskInfo.mTaskId	            = msgPacket:GetInt()
			taskInfo.mTaskNameStr	        = msgPacket:GetString()
			taskInfo.mTaskDescStr			= msgPacket:GetString()
			taskInfo.mTaskProStr			= msgPacket:GetString()
	        taskInfo.mTaskIsFinish			= msgPacket:GetChar()--0 未完成 1 已完成
	        taskInfo.mTaskDiffculty			= msgPacket:GetChar()

			taskInfo.mTaskJumpType			= msgPacket:GetChar()
			taskInfo.mTaskJumpPara          = {}

			local jumpParaCnt				= msgPacket:GetChar()
			for i=1,jumpParaCnt do
				local para 					= msgPacket:GetChar()
				table.insert(taskInfo.mTaskJumpPara,para)
			end

			taskInfo.mRewardArr				= {}
			local rewardNum 				= msgPacket:GetUShort()
			for k = 1,rewardNum do
				local rewardInfo            = {}
				rewardInfo.mRewardType      = msgPacket:GetInt()
				rewardInfo.mItemId          = msgPacket:GetInt()
				rewardInfo.mItemCnt         = msgPacket:GetInt()
				table.insert(taskInfo.mRewardArr,rewardInfo)
			end

			if taskInfo.mTaskType == TASKTYPE.ACHIEVE or taskInfo.mTaskType == TASKTYPE.USUAL then
				self.syncTaskInfo = taskInfo
	    		GUIEventManager:pushEvent("taskSyncHappen")
	    	elseif taskInfo.mTaskType == TASKTYPE.MAINLINE then
	    		FightSystem.mTaskMainManager.mMainTaskInfo = taskInfo
	    		if GUISystem.Windows["HomeWindow"].mRootNode then
	    			GUISystem.Windows["HomeWindow"]:upDateTaskMain()
	    		end
			end

		elseif 19 == syncType then -- 关卡同步
			local level = msgPacket:GetChar()
			local chapterId = msgPacket:GetInt()
			local sectionId = msgPacket:GetInt()
			self.curChapterId[level] = chapterId
			self.curSectionId[level] = sectionId
		elseif 20 == syncType then -- 从背包删除装备
			local guid = msgPacket:GetString()
			-- 从背包中移除
			for i = 1, #self.equipList do
				if guid == self.equipList[i].guid then
					table.remove(self.equipList, i)
					break
				end
			end
			GUIEventManager:pushEvent("itemInfoChanged")
		elseif 21 == syncType then -- 添加英雄
			local heroId , starCnt = self:addHeroFromLottery(msgPacket)
			-- 指引部分
			local function guideFunc()
				local function doHomeGuideTwo_Step5()
					local window = GUISystem:GetWindowByName("HeroInfoWindow")
					if window.mRootWidget then
						local guideBtn = window.mRootWidget:getChildByName("Image_DangAn")
						local size = guideBtn:getContentSize()
						local pos = guideBtn:getWorldPosition()
						pos.x = pos.x - size.width/2
						pos.y = pos.y - size.height/2
						local touchRect = cc.rect(pos.x, pos.y, size.width, size.height)
						HeroGuideTwo:step(5, touchRect)
					end
				end
				HeroGuideTwo:step(4, nil, doHomeGuideTwo_Step5)
			end
			CommonAnimation.PlayEffectId(5009)
			createNewHeroPanelByID(heroId, GUISystem:GetRootNode(), guideFunc)
			GUIEventManager:pushEvent("heroAddSync")
		elseif 22 == syncType then
			local noticeType = msgPacket:GetUShort()
			local noticeState = msgPacket:GetChar()
			NoticeSystem:resetPair(noticeType, noticeState)
		-- 	print("noticeType:", noticeType, "noticeState:", noticeState)
		--	if 7001 == noticeType or 14001 == noticeType then
		--		doError(string.format("%d, %d", noticeType, noticeState))
		--	end
		elseif 23 == syncType then -- 英雄信息同步
			local guid = msgPacket:GetString()
			local index = msgPacket:GetInt()
			local heroId = msgPacket:GetInt()
			local heroObj = self:findHeroById(heroId)
			if not heroObj then
				return
			end
			heroObj.name = msgPacket:GetString()
			heroObj.level = msgPacket:GetInt()
			heroObj.exp = msgPacket:GetInt()
			heroObj.maxExp = msgPacket:GetInt()
			heroObj.advanceLevel = msgPacket:GetInt()
			heroObj.quality = msgPacket:GetInt()
			heroObj.combat = msgPacket:GetInt()
			heroObj.chipId = msgPacket:GetInt()
			heroObj.chipCount = msgPacket:GetInt()

			-- 取出该英雄的属性信息
			heroObj.propList = {}
			heroObj.propListEx = {}
			heroObj.propCount = msgPacket:GetUShort()
			for m = 1, heroObj.propCount do
				local propType = msgPacket:GetChar()
				local val = msgPacket:GetInt()
				heroObj.propList[propType] = val
				heroObj.propListEx[propType] = msgPacket:GetInt()
			end
			GUIEventManager:pushEvent("heroInfoSync")
		elseif 24 == syncType then -- 英雄技能同步
			local heroId = msgPacket:GetInt()
			local isNew = msgPacket:GetChar() -- 1:新的 0:旧的
			local skillId = msgPacket:GetInt()
			local skillType = msgPacket:GetChar()
			local skillIndex = msgPacket:GetChar()
			local skillSelected = msgPacket:GetChar()
			local skillLevel = msgPacket:GetInt()
			local skillCost = msgPacket:GetInt()

			local heroObj = self:findHeroById(heroId)
			if 1 == isNew then  -- 新技能get，但需要检查list里是否已有该技能
				local hasExistId = -1
		        for i =1,#heroObj.skillList do
		        	if heroObj.skillList[i].mSkillType == skillType and heroObj.skillList[i].mSkillId == skillId then
		        	   hasExistId = i
		        	break end
		        end
		        if hasExistId ~= -1 then
					heroObj.skillList[hasExistId].mSkillId = skillId
					heroObj.skillList[hasExistId].mSkillType = skillType
					heroObj.skillList[hasExistId].mSkillIndex = skillIndex
					heroObj.skillList[hasExistId].mSkillSelected = skillSelected
					heroObj.skillList[hasExistId].mSkillLevel = skillLevel
					heroObj.skillList[hasExistId].mPrice = skillCost
				else
					local newSkillObj = skillObject.new()
					newSkillObj.mSkillId = skillId
					newSkillObj.mSkillType = skillType
					newSkillObj.mSkillIndex = skillIndex
					newSkillObj.mSkillSelected = skillSelected
					newSkillObj.mSkillLevel = skillLevel
					newSkillObj.mPrice = skillCost
					table.insert(heroObj.skillList, newSkillObj)
				end
				heroObj.skillCount = #heroObj.skillList
				MessageBox:showMessageBox1("有新的技能开启了哦~快去看看吧~")
				print("服务器发来技能信息(开启):")
				print("skillId:", skillId, "skillType", skillType, "skillIndex", skillIndex, "skillLevel", skillLevel, "skillSelected", skillSelected)
			elseif 0 == isNew then
				for i = 1, #heroObj.skillList do
					if skillId == heroObj.skillList[i].mSkillId and skillType == heroObj.skillList[i].mSkillType then
						heroObj.skillList[i].mSkillIndex = skillIndex

						-- 技能选择
						local boolVal2 = true
						if skillSelected == heroObj.skillList[i].mSkillSelected then
							boolVal2 = false
						end 
						heroObj.skillList[i].mSkillSelected = skillSelected

						-- 技能升级
						local boolVal = true
						if skillLevel == heroObj.skillList[i].mSkillLevel then
							boolVal = false
						end
						heroObj.skillList[i].mSkillLevel = skillLevel

						heroObj.skillList[i].mPrice = skillCost
						GUIEventManager:pushEvent("autoSkillUpdate", i, boolVal, boolVal2)
						print("服务器发来技能信息(升级):")
						print("skillId:", skillId, "skillType", skillType, "skillIndex", skillIndex, "skillLevel", skillLevel, "skillSelected", skillSelected)
					end
				end
			end
		elseif 25 == syncType then
			self:setPlayerBaseData("partyMoney", msgPacket:GetInt())
			GUIEventManager:pushEvent("roleBaseInfoChanged")
		elseif 26 == syncType then
			self:setPlayerBaseData("tiantiMoney", msgPacket:GetInt())
			GUIEventManager:pushEvent("roleBaseInfoChanged")
		elseif 27 == syncType then
			local cnt = msgPacket:GetUShort()

			for i=1,cnt do
				self.mealStateArr[i] = msgPacket:GetChar()
			end

			if GUISystem.Windows["DailyRewardWindow"].mRootNode ~= nil then
				GUISystem.Windows["DailyRewardWindow"]:UpdateMealPanel()
			end
		elseif 28 == syncType then
			self.partyId = msgPacket:GetString()
			self.partyName = msgPacket:GetString()
			self.partyIconId = msgPacket:GetInt()

			if self.partyId == "" then
				if HallManager:isInUnionHall() then
					UnionSubManager:leaveUnionHall()
				end
			else
				if GUISystem:IsWindowShowed("PartyJoinWindow") then
					UnionSubManager:enterUnionHall()
				end
			end
		elseif 29 == syncType then
			self:setPlayerBaseData("towerMoney", msgPacket:GetInt())
			GUIEventManager:pushEvent("roleBaseInfoChanged")
		elseif 30 == syncType then
			globaldata.curLvRewardInfo.idx        = msgPacket:GetInt()
	    	globaldata.curLvRewardInfo.state      = msgPacket:GetInt()
	   	 	cclog(string.format("globaldata.curLvRewardInfo.idx = %d,globaldata.curLvRewardInfo.state = %d",
	   	 		globaldata.curLvRewardInfo.idx,globaldata.curLvRewardInfo.state))
	   	 	if GUISystem.Windows["HomeWindow"].mRootNode then
				GUISystem.Windows["HomeWindow"]:UpdateLevelReward(globaldata.curLvRewardInfo)
			end
		end
	end
end

function globaldata:syncBattleFromServer(msgPacket)
	local syncCount = msgPacket:GetUShort()
	local leaderChanged = false

	for i = 1, syncCount do
		local newGuid = msgPacket:GetString()
		local newIndex = msgPacket:GetInt()
		local newCombat = msgPacket:GetInt()
		-- 新的英雄上阵
		if not globaldata.battleTeam[newIndex] then
			-- 非调换，直接上阵的情况
			globaldata.battleTeam[newIndex] = posObject:new()
		end
		globaldata.battleTeam[newIndex].guid = newGuid
		local newId = globaldata:getHeroInfoByBattleIndex(newIndex, "id")
		local newHero = globaldata:findHeroById(newId)
		newHero.combat = newCombat
		newHero.index = newIndex
		-- 取出该英雄百分比属性信息
		newHero.growPropCount = msgPacket:GetUShort()
		for m = 1, newHero.growPropCount do
			local propType = msgPacket:GetChar()
			local val = msgPacket:GetInt()
			newHero.growPropList[propType] = val
		end

		-- 取出该英雄属性信息
		newHero.propCount = msgPacket:GetUShort()
		for m = 1, newHero.propCount do
			local propType = msgPacket:GetChar()
			local val = msgPacket:GetInt()
			newHero.propList[propType] = val
		end

		if 1 == newIndex then
			leaderChanged = true
		end

	end

	local outHeroId = msgPacket:GetInt()
	if 0 ~= outHeroId then
		local outHeroObj = globaldata:findHeroById(outHeroId)
		outHeroObj.index = 0
	end
	GUISystem:hideLoading()
	
	GUIEventManager:pushEvent("combatChanged")
	GUIEventManager:pushEvent("battleTeamChanged", leaderChanged, newIndex)
end

-- 成功回调
globaldata.onEquipStrengthenSucessHandler = nil

function globaldata:onEquipDoStrengthen(msgPacket)
	-- 旧的属性
	local oldPropTbl = {}
	-- 新的属性
	local newPropTbl = {}

	local newEquip = equipObject:new()
	newEquip.type = msgPacket:GetInt()
	newEquip.level = msgPacket:GetInt()
	newEquip.guid = msgPacket:GetString()
	newEquip.id = msgPacket:GetInt()
	newEquip.quality = msgPacket:GetInt()
	newEquip.qualityAddValue = msgPacket:GetInt()
	newEquip.advanceLevel = msgPacket:GetInt()
	local equipObj = self:getEquipByGuid(newEquip.guid)
	equipObj.diamondList = {0, 0, 0, 0, 0}
	local diamondCount = msgPacket:GetUShort()
	for i = 1, diamondCount do
		local index = msgPacket:GetChar()
		local value = msgPacket:GetInt()
		equipObj.diamondList[index] = value
	end
	equipObj.propCount = msgPacket:GetUShort()
	-- 备份旧的属性
	for k, v in pairs(equipObj.propList) do
		oldPropTbl[k] = v
	end
	equipObj.propList = {}
	print("强化后的基础属性数量:", equipObj.propCount)
	for m = 1, equipObj.propCount do
		local propType = msgPacket:GetChar()
		local propVal = msgPacket:GetInt()
		print("强化后的属性类型:", propType, "强化后的属性值:", propVal)
		equipObj.propList[propType] = propVal
	end
	-- 备份新的属性
	for k, v in pairs(equipObj.propList) do
		newPropTbl[k] = v
	end
	equipObj.growPropCount = msgPacket:GetUShort()
	equipObj.growPropList = {}
	print("强化后的成长属性数量:", equipObj.propCount)
	for m = 1, equipObj.growPropCount do
		local propType = msgPacket:GetChar()
		local propVal = msgPacket:GetInt()
		print("强化后的属性类型:", propType, "强化后的属性值:", propVal)
		equipObj.growPropList[propType] = propVal
	end

	equipObj.type = newEquip.type
	equipObj.level = newEquip.level
	equipObj.guid = newEquip.guid
	equipObj.id = newEquip.id
	equipObj.quality = newEquip.quality
	equipObj.qualityAddValue = newEquip.qualityAddValue
	equipObj.advanceLevel = newEquip.advanceLevel
	equipObj.strengthGoodCount = msgPacket:GetUShort()
	equipObj.strengthGoodList = {}
	for i = 1, equipObj.strengthGoodCount do
		equipObj.strengthGoodList[i] = strengthGoodObject:new()
		equipObj.strengthGoodList[i].mType = msgPacket:GetInt()
		equipObj.strengthGoodList[i].mId = msgPacket:GetInt()
		equipObj.strengthGoodList[i].mCount = msgPacket:GetInt()
		print("type:", equipObj.strengthGoodList[i].mType)
		print("id:", equipObj.strengthGoodList[i].mId)
		print("count:", equipObj.strengthGoodList[i].mCount)
	end
	for k, v in pairs(newPropTbl) do
		oldPropTbl[k] = v - oldPropTbl[k]
	end
	if globaldata.onEquipStrengthenSucessHandler then
		globaldata.onEquipStrengthenSucessHandler(equipObj, oldPropTbl)
	end

end

function globaldata:updateWorkInfoFromServer(msgPacket)
	local typeCount = msgPacket:GetUShort()
	for j = 1, typeCount do
		local workType = msgPacket:GetChar()
		for i = 1, #globaldata.workers[workType] do
			globaldata.workers[workType][i]:destroy()
		end
		globaldata.workers[workType] = {}

		local count = msgPacket:GetUShort()
		for i = 1, count do
			local newWorker = workerObject:new()
			newWorker.mWorkType = workType
			newWorker.mWorkHeroGuid = msgPacket:GetString()
			newWorker.mWorkHeroId = msgPacket:GetInt()
			newWorker.mLeftTime = msgPacket:GetInt()
			newWorker.mItemType = msgPacket:GetInt()
			newWorker.mItemId = msgPacket:GetInt()
			newWorker.mItemCount = msgPacket:GetInt()
			newWorker.mTotleCount = msgPacket:GetInt()
			globaldata.workers[workType][i] = newWorker
			-- 开启定时器
			newWorker:init()
		end
	end
end

-- 添加一个打工者
function globaldata:addWorkerFromServer(workType, msgPacket)
	local newWorker = workerObject:new()
	newWorker.mWorkType = workType
	newWorker.mWorkHeroGuid = msgPacket:GetString()
	newWorker.mWorkHeroId = msgPacket:GetInt()
	newWorker.mLeftTime = msgPacket:GetInt()
	newWorker.mItemType = msgPacket:GetInt()
	newWorker.mItemId = msgPacket:GetInt()
	newWorker.mItemCount = msgPacket:GetInt()

	self.workers[workType][#self.workers[workType] + 1] = newWorker
	-- 开启定时器
	newWorker:init()
	-- 通知
	--GUISystem.Windows["WorkPositionWindow"]:addWorker(newWorker)
	GUIEventManager:pushEvent("updateWorkerInfo")
end

-- 删除一个打工者
function globaldata:removeWorker(id)
	for i = 1, 3 do
		for j = 1, #self.workers[i] do
			if id == self.workers[i][j].mWorkHeroId then	-- 删除操作
				self.workers[i][j]:destroy()
				table.remove(self.workers[i], j)
				GUIEventManager:pushEvent("updateWorkerInfo")
				return
			end
		end
	end
end

function globaldata:cleanWidget()
	for i = 1, 3 do
		for j = 1, #self.workers[i] do
			self.workers[i][j]:cleanWidget()
		end
	end
end

function globaldata:cleanWorkers()
	for i = 1, 3 do
		for j = 1, #self.workers[i] do
			self.workers[i][j]:destroy()
		end
	end
end

-- 判断某个英雄是否在打工
function globaldata:isHeroWorking(id)
	for i = 1, 3 do
		for j = 1, #self.workers[i] do
			if id == self.workers[i][j].mWorkHeroId then
				return true
			end
		end
	end
	return false
end

function globaldata:getTypeString(index)
	if 0 == index then
		return "生命"
	elseif 1 == index then
		return "格斗"
	elseif 2 == index then
		return "破甲"
	elseif 3 == index then
		return "护甲"
	elseif 4 == index then
		return "功夫"
	elseif 5 == index then
		return "柔术"
	elseif 6 == index then
		return "暴击"
	elseif 7 == index then
		return "韧性"
	elseif 8 == index then
		return "攻速"
	else
		return "错误类型"
	end
end

function globaldata:getTypeMax(index)
	if 0 == index then
		return 300
	else
		return 40
	end
end

function globaldata:finishGradualEffect()
	self:setPlayerPreBaseData("playerId", self:getPlayerBaseData("playerId"))
	self:setPlayerPreBaseData("name", self:getPlayerBaseData("name"))
	self:setPlayerPreBaseData("level", self:getPlayerBaseData("level"))
	self:setPlayerPreBaseData("exp", self:getPlayerBaseData("exp"))
	self:setPlayerPreBaseData("maxExp", self:getPlayerBaseData("maxExp"))
	self:setPlayerPreBaseData("vatality", self:getPlayerBaseData("vatality"))
	self:setPlayerPreBaseData("maxVatality", self:getPlayerBaseData("maxVatality"))
	self:setPlayerPreBaseData("naili", self:getPlayerBaseData("naili"))
	self:setPlayerPreBaseData("shenmi", self:getPlayerBaseData("shenmi"))
	self:setPlayerPreBaseData("money", self:getPlayerBaseData("money"))
	self:setPlayerPreBaseData("diamond", self:getPlayerBaseData("diamond"))
	self:setPlayerPreBaseData("vipLevel", self:getPlayerBaseData("vipLevel"))
end

-- 一键镶嵌回包
function globaldata:onEquipOneKeyXiangqian(msgPacket)
	-- 旧的属性列表
	local oldPropTbl = {}
	-- 新的属性列表
	local newPropTbl = {}

	local newEquip = equipObject:new()
	newEquip.type = msgPacket:GetInt()
	newEquip.level = msgPacket:GetInt()
	newEquip.guid = msgPacket:GetString()
	newEquip.id = msgPacket:GetInt()
	newEquip.quality = msgPacket:GetInt()
	newEquip.qualityAddValue = msgPacket:GetInt()
	newEquip.advanceLevel = msgPacket:GetInt()
	
	local equipObj = self:getEquipByGuid(newEquip.guid)
	equipObj.diamondList = {0, 0, 0, 0, 0}
	local diamondCount = msgPacket:GetUShort()
	print("宝石数量:", diamondCount)
	for i = 1, diamondCount do
		local index = msgPacket:GetChar()
		local value = msgPacket:GetInt()
		equipObj.diamondList[index] = value
		print("位置:", index, "宝石:", value)
	end

	equipObj.propCount = msgPacket:GetUShort()
	-- 备份旧的属性列表
	for k, v in pairs(equipObj.propList) do
		oldPropTbl[k] = v
	end
	equipObj.propList = {}
	for m = 1, equipObj.propCount do
		local propType = msgPacket:GetChar()
		local propVal = msgPacket:GetInt()
		equipObj.propList[propType] = propVal
	end
	-- 备份新的属性列表
	for k, v in pairs(equipObj.propList) do
		newPropTbl[k] = v
	end
	equipObj.growPropCount = msgPacket:GetUShort()
	-- 备份旧的成长属性列表
	for k, v in pairs(equipObj.growPropList) do
		oldPropTbl[k] = v
	end
	equipObj.growPropList = {}
	for m = 1, equipObj.growPropCount do
		local propType = msgPacket:GetChar()
		local propVal = msgPacket:GetInt()
		equipObj.growPropList[propType] = propVal
	end
	-- 备份新的成长属性列表
	for k, v in pairs(equipObj.growPropList) do
		newPropTbl[k] = v
	end
	equipObj.type = newEquip.type
	equipObj.level = newEquip.level
	equipObj.guid = newEquip.guid
	equipObj.id = newEquip.id
	equipObj.quality = newEquip.quality
	equipObj.qualityAddValue = newEquip.qualityAddValue
	equipObj.advanceLevel = newEquip.advanceLevel
	equipObj.strengthGoodCount = msgPacket:GetUShort()
	equipObj.strengthGoodList = {}
	for i = 1, equipObj.strengthGoodCount do
		equipObj.strengthGoodList[i] = strengthGoodObject:new()
		equipObj.strengthGoodList[i].mType = msgPacket:GetInt()
		equipObj.strengthGoodList[i].mId = msgPacket:GetInt()
		equipObj.strengthGoodList[i].mCount = msgPacket:GetInt()
	end
	for k, v in pairs(newPropTbl) do
		if oldPropTbl[k] then
			oldPropTbl[k] = v - oldPropTbl[k]
		else
			oldPropTbl[k] = v
		end
	end
	GUISystem:hideLoading()
	GUIEventManager:pushEvent("diamondXiangqianSuccess", equipObj, oldPropTbl)
end

-- 镶嵌宝石回包
function globaldata:onEquipDoDiamondXiangqian(msgPacket)
	-- 旧的属性列表
	local oldPropTbl = {}
	-- 新的属性列表
	local newPropTbl = {}

	local newEquip = equipObject:new()
	newEquip.type = msgPacket:GetInt()
	newEquip.level = msgPacket:GetInt()
	newEquip.guid = msgPacket:GetString()
	newEquip.id = msgPacket:GetInt()
	newEquip.quality = msgPacket:GetInt()
	newEquip.qualityAddValue = msgPacket:GetInt()
	newEquip.advanceLevel = msgPacket:GetInt()
	
	local equipObj = self:getEquipByGuid(newEquip.guid)
	equipObj.diamondList = {0, 0, 0, 0, 0}
	local diamondCount = msgPacket:GetUShort()
	print("宝石数量:", diamondCount)
	for i = 1, diamondCount do
		local index = msgPacket:GetChar()
		local value = msgPacket:GetInt()
		equipObj.diamondList[index] = value
		print("位置:", index, "宝石:", value)
	end

	equipObj.propCount = msgPacket:GetUShort()
	-- 备份旧的属性列表
	for k, v in pairs(equipObj.propList) do
		oldPropTbl[k] = v
	end
	equipObj.propList = {}
	for m = 1, equipObj.propCount do
		local propType = msgPacket:GetChar()
		local propVal = msgPacket:GetInt()
		equipObj.propList[propType] = propVal
	end
	-- 备份新的属性列表
	for k, v in pairs(equipObj.propList) do
		newPropTbl[k] = v
	end
	equipObj.growPropCount = msgPacket:GetUShort()
	-- 备份旧的成长属性列表
	for k, v in pairs(equipObj.growPropList) do
		oldPropTbl[k] = v
	end
	equipObj.growPropList = {}
	for m = 1, equipObj.growPropCount do
		local propType = msgPacket:GetChar()
		local propVal = msgPacket:GetInt()
		equipObj.growPropList[propType] = propVal
	end
	-- 备份新的成长属性列表
	for k, v in pairs(equipObj.growPropList) do
		newPropTbl[k] = v
	end
	equipObj.type = newEquip.type
	equipObj.level = newEquip.level
	equipObj.guid = newEquip.guid
	equipObj.id = newEquip.id
	equipObj.quality = newEquip.quality
	equipObj.qualityAddValue = newEquip.qualityAddValue
	equipObj.advanceLevel = newEquip.advanceLevel
	equipObj.strengthGoodCount = msgPacket:GetUShort()
	equipObj.strengthGoodList = {}
	print("材料数量", equipObj.strengthGoodCount)
	for i = 1, equipObj.strengthGoodCount do
		equipObj.strengthGoodList[i] = strengthGoodObject:new()
		equipObj.strengthGoodList[i].mType = msgPacket:GetInt()
		equipObj.strengthGoodList[i].mId = msgPacket:GetInt()
		equipObj.strengthGoodList[i].mCount = msgPacket:GetInt()
		print("材料顺序:", i, "材料类型:", equipObj.strengthGoodList[i].mType, "材料ID:", equipObj.strengthGoodList[i].mId, "材料数量:", equipObj.strengthGoodList[i].mCount)
	end
	for k, v in pairs(newPropTbl) do
		if oldPropTbl[k] then
			oldPropTbl[k] = v - oldPropTbl[k]
		else
			oldPropTbl[k] = v
		end
	end
	GUISystem:hideLoading()
	GUIEventManager:pushEvent("diamondXiangqianSuccess", equipObj, oldPropTbl)
end

-- 脱掉宝石回包
function globaldata:onEquipDoDiamondPutoff(msgPacket)
	GUISystem:hideLoading()
	-- 旧的属性列表
	local oldPropTbl = {}
	-- 新的属性列表
	local newPropTbl = {}

	local newEquip = equipObject:new()
	newEquip.type = msgPacket:GetInt()
	newEquip.level = msgPacket:GetInt()
	newEquip.guid = msgPacket:GetString()
	newEquip.id = msgPacket:GetInt()
	newEquip.quality = msgPacket:GetInt()
	newEquip.qualityAddValue = msgPacket:GetInt()
	newEquip.advanceLevel = msgPacket:GetInt()
	
	local equipObj = self:getEquipByGuid(newEquip.guid)
	equipObj.diamondList = {0, 0, 0, 0, 0}
	local diamondCount = msgPacket:GetUShort()
	print("宝石数量:", diamondCount)
	for i = 1, diamondCount do
		local index = msgPacket:GetChar()
		local value = msgPacket:GetInt()
		equipObj.diamondList[index] = value
		print("位置:", index, "宝石:", value)
	end

	equipObj.propCount = msgPacket:GetUShort()

	-- 备份旧的属性列表
	for k, v in pairs(equipObj.propList) do
		oldPropTbl[k] = v
	end

	equipObj.propList = {}
	for m = 1, equipObj.propCount do
		local propType = msgPacket:GetChar()
		local propVal = msgPacket:GetInt()
		equipObj.propList[propType] = propVal
	end

	-- 备份新的属性列表
	for k, v in pairs(equipObj.propList) do
		newPropTbl[k] = v
	end

	equipObj.growPropCount = msgPacket:GetUShort()
	-- 备份旧的成长属性列表
	for k, v in pairs(equipObj.growPropList) do
		oldPropTbl[k] = v
	end
	equipObj.growPropList = {}
	for m = 1, equipObj.growPropCount do
		local propType = msgPacket:GetChar()
		local propVal = msgPacket:GetInt()
		equipObj.growPropList[propType] = propVal
	end
	-- 备份新的成长属性列表
	for k, v in pairs(equipObj.growPropList) do
		newPropTbl[k] = v
	end

	equipObj.type = newEquip.type
	equipObj.level = newEquip.level
	equipObj.guid = newEquip.guid
	equipObj.id = newEquip.id
	equipObj.quality = newEquip.quality
	equipObj.qualityAddValue = newEquip.qualityAddValue
	equipObj.advanceLevel = newEquip.advanceLevel
	equipObj.strengthGoodCount = msgPacket:GetUShort()
	equipObj.strengthGoodList = {}
	for i = 1, equipObj.strengthGoodCount do
		equipObj.strengthGoodList[i] = strengthGoodObject:new()
		equipObj.strengthGoodList[i].mType = msgPacket:GetInt()
		equipObj.strengthGoodList[i].mId = msgPacket:GetInt()
		equipObj.strengthGoodList[i].mCount = msgPacket:GetInt()
	end
	for k, v in pairs(newPropTbl) do
		if oldPropTbl[k] then
			oldPropTbl[k] = v - oldPropTbl[k]
		else
			oldPropTbl[k] = v
		end
	end
	GUIEventManager:pushEvent("diamondPutoffSuccess", equipObj, oldPropTbl)
end

-- 更新英雄好感度信息
function globaldata:updateHeroFavorInfoFromServerPacket(msgPacket)
	globaldata.heroBook = {}
	local count = msgPacket:GetUShort()
	for i = 1, count do
		local heroObj = favorHero:new()
		heroObj.heroId = msgPacket:GetInt()
		heroObj.favorLevel = msgPacket:GetInt()
		heroObj.favorValue = msgPacket:GetInt()
		heroObj.favorMaxValue = msgPacket:GetInt()
		globaldata.heroBook[heroObj.heroId] = heroObj
	end
end

-- 判断图鉴是否有某一个英雄
function globaldata:isHeroInBook(heroId)
	if self.heroBook[heroId] then
		return self.heroBook[heroId]
	else
		return nil
	end
end

-- 玩家升级
function globaldata:onPlayerLevelup(msgPacket)
	self.levelupbackwindow = nil

	self.levelold = msgPacket:GetInt()
	self.level = msgPacket:GetInt()
	self.maxUpdateVityold = msgPacket:GetInt()
	self.maxUpdateVity = msgPacket:GetInt()
	self.maxEquipold = msgPacket:GetInt()
	self.maxEquip = msgPacket:GetInt()

	if self.wait then
		self.showlevelup = true
		return
	end
	self:Showplayerlevelup()
end

-- 显示玩家升级
function globaldata:Showplayerlevelup()
	-- if "null" ~= self.func then
	-- 	GUISystem:setFuncOpen(tostring(self.func), true)
	-- end
	-- GUIEventManager:pushEvent("playerLevelupForwindow", self.level,self.func)

	GUISystem:onPlayerLevelup(self.levelold,self.level,self.maxUpdateVityold,self.maxUpdateVity,self.maxEquipold,self.maxEquip)
end

-- 通过index获得spine信息
function globaldata:getMyFightTeamSpineData(_posIndex)
 	local _heroID = globaldata:getBattleFormationInfoByIndexAndKey(_posIndex, "id")
    local _skillList = globaldata:getBattleFormationInfoByIndexAndKey(_posIndex, "skillList")
    local _prop = globaldata:getBattleFormationInfoByIndexAndKey(_posIndex, "propList")
	local _infoDB = DB_HeroConfig.getDataById(_heroID)
	local _resDB = DB_ResourceList.getDataById(_infoDB.ResouceID)
	local _skillListNew = self:getSkillIdByskillList(_skillList)
	return _resDB.Res_path2, _resDB.Res_path1, _infoDB.ResouceZoom, _infoDB.SoundList, _skillListNew
end

-- 通过index获得spine敌方信息
function globaldata:getEnemyFightTeamSpineData(_posIndex)
 	local _heroID = globaldata:getBattleEnemyFormationInfoByIndexAndKey(_posIndex, "id")
 	local _skillList = globaldata:getBattleEnemyFormationInfoByIndexAndKey(_posIndex, "skillList")
	local _infoDB = DB_HeroConfig.getDataById(_heroID)
	local _resDB = DB_ResourceList.getDataById(_infoDB.ResouceID)
	local _skillListNew = self:getSkillIdByskillList(_skillList)
	return _resDB.Res_path2, _resDB.Res_path1, _infoDB.ResouceZoom, _infoDB.SoundList, _skillListNew
end

function globaldata:getSkillIdByskillList(_skillList)
 	local skillListNew = {}
	for i=1,4 do
		if _skillList["Role_Change_NormalSkill" .. i] then
			table.insert(skillListNew,_skillList["Role_Change_NormalSkill" .. i])
		end
	end
	for i=1,4 do
		if _skillList["Role_Change_SpecialSkill" .. i] then
			table.insert(skillListNew,_skillList["Role_Change_SpecialSkill" .. i])
		end
	end
	return skillListNew
end

-- 通过heroindex获得spine信息
function globaldata:getSimpleSpineDataByHeroIdx(_heroIdx)
	local _db = DB_HeroConfig.getDataById(_heroIdx)
	local _resDB = DB_ResourceList.getDataById(_db.SimpleResouceID)

	return _resDB.Res_path2, _resDB.Res_path1, _db.SimpleResouceZoom
end

globaldata.mLastGetRewardChapterId = nil 	-- 最后一次领取的章节Id
globaldata.mLastGetRewardIndex = nil 		-- 最后一次领取的序号

function globaldata:onRequestRewardInfo(msgPacket)
	local level = msgPacket:GetChar()
	local canGet = msgPacket:GetChar() -- 能否领取
	local rewardId = msgPacket:GetInt() -- 奖励Id
	local rewardIndex = msgPacket:GetChar() -- 奖励Id
	local rewardCount = msgPacket:GetUShort() -- 奖励物品数量
	local itemList = {}
	for i = 1, rewardCount do
		local itemType = msgPacket:GetInt()
		local itemId = msgPacket:GetInt()
		local itemCount = msgPacket:GetInt()
		itemList[i] = {itemType, itemId, itemCount}
	end

	if 0 == canGet or 2 == canGet then -- 不可以
		MessageBox:showMessageBox6(itemList)
	elseif 1 ==  canGet then -- 可以
		MessageBox:showMessageBox5(rewardId, rewardIndex, itemList, level)
	end
	GUISystem:hideLoading()
end

function globaldata:onRequestRewardGet(msgPacket)
	local sucess = msgPacket:GetChar()
	if 0 == sucess then
		local chapterLevel = msgPacket:GetChar()
		local chapterId = msgPacket:GetInt()
		local rewardIndex = msgPacket:GetChar()

		local chapterList = globaldata:getChapterListByLevel(chapterLevel)
		local chapterObj = chapterList[chapterId]
		local starRewardInfo = chapterObj:getKeyValue("mStarReward")
		starRewardInfo[rewardIndex][2] = 2 -- 已经领取
		GUIEventManager:pushEvent("starRewardGot")
	end	
	GUISystem:hideLoading()
end

-- 上传当前Pk返回 2903
function globaldata:onPkBackInfo(msgPacket)
	--FightSystem:PushNotification("hall_anytouch")
	self.PvpType = "pk"
	self.pvpmapType = msgPacket:GetChar()
	self.pvpmapId =  msgPacket:GetInt()
	self.pvpmapNameId =  msgPacket:GetInt()
	self.pvpmaxTime =  msgPacket:GetInt()
	self.pvpfriendTeamCount  = msgPacket:GetUShort()
	self.pvpFriendPosList = {}
	for i=1,self.pvpfriendTeamCount do
		local x = msgPacket:GetUShort()/100
		local y = msgPacket:GetUShort()/100
		local pos = cc.p(x,y)
		table.insert(self.pvpFriendPosList,pos)
	end
	self.pvpEnemyTeamCount  = msgPacket:GetUShort()
	self.pvpEnemyPosList = {}
	for i=1,self.pvpEnemyTeamCount do
		local x = msgPacket:GetUShort()/100
		local y = msgPacket:GetUShort()/100
		local pos = cc.p(x,y)
		table.insert(self.pvpEnemyPosList,pos)
	end
	self.pvpmucicId = msgPacket:GetUShort()

	self:updateBattleFormation(msgPacket,true)
	self:updateEnemyInfoFormation(msgPacket)
	
	---------
	GUISystem:hideLoading()
	if globaldata.fightagain then
		globaldata.fightagain = false
		FightSystem:reloadFightWindow()
	else
		GUISystem:HideAllWindow()
		HomeWindow:destroyRootNode()
		showLoadingWindow("FightWindow")
	end
	PvpArenaManager:OnPreEnterPVP2(self.pvpmapId)
end

-- 闯关回包返回 3203
function globaldata:onChallengeBrave(msgPacket)
	__IsEnterFightWindow__ = true
	self.PvpType = "brave"
	AnySDKManager:td_task_begin("park")
	globaldata.fightresultkey = msgPacket:GetInt()
	self.pvpmapType = msgPacket:GetChar()
	self.pvpmapId =  msgPacket:GetInt()
	self.pvpmapNameId =  msgPacket:GetInt()
	self.pvpmaxTime =  msgPacket:GetInt()
	self.pvpfriendTeamCount  = msgPacket:GetUShort()
	self.pvpFriendPosList = {}
	for i=1,self.pvpfriendTeamCount do
		local x = msgPacket:GetUShort()/100
		local y = msgPacket:GetUShort()/100
		local pos = cc.p(x,y)
		table.insert(self.pvpFriendPosList,pos)
	end
	self.pvpEnemyTeamCount  = msgPacket:GetUShort()
	self.pvpEnemyPosList = {}
	for i=1,self.pvpEnemyTeamCount do
		local x = msgPacket:GetUShort()/100
		local y = msgPacket:GetUShort()/100
		local pos = cc.p(x,y)
		table.insert(self.pvpEnemyPosList,pos)
	end
	self.pvpmucicId = msgPacket:GetUShort()

	self:updateBattleFormation(msgPacket,true)
	self:updateEnemyInfoFormation(msgPacket)
	
	---------
	GUISystem:hideLoading()
	if globaldata.fightagain then
		globaldata.fightagain = false
		FightSystem:reloadFightWindow()
	else
		GUISystem:HideAllWindow()
		HomeWindow:destroyRootNode()
		showLoadingWindow("FightWindow")
	end
	PvpArenaManager:OnPreEnterPVP3(self.pvpmapId)
end

-- 挑战世界boss回包
function globaldata:onChallengWorldBoss(msgPacket)
	AnySDKManager:td_task_begin("wb")
	__IsEnterFightWindow__ = true
	self.PvpType = "boss"
	globaldata.fightresultkey = msgPacket:GetInt()
	self.pvpmapType = msgPacket:GetChar()
	self.pvpmapId =  msgPacket:GetInt()
	self.pvpmapNameId =  msgPacket:GetInt()
	self.pvpmaxTime =  msgPacket:GetInt()
	self.pvpfriendTeamCount  = msgPacket:GetUShort()
	self.pvpFriendPosList = {}
	for i=1,self.pvpfriendTeamCount do
		local x = msgPacket:GetUShort()/100
		local y = msgPacket:GetUShort()/100
		local pos = cc.p(x,y)
		table.insert(self.pvpFriendPosList,pos)
	end
	self.pvpEnemyTeamCount  = msgPacket:GetUShort()
	self.pvpEnemyPosList = {}
	for i=1,self.pvpEnemyTeamCount do
		local x = msgPacket:GetUShort()/100
		local y = msgPacket:GetUShort()/100
		local pos = cc.p(x,y)
		table.insert(self.pvpEnemyPosList,pos)
	end
	self.pvpmucicId = msgPacket:GetUShort()

	self:updateBattleFormation(msgPacket,true)
	self:updateEnemyInfoFormation(msgPacket)
	

	---------
	GUISystem:hideLoading()
	if globaldata.fightagain then
		globaldata.fightagain = false
		FightSystem:reloadFightWindow()
	else
		GUISystem:HideAllWindow()
		HomeWindow:destroyRootNode()
		showLoadingWindow("FightWindow")
	end
	globaldata.mFriendPvpDamage = {}
	PvpArenaManager:OnPreEnterWorldBoss(self.pvpmapId)
end


-- 掠夺战斗回包
function globaldata:onPlunderFightInfo(msgPacket)
	AnySDKManager:td_task_begin("market-rob")
	self.PvpType = "blackMarket"
	globaldata.fightresultkey = msgPacket:GetInt()
	self.mplunderindex = msgPacket:GetChar()
	self.mplundertaskid = msgPacket:GetInt()
	self.mplunderPlayerid = msgPacket:GetString()
	self.mboardIDforPlunder = msgPacket:GetInt()
	self.PlunderhardId = msgPacket:GetChar()
	self:updateBattleFormation(msgPacket,true)
	self:updateEnemyInfoFormation(msgPacket)
	----
	GUISystem:hideLoading()
	
	if globaldata.fightagain then
		globaldata.fightagain = false
		FightSystem:reloadFightWindow()
	else
		-- __IsEnterFighting__ = true
		GUISystem:HideAllWindow()
		HomeWindow:destroyRootNode()
		showLoadingWindow("FightWindow")
	end
	FubenManager:OnPreEnterPvePlunder()
end

-- 返回闯关奖励 3209
function globaldata:onChallenReward(msgPacket)
	local itemList = {}
	local towerLevel = msgPacket:GetInt()
	local rewardCount = msgPacket:GetUShort()
	for i = 1, rewardCount do
		local itemType = msgPacket:GetInt()
		local itemId = msgPacket:GetInt()
		local itemCount = msgPacket:GetInt()
		itemList[i] = {itemType, itemId, itemCount}
	end
	GUISystem:hideLoading()
	if rewardCount == 0 then return end
	MessageBox:showMessageBox4(itemList, false)
end

-- 返回查看玩家信息 2901
function globaldata:onPlayerInfoBack(msgPacket)
	globaldata.cityPlayer = {}
	globaldata.cityPlayer.playerId = msgPacket:GetString()
	globaldata.cityPlayer.banghuiName = msgPacket:GetString()
	if globaldata.cityPlayer.banghuiName == "" then
		globaldata.cityPlayer.banghuiName = "未加入公会"
	end
	globaldata.cityPlayer.playerName = msgPacket:GetString()
	globaldata.cityPlayer.playerFrame = msgPacket:GetInt()
	globaldata.cityPlayer.playerIcon = msgPacket:GetInt()
	globaldata.cityPlayer.playerLevel = msgPacket:GetInt()
	globaldata.cityPlayer.playerZhanli = msgPacket:GetInt()
	globaldata.cityPlayer.playerRank = msgPacket:GetInt()
	globaldata.cityPlayer.isfriend = msgPacket:GetChar()
	globaldata.cityPlayer.heroCount = msgPacket:GetUShort()
	globaldata.cityPlayer.hero = {}
	for j = 1, globaldata.cityPlayer.heroCount do
		globaldata.cityPlayer.hero[j] = {}
		globaldata.cityPlayer.hero[j].heroId = msgPacket:GetInt() 
		globaldata.cityPlayer.hero[j].advanceLevel = msgPacket:GetChar()
		globaldata.cityPlayer.hero[j].quality = msgPacket:GetChar()
		globaldata.cityPlayer.hero[j].level = msgPacket:GetInt()
	end
	if globaldata.requestType == "hallcity" then
		FightSystem.mHallManager:ShowPlayInfo(globaldata.cityPlayer, globaldata.menupos)
	elseif globaldata.requestType == "RankingWindow" then
		GUISystem.Windows["RankingWindow"]:onReceivePlayInfo()
	elseif globaldata.requestType == "FriendWindow" then
		GUISystem.Windows["FriendWindow"]:onReceivePlayInfo()
	elseif globaldata.requestType == "worldplayerinfo" then
		GUISystem.Windows["WorldBossWindow"]:onReceivePlayInfo(globaldata.cityPlayer)
	end
	GUISystem:hideLoading()
end

function globaldata:onOlPvpFightCall(msgPacket)
	--[[
	self.PvpType = "olpvp"
	self.pvpmapType = msgPacket:GetChar()
	self.pvpmapId =  msgPacket:GetInt()
	self.pvpmapNameId =  msgPacket:GetInt()
	self.pvpmaxTime =  msgPacket:GetInt()
	self.pvpfriendTeamCount  = msgPacket:GetUShort()
	self.pvpFriendPosList = {}
	for i=1,self.pvpfriendTeamCount do
		local x = msgPacket:GetUShort()/100
		local y = msgPacket:GetUShort()/100
		local pos = cc.p(x,y)
		table.insert(self.pvpFriendPosList,pos)
	end
	self.pvpEnemyTeamCount  = msgPacket:GetUShort()
	self.pvpEnemyPosList = {}
	for i=1,self.pvpEnemyTeamCount do
		local x = msgPacket:GetUShort()/100
		local y = msgPacket:GetUShort()/100
		local pos = cc.p(x,y)
		table.insert(self.pvpEnemyPosList,pos)
	end
	self.pvpmucicId = msgPacket:GetUShort()

	self:updateBattleFormation(msgPacket,true)
	self:updateEnemyInfoFormation(msgPacket)
	
	---------
	OnlinePvpManager:OnPreEnterPVP(self.pvpmapId)
	]]
end

-- 25001 收到游戏服务器匹配返回 
function globaldata:onMatchOnlineCallBack(msgPacket)
	self.Olmatchsuccess = msgPacket:GetChar()
	if self.Olmatchsuccess == 0 then
		local fighttype = msgPacket:GetChar()
		NetSystem.mNetManager2:setLoginKey(msgPacket:GetInt())
		globaldata.battleServerIp = msgPacket:GetString()
		globaldata.battleServerPort = msgPacket:GetInt()
		NetSystem:connectToSubServer(globaldata.battleServerIp,globaldata.battleServerPort)
	end
end

-- 客户端请求战斗消息 5006
-- function globaldata:onMatchOnlineCallBack(msgPacket)
-- 	-- self.Olmatchsuccess = msgPacket:GetChar()
-- 	-- if self.Olmatchsuccess == 0 then
-- 	-- 	local roomid = msgPacket:GetInt()
-- 	-- 	local targetid = msgPacket:GetString()
-- 	-- 	local targetName = msgPacket:GetString()
-- 	-- 	local level = msgPacket:GetInt()
-- 	-- 	local fightpower = msgPacket:GetInt()

-- 	-- 	local packet = NetSystem.mNetManager:GetSPacket()
--  --   	 	packet:SetType(PacketTyper._PTYPE_CS_REQUEST_OL_PVP_FIGHT_)
--  --   		packet:Send()

--  --   		 GUISystem:HideAllWindow()
--  --    	showLoadingWindow("FightWindow")
-- 	-- end
-- end

-- 客户端发送战斗开始信息 5008
function globaldata:RequeststartFight_OL()
	local packet = NetSystem.mNetManager2:GetSPacket()
    packet:SetType(PacketTyper2.C2B_PTYPE_CS_REDAY_OL_PVP_CLIENT)
    packet:Send(false)
end

-- 客户端发送同步技能消息
function globaldata:SendSyncSkill(_face , _skillID, _x, _y)
	
	local packet = NetSystem.mNetManager:GetSPacket()
    packet:SetType(PacketTyper._PTYPE_CS_FIGHT_SYNC_OL_PVP_)
    packet:PushChar(_face)
    packet:PushInt(_skillID)
    packet:PushUShort(_x)
	packet:PushUShort(_y)
    packet:Send()
end

-- 客户端

function globaldata:onItemGet(msgPacket)
	local itemList = {}
	local rewardCount = msgPacket:GetUShort()
	for i = 1, rewardCount do
		local itemType = msgPacket:GetInt()
		local itemId = msgPacket:GetInt()
		local itemCount = msgPacket:GetInt()
		itemList[i] = {itemType, itemId, itemCount}
		print("aaaaaaaaaaaaaaaaaaaaaa",itemType)
	end

	MessageBox:showMessageBox_ItemAlreadyGot(itemList)
end

function globaldata:onMoveFurnit(msgPacket)
	local sucess = msgPacket:GetChar()
	if 0 == sucess then
		local objGuid = msgPacket:GetString()
		local objId = msgPacket:GetInt()
		local posX = msgPacket:GetUShort()
		local posY = msgPacket:GetUShort()

		-- 查找已放置的
		for i = 1, #self.furnitListInHouse do
			if objGuid == self.furnitListInHouse[i].mGuid then -- 在已放置中
				
				-- if GUISystem.mFurnitManager then
				-- 	GUISystem.mFurnitManager:refresh()
				-- end

				local oldPosX = self.furnitListInHouse[i].mPosX
				local oldPosY = self.furnitListInHouse[i].mPosY
				self.furnitListInHouse[i].mPosX = posX
				self.furnitListInHouse[i].mPosY = posY
				GUISystem:hideLoading()

				-- 位置变化
				GUIEventManager:pushEvent("furnitChanged", "move", self.furnitListInHouse[i], oldPosX, oldPosY) 
				return
			end
		end

		-- 添加进已放置的
		local newFurnit = furnitObject:new()
		newFurnit.mGuid = objGuid
		newFurnit.mId = objId
		newFurnit.mPosX = posX
		newFurnit.mPosY = posY
		table.insert(self.furnitListInHouse, newFurnit)

		-- 未放置的删除
		for i = 1, #self.furnitListOutHouse do
			if objGuid == self.furnitListOutHouse[i].mGuid then
				table.remove(self.furnitListOutHouse, i)
				break
			end
		end
		GUISystem:hideLoading()
		-- if GUISystem.mFurnitManager then
		-- 	GUISystem.mFurnitManager:refresh()
		-- end
		-- 添加新家具
		GUIEventManager:pushEvent("furnitChanged", "add", newFurnit) 
	end
end

function globaldata:onDelFurnit(msgPacket)
	local objGuid = msgPacket:GetString()
	-- 查找已放置的
	for i = 1, #self.furnitListInHouse do
		if objGuid == self.furnitListInHouse[i].mGuid then -- 在已放置中
			-- 删除旧家具
			GUIEventManager:pushEvent("furnitChanged", "del", self.furnitListInHouse[i]) 

			table.remove(self.furnitListInHouse, i)
			GUISystem:hideLoading()
			-- if GUISystem.mFurnitManager then
			-- 	GUISystem.mFurnitManager:refresh()
			-- end
			return
		end
	end
end

-- 请求OLPVP 战斗消息
function globaldata:onrequestOlpvpInfo()
	local packet = NetSystem.mNetManager2:GetSPacket()
	packet:SetType(PacketTyper2.C2B_CONNECT_OLPVPFIGHTINFO_CLIENT)
	packet:Send(false)
	GUISystem:showLoading()
end

function globaldata:onOlPvpFightInfoCall(msgPacket)
	self.PvpType = "olpvp"
	self.pvpmapType = msgPacket:GetChar()
	self.pvpmapId =  msgPacket:GetInt()
	self.pvpmapNameId =  msgPacket:GetInt()
	self.pvpmaxTime =  msgPacket:GetInt()
	self.pvpfriendTeamCount  = msgPacket:GetUShort()
	self.pvpFriendPosList = {}
	for i=1,self.pvpfriendTeamCount do
		local x = msgPacket:GetUShort()/100
		local y = msgPacket:GetUShort()/100
		local pos = cc.p(x,y)
		table.insert(self.pvpFriendPosList,pos)
	end
	self.pvpEnemyTeamCount  = msgPacket:GetUShort()
	self.pvpEnemyPosList = {}
	for i=1,self.pvpEnemyTeamCount do
		local x = msgPacket:GetUShort()/100
		local y = msgPacket:GetUShort()/100
		local pos = cc.p(x,y)
		table.insert(self.pvpEnemyPosList,pos)
	end
	self.pvpmucicId = msgPacket:GetUShort()
	self.olpvpType = msgPacket:GetInt()
	self.olHoldindex = nil
	if self.olpvpType == 1 or self.olpvpType == 2 then
		self.olHoldindex = msgPacket:GetChar()
	end
	self:updateFriendFightInfo_OLPvp(msgPacket)
	self:updateEnemyFightInfo_OLPvp(msgPacket)
	
	GUISystem:hideLoading()
	
	if GUISystem.Windows["LadderWindow"].mRootNode ~= nil and self.olpvpType ~= 3 then
		GUISystem.Windows["LadderWindow"]:NotifySearchSuccess()
	else
		GUISystem:HideAllWindow()
		showPVPLoadingWindow("FightWindow")
	end
	if self.olpvpType == 0 or self.olpvpType == 3 then
		self.mFriendCurLive = 1
		self.mEnemyCurLive = 1
	end

	if self.olpvpType == 0 then
		-- 1v1
		AnySDKManager:td_task_begin("pvp-1")
	elseif self.olpvpType == 1 then
		-- 3v3
		AnySDKManager:td_task_begin("pvp-3")
	elseif self.olpvpType == 2 then
		-- 公会战
		AnySDKManager:td_task_begin("union-fight")
	end
end

-- 加载游戏百分比
function globaldata:onLoadPVPPercentage(msgPacket)
	local count = msgPacket:GetUShort()
	for i=1,count do
		local index = msgPacket:GetChar()
		local percentag = msgPacket:GetChar()
		if GUISystem.Windows["LadderLoadingWindow"].mRootNode then
			GUISystem.Windows["LadderLoadingWindow"]:setPercentLoad(index,percentag)
		else
			if FightSystem.mTouchPad and FightSystem.mTouchPad.mTypeName == "fighttouch" then
				FightSystem.mTouchPad:setLoadPanelPer(index,percentag)
			end
		end
	end
end

function globaldata:onOlPvpFinishCall(msgPacket)
	local sucess = msgPacket:GetChar()

	self.mPvpTotalScore = msgPacket:GetInt()
	self.mPvpWinScore = msgPacket:GetInt()

	if FightSystem:GetFightManager() then
		FightSystem:GetFightManager().isTick = false
	end
	local infoArr = {}
	for i=1,3 do
		infoArr[i]    = {}
		infoArr[i][1] = globaldata:getBattleFormationInfoByIndexAndKey(i,"id")
		infoArr[i][2] = globaldata:getBattleFormationInfoByIndexAndKey(i,"level")
		infoArr[i][3] = globaldata:getBattleFormationInfoByIndexAndKey(i,"quality")
		infoArr[i][4] = globaldata:getBattleFormationInfoByIndexAndKey(i,"advanceLevel")
		infoArr[i][5] = globaldata:getBattleFormationInfoByIndexAndKey(i,"playerName")
		infoArr[i][6] = 1000*i
	end

	for i = 1,3 do
		infoArr[3 + i]    = {}
		infoArr[3 + i][1] = globaldata:getBattleEnemyFormationInfoByIndexAndKey(i,"id")
		infoArr[3 + i][2] = globaldata:getBattleEnemyFormationInfoByIndexAndKey(i,"level")
		infoArr[3 + i][3] = globaldata:getBattleEnemyFormationInfoByIndexAndKey(i,"quality")
		infoArr[3 + i][4] = globaldata:getBattleEnemyFormationInfoByIndexAndKey(i,"advanceLevel")
		infoArr[3 + i][5] = globaldata:getBattleFormationInfoByIndex(i,"playerName")
		infoArr[3 + i][6] = 1000*(i + 3)
	end
	self.mFriendPvpDamage = {}
	self.mEnemyPvpDamage = {}
	self.mPvpDamageMax = 0
	if sucess == 0 then
		local winTeamNum = msgPacket:GetUShort()
		for i=1,winTeamNum do
			local DamagData = {}
			DamagData.Name = msgPacket:GetString()
			DamagData.Damage = msgPacket:GetInt()
			self.mFriendPvpDamage[i] = DamagData
			if self.mPvpDamageMax < DamagData.Damage then
				self.mPvpDamageMax = DamagData.Damage
			end
		end

		local loseTeamNum = msgPacket:GetUShort()
		for i=1,loseTeamNum do
			local DamagData = {}
			DamagData.Name = msgPacket:GetString()
			DamagData.Damage = msgPacket:GetInt()
			self.mEnemyPvpDamage[i] = DamagData
			if self.mPvpDamageMax < DamagData.Damage then
				self.mPvpDamageMax = DamagData.Damage
			end
		end
	else
		local winTeamNum = msgPacket:GetUShort()
		for i=1,winTeamNum do
			local DamagData = {}
			DamagData.Name = msgPacket:GetString()
			DamagData.Damage = msgPacket:GetInt()
			self.mEnemyPvpDamage[i] = DamagData
			if self.mPvpDamageMax < DamagData.Damage then
				self.mPvpDamageMax = DamagData.Damage
			end
		end
		local loseTeamNum = msgPacket:GetUShort()
		for i=1,loseTeamNum do
			local DamagData = {}
			DamagData.Name = msgPacket:GetString()
			DamagData.Damage = msgPacket:GetInt()
			self.mFriendPvpDamage[i] = DamagData
			if self.mPvpDamageMax < DamagData.Damage then
				self.mPvpDamageMax = DamagData.Damage
			end
		end
	end

	Event.GUISYSTEM_SHOW_LADDERRESULTWINDOW.mData    = {{},{}}
	Event.GUISYSTEM_SHOW_LADDERRESULTWINDOW.mData[1] = {sucess,globaldata.olpvpType}
	Event.GUISYSTEM_SHOW_LADDERRESULTWINDOW.mData[2] = infoArr--{{1,9,6,3,"",1000},{2,9,6,3,"",900},{3,9,6,3,"",800},{4,9,6,3,"",700},{5,9,6,3,"",600},{6,9,6,3,"",500}}
														-- 1.id 2.level 3.quality 4.advancedLevel 5.name 6.damage
	EventSystem:PushEvent(Event.GUISYSTEM_SHOW_LADDERRESULTWINDOW)
	NetSystem.mNetManager2:ForceDisconnectSubServer()
end

function globaldata:onCancelOlPvp(msgPacket)
	local sucess = msgPacket:GetChar()
	if sucess == 0 then
		if GUISystem.Windows["LadderWindow"].mRootNode ~= nil then
			GUISystem.Windows["LadderWindow"]:NotifyCancelSearch(LADDERCANCEL.NORMAL)
		end
	end
end

-- 3v3
function globaldata:requestOLpvp3v3(heroId)
	local packet = NetSystem.mNetManager:GetSPacket()
	packet:SetType(PacketTyper._PTYPE_CS_MATCH_OL_PVP_)
	packet:PushChar(1)
	packet:PushUShort(1)
	packet:PushInt(heroId)
	packet:Send(false)
end

function globaldata:requestOLpvp1v1(heroId1,heroId2,heroId3)
	local packet = NetSystem.mNetManager:GetSPacket()
	packet:SetType(PacketTyper._PTYPE_CS_MATCH_OL_PVP_)
	packet:PushChar(0)
	packet:PushUShort(3)
	packet:PushInt(heroId1)
	packet:PushInt(heroId2)
	packet:PushInt(heroId3)
	packet:Send(false)
end

function globaldata:cancelOLpvp()
	local packet = NetSystem.mNetManager:GetSPacket()
    packet:SetType(PacketTyper._PTYPE_CS_CANCLE_OL_PVP_)
    packet:Send(false)
end

-- 帮会排名信息
function globaldata:onRequestBanghuiHallData(msgPacket)
	self.GangData.rankNum = msgPacket:GetUShort()
	self.GangData.rankList = {}
	for i=1,self.GangData.rankNum do
		local data = BanghuirankObject:new()
		data.mBanghuiName = msgPacket:GetString()
		data.mScore = msgPacket:GetInt()
		table.insert(self.GangData.rankList,data)
	end
	self.GangData.memberrankNum = msgPacket:GetUShort()
	self.GangData.memberrankList = {}
	for i=1,self.GangData.memberrankNum do
		local data = BanghuirankObject:new()
		data.mBanghuiName = msgPacket:GetString()
		data.mScore = msgPacket:GetInt()
		table.insert(self.GangData.memberrankList,data)
	end
	self.GangData.mMyFighgCount = msgPacket:GetInt()
	self.GangData.mMyWinTimes = msgPacket:GetInt()
	self.GangData.mOwnScore = msgPacket:GetInt()
end

-- 帮会信息
function globaldata:onRequestBanghuiTeamObject(msgPacket)
	local roomData = BanghuiTeamObject:new()
		roomData.mBanghuiRoomId = msgPacket:GetInt()
		roomData.mBanghuiTeamCount = msgPacket:GetUShort()
		roomData.mBanghuiList = {}
		for i=1,roomData.mBanghuiTeamCount do
			local playerinfo = BanghuiPlayerInfo:new()
			playerinfo.mPlayerId = 	msgPacket:GetString() 	
			playerinfo.mPlayerName 	= 	msgPacket:GetString()
			playerinfo.mFightHeroId = msgPacket:GetInt()
			playerinfo.mFightHeroLevel = msgPacket:GetInt()
			playerinfo.mFightHeroquality = msgPacket:GetChar()
			playerinfo.mFightHeroadvanceLv = msgPacket:GetChar()
			playerinfo.mIsLeader = msgPacket:GetChar()
			playerinfo.mIsReady = msgPacket:GetChar() --0    1== 准备
			table.insert(roomData.mBanghuiList,playerinfo)
		end
	return  roomData
end

-- 帮会战斗信息
function globaldata:onRequestFightBanghuiData(msgPacket)
	self.GangData.teamNum = msgPacket:GetUShort()
	self.GangData.teamFightList = {}
	for i=1,self.GangData.teamNum do
		local roomData = self:onRequestBanghuiTeamObject(msgPacket)
		self.GangData.teamFightList[roomData.mBanghuiRoomId] = roomData
	end
end

function globaldata:onRequestCreateTeamFight(msgPacket)
	local roomData = self:onRequestBanghuiTeamObject(msgPacket)
	self.GangData.mOwnTeam = roomData
end

function globaldata:onRequestTeamListBanghuiSYNC(msgPacket)
	local roomData = self:onRequestBanghuiTeamObject(msgPacket)
	return roomData
end

function globaldata:doGetLevelRewardExRequest()
	if globaldata.curLvRewardInfo.idx == 0 then MessageBox:showMessageBox1("暂无等级奖励！") return end
	local packet = NetSystem.mNetManager:GetSPacket()
	packet:SetType(PacketTyper._PTYPE_CS_GET_LEVEL_REWARDEX_REQUEST_)
	packet:Send()	
end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 同步基础数据,背包
NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_REQUEST_SYNCINFO_, handler(globaldata, globaldata.syncInfoFromServer))

-- 同步阵容
--NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_REQUEST_EXCHANGEHERO_, handler(globaldata, globaldata.syncBattleFromServer))

-- 响应装备强化信息
NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_REQUEST_EQUIP_STRENGTHEN_, handler(globaldata, globaldata.onEquipDoStrengthen))

-- 请求一键镶嵌回包
NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_REQUEST_ONEKEY_XIANGQIAN_, handler(globaldata, globaldata.onEquipOneKeyXiangqian))

-- 请求镶嵌宝石回包
NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_REQUEST_DIAMOND_XIANGQIAN_, handler(globaldata, globaldata.onEquipDoDiamondXiangqian))

-- 请求脱掉宝石回包
NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_REQUEST_DIAMOND_PUTOFF_, handler(globaldata, globaldata.onEquipDoDiamondPutoff))

-- 城镇大厅更新新场景数据
NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_CITYHALL_NEWCITYDATA, handler(globaldata, globaldata.onCityHallNewSceneEnter))

-- 3023 副本战斗结算服务器返回
NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_REQUEST_FUBEN_BALANCE_, handler(globaldata, globaldata.onFubenBalance))

-- 8509 爬塔战斗结算服务器返回
NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_TOWEREX_RESULT_RESPONSE, handler(globaldata, globaldata.onFubenPaTaBalance))

-- 8015 掠夺战斗结算服务器返回
NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_BEGIN_ROB_RESULT_RESPONSE, handler(globaldata, globaldata.onFubenPlunderBalance))

-- 玩家升级
NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_PLAYER_LEVELUP_, handler(globaldata, globaldata.onPlayerLevelup))

-- 商城刷新
NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_REQUEST_FRESHSHOP_, handler(globaldata, globaldata.onRequestFreshShop))

-- 战斗回包 3021
NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_REQUEST_GOTOBATTLE_, handler(globaldata,globaldata.onRequestEnterBattle))

-- 财富之山战斗回包 2729
NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_REQUEST_WEALTH_BATTLE_, handler(globaldata,globaldata.onRequestEnterBattleWealth))

-- 爬塔挑战回包 8507
NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_TOWER_EX_CHALLENGE_RESPONSE, handler(globaldata,globaldata.onRequestEnterBattleTower))

-- 掠夺战斗回包8013
NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_BEGIN_ROB_RESPONSE, handler(globaldata,globaldata.onPlunderFightInfo))

-- 查询星星奖励回包
NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_STARREWARD_INFO_, handler(globaldata,globaldata.onRequestRewardInfo))

-- 领取星星奖励回包
NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_STARREWARD_GET_, handler(globaldata,globaldata.onRequestRewardGet))

-- PK回包2903
NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_REQUEST_PLAYER_PK_, handler(globaldata,globaldata.onPkBackInfo))

-- PVP回包2803
NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_REQUEST_CHALLENGE_PLAYER_, handler(globaldata,globaldata.updateBattlePvpInfo))

-- 2901 查看玩家信息返回
NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_REQUEST_PLAYER_INFO_, handler(globaldata,globaldata.onPlayerInfoBack))

-- 通用显示物品窗
NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_ITEM_GET, handler(globaldata,globaldata.onItemGet))

-- 3203 闯关回包
NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_REQUEST_CHALLENGE_BRAVE, handler(globaldata,globaldata.onChallengeBrave))

--3255 挑战boss回包
NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_BOSSFIGHT_REQUEST_BACK_, handler(globaldata,globaldata.onChallengWorldBoss))

-- 3209 闯关奖励回包
NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_REQUEST_BRAVE_COMPLETE_, handler(globaldata,globaldata.onChallenReward))

-- 竞技场结果返回
NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_RESULT_PVP_BACK_, handler(globaldata,globaldata.onPvpArenaResultBack))

-- boos结果返回
NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_BOSSFIGHT_RESULT_BACK_, handler(globaldata,globaldata.onBossResultBack))

-- 移动家具回包
NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_FURNITURE_MOVE_, handler(globaldata,globaldata.onMoveFurnit))

-- 删除家具回包
NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_FURNITURE_DEL_, handler(globaldata,globaldata.onDelFurnit))

-- 客户端请求战斗消息 5007
NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_REQUEST_OL_PVP_FIGHT_, handler(globaldata,globaldata.onOlPvpFightCall))

-- 客户端发送战斗开始信息 5009
NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_FURNITURE_DEL_, handler(globaldata,globaldata.onDelFurnit))

-- 客户端向服务器请求匹配进行Online 5002
NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_MATCH_OL_PVP_, handler(globaldata,globaldata.onMatchOnlineCallBack))

-- 服务器向客户端返回OLPVP
NetSystem.mNetManager2:RegisterPacketHandler(PacketTyper2.B2C_CONNECT_OLPVPFIGHTINFO_SERVER, handler(globaldata,globaldata.onOlPvpFightInfoCall))

-- 服务器返回OLPVP结果
NetSystem.mNetManager2:RegisterPacketHandler(PacketTyper2.B2C_FIGHT_OLPVP_FINISH_SERVER, handler(globaldata,globaldata.onOlPvpFinishCall))

-- 取消匹配
NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_CANCLE_OL_PVP_, handler(globaldata,globaldata.onCancelOlPvp))

-- PVP配分加载游戏百分比
NetSystem.mNetManager2:RegisterPacketHandler(PacketTyper2.B2C_FIGHT_OLPVP_LOAD_PERCENT_SERVER, handler(globaldata,globaldata.onLoadPVPPercentage))

---------------------------------------------------QA--------------------------------------------------------


function globaldata:onQA_Tili(msgPacket)
	GUISystem:hideLoading()

	local param_Price 		= msgPacket:GetInt() -- 价格
	local param_Vatality 	= msgPacket:GetInt() -- 购买体力的数量
	local parem_HasBuy 		= msgPacket:GetInt() -- 已经购买的数量
	local param_TotalBuy 	= msgPacket:GetInt() -- 总共可以购买的次数

	local paramList = {param_Price, param_Vatality, parem_HasBuy, param_TotalBuy}

	local function doOk()
		local packet = NetSystem.mNetManager:GetSPacket()
    	packet:SetType(PacketTyper._PTYPE_CLIENT_QA_TILI)
    	packet:Send()
    	GUISystem:showLoading()
	end

	MessageBox:showMessageBox_QA("tili", paramList, doOk)

end

NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SERVER_QA_TILI, handler(globaldata, globaldata.onQA_Tili))

function globaldata:onQA_Libao(msgPacket)
	GUISystem:hideLoading()

	local param_Price 		= msgPacket:GetInt() -- 价格
	local param_VipLevel 	= msgPacket:GetInt() -- 购买VIP礼包的等级

	local paramList = {param_Price, param_VipLevel}

	local function doOk()
		local packet = NetSystem.mNetManager:GetSPacket()
    	packet:SetType(PacketTyper._PTYPE_CLIENT_QA_LIBAO)
    	packet:PushInt(param_VipLevel)
    	packet:Send()
    	GUISystem:showLoading()
	end

	MessageBox:showMessageBox_QA("libao", paramList, doOk)

end

NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SERVER_QA_LIBAO, handler(globaldata, globaldata.onQA_Libao))

function globaldata:onQA_Chongzhi(msgPacket)
	GUISystem:hideLoading()

	local param_MapType 	= msgPacket:GetInt() -- 地图类型
	local param_MapId 		= msgPacket:GetInt() -- 章节ID
	local param_StageId		= msgPacket:GetInt() -- 关卡ID
	local param_Price       = msgPacket:GetInt() -- 价格
	local param_HasBuy 		= msgPacket:GetInt() -- 已经购买的次数
	local param_TotalBuy 	= msgPacket:GetInt() -- 总共可以购买的次数

	local paramList = {param_Price, param_HasBuy, param_TotalBuy}

	local function doOk()
		local packet = NetSystem.mNetManager:GetSPacket()
    	packet:SetType(PacketTyper._PTYPE_CLIENT_QA_CHONHZHI)
    	packet:PushInt(param_MapType)
    	packet:PushInt(param_MapId)
    	packet:PushInt(param_StageId)
    	packet:Send()
    	GUISystem:showLoading()
	end

	MessageBox:showMessageBox_QA("chongzhi", paramList, doOk)

end

NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SERVER_QA_CHONHZHI, handler(globaldata, globaldata.onQA_Chongzhi))

function globaldata:onQA_Arena(msgPacket)
	GUISystem:hideLoading()

	local param_Price 		= msgPacket:GetInt() -- 价格
	local param_Count 		= msgPacket:GetInt() -- 次数
	local param_HasBuy 		= msgPacket:GetInt() -- 已经购买的次数
	local param_TotalBuy 	= msgPacket:GetInt() -- 总共可以购买的次数

	local paramList = {param_Price, param_Count, param_HasBuy, param_TotalBuy}

	local function doOk()
		local packet = NetSystem.mNetManager:GetSPacket()
    	packet:SetType(PacketTyper._PTYPE_CLIENT_QA_ARENA)
    	packet:Send()
    	GUISystem:showLoading()
	end

	MessageBox:showMessageBox_QA("arena", paramList, doOk)

end

NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SERVER_QA_ARENA, handler(globaldata, globaldata.onQA_Arena))

function globaldata:onQA_Shop(msgPacket)
	GUISystem:hideLoading()

	local param_ShopType 	= msgPacket:GetInt() -- 商店类型
	local param_Price 		= msgPacket:GetInt() -- 价格
	local param_HasBuy 		= msgPacket:GetInt() -- 已经购买的次数
	local param_TotalBuy 	= msgPacket:GetInt() -- 总共可以购买的次数

	local paramList = {param_Price, param_HasBuy, param_TotalBuy}

	local function doOk()
		local packet = NetSystem.mNetManager:GetSPacket()
    	packet:SetType(PacketTyper._PTYPE_CLIENT_QA_SHOP)
    	packet:PushInt(param_ShopType)
    	packet:Send()
    	GUISystem:showLoading()
	end

	MessageBox:showMessageBox_QA("shopFresh", paramList, doOk)

end

NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SERVER_QA_SHOP, handler(globaldata, globaldata.onQA_Shop))

function globaldata:onQA_ShopBuy(msgPacket)
	GUISystem:hideLoading()

	local param_ShopType 	= msgPacket:GetInt() 	-- 商店类型
	local param_ItemIndex   = msgPacket:GetInt() 	-- 商品索引
	local param_ItemType	= msgPacket:GetInt() 	-- 商品类型
	local param_ItemId 		= msgPacket:GetInt() 	-- 商品ID
	local param_Count 		= msgPacket:GetInt() 	-- 数量
	local param_ItemName 	= msgPacket:GetString() -- 商品名称
	local param_Price 		= msgPacket:GetInt() 	-- 价格

	local paramList = {param_Price, param_Count, param_ItemName, param_ItemType, param_ItemId}

	local function doOk()
		local packet = NetSystem.mNetManager:GetSPacket()
    	packet:SetType(PacketTyper._PTYPE_CLIENT_QA_SHOP_BUY)
    	packet:PushInt(param_ShopType)
    	packet:PushInt(param_ItemIndex)
    	packet:PushInt(param_ItemType)
    	packet:PushInt(param_ItemId)
    	packet:PushInt(param_Count)
    	packet:Send()
    	GUISystem:showLoading()
	end

	MessageBox:showMessageBox_QA("shopBuy", paramList, doOk)

end

NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SERVER_QA_SHOP_BUY, handler(globaldata, globaldata.onQA_ShopBuy))

function globaldata:onQA_Heishi(msgPacket)
	GUISystem:hideLoading()

	local param_Price 		= msgPacket:GetInt() 	-- 价格

	local paramList = {param_Price}

	local function doOk()
		local packet = NetSystem.mNetManager:GetSPacket()
    	packet:SetType(PacketTyper._PTYPE_CLIENT_QA_SHOP_HEISHI)
    	packet:Send()
    	GUISystem:showLoading()
	end

	MessageBox:showMessageBox_QA("heishi", paramList, doOk)

end

NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SERVER_QA_SHOP_HEISHI, handler(globaldata, globaldata.onQA_Heishi))

function globaldata:onQA_Gonghui(msgPacket)
	GUISystem:hideLoading()

	local param_IconId		= msgPacket:GetInt()	-- 图标
	local param_Name 		= msgPacket:GetString() -- 名字
	local param_Price 		= msgPacket:GetInt() 	-- 价格

	local paramList = {param_Price}

	local function doOk()
		local packet = NetSystem.mNetManager:GetSPacket()
    	packet:SetType(PacketTyper._PTYPE_CLIENT_QA_SHOP_GONGHUI)
    	packet:PushInt(param_IconId)
    	packet:PushString(param_Name)
    	packet:Send()
    	GUISystem:showLoading()
	end

	MessageBox:showMessageBox_QA("gonghui", paramList, doOk)

end

NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SERVER_QA_SHOP_GONGHUI, handler(globaldata, globaldata.onQA_Gonghui))


function globaldata:onQA_WorldBoss(msgPacket)
	GUISystem:hideLoading()

	local param_price 		= msgPacket:GetInt() 	-- 价钱
	local param_count		= msgPacket:GetInt() 	-- 数量

	local paramList = {param_price,param_count}

	local function doOk()
		local packet = NetSystem.mNetManager:GetSPacket()
    	packet:SetType(PacketTyper._PTYPE_CLIENT_QA_WORLD_BOSS_)
    	packet:Send()
    	GUISystem:showLoading()
	end

	MessageBox:showMessageBox_QA("worldboss", paramList, doOk)

end

NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SERVER_QA_WORLD_BOSS_, handler(globaldata, globaldata.onQA_WorldBoss))

function globaldata:onQA_WorldBoss(msgPacket)
	GUISystem:hideLoading()

	local param_heroid		= msgPacket:GetInt() 	-- 数量
	local param_price 		= msgPacket:GetInt() 	-- 价钱

	local paramList = {param_price}

	local function doOk()
		local packet = NetSystem.mNetManager:GetSPacket()
    	packet:SetType(PacketTyper._PTYPE_CLIENT_QA_TALENT_RESET_)
    	packet:PushInt(param_heroid)
    	packet:Send()
    	GUISystem:showLoading()
	end

	MessageBox:showMessageBox_QA("talent", paramList, doOk)

end

NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SERVER_QA_TALENT_RESET_, handler(globaldata, globaldata.onQA_WorldBoss))

function globaldata:onQA_ExpandAfBag(msgPacket)
	GUISystem:hideLoading()

	local param_price 		= msgPacket:GetInt() 	-- 价钱
	local paramList = {param_price}

	local function doOk()
		local packet = NetSystem.mNetManager:GetSPacket()
    	packet:SetType(PacketTyper._PTYPE_CS_EXPAND_AFBAG_ANSWER)
    	packet:Send()
    	GUISystem:showLoading()
	end

	MessageBox:showMessageBox_QA("afbag", paramList, doOk)

end

NetSystem.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_EXPAND_AFBAG_QUESTION, handler(globaldata, globaldata.onQA_ExpandAfBag))


---------------------------------------------------QA--------------------------------------------------------
