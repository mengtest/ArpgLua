-- Name: SoundData
-- Func: 声音数据
-- Author: Johny

--[[
	mSoundType = 1: BGM    2: Effect
]]

SoundData = class("SoundData")

function SoundData:ctor(_soundIDX)
	local _sDB = DB_MusicConfig.getDataById(_soundIDX)
	if not _sDB then 
       self.mCreateState = -1
	end
	--
	self.mCreateState = 0
	self.mIndex = _soundIDX
	self.mSoundType = _sDB.SoundType
	local _curOS = EngineSystem:getOS()
	if _curOS == "IOS" then
	   self.mSoundFile = _sDB.IOSsound_iosPath
	elseif _curOS == "ANDROID" then
		self.mSoundFile = _sDB.AndroidSoundPath
	else
		self.mSoundFile = _sDB.SoundPath
	end
	
	self.mIsLoop = _sDB.SoundLoop == 1
	self.mPitch = nil  -- 播放速度 nil为正常速度
	self.mVolume = _sDB.SoundVolume
	self.mNeedPreLoad = _sDB.SoundPreload
	-- 声音间隔
	self.mBGMInterval = _sDB.PlayInterval
	--只有音效播放时才生成
	self.mOpenALIndex = -1

	--
	self.mFadeOutCallBack = nil

end

function SoundData:PlayBGM()
	if FightConfig.__DEBUG_BGM_CLOSED_ then return end
	-- 检查该文件是否存在
	local fileUitls = cc.FileUtils:getInstance()
	if not fileUitls:isFileExist(self.mSoundFile) then 
	   doError("[ERROR][BGM]Can not find file: " .. self.mSoundFile)
	return end
	AudioEngine.playMusic(self.mSoundFile, self.mIsLoop)
end

function SoundData:StopBGM()
	AudioEngine.stopMusic()
end