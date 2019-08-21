-- Filename: DB_Skill.lua
-- Author: auto-created by XmlToScript tool.
-- Function: it`s auto-created by XmlToScript tool.
--ExcelVBA output tools start flag
module("DB_GuideCGSpeak", package.seeall)
--{ID,数量,对话1,对话2,对话3,对话4,对话5,对话6,对话7,对话8,对话9,对话10,}

GuideCGSpeak = {
	[1] = {["ID"] = 1,["Number"] = 6,["Speak_1"] = {52,1001},["Speak_2"] = {38,1002},["Speak_3"] = {38,1003},["Speak_4"] = {52,1004},["Speak_5"] = {38,1005},["Speak_6"] = {52,1006},["Speak_7"] = -1,["Speak_8"] = -1,["Speak_9"] = -1,["Speak_10"] = -1,},
	[2] = {["ID"] = 2,["Number"] = 4,["Speak_1"] = {53,1007},["Speak_2"] = {0,1008},["Speak_3"] = {0,1009},["Speak_4"] = {53,1010},["Speak_5"] = -1,["Speak_6"] = -1,["Speak_7"] = -1,["Speak_8"] = -1,["Speak_9"] = -1,["Speak_10"] = -1,},
	[3] = {["ID"] = 3,["Number"] = 7,["Speak_1"] = {0,1011},["Speak_2"] = {0,1012},["Speak_3"] = {30,1013},["Speak_4"] = {0,1014},["Speak_5"] = {30,1015},["Speak_6"] = {0,1016},["Speak_7"] = {30,1017},["Speak_8"] = -1,["Speak_9"] = -1,["Speak_10"] = -1,},
	[4] = {["ID"] = 4,["Number"] = 4,["Speak_1"] = {30,1018},["Speak_2"] = {0,1019},["Speak_3"] = {30,1020},["Speak_4"] = {0,1021},["Speak_5"] = -1,["Speak_6"] = -1,["Speak_7"] = -1,["Speak_8"] = -1,["Speak_9"] = -1,["Speak_10"] = -1,},
	[5] = {["ID"] = 5,["Number"] = 6,["Speak_1"] = {30,1022},["Speak_2"] = {0,1023},["Speak_3"] = {30,1024},["Speak_4"] = {0,1025},["Speak_5"] = {30,1026},["Speak_6"] = {30,1027},["Speak_7"] = -1,["Speak_8"] = -1,["Speak_9"] = -1,["Speak_10"] = -1,},
	[6] = {["ID"] = 6,["Number"] = 2,["Speak_1"] = {0,1028},["Speak_2"] = {30,1029},["Speak_3"] = -1,["Speak_4"] = -1,["Speak_5"] = -1,["Speak_6"] = -1,["Speak_7"] = -1,["Speak_8"] = -1,["Speak_9"] = -1,["Speak_10"] = -1,},
	[7] = {["ID"] = 7,["Number"] = 4,["Speak_1"] = {0,1030},["Speak_2"] = {52,1031},["Speak_3"] = {53,1032},["Speak_4"] = {0,1033},["Speak_5"] = -1,["Speak_6"] = -1,["Speak_7"] = -1,["Speak_8"] = -1,["Speak_9"] = -1,["Speak_10"] = -1,},
	[8] = {["ID"] = 8,["Number"] = 3,["Speak_1"] = {0,1034},["Speak_2"] = {0,1035},["Speak_3"] = {30,1036},["Speak_4"] = -1,["Speak_5"] = -1,["Speak_6"] = -1,["Speak_7"] = -1,["Speak_8"] = -1,["Speak_9"] = -1,["Speak_10"] = -1,},
	[9] = {["ID"] = 9,["Number"] = 3,["Speak_1"] = {30,1037},["Speak_2"] = {0,1038},["Speak_3"] = {30,1039},["Speak_4"] = -1,["Speak_5"] = -1,["Speak_6"] = -1,["Speak_7"] = -1,["Speak_8"] = -1,["Speak_9"] = -1,["Speak_10"] = -1,},
	[10] = {["ID"] = 10,["Number"] = 1,["Speak_1"] = {30,1040},["Speak_2"] = -1,["Speak_3"] = -1,["Speak_4"] = -1,["Speak_5"] = -1,["Speak_6"] = -1,["Speak_7"] = -1,["Speak_8"] = -1,["Speak_9"] = -1,["Speak_10"] = -1,},
	[11] = {["ID"] = 11,["Number"] = 3,["Speak_1"] = {0,1041},["Speak_2"] = {30,1042},["Speak_3"] = {0,1043},["Speak_4"] = -1,["Speak_5"] = -1,["Speak_6"] = -1,["Speak_7"] = -1,["Speak_8"] = -1,["Speak_9"] = -1,["Speak_10"] = -1,},
	[12] = {["ID"] = 12,["Number"] = 4,["Speak_1"] = {53,1044},["Speak_2"] = {54,1045},["Speak_3"] = {53,1046},["Speak_4"] = {54,1047},["Speak_5"] = -1,["Speak_6"] = -1,["Speak_7"] = -1,["Speak_8"] = -1,["Speak_9"] = -1,["Speak_10"] = -1,},
	[13] = {["ID"] = 13,["Number"] = 5,["Speak_1"] = {54,1048},["Speak_2"] = {0,1049},["Speak_3"] = {30,1050},["Speak_4"] = {0,1051},["Speak_5"] = {0,1052},["Speak_6"] = -1,["Speak_7"] = -1,["Speak_8"] = -1,["Speak_9"] = -1,["Speak_10"] = -1,},
	[14] = {["ID"] = 14,["Number"] = 5,["Speak_1"] = {30,1053},["Speak_2"] = {0,1054},["Speak_3"] = {30,1055},["Speak_4"] = {0,1056},["Speak_5"] = {30,1057},["Speak_6"] = -1,["Speak_7"] = -1,["Speak_8"] = -1,["Speak_9"] = -1,["Speak_10"] = -1,},
	[15] = {["ID"] = 15,["Number"] = 4,["Speak_1"] = {0,1058},["Speak_2"] = {30,1059},["Speak_3"] = {0,1060},["Speak_4"] = {30,1061},["Speak_5"] = -1,["Speak_6"] = -1,["Speak_7"] = -1,["Speak_8"] = -1,["Speak_9"] = -1,["Speak_10"] = -1,},
	[16] = {["ID"] = 16,["Number"] = 6,["Speak_1"] = {30,1062},["Speak_2"] = {19,1063},["Speak_3"] = {0,1064},["Speak_4"] = {30,1065},["Speak_5"] = {0,1066},["Speak_6"] = {19,1067},["Speak_7"] = -1,["Speak_8"] = -1,["Speak_9"] = -1,["Speak_10"] = -1,},
	[17] = {["ID"] = 17,["Number"] = 1,["Speak_1"] = {30,1068},["Speak_2"] = -1,["Speak_3"] = -1,["Speak_4"] = -1,["Speak_5"] = -1,["Speak_6"] = -1,["Speak_7"] = -1,["Speak_8"] = -1,["Speak_9"] = -1,["Speak_10"] = -1,},
	[18] = {["ID"] = 18,["Number"] = 3,["Speak_1"] = {19,1069},["Speak_2"] = {0,1070},["Speak_3"] = {19,1071},["Speak_4"] = -1,["Speak_5"] = -1,["Speak_6"] = -1,["Speak_7"] = -1,["Speak_8"] = -1,["Speak_9"] = -1,["Speak_10"] = -1,},
	[19] = {["ID"] = 19,["Number"] = 3,["Speak_1"] = {0,1072},["Speak_2"] = {19,1073},["Speak_3"] = {30,1074},["Speak_4"] = -1,["Speak_5"] = -1,["Speak_6"] = -1,["Speak_7"] = -1,["Speak_8"] = -1,["Speak_9"] = -1,["Speak_10"] = -1,},
	[20] = {["ID"] = 20,["Number"] = 2,["Speak_1"] = {30,1075},["Speak_2"] = {30,1076},["Speak_3"] = -1,["Speak_4"] = -1,["Speak_5"] = -1,["Speak_6"] = -1,["Speak_7"] = -1,["Speak_8"] = -1,["Speak_9"] = -1,["Speak_10"] = -1,},
	[21] = {["ID"] = 21,["Number"] = 3,["Speak_1"] = {30,1077},["Speak_2"] = {0,1078},["Speak_3"] = {30,1079},["Speak_4"] = -1,["Speak_5"] = -1,["Speak_6"] = -1,["Speak_7"] = -1,["Speak_8"] = -1,["Speak_9"] = -1,["Speak_10"] = -1,},
	[22] = {["ID"] = 22,["Number"] = 3,["Speak_1"] = {0,1080},["Speak_2"] = {30,1081},["Speak_3"] = {30,1082},["Speak_4"] = -1,["Speak_5"] = -1,["Speak_6"] = -1,["Speak_7"] = -1,["Speak_8"] = -1,["Speak_9"] = -1,["Speak_10"] = -1,},
	[23] = {["ID"] = 23,["Number"] = 3,["Speak_1"] = {0,1083},["Speak_2"] = {19,1084},["Speak_3"] = {0,1085},["Speak_4"] = -1,["Speak_5"] = -1,["Speak_6"] = -1,["Speak_7"] = -1,["Speak_8"] = -1,["Speak_9"] = -1,["Speak_10"] = -1,},
	[24] = {["ID"] = 24,["Number"] = 6,["Speak_1"] = {30,1086},["Speak_2"] = {0,1087},["Speak_3"] = {19,1088},["Speak_4"] = {30,1089},["Speak_5"] = {0,1090},["Speak_6"] = {19,1091},["Speak_7"] = -1,["Speak_8"] = -1,["Speak_9"] = -1,["Speak_10"] = -1,},
	[25] = {["ID"] = 25,["Number"] = 5,["Speak_1"] = {19,1092},["Speak_2"] = {0,1093},["Speak_3"] = {19,1094},["Speak_4"] = {0,1095},["Speak_5"] = {19,1096},["Speak_6"] = -1,["Speak_7"] = -1,["Speak_8"] = -1,["Speak_9"] = -1,["Speak_10"] = -1,},
	[26] = {["ID"] = 26,["Number"] = 8,["Speak_1"] = {19,1097},["Speak_2"] = {0,1098},["Speak_3"] = {39,1099},["Speak_4"] = {19,1100},["Speak_5"] = {39,1101},["Speak_6"] = {19,1102},["Speak_7"] = {0,1103},["Speak_8"] = {19,1104},["Speak_9"] = -1,["Speak_10"] = -1,},
	[27] = {["ID"] = 27,["Number"] = 3,["Speak_1"] = {30,1105},["Speak_2"] = {0,1106},["Speak_3"] = {30,1107},["Speak_4"] = -1,["Speak_5"] = -1,["Speak_6"] = -1,["Speak_7"] = -1,["Speak_8"] = -1,["Speak_9"] = -1,["Speak_10"] = -1,},
	[28] = {["ID"] = 28,["Number"] = 2,["Speak_1"] = {30,1108},["Speak_2"] = {30,1109},["Speak_3"] = -1,["Speak_4"] = -1,["Speak_5"] = -1,["Speak_6"] = -1,["Speak_7"] = -1,["Speak_8"] = -1,["Speak_9"] = -1,["Speak_10"] = -1,},
	[29] = {["ID"] = 29,["Number"] = 4,["Speak_1"] = {30,1110},["Speak_2"] = {30,1111},["Speak_3"] = {30,1112},["Speak_4"] = {30,1113},["Speak_5"] = -1,["Speak_6"] = -1,["Speak_7"] = -1,["Speak_8"] = -1,["Speak_9"] = -1,["Speak_10"] = -1,},
	[30] = {["ID"] = 30,["Number"] = 2,["Speak_1"] = {30,1114},["Speak_2"] = {30,1115},["Speak_3"] = -1,["Speak_4"] = -1,["Speak_5"] = -1,["Speak_6"] = -1,["Speak_7"] = -1,["Speak_8"] = -1,["Speak_9"] = -1,["Speak_10"] = -1,},
	[100] = {["ID"] = 100,["Number"] = 1,["Speak_1"] = {30,2100},["Speak_2"] = -1,["Speak_3"] = -1,["Speak_4"] = -1,["Speak_5"] = -1,["Speak_6"] = -1,["Speak_7"] = -1,["Speak_8"] = -1,["Speak_9"] = -1,["Speak_10"] = -1,},
	[101] = {["ID"] = 101,["Number"] = 2,["Speak_1"] = {30,2101},["Speak_2"] = {30,2102},["Speak_3"] = -1,["Speak_4"] = -1,["Speak_5"] = -1,["Speak_6"] = -1,["Speak_7"] = -1,["Speak_8"] = -1,["Speak_9"] = -1,["Speak_10"] = -1,},
	[102] = {["ID"] = 102,["Number"] = 2,["Speak_1"] = {30,2103},["Speak_2"] = {30,2104},["Speak_3"] = -1,["Speak_4"] = -1,["Speak_5"] = -1,["Speak_6"] = -1,["Speak_7"] = -1,["Speak_8"] = -1,["Speak_9"] = -1,["Speak_10"] = -1,},
	[103] = {["ID"] = 103,["Number"] = 2,["Speak_1"] = {0,2105},["Speak_2"] = {30,2106},["Speak_3"] = -1,["Speak_4"] = -1,["Speak_5"] = -1,["Speak_6"] = -1,["Speak_7"] = -1,["Speak_8"] = -1,["Speak_9"] = -1,["Speak_10"] = -1,},
	[104] = {["ID"] = 104,["Number"] = 2,["Speak_1"] = {30,2107},["Speak_2"] = {30,2108},["Speak_3"] = -1,["Speak_4"] = -1,["Speak_5"] = -1,["Speak_6"] = -1,["Speak_7"] = -1,["Speak_8"] = -1,["Speak_9"] = -1,["Speak_10"] = -1,},
	[105] = {["ID"] = 105,["Number"] = 2,["Speak_1"] = {30,2109},["Speak_2"] = {30,2110},["Speak_3"] = -1,["Speak_4"] = -1,["Speak_5"] = -1,["Speak_6"] = -1,["Speak_7"] = -1,["Speak_8"] = -1,["Speak_9"] = -1,["Speak_10"] = -1,},
	[106] = {["ID"] = 106,["Number"] = 2,["Speak_1"] = {30,2111},["Speak_2"] = {30,2112},["Speak_3"] = -1,["Speak_4"] = -1,["Speak_5"] = -1,["Speak_6"] = -1,["Speak_7"] = -1,["Speak_8"] = -1,["Speak_9"] = -1,["Speak_10"] = -1,},
	[107] = {["ID"] = 107,["Number"] = 2,["Speak_1"] = {30,2113},["Speak_2"] = {30,2114},["Speak_3"] = -1,["Speak_4"] = -1,["Speak_5"] = -1,["Speak_6"] = -1,["Speak_7"] = -1,["Speak_8"] = -1,["Speak_9"] = -1,["Speak_10"] = -1,},
	[108] = {["ID"] = 108,["Number"] = 2,["Speak_1"] = {30,2115},["Speak_2"] = {30,2116},["Speak_3"] = -1,["Speak_4"] = -1,["Speak_5"] = -1,["Speak_6"] = -1,["Speak_7"] = -1,["Speak_8"] = -1,["Speak_9"] = -1,["Speak_10"] = -1,},
	[109] = {["ID"] = 109,["Number"] = 2,["Speak_1"] = {30,2117},["Speak_2"] = {30,2118},["Speak_3"] = -1,["Speak_4"] = -1,["Speak_5"] = -1,["Speak_6"] = -1,["Speak_7"] = -1,["Speak_8"] = -1,["Speak_9"] = -1,["Speak_10"] = -1,},
	[110] = {["ID"] = 110,["Number"] = 1,["Speak_1"] = {30,2119},["Speak_2"] = -1,["Speak_3"] = -1,["Speak_4"] = -1,["Speak_5"] = -1,["Speak_6"] = -1,["Speak_7"] = -1,["Speak_8"] = -1,["Speak_9"] = -1,["Speak_10"] = -1,},
	[111] = {["ID"] = 111,["Number"] = 1,["Speak_1"] = {30,2120},["Speak_2"] = -1,["Speak_3"] = -1,["Speak_4"] = -1,["Speak_5"] = -1,["Speak_6"] = -1,["Speak_7"] = -1,["Speak_8"] = -1,["Speak_9"] = -1,["Speak_10"] = -1,},
	[112] = {["ID"] = 112,["Number"] = 1,["Speak_1"] = {30,2121},["Speak_2"] = -1,["Speak_3"] = -1,["Speak_4"] = -1,["Speak_5"] = -1,["Speak_6"] = -1,["Speak_7"] = -1,["Speak_8"] = -1,["Speak_9"] = -1,["Speak_10"] = -1,},
	[113] = {["ID"] = 113,["Number"] = 1,["Speak_1"] = {30,2122},["Speak_2"] = -1,["Speak_3"] = -1,["Speak_4"] = -1,["Speak_5"] = -1,["Speak_6"] = -1,["Speak_7"] = -1,["Speak_8"] = -1,["Speak_9"] = -1,["Speak_10"] = -1,},
	[201] = {["ID"] = 201,["Number"] = 2,["Speak_1"] = {0,3001},["Speak_2"] = {30,3002},["Speak_3"] = -1,["Speak_4"] = -1,["Speak_5"] = -1,["Speak_6"] = -1,["Speak_7"] = -1,["Speak_8"] = -1,["Speak_9"] = -1,["Speak_10"] = -1,},
	[202] = {["ID"] = 202,["Number"] = 2,["Speak_1"] = {30,3006},["Speak_2"] = {30,3007},["Speak_3"] = -1,["Speak_4"] = -1,["Speak_5"] = -1,["Speak_6"] = -1,["Speak_7"] = -1,["Speak_8"] = -1,["Speak_9"] = -1,["Speak_10"] = -1,},
	[203] = {["ID"] = 203,["Number"] = 4,["Speak_1"] = {0,3011},["Speak_2"] = {38,3012},["Speak_3"] = {0,3013},["Speak_4"] = {30,3014},["Speak_5"] = -1,["Speak_6"] = -1,["Speak_7"] = -1,["Speak_8"] = -1,["Speak_9"] = -1,["Speak_10"] = -1,},
	[204] = {["ID"] = 204,["Number"] = 3,["Speak_1"] = {52,3016},["Speak_2"] = {38,3017},["Speak_3"] = {52,3018},["Speak_4"] = -1,["Speak_5"] = -1,["Speak_6"] = -1,["Speak_7"] = -1,["Speak_8"] = -1,["Speak_9"] = -1,["Speak_10"] = -1,},
	[205] = {["ID"] = 205,["Number"] = 3,["Speak_1"] = {53,3021},["Speak_2"] = {0,3022},["Speak_3"] = {53,3023},["Speak_4"] = -1,["Speak_5"] = -1,["Speak_6"] = -1,["Speak_7"] = -1,["Speak_8"] = -1,["Speak_9"] = -1,["Speak_10"] = -1,},
	[206] = {["ID"] = 206,["Number"] = 2,["Speak_1"] = {30,3026},["Speak_2"] = {0,3027},["Speak_3"] = -1,["Speak_4"] = -1,["Speak_5"] = -1,["Speak_6"] = -1,["Speak_7"] = -1,["Speak_8"] = -1,["Speak_9"] = -1,["Speak_10"] = -1,},
	[207] = {["ID"] = 207,["Number"] = 2,["Speak_1"] = {0,3031},["Speak_2"] = {30,3032},["Speak_3"] = -1,["Speak_4"] = -1,["Speak_5"] = -1,["Speak_6"] = -1,["Speak_7"] = -1,["Speak_8"] = -1,["Speak_9"] = -1,["Speak_10"] = -1,},
	[208] = {["ID"] = 208,["Number"] = 2,["Speak_1"] = {52,3036},["Speak_2"] = {53,3037},["Speak_3"] = -1,["Speak_4"] = -1,["Speak_5"] = -1,["Speak_6"] = -1,["Speak_7"] = -1,["Speak_8"] = -1,["Speak_9"] = -1,["Speak_10"] = -1,},
	[209] = {["ID"] = 209,["Number"] = 1,["Speak_1"] = {30,3041},["Speak_2"] = -1,["Speak_3"] = -1,["Speak_4"] = -1,["Speak_5"] = -1,["Speak_6"] = -1,["Speak_7"] = -1,["Speak_8"] = -1,["Speak_9"] = -1,["Speak_10"] = -1,},
	[210] = {["ID"] = 210,["Number"] = 1,["Speak_1"] = {30,3046},["Speak_2"] = -1,["Speak_3"] = -1,["Speak_4"] = -1,["Speak_5"] = -1,["Speak_6"] = -1,["Speak_7"] = -1,["Speak_8"] = -1,["Speak_9"] = -1,["Speak_10"] = -1,},
	[211] = {["ID"] = 211,["Number"] = 3,["Speak_1"] = {23,3051},["Speak_2"] = {30,3052},["Speak_3"] = {0,3053},["Speak_4"] = -1,["Speak_5"] = -1,["Speak_6"] = -1,["Speak_7"] = -1,["Speak_8"] = -1,["Speak_9"] = -1,["Speak_10"] = -1,},
	[212] = {["ID"] = 212,["Number"] = 3,["Speak_1"] = {30,3056},["Speak_2"] = {30,3057},["Speak_3"] = {30,3058},["Speak_4"] = -1,["Speak_5"] = -1,["Speak_6"] = -1,["Speak_7"] = -1,["Speak_8"] = -1,["Speak_9"] = -1,["Speak_10"] = -1,},
	[213] = {["ID"] = 213,["Number"] = 2,["Speak_1"] = {30,3061},["Speak_2"] = {30,3062},["Speak_3"] = -1,["Speak_4"] = -1,["Speak_5"] = -1,["Speak_6"] = -1,["Speak_7"] = -1,["Speak_8"] = -1,["Speak_9"] = -1,["Speak_10"] = -1,},
	[214] = {["ID"] = 214,["Number"] = 2,["Speak_1"] = {23,3066},["Speak_2"] = {30,3067},["Speak_3"] = -1,["Speak_4"] = -1,["Speak_5"] = -1,["Speak_6"] = -1,["Speak_7"] = -1,["Speak_8"] = -1,["Speak_9"] = -1,["Speak_10"] = -1,},
	[215] = {["ID"] = 215,["Number"] = 1,["Speak_1"] = {30,3071},["Speak_2"] = -1,["Speak_3"] = -1,["Speak_4"] = -1,["Speak_5"] = -1,["Speak_6"] = -1,["Speak_7"] = -1,["Speak_8"] = -1,["Speak_9"] = -1,["Speak_10"] = -1,},
	[216] = {["ID"] = 216,["Number"] = 3,["Speak_1"] = {30,3076},["Speak_2"] = {19,3077},["Speak_3"] = {23,3078},["Speak_4"] = -1,["Speak_5"] = -1,["Speak_6"] = -1,["Speak_7"] = -1,["Speak_8"] = -1,["Speak_9"] = -1,["Speak_10"] = -1,},
	[217] = {["ID"] = 217,["Number"] = 2,["Speak_1"] = {30,3081},["Speak_2"] = {30,3082},["Speak_3"] = -1,["Speak_4"] = -1,["Speak_5"] = -1,["Speak_6"] = -1,["Speak_7"] = -1,["Speak_8"] = -1,["Speak_9"] = -1,["Speak_10"] = -1,},
	[218] = {["ID"] = 218,["Number"] = 2,["Speak_1"] = {30,3086},["Speak_2"] = {30,3087},["Speak_3"] = -1,["Speak_4"] = -1,["Speak_5"] = -1,["Speak_6"] = -1,["Speak_7"] = -1,["Speak_8"] = -1,["Speak_9"] = -1,["Speak_10"] = -1,},
	[219] = {["ID"] = 219,["Number"] = 1,["Speak_1"] = {30,3091},["Speak_2"] = -1,["Speak_3"] = -1,["Speak_4"] = -1,["Speak_5"] = -1,["Speak_6"] = -1,["Speak_7"] = -1,["Speak_8"] = -1,["Speak_9"] = -1,["Speak_10"] = -1,},
	[220] = {["ID"] = 220,["Number"] = 1,["Speak_1"] = {30,3096},["Speak_2"] = -1,["Speak_3"] = -1,["Speak_4"] = -1,["Speak_5"] = -1,["Speak_6"] = -1,["Speak_7"] = -1,["Speak_8"] = -1,["Speak_9"] = -1,["Speak_10"] = -1,},
	[221] = {["ID"] = 221,["Number"] = 2,["Speak_1"] = {30,3101},["Speak_2"] = {30,3102},["Speak_3"] = -1,["Speak_4"] = -1,["Speak_5"] = -1,["Speak_6"] = -1,["Speak_7"] = -1,["Speak_8"] = -1,["Speak_9"] = -1,["Speak_10"] = -1,},
	[222] = {["ID"] = 222,["Number"] = 1,["Speak_1"] = {30,3106},["Speak_2"] = -1,["Speak_3"] = -1,["Speak_4"] = -1,["Speak_5"] = -1,["Speak_6"] = -1,["Speak_7"] = -1,["Speak_8"] = -1,["Speak_9"] = -1,["Speak_10"] = -1,},
	[223] = {["ID"] = 223,["Number"] = 2,["Speak_1"] = {30,3111},["Speak_2"] = {30,3112},["Speak_3"] = -1,["Speak_4"] = -1,["Speak_5"] = -1,["Speak_6"] = -1,["Speak_7"] = -1,["Speak_8"] = -1,["Speak_9"] = -1,["Speak_10"] = -1,},
	[224] = {["ID"] = 224,["Number"] = 3,["Speak_1"] = {30,3116},["Speak_2"] = {30,3117},["Speak_3"] = {30,3118},["Speak_4"] = -1,["Speak_5"] = -1,["Speak_6"] = -1,["Speak_7"] = -1,["Speak_8"] = -1,["Speak_9"] = -1,["Speak_10"] = -1,},
	[225] = {["ID"] = 225,["Number"] = 1,["Speak_1"] = {30,3121},["Speak_2"] = -1,["Speak_3"] = -1,["Speak_4"] = -1,["Speak_5"] = -1,["Speak_6"] = -1,["Speak_7"] = -1,["Speak_8"] = -1,["Speak_9"] = -1,["Speak_10"] = -1,},
	[226] = {["ID"] = 226,["Number"] = 2,["Speak_1"] = {30,3126},["Speak_2"] = {30,3127},["Speak_3"] = -1,["Speak_4"] = -1,["Speak_5"] = -1,["Speak_6"] = -1,["Speak_7"] = -1,["Speak_8"] = -1,["Speak_9"] = -1,["Speak_10"] = -1,},
	[227] = {["ID"] = 227,["Number"] = 2,["Speak_1"] = {30,3131},["Speak_2"] = {30,3132},["Speak_3"] = -1,["Speak_4"] = -1,["Speak_5"] = -1,["Speak_6"] = -1,["Speak_7"] = -1,["Speak_8"] = -1,["Speak_9"] = -1,["Speak_10"] = -1,},
	[228] = {["ID"] = 228,["Number"] = 2,["Speak_1"] = {30,3136},["Speak_2"] = {30,3137},["Speak_3"] = -1,["Speak_4"] = -1,["Speak_5"] = -1,["Speak_6"] = -1,["Speak_7"] = -1,["Speak_8"] = -1,["Speak_9"] = -1,["Speak_10"] = -1,},
	[229] = {["ID"] = 229,["Number"] = 2,["Speak_1"] = {30,3141},["Speak_2"] = {30,3142},["Speak_3"] = -1,["Speak_4"] = -1,["Speak_5"] = -1,["Speak_6"] = -1,["Speak_7"] = -1,["Speak_8"] = -1,["Speak_9"] = -1,["Speak_10"] = -1,},
	[230] = {["ID"] = 230,["Number"] = 2,["Speak_1"] = {30,3146},["Speak_2"] = {30,3147},["Speak_3"] = -1,["Speak_4"] = -1,["Speak_5"] = -1,["Speak_6"] = -1,["Speak_7"] = -1,["Speak_8"] = -1,["Speak_9"] = -1,["Speak_10"] = -1,},
	[231] = {["ID"] = 231,["Number"] = 1,["Speak_1"] = {30,3151},["Speak_2"] = -1,["Speak_3"] = -1,["Speak_4"] = -1,["Speak_5"] = -1,["Speak_6"] = -1,["Speak_7"] = -1,["Speak_8"] = -1,["Speak_9"] = -1,["Speak_10"] = -1,},
	[232] = {["ID"] = 232,["Number"] = 3,["Speak_1"] = {30,3156},["Speak_2"] = {30,3157},["Speak_3"] = {30,3158},["Speak_4"] = -1,["Speak_5"] = -1,["Speak_6"] = -1,["Speak_7"] = -1,["Speak_8"] = -1,["Speak_9"] = -1,["Speak_10"] = -1,},
	[233] = {["ID"] = 233,["Number"] = 2,["Speak_1"] = {30,3161},["Speak_2"] = {30,3162},["Speak_3"] = -1,["Speak_4"] = -1,["Speak_5"] = -1,["Speak_6"] = -1,["Speak_7"] = -1,["Speak_8"] = -1,["Speak_9"] = -1,["Speak_10"] = -1,},
	[234] = {["ID"] = 234,["Number"] = 2,["Speak_1"] = {30,3166},["Speak_2"] = {30,3167},["Speak_3"] = -1,["Speak_4"] = -1,["Speak_5"] = -1,["Speak_6"] = -1,["Speak_7"] = -1,["Speak_8"] = -1,["Speak_9"] = -1,["Speak_10"] = -1,},
	[235] = {["ID"] = 235,["Number"] = 2,["Speak_1"] = {30,3171},["Speak_2"] = {30,3172},["Speak_3"] = -1,["Speak_4"] = -1,["Speak_5"] = -1,["Speak_6"] = -1,["Speak_7"] = -1,["Speak_8"] = -1,["Speak_9"] = -1,["Speak_10"] = -1,},
	[236] = {["ID"] = 236,["Number"] = 3,["Speak_1"] = {30,3176},["Speak_2"] = {30,3177},["Speak_3"] = {30,3178},["Speak_4"] = -1,["Speak_5"] = -1,["Speak_6"] = -1,["Speak_7"] = -1,["Speak_8"] = -1,["Speak_9"] = -1,["Speak_10"] = -1,},
	[237] = {["ID"] = 237,["Number"] = 2,["Speak_1"] = {30,3181},["Speak_2"] = {30,3182},["Speak_3"] = -1,["Speak_4"] = -1,["Speak_5"] = -1,["Speak_6"] = -1,["Speak_7"] = -1,["Speak_8"] = -1,["Speak_9"] = -1,["Speak_10"] = -1,},
}

function getDataById(key_id)
    local id_data = GuideCGSpeak[key_id]

    return id_data
end

function getArrDataByField(fieldName, fieldValue)
    local arrData = {}
    for k, v in pairs(GuideCGSpeak) do
        if v[fieldName] == fieldValue then
            arrData[#arrData+1] = v
        end
    end

    return arrData
end

function release()
    _G["DB_GuideCGSpeak"] = nil
    package.loaded["DB_GuideCGSpeak"] = nil
    package.loaded["DBSystem/DB_GuideCGSpeak"] = nil
end
--ExcelVBA output tools end flag