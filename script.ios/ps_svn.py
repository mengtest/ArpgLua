#-*- coding: UTF-8 -*-
# Name: ps_svn
# Func: SVN相关操作
# 1.更新SVN的内容，使本地达到最新的代码资源
# 2.上传包到SVN
# Author: Johny

import os

#################配置信息###########################
USN = 'yinqiang'
PWD = 'yinqiang'
PATH_UP = '/Users/beita/Project/Beta/bin'
# PATH_CI_IPA = 'D:/Data/Project/Beta/BetaSVN/trunk/product/debug/ipa'
# PATH_CI_APK = 'D:/Data/Project/Beta/BetaSVN/trunk/product/debug/apk'
# MSG_CI_IPA = 'New Ipa'
# MSG_CI_APK = 'New Apk'
####################################################

def _updateAll():
	cmd = 'svn --username %s --password %s up %s' % (USN, PWD, PATH_UP)
	if os.system(cmd) != 0:
		raise Exception("[ERROR] Update SVN Failed.")
		return -1


def _commitIPA():
	#1.add new ipa
	cmd = 'svn --username %s --password %s add %s/* --force ' % (USN, PWD, PATH_CI_IPA)
	if os.system(cmd) != 0:
		raise Exception("[ERROR] SVN Add Ipa Failed.")
		return -1

	#2.ci new ipa
	cmd = 'svn --username %s --password %s ci -m \"%s\" %s' % (USN, PWD, MSG_CI_IPA, PATH_CI_IPA)
	if os.system(cmd) != 0:
		raise Exception("[ERROR] SVN Commit Ipa Failed.")
		return -1


def _commitAPK():
	#1.add new apk
	cmd = 'svn --username %s --password %s add %s/* --force ' % (USN, PWD, PATH_CI_APK)
	if os.system(cmd) != 0:
		raise Exception("[ERROR] SVN Add Apk Failed.")
		return -1

	#2.ci new apk
	cmd = 'svn --username %s --password %s ci -m \"%s\" %s' % (USN, PWD, MSG_CI_APK, PATH_CI_APK)
	if os.system(cmd) != 0:
		raise Exception("[ERROR] SVN Commit Apk Failed.")
		return -1


def Update():
	return _updateAll()


def Commit():
	_commitIPA()
	_commitAPK()