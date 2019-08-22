# -*- coding: utf-8 -*-  
# 查看image下所有图片大小写，将包含大写字母的文件名show出来

import re,os
  
PATH = "../res/image"

def _checkcapalization(_file, _folder):
    for _letter in _file:
        if _letter.isupper():
           f_path = _folder + "/" + _file
           print "[]%s" %f_path
           break

def _recursiveFolder(_curFolder):
    for f in os.listdir(_curFolder):
        f_path = _curFolder + "/" + f
        if os.path.isdir(f_path):
           _recursiveFolder(f_path)
        else:
           _checkcapalization(f, _curFolder)

def foo():
    rootPath = os.path.abspath(PATH)
    print "<The List Of Files Contain Capitalization>"
    _recursiveFolder(rootPath)


if __name__ == "__main__":  
    print "===[check image capitalization now]==="
    foo()
    print("===[Author: Johny]===")