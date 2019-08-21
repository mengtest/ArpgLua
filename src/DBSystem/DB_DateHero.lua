-- Filename: DB_Skill.lua
-- Author: auto-created by XmlToScript tool.
-- Function: it`s auto-created by XmlToScript tool.
--ExcelVBA output tools start flag
module("DB_DateHero", package.seeall)
--{序号,实际对应的ID,开放等级,送礼感言,聊天泡泡英雄发言1,聊天泡泡英雄发言2,聊天泡泡英雄发言3,聊天内容-问题,聊天内容-问题1-回答1,聊天内容-问题1-回答2,聊天内容-问题1-回答3,聊天内容英雄发言2回答正确,聊天内容英雄发言2回答错误,卡牌战血量上限,卡牌站怒气上限,}

DateHero = {
	[1] = {["ID"] = 1,["real_ID"] = 1,["OpenLevel"] = 1,["Gift_text"] = 958,["ChatBubble_HeroSpeak_1"] = 992,["ChatBubble_HeroSpeak_2"] = 1016,["ChatBubble_HeroSpeak_3"] = 1040,["Chat_Hero"] = 1064,["Chat_Player_1"] = 1088,["Chat_Player_2"] = 1112,["Chat_Player_3"] = 1136,["Chat_Hero2_Right"] = 1160,["Chat_Hero2_wrong"] = 1184,["GameCard_MaxBlood"] = 25,["GameCard_MaxAnger"] = 25,},
	[2] = {["ID"] = 2,["real_ID"] = 2,["OpenLevel"] = 1,["Gift_text"] = 959,["ChatBubble_HeroSpeak_1"] = 993,["ChatBubble_HeroSpeak_2"] = 1017,["ChatBubble_HeroSpeak_3"] = 1041,["Chat_Hero"] = 1065,["Chat_Player_1"] = 1089,["Chat_Player_2"] = 1113,["Chat_Player_3"] = 1137,["Chat_Hero2_Right"] = 1161,["Chat_Hero2_wrong"] = 1185,["GameCard_MaxBlood"] = 25,["GameCard_MaxAnger"] = 25,},
	[3] = {["ID"] = 3,["real_ID"] = 3,["OpenLevel"] = 1,["Gift_text"] = 960,["ChatBubble_HeroSpeak_1"] = 994,["ChatBubble_HeroSpeak_2"] = 1018,["ChatBubble_HeroSpeak_3"] = 1042,["Chat_Hero"] = 1066,["Chat_Player_1"] = 1090,["Chat_Player_2"] = 1114,["Chat_Player_3"] = 1138,["Chat_Hero2_Right"] = 1162,["Chat_Hero2_wrong"] = 1186,["GameCard_MaxBlood"] = 25,["GameCard_MaxAnger"] = 25,},
	[4] = {["ID"] = 4,["real_ID"] = 4,["OpenLevel"] = 1,["Gift_text"] = 961,["ChatBubble_HeroSpeak_1"] = 995,["ChatBubble_HeroSpeak_2"] = 1019,["ChatBubble_HeroSpeak_3"] = 1043,["Chat_Hero"] = 1067,["Chat_Player_1"] = 1091,["Chat_Player_2"] = 1115,["Chat_Player_3"] = 1139,["Chat_Hero2_Right"] = 1163,["Chat_Hero2_wrong"] = 1187,["GameCard_MaxBlood"] = 25,["GameCard_MaxAnger"] = 25,},
	[5] = {["ID"] = 5,["real_ID"] = 5,["OpenLevel"] = 2,["Gift_text"] = 962,["ChatBubble_HeroSpeak_1"] = 996,["ChatBubble_HeroSpeak_2"] = 1020,["ChatBubble_HeroSpeak_3"] = 1044,["Chat_Hero"] = 1068,["Chat_Player_1"] = 1092,["Chat_Player_2"] = 1116,["Chat_Player_3"] = 1140,["Chat_Hero2_Right"] = 1164,["Chat_Hero2_wrong"] = 1188,["GameCard_MaxBlood"] = 25,["GameCard_MaxAnger"] = 25,},
	[6] = {["ID"] = 6,["real_ID"] = 6,["OpenLevel"] = 2,["Gift_text"] = 963,["ChatBubble_HeroSpeak_1"] = 997,["ChatBubble_HeroSpeak_2"] = 1021,["ChatBubble_HeroSpeak_3"] = 1045,["Chat_Hero"] = 1069,["Chat_Player_1"] = 1093,["Chat_Player_2"] = 1117,["Chat_Player_3"] = 1141,["Chat_Hero2_Right"] = 1165,["Chat_Hero2_wrong"] = 1189,["GameCard_MaxBlood"] = 25,["GameCard_MaxAnger"] = 25,},
	[7] = {["ID"] = 7,["real_ID"] = 7,["OpenLevel"] = 2,["Gift_text"] = 964,["ChatBubble_HeroSpeak_1"] = 998,["ChatBubble_HeroSpeak_2"] = 1022,["ChatBubble_HeroSpeak_3"] = 1046,["Chat_Hero"] = 1070,["Chat_Player_1"] = 1094,["Chat_Player_2"] = 1118,["Chat_Player_3"] = 1142,["Chat_Hero2_Right"] = 1166,["Chat_Hero2_wrong"] = 1190,["GameCard_MaxBlood"] = 25,["GameCard_MaxAnger"] = 25,},
	[8] = {["ID"] = 8,["real_ID"] = 8,["OpenLevel"] = 2,["Gift_text"] = 965,["ChatBubble_HeroSpeak_1"] = 999,["ChatBubble_HeroSpeak_2"] = 1023,["ChatBubble_HeroSpeak_3"] = 1047,["Chat_Hero"] = 1071,["Chat_Player_1"] = 1095,["Chat_Player_2"] = 1119,["Chat_Player_3"] = 1143,["Chat_Hero2_Right"] = 1167,["Chat_Hero2_wrong"] = 1191,["GameCard_MaxBlood"] = 25,["GameCard_MaxAnger"] = 25,},
	[9] = {["ID"] = 9,["real_ID"] = 9,["OpenLevel"] = 2,["Gift_text"] = 966,["ChatBubble_HeroSpeak_1"] = 1000,["ChatBubble_HeroSpeak_2"] = 1024,["ChatBubble_HeroSpeak_3"] = 1048,["Chat_Hero"] = 1072,["Chat_Player_1"] = 1096,["Chat_Player_2"] = 1120,["Chat_Player_3"] = 1144,["Chat_Hero2_Right"] = 1168,["Chat_Hero2_wrong"] = 1192,["GameCard_MaxBlood"] = 25,["GameCard_MaxAnger"] = 25,},
	[10] = {["ID"] = 10,["real_ID"] = 10,["OpenLevel"] = 3,["Gift_text"] = 967,["ChatBubble_HeroSpeak_1"] = 1001,["ChatBubble_HeroSpeak_2"] = 1025,["ChatBubble_HeroSpeak_3"] = 1049,["Chat_Hero"] = 1073,["Chat_Player_1"] = 1097,["Chat_Player_2"] = 1121,["Chat_Player_3"] = 1145,["Chat_Hero2_Right"] = 1169,["Chat_Hero2_wrong"] = 1193,["GameCard_MaxBlood"] = 25,["GameCard_MaxAnger"] = 25,},
	[11] = {["ID"] = 11,["real_ID"] = 11,["OpenLevel"] = 3,["Gift_text"] = 968,["ChatBubble_HeroSpeak_1"] = 1002,["ChatBubble_HeroSpeak_2"] = 1026,["ChatBubble_HeroSpeak_3"] = 1050,["Chat_Hero"] = 1074,["Chat_Player_1"] = 1098,["Chat_Player_2"] = 1122,["Chat_Player_3"] = 1146,["Chat_Hero2_Right"] = 1170,["Chat_Hero2_wrong"] = 1194,["GameCard_MaxBlood"] = 25,["GameCard_MaxAnger"] = 25,},
	[12] = {["ID"] = 12,["real_ID"] = 12,["OpenLevel"] = 3,["Gift_text"] = 969,["ChatBubble_HeroSpeak_1"] = 1003,["ChatBubble_HeroSpeak_2"] = 1027,["ChatBubble_HeroSpeak_3"] = 1051,["Chat_Hero"] = 1075,["Chat_Player_1"] = 1099,["Chat_Player_2"] = 1123,["Chat_Player_3"] = 1147,["Chat_Hero2_Right"] = 1171,["Chat_Hero2_wrong"] = 1195,["GameCard_MaxBlood"] = 25,["GameCard_MaxAnger"] = 25,},
	[13] = {["ID"] = 13,["real_ID"] = 13,["OpenLevel"] = 3,["Gift_text"] = 970,["ChatBubble_HeroSpeak_1"] = 1004,["ChatBubble_HeroSpeak_2"] = 1028,["ChatBubble_HeroSpeak_3"] = 1052,["Chat_Hero"] = 1076,["Chat_Player_1"] = 1100,["Chat_Player_2"] = 1124,["Chat_Player_3"] = 1148,["Chat_Hero2_Right"] = 1172,["Chat_Hero2_wrong"] = 1196,["GameCard_MaxBlood"] = 25,["GameCard_MaxAnger"] = 25,},
	[14] = {["ID"] = 14,["real_ID"] = 14,["OpenLevel"] = 3,["Gift_text"] = 971,["ChatBubble_HeroSpeak_1"] = 1005,["ChatBubble_HeroSpeak_2"] = 1029,["ChatBubble_HeroSpeak_3"] = 1053,["Chat_Hero"] = 1077,["Chat_Player_1"] = 1101,["Chat_Player_2"] = 1125,["Chat_Player_3"] = 1149,["Chat_Hero2_Right"] = 1173,["Chat_Hero2_wrong"] = 1197,["GameCard_MaxBlood"] = 25,["GameCard_MaxAnger"] = 25,},
	[15] = {["ID"] = 15,["real_ID"] = 15,["OpenLevel"] = 4,["Gift_text"] = 972,["ChatBubble_HeroSpeak_1"] = 1006,["ChatBubble_HeroSpeak_2"] = 1030,["ChatBubble_HeroSpeak_3"] = 1054,["Chat_Hero"] = 1078,["Chat_Player_1"] = 1102,["Chat_Player_2"] = 1126,["Chat_Player_3"] = 1150,["Chat_Hero2_Right"] = 1174,["Chat_Hero2_wrong"] = 1198,["GameCard_MaxBlood"] = 25,["GameCard_MaxAnger"] = 25,},
	[16] = {["ID"] = 16,["real_ID"] = 16,["OpenLevel"] = 4,["Gift_text"] = 973,["ChatBubble_HeroSpeak_1"] = 1007,["ChatBubble_HeroSpeak_2"] = 1031,["ChatBubble_HeroSpeak_3"] = 1055,["Chat_Hero"] = 1079,["Chat_Player_1"] = 1103,["Chat_Player_2"] = 1127,["Chat_Player_3"] = 1151,["Chat_Hero2_Right"] = 1175,["Chat_Hero2_wrong"] = 1199,["GameCard_MaxBlood"] = 25,["GameCard_MaxAnger"] = 25,},
	[17] = {["ID"] = 17,["real_ID"] = 17,["OpenLevel"] = 4,["Gift_text"] = 974,["ChatBubble_HeroSpeak_1"] = 1008,["ChatBubble_HeroSpeak_2"] = 1032,["ChatBubble_HeroSpeak_3"] = 1056,["Chat_Hero"] = 1080,["Chat_Player_1"] = 1104,["Chat_Player_2"] = 1128,["Chat_Player_3"] = 1152,["Chat_Hero2_Right"] = 1176,["Chat_Hero2_wrong"] = 1200,["GameCard_MaxBlood"] = 25,["GameCard_MaxAnger"] = 25,},
	[18] = {["ID"] = 18,["real_ID"] = 18,["OpenLevel"] = 4,["Gift_text"] = 975,["ChatBubble_HeroSpeak_1"] = 1009,["ChatBubble_HeroSpeak_2"] = 1033,["ChatBubble_HeroSpeak_3"] = 1057,["Chat_Hero"] = 1081,["Chat_Player_1"] = 1105,["Chat_Player_2"] = 1129,["Chat_Player_3"] = 1153,["Chat_Hero2_Right"] = 1177,["Chat_Hero2_wrong"] = 1201,["GameCard_MaxBlood"] = 25,["GameCard_MaxAnger"] = 25,},
	[19] = {["ID"] = 19,["real_ID"] = 19,["OpenLevel"] = 4,["Gift_text"] = 976,["ChatBubble_HeroSpeak_1"] = 1010,["ChatBubble_HeroSpeak_2"] = 1034,["ChatBubble_HeroSpeak_3"] = 1058,["Chat_Hero"] = 1082,["Chat_Player_1"] = 1106,["Chat_Player_2"] = 1130,["Chat_Player_3"] = 1154,["Chat_Hero2_Right"] = 1178,["Chat_Hero2_wrong"] = 1202,["GameCard_MaxBlood"] = 25,["GameCard_MaxAnger"] = 25,},
	[20] = {["ID"] = 20,["real_ID"] = 20,["OpenLevel"] = 5,["Gift_text"] = 977,["ChatBubble_HeroSpeak_1"] = 1011,["ChatBubble_HeroSpeak_2"] = 1035,["ChatBubble_HeroSpeak_3"] = 1059,["Chat_Hero"] = 1083,["Chat_Player_1"] = 1107,["Chat_Player_2"] = 1131,["Chat_Player_3"] = 1155,["Chat_Hero2_Right"] = 1179,["Chat_Hero2_wrong"] = 1203,["GameCard_MaxBlood"] = 25,["GameCard_MaxAnger"] = 25,},
	[21] = {["ID"] = 21,["real_ID"] = 21,["OpenLevel"] = 5,["Gift_text"] = 978,["ChatBubble_HeroSpeak_1"] = 1012,["ChatBubble_HeroSpeak_2"] = 1036,["ChatBubble_HeroSpeak_3"] = 1060,["Chat_Hero"] = 1084,["Chat_Player_1"] = 1108,["Chat_Player_2"] = 1132,["Chat_Player_3"] = 1156,["Chat_Hero2_Right"] = 1180,["Chat_Hero2_wrong"] = 1204,["GameCard_MaxBlood"] = 25,["GameCard_MaxAnger"] = 25,},
	[22] = {["ID"] = 22,["real_ID"] = 22,["OpenLevel"] = 5,["Gift_text"] = 979,["ChatBubble_HeroSpeak_1"] = 1013,["ChatBubble_HeroSpeak_2"] = 1037,["ChatBubble_HeroSpeak_3"] = 1061,["Chat_Hero"] = 1085,["Chat_Player_1"] = 1109,["Chat_Player_2"] = 1133,["Chat_Player_3"] = 1157,["Chat_Hero2_Right"] = 1181,["Chat_Hero2_wrong"] = 1205,["GameCard_MaxBlood"] = 25,["GameCard_MaxAnger"] = 25,},
	[23] = {["ID"] = 23,["real_ID"] = 23,["OpenLevel"] = 5,["Gift_text"] = 980,["ChatBubble_HeroSpeak_1"] = 1014,["ChatBubble_HeroSpeak_2"] = 1038,["ChatBubble_HeroSpeak_3"] = 1062,["Chat_Hero"] = 1086,["Chat_Player_1"] = 1110,["Chat_Player_2"] = 1134,["Chat_Player_3"] = 1158,["Chat_Hero2_Right"] = 1182,["Chat_Hero2_wrong"] = 1206,["GameCard_MaxBlood"] = 25,["GameCard_MaxAnger"] = 25,},
	[24] = {["ID"] = 24,["real_ID"] = 24,["OpenLevel"] = 5,["Gift_text"] = 981,["ChatBubble_HeroSpeak_1"] = 1015,["ChatBubble_HeroSpeak_2"] = 1039,["ChatBubble_HeroSpeak_3"] = 1063,["Chat_Hero"] = 1087,["Chat_Player_1"] = 1111,["Chat_Player_2"] = 1135,["Chat_Player_3"] = 1159,["Chat_Hero2_Right"] = 1183,["Chat_Hero2_wrong"] = 1207,["GameCard_MaxBlood"] = 25,["GameCard_MaxAnger"] = 25,},
}

function getDataById(key_id)
    local id_data = DateHero[key_id]

    return id_data
end

function getArrDataByField(fieldName, fieldValue)
    local arrData = {}
    for k, v in pairs(DateHero) do
        if v[fieldName] == fieldValue then
            arrData[#arrData+1] = v
        end
    end

    return arrData
end

function release()
    _G["DB_DateHero"] = nil
    package.loaded["DB_DateHero"] = nil
    package.loaded["DBSystem/DB_DateHero"] = nil
end
--ExcelVBA output tools end flag