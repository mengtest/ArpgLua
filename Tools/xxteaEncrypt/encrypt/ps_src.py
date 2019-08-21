# -*- coding: utf-8 -*-  
# 把src下的所有文件递归加密

import sys,os
sys.path.append("..")
import xxtea

PATH = "../src_slotsnew"
# PATH = "../src_config"

def genMD5(forder):
	_cmd = r'./gen_update_list.sh %s' %forder
	os.system(_cmd)

def foo():
	# 1. find src folder
	rootPath = os.path.abspath(PATH)
	# 2. recursive src folder, and compile lua files
	xxtea.encryptEntry(rootPath)
	# 3. gen MD5
	genMD5(rootPath)
	print("================================")
	print("Finish!")
	print("Author: Johny")
	print("================================")


if __name__=="__main__":
    foo()