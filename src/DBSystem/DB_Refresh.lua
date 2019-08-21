-- Filename: DB_Skill.lua
-- Author: auto-created by XmlToScript tool.
-- Function: it`s auto-created by XmlToScript tool.
--ExcelVBA output tools start flag
module("DB_Refresh", package.seeall)
--{属性类型,区间1,颜色ID1,区间2,颜色ID2,区间3,颜色ID3,区间4,颜色ID4,区间5,颜色ID5,}

Refresh = {
	[0] = {["ID"] = 0,["area1"] = "300,300",["color1"] = 1,["area2"] = "230,250",["color2"] = 2,["area3"] = "170,200",["color3"] = 3,["area4"] = "120,140",["color4"] = 4,["area5"] = "30,90",["color5"] = 5,},
	[1] = {["ID"] = 1,["area1"] = "40,40",["color1"] = 1,["area2"] = "31,34",["color2"] = 2,["area3"] = "23,27",["color3"] = 3,["area4"] = "16,19",["color4"] = 4,["area5"] = "4,12",["color5"] = 5,},
	[2] = {["ID"] = 2,["area1"] = "40,40",["color1"] = 1,["area2"] = "31,34",["color2"] = 2,["area3"] = "23,27",["color3"] = 3,["area4"] = "16,19",["color4"] = 4,["area5"] = "4,12",["color5"] = 5,},
	[3] = {["ID"] = 3,["area1"] = "40,40",["color1"] = 1,["area2"] = "31,34",["color2"] = 2,["area3"] = "23,27",["color3"] = 3,["area4"] = "16,19",["color4"] = 4,["area5"] = "4,12",["color5"] = 5,},
	[4] = {["ID"] = 4,["area1"] = "40,40",["color1"] = 1,["area2"] = "31,34",["color2"] = 2,["area3"] = "23,27",["color3"] = 3,["area4"] = "16,19",["color4"] = 4,["area5"] = "4,12",["color5"] = 5,},
	[5] = {["ID"] = 5,["area1"] = "40,40",["color1"] = 1,["area2"] = "31,34",["color2"] = 2,["area3"] = "23,27",["color3"] = 3,["area4"] = "16,19",["color4"] = 4,["area5"] = "4,12",["color5"] = 5,},
	[6] = {["ID"] = 6,["area1"] = "40,40",["color1"] = 1,["area2"] = "31,34",["color2"] = 2,["area3"] = "23,27",["color3"] = 3,["area4"] = "16,19",["color4"] = 4,["area5"] = "4,12",["color5"] = 5,},
	[7] = {["ID"] = 7,["area1"] = "40,40",["color1"] = 1,["area2"] = "31,34",["color2"] = 2,["area3"] = "23,27",["color3"] = 3,["area4"] = "16,19",["color4"] = 4,["area5"] = "4,12",["color5"] = 5,},
	[8] = {["ID"] = 8,["area1"] = "40,40",["color1"] = 1,["area2"] = "31,34",["color2"] = 2,["area3"] = "23,27",["color3"] = 3,["area4"] = "16,19",["color4"] = 4,["area5"] = "4,12",["color5"] = 5,},
}

function getDataById(key_id)
    local id_data = Refresh[key_id]

    return id_data
end

function getArrDataByField(fieldName, fieldValue)
    local arrData = {}
    for k, v in pairs(Refresh) do
        if v[fieldName] == fieldValue then
            arrData[#arrData+1] = v
        end
    end

    return arrData
end

function release()
    _G["DB_Refresh"] = nil
    package.loaded["DB_Refresh"] = nil
    package.loaded["DBSystem/DB_Refresh"] = nil
end
--ExcelVBA output tools end flag