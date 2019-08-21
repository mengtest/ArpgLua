-- Name: UpdateManager
-- Func: 更新管理器
-- Author: Johny

local DOWNLOAD_STATUS = {
	kSTATUS_UNKNOW = 0,
	kSTATUS_DOWNLOAD_FAIL = 1,
	kSTATUS_DOWNLOAD_SUCC = 2,
	kSTATUS_DOWNLOAD_PROGRESS = 3,
	kSTATUS_VERIFY_FAIL = 4,
	kSTATUS_VERIFY_SUCC = 5,
	kSTATUS_UNZIP_START = 6,
	kSTATUS_UNZIP_FAIL = 7,
	kSTATUS_UNZIP_SUCC = 8,
}

UpdateManager = {}

--------------------------------静态方法--------------------------------
-- 跳转appstore
function UpdateManager:GotoAppStore(_url)
	EngineSystem:OpenUrl(_url)
end
-- 开始在线更新
function UpdateManager:UpdateOneVersion(_url, _md5, _newVersion)
	GUIEventManager:pushEvent("loadingResource", 0, string.format("版本V%s开始更新...", self.mTmpVersion))
	self.mCppAgent:StartUpdateOnline(_url, _md5)
	self.mTmpVersion = _newVersion
end
-- 插入需更新的版本
-- _update = {version, type, md5, url}
function UpdateManager:PushUpdateVersion(_update)
	table.insert(self.mUpdateList, _update)
end
-- 下载总入口
function UpdateManager:StartUpdate()
	-- 检查是否有需要appstore更新的
	for k,_update in pairs(self.mUpdateList) do
		if _update.type == 1 then
		   -- 提示去appstore下载
		return end
	end
	self:downloadUpdateList()
end
-- 下载更新列表
function UpdateManager:downloadUpdateList()
	if #self.mUpdateList == 0 then -- 没有需要更新的版本了，准备重新载入
		MessageBox:showMessageBox1("版本已更新，即将重新启动")
		local function restart()
			GUIEventManager:pushEvent("finishUpdating")
			GUISystem:hideLoading()
			EngineSystem:reloadLoadedLuaFiles()
		end
		nextTick_frameCount(restart, 3)
	return end
	for i = 1, #self.mUpdateList do
		local _update = self.mUpdateList[i]
		self:UpdateOneVersion(_update.url, _update.md5, _update.version)
		table.remove(self.mUpdateList, 1)
	break end
end
--------------------------------静态方法--------------------------------

function UpdateManager:init()
	cclog("===== UpdateManager:ctor ===== 1")
	-- 临时版本号，暂存内存中，下载成功解压后，写入沙盒
	self.mTmpVersion = nil
	-- 记录需要更新的版本
	self.mUpdateList = {}


	-- 初始化
	self.mCppAgent = UpdateAgent:GetLuaInstance()
	self:RegisterLuaHandler()
	cclog("===== UpdateManager:ctor ===== 2")
end


function UpdateManager:Tick()
	self.mCppAgent:Tick()
end

function UpdateManager:Release()
	UpdateAgent:FreeInstance()
	_G["UpdateManager"] = nil
 	package.loaded["UpdateManager"] = nil
 	package.loaded["NetSystem/UpdateManager"] = nil
end

-----------------------------回调----------------------------------
-- Status CallBack from Cpp
function UpdateManager:OnDownloadStatusListener(_status, _data, _errCode)
	-- cclog("=====UpdateManager:OnDownloadStatusListener===== status: " .. _status .. "===data: " .. _data .. "===errCode: " .. _errCode)
	if _status == DOWNLOAD_STATUS.kSTATUS_DOWNLOAD_FAIL then
		local function closeGame()
			EngineSystem:quitGame()
		end
		MessageBox:showMessageBox3(string.format("V%s下载失败,错误码:%d", self.mTmpVersion, _errCode), closeGame)
	elseif _status == DOWNLOAD_STATUS.kSTATUS_DOWNLOAD_SUCC then
	--	MessageBox:showMessageBox1("下载成功")
	elseif _status == DOWNLOAD_STATUS.kSTATUS_DOWNLOAD_PROGRESS then
		GUIEventManager:pushEvent("loadingResource", _data, string.format("正在更新V%s,进度:%s%%", self.mTmpVersion, _data))
	elseif _status == DOWNLOAD_STATUS.kSTATUS_VERIFY_FAIL then
		local function closeGame()
			EngineSystem:quitGame()
		end
		MessageBox:showMessageBox3(string.format("更新文件验证失败",_errCode), closeGame)
	elseif _status == DOWNLOAD_STATUS.kSTATUS_VERIFY_SUCC then
	--	MessageBox:showMessageBox1("验证成功")
	elseif _status == DOWNLOAD_STATUS.kSTATUS_UNZIP_START then
        GUIEventManager:pushEvent("loadingResource", _data, string.format("正在解压V%s,进度:%s%%", self.mTmpVersion, _data))
	elseif _status == DOWNLOAD_STATUS.kSTATUS_UNZIP_FAIL then
		local function closeGame()
			EngineSystem:quitGame()
		end
		MessageBox:showMessageBox3(string.format("解压失败,错误码:%d",_errCode), closeGame)
	elseif _status == DOWNLOAD_STATUS.kSTATUS_UNZIP_SUCC then
		GUIEventManager:pushEvent("loadingResource", 100, string.format("正在解压V%s,进度:100%%", self.mTmpVersion))
		EngineSystem:setGameVersion(self.mTmpVersion)
		UpdateManager:downloadUpdateList()
	end
end



--cpp 交互
function UpdateManager:RegisterLuaHandler()
	self.mCppAgent:RegisterLuaHandler(handler(UpdateManager, UpdateManager.OnDownloadStatusListener))
end