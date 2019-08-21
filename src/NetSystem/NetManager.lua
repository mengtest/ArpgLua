-- Name: NetManager
-- Func: 网络管理器---管理网关连接，主服务器连接,文件服务器连接等
-- Author: Johny

require "NetSystem/PacketTyper"

NetManager = {}
NetManager.mRPacketHandlerList = {}

function NetManager:init()
	cclog("===== NetManager:init ===== 1")
	self.mCppAgent = NetAgent:GetLuaInstance()
	self.mCppAgent:RegisterLuaHandler(handler(self, self.OnNetEventHandler))
	-----
	self.mIsLoginedSuccess = false  -- 收到1003才算登录成功
	self.mKeepAliveHandler = nil  -- 心跳定时器句柄
	-- 重新登录回调Map
	self.mReLoginFuncMap = {}
	-----
	self:enableKeepAlive()
	self:RegisterPacketHandler(PacketTyper._PTYPE_SC_ERRORCODE_, handler(self, self.onRecieveErrorCodeFromServer))
	cclog("===== NetManager:init ===== 2")
end

function NetManager:Destroy()
	self.mIsLoginedSuccess = false
	self:cancelKeepAlive()
	NetAgent:FreeInstance()
end

function NetManager:Tick()
	self.mCppAgent:Tick()
end

--@连接游戏主服务器
function NetManager:connectToGameServer(_ip, _port)
	self.mCppAgent:setGameServerUrlAndPort(_ip, _port)
	self.mCppAgent:ConnectGameServer()
end

--@重新连接游戏服务器
function NetManager:ReConnectGameServer()
	GUISystem:showLoading(true)
	self.mCppAgent:ReConnectGameServer()
end

--@强行断开与游戏服务器的连接
function NetManager:ForceDisconnectGameServer()
	self.mCppAgent:ForceDisconnectGameServer()
	NetSystem.mPlayerCount = 0
end

--@设置Gate URL
function NetManager:SetGateUrl(_url)
	self.mCppAgent:SetGateUrl(_url)
end

function NetManager:GetGateUrl()
	return self.mCppAgent:GetGateUrl()
end

--@设置上行秘钥
function NetManager:SetSPacketKey(_key)
	self.mCppAgent:SetSPacketKey(_key)
end

function NetManager:GetSPacket()
	return self.mCppAgent:GetSPacket()
end

function NetManager:GetRPacket()
	return self.mCppAgent:GetRPacket()
end

-- 上传文件
function NetManager:uploadFile(_file, _url)
	self.mCppAgent:uploadFile(_file, _url)
end

-- 下载文件
function NetManager:downloadFile(_url, _file)
	self.mCppAgent:downloadFile(_url, _file)
end

--@处理网络底层传来的各种事件
function NetManager:OnNetEventHandler(_type, _param1)
	_t = tonumber(_type)
	if _t == NetConfig.NE.kNET_RPACKET then --收到网络包
		cclog("=====NetManager:OnNetEventHandler==A Packet Comming!!!")
		self:DispatchPacket() 
	elseif _t == NetConfig.NE.kNET_SOCKETCONNECTFAIL or _t == NetConfig.NE.kNET_SOCKETCLOSEDHINT then -- socket断开或连接失败
		GUISystem:hideLoading()
		cclog("Socket is closed!!!")
		self:onGameServerSocketClosed()
	elseif _t == NetConfig.NE.kNET_SOCKETCONNECTSUCCESS then --连接成功提示
		self:onConnectGameServerSuccess()
	elseif _t == NetConfig.NE.kNET_HTTPCONNECTFAIL then --Http连接失败提示
		GUISystem:hideLoading()
		MessageBox:showMessageBox1("连接服务器失败~请检查网络是否通畅~")
	elseif _t == NetConfig.NE.kNET_UPLOADFILE_SUCCESS then --上传文件成功
		GUISystem:hideLoading()
		cclog("Upload File Success!!==" .. _param1)
		NetSystem:onUploadFileFinish(true, _param1)		
	elseif _t == NetConfig.NE.kNET_UPLOADFILE_FAIL then --上传文件失败
		GUISystem:hideLoading()
		cclog("Upload File Fail!!")
		NetSystem:onUploadFileFinish(false)
	end
end

-- socket断开回调---新手引导之中
function NetManager:onSocketClosed_DuringNewGuide()
	self:popHintLogoutGame(1, "断开服务器连接")
end

-- socket断开回调---普遍情况
function NetManager:onSocketClosed_Common()
	-- 网络异常断开
	if self.mIsLoginedSuccess then
		self.mIsLoginedSuccess = false
		self:popHintLogoutGame(2, "服务器断开连接，是否尝试重连？")
	else--未收到1003的断网直接回主界面
		self:popHintLogoutGame(1, "断开服务器连接")
	end
end

-- socket断开回调---战斗中
function NetManager:onSocketClosed_DuringFight()
	self.mIsLoginedSuccess = false
end

-- socket断开后游戏内逻辑处理
function NetManager:handleGameLogicAfterSocketClosed()
    -- 通知主城镇清空在线玩家
	HallManager:clearOPDataListAndUnloadAllOP()
end

-- socket断开回调---总
function NetManager:onGameServerSocketClosed()
	-------游戏内逻辑处理
	NetManager:handleGameLogicAfterSocketClosed()
	-------处理网络问题
	-- if GUISystem:IsWindowShowed("FightWindow") then
	-- 	NetManager:onSocketClosed_DuringFight()
	if GuideSystem:isInGuidingState() then
		NetManager:onSocketClosed_DuringNewGuide()
	else
		NetManager:onSocketClosed_Common()		
	end
end


-- 连接游戏服务器成功回调
function NetManager:onConnectGameServerSuccess()
	MessageBox:showMessageBox1("服务器连接成功")
	if BANSHU_ENABLED and NetSystem.mUsn ~= "" then
		NetSystem:loginGameServer_account(NetSystem.mUsn, NetSystem.mPwd)
	else
		NetSystem:loginGameServer()
	end
end

--@服务器发来错误信息
local _ERRCODE_SERVER_ = {
	_ACCOUNT_UNAVAILABLE = 1,  -- 封号
	_LOGIN_REPEAT = 2,		   -- 重复登录
	_DATA_WRONG = 3,		   -- 数据异常
}
function NetManager:onRecieveErrorCodeFromServer(_packet)
	-- 先断开socket
	self:ForceDisconnectGameServer()
	-- 提示异常
	local _errCode = _packet:GetUShort()
	local _reseaon = _packet:GetString()
	if _errCode == _ERRCODE_SERVER_._ACCOUNT_UNAVAILABLE then
		-- 帐号封停特殊处理，出现在发1004之后
		GUIEventManager:pushEvent("failToGetPlayerInfo")
		self:popHintLogoutGame(3, _reseaon)
	else
		self:popHintLogoutGame(1, _reseaon)
	end
end

--弹出提示退出的弹窗,在socket已断开之后
--@_type: 1: 单个按钮，只能退回主界面  2: 两个按钮，可选重新连接 3: 1个按钮，点击取消
function NetManager:popHintLogoutGame(_type, _hint)
	if _type == 1 then
		local function func()
			GUISystem:BackToLoginWindow()
		end
		MessageBox:showMessageBox3(_hint, func)
	elseif _type == 2 then
		local function func1()
			self:ReConnectGameServer()
		end
		local function func2()
			GUISystem:BackToLoginWindow()
		end
		MessageBox:showMessageBox2(_hint, func1, func2)
	elseif _type == 3 then
		local function func()
			
		end
		MessageBox:showMessageBox3(_hint, func)
	end
end

--@注册协议包的管理器
function NetManager:RegisterPacketHandler(_type, _handler)
	self.mRPacketHandlerList[_type] = _handler
end

-- 解注册协议包管理器
function NetManager:UnregisterPacketHandler(_type)
	self.mRPacketHandlerList[_type] = nil
end

-- 注册广播消息处理
function NetManager:onRecieveBroadcastPacket(msgPacket)
	local strMsg = msgPacket:GetString()
	MessageBox:showMessageBox1(strMsg)
	GUISystem:hideLoading()
end

-- 注册Tips消息处理
function NetManager:onRecieveTipsPacket(msgPacket)
	local showType = msgPacket:GetChar()
	local showTips = msgPacket:GetString()
	GUISystem.mTipsWidget:pushTips(showTips)
end

function NetManager:DispatchPacket()
	if GameApp.mHasEnterBackGround then return end
    local rpacket = self:GetRPacket()

    --@如果是tcp的，需要砍头
    if rpacket:IsHttpPacket() == false then
    	rpacket:GetHead(2)
    	rpacket:GetInt()
    	rpacket:GetUShort()
    end

    --@继续派发
    local ptype = rpacket:GetPacketType()
    if PacketTyper._PTYPE_SC_BROADCAST_MESSAGE_ == ptype then	-- 广播
    	self:onRecieveBroadcastPacket(rpacket)
	else
		local _handler = self.mRPacketHandlerList[ptype]
		if _handler then
			cclog("分发包:" .. ptype)
			_handler(rpacket)
		else
			cclog("=====NetManager:OnNetEventHandler==ERROR==_handler is nil,  PTYPE:   " .. ptype)
		end
	end
end


------------------------逻辑性函数------------------------------

-- 心跳协议
function NetManager:enableKeepAlive()
    local function sendPacket()
        if not self.mIsLoginedSuccess then return end
        local packet = self:GetSPacket()
        packet:SetType(PacketTyper._PTYPE_CS_REQUEST_KEEPALIVE)
        packet:Send(false)
    end
    self.mKeepAliveHandler = nextTick_eachSecond(sendPacket, 30)
end

function NetManager:cancelKeepAlive()
    if not self.mKeepAliveHandler then return end
    G_unSchedule(self.mKeepAliveHandler)
end

function NetManager:addGSReLoginFunc(key, func)
	self.mReLoginFuncMap[key] = func
end

function NetManager:removeGSReLoginFunc(key)
	self.mReLoginFuncMap[key] = nil
end
-- 以服务器回1003包为准
function NetManager:NotifyLoginSuccess()
	for k,func in pairs(self.mReLoginFuncMap) do
		func()
	end
end