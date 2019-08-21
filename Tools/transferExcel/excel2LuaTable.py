# -*- coding: utf-8 -*-  
# 解析excel文件，导出指定luatable格式

from xlrd import open_workbook
import re

###config
#subid: 49
# TABLENAME_FEEL   = r'reel_TripleHitDiamond'
# TABLENAME_FEEL_WEIGHT   = r'reel_TripleHitDiamond_weight'
# INPUT_FILE  = r'input/reel_TripleHitDiamond.xlsx'
# OUTPUT_FILE = r'output/reel_TripleHitDiamond.lua'

#subid: 37
# TABLENAME_FEEL   = r'reel_AmericanDream'
# TABLENAME_FEEL_WEIGHT   = r'reel_AmericanDream_weight'
# TABLENAME_FREEFEEL   = r'reel_AmericanDream_free'
# TABLENAME_FREEFEEL_WEIGHT   = r'reel_AmericanDream_free_weight'
# INPUT_FILE  = r'input/reel_American.xlsx'
# OUTPUT_FILE = r'output/reel_American.lua'

#subid: 47
TABLENAME_FEEL   = r'reel_Classic777'
TABLENAME_FEEL_WEIGHT   = r'reel_Classic777_weight'
TABLENAME_FREEFEEL   = r'reel_Classic777_free'
TABLENAME_FREEFEEL_WEIGHT   = r'reel_Classic777_free_weight'
INPUT_FILE  = r'input/reel_Classic777.xlsx'
OUTPUT_FILE = r'output/reel_Classic777.lua'

# #subid: 50
# TABLENAME_FEEL   = r'reel_VegaStar'
# TABLENAME_FEEL_WEIGHT   = r'reel_VegaStar_weight'
# TABLENAME_FREEFEEL   = r'reel_VegaStar_free'
# TABLENAME_FREEFEEL_WEIGHT   = r'reel_VegaStar_free_weight'
# INPUT_FILE  = r'input/reel_VegaStar.xlsx'
# OUTPUT_FILE = r'output/reel_VegaStar.lua'

#lua模板
LUATEMPLATE = '%s={\r\
{%s},\r\
{%s},\r\
{%s},\r\
{%s},\r\
{%s}\r\
}'
LUATEMPLATE_3COL = '%s={\r\
{%s},\r\
{%s},\r\
{%s},\r\
}'

#轮子名
REEL1   =  r'reel1'
REEL2   =  r'reel2'
REEL3   =  r'reel3'
REEL4   =  r'reel4'
REEL5   =  r'reel5'
###

##全局变量
G_nrows = 0
G_ncols = 0
G_reelTableStr = ''
G_reelTableWeightStr = ''
G_freereeTableStr = ''
G_freereeTableWeightStr = ''


#转换列
def transferCol(sheet, col):
	ret = ''
	for row in xrange(G_nrows):
		tmp = sheet.cell(row, col).value
		if row != 0 and tmp != r'':
		   ret += '%d'%tmp
		   ret += r','
	ret = ret[:-1]
	return ret
		   

#转换普通轮子表
def transferReelTable(sheet):
	nums1 = transferCol(sheet, 0)
	nums2 = transferCol(sheet, 2)
	nums3 = transferCol(sheet, 4)
	# nums4 = transferCol(sheet, 6)
	# nums5 = transferCol(sheet, 8)

	global G_reelTableStr
	# G_reelTableStr = LUATEMPLATE %(TABLENAME_FEEL, nums1, nums2, nums3, nums4, nums5)
	G_reelTableStr = LUATEMPLATE_3COL %(TABLENAME_FEEL, nums1, nums2, nums3)
	print G_reelTableStr

#转换普通轮子权重表
def transferReelWeightTable(sheet):
	nums1 = transferCol(sheet, 1)
	nums2 = transferCol(sheet, 3)
	nums3 = transferCol(sheet, 5)
	# nums4 = transferCol(sheet, 7)
	# nums5 = transferCol(sheet, 9)

	global G_reelTableWeightStr
	# G_reelTableWeightStr = LUATEMPLATE %(TABLENAME_FEEL_WEIGHT, nums1, nums2, nums3, nums4, nums5)
	G_reelTableWeightStr = LUATEMPLATE_3COL %(TABLENAME_FEEL_WEIGHT, nums1, nums2, nums3)
	print G_reelTableWeightStr



#转换free轮子表
def transferFreeReelTable(sheet):
	nums1 = transferCol(sheet, 10)
	nums2 = transferCol(sheet, 12)
	nums3 = transferCol(sheet, 14)
	nums4 = transferCol(sheet, 16)
	nums5 = transferCol(sheet, 18)

	global G_freereeTableStr
	G_freereeTableStr = LUATEMPLATE %(TABLENAME_FREEFEEL, nums1, nums2, nums3, nums4, nums5)
	print G_freereeTableStr

#转换free轮子权重表
def transferFreeReelTableWeight(sheet):
	nums1 = transferCol(sheet, 11)
	nums2 = transferCol(sheet, 13)
	nums3 = transferCol(sheet, 15)
	nums4 = transferCol(sheet, 17)
	nums5 = transferCol(sheet, 19)

	global G_freereeTableWeightStr
	G_freereeTableWeightStr = LUATEMPLATE %(TABLENAME_FREEFEEL_WEIGHT, nums1, nums2, nums3, nums4, nums5)
	print G_freereeTableWeightStr
	

def handleTransfer(sheet):
	global G_nrows
	global G_ncols
	G_nrows = sheet.nrows
	G_ncols = sheet.ncols
	transferReelTable(sheet)
	transferReelWeightTable(sheet)
	# transferFreeReelTable(sheet)
	# transferFreeReelTableWeight(sheet)

	#将结果输出到lua文件
	with open(OUTPUT_FILE, 'w') as f:
		f.write(G_reelTableStr)
		f.write(G_reelTableWeightStr)
		f.write('\r')
		f.write(G_freereeTableStr)
		f.write(G_freereeTableWeightStr)
	f.close()



def foo():
	wb = open_workbook(INPUT_FILE) #打开Excel文件
	s = wb.sheets()[0]
	handleTransfer(s)
	print("================================")
	print("Finish!")
	print("Author: Johny")
	print("================================")


if __name__=="__main__":
    foo()


