-- Name: TextureSystem
-- Func: 纹理贴图系统
-- Author: Johny

require "ResSystem/CocosCacheManager"
require "ResSystem/TextParseManager"

TextureSystem = {}
TextureSystem.mType = "TEXTURESYSTEM"

function TextureSystem:Init()
    cclog("=====TextureSystem:Init=====1")
    --
    require "ResSystem/ShaderManager"
    self.mShaderManager = ShaderManager
    require "ResSystem/SpineDataCacheManager"
    self.mSpineDataCacheManager = SpineDataCacheManager
    self.mSpineDataCacheManager:Init()
    --
    cclog("=====TextureSystem:Init=====2")
end

-- 第二次初始化，在GUiWidgetPool中调用
function TextureSystem:init2()
	self.mResDBPointer = DB_ResourceList.ResourceList
	-- 初始化控件缓存管理器
    CocosCacheManager:init()
    -- 初始化文本解析管理器
    TextParseManager:init()
end

function TextureSystem:Tick()
	CocosCacheManager:Tick()
	self.mSpineDataCacheManager:Tick()
end

function TextureSystem:Release()
	TextParseManager:destroy()
	-----
	self:UnLoadPublicTexture()
	self.mShaderManager:Release()
	self.mSpineDataCacheManager:Release()
	_G["TextureSystem"] = nil
	package.loaded["TextureSystem"] = nil
	package.loaded["ResSystem/TextureSystem"] = nil
end

-- 进入游戏时，GUIWidgetPool调用
function TextureSystem:LoadPublicTexture()
	local t1 = os.clock()
	if GAME_MODE == ENUM_GAMEMODE.debug then
		TextureSystem:LoadPlist("res/image/debug/debug.plist", true)
	end
	TextureSystem:LoadPlist("res/image/iconhero/item_iconhero.plist", true)
	TextureSystem:LoadPlist("res/image/iconitem/item_items.plist", true)
	TextureSystem:LoadPlist("res/image/iconitem/icon_hero.plist", true)
	TextureSystem:LoadPlist("res/image/diamond/item_diamond.plist", true)
	TextureSystem:LoadPlist("res/image/homewindow/NewHome0.plist", true)
	TextureSystem:LoadPlist("res/image/homewindow/HerolistCell.plist", true)
	local t2 = os.clock()
	cclog(string.format("[TextureSystem:LoadPublicTexture]Cost:  %.4fs", t2-t1))
end

function TextureSystem:UnLoadPublicTexture()
	local t1 = os.clock()
	if GAME_MODE == ENUM_GAMEMODE.debug then
		TextureSystem:UnLoadPlist("res/image/debug/debug.plist", true)
	end
	TextureSystem:UnLoadPlist("res/image/iconhero/item_iconhero.plist", true)
	TextureSystem:UnLoadPlist("res/image/iconitem/item_items.plist", true)
	TextureSystem:UnLoadPlist("res/image/iconitem/icon_hero.plist", true)
	TextureSystem:UnLoadPlist("res/image/diamond/item_diamond.plist", true)
	TextureSystem:UnLoadPlist("res/image/homewindow/NewHome0.plist", true)
	TextureSystem:UnLoadPlist("res/image/homewindow/HerolistCell.plist", true)
	self:unloadAllImage()
	TextureSystem:UnLoadAllUnusedTexture()
	local t2 = os.clock()
	cclog(string.format("[TextureSystem:UnLoadPublicTexture]Cost:  %.4fs", t2-t1))
end

-- 加载纹理图
function TextureSystem:LoadImage(_file)
	local _cache = cc.Director:getInstance():getTextureCache()
	_cache:addImage(_file)
end
-- 加载纹理图并设置引用+1
function TextureSystem:LoadImageWithRef1(_file)
	local _cache = cc.Director:getInstance():getTextureCache()
	local _tex = _cache:addImage(_file)
	if _tex then 
	   _tex:retain()
	end
end

function TextureSystem:UnLoadImage(_file)
	cc.Director:getInstance():getTextureCache():removeTextureForKey(_file)
end


function TextureSystem:LoadPlist(_file, ispublic)
	if ispublic == nil then ispublic = false end
	cc.SpriteFrameCache:getInstance():addSpriteFrames(_file, ispublic)
end

function TextureSystem:UnLoadPlist(_file, ispublic)
	if ispublic == nil then ispublic = false end
	cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile(_file, ispublic)
end

function TextureSystem:UnLoadAllUnusedPlist()
	local t1 = os.clock()
	cc.SpriteFrameCache:getInstance():removeUnusedSpriteFrames()
	local t2 = os.clock()
	cclog(string.format("[TextureSystem:UnLoadAllUnusedPlist]Cost:  %.4fs", t2-t1))
end


--@释放无用纹理
function TextureSystem:UnLoadAllUnusedTexture()
	local t1 = os.clock()
	cc.Director:getInstance():getTextureCache():removeUnusedTextures()
	local t2 = os.clock()
	cclog(string.format("[TextureSystem:UnLoadAllUnusedTexture]Cost:  %.4fs", t2-t1))
end

--@释放全部纹理
function TextureSystem:UnLoadAllTexture()
	local t1 = os.clock()
	cc.Director:getInstance():getTextureCache():removeAllTextures()
	local t2 = os.clock()
	cclog(string.format("[TextureSystem:removeAllTextures]Cost:  %.4fs", t2-t1))
end

--@查看当前纹理内存占用情况
function TextureSystem:logTextureCacheInfo()
	if GAME_MODE == ENUM_GAMEMODE.debug then
		cc.Director:getInstance():getTextureCache():getCachedTextureInfo()
	end
end


--@接收事件
function TextureSystem:onEventHandler(event)

end



-----------------------load大图快速接口---------------------------
-- 主城镇场景各界面大图
function TextureSystem:loadPlist_HomeScene()
	TextureSystem:LoadPlist("res/image/homewindow/Welfare0.plist")
end
function TextureSystem:unloadPlist_HomeScene()
	TextureSystem:UnLoadPlist("res/image/homewindow/Welfare0.plist")
end

-- 技能图标
function TextureSystem:loadPlist_iconskill()
	TextureSystem:LoadPlist("res/image/iconskill/icon_skill.plist")
end
function TextureSystem:unloadPlist_iconskill()
	TextureSystem:UnLoadPlist("res/image/iconskill/icon_skill.plist")
end

-- pve板块图
function TextureSystem:loadPlist_pvesection()
	TextureSystem:LoadPlist("res/image/pve/pve_section1.plist")
	TextureSystem:LoadPlist("res/image/pve/pve_section2.plist")
	TextureSystem:LoadPlist("res/image/pve/pve_section3.plist")
	TextureSystem:LoadPlist("res/image/pve/pve_section4.plist")
	TextureSystem:LoadPlist("res/image/pve/pve_section5.plist")
	TextureSystem:LoadPlist("res/image/pve/pve_section6.plist")
	TextureSystem:LoadPlist("res/image/pve/pve_section7.plist")
	TextureSystem:LoadPlist("res/image/pve/pve_section8.plist")
	TextureSystem:LoadPlist("res/image/pve/pve_section9.plist")
	TextureSystem:LoadPlist("res/image/pve/pve_section10.plist")
end
function TextureSystem:unloadPlist_pvesection()
	TextureSystem:UnLoadPlist("res/image/pve/pve_section1.plist")
	TextureSystem:UnLoadPlist("res/image/pve/pve_section2.plist")
	TextureSystem:UnLoadPlist("res/image/pve/pve_section3.plist")
	TextureSystem:UnLoadPlist("res/image/pve/pve_section4.plist")
	TextureSystem:UnLoadPlist("res/image/pve/pve_section5.plist")
	TextureSystem:UnLoadPlist("res/image/pve/pve_section6.plist")
	TextureSystem:UnLoadPlist("res/image/pve/pve_section7.plist")
	TextureSystem:UnLoadPlist("res/image/pve/pve_section8.plist")
	TextureSystem:UnLoadPlist("res/image/pve/pve_section9.plist")
	TextureSystem:UnLoadPlist("res/image/pve/pve_section10.plist")
end

-- 星座图标大图
function TextureSystem:loadPlist_zodiac()
	TextureSystem:LoadPlist("res/image/icontech/icon_tech.plist")
end
function TextureSystem:unloadPlist_zodiac()
	TextureSystem:UnLoadPlist("res/image/icontech/icon_tech.plist")
end
-----------------load小图快捷接口-----------------------
-- 加载ResourceList中的所有图,并且引用计数+1
function TextureSystem:loadAllImageWithRef1()
	local t1 = os.clock()
	for k,v in pairs(self.mResDBPointer) do
		for k,_value in pairs(v) do
			if type(_value) == "string" and string.find(_value, ".png") and string.find(_value, "/") then
			   self:LoadImageWithRef1(_value)
			end
		end
	end
	local t2 = os.clock()
	cclog(string.format("[TextureSystem:loadAllImageWithRef1]Cost:  %.4fs", t2-t1))
end

function TextureSystem:unloadAllImage()
	if not self.mResDBPointer then return end
	local t1 = os.clock()
	for k,v in pairs(self.mResDBPointer) do
		for k,_value in pairs(v) do
			if type(_value) == "string" and string.find(_value, ".png") and string.find(_value, "/") then
			   self:UnLoadImage(_value)
			end
		end
	end
	local t2 = os.clock()
	cclog(string.format("[TextureSystem:unloadAllImage]Cost:  %.4fs", t2-t1))
end