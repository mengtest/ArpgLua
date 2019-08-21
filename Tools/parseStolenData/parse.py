# -*- coding: utf-8 -*-  
# 解析偷来的数据，转换成定制的格式给数值分析
# input: fileSeq.txt, numSeq.txt
# output: parseResult.xlsx
# 声明：
#     1.本脚本授权于湧晖使用，不经本人允许不得转给他人使用
#	  2.本脚本可以修改源码，但不允许修改作者名
# 	  3.本脚本著作权归Johny尹强所属，对外说明时需主动说明

from xlrd import open_workbook
from xlwt import *
import os


#filepath
INPUTFILE_FILESEQ = r'input/fileSeq.txt'
INPUTFILE_NUMSEQ  = r'input/numSeq.txt'
OUTPUT_PARSERSEULT = r'output/parseResult.xls'

#var
BET				= 50000


#const 
COL_WIN  		= 0
COL_ISBONUS	 	= 1
COL_ISCHOOSE 	= 2
COL_ISFREESPIN 	= 3
COL_ISWILD		= 4


#inputDataList
list_FileSeq = []
list_NumSeq = []

def deleteFile(_file):
	_cmd = r'rm -f %s' %_file
	os.system(_cmd)


def checkOutFileExist():
	if os.path.exists(OUTPUT_PARSERSEULT):
		deleteFile(OUTPUT_PARSERSEULT)
	book = Workbook()
	sheet = book.add_sheet('Sheet1')
	sheet.write(0, COL_WIN, "COL_WIN")
	sheet.write(0, COL_ISBONUS, "COL_ISBONUS")
	sheet.write(0, COL_ISCHOOSE, "COL_ISCHOOSE")
	sheet.write(0, COL_ISFREESPIN, "COL_ISFREESPIN")
	sheet.write(0, COL_ISWILD, "COL_ISWILD")

	return book, sheet


def readInputDatas():
	global list_FileSeq
	global list_NumSeq
	with open(INPUTFILE_FILESEQ, 'r') as f:
		for line in f:
			line=line.strip('\n')
			if len(line) == 0:
			 	line = 0
			list_FileSeq.append(line)
	f.close()
	with open(INPUTFILE_NUMSEQ, 'r') as f:
		for line in f:
			line=line.strip('\n')
			if len(line) == 0:
			 	line = 0
			list_NumSeq.append(line)
	f.close()
	print("[HINT]list_FileSeq size: ", len(list_FileSeq))
	print("[HINT]list_NumSeq size: ", len(list_NumSeq))

def parseInputDataAndOutputToResult(book, sheet):
	if len(list_FileSeq) != len(list_NumSeq):
	   print("[ERROR]the data num of fileSeq is not equal to the data num of numSeq")
	else:
		##
		theBaseFileName = list_FileSeq[0]
		theBaseNum = int(list_NumSeq[0])
		theLastNum = 0
		theNextNum = 0
		##
		theEnterFree = False
		theFreeBonusFileName = r''
		theFreeBonusNum = 0
		for i in range(1,len(list_FileSeq)):
			theFileName = list_FileSeq[i]
			# print theFileName
			try:
				theNum = int(list_NumSeq[i])
			except ValueError:
				print("[ERROR_INPUT_NUM]", list_NumSeq[i])
			else:
				theWin = 0
				#检查Bonus，两种情况：choose和freespin 
				if r'Bonus' in theFileName:
				   if r'free' in list_FileSeq[i + 1]:
				   	  sheet.write(i, COL_ISBONUS, 1)
				   	  theWin = theNum
				   	  theFreeBonusFileName = theFileName
				   	  theFreeBonusNum = theNum
				elif r'choose' in theFileName:
					sheet.write(i, COL_ISCHOOSE, 1)
					theWin = theNum - theBaseNum
					#更换base值
					theBaseFileName = theFileName
					theBaseNum = theNum
				elif r'free' in theFileName:
					sheet.write(i, COL_ISFREESPIN, 1)
					if not theEnterFree:
					   #本次为第一次free
					   theWin = theNum
					   theEnterFree = True
					else:
						#不是第一次free，本次减之前一次
						theWin = theNum - theLastNum
				else:
					#检查wild,做标记
					if r'wild' in theFileName:
				   		sheet.write(i, COL_ISWILD, 1)
					if theEnterFree:
					   theEnterFree = False
					   theWin = theNum - theBaseNum - theFreeBonusNum - theLastNum + BET
					else:
						theWin = theNum - theBaseNum + BET
					#更换base值
					theBaseFileName = theFileName
					theBaseNum = theNum
				sheet.write(i, COL_WIN, theWin)
				theLastNum = theNum
			

		


def foo():
	book, sheet = checkOutFileExist()
	readInputDatas()
	parseInputDataAndOutputToResult(book, sheet)
	book.save(OUTPUT_PARSERSEULT)
	print("================================")
	print("Finish!")
	print("Author: Johny")
	print("================================")


if __name__=="__main__":
    foo()