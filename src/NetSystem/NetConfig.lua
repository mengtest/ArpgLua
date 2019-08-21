-- Name: NetConfig
-- Func: 网络配置表
-- Author: Johny

module("NetConfig", package.seeall)


-- Update-Download-Status
UD = {}
UD.kSTATUS_UNKNOW = 0
UD.kSTATUS_DOWNLOAD_FAIL = 1
UD.kSTATUS_DOWNLOAD_SUCC = 2
UD.kSTATUS_DOWNLOAD_PROGRESS = 3
UD.kSTATUS_VERIFY_FAIL = 4
UD.kSTATUS_VERIFY_SUCC = 5
UD.kSTATUS_UNZIP_START = 6
UD.kSTATUS_UNZIP_FAIL = 7
UD.kSTATUS_UNZIP_SUCC = 8


-- Net-Event-Type
NE = {}
NE.kNET_SOCKETCONNECTFAIL = 0
NE.kNET_SOCKETCLOSEDHINT = 1
NE.kNET_SOCKETCONNECTSUCCESS = 2
NE.kNET_HTTPCONNECTFAIL = 3
NE.kNET_RPACKET = 4
NE.kNET_UPLOADFILE_SUCCESS = 5
NE.kNET_UPLOADFILE_FAIL = 6








function release()
	_G["NetConfig"] = nil
	package.loaded["NetConfig"] = nil
	package.loaded["NetSystem/NetConfig"] = nil
end