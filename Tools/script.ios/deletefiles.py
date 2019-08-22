# -*- coding: utf-8 -*-  
# 将本脚本放到批量修改后缀的文件夹下

import os

PATH = '.'
FILE = '.png'

def deleteFile(_file):
  _cmd = r'rm %s' %_file
  os.system(_cmd)

def _recursiveFolder(_curFolder):
    for f in os.listdir(_curFolder):
        f_path = _curFolder + "/" + f
        if os.path.isdir(f_path):
           _recursiveFolder(f_path)
        else:
           fname,fext=os.path.splitext(f_path)
           if fext == FILE:
              deleteFile(f_path)


###########MAIN###############
if __name__=="__main__":
	_recursiveFolder(PATH)
	print("===[Author: Johny]===")
