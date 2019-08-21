-- Filename: DB_Skill.lua
-- Author: auto-created by XmlToScript tool.
-- Function: it`s auto-created by XmlToScript tool.
--ExcelVBA output tools start flag
module("DB_FashionEquip", package.seeall)
--{时装id,名称,所需物品id,升5高级材料,文字描述说明,图标ID,品质,价格,类型,类别,初始属性条数,初始生命,初始物攻,初始破甲,初始护甲,初始命中,初始闪避,初始暴击,初始韧性,初始攻速,初始移速,初始跳跃,时装坐骑,时装技能1,时装技能2,时装技能3,激活新模型等级1,新模型图标1,新模型时装坐骑1,激活新模型等级2,新模型图标2,新模型时装坐骑2,背景图,进阶需求等级1,进阶属性类型1,进阶属性数值1,进阶需求等级2,进阶属性类型2,进阶属性数值2,进阶需求等级3,进阶属性类型3,进阶属性数值3,客户端基础属性个数,客户端基础属性类型1,客户端基础属性数值1,客户端基础属性类型2,客户端基础属性数值2,客户端基础属性类型3,客户端基础属性数值3,}

FashionEquip = {
	[101] = {101,5900,51001,50998,5905,4100,1,20000,1,2,3,6000,205,-1,-1,-1,-1,-1,195,-1,-1,-1,102,1,2,3,3,4101,103,5,4102,101,686,1,6,203,3,2,195,5,3,202,3,0,6000,1,205,7,195,},
	[102] = {102,632,51002,50998,5906,4103,1,20000,1,1,3,5850,-1,-1,203,-1,-1,-1,202,-1,-1,-1,104,4,5,6,3,4104,105,5,4105,106,687,1,7,203,3,2,202,5,6,195,3,0,5850,3,203,7,202,},
	[103] = {103,5903,51003,50998,5908,4106,1,20000,1,1,3,6150,-1,-1,-1,202,193,-1,-1,-1,-1,-1,121,4,5,6,3,4107,123,5,4108,122,687,1,6,202,3,2,203,5,3,195,3,0,6150,4,202,5,193,},
	[201] = {201,663,51101,50999,5907,4157,1,20000,2,4,3,-1,-1,195,202,-1,-1,203,-1,-1,-1,-1,201,11,12,13,3,4158,202,5,4159,203,687,1,5,205,3,1,202,5,4,193,3,2,195,3,202,6,203,},
	[202] = {202,665,51102,50999,5907,4151,1,20000,2,4,3,-1,-1,202,-1,-1,-1,195,203,-1,-1,-1,211,11,12,13,3,4152,212,5,4153,213,687,1,5,202,3,1,193,5,4,205,3,2,202,6,195,7,203,},
	[203] = {203,664,51103,50999,5907,4154,1,20000,2,4,3,-1,-1,203,195,-1,-1,202,-1,-1,-1,-1,221,11,12,13,3,4155,222,5,4156,223,687,1,7,195,3,0,6000,5,1,205,3,2,203,3,195,6,202,},
	[204] = {204,934,51104,50999,5907,4163,1,20000,2,4,3,-1,202,-1,-1,193,205,-1,-1,-1,-1,-1,231,11,12,13,3,4164,232,5,4165,233,687,1,7,202,3,0,5850,5,3,203,3,1,202,4,193,5,205,},
	[205] = {205,935,51105,50999,5907,4160,1,20000,2,4,3,-1,193,-1,-1,205,202,-1,-1,-1,-1,-1,241,11,12,13,3,4161,242,5,4162,243,687,1,5,193,3,0,6150,5,4,202,3,1,193,4,205,5,202,},
}
local mt = {}
local t_DB = {
["ID"] = 1,["name"] = 2,["Itemid"] = 3,["Itemid_senior"] = 4,["EquipText"] = 5,["IconID"] = 6,["Quality"] = 7,["Price"] = 8,["type"] = 9,["system"] = 10,["InitAttrNum"] = 11,["InitHP"] = 12,["InitPhyAttack"] = 13,["InitArmorPene"] = 14,["InitArmor"] = 15,["InitHit"] = 16,["InitDodge"] = 17,["InitCrit"] = 18,["InitTenacity"] = 19,["InitAttackSpeed"] = 20,["InitMoveSpeed"] = 21,["InitJumpHeight"] = 22,["FashionHorseID1"] = 23,["fashion_skill1"] = 24,["fashion_skill2"] = 25,["fashion_skill3"] = 26,["newlevel1"] = 27,["newIconID1"] = 28,["FashionHorseID2"] = 29,["newlevel2"] = 30,["newIconID2"] = 31,["FashionHorseID3"] = 32,["ResourceId"] = 33,["Advancelevel1"] = 34,["Advancetype1"] = 35,["Advancevalue1"] = 36,["Advancelevel2"] = 37,["Advancetype2"] = 38,["Advancevalue2"] = 39,["Advancelevel3"] = 40,["Advancetype3"] = 41,["Advancevalue3"] = 42,["InitNumber"] = 43,["InitType1"] = 44,["InitValue1"] = 45,["InitType2"] = 46,["InitValue2"] = 47,["InitType3"] = 48,["InitValue3"] = 49,
}
mt.__index =    function (table, key)
                return table[t_DB[key]]
            end

function getDataById(key_id)
    local id_data = FashionEquip[key_id]

    if id_data == nil then
        return nil
    end
    if getmetatable(id_data) ~= nil then
        return id_data
    end
    setmetatable(id_data, mt)
    return id_data
end

function getArrDataByField(fieldName, fieldValue)
    local arrData = {}
    for k, v in pairs(FashionEquip) do
        if getmetatable(v) == nil then
            setmetatable(v, mt)
        end
        if v[fieldName] == fieldValue then
            arrData[#arrData+1] = v
        end
    end

    return arrData
end

function release()
    _G["DB_FashionEquip"] = nil
    package.loaded["DB_FashionEquip"] = nil
    package.loaded["DBSystem/DB_FashionEquip"] = nil
end
--ExcelVBA output tools end flag