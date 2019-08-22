# -*- coding: utf-8 -*-  
# 把src下的所有文件递归加密

import sys,os
sys.path.append("..")
import xxtea

PATH = "../../src"

def foo():
    # 1. find src folder
    rootPath = os.path.abspath(PATH)
    # 2. recursive src folder, and compile lua files
    xxtea.encryptEntry(rootPath)


if __name__=="__main__":
    foo()