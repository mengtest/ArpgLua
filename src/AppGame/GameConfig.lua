-- Name: GameConfig
-- Func: 游戏配置
-- Author: Johny


-----------------------------------出包前确认设置------------------------------------------
--@是否开启版署专用
BANSHU_ENABLED  =  false

--@调试模式设置
-- 0: debug  1: inner  2: real
ENUM_GAMEMODE = {debug = 0, inner = 1, release = 2}
GAME_MODE = ENUM_GAMEMODE.debug

--@版本号
GAME_VERSION = '1.0.11'
--@网关
if BANSHU_ENABLED then
	GATE_URL = "http://120.132.57.123:12012/"
else
	if GAME_MODE == ENUM_GAMEMODE.release then
        GATE_URL = "http://120.132.57.123:12102/"
    else
    	GATE_URL = "http://120.132.57.123:12002/"
    end
end

-- 最大英雄数量
maxHeroCount = 24 -- add by Wangsd 2015-12-8
--------------------------------------------------------------------------------------------
-- 文字相关配置
GAMPE_NAME = "别动我学姐"
GAME_LANGUAGE = "Text_CN"
GAME_DEFAULT_FONT = "Helvetica"


---------------------------------Windows下需要设置------------------------------------------
-- 设备类型
ENUM_DEVICEMODE = {unknown = -1, ipad = 0, ipad_retina = 1, iphone6_plus = 2, iphone6 = 3, iphone5 = 4, iphone = 5, android_3_2 = 6, android_4_3 = 7, android_15_9 = 8
				  ,android_16_9 = 9}
DEVICE_MODE = ENUM_DEVICEMODE.iphone6
--------------------------------------------------------------------------------------------

--
--@分辨率大小
_IOS_IPAD_DEVICE_WIDTH_         = 1024
_IOS_IPAD_DEVICE_HEIGHT_        = 768
_IOS_IPAD_RETINA_WIDTH_         = 2048
_IOS_IPAD_RETINA_HEIGHT_        = 1536
_IOS_IPHONE6PLUS_DEVICE_WIDTH_  = 1920
_IOS_IPHONE6PLUS_DEVICE_HEIGHT_ = 1080
_IOS_IPHONE6_DEVICE_WIDTH_      = 1334
_IOS_IPHONE6_DEVICE_HEIGHT_     = 750
_IOS_IPHONE5_DEVICE_WIDTH_      = 1136
_IOS_IPHONE5_DEVICE_HEIGHT_     = 640
_IOS_IPHONE_DEVICE_WIDTH_       = 960
_IOS_IPHONE_DEVICE_HEIGHT_      = 640
_ANDROID_3_2_DEVICE_WIDTH_		= 960
_ANDROID_3_2_DEVICE_HEIGHT_ 	= 720
_ANDROID_4_3_DEVICE_WIDTH_ 		= 1024
_ANDROID_4_3_DEVICE_HEIGHT_	    = 768
_ANDROID_15_9_DEVICE_WIDTH_ 	= 1280
_ANDROID_15_9_DEVICE_HEIGHT_ 	= 640
_ANDROID_16_9_DEVICE_WIDTH_ 	= 1136
_ANDROID_16_9_DEVICE_HEIGHT_ 	= 640


--@分辨率Table
RESOLUTION_TABLE = {
					[ENUM_DEVICEMODE.ipad] = {w = _IOS_IPAD_DEVICE_WIDTH_, h = _IOS_IPAD_DEVICE_HEIGHT_},
					[ENUM_DEVICEMODE.ipad_retina] = {w = _IOS_IPAD_RETINA_WIDTH_, h = _IOS_IPAD_RETINA_HEIGHT_},
					[ENUM_DEVICEMODE.iphone6_plus] = {w = _IOS_IPHONE6PLUS_DEVICE_WIDTH_, h = _IOS_IPHONE6PLUS_DEVICE_HEIGHT_},
					[ENUM_DEVICEMODE.iphone6] = {w = _IOS_IPHONE6_DEVICE_WIDTH_, h = _IOS_IPHONE6_DEVICE_HEIGHT_},
				    [ENUM_DEVICEMODE.iphone5] = {w = _IOS_IPHONE5_DEVICE_WIDTH_, h = _IOS_IPHONE5_DEVICE_HEIGHT_},
				    [ENUM_DEVICEMODE.iphone] = {w = _IOS_IPHONE_DEVICE_WIDTH_, h = _IOS_IPHONE_DEVICE_HEIGHT_},
				    [ENUM_DEVICEMODE.android_3_2] = {w = _ANDROID_3_2_DEVICE_WIDTH_, h = _ANDROID_3_2_DEVICE_HEIGHT_},
				    [ENUM_DEVICEMODE.android_4_3] = {w = _ANDROID_4_3_DEVICE_WIDTH_, h = _ANDROID_4_3_DEVICE_HEIGHT_},
				    [ENUM_DEVICEMODE.android_15_9] = {w = _ANDROID_15_9_DEVICE_WIDTH_, h = _ANDROID_15_9_DEVICE_HEIGHT_},
				    [ENUM_DEVICEMODE.android_16_9] = {w = _ANDROID_16_9_DEVICE_WIDTH_, h = _ANDROID_16_9_DEVICE_HEIGHT_}
				   }



--@资源设计时分辨率的大小
_RESOURCE_DESIGN_RESOLUTION_W_   =    1140
_RESOURCE_DESIGN_RESOLUTION_H_   =    770