#-*- coding: UTF-8 -*-
#递归找出文件夹下ccb文件，指定后缀的文件
#再次递归文件下所有plist文件，如果不在集合中，直接删除，并删除同名png文件

import os,re

PATH_ROOT 	= r'.'
FILE_SUFFIX = r'.ccb'
KEY_SUFFIX  = r'.plist'

ret_list = set()



def findKeySuffixInFile(filePath):
	global ret_list
	theFile = file(filePath, "r+")
	for s in theFile.readlines():       #每次从hello.txt中读取一行，保存到s中
		li = re.findall(KEY_SUFFIX, s)   #调用findall（）查询s， 并将查询到的结果保存到li中
		if len(li) > 0:  
		   ss = ' '.join(s.split())
		   ret_list.add(ss)




def _recursiveFolder(_curFolder):
	if os.path.exists(_curFolder):
	    for f in os.listdir(_curFolder):
	        f_path = _curFolder + "/" + f
	        if os.path.isdir(f_path):
	           _recursiveFolder(f_path)
	        else:
	           fname,fext=os.path.splitext(f_path)
	           if fext == FILE_SUFFIX:
	           	  # print f_path
	           	  findKeySuffixInFile(f_path)


def outputResult():
	for item in ret_list:
		print item


def foo():
	_recursiveFolder(PATH_ROOT)
	outputResult()
	print("================================")
	print("Finish!")
	print("Author: Johny")
	print("================================")


if __name__=="__main__":
    foo()