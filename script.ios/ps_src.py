# -*- coding: utf-8 -*-  
# 把src下的所有文件递归加密

import xxtea

PATH = "../src"

def entry():
    # 1. find src folder
    rootPath = os.path.abspath(PATH)
    # 2. recursive src folder, and compile lua files
    xxtea.encryptEntry(rootPath)