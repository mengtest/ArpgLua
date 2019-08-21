-- Filename: DB_Skill.lua
-- Author: auto-created by XmlToScript tool.
-- Function: it`s auto-created by XmlToScript tool.
--ExcelVBA output tools start flag
module("DB_pvprewards3v3", package.seeall)
--{等级,空,描述,分数下限,分数上限,制霸币,奖励1,奖励2,K值,}

pvprewards3v3 = {
	[1] = {["ID"] = 1,["Name"] = 4701,["Minscore"] = 600,["Maxscore"] = 799,["Reward1"] = {11,0,200},["Reward2"] = {3,0,20},["Reward3"] = {2,0,10000},["MarkK"] = 60,},
	[2] = {["ID"] = 2,["Name"] = 4702,["Minscore"] = 800,["Maxscore"] = 999,["Reward1"] = {11,0,205},["Reward2"] = {3,0,30},["Reward3"] = {2,0,11000},["MarkK"] = 50,},
	[3] = {["ID"] = 3,["Name"] = 4703,["Minscore"] = 1000,["Maxscore"] = 1199,["Reward1"] = {11,0,210},["Reward2"] = {3,0,40},["Reward3"] = {2,0,12000},["MarkK"] = 40,},
	[4] = {["ID"] = 4,["Name"] = 4704,["Minscore"] = 1200,["Maxscore"] = 1299,["Reward1"] = {11,0,220},["Reward2"] = {3,0,60},["Reward3"] = {2,0,14000},["MarkK"] = 30,},
	[5] = {["ID"] = 5,["Name"] = 4705,["Minscore"] = 1300,["Maxscore"] = 1399,["Reward1"] = {11,0,225},["Reward2"] = {3,0,70},["Reward3"] = {2,0,15000},["MarkK"] = 30,},
	[6] = {["ID"] = 6,["Name"] = 4706,["Minscore"] = 1400,["Maxscore"] = 1499,["Reward1"] = {11,0,230},["Reward2"] = {3,0,80},["Reward3"] = {2,0,16000},["MarkK"] = 30,},
	[7] = {["ID"] = 7,["Name"] = 4707,["Minscore"] = 1500,["Maxscore"] = 1599,["Reward1"] = {11,0,240},["Reward2"] = {3,0,100},["Reward3"] = {2,0,18000},["MarkK"] = 24,},
	[8] = {["ID"] = 8,["Name"] = 4708,["Minscore"] = 1600,["Maxscore"] = 1699,["Reward1"] = {11,0,245},["Reward2"] = {3,0,110},["Reward3"] = {2,0,19000},["MarkK"] = 24,},
	[9] = {["ID"] = 9,["Name"] = 4709,["Minscore"] = 1700,["Maxscore"] = 1799,["Reward1"] = {11,0,250},["Reward2"] = {3,0,120},["Reward3"] = {2,0,20000},["MarkK"] = 24,},
	[10] = {["ID"] = 10,["Name"] = 4710,["Minscore"] = 1800,["Maxscore"] = 1899,["Reward1"] = {11,0,260},["Reward2"] = {3,0,140},["Reward3"] = {2,0,22000},["MarkK"] = 20,},
	[11] = {["ID"] = 11,["Name"] = 4711,["Minscore"] = 1900,["Maxscore"] = 1999,["Reward1"] = {11,0,265},["Reward2"] = {3,0,150},["Reward3"] = {2,0,23000},["MarkK"] = 20,},
	[12] = {["ID"] = 12,["Name"] = 4712,["Minscore"] = 2000,["Maxscore"] = 2099,["Reward1"] = {11,0,270},["Reward2"] = {3,0,160},["Reward3"] = {2,0,24000},["MarkK"] = 20,},
	[13] = {["ID"] = 13,["Name"] = 4713,["Minscore"] = 2100,["Maxscore"] = 2199,["Reward1"] = {11,0,280},["Reward2"] = {3,0,180},["Reward3"] = {2,0,26000},["MarkK"] = 16,},
	[14] = {["ID"] = 14,["Name"] = 4714,["Minscore"] = 2200,["Maxscore"] = 2299,["Reward1"] = {11,0,285},["Reward2"] = {3,0,190},["Reward3"] = {2,0,27000},["MarkK"] = 16,},
	[15] = {["ID"] = 15,["Name"] = 4715,["Minscore"] = 2300,["Maxscore"] = 2399,["Reward1"] = {11,0,290},["Reward2"] = {3,0,200},["Reward3"] = {2,0,28000},["MarkK"] = 16,},
	[16] = {["ID"] = 16,["Name"] = 4716,["Minscore"] = 2400,["Maxscore"] = 2599,["Reward1"] = {11,0,300},["Reward2"] = {3,0,220},["Reward3"] = {2,0,30000},["MarkK"] = 12,},
	[17] = {["ID"] = 17,["Name"] = 4717,["Minscore"] = 2600,["Maxscore"] = 99999,["Reward1"] = {11,0,320},["Reward2"] = {3,0,240},["Reward3"] = {2,0,32000},["MarkK"] = 12,},
}

function getDataById(key_id)
    local id_data = pvprewards3v3[key_id]

    return id_data
end

function getArrDataByField(fieldName, fieldValue)
    local arrData = {}
    for k, v in pairs(pvprewards3v3) do
        if v[fieldName] == fieldValue then
            arrData[#arrData+1] = v
        end
    end

    return arrData
end

function release()
    _G["DB_pvprewards3v3"] = nil
    package.loaded["DB_pvprewards3v3"] = nil
    package.loaded["DBSystem/DB_pvprewards3v3"] = nil
end
--ExcelVBA output tools end flag