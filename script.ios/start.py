#-*- coding: UTF-8 -*-
# 包括svn更新，跑脚本压图，代码加密等

import ps_svn,ps_res,ps_src

PATH_IMAGE = r'../res/image'
PATH_SPINE = r'../res/spine/binary'
PATH_SCENE = r'../res/scene'
PATH_EFFECT = r'../res/animation'
PATH_SRC = r'../src'


def handle_svn():
	print("================================")
	print("开始更新SVN")
	print("================================")
	# TP加密部分 #
	ps_res.deleteForder(PATH_IMAGE)
	ps_res.deleteForder(PATH_SPINE)
	ps_res.deleteForder(PATH_SCENE)

	# 手动加密部分 #
	ps_res.deleteForder(PATH_EFFECT)
	# ps_res.deleteForder(PATH_SRC)

	
	ps_svn.Update()

def handle_res():
	print("================================")
	print("开始压缩并加密图片资源")
	print("================================")
	ps_res.entry()

def handle_src():
	print("================================")
	print("开始加密代码")
	print("================================")
	ps_src.entry()

def foo():
	handle_svn()
	handle_res()
	# handle_src()
	print("================================")
	print("Finish!")
	print("Author: Johny")
	print("================================")


if __name__=="__main__":
    foo()