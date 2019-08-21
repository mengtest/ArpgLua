-- Filename: DB_Skill.lua
-- Author: auto-created by XmlToScript tool.
-- Function: it`s auto-created by XmlToScript tool.
--ExcelVBA output tools start flag
module("DB_pvprewards1v1", package.seeall)
--{等级,空,描述,分数下限,分数上限,奖励1,奖励2,奖励3,K值,}

pvprewards1v1 = {
	[1] = {["ID"] = 1,["Name"] = 4701,["Minscore"] = 600,["Maxscore"] = 799,["Reward1"] = {3,0,100},["Reward2"] = {2,0,50000},["Reward3"] = {0,0,0},["MarkK"] = 120,},
	[2] = {["ID"] = 2,["Name"] = 4702,["Minscore"] = 800,["Maxscore"] = 999,["Reward1"] = {3,0,130},["Reward2"] = {2,0,55000},["Reward3"] = {0,0,0},["MarkK"] = 100,},
	[3] = {["ID"] = 3,["Name"] = 4703,["Minscore"] = 1000,["Maxscore"] = 1199,["Reward1"] = {3,0,160},["Reward2"] = {2,0,60000},["Reward3"] = {0,0,0},["MarkK"] = 80,},
	[4] = {["ID"] = 4,["Name"] = 4704,["Minscore"] = 1200,["Maxscore"] = 1299,["Reward1"] = {3,0,200},["Reward2"] = {2,0,70000},["Reward3"] = {0,0,0},["MarkK"] = 60,},
	[5] = {["ID"] = 5,["Name"] = 4705,["Minscore"] = 1300,["Maxscore"] = 1399,["Reward1"] = {3,0,250},["Reward2"] = {2,0,75000},["Reward3"] = {0,0,0},["MarkK"] = 60,},
	[6] = {["ID"] = 6,["Name"] = 4706,["Minscore"] = 1400,["Maxscore"] = 1499,["Reward1"] = {3,0,300},["Reward2"] = {2,0,80000},["Reward3"] = {0,0,0},["MarkK"] = 50,},
	[7] = {["ID"] = 7,["Name"] = 4707,["Minscore"] = 1500,["Maxscore"] = 1599,["Reward1"] = {3,0,350},["Reward2"] = {2,0,90000},["Reward3"] = {0,0,0},["MarkK"] = 40,},
	[8] = {["ID"] = 8,["Name"] = 4708,["Minscore"] = 1600,["Maxscore"] = 1699,["Reward1"] = {3,0,400},["Reward2"] = {2,0,95000},["Reward3"] = {0,0,0},["MarkK"] = 40,},
	[9] = {["ID"] = 9,["Name"] = 4709,["Minscore"] = 1700,["Maxscore"] = 1799,["Reward1"] = {3,0,450},["Reward2"] = {2,0,100000},["Reward3"] = {0,0,0},["MarkK"] = 40,},
	[10] = {["ID"] = 10,["Name"] = 4710,["Minscore"] = 1800,["Maxscore"] = 1899,["Reward1"] = {3,0,500},["Reward2"] = {2,0,110000},["Reward3"] = {0,0,0},["MarkK"] = 30,},
	[11] = {["ID"] = 11,["Name"] = 4711,["Minscore"] = 1900,["Maxscore"] = 1999,["Reward1"] = {3,0,600},["Reward2"] = {2,0,115000},["Reward3"] = {0,0,0},["MarkK"] = 30,},
	[12] = {["ID"] = 12,["Name"] = 4712,["Minscore"] = 2000,["Maxscore"] = 2099,["Reward1"] = {3,0,700},["Reward2"] = {2,0,120000},["Reward3"] = {0,0,0},["MarkK"] = 30,},
	[13] = {["ID"] = 13,["Name"] = 4713,["Minscore"] = 2100,["Maxscore"] = 2199,["Reward1"] = {3,0,800},["Reward2"] = {2,0,130000},["Reward3"] = {0,0,0},["MarkK"] = 20,},
	[14] = {["ID"] = 14,["Name"] = 4714,["Minscore"] = 2200,["Maxscore"] = 2299,["Reward1"] = {3,0,900},["Reward2"] = {2,0,135000},["Reward3"] = {0,0,0},["MarkK"] = 20,},
	[15] = {["ID"] = 15,["Name"] = 4715,["Minscore"] = 2300,["Maxscore"] = 2399,["Reward1"] = {3,0,1000},["Reward2"] = {2,0,140000},["Reward3"] = {0,0,0},["MarkK"] = 20,},
	[16] = {["ID"] = 16,["Name"] = 4716,["Minscore"] = 2400,["Maxscore"] = 2599,["Reward1"] = {3,0,1100},["Reward2"] = {2,0,150000},["Reward3"] = {0,0,0},["MarkK"] = 12,},
	[17] = {["ID"] = 17,["Name"] = 4717,["Minscore"] = 2600,["Maxscore"] = 99999,["Reward1"] = {3,0,1200},["Reward2"] = {2,0,160000},["Reward3"] = {0,0,0},["MarkK"] = 12,},
}

function getDataById(key_id)
    local id_data = pvprewards1v1[key_id]

    return id_data
end

function getArrDataByField(fieldName, fieldValue)
    local arrData = {}
    for k, v in pairs(pvprewards1v1) do
        if v[fieldName] == fieldValue then
            arrData[#arrData+1] = v
        end
    end

    return arrData
end

function release()
    _G["DB_pvprewards1v1"] = nil
    package.loaded["DB_pvprewards1v1"] = nil
    package.loaded["DBSystem/DB_pvprewards1v1"] = nil
end
--ExcelVBA output tools end flag