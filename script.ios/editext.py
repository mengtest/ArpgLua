# -*- coding: utf-8 -*-  
# 将本脚本放到批量修改后缀的文件夹下

import os

PATH = '.'
OLD_EXT = '.pkm'
NEW_EXT = '.png'

def editExt(_file):
    print("===[File]===%s" %_file)
    portion = os.path.splitext(_file)
    # 重新组合文件名和后缀名   
    newname = portion[0] + NEW_EXT   
    os.rename(_file,newname)


def _recursiveFolder(_curFolder):
    for f in os.listdir(_curFolder):
        f_path = _curFolder + "/" + f
        if os.path.isdir(f_path):
           _recursiveFolder(f_path)
        else:
           fname,fext=os.path.splitext(f_path)
           if fext == OLD_EXT:
              editExt(f_path)


###########MAIN###############
if __name__=="__main__":
	_recursiveFolder(PATH)
	print("===[Author: Johny]===")
