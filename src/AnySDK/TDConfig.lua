-- Name: TDConfig
-- Func: talkingdata常量表
-- Author: Johny

module("TDConfig", package.seeall)

--是否开启
ENABLE_TD           =  GAME_MODE == ENUM_GAMEMODE.release

--app key和渠道ID
APPKEY				= "5D67BC38E9E3621C4819B8AD6F81361C"


--账号类型
kAccountAnonymous  		=  0    --匿名帐户
kAccountRegistered 		=  1    --显性注册帐户
kAccountSinaWeibo  		=  2    --新浪微博
kAccountQQ 		   		=  3    --QQ 帐户
kAccountTencentWeibo    =  4    --腾讯微博
kAccountND91   			=  5    --91 帐户
kAccountType1  			=  6	--预留1
kAccountType2  			=  7	--预留2
kAccountType3  			=  8	--预留3
kAccountType4  			=  9 	--预留4
kAccountType5  			= 10	--预留5
kAccountType6 			= 11    --预留6
kAccountType7  			= 12	--预留7
kAccountType8  			= 13	--预留8
kAccountType9  			= 14 	--预留9
kAccountType10 			= 15	--预留10
--性别
kGenderUnknown 			= 0     --未知
kGenderMale 			= 1     --男
kGenderFemale 			= 2 	--女
