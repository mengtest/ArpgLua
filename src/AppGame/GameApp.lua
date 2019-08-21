-- Name: GameApp
-- Func: 游戏入口
-- Author: Johny


-- avoid memory leak
collectgarbage("collect")
collectgarbage("setpause", 100)
collectgarbage("setstepmul", 5000)

--
require "AppGame/GameQuickAPI"
require "AnySDK/AnySDKManager"


GameApp = {}
GameApp.mSystemList = {}
GameApp.mTickHandler = -1
GameApp.mIsPaused = false
GameApp.mHasEnterBackGround = false


--@private
local function _loadLuaFiles()
    require "EventSystem/EventSystem"
end

local function _initSystems()
    EventSystem:Init()
end

local function _initSearchPath()
    local _respaths  = { "res/fonts", "res/image/new"}
    for i = 1,#_respaths do
        cc.FileUtils:getInstance():addSearchPath(_respaths[i])
    end
end

--------------------------------------------------------------
-- 暂停游戏进程(外部使用)
function GameApp:Pause()
    cc.Director:getInstance():pause()
    GameApp.mIsPaused = true 
end

-- 恢复游戏进程(外部使用)
function GameApp:Resume()
    cc.Director:getInstance():resume()
    GameApp.mIsPaused = false
end

--------------------------------------------------------------
function GameApp:Init()
    cclog("GameApp:Init 1")
    --
    _loadLuaFiles()
    _initSystems()
    _initSearchPath()
    cclog("GameApp:Init 2")
    --
    AnySDKManager:init()
    cclog("GameApp:Init 3")
    --
    self:GameStart()

    cclog("GameApp:Init 4")
end


local function Tick(delta)
    EventSystem:Tick(delta)
end

-- 游戏准备内部重启
function GameApp:PreRestart()
    cclog("GameApp:PreRestart")
    CommonAnimation.StopBGMAndAllEffect()
    TextureSystem:UnLoadAllTexture()
    EventSystem:PushEvent(Event.GUISYSTEM_HIDE_LOGINWINDOW)
    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(GameApp.mTickHandler)
end
-- 应用关闭
function GameApp:Closed()
    cclog("[GameApp:Destroy] Game Has Quit!")
    CommonAnimation.StopBGMAndAllEffect()
    AnySDKManager:destroy()
    EventSystem:Release()
    collectgarbage("collect")
end
-- 游戏开始
function GameApp:GameStart()
    cclog("GameApp:GameStart")
    require "AppGame/globaldata"
    --- 安卓先show launchwindow
    if EngineSystem:getOS() == "ANDROID" then
        EventSystem:PushEvent(Event.GUISYSTEM_SHOW_ANDROIDLAUNCHWINDOW)
        local function showLoginWindow()
            EventSystem:PushEvent(Event.GUISYSTEM_HIDE_ANDROIDLAUNCHWINDOW)
            EventSystem:PushEvent(Event.GUISYSTEM_SHOW_LOGINWINDOW)
        end
        nextTick_frameCount(showLoginWindow, 3)
    else
        EventSystem:PushEvent(Event.GUISYSTEM_SHOW_LOGINWINDOW)
    end
end

--
-- Main Entry For Lua
local function main()
    -- 开启logFile
    LogFile(true)

    cclog("GameApp:main 1")
    GameApp:Init()
    GameApp.mTickHandler = cc.Director:getInstance():getScheduler():scheduleScriptFunc(Tick, 0, false)
    cclog("GameApp:main 2")
end


--
-------------------@来自Cpp的调用---------------------------------------
--

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    error(msg)
end


--@GameQuit from Cpp
function GameQuit()
    cclog("GameQuit")
    -- 注册通知
    NotifySystem:RegisterAllNotification()
    ---
    GameApp:Closed()
    LogFile(false)
end

--@GameEnterBackground from Cpp
function GameEnterBackground()
    GameApp.mHasEnterBackGround = true
    cclog("GameEnterBackground")
    -- 停止影子渲染
    SpineShadowRenderManager:stopAllDrawed(true)
    -- 注册通知
    NotifySystem:RegisterAllNotification()
    -- 暂停游戏
    cc.Director:getInstance():pause()
end

--@GameEnterForeground from Cpp
function GameEnterForeground()
    cclog("GameEnterForeground")
    -- 取消注册通知
    NotifySystem:ClearAllNotification()
    -- 如果进入背景前主动暂停，则继续暂停
    if GameApp.mIsPaused then
        cc.Director:getInstance():pause()
    else
        -- 恢复游戏
        cc.Director:getInstance():resume()
    end
    -- 开启影子渲染
    local function enableDrawShadow()
        SpineShadowRenderManager:stopAllDrawed(false)
    end
    nextTick(enableDrawShadow)
    GameApp.mHasEnterBackGround = false
end
