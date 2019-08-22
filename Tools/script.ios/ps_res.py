# -*- coding: utf-8 -*-  
# 将本脚本放到bin目录下
# 1. 将spine下的所有png转换为pvr.ccz
# 2. 将scene下的所有png转为pvr.ccz
# 3. 将sound文件夹删除

# ios打包前使用
import os,string
from xml.etree.ElementTree import ElementTree,Element
import xml.dom.minidom
import xxtea

#图片目录
PATH_SPINE = r'../res/spine/binary'
PATH_SCENE = r'../res/scene'
PATH_EFFECT = r'../res/animation'
#碎图
PATH_IMAGE_NEW = r'../res/image/new'
PATH_IMAGE_HEROPIC = r'../res/image/heropic'
PATH_IMAGE_LOADING = r'../res/image/loading'
###大图###
PATH_IMAGE_PVE = r'../res/image/pve'
PATH_IMAGE_ICONITEM = r'../res/image/iconitem'
PATH_IMAGE_ICONHERO = r'../res/image/iconhero'
PATH_IMAGE_ICONEQUIP = r'../res/image/iconequip'
PATH_IMAGE_DIAMOND = r'../res/image/diamond'
PATH_IMAGE_ICONSKILL = r'../res/image/iconskill'

#后缀
JPG = r'.jpg'
PNG = r'.png'
PLIST = r'.plist'

#声音目录
PATH_SOUND = r'../res/sound'
PATH_SOUND_ANDROID = r'../res/sound_android'


#秘钥
KEY_TP = r'30528df65a165617344c844133e664c9'

###################Basic##############################
def deleteFile(_file):
	_cmd = r'rm %s' %_file
	os.system(_cmd)

def deleteForder(_forder):
	_cmd = r'rm -fr %s' %_forder
	os.system(_cmd)

#修改后缀
def editExt(_file, _newext):
    print("===[File]===%s" %_file)
    portion = os.path.splitext(_file)
    # 重新组合文件名和后缀名   
    newname = portion[0] + _newext   
    os.rename(_file,newname)

#修改后缀, .pvr.ccz 2 .png
def editExt_pvrccz2png(_file):
	print("===[File]===%s" %_file)
	os.rename(_file,_file.replace('.pvr.ccz', '.png'))

def img2pvrccz(_file):
	fname,fext=os.path.splitext(_file)
	_cmd = r'texturepacker %s \
	 --sheet %s.pvr.ccz \
	 --texture-format pvr2ccz \
	 --algorithm MaxRects \
	 --trim-mode Trim \
	 --premultiply-alpha \
	 --opt RGBA4444 \
	 --force-squared \
	 --content-protection %s\
	 --size-constraints AnySize' %(_file, fname, KEY_TP)
	os.system(_cmd)

def img2RGBA4444(_file):
	fname,fext=os.path.splitext(_file)
	_cmd = r'texturepacker %s \
	--sheet %s.pvr.ccz \
	--texture-format pvr2ccz \
	--algorithm MaxRects \
	--trim-mode None \
	--premultiply-alpha \
	--opt RGBA4444 \
	--disable-rotation \
	--border-padding 0 \
	--shape-padding 0 \
	--dither-fs-alpha \
	--content-protection %s\
	--size-constraints AnySize' %(_file, fname, KEY_TP)
	os.system(_cmd)

def xmlPng2pvrccz(file):
	dom = xml.dom.minidom.parse(file)
	root = dom.documentElement
	list = root.getElementsByTagName('string')
	for item in list:
		value = item.firstChild.data
		item.firstChild.data = value.replace(".png", ".pvr.ccz")
	f =  open(file,'w')
	dom.writexml(f)  
	f.close()
#######################################################
def plistTopvrccz(_path):
	for file in os.listdir(_path):
		fname,fext=os.path.splitext(file)
		_file = "%s/%s" %(_path, file)
		if fext == PNG:
			img2pvrccz(_file)
			deleteFile(_file)
		if fext == PLIST:
			xmlPng2pvrccz(_file)


def _recursiveFolder(_curFolder):
	if os.path.exists(_curFolder):
	    for f in os.listdir(_curFolder):
	        f_path = _curFolder + "/" + f
	        if os.path.isdir(f_path):
	           _recursiveFolder(f_path)
	        else:
	           fname,fext=os.path.splitext(f_path)
	           if fext == PNG:
	           	  img2RGBA4444(f_path)
	           	  editExt_pvrccz2png(f_path.replace('.png','.pvr.ccz'))
######################Basic##############################
# 找到spine文件夹下的png图片
# ps: role文件夹下只压缩effect图片
_SPINE_IGNORE_LIST_ = ["login_ani.png", "login_ani2.png", "zhuanpan.png", "yaoganhong.png", "yaoganlan.png"]
_SPINE_IGNORE_LIST_ROLE_ = ["140kulounv.png","baixifu.png","baiyizhongfennan.png","bianzi.png","ciweitou.png","dazhuang.png","gongjiannv.png","hongwaitao.png","huachenyi.png","kouzhao150.png","kouzhaomei.png","lvjiake.png","maodounan.png","maozidashu.png","mushi.png","nvlaoshi.png","piyinan.png","shuangdao.png", "gongjiannv_effect.png"]
_SPINE_IGNORE_LIST_HORSE = ["tiger_1.png", "tiger_2.png", "tiger_3.png"]
def handlePressPng(forder, igorelist):
	_forder = "%s/%s" %(PATH_SPINE, forder)
	for file in os.listdir(_forder):
		fname,fext=os.path.splitext(file)
		if fext == PNG:
			_file = "%s/%s/%s" %(PATH_SPINE, forder, file)
			if file in igorelist:
				editExt(_file, ".pvr.ccz")
			else:
			   	img2pvrccz(_file)
				deleteFile(_file)	


def findPngInSpine():
	print("=====[SPINE]==[img2pvrccz]=====")
	if os.path.exists(PATH_SPINE):
		for forder in os.listdir(PATH_SPINE):
			if forder != ".DS_Store":
				# role文件夹下只压缩effect图片
				if forder == "role":
				    handlePressPng(forder, _SPINE_IGNORE_LIST_ROLE_)
				elif forder == "horse":
					handlePressPng(forder, _SPINE_IGNORE_LIST_HORSE)														
				else:
					handlePressPng(forder, _SPINE_IGNORE_LIST_)

# 遍历场景的所有资源
def findPngInScene():
    print("=====[findPngInScene]=====")
    _recursiveFolder(PATH_SCENE)

#找到image下各文件夹的图片,转为RGBA4444，后缀不变
def findImgInImage():
	print("=====[Image/pve]==[big]=====")
	_recursiveFolder(PATH_IMAGE_PVE)
	print("=====[Image/loading]=====")
	_recursiveFolder(PATH_IMAGE_LOADING)
	print("=====[Image/heropic]======")
	_recursiveFolder(PATH_IMAGE_HEROPIC)
	print("=====[Image/iconitem]==[big]=====")
	_recursiveFolder(PATH_IMAGE_ICONITEM)
	print("=====[Image/iconhero]==[big]=====")
	_recursiveFolder(PATH_IMAGE_ICONHERO)
	print("=====[Image/iconequip]==[big]=====")
	_recursiveFolder(PATH_IMAGE_ICONEQUIP)
	print("=====[Image/diamond]==[big]=====")
	_recursiveFolder(PATH_IMAGE_DIAMOND)
	print("=====[Image/iconskill]==[big]===")
	_recursiveFolder(PATH_IMAGE_ICONSKILL)


#删除win32下的声音
def deleteSoundForder():
	print("=====[deleteSoundForder]====")
	deleteForder(PATH_SOUND)
	deleteForder(PATH_SOUND_ANDROID)

#走自行加密的文件
def xxteaEncrypt():
	print("=====[xxteaEncrypt]==[new]==")
	xxtea.encryptEntry(PATH_IMAGE_NEW)
	print("=====[xxteaEncrypt]==[effect]==")
	xxtea.encryptEntry(PATH_EFFECT)

###########MAIN###############
def entry():
	deleteSoundForder()
	findPngInSpine()
	findPngInScene()
	findImgInImage()
	xxteaEncrypt()