-- Name: NetManager2
-- Func: 网络管理器-----管理socket2
-- 不负责生命周期的任何处理，只维护socket2相关部分,
-- 在NetManager创建后创建，在NetManger销毁前销毁
-- Author: Johny

require "NetSystem/PacketTyper2"

------------------局部变量---------------------
local _PING_INTERVAL_ = 5
-----------------------------------------------
NetManager2 = {}
NetManager2.mRPacketHandlerList = {}

function NetManager2:init()
	cclog("===== NetManager2:init ===== 1")
	self.mCppAgent = NetAgent:GetLuaInstance()
	self.mCppAgent:RegisterLuaHandler2(handler(self, self.OnNetEventHandler))
	----
	self.mIsConnected = false
    self.mPing_Serial_Num = 0	  -- ping 序列号
    self.mPing_Time = 0           -- 当前时间
    self.mLoginKey = 0            -- 子服务器登录秘钥
    -----
    self:registerPingFightServer()
    
    -- 注册一些服务器回包的回调
    self:RegisterPacketHandler(PacketTyper2.B2C_CONNECT_SERVER, handler(self, self.onLoginCallBack))
    self:RegisterPacketHandler(PacketTyper2.B2C_EXCEPTION_SERVER, handler(self,self.onExceptionFightserver))
    
	cclog("===== NetManager2:init ===== 2")
end

function NetManager2:Destroy()
	self.mIsConnected = false
end

--[[
	setter and getter
]]
function NetManager2:setLoginKey(_key)
	self.mLoginKey = _key
end

--@连接子服务器
function NetManager2:connectToSubServer(_ip, _port)
	-- doError("11==" .. _ip .. "==" .. _port)
	self.mCppAgent:setSubServerUrlAndPort(_ip, _port)
	self.mCppAgent:ConnectSubServer()
end

--@重新连接子服务器
function NetManager2:ReConnectSubServer()
	return self.mCppAgent:ReConnectSubServer()
end

--@强行断开与子服务器的连接
function NetManager2:ForceDisconnectSubServer()
	self.mCppAgent:ForceDisconnectSubServer()
end

function NetManager2:GetSPacket()
	return self.mCppAgent:GetSPacket2()
end

function NetManager2:GetRPacket()
	return self.mCppAgent:GetRPacket2()
end

--@来自C层的通知
function NetManager2:OnNetEventHandler(_type, _param1)
	_t = tonumber(_type)
	if _t == NetConfig.NE.kNET_RPACKET then
		cclog("=====NetManager2:OnNetEventHandler==A Packet Comming!!!")
		self:DispatchPacket()
	elseif _t == NetConfig.NE.kNET_SOCKETCONNECTFAIL then
		--MessageBox:showMessageBox1("子服务器连接失败")
	elseif _t == NetConfig.NE.kNET_SOCKETCLOSEDHINT then
		-- MessageBox:showMessageBox1("子服务器断开连接")
		-- doError("NetManager2:OnNetEventHandler")
		self.mIsConnected = false
		-- 异常断开，返回主城镇
		if not GUISystem:IsWindowShowed("LadderResultWindow") then
			if globaldata.olpvpType == 2 then
				local function xxx()
			        local function callFun()
			          GUISystem:HideAllWindow()
			          showLoadingWindow("HomeWindow")
			        end
			        FightSystem:sendChangeCity(5,callFun)
			    end
			    xxx()
			else
				if GUISystem:IsWindowShowed("LadderWindow") then
					GUISystem:GetWindowByName("LadderWindow"):NotifyCancelSearch(LADDERCANCEL.EXCEPTION)
				else
					local function CallFun( ... )
						GUISystem:HideAllWindow()
						FightSystem.mFightType = "none"
					end
					GUISystem:goTo("ladder",{BATTLE_RESULT.EXCEPTION,CallFun})
				end
			end
		end
	elseif _t == NetConfig.NE.kNET_SOCKETCONNECTSUCCESS then
		--MessageBox:showMessageBox1("子服务器连接成功")
		self.mIsConnected = true
		self:loginFightServer()
	end
end

--@注册协议包的管理器
function NetManager2:RegisterPacketHandler(_type, _handler)
	self.mRPacketHandlerList[_type] = _handler
end

-- 解注册协议包管理器
function NetManager2:UnregisterPacketHandler(_type)
	self.mRPacketHandlerList[_type] = nil
end

--@分发来自该服务器的包
function NetManager2:DispatchPacket()
    local rpacket = self:GetRPacket()
	rpacket:GetHead(2)
	rpacket:GetInt()
	rpacket:GetUShort()

    --@继续派发
    local ptype = rpacket:GetPacketType()
	local _handler = self.mRPacketHandlerList[ptype]
	if _handler then
		_handler(rpacket)
	else
		cclog("=====NetManager2:OnNetEventHandler==ERROR==_handler is nil,  PTYPE:   " .. ptype)
	end
end

------------------------逻辑性函数------------------------------
-- ping fightserver,同时作为心跳
function NetManager2:registerPingFightServer()
    local function ping()
        if not self.mIsConnected then return end
        self.mPing_Serial_Num = self.mPing_Serial_Num + 1
        if self.mPing_Serial_Num > 100 then self.mPing_Serial_Num = 1 end
        local packet = self:GetSPacket()
        packet:SetType(PacketTyper2.C2B_CONNECT_HEART_CLIENT)
        packet:PushUChar(self.mPing_Serial_Num)
        packet:Send(false)
        self.mPing_Time = os.clock()
    end
    local function onPingBack(msgPacket)
        local serialnum_back = msgPacket:GetUChar()
        if serialnum_back ~= self.mPing_Serial_Num then return end
        local _during_ping = os.clock() - self.mPing_Time
        -- cclog(string.format("NetSystem:pingGameServer---%.3fs", _during_ping))
      	GUIEventManager:pushEvent("updatePingStatus", _during_ping)
    end
    self:RegisterPacketHandler(PacketTyper2.B2C_CONNECT_HEART_SERVER, onPingBack)
    return nextTick_eachSecond(ping, _PING_INTERVAL_)
end

-- login Fight server
function NetManager2:loginFightServer()
	local packet = self:GetSPacket()
	packet:SetType(PacketTyper2.C2B_CONNECT_CLIENT)
	packet:PushString(NetSystem:getFirstPlayerID())
	packet:PushInt(self.mLoginKey)
    packet:Send(false)
end

-- 登录返回
function NetManager2:onLoginCallBack(msgPacket)
	local _logret = msgPacket:GetChar()
	if _logret == 0 then
	  --MessageBox:showMessageBox1("战斗服务器登录成功")
	  globaldata:onrequestOlpvpInfo()
	end
end

-- 收到战斗服务器异常通知
function NetManager2:onExceptionFightserver(msgPacket)
	local code = msgPacket:GetInt()
	self:ForceDisconnectSubServer()
end