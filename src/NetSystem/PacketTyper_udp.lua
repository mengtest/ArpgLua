-- Name: PacketTyper_udp
-- Func: udp的协议号
-- Author: Johny

module("PacketTyper_udp", package.seeall)


_PTYPE_UNKNOWN_                   =  0

--

function release()
	_G["PacketTyper_udp"] = nil
	package.loaded["PacketTyper_udp"] = nil
	package.loaded["NetSystem/PacketTyper_udp"] = nil
end