-- Name: IAPSystem
-- Func: 支付系统
-- Author: Johny

local IAPSystem = {}
IAPSystem.mType = "IAPSYSTEM"
IAPSystem.mCppAgent = nil


-----------------------@来自cpp的消息号-------------------------
local kPAYFAILED = 1
local kPAYSUCC = 2
local kVERIFYFAILED = 3
local kVERIFYFSUCC = 4
local kINSERTPAYMENT = 5	
----------------------------------------------------------------


function IAPSystem:Init()
    cclog("=====IAPSystem:Init=====1")

    --
	self.mCppAgent = IAPAgent:GetLuaInstance()
	self:RegisterLuaHandler()


	cclog("=====IAPSystem:Init=====2")
end


function IAPSystem:Tick()

end

function IAPSystem:Release()
	--
	IAPAgent:FreeInstance()

	_G["IAPSystem"] = nil
 	package.loaded["IAPSystem"] = nil
 	package.loaded["IAPSystem/IAPSystem"] = nil
end


function IAPSystem:RegisterLuaHandler()
	self.mCppAgent:RegisterLuaHandler(handler(IAPSystem, IAPSystem.OnIAPEventHandler))
end


function IAPSystem:Pay(_productId, _productName, _productDesc, _productMoney, _chargePoint, _IAPId)
	self.mCppAgent:pay(_productId, _productName, _productDesc, _productMoney, _chargePoint, _IAPId)
end

function IAPSystem:Verify(_IAPId)
	self.mCppAgent:verify(_IAPId)
end


--@监听来自cpp的事件
function IAPSystem:OnIAPEventHandler(_type)
	cclog("=====IAPSystem:OnIAPEventHandler==_type:  " .. _type)
	if _type == kPAYFAILED then

	elseif _type == kPAYSUCC then

	elseif _type == kVERIFYFAILED then

	elseif _type == kVERIFYFSUCC then

	elseif _type == kINSERTPAYMENT then

	end
end



--@监听事件
function IAPSystem:onEventHandler(event)

end




return IAPSystem