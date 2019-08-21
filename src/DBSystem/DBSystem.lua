-- Name: DBSystem
-- Func: 数据系统
-- Author: Johny
-- 职能：
--		负责读取appbundle中的数据表（lua形式）
--		负责读取sandbox中的数据表(lua形式)
--		负责读写sandbox中配置表(lua形式)



DBSystem = {}
DBSystem.mType = "DBSYSTEM"

-- 开机调用，加载第一批必须加载的DB
function DBSystem:Init()
    cclog("=====DBSystem:Init=====1")

    require("DBSystem/DB_ResourceList")
    require("DBSystem/DB_MusicConfig")
    require("DBSystem/DB_Text")
    
    cclog("=====DBSystem:Init=====2")
end

-- 第二次加载其余DB,在GUIWidgetPool中加载
function DBSystem:init2_1()
    require("DBSystem/DB_MapUIConfigEasy")
    require("DBSystem/DB_MapUIConfigNormal")
    -- require("DBSystem/DB_MapUIConfigHard")
    require("DBSystem/DB_MapUIConfig")
    require("DBSystem/DB_MapConfig")
    require("DBSystem/DB_BoardsConfig")
    require("DBSystem/DB_ControllerConfig")
end
-- 第二次加载其余DB,在GUIWidgetPool中加载
function DBSystem:init2_2()
    require("DBSystem/DB_MonsterConfig")
    require("DBSystem/DB_AIConfig")
end
-- 第二次加载其余DB,在GUIWidgetPool中加载
function DBSystem:init2_3()
    require("DBSystem/DB_SceneAnimationConfig")
    require("DBSystem/DB_CGStageConfig")
    require("DBSystem/DB_SchoolConfig")
end

-- 第二次加载其余DB,在GUIWidgetPool中加载
function DBSystem:init2_4()
    require("DBSystem/DB_SkillEssence")
    require("DBSystem/DB_SkillProcess") 
    require("DBSystem/DB_Weapon_Skill")
end

-- 第二次加载其余DB,在GUIWidgetPool中加载
function DBSystem:init2_5()
    require("DBSystem/DB_SkillState")
    require("DBSystem/DB_SkillEffect")
    require("DBSystem/DB_SkillSubObject")
    require("DBSystem/DB_SkillDisplay")
end

-- 第二次加载其余DB,在GUIWidgetPool中加载
function DBSystem:init2_6()
    require("DBSystem/DB_PlayerEXP")
    require("DBSystem/DB_Diamond")
    require("DBSystem/DB_Refresh")
    require("DBSystem/DB_Activity")
    require("DBSystem/DB_TaskUsual")
    require("DBSystem/DB_ItemConfig")
    require("DBSystem/DB_HeroConfig")
    require("DBSystem/DB_EquipmentConfig")
    require("DBSystem/DB_HorseConfig")
    require("DBSystem/DB_DateHero")
    require("DBSystem/DB_DateCard")
    require("DBSystem/DB_DateCardPK")
    require("DBSystem/DB_DateRound")
    require("DBSystem/DB_VipBag")
    require("DBSystem/DB_AttackCorrect")
    require("DBSystem/DB_TaskConfig")
    require("DBSystem/DB_SpecialMap")
    require("DBSystem/DB_GuideCGSpeak")
    require("DBSystem/DB_HeroEXP")
    require("DBSystem/DB_PlayerLevelFunction")
    require("DBSystem/DB_DateGift")
    require("DBSystem/DB_ArtifactConfig")
    require("DBSystem/DB_AfterClass")
    require("DBSystem/DB_PlayerIcon")
    require("DBSystem/DB_pvprewards1v1")
    require("DBSystem/DB_pvprewards3v3")
    require("DBSystem/DB_rankrewards3v3")
    require("DBSystem/DB_EventTotal")
    require("DBSystem/DB_EventSpecific")
    require("DBSystem/DB_EventObject")
    require("DBSystem/DB_SpeakText")
    require("DBSystem/DB_CityConfig")
    require("DBSystem/DB_Notice")
    require("DBSystem/DB_GuildIcon")
    require("DBSystem/DB_Talent")
    require("DBSystem/DB_PlayerTitle")
    require("DBSystem/DB_CommandText")
    require("DBSystem/DB_LevelRewards")
    require("DBSystem/DB_FashionEquip")
    require("DBSystem/DB_FashionTrain")
    require("DBSystem/DB_HeroWeapon")
    require("DBSystem/DB_DiamondStar")
    require("DBSystem/DB_NewLevelRewards")
end

---------------------------------------------------------------


function DBSystem:Tick()

end

function DBSystem:Release()
	_G["DBSystem"] = nil
	package.loaded["DBSystem"] = nil
	package.loaded["DBSystem/DBSystem"] = nil
end

function DBSystem:onEventHandler(event)
  
end

--[[
	Save To SandBox
]]
function DBSystem:Save_String_ToSandBox(_key, _value)
	cc.UserDefault:getInstance():setStringForKey(_key, _value)
end

function DBSystem:Save_Boolean_ToSandBox(_key, _value)
	cc.UserDefault:getInstance():setBoolForKey(_key, _value)
end

function DBSystem:Save_Integer_ToSandBox(_key, _value)
	cc.UserDefault:getInstance():setIntegerForKey(_key, _value)
end

function DBSystem:Save_Float_ToSandBox(_key, _value)
	cc.UserDefault:getInstance():setFloatForKey(_key, _value)
end

function DBSystem:Save_Double_ToSandBox(_key, _value)
	cc.UserDefault:getInstance():setDoubleForKey(_key, _value)
end

function DBSystem:flush()
   cc.UserDefault:getInstance():flush()
end


--[[
	Get From SandBox
]]
function DBSystem:Get_String_FromSandBox(_key)
	return cc.UserDefault:getInstance():getStringForKey(_key)
end

function DBSystem:Get_Boolean_FromSandBox(_key)
	return cc.UserDefault:getInstance():getBoolForKey(_key)
end

function DBSystem:Get_Integer_FromSandBox(_key)
	return cc.UserDefault:getInstance():getIntegerForKey(_key)
end

function DBSystem:Get_Float_FromSandBox(_key)
	return cc.UserDefault:getInstance():getFloatForKey(_key)
end

function DBSystem:Get_Double_FromSandBox(_key)
	return cc.UserDefault:getInstance():getDoubleForKey(_key)
end