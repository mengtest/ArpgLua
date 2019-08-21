-- Name: SoundSystem
-- Func: 声音系统
-- Author: Johny

require "AudioEngine.lua"
require "ResSystem/SoundData"

SoundSystem = {}
SoundSystem.mType = "SOUNDSYSTEM"
-- 本地录音临时文件名
SoundSystem.mRecordFile = "recording_tmp.wav"
SoundSystem.ENUM_CPP = 
{
  RECORDING_FINISH = 1,
  PLAY_BEGIN = 2,
  PLAY_FINISH = 3,
}

------------------------本地变量------------------------------
local  _SOUND_DB_KEY_VOLUME_BGM_  = "_SOUND_DB_KEY_VOLUME_BGM_"
local  _SOUND_DB_KEY_VOLUME_EFFECT_  = "_SOUND_DB_KEY_VOLUME_EFFECT_"
local  _EFFECT_PLAY_INTERVAL_   =  1
local  _BGM_MAX_VOLUME_         =  0.75
--------------------------------------------------------------

function SoundSystem:Init()
    self.mCurBGM = nil
    self.mCallBack_downloadAndPlayRecording = nil
    self.mRecorderAgent = RecorderAgent:GetLuaInstance()
    self.mRecorderAgent:RegisterLuaHandler(handler(self, self.onCppEvent))
    -- 是否暂停音效
    self.mIsPauseEffect = false
    -- 音效队伍列表{sounddata.mSoundFile, sounddata.mIsLoop, sounddata.mPitch, _func}
    self.mSoundEffectList = {}
    self.mTickCount = _EFFECT_PLAY_INTERVAL_

    -- 检查BGM与音效开启情况
    local function _checkBGMAndEffectStatus()
        self:setBGMVolumeBySetting()
        self:setEffectVolumeBySetting()
    end
    _checkBGMAndEffectStatus()
end

function SoundSystem:Tick()
    -- self:_playEffect()
end

function SoundSystem:Release()
    RecorderAgent:FreeInstance()
    --
    _G["SoundSystem"] = nil
    package.loaded["SoundSystem"] = nil
    package.loaded["ResSystem/SoundSystem"] = nil
end

-------------------------------关于录音------------------------------
-- 开始录音
function SoundSystem:startRecording()
   cclog("开始录音==")
   self:pauseBGM()
   local _fullPath = string.format("%s/%s", cc.FileUtils:getInstance():getWritablePath(), self.mRecordFile)
   self.mRecorderAgent:startRecording(_fullPath)
end
-- 停止录音
function SoundSystem:finishRecording()
   cclog("结束录音==")
   self.mRecorderAgent:finishRecording()
   SoundSystem:resumeBGM()
end
-- 取消录音
function SoundSystem:cancelRecording()
   cclog("取消录音==")
   self.mRecorderAgent:cancelRecording()
   SoundSystem:resumeBGM()
end
-- 下载并播放录音（检查文件是否已存在）
function SoundSystem:downloadAndPlayRecording(_fileName, _callback)
    cclog("下载+播放录音==" .. _fileName)
    self:pauseBGM()
    self.mCallBack_downloadAndPlayRecording = _callback
    local _fullPath = string.format("%s/%s", cc.FileUtils:getInstance():getWritablePath(), _fileName)
    self.mRecorderAgent:downloadAndPlayRecording(string.format("%s?fileName=%s", NetSystem.mFileURL, _fileName), _fullPath)
end
-- 停止播放录音
function SoundSystem:stopPlayRecording()
    cclog("播放结束==")
    self.mRecorderAgent:cancelPlay()
    SoundSystem:resumeBGM()
end
---------------------------------------------------------------


--
--	实现sound的操作
--
-- 播放背景音乐
function SoundSystem:PlayBGM(sounddata)
    self.mCurBGM = sounddata
    self.mCurBGM:PlayBGM()
end
-- 停止背景音乐
function SoundSystem:StopBGM()
    if not self.mCurBGM then return end
	  self.mCurBGM:StopBGM()
    self.mCurBGM = nil
    if self.mBGMIntervalHandler then
      G_unSchedule(self.mBGMIntervalHandler)
      self.mBGMIntervalHandler = nil
    end
end
-- 更换背景音乐
-- 同样的音乐就不要更换了
function SoundSystem:ChangeBGM(sounddata)
  if self.mCurBGM and self.mCurBGM.mIndex == sounddata.mIndex then return end
	self:StopBGM()
	self:PlayBGM(sounddata)
end

--@private
-- 播放缓冲区音效，一帧限播一个
function SoundSystem:_playEffect()
    if #self.mSoundEffectList == 0 then return end
    -- if self.mTickCount >= _EFFECT_PLAY_INTERVAL_ then
      local v = self.mSoundEffectList[1]
      local _openALIndex = AudioEngine.playEffect(v[1], v[2], v[3])
      if v[4] then
         v[4](_openALIndex)
      end
      table.remove(self.mSoundEffectList, 1)
      -- self.mTickCount = 0
   -- end
   -- self.mTickCount = self.mTickCount + 1
end

function SoundSystem:PlayEffect(sounddata, _func)
    if self:getEffectVolumBySetting() == 0 then return end
    -- 检查该文件是否存在
    local fileUitls = cc.FileUtils:getInstance()
    if not fileUitls:isFileExist(sounddata.mSoundFile) then 
       doError("[ERROR][SOUNDEFFECT]Can not find file: " .. sounddata.mSoundFile)
    return end
    table.insert(self.mSoundEffectList, {sounddata.mSoundFile, sounddata.mIsLoop, sounddata.mPitch, _func})
    self:_playEffect()
end

function SoundSystem:StopEffect(_openalindex)
	AudioEngine.stopEffect(_openalindex)
end

function SoundSystem:StopEffectAll()
	 AudioEngine.stopAllEffects()
end

-- 预加载背景音乐
function SoundSystem:PreLoadBGM(_data)
    -- 检查该文件是否存在
    local fileUitls = cc.FileUtils:getInstance()
    if not fileUitls:isFileExist(_data.mSoundFile) then 
       doError("[ERROR][BGM]Can not find file: " .. _data.mSoundFile)
    return end
	  AudioEngine.preloadMusic(_data.mSoundFile)
end

-- 预加载音效
function SoundSystem:PreLoadEffect(_data)
    cclog("SoundSystem:PreLoadEffect .. " .. _data.mSoundFile)
    -- 检查该文件是否存在
    local fileUitls = cc.FileUtils:getInstance()
    if not fileUitls:isFileExist(_data.mSoundFile) then 
       doError("[ERROR][SOUNDEFFECT]Can not find file: " .. _data.mSoundFile)
    return end
	  AudioEngine.preloadEffect(_data.mSoundFile)
end

-- 卸载所有音效
function SoundSystem:unloadAllEffects()
   AudioEngine.unloadAllEffects()
end

-- 暂停音乐播放
function SoundSystem:pauseBGM()
   AudioEngine.pauseMusic()
end

-- 恢复音乐播放
function SoundSystem:resumeBGM()
   AudioEngine.resumeMusic()
end

-- 根据配置设置BGM音量
function SoundSystem:setBGMVolumeBySetting()
   local volume = DBSystem:Get_Integer_FromSandBox(_SOUND_DB_KEY_VOLUME_BGM_)
   if volume == 0 then
      volume = 100
      DBSystem:Save_Integer_ToSandBox(_SOUND_DB_KEY_VOLUME_BGM_, volume)
   end
   -- 静音-1标志，转为音量0
   if volume == -1 then
      volume = 0
   end
   AudioEngine.setMusicVolume(volume * 0.01 * _BGM_MAX_VOLUME_)
end
-- 设置BGM音量并存储
function SoundSystem:setBGMVolumeToSetting(volume)
   -- 音量0转为静音标志-1
   if volume == 0 then volume = -1 end
   DBSystem:Save_Integer_ToSandBox(_SOUND_DB_KEY_VOLUME_BGM_, volume)
   AudioEngine.setMusicVolume(volume * 0.01 * _BGM_MAX_VOLUME_)
end
-- 获取配置BGM音量
function SoundSystem:getBGMVolumBySetting()
   return DBSystem:Get_Integer_FromSandBox(_SOUND_DB_KEY_VOLUME_BGM_)
end

-- 根据配置设置BGM音量
function SoundSystem:setEffectVolumeBySetting()
   local volume = DBSystem:Get_Integer_FromSandBox(_SOUND_DB_KEY_VOLUME_EFFECT_)
   if volume == 0 then
      volume = 100
      DBSystem:Save_Integer_ToSandBox(_SOUND_DB_KEY_VOLUME_EFFECT_, volume)
   end
   -- 静音-1标志，转为音量0
   if volume == -1 then
      volume = 0
   end
   AudioEngine.setEffectsVolume(volume/100)
end
-- 设置BGM音量并存储
function SoundSystem:setEffectVolumeToSetting(volume)
   -- 音量0转为静音标志-1
   if volume == 0 then volume = -1 end
   DBSystem:Save_Integer_ToSandBox(_SOUND_DB_KEY_VOLUME_EFFECT_, volume)
   AudioEngine.setEffectsVolume(volume/100)
end
-- 获取配置Effect音量
function SoundSystem:getEffectVolumBySetting()
   return DBSystem:Get_Integer_FromSandBox(_SOUND_DB_KEY_VOLUME_EFFECT_)
end


-- 强制开启背景音乐和音效
function SoundSystem:forcePlayBGMandEffect(forced)
   if forced then
      AudioEngine.setMusicVolume(_BGM_MAX_VOLUME_)
      AudioEngine.setEffectsVolume(1.0)
   else
      self:setBGMVolumeBySetting()
      self:setEffectVolumeBySetting()
   end
end



--[[
	data = {
		mSoundIndex = -1
	}
]]

function SoundSystem:FindSoundData(data)
	local sd = SoundData.new(data)
	if sd.mCreateState == -1 then
		doError("=====SoundSystem:FindSoundData===ERROR: Can not find Sound Data, SoundIndex is: " .. data.mSoundIndex)
	return nil end

	return sd
end


-------------------------------回调-------------------------------------
--@接收事件
function SoundSystem:onEventHandler(event)
    -- 停止
    if event.mAction == Event.tSOUND_EFFECT_STOP then
         local _openalindex = event.mData[1]
         self:StopEffect(_openalindex)
         return
    elseif event.mAction == Event.tSOUND_EFFECTALL_STOP then
         self:StopEffectAll()
         return
    elseif event.mAction == Event.tSOUND_BGM_STOP then
         self:StopBGM()
         return
    end

    -- 播放音效
    if event.mAction == Event.tSOUND_EFFECT_PLAY then
        local sd = self:FindSoundData(event.mData[1])
        local _func = event.mData[2]
        event.mData = nil
        if sd == nil then return end
        self:PlayEffect(sd, _func)
        return
    end

    -- 播放
  	local sd = self:FindSoundData(event.mData)
  	event.mData = nil
  	if sd == nil then return end
  	if event.mAction == Event.tSOUND_BGM_PLAY then
  		 self:PlayBGM( sd)
  	elseif event.mAction == Event.tSOUND_BGM_CHANGE then
  		 self:ChangeBGM( sd)
    elseif event.mAction == Event.tSOUND_EFFECT_PRELOAD then
       self:PreLoadEffect( sd)
    elseif event.mAction == Event.tSOUND_BGM_PRELOAD then
       self:PreLoadBGM( sd)
    end

end

--@cpp层传来回调
function SoundSystem:onCppEvent(_type, _param1)
   if _type == self.ENUM_CPP.PLAY_BEGIN then
      cclog("播放开始==" .. _param1)
      if self.mCallBack_downloadAndPlayRecording then
         self.mCallBack_downloadAndPlayRecording(_param1)
         self.mCallBack_downloadAndPlayRecording = nil
      end
   end
end
