-- Name: UDPNetManager
-- Func: 网络管理器-----管理udpsocket
-- Author: Johny

UDPNetManager = {}
UDPNetManager.mRPacketHandlerList = {}

function UDPNetManager:init()
	cclog("===== UDPNetManager:init ===== 1")
	self.mCppAgent = NetAgent:GetLuaInstance()
	self.mCppAgent:RegisterLuaHandler_udp(handler(self, self.OnNetEventHandler))
	self.mCppAgent:SetUDPIPAddressAndPort("192.168.1.168", 11233)
    -----
	cclog("===== UDPNetManager:init ===== 2")
end

function UDPNetManager:Destroy()
	
end

function UDPNetManager:GetSPacket()
	return self.mCppAgent:GetSPacket_UDP()
end

function UDPNetManager:GetRPacket()
	return self.mCppAgent:GetRPacket_UDP()
end

--@来自C层的通知
function UDPNetManager:OnNetEventHandler(_type, _param1)
	_t = tonumber(_type)
	if _t == NetConfig.NE.kNET_RPACKET then
		cclog("=====UDPNetManager:OnNetEventHandler==A Packet Comming!!!")
		self:DispatchPacket()
	end
end

--@注册协议包的管理器
function UDPNetManager:RegisterPacketHandler(_type, _handler)
	self.mRPacketHandlerList[_type] = _handler
end

--@分发来自该服务器的包
function UDPNetManager:DispatchPacket()
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
		cclog("=====UDPNetManager:OnNetEventHandler==ERROR==_handler is nil,  PTYPE:   " .. ptype .. " " .. rpacket:GetInt() .. " " .. rpacket:GetString())
	end
end