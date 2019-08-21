-- Name: NetSystem
-- Func: 网络系统
-- Author: Johny

--[[
登录流程说明：
1. 检查版本（http）
2. 连接游戏服务器
3. 登录
4. 获取角色列表
]]


require "NetSystem/NetConfig"
require "NetSystem/UpdateManager"
require "NetSystem/NetManager"
require "NetSystem/NetManager2"
require "NetSystem/UDPNetManager"
require "GUISystem/Widget/BottomChatPanel"

NetSystem = {}
NetSystem.mType = "NETSYSTEM"
-- 文件服务器链接
NetSystem.mFileURL = "http://120.132.57.123:8080/FileUploadDownload/UploadDownloadFileServlet"
-- 主服务器等待回包时间(s)
NetSystem.mBackDuring = 10



function NetSystem:Release()
    self.mUpdateManager:Release()
    self.mUpdateManager = nil
    -- NetManager2要在NetManager之前销毁
    self.mNetManager2:Destroy()
    self.mNetManager2 = nil
    self.mNetManager:Destroy()
    self.mNetManager = nil
    self.mUDPNetManager:Destroy()
    self.UDPNetManager = nil
    self.mServerList = {}
    self.mServerInfo = {}
    self.mCanAutoReconnect = false
    --
    _G["NetSystem"] = nil
    package.loaded["NetSystem"] = nil
    package.loaded["NetSystem/NetSystem"] = nil
end

function NetSystem:Init()
    cclog("=====NetSystem:Init=====1")
    -- init vars
    self.mUsn      = ""
    self.mPwd      = ""
    self.mServerList = {}
    self.mServerInfo = {}
    self.mCanAutoReconnect = false  -- 重连接标识
    self.mUploadFileFinishHandler = nil  -- 上传文件结束句柄
    self.mPlayerCount = 0       -- 角色数量
    --
    self.mUpdateManager = UpdateManager
    self.mUpdateManager:init()

    -- NetManager2在NetManager之后创建
    self.mNetManager = NetManager
    self.mNetManager:init()
    self.mNetManager:SetSPacketKey(79)
    self.mNetManager2 = NetManager2
    self.mNetManager2:init()
    self.mUDPNetManager = UDPNetManager
    self.mUDPNetManager:init()
    -----------注册登录账号回调事件---------
    local function registerMsgBack()
         self.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_LOGINACCOUNT_, handler(self,self.onLoginAccount))
         self.mNetManager:RegisterPacketHandler(PacketTyper._PTYPE_SC_PLAYERINFO_ALL_, handler(self,self.onBackPlayerInfo))
    end
    registerMsgBack()
    --注册聊天接收包事件
    BottomChatPanel:registerReceiveChatDataHandler()
	cclog("=====NetSystem:Init=====2")
end

function NetSystem:Tick()
    self.mUpdateManager:Tick()
    -- 通过Tick传到C层，NetManager2不需要重复tick
    self.mNetManager:Tick()
end

-- 设置用户名和密码
function NetSystem:setUsnAndPwd(usn, pwd)
    self.mUsn = usn
    self.mPwd = pwd
end

-- 设置角色数量
function NetSystem:setPlayerCount(_count)
    self.mPlayerCount = _count
end

-- 获取第一个玩家ID
function NetSystem:getFirstPlayerID()
    return globaldata.playerId
end

-- 设置重连接标识
function NetSystem:setCanAutoConnnectServer(_flag)
    self.mCanAutoReconnect = _flag
end

-- 是否可以自动登录
function NetSystem:canAutoConnectGameServer()
    return self.mCanAutoReconnect
end

-- 登录流程总接口
-- ps: 根据帐号类型分发
function NetSystem:loginDispatch()
    if AnySDKManager:isLoginByGuest() then
       self:loginByGuest()
    else
       AnySDKManager:loginBySDK()   
    end
end

-- 游客登录总接口
function NetSystem:loginByGuest()
    -- 游客登录，先连服务器
    self:connectToGameServer()   
end

-- 连接游戏主服务器
function NetSystem:connectToGameServer()
    GUISystem:showLoading()
    self.mNetManager:connectToGameServer(self.mServerInfo.ip, self.mServerInfo.port)
end

-- 连接战斗服务器
function NetSystem:connectToSubServer(_ipstr , _port)
    self.mNetManager2:connectToSubServer(_ipstr, _port)
end

-- 注册游戏服务器重连回调
function NetSystem:addGSReLoginFunc(key, func)
    self.mNetManager:addGSReLoginFunc(key, func)
end

function NetSystem:removeGSReLoginFunc(key)
    self.mNetManager:removeGSReLoginFunc(key)
end

-- 通知游戏服务器登录成功
function NetSystem:NotifyGSLoginFunc()
    self.mNetManager:NotifyLoginSuccess()
end

--------------------------------------------文件上传下载--------------------------------------------------
-- 上传文件
function NetSystem:uploadFile(_fileName, _calllback)
    local _fullPath = string.format("%s%s", cc.FileUtils:getInstance():getWritablePath(), _fileName)
    cclog("上传文件==" .. _fullPath)
    self.mUploadFileFinishHandler = _calllback
    self.mNetManager:uploadFile(_fullPath, self.mFileURL)
end

-- 下载文件
function NetSystem:downloadFile(_fileName)
    local _fullPath = string.format("%s/%s", cc.FileUtils:getInstance():getWritablePath(), _fileName)
    NetSystem.mNetManager:downloadFile(string.format("%s?fileName=%s", self.mFileURL, _fileName), _fullPath)
end

-- 上传错误日志
function NetSystem:uploadErrorLog()
    if GAME_MODE ~= ENUM_GAMEMODE.release then return end
    local function finishUpload()
       cclog("错误日志已上传...")
    end
    ErrFile(false)
    self:uploadFile("Err_log.txt", finishUpload)
    ErrFile(true)
end


-----------------------------------------网络收发包业务区域------------------------------------------------
-- 处理角色列表回复,1001
function NetSystem:handleRoleListResponse(msgPacket)
    NetSystem:setPlayerCount(msgPacket:GetUShort())
    for i = 1, NetSystem.mPlayerCount do
        local _playerID = msgPacket:GetString()
        -- 由于登录需要，临时存,1003返回时替换掉
        globaldata:setPlayerBaseData("playerId", _playerID)
    end
end

-- 请求公告
function NetSystem:requestAnnounce()
    GUISystem:showLoading()
    self.mNetManager:SetGateUrl(GATE_URL)
    local packet = NetSystem.mNetManager:GetSPacket()
    packet:SetType(PacketTyper._PTYPE_CG_GET_ANNOUNCE_)
    packet:SendHttp()
end

-- 检查版本
function NetSystem:requestCheckVersion()
    GUISystem:showLoading(true)
    self.mNetManager:SetGateUrl(GATE_URL)
    local packet = NetSystem.mNetManager:GetSPacket()
    packet:SetType(PacketTyper._PTYPE_CG_CHECK_VERSION_)
    packet:PushString(EngineSystem:getGameVersion())
    packet:SendHttp()
end

-- 获取服务器列表
function NetSystem:requestServerList()
    self.mNetManager:SetGateUrl(GATE_URL)
    local packet = NetSystem.mNetManager:GetSPacket()
    packet:SetType(PacketTyper._PTYPE_CG_REQUEST_SERVERLIST_)
    packet:PushString(EngineSystem:getGameVersion())
    packet:SendHttp()
end

-- 注册账户
function NetSystem:registerAccount()
    MessageBox:showMessageBox1("需要注册账户")
    -- 注册账户
    local packet = NetSystem.mNetManager:GetSPacket()
    packet:SetType(PacketTyper._PTYPE_CS_REGISTERACCOUNT_)
    -- 设备id
    local deviceId = EngineSystem:getDeviceUUID()
    packet:PushString(deviceId)
    packet:Send(false)
end

-- 登录游戏服务器
function NetSystem:loginGameServer()
    local ret1,ret2 = AnySDKManager:getUserNameAndPwd()
    local usn = ""
    local pwd = ""
    -- 没有账户则注册
    if ret1 == -1 then
        self:registerAccount()
    return end
    -- 得到用户名，密码
    if ret1 ~= 0 then
       usn = ret1
       pwd = ret2
    end
    -- 组织协议包
    local packet = NetSystem.mNetManager:GetSPacket()
    packet:SetType(PacketTyper._PTYPE_CS_LOGINACCOUNT_)
    packet:PushInt(AnySDKManager:getChannelId())                -- 游客
    packet:PushString( EngineSystem:getOS() )                   -- 系统
    packet:PushString( EngineSystem:getOSVersion() )            -- 系统版本
    packet:PushString( EngineSystem:getDeviceModel() )          -- 设备型号
    packet:PushString( EngineSystem:getDeviceUUID() )           -- UUID
    packet:PushString( EngineSystem:getDeviceMacAddr() )        -- MAC
    packet:PushChar( EngineSystem:getIOSjailbreak() )           -- 是否越狱
    packet:PushString(EngineSystem:getGameVersion())            -- 客户端版本号
    packet:PushString("")                                       -- 附加参数
    -- 渠道参数(各渠道不一样)
    packet:PushString(AnySDKManager:getSDKParam1())
    packet:PushString(AnySDKManager:getSDKParam2())
    for i = 1, 8 do
        packet:PushString("")                   -- 10个String
    end
    -- 渠道时，发空字符串
    packet:PushString(usn)   -- 用户名
    packet:PushString(pwd)   -- 密码

    -- 发送
    packet:Send(false)
end

-- 帐号密码本地检查
function NetSystem:checkUsnAndPwd()
    if not self.mUsn or self.mUsn == "" then
       MessageBox:showMessageBox1("帐号不能为空!")
    return false end 
    if not self.mPwd or self.mPwd == "" then
       MessageBox:showMessageBox1("密码不能为空!")
    return false end

    return true
end

-- 用账号密码登录游戏服务器
function NetSystem:loginGameServer_account()
    if not self:checkUsnAndPwd(self.mUsn, self.mPwd) then return end
    -----
    local packet = NetSystem.mNetManager:GetSPacket()
    packet:SetType(PacketTyper._PTYPE_CS_LOGINACCOUNT_)
    packet:PushInt(1)                                           -- 游客
    packet:PushString( EngineSystem:getOS() )                   -- 系统
    packet:PushString( EngineSystem:getOSVersion() )            -- 系统版本
    packet:PushString( EngineSystem:getDeviceModel() )          -- 设备型号
    packet:PushString( EngineSystem:getDeviceUUID() )           -- UUID
    packet:PushString( EngineSystem:getDeviceMacAddr() )        -- MAC
    packet:PushChar( EngineSystem:getIOSjailbreak() )           -- 是否越狱
    packet:PushString(EngineSystem:getGameVersion())            -- 客户端版本号
    packet:PushString("")                                       -- 附加参数

    for i = 1, 10 do
        packet:PushString("")                   -- 10个String
    end

    packet:PushString(self.mUsn)   -- 用户名
    packet:PushString(self.mPwd)   -- 密码

    -- 发送
    packet:Send(false)
end

-- 请求角色列表-1000
function NetSystem:requestRoleList()
    local packet = self.mNetManager:GetSPacket()
    packet:SetType(PacketTyper._PTYPE_CS_REQUEST_PLAYERLIST_)
    packet:Send(false)
end

-- 玩家登录请求-1004
function NetSystem:requestPlayerLogin()
    local packet = NetSystem.mNetManager:GetSPacket()
    packet:SetType(PacketTyper._PTYPE_CS_REQUEST_PLAYERLOGIN_)
    packet:PushString(NetSystem:getFirstPlayerID())
    packet:Send(false)
end

-------------------------------回调-------------------------------------
-- 上传文件结束回调
function NetSystem:onUploadFileFinish(_isSuccess, _fileName)
    if _isSuccess then 
        -- 上传文件成功
        if self.mUploadFileFinishHandler then
           self.mUploadFileFinishHandler(_fileName)
           self.mUploadFileFinishHandler = nil
        end
    else
        -- 上传文件失败
    end
end


-- 登录账户回包
function NetSystem:onLoginAccount(msgPacket)
    local ret = msgPacket:GetUShort()
    if 0 == ret then
        MessageBox:showMessageBox1("登入帐号成功~")
        if not NetSystem:canAutoConnectGameServer() then -- 不是断线重连 
            --  1000
            self:requestRoleList()
        else -- 断线重连
            --  1004
            self:requestPlayerLogin()
        end
    end
end

-- 返回玩家信息1003
function NetSystem:onBackPlayerInfo(msgPacket)
    GUISystem:hideLoading()
    self:setPlayerCount(1)
    local function handleLoginWindow()
        GUISystem:HideAllWindow()
        showLoadingWindow("HomeWindow","LoginWindow")
        local _cityid = globaldata:getCityHallData("cityid")
        FightSystem.mHallManager:OnPreEnterCity(_cityid)
    end
    local function handleRoleselWindow()
       globaldata:onEnterShowGuanqiaBattle()
    end

    -- 是否处于新手流程  add by wangsd 15-12-18
    local function isInGuide() 
        local chapterObj = globaldata.chapterList[1][1]
        local sectionObj = chapterObj.mSectionList[1]
        if 0 == sectionObj.mCurStarCount and not FightSystem:isEnabledShowGuanqia() then
            return true
        else
            return false
        end
    end

    -- 初始化所有数据
    globaldata:initFromServerPacket(msgPacket)
    -- 处理所在窗口该处理的功能
    if not self:canAutoConnectGameServer() then
        
        if not isInGuide() then
               handleLoginWindow()
        else
              handleRoleselWindow()
        end
    end

    -- 回调曾经注册登录成功回调的func
    self:NotifyGSLoginFunc()

    -- 记录玩家账户信息
    AnySDKManager:td_accountinfo(globaldata:getPlayerBaseData("name"), globaldata:getPlayerBaseData("level"), self.mServerInfo.name)

    -- 记录登录成功标记
    self.mNetManager.mIsLoginedSuccess = true
end