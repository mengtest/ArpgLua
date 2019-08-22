# -*- coding: utf-8 -*-  
# 指定文件夹（递归）所有指定后缀文件，copy

import sys,os
import shutil

SRC_FILE_SUFFIX = r'cs'
DST_FILE_SUFFIX = r'js'
SRC_PATH = r'Resturant/Client/MProject/Assets/Scripts/Match3'
DST_PATH = r'Match3WithCSharp/Match3'


def change_file_name(path):
	path_arr = path.split('.')
	if path_arr[-1] == SRC_FILE_SUFFIX:
	    dst_file = '%s.%s'%(path_arr[0], DST_FILE_SUFFIX)
	    return dst_file
	else:
		return ""


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
	            shutil.copyfile(temp_path, dst_path)
        else:
            newDstpath = os.path.join(dstpath, temp)
            os.mkdir(newDstpath)
            traverse(temp_path, newDstpath)


def foo():
	traverse(SRC_PATH, DST_PATH)


if __name__=="__main__":
    foo()