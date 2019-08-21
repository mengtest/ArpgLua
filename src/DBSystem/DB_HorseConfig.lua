-- Filename: DB_Skill.lua
-- Author: auto-created by XmlToScript tool.
-- Function: it`s auto-created by XmlToScript tool.
--ExcelVBA output tools start flag
module("DB_HorseConfig", package.seeall)
--{ID,类型,名字,资源ID,乘骑类型,乘骑增加移动速度,显示层级是否在人物前,影子大小,时装武器序号,绑定后普通攻击技能ID,绑定道具最大使用次数,}

HorseConfig = {
	[1] = {["ID"] = 1,["Type"] = 1,["Name"] = 110,["Horse_ResID"] = {113,0},["Horse_Type"] = 1,["Horse_Speed"] = 2,["Horse_DrawFirst"] = 0,["ShadowSize"] = {4,2.5},["FashionWeaponIndex"] = "\n0",["BindNormalAttack"] = 0,["BindingMaxUseCount"] = 0,},
	[2] = {["ID"] = 2,["Type"] = 1,["Name"] = 110,["Horse_ResID"] = {114,0},["Horse_Type"] = 2,["Horse_Speed"] = 1.5,["Horse_DrawFirst"] = 0,["ShadowSize"] = {4,2.5},["FashionWeaponIndex"] = "\n0",["BindNormalAttack"] = 0,["BindingMaxUseCount"] = 0,},
	[101] = {["ID"] = 101,["Type"] = 1,["Name"] = 110,["Horse_ResID"] = {4060,0},["Horse_Type"] = 1,["Horse_Speed"] = 2.1,["Horse_DrawFirst"] = 0,["ShadowSize"] = {4,2.5},["FashionWeaponIndex"] = "\n0",["BindNormalAttack"] = 0,["BindingMaxUseCount"] = 0,},
	[102] = {["ID"] = 102,["Type"] = 1,["Name"] = 110,["Horse_ResID"] = {4061,0},["Horse_Type"] = 1,["Horse_Speed"] = 1.5,["Horse_DrawFirst"] = 0,["ShadowSize"] = {4,2.5},["FashionWeaponIndex"] = "\n0",["BindNormalAttack"] = 0,["BindingMaxUseCount"] = 0,},
	[103] = {["ID"] = 103,["Type"] = 1,["Name"] = 110,["Horse_ResID"] = {4062,0},["Horse_Type"] = 1,["Horse_Speed"] = 1.8,["Horse_DrawFirst"] = 0,["ShadowSize"] = {4,2.5},["FashionWeaponIndex"] = "\n0",["BindNormalAttack"] = 0,["BindingMaxUseCount"] = 0,},
	[104] = {["ID"] = 104,["Type"] = 1,["Name"] = 110,["Horse_ResID"] = {4063,0},["Horse_Type"] = 1,["Horse_Speed"] = 1.5,["Horse_DrawFirst"] = 0,["ShadowSize"] = {4,2.5},["FashionWeaponIndex"] = "\n0",["BindNormalAttack"] = 0,["BindingMaxUseCount"] = 0,},
	[105] = {["ID"] = 105,["Type"] = 1,["Name"] = 110,["Horse_ResID"] = {4064,0},["Horse_Type"] = 1,["Horse_Speed"] = 1.5,["Horse_DrawFirst"] = 0,["ShadowSize"] = {4,2.5},["FashionWeaponIndex"] = "\n0",["BindNormalAttack"] = 0,["BindingMaxUseCount"] = 0,},
	[106] = {["ID"] = 106,["Type"] = 1,["Name"] = 110,["Horse_ResID"] = {4065,0},["Horse_Type"] = 1,["Horse_Speed"] = 1.5,["Horse_DrawFirst"] = 0,["ShadowSize"] = {4,2.5},["FashionWeaponIndex"] = "\n0",["BindNormalAttack"] = 0,["BindingMaxUseCount"] = 0,},
	[121] = {["ID"] = 121,["Type"] = 1,["Name"] = 110,["Horse_ResID"] = {4067,4066},["Horse_Type"] = 2,["Horse_Speed"] = 3,["Horse_DrawFirst"] = 0,["ShadowSize"] = {4,2.5},["FashionWeaponIndex"] = "\n0",["BindNormalAttack"] = 0,["BindingMaxUseCount"] = 0,},
	[122] = {["ID"] = 122,["Type"] = 1,["Name"] = 110,["Horse_ResID"] = {4069,4068},["Horse_Type"] = 2,["Horse_Speed"] = 3,["Horse_DrawFirst"] = 0,["ShadowSize"] = {4,2.5},["FashionWeaponIndex"] = "\n0",["BindNormalAttack"] = 0,["BindingMaxUseCount"] = 0,},
	[123] = {["ID"] = 123,["Type"] = 1,["Name"] = 110,["Horse_ResID"] = {4071,4070},["Horse_Type"] = 2,["Horse_Speed"] = 3,["Horse_DrawFirst"] = 0,["ShadowSize"] = {4,2.5},["FashionWeaponIndex"] = "\n0",["BindNormalAttack"] = 0,["BindingMaxUseCount"] = 0,},
	[201] = {["ID"] = 201,["Type"] = 2,["Name"] = 110,["Horse_ResID"] = {4065,0},["Horse_Type"] = 1,["Horse_Speed"] = 1.5,["Horse_DrawFirst"] = 0,["ShadowSize"] = {4,2.5},["FashionWeaponIndex"] = "\nallgun.png\nsize: 1627,351\nformat: RGBA4444\nfilter: Linear,Linear\nrepeat: none\ngun1\nrotate: true\nxy: 752, 2\nsize: 347, 123\norig: 347, 123\noffset: 0, 0\nindex: -1",["BindNormalAttack"] = 10001,["BindingMaxUseCount"] = 30,},
	[202] = {["ID"] = 202,["Type"] = 2,["Name"] = 110,["Horse_ResID"] = {4065,0},["Horse_Type"] = 1,["Horse_Speed"] = 1.5,["Horse_DrawFirst"] = 0,["ShadowSize"] = {4,2.5},["FashionWeaponIndex"] = "\nallgun.png\nsize: 1627,351\nformat: RGBA4444\nfilter: Linear,Linear\nrepeat: none\ngun1\nrotate: true\n  xy: 877, 2\n  size: 347, 123\n  orig: 347, 123\n  offset: 0, 0\n  index: -1",["BindNormalAttack"] = 10101,["BindingMaxUseCount"] = 20,},
	[203] = {["ID"] = 203,["Type"] = 2,["Name"] = 110,["Horse_ResID"] = {4065,0},["Horse_Type"] = 1,["Horse_Speed"] = 1.5,["Horse_DrawFirst"] = 0,["ShadowSize"] = {4,2.5},["FashionWeaponIndex"] = "\nallgun.png\nsize: 1627,351\nformat: RGBA4444\nfilter: Linear,Linear\nrepeat: none\ngun1\nrotate: true\n  xy: 1002, 2\n  size: 347, 123\n  orig: 347, 123\n  offset: 0, 0\n  index: -1",["BindNormalAttack"] = 10201,["BindingMaxUseCount"] = 100,},
	[211] = {["ID"] = 211,["Type"] = 2,["Name"] = 110,["Horse_ResID"] = {4065,0},["Horse_Type"] = 1,["Horse_Speed"] = 1.5,["Horse_DrawFirst"] = 0,["ShadowSize"] = {4,2.5},["FashionWeaponIndex"] = "\nallgun.png\nsize: 1627,351\nformat: RGBA4444\nfilter: Linear,Linear\nrepeat: none\ngun1\nrotate: true\n  xy: 2, 2\n  size: 347, 123\n  orig: 347, 123\n  offset: 0, 0\n  index: -1",["BindNormalAttack"] = 10003,["BindingMaxUseCount"] = 30,},
	[212] = {["ID"] = 212,["Type"] = 2,["Name"] = 110,["Horse_ResID"] = {4065,0},["Horse_Type"] = 1,["Horse_Speed"] = 1.5,["Horse_DrawFirst"] = 0,["ShadowSize"] = {4,2.5},["FashionWeaponIndex"] = "\nallgun.png\nsize: 1627,351\nformat: RGBA4444\nfilter: Linear,Linear\nrepeat: none\ngun1\nrotate: true\n  xy: 127, 2\n  size: 347, 123\n  orig: 347, 123\n  offset: 0, 0\n  index: -1",["BindNormalAttack"] = 10103,["BindingMaxUseCount"] = 20,},
	[213] = {["ID"] = 213,["Type"] = 2,["Name"] = 110,["Horse_ResID"] = {4065,0},["Horse_Type"] = 1,["Horse_Speed"] = 1.5,["Horse_DrawFirst"] = 0,["ShadowSize"] = {4,2.5},["FashionWeaponIndex"] = "\nallgun.png\nsize: 1627,351\nformat: RGBA4444\nfilter: Linear,Linear\nrepeat: none\ngun1\nrotate: true\n  xy: 252, 2\n  size: 347, 123\n  orig: 347, 123\n  offset: 0, 0\n  index: -1",["BindNormalAttack"] = 10203,["BindingMaxUseCount"] = 100,},
	[221] = {["ID"] = 221,["Type"] = 2,["Name"] = 110,["Horse_ResID"] = {4065,0},["Horse_Type"] = 1,["Horse_Speed"] = 1.5,["Horse_DrawFirst"] = 0,["ShadowSize"] = {4,2.5},["FashionWeaponIndex"] = "\nallgun.png\nsize: 1627,351\nformat: RGBA4444\nfilter: Linear,Linear\nrepeat: none\ngun1\nrotate: true\n  xy: 377, 2\n  size: 347, 123\n  orig: 347, 123\n  offset: 0, 0\n  index: -1",["BindNormalAttack"] = 10002,["BindingMaxUseCount"] = 30,},
	[222] = {["ID"] = 222,["Type"] = 2,["Name"] = 110,["Horse_ResID"] = {4065,0},["Horse_Type"] = 1,["Horse_Speed"] = 1.5,["Horse_DrawFirst"] = 0,["ShadowSize"] = {4,2.5},["FashionWeaponIndex"] = "\nallgun.png\nsize: 1627,351\nformat: RGBA4444\nfilter: Linear,Linear\nrepeat: none\ngun1\nrotate: true\n  xy: 502, 2\n  size: 347, 123\n  orig: 347, 123\n  offset: 0, 0\n  index: -1",["BindNormalAttack"] = 10102,["BindingMaxUseCount"] = 20,},
	[223] = {["ID"] = 223,["Type"] = 2,["Name"] = 110,["Horse_ResID"] = {4065,0},["Horse_Type"] = 1,["Horse_Speed"] = 1.5,["Horse_DrawFirst"] = 0,["ShadowSize"] = {4,2.5},["FashionWeaponIndex"] = "\nallgun.png\nsize: 1627,351\nformat: RGBA4444\nfilter: Linear,Linear\nrepeat: none\ngun1\nrotate: true\n  xy: 627, 2\n  size: 347, 123\n  orig: 347, 123\n  offset: 0, 0\n  index: -1",["BindNormalAttack"] = 10202,["BindingMaxUseCount"] = 100,},
	[231] = {["ID"] = 231,["Type"] = 2,["Name"] = 110,["Horse_ResID"] = {4065,0},["Horse_Type"] = 1,["Horse_Speed"] = 1.5,["Horse_DrawFirst"] = 0,["ShadowSize"] = {4,2.5},["FashionWeaponIndex"] = "\nallgun.png\nsize: 1627,351\nformat: RGBA4444\nfilter: Linear,Linear\nrepeat: none\ngun1\nrotate: true\n  xy: 1377, 2\n  size: 347, 123\n  orig: 347, 123\n  offset: 0, 0\n  index: -1",["BindNormalAttack"] = 10004,["BindingMaxUseCount"] = 30,},
	[232] = {["ID"] = 232,["Type"] = 2,["Name"] = 110,["Horse_ResID"] = {4065,0},["Horse_Type"] = 1,["Horse_Speed"] = 1.5,["Horse_DrawFirst"] = 0,["ShadowSize"] = {4,2.5},["FashionWeaponIndex"] = "\nallgun.png\nsize: 1627,351\nformat: RGBA4444\nfilter: Linear,Linear\nrepeat: none\ngun1\nrotate: true\n  xy: 1502, 2\n  size: 347, 123\n  orig: 347, 123\n  offset: 0, 0\n  index: -1",["BindNormalAttack"] = 10104,["BindingMaxUseCount"] = 20,},
	[233] = {["ID"] = 233,["Type"] = 2,["Name"] = 110,["Horse_ResID"] = {4065,0},["Horse_Type"] = 1,["Horse_Speed"] = 1.5,["Horse_DrawFirst"] = 0,["ShadowSize"] = {4,2.5},["FashionWeaponIndex"] = "\nallgun.png\nsize: 1627,351\nformat: RGBA4444\nfilter: Linear,Linear\nrepeat: none\ngun1\nrotate: true\n  xy: 1502, 2\n  size: 347, 123\n  orig: 347, 123\n  offset: 0, 0\n  index: -1",["BindNormalAttack"] = 10204,["BindingMaxUseCount"] = 100,},
	[241] = {["ID"] = 241,["Type"] = 2,["Name"] = 110,["Horse_ResID"] = {4065,0},["Horse_Type"] = 1,["Horse_Speed"] = 1.5,["Horse_DrawFirst"] = 0,["ShadowSize"] = {4,2.5},["FashionWeaponIndex"] = "\nallgun.png\nsize: 1627,351\nformat: RGBA4444\nfilter: Linear,Linear\nrepeat: none\ngun1\nrotate: true\n  xy: 1127, 2\n  size: 347, 123\n  orig: 347, 123\n  offset: 0, 0\n  index: -1",["BindNormalAttack"] = 10005,["BindingMaxUseCount"] = 30,},
	[242] = {["ID"] = 242,["Type"] = 2,["Name"] = 110,["Horse_ResID"] = {4065,0},["Horse_Type"] = 1,["Horse_Speed"] = 1.5,["Horse_DrawFirst"] = 0,["ShadowSize"] = {4,2.5},["FashionWeaponIndex"] = "\nallgun.png\nsize: 1627,351\nformat: RGBA4444\nfilter: Linear,Linear\nrepeat: none\ngun1\nrotate: true\n  xy: 1252, 2\n  size: 347, 123\n  orig: 347, 123\n  offset: 0, 0\n  index: -1",["BindNormalAttack"] = 10105,["BindingMaxUseCount"] = 20,},
	[243] = {["ID"] = 243,["Type"] = 2,["Name"] = 110,["Horse_ResID"] = {4065,0},["Horse_Type"] = 1,["Horse_Speed"] = 1.5,["Horse_DrawFirst"] = 0,["ShadowSize"] = {4,2.5},["FashionWeaponIndex"] = "\nallgun.png\nsize: 1627,351\nformat: RGBA4444\nfilter: Linear,Linear\nrepeat: none\ngun1\nrotate: true\n  xy: 1252, 2\n  size: 347, 123\n  orig: 347, 123\n  offset: 0, 0\n  index: -1",["BindNormalAttack"] = 10205,["BindingMaxUseCount"] = 100,},
}

function getDataById(key_id)
    local id_data = HorseConfig[key_id]

    return id_data
end

function getArrDataByField(fieldName, fieldValue)
    local arrData = {}
    for k, v in pairs(HorseConfig) do
        if v[fieldName] == fieldValue then
            arrData[#arrData+1] = v
        end
    end

    return arrData
end

function release()
    _G["DB_HorseConfig"] = nil
    package.loaded["DB_HorseConfig"] = nil
    package.loaded["DBSystem/DB_HorseConfig"] = nil
end
--ExcelVBA output tools end flag