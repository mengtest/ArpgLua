-- Name: FubenConfig
-- Func: 副本配置
-- Author: Lvyunlong

module("FubenConfig", package.seeall)

--副本版面类型
-- 1 :起始版面  2 :中间版面   3 :结束版面
BOARD_TYPE = {START_BOARD = 1,_MIDDLE_BOARD = 2,OVER_BOARD = 3}

--副本结束条件
-- 1 ：击杀版面内所有怪物  2 ：击杀特定ID怪物   3：碰撞特定ID道具
FINISHCONTROLLER_TYPE = {KILLALLMONSTER = 1,KILLMONSTER_ID = 2,ITEM_ID = 3}

--跳转方式
--1: 直接链接   2：跳转
CHANGEBOARD_TYPE = {DIRECT = 1,SKIP = 2}

--控制器配置 ID类型
--1：怪物 2：场景道具 3：场景动画
CONTROLLER_TYPEID = {MONSTER = 1,ITEM = 2,ANIMATION = 3}

--怪物配置 品级
--1 普通 2 精英 3 稀有 4 头目
MONSTER_GRADE = {PUTONG = 1,JINGYING = 2,XIYOU = 3,TOUMU = 4} 

--副本可移动版面系数
FUBEN_BOARDMOVE = 0.2

function release()
	_G["FubenConfig"] = nil
	package.loaded["FubenConfig"] = nil
	package.loaded["FightSystem/Fuben/FubenConfig"] = nil
end