-- Name: EngineSystem
-- Func: 引擎系统,需要在C++层分ios，安卓，win32来实现
-- Author: Johny


EngineSystem = {}
EngineSystem.mType = "ENGINESYSTEM"

------------------------@配置表---------------------------------
--
--  必须与cpp层定义的一致
EngineSystem._DOWNLOAD_FOLDER_ = 'download'
--
--@从userdefault取版本号的key
--#上线后不能再改变
local _VERSION_KEY_UD_ = '_VERSION_KEY_UD_'
----------------------------------------------------------------

function EngineSystem:Init()
  cclog("=====EngineSystem:Init=====1")
  -- init CppAgent
  self.mCppAgent = EngineAgent:GetLuaInstance()

  --
  self.mCurOS = EngineAgent:GetOS()
  self.mOSVersion = self.mCppAgent:getOSVersion()
  self.mDeviceModel = self.mCppAgent:getDeviceModel()
  self.mUUID = self.mCppAgent:getDeviceUUID()
  self.mIMEI = self.mCppAgent:getDeviceIMEI()
  self.mMAC = self.mCppAgent:getDeviceMacAddr()
  --
	self:InitEnv()
	self:InitResolution()
  self:InitUISetting()

  -- 设置整体游戏速度
  FightSystem:setGameSpeedScale(FightConfig.__DEBUG_FIGHT_DIRECTOR_TIMESCALE)
  cclog("=====EngineSystem:Init=====2")
end

function EngineSystem:Tick()
   EngineSystem.mCppAgent:Tick()
end

function EngineSystem:Release()
  --
  EngineAgent:FreeInstance()
  --
  _G["EngineSystem"] = nil
  package.loaded["EngineSystem"] = nil
  package.loaded["EngineSystem/EngineSystem"] = nil
end

function EngineSystem:showStats(_director)
    _director:setDisplayStats(GAME_MODE == ENUM_GAMEMODE.debug)
end

-- 获得当前版本号
function EngineSystem:getTheLatestVersion()
    local _version1 = GAME_VERSION
    local _version2 = DBSystem:Get_String_FromSandBox(_VERSION_KEY_UD_)
    if _version1 > _version2 then
       return _version1
    else
       return _version2
    end 
end

function EngineSystem:InitEnv()
	  local director = cc.Director:getInstance()
    --@是否显示帧率
    self:showStats(director)

    --
    -- init Download Folder
    -- if the bundle version big than config version delete old download
    local _version1 = GAME_VERSION
    local _version2 = DBSystem:Get_String_FromSandBox(_VERSION_KEY_UD_)
    if string.len(_version2) ~= 0 and _version1 > _version2 then
      self:DeleteDocumentSubDir(self._DOWNLOAD_FOLDER_)
    elseif string.len(_version2) == 0 then
      --@如果第一次进游戏，则UD中的Version为空，则记录为bundle的版本号
      DBSystem:Save_String_ToSandBox(_VERSION_KEY_UD_, GAME_VERSION)
    end


    --@创建download文件夹，已存在则不会创建
    self:CreateDocumentSubDir(self._DOWNLOAD_FOLDER_)


    --@检查是否支持ETC1
    self.mCppAgent:setEnabledETC1(false)
end

function EngineSystem:InitResolution()
    -- 获取宽高
    local width = RESOLUTION_TABLE[DEVICE_MODE].w
    local height = RESOLUTION_TABLE[DEVICE_MODE].h
    -- 在ios中，glview由mm文件中生成
    -- 在Android中，glview由cpp文件生成
    local director = cc.Director:getInstance()
    local glview = director:getOpenGLView()
    -- windows下，需要自行创建GLView
    if glview == nil then
       glview = cc.GLView:createWithRect(GAMPE_NAME, cc.rect(0,0, width, height))
       director:setOpenGLView(glview)
    end
    -- 设置画布大小
    -- 无论设备型号，画布始终为设计分辨率
    glview:setDesignResolutionSize(_RESOURCE_DESIGN_RESOLUTION_W_, _RESOURCE_DESIGN_RESOLUTION_H_, cc.ResolutionPolicy.NO_BORDER)
end

function EngineSystem:InitUISetting()
   cc.Director:getInstance():setDefaultFont(GAME_DEFAULT_FONT)
end

-- 关闭spine渲染
function EngineSystem:closeSpineRender(_closed)
   self.mCppAgent:setClosedSpineRender(_closed)
end

function EngineSystem:OpenUrl(_url)
    -- call cpp agent
    self.mCppAgent:OpenURL(_url)
end

function EngineSystem:CreateDocumentSubDir(_subDir)
    -- call cpp agent
    EngineAgent:CreateDocumentSubDir(_subDir)
end

function EngineSystem:DeleteDocumentSubDir(_subDir)
    -- call cpp agent
    EngineAgent:DeleteDocumentSubDir(_subDir)
end

--@加密string
function EngineSystem:EncryptString(_str)
    return EngineAgent:EncryptString(_str)
end

--@解密string
function EngineSystem:DecryptString(_str)
    return EngineAgent:DecryptString(_str)
end


--[[
  获取设备相关信息
]]
-- 获取设备名称
function EngineSystem:getDeviceModel()
   return self.mDeviceModel
end

function EngineSystem:getDeviceUUID()
  return self.mUUID
end

function EngineSystem:getDeviceIMEI()
  return self.mIMEI
end

function EngineSystem:getDeviceMacAddr()
  return self.mMAC
end

--[[
  获取系统相关信息
]]
function EngineSystem:getIOSjailbreak()
  return self.mCppAgent:getIOSjailbreak()
end

-- @return: PC, IOS, ANDROID
function EngineSystem:getOS()
  return self.mCurOS
end

function EngineSystem:getOSVersion()
  return self.mOSVersion
end

--[[
  获取当前游戏版本号
]]
function EngineSystem:getGameVersion()
    local _version1 = GAME_VERSION
    local _version2 = DBSystem:Get_String_FromSandBox(_VERSION_KEY_UD_)
    if _version1 >= _version2 or string.len(_version2) == 0 then
       return _version1
    else
       return _version2
    end
end

--[[
  修改版本号(沙盒)
]]
function EngineSystem:setGameVersion(_version)
   DBSystem:Save_String_ToSandBox(_VERSION_KEY_UD_, _version)
end

-- quitGame
function EngineSystem:quitGame()
   cc.Director:getInstance():endToLua()
end

-- reload loaded luafiles
function EngineSystem:reloadLoadedLuaFiles()
   GameApp:PreRestart()
   local function isCanReloadLuaFile(_key)
      -- 筛选出是lua逻辑文件的，判断依据"/"
      local ret = string.find(_key, "/")
      return ret
   end

   for k,v in pairs(package.loaded) do
       if isCanReloadLuaFile(k) then
           package.loaded[k] = nil
       end
   end
   -----------
 require("AppGame/GameConfig")
 require("AppGame/GameApp")
end


--@接收事件
function EngineSystem:onEventHandler(event)
  
end