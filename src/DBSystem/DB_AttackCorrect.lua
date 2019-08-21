-- Filename: DB_Skill.lua
-- Author: auto-created by XmlToScript tool.
-- Function: it`s auto-created by XmlToScript tool.
--ExcelVBA output tools start flag
module("DB_AttackCorrect", package.seeall)
--{ID,进阶数,英雄组,进阶数,格斗（被攻击）,功夫（被攻击）,柔术（被攻击）,格怪（被攻击）,攻怪（被攻击）,柔怪（被攻击）,普通4（被攻击）,普通5（被攻击）,}

AttackCorrect = {
	[1] = {["ID"] = 1,["Group_Advance"] = "Gedou_0",["GroupID"] = 1,["Level"] = "0",["Group_Hit01"] = 1,["Group_Hit02"] = 1.28,["Group_Hit03"] = .72,["Group_Hit04"] = .4,["Group_Hit05"] = 5.12,["Group_Hit06"] = .3,["Group_Hit07"] = 1,["Group_Hit08"] = 1,},
	[2] = {["ID"] = 2,["Group_Advance"] = "Gedou_1",["GroupID"] = 1,["Level"] = "1",["Group_Hit01"] = 1.04,["Group_Hit02"] = 1.32,["Group_Hit03"] = .76,["Group_Hit04"] = .42,["Group_Hit05"] = 5.28,["Group_Hit06"] = .32,["Group_Hit07"] = 1,["Group_Hit08"] = 1,},
	[3] = {["ID"] = 3,["Group_Advance"] = "Gedou_2",["GroupID"] = 1,["Level"] = "2",["Group_Hit01"] = 1.08,["Group_Hit02"] = 1.36,["Group_Hit03"] = .8,["Group_Hit04"] = .44,["Group_Hit05"] = 5.44,["Group_Hit06"] = .34,["Group_Hit07"] = 1,["Group_Hit08"] = 1,},
	[4] = {["ID"] = 4,["Group_Advance"] = "Gedou_3",["GroupID"] = 1,["Level"] = "3",["Group_Hit01"] = 1.12,["Group_Hit02"] = 1.4,["Group_Hit03"] = .84,["Group_Hit04"] = .46,["Group_Hit05"] = 5.6,["Group_Hit06"] = .36,["Group_Hit07"] = 1,["Group_Hit08"] = 1,},
	[5] = {["ID"] = 5,["Group_Advance"] = "Gedou_4",["GroupID"] = 1,["Level"] = "4",["Group_Hit01"] = 1.16,["Group_Hit02"] = 1.44,["Group_Hit03"] = .88,["Group_Hit04"] = .48,["Group_Hit05"] = 5.76,["Group_Hit06"] = .38,["Group_Hit07"] = 1,["Group_Hit08"] = 1,},
	[6] = {["ID"] = 6,["Group_Advance"] = "Gedou_5",["GroupID"] = 1,["Level"] = "5",["Group_Hit01"] = 1.2,["Group_Hit02"] = 1.48,["Group_Hit03"] = .92,["Group_Hit04"] = .5,["Group_Hit05"] = 5.92,["Group_Hit06"] = .4,["Group_Hit07"] = 1,["Group_Hit08"] = 1,},
	[7] = {["ID"] = 7,["Group_Advance"] = "Gedou_6",["GroupID"] = 1,["Level"] = "6",["Group_Hit01"] = 1.24,["Group_Hit02"] = 1.52,["Group_Hit03"] = .96,["Group_Hit04"] = .52,["Group_Hit05"] = 6.08,["Group_Hit06"] = .42,["Group_Hit07"] = 1,["Group_Hit08"] = 1,},
	[8] = {["ID"] = 8,["Group_Advance"] = "Gedou_7",["GroupID"] = 1,["Level"] = "7",["Group_Hit01"] = 1.28,["Group_Hit02"] = 1.56,["Group_Hit03"] = 1,["Group_Hit04"] = .54,["Group_Hit05"] = 6.24,["Group_Hit06"] = .44,["Group_Hit07"] = 1,["Group_Hit08"] = 1,},
	[9] = {["ID"] = 9,["Group_Advance"] = "Gongfu_0",["GroupID"] = 2,["Level"] = "0",["Group_Hit01"] = .72,["Group_Hit02"] = 1,["Group_Hit03"] = 1.28,["Group_Hit04"] = .3,["Group_Hit05"] = .4,["Group_Hit06"] = 5.12,["Group_Hit07"] = 1,["Group_Hit08"] = 1,},
	[10] = {["ID"] = 10,["Group_Advance"] = "Gongfu_1",["GroupID"] = 2,["Level"] = "1",["Group_Hit01"] = .76,["Group_Hit02"] = 1.04,["Group_Hit03"] = 1.32,["Group_Hit04"] = .32,["Group_Hit05"] = .42,["Group_Hit06"] = 5.28,["Group_Hit07"] = 1,["Group_Hit08"] = 1,},
	[11] = {["ID"] = 11,["Group_Advance"] = "Gongfu_2",["GroupID"] = 2,["Level"] = "2",["Group_Hit01"] = .8,["Group_Hit02"] = 1.08,["Group_Hit03"] = 1.36,["Group_Hit04"] = .34,["Group_Hit05"] = .44,["Group_Hit06"] = 5.44,["Group_Hit07"] = 1,["Group_Hit08"] = 1,},
	[12] = {["ID"] = 12,["Group_Advance"] = "Gongfu_3",["GroupID"] = 2,["Level"] = "3",["Group_Hit01"] = .84,["Group_Hit02"] = 1.12,["Group_Hit03"] = 1.4,["Group_Hit04"] = .36,["Group_Hit05"] = .46,["Group_Hit06"] = 5.6,["Group_Hit07"] = 1,["Group_Hit08"] = 1,},
	[13] = {["ID"] = 13,["Group_Advance"] = "Gongfu_4",["GroupID"] = 2,["Level"] = "4",["Group_Hit01"] = .88,["Group_Hit02"] = 1.16,["Group_Hit03"] = 1.44,["Group_Hit04"] = .38,["Group_Hit05"] = .48,["Group_Hit06"] = 5.76,["Group_Hit07"] = 1,["Group_Hit08"] = 1,},
	[14] = {["ID"] = 14,["Group_Advance"] = "Gongfu_5",["GroupID"] = 2,["Level"] = "5",["Group_Hit01"] = .92,["Group_Hit02"] = 1.2,["Group_Hit03"] = 1.48,["Group_Hit04"] = .4,["Group_Hit05"] = .5,["Group_Hit06"] = 5.92,["Group_Hit07"] = 1,["Group_Hit08"] = 1,},
	[15] = {["ID"] = 15,["Group_Advance"] = "Gongfu_6",["GroupID"] = 2,["Level"] = "6",["Group_Hit01"] = .96,["Group_Hit02"] = 1.24,["Group_Hit03"] = 1.52,["Group_Hit04"] = .42,["Group_Hit05"] = .52,["Group_Hit06"] = 6.08,["Group_Hit07"] = 1,["Group_Hit08"] = 1,},
	[16] = {["ID"] = 16,["Group_Advance"] = "Gongfu_7",["GroupID"] = 2,["Level"] = "7",["Group_Hit01"] = 1,["Group_Hit02"] = 1.28,["Group_Hit03"] = 1.56,["Group_Hit04"] = .44,["Group_Hit05"] = .54,["Group_Hit06"] = 6.24,["Group_Hit07"] = 1,["Group_Hit08"] = 1,},
	[17] = {["ID"] = 17,["Group_Advance"] = "Roushu_0",["GroupID"] = 3,["Level"] = "0",["Group_Hit01"] = 1.28,["Group_Hit02"] = .72,["Group_Hit03"] = 1,["Group_Hit04"] = 5.12,["Group_Hit05"] = .3,["Group_Hit06"] = .4,["Group_Hit07"] = 1,["Group_Hit08"] = 1,},
	[18] = {["ID"] = 18,["Group_Advance"] = "Roushu_1",["GroupID"] = 3,["Level"] = "1",["Group_Hit01"] = 1.32,["Group_Hit02"] = .76,["Group_Hit03"] = 1.04,["Group_Hit04"] = 5.28,["Group_Hit05"] = .32,["Group_Hit06"] = .42,["Group_Hit07"] = 1,["Group_Hit08"] = 1,},
	[19] = {["ID"] = 19,["Group_Advance"] = "Roushu_2",["GroupID"] = 3,["Level"] = "2",["Group_Hit01"] = 1.36,["Group_Hit02"] = .8,["Group_Hit03"] = 1.08,["Group_Hit04"] = 5.44,["Group_Hit05"] = .34,["Group_Hit06"] = .44,["Group_Hit07"] = 1,["Group_Hit08"] = 1,},
	[20] = {["ID"] = 20,["Group_Advance"] = "Roushu_3",["GroupID"] = 3,["Level"] = "3",["Group_Hit01"] = 1.4,["Group_Hit02"] = .84,["Group_Hit03"] = 1.12,["Group_Hit04"] = 5.6,["Group_Hit05"] = .36,["Group_Hit06"] = .46,["Group_Hit07"] = 1,["Group_Hit08"] = 1,},
	[21] = {["ID"] = 21,["Group_Advance"] = "Roushu_4",["GroupID"] = 3,["Level"] = "4",["Group_Hit01"] = 1.44,["Group_Hit02"] = .88,["Group_Hit03"] = 1.16,["Group_Hit04"] = 5.76,["Group_Hit05"] = .38,["Group_Hit06"] = .48,["Group_Hit07"] = 1,["Group_Hit08"] = 1,},
	[22] = {["ID"] = 22,["Group_Advance"] = "Roushu_5",["GroupID"] = 3,["Level"] = "5",["Group_Hit01"] = 1.48,["Group_Hit02"] = .92,["Group_Hit03"] = 1.2,["Group_Hit04"] = 5.92,["Group_Hit05"] = .4,["Group_Hit06"] = .5,["Group_Hit07"] = 1,["Group_Hit08"] = 1,},
	[23] = {["ID"] = 23,["Group_Advance"] = "Roushu_6",["GroupID"] = 3,["Level"] = "6",["Group_Hit01"] = 1.52,["Group_Hit02"] = .96,["Group_Hit03"] = 1.24,["Group_Hit04"] = 6.08,["Group_Hit05"] = .42,["Group_Hit06"] = .52,["Group_Hit07"] = 1,["Group_Hit08"] = 1,},
	[24] = {["ID"] = 24,["Group_Advance"] = "Roushu_7",["GroupID"] = 3,["Level"] = "7",["Group_Hit01"] = 1.56,["Group_Hit02"] = 1,["Group_Hit03"] = 1.28,["Group_Hit04"] = 6.24,["Group_Hit05"] = .44,["Group_Hit06"] = .54,["Group_Hit07"] = 1,["Group_Hit08"] = 1,},
	[25] = {["ID"] = 25,["Group_Advance"] = "MGedou_0",["GroupID"] = 4,["Level"] = "0",["Group_Hit01"] = 2,["Group_Hit02"] = 2.56,["Group_Hit03"] = .72,["Group_Hit04"] = 1,["Group_Hit05"] = 1.28,["Group_Hit06"] = .72,["Group_Hit07"] = 1,["Group_Hit08"] = 1,},
	[26] = {["ID"] = 26,["Group_Advance"] = "MGongfu_0",["GroupID"] = 5,["Level"] = "0",["Group_Hit01"] = .72,["Group_Hit02"] = 2,["Group_Hit03"] = 2.56,["Group_Hit04"] = .72,["Group_Hit05"] = 1,["Group_Hit06"] = 1.28,["Group_Hit07"] = 1,["Group_Hit08"] = 1,},
	[24] = {["ID"] = 24,["Group_Advance"] = "MRoushu_0",["GroupID"] = 6,["Level"] = "0",["Group_Hit01"] = 2.56,["Group_Hit02"] = .72,["Group_Hit03"] = 2,["Group_Hit04"] = 1.28,["Group_Hit05"] = .72,["Group_Hit06"] = 1,["Group_Hit07"] = 1,["Group_Hit08"] = 1,},
}

function getDataById(key_id)
    local id_data = AttackCorrect[key_id]

    return id_data
end

function getArrDataByField(fieldName, fieldValue)
    local arrData = {}
    for k, v in pairs(AttackCorrect) do
        if v[fieldName] == fieldValue then
            arrData[#arrData+1] = v
        end
    end

    return arrData
end

function release()
    _G["DB_AttackCorrect"] = nil
    package.loaded["DB_AttackCorrect"] = nil
    package.loaded["DBSystem/DB_AttackCorrect"] = nil
end
--ExcelVBA output tools end flag