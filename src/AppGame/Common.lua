-- Name: 	Common
-- Func：	common types
-- Author:	lichuan
-- Data:	15-5-11

--UICONFIG

config = config or {}

config.TowerSweepValue          = 3
config.TowerEnemyCnt            = 3     --闯关敌方人数
config.NoticeWidthFactor        = 100   --每100长度 
config.NoticeTimeFactor         = 2     --用2s
config.NoticeTimerGap           = 5     --每5秒播一次
config.LadderCancelTimeGap      = 5     --天梯取消时间间隔
config.TowerExTotalFloor        = 200   --闯关总工关卡数量
config.TechBoardFactorBase1     = 10    --星运板1开放参数
config.TechBoardFactorBase2     = 20    --星运板2开放参数
config.TechBoardFactorEx1       = 6     --星运板1开放参数ex
config.TechBoardFactorEx2       = 8     --星运板2开放参数ex
config.TowerFigntCnt            = 1     --游乐园上阵人数限制 at least


--TYPES
SUCCESS                         = 0
FAILED                          = 1            

--战斗类型
BATTLE_TYPE		                 = {}
BATTLE_TYPE.SINGLE              = 0
BATTLE_TYPE.MULTI               = 1
BATTLE_TYPE.BANGHUI             = 2

--战斗结果
BATTLE_RESULT		              = {}
BATTLE_RESULT.SUCCESS           = 0
BATTLE_RESULT.FAIL              = 1
BATTLE_RESULT.EXCEPTION         = 2

--天梯取消类型
LADDERCANCEL                    = {}
LADDERCANCEL.NORMAL             = 1
LADDERCANCEL.EXCEPTION          = 0

--窗口
WINDOW_FROM                     = {}
WINDOW_FROM.BATTLE              = 1  	    --FightWindow
WINDOW_FROM.GAME                = 2			--Game2048Window
WINDOW_FROM.CARDGAME            = 3			--卡牌
WINDOW_FROM.HEROGUESS           = 4			--篮球
WINDOW_FROM.ROUND               = 5			--回合制

--任务类型
TASKTYPE                        = {}
TASKTYPE.MAINLINE               = 4
TASKTYPE.ACTIVITY               = 3
TASKTYPE.USUAL 	              = 2
TASKTYPE.ACHIEVE 	              = 1

--黑市任务类型
BMTYPE = {}
BMTYPE.GUARD   = 1
BMTYPE.PLUNDER = 2

--排行榜类型
RANKTYPE                        = {MAIN = {},MINOR = {}}
RANKTYPE.MAIN.ORGANIZE          = 1
RANKTYPE.MAIN.HERO              = 2
RANKTYPE.MAIN.PARTY             = 3

RANKTYPE.MINOR.ALLFIGHTPOWER    = 1
RANKTYPE.MINOR.ARENA 	        = 2
RANKTYPE.MINOR.LADDER1V1 	     = 3
RANKTYPE.MINOR.LADDER3V3 	     = 4
RANKTYPE.MINOR.CHARM 	        = 5

--帮派类型

PARTYROLE                       = {}
PARTYROLE.MASTER                = 3
PARTYROLE.SMALLMASTER           = 2
PARTYROLE.MEMBER                = 1
PARTYROLE.NOTMEMBER             = 0

PARTYROLESTR                    = {"会员","副会长","会长"}

LIMITTYPE                       = {LIMITT_NONE,LIMITT_NEED,LIMIT_FORBIDDEN}

--奖励领取状态

REWARDSTATE                     = {}
REWARDSTATE.CANNOTRECEIVE       = 0
REWARDSTATE.CANRECEIVE          = 1
REWARDSTATE.HAVERECEIVED        = 2

--选人界面类型
SELECTHERO                      = {}
SELECTHERO.SHOWSELF             = 1
SELECTHERO.SHOWBOTH             = 2

--财富山
WEALTHTYPE                      = {}
WEALTHTYPE.MONEY                = 1
WEALTHTYPE.SUSHI                = 2
WEALTHTYPE.STONE                = 3  

deque={}

function deque.new()
   return {first=0, last=-1}
end

function deque.pushFront(dq,value)
   dq.first = dq.first-1
   dq[dq.first] = value
end

function deque.pushBack(dq,value)
   dq.last = dq.last + 1
   dq[dq.last] = value
end

function deque.popFront(dq)
   local first = dq.first
   if first > dq.last then 
      error("deque is empty!")
   end
   local value = dq[first]
   dq[first] = nil
   dq.first = first + 1
   return value
end

function deque.popBack(dq)
   local last = dq.last
   if last < dq.first then 
      error("deque is empty!")
   end
   local value = dq[last]
   dq[last] = nil
   dq.last = last-1
   return value
end

function deque.getFront(dq)
   local first = dq.first
   if first > dq.last then 
      error("deque is empty!") 
   end
   return dq[first]
end

function deque.getNextToLast(dq) --压轴
   local last = dq.last

   if last < dq.first then 
      error("deque is empty!") 
   end

   return dq[last - 1]  
end

function deque.getBack(dq)
   local last = dq.last
   if last < dq.first then 
      error("deque is empty!")
   end
   return dq[last]
end

function deque.empty(dq)
   local first = dq.first
   return first > dq.last
end

function empty(table)
   return next(table) == nil
end

function istable(tbl)
    return type(tbl) == "table"
end

function CreatEnumTable(tbl,index)
   assert(istable(tbl)) 
   local enumtbl = {} 
   local enumindex = index or 0 
   for i, v in ipairs(tbl) do 
      enumtbl[v] = enumindex + i 
   end 
   return enumtbl 
end

--ex  
-- EnumTable = 
-- { 
--     "ET1", 
--     "ET2", 
-- }

-- EnumTable = CreatEnumTable(EnumTable)
-- EnumTable = CreatEnumTable(EnumTable,10)  
-- print(EnumTable.ET1) 
-- print(EnumTable.ET2) 