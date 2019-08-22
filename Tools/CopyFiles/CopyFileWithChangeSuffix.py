# -*- coding: utf-8 -*-  
# 指定文件夹（递归）所有指定后缀文件，copy

import sys,os

SRC_FILE_SUFFIX_1 = r'cs'
SRC_FILE_SUFFIX_2 = r''
DST_FILE_SUFFIX_1 = r'js'
DST_FILE_SUFFIX_2 = r''

SRC_PATH = r'Resturant/Client/MProject/Assets/Scripts'
DST_PATH = r'Match3_js/Scripts'


def change_file_name(path):
    path_arr = path.split('.')
    dst_file = ''
    if path_arr[-1] == SRC_FILE_SUFFIX_1:
        dst_file = '%s.%s'%(path_arr[0], DST_FILE_SUFFIX_1)
    elif path_arr[-1] == SRC_FILE_SUFFIX_2:
        dst_file = '%s.%s'%(path_arr[0], DST_FILE_SUFFIX_2)

    return dst_file

def copyFile(temp_path, dst_path):
    theFile = file(temp_path, "r+")
    fp = open(dst_path, 'w+')
    cc = ''
    for s in theFile.readlines():
        cc = cc + s

    fp.write(cc)
    fp.close()
    


def traverse(path,dstpath):
    fs = os.listdir(path)
    for temp in fs:
        '''
        这里temp是不包含path字符串的相对目录或文件
        例如：path=D:\a， 且temp.txt目录为D:\a\temp.txt,则temp=temp.txt
        '''
        temp_path = os.path.join(path, temp) #连接字符串，形成完整文件路径
        if not os.path.isdir(temp_path):
            dst_file = change_file_name(temp)
            if dst_file != "":
	            dst_path = os.path.join(dstpath, dst_file)
	            print('文件：%s'%temp_path)
	            copyFile(temp_path, dst_path)
        else:
            newDstpath = os.path.join(dstpath, temp)
            os.mkdir(newDstpath)
            traverse(temp_path, newDstpath)


def foo():
	traverse(SRC_PATH, DST_PATH)


if __name__=="__main__":
    foo()