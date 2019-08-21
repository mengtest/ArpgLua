-- Name: GameQuickAPI
-- Func: 用于游戏内部的方法封装，快速调用
-- Author: Johny

require "LuaLibList"


local TAG = "rexuegaoxiao"
local logFile_handler = nil
local errFile_handler = nil
local _ENABLE_DURING_MONITOR_ = false


-- custom error report
function G_ErrorReport(msg)
    local errMsg = string.format("[LUA ERROR]: %s\n",tostring(msg))
    cclog(errMsg)
    cclog(debug.traceback())
    --for bugly
    if GAME_MODE ~= ENUM_GAMEMODE.debug then
       buglyReportLuaException(errMsg, debug.traceback())
    else
       doAssert(false, string.format("%s-%s",errMsg,debug.traceback()))
    end 
end

-- for CCLuaEngine traceback
function __G__TRACKBACK__(msg)
    local errMsg = string.format("[LUA ERROR]: %s\n",tostring(msg))
    cclog(errMsg)
    cclog(debug.traceback())
    --for bugly
    if GAME_MODE ~= ENUM_GAMEMODE.debug then
       buglyReportLuaException(errMsg, debug.traceback())
    else
       doAssert(false, string.format("%s-%s",errMsg,debug.traceback()))
    end
    
    return msg
end

-- log file
function LogFile(_open)
    if GAME_MODE ~= ENUM_GAMEMODE.release then
      if _open then
         local _file = string.format("%s/Beta_log.txt", cc.FileUtils:getInstance():getWritablePath()) 
         logFile_handler = assert(io.open(_file, "w"))
         logFile_handler:setvbuf("no")
      else
         logFile_handler:close()
      end
    end
end

-- cclog
cclog = function(...)
    if GAME_MODE ~= ENUM_GAMEMODE.release then
      local _string = string.format("%s-----%s-----%s\n",TAG, os.date("%X", time), ...)
      print(_string)
      logFile_handler:write(_string)
    end
end

-- debugLog,用于输出单项调试
debugLog = function(...)
    if GAME_MODE ~= ENUM_GAMEMODE.release then
      local _string = string.format("%s-----%s-----%s\n",TAG, os.date("%X", time), ...)
      print(_string)
      logFile_handler:write(_string)
    end
end

-- 检查空值
function GG_CheckNil(value, msg)
   if not value then
      doError(string.format("[ERROR]%s", msg))
   end
end

-- 用于封装带一个对象的方法
function handler(target, method)
    return function(...) return method(target, ...) end 
end

function iter(t)
  local index = 0
  return function()
         index = index + 1
         return t[i] end
end

-- 获得画布大小
function GG_GetWinSize()
    local _sz = cc.Director:getInstance():getWinSize()

    -- cclog("GG_GetWinSize == " .. _sz.width .. " == " .. _sz.height)
    return _sz
end

-- 获得屏幕大小
function GG_GetSceenSize()
    local director = cc.Director:getInstance()
    local glview = director:getOpenGLView()
    local _sz = glview:getFrameSize()
    -- cclog("GG_GetSceenSize == " .. _sz.width .. " == " .. _sz.height)
    return _sz
end

-- 获得缩放后的画布大小
function GG_GetScaledWinSize( ... )
    local director = cc.Director:getInstance()
    local rect = director:getOpenGLView():getViewPortRect()

    -- cclog("GG_GetScaledWinSize == rect == " .. rect.width .. " == " .. rect.height)
    return cc.size(rect.width, rect.height)
end

-- Split String
function extern_string_split_(szFullString, szSeparator)  
    local nFindStartIndex = 1  
    local nSplitIndex = 1  
    local nSplitArray = {}  
    while true do  
       local nFindLastIndex = string.find(szFullString, szSeparator, nFindStartIndex)  
       if not nFindLastIndex then  
        nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, string.len(szFullString))  
        break  
       end  
       nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, nFindLastIndex - 1)  
       nFindStartIndex = nFindLastIndex + string.len(szSeparator)  
       nSplitIndex = nSplitIndex + 1  
    end  
    return nSplitArray  
end  

-- 下一帧执行
function nextTick(func)
  local scheduler = cc.Director:getInstance():getScheduler()
  local schedulerHandler = nil

  local function doSomthing()
    func()
    scheduler:unscheduleScriptEntry(schedulerHandler)
  end

  schedulerHandler = scheduler:scheduleScriptFunc(doSomthing, 0, false)
end

-- 延迟几秒执行
function nextTick_frameCount(func, _second)
    local scheduler = cc.Director:getInstance():getScheduler()
    local schedulerHandler = nil

    local function doSomthing()
      func()
      scheduler:unscheduleScriptEntry(schedulerHandler)
    end

    schedulerHandler = scheduler:scheduleScriptFunc(doSomthing, _second, false)

    return schedulerHandler
end

-- 间隔几秒执行
function nextTick_eachSecond(func, _second)
    local scheduler = cc.Director:getInstance():getScheduler()

    local function doSomthing()
        func()
    end

    return scheduler:scheduleScriptFunc(doSomthing, _second, false)
end

-- 解注册计时器
function G_unSchedule(_scheduler)
      if not _scheduler then return end
      local scheduler = cc.Director:getInstance():getScheduler()
      scheduler:unscheduleScriptEntry(_scheduler)
end


-- 注册弹起
function registerWidgetReleaseUpEvent(widget, func)
  local function onReleaseUp(widget, eventType)
    if eventType == ccui.TouchEventType.began then
        cclog("摁下,开启屏蔽", os.date("%c"))
        GUISystem:disableUserInput2()
      elseif eventType == ccui.TouchEventType.ended then
        cclog("弹起,解除屏蔽", os.date("%c"))
        GUISystem:enableUserInput2()
        func(widget)
      elseif eventType == ccui.TouchEventType.moved then
        
      elseif eventType == ccui.TouchEventType.canceled then
        cclog("取消,解除屏蔽", os.date("%c"))
        GUISystem:enableUserInput2()
      end
  end
  widget:addTouchEventListener(onReleaseUp)
end

-- 注册按下
function registerWidgetPushDownEvent(widget, func)
  local function onPushDown(widget, eventType)
    if eventType == ccui.TouchEventType.began then
      func(widget)
    end
  end
  widget:addTouchEventListener(onPushDown)
end

-- 注册按下和弹起
function registerWidgetPushAndReleaseEvent(widget, func, _param)
    local function onTouch(widget, eventType)
      if eventType == ccui.TouchEventType.began then
        func(widget, 1, _param)
      elseif eventType == ccui.TouchEventType.ended then
        func(widget, 2, _param)
      elseif eventType == ccui.TouchEventType.moved then
        func(widget, 3, _param)
      elseif eventType == ccui.TouchEventType.canceled then
        func(widget, 4, _param)
      end
    end
    widget:addTouchEventListener(onTouch)
end

-- 快速设置元表
function newObject(o, class)
    class.__index = class
    return setmetatable(o, class)
end

-- 断言
function doAssert(assertion, text)
  if GAME_MODE ~= ENUM_GAMEMODE.debug then return end
  --
  if not assertion then
     cc.Director:getInstance():showMessageBox(text, "doAssert")
  end
end

-- 弹出错误框
function doError(text)
    cc.Director:getInstance():showMessageBox(tostring(text), "error")
end

-- 取出文字
function getDictionaryText(id)
    local textData = DB_Text.getDataById(id)
    return textData[GAME_LANGUAGE]
end


-- 取出Board ID
function getBoardIdByMapUI(_chapter, _section, _level)
  local sections = nil
  if 1 == _level then
    sections = DB_MapUIConfig.getArrDataByField("MapUI_ChapterID", _chapter)
  elseif 2 == _level then
    sections = DB_MapUIConfigNormal.getArrDataByField("MapUI_ChapterID", _chapter)
  end

  local function sortFunc(section1, section2)
    return section1.ID < section2.ID
  end
  table.sort(sections, sortFunc)

  for i = 1, #sections do
    if 0 == sections[i].MapUI_SectionID then
      table.remove(sections, i)
      break
    end
  end
  return sections[_section].MapUI_BoardConfigID
end

-- 取出CG对话文字
function getDictionaryCGText(id)
    cclog("getDictionaryCGText=======" .. id)
    local textData = DB_SpeakText.getDataById(id)
    return textData[GAME_LANGUAGE]
end

-- 随机取出24英雄Date
function getRandomHeroData()
    local id = math.random(1,24)
    local Data = DB_HeroConfig.getDataById(id)
    if Data then
        return Data
    else
      return DB_HeroConfig.getDataById(1)
    end
end
-- vip背景转换
function getVipLevelBg(_lv)
  local bg = 1
  if _lv < 6 then
    bg = 1
  elseif _lv < 11 and _lv >= 6 then
    bg = 2
  elseif _lv < 15 and _lv >= 11 then
    bg = 3
  elseif _lv == 15 or _lv == 16 then
    bg = 4
  end
  return bg
end

-- 函数调用前，判断函数的持有者是否为空
function pCall(_holder, _func, ...)
    if _holder == nil then return end
    return _func(...)
end


-- 字段是否在table中
function isValueInTable(_value, _table)
   for k,v in pairs(_table) do
       if v == _value then
       return true end
   end

   return false
end

-- table判空条件
function table_is_empty(t)
    return _G.next( t ) == nil
end

local character = 
{
  "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", 
  "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z",  
  "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
  "!", "@", "$", "%", "^", "&", "*", "(", ")", "-", "+", "=", "/", "?", ",", ".", "<", ">", "[", "]", "{", "}", "|", "/",      
}

ProcessID_Table = 
{
  "ProcessID1","ProcessID2","ProcessID3","ProcessID4","ProcessID5","ProcessID6","ProcessID7","ProcessID8","ProcessID9","ProcessID10",
  "ProcessID11","ProcessID12","ProcessID13","ProcessID14","ProcessID15","ProcessID16","ProcessID17","ProcessID18","ProcessID19","ProcessID20",
  "ProcessID21","ProcessID22","ProcessID23","ProcessID24","ProcessID25","ProcessID26","ProcessID27","ProcessID28","ProcessID29","ProcessID30",
  "ProcessID31","ProcessID32",
}

SubObjectID_Table = 
{
  "SubObjectID1","SubObjectID2","SubObjectID3","SubObjectID4","SubObjectID5","SubObjectID6","SubObjectID7","SubObjectID8",
}

EffectID_Table = 
{
  "EffectID1","EffectID2","EffectID3","EffectID4",
}

TargetStateID_Table = 
{
  "TargetStateID1","TargetStateID2","TargetStateID3","TargetStateID4",
}

SelfStateID_Table = 
{
  "SelfStateID1","SelfStateID2","SelfStateID3","SelfStateID4",
}

ChildSubobject_Table = 
{
  "ChildSubobject1","ChildSubobject2","ChildSubobject3","ChildSubobject4"
}

Group_Hit_Table = 
{
  "Group_Hit01","Group_Hit02","Group_Hit03","Group_Hit04","Group_Hit05","Group_Hit06","Group_Hit07","Group_Hit08"
}

Dye_Part_Table = 
{
  "头发","上衣","裤子","鞋",
}

-- 伤害克制
function RestraintGroup(_hitGroup, _victimGroup )
  if _victimGroup ~= 0 then
    local data =  DB_AttackCorrect.getArrDataByField("Group_Advance",_hitGroup)
    if not data then
      return 1
    end
    return data[1][Group_Hit_Table[_victimGroup]]
  end
  return 1
end

-- 查找边框和英雄头像
function FindFrameIconbyId(_id) 
  local data = DB_PlayerIcon.getDataById(_id)
  if data then
    return DB_ResourceList.getDataById(data.ResourceListID).Res_path1
  end
end

function getBloodColor( _value)
  if 100 >= _value and 90 <= _value then
    return G_COLOR_C3B.BLUE
  elseif 90 > _value and 60 <= _value then
    local cur =  90 - _value
    local num = math.floor(255/30 * cur) 
    return cc.c3b(num,255,0)
  elseif 60 > _value and 30 <= _value then
    local cur =  _value - 30
    local num = math.floor(255/30 * cur) 
    return cc.c3b(255,num,0)
  elseif 30 > _value and 0 <= _value then
    return G_COLOR_C3B.RED 
  end
end

function getEnergyPerByMp(_mp)
  if _mp >= 25 and _mp < 50 then
    return 25
  elseif _mp >= 50 and _mp < 75 then
   return 50
  elseif _mp >= 75 and _mp < 100 then
   return 75
  elseif _mp >= 100 then
   return 100
  end 
  return 0
end

function isASCII(str)
  for k, v in pairs(character) do
    if str == v then
      return true
    end
  end
  return false
end

function splitChineseString(srcString)
  local result = {}
  local strLen = string.len(srcString)

  local i = 1
  while i < strLen do
    local str = string.sub(srcString, i, i)
    if isASCII(str) then
      i = i + 1
    elseif str == "#" then
      local nextShape,len = string.find(srcString, "#", i+1)
      if len and len > 0 then
         local len_Color = nextShape - i
         str = string.sub(srcString,i,i+len_Color)
         i = nextShape + 1
      end
    else
      str = string.sub(srcString, i, i + 2)
      i = i + 3
    end
    table.insert(result, str)
  end
  local newResult = {}
  
  for i = 1, #result do
    local newStr = ""
    for j = 1, i do
      newStr = string.format("%s%s",newStr,result[j])
    end
    table.insert(newResult, newStr)
  end
  return newResult
end

function getChineseStringLength(srcString)
  local result = {}
  local strLen = string.len(srcString)

  local i = 1
  while i <= strLen do
    local str = string.sub(srcString, i, i)
    if isASCII(str) then
      i = i + 1
    else
      str = string.sub(srcString, i, i + 2)
      i = i + 3
    end
    table.insert(result, str)
  end
  return #result
end

-- 获取一段文字(包括汉字、英文、数字)所占字符个数
function getStringLength(srcString)
  local result = {}
  local strLen = string.len(srcString)

  local i = 1
  while i < strLen do
    local str = string.sub(srcString, i, i)
    if isASCII(str) then
      i = i + 1
    else
      str = string.sub(srcString, i, i + 2)
      i = i + 3
    end
    table.insert(result, str)
  end

  local newLength = 0
  for j = 1, #result do
    if isASCII(result[j]) then
      newLength = newLength + 2
    else
      newLength = newLength + 3
    end
  end
  return newLength
end

-- 秒转时间
function secondToHour(seconds)
  if not seconds or seconds <= 0 then
    return "免费"
  end
  local hour = math.floor(seconds / 3600)
  seconds = math.mod(seconds, 3600)
  local min = math.floor(seconds / 60)
  seconds = math.mod(seconds, 60)
  local sec = seconds
  return string.format("%02d:%02d:%02d",hour,min,sec)
end

-- 秒转时间
function secondToHour2(seconds)
    local hour = math.floor(seconds / 3600)
    seconds = math.mod(seconds, 3600)
    local min = math.floor(seconds / 60)
    seconds = math.mod(seconds, 60)
    local sec = math.floor(seconds)
    cclog(hour, "时", min, "分", sec, "秒")
    return hour, min, sec
end

--
function timeFormat(seconds)
  local hour = math.floor(seconds / 3600)
  seconds = math.mod(seconds, 3600)
  local min = math.floor(seconds / 60)
  seconds = math.mod(seconds, 60)
  local sec = seconds
  return string.format("%02d:%02d:%02d",hour,min,sec)
end

-- 查看lua内存占用
function doLuaMemory()
  local count = collectgarbage("count")
  cclog("当前lua虚拟机占用内存为:", count)
end

-- 是否是需要合成的纹理文件
function isNeedCoporateTexFile(_file)
   return not string.find(_file, ".png") and not string.find(_file, ".jpg")
end

-- 计算一个function执行的时间
function caculateFuncDuring(_funcName, _func)
   local _time1 = os.clock()
   local _ret1,_ret2,_ret3 = _func()  
   local _time2 = os.clock()
   if _ENABLE_DURING_MONITOR_ then
      local _during = _time2 - _time1
      monitorFuncDuring(_funcName, _during)
   end

   return _ret1,_ret2,_ret3
end

-- 监视func执行时间，超过给警告
local _MONITOR_LIST_ = {}
function monitorFuncDuring(_funcName, _during)
    if not _MONITOR_LIST_[_funcName] then _MONITOR_LIST_[_funcName] = {0,0} end
    _MONITOR_LIST_[_funcName][1] = _MONITOR_LIST_[_funcName][1] + 1
    _MONITOR_LIST_[_funcName][2] = _MONITOR_LIST_[_funcName][2] + _during
    if _MONITOR_LIST_[_funcName][1] == 1 then
       local msg = string.format("[monitorFuncDuring]%s cost %.4fs, plz check it." , _funcName, _MONITOR_LIST_[_funcName][2])
       debugLog(msg)
       _MONITOR_LIST_[_funcName] = {0,0}
    end
end

--------------------位运算-----------------------------
-- 取第几位的值
-- _idx: 0 ~ n-1
function bitNum(_num, _idx)
   local bit = require "bit"
   return bit.rshift(_num, _idx)
end

-- 打开第几位的值
-- 使该位值为1，其余位不变
-- _idx: 0 ~ n-1
function bitOpenNumBit(_num, _idx)
   local bit = require "bit"
   local _mask = 1
   _mask = bit.lshift(_mask, _idx)
   return bit.bor(_num, _mask)
end

-- 关闭第几位的值
-- 使该位值为0，其余位不变
-- _idx: 0 ~ n-1
function bitCloseNumBit(_num, _idx)
   local bit = require "bit"
   local _mask = 1
   _mask = bit.bnot(bit.lshift(_mask, _idx))
   return bit.band(_num, _mask)
end
--------------------位运算---------------------------

-------------------lua字符串替换---------------------
function G_stringReplace(str, srcString, destString)
   local _begin,_end = string.find(str, srcString)
   if not _begin then return str end
   local _str1 = string.sub(str, 0, _begin - 1)
   local ret = string.format("%s%s", _str1, destString)

   return ret
end
-------------------lua字符串替换---------------------

--------------------自动添加换行符-------------------
-- 纯英文自动添加换行符
function G_AddChangeLineForText(srcString, fontsize, limitwidth)
      fontsize = fontsize * 0.5

      local result = {}
      local strLen = string.len(srcString)

      local i = 1
      while i <= strLen do
        local str = string.sub(srcString, i, i)
        if isASCII(str) then
           i = i + 1
        else
           return srcString
        end
        table.insert(result, str)
      end
      
      local _curWidth = 0
      local _ret = ""
      for i = 1, #result do
         _ret = string.format("%s%s",_ret,result[i])
         _curWidth = _curWidth + fontsize
         if _curWidth + fontsize > limitwidth then
            _ret = string.format("%s%s",_ret,"\n")
            _curWidth = 0
         end
      end


      return _ret
end

-- 画布坐标转换到屏幕坐标
function CanvasToScreen(posX, posY)
  return cc.p(getGoldFightPosition_LD().x+posX, getGoldFightPosition_LD().y+posY)
end

--------------------自动添加换行符-------------------