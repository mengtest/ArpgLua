-- Name: 	CommonAnimation
-- Func：	公用的动画
-- Author:	Johny

module("CommonAnimation", package.seeall)

local DEFAULT_SPINE_RESID   = 2599

-- 预加载spine模型
function preloadSpine_commonByResID(_resID)
	local _resDB = DB_ResourceList.getDataById(_resID)
	preloadSpine_common(_resDB.Res_path2, _resDB.Res_path1)
end
function preloadSpine_common(_file, _atlas)
	local fileUitls = cc.FileUtils:getInstance()
	local _png = G_stringReplace(_atlas, ".atlas", ".png")
	local _pvr = G_stringReplace(_atlas, ".atlas", ".pvr.ccz")
	if not fileUitls:isFileExist(_file) or not fileUitls:isFileExist(_atlas) or (not fileUitls:isFileExist(_png) and not fileUitls:isFileExist(_pvr)) then
		doError("[Error]Missing Spine: " .. _file .. ";" .. _atlas)
		local db = DB_ResourceList.getDataById(DEFAULT_SPINE_RESID)
		_file = db.Res_path2
		_atlas = db.Res_path1
	end
	FightSystem.mSpineAgent:PreloadSpineData(_file, _atlas, cc.SPINE_FILETYPE_BINARY, 1)
end

-- 创建spine模型
function createSpine_commonByResID(_resID)
	local _resDB = DB_ResourceList.getDataById(_resID)
	return createSpine_common(_resDB.Res_path2, _resDB.Res_path1)
end

function createCacheSpine_commonByResID(_resID, _root)
	local _resDB = DB_ResourceList.getDataById(_resID)
	if _resDB == nil then
	   doError("No ResID:" .. _resID)
	end
	return SpineDataCacheManager:getFightSpineByatlas(_resDB.Res_path2, _resDB.Res_path1, 1, _root)
end

function createSpine_common(_file, _atlas, _scale)
	local fileUitls = cc.FileUtils:getInstance()
	if not _scale then _scale = 1 end
	local _png = G_stringReplace(_atlas, ".atlas", ".png")
	local _pvr = G_stringReplace(_atlas, ".atlas", ".pvr.ccz")
	if not fileUitls:isFileExist(_file) or not fileUitls:isFileExist(_atlas) or (not fileUitls:isFileExist(_png) and not fileUitls:isFileExist(_pvr)) then
		doError("[Error]Missing Spine: " .. _file .. ";" .. _atlas)
		local db = DB_ResourceList.getDataById(DEFAULT_SPINE_RESID)
		_file = db.Res_path2
		_atlas = db.Res_path1
	end
	local _spine = sp.SkeletonAnimation:createWithBinary(_file, _atlas, 1)
	_spine:setScale(_scale)
	return _spine
end

-- 带枪的骨骼文件创建
function createSpine_weapon(_file, _atlas, _atlasWeapon, _scale)
	if not _scale then _scale = 1 end
	local _spine = sp.SkeletonAnimation:createWithBinary_Weapon(_file, _atlas, _atlasWeapon, 1)
	_spine:setScale(_scale)
	return _spine
end

-- 改变骨骼
function changeSpine_common(_spine, _file, _atlas, _scale)
	if not _scale then _scale = 1 end
	_spine:changeSkeleton(cc.SPINE_FILETYPE_BINARY, _file, _atlas, 1)
	_spine:setScale(_scale)
	return _spine
end

-- 任何卸载必调
function basicClearCache()
	-- studio动作缓存
	ccs.ActionManagerEx:destroyInstance()
	-- 清特效缓存
	AnimManager:removeAllAniFileInfo()
	-- 清除文件读写缓存
	cc.FileUtils:getInstance():purgeCachedEntries()
	-- 清除lua垃圾
	collectgarbage("collect")
end

-- 卸载纹理与spine数据,窗口销毁优先调用1级
function clearAllTexturesAndSpineData()
	basicClearCache()
	-- 清大图缓存
	TextureSystem:UnLoadAllUnusedPlist()
	--清除spine相关
	SpineDataCacheManager:applyForRemoveSpineDataCache()
end

-- 卸载内存中的纹理,窗口销毁优先调用1级
function clearAllTextures()
	basicClearCache()
	TextureSystem:UnLoadAllUnusedTexture()
end

-- spine两种融合颜色之间渐变
-- color1 RGB需要大于 color2 RGB
-- 返回计时器句柄
function Spine_ColorChangeBetween2(_spine, _color1, _color2, _tableList, _GlProKey)

	local _curColor = cc.vec4(0,0,0,0)
	_curColor.x = _color1.x
	_curColor.y = _color1.y
	_curColor.z = _color1.z
	_curColor.w = _color1.w
	local _increased = false
	local _R_INC = (_color1.x - _color2.x) / 20
	local _G_INC = (_color1.y - _color2.y) / 20
	local _B_INC = (_color1.z - _color2.z) / 20
	local _light = 0
	local _count = 1
	local function setCurColor()
		if _tableList then
			ShaderManager:combineColor_spine(_spine,_curColor,_light,_tableList,_GlProKey)
		else
			ShaderManager:combineColor_spine(_spine,_curColor,_light,nil,_GlProKey)
		end
	end
	local function updateShader()
		setCurColor()
		if _increased then
			_curColor.x = _curColor.x + _R_INC
			_curColor.y = _curColor.y + _G_INC
			_curColor.z = _curColor.z + _B_INC
			_light = _light - 0.045
			_count = _count - 1
			if _count < 2 then
				_increased = false
			end
			-- doError(string.format("11==%f,%f,%f", _curColor.x, _curColor.y, _curColor.z))
		else
			_curColor.x = _curColor.x - _R_INC
			_curColor.y = _curColor.y - _G_INC
			_curColor.z = _curColor.z - _B_INC
			_light = _light + 0.045
			_count = _count + 1
			if _count > 20 then
				_increased = true
			end
			-- doError(string.format("22==%f,%f,%f", _curColor.x, _curColor.y, _curColor.z))
		end
	end
--[[
	local _curColor = _color1
	local _increased = false
	local function setCurColor()
		if _tableList then
			ShaderManager:combineColor_spine(_spine,_curColor, 0.0, _tableList)
		else
			ShaderManager:combineColor_spine(_spine,_curColor, 0.0)
		end
	end
	local function updateShader()
		setCurColor()
		if _increased then
			_increased = false
			_curColor = _color1
		else
			_increased = true
			_curColor = _color2
		end
	end
	]]
	setCurColor()
	return nextTick_eachSecond(updateShader, 0.03)
end

-- 渐隐到消失
function FadeoutToDestroy(_node, _func)
	local function hide()
		 _node:setVisible(false)
	end
	local function show()
		_node:setVisible(true)
	end
	local actionList = {}
	
	for i = 1,10 do
		local _ac1 = cc.CallFunc:create(hide)
		local _ac2 = cc.DelayTime:create(1/20)
		local _ac3 = cc.CallFunc:create(show)
		local _ac4 = cc.DelayTime:create(1/20)
		table.insert(actionList, _ac1)
		table.insert(actionList, _ac2)
		table.insert(actionList, _ac3)
		table.insert(actionList, _ac4)
	end

	local _callback = cc.CallFunc:create(_func)
	table.insert(actionList, _callback)
	local _seq = cc.Sequence:create(actionList)
	_node:runAction(_seq)
end

-- 无敌闪烁
function FadeoutForInvincible(_node,time)
	local _Tag = 9527
	local _Tag1 = 19527
	local actionList = {}
	local function WaitCall()
		_node:stopActionByTag(_Tag)
		_node:setVisible(true)
	end
	local WaitTime = cc.DelayTime:create(time)
	local call = cc.CallFunc:create(WaitCall)
	local _seq1 = cc.Sequence:create(WaitTime,call)
	
	local _ac1 = cc.Hide:create()
	local _ac2 = cc.DelayTime:create(1/10)
	local _ac3 = cc.Show:create()
	local _ac4 = cc.DelayTime:create(1/3)
	table.insert(actionList, _ac1)
	table.insert(actionList, _ac2)
	table.insert(actionList, _ac3)
	table.insert(actionList, _ac4)
	local _seq = cc.Sequence:create(actionList)
	local forever = cc.RepeatForever:create(_seq)
	forever:setTag(_Tag)
	_node:runAction(forever)
	_seq1:setTag(_Tag1)
	_node:runAction(_seq1)
end
-- 无敌闪烁取消
function CanceltForInvincible(_node)
	local _Tag = 9527
	local _Tag1 = 19527
	_node:stopActionByTag(_Tag)
	_node:stopActionByTag(_Tag1)
	_node:setVisible(true)
end


-- 直接淡出
function FadeOutToDestroy_2(_node, _func)
	local _action = cc.FadeOut:create(1)
	local _callback = cc.CallFunc:create(_func)
	local _seq = cc.Sequence:create(_action, _callback)
	_node:runAction(_seq)
end

-- 黑屏效果
function BlackScreen(_node,time,_func,_funCastAnimation)
	local layer = cc.LayerColor:create(G_COLOR_C4B.WHITE, 10, 10)
	layer:setScaleX(342)
	layer:setScaleY(77)
	layer:setAnchorPoint(cc.p(0,0))
	--layer:setVisible(false)
	_node:addChild(layer)
	layer:setPositionX(math.abs(_node:getPositionX())-1140)
	local function Remove()
		layer:removeFromParent()
	end
	local actionList = {}

	local function ChangeColor()
		layer:setColor(G_COLOR_C3B.BLACK)
		if _funCastAnimation then
			_funCastAnimation()
		end
	end 

	local _ac1 = cc.DelayTime:create(0.15)
	local _ac2 = cc.CallFunc:create(ChangeColor)

	local _ac3 = cc.FadeIn:create(time/5)
	local _ac4 = cc.DelayTime:create(time*(3/5))
	local _ac5 = cc.FadeOut:create(time/5)
	local _ac6 = cc.CallFunc:create(Remove)
	actionList = {_ac1, _ac2, _ac3, _ac4, _ac5, _ac6}

	local _seq = cc.Sequence:create(actionList)
	local _callback = cc.Sequence:create(cc.DelayTime:create(time-0.2), cc.CallFunc:create(_func))
	layer:runAction(cc.Spawn:create(_seq, _callback))
	

	return layer
end


-- 黑屏效果为合体技
function BlackScreenForComSkill(_node,time,_func)
	local layer = cc.LayerColor:create(G_COLOR_C4B.BLACK, 10, 10)
	layer:setScaleX(342)
	layer:setScaleY(77)
	layer:setAnchorPoint(cc.p(0,0))
	_node:addChild(layer)
	layer:setPositionX(math.abs(_node:getPositionX())-1140)
	local function Remove()
		layer:removeFromParent()
	end
	local actionList = {}
	
	local _ac1 = cc.FadeIn:create(time/5)
	local _ac2 = cc.DelayTime:create(time*(3/5))
	local _ac3 = cc.FadeOut:create(time/5)
	local _ac4 = cc.CallFunc:create(Remove)
	actionList = {_ac1, _ac2, _ac3, _ac4}

	local _seq = cc.Sequence:create(actionList)
	local _callback = cc.Sequence:create(cc.DelayTime:create(time-0.2), cc.CallFunc:create(_func))
	layer:runAction(cc.Spawn:create(_seq, _callback))
	

	return layer
end

function fadeOutBlackScreen(_blacklayer, _func)
	local function Remove()
		_blacklayer:removeFromParent()
	end
	local _ac1 = cc.FadeOut:create(1)
	local _ac2 = cc.CallFunc:create(Remove)
	local _seq = cc.Sequence:create(_ac1, _ac2)
	local _callback = cc.Sequence:create(cc.DelayTime:create(1-0.2), cc.CallFunc:create(_func))
	_blacklayer:runAction(cc.Spawn:create(_seq, _callback))
end

-- 黑屏效果进入副本
function BlackScreenForFuben(_node,time)
	local layer = cc.LayerColor:create(G_COLOR_C4B.BLACK, 10, 10)
	layer:setScaleX(342)
	layer:setScaleY(77)
	layer:setAnchorPoint(cc.p(0,0))
	_node:addChild(layer,1000)
	local function Remove()
		layer:removeFromParent(true)
	end
	local actionList = {}
	
	--local _ac1 = cc.FadeIn:create(time/2)
	--local _ac2 = cc.DelayTime:create(time*(3/5))
	local _ac3 = cc.FadeOut:create(time)
	local _ac4 = cc.CallFunc:create(Remove)
	actionList = { _ac3, _ac4}

	local _seq = cc.Sequence:create(actionList)
	layer:runAction(_seq)
	--
end

-- Cg黑屏进入 之后渐亮
function BlackScreenForFCG(_node,timein,timeout,inCallfun,outCallfun)
	local layer = cc.LayerColor:create(G_COLOR_C4B.BLACK, 10, 10)
	layer:setScaleX(342)
	layer:setScaleY(77)
	layer:setAnchorPoint(cc.p(0,0))
	_node:addChild(layer,1000)
	local _inCallfun = inCallfun
	local _outCallfun = outCallfun
	local function CallFunIn()
		_inCallfun()
	end

	local function CallFunOut()
		_outCallfun()
		layer:removeFromParent(true)
	end

	local actionList = {}
	
	local _ac1 = cc.FadeIn:create(timein)
	table.insert(actionList,_ac1)
	if inCallfun then
		local _ac2 = cc.CallFunc:create(CallFunIn)
		table.insert(actionList,_ac2)
	end
	local _ac3 = cc.FadeOut:create(timeout)
	table.insert(actionList,_ac3)
	if outCallfun then
		local _ac4 = cc.CallFunc:create(CallFunOut)
		table.insert(actionList,_ac4)
	end
	
	local _seq = cc.Sequence:create(actionList)
	layer:runAction(_seq)
	--
end

-- 名字显示在屏幕中间淡入淡出
function ScreenMiddlelabelText(_node,str,time)

	local xpos = (getGoldFightPosition_RU().x - getGoldFightPosition_LU().x )/2
	local ypos = (getGoldFightPosition_RU().y - getGoldFightPosition_RD().y )/2 + getGoldFightPosition_RD().y
	local _lb = ccui.Text:create()
	_node:addChild(_lb,1000)
	_lb:setAnchorPoint(cc.p(0.5,0.5))
	_lb:setPosition(cc.p(xpos,ypos))
	_lb:setString(str)
	_lb:setFontSize(60)
	local function Remove()
		_lb:removeFromParent(true)
	end
	local actionList = {}
	
	--local _ac1 = cc.FadeIn:create(time/3)
	--local _ac2 = cc.DelayTime:create(time/3)
	local _ac3 = cc.FadeOut:create(time)
	local _ac4 = cc.CallFunc:create(Remove)
	actionList = { _ac3, _ac4}

	local _seq = cc.Sequence:create(actionList)
	_lb:runAction(_seq)
	--
end

-- 图片显示在屏幕中间淡入淡出
function ScreenMiddlelabelPic(_node,str,time)

	local xpos = (getGoldFightPosition_RU().x - getGoldFightPosition_LU().x )/2
	local ypos = (getGoldFightPosition_RU().y - getGoldFightPosition_RD().y )/2 + getGoldFightPosition_RD().y
	
	local _lb = cc.Sprite:create()
     _lb:setProperty("Image", str)
	_node:addChild(_lb,1000)
	_lb:setAnchorPoint(cc.p(0.5,0.5))
	_lb:setPosition(cc.p(xpos,ypos))
	local function Remove()
		_lb:removeFromParent(true)
	end
	local actionList = {}
	
	--local _ac1 = cc.FadeIn:create(time/3)
	--local _ac2 = cc.DelayTime:create(time/3)
	local _ac3 = cc.FadeOut:create(time)
	local _ac4 = cc.CallFunc:create(Remove)
	actionList = { _ac3, _ac4}

	local _seq = cc.Sequence:create(actionList)
	_lb:runAction(_seq)
	--
end

-- 播放一次spine动画
-- _cmd: 动作指令
-- _speedScale: 播放速度比例
-- _endEvent: 结束回调
-- _customEvent: 自定义事件，参数event，可参考FightArmature
function playOnceSpineAni(_resID, _cmd, _speedScale, _endEvent, _customEvent, _root)
	local _spine = CommonAnimation.createCacheSpine_commonByResID(_resID,_root)
	local function aniEnd()
		if _endEvent then _endEvent() end
		SpineDataCacheManager:collectFightSpineByAtlas(_spine)
		_spine = nil
	end
	_spine:registerSpineEventHandler(aniEnd,1)
	if _customEvent then
	   _spine:registerSpineEventHandler(_customEvent, 3)
	end
	_spine:setAnimationWithSpeedScale(0,_cmd, false, _speedScale)
	
	return _spine
end


------------------------------音效快捷接口------------------------------------
-- 停止播放音乐和所有音效
function StopBGMAndAllEffect()
    EventSystem:PushEvent(Event.SOUNDSYS_BGM_STOP)
    EventSystem:PushEvent(Event.SOUNDSYS_EFFECTALL_STOP)
end
-- 播放背景音乐
function PlayBGM(_id)
    Event.SOUNDSYS_BGM_PLAY.mData = _id
    EventSystem:PushEvent(Event.SOUNDSYS_BGM_PLAY)
end
-- 停止背景音乐
function StopBGM()
    EventSystem:PushEvent(Event.SOUNDSYS_BGM_STOP)
end
-- 更改背景音乐
function ChangeBGM(_id)
	Event.SOUNDSYS_BGM_CHANGE.mData = _id
	EventSystem:PushEvent(Event.SOUNDSYS_BGM_CHANGE)
end

-- 播放音效播放
function PlayEffectId(_id, _func)
	Event.SOUNDSYS_EFFECT_PLAY.mData = {}
	Event.SOUNDSYS_EFFECT_PLAY.mData[1] = _id
	Event.SOUNDSYS_EFFECT_PLAY.mData[2] = _func
	EventSystem:PushEvent(Event.SOUNDSYS_EFFECT_PLAY)
end

-- 停止音效播放
function StopEffectId(id)
	Event.SOUNDSYS_EFFECT_STOP.mData = {}
	Event.SOUNDSYS_EFFECT_STOP.mData[1] = id
	EventSystem:PushEvent(Event.SOUNDSYS_EFFECT_STOP)
end

-- 预加载音效
function preloadEffect(_id)
	Event.SOUNDSYS_EFFECT_PRELOAD.mData = _id
	EventSystem:PushEvent(Event.SOUNDSYS_EFFECT_PRELOAD)
end


-- 预加载技能音效
-- @优化，过程ID相同则不重复加载
function preloadSkillSoundAndEffect(_skillList)
	if not _skillList then
	   doError("[ERROR]preloadSkillSoundAndEffect===_skillList is nil!!!")
	end
	local _displayIDList = {}
	local _seList = {}
	local _hseList = {}
	local _heList = {}
	local _bheList = {}
	for k,_skillID in pairs(_skillList) do
		if _skillID > 0 then
			local _skillDB = DB_SkillEssence.getDataById(_skillID)
			for num = 1, 32 do
				local _proID = _skillDB[ProcessID_Table[num]]
				if _proID == 0 then break end
				local function perloadActionbyID( _actionID )
					if _actionID > 0 and _displayIDList[_actionID] == nil then
							_displayIDList[_actionID] = 1
					    local _actionDB = DB_SkillDisplay.getDataById(_actionID)
					    -- -- 预加载音效
					    -- for k,_se in pairs(_actionDB.SoundEffect) do
					    -- 	if _se > 0 and _seList[_se] == nil then
					    -- 	   _seList[_se] = 1
					    -- 	   preloadEffect(_se)
					    -- 	end
					    -- end
					    local _hse = _actionDB.HitSoundEffect
						if _hse > 0 and _hseList[_hse] == nil then
							_hseList[_hse] = 1
							preloadEffect(_hse)
						end
						-- 预加载特效
						local _he = _actionDB.HitEffect
						if type(_he) == "table" and _heList[_he[1]] == nil then
						   _heList[_he[1]] = 1
						   preloadSpine_commonByResID(_he[1])
						end
						-- 预加载大招特效
						local _bhe = _actionDB.CastAnimation[1]
						if _bhe > 0 and _bheList[_bhe] == nil then
						   _bheList[_bhe] = 1
						   preloadSpine_commonByResID(_bhe)
						end
						_bhe = _actionDB.CastAnimation[2]
						if _bhe > 0 and _bheList[_bhe] == nil then
						   _bheList[_bhe] = 1
						   preloadSpine_commonByResID(_bhe)
						end
						-- 预加载地面特效
						local _ge = _actionDB.GroundGfxFile
						if _ge > 0 then
						   preloadSpine_commonByResID(_ge)
						end
						local _ge2 = _actionDB.ExtraGfxFile
						if _ge2 > 0 then
						   preloadSpine_commonByResID(_ge2)
						end
						-- 加载子物体
						local _sub = _actionDB.SubObjectModel
						if _sub > 0 then
						   preloadSpine_commonByResID(_sub)
						end
					end
				end
				local _proDB = DB_SkillProcess.getDataById(_proID)
				local _actionID = _proDB.ProcessDisplayID
				perloadActionbyID(_actionID)
				for i=1,8 do
					if _proDB[SubObjectID_Table[i]] > 0 then
						local subData = DB_SkillSubObject.getDataById(_proDB[SubObjectID_Table[i]])
						if subData.ProcessDisplayID > 0 then
							perloadActionbyID(subData.ProcessDisplayID)
						end
					end
				end
			end
		end
	end
end

-- 预加载人物音效
function preloadSoundList(_soundList)
	-- if not _soundList then
	--    doError("[ERROR]preloadSoundList===_soundList is nil!!!")
	-- end
	-- for k,_soundID in pairs(_soundList) do
	-- 	if _soundID > 0 then
	-- 		CommonAnimation.preloadEffect(_soundID)
	-- 	end
	-- end
end
------------------------------音效快捷接口------------------------------------