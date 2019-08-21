-- Name: FightConfig
-- Func: 战斗配置
-- Author: Johny

module("FightConfig", package.seeall)


----------------------------DEBUG 模式下，各功能的开关-----------------------
if GAME_MODE == ENUM_GAMEMODE.debug then
__DEBUG_ROLEPOINT               		= false
__DEBUG_SKILLRANGE 						= false
__DEBUG_SCENEANI_RANGE 					= false
__DEBUG_CITYHALL_MYPOS 					= false
__DEBUG_ROLE_STATUS 					= false  	-- 角色状态信息
__DEBUG_AI_NOPAIHUAI 					= false
__DEBUG_SKILL_COOLDOWN 					= false  	-- 是否技能冷却
__DEBUG_FIGHT_DIRECTOR_TIMESCALE 		= 1 		-- 游戏全局时间scale
__DEBUG_FRIEND_AI_  					= false   	-- 有方AI 暂停
__DEBUG_ENEMY_AI_  						= false   	-- 敌方AI 暂停
__DEBUG_PLAYCG_ 						= false 	-- 开启CG
__DEBUG_FUBEN_ONE_MONSTERID_ 			= false 	-- 开启副本单怪模式
-------------------------性能调试开关-----------------------------
__DEBUG_BGM_CLOSED_						= true      -- 关闭BGM
__DEBUG_MEMORY_ 						= false  	-- 开启 显示内存
__DEBUG_CLOSELOAD_SCENE_ 				= false   	-- 关闭渲染场景
__DEBUG_CLOSELOAD_SPINE_ 				= false  	-- 关闭spine渲染
__DEBUG_CLOSELOAD_FLOWLABEL_ 			= false 	-- 关闭战斗飘字
__DEBUG_TOUCH_BEGAN_POINT_ 				= false  	-- 关闭点屏幕转换地图坐标点
end

---------------------------仅realse模式下,特殊处理------------------------------
__DEBUG_FIGHT_GM_ 						= not (GAME_MODE == ENUM_GAMEMODE.release)   	-- 战斗中GM命令开关(一键通关等)
------------------------------------------------------------------------------

----------------------------任何 模式下，各功能的开关-----------------------
__DEBUG_DAMAGE_FONTNUM 					= true  	-- 是否显示伤害字
------------------------------------------------------------------------------




--受击者搜寻高度限制
VICTIM_HEIGHT_LIMITED = 250

-- 死亡击飞时间
DEAD_FLY_DURING = 30
DEAD_FLY_DISX = 250

-- 击飞静止帧
KNOCKFLY_FLY_DURING = 3

-- 战斗边缘
MAP_EDGE = 100

-- 0:STOP  1：方向-上  2：方向-下  3：方向-左  4：方向-右  5：方向左上  6：方向右上  7：方向左下  8：方向右下
DIRECTION_CMD = {STOP = 0, DUP = 1, DDOWN = 2, DLEFT =3, DRIGHT = 4,
             DLEFTUP = 5, DRIGHTUP = 6, DLEFTDOWN = 7, DRIGHTDOWN =8
            }


-- 移动状态(触摸板与人物对接枚举)
GOSTATE = {UNKNOWN = 0, WALK = 1, RUN = 2}

-- 战斗场景层级 
FIGHTWINDOW_Z_SCENEVIEW = 1
FIGHTWINDOW_Z_SKILLANI = 2
FIGHTWINDOW_Z_TOUCHPAD = 3
FIGHTWINDOW_Z_CGSCENE = 4






-- 地图上各层的zorder
FIGHTSCENE_ZORDER = {}
-- 地图分层
FIGHTSCENE_ZORDER.SKY = 5
FIGHTSCENE_ZORDER.BACKBUILDING = 10
FIGHTSCENE_ZORDER.MAINBUILDING = 15
FIGHTSCENE_ZORDER.WALL = 20
FIGHTSCENE_ZORDER.ROAD = 25
FIGHTSCENE_ZORDER.TILEDMAP = 30
FIGHTSCENE_ZORDER.FOREGROUND = 35

-- Tiled上的层级
TILED_ZORDER = {}
TILED_ZORDER.DAMAGE = 10
TILED_ZORDER.SKILLSTATE = 20

--摄像头速度
CAMERA_SPEED_FIND = 0.35
CAMERA_SPEED = 0.3
CAMERA_SPEED_STOP = 1

CAMERA_DIS_X = 0.5

CAMERA_DIS_Y = 0.11
--跑动范围
TABLE_RUNRANGE = {}
for i=1,150 do
	local a = -49 - i
	TABLE_RUNRANGE[i] = a
end

for i=151,300 do
	local a = i - 101
	TABLE_RUNRANGE[i] = a
end

-- 判断两个方向是否同向
function IsTwoDirectionSame(_dir1, _dir2)
	local ret1 = IsDirectionUp(_dir1) and IsDirectionUp(_dir2)
	local ret2 = IsDirectionDown(_dir1) and IsDirectionDown(_dir2)
	local ret3 = IsDirectionLeft(_dir1) and IsDirectionLeft(_dir2)
	local ret4 = IsDirectionRight(_dir1) and IsDirectionRight(_dir2)

	return ret1 or ret2 or ret3 or ret4
end

function IsDirectionUp(_dir)
	return _dir == 1 or _dir == 5 or _dir == 6
end

function IsDirectionDown(_dir)
	return _dir == 2 or _dir == 7 or _dir == 8
end

function IsDirectionLeft(_dir)
	return _dir == 3 or _dir == 5 or _dir == 7
end

function IsDirectionRight(_dir)
	return _dir == 4 or _dir == 6 or _dir == 8
end

-- 根据角度得方向
function GetDirectionByDegree(_deg)
	local dir = 0
	-- define up
	  if _deg == 90 then
	    --cclog("direction UP!!!")
	    dir = FightConfig.DIRECTION_CMD.DUP
	  end

	  -- define down
	  if _deg == -90 then
	    --cclog("direction DOWN!!!")
	    dir = FightConfig.DIRECTION_CMD.DDOWN
	  end 

	  -- define left
	  if _deg == 180 then
	    --cclog("direction LEFT!!!")
	    dir = FightConfig.DIRECTION_CMD.DLEFT
	  end

	  -- define right
	  if _deg == 0 then
	    --cclog("direction RIGHT!!!")
	    dir = FightConfig.DIRECTION_CMD.DRIGHT
	  end

	  -- define up-left
	  if _deg > 90 and _deg < 180 then
	    --cclog("direction UP-LEFT")
	    dir = FightConfig.DIRECTION_CMD.DLEFTUP
	  end

	  -- define up-right
	  if _deg > 0 and _deg < 90 then
	    --cclog("direction UP-RIGHT")
	    dir = FightConfig.DIRECTION_CMD.DRIGHTUP
	  end

	  -- define down-left
	  if _deg < -90 and _deg > -180 then
	    --cclog("direction DOWN-LEFT")
	    dir = FightConfig.DIRECTION_CMD.DLEFTDOWN
	  end

	  -- define down-right
	  if _deg < 0 and _deg > -90 then
	    --cclog("direction DOWn-RIGHT")
	    dir = FightConfig.DIRECTION_CMD.DRIGHTDOWN
	  end

	  return dir
end



function release()
	_G["FightConfig"] = nil
	package.loaded["FightConfig"] = nil
	package.loaded["FightSystem/FightConfig"] = nil
end