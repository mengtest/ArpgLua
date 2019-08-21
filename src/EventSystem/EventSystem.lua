-- Name: EventSystem
-- Func: 事件系统
-- Author: Johny

-- system list
require "EngineSystem/EngineSystem"
require "NetSystem/NetSystem"
require "DBSystem/DBSystem"
require "GUISystem/GUISystem"
require "FightSystem/FightSystem"
require "ResSystem/SoundSystem"
require "ResSystem/TextureSystem"
require "EngineSystem/NotifySystem"

EventSystem = {}
EventSystem.mType = "EVENTSYSTEM"
EventSystem.mSystems = {}


function EventSystem:Init()
    cclog("=====EventSystem:Init=====1")

    -- 初始化GUIEvent
    require("GUISystem/GUIEventManager")
    -- 加载WidgetPool
    require("GUISystem/GUIWidgetPool")


    -- Register All System
    self:RegisterSystem(EngineSystem)
    self:RegisterSystem(NetSystem)
    self:RegisterSystem(DBSystem)

    require("NoticeSystem/NoticeSystem")

    self:RegisterSystem(TextureSystem)
    self:RegisterSystem(SoundSystem)
    self:RegisterSystem(GUISystem)
    require "GuideSystem/GuideSystem"
    self:RegisterSystem(FightSystem)
    self:RegisterSystem(NotifySystem)
    self:RegisterSystem(require("StorySystem/StorySystem"))
    self:RegisterSystem(require("IAPSystem/IAPSystem"))


    

    --At Last
    require "EventSystem/Event"

	cclog("=====EventSystem:Init=====2")
end

function EventSystem:Release()
    for k,v in pairs(self.mSystems) do 
        v:Release()
    end
    --
    _G["EventSystem"] = nil
    package.loaded["EventSystem"] = nil
    package.loaded["EventSystem/EventSystem"] = nil
end

function EventSystem:Tick(delta)
    for k,v in pairs(self.mSystems) do 
        v:Tick(delta)
    end
end

function EventSystem:RegisterSystem(system)
	system:Init()
	self.mSystems[system.mType] = system
end


function EventSystem:PushEvent(event, func)
	local sys = self.mSystems[event.mType]
	if sys ~= nil then
		sys:onEventHandler(event, func)
	else
		cclog("=====EventSystem:PushEvent====ERROR, System is not Existed. Event Name: " .. event.mType)
	end
end

